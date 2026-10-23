package cn.iocoder.yudao.module.aiops.dal.dataobject;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * AI 调价记录（建议 / 自动执行 / 回滚 都在这里留痕）
 */
@TableName("aiops_price_log")
@Data
@EqualsAndHashCode(callSuper = true)
public class AiOpsPriceLogDO extends TenantBaseDO {

    @TableId
    private Long id;
    /** 运行批次号 */
    private String runId;
    private Long spuId;
    private String spuName;
    private Long skuId;
    private String skuName;
    /** 价格单位均为分 */
    private Integer oldPrice;
    /** 规则引擎建议价 */
    private Integer rulePrice;
    /** 大模型建议价（未经护栏） */
    private Integer llmPrice;
    /** 经过护栏后的最终价格 */
    private Integer newPrice;
    private Integer floorPrice;
    private Integer ceilPrice;
    private Integer costPrice;
    /** 规则说明 */
    private String ruleReason;
    /** 大模型给出的理由 */
    private String reason;
    /** 护栏处理说明（例如被截断到 +10%） */
    private String guardNote;
    /** 统计数据快照 JSON */
    private String stats;
    /** SUGGEST / AUTO */
    private String mode;
    /** 状态，见 AiOpsLogStatusEnum */
    private Integer status;
    private LocalDateTime applyTime;
    private LocalDateTime rollbackTime;

}
