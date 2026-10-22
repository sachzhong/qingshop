package cn.iocoder.yudao.module.aiops.service;

import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.common.util.json.JsonUtils;
import cn.iocoder.yudao.module.aiops.controller.admin.vo.AiOpsLogPageReqVO;
import cn.iocoder.yudao.module.aiops.controller.admin.vo.AiOpsRunResultVO;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsConfigDO;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsPriceLogDO;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsSkuStatBO;
import cn.iocoder.yudao.module.aiops.dal.mysql.AiOpsPriceLogMapper;
import cn.iocoder.yudao.module.aiops.dal.mysql.AiOpsProductMapper;
import cn.iocoder.yudao.module.aiops.enums.AiOpsLogStatusEnum;
import cn.iocoder.yudao.module.aiops.enums.AiOpsModeEnum;
import cn.iocoder.yudao.module.aiops.framework.llm.AiOpsLlmClient;
import com.fasterxml.jackson.databind.JsonNode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.invalidParamException;

/**
 * 智能定价：规则引擎给出方向和幅度 → 大模型结合数据给出建议价和理由 → 护栏截断 → SUGGEST 待审批 / AUTO 自动执行
 */
@Service
@Slf4j
public class AiOpsPriceService {

    private static final String SYSTEM_PROMPT = "你是电商定价分析师。根据每个 SKU 的经营数据和规则引擎的初步建议，给出建议售价（单位：分，整数）和简短中文理由。"
            + "要求：1) 只能在给定的 [minPrice, maxPrice] 区间内；2) 数据不足或无明显信号时维持当前价；3) 不要编造数据。"
            + "只输出 JSON：{\"items\":[{\"skuId\":数字,\"price\":数字,\"reason\":\"不超过60字\"}]}";

    private final Set<String> running = ConcurrentHashMap.newKeySet();

    @Resource
    private AiOpsConfigService configService;
    @Resource
    private AiOpsProductMapper productMapper;
    @Resource
    private AiOpsPriceLogMapper priceLogMapper;
    @Resource
    private AiOpsLlmClient llmClient;
    /** 通过代理调用，保证 approve 的事务生效 */
    @Resource
    @org.springframework.context.annotation.Lazy
    private AiOpsPriceService self;

    /** 规则引擎的输出 */
    static class RuleDecision {
        double changeRatio;
        String reason;

        RuleDecision(double changeRatio, String reason) {
            this.changeRatio = changeRatio;
            this.reason = reason;
        }
    }

    static RuleDecision rule(AiOpsSkuStatBO s, int statDays) {
        long daysOnShelf = s.getSpuCreateTime() == null ? 0 : Duration.between(s.getSpuCreateTime(), LocalDateTime.now()).toDays();
        int sales = nz(s.getSalesQty());
        int stock = nz(s.getStock());
        double velocity = sales / (double) statDays;
        double stockDays = velocity > 0 ? stock / velocity : Double.MAX_VALUE;
        Integer browse = s.getBrowseCount();
        double conversion = browse != null && browse > 0 ? nz(s.getOrderCount()) / (double) browse : -1;
        if (stock <= 0) {
            return new RuleDecision(0, "无库存，不调价");
        }
        if (sales > 0 && nz(s.getRefundQty()) / (double) sales > 0.3) {
            return new RuleDecision(0, "退款率超过 30%，先排查商品问题，不调价");
        }
        if (sales == 0 && daysOnShelf >= 7) {
            return new RuleDecision(-0.08, "上架 " + daysOnShelf + " 天、近 " + statDays + " 天零销量，建议降价促销");
        }
        if (sales >= 3 && stockDays < 7) {
            return new RuleDecision(0.06, String.format("畅销且库存仅够约 %.1f 天，建议小幅提价", stockDays));
        }
        if (conversion >= 0.10 && stockDays > 30) {
            return new RuleDecision(0.03, String.format("转化率 %.1f%% 较高且库存充足，可小幅提价", conversion * 100));
        }
        if (daysOnShelf < 7) {
            return new RuleDecision(0, "新品观察期（上架不足 7 天），维持原价");
        }
        return new RuleDecision(0, "无明显信号，维持原价");
    }

    public AiOpsRunResultVO run(Long spuId, boolean useLlm) {
        AiOpsConfigDO config = configService.getOrCreate();
        String lockKey = String.valueOf(cn.iocoder.yudao.framework.tenant.core.context.TenantContextHolder.getTenantId());
        if (!running.add(lockKey)) {
            throw invalidParamException("智能定价正在运行中，请稍后再试");
        }
        try {
            return doRun(config, spuId, useLlm);
        } finally {
            running.remove(lockKey);
        }
    }

    private AiOpsRunResultVO doRun(AiOpsConfigDO config, Long spuId, boolean useLlm) {
        AiOpsRunResultVO result = new AiOpsRunResultVO();
        result.setRunId("P" + IdUtil.getSnowflakeNextIdStr());
        result.setMode(config.getPriceMode());
        int statDays = config.getStatDays() == null ? 30 : config.getStatDays();
        List<AiOpsSkuStatBO> stats = productMapper.selectSkuStats(LocalDateTime.now().minusDays(statDays), spuId);
        result.setScanned(stats.size());
        LocalDateTime cooldownSince = LocalDateTime.now().minusHours(config.getCooldownHours() == null ? 72 : config.getCooldownHours());
        Map<Long, List<AiOpsSkuStatBO>> bySpu = stats.stream().collect(Collectors.groupingBy(AiOpsSkuStatBO::getSpuId, LinkedHashMap::new, Collectors.toList()));
        for (List<AiOpsSkuStatBO> group : bySpu.values()) {
            List<AiOpsSkuStatBO> todo = new ArrayList<>();
            for (AiOpsSkuStatBO s : group) {
                if (priceLogMapper.existsRecent(s.getSkuId(), cooldownSince)) {
                    result.setSkipped(result.getSkipped() + 1);
                } else {
                    todo.add(s);
                }
            }
            if (todo.isEmpty()) {
                continue;
            }
            // 1. 规则
            Map<Long, RuleDecision> rules = new HashMap<>();
            Map<Long, AiOpsGuardrail.Result> bounds = new HashMap<>();
            for (AiOpsSkuStatBO s : todo) {
                rules.put(s.getSkuId(), rule(s, statDays));
                // 用一个“不可能”的候选价求出区间上下限
                AiOpsGuardrail.Result lo = guard(config, s, 0);
                AiOpsGuardrail.Result hi = guard(config, s, Integer.MAX_VALUE / 2);
                bounds.put(s.getSkuId(), new AiOpsGuardrail.Result(0, lo.getPrice(), hi.getPrice(), null, lo.isBlocked()));
            }
            // 2. 大模型
            Map<Long, JsonNode> llm = new HashMap<>();
            if (useLlm) {
                try {
                    llm = askLlm(config, todo, rules, bounds, statDays);
                    result.setLlmUsed(true);
                } catch (Exception e) {
                    log.warn("[doRun][spu({}) 大模型调用失败，回退到规则]", todo.get(0).getSpuId(), e);
                    result.getMessages().add("SPU " + todo.get(0).getSpuId() + " 大模型调用失败，已回退规则：" + StrUtil.subPre(e.getMessage(), 120));
                    result.setErrors(result.getErrors() + 1);
                }
            }
            // 3. 护栏 + 落库
            for (AiOpsSkuStatBO s : todo) {
                RuleDecision rd = rules.get(s.getSkuId());
                int current = s.getPrice();
                int rulePrice = (int) Math.round(current * (1 + rd.changeRatio));
                JsonNode item = llm.get(s.getSkuId());
                Integer llmPrice = item != null && item.hasNonNull("price") ? item.get("price").asInt() : null;
                int candidate = llmPrice != null ? llmPrice : rulePrice;
                AiOpsGuardrail.Result g = guard(config, s, candidate);
                if (g.isBlocked() || g.getPrice() == current) {
                    result.setHeld(result.getHeld() + 1);
                    result.getMessages().add("SKU " + s.getSkuId() + " 维持 " + current + "：" + (item != null ? item.path("reason").asText(rd.reason) : rd.reason)
                            + (g.getNote() != null ? "（" + g.getNote() + "）" : ""));
                    continue;
                }
                AiOpsPriceLogDO logDO = new AiOpsPriceLogDO();
                logDO.setRunId(result.getRunId());
                logDO.setSpuId(s.getSpuId());
                logDO.setSpuName(s.getSpuName());
                logDO.setSkuId(s.getSkuId());
                logDO.setSkuName(skuName(s.getSkuProperties()));
                logDO.setOldPrice(current);
                logDO.setRulePrice(rulePrice);
                logDO.setLlmPrice(llmPrice);
                logDO.setNewPrice(g.getPrice());
                logDO.setFloorPrice(g.getFloor());
                logDO.setCeilPrice(g.getCeil());
                logDO.setCostPrice(s.getCostPrice());
                logDO.setRuleReason(rd.reason);
                logDO.setReason(item != null ? StrUtil.subPre(item.path("reason").asText(""), 500) : "（未使用大模型）" + rd.reason);
                logDO.setGuardNote(g.getNote());
                logDO.setStats(JsonUtils.toJsonString(s));
                logDO.setMode(config.getPriceMode());
                logDO.setStatus(AiOpsLogStatusEnum.PENDING.getStatus());
                priceLogMapper.insert(logDO);
                result.setSuggested(result.getSuggested() + 1);
                if (AiOpsModeEnum.isAuto(config.getPriceMode())) {
                    try {
                        self.approve(logDO.getId());
                        result.setApplied(result.getApplied() + 1);
                    } catch (Exception e) {
                        result.getMessages().add("SKU " + s.getSkuId() + " 自动执行失败：" + e.getMessage());
                        result.setErrors(result.getErrors() + 1);
                    }
                }
            }
        }
        log.info("[doRun][定价运行完成 {}]", result);
        return result;
    }

    private Map<Long, JsonNode> askLlm(AiOpsConfigDO config, List<AiOpsSkuStatBO> todo, Map<Long, RuleDecision> rules,
                                       Map<Long, AiOpsGuardrail.Result> bounds, int statDays) {
        List<Map<String, Object>> rows = new ArrayList<>();
        for (AiOpsSkuStatBO s : todo) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("skuId", s.getSkuId());
            m.put("商品", s.getSpuName() + " " + skuName(s.getSkuProperties()));
            m.put("当前价", s.getPrice());
            m.put("成本价", s.getCostPrice());
            m.put("划线价", s.getMarketPrice());
            m.put("库存", s.getStock());
            m.put("近" + statDays + "天销量", s.getSalesQty());
            m.put("近" + statDays + "天订单数", s.getOrderCount());
            m.put("近" + statDays + "天退款件数", s.getRefundQty());
            m.put("商品浏览量", s.getBrowseCount());
            m.put("上架天数", s.getSpuCreateTime() == null ? null : Duration.between(s.getSpuCreateTime(), LocalDateTime.now()).toDays());
            m.put("规则建议", rules.get(s.getSkuId()).reason);
            m.put("minPrice", bounds.get(s.getSkuId()).getFloor());
            m.put("maxPrice", bounds.get(s.getSkuId()).getCeil());
            rows.add(m);
        }
        JsonNode root = llmClient.chatJson(config, SYSTEM_PROMPT, "SKU 数据（价格单位：分）：\n" + JsonUtils.toJsonString(rows));
        Map<Long, JsonNode> map = new HashMap<>();
        for (JsonNode n : root.path("items")) {
            map.put(n.path("skuId").asLong(), n);
        }
        return map;
    }

    private static AiOpsGuardrail.Result guard(AiOpsConfigDO c, AiOpsSkuStatBO s, int candidate) {
        return AiOpsGuardrail.apply(s.getPrice(), s.getCostPrice(), candidate, c.getFloorCostRatio(), c.getFloorCurrentRatio(),
                c.getCeilRatio(), c.getMaxChangeRatio());
    }

    @Transactional(rollbackFor = Exception.class)
    public void approve(Long id) {
        AiOpsPriceLogDO logDO = getLog(id, AiOpsLogStatusEnum.PENDING);
        // 执行前再校验一次：建议价必须在记录的底价/顶价之内
        if (logDO.getNewPrice() < logDO.getFloorPrice() || logDO.getNewPrice() > logDO.getCeilPrice()) {
            throw invalidParamException("建议价超出护栏区间，拒绝执行");
        }
        if (productMapper.updateSkuPrice(logDO.getSkuId(), logDO.getOldPrice(), logDO.getNewPrice()) == 0) {
            throw invalidParamException("SKU 当前价格已不是 " + logDO.getOldPrice() + "（可能被人工修改），请重新运行定价");
        }
        refreshSpuPrice(logDO.getSpuId());
        AiOpsPriceLogDO update = new AiOpsPriceLogDO();
        update.setId(id);
        update.setStatus(AiOpsLogStatusEnum.APPLIED.getStatus());
        update.setApplyTime(LocalDateTime.now());
        priceLogMapper.updateById(update);
    }

    public void reject(Long id) {
        getLog(id, AiOpsLogStatusEnum.PENDING);
        AiOpsPriceLogDO update = new AiOpsPriceLogDO();
        update.setId(id);
        update.setStatus(AiOpsLogStatusEnum.REJECTED.getStatus());
        priceLogMapper.updateById(update);
    }

    @Transactional(rollbackFor = Exception.class)
    public void rollback(Long id) {
        AiOpsPriceLogDO logDO = getLog(id, AiOpsLogStatusEnum.APPLIED);
        if (productMapper.updateSkuPrice(logDO.getSkuId(), logDO.getNewPrice(), logDO.getOldPrice()) == 0) {
            throw invalidParamException("SKU 当前价格已不是 " + logDO.getNewPrice() + "，无法自动回滚");
        }
        refreshSpuPrice(logDO.getSpuId());
        AiOpsPriceLogDO update = new AiOpsPriceLogDO();
        update.setId(id);
        update.setStatus(AiOpsLogStatusEnum.ROLLED_BACK.getStatus());
        update.setRollbackTime(LocalDateTime.now());
        priceLogMapper.updateById(update);
    }

    public PageResult<AiOpsPriceLogDO> getPage(AiOpsLogPageReqVO reqVO) {
        return priceLogMapper.selectPage(reqVO);
    }

    private void refreshSpuPrice(Long spuId) {
        Integer min = productMapper.selectMinSkuPrice(spuId);
        if (min != null) {
            productMapper.updateSpuPrice(spuId, min);
        }
    }

    private AiOpsPriceLogDO getLog(Long id, AiOpsLogStatusEnum expect) {
        AiOpsPriceLogDO logDO = priceLogMapper.selectById(id);
        if (logDO == null) {
            throw invalidParamException("调价记录不存在");
        }
        if (!expect.getStatus().equals(logDO.getStatus())) {
            throw invalidParamException("调价记录状态不是「" + expect.getName() + "」");
        }
        return logDO;
    }

    static String skuName(String propertiesJson) {
        if (StrUtil.isBlank(propertiesJson)) {
            return "";
        }
        try {
            List<String> names = new ArrayList<>();
            for (JsonNode n : JsonUtils.parseTree(propertiesJson)) {
                names.add(n.path("valueName").asText());
            }
            return String.join("/", names);
        } catch (Exception e) {
            return "";
        }
    }

    private static int nz(Integer v) {
        return v == null ? 0 : v;
    }

}
