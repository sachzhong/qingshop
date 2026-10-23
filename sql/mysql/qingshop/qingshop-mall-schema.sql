-- QingShop mall/member/pay schema, generated from DO classes by gen_mall_schema.py (no official SQL used)
SET NAMES utf8mb4;

-- from AfterSaleDO
DROP TABLE IF EXISTS `trade_after_sale`;
CREATE TABLE `trade_after_sale` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `no` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `way` int NULL DEFAULT 0,
  `type` int NULL DEFAULT 0,
  `user_id` bigint NULL,
  `apply_reason` text NULL,
  `apply_description` text NULL,
  `apply_pic_urls` text NULL,
  `order_id` bigint NULL,
  `order_no` varchar(512) NULL,
  `order_item_id` bigint NULL,
  `spu_id` bigint NULL,
  `spu_name` varchar(512) NULL,
  `sku_id` bigint NULL,
  `properties` text NULL,
  `pic_url` varchar(512) NULL,
  `count` int NULL DEFAULT 0,
  `audit_time` datetime NULL,
  `audit_user_id` bigint NULL,
  `audit_reason` text NULL,
  `refund_price` int NULL DEFAULT 0,
  `pay_refund_id` bigint NULL,
  `refund_time` datetime NULL,
  `logistics_id` bigint NULL,
  `logistics_no` varchar(512) NULL,
  `delivery_time` datetime NULL,
  `receive_time` datetime NULL,
  `receive_reason` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_no` (`no`),
  KEY `idx_audit_user_id` (`audit_user_id`),
  KEY `idx_logistics_id` (`logistics_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_item_id` (`order_item_id`),
  KEY `idx_pay_refund_id` (`pay_refund_id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_spu_id` (`spu_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from AfterSaleLogDO
DROP TABLE IF EXISTS `trade_after_sale_log`;
CREATE TABLE `trade_after_sale_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `user_type` int NULL DEFAULT 0,
  `after_sale_id` bigint NULL,
  `before_status` int NULL DEFAULT 0,
  `after_status` int NULL DEFAULT 0,
  `operate_type` int NULL DEFAULT 0,
  `content` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_after_sale_id` (`after_sale_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from ArticleCategoryDO
DROP TABLE IF EXISTS `promotion_article_category`;
CREATE TABLE `promotion_article_category` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `pic_url` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `sort` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from ArticleDO
DROP TABLE IF EXISTS `promotion_article`;
CREATE TABLE `promotion_article` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `category_id` bigint NULL,
  `spu_id` bigint NULL,
  `title` varchar(512) NULL,
  `author` varchar(512) NULL,
  `pic_url` varchar(512) NULL,
  `introduction` text NULL,
  `browse_count` int NULL DEFAULT 0,
  `sort` int NULL DEFAULT 0,
  `status` int NULL DEFAULT 0,
  `recommend_hot` bit(1) NULL DEFAULT b'0',
  `recommend_banner` bit(1) NULL DEFAULT b'0',
  `content` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_spu_id` (`spu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from BannerDO
DROP TABLE IF EXISTS `promotion_banner`;
CREATE TABLE `promotion_banner` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(512) NULL,
  `url` varchar(512) NULL,
  `pic_url` varchar(512) NULL,
  `sort` int NULL DEFAULT 0,
  `status` int NULL DEFAULT 0,
  `position` int NULL DEFAULT 0,
  `memo` text NULL,
  `browse_count` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from BargainActivityDO
DROP TABLE IF EXISTS `promotion_bargain_activity`;
CREATE TABLE `promotion_bargain_activity` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `start_time` datetime NULL,
  `end_time` datetime NULL,
  `status` int NULL DEFAULT 0,
  `spu_id` bigint NULL,
  `sku_id` bigint NULL,
  `bargain_first_price` int NULL DEFAULT 0,
  `bargain_min_price` int NULL DEFAULT 0,
  `stock` int NULL DEFAULT 0,
  `total_stock` int NULL DEFAULT 0,
  `help_max_count` int NULL DEFAULT 0,
  `bargain_count` int NULL DEFAULT 0,
  `total_limit_count` int NULL DEFAULT 0,
  `random_min_price` int NULL DEFAULT 0,
  `random_max_price` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_spu_id` (`spu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from BargainHelpDO
DROP TABLE IF EXISTS `promotion_bargain_help`;
CREATE TABLE `promotion_bargain_help` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `activity_id` bigint NULL,
  `record_id` bigint NULL,
  `user_id` bigint NULL,
  `reduce_price` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_record_id` (`record_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from BargainRecordDO
DROP TABLE IF EXISTS `promotion_bargain_record`;
CREATE TABLE `promotion_bargain_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `activity_id` bigint NULL,
  `spu_id` bigint NULL,
  `sku_id` bigint NULL,
  `bargain_first_price` int NULL DEFAULT 0,
  `bargain_price` int NULL DEFAULT 0,
  `status` int NULL DEFAULT 0,
  `end_time` datetime NULL,
  `order_id` bigint NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_spu_id` (`spu_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from BrokerageRecordDO
DROP TABLE IF EXISTS `trade_brokerage_record`;
CREATE TABLE `trade_brokerage_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `biz_id` varchar(512) NULL,
  `biz_type` int NULL DEFAULT 0,
  `title` varchar(512) NULL,
  `description` text NULL,
  `price` int NULL DEFAULT 0,
  `total_price` int NULL DEFAULT 0,
  `status` int NULL DEFAULT 0,
  `frozen_days` int NULL DEFAULT 0,
  `unfreeze_time` datetime NULL,
  `source_user_level` int NULL DEFAULT 0,
  `source_user_id` bigint NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_biz_id` (`biz_id`),
  KEY `idx_source_user_id` (`source_user_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from BrokerageUserDO
DROP TABLE IF EXISTS `trade_brokerage_user`;
CREATE TABLE `trade_brokerage_user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `bind_user_id` bigint NULL,
  `bind_user_time` datetime NULL,
  `brokerage_enabled` bit(1) NULL DEFAULT b'0',
  `brokerage_time` datetime NULL,
  `brokerage_price` int NULL DEFAULT 0,
  `frozen_price` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_bind_user_id` (`bind_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from BrokerageWithdrawDO
DROP TABLE IF EXISTS `trade_brokerage_withdraw`;
CREATE TABLE `trade_brokerage_withdraw` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `price` int NULL DEFAULT 0,
  `fee_price` int NULL DEFAULT 0,
  `total_price` int NULL DEFAULT 0,
  `type` int NULL DEFAULT 0,
  `user_name` varchar(512) NULL,
  `user_account` varchar(512) NULL,
  `qr_code_url` varchar(512) NULL,
  `bank_name` varchar(512) NULL,
  `bank_address` text NULL,
  `status` int NULL DEFAULT 0,
  `audit_reason` text NULL,
  `audit_time` datetime NULL,
  `remark` text NULL,
  `pay_transfer_id` bigint NULL,
  `transfer_channel_code` varchar(512) NULL,
  `transfer_time` datetime NULL,
  `transfer_error_msg` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_pay_transfer_id` (`pay_transfer_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from CartDO
DROP TABLE IF EXISTS `trade_cart`;
CREATE TABLE `trade_cart` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `spu_id` bigint NULL,
  `sku_id` bigint NULL,
  `count` int NULL DEFAULT 0,
  `selected` bit(1) NULL DEFAULT b'0',
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_spu_id` (`spu_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from CombinationActivityDO
DROP TABLE IF EXISTS `promotion_combination_activity`;
CREATE TABLE `promotion_combination_activity` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `spu_id` bigint NULL,
  `total_limit_count` int NULL DEFAULT 0,
  `single_limit_count` int NULL DEFAULT 0,
  `start_time` datetime NULL,
  `end_time` datetime NULL,
  `user_size` int NULL DEFAULT 0,
  `virtual_group` bit(1) NULL DEFAULT b'0',
  `status` int NULL DEFAULT 0,
  `limit_duration` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_spu_id` (`spu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from CombinationProductDO
DROP TABLE IF EXISTS `promotion_combination_product`;
CREATE TABLE `promotion_combination_product` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `activity_id` bigint NULL,
  `spu_id` bigint NULL,
  `sku_id` bigint NULL,
  `combination_price` int NULL DEFAULT 0,
  `activity_status` int NULL DEFAULT 0,
  `activity_start_time` datetime NULL,
  `activity_end_time` datetime NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_spu_id` (`spu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from CombinationRecordDO
DROP TABLE IF EXISTS `promotion_combination_record`;
CREATE TABLE `promotion_combination_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `activity_id` bigint NULL,
  `combination_price` int NULL DEFAULT 0,
  `spu_id` bigint NULL,
  `spu_name` varchar(512) NULL,
  `pic_url` varchar(512) NULL,
  `sku_id` bigint NULL,
  `count` int NULL DEFAULT 0,
  `user_id` bigint NULL,
  `nickname` varchar(512) NULL,
  `avatar` varchar(512) NULL,
  `head_id` bigint NULL,
  `status` int NULL DEFAULT 0,
  `order_id` bigint NULL,
  `user_size` int NULL DEFAULT 0,
  `user_count` int NULL DEFAULT 0,
  `virtual_group` bit(1) NULL DEFAULT b'0',
  `expire_time` datetime NULL,
  `start_time` datetime NULL,
  `end_time` datetime NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_head_id` (`head_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_spu_id` (`spu_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from CouponDO
DROP TABLE IF EXISTS `promotion_coupon`;
CREATE TABLE `promotion_coupon` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `template_id` bigint NULL,
  `name` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `user_id` bigint NULL,
  `take_type` int NULL DEFAULT 0,
  `use_price` int NULL DEFAULT 0,
  `valid_start_time` datetime NULL,
  `valid_end_time` datetime NULL,
  `product_scope` int NULL DEFAULT 0,
  `product_scope_values` text NULL,
  `discount_type` int NULL DEFAULT 0,
  `discount_percent` int NULL DEFAULT 0,
  `discount_price` int NULL DEFAULT 0,
  `discount_limit_price` int NULL DEFAULT 0,
  `use_order_id` bigint NULL,
  `use_time` datetime NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_use_order_id` (`use_order_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from CouponTemplateDO
DROP TABLE IF EXISTS `promotion_coupon_template`;
CREATE TABLE `promotion_coupon_template` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `description` text NULL,
  `status` int NULL DEFAULT 0,
  `total_count` int NULL DEFAULT 0,
  `take_limit_count` int NULL DEFAULT 0,
  `take_type` int NULL DEFAULT 0,
  `use_price` int NULL DEFAULT 0,
  `product_scope` int NULL DEFAULT 0,
  `product_scope_values` text NULL,
  `validity_type` int NULL DEFAULT 0,
  `valid_start_time` datetime NULL,
  `valid_end_time` datetime NULL,
  `fixed_start_term` int NULL DEFAULT 0,
  `fixed_end_term` int NULL DEFAULT 0,
  `discount_type` int NULL DEFAULT 0,
  `discount_percent` int NULL DEFAULT 0,
  `discount_price` int NULL DEFAULT 0,
  `discount_limit_price` int NULL DEFAULT 0,
  `take_count` int NULL DEFAULT 0,
  `use_count` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from DeliveryExpressDO
DROP TABLE IF EXISTS `trade_delivery_express`;
CREATE TABLE `trade_delivery_express` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(512) NULL,
  `name` varchar(512) NULL,
  `logo` varchar(512) NULL,
  `sort` int NULL DEFAULT 0,
  `status` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from DeliveryExpressTemplateChargeDO
DROP TABLE IF EXISTS `trade_delivery_express_template_charge`;
CREATE TABLE `trade_delivery_express_template_charge` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `template_id` bigint NULL,
  `area_ids` text NULL,
  `charge_mode` int NULL DEFAULT 0,
  `start_count` double NULL DEFAULT 0,
  `start_price` int NULL DEFAULT 0,
  `extra_count` double NULL DEFAULT 0,
  `extra_price` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from DeliveryExpressTemplateDO
DROP TABLE IF EXISTS `trade_delivery_express_template`;
CREATE TABLE `trade_delivery_express_template` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `charge_mode` int NULL DEFAULT 0,
  `sort` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from DeliveryExpressTemplateFreeDO
DROP TABLE IF EXISTS `trade_delivery_express_template_free`;
CREATE TABLE `trade_delivery_express_template_free` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `template_id` bigint NULL,
  `area_ids` text NULL,
  `free_price` int NULL DEFAULT 0,
  `free_count` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from DeliveryPickUpStoreDO
DROP TABLE IF EXISTS `trade_delivery_pick_up_store`;
CREATE TABLE `trade_delivery_pick_up_store` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `introduction` text NULL,
  `phone` varchar(512) NULL,
  `area_id` int NULL,
  `detail_address` text NULL,
  `logo` varchar(512) NULL,
  `opening_time` time NULL,
  `closing_time` time NULL,
  `latitude` double NULL DEFAULT 0,
  `longitude` double NULL DEFAULT 0,
  `verify_user_ids` text NULL,
  `status` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_area_id` (`area_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from DiscountActivityDO
DROP TABLE IF EXISTS `promotion_discount_activity`;
CREATE TABLE `promotion_discount_activity` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `start_time` datetime NULL,
  `end_time` datetime NULL,
  `remark` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from DiscountProductDO
DROP TABLE IF EXISTS `promotion_discount_product`;
CREATE TABLE `promotion_discount_product` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `activity_id` bigint NULL,
  `spu_id` bigint NULL,
  `sku_id` bigint NULL,
  `discount_type` int NULL DEFAULT 0,
  `discount_percent` int NULL DEFAULT 0,
  `discount_price` int NULL DEFAULT 0,
  `activity_name` varchar(512) NULL,
  `activity_status` int NULL DEFAULT 0,
  `activity_start_time` datetime NULL,
  `activity_end_time` datetime NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_spu_id` (`spu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from DiyPageDO
DROP TABLE IF EXISTS `promotion_diy_page`;
CREATE TABLE `promotion_diy_page` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `template_id` bigint NULL,
  `name` varchar(512) NULL,
  `remark` text NULL,
  `preview_pic_urls` text NULL,
  `property` longtext NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from DiyTemplateDO
DROP TABLE IF EXISTS `promotion_diy_template`;
CREATE TABLE `promotion_diy_template` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `used` bit(1) NULL DEFAULT b'0',
  `used_time` datetime NULL,
  `remark` text NULL,
  `preview_pic_urls` text NULL,
  `property` longtext NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from KeFuConversationDO
DROP TABLE IF EXISTS `promotion_kefu_conversation`;
CREATE TABLE `promotion_kefu_conversation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `last_message_time` datetime NULL,
  `last_message_content` text NULL,
  `last_message_content_type` int NULL DEFAULT 0,
  `admin_pinned` bit(1) NULL DEFAULT b'0',
  `user_deleted` bit(1) NULL DEFAULT b'0',
  `admin_deleted` bit(1) NULL DEFAULT b'0',
  `admin_unread_message_count` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from KeFuMessageDO
DROP TABLE IF EXISTS `promotion_kefu_message`;
CREATE TABLE `promotion_kefu_message` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint NULL,
  `sender_id` bigint NULL,
  `sender_type` int NULL DEFAULT 0,
  `receiver_id` bigint NULL,
  `receiver_type` int NULL DEFAULT 0,
  `content_type` int NULL DEFAULT 0,
  `content` text NULL,
  `read_status` bit(1) NULL DEFAULT b'0',
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_conversation_id` (`conversation_id`),
  KEY `idx_receiver_id` (`receiver_id`),
  KEY `idx_sender_id` (`sender_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from MemberAddressDO
DROP TABLE IF EXISTS `member_address`;
CREATE TABLE `member_address` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `name` varchar(512) NULL,
  `mobile` varchar(512) NULL,
  `area_id` bigint NULL,
  `detail_address` text NULL,
  `default_status` bit(1) NULL DEFAULT b'0',
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_area_id` (`area_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from MemberConfigDO
DROP TABLE IF EXISTS `member_config`;
CREATE TABLE `member_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `point_trade_deduct_enable` bit(1) NULL DEFAULT b'0',
  `point_trade_deduct_unit_price` int NULL DEFAULT 0,
  `point_trade_deduct_max_price` int NULL DEFAULT 0,
  `point_trade_give_point` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from MemberExperienceRecordDO
DROP TABLE IF EXISTS `member_experience_record`;
CREATE TABLE `member_experience_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `biz_type` int NULL DEFAULT 0,
  `biz_id` varchar(512) NULL,
  `title` varchar(512) NULL,
  `description` text NULL,
  `experience` int NULL DEFAULT 0,
  `total_experience` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_biz_id` (`biz_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from MemberGroupDO
DROP TABLE IF EXISTS `member_group`;
CREATE TABLE `member_group` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `remark` text NULL,
  `status` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from MemberLevelDO
DROP TABLE IF EXISTS `member_level`;
CREATE TABLE `member_level` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `level` int NULL DEFAULT 0,
  `experience` int NULL DEFAULT 0,
  `discount_percent` int NULL DEFAULT 0,
  `icon` varchar(512) NULL,
  `background_url` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from MemberLevelRecordDO
DROP TABLE IF EXISTS `member_level_record`;
CREATE TABLE `member_level_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `level_id` bigint NULL,
  `level` int NULL DEFAULT 0,
  `discount_percent` int NULL DEFAULT 0,
  `experience` int NULL DEFAULT 0,
  `user_experience` int NULL DEFAULT 0,
  `remark` text NULL,
  `description` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_level_id` (`level_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from MemberPointRecordDO
DROP TABLE IF EXISTS `member_point_record`;
CREATE TABLE `member_point_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `biz_id` varchar(512) NULL,
  `biz_type` int NULL DEFAULT 0,
  `title` varchar(512) NULL,
  `description` text NULL,
  `point` int NULL DEFAULT 0,
  `total_point` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_biz_id` (`biz_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from MemberSignInConfigDO
DROP TABLE IF EXISTS `member_sign_in_config`;
CREATE TABLE `member_sign_in_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `day` int NULL DEFAULT 0,
  `point` int NULL DEFAULT 0,
  `experience` int NULL DEFAULT 0,
  `status` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from MemberSignInRecordDO
DROP TABLE IF EXISTS `member_sign_in_record`;
CREATE TABLE `member_sign_in_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `day` int NULL DEFAULT 0,
  `point` int NULL DEFAULT 0,
  `experience` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from MemberTagDO
DROP TABLE IF EXISTS `member_tag`;
CREATE TABLE `member_tag` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from MemberUserDO
DROP TABLE IF EXISTS `member_user`;
CREATE TABLE `member_user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mobile` varchar(512) NULL,
  `email` varchar(512) NULL,
  `password` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `register_ip` varchar(512) NULL,
  `register_terminal` int NULL DEFAULT 0,
  `login_ip` varchar(512) NULL,
  `login_date` datetime NULL,
  `nickname` varchar(512) NULL,
  `avatar` varchar(512) NULL,
  `name` varchar(512) NULL,
  `sex` int NULL DEFAULT 0,
  `birthday` datetime NULL,
  `area_id` int NULL,
  `mark` varchar(512) NULL,
  `point` int NULL DEFAULT 0,
  `tag_ids` text NULL,
  `level_id` bigint NULL,
  `experience` int NULL DEFAULT 0,
  `group_id` bigint NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_area_id` (`area_id`),
  KEY `idx_group_id` (`group_id`),
  KEY `idx_level_id` (`level_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PayAppDO
DROP TABLE IF EXISTS `pay_app`;
CREATE TABLE `pay_app` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app_key` varchar(512) NULL,
  `name` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `remark` text NULL,
  `order_notify_url` varchar(512) NULL,
  `refund_notify_url` varchar(512) NULL,
  `transfer_notify_url` varchar(512) NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PayChannelDO
DROP TABLE IF EXISTS `pay_channel`;
CREATE TABLE `pay_channel` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `fee_rate` double NULL DEFAULT 0,
  `remark` text NULL,
  `app_id` bigint NULL,
  `config` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_app_id` (`app_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PayDemoOrderDO
DROP TABLE IF EXISTS `pay_demo_order`;
CREATE TABLE `pay_demo_order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `spu_id` bigint NULL,
  `spu_name` varchar(512) NULL,
  `price` int NULL DEFAULT 0,
  `pay_status` bit(1) NULL DEFAULT b'0',
  `pay_order_id` bigint NULL,
  `pay_time` datetime NULL,
  `pay_channel_code` varchar(512) NULL,
  `pay_refund_id` bigint NULL,
  `refund_price` int NULL DEFAULT 0,
  `refund_time` datetime NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_pay_order_id` (`pay_order_id`),
  KEY `idx_pay_refund_id` (`pay_refund_id`),
  KEY `idx_spu_id` (`spu_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PayDemoWithdrawDO
DROP TABLE IF EXISTS `pay_demo_withdraw`;
CREATE TABLE `pay_demo_withdraw` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `subject` varchar(512) NULL,
  `price` int NULL DEFAULT 0,
  `user_account` varchar(512) NULL,
  `user_name` varchar(512) NULL,
  `type` int NULL DEFAULT 0,
  `status` int NULL DEFAULT 0,
  `pay_transfer_id` bigint NULL,
  `transfer_channel_code` varchar(512) NULL,
  `transfer_time` datetime NULL,
  `transfer_error_msg` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_pay_transfer_id` (`pay_transfer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PayNotifyLogDO
DROP TABLE IF EXISTS `pay_notify_log`;
CREATE TABLE `pay_notify_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_id` bigint NULL,
  `notify_times` int NULL DEFAULT 0,
  `response` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_task_id` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PayNotifyTaskDO
DROP TABLE IF EXISTS `pay_notify_task`;
CREATE TABLE `pay_notify_task` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app_id` bigint NULL,
  `type` int NULL DEFAULT 0,
  `data_id` bigint NULL,
  `merchant_order_id` varchar(512) NULL,
  `merchant_refund_id` varchar(512) NULL,
  `merchant_transfer_id` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `next_notify_time` datetime NULL,
  `last_execute_time` datetime NULL,
  `notify_times` int NULL DEFAULT 0,
  `max_notify_times` int NULL DEFAULT 0,
  `notify_url` varchar(512) NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_app_id` (`app_id`),
  KEY `idx_data_id` (`data_id`),
  KEY `idx_merchant_order_id` (`merchant_order_id`),
  KEY `idx_merchant_refund_id` (`merchant_refund_id`),
  KEY `idx_merchant_transfer_id` (`merchant_transfer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PayOrderDO
DROP TABLE IF EXISTS `pay_order`;
CREATE TABLE `pay_order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app_id` bigint NULL,
  `channel_id` bigint NULL,
  `channel_code` varchar(512) NULL,
  `user_id` bigint NULL,
  `user_type` int NULL DEFAULT 0,
  `merchant_order_id` varchar(512) NULL,
  `subject` varchar(512) NULL,
  `body` text NULL,
  `notify_url` varchar(512) NULL,
  `price` int NULL DEFAULT 0,
  `channel_fee_rate` double NULL DEFAULT 0,
  `channel_fee_price` int NULL DEFAULT 0,
  `status` int NULL DEFAULT 0,
  `user_ip` varchar(512) NULL,
  `expire_time` datetime NULL,
  `success_time` datetime NULL,
  `extension_id` bigint NULL,
  `no` varchar(512) NULL,
  `refund_price` int NULL DEFAULT 0,
  `channel_user_id` varchar(512) NULL,
  `channel_order_no` varchar(512) NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_app_id` (`app_id`),
  KEY `idx_channel_id` (`channel_id`),
  KEY `idx_channel_user_id` (`channel_user_id`),
  KEY `idx_extension_id` (`extension_id`),
  KEY `idx_merchant_order_id` (`merchant_order_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PayOrderExtensionDO
DROP TABLE IF EXISTS `pay_order_extension`;
CREATE TABLE `pay_order_extension` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `no` varchar(512) NULL,
  `order_id` bigint NULL,
  `channel_id` bigint NULL,
  `channel_code` varchar(512) NULL,
  `user_ip` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `channel_extras` text NULL,
  `channel_error_code` varchar(512) NULL,
  `channel_error_msg` text NULL,
  `channel_notify_data` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_no` (`no`),
  KEY `idx_channel_id` (`channel_id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PayRefundDO
DROP TABLE IF EXISTS `pay_refund`;
CREATE TABLE `pay_refund` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `no` varchar(512) NULL,
  `app_id` bigint NULL,
  `channel_id` bigint NULL,
  `channel_code` varchar(512) NULL,
  `order_id` bigint NULL,
  `order_no` varchar(512) NULL,
  `user_id` bigint NULL,
  `user_type` int NULL DEFAULT 0,
  `merchant_order_id` varchar(512) NULL,
  `merchant_refund_id` varchar(512) NULL,
  `notify_url` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `pay_price` int NULL DEFAULT 0,
  `refund_price` int NULL DEFAULT 0,
  `reason` text NULL,
  `user_ip` varchar(512) NULL,
  `channel_order_no` varchar(512) NULL,
  `channel_refund_no` varchar(512) NULL,
  `success_time` datetime NULL,
  `channel_error_code` varchar(512) NULL,
  `channel_error_msg` text NULL,
  `channel_notify_data` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_no` (`no`),
  KEY `idx_app_id` (`app_id`),
  KEY `idx_channel_id` (`channel_id`),
  KEY `idx_merchant_order_id` (`merchant_order_id`),
  KEY `idx_merchant_refund_id` (`merchant_refund_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PayTransferDO
DROP TABLE IF EXISTS `pay_transfer`;
CREATE TABLE `pay_transfer` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `no` varchar(512) NULL,
  `app_id` bigint NULL,
  `channel_id` bigint NULL,
  `channel_code` varchar(512) NULL,
  `user_id` bigint NULL,
  `user_type` int NULL DEFAULT 0,
  `merchant_transfer_id` varchar(512) NULL,
  `subject` varchar(512) NULL,
  `price` int NULL DEFAULT 0,
  `user_account` varchar(512) NULL,
  `user_name` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `success_time` datetime NULL,
  `notify_url` varchar(512) NULL,
  `user_ip` varchar(512) NULL,
  `channel_extras` text NULL,
  `channel_transfer_no` varchar(512) NULL,
  `channel_error_code` varchar(512) NULL,
  `channel_error_msg` text NULL,
  `channel_notify_data` text NULL,
  `channel_package_info` varchar(512) NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_no` (`no`),
  KEY `idx_app_id` (`app_id`),
  KEY `idx_channel_id` (`channel_id`),
  KEY `idx_merchant_transfer_id` (`merchant_transfer_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PayWalletDO
DROP TABLE IF EXISTS `pay_wallet`;
CREATE TABLE `pay_wallet` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `user_type` int NULL DEFAULT 0,
  `balance` int NULL DEFAULT 0,
  `freeze_price` int NULL DEFAULT 0,
  `total_expense` int NULL DEFAULT 0,
  `total_recharge` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PayWalletRechargeDO
DROP TABLE IF EXISTS `pay_wallet_recharge`;
CREATE TABLE `pay_wallet_recharge` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `wallet_id` bigint NULL,
  `total_price` int NULL DEFAULT 0,
  `pay_price` int NULL DEFAULT 0,
  `bonus_price` int NULL DEFAULT 0,
  `package_id` bigint NULL,
  `pay_status` bit(1) NULL DEFAULT b'0',
  `pay_order_id` bigint NULL,
  `pay_channel_code` varchar(512) NULL,
  `pay_time` datetime NULL,
  `pay_refund_id` bigint NULL,
  `refund_total_price` int NULL DEFAULT 0,
  `refund_pay_price` int NULL DEFAULT 0,
  `refund_bonus_price` int NULL DEFAULT 0,
  `refund_time` datetime NULL,
  `refund_status` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_package_id` (`package_id`),
  KEY `idx_pay_order_id` (`pay_order_id`),
  KEY `idx_pay_refund_id` (`pay_refund_id`),
  KEY `idx_wallet_id` (`wallet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PayWalletRechargePackageDO
DROP TABLE IF EXISTS `pay_wallet_recharge_package`;
CREATE TABLE `pay_wallet_recharge_package` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `pay_price` int NULL DEFAULT 0,
  `bonus_price` int NULL DEFAULT 0,
  `status` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PayWalletTransactionDO
DROP TABLE IF EXISTS `pay_wallet_transaction`;
CREATE TABLE `pay_wallet_transaction` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `no` varchar(512) NULL,
  `wallet_id` bigint NULL,
  `biz_type` int NULL DEFAULT 0,
  `biz_id` varchar(512) NULL,
  `title` varchar(512) NULL,
  `price` int NULL DEFAULT 0,
  `balance` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_biz_id` (`biz_id`),
  KEY `idx_wallet_id` (`wallet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PointActivityDO
DROP TABLE IF EXISTS `promotion_point_activity`;
CREATE TABLE `promotion_point_activity` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `spu_id` bigint NULL,
  `status` int NULL DEFAULT 0,
  `remark` text NULL,
  `sort` int NULL DEFAULT 0,
  `stock` int NULL DEFAULT 0,
  `total_stock` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_spu_id` (`spu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from PointProductDO
DROP TABLE IF EXISTS `promotion_point_product`;
CREATE TABLE `promotion_point_product` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `activity_id` bigint NULL,
  `spu_id` bigint NULL,
  `sku_id` bigint NULL,
  `count` int NULL DEFAULT 0,
  `point` int NULL DEFAULT 0,
  `price` int NULL DEFAULT 0,
  `stock` int NULL DEFAULT 0,
  `activity_status` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_spu_id` (`spu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from ProductBrandDO
DROP TABLE IF EXISTS `product_brand`;
CREATE TABLE `product_brand` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `pic_url` varchar(512) NULL,
  `sort` int NULL DEFAULT 0,
  `description` text NULL,
  `status` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from ProductBrowseHistoryDO
DROP TABLE IF EXISTS `product_browse_history`;
CREATE TABLE `product_browse_history` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `spu_id` bigint NULL,
  `user_id` bigint NULL,
  `user_deleted` bit(1) NULL DEFAULT b'0',
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_spu_id` (`spu_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from ProductCategoryDO
DROP TABLE IF EXISTS `product_category`;
CREATE TABLE `product_category` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `parent_id` bigint NULL,
  `name` varchar(512) NULL,
  `pic_url` varchar(512) NULL,
  `sort` int NULL DEFAULT 0,
  `status` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from ProductCommentDO
DROP TABLE IF EXISTS `product_comment`;
CREATE TABLE `product_comment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `user_nickname` varchar(512) NULL,
  `user_avatar` varchar(512) NULL,
  `anonymous` bit(1) NULL DEFAULT b'0',
  `order_id` bigint NULL,
  `order_item_id` bigint NULL,
  `spu_id` bigint NULL,
  `spu_name` varchar(512) NULL,
  `sku_id` bigint NULL,
  `sku_pic_url` varchar(512) NULL,
  `sku_properties` text NULL,
  `visible` bit(1) NULL DEFAULT b'0',
  `scores` int NULL DEFAULT 0,
  `description_scores` int NULL DEFAULT 0,
  `benefit_scores` int NULL DEFAULT 0,
  `content` text NULL,
  `pic_urls` text NULL,
  `reply_status` bit(1) NULL DEFAULT b'0',
  `reply_user_id` bigint NULL,
  `reply_content` text NULL,
  `reply_time` datetime NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_item_id` (`order_item_id`),
  KEY `idx_reply_user_id` (`reply_user_id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_spu_id` (`spu_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from ProductFavoriteDO
DROP TABLE IF EXISTS `product_favorite`;
CREATE TABLE `product_favorite` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `spu_id` bigint NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_spu_id` (`spu_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from ProductPropertyDO
DROP TABLE IF EXISTS `product_property`;
CREATE TABLE `product_property` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `remark` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from ProductPropertyValueDO
DROP TABLE IF EXISTS `product_property_value`;
CREATE TABLE `product_property_value` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `property_id` bigint NULL,
  `name` varchar(512) NULL,
  `remark` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_property_id` (`property_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from ProductSkuDO
DROP TABLE IF EXISTS `product_sku`;
CREATE TABLE `product_sku` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `spu_id` bigint NULL,
  `properties` text NULL,
  `price` int NULL DEFAULT 0,
  `market_price` int NULL DEFAULT 0,
  `cost_price` int NULL DEFAULT 0,
  `bar_code` varchar(512) NULL,
  `pic_url` varchar(512) NULL,
  `stock` int NULL DEFAULT 0,
  `weight` double NULL DEFAULT 0,
  `volume` double NULL DEFAULT 0,
  `first_brokerage_price` int NULL DEFAULT 0,
  `second_brokerage_price` int NULL DEFAULT 0,
  `sales_count` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_spu_id` (`spu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from ProductSpuDO
DROP TABLE IF EXISTS `product_spu`;
CREATE TABLE `product_spu` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `keyword` varchar(512) NULL,
  `introduction` text NULL,
  `description` text NULL,
  `category_id` bigint NULL,
  `brand_id` bigint NULL,
  `pic_url` varchar(512) NULL,
  `slider_pic_urls` text NULL,
  `sort` int NULL DEFAULT 0,
  `status` int NULL DEFAULT 0,
  `spec_type` bit(1) NULL DEFAULT b'0',
  `price` int NULL DEFAULT 0,
  `market_price` int NULL DEFAULT 0,
  `cost_price` int NULL DEFAULT 0,
  `stock` int NULL DEFAULT 0,
  `delivery_types` text NULL,
  `delivery_template_id` bigint NULL,
  `give_integral` int NULL DEFAULT 0,
  `sub_commission_type` bit(1) NULL DEFAULT b'0',
  `sales_count` int NULL DEFAULT 0,
  `virtual_sales_count` int NULL DEFAULT 0,
  `browse_count` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_brand_id` (`brand_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_delivery_template_id` (`delivery_template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from ProductStatisticsDO
DROP TABLE IF EXISTS `product_statistics`;
CREATE TABLE `product_statistics` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `time` date NULL,
  `spu_id` bigint NULL,
  `browse_count` int NULL DEFAULT 0,
  `browse_user_count` int NULL DEFAULT 0,
  `favorite_count` int NULL DEFAULT 0,
  `cart_count` int NULL DEFAULT 0,
  `order_count` int NULL DEFAULT 0,
  `order_pay_count` int NULL DEFAULT 0,
  `order_pay_price` int NULL DEFAULT 0,
  `after_sale_count` int NULL DEFAULT 0,
  `after_sale_refund_price` int NULL DEFAULT 0,
  `browse_convert_percent` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_spu_id` (`spu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from RewardActivityDO
DROP TABLE IF EXISTS `promotion_reward_activity`;
CREATE TABLE `promotion_reward_activity` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `start_time` datetime NULL,
  `end_time` datetime NULL,
  `remark` text NULL,
  `condition_type` int NULL DEFAULT 0,
  `product_scope` int NULL DEFAULT 0,
  `product_scope_values` text NULL,
  `rules` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from SeckillActivityDO
DROP TABLE IF EXISTS `promotion_seckill_activity`;
CREATE TABLE `promotion_seckill_activity` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `spu_id` bigint NULL,
  `name` varchar(512) NULL,
  `status` int NULL DEFAULT 0,
  `remark` text NULL,
  `start_time` datetime NULL,
  `end_time` datetime NULL,
  `sort` int NULL DEFAULT 0,
  `config_ids` text NULL,
  `total_limit_count` int NULL DEFAULT 0,
  `single_limit_count` int NULL DEFAULT 0,
  `stock` int NULL DEFAULT 0,
  `total_stock` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_spu_id` (`spu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from SeckillConfigDO
DROP TABLE IF EXISTS `promotion_seckill_config`;
CREATE TABLE `promotion_seckill_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NULL,
  `start_time` varchar(512) NULL,
  `end_time` varchar(512) NULL,
  `slider_pic_urls` text NULL,
  `status` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from SeckillProductDO
DROP TABLE IF EXISTS `promotion_seckill_product`;
CREATE TABLE `promotion_seckill_product` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `activity_id` bigint NULL,
  `config_ids` text NULL,
  `spu_id` bigint NULL,
  `sku_id` bigint NULL,
  `seckill_price` int NULL DEFAULT 0,
  `stock` int NULL DEFAULT 0,
  `activity_status` int NULL DEFAULT 0,
  `activity_start_time` datetime NULL,
  `activity_end_time` datetime NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_spu_id` (`spu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from TradeConfigDO
DROP TABLE IF EXISTS `trade_config`;
CREATE TABLE `trade_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `after_sale_refund_reasons` text NULL,
  `after_sale_return_reasons` text NULL,
  `delivery_express_free_enabled` bit(1) NULL DEFAULT b'0',
  `delivery_express_free_price` int NULL DEFAULT 0,
  `delivery_pick_up_enabled` bit(1) NULL DEFAULT b'0',
  `brokerage_enabled` bit(1) NULL DEFAULT b'0',
  `brokerage_enabled_condition` int NULL DEFAULT 0,
  `brokerage_bind_mode` int NULL DEFAULT 0,
  `brokerage_poster_urls` text NULL,
  `brokerage_first_percent` int NULL DEFAULT 0,
  `brokerage_second_percent` int NULL DEFAULT 0,
  `brokerage_withdraw_min_price` int NULL DEFAULT 0,
  `brokerage_withdraw_fee_percent` int NULL DEFAULT 0,
  `brokerage_frozen_days` int NULL DEFAULT 0,
  `brokerage_withdraw_types` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from TradeOrderDO
DROP TABLE IF EXISTS `trade_order`;
CREATE TABLE `trade_order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `no` varchar(512) NULL,
  `type` int NULL DEFAULT 0,
  `terminal` int NULL DEFAULT 0,
  `user_id` bigint NULL,
  `user_ip` varchar(512) NULL,
  `user_remark` text NULL,
  `status` int NULL DEFAULT 0,
  `product_count` int NULL DEFAULT 0,
  `finish_time` datetime NULL,
  `cancel_time` datetime NULL,
  `cancel_type` int NULL DEFAULT 0,
  `remark` text NULL,
  `comment_status` bit(1) NULL DEFAULT b'0',
  `brokerage_user_id` bigint NULL,
  `pay_order_id` bigint NULL,
  `pay_status` bit(1) NULL DEFAULT b'0',
  `pay_time` datetime NULL,
  `pay_channel_code` varchar(512) NULL,
  `total_price` int NULL DEFAULT 0,
  `discount_price` int NULL DEFAULT 0,
  `delivery_price` int NULL DEFAULT 0,
  `adjust_price` int NULL DEFAULT 0,
  `pay_price` int NULL DEFAULT 0,
  `delivery_type` int NULL DEFAULT 0,
  `logistics_id` bigint NULL,
  `logistics_no` varchar(512) NULL,
  `delivery_time` datetime NULL,
  `receive_time` datetime NULL,
  `receiver_name` varchar(512) NULL,
  `receiver_mobile` varchar(512) NULL,
  `receiver_area_id` int NULL,
  `receiver_detail_address` text NULL,
  `pick_up_store_id` bigint NULL,
  `pick_up_verify_code` varchar(512) NULL,
  `refund_status` int NULL DEFAULT 0,
  `refund_price` int NULL DEFAULT 0,
  `coupon_id` bigint NULL,
  `coupon_price` int NULL DEFAULT 0,
  `use_point` int NULL DEFAULT 0,
  `point_price` int NULL DEFAULT 0,
  `give_point` int NULL DEFAULT 0,
  `refund_point` int NULL DEFAULT 0,
  `vip_price` int NULL DEFAULT 0,
  `give_coupon_template_counts` text NULL,
  `give_coupon_ids` text NULL,
  `seckill_activity_id` bigint NULL,
  `bargain_activity_id` bigint NULL,
  `bargain_record_id` bigint NULL,
  `combination_activity_id` bigint NULL,
  `combination_head_id` bigint NULL,
  `combination_record_id` bigint NULL,
  `point_activity_id` bigint NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_no` (`no`),
  KEY `idx_bargain_activity_id` (`bargain_activity_id`),
  KEY `idx_bargain_record_id` (`bargain_record_id`),
  KEY `idx_brokerage_user_id` (`brokerage_user_id`),
  KEY `idx_combination_activity_id` (`combination_activity_id`),
  KEY `idx_combination_head_id` (`combination_head_id`),
  KEY `idx_combination_record_id` (`combination_record_id`),
  KEY `idx_coupon_id` (`coupon_id`),
  KEY `idx_logistics_id` (`logistics_id`),
  KEY `idx_pay_order_id` (`pay_order_id`),
  KEY `idx_pick_up_store_id` (`pick_up_store_id`),
  KEY `idx_point_activity_id` (`point_activity_id`),
  KEY `idx_receiver_area_id` (`receiver_area_id`),
  KEY `idx_seckill_activity_id` (`seckill_activity_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from TradeOrderItemDO
DROP TABLE IF EXISTS `trade_order_item`;
CREATE TABLE `trade_order_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `order_id` bigint NULL,
  `cart_id` bigint NULL,
  `spu_id` bigint NULL,
  `spu_name` varchar(512) NULL,
  `sku_id` bigint NULL,
  `properties` text NULL,
  `pic_url` varchar(512) NULL,
  `count` int NULL DEFAULT 0,
  `comment_status` bit(1) NULL DEFAULT b'0',
  `price` int NULL DEFAULT 0,
  `discount_price` int NULL DEFAULT 0,
  `delivery_price` int NULL DEFAULT 0,
  `adjust_price` int NULL DEFAULT 0,
  `pay_price` int NULL DEFAULT 0,
  `coupon_price` int NULL DEFAULT 0,
  `point_price` int NULL DEFAULT 0,
  `use_point` int NULL DEFAULT 0,
  `give_point` int NULL DEFAULT 0,
  `vip_price` int NULL DEFAULT 0,
  `after_sale_id` bigint NULL,
  `after_sale_status` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_after_sale_id` (`after_sale_id`),
  KEY `idx_cart_id` (`cart_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_spu_id` (`spu_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from TradeOrderLogDO
DROP TABLE IF EXISTS `trade_order_log`;
CREATE TABLE `trade_order_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL,
  `user_type` int NULL DEFAULT 0,
  `order_id` bigint NULL,
  `before_status` int NULL DEFAULT 0,
  `after_status` int NULL DEFAULT 0,
  `operate_type` int NULL DEFAULT 0,
  `content` text NULL,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- from TradeStatisticsDO
DROP TABLE IF EXISTS `trade_statistics`;
CREATE TABLE `trade_statistics` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `time` datetime NULL,
  `order_create_count` int NULL DEFAULT 0,
  `order_pay_count` int NULL DEFAULT 0,
  `order_pay_price` int NULL DEFAULT 0,
  `after_sale_count` int NULL DEFAULT 0,
  `after_sale_refund_price` int NULL DEFAULT 0,
  `brokerage_settlement_price` int NULL DEFAULT 0,
  `wallet_pay_price` int NULL DEFAULT 0,
  `recharge_pay_count` int NULL DEFAULT 0,
  `recharge_pay_price` int NULL DEFAULT 0,
  `recharge_refund_count` int NULL DEFAULT 0,
  `recharge_refund_price` int NULL DEFAULT 0,
  `creator` varchar(64) DEFAULT '',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updater` varchar(64) DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  `tenant_id` bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
