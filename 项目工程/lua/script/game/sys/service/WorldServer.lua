--
-- Author: ZhangYanguang
-- Date: 2016-02-22
--
--六界系统，网络服务类

local WorldServer = class("WorldServer")

function WorldServer:init()
	-- 监听战斗事件
    -- 战斗系统关闭
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,self.onBattleClose,self)

    -- PVE 战斗结束
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT,self.onPVEBattleComplete,self)

    -- PVE 战斗离开
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_USER_LEAVE,self.onPVEBattleLeave,self)

    -- PVE 战斗胜利
    EventControler:addEventListener(WorldEvent.WORLDEVENT_PVE_BATTLE_WIN, self.onPVEBattleWin, self)
end

function WorldServer:onPVEBattleWin(battleResult)
    local pveBattleCache = WorldModel:getPVEBattleCache()
    if pveBattleCache then
        pveBattleCache.battleRt = Fight.result_win
    end
end

-- PVE战斗离开
function WorldServer:onPVEBattleLeave(data)
    echo("onPVEBattleLeave")
    local battleResult = data.params
    self:reportPVEBattleResult(battleResult)
end

-- PVE战斗结束回调
function WorldServer:onPVEBattleComplete(data)
    echo("WorldServer:onPVEBattleComplete")
    local battleResult = data.params
    self:reportPVEBattleResult(battleResult)
end

-- 上报PVE战斗结果
function WorldServer:reportPVEBattleResult(battleResult)
    local cachePVeBattlInfo = WorldModel:getCurPVEBattleInfo()
    if cachePVeBattlInfo == nil then
        return
    end

    if BattleControler:getBattleLabel() == GameVars.battleLabels.worldPve then
        local battleId = cachePVeBattlInfo.battleId

        local battleParams = {}
        battleParams.battleId = tostring(battleId)
        battleParams.frame = battleResult.frame
        battleParams.fragment = battleResult.fragment
        battleParams.operation = battleResult.operation
        battleParams.rt = battleResult.rt
        battleParams.star = battleResult.battleStar
        
        -- 缓存数据
        cachePVeBattlInfo.battleStar = battleParams.star
        cachePVeBattlInfo.battleRt = battleResult.rt
        cachePVeBattlInfo.resultInfo = battleResult.resultInfo

        self:reportBattleResult(battleParams,c_func(self.onPVEReportBattlResultCallBack,self))
    end
end

-- 报告战斗结果回调
function WorldServer:onPVEReportBattlResultCallBack(event)
	echo("onPVEReportBattlResultCallBack ")
	self.extraBonus = nil
	self.battleResult = nil

    if event.result ~= nil then
        local serverData = event.result

        -- 获取战斗开始前缓存的信息
        local cacheBattleInfo = WorldModel:getCurPVEBattleInfo()

        -- 额外奖励
        self.extraBonus = serverData.data.extraBonus

        -- 显示奖品列表界面
        local rewardData = {}
        rewardData.reward = serverData.data.reward
        rewardData.inBattleDrop = serverData.data.inBattleDrop
        rewardData.result = cacheBattleInfo.battleRt
        rewardData.star = cacheBattleInfo.battleStar

        self.battleResult = rewardData.result

        -- zhangyg 服务器没有在该接口回传exp
        local cacheData = UserModel:getCacheUserData()
        -- 战斗胜利
        if tonumber(Fight.result_win) == tonumber(cacheBattleInfo.battleRt) then
            -- 战斗成功加经验值
            rewardData.addExp = cacheBattleInfo.spCost
            rewardData.heroAddExp = cacheBattleInfo.heroAddExp

            EventControler:dispatchEvent(WorldEvent.WORLDEVENT_PVE_BATTLE_WIN,{raidId=UserExtModel:getMainStageId()})
            EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = MainLineQuestModel.Type.RAID});
        else
            -- 战斗失败加经验值
            rewardData.addExp = 1
            rewardData.heroAddExp = 0
        end

        rewardData.preLv = cacheData.preLv
        rewardData.preExp = cacheData.preExp

        -- 展示结算界面
        BattleControler:showReward(rewardData)
    end
end

-- GVE&PVE战斗界面关闭
function WorldServer:onBattleClose(event)
    echo("WorldServer:onBattleClose,self.battleResult=",self.battleResult)
    if tostring(self.battleResult) ~= tostring(Fight.result_win) then
    	return
    end

    -- 获取战斗开始前缓存的信息
    local cacheBattleInfo = WorldModel:getCurPVEBattleInfo()
    -- echo("cacheBattleInfo==",cacheBattleInfo)

    -- PVE 战斗
    if cacheBattleInfo ~= nil then
        EventControler:dispatchEvent(WorldEvent.WORLDEVENT_CLOSE_PVE_BATTLE)
		-- 重置缓存
    	WorldModel:setCurPVEBattleInfo(nil)
    end
end

-- ===================================================================================
-- 进入主线副本
-- stageId，节点ID
function WorldServer:enterMainStage(stageId,callBack)
	local params = {
		stageId = stageId,
	}
	Server:sendRequest(params,MethodCode.pve_enterMainStage_1201 , callBack )
end

-- 汇报战斗结果
-- battleParams结构
--[[
	battleId
	frame
	fragment
	operation
	rt
	star
]]
function WorldServer:reportBattleResult(battleParams,callBack)
	local params = {
		battleParams = battleParams
	}

	Server:sendRequest(params,MethodCode.pve_reportBattleResult_1203 , callBack)
end

-- 领取星评级宝箱
function WorldServer:openStarBox(storyId,boxIndex,callBack)
	local params = {
		chapterId = storyId,
		id = boxIndex
	}

	Server:sendRequest(params,MethodCode.pve_openStarBox_1209 , callBack)
end

-- 进入精英副本
-- eliteId，节点ID
function WorldServer:enterEliteStage(eliteId,callBack)
	local params = {
		eliteId = eliteId,
	}
	Server:sendRequest(params,MethodCode.pve_enterEliteStage_1205 , callBack ,nil,nil,true)
end


-- 打开额外宝箱
function WorldServer:openExtraBox(raidId,callBack)
    local params = {
        stageId = raidId
    }
    Server:sendRequest(params,MethodCode.pve_openExtraBox_1211, callBack)
end


-- PVE扫荡
function WorldServer:sweep(raidId,times,callBack)
    local params = {
        stageId = raidId,
        times = times
    }

    dump(params)
    Server:sendRequest(params,MethodCode.pve_sweep_1213, callBack)
end

WorldServer:init();

return WorldServer
