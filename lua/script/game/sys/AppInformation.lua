--
-- Author: ZhangYanguang
-- Date: 2016-06-02
-- 获取App信息及与Native通信

ServiceData = require("game.sys.data.ServiceData")

AppInformation = AppInformation or {}

-- 各平台配置
AppInformation.platformCfg = ServiceData.platformCfg

-- Java通信工具类的名称
AppInformation.javaPCCommHelperClsName = "com/playcrab/xianpro/PCCommHelper"

-- ObjectC通信工具类名称
AppInformation.ocPCCommHelperClsName = "PCCommHelper"

-- Native通信ActionCode
AppInformation.actionCode = {
	ACTION_EXIT_GAME = 1,   --退出游戏
}

-- 当前平台，如果需要切换平台，修改该配置即可
AppInformation.curPlatform = ServiceData.curPlatform

function AppInformation:init()
	echo("\n\nAppInformation:init")
	if device.platform ~= "windows" then
		self.configMgr = kakura.Config:getInstance()
	end
end

-- 获取SDK相关账号ID
-- 接入SDK后需要设置该值
function AppInformation:getSDKAccountID()
	return "account_id"
end

-- 获取SDK相关账号名称
-- 接入SDK后需要设置该值
function AppInformation:getSDKAccountName()
	return "account_name"
end

-- 获取SDK相关Token
-- 接入SDK后需要设置该值
function AppInformation:getSDKToken()
	return "account_name"
end

-- 获取游戏名称
-- 注意：只能调用getGameCfgValue，不能调用getValue
-- 因为LS初始化会调用getGameName,而getValue又会调用LS，会引起循环调用，导致栈溢出
function AppInformation:getGameName()
	local gameName = self:getGameCfgValue("APP_GAME_NAME")
	return gameName or "xianpro"
end

-- 获取APP平台
-- 注意：只能调用getGameCfgValue，不能调用getValue
-- 因为LS初始化会调用getAppPlatform,而getValue又会调用LS，会引起循环调用，导致栈溢出
function AppInformation:getAppPlatform()
	local platform = self:getGameCfgValue("APP_PLATFORM")

	if platform == nil then
		platform = AppInformation.curPlatform
	end

	return platform
end

-- 获取客户端版本
function AppInformation:getClientVersion()
	local clientVersion = self:getValue("APP_BUILD_NATIVE_NUM")
	if clientVersion == nil then
		-- dev模式下没有clientVersion，用vesion代替
		clientVersion = self:getVersion()
	end
	
	return clientVersion
end

-- 获取客户端脚本版本
function AppInformation:getVersion()
	local scriptVersion = self:getValue("APP_BUILD_NUM")
	return scriptVersion or "1"
end

-- 更新脚本版本
function AppInformation:setVersion(version)
	if version == nil or version == "" then
		return
	end

	self:setValue("APP_BUILD_NUM", version)
end

-- 获取 global_server_url
function AppInformation:getGlobalServerURL()
	local globalServerURL = self:getValue("GLOBAL_SERVER_URL")
	return globalServerURL
end


-- 重置global_server_url
function AppInformation:setGlobalServerURL(globalServerURL)
	if globalServerURL == nil or globalServerURL == "" then
		return
	end

	self:setValue("GLOBAL_SERVER_URL", globalServerURL)
end

-- 获取VMS URL
function AppInformation:getVmsURL()
	local vmsURL = self:getValue("VMS_URL")
	if vmsURL == nil then
		vmsURL = AppInformation.platformCfg[AppInformation.curPlatform].vms_url
	end

	return vmsURL
end

-- 重置VMS URL
function AppInformation:setVmsURL(vmsURL)
	echo("AppInformation:setVmsURL vmsURL = ",vmsURL)
	if vmsURL == nil or vmsURL == "" then
		return
	end

	self:setValue("VMS_URL", vmsURL)
end

-- 获取升级序列
function AppInformation:getUpgradePath()
	local upgradePath = self:getValue("UPGRADE_PATH")

	if upgradePath == nil then
		upgradePath = AppInformation.platformCfg[AppInformation.curPlatform].upgrade_path
	end

	return upgradePath
end

-- 获取 app information
function AppInformation:getValue(key)
	
	local value = nil
	if self:isReleaseMode() then
		value = self:getGameCfgValue(key)
	else
		value = LS:pub():get(key,nil)
	end

	return value
end

-- 持久化保存app information数据
function AppInformation:setValue(key,value)
	if self:isReleaseMode() then
		self:setGameCfgValue(key,value)
	else
		LS:pub():set(key,value)
	end
end

-- 从game.conf配置文件中获取值（walleui正式包中才有该配置文件）
function AppInformation:getGameCfgValue(key)
	local value = nil
	if self.configMgr ~= nil then
		value = self.configMgr:getValue(tostring(key))
		if value == "" or value == nil then
			value = nil
		end
	end

	return value
end

-- 更新game.confg中的值
function AppInformation:setGameCfgValue(key,value)
	if self.configMgr ~= nil then
		self.configMgr:setValue(key, value)        				
		self.configMgr:save()
	end
end

-- 获取行为日志服务器地址
function AppInformation:getActionLogServerURL()
	local serverUrl = self:getValue("LOG_SERVER_URL")
	if serverUrl == nil or serverUrl == "" then
		serverUrl = "http://api.xianpro.client.playcrab.com/v1/upload/api/";
	end

	return serverUrl
end

-- 获取错误日志服务器地址
function AppInformation:getErrorLogServerURL()
	local serverUrl = "http://api.xianpro.lua.playcrab.com/v1/upload/api/";

	return serverUrl
end

-- 获取操作系统平台
function AppInformation:getOSPlatform()
	local devInfo = PCSdkHelper:getDeviceInfo()
	if devInfo then
		return devInfo.system_name
	else
		return "pc"
	end
end

-- 获取渠道名称
function AppInformation:getChannelName()
	return "cname"
end

-- 获取渠道ID
function AppInformation:getChannelID()
	return "cid"
end

-- 获取渠道信息
function AppInformation:getChannelInfo()
	return PCSdkHelper:getChannelInfo()
end

-- 获取设备ID
function AppInformation:getDeviceID()
	return PCSdkHelper:getDeviceID()
end

--获取设备信息
--[[[
result = {
	"broken"      = "0"
	"device_id"   = "AA9C3F9E-0D16-4F6F-BB89-DB04D234D1BE"
	"idfa"        = "AA9C3F9E-0D16-4F6F-BB89-DB04D234D1BE"
	"idfv"        = "534C19CA-7FFE-49E2-AB8C-05A64877E994"
	"mac"         = "02:00:00:00:00:00"
	"model"       = "iPhone7,2"
	"network"     = "WIFI"
	"os_version"  = "9.3.1"
	"room_size"   = "129856.000000"
	"system_name" = "iPhone OS"
}
---]]
function AppInformation:getDeviceInfo()
	return PCSdkHelper:getDeviceInfo()
end

-- MostSDK id
function AppInformation:getMostId()
	return "most_id"
end

-- client是否Releas版，walleui出的正式包为Release版本
function AppInformation:isReleaseMode()
	return cc.FileUtils:getInstance():isFileExist("game.conf")
end

-- Lua调用Natvie
-- actionCode:AppInformation.actionCode
-- params:调用参数，数据类型为table
function AppInformation:callNative(actionCode,params)
	echo("callNative actionCode=" .. actionCode)

	local functionName = "callNative"
	local callParams = params or {}
	callParams.action_code = actionCode

	if device.platform == "android" then
		luaj.callStaticMethod(AppInformation.javaPCCommHelperClsName, functionName, {callParams}, "(Ljava/util/HashMap;)V");
	elseif device.platform == "ios" then 
		dump(chargeInfoParams)

		luaoc.callStaticMethod(AppInformation.ocPCCommHelperClsName, functionName,callParams)
	else
		WindowControler:showTips("PC平台没有实现强制退出功能")
	end
end

AppInformation:init()

