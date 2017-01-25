FuncChallenge= FuncChallenge or {}

local config_challenge = nil




function FuncChallenge.init()
	config_challenge = require("challenge.challenge")
end

function FuncChallenge.getDataByKey(itemId,key)
    local valueRow = config_challenge[itemId]
	if valueRow == nil then 
		echo("error: FuncChallenge.getAchievementValueByKey id " ..  tostring(id) .. " is nil")
		return nil
	end 
	local value = valueRow[key]
	if value == nil then 
		echo("error: FuncChallenge.getAchievementValueByKey key " ..  tostring(key) .. " is nil")
	end 
	return value
end
--通过itemId获得开启的条件
function FuncChallenge.getOpenLevelByitemId(itemId)
	return FuncChallenge.getDataByKey(itemId,"condition")
end

--通过itemId获得daytime
function FuncChallenge.getDayTimeByitemId(itemId)
	return FuncChallenge.getDataByKey(itemId,"dayTimes")
end

--通过itemId获得icon
function FuncChallenge.getIconByitemId(itemId)
	return FuncChallenge.getDataByKey(itemId,"icon")
end


