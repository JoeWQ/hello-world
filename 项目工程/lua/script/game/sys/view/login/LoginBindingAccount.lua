local LoginBindingAccount = class("LoginBindingAccount", UIBase)

function LoginBindingAccount:ctor(winName, isBinding)
	LoginBindingAccount.super.ctor(self, winName)
	self.isBinding = isBinding
	self.userIsAgreed = false
end

function LoginBindingAccount:loadUIComplete()
	if not self.isBinding then
		self.mc_content:showFrame(2)
        --//安卓平台
       if(device.platform == "android")then
             echo("-------------LoginBindingAccount:loadUIComplete-----------------------");
             self.mc_content.currentView.txt_1:setPositionY(self.mc_content.currentView.txt_1:getPositionY()+24);
       end
	end
	self:registerEvent()
end

function LoginBindingAccount:registerEvent()
	local bindingView = self.mc_content:getViewByFrame(1)
	bindingView.btn_close:setTap(c_func(self.close, self))
	bindingView.btn_confirm:setTap(c_func(self.beginBinding, self))
	bindingView.panel_user_agreement:setTouchedFunc(c_func(self.onUserAgreementTap, self))
	local waringView = self.mc_content:getViewByFrame(2)
	waringView.btn_close:setTap(c_func(self.close, self))
	waringView.btn_cancel:setTap(c_func(self.close, self))
	waringView.btn_gobinding:setTap(c_func(self.goBinding, self))

	EventControler:addEventListener(LoginEvent.LOGINEVENT_BIND_ACCOUNT_SUCCESS, self.onBindSuccess, self)
	EventControler:addEventListener(LoginEvent.LOGINEVENT_BIND_ACCOUNT_FAIL, self.onBindFail, self)
end

-- 绑定成功
function LoginBindingAccount:onBindSuccess()
	WindowControler:showTips(GameConfig.getLanguage("tid_login_1009"))

	LoginControler:setLocalLoginType(LoginControler.LOGIN_TYPE.ACCOUNT)
	-- 绑定成功后，修改上次登录类型 by ZhangYanguang
	LoginControler:setLastLoginType(LoginControler.LOGIN_TYPE.ACCOUNT)

	LS:pub():set(StorageCode.username, self.name)
	LS:pub():set(StorageCode.userpassword, self.pass)

	self:close()
end

-- 绑定失败
function LoginBindingAccount:onBindFail(event)
	local serverData = event.params
	local errorData = serverData.error
	if errorData then
		if errorData.code == 20101 then
			WindowControler:showTips(GameConfig.getLanguage("tid_login_1034"))
		end
	end
end

function LoginBindingAccount:beginBinding()
	local bindingView = self.mc_content:getViewByFrame(1)
	local inputUserName = bindingView.input_name
	local inputPassword = bindingView.input_password
	local inputPasswordConfirm = bindingView.input_password_confirm
	local name = inputUserName:getText() 
	if name == "" then
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1013"))
		return
	end	
	--检查名字
	local nameIsOk, nameOkTip = FuncAccountUtil.checkAccountName(name)
	if not nameIsOk then
		WindowControler:showTips(nameOkTip)
		return
	end

	local pass = inputPassword:getText() 
	local pass_confirm = inputPasswordConfirm:getText() 
	if  pass == "" or pass_confirm == "" then
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1002"))
		return
	end
	if pass ~= pass_confirm then
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1008"))
		return
	end
	--检查密码长度
	local passOk, passOkTip = FuncAccountUtil.checkAccountPassword(pass) 
	if not passOk then
		WindowControler:showTips(passOkTip)
		return
	end
	if not self.userIsAgreed then
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1012"))
		return
	end
	self.name = name
	self.pass = pass
	LoginControler:bindAccount(name, pass)
end

function LoginBindingAccount:goBinding()
	self.isBinding = true
	self.mc_content:showFrame(1)
	self.mc_content.currentView.panel_user_agreement.panel_dot:visible(self.userIsAgreed)
end

function LoginBindingAccount:close()
	self:startHide()
end

function LoginBindingAccount:onUserAgreementTap()
	self.userIsAgreed = not self.userIsAgreed
	self.mc_content.currentView.panel_user_agreement.panel_dot:visible(self.userIsAgreed)
end

return LoginBindingAccount

