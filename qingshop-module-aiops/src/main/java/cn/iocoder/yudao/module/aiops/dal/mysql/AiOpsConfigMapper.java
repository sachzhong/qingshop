package cn.iocoder.yudao.module.aiops.dal.mysql;

import cn.iocoder.yudao.framework.mybatis.core.mapper.BaseMapperX;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsConfigDO;
import cn.iocoder.yudao.framework.tenant.core.aop.TenantIgnore;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface AiOpsConfigMapper extends BaseMapperX<AiOpsConfigDO> {

    /** 定时任务使用：跨租户查询启用了 AI 运营的配置 */
    @TenantIgnore
    @Select("SELECT * FROM aiops_config WHERE deleted = 0")
    List<AiOpsConfigDO> selectAllIgnoreTenant();

}
