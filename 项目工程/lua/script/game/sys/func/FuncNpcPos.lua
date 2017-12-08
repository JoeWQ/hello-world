--[[
	guan
	2016.7.8
]]

FuncNpcPos = FuncNpcPos or {}

local npcPos = nil

function FuncNpcPos.init()
	npcPos = require("home.NpcPos");
end

function FuncNpcPos.getValue(id, key)
	local valueRow = npcPos[tostring(id)];
	if valueRow == nil then 
		echo("error: FuncNpcPos.getValue id " .. 
			tostring(id) .. " is nil;");
		return nil;
	end 

	local value = valueRow[tostring(key)];
	if value == nil then 
		echo("error: FuncNpcPos.getValue key " .. 
			tostring(key) .. " is nil");
	end 
    return value;
end

function FuncNpcPos.getNpcId(id)
	return FuncNpcPos.getValue(id, "npcid");
end

function FuncNpcPos.getPicOnHead(id)
	return FuncNpcPos.getValue(id, "picOnHead");
end

function FuncNpcPos.getPos(id)
	return FuncNpcPos.getValue(id, "pos");
end

function FuncNpcPos.getDes(id)
	return FuncNpcPos.getValue(id, "des");
end

function FuncNpcPos.getFuncDes(id)
	return FuncNpcPos.getValue(id, "fucDes");
end












