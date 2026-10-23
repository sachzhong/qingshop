package cn.iocoder.yudao.module.aiops.dal.dataobject;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

/**
 * AI 运营配置（每个租户一行）
 *
 * 注意：大模型 API Key 不入库，只保存环境变量名（例如 LLM_SERVICE_KEY）。
 */
@TableName("aiops_config")
@Data
@EqualsAndHashCode(callSuper = true)
public class AiOpsConfigDO extends TenantBaseDO {

    @TableId
    private Long id;

    /** 智能定价是否启用（定时任务只处理启用的租户） */
    private Boolean priceEnabled;
    /** 智能定价模式：SUGGEST / AUTO */
    private String priceMode;
    /** 底价 = max(成本价 * floorCostRatio, 当前价 * floorCurrentRatio) */
    private BigDecimal floorCostRatio;
    private BigDecimal floorCurrentRatio;
    /** 顶价 = 当前价 * ceilRatio */
    private BigDecimal ceilRatio;
    /** 单次最大调整幅度，例如 0.10 */
    private BigDecimal maxChangeRatio;
    /** 同一 SKU 两次调价的冷却时间（小时） */
    private Integer cooldownHours;
    /** 统计窗口（天） */
    private Integer statDays;

    // ---- 规则引擎阈值（默认与原硬编码一致；null 时按默认） ----
    /** 退款率超过该值则不调价，默认 0.30 */
    private BigDecimal ruleRefundRateHold;
    /** 零销量且上架天数 ≥ 该值 → 降价，默认 7 */
    private Integer ruleZeroSalesDays;
    /** 零销量降价幅度（正数，实际取负），默认 0.08 */
    private BigDecimal ruleZeroSalesCutRatio;
    /** 畅销销量下限，默认 3 */
    private Integer ruleHotSalesMin;
    /** 畅销且库存天数低于该值 → 提价，默认 7 */
    private Integer ruleHotStockDays;
    /** 畅销提价幅度，默认 0.06 */
    private BigDecimal ruleHotRaiseRatio;
    /** 转化率下限（订单/浏览），默认 0.10 */
    private BigDecimal ruleConvMin;
    /** 高转化且库存天数高于该值 → 提价，默认 30 */
    private Integer ruleConvStockDays;
    /** 高转化提价幅度，默认 0.03 */
    private BigDecimal ruleConvRaiseRatio;
    /** 新品观察期天数，默认 7 */
    private Integer ruleNewProductDays;

    /** 内容优化是否启用 */
    private Boolean contentEnabled;
    /** 内容优化模式：SUGGEST / AUTO */
    private String contentMode;
    /** 每次运行最多处理的 SPU 数 */
    private Integer contentMaxSpu;
    /** 同一 SPU 两次内容改写的冷却时间（小时） */
    private Integer contentCooldownHours;

    /** OpenAI 兼容接口 */
    private String llmBaseUrl;
    private String llmModel;
    /** 存放 API Key 的环境变量名 */
    private String llmKeyEnv;

    /** 图片生成（OpenAI 兼容 /images/generations），为空表示未配置，只保存提示词 */
    private String imageBaseUrl;
    private String imageModel;
    private String imageKeyEnv;

}
