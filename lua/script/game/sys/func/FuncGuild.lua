FuncGuild= FuncGuild or {}

local groudLvData = nil
local groupRightData = nil


function FuncGuild.init(  )
	groudLvData = require("guild.GroupLv");
	groupRightData = require("guild.GroupRight");
end

function FuncGuild.getGroudLvData(id, key)
	local value = groudLvData[tostring(id)][tostring(key)];
    return numEncrypt:getNum(value);
end

function FuncGuild.getGroupRightData(id)
	local value = groupRightData[tostring(id)][tostring(key)];
    return numEncrypt:getNum(value);
end



