package cn.iocoder.yudao.module.aiops.dal.dataobject;

import cn.iocoder.yudao.framework.tenant.core.db.TenantBaseDO;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * AI 商品内容改写记录。old_* 为改写前（A 版本），new_* 为改写后（B 版本），便于 A/B 对比与回滚。
 */
@TableName("aiops_content_log")
@Data
@EqualsAndHashCode(callSuper = true)
public class AiOpsContentLogDO extends TenantBaseDO {

    @TableId
    private Long id;
    private String runId;
    private Long spuId;
    private String oldName;
    private String newName;
    private String oldIntroduction;
    private String newIntroduction;
    private String oldKeyword;
    private String newKeyword;
    private String oldDescription;
    private String newDescription;
    /** 卖点 JSON 数组 */
    private String sellingPoints;
    /** 图片提示词 JSON 数组 */
    private String imagePrompts;
    /** 图片状态：0 无，1 待生成（未配置图片接口），2 已生成，3 生成失败 */
    private Integer imageStatus;
    /** 生成并上传后的图片地址 JSON 数组 */
    private String imageUrls;
    private String reason;
    private String stats;
    private String mode;
    private Integer status;
    private LocalDateTime applyTime;
    private LocalDateTime rollbackTime;

}
