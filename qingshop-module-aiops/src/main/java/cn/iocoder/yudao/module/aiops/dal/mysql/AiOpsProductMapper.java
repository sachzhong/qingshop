package cn.iocoder.yudao.module.aiops.dal.mysql;

import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsSkuStatBO;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsSpuBO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 直接读写商品 / 交易表。aiops 嵌入 product-server，且商城各服务共用同一个库，
 * 为避免新增 RPC 接口，这里用 SQL 直接读取；多租户条件由 TenantLineInnerInterceptor 自动追加。
 */
@Mapper
public interface AiOpsProductMapper {

    @Select("<script>SELECT k.id AS sku_id, k.spu_id, s.name AS spu_name, k.properties AS sku_properties, k.price, k.market_price, k.cost_price, k.stock,"
            + " s.browse_count, s.sales_count AS spu_sales_count, s.create_time AS spu_create_time,"
            + " COALESCE(st.qty, 0) AS sales_qty, COALESCE(st.orders, 0) AS order_count, COALESCE(rf.qty, 0) AS refund_qty"
            + " FROM product_sku k JOIN product_spu s ON s.id = k.spu_id"
            + " LEFT JOIN (SELECT i.sku_id, SUM(i.count) AS qty, COUNT(DISTINCT i.order_id) AS orders FROM trade_order_item i"
            + "   JOIN trade_order o ON o.id = i.order_id WHERE o.pay_status = 1 AND o.pay_time &gt;= #{since} AND o.deleted = 0 AND i.deleted = 0"
            + "   GROUP BY i.sku_id) st ON st.sku_id = k.id"
            + " LEFT JOIN (SELECT a.sku_id, SUM(a.count) AS qty FROM trade_after_sale a WHERE a.status = 50 AND a.create_time &gt;= #{since} AND a.deleted = 0"
            + "   GROUP BY a.sku_id) rf ON rf.sku_id = k.id"
            + " WHERE k.deleted = 0 AND s.deleted = 0 AND s.status = 1"
            + "<if test='spuId != null'> AND s.id = #{spuId}</if>"
            + " ORDER BY k.id</script>")
    List<AiOpsSkuStatBO> selectSkuStats(@Param("since") LocalDateTime since, @Param("spuId") Long spuId);

    @Select("<script>SELECT s.id, s.name, s.keyword, s.introduction, s.description, c.name AS category_name, s.price, s.stock, s.browse_count,"
            + " COALESCE(st.qty, 0) AS sales_qty, COALESCE(st.orders, 0) AS order_count"
            + " FROM product_spu s LEFT JOIN product_category c ON c.id = s.category_id"
            + " LEFT JOIN (SELECT i.spu_id, SUM(i.count) AS qty, COUNT(DISTINCT i.order_id) AS orders FROM trade_order_item i"
            + "   JOIN trade_order o ON o.id = i.order_id WHERE o.pay_status = 1 AND o.pay_time &gt;= #{since} AND o.deleted = 0 AND i.deleted = 0"
            + "   GROUP BY i.spu_id) st ON st.spu_id = s.id"
            + " WHERE s.deleted = 0 AND s.status = 1"
            + "<if test='spuId != null'> AND s.id = #{spuId}</if>"
            + " ORDER BY s.id</script>")
    List<AiOpsSpuBO> selectSpus(@Param("since") LocalDateTime since, @Param("spuId") Long spuId);

    /** 乐观更新：只有当前价等于 expectPrice 时才修改，防止覆盖人工改价 */
    @Update("UPDATE product_sku SET price = #{price}, update_time = NOW() WHERE id = #{skuId} AND price = #{expectPrice} AND deleted = 0")
    int updateSkuPrice(@Param("skuId") Long skuId, @Param("expectPrice") Integer expectPrice, @Param("price") Integer price);

    @Select("SELECT price FROM product_sku WHERE id = #{skuId} AND deleted = 0")
    Integer selectSkuPrice(@Param("skuId") Long skuId);

    @Select("SELECT MIN(price) FROM product_sku WHERE spu_id = #{spuId} AND deleted = 0")
    Integer selectMinSkuPrice(@Param("spuId") Long spuId);

    /** SPU 的 price 冗余为最低 SKU 价，与 ProductSpuServiceImpl 保持一致 */
    @Update("UPDATE product_spu SET price = #{price}, update_time = NOW() WHERE id = #{spuId} AND deleted = 0")
    int updateSpuPrice(@Param("spuId") Long spuId, @Param("price") Integer price);

    @Update("UPDATE product_spu SET name = #{name}, introduction = #{introduction}, keyword = #{keyword}, description = #{description},"
            + " update_time = NOW() WHERE id = #{spuId} AND deleted = 0")
    int updateSpuContent(@Param("spuId") Long spuId, @Param("name") String name, @Param("introduction") String introduction,
                         @Param("keyword") String keyword, @Param("description") String description);

}
