--[[
	guan
]]

FuncHome = FuncHome or {}

local homeBtn = nil

function FuncHome.init()
	homeBtn = require("home.HomeUpBtns");
end

function FuncHome.getValue(id, key)
	local valueRow = homeBtn[tostring(id)];
	if valueRow == nil then 
		echo("error: FuncHome.getValue id " .. 
			tostring(id) .. " is nil;");
		return nil;
	end 

	local value = valueRow[tostring(key)];
	if value == nil then 
		echo("error: FuncHome.getValue key " .. 
			tostring(key) .. " is nil");
	end 
    return value;
end

function FuncHome.getFuncId(id)
	return FuncHome.getValue(id, "funcId");
end

function FuncHome.getIconSp(id)
	local iconName = FuncHome.getValue(id, "icon");
    local iconPath = FuncRes.iconIconHome(iconName);
    local iconSp = display.newSprite(iconPath);
    return iconSp;
end

function FuncHome.getDes(id)
	local tid = FuncHome.getValue(id, "des");
	return GameConfig.getLanguage(tid);
end













