--
-- Author: zq
-- Date: 2016-08-19 
--

FuncElite = FuncElite or {}

local config_Elite = nil



function FuncElite.init()
	config_Elite = require("elite.Elite")
	
end

function FuncElite.getConfigElite()
    return config_Elite
end
function FuncElite.getRaidDataByRaidId(id)
    return config_Elite[id]
end


function FuncElite.getEliteDataById(eliteId)
	local data = config_Elite[tostring(eliteId)]
	return data
end