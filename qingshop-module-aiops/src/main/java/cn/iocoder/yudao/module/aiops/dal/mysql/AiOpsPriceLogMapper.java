package cn.iocoder.yudao.module.aiops.dal.mysql;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.iocoder.yudao.module.aiops.controller.admin.vo.AiOpsLogPageReqVO;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsPriceLogDO;
import org.apache.ibatis.annotations.Mapper;

import java.time.LocalDateTime;

@Mapper
public interface AiOpsPriceLogMapper extends BaseMapperX<AiOpsPriceLogDO> {

    default PageResult<AiOpsPriceLogDO> selectPage(AiOpsLogPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<AiOpsPriceLogDO>()
                .eqIfPresent(AiOpsPriceLogDO::getSpuId, reqVO.getSpuId())
                .eqIfPresent(AiOpsPriceLogDO::getStatus, reqVO.getStatus())
                .eqIfPresent(AiOpsPriceLogDO::getRunId, reqVO.getRunId())
                .orderByDesc(AiOpsPriceLogDO::getId));
    }

    /** 冷却期内是否执行过调价（含之后被回滚的），或仍有待审批的建议 */
    default boolean existsRecent(Long skuId, LocalDateTime since) {
        return selectCount(new LambdaQueryWrapperX<AiOpsPriceLogDO>()
                .eq(AiOpsPriceLogDO::getSkuId, skuId)
                .and(w -> w.eq(AiOpsPriceLogDO::getStatus, 0)
                        .or(x -> x.ge(AiOpsPriceLogDO::getApplyTime, since)))) > 0;
    }

}
