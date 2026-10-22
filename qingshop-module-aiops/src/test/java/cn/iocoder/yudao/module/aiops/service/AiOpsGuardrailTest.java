package cn.iocoder.yudao.module.aiops.service;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

class AiOpsGuardrailTest {

    private static AiOpsGuardrail.Result apply(int current, Integer cost, int candidate) {
        return AiOpsGuardrail.apply(current, cost, candidate, new BigDecimal("1.10"), new BigDecimal("0.70"),
                new BigDecimal("1.30"), new BigDecimal("0.10"));
    }

    @Test
    void clampToMaxChange() {
        AiOpsGuardrail.Result r = apply(10000, 3000, 20000);
        assertEquals(11000, r.getPrice());
        assertNotNull(r.getNote());
        assertEquals(9000, apply(10000, 3000, 1).getPrice());
    }

    @Test
    void floorByCost() {
        // 成本 9500 * 1.1 = 10450，高于当前价 * 0.9，下限取 10450
        AiOpsGuardrail.Result r = apply(10000, 9500, 9000);
        assertEquals(10450, r.getFloor());
        assertTrue(r.getPrice() >= 10450 && r.getPrice() <= 11000);
    }

    @Test
    void blockedWhenFloorAboveCeil() {
        AiOpsGuardrail.Result r = apply(10000, 12000, 9000);
        assertTrue(r.isBlocked());
        assertEquals(10000, r.getPrice());
    }

    @Test
    void roundTo10Fen() {
        assertEquals(10260, apply(10000, 3000, 10257).getPrice());
    }

    @Test
    void ruleSlowMover() {
        cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsSkuStatBO s = new cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsSkuStatBO();
        s.setPrice(10000);
        s.setStock(50);
        s.setSalesQty(0);
        s.setSpuCreateTime(java.time.LocalDateTime.now().minusDays(20));
        assertEquals(-0.08, AiOpsPriceService.rule(s, 30).changeRatio, 1e-9);
    }

}
