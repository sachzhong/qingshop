# QingShop 优化日志

## 2026-10-22 第 1 轮（分支 feat/ai-ops）
- 修复上游 bug：游客调用 `/app-api/trade/order/settlement-product` 返回 400。
- 自建商城 / 会员 / 支付表结构（`sql/mysql/qingshop/`），新增 151 个 `*_id` 索引与 5 个单号唯一键，附补列 / 补索引脚本。
- 新增 `qingshop-module-aiops`：智能定价（规则 + MiMo + 护栏 + SUGGEST/AUTO + 审批 / 回滚 + 冷却）、内容优化（A/B 记录 + 图片提示词），嵌入 product-server，网关新增路由。
- 管理后台新增「AI运营」菜单：运营配置、智能定价、内容优化。
- 验证（本机测试环境）：
  - 护栏单测 5/5 通过；
  - 真实 MiMo 定价运行：扫描 6 个 SKU，生成 2 条建议（+3.8%），4 条维持（含 2 条因退款率高）；
  - 批准后 SKU / SPU 价格 159.00 → 165.00，回滚后恢复；AUTO 模式自动执行并回滚成功；冷却与非法配置被拒绝；
  - 内容优化：生成 1 条改写，采用后后台和商城前台都返回新标题，回滚后恢复；
  - 定时任务以每分钟 cron 临时验证成功执行一次后已恢复默认；
  - 管理后台三个页面在浏览器中加载、接口全部 code=0。

## 2026-10-23 第 2 轮（分支 feat/ai-ops）
- 智能定价规则阈值可配置：在 `aiops_config` 增加 10 个字段（退款率 hold、零销量天数/降幅、畅销销量/库存天数/提幅、转化率/库存天数/提幅、新品观察期），默认与 Round 1 硬编码一致。
- `AiOpsPriceService#rule` 改为接收 `RuleParams`（可由配置构造；null 字段回落默认）；管理端「运营配置」页新增「定价规则阈值」表单项，保存时校验比率 0～1、调价幅度 0～0.10 且不超过 `maxChangeRatio`。
- SQL：`qingshop-aiops.sql` CREATE 已含新列；存量库用 `qingshop-aiops-alter-r2.sql`（可重复）。
- 验证：
  - 护栏单测 5/5 + 规则单测（自定义阈值）8/8 全部通过；
  - 管理 API：`/config/get` 返回全部新字段；写入 `ruleZeroSalesDays=3` / `ruleZeroSalesCutRatio=0.05` 可读回；降幅超过 `maxChangeRatio` 返回 400；
  - `useLlm=false`：把 `ruleNewProductDays` 改为 1 后理由变为「上架不足 1 天」；把 `ruleRefundRateHold` 改为 0.99 后理由变为「退款率超过 99%」（证明规则读配置）；恢复默认；
  - `useLlm=true` MiMo 冒烟：扫描 8 SKU，llmUsed=true，生成建议正常。
