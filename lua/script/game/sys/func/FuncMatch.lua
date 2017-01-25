--
-- Author: xd
-- Date: 2016-03-21 20:26:06
--
FuncMatch = {}
local matchData 
local matchSystem 

FuncMatch.SYSTEM_TYPE = {
	worldGve1 = "1",   --主线副本
	worldGve2 =  "2", --主线精英
	kindGve = "0",		--行侠仗义
	trailGve1 = "301",	--山神试炼
	trailGve2 = "302",	--火神试炼
	trailGve3 = "303",	--雷神试炼
}



function FuncMatch.init(  )
	matchData = require("world.Match")
	matchSystem = require("world.MatchSystem")
end

--获取匹配数据
function FuncMatch.getMatchData( poolType )
	local data = matchData[poolType]
	if not data then
		echoError("没有找到 "..tostring(poolType).." 对应的匹配信息")
		return {}
	end
	return data
end


--根据poolType 获取 关卡id
function FuncMatch.getBattleLevelId( poolType )
	echo("poolType=======================",poolType,"======")
	local data = FuncMatch.getMatchData( poolType )

	local poolSystem = data.poolSystem
	--LogsControler:writeDumpToFile("FuncMatch:getBattleLevelId----------")
	--LogsControler:writeDumpToFile(data)
	local extId = data.extId
	local levelId
	--如果是精英
	if poolSystem== "1" then
		--levelId = FuncChapter.getRaidDataByRaidId(extId).level
		levelId = FuncElite.getEliteDataById(extId).level
		
	--试炼匹配
	elseif poolSystem== GameVars.poolSystem.trail1 or poolSystem== GameVars.poolSystem.trail2 or poolSystem== GameVars.poolSystem.trail3 then
		levelId = FuncTrail.getTrailData(extId,"level2")
	else
		
		echoError("错误的 战斗系统:",poolSystem)
	end

	return levelId

end


--获取poolSystem
function FuncMatch.getPoolSystem( poolType )
	local data = FuncMatch.getMatchData( poolType )
	return data.poolSystem
end

--根据poolType 获取 battleLabel
function FuncMatch.getBattleLabelByPoolType( poolType )
	local poolSystem = FuncMatch.getPoolSystem( poolType )
	return FuncMatch.getBattleLabelByPoolSystem( poolSystem )
end


function FuncMatch.getBattleLabelByPoolSystem( poolSystem )
	poolSystem = tostring(poolSystem)
	
	for k,v in pairs(FuncMatch.SYSTEM_TYPE ) do
		if v == poolSystem then
			return GameVars.battleLabels[k]
		end
	end
	echoError("错误的poolSystem:",poolSystem)

end


--根据poolSystem 获取loading
function FuncMatch.getLoadIdBySystem( poolSystem )
	return FuncMatch.readMatchSystem(poolSystem,"loading")
end


--读表
function FuncMatch.readMatchSystem(id, key)
	local data = matchSystem[tostring(id)];
	if data == nil then 
		echo("FuncMatch.readMatchSystem id " .. tostring(id) .. " is nil.");
		return nil;
	else 	
		local ret = data[key];
		if ret == nil then 
			echo("FuncMatch.readMatchSystem id " 
				.. tostring(id) .. " key " .. tostring(key) .. " is nil.");
			return nil;
		else 
			return ret;
		end 
	end 
end


