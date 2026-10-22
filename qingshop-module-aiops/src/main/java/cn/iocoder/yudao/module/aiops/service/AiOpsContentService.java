package cn.iocoder.yudao.module.aiops.service;

import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.json.JsonUtils;
import cn.iocoder.yudao.module.aiops.controller.admin.vo.AiOpsLogPageReqVO;
import cn.iocoder.yudao.module.aiops.controller.admin.vo.AiOpsRunResultVO;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsConfigDO;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsContentLogDO;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsSpuBO;
import cn.iocoder.yudao.module.aiops.dal.mysql.AiOpsContentLogMapper;
import cn.iocoder.yudao.module.aiops.dal.mysql.AiOpsProductMapper;
import cn.iocoder.yudao.module.aiops.enums.AiOpsLogStatusEnum;
import cn.iocoder.yudao.module.aiops.enums.AiOpsModeEnum;
import cn.iocoder.yudao.module.aiops.framework.llm.AiOpsLlmClient;
import cn.iocoder.yudao.module.infra.api.file.FileApi;
import com.fasterxml.jackson.databind.JsonNode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.*;
import java.util.regex.Pattern;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.invalidParamException;

/**
 * 商品内容优化：大模型根据商品现状与销售表现改写标题 / 副标题 / 关键词 / 卖点 / 详情，并给出图片提示词
 */
@Service
@Slf4j
public class AiOpsContentService {

    private static final String SYSTEM_PROMPT = "你是资深电商文案。根据商品现有信息和销售数据，改写商品内容以提升点击率和转化率。"
            + "要求：1) 不得编造参数、材质、认证、功效等原文没有的事实；2) 遵守广告法，不用“最、第一、顶级、国家级、100%”等极限词；"
            + "3) name 不超过 40 字，introduction 不超过 60 字，keyword 用空格分隔不超过 5 个；4) description 为简洁 HTML，只用 p/ul/li/strong 标签；"
            + "5) imagePrompts 给 2 条英文商品主图生成提示词。只输出 JSON："
            + "{\"name\":\"\",\"introduction\":\"\",\"keyword\":\"\",\"sellingPoints\":[\"\"],\"description\":\"\",\"imagePrompts\":[\"\"],\"reason\":\"改写思路，不超过80字\"}";

    private static final List<String> BANNED = Arrays.asList("最佳", "最好", "最强", "最低价", "第一", "顶级", "国家级", "极致", "100%", "万能");
    private static final Pattern DANGEROUS_TAG = Pattern.compile("(?is)<(script|iframe|style|object|embed|form)[^>]*>.*?</\\1>|<(script|iframe|style|object|embed|form)[^>]*/?>");
    private static final Pattern EVENT_ATTR = Pattern.compile("(?i)\\s+on\\w+\\s*=\\s*(\"[^\"]*\"|'[^']*'|[^\\s>]+)");
    private static final Pattern JS_URL = Pattern.compile("(?i)javascript:");

    @Resource
    private AiOpsConfigService configService;
    @Resource
    private AiOpsProductMapper productMapper;
    @Resource
    private AiOpsContentLogMapper contentLogMapper;
    @Resource
    private AiOpsLlmClient llmClient;
    @Resource
    private FileApi fileApi;

    public AiOpsRunResultVO run(Long spuId) {
        AiOpsConfigDO config = configService.getOrCreate();
        AiOpsRunResultVO result = new AiOpsRunResultVO();
        result.setRunId("C" + IdUtil.getSnowflakeNextIdStr());
        result.setMode(config.getContentMode());
        result.setLlmUsed(true);
        int statDays = config.getStatDays() == null ? 30 : config.getStatDays();
        List<AiOpsSpuBO> spus = productMapper.selectSpus(LocalDateTime.now().minusDays(statDays), spuId);
        result.setScanned(spus.size());
        LocalDateTime since = LocalDateTime.now().minusHours(config.getContentCooldownHours() == null ? 168 : config.getContentCooldownHours());
        int limit = spuId != null ? 1 : (config.getContentMaxSpu() == null ? 5 : config.getContentMaxSpu());
        // 优先处理“有浏览没成交”的商品
        spus.sort(Comparator.comparingDouble(AiOpsContentService::conversion));
        int done = 0;
        for (AiOpsSpuBO spu : spus) {
            if (done >= limit) {
                break;
            }
            if (contentLogMapper.existsRecent(spu.getId(), since)) {
                result.setSkipped(result.getSkipped() + 1);
                continue;
            }
            done++;
            try {
                AiOpsContentLogDO logDO = generate(config, spu, statDays);
                logDO.setRunId(result.getRunId());
                contentLogMapper.insert(logDO);
                result.setSuggested(result.getSuggested() + 1);
                if (AiOpsModeEnum.isAuto(config.getContentMode())) {
                    approve(logDO.getId());
                    result.setApplied(result.getApplied() + 1);
                }
            } catch (Exception e) {
                log.warn("[run][spu({}) 内容优化失败]", spu.getId(), e);
                result.setErrors(result.getErrors() + 1);
                result.getMessages().add("SPU " + spu.getId() + " 失败：" + StrUtil.subPre(e.getMessage(), 150));
            }
        }
        return result;
    }

    private AiOpsContentLogDO generate(AiOpsConfigDO config, AiOpsSpuBO spu, int statDays) {
        Map<String, Object> input = new LinkedHashMap<>();
        input.put("当前标题", spu.getName());
        input.put("当前副标题", spu.getIntroduction());
        input.put("当前关键词", spu.getKeyword());
        input.put("当前详情", StrUtil.subPre(spu.getDescription(), 3000));
        input.put("分类", spu.getCategoryName());
        input.put("售价(分)", spu.getPrice());
        input.put("库存", spu.getStock());
        input.put("浏览量", spu.getBrowseCount());
        input.put("近" + statDays + "天销量", spu.getSalesQty());
        input.put("近" + statDays + "天订单数", spu.getOrderCount());
        JsonNode r = llmClient.chatJson(config, SYSTEM_PROMPT, JsonUtils.toJsonString(input));

        AiOpsContentLogDO logDO = new AiOpsContentLogDO();
        logDO.setSpuId(spu.getId());
        logDO.setOldName(spu.getName());
        logDO.setOldIntroduction(spu.getIntroduction());
        logDO.setOldKeyword(spu.getKeyword());
        logDO.setOldDescription(spu.getDescription());
        String name = clean(r.path("name").asText(""), 60);
        if (StrUtil.isBlank(name)) {
            throw new IllegalStateException("大模型没有返回标题");
        }
        logDO.setNewName(name);
        logDO.setNewIntroduction(StrUtil.blankToDefault(clean(r.path("introduction").asText(""), 120), spu.getIntroduction()));
        logDO.setNewKeyword(StrUtil.blankToDefault(clean(r.path("keyword").asText(""), 60), spu.getKeyword()));
        List<String> points = new ArrayList<>();
        for (JsonNode n : r.path("sellingPoints")) {
            String p = clean(n.asText(""), 40);
            if (StrUtil.isNotBlank(p)) {
                points.add(p);
            }
        }
        logDO.setSellingPoints(JsonUtils.toJsonString(points));
        StringBuilder desc = new StringBuilder();
        if (!points.isEmpty()) {
            desc.append("<ul class=\"qs-selling-points\">");
            for (String p : points) {
                desc.append("<li>").append(escape(p)).append("</li>");
            }
            desc.append("</ul>");
        }
        desc.append(sanitizeHtml(r.path("description").asText("")));
        logDO.setNewDescription(StrUtil.subPre(desc.toString(), 20000));
        List<String> prompts = new ArrayList<>();
        for (JsonNode n : r.path("imagePrompts")) {
            prompts.add(StrUtil.subPre(n.asText(""), 500));
        }
        logDO.setImagePrompts(JsonUtils.toJsonString(prompts));
        logDO.setReason(StrUtil.subPre(r.path("reason").asText(""), 500));
        logDO.setStats(JsonUtils.toJsonString(input));
        logDO.setMode(config.getContentMode());
        logDO.setStatus(AiOpsLogStatusEnum.PENDING.getStatus());
        fillImages(config, logDO, prompts);
        return logDO;
    }

    /** 配置了图片接口才生成并上传到 infra 文件存储；否则只保存提示词，状态为“待生成” */
    private void fillImages(AiOpsConfigDO config, AiOpsContentLogDO logDO, List<String> prompts) {
        if (prompts.isEmpty()) {
            logDO.setImageStatus(0);
            return;
        }
        if (StrUtil.isBlank(config.getImageBaseUrl()) || StrUtil.isBlank(AiOpsLlmClient.resolveKey(config.getImageKeyEnv()))) {
            logDO.setImageStatus(1);
            return;
        }
        try {
            byte[] img = llmClient.generateImage(config, prompts.get(0));
            String url = fileApi.createFile(img, "aiops-spu-" + logDO.getSpuId() + ".png", "aiops", "image/png");
            logDO.setImageUrls(JsonUtils.toJsonString(Collections.singletonList(url)));
            logDO.setImageStatus(2);
        } catch (Exception e) {
            log.warn("[fillImages][spu({}) 图片生成失败]", logDO.getSpuId(), e);
            logDO.setImageStatus(3);
        }
    }

    public void approve(Long id) {
        AiOpsContentLogDO logDO = getLog(id, AiOpsLogStatusEnum.PENDING);
        productMapper.updateSpuContent(logDO.getSpuId(), logDO.getNewName(), logDO.getNewIntroduction(), logDO.getNewKeyword(), logDO.getNewDescription());
        AiOpsContentLogDO update = new AiOpsContentLogDO();
        update.setId(id);
        update.setStatus(AiOpsLogStatusEnum.APPLIED.getStatus());
        update.setApplyTime(LocalDateTime.now());
        contentLogMapper.updateById(update);
    }

    public void reject(Long id) {
        getLog(id, AiOpsLogStatusEnum.PENDING);
        AiOpsContentLogDO update = new AiOpsContentLogDO();
        update.setId(id);
        update.setStatus(AiOpsLogStatusEnum.REJECTED.getStatus());
        contentLogMapper.updateById(update);
    }

    /** 回滚到 A 版本（改写前的内容） */
    public void rollback(Long id) {
        AiOpsContentLogDO logDO = getLog(id, AiOpsLogStatusEnum.APPLIED);
        productMapper.updateSpuContent(logDO.getSpuId(), logDO.getOldName(), logDO.getOldIntroduction(), logDO.getOldKeyword(), logDO.getOldDescription());
        AiOpsContentLogDO update = new AiOpsContentLogDO();
        update.setId(id);
        update.setStatus(AiOpsLogStatusEnum.ROLLED_BACK.getStatus());
        update.setRollbackTime(LocalDateTime.now());
        contentLogMapper.updateById(update);
    }

    public PageResult<AiOpsContentLogDO> getPage(AiOpsLogPageReqVO reqVO) {
        return contentLogMapper.selectPage(reqVO);
    }

    private AiOpsContentLogDO getLog(Long id, AiOpsLogStatusEnum expect) {
        AiOpsContentLogDO logDO = contentLogMapper.selectById(id);
        if (logDO == null) {
            throw invalidParamException("内容记录不存在");
        }
        if (!expect.getStatus().equals(logDO.getStatus())) {
            throw invalidParamException("内容记录状态不是「" + expect.getName() + "」");
        }
        return logDO;
    }

    private static double conversion(AiOpsSpuBO s) {
        int browse = s.getBrowseCount() == null ? 0 : s.getBrowseCount();
        return browse == 0 ? 1 : (s.getOrderCount() == null ? 0 : s.getOrderCount()) / (double) browse;
    }

    /** 去掉 HTML、极限词，并截断 */
    static String clean(String s, int max) {
        String v = StrUtil.trim(s.replaceAll("<[^>]*>", ""));
        for (String w : BANNED) {
            v = v.replace(w, "");
        }
        return StrUtil.subPre(v, max);
    }

    static String sanitizeHtml(String html) {
        String v = DANGEROUS_TAG.matcher(StrUtil.nullToEmpty(html)).replaceAll("");
        v = EVENT_ATTR.matcher(v).replaceAll("");
        v = JS_URL.matcher(v).replaceAll("");
        for (String w : BANNED) {
            v = v.replace(w, "");
        }
        return v;
    }

    private static String escape(String s) {
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }

}
