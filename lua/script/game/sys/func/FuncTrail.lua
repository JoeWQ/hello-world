
FuncTrail = FuncTrail or {}

local trial = nil;
local trialResources = nil;

function FuncTrail.init()
	trial = require("trial.Trial");
	trialResources = require("trial.TrialResources");
end

function FuncTrail.getTrailData(id, key)
	local value = trial[tostring(id)][tostring(key)];
	if value == nil then
		echo("getTrailData id " .. tostring(id) .. 
			" " .. tostring(key) .. "is nil"); 
		return nil;
	else 
		return value;
	end 
end

function FuncTrail.getTrialResourcesData(id, key)
	local value = trialResources[tostring(id)][tostring(key)];

	if value == nil then
		echo("getTrialResourcesData id " .. tostring(id) .. " " .. tostring(key) .. "is nil"); 
		return nil;
	else 
		return value;
	end 
end


function FuncTrail.getTotalTimes(id)
	return FuncTrail.getTrailData(id, "totalTimes")
end















