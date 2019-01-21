
FuncSign = FuncSign or {}

local totalSingConfig = nil;
local totalSingConfigKeys = {};

function FuncSign.init(  )
	totalSingConfig = require("sign.TotalSign");
	local func = function (a, b)
		return a < b;
	end
	for k, v in pairs(totalSingConfig) do
		table.insert(totalSingConfigKeys, tonumber(k));
	end
	table.sort(totalSingConfigKeys, func);
end

--累计签到奖励
function FuncSign.getTotalSign(id, key)
	local value = totalSingConfig[tostring(id)][tostring(key)];

	if value == nil then 
		echo("getTotalSign " .. tostring(key) .. " is empty!");
		return;
	end 
	return value;
end

function FuncSign.getMonthTable(year, month)
	local year, month = SignModel:getYearAndMonth()

	local monthTable = require("sign.Sign" .. tostring(year) ..
		(month < 10 and  "0" .. tostring(month) or tostring(month)));
	return monthTable;
end

function FuncSign.getMonthValue(year, month, id, key)
	local monthTable = FuncSign.getMonthTable(year, month);
	if monthTable == nil or monthTable[tostring(id)][tostring(key)] == nil then 
		--echo("getMonthValue " .. tostring(year) .. tostring(month) ..
		--	tostring(id) ..tostring(key) .. " empty!");
		return ;
	end 
	return monthTable[tostring(id)][tostring(key)];
end

function FuncSign.getNextDay(day)
	local isFind = false;
	local maxDayVal = 0
	for k, v in pairs(totalSingConfigKeys) do
		if isFind == true or day == 0 then 
			return tonumber(v);
		end 
		if tonumber(day) == tonumber(v) then 
			isFind = true;
		end
		maxDayVal = v 
	end
	return maxDayVal;
end

--获取真是的下一个天数
function  FuncSign.getNextRealDay( day )
	local targetDay = FuncSign.getNextDay(day)
	if day>=targetDay then
		while day>=targetDay do
			targetDay = targetDay+10
		end
	end
	return targetDay
end







