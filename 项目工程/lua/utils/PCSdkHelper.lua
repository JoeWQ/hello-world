--
-- Author: ZhangYanguang
-- Date: 2016-02-23
-- MostSdk 工具类

PCSdkHelper = {}

local PLANTFORM_ANDROID = "android"
local PLANTFORM_IOS = "ios"

-- Lua&Java通信工具类的名称
local javaPCCommHelperClsName = "com/utils/core/SDKUtils"
local ocPCCommHelperClsName = "SDKUtils"

-- MostSdk 状态码
MystiqueStatusCode = {
	MST_INIT_SUCCESS = 0,
	MST_INIT_FAIL = 1,
	MST_LOGIN_SUCCESS = 2,
	MST_LOGIN_FAIL = 3,
	MST_LOGIN_CANCEL = 4,
	MST_LOGOUT_SUCCESS = 5,
	MST_LOGOUT_FAIL = 6,
	MST_LOGOUT_CANCEL = 7,
	MST_CHARGE_SUCCESS = 8,
	MST_CHARGE_FAIL = 9,
	MST_CHARGE_CANCEL = 10,
	MST_CHARGE_FORBIDDEN = 11,
	MST_SWITCH_USER_SUCCESS = 12,
	MST_SWITCH_USER_FAIL = 13,
	MST_SHARE_SUCCESS = 14,
	MST_SHARE_FAIL = 15,
	MST_SHARE_CANCEL = 16,
}

-- ========================================================
-- MostSDK Java&Object-c 端回调Lua的全局函数
function G_SDKCallBackFromNative(jsonData)
	echo("G_SDKCallBackFromNative")
	-- dump(jsonData)

	local jsonParams
	local code = nil
	local actionData = nil

	if device.platform == PLANTFORM_ANDROID then
		jsonParams = jsonData
		actionData = json.decode(jsonParams)
		code = actionData.code

	elseif device.platform == PLANTFORM_IOS then
		if jsonData == nil then
			PCSdkHelper:registerLuaScriptHandler()
			return
		end
		
		code = jsonData.code
		jsonParams = jsonData.data
		actionData = json.decode(jsonParams)
	end

	if code == nil or code == "" then
		echo("G_SDKCallBackFromNative Error code is ",code)
		return
	else
		echo("G_SDKCallBackFromNative code is ",code)
	end 

	-- 初始化成功
	if code == MystiqueStatusCode.MST_INIT_SUCCESS then
		echo("MostSdk初始化成功，开始登录逻辑")
		-- 调用sdk的登录
		PCSdkHelper:login()
	-- 初始化失败
	elseif code == MystiqueStatusCode.MST_INIT_FAIL then
		-- Zhangyg
		-- 弹出相关提醒界面

	-- 登录成功，做选服等游戏内登录逻辑
	elseif code == MystiqueStatusCode.MST_LOGIN_SUCCESS then
		echo("登录成功，开始选服登录的相关逻辑")
		local token = actionData.ext
		LoginControler:setToken(token)
		WindowControler:showWindow("TestLoginView")

	-- 登录失败或取消
	elseif code == MystiqueStatusCode.MST_LOGIN_FAIL or code == MystiqueStatusCode.MST_LOGIN_CANCEL then
		-- 可与MST_LOGIN_CANCEL做相同处理

	-- 支付成功
	elseif code == MystiqueStatusCode.MST_CHARGE_SUCCESS then
		echo("支付成功")
		WindowControler:showTips("支付成功")
		--这里会回调支付成功的订单号，游戏根据自己需要处理后续逻辑
        --data返回示例 {"bill_id":"201507241000000313"}

	-- 支付失败
	elseif code == MystiqueStatusCode.MST_CHARGE_FAIL then
		echo("支付失败")
		--游戏可以忽略

	-- 支付取消
	elseif code == MystiqueStatusCode.MST_CHARGE_CANCEL then
		echo("支付取消")
		--游戏可以忽略

	-- 支付禁止
	elseif code == MystiqueStatusCode.MST_CHARGE_FORBIDDEN then

	-- 玩家切换账号成功
	elseif code == MystiqueStatusCode.MST_SWITCH_USER_SUCCESS then
		--这里可能出现两种情况,游戏方需要处理这两种情况
        --1.玩家还在登录页面，并未加载任何的游戏数据但是通过用户中心切换了账号。
        --2.玩家在游戏中切换账号

    -- 玩家切换账号失败
	elseif code == MystiqueStatusCode.MST_SWITCH_USER_FAIL then

	-- 分享成功
	elseif code == MystiqueStatusCode.MST_SHARE_SUCCESS then

	-- 分享失败
	elseif code == MystiqueStatusCode.MST_SHARE_FAIL then

	-- 分享取消
	elseif code == MystiqueStatusCode.MST_SHARE_CANCEL then

	end
end

--[[
 * 上报游戏数据
 * 玩家数据初始化成功后以及执行支付操作前需要向渠道上报游戏数据
 * 
 * role_id: 角色id
 * role_name:角色名称
 * sec: 分区标识
 * sec_name: 分区名称
 * vip: vip等级
 * level: 角色等级
 * balance: 货币余额
 * @param userInfoMap
]]
function PCSdkHelper:sendUserInfo()
	local functionName = "sendUserInfo"
	local userInfoParams = {}
	userInfoParams.role_id = UserModel:rid()
	-- Zhangyg 角色名称
	userInfoParams.role_name = UserModel:rid()
	userInfoParams.sec = LoginControler:getServerId()
	userInfoParams.sec_name = LoginControler:getServerName()
	userInfoParams.vip = UserModel:vip()
	userInfoParams.level = UserModel:level()
	userInfoParams.balance = UserModel:getGold()

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {userInfoParams}, "(Ljava/util/HashMap;)V");
	elseif device.platform == PLANTFORM_IOS then 
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,userInfoParams)
	else
		echoWarn(device.platform .. " no sendUserInfo function")
	end	
end

--[[
 * 支付接口 参数列表如下：
 * productId:商品Id
 * productName:商品名称
 * productNum:商品数量
 * productPrice:商品价格 单位分
 *==========================
 * chargeInfoParams的结构如下：
 * role_id: 角色id
 * sec: 分区标识
 * product_id: 商品id
 * product_name: 商品名称
 * product_num: 商品数量
 * product_price: 商品单价 单位分
 * ext: 透传字段，对应服务端支付通知的透传字段
 * 返回数据参考回调接口 
]]
function PCSdkHelper:charge(productId,productName,productNum,productPrice)
	local functionName = "charge"

	local chargeInfoParams = {}
	chargeInfoParams.product_id = productId
	chargeInfoParams.product_name = productName
	chargeInfoParams.product_num = productNum
	chargeInfoParams.product_price = productPrice

	chargeInfoParams.role_id = UserModel:rid()
	chargeInfoParams.sec = LoginControler:getServerId()
	chargeInfoParams.ext = LoginControler:getToken()

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {chargeInfoParams}, "(Ljava/util/HashMap;)V");
	elseif device.platform == PLANTFORM_IOS then 
		echo("IOS 支付")
		dump(chargeInfoParams)

		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,chargeInfoParams)
	end
end

-- 调用sdk登录功能，弹出渠道登录界面
function PCSdkHelper:login()
	local functionName = "login"

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {}, "()V");
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end
end

-- 调用sdk登出功能
function PCSdkHelper:logout()
	local functionName = "logout"

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {}, "()V");
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end
end

-- 打开论坛界面
function PCSdkHelper:openForum()
	local functionName = "openForum"

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {}, "()V");
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end
end

-- 切换账号
function PCSdkHelper:switchUser()
	local functionName = "switchUser"

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {}, "()V");
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end
end

--[[
 * 加载url
 * url:加载的url地址
 * type: 0-webview 全屏窗口 1-webview 半屏窗口 2-browser浏览器
]]
function PCSdkHelper:loadUrl(url,type)
	local functionName = "loadUrl"
	local urlInfo = {
		url = url,
		type = type
	}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {urlInfo}, "(Ljava/util/HashMap;)V");
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName ,urlInfo)
	end
end

--获取设备Id
function PCSdkHelper:getDeviceID()
	local functionName = "getDeviceID"

	local localStoragedDeviceId = LS:pub():get(StorageCode.device_id ,"")
	if localStoragedDeviceId ~= "" then
		return localStoragedDeviceId
	end

	local deviceId = nil
	local result = false
	if device.platform == PLANTFORM_ANDROID then
		result,deviceId = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {}, "()Ljava/lang/String;");
	elseif device.platform == PLANTFORM_IOS then
		result,deviceId = luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	else
		--windows and mac and else
		result = true
		deviceId = Tool:getDeviceId()
	end

	if not result then
		echoError(functionName .. " fail")
	else
		LS:pub():set(StorageCode.device_id, deviceId)
	end

	return deviceId
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
function PCSdkHelper:getDeviceInfo()
	local functionName = "getDeviceInfo"

	local deviceInfoObj = {}
	local deviceInfo = "{}"
	local result = false
	if device.platform == PLANTFORM_ANDROID then
		result,deviceInfo = luaj.callStaticMethod(javaPCCommHelperClsName, functionName,{},"()Ljava/lang/String;");
	elseif device.platform == PLANTFORM_IOS then
		result,deviceInfo = luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	else
		result = true
		deviceInfoObj.system_name = "pc"
	end

	if result then
		if deviceInfoObj.system_name ~= "pc" then 
			deviceInfoObj = json.decode(deviceInfo)
		end
	else
		echoWarn( functionName .. " fail")
	end

	return deviceInfoObj
end

--获取渠道信息
function PCSdkHelper:getChannelInfo()
	local functionName = "getChannelInfo"

	local channelInfoObj = {}
	local channelInfo = ""
	local result = false

	if device.platform == PLANTFORM_ANDROID then
		result,channelInfo = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {}, "()Ljava/lang/String;");
	elseif device.platform == PLANTFORM_IOS then
		result,channelInfo = luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end

	if result then
		channelInfoObj = json.decode(channelInfo)
		if channelInfoObj == nil then
			channelInfoObj = {}
		end
	else
		echoWarn( functionName .. " fail")
	end

	return channelInfoObj
end

-- =======================================
-- 为Object-c注册回调Lua的函数
function PCSdkHelper:registerLuaScriptHandler()
	local params = {
        callLuaHandler = G_SDKCallBackFromNative
    }

    luaoc.callStaticMethod("PCCommHelper", "regisgerLuaScriptHandler",params)
end

-- Object-c请求注册Lua回调函数
function G_RequestRegisgerLuaScriptHandler()
	PCSdkHelper:registerLuaScriptHandler()
end

if device.platform == PLANTFORM_IOS then
	PCSdkHelper:registerLuaScriptHandler()
end
-- =======================================

return PCSdkHelper
