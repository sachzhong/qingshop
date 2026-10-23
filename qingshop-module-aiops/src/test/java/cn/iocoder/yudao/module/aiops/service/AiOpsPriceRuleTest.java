package cn.iocoder.yudao.module.aiops.service;

import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsConfigDO;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsSkuStatBO;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 规则引擎：默认阈值与自定义阈值（纯单元，无 Spring）
 */
class AiOpsPriceRuleTest {

    private static AiOpsSkuStatBO base() {
        AiOpsSkuStatBO s = new AiOpsSkuStatBO();
        s.setPrice(10000);
        s.setStock(50);
        s.setSalesQty(0);
        s.setRefundQty(0);
        s.setOrderCount(0);
        s.setBrowseCount(0);
        s.setSpuCreateTime(LocalDateTime.now().minusDays(20));
        return s;
    }

    @Test
    void defaultZeroSalesCut() {
        assertEquals(-0.08, AiOpsPriceService.rule(base(), 30).changeRatio, 1e-9);
    }

    @Test
    void customZeroSalesCutAndDays() {
        AiOpsPriceService.RuleParams p = AiOpsPriceService.RuleParams.defaults();
        p.zeroSalesDays = 14;
        p.zeroSalesCutRatio = 0.05;
        // 上架 20 天 ≥ 14 → 降 5%
        assertEquals(-0.05, AiOpsPriceService.rule(base(), 30, p).changeRatio, 1e-9);
        // 上架 10 天 < 14 → 不触发零销量降价；非新品（newProductDays=7）→ 无明显信号
        AiOpsSkuStatBO young = base();
        young.setSpuCreateTime(LocalDateTime.now().minusDays(10));
        assertEquals(0, AiOpsPriceService.rule(young, 30, p).changeRatio, 1e-9);
        assertTrue(AiOpsPriceService.rule(young, 30, p).reason.contains("无明显信号"));
    }

    @Test
    void customRefundHold() {
        AiOpsSkuStatBO s = base();
        s.setSalesQty(10);
        s.setRefundQty(2); // 20%
        // 默认 30% → 不因退款 hold
        AiOpsPriceService.RuleDecision d = AiOpsPriceService.rule(s, 30);
        assertFalse(d.reason.contains("退款率"));
        // 阈值 0.15 → hold
        AiOpsPriceService.RuleParams p = AiOpsPriceService.RuleParams.defaults();
        p.refundRateHold = 0.15;
        AiOpsPriceService.RuleDecision hold = AiOpsPriceService.rule(s, 30, p);
        assertEquals(0, hold.changeRatio, 1e-9);
        assertTrue(hold.reason.contains("退款率"));
    }

    @Test
    void customHotRaise() {
        AiOpsSkuStatBO s = base();
        s.setSalesQty(5);
        s.setStock(5); // velocity=5/30, stockDays=5/(5/30)=30 — not hot under default stockDays<7
        // Force hot: sales>=2, stockDays < 40
        AiOpsPriceService.RuleParams p = AiOpsPriceService.RuleParams.defaults();
        p.hotSalesMin = 2;
        p.hotStockDays = 40;
        p.hotRaiseRatio = 0.04;
        AiOpsPriceService.RuleDecision d = AiOpsPriceService.rule(s, 30, p);
        assertEquals(0.04, d.changeRatio, 1e-9);
        assertTrue(d.reason.contains("畅销"));
    }

    @Test
    void customConversionRaise() {
        AiOpsSkuStatBO s = base();
        s.setSalesQty(2);
        s.setOrderCount(5);
        s.setBrowseCount(100); // conv=0.05
        s.setStock(1000); // huge stock days
        AiOpsPriceService.RuleParams p = AiOpsPriceService.RuleParams.defaults();
        p.convMin = 0.04;
        p.convStockDays = 10;
        p.convRaiseRatio = 0.02;
        AiOpsPriceService.RuleDecision d = AiOpsPriceService.rule(s, 30, p);
        assertEquals(0.02, d.changeRatio, 1e-9);
        assertTrue(d.reason.contains("转化率"));
    }

    @Test
    void customNewProductDays() {
        AiOpsSkuStatBO s = base();
        s.setSpuCreateTime(LocalDateTime.now().minusDays(5));
        s.setSalesQty(0);
        AiOpsPriceService.RuleParams p = AiOpsPriceService.RuleParams.defaults();
        p.newProductDays = 10;
        p.zeroSalesDays = 30; // 避免零销量规则抢先
        AiOpsPriceService.RuleDecision d = AiOpsPriceService.rule(s, 30, p);
        assertEquals(0, d.changeRatio, 1e-9);
        assertTrue(d.reason.contains("新品观察期"));
        assertTrue(d.reason.contains("10"));
    }

    @Test
    void fromConfigNullSafe() {
        AiOpsConfigDO c = new AiOpsConfigDO();
        c.setRuleHotRaiseRatio(new BigDecimal("0.05"));
        AiOpsPriceService.RuleParams p = AiOpsPriceService.RuleParams.from(c);
        assertEquals(0.05, p.hotRaiseRatio, 1e-9);
        assertEquals(0.30, p.refundRateHold, 1e-9); // default for null fields
        assertEquals(7, p.zeroSalesDays);
    }

    @Test
    void noStockAlwaysHold() {
        AiOpsSkuStatBO s = base();
        s.setStock(0);
        assertEquals(0, AiOpsPriceService.rule(s, 30).changeRatio, 1e-9);
    }
}
