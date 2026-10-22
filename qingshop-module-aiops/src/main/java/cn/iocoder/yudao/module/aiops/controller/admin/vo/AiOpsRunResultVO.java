package cn.iocoder.yudao.module.aiops.controller.admin.vo;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class AiOpsRunResultVO {
    private String runId;
    private String mode;
    /** 扫描的 SKU / SPU 数 */
    private int scanned;
    /** 生成的建议数（含自动执行） */
    private int suggested;
    /** 自动执行数 */
    private int applied;
    /** 维持原价 / 无需修改 */
    private int held;
    /** 冷却期跳过 */
    private int skipped;
    private int errors;
    private boolean llmUsed;
    private List<String> messages = new ArrayList<>();
}
