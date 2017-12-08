--
-- Author: ZhangYanguang
-- Date: 2017-01-04
--
--主角模块，网络服务类
local CharServer = class("CharServer")

-- 主角升品
function CharServer:qualityLevelUp(callBack)
	local params = {
	}

	Server:sendRequest(params,MethodCode.char_qualitry_levelup_349, callBack)
end

return CharServer
