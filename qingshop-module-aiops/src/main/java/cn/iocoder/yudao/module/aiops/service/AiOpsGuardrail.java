package cn.iocoder.yudao.module.aiops.service;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 调价护栏（纯函数，便于单测）。
 *
 * 底价 floor = max(成本价 × floorCostRatio, 当前价 × floorCurrentRatio)
 * 顶价 ceil  = 当前价 × ceilRatio
 * 单次幅度   = 当前价 × (1 ± maxChangeRatio)
 * 最终价格取候选价在 [max(floor, 下限), min(ceil, 上限)] 区间内的截断值，并取整到 10 分。
 */
public class AiOpsGuardrail {

    @Data
    @AllArgsConstructor
    public static class Result {
        private int price;
        private int floor;
        private int ceil;
        /** 护栏说明，为空表示未触发 */
        private String note;
        /** 区间为空（例如底价已高于允许的最高价），只能维持原价 */
        private boolean blocked;
    }

    public static Result apply(int current, Integer cost, int candidate,
                               BigDecimal floorCostRatio, BigDecimal floorCurrentRatio,
                               BigDecimal ceilRatio, BigDecimal maxChangeRatio) {
        int floorByCost = cost != null && cost > 0 ? ceilInt(cost * floorCostRatio.doubleValue()) : 0;
        int floor = Math.max(floorByCost, ceilInt(current * floorCurrentRatio.doubleValue()));
        int ceil = (int) Math.floor(current * ceilRatio.doubleValue());
        int lo = Math.max(floor, ceilInt(current * (1 - maxChangeRatio.doubleValue())));
        int hi = Math.min(ceil, (int) Math.floor(current * (1 + maxChangeRatio.doubleValue())));
        if (lo > hi) {
            return new Result(current, floor, ceil, "护栏区间为空（底价 " + floor + " 高于允许最高价 " + hi + "），维持原价", true);
        }
        StringBuilder note = new StringBuilder();
        int p = candidate;
        if (p < lo) {
            note.append("候选价 ").append(candidate).append(" 低于下限 ").append(lo).append("，已截断；");
            p = lo;
        } else if (p > hi) {
            note.append("候选价 ").append(candidate).append(" 高于上限 ").append(hi).append("，已截断；");
            p = hi;
        }
        // 取整到 10 分，且保持在区间内
        int rounded = Math.round(p / 10f) * 10;
        if (rounded < lo) {
            rounded += 10;
        }
        if (rounded > hi) {
            rounded = p;
        }
        return new Result(rounded, floor, ceil, note.length() > 0 ? note.toString() : null, false);
    }

    private static int ceilInt(double v) {
        return (int) Math.ceil(v - 1e-9);
    }

}
