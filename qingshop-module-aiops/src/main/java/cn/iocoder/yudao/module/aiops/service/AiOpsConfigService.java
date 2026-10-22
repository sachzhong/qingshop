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
    }

    private static void checkRange(String name, BigDecimal v, String min, String max) {
        if (v != null && (v.compareTo(new BigDecimal(min)) < 0 || v.compareTo(new BigDecimal(max)) > 0)) {
            throw invalidParamException(name + " 需在 " + min + " ~ " + max + " 之间");
        }
    }

}
