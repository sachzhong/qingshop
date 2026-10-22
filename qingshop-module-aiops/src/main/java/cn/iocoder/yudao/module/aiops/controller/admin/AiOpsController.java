package cn.iocoder.yudao.module.aiops.controller.admin;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import cn.iocoder.yudao.framework.common.pojo.CommonResult;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.aiops.controller.admin.vo.AiOpsConfigSaveReqVO;
import cn.iocoder.yudao.module.aiops.controller.admin.vo.AiOpsLogPageReqVO;
import cn.iocoder.yudao.module.aiops.controller.admin.vo.AiOpsRunResultVO;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsConfigDO;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsContentLogDO;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsPriceLogDO;
import cn.iocoder.yudao.module.aiops.framework.llm.AiOpsLlmClient;
import cn.iocoder.yudao.module.aiops.service.AiOpsConfigService;
import cn.iocoder.yudao.module.aiops.service.AiOpsContentService;
import cn.iocoder.yudao.module.aiops.service.AiOpsPriceService;
import com.fasterxml.jackson.databind.JsonNode;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.LinkedHashMap;
import java.util.Map;

import static cn.iocoder.yudao.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - AI 运营")
@RestController
@RequestMapping("/aiops")
@Validated
public class AiOpsController {

    @Resource
    private AiOpsConfigService configService;
    @Resource
    private AiOpsPriceService priceService;
    @Resource
    private AiOpsContentService contentService;
    @Resource
    private AiOpsLlmClient llmClient;

    // ========== 配置 ==========

    @GetMapping("/config/get")
    @Operation(summary = "获得 AI 运营配置")
    @PreAuthorize("@ss.hasPermission('aiops:config:query')")
    public CommonResult<Map<String, Object>> getConfig() {
        AiOpsConfigDO config = configService.getOrCreate();
        Map<String, Object> map = BeanUtil.beanToMap(config);
        // 只告诉前端环境变量是否已设置，不返回 Key
        map.put("llmKeyPresent", StrUtil.isNotBlank(AiOpsLlmClient.resolveKey(config.getLlmKeyEnv())));
        map.put("imageKeyPresent", StrUtil.isNotBlank(AiOpsLlmClient.resolveKey(config.getImageKeyEnv())));
        return success(map);
    }

    @PutMapping("/config/update")
    @Operation(summary = "更新 AI 运营配置")
    @PreAuthorize("@ss.hasPermission('aiops:config:update')")
    public CommonResult<Boolean> updateConfig(@RequestBody AiOpsConfigSaveReqVO reqVO) {
        configService.update(BeanUtil.toBean(reqVO, AiOpsConfigDO.class));
        return success(true);
    }

    @PostMapping("/config/test-llm")
    @Operation(summary = "测试大模型连通性")
    @PreAuthorize("@ss.hasPermission('aiops:config:update')")
    public CommonResult<Map<String, Object>> testLlm() {
        AiOpsConfigDO config = configService.getOrCreate();
        long start = System.currentTimeMillis();
        JsonNode node = llmClient.chatJson(config, "只输出 JSON。", "返回 {\"ok\":true}");
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("ok", node.path("ok").asBoolean(false));
        map.put("model", config.getLlmModel());
        map.put("costMs", System.currentTimeMillis() - start);
        return success(map);
    }

    // ========== 智能定价 ==========

    @PostMapping("/price/run")
    @Operation(summary = "手动运行智能定价")
    @PreAuthorize("@ss.hasPermission('aiops:price:run')")
    public CommonResult<AiOpsRunResultVO> runPrice(@RequestParam(value = "spuId", required = false) Long spuId,
                                                   @RequestParam(value = "useLlm", defaultValue = "true") Boolean useLlm) {
        return success(priceService.run(spuId, useLlm));
    }

    @GetMapping("/price-log/page")
    @Operation(summary = "调价记录分页")
    @PreAuthorize("@ss.hasPermission('aiops:price:query')")
    public CommonResult<PageResult<AiOpsPriceLogDO>> getPricePage(AiOpsLogPageReqVO reqVO) {
        return success(priceService.getPage(reqVO));
    }

    @PutMapping("/price-log/approve")
    @Operation(summary = "批准调价建议")
    @PreAuthorize("@ss.hasPermission('aiops:price:audit')")
    public CommonResult<Boolean> approvePrice(@RequestParam("id") Long id) {
        priceService.approve(id);
        return success(true);
    }

    @PutMapping("/price-log/reject")
    @Operation(summary = "拒绝调价建议")
    @PreAuthorize("@ss.hasPermission('aiops:price:audit')")
    public CommonResult<Boolean> rejectPrice(@RequestParam("id") Long id) {
        priceService.reject(id);
        return success(true);
    }

    @PutMapping("/price-log/rollback")
    @Operation(summary = "回滚已执行的调价")
    @PreAuthorize("@ss.hasPermission('aiops:price:audit')")
    public CommonResult<Boolean> rollbackPrice(@RequestParam("id") Long id) {
        priceService.rollback(id);
        return success(true);
    }

    // ========== 内容优化 ==========

    @PostMapping("/content/run")
    @Operation(summary = "手动运行内容优化")
    @PreAuthorize("@ss.hasPermission('aiops:content:run')")
    public CommonResult<AiOpsRunResultVO> runContent(@RequestParam(value = "spuId", required = false) Long spuId) {
        return success(contentService.run(spuId));
    }

    @GetMapping("/content-log/page")
    @Operation(summary = "内容改写记录分页")
    @PreAuthorize("@ss.hasPermission('aiops:content:query')")
    public CommonResult<PageResult<AiOpsContentLogDO>> getContentPage(AiOpsLogPageReqVO reqVO) {
        return success(contentService.getPage(reqVO));
    }

    @PutMapping("/content-log/approve")
    @Operation(summary = "采用改写内容")
    @PreAuthorize("@ss.hasPermission('aiops:content:audit')")
    public CommonResult<Boolean> approveContent(@RequestParam("id") Long id) {
        contentService.approve(id);
        return success(true);
    }

    @PutMapping("/content-log/reject")
    @Operation(summary = "拒绝改写内容")
    @PreAuthorize("@ss.hasPermission('aiops:content:audit')")
    public CommonResult<Boolean> rejectContent(@RequestParam("id") Long id) {
        contentService.reject(id);
        return success(true);
    }

    @PutMapping("/content-log/rollback")
    @Operation(summary = "回滚到改写前内容")
    @PreAuthorize("@ss.hasPermission('aiops:content:audit')")
    public CommonResult<Boolean> rollbackContent(@RequestParam("id") Long id) {
        contentService.rollback(id);
        return success(true);
    }

}
