package cn.iocoder.yudao.module.aiops.dal.mysql;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.aiops.controller.admin.vo.AiOpsLogPageReqVO;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsContentLogDO;
import org.apache.ibatis.annotations.Mapper;

import java.time.LocalDateTime;

@Mapper
public interface AiOpsContentLogMapper extends BaseMapperX<AiOpsContentLogDO> {

    default PageResult<AiOpsContentLogDO> selectPage(AiOpsLogPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<AiOpsContentLogDO>()
                .eqIfPresent(AiOpsContentLogDO::getSpuId, reqVO.getSpuId())
                .eqIfPresent(AiOpsContentLogDO::getStatus, reqVO.getStatus())
                .eqIfPresent(AiOpsContentLogDO::getRunId, reqVO.getRunId())
                .orderByDesc(AiOpsContentLogDO::getId));
    }

    default boolean existsRecent(Long spuId, LocalDateTime since) {
        return selectCount(new LambdaQueryWrapperX<AiOpsContentLogDO>()
                .eq(AiOpsContentLogDO::getSpuId, spuId)
                .and(w -> w.eq(AiOpsContentLogDO::getStatus, 0)
                        .or(x -> x.ge(AiOpsContentLogDO::getApplyTime, since)))) > 0;
    }

}
