FuncYongAnGamble = FuncYongAnGamble or {}

local config_gamble = nil
local config_gamble_bonus = nil
local config_gamble_reward = nil
local config_gamble_npc_talks = nil

FuncYongAnGamble.DICES_COUNT = 6

FuncYongAnGamble.ROLL_STATUS = {
	INIT = 0, 
	CHANGE = 1,
}

function FuncYongAnGamble.init()
	config_gamble = require("gamble.Gamble")
	config_gamble_bonus = require("gamble.GambleBonus")
	config_gamble_reward = require("gamble.GambleReward")
	config_gamble_npc_talks = require("gamble.NpcTalks")
end

function FuncYongAnGamble.getInitialGambleCount()
	return FuncDataSetting.getDataByConstantName("GambleTimes")
end

function FuncYongAnGamble.getChangeFateGoldCost()
	return FuncDataSetting.getDataByConstantName("GambleCost")
end

--每日免费改投次数
function FuncYongAnGamble.getDailyFreeChangeCount()
	return FuncDataSetting.getDataByConstantName("GambleChangeFreeTimes")
end

--每日付费改投次数
function FuncYongAnGamble.getDailyChargeChangeCount()
	return FuncCommon.getGambleChangeCount(UserModel:vip())
end

function FuncYongAnGamble.isHigherVipHasMoreGambleChangeCount()
	local currentVip = UserModel:vip()
	local maxVipLevel = FuncCommon.getMaxVipLevel()
	local currentCount = FuncYongAnGamble.getDailyChargeChangeCount()
	for i=currentVip, maxVipLevel do
		local count = FuncCommon.getGambleChangeCount(i)
		if count > currentCount then
			return true
		end
	end
	return false
end

--根据吉的个数，查找相应的奖励
function FuncYongAnGamble.getRewardsByStatus(statusArr)
	local luckCount = 0
	for _, v in pairs(statusArr) do
		if tonumber(v) == 6 then
			luckCount = luckCount + 1
		end
	end
	if luckCount > FuncYongAnGamble.DICES_COUNT then
		luckCount = 0
	end
	local rewards = config_gamble_reward[luckCount..""].reward
	return rewards
end

function FuncYongAnGamble.getBonusConfig(bonusId)
	return config_gamble_bonus[bonusId]
end

function FuncYongAnGamble.getBonusAddGambleCount(bonusId)
	local config = FuncYongAnGamble.getBonusConfig(bonusId.."")
	if not config then return 0 end
	return config.gambleTimes
end

function FuncYongAnGamble.getRandomNpcTalks(npcStatus)
	local status = npcStatus..''
	local random_pool = config_gamble_npc_talks[status].random_talks
	local index = RandomControl.getOneRandomInt(#random_pool+1, 1)
	return GameConfig.getLanguage(random_pool[index])
end

function FuncYongAnGamble.getPreBonusIdAddCount(bonusId)
	local preId = (tonumber(bonusId) - 1)..""
	local config = FuncYongAnGamble.getBonusConfig(preId)
	if not config then return 0 end
	return config.gambleTimes
end

