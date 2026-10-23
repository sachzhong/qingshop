package cn.iocoder.yudao.module.aiops.service;

import cn.hutool.core.util.StrUtil;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsConfigDO;
import cn.iocoder.yudao.module.aiops.dal.mysql.AiOpsConfigMapper;
import cn.iocoder.yudao.module.aiops.enums.AiOpsModeEnum;
import cn.iocoder.yudao.module.aiops.framework.config.AiOpsProperties;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.math.BigDecimal;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.invalidParamException;

@Service
public class AiOpsConfigService {

    @Resource
    private AiOpsConfigMapper configMapper;
    @Resource
    private AiOpsProperties properties;

    /** 获取当前租户的配置；没有则按默认值创建 */
    public AiOpsConfigDO getOrCreate() {
        AiOpsConfigDO config = configMapper.selectOne(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<AiOpsConfigDO>().last("LIMIT 1"));
        if (config != null) {
            return config;
        }
        config = new AiOpsConfigDO();
        config.setPriceEnabled(true);
        config.setPriceMode(AiOpsModeEnum.SUGGEST.name());
        config.setFloorCostRatio(new BigDecimal("1.10"));
        config.setFloorCurrentRatio(new BigDecimal("0.70"));
        config.setCeilRatio(new BigDecimal("1.30"));
        config.setMaxChangeRatio(new BigDecimal("0.10"));
        config.setCooldownHours(72);
        config.setStatDays(30);
        config.setRuleRefundRateHold(new BigDecimal("0.30"));
        config.setRuleZeroSalesDays(7);
        config.setRuleZeroSalesCutRatio(new BigDecimal("0.08"));
        config.setRuleHotSalesMin(3);
        config.setRuleHotStockDays(7);
        config.setRuleHotRaiseRatio(new BigDecimal("0.06"));
        config.setRuleConvMin(new BigDecimal("0.10"));
        config.setRuleConvStockDays(30);
        config.setRuleConvRaiseRatio(new BigDecimal("0.03"));
        config.setRuleNewProductDays(7);
        config.setContentEnabled(false);
        config.setContentMode(AiOpsModeEnum.SUGGEST.name());
        config.setContentMaxSpu(5);
        config.setContentCooldownHours(168);
        config.setLlmBaseUrl(properties.getLlmBaseUrl());
        config.setLlmModel(properties.getLlmModel());
        config.setLlmKeyEnv(properties.getLlmKeyEnv());
        config.setImageBaseUrl(properties.getImageBaseUrl());
        config.setImageModel(properties.getImageModel());
        config.setImageKeyEnv(properties.getImageKeyEnv());
        configMapper.insert(config);
        return config;
    }

    public void update(AiOpsConfigDO reqVO) {
        AiOpsConfigDO config = getOrCreate();
        validate(reqVO);
        reqVO.setId(config.getId());
        configMapper.updateById(reqVO);
    }

    private static void validate(AiOpsConfigDO c) {
        if (c.getPriceMode() != null && !StrUtil.equalsAnyIgnoreCase(c.getPriceMode(), "SUGGEST", "AUTO")) {
            throw invalidParamException("定价模式只能是 SUGGEST 或 AUTO");
        }
        if (c.getContentMode() != null && !StrUtil.equalsAnyIgnoreCase(c.getContentMode(), "SUGGEST", "AUTO")) {
            throw invalidParamException("内容模式只能是 SUGGEST 或 AUTO");
        }
        checkRange("成本价底价倍数", c.getFloorCostRatio(), "1.00", "3.00");
        checkRange("当前价底价比例", c.getFloorCurrentRatio(), "0.30", "1.00");
        checkRange("顶价比例", c.getCeilRatio(), "1.00", "3.00");
        checkRange("单次最大调整幅度", c.getMaxChangeRatio(), "0.01", "0.50");
        if (c.getCooldownHours() != null && c.getCooldownHours() < 0) {
            throw invalidParamException("冷却时间不能为负数");
        }
        if (c.getStatDays() != null && (c.getStatDays() < 1 || c.getStatDays() > 365)) {
            throw invalidParamException("统计窗口需在 1-365 天");
        }
        if (c.getContentMaxSpu() != null && (c.getContentMaxSpu() < 1 || c.getContentMaxSpu() > 50)) {
            throw invalidParamException("每次内容优化的商品数需在 1-50");
        }
        // 规则阈值：比率 0~1；调价幅度 0~0.10（且不超过当前 maxChangeRatio，若已给出）
        checkRange("退款率阈值", c.getRuleRefundRateHold(), "0", "1");
        checkRange("零销量降价幅度", c.getRuleZeroSalesCutRatio(), "0", "0.10");
        checkRange("畅销提价幅度", c.getRuleHotRaiseRatio(), "0", "0.10");
        checkRange("高转化提价幅度", c.getRuleConvRaiseRatio(), "0", "0.10");
        checkRange("转化率阈值", c.getRuleConvMin(), "0", "1");
        checkPositiveDays("零销量上架天数阈值", c.getRuleZeroSalesDays());
        checkPositiveDays("畅销库存天数阈值", c.getRuleHotStockDays());
        checkPositiveDays("高转化库存天数阈值", c.getRuleConvStockDays());
        checkPositiveDays("新品观察期天数", c.getRuleNewProductDays());
        if (c.getRuleHotSalesMin() != null && c.getRuleHotSalesMin() < 0) {
            throw invalidParamException("畅销销量下限不能为负数");
        }
        BigDecimal maxChange = c.getMaxChangeRatio();
        if (maxChange != null) {
            ensureNotExceed("零销量降价幅度", c.getRuleZeroSalesCutRatio(), maxChange);
            ensureNotExceed("畅销提价幅度", c.getRuleHotRaiseRatio(), maxChange);
            ensureNotExceed("高转化提价幅度", c.getRuleConvRaiseRatio(), maxChange);
        }
    }

    private static void checkPositiveDays(String name, Integer v) {
        if (v != null && (v < 1 || v > 365)) {
            throw invalidParamException(name + " 需在 1-365");
        }
    }

    private static void ensureNotExceed(String name, BigDecimal ratio, BigDecimal maxChange) {
        if (ratio != null && ratio.compareTo(maxChange) > 0) {
            throw invalidParamException(name + " 不能超过单次最大调整幅度 " + maxChange);
        }
    }

    private static void checkRange(String name, BigDecimal v, String min, String max) {
        if (v != null && (v.compareTo(new BigDecimal(min)) < 0 || v.compareTo(new BigDecimal(max)) > 0)) {
            throw invalidParamException(name + " 需在 " + min + " ~ " + max + " 之间");
        }
    }

}
