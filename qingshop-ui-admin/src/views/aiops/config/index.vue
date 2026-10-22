<template>
  <ContentWrap v-loading="loading">
    <el-alert
      type="info"
      :closable="false"
      class="mb-15px"
      title="AI 运营默认为「建议模式」：AI 只生成建议，需管理员在「智能定价 / 内容优化」页面审批后才生效。自动模式下也只会在护栏范围内修改。"
    />
    <el-form ref="formRef" :model="form" label-width="170px" class="max-w-900px">
      <el-divider content-position="left">智能定价</el-divider>
      <el-form-item label="定时任务">
        <el-switch v-model="form.priceEnabled" active-text="启用" inactive-text="停用" />
      </el-form-item>
      <el-form-item label="运行模式">
        <el-radio-group v-model="form.priceMode">
          <el-radio value="SUGGEST">建议（需审批）</el-radio>
          <el-radio value="AUTO">自动（护栏内直接生效）</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="底价 = 成本价 ×">
        <el-input-number v-model="form.floorCostRatio" :min="1" :max="3" :step="0.05" :precision="2" />
        <span class="ml-10px text-gray-400">与「当前价 × 比例」取较大值</span>
      </el-form-item>
      <el-form-item label="底价 = 当前价 ×">
        <el-input-number v-model="form.floorCurrentRatio" :min="0.3" :max="1" :step="0.05" :precision="2" />
      </el-form-item>
      <el-form-item label="顶价 = 当前价 ×">
        <el-input-number v-model="form.ceilRatio" :min="1" :max="3" :step="0.05" :precision="2" />
      </el-form-item>
      <el-form-item label="单次最大调整幅度">
        <el-input-number v-model="form.maxChangeRatio" :min="0.01" :max="0.5" :step="0.01" :precision="2" />
        <span class="ml-10px text-gray-400">0.10 = ±10%</span>
      </el-form-item>
      <el-form-item label="调价冷却（小时）">
        <el-input-number v-model="form.cooldownHours" :min="0" :max="2160" />
      </el-form-item>
      <el-form-item label="统计窗口（天）">
        <el-input-number v-model="form.statDays" :min="1" :max="365" />
      </el-form-item>

      <el-divider content-position="left">内容优化</el-divider>
      <el-form-item label="定时任务">
        <el-switch v-model="form.contentEnabled" active-text="启用" inactive-text="停用" />
      </el-form-item>
      <el-form-item label="运行模式">
        <el-radio-group v-model="form.contentMode">
          <el-radio value="SUGGEST">建议（需审批）</el-radio>
          <el-radio value="AUTO">自动</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="每次最多处理商品数">
        <el-input-number v-model="form.contentMaxSpu" :min="1" :max="50" />
      </el-form-item>
      <el-form-item label="内容冷却（小时）">
        <el-input-number v-model="form.contentCooldownHours" :min="0" :max="2160" />
      </el-form-item>

      <el-divider content-position="left">大模型（OpenAI 兼容）</el-divider>
      <el-form-item label="Base URL">
        <el-input v-model="form.llmBaseUrl" placeholder="https://api.xiaomimimo.com/v1" />
      </el-form-item>
      <el-form-item label="模型">
        <el-input v-model="form.llmModel" placeholder="mimo-v2.6-flash" />
      </el-form-item>
      <el-form-item label="API Key 环境变量名">
        <el-input v-model="form.llmKeyEnv" placeholder="LLM_SERVICE_KEY" class="!w-300px" />
        <el-tag class="ml-10px" :type="form.llmKeyPresent ? 'success' : 'danger'">
          {{ form.llmKeyPresent ? '服务端已读取到 Key' : '服务端未设置该环境变量' }}
        </el-tag>
      </el-form-item>
      <el-form-item label="图片接口 Base URL">
        <el-input v-model="form.imageBaseUrl" placeholder="留空 = 不生成图片，只保存提示词" />
      </el-form-item>
      <el-form-item label="图片模型 / Key 环境变量">
        <el-input v-model="form.imageModel" placeholder="模型" class="!w-200px mr-10px" />
        <el-input v-model="form.imageKeyEnv" placeholder="环境变量名" class="!w-200px" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="save" v-hasPermi="['aiops:config:update']">保存</el-button>
        <el-button @click="test" :loading="testing" v-hasPermi="['aiops:config:update']">测试大模型</el-button>
      </el-form-item>
    </el-form>
  </ContentWrap>
</template>

<script lang="ts" setup>
import * as AiOpsApi from '@/api/aiops'

defineOptions({ name: 'AiOpsConfig' })

const message = useMessage()
const loading = ref(true)
const testing = ref(false)
const form = ref<AiOpsApi.AiOpsConfigVO>({} as AiOpsApi.AiOpsConfigVO)

const load = async () => {
  loading.value = true
  try {
    form.value = await AiOpsApi.getConfig()
  } finally {
    loading.value = false
  }
}

const save = async () => {
  await AiOpsApi.updateConfig(form.value)
  message.success('保存成功')
  await load()
}

const test = async () => {
  testing.value = true
  try {
    const res: any = await AiOpsApi.testLlm()
    message.success(`连通成功：${res.model}，耗时 ${res.costMs} ms`)
  } finally {
    testing.value = false
  }
}

onMounted(load)
</script>
