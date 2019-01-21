FuncTower= FuncTower or {}

local config_tower_achievement = nil
local config_tower_box_reward = nil
local config_tower = nil
local config_tower_option = nil

FuncTower.TOWER_SHOW_TYPES = {
	INIT = 1,
	HIGHER = 2,
}

FuncTower.KEYS = {
    COPPER = "4046",
    SILVER = "4047",
    GOLD = "4048",
}

--对应TowerOpitons 表中的type
FuncTower.BUFF_TYPE = {
	BUFF = 1, --属性改变
	REUSE_TREASURE = 2, --重用已用过的法宝
	TREASURE_POWER = 3, --法宝属性改变
}

FuncTower.KEY_TYPES = {
	"COPPER", "SILVER", "GOLD"
}

FuncTower.CD_CLEAR_COST_ID = "5"


FuncTower.MAX_RESET_COUNT = 1 --每日最大重置次数

function FuncTower.init()
	config_tower_achievement = require("tower.TowerAchievement")
	config_tower_box_reward = require("tower.TowerTreasureBoxReward")
	config_tower = require("tower.Tower")
	config_tower_option = require("tower.TowerOptions")
end

function FuncTower.getAchievementValueByKey(id, key)
	local valueRow = config_tower_achievement[tostring(id)]
	if valueRow == nil then 
		echo("error: FuncTower.getAchievementValueByKey id " ..  tostring(id) .. " is nil")
		return nil
	end 
	local value = valueRow[tostring(key)]
	if value == nil then 
		echo("error: FuncTower.getAchievementValueByKey key " ..  tostring(key) .. " is nil")
	end 
	return value
end

function FuncTower.getTowerAchievementConfig()
	return table.deepCopy(config_tower_achievement)
end 

function FuncTower.getFloor(id)
	return FuncTower.getAchievementValueByKey(id,"floor")
end

function FuncTower.getReward(id)
	return FuncTower.getAchievementValueByKey(id,"reward")
end

--获取buff数据 temp
function FuncTower.getBuffData(id)
	local info = config_tower_option[tostring(id)]
	local ret =  {
		info["type"],
		info["params1"],
		info["params2"] 
	}
	return ret
end 

function FuncTower.getTowerOptionText(id)  
	return config_tower_option[tostring(id)]["eventText"]
end 

function FuncTower.getTowerTreasureBoxRewardByKey(id,key)
	return config_tower_box_reward[tostring(id)][tostring(key)]
end 

function FuncTower.getTowerDataByKey(id , key)
	local config = config_tower[tostring(id)]
	if config == nil then
		echo("error getTowerDataByKey", id, key)
	end
	local data = config[tostring(key)]
	return data
end 

--cd花费暂时写死
function FuncTower.getClearCdCost(leftTime)
	local cost = FuncCommon.getCdCostById(tostring(FuncTower.CD_CLEAR_COST_ID), leftTime)
	return cost
end 

function FuncTower.getMaxTowerFloor()
	local len = table.length(config_tower)
	return len
end

function FuncTower.getTowerAllFloorData()
	return table.deepCopy(config_tower)
end
--扫荡每层塔需用的时间
function FuncTower.getSweepIntervalPerFloor()
    local needTime = FuncDataSetting.getDataByHid("SweepInterval").num
    return needTime
end
