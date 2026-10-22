# QingShop 自有 SQL

| 文件 | 说明 |
|---|---|
| `gen_mall_schema.py` | 从 mall / member / pay 模块的 `@TableName` DO 类生成 MySQL 8 建表语句（不使用官方付费 SQL） |
| `qingshop-mall-schema.sql` | 生成结果：74 张表，含 `*_id` 普通索引与订单号等唯一键 |
| `sync_schema.py` | 对已有库只增不删地补列、改 text 类型、补索引（保留数据） |
| `qingshop-aiops.sql` | AI 运营模块的 3 张表与「AI运营」菜单，可重复执行 |

```bash
# 全新库：先导入 sql/mysql/ruoyi-vue-pro.sql、quartz.sql，再：
mysql -uroot ruoyi-vue-pro < sql/mysql/qingshop/qingshop-mall-schema.sql   # 注意：含 DROP TABLE IF EXISTS
mysql -uroot ruoyi-vue-pro < sql/mysql/qingshop/qingshop-aiops.sql
# 已有数据的库：
python3 sql/mysql/qingshop/sync_schema.py mysql -uroot -p
# 修改 DO 后重新生成（第一个参数为已存在、需跳过的表，逗号分隔）
python3 sql/mysql/qingshop/gen_mall_schema.py ""
```

说明：生成的表没有 COMMENT；数字列默认 0、集合/JSON 字段用 text；系统自带表不在生成范围内。
