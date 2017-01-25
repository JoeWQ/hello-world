--
-- Author: xd
-- Date: 2015-11-19 17:37:08
--

local UserExtModel = class("UserExtModel",BaseModel)

UserExtModel.INIT_TYPES = {
	AVATAR_INITED = {key = "AVATAR_INITED", bit=1}, --是否设置过形象
	NAME_CHANGE = {key = "NAME_CHANGE", bit = 2}, --是否改过名字
}

function UserExtModel:ctor()
	
end

function UserExtModel:init(d)
	self.modelName = "userExt"
    UserExtModel.super.init(self,d)
    self:registerEvent()

    self._datakeys = {
        avatar = "",                    --玩家头像/形象
        holySpace = numEncrypt:ns0(),   --神器占用空间
        sp = numEncrypt:ns0(),          --体力值
        upSpTime = "",                  --上次体力更新时间

        stageId = "",                  --主线章节Id
        eliteId = "",                  --精英章节Id
        currentStage = 0,               --标记状态：当前正在进行的副本id，为0表示当前没有进行中的副本
        loginTime = 0,      
        logoutTime = 0,  
        upSpTime = 0,
        totalSignDays = 0,
        totalSignDaysReceive = 0,
        totalSoul = 0, --历史宝物精华数量
        hasInit = 0, --按二进制数看待，每一位代表不同的含义，见UserExtModel.INIT_TYPES
        -- PVE特等总星数量
        totalStageStar = 0,
        guide = 0,
        pulseNode = numEncrypt:ns0(), --灵脉修炼进度
        firstRechargeGift = 0, --是否领过首冲奖励
        buyVipGift = 0, --是否买过首冲礼包
        partnerSkill =0, --伙伴系统技能点
        upPartnerSkillTime =0,--伙伴技能点更新时间
    }

    self:createKeyFunc()

    -- 根据时间差更新体力
    self:updateSpByUpTime()
    --计算技能点上限
    self:setPartnerSkillPoint()
    --VIP监听
    EventControler:addEventListener(UserEvent.USEREVENT_VIP_CHANGE,self.setPartnerSkillPoint,self)
end

function UserExtModel:hasInited()
	return self:hasInitAvatar()
	--local hasInit = self._data.hasInit
	--return hasInit~=nil and hasInit > 0
end

function UserExtModel:hasInitAvatar()
	return self:checkInitByType(self.INIT_TYPES.AVATAR_INITED.key)
end

function UserExtModel:hasChangedName()
	return self:checkInitByType(self.INIT_TYPES.NAME_CHANGE.key)
end

--initType must in UserExtModel.INIT_TYPES
function UserExtModel:checkInitByType(initType)
	local info = self.INIT_TYPES[initType]
	if not info then
		return false
	end
	local bitNum = info.bit
	local hasInit = self:_getHasInitValue()
	local convertResult = bit.rshift(hasInit, bitNum - 1)
	if convertResult % 2 > 0 then
		return true
	else
		return false
	end
end

function UserExtModel:_getHasInitValue()
	return self._data.hasInit or 0
end

function UserExtModel:getRenameCost()
	local key = "PlayerModifyName"
	local cost = FuncDataSetting.getDataByConstantName(key)
	return tonumber(cost)
end

--是否改过名字
function UserExtModel:hasChangeNameBefore()
	return self:checkInitByType(self.INIT_TYPES.NAME_CHANGE.key)
end

function UserExtModel:getMainStageId()
    local raidId = self:stageId()
    if raidId == nil or raidId == "" or raidId == 0 then
        return 0
    end
    
    -- return "10404"
    return raidId
end

function UserExtModel:getEliteStageId()
    local raidId = self:eliteId()
    if raidId == nil or raidId == "" or raidId == 0 then
        return 0
    end
    
    return raidId
end

-- 注册事件监听
function UserExtModel:registerEvent()
    EventControler:addEventListener(TimeEvent.TIMEEVENT_ONSP, self.updateSpByTimeEvent, self)
end

--更新data数据
function UserExtModel:updateData(data)
    UserExtModel.super.updateData(self,data);

    -- PVE 从非特等打到特等或者第一次打就打了特等
    if data.totalStageStar ~= nil then
        EventControler:dispatchEvent(WorldEvent.WORLDEVENT_CHAPTER_STAGE_SCORE_UPDATE, {});
    end
    --体力的发生了变化
    if(data.sp ~=nil)then
        EventControler:dispatchEvent(UserEvent.USEREVENT_SP_CHANGE,data.sp)
    end
    --伙伴技能点发生了变化
    if data.partnerSkill then
        self:resetSkillPointTime()
        EventControler:dispatchEvent(PartnerEvent.PARTNER_SKILL_POINT_CHANGED,data.partnerSkill)
    end
    --伙伴技能点更新时间发生了变化
    if data.upPartnerSkillTime then
        EventControler:dispatchEvent(PartnerEvent.PARTNER_SKILL_POINT_UPDATE_TIME_CHANGED,data.upPartnerSkillTime)
    end
    --技能点发生变化
    if data.partnerSkill ~=nil then
        EventControler:dispatchEvent(PartnerEvent.PARTNER_SKILL_POINT_CHANGED,data.partnerSkill)
    end
    -- echo("UserExtModel 更新")
    EventControler:dispatchEvent(UserExtEvent.USEREXTEVENT_MODEL_UPDATE,data);

    WorldModel:sendRedStatusMsg()

end

-- 通过upSpTime更新体力
function UserExtModel:updateSpByUpTime()
    echo("根据上次体力更新时间，更新sp=",self:upSpTime())
    local maxSpLimit = UserModel:getMaxSpLimit()
    local curSp = self:sp()

    if curSp <  maxSpLimit then
        --体力恢复间隔(秒)
        local secondInterval = FuncDataSetting.getDataByConstantName("HomeSPRecoverSpeed")
        local upSpTime = self:upSpTime()

        -- 增加的sp
        local addSp = TimeControler:countIntervalTimes(secondInterval,upSpTime)
        local newSp = self:sp() + addSp
        if tonumber(newSp) >= tonumber(maxSpLimit) then
            newSp = maxSpLimit
        end
        self:setSp(newSp)
    end
end

-- 通过事件更新体力
function UserExtModel:updateSpByTimeEvent()
    if self._data ~= nil then
        local maxSpLimit = UserModel:getMaxSpLimit()

        local curSp = self:sp()
        local newSp = tonumber(curSp) + 1

        if tonumber(curSp) < tonumber(maxSpLimit) then
            -- newSp = maxSpLimit
            self:setSp(newSp)
        end

    end
end

-- 更新sp的值
function UserExtModel:setSp(newSp)
    local maxSpLimit = UserModel:getMaxSpLimit()

    if tonumber(newSp) <= tonumber(maxSpLimit) then
        self._data.sp = newSp
        EventControler:dispatchEvent(UserEvent.USEREVENT_SP_CHANGE);
    end

end

-- 获取灵穴修炼节点
function UserExtModel:getPulseNode( ) 
    local pulseNode = self:pulseNode()
    if pulseNode == nil then
        return 0
    end

    -- return 40
    return pulseNode
end
--伙伴技能点
function UserExtModel:getPartnerSkillPoint()
    return  self:partnerSkill()
end
--技能点更新
--VIP变化
--设置技能点变化
function UserExtModel:setPartnerSkillPoint()
    local _newVIP = UserModel:vip() 
    local _now_limit = FuncCommon.getVipPropByKey(_newVIP,"partnerSkillMax")
    local _time_interval = FuncCommon.getVipPropByKey(_newVIP,"partnerSkillInterval")
    local _last_update_time = self:upPartnerSkillTime()
    local _skill_point_inc = TimeControler:countIntervalTimes(_time_interval,_last_update_time)
    local _now_skill_point = self:partnerSkill()
    
    local _after_fix_skill_point = _now_skill_point + _skill_point_inc
    if  _after_fix_skill_point> _now_limit then
        _after_fix_skill_point = _now_limit
    end
    --上限
    self._data.partnerSkill = _after_fix_skill_point
--    TimeControler:registerCycleCall(TimeEvent.TIMEEVENT_PARTNER_SKILL_POINT_RESUME_EVENT,_time_interval)
    self:setSkillPointTimer(_time_interval)
    EventControler:addEventListener(TimeEvent.TIMEEVENT_PARTNER_SKILL_POINT_RESUME_EVENT,self.onPartnerSkillPointInc,self)
end
--重新设置技能点冷却时间
function UserExtModel:resetSkillPointTime()
    local _newVIP = UserModel:vip() 
    local _now_limit = FuncCommon.getVipPropByKey(_newVIP,"partnerSkillMax")
    local _now_skill_point = self:partnerSkill()
    --检测是否达到了最大值-1
    if _now_skill_point == _now_limit-1 then
        local _time_interval = FuncCommon.getVipPropByKey(_newVIP,"partnerSkillInterval")
        self:setSkillPointTimer(_time_interval)
    end
end
--技能点增加
function UserExtModel:onPartnerSkillPointInc()
    local _newVIP = UserModel:vip() 
    local _now_limit = FuncCommon.getVipPropByKey(_newVIP,"partnerSkillMax")
    local _time_interval = FuncCommon.getVipPropByKey(_newVIP,"partnerSkillInterval")
    local _now_skill_point = self:partnerSkill()
    
    local _after_fix_skill_point = _now_skill_point + 1
    local _old_skill_point = _now_skill_point
    if  _after_fix_skill_point>= _now_limit then
        _after_fix_skill_point = _now_limit
    end
    --上限
    self._data.partnerSkill = _after_fix_skill_point
    --派发事件
    if _old_skill_point ~= _after_fix_skill_point then
        EventControler:dispatchEvent(PartnerEvent.PARTNER_SKILL_POINT_CHANGED,_after_fix_skill_point)
    end
    self:setSkillPointTimer(_time_interval)
end
--获取恢复到下一个技能点所需要的时间
function UserExtModel:getSkillPointResumeTime()
    return TimeControler:getCdLeftime(TimeEvent.TIMEEVENT_PARTNER_SKILL_POINT_RESUME_EVENT)
end
--设定伙伴技能恢复计时器
function UserExtModel:setSkillPointTimer( left_time)
    TimeControler:startOneCd(TimeEvent.TIMEEVENT_PARTNER_SKILL_POINT_RESUME_EVENT,left_time)
end
return UserExtModel

