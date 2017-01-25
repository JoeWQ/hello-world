--服务器相关数据
local ServiceData = ServiceData or {}

-- VMS 配置
ServiceData.platformCfg = {
	-- dev平台
	dev = {
		platform = "dev",											--平台名称
		vms_url = "http://172.16.240.8:8100/index.php",				--VMS 地址
		upgrade_path = "ios_cn_0511"								--升级序列
	},

	-- sanbox平台
	sandbox = {
		platform = "sandbox",											
		vms_url = "http://vms.sandbox.xianpro.playcrab.com/index.php",
		upgrade_path = "ios_cn_0511"
	}
}

-- 切换服务器平台，修改该配置
ServiceData.curPlatform = "dev"


ServiceData.SIGN_SALT = "MaybeYouHaveGotThisSignWithWireSharkOrIDA" --"MaybeYouHaveGotThisSignWithWireSharkOrIDA"

ServiceData.MESSAGE_ERROR = "error" 			--网络错误
ServiceData.MESSAGE_RESPONSE = "response" 		--接收到消息
ServiceData.MESSAGE_CLOSE = "close" 			--网络关闭
ServiceData.MESSAGE_NOTIFY = "notify" 			--通知 		--目前应该用不上

ServiceData.overTimeSecond = 20 				--超时时间 

ServiceData.initMethdoCode = "init" 		--初始化code

ServiceData.nodeServerName = "game" 		--nodeserVerName

function ServiceData:getErrorMessage(id )
    local txtId = self.errorCode[id]
    return lang[txtId]
end

return ServiceData
