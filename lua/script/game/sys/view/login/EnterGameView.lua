local EnterGameView = class("EnterGameView", UIBase)
local SERVER_STATUS_LANG = {
	{lang = "tid_login_1020", mark="[新开]"},
	{lang = "tid_login_1021", mark="[火爆]"},
	{lang = "tid_login_1022", mark="[维护]"},
	{lang = "tid_login_1025", mark="[关闭]"},
}

function EnterGameView:ctor(winName)
	EnterGameView.super.ctor(self, winName)
end

function EnterGameView:loadUIComplete()
	self:setViewAlign()
	self:registEventListeners()
	self:registerEvent()
	self:updateUI()

	self:delayCall(c_func(self.checkShowLoginViewOrAudoLogin, self), 0.2)

	--if LoginControler:getToken() then
	--    self:delayCall(c_func(LoginControler.doGetServerList, LoginControler), 1.0/10)
	--end
	AudioModel:playMusic("m_scene_start", true)
end

-- 注册点击事件
function EnterGameView:registerEvent()
	self.panel_1.btn_serverlist:setTap(c_func(self.onServerListTap, self))
	self.panel_account.btn_help:setTap(c_func(self.onHelpTap, self))
	self.btn_entergame:setTap(c_func(self.onEnterGameTap, self))
	self.panel_account.btn_account:setTap(c_func(self.onAccountTap, self))
end

-- 注册监听事件
function EnterGameView:registEventListeners()
	EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, self.onModelUpdateEnd, self)
    EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_SUCCESS, self.onLoginOk,self )
	EventControler:addEventListener(LoginEvent.LOGINEVENT_GET_SERVER_LIST_OK, self.onGetServerList, self)
	EventControler:addEventListener(LoginEvent.LOGINEVENT_CHANGEZONE, self.onChangeZone, self)
	EventControler:addEventListener(LoginEvent.LOGINEVENT_SELECT_ZONE_BACK, self.onSelectZoneBack, self)
	EventControler:addEventListener(LoginEvent.LOGINEVENT_LOG_OUT, self.onLogout, self)
end

function EnterGameView:checkShowLoginViewOrAudoLogin()
	if not LoginControler:isLogin() then
		--只有第一次进客户端时才自动登录
		if LoginControler:getLoginCount() < 1 then
			local lastLoginType = LS:pub():get(StorageCode.last_login_type)
			if lastLoginType == LoginControler.LOGIN_TYPE.ACCOUNT or lastLoginType == LoginControler.LOGIN_TYPE.GUEST then
				LoginControler:tryAutoLogin()
			else
				WindowControler:showWindow("LoginSelectView")
			end
		else
			WindowControler:showWindow("LoginSelectView")
		end
	end
end

function EnterGameView:updateUI()
	self:setServerListBtn()
	self:setEnterGameBtn()
end

--进入游戏界面按钮特效
function EnterGameView:setEnterGameBtn()
	local ctn = self.btn_entergame:getUpPanel().ctn_1

	--创建spine特效
	local spine  = ViewSpine.new("UI_login"):addto(ctn)
	spine:playLabel("animation",true)

	local anim = self:createUIArmature("UI_login", "UI_login_biaoti", ctn, false, GameVars.emptyFunc)
	anim:gotoAndPause(1)
	anim:startPlay(true)
end

function EnterGameView:setServerListBtn()
	local btn = self.panel_1.btn_serverlist
	local serverId = LoginControler:getServerId() 
	if not serverId then
		btn:setBtnStr('', "txt_1")
		btn:setBtnStr('', "txt_2")
		btn:getUpPanel().rich_servermark:setString("")
	else
		local serverName = LoginControler:getServerName()
		local serverMark = string.format("%s服", LoginControler:getServerMark())
		btn:setBtnStr(serverMark, "txt_1")
		local index = LoginControler:getServerStatusKey(LoginControler:getServerInfo())
		local lang = SERVER_STATUS_LANG[index].lang
		local statusMark = SERVER_STATUS_LANG[index].mark
		local str = GameConfig.getLanguageWithSwap(lang, serverName,statusMark)
		btn:getUpPanel().rich_servermark:setString(str)
	end
end

function EnterGameView:setViewAlign()
	FuncCommUI.setViewAlign(self.panel_account, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_1, UIAlignTypes.MiddleBottom)
	-- FuncCommUI.setViewAlign(self.txt_1, UIAlignTypes.MiddleBottom)
end

function EnterGameView:onLogout()
	self:setServerListBtn()
end

function EnterGameView:onSelectZoneBack()
end

function EnterGameView:onModelUpdateEnd()
	--echo("========================================onModelUpdateEnd----------------------------------------")
	self:storeCurrentServerInfo()
	self:startHide()
	
	--游客登录后没有初始化
	if UserExtModel:hasInited() then
		LoginControler:showEnterGameResLoading()
	else
		WindowControler:showWindow("SelectRoleView")
	end

end

function EnterGameView:storeCurrentServerInfo()
	LS:pub():set(StorageCode.login_last_server_id, LoginControler:getServerId())
	LS:pub():set(StorageCode.login_last_server_index, LoginControler:getServerMark())
	LS:pub():set(StorageCode.login_last_server_name, LoginControler:getServerName())
end

function EnterGameView:onHelpTap()
	WindowControler:showTips("这是帮助，请点击御剑寻仙登录")
end

function EnterGameView:onAccountTap()
	WindowControler:showWindow("LoginSelectView")
	--WindowControler:showWindow("LoginView")
end

function EnterGameView:onChangeZone()
	self:setServerListBtn()
end

function EnterGameView:onGetServerList()
	local serverList = LoginControler:getServerList()
	local history = LoginControler:getHistoryLoginServers(true)
	-- local id = LS:pub():get(StorageCode.login_last_server_id, "")
	-- local index = LS:pub():get(StorageCode.login_last_server_index, "")
	-- local name = LS:pub():get(StorageCode.login_last_server_name, "")
	local id = VersionControler:getServerId()
	-- echo("id====",id);
	-- echo("history==")
	-- dump(history)
	local info 
	
	-- if id=="" or id==nil then
	-- 	info = self:getLatestOpenServer()
	-- else
	-- 	if #history > 0 then
	-- 		--服务器数据优先
	-- 		local serverId = history[1].sec
	-- 		info = self:getServerInfoById(serverId)
	-- 	else
	-- 		--本地
	-- 		info = self:getServerInfoById(id)
	-- 	end
	-- end

	if id ~= nil and id ~= "" then
		-- 本地优先
		info = self:getServerInfoById(id)
	else
		if #history > 0 then
			--服务器数据优先
			local serverId = history[1].sec
			info = self:getServerInfoById(serverId)
		else
			info = self:getLatestOpenServer()
		end
	end

	LoginControler:setServerInfo(info)	
	self:onChangeZone()
end

function EnterGameView:getServerInfoById(id)
	local serverList = LoginControler:getServerList()
	for _, info in pairs(serverList) do
		if tostring(info._id) == tostring(id) then
			return info
		end
	end
end

function EnterGameView:getLatestOpenServer()
	local serverList = LoginControler:getServerList()
	local list = table.deepCopy(serverList)
	local sortByOpenTime = function(a, b)
		return tonumber(a.openTime) > tonumber(b.openTime)
	end
	table.sort(list, sortByOpenTime)
	return list[1]
end

function EnterGameView:onLoginOk(event)

	local loginType = LoginControler:getLocalLoginType()
	local lastLoginType = LS:pub():get(StorageCode.last_login_type, "")
    LoginControler:setLastLoginType(LoginControler:getLocalLoginType())

	if lastLoginType == "" then return end
	local showBindingView = false
	if lastLoginType == LoginControler.LOGIN_TYPE.GUEST then
		if loginType == LoginControler.LOGIN_TYPE.GUEST then
			showBindingView = true
		end
	end
	if showBindingView then
		WindowControler:showWindow("LoginBindingAccount")
		LoginControler:tryShowGonggao()
	end
	--拉取公告
end

function EnterGameView:onServerListTap()
    if not LoginControler:getToken() then
        WindowControler:showTips(GameConfig.getLanguage("tid_login_1003") )
		WindowControler:showWindow("LoginView")
        return
    end
	WindowControler:showWindow("ServerListView")
end

function EnterGameView:onEnterGameTap()
    --检查已经选中的服务器的状态
    ClientActionControler:sendNewDeviceActionToWebCenter(
        ClientActionControler.NEW_DEVICE_ACTION.CLICK_ENTERGAME);

    playSound = false;
    
	-- 进入游戏前，再次判断是否需要执行更新逻辑
	local targetVersion = VersionControler:getTargetServerVersion()
	echo("\n\n点击进入游戏,doCheckVersion targetVersion=",targetVersion)
	local doCheck = VersionControler:doCheckByTargetVersion(targetVersion)
	if doCheck then
		self:startHide()
		WindowControler:showWindow("LoginLoadingView")
		return
	end

	if LoginControler:hasGetUserInfo() then
		return
	end
    if not LoginControler:getToken() then
		self:checkShowLoginViewOrAudoLogin()
        return
	end

	--初次登录、切换服务服务器
	local serverId = LoginControler:getServerId()
	local lastServerId = LoginControler:getLastServerId()
	if tostring(serverId) ~= tostring(lastServerId) then
		if not LoginControler:getServerId() then
			return
		end
		LoginControler:setHasGetUserInfo(false)
		LoginControler:doSelectZone()
		return
	end

	if LoginControler:hasGetUserInfo() then
		self:startHide()
		LoginControler:showEnterGameResLoading()
	else
		LoginControler:doSelectZone()
	end
end

return EnterGameView

