FuncGod= FuncGod or {}

local config_god = nil
local config_godChar = nil
local config_godExp = nil
local config_godSkill = nil
local config_godGroove = nil
local config_godLevelUpCoin = nil
local config_godLevelUpGold = nil

function FuncGod.init()
	config_god = require("god.God")
    config_godChar = require("god.GodChar")
    config_godExp = require("god.GodExp")
    config_godSkill = require("god.GodSkill")
    config_godGroove = require("god.GodGroove")
    config_godLevelUpCoin = require("god.GodUpLevelCoin")
    config_godLevelUpGold = require("god.GodUpLevelGold")
	
end
-- 神明UI信息
function FuncGod.getGodValueByKey(id, key)
	local valueRow = config_god[tostring(id)]
	FuncGod.getCommonValue(valueRow,key)
end

-- 神明经验 威能

function FuncGod.getGodExp()
    return config_godExp
end
-- GodChar
function FuncGod.getGodChar()
    return config_godChar
end
function FuncGod.getGodCharValueByKey(id,key)
    local valueRow = config_godChar[tostring(id)]
	FuncGod.getCommonValue(valueRow,key)
end
-- GodGroove
function FuncGod.getGodGroove()
    return config_godGroove
end
function FuncGod.getGodGrooveValueByKey(id,key)
    local valueRow = config_godGroove[tostring(id)]
	FuncGod.getCommonValue(valueRow,key)
end
-- 铜钱强化
function FuncGod.getGodLevelUpCoinValueByKey(id,key)
    for i,v in pairs(config_godLevelUpCoin) do
        if v.id == tonumber(id) then
            return v[key]
        end
    end
    return nil
end
-- 仙玉强化
function FuncGod.getGodLevelUpGoldValueByKey(id,key)
    for i,v in pairs(config_godLevelUpGold) do
        if v.id == tostring(id) then
            return v[key]
        end
    end
    return nil
end
function FuncGod.getCommonValue(valueRow,key)
	if valueRow == nil then 
		echo("error: FuncGod.config_god id " ..  tostring(id) .. " is nil")
		return nil
	end 
	local value = valueRow[tostring(key)]
	if value == nil then 
		echo("error: FuncGod.config_god key " ..  tostring(key) .. " is nil")
	end 
	return value
end
function FuncGod.getGodData()
    return config_god
end
function FuncGod.getConfigGodData()
    local allData = {}
    for i,v in pairs(config_god) do
        table.insert(allData,v)
    end
    function sortFunc(a, b)
		return tonumber(a.fla) < tonumber(b.fla);
	end
	table.sort(allData, sortFunc);
	return allData
end


