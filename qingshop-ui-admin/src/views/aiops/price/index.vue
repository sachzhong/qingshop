<template>
  <ContentWrap>
    <el-form :model="queryParams" :inline="true" class="-mb-15px">
      <el-form-item label="商品编号">
        <el-input v-model="queryParams.spuId" placeholder="SPU 编号" clearable class="!w-160px" />
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="queryParams.status" clearable placeholder="全部" class="!w-140px">
          <el-option v-for="s in AiOpsApi.LOG_STATUS" :key="s.value" :label="s.label" :value="s.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button @click="handleQuery"><Icon icon="ep:search" class="mr-5px" />搜索</el-button>
        <el-button type="primary" :loading="running" @click="run" v-hasPermi="['aiops:price:run']">
          <Icon icon="ep:magic-stick" class="mr-5px" />立即运行智能定价
        </el-button>
      </el-form-item>
    </el-form>
  </ContentWrap>

  <ContentWrap v-if="lastRun">
    <el-descriptions :column="7" border size="small" title="本次运行结果">
      <el-descriptions-item label="模式">{{ lastRun.mode }}</el-descriptions-item>
      <el-descriptions-item label="扫描 SKU">{{ lastRun.scanned }}</el-descriptions-item>
      <el-descriptions-item label="生成建议">{{ lastRun.suggested }}</el-descriptions-item>
      <el-descriptions-item label="自动执行">{{ lastRun.applied }}</el-descriptions-item>
      <el-descriptions-item label="维持原价">{{ lastRun.held }}</el-descriptions-item>
      <el-descriptions-item label="冷却跳过">{{ lastRun.skipped }}</el-descriptions-item>
      <el-descriptions-item label="错误">{{ lastRun.errors }}</el-descriptions-item>
    </el-descriptions>
    <ul class="text-12px text-gray-500 mt-10px">
      <li v-for="(m, i) in lastRun.messages" :key="i">{{ m }}</li>
    </ul>
  </ContentWrap>

  <ContentWrap>
    <el-table v-loading="loading" :data="list">
      <el-table-column label="编号" prop="id" width="70" />
      <el-table-column label="商品" min-width="200">
        <template #default="{ row }">
          <div>{{ row.spuName }}</div>
          <div class="text-gray-400 text-12px">SPU {{ row.spuId }} / SKU {{ row.skuId }} {{ row.skuName }}</div>
        </template>
      </el-table-column>
      <el-table-column label="原价 → 新价" width="170">
        <template #default="{ row }">
          ¥{{ fen(row.oldPrice) }} → <b>¥{{ fen(row.newPrice) }}</b>
          <el-tag size="small" :type="row.newPrice > row.oldPrice ? 'danger' : 'success'" class="ml-5px">
            {{ pct(row) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="护栏区间" width="150">
        <template #default="{ row }">¥{{ fen(row.floorPrice) }} ~ ¥{{ fen(row.ceilPrice) }}</template>
      </el-table-column>
      <el-table-column label="理由" min-width="300">
        <template #default="{ row }">
          <div>{{ row.reason }}</div>
          <div class="text-gray-400 text-12px">规则：{{ row.ruleReason }}</div>
          <div v-if="row.guardNote" class="text-orange-400 text-12px">护栏：{{ row.guardNote }}</div>
        </template>
      </el-table-column>
      <el-table-column label="模式" prop="mode" width="90" />
      <el-table-column label="状态" width="90">
        <template #default="{ row }">
          <el-tag :type="statusOf(row.status).type">{{ statusOf(row.status).label }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" prop="createTime" :formatter="dateFormatter" width="170" />
      <el-table-column label="操作" width="170" fixed="right">
        <template #default="{ row }">
          <template v-if="row.status === 0">
            <el-button link type="primary" @click="act('approve', row)" v-hasPermi="['aiops:price:audit']">批准</el-button>
            <el-button link type="info" @click="act('reject', row)" v-hasPermi="['aiops:price:audit']">拒绝</el-button>
          </template>
          <el-button v-if="row.status === 1" link type="danger" @click="act('rollback', row)" v-hasPermi="['aiops:price:audit']">回滚</el-button>
        </template>
      </el-table-column>
    </el-table>
    <Pagination :total="total" v-model:page="queryParams.pageNo" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </ContentWrap>
</template>

<script lang="ts" setup>
import { dateFormatter } from '@/utils/formatTime'
import * as AiOpsApi from '@/api/aiops'

defineOptions({ name: 'AiOpsPrice' })

const message = useMessage()
const loading = ref(true)
const running = ref(false)
const total = ref(0)
const list = ref<any[]>([])
const lastRun = ref<AiOpsApi.AiOpsRunResultVO>()
const queryParams = reactive({ pageNo: 1, pageSize: 10, spuId: undefined, status: undefined })

const fen = (v: number) => (v / 100).toFixed(2)
const pct = (row: any) => ((row.newPrice - row.oldPrice) / row.oldPrice * 100).toFixed(1) + '%'
const statusOf = (s: number) => AiOpsApi.LOG_STATUS.find((x) => x.value === s) || AiOpsApi.LOG_STATUS[0]

const getList = async () => {
  loading.value = true
  try {
    const data = await AiOpsApi.getPriceLogPage(queryParams)
    list.value = data.list
    total.value = data.total
  } finally {
    loading.value = false
  }
}
const handleQuery = () => {
  queryParams.pageNo = 1
  getList()
}
const run = async () => {
  running.value = true
  try {
    lastRun.value = await AiOpsApi.runPrice({})
    message.success('运行完成')
    await getList()
  } finally {
    running.value = false
  }
}
const act = async (type: 'approve' | 'reject' | 'rollback', row: any) => {
  const text = { approve: '批准并修改售价', reject: '拒绝该建议', rollback: '回滚到原价' }[type]
  await message.confirm(`确认${text}？SKU ${row.skuId}：¥${fen(row.oldPrice)} → ¥${fen(row.newPrice)}`)
  const fn = { approve: AiOpsApi.approvePrice, reject: AiOpsApi.rejectPrice, rollback: AiOpsApi.rollbackPrice }[type]
  await fn(row.id)
  message.success('操作成功')
  await getList()
}

onMounted(getList)
</script>
