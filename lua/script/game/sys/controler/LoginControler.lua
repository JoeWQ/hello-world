--
-- Author: xd
-- Date: 2015-11-24 19:01:12
--
local LoginControler={
	_login_count = 0,
}

LoginControler._token =nil 
LoginControler._uname = nil
LoginControler.MAX_HISTORY_SERVERS = 10

LoginControler.SERVER_STATUS = {
	NORMAL = 1,
	MAINTAIN = 2, 
	CLOSE = 3,
}

LoginControler.LOGIN_TYPE = {
	ACCOUNT ="account",
	GUEST = "guest"
}

--服务器信息 
LoginControler._serverInfo = {
	id = "dev",
	name = "内网测试服1",
	link ="172.16.110.249:9091",
	status = 1

}
-- {
-- 		id = "dev",
-- 		name ="内网测试服1",
-- 		status = 1,
-- 		link ="172.16.110.249:9091" 
-- }

--如果有有账号信息，自动登录
function LoginControler:autoLogin()
	local username = LS:pub():get(StorageCode.username ,"")
    local password = LS:pub():get(StorageCode.userpassword ,"")
	self:doLogin(username, password)
end

function LoginControler:tryAutoLogin()
	local lastLoginType = LS:pub():get(StorageCode.last_login_type)
	if lastLoginType == LoginControler.LOGIN_TYPE.ACCOUNT then
		if LoginControler:getLocalAccountInfo() ~= nil then
			local last_server_id = LS:pub():get(StorageCode.login_last_server_id)
			if last_server_id ~= "" and last_server_id~=nil then 
				LoginControler:tryShowGonggao()
			end
			--如果有账号信息，自动登录
			WindowControler:showTips("账号自动登录")
			LoginControler:autoLogin()
		end
	elseif lastLoginType == LoginControler.LOGIN_TYPE.GUEST then
		if LoginControler:getLocalGuestInfo() ~= nil then
			WindowControler:showTips("游客账户，自动登录")
			LoginControler:guestLogin()
		else
			echoError("游客登录信息为空")
		end
	end
	
end

--登入入口 如果不传回调 表示快速登入  选服 等等
function LoginControler:doLogin(uname, upassword, isquick)
	self._currentLoginingType = LoginControler.LOGIN_TYPE.ACCOUNT
	self._uname = uname
	self:setHasGetUserInfo(false)
	local params = {passport=uname, password = upassword}
	local loginBack = c_func(self.doLoginBack, self, isquick or false)
	HttpServer:sendHttpRequest(params, MethodCode.user_login_205, 
		loginBack, nil, true, true)
end


--退出登入
function LoginControler:logout()
	self:destroyData()
	Server:handleClose()
	EventControler:dispatchEvent(LoginEvent.LOGINEVENT_LOG_OUT)
end

function LoginControler:destroyData()
	self._token = nil
	self._uname = nil
	self._cid = nil
	self._serverInfo = nil
	self._historyServers = nil
	self._roleHistoryServers = nil

	self:setHasGetUserInfo(false)

	self._lastBattleId = nil
	self._lastPoolType = nil
end

function LoginControler:clearModels()
	local skip_models = {"AudioModel"}
	for k,v in pairs(_G) do
		if string.find(k, "Model$") then
			if not table.find(skip_models, k) then
				_G[k] = nil
			end
		end
	end
	local model_path = "game.sys.model.init"
	package.loaded[model_path] = false
	require("game.sys.model.init")

	TimeControler:destroyData()
	WindowControler:clearGlobalDelay()
	--EventControler:clearAllEvent()
	--WindowControler:destroyData()
end

--注册
function LoginControler:doRegister( uname,upassword ,call)
	if not call then
		call = GameVars.emptyFunc
	end

	HttpServer:sendHttpRequest({  passport=uname,password = upassword   },MethodCode.user_register_207, call, nil, true, true)
end

function LoginControler:addLoginCount()
	self._login_count = self._login_count + 1
end

function LoginControler:getLoginCount()
	return self._login_count
end

--登入返回
function LoginControler:doLoginBack(quickLogin, result)

	if result.error then
		local tip = ServerErrorTipControler:checkShowTipByError(result.error)
		return
	end
	result = result.result

	--这个是干啥用的，为啥是全局的，先注释掉
	--time = os.clock()

	local data = result.data
	self._token = data.loginToken

	self:addLoginCount()

	if quickLogin then
		self:doSelectZone()  
	else
		self:doGetServerList()
	end
	self:setHasGetUserInfo(false)
	self:setLocalLoginType(self._currentLoginingType)
	EventControler:dispatchEvent(LoginEvent.LOGINEVENT_LOGIN_SUCCESS)
	
end 

--loginType : guest or account
function LoginControler:setLocalLoginType(loginType)
	LS:pub():set(StorageCode.login_type, loginType)
end

function LoginControler:setLastLoginType(loginType)
	LS:pub():set(StorageCode.last_login_type, loginType)
end

function LoginControler:getLastLoginType()
	return LS:pub():set(StorageCode.last_login_type, "")
end
function LoginControler:getLocalLoginType()
	return LS:pub():get(StorageCode.login_type, "")
end

function LoginControler:getServerStatusKey(info)
	--维护
	if tonumber(info.status) == self.SERVER_STATUS.MAINTAIN then
		return 3
	end
	if tonumber(info.status) == self.SERVER_STATUS.CLOSE then
		return 4
	end
	--新开
	if info.new_open then
		return 1
	end
	--火爆
	return 2
end

--var content = '[{"method":105,"params":{"passport":"hlxabcd","password":"1"},"id":"1"}]';
--var content = '[{"method":109,"params":{"loginToken":"c4ca4238a0b923820dcc509a6f75849b","sec":"dev"},"id":"1"}]';
--var content = '[{"method":201,"params":{"clientInfo":{"cid":"Y2BvXS1zMC8tNi8tNC4tN3hbZHE"}},"id":1}]';

--获取服务器列表
function LoginControler:doGetServerList()
	local params = {loginToken=self._token }
	HttpServer:sendHttpRequest(params, MethodCode.user_serverList_211,c_func(self.getServerListBack, self), nil, true, true)
end

--获取服务器列表返回
function LoginControler:getServerListBack(result)
	if result.error then
		--TODO 待处理比如token过期
		local tip = ServerErrorTipControler:checkShowTipByError(result.error)
		return
	end
	if result.result then
		self:setServerListData(result.result.data)
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_GET_SERVER_LIST_OK)
	end
end

function LoginControler:checkAbnormalStatus(serverInfo)
	--提示服务器维护或者关闭
	local info = serverInfo
	local status = tonumber(info.status)
	if status == LoginControler.SERVER_STATUS.CLOSE then
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1024"))
		return false
	end
	if status == LoginControler.SERVER_STATUS.MAINTAIN then
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1023"))
		return false
	end
	return true
end

--选区
function LoginControler:doSelectZone()
	local zoneId = self:getServerId()
	if not zoneId then
		echo("服务器id为空")
		return
	end

	if not self:checkAbnormalStatus(self:getServerInfo()) then
		return
	end
    --检查服务器的状态
    local _status = tonumber(self._serverInfo.status)
    if _status == LoginControler.SERVER_STATUS.CLOSE then--处于关闭状态
        WindowControler:showTips(GameConfig.getLanguage("login_server_is_close_1001"))
        return
    elseif _status == LoginControler.SERVER_STATUS.MAINTAIN then
        WindowControler:showTips(GameConfig.getLanguage("login_server_is_maintain_1002"))
        return
    end
	local link = self:getServerLink()
	local tempArr = string.split(link, ":")
	ServiceData.IP = tempArr[1]
	ServiceData.PORT =  tempArr[2]

	echo("更新后的ip:",tempArr[1])
	echo("更新后的端口:",tempArr[2])
    ServiceData.Sec=zoneId--//加上区号
	HttpServer:sendHttpRequest({loginToken=self._token,sec =zoneId}, MethodCode.user_selectZone_209  , c_func(self.doSelectZoneBack, self), nil, nil, true)
end

--选区回来
function LoginControler:doSelectZoneBack(result )
	
	--如果有错误了 return
	if result.error then
		echo("doSelectZoneBack error")
		return
	end
	result = result.result
	local data =result.data
	local cid = data.cid
	self._cid = cid
	self._lastServerInfo = self._serverInfo

	--选区完毕以后 就 获取用户信息 理论上 获取用户信息  这个接口 需要新开辟一个  websocket 现在因为测试 
	--所以 走同一个连接,以后 登入 是走另外一个接口
	--选区回来 开始请求用户信息的时候 重启一个server
	EventControler:dispatchEvent(LoginEvent.LOGINEVENT_SELECT_ZONE_BACK)
	Server:init()
end

--试玩登录
function LoginControler:guestLogin()
	local deviceId = AppInformation:getDeviceID()
	HttpServer:sendHttpRequest({deviceId=deviceId}, MethodCode.user_guest_login_217, c_func(self.onGuestLoginOk, self), nil, true, true)
end

function LoginControler:onGuestLoginOk(data)
	self._currentLoginingType = LoginControler.LOGIN_TYPE.GUEST
	self:doLoginBack(false, data)
end

function LoginControler:bindAccount(passport, password)
	local did = AppInformation:getDeviceID()
	local params = {
		deviceId = did,
		passport = passport, 
		password = password,
	}
	echo("账号绑定......")
	dump(params)

	HttpServer:sendHttpRequest(params, MethodCode.user_bind_account_219, c_func(self.onBindAccountCallBack, self), nil, true, true)
end

function LoginControler:onBindAccountCallBack(data)
	if data and data.result then
		LS:pub():set(StorageCode.device_id, "")
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_BIND_ACCOUNT_SUCCESS)
	else
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_BIND_ACCOUNT_FAIL,data)
	end
end

function LoginControler:doConnectBack(result )
	echo("========================================LoginControler:doConnectBack--------------------------------------------------")
	if result.result and result.result.data then
		local lastBattleId =  result.result.data.battleId
		self._lastBattleId = lastBattleId
		self._lastPoolType = result.result.data.poolType

		--如果有上一场没有完成的战斗  那么直接提示进入战斗 不用确认 进主场景后直接就是进入战斗了
		-- if BattleServer:getLastBattleId() then
		-- 	echo("掉线之前有上一场战斗,直接进入上一场战斗-")
		-- 	BattleServer:getBattleInfo( BattleServer:getLastBattleId()  )
		-- 	BattleServer:setLastBattleId(nil)
		-- end

	end
	if not self:hasGetUserInfo() then
		--请求用户信息
		self:doGetUserInfo()
	else --//否则是掉线后重新登录
        self:doGetUserDataAfterOffline();
--		if self._lastBattleId then
--			BattleControler:reConnectBattle(self._lastBattleId,self._lastPoolType)
--			self._lastBattleId = nil
--			self._lastPoolType = nil
--		end

	end

	
end


--获取用户信息
function LoginControler:doGetUserInfo()
	local tempFunc = function()
		Server:sendRequest({}, MethodCode.user_getUserInfo_301, c_func(self.doGetUserInfoBack, self))
	end
	WindowControler:globalDelayCall(tempFunc)
end

--//离线之后重新联网获取用户信息
function LoginControler:doGetUserDataAfterOffline()
	local tempFunc = function()
		Server:sendRequest({}, MethodCode.user_getUserInfo_301, c_func(self.onGetUserDataAfterReconnect, self))
	end
	WindowControler:globalDelayCall(tempFunc)
end

--获取用户信息返回
function LoginControler:doGetUserInfoBack( result )
	
	self._hasGetUserInfo = true

	--如果有错误了 return
	if result.error then
		return
	end
	result = result.result

	local data = result.data
	local userData = data.user

	self:initGameStaticData(data.configs)
	--初始化时间控制器
	TimeControler:init()


	--开始初始化userModel
	UserModel:init(userData)
	UserExtModel:init(userData.userExt or {})
	HomeModel:init();

    FriendModel:init(userData.userExt);
		
	ItemsModel:init(userData.items or {})

	TreasuresModel:init(userData.treasures or {})
	--注意顺序，cdmodel这个要尽量靠前
	CdModel:init(userData.cds or {})

	ShopModel:init(userData.shops or {})
	ActConditionModel:init(userData.actConditions or {})
	ActTaskModel:init(userData.actTasks or {})

	NoRandShopModel:init(userData.noRandShops or {})
	YongAnGambleModel:init(userData.gambleExt or {})
	-- LotteryModel:init(userData.lotteryExt or {})	--抽卡模块

	SmeltModel:init(userData.smelts or {})

	--如果没有商店信息 那么 需要重新请求商店数据
	ShopModel:tryGetShopInfo()
	
	CountModel:init(userData.counts or {} )
    ChatModel:init();
	PVPModel:init(userData.pvpExt or {})
	WorldModel:init({})
	MailModel:init({})		--邮件模块
	TrailModel:init({});
    
	TowerNewModel:init(userData.towerExt or {})--爬塔模块
	DailyQuestModel:init(userData.everydayQuest or {});  --每日任务
	MainLineQuestModel:init(userData.mainlineQuests or {});  --主线任务	

    userData.starLights=userData.starLights or {}
    StarlightModel:init(userData.starLights)
	SignModel:init(); -- 签到
    HappySignModel:init(UserModel:happySign() or {}); -- 欢乐签到
    EliteChanllengeModel:init(UserModel:romances())
    EliteModel:init(UserModel:romanceInteracts())  --

    -- 神明
    GodModel:init(userData.gods)
    GodFormulaModel:init(userData.formula)
    
    
    -- CharModel会调用NatalModel及TalentModel，必须在它们之后初始化
    CharModel:init({});  			--主角模块
    RechargeModel:init({});         --充值模块
    VipModel:init({});              --vip模块

    DefenderModel:init({});   -----TODO ---守护紫萱模块 
    NewLotteryModel:init(userData.lotteryExt or {},userData.lotteryCommonPools or {},userData.lotteryGoldPools or {}); ---三皇抽奖


    --所有model init 后执行
    UserModel:initPlayerPower();
    PartnerModel:init(userData.partners or {},userData.userExt.partnerSkill or 0)
    --这个必须放在Partner和Treasure初始化之后
    TeamFormationModel:init( userData.formations or {} )
	-- 调用MostSDK发送用户数据
	PCSdkHelper:sendUserInfo()

	--调试显示用户信息
	if DEBUG >0 then
		local scene = WindowControler:getCurrScene()
		scene:showUserInfo()
	end

	--登入完成后 初始化邮件
	MailServer:init()
	--登入完成以后请求下邮件
	MailServer:requestMail()
--请求一下好友系统事件
    FriendServer:init();
    FriendServer:requestFriendApply();--请求好友申请列表
    FriendServer:requestFriendSp();--请求好友的体力赠送情况

    ChatServer:init();

	EventControler:dispatchEvent(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE);

    LampServer:init()
	--然后 建立连接
	-- Server:sendRequest(  {cid = self._cid,nodeServer = "game"}   , MethodCode.user_state_315  , c_func(self.doConnectBack, self))

	--如果有上一场没有完成的战斗  那么直接提示进入战斗 不用确认 进主场景后直接就是进入战斗了
	local lastBattleId =  result.data.battleId
	self._lastBattleId = lastBattleId
	self._lastPoolType = result.data.poolType
    if lastBattleId then
			BattleControler:reConnectBattle(self._lastBattleId,self._lastPoolType)
			self._lastBattleId = nil
			self._lastPoolType = nil
	end
	ClientActionControler:sendLoginDataToWebCenter()
end

--掉线重连后重新获取的用户信息
function LoginControler:onGetUserDataAfterReconnect( result )
    	
	self._hasGetUserInfo = true

	--如果有错误了 return
	if result.error then
		return
	end
	result = result.result

	local data = result.data
	local userData = data.user

	self:initGameStaticData(data.configs)
	--初始化时间控制器
	TimeControler:init()

	--开始初始化userModel
--	UserModel:init(userData)
    UserModel:updateData(userData);
--	UserExtModel:init(userData.userExt or {})
    UserExtModel:updateData(userData.userExt or {});
--	HomeModel:init();

--    FriendModel:init(userData.userExt);
		
	ItemsModel:updateData(userData.items or {})

	TreasuresModel:init(userData.treasures or {})--//这个需要使用init函数
	--注意顺序，cdmodel这个要尽量靠前
	CdModel:updateData(userData.cds or {})

	ShopModel:init(userData.shops or {})
	ActConditionModel:init(userData.actConditions or {})
	ActTaskModel:init(userData.actTasks or {})

	NoRandShopModel:init(userData.noRandShops or {})
	YongAnGambleModel:updateData(userData.gambleExt or {})
	LotteryModel:init(userData.lotteryExt or {})	--抽卡模块

	SmeltModel:updateData(userData.smelts or {})

	--如果没有商店信息 那么 需要重新请求商店数据
--	ShopModel:tryGetShopInfo()
	
	CountModel:updateData(userData.counts or {} )
	
 --   ChatModel:init();
	PVPModel:updateData(userData.pvpExt or {})
--	WorldModel:init({})
--	MailModel:init({})		--邮件模块
--	TrailModel:init({});
    
	TowerNewModel:updateData(userData.towerExt or {})--爬塔模块
	DailyQuestModel:updateData(userData.everydayQuest or {});  --每日任务
	MainLineQuestModel:updateData(userData.mainlineQuests or {});  --主线任务	

    userData.starLights=userData.starLights or {}
    StarlightModel:updateData(userData.starLights)
--	SignModel:init(); -- 签到
    HappySignModel:updateData(UserModel:happySign() or {}); -- 欢乐签到
    EliteChanllengeModel:updateData(UserModel:romances())
    EliteModel:updateData(UserModel:romanceInteracts())  --

    -- 神明
    GodModel:updateData(userData.gods)
    GodFormulaModel:updateData(userData.formula)
    
--本命法宝,天赋
 --   userData.treasureNatal= userData.treasureNatal or {};
 --   userData.talents = userData.talents or {};
 --   NatalModel:updateData(userData.treasureNatal);
 --   TalentModel:updateData(userData.talents);
    -- CharModel会调用NatalModel及TalentModel，必须在它们之后初始化
    CharModel:init({});  			--主角模块

 --   RechargeModel:init({});         --充值模块
--    VipModel:init({});              --vip模块

 --   DefenderModel:init({});   -----TODO ---守护紫萱模块 

    --所有model init 后执行
    UserModel:initPlayerPower();
    PartnerModel:init(userData.partners or {},userData.userExt.partnerSkill or 0)
	-- 调用MostSDK发送用户数据
--	PCSdkHelper:sendUserInfo()

	--调试显示用户信息
--	if DEBUG >0 then
--		local scene = WindowControler:getCurrScene()
--		scene:showUserInfo()
--	end

	--登入完成后 初始化邮件
--	MailServer:init()
--登入完成以后请求下邮件
--	MailServer:requestMail()
--请求一下好友系统事件
--    FriendServer:init();
 --   FriendServer:requestFriendApply();--请求好友申请列表
 --   FriendServer:requestFriendSp();--请求好友的体力赠送情况
--    ChatServer:init();
 --   LampServer:init()
	--然后 建立连接
	-- Server:sendRequest(  {cid = self._cid,nodeServer = "game"}   , MethodCode.user_state_315  , c_func(self.doConnectBack, self))

end
function LoginControler:initGameStaticData(staticData)
	GameStatic:mergeServerData(staticData)
end

function LoginControler:isLogin()
	if self._cid then
		return true
	end
	return false
end


--获取token 是用来判断 是否登入的标志
function LoginControler:getToken()
	return self._token
end

-- 设置token
function LoginControler:setToken(token)
	self._token = token
	echo("self._token==",self._token)
end

--每个请求都有唯一的cid  
function LoginControler:getCid()
	return self._cid
end

function LoginControler:getUname()
	return self._uname or ""
end



--设置服务器列表
function LoginControler:setServerListData(data)
	local list = data.secList
	local latest_index = nil
	local server_open_t = 0
	for index, info in pairs(list) do
		if tonumber(info.openTime) >= server_open_t then
			latest_index = index
			server_open_t = tonumber(info.openTime)
		end
	end
	list[latest_index].new_open = true
	self._serverList = list

	local history = data.roleHistorys or {}
	local sortByLogoutTime = function(a, b)
		local at = tonumber(a.logoutTime) or 0
		local bt = tonumber(b.logoutTime) or 0
		return at > bt
	end
	local keys = table.sortedKeys(history, sortByLogoutTime)
	local ret = {}
	for i=1,self.MAX_HISTORY_SERVERS do
		local key = keys[i]
		if key and history[key] then
			table.insert(ret, history[key])
		end
	end
	self._historyServers = ret
	
	self._roleHistoryServers = data.roleHistorys
end

function LoginControler:getHistoryLoginServers(sorted)
	if sorted then
		return self._historyServers
	else
		return self._roleHistoryServers
	end
end

--获取服务器列表
function LoginControler:getServerList()
	return self._serverList
end

function LoginControler:removeServerListCache()
	self._serverList = nil
end

--设置当前的服务器信息
--[[
	id = "dev",
	"link" = "172.16.110.249:9091"
	"name" ="内网测试服",
	"status" ="状态"

]]
function LoginControler:setServerInfo(serverInfo )
	-- echo("\n\nsetServerInfo")
	-- dump(serverInfo)
	-- 保存新选择的服务器版本列表
	if serverInfo then
		VersionControler:saveServerInfo(serverInfo)
	end
	
	self._lastServerInfo = self._serverInfo
	self._serverInfo = serverInfo
	EventControler:dispatchEvent(LoginEvent.LOGINEVENT_CHANGEZONE)
end

function LoginControler:getLastServerInfo()
	return self._lastServerInfo
end

function LoginControler:getLastServerId()
	return self._lastServerInfo and self._lastServerInfo._id or nil
end

function LoginControler:getServerInfo()
	return self._serverInfo
end

-- 获取本服对应的游戏client版本号
function LoginControler:getServerVersionNum()
	return "17"
end

--获取服务器的id
function LoginControler:getServerId()
	return self._serverInfo and self._serverInfo._id or nil
end

function LoginControler:getServerMark()
	return self._serverInfo and self._serverInfo.mark or nil
end

--获取服务器名字
function LoginControler:getServerName()
	return self._serverInfo and self._serverInfo.name or nil
end

function LoginControler:getServerMark()
	return self._serverInfo and self._serverInfo.mark or ""
end

--获取服务器的ip
function LoginControler:getServerLink()
	return self._serverInfo.link
end

--是否获取过用户信息
function LoginControler:hasGetUserInfo()
	return self._hasGetUserInfo
end

function LoginControler:setHasGetUserInfo(hasGet)
	self._hasGetUserInfo = hasGet
end


--获取service 名称 根据id
function LoginControler:getServerNameById( id )
	for k,v in pairs(self._serverList) do
		if v._id == id then
			return v.name
		end
	end
	echo("____没有获取到区服:",id)
	return "no区服"
end

function LoginControler:getLocalAccountInfo()
	local username = LS:pub():get(StorageCode.username ,"")
    local password = LS:pub():get(StorageCode.userpassword ,"")
    if username~="" and password ~= "" then
    	return {username=username, password = password}
	end
	return nil
end

function LoginControler:getLocalGuestInfo()
	local loginType = self:getLocalLoginType()
	--local deviceId = LS:pub():get(StorageCode.device_id, "")
	local deviceId = AppInformation:getDeviceID()
	if deviceId ~= "" and loginType == "guest" then
		return {deviceId = deviceId, loginType = loginType}
	end
	return nil
end

function LoginControler:tryShowGonggao()
	if not self._gonggao_has_show then
		self:fetchGonggao()
	end
end

function LoginControler:fetchGonggao()
	local params = {PlatId = AppInformation:getAppPlatform()}
	HttpServer:sendHttpRequest(params, MethodCode.get_notice_3101, c_func(self.onGonggaoBack, self), nil, true, true)
end

function LoginControler:onGonggaoBack(serverData)
	if serverData.result and serverData.result.data then
		self._gonggao_has_show = true
		WindowControler:showWindow("GameGonggaoView", serverData.result.data)
	end
end

function LoginControler:showEnterGameResLoading()
	local initTweenPercentInfo = {percent = 25,frame=20}
	local actionFuncs = {percent=50, frame=20, action = c_func(GameLuaLoader.loadGameSysFuncs, GameLuaLoader)}
	local actionBattleInit =  {percent=70, frame=20, action = c_func(GameLuaLoader.loadGameBattleInit, GameLuaLoader)}

	local loadTextures = c_func(function() 
		local texs = {"global1"}
		local path = "ui/"
		for _, texName in ipairs(texs) do
			local plistFile = string.format("%s%s.plist", path, texName)
			local texFile = string.format("%s%s.png", path, texName)
			GameResUtils:loadTexture(plistFile, texFile)
		end
		--TODO --spine 材质
	end)
	local actionTextures = {percent=100, frame=30, action = loadTextures}

	local processActions = {actionFuncs, actionBattleInit, actionTextures}
	local endFunc = c_func(function() 
		if IS_OPEN_TURORIAL == true then 
			local tutorialManager = TutorialManager.getInstance();
			if tutorialManager:isAllFinish() == false then 
				tutorialManager:startWork(self);
			end 

			-- 暂时关闭强制引导
			-- local unforcedTutorialManager = UnforcedTutorialManager.getInstance();
			-- if unforcedTutorialManager:isAllFinish() == false then 
			-- 	unforcedTutorialManager:startWork();
			-- end 
		end
		WindowControler:showWindow("HomeMainView")
		self._isStartPlay = true;
	end)
	--材质
	WindowControler:showWindow("CompLoading", initTweenPercentInfo, processActions, endFunc)

	--告诉数据中心Loading完了
	ClientActionControler:sendNewDeviceActionToWebCenter(
		ClientActionControler.NEW_DEVICE_ACTION.LOAD_RES_SUCCESS);

	--加一个全局资源的占用符
	local placeHolderPic;
	if CONFIG_USEDISPERSED == true then 
		placeHolderPic = display.newSprite("uipng/global_placeholder_pic.png");
	else 
		placeHolderPic = display.newSprite("#global_placeholder_pic.png");
	end 
	local root = WindowControler:getCurrScene()._root;
	root:addChild(placeHolderPic);

end

function LoginControler:isStartPlay()
 	return self._isStartPlay == true and true or false;
end 

return LoginControler
