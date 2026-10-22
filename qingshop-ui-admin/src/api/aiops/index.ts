import request from '@/config/axios'

/** QingShop AI 运营（后端：qingshop-module-aiops，嵌入 product-server，网关路由 /admin-api/aiops/**） */

export interface AiOpsConfigVO {
  id?: number
  priceEnabled: boolean
  priceMode: 'SUGGEST' | 'AUTO'
  floorCostRatio: number
  floorCurrentRatio: number
  ceilRatio: number
  maxChangeRatio: number
  cooldownHours: number
  statDays: number
  contentEnabled: boolean
  contentMode: 'SUGGEST' | 'AUTO'
  contentMaxSpu: number
  contentCooldownHours: number
  llmBaseUrl: string
  llmModel: string
  llmKeyEnv: string
  imageBaseUrl?: string
  imageModel?: string
  imageKeyEnv?: string
  /** 只读：环境变量中是否存在 Key */
  llmKeyPresent?: boolean
  imageKeyPresent?: boolean
}

export interface AiOpsRunResultVO {
  runId: string
  mode: string
  scanned: number
  suggested: number
  applied: number
  held: number
  skipped: number
  errors: number
  llmUsed: boolean
  messages: string[]
}

/** 大模型调用较慢，运行类接口放宽超时 */
const LONG_TIMEOUT = 5 * 60 * 1000

export const getConfig = () => request.get<AiOpsConfigVO>({ url: '/aiops/config/get' })
export const updateConfig = (data: AiOpsConfigVO) => request.put({ url: '/aiops/config/update', data })
export const testLlm = () => request.post({ url: '/aiops/config/test-llm', timeout: 120000 })

export const runPrice = (params: { spuId?: number; useLlm?: boolean }) =>
  request.post<AiOpsRunResultVO>({ url: '/aiops/price/run', params, timeout: LONG_TIMEOUT })
export const getPriceLogPage = (params: any) => request.get({ url: '/aiops/price-log/page', params })
export const approvePrice = (id: number) => request.put({ url: '/aiops/price-log/approve?id=' + id })
export const rejectPrice = (id: number) => request.put({ url: '/aiops/price-log/reject?id=' + id })
export const rollbackPrice = (id: number) => request.put({ url: '/aiops/price-log/rollback?id=' + id })

export const runContent = (params: { spuId?: number }) =>
  request.post<AiOpsRunResultVO>({ url: '/aiops/content/run', params, timeout: LONG_TIMEOUT })
export const getContentLogPage = (params: any) => request.get({ url: '/aiops/content-log/page', params })
export const approveContent = (id: number) => request.put({ url: '/aiops/content-log/approve?id=' + id })
export const rejectContent = (id: number) => request.put({ url: '/aiops/content-log/reject?id=' + id })
export const rollbackContent = (id: number) => request.put({ url: '/aiops/content-log/rollback?id=' + id })

export const LOG_STATUS = [
  { value: 0, label: '待审批', type: 'warning' },
  { value: 1, label: '已执行', type: 'success' },
  { value: 2, label: '已拒绝', type: 'info' },
  { value: 3, label: '已回滚', type: 'danger' }
]
export const IMAGE_STATUS: Record<number, string> = { 0: '无', 1: '待生成（未配置图片接口）', 2: '已生成', 3: '生成失败' }
