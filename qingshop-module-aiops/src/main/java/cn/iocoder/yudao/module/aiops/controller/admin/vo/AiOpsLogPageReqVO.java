package cn.iocoder.yudao.module.aiops.controller.admin.vo;

import cn.iocoder.yudao.framework.common.pojo.PageParam;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class AiOpsLogPageReqVO extends PageParam {
    private Long spuId;
    private Integer status;
    private String runId;
}
