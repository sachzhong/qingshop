package cn.iocoder.yudao.module.aiops.job;

import cn.iocoder.yudao.framework.tenant.core.util.TenantUtils;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsConfigDO;
import cn.iocoder.yudao.module.aiops.dal.mysql.AiOpsConfigMapper;
import cn.iocoder.yudao.module.aiops.framework.config.AiOpsProperties;
import cn.iocoder.yudao.module.aiops.service.AiOpsContentService;
import cn.iocoder.yudao.module.aiops.service.AiOpsPriceService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;

/**
 * AI 运营定时任务。用 Spring @Scheduled 而不是 xxl-job，避免额外部署调度中心；
 * 多实例部署时请只在一个实例开启 qingshop.aiops.job-enabled，或改造成 xxl-job。
 */
@Component
@Slf4j
public class AiOpsJob {

    @Resource
    private AiOpsProperties properties;
    @Resource
    private AiOpsConfigMapper configMapper;
    @Resource
    private AiOpsPriceService priceService;
    @Resource
    private AiOpsContentService contentService;

    @Scheduled(cron = "${qingshop.aiops.price-cron:0 0 3 * * ?}")
    public void priceJob() {
        if (!properties.isJobEnabled()) {
            return;
        }
        for (AiOpsConfigDO c : configMapper.selectAllIgnoreTenant()) {
            if (Boolean.TRUE.equals(c.getPriceEnabled())) {
                try {
                    TenantUtils.execute(c.getTenantId(), () -> log.info("[priceJob][tenant({}) {}]", c.getTenantId(), priceService.run(null, true)));
                } catch (Exception e) {
                    log.error("[priceJob][tenant({}) 失败]", c.getTenantId(), e);
                }
            }
        }
    }

    @Scheduled(cron = "${qingshop.aiops.content-cron:0 0 4 * * ?}")
    public void contentJob() {
        if (!properties.isJobEnabled()) {
            return;
        }
        for (AiOpsConfigDO c : configMapper.selectAllIgnoreTenant()) {
            if (Boolean.TRUE.equals(c.getContentEnabled())) {
                try {
                    TenantUtils.execute(c.getTenantId(), () -> log.info("[contentJob][tenant({}) {}]", c.getTenantId(), contentService.run(null)));
                } catch (Exception e) {
                    log.error("[contentJob][tenant({}) 失败]", c.getTenantId(), e);
                }
            }
        }
    }

}
