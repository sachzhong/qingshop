package cn.iocoder.yudao.module.aiops.dal.dataobject;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * SKU 维度的经营统计（来自 product_sku / product_spu / trade_order / trade_order_item）
 */
@Data
public class AiOpsSkuStatBO {
    private Long skuId;
    private Long spuId;
    private String spuName;
    private String skuProperties;
    private Integer price;
    private Integer marketPrice;
    private Integer costPrice;
    private Integer stock;
    private Integer browseCount;
    private Integer spuSalesCount;
    private LocalDateTime spuCreateTime;
    /** 统计窗口内已支付的销量（件） */
    private Integer salesQty;
    /** 统计窗口内已支付的订单数 */
    private Integer orderCount;
    /** 统计窗口内已退款的件数 */
    private Integer refundQty;
}
