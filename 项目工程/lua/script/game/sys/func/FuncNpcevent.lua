--guan 
--2016.4.20

FuncNpcevent = FuncNpcevent or {}

local npcEvent = nil;

function FuncNpcevent.init()
	npcEvent = require("home.NPCevent");
end

function FuncNpcevent.getValue(id, key)
	local valueRow = npcEvent[tostring(id)];
	if valueRow == nil then 
		echo("error: FuncNpcevent.getValue id " .. 
			tostring(id) .. " is nil;");
		return nil;
	end 

	local value = valueRow[tostring(key)];
	if value == nil then 
		echo("error: FuncNpcevent.getValue key " .. 
			tostring(key) .. " is nil");
	end 
    return value;
end

function FuncNpcevent.getNormalStoryId(id)
	return FuncNpcevent.getValue(id, "normalstoryid");
end

function FuncNpcevent.getLuckyStoryId(id)
	return FuncNpcevent.getValue(id, "luckystoryid");	
end

function FuncNpcevent.getNormalReward(id)
	return FuncNpcevent.getValue(id, "normalreward");		
end

function FuncNpcevent.getLuckyReward(id)
	return FuncNpcevent.getValue(id, "luckyreward");		
end

function FuncNpcevent.getSpineName(id)
	local npcId = FuncNpcevent.getValue(id, "npcid");	
	local spineResName = FuncCommon.getNpcSpineBody(npcId);
	return spineResName;
end


