FuncSmelt = FuncSmelt or {}

local config_smelt_shop = nil
local config_smelt_reward = nil

--稀有度标签
FuncSmelt.RARITY_LABEL = {
	COMMON = 1,
	RARE = 2
}

function FuncSmelt.init()
	config_smelt_shop = require("smelt.SmeltShop")
	config_smelt_reward = require("smelt.SmeltReward")
end

function FuncSmelt.isSmeltOpen()
	local openLevel = FuncDataSetting.getDataByConstantName("SmeltLevel")
end

function FuncSmelt.getSmeltShopGoodsData()
	return config_smelt_shop
end

function FuncSmelt.getSmeltRewardsData()
	return config_smelt_reward
end

function FuncSmelt.getSmeltReward(id)
	return config_smelt_reward[id]
end

function FuncSmelt.getSmeltShopRefreshTime()
	local now = TimeControler:getServerTime()
	local config_h = 4
	local h = os.date("%H", now)
	local time = now
	if tonumber(h) > config_h then
		time = now + 86400
	end
	local time_info = os.date("*t", time)
	time_info.hour = config_h
	time_info.min = 0
	time_info.sec = 0
	local refresh_time = os.time(time_info)
	return refresh_time
end

function FuncSmelt.getShopRefreshSoulNum()
	return FuncDataSetting.getDataByConstantName("SmeltCost")
end
