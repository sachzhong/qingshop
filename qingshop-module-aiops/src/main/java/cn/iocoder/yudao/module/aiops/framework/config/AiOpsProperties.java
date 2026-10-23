package cn.iocoder.yudao.module.aiops.framework.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * AI 运营默认配置（application.yaml 中 qingshop.aiops.*），租户首次使用时写入 aiops_config 作为初始值
 */
@ConfigurationProperties(prefix = "qingshop.aiops")
@Data
public class AiOpsProperties {

    /** 是否开启定时任务（总开关；租户级开关在 aiops_config 中） */
    private boolean jobEnabled = true;
    /** 智能定价定时任务 cron，默认每天 03:00 */
    private String priceCron = "0 0 3 * * ?";
    /** 内容优化定时任务 cron，默认每天 04:00 */
    private String contentCron = "0 0 4 * * ?";

    private String llmBaseUrl = "https://api.xiaomimimo.com/v1";
    private String llmModel = "mimo-v2.6-flash";
    private String llmKeyEnv = "LLM_SERVICE_KEY";

    /** 图片生成接口，默认不配置（MiMo 没有图片生成模型） */
    private String imageBaseUrl;
    private String imageModel;
    private String imageKeyEnv;

}
