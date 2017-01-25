--[[
	guan
	2016.4.26
]]

FuncGuide = FuncGuide or {}

local funcGuide = nil

function FuncGuide.init(  )
	funcGuide = require("guide.NoviceGuide");
end

function FuncGuide.getValueByKey(id1, id2, key)
	local t1 = funcGuide[tostring(id1)];
	if t1 == nil then 
		echo("FuncGuide.getValueByKey id1 not found " .. id1);
		return nil;
	end 

	local t2 = t1[tostring(id2)];
	if t2 == nil then 
		echo("FuncGuide.getValueByKey id2 not found " .. id2);
		return nil;
	end 

	local value = t2[tostring(key)]

	if value == nil then 
		-- echo("FuncGuide.getValueByKey key not found " .. key);
		return nil;
	end 

	return value;
end

function FuncGuide.getWinName(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "Currentinterface");
end

function FuncGuide.getToCenterId(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "toCenterId");
end

function FuncGuide.getLast(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "last");
end

function FuncGuide.getKeypoint(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "keypoint");
end


function FuncGuide.isGroundExist(groundId)
	local t1 = funcGuide[tostring(groundId)];

	if t1 == nil then 
		return false;
	end 
	return true;
end

function FuncGuide.getPlotId(groundId, step)
	local plotId = FuncGuide.getValueByKey(groundId, step, "plotid");
	return plotId;
end

function FuncGuide.getRect(groundId, step)
	local t = FuncGuide.getValueByKey(groundId, step, "Rect");
	return {tonumber(t[1]), tonumber(t[2])};
end

function FuncGuide.getClickPos(groundId, step)
	local t = FuncGuide.getValueByKey(groundId, step, "origin");
	return {tonumber(t[1]), tonumber(t[2])};
end

function FuncGuide.getAdaptation(groundId, step)
	local adaptation = FuncGuide.getValueByKey(groundId, step, "Adaptation");

	if adaptation == nil then 
		return 0, 0;
	else 
		local scaleX = 1;
		if adaptation[3] ~= nil then 
			scaleX = tonumber(adaptation[3]);
		end 
		local scaleY = 1;

		if adaptation[4] ~= nil then 
			scaleX = tonumber(adaptation[4]);
		end 
		return tonumber(adaptation[1]), tonumber(adaptation[2]), scaleX, scaleY;
	end 
end

function FuncGuide.getNpcskin(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "npcskin");
end

function FuncGuide.getTextcontentIndex(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "TextcontentIndex");
end

function FuncGuide.getNpcPos(groundId, step)
	local t = FuncGuide.getValueByKey(groundId, step, "npcorigin");
	if t ~= nil then  
		return {tonumber(t[1]), tonumber(t[2])};
	else 
		return nil;
	end 
end

function FuncGuide.getJump(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "Jump");
end

function FuncGuide.getArrowPicName(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "arrow");
end

function FuncGuide.getArrowDirection(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "directiondirection") or 0;
end

function FuncGuide.getMaskskin(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "Maskskin") or "0";
end

function FuncGuide.getTime(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "time");
end

function FuncGuide.getMode(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "mode");
end

function FuncGuide.getBubblePosition(groundId, step)
	return FuncGuide.getValueByKey(groundId, 
		step, "BubblePosition");
end

function FuncGuide.getBubbleStr(groundId, step)
	local tid = FuncGuide.getValueByKey(groundId, step, "BubblePromptn");
	return GameConfig.getLanguage(tid); 
end

function FuncGuide.getBubbleDirection(groundId, step)
	local dir = FuncGuide.getValueByKey(groundId, step, "BubbleDirection");
	return dir == nil and "1" or dir;
end

function FuncGuide.getCameraPosX(groundId, step)
	local posX = FuncGuide.getValueByKey(groundId, step, "cameraPosX");
	return posX;
end















