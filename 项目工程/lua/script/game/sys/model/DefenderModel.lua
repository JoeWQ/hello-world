local DefenderModel = class("DefenderModel", BaseModel)   -----处理服务器的数据

function DefenderModel:init(data)

	-- DefenderModel.super.init(self, data)

	-- self:createKeyFunc()
	-- self.sortedAchievementArrConfig = {}
 --    EventControler:addEventListener(InitEvent.INITEVENT_FUNC_INIT, self.onFuncInit, self)  
end

-- 最大重置次数 
function DefenderModel:getDefenderResetMaxCount()
    local vipLevel = UserModel:vip();    ---获得vip等级
    local extra = FuncCommon.getVipPropByKey(vipLevel, "defenderresettimes") or 0;
    return FuncDefender.MAX_RESET_COUNT + extra

end
-- 剩余重置次数
function DefenderModel:getDefenderResetLeftCount()
	local max = self:getDefenderResetMaxCount()
	local alreadyResetCount = CountModel:getDefenderCountTime()  ---TODO
	local left = max - alreadyResetCount
	return left
end
function DefenderModel:getDefenderVIPWhetherAgainAward()
	local vipLevel = UserModel:vip();
	local AgainAwardVIP = FuncDefender:getAgainAwardNeedVIP()
	if vipLevel > AgainAwardVIP then
		return true
	else
		return false
	end
end
function DefenderModel:getDefenderJadeWhetherAgainAward()
	local Sumgold = UserModel:getGold()
	local costGold = FuncDefender.MAX_GOLDCOST_COUNT
	if Sumgold >= costGold then
		return true
	else
		return false
	end
end
function DefenderModel:getChallengStagnumber()
	local stagenumber = 5 ---TODO ---获取服务器的挑战第几波
  	return stagenumber
end
function DefenderModel:judgeIsChallenger()   ---判断是否能挑战
	return 1
end
function DefenderModel:judgeGetaward()        --判断是否能领取奖励
	return 0
end
function DefenderModel:judgeAgainGetAward()   --判断是否能再次领取奖励
	return 0
end

return DefenderModel
