-- QingShop AI 运营 Round 2：规则阈值可配置（可重复执行）
-- mysql ... < sql/mysql/qingshop/qingshop-aiops-alter-r2.sql
SET NAMES utf8mb4;

-- 用存储过程包装，避免列已存在时报错
DROP PROCEDURE IF EXISTS qingshop_aiops_alter_r2;
DELIMITER $$
CREATE PROCEDURE qingshop_aiops_alter_r2()
BEGIN
  DECLARE CONTINUE HANDLER FOR 1060 BEGIN END; -- Duplicate column name
  ALTER TABLE `aiops_config` ADD COLUMN `rule_refund_rate_hold` decimal(6,3) NOT NULL DEFAULT 0.300 COMMENT '退款率超过该值则不调价' AFTER `stat_days`;
  ALTER TABLE `aiops_config` ADD COLUMN `rule_zero_sales_days` int NOT NULL DEFAULT 7 COMMENT '零销量且上架天数≥该值 → 降价' AFTER `rule_refund_rate_hold`;
  ALTER TABLE `aiops_config` ADD COLUMN `rule_zero_sales_cut_ratio` decimal(6,3) NOT NULL DEFAULT 0.080 COMMENT '零销量降价幅度（正数，实际为负）' AFTER `rule_zero_sales_days`;
  ALTER TABLE `aiops_config` ADD COLUMN `rule_hot_sales_min` int NOT NULL DEFAULT 3 COMMENT '畅销销量下限' AFTER `rule_zero_sales_cut_ratio`;
  ALTER TABLE `aiops_config` ADD COLUMN `rule_hot_stock_days` int NOT NULL DEFAULT 7 COMMENT '畅销且库存天数低于该值 → 提价' AFTER `rule_hot_sales_min`;
  ALTER TABLE `aiops_config` ADD COLUMN `rule_hot_raise_ratio` decimal(6,3) NOT NULL DEFAULT 0.060 COMMENT '畅销提价幅度' AFTER `rule_hot_stock_days`;
  ALTER TABLE `aiops_config` ADD COLUMN `rule_conv_min` decimal(6,3) NOT NULL DEFAULT 0.100 COMMENT '转化率下限（订单/浏览）' AFTER `rule_hot_raise_ratio`;
  ALTER TABLE `aiops_config` ADD COLUMN `rule_conv_stock_days` int NOT NULL DEFAULT 30 COMMENT '高转化且库存天数高于该值 → 提价' AFTER `rule_conv_min`;
  ALTER TABLE `aiops_config` ADD COLUMN `rule_conv_raise_ratio` decimal(6,3) NOT NULL DEFAULT 0.030 COMMENT '高转化提价幅度' AFTER `rule_conv_stock_days`;
  ALTER TABLE `aiops_config` ADD COLUMN `rule_new_product_days` int NOT NULL DEFAULT 7 COMMENT '新品观察期（上架不足该天数不调价）' AFTER `rule_conv_raise_ratio`;
END$$
DELIMITER ;
CALL qingshop_aiops_alter_r2();
DROP PROCEDURE IF EXISTS qingshop_aiops_alter_r2;
