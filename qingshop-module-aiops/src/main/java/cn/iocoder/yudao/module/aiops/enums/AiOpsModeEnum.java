package cn.iocoder.yudao.module.aiops.enums;

/**
 * 运行模式：SUGGEST 只出建议，需管理员审批；AUTO 在护栏内自动执行
 */
public enum AiOpsModeEnum {
    SUGGEST, AUTO;

    public static boolean isAuto(String mode) {
        return AUTO.name().equalsIgnoreCase(mode);
    }
}
