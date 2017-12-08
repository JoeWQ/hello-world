--[[
	guan
	2016.5.5
	数据中心 发数据 接口
	todo ios Android 真机测试
]]

local ClientActionControler = class("ClientActionControler");

-- 游戏名称
local GAME_NAME = AppInformation:getGameName();

-- 行为日志收集WebCenterUrl
local WebCenterUrl = AppInformation:getActionLogServerURL();

--错误收集WebCenterUrl
local errorLogCenterUrl = AppInformation:getErrorLogServerURL();

local RequestMode = "POST";

--每生成一个文件，fileNameIndex+1
--每次进游戏，来发送之前没有发送成功的数据
local fileNameIndex = 1;
local dataCenterFilePreFix = "DataCenterSend";
local errorCenterFilePreFix = "errorCenterSend";

local cErrorPreFix = "cCrashData";

local dirInWritablePath = "DataCenterTemp";


-- 错误日志类型
ClientActionControler.LOG_ERROR_TYPE = {
	TYPE_C = "c",
	TYPE_LUA = "lua",
	TYPE_DOWNLOAD = "download",
	TYPE_OTHER = "other"
};

--新设备数据分析
ClientActionControler.NEW_DEVICE_ACTION = {

	LAUNCH_APP_SUCCESS = "launchApp_1", --启动游戏
	SHOW_LOGO_SUCCESS = "showLogo_2",   --读取logo完成
	SHOW_CG_SUCCESS = "ShowCG_3",        --显示cg完成 --没加，没cg
	CHECK_UPDATE_SUCCESS = "checkUpdate_4",  --检查内更新完成
	DO_UPDATE_SUCCESS = "doUpdate_5",   --执行内更新完成
	SHOW_LOGIN_OR_SIGN_VIEW = "showLoginOrSign_6",   --显示有sdk的登录界面
	SIGN_SUCCESS = "signSuccess_7", --注册成功
	--8是直接登陆游戏，没有通过注册进入游戏的玩家，如何判断~~
	-- SHOW_ENTERGAME_OR_CHANGE_SESSION_VIEW = "showEnterGame_view_9", --显示进入游戏界面
	CLICK_ENTERGAME = "clickEnterGame_10", --点击进入游戏
	LOAD_RES_SUCCESS = "loadResSuccess_11", --完成资源加载的设备

};

function ClientActionControler:ctor()

end

--新设备数据统计 
--详见/svn/Design/yuping/客户端-登录流程打点
--action 是 ClientActionControler.NEW_DEVICE_ACTION
function ClientActionControler:sendNewDeviceActionToWebCenter(action)
	--check 本地 sqlite 中是否有数据
	if LS:pub():get(action, "defaultValue") ~= "defaultValue" then
		LS:pub():set(action, action);

		local baseInfo = self:getBaseInfo();
		local infoToSend = table.copy(baseInfo);

		infoToSend["module"] = "action";
		infoToSend["action"] = tostring(action);

		self:sendDataToWebCenter(infoToSend);
	end 
end

--[[
	给数据中心发新手引导数据 action 是新手引导步骤
]]
function ClientActionControler:sendTutoralStepToWebCenter(action)
	local baseInfo = self:getBaseInfo();
	local infoToSend = table.copy(baseInfo);

	--登陆后在新手界面，不可能没有rid
	infoToSend["module"] = "roleaction";
	infoToSend["rid"] = UserModel:rid();

	infoToSend["action"] = tostring(action);

	self:sendDataToWebCenter(infoToSend);
end

--[[
	给数据中心发登录数据
]]
function ClientActionControler:sendLoginDataToWebCenter()
	local baseInfo = self:getBaseInfo();
	local infoToSend = table.copy(baseInfo);
	infoToSend["module"] = "login"
	infoToSend["rid"] = UserModel:rid()
	infoToSend["vip"] = UserModel:vip()

	self:sendDataToWebCenter(infoToSend);
end

--[[
	给数据中心发充值数据
	cash:充值金额
]]
function ClientActionControler:sendChargeDataToWebCenter(cash)
	local baseInfo = self:getBaseInfo();
	local infoToSend = table.copy(baseInfo);
	infoToSend["module"] = "cash"
	infoToSend["rid"] = UserModel:rid()
	infoToSend["cash"] = cash

	self:sendDataToWebCenter(infoToSend);
end

--[[
	给数据中心发VIP数据
	cash:充值金额
]]
function ClientActionControler:sendVIPDataToWebCenter(oldVIP,newVIP)
	local baseInfo = self:getBaseInfo();
	local infoToSend = table.copy(baseInfo);
	infoToSend["module"] = "vip"
	infoToSend["rid"] = UserModel:rid()
	infoToSend["old_vip"] = oldVIP
	infoToSend["vip"] = newVIP

	self:sendDataToWebCenter(infoToSend);
end

--[[
	给数据中心发错误日志数据
	errorType:ClientActionControler.LOG_ERROR_TYPE 中定义的类型
	functionName:出错函数名称
	errorStack:错误信息或错误堆栈信息
]]
function ClientActionControler:sendErrorLogToWebCenter(errorType,functionName,errorStack)
	--todo UserModel TimeControler 等等 还没有就报错 如何是好
	if UserModel == nil or TimeControler == nil or AppInformation == nil or LoginControler == nil then 
		return;
	end 


	local errorData = {
		module = "error",

		game = GAME_NAME,
		platform = AppInformation:getAppPlatform(),
		pid = AppInformation:getMostId(),
		
		uid = UserModel:uid(),
		version_base = AppInformation:getClientVersion(),
		version_current = AppInformation:getVersion(),
		sys_version = AppInformation:getOSPlatform() or "None",
		devices_id = AppInformation:getDeviceID(),
		log_time = TimeControler:getServerTime(),
		section_id = LoginControler:getServerId() or "None",

		error_code = errorType,
		function_name = functionName,
		error_stack = errorStack,
	}
    
    -- dump(errorData, "--error_stack--");

	self:sendDataToWebCenter(errorData, errorLogCenterUrl);
end

-- 发送Lua Error到服务器
function ClientActionControler:sendLuaErrorLog(...)
	local args = {...}
    local logMsg = ""
    local count = 1
    for k,v in pairs(args) do
        logMsg = logMsg .. " " .. tostring(v)
        count = count + 1
        if count > 10 then
        	break
        end
    end

    self:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_LUA,"",logMsg)
end

-------------------------霸气分割线-------------------------
--给数据中心发消息
--todo 可能需要callback
function ClientActionControler:sendDataToWebCenter(infoToSend, serverUrl)
	local url = serverUrl or WebCenterUrl;

	--写个文件
	self:ifSaveDirNotExistThenMkSaveDir();

	if url == WebCenterUrl then 
		-- echo("---serverUrl == WebCenterUrl----");
		--给数据中心的文件
		filePath = self:dataCenterfilePathGen();
	else 
		-- echo("---serverUrl ~= WebCenterUrl----");
		--给错误中心发的
		filePath = self:errorCenterfilePathGen();
	end 

	file = io.open(filePath, "w");
	local jsonStr = json.encode(infoToSend) .. "\n";

	file:write(jsonStr);
	file:close();

	self:justSendFile(filePath, url);

	fileNameIndex = fileNameIndex + 1;
end

function ClientActionControler:justSendFile(filePath, serverUrl)
	local datas = {
		fileFieldName = "filepath",
		filePath = filePath,
		contentType = "text/plain",
		headers = {"Expect:"}  --不要  100 continue
	};

	local url = serverUrl or WebCenterUrl;

	-- url = "127.0.0.1";
	-- url = "172.16.148.89";

	echo("---filePath---", filePath, url);

	network.uploadFile(c_func(self.onHttpCallBack, self, filePath), url, datas);
end

--抄袭 function WebHttpServer:onHttpCallBack(callBack, message)
function ClientActionControler:onHttpCallBack(filePath, message)
	-- echo("---ClientActionControler:onHttpCallBack----");
	local req = message.request;
	-- echo("message.name", message.name);

	--如果连接失败
	if message.name == "failed" then
		echo("----filePath error----", filePath);
		echo("---ClientActionControler http请求失败, 请检查网络---")
		return
	end

	if message.name == "progress" then
		----说明请求在路上---
		return
	end

	local state = req:getState()
	local statusCode = req:getResponseStatusCode()
	local resString = req:getResponseString()

	-- echo("state", state);
	-- echo("statusCode", statusCode);
	-- echo("\n--------resString----------",resString)

	if state == 5 then --超时
		echo("ClientActionControler http请求超时---")
		return
	end

	local responseData = req:getResponseData()

	if statusCode == 200 then 
		FS.removeFile(filePath);
		echo("----send file finish----", filePath);
		echo(" ----statusCode == 200---");
		return;
	else 
		echoWarn("ClientActionControler http请求错误, statusCode", statusCode)
		return;
	end
end

--生成文件放置路径
function ClientActionControler:dataCenterfilePathGen()
	-- local dir = "/Users/playcrab/Documents/";
	local fileName = dataCenterFilePreFix .. tostring(fileNameIndex) .. ".txt";
	local writablePath = self:getSaveDir();

	return writablePath .. fileName;
end

function ClientActionControler:errorCenterfilePathGen()
	-- local dir = "/Users/playcrab/Documents/";
	local fileName = errorCenterFilePreFix .. tostring(fileNameIndex) .. ".txt";
	local writablePath = self:getSaveDir();

	return writablePath .. fileName;
end


function ClientActionControler:getSaveDir()
	return device.writablePath .. dirInWritablePath .. "/";
end

--[[
	ret {
		device_id = 08478676-C198-45EC-B1DF-1F1605BBC40F,
		time = 1453780310,
		game = xianpro,
		platform = dev,
		section = s2,
		channel = baidu,

	}
]]
function ClientActionControler:getBaseInfo()
	local time = TimeControler:getServerTime();
	local deviceID = AppInformation:getDeviceID();

	local platform = AppInformation:getAppPlatform();
	local section = LoginControler:getServerId();
	local channel = AppInformation:getChannelName();

	return {device_id = deviceID, 
			time = time, 
			game = GAME_NAME,
			platform = platform,
			section = section,
			channel = channel};
end

--[[
	发送没有发送的数据给数据中心
	可能是之前发送失败或是出错大退了
]]
function ClientActionControler:sendStorageFileToDataCenter()
	local saveDirPath = self:getSaveDir();
	self:ifSaveDirNotExistThenMkSaveDir();
	local fileArray = FS.getFileList(saveDirPath);

	local fileSendToDataCenterArray = {};
	local fileSendToErrorCenterArray = {};
	local cErrorArray = {};

	for _, v in pairs(fileArray) do
		if string.isContainSubStr(v, dataCenterFilePreFix) == true then 
			table.insert(fileSendToDataCenterArray, v);
		end 

		if string.isContainSubStr(v, errorCenterFilePreFix) == true then 
			table.insert(fileSendToErrorCenterArray, v);
		end 

		if string.isContainSubStr(v, cErrorPreFix) == true then 
			table.insert(cErrorArray, v);
		end 
	end

	--发送
	for _, v in pairs(fileSendToDataCenterArray) do
		self:justSendFile(v, WebCenterUrl);
	end

	--发送
	for _, v in pairs(fileSendToErrorCenterArray) do
		self:justSendFile(v, errorLogCenterUrl);
	end

	--发送
	for _, v in pairs(cErrorArray) do
		self:sendCppCrashFile(v);
	end
end

function ClientActionControler:ifSaveDirNotExistThenMkSaveDir()
	--创建个给数据中心发消息的专门文件夹
	local saveDirPath = self:getSaveDir();
	-- echo("----saveDirPath:getSaveDir-----", saveDirPath);
	local isExist = FS.exists(saveDirPath)
	if isExist == nil or isExist == false then 
		FS.mkDir(saveDirPath);
	end 
end

function ClientActionControler:sendCppCrashFile(filePath)
	--local dir = "/Users/playcrab/Documents/";
	local errorFileStr = FS.readFileContent(filePath);

	FS.removeFile(filePath);

	self:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_C, 
		"", errorFileStr);

end

return ClientActionControler;











