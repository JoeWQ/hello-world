--
-- Author: ZhangYanguang
-- Date: 2015-12-18
-- PVP 数据类

local PVPModel = class("PVPModel",BaseModel)
function PVPModel:init(d)
	PVPModel.super.init(self, d)
	self.modelName = "pvp"
    local _default_pvp_rank =10001 --必须等于FuncPvp.DEFAULT_RANK
	self._datakeys = {
		pvpPeakRank = _default_pvp_rank, --历史最高排名
        exchangeIds = {}, --竞技场的排名兑换奖励
        scoreRewards = {},--已经领取过的积分奖励
        scoreRewardExpireTime = 0,--积分奖励的过期时间
	}
    local _server_time = TimeControler:getServerTime()
    if d.scoreRewardExpireTime and d.scoreRewardExpireTime < _server_time then
        self._data.scoreRewards = {}
    end
	self:createKeyFunc()
	self.fast_refresh_count = 0
	self.last_refresh_pvp_time = 0
	self:initData()

	EventControler:addEventListener(TimeEvent.TIMEEVENT_PVP_FAST_REFRESH_CD, self.onFastRefreshCdEnd, self)
	EventControler:addEventListener(BattleEvent.BATTLEEVENT_REPLAY_GAME, self.onPvpFightEnd, self)
	EventControler:addEventListener(BattleEvent.BATTLEEVENT_JJC_LOGIC_PRO, self.onPvpLogicResult, self)

	EventControler:addEventListener("notify_pvp_new_fight_resport_1116", self.onNewReport, self)


	EventControler:addEventListener(BattleEvent.BATTLEEVENT_REPLAY_GAME, self.onReplayEnd, self)
	EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE, self.onBattleClose, self)


	self.last_pvp_peak_rank = self:pvpPeakRank() or _default_pvp_rank
end
--积分奖励过期时间
function PVPModel:processScoreReward()

end
--返回所有的已经领取的排名兑换奖励
function PVPModel:getAllRankExchanges()
    return self:exchangeIds()
end
--返回所有的已经领取的积分奖励
function PVPModel:getAllScoreRewards()
    return self:scoreRewards()
end

function PVPModel:onNewReport(e)
    local data = e.params.params.data
    self.new_reports_ids = data
	self:checkNewReport()
end

function PVPModel:onFuncInit(event)
	local params = event.params
	local funcname = params.funcname
	if funcname == "FuncPvp" then
	end
end

--当战斗关闭
function PVPModel:onBattleClose(  )
	if BattleControler:getBattleLabel() == GameVars.battleLabels.pvp then
		self:clearReplayData()
	end
end

--重播结束
function PVPModel:onReplayEnd(e)

	if BattleControler:getBattleLabel() ~= GameVars.battleLabels.pvp then
		return
	end

	--目前正在播放的战报数据
	local data = self:getCurrentReplayBattleData()
	if not data then
		return
	end
	--local result = Fight.result_win
	--if self:isUserSuccess(data) then
	--    result = Fight.result_lose
	--end
	WindowControler:showBattleWindow("ArenaBattleReplayResult")
	echo("ArenaBattlePlayBackView:onReplayEnd--------------------------------------------------")
end

--清除当前缓存的数据
function PVPModel:clearCurrentFightReports()
	self.new_reports_ids = nil
end

-- 初始化数据
function PVPModel:initData()
	-- PVP系统，cd等级分割值
	self.PVP_CD_LEVEL = 50
	-- PVP系统CD的id，小于PVP_CD_LEVEL的CD为1，大于的为2
	self.PVP_CD_ID = {1,2} 
end

--逻辑结果出来了
function PVPModel:onPvpLogicResult(event)
	local battleInfo = self:getCurrentPvpBattleInfo()
	if not battleInfo then
		return
	end
	--echo("onPvpLogicResult==================================================")
	if self.battleResult == nil then
		local battleResult = event.params
		self.battleResult = battleResult
		self:setLastFightResult(battleResult.rt)
		local battleUsers = battleInfo.battleUsers
		local params = {
			result = battleResult.rt,
			pvpBattleId = battleInfo.battleId,
			battleInfo = { treasures = battleResult.usedTreasures },
			resultInfo = event.params.resultInfo
		}
		PVPServer:reportBattleResult(params, c_func(self.reportBattleResultOk, self, battleResult))
	end
end

function PVPModel:setLastFightResult(rt)
	self._last_fight_result = rt
end

function PVPModel:isLastFightWin()
	return self._last_fight_result == Fight.result_win
end

--展示战斗结果
function PVPModel:onPvpFightEnd(event)
	local battleInfo = self:getCurrentPvpBattleInfo()
	if not battleInfo then
		return
	end

	local r = self.server_check_pvp_fight_result
	dump(self.battleResult.reward,"_self.battleResult.reward")
	local battleResultData = {
		result = r,
		star = self.battleResult.battleStar,
		reward = self.battleResult.reward
	}

	local historyTopRank = self.battleResult._historyTopRank 
	--胜利
	if r == Fight.result_win then
		local pvpRankChangeInfo = {
			currentRank = self:getUserRank(),
			rankDelta = math.abs(self.userLastRank - self:getUserRank()), --排名变化
		}
--//有关历史排名的数据
        local   historyRank={
            historyRank=self.last_pvp_peak_rank,
            rankDelta=self.last_pvp_peak_rank-self:getUserRank(),
        };
		if historyTopRank then
			pvpRankChangeInfo.historyTopRank = historyTopRank
			pvpRankChangeInfo.historyTopRankDelta = math.abs(self:pvpPeakRank() - self.last_pvp_peak_rank)
		end
		battleResultData.pvpRankChangeInfo = pvpRankChangeInfo
        battleResultData.historyRank=historyRank;
	end

	if historyTopRank and not battleResultData.reward then
		local historyTopReward = FuncPvp.getHistoryTopRankReward(tonumber(historyTopRank))
		battleResultData.reward = historyTopReward
	end
	self.battleResult = nil
	self.currentBattleInfo = nil
	BattleControler:showReward(battleResultData)
end

--更新data数据
function PVPModel:updateData(data)
	for k,v in pairs(data) do
		if k == "pvpPeakRank" then
			self.last_pvp_peak_rank = self:pvpPeakRank()
		end
	end
    PVPModel.super.updateData(self, data)
    --积分兑换发生变化
    if data.exchangeIds ~=nil then
        EventControler:dispatchEvent(PvpEvent.RANK_EXCHANGE_CHANGED_EVENT,data.exchangeIds)
    end
    --积分奖励发生变化
    if data.scoreRewards ~= nil then
        EventControler:dispatchEvent(PvpEvent.SCORE_REWARD_CHANGED_EVENT,data.scoreRewards)
    end
    --积分奖励过期时间
    if data.scoreRewardExpireTime then
        EventControler:dispatchEvent(PvpEvent.SCORE_REWARD_EXPIRE_TIME_CHANGED_EVENT,data.scoreRewardExpireTime)
    end
end

function PVPModel:checkNewReport()
	local show = self:hasNewReport()
	-- EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, {redPointType=HomeModel.REDPOINT.NAVIGATION.ARENA, isShow = show})
	EventControler:dispatchEvent(PvpEvent.PVPEVENT_PVP_REPORT_RED_POINT, show)
	EventControler:dispatchEvent(WorldEvent.WORLDEVENT_PVP_RED_POINT_UPDATE , show)
end

function PVPModel:hasNewReport()
	return self.new_reports_ids ~= nil
end

function PVPModel:setUserRank(rank)
   if(rank and rank ~= self.userRank)then
	   self.userLastRank = self.userRank or FuncPvp.DEFAULT_RANK
	   self.userRank = rank
    end
end

function PVPModel:cacheRankList(data)
	self.rank_list = data
end

function PVPModel:getCacheRankList()
	return self.rank_list
end

--获得用户当前的排名
function PVPModel:getUserRank(rank)
	return self.userRank or FuncPvp.DEFAULT_RANK
end

function PVPModel:getHistoryTopRank()
	return self:pvpPeakRank() or FuncPvp.DEFAULT_RANK
end

function PVPModel:onFastRefreshCdEnd()
	self.fast_refresh_count = 0
end

function PVPModel:recordManulRefresh()
	local now = TimeControler:getServerTime()
	local delta = now - self.last_refresh_pvp_time
	if delta < FuncPvp.MIN_REFRESH_INTERVAL then
		self.fast_refresh_count = self.fast_refresh_count + 1
	end
	if self.fast_refresh_count >= 3 then
		return false
	end
	self.last_refresh_pvp_time = now
	return true
end

-- 获得下次购买消费
function PVPModel:getNextBuyCost()
	local buyCost = FuncPvp.getBuyPVPCost()
	return buyCost
end

function PVPModel:composeBattleInfoForReplay(battleData)
    local _attackInfo = json.decode(battleData.attackerInfo)
    local _defenderInfo = json.decode(battleData.defenderInfo)
    if _attackInfo.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
        _attackInfo = FuncPvp.getRobotDataById(_attackInfo._id)
    end
    if _defenderInfo.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
        _defenderInfo = FuncPvp.getRobotDataById(_defenderInfo._id)
    end
	--攻击在前
	local playerCamp = _attackInfo
	playerCamp.rank = battleData.attackerRank
	playerCamp.titleId = FuncPvp.getTitleByAbility(playerCamp.ability or 0)
	playerCamp.team = 1
	local enemyCamp = _defenderInfo
	enemyCamp.rank = battleData.defenderRank
	enemyCamp.titleId = FuncPvp.getTitleByAbility(enemyCamp.ability or 0)
	enemyCamp.team = 2
	if enemyCamp.userBattleType == Fight.people_type_robot then
		enemyCamp.name = GameConfig.getLanguage(enemyCamp.name)
		local t = {}
		local enemyTreasures = enemyCamp.treasures
		if #enemyTreasures ~= 0 then
			for _, info in pairs(enemyTreasures) do
				t[info.id] = info
			end
			enemyCamp.treasures = t
		end
	end

	local battleInfo = {
		battleUsers = {
			playerCamp,
			enemyCamp,
		},
		randomSeed = battleData.randomSeed,
		battleId = battleData.battleId,
		gameMode = Fight.gameMode_pvp,
		battleLabel = GameVars.battleLabels.pvp,
	}
	return battleInfo
end

function PVPModel:tryShowBuyPvpView()
	if CountModel:canBuyPVPSn() then
		local gold = UserModel:getGold()
		local buyCost = PVPModel:getNextBuyCost()
		if buyCost > gold then
			WindowControler:showTips(GameConfig.getLanguage("tid_common_1001"))
		else
			WindowControler:showWindow("ArenaBuyCountView")
		end
	else
        --现在购买次数限制已经解除了,只要有钱就可以购买
--		local maxVipLevel = FuncCommon.getMaxVipLevel()
--		if maxVipLevel >= UserModel:vip() then
--			--local maxBuyTimes = FuncPvp.getPVPMaxBuyTimes()
--			--WindowControler:showTips(GameConfig.getLanguageWithSwap("tid_common_1012", maxBuyTimes))
--			WindowControler:showTips(GameConfig.getLanguage("tid_common_1017")) --  今日已达购买次数上限
--		else
			WindowControler:showWindow("CompVipToChargeView", {tip=GameConfig.getLanguage("tid_pvp_1047"), title="购买次数"})
--		end

	end
end

function PVPModel:setCurrentPvpBattleInfo(info)
	self.currentBattleInfo = info
end

function PVPModel:getCurrentPvpBattleInfo()
	return self.currentBattleInfo
end

function PVPModel:setCurrentReplayBattleData(data)
	self.currentReplayData = data
end

function PVPModel:getCurrentReplayBattleData()
	return self.currentReplayData
end

function PVPModel:clearReplayData()
	self.currentReplayData = nil
end

function PVPModel:reportBattleResultOk(battleResult, serverData)
	EventControler:dispatchEvent(PvpEvent.PVPEVENT_REPORT_RESULT_OK, serverData)
	local data = serverData.result.data
	local result = data.result
	--历史最高排名
	if data.isPeakRank == 1 then
		self.battleResult._historyTopRank = data.userRank
	end
--//记录玩家的竞技场排名变化
    self:setUserRank(data.userRank);
	self.server_check_pvp_fight_result = result

	--test 这个事件应该由结果界面dispatch ,目前先放在这里
	--FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD )
end


-- 通过总战力获取最新获取的称号
function PVPModel:getLastTitleByAbility(ability)
	local tid = FuncPvp.getTitleByAbility(ability)
	return tid
end

function PVPModel:getLatestAchievedTitle()
	return self._data.title
end

function PVPModel:checkDisplayNewTitleId()
	local latestTitle = self:getLatestAchievedTitle() or 0
	local currentTitleId = FuncPvp.getTitleByAbility(UserModel:getAbility()) or 0
	if tonumber(currentTitleId) > tonumber(latestTitle) then
		PVPServer:recordTitle(tostring(currentTitleId), c_func(self.onRecordNewTitleOk, self))
	end
end

function PVPModel:onRecordNewTitleOk()
--	EventControler:dispatchEvent(PvpEvent.PVPEVENT_RECORD_NEW_TITLE_OK)
end


return PVPModel

