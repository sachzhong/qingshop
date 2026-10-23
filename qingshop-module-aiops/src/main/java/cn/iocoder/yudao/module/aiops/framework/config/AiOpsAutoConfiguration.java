package cn.iocoder.yudao.module.aiops.framework.config;

import cn.iocoder.yudao.module.infra.api.file.FileApi;
import org.apache.ibatis.annotations.Mapper;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * AI 运营模块自动配置：被嵌入的服务（目前是 product-server）引入 jar 即生效
 */
@AutoConfiguration
@EnableConfigurationProperties(AiOpsProperties.class)
@ComponentScan("cn.iocoder.yudao.module.aiops")
@MapperScan(value = "cn.iocoder.yudao.module.aiops.dal.mysql", annotationClass = Mapper.class)
@EnableFeignClients(clients = FileApi.class)
@EnableScheduling
public class AiOpsAutoConfiguration {
}
