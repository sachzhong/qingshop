package cn.iocoder.yudao.module.aiops.controller.admin.vo;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 更新 AI 运营配置。注意：只接受 API Key 的环境变量名，不接受 Key 本身
 */
@Data
public class AiOpsConfigSaveReqVO {
    private Boolean priceEnabled;
    private String priceMode;
    private BigDecimal floorCostRatio;
    private BigDecimal floorCurrentRatio;
    private BigDecimal ceilRatio;
    private BigDecimal maxChangeRatio;
    private Integer cooldownHours;
    private Integer statDays;
    private Boolean contentEnabled;
    private String contentMode;
    private Integer contentMaxSpu;
    private Integer contentCooldownHours;
    private String llmBaseUrl;
    private String llmModel;
    private String llmKeyEnv;
    private String imageBaseUrl;
    private String imageModel;
    private String imageKeyEnv;
}
