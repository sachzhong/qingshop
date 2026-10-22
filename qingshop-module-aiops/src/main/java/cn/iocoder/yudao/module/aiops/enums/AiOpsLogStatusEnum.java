package cn.iocoder.yudao.module.aiops.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * AI 运营建议的状态
 */
@Getter
@AllArgsConstructor
public enum AiOpsLogStatusEnum {

    PENDING(0, "待审批"),
    APPLIED(1, "已执行"),
    REJECTED(2, "已拒绝"),
    ROLLED_BACK(3, "已回滚");

    private final Integer status;
    private final String name;

}
