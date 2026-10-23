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
        <el-button type="primary" :loading="running" @click="run" v-hasPermi="['aiops:content:run']">
          <Icon icon="ep:magic-stick" class="mr-5px" />立即优化{{ queryParams.spuId ? '该商品' : '商品内容' }}
        </el-button>
      </el-form-item>
    </el-form>
  </ContentWrap>

  <ContentWrap v-if="lastRun">
    <el-text>
      本次：扫描 {{ lastRun.scanned }}，生成 {{ lastRun.suggested }}，自动执行 {{ lastRun.applied }}，冷却跳过
      {{ lastRun.skipped }}，错误 {{ lastRun.errors }}
    </el-text>
    <ul class="text-12px text-gray-500">
      <li v-for="(m, i) in lastRun.messages" :key="i">{{ m }}</li>
    </ul>
  </ContentWrap>

  <ContentWrap>
    <el-table v-loading="loading" :data="list">
      <el-table-column type="expand">
        <template #default="{ row }">
          <el-row :gutter="20" class="px-20px">
            <el-col :span="12">
              <h4>A 版本（原内容）</h4>
              <p><b>副标题：</b>{{ row.oldIntroduction }}</p>
              <p><b>关键词：</b>{{ row.oldKeyword }}</p>
              <div class="aiops-html" v-dompurify-html="row.oldDescription || ''"></div>
            </el-col>
            <el-col :span="12">
              <h4>B 版本（AI 改写）</h4>
              <p><b>副标题：</b>{{ row.newIntroduction }}</p>
              <p><b>关键词：</b>{{ row.newKeyword }}</p>
              <div class="aiops-html" v-dompurify-html="row.newDescription || ''"></div>
            </el-col>
          </el-row>
          <div class="px-20px text-12px text-gray-500">
            <p><b>图片：</b>{{ AiOpsApi.IMAGE_STATUS[row.imageStatus] }}</p>
            <p v-for="(p, i) in parse(row.imagePrompts)" :key="i">提示词 {{ i + 1 }}：{{ p }}</p>
            <p v-for="(u, i) in parse(row.imageUrls)" :key="'u' + i"><el-image :src="u" class="w-120px" /></p>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="编号" prop="id" width="70" />
      <el-table-column label="SPU" prop="spuId" width="70" />
      <el-table-column label="标题（原 → 新）" min-width="300">
        <template #default="{ row }">
          <div class="text-gray-400 line-through">{{ row.oldName }}</div>
          <div>{{ row.newName }}</div>
        </template>
      </el-table-column>
      <el-table-column label="改写思路" prop="reason" min-width="260" />
      <el-table-column label="状态" width="90">
        <template #default="{ row }">
          <el-tag :type="statusOf(row.status).type">{{ statusOf(row.status).label }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" prop="createTime" :formatter="dateFormatter" width="170" />
      <el-table-column label="操作" width="170" fixed="right">
        <template #default="{ row }">
          <template v-if="row.status === 0">
            <el-button link type="primary" @click="act('approve', row)" v-hasPermi="['aiops:content:audit']">采用</el-button>
            <el-button link type="info" @click="act('reject', row)" v-hasPermi="['aiops:content:audit']">拒绝</el-button>
          </template>
          <el-button v-if="row.status === 1" link type="danger" @click="act('rollback', row)" v-hasPermi="['aiops:content:audit']">回滚到 A</el-button>
        </template>
      </el-table-column>
    </el-table>
    <Pagination :total="total" v-model:page="queryParams.pageNo" v-model:limit="queryParams.pageSize" @pagination="getList" />
  </ContentWrap>
</template>

<script lang="ts" setup>
import { dateFormatter } from '@/utils/formatTime'
import * as AiOpsApi from '@/api/aiops'

defineOptions({ name: 'AiOpsContent' })

const message = useMessage()
const loading = ref(true)
const running = ref(false)
const total = ref(0)
const list = ref<any[]>([])
const lastRun = ref<AiOpsApi.AiOpsRunResultVO>()
const queryParams = reactive({ pageNo: 1, pageSize: 10, spuId: undefined, status: undefined })

const statusOf = (s: number) => AiOpsApi.LOG_STATUS.find((x) => x.value === s) || AiOpsApi.LOG_STATUS[0]
const parse = (s?: string) => {
  try {
    return s ? JSON.parse(s) : []
  } catch {
    return []
  }
}

const getList = async () => {
  loading.value = true
  try {
    const data = await AiOpsApi.getContentLogPage(queryParams)
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
    lastRun.value = await AiOpsApi.runContent({ spuId: queryParams.spuId || undefined })
    message.success('运行完成')
    await getList()
  } finally {
    running.value = false
  }
}
const act = async (type: 'approve' | 'reject' | 'rollback', row: any) => {
  const text = { approve: '采用 AI 改写内容（会修改商品标题/详情）', reject: '拒绝', rollback: '回滚到原内容' }[type]
  await message.confirm(`确认${text}？商品 ${row.spuId}`)
  const fn = { approve: AiOpsApi.approveContent, reject: AiOpsApi.rejectContent, rollback: AiOpsApi.rollbackContent }[type]
  await fn(row.id)
  message.success('操作成功')
  await getList()
}

onMounted(getList)
</script>

<style scoped>
.aiops-html {
  max-height: 300px;
  overflow: auto;
  padding: 8px;
  border: 1px dashed var(--el-border-color);
}
</style>
