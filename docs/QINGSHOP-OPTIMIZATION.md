# QingShop 优化与 AI 运营说明

> 基线：yudao-cloud `master@0757f05`（2026.09-jdk8-SNAPSHOT）+ yudao-ui-admin-vue3 `master@050bac1` + yudao-mall-uniapp `master@4924ad5`。
> 本文档对应分支 `feat/ai-ops` 第 1 轮（2026-10-22）。

## 1. 本轮优化内容

### 1.1 修复：游客访问商品价格接口返回 400（上游 bug）
- 现象：未登录时调用 `GET /app-api/trade/order/settlement-product?spuIds=..`（商城首页、商品列表、详情都会调）返回
  `{"code":400,"msg":"请求参数缺失:id"}`，商城 H5 首页的活动价因此加载失败。
- 原因：`TradeDiscountActivityPriceCalculator#getMemberLevel` 在 `userId == null` 时仍 RPC 调用 `member/user/get`，缺少 `id` 参数。
- 修复：`userId == null` 时直接返回 null（游客没有会员等级）。
- 验证：修复后游客调用返回 `code=0`，登录用户行为不变。

### 1.2 商城表结构：自建 DDL + 索引
- 官方商城 SQL 只提供给付费会员，QingShop 不使用。`sql/mysql/qingshop/gen_mall_schema.py` 从 MIT 代码中的 DO 类生成 74 张表。
- 本轮新增索引：所有 `*_id` 外键列建普通索引（151 个），`trade_order.no`、`trade_after_sale.no`、`pay_order_extension.no`、`pay_refund.no`、`pay_transfer.no` 建唯一键。
  依据：各 Mapper 大量按 `user_id / order_id / spu_id / sku_id / template_id` 查询，以及按单号回调查询；原先全部是全表扫描。
- `EXPLAIN select * from trade_order_item where order_id=?` 已走 `idx_order_id`。
- `sync_schema.py` 可在已有数据的库上补列 / 补索引。

### 1.3 其他
- 新增 AI 运营模块（见下文），嵌入 product-server，不增加新的 JVM 进程。

## 2. AI 运营模块 `qingshop-module-aiops`

### 2.1 部署形态
- Maven 模块 `qingshop-module-aiops`（jar），包名 `cn.iocoder.yudao.module.aiops`。
- 通过 Spring Boot 自动配置（`AiOpsAutoConfiguration`）嵌入 **product-server**：扫描自身组件、Mapper，注册 `FileApi` Feign 客户端，开启 `@Scheduled`。
- 网关新增路由 `/admin-api/aiops/** → product-server`。
- 数据访问：商城各服务共用同一个库，模块用 SQL 直接读取 `product_spu / product_sku / trade_order / trade_order_item / trade_after_sale`，
  并直接更新 SKU / SPU 价格和 SPU 文案；多租户条件由 MyBatis-Plus 租户插件自动追加。
  **如果以后各服务拆库，需要改成调用 product / trade 的 RPC 接口。**

### 2.2 大模型
- 自带极简 OpenAI 兼容客户端 `AiOpsLlmClient`（hutool HTTP，`chat/completions`，`response_format=json_object`）。
- 没有复用 `yudao-module-ai`：它依赖 Spring AI 全家桶，在 yudao-cloud 中默认未启用，体积和内存开销都大。
- 默认：`https://api.xiaomimimo.com/v1`、`mimo-v2.6-flash`，Key 从环境变量 `LLM_SERVICE_KEY` 读取（**Key 不入库、不写配置文件**，接口只返回“是否已设置”）。
- 图片：MiMo 的 `/v1/models` 只有文本、语音模型，`/v1/images/generations` 返回 404，**没有图片生成能力**。
  因此默认只保存英文图片提示词并标记「待生成」。配置了 OpenAI 兼容的图片接口（`image_base_url/model/key_env`）后，
  会生成首张图并通过 infra `FileApi` 上传到文件存储——这条路径本轮未能实测。

### 2.3 智能定价
数据流：
1. 统计（窗口默认 30 天）：每个上架 SKU 的已支付销量、订单数、退款件数（售后完成）、库存、当前价、成本价、划线价，SPU 浏览量、上架天数。
2. 规则引擎（`AiOpsPriceService#rule`，阈值来自 `aiops_config`，默认如下）：
   - 无库存 → 不调；退款率 > `rule_refund_rate_hold`(0.30) → 不调；
   - 上架 ≥ `rule_zero_sales_days`(7) 且零销量 → -`rule_zero_sales_cut_ratio`(0.08)；
   - 销量 ≥ `rule_hot_sales_min`(3) 且库存天数 < `rule_hot_stock_days`(7) → +`rule_hot_raise_ratio`(0.06)；
   - 转化率（订单/浏览）≥ `rule_conv_min`(0.10) 且库存天数 > `rule_conv_stock_days`(30) → +`rule_conv_raise_ratio`(0.03)；
   - 上架不足 `rule_new_product_days`(7) → 观察期不调。
3. 大模型：同一 SPU 的 SKU 一次请求，输入统计数据、规则建议、允许区间，输出建议价（分）和理由；失败则回退规则价。
4. 护栏（`AiOpsGuardrail`，纯函数 + 单测）：
   - 底价 = max(成本价 × 1.1, 当前价 × 0.7)，顶价 = 当前价 × 1.3；
   - 单次幅度 ≤ ±10%；区间为空（例如成本过高）时维持原价；
   - 价格取整到 10 分；
   - 冷却：72 小时内执行过（含已回滚）或有待审批建议的 SKU 跳过。
5. 模式：`SUGGEST`（默认，写入待审批）/ `AUTO`（护栏内直接执行）。
6. 执行：乐观更新 `UPDATE product_sku SET price=new WHERE id=? AND price=old`，防止覆盖人工改价；SPU 价同步为最低 SKU 价。
7. 回滚：只有当前价仍等于 AI 设置的价格时才恢复原价。

### 2.4 内容优化
- 输入：标题、副标题、关键词、详情、分类、售价、库存、浏览量、销量；优先处理“有浏览、低转化”的商品。
- 输出：标题（≤40 字）、副标题、关键词、卖点、HTML 详情、2 条图片提示词、改写思路。
- 护栏：去掉 HTML 中的 script/iframe/style/form、on* 事件和 `javascript:`；过滤“最好、第一、顶级、国家级、100%”等广告法极限词；长度截断。
- A/B：`old_*` 为 A 版本、`new_*` 为 B 版本，采用后可一键回滚到 A。本轮只记录版本，没有做前台流量分流。
- 模式同样分 SUGGEST / AUTO，冷却默认 168 小时。

### 2.5 表
| 表 | 说明 |
|---|---|
| `aiops_config` | 每个租户一行：模式、护栏参数、冷却、统计窗口、**规则阈值**、大模型与图片接口配置（只存 Key 的环境变量名） |
| `aiops_price_log` | 每条调价建议：原价、规则价、模型价、最终价、底/顶价、理由、护栏说明、统计快照、状态、执行/回滚时间 |
| `aiops_content_log` | 每条内容改写：A/B 两版内容、卖点、图片提示词与状态、理由、状态 |

状态：0 待审批，1 已执行，2 已拒绝，3 已回滚。

### 2.6 接口（`/admin-api/aiops`）
| 方法 | 路径 | 权限 |
|---|---|---|
| GET | `/config/get` | aiops:config:query |
| PUT | `/config/update` | aiops:config:update |
| POST | `/config/test-llm` | aiops:config:update |
| POST | `/price/run?spuId=&useLlm=` | aiops:price:run |
| GET | `/price-log/page` | aiops:price:query |
| PUT | `/price-log/approve` `/reject` `/rollback` `?id=` | aiops:price:audit |
| POST | `/content/run?spuId=` | aiops:content:run |
| GET | `/content-log/page` | aiops:content:query |
| PUT | `/content-log/approve` `/reject` `/rollback` `?id=` | aiops:content:audit |

### 2.7 定时任务与配置
`product-server` 的 `application.yaml`：
```yaml
qingshop:
  aiops:
    job-enabled: true
    price-cron: "0 0 3 * * ?"
    content-cron: "0 0 4 * * ?"
    llm-base-url: https://api.xiaomimimo.com/v1
    llm-model: mimo-v2.6-flash
    llm-key-env: LLM_SERVICE_KEY
```
定时任务用 Spring `@Scheduled`（不依赖 xxl-job），逐个租户执行已启用的功能。多实例部署时只在一个实例开启 `job-enabled`。

### 2.8 管理后台
菜单「AI运营」（`system_menu` id 9100-9132）：
- 运营配置：模式、护栏、冷却、规则阈值、大模型、图片接口，「测试大模型」按钮；
- 智能定价：立即运行、建议列表（原价→新价、涨跌幅、护栏区间、理由）、批准 / 拒绝 / 回滚；
- 内容优化：立即运行（可指定 SPU）、A/B 对比展开、图片提示词、采用 / 拒绝 / 回滚。

## 3. 如何运行
```bash
# 1. 数据库
mysql -uroot ruoyi-vue-pro < sql/mysql/qingshop/qingshop-aiops.sql
# 2. 后端（product-server 会带上 aiops 模块；gateway 需要新路由）
mvn clean install -DskipTests -pl yudao-gateway,yudao-module-mall/yudao-module-product-server,yudao-module-mall/yudao-module-trade-server -am
export LLM_SERVICE_KEY=你的MiMoKey   # 必须在启动 product-server 的环境中
# 重启 gateway、product-server、trade-server
# 3. 管理后台
cd qingshop-ui-admin && pnpm install && pnpm build:local   # 或 pnpm dev
```
运营配置页确认「服务端已读取到 Key」→「测试大模型」→ 在智能定价页点「立即运行」。

## 4. 已知限制
- 统计只用了订单与售后表，没有用 `product_statistics` 日统计；浏览量来自 `product_spu.browse_count`（累计值，不是窗口值）。
- 规则阈值已可配置（Round 2）；没有竞品价格和节假日因素。
- 大模型可能写出原文没有的描述（实测出现过“基础纯色易搭”这类推断），所以内容默认 SUGGEST，需要人工审核。
- 图片生成路径未实测（没有可用的图片接口）。
- A/B 只是版本记录，没有前台分流与效果统计。
- 定时任务是单机 `@Scheduled`；运行接口是同步的，大模型慢时单次可能要 30–90 秒（前端已放宽超时到 5 分钟）。
- aiops 直接读写商品 / 交易表，依赖“同库部署”。

## 5. 后续每日迭代路线
1. 国际化（i18n）：后台多语言、商品多语言字段、商城前台语言切换。
2. 多币种：商品按币种定价或汇率换算，订单记录结算币种。
3. Stripe / PayPal 支付渠道，接入 pay 模块的渠道抽象。
4. SEO 友好的独立站前台（Nuxt / Next SSR），站点地图、结构化数据。
5. AI 运营：~~规则阈值可配置~~（已完成 Round 2）、按日统计、效果回看（调价前后转化对比）、A/B 分流、接入可用的图片生成接口。
6. 补齐 DDL 的 COMMENT 和更细的字段类型，覆盖更多写入流程的回归测试。
