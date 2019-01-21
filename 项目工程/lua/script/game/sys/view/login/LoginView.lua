local LoginView = class("LoginView", UIBase)

function LoginView:ctor(winName)
	LoginView.super.ctor(self, winName)
	self:initData()
	self.current_is_registing = false
end

function LoginView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
end

function LoginView:updateUI()
	self:setUserNameAndPass(self.username, self.password)
end

function LoginView:setUserNameAndPass(username, password)
	local infoView = self.mc_info.currentView
	infoView.input_name:setText(username)
	infoView.input_password:setText(password)
end

function LoginView:initData()
	self.username = LS:pub():get(StorageCode.username ,"")
    self.password = LS:pub():get(StorageCode.userpassword ,"")
end

function LoginView:setViewAlign()
	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
end

function LoginView:registerEvent()
	self.btn_close:setTap(c_func(self.onBackTap, self))
	self.mc_info:getViewByFrame(1).btn_login:setTap(c_func(self.onLoginTap, self))
	self.mc_info:getViewByFrame(1).btn_register:setTap(c_func(self.onRegistTap, self))
	self.mc_info:getViewByFrame(2).btn_register:setTap(c_func(self.beginRegist, self))
	EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_SUCCESS, self.onLoginOk, self)
	EventControler:addEventListener(LoginEvent.LOGINEVENT_GET_SERVER_LIST_OK, self.onGetServerList, self)
end

function LoginView:onBackTap()
	if self.current_is_registing then
		self.mc_info:showFrame(1)
		self.current_is_registing = false
	else
		self:startHide()
	end
end

function LoginView:onLoginOk()
    LS:pub():set(StorageCode.username, self.username)
    LS:pub():set(StorageCode.userpassword, self.password)
end

function LoginView:onGetServerList()
	self:startHide()
end

--登入
function LoginView:onLoginTap()

	local infoView = self.mc_info.currentView
	self.username = infoView.input_name:getText()
	self.password = infoView.input_password:getText()
	if not self:checkUserNameOrPassword(self.username, self.password,true) then
		return
	end
	LoginControler:doLogin(self.username, self.password)
end

--点击登录旁边的注册按钮
function LoginView:onRegistTap()
	self.current_is_registing = true
	self.mc_info:showFrame(2)
	self:setUserNameAndPass(self.username, self.password)
end

function LoginView:checkUserNameOrPassword(username, password,isLogin)
    if not username or username=="" then 
        WindowControler:showTips(GameConfig.getLanguage("tid_login_1001"))
        return false
    else
    	-- TODO 之后登录也要做这个检查
    	if not isLogin then
    		--检查名字
			local nameIsOk, nameOkTip = FuncAccountUtil.checkAccountName(username)
			if not nameIsOk then
				WindowControler:showTips(nameOkTip)
				return false
			end
    	end
    end

    -- if not password or password == "" then
    --     WindowControler:showTips(GameConfig.getLanguage("tid_login_1002"))
    --     return false
    -- end

    if not isLogin then
    	--检查密码长度
		local passOk, passOkTip = FuncAccountUtil.checkAccountPassword(password) 

		echo("\n\n============ passOk, passOkTip=",passOk, passOkTip)
		if not passOk then
			WindowControler:showTips(passOkTip)
			return false
		end
    end
    
	return true
end

--开始注册
function LoginView:beginRegist()
	local infoView = self.mc_info.currentView
    local username = infoView.input_name:getText()
    local password = infoView.input_password:getText()
	if not self:checkUserNameOrPassword(username, password) then
		return
	end
	self.username = username
	self.password = password
    LoginControler:doRegister(username, password, c_func(self.onRegistOk, self))
end

function LoginView:onRegistOk(serverData)
	local errorData = serverData.error
	if errorData then
		if errorData.code == 20101 then
			WindowControler:showTips(GameConfig.getLanguage("tid_login_1034"))
		end
	else
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1006"))
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_REGIST_OK)
		LoginControler:setToken(nil)
		LoginControler:removeServerListCache()
		self.mc_info:showFrame(1)

		LS:pub():set(StorageCode.username ,self.username)
		LS:pub():set(StorageCode.userpassword ,self.password)
		LS:pub():set(StorageCode.login_last_server_id, "")

		self:setUserNameAndPass(self.username, self.password)
	end
end

return LoginView

