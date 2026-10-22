package cn.iocoder.yudao.module.aiops.dal.dataobject;

import lombok.Data;

/**
 * SPU 内容字段（用于内容优化）
 */
@Data
public class AiOpsSpuBO {
    private Long id;
    private String name;
    private String keyword;
    private String introduction;
    private String description;
    private String categoryName;
    private Integer price;
    private Integer stock;
    private Integer browseCount;
    private Integer salesQty;
    private Integer orderCount;
}
