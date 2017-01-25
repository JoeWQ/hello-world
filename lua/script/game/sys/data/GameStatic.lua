--存储服务器返回来的一些设置
--
local data = {
	--some local key settings
	debugMode = false, 
	displayErrorBoard = false, --如果错误码没有对应的translate，是否弹出error_code
	kakuraHeartBeatSecend = 20, 
	battleReportVersion = 1, 	--战斗版本号 
	onLineUserHeart = 300 ,		--获取在线用户的心跳间隔 以帧为单位
}

local GameStatic = table.deepCopy(data)
GameStatic._local_data = data

function GameStatic:mergeServerData(serverStaticData)
	table.deepMerge(self, serverStaticData)
end

function GameStatic:cleanStaticDataCache()
	for k,v in pairs(self) do
		if k ~= "_local_data" and type(v) ~= "function" then
			self[k] = nil
		end
	end
end

function GameStatic:restoreOriginData()
	self:cleanStaticDataCache()
	table.deepMerge(self, data)
end

return GameStatic
