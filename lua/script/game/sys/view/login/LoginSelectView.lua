local LoginSelectView = class("LoginSelectView", UIBase)

function LoginSelectView:ctor(winName)
	LoginSelectView.super.ctor(self, winName)
end

function LoginSelectView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()

    ClientActionControler:sendNewDeviceActionToWebCenter(
        ClientActionControler.NEW_DEVICE_ACTION.SHOW_LOGIN_OR_SIGN_VIEW);
end

function LoginSelectView:setViewAlign()
end

function LoginSelectView:registerEvent()
	self.btn_account_login:setTap(c_func(self.onAccountLoginTap, self))
	self.btn_guest_login:setTap(c_func(self.onGuestLoginTap, self))
	self.btn_close:setTap(c_func(self.close, self))
	EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_SUCCESS, self.onLoginOk, self)
end

function LoginSelectView:onAccountLoginTap()
	self:startHide()
	WindowControler:showWindow("LoginView")
end

function LoginSelectView:onLoginOk()
    ClientActionControler:sendNewDeviceActionToWebCenter(
        ClientActionControler.NEW_DEVICE_ACTION.SIGN_SUCCESS);
    
	self:close()
end

--试玩
function LoginSelectView:onGuestLoginTap()
	if LoginControler:isLogin() then
		LoginControler:outLogin()
	end
	LoginControler:guestLogin()
end

function LoginSelectView:close()
	self:startHide()
end


return LoginSelectView















