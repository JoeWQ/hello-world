local LoginExceptionView = class("LoginExceptionView", UIBase)

function LoginExceptionView:ctor(winName, title, infoStr, okAction)
	LoginExceptionView.super.ctor(self, winName)
	self.titleStr = title
	self.infoStr = infoStr
	self.okAction = okAction --a c_func
end

function LoginExceptionView:loadUIComplete()
	self.txt_1:setString(self.infoStr)
	self.UI_1.txt_1:setString(self.titleStr)
	self:registerEvent()
end

function LoginExceptionView:registerEvent()
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.onOkTap, self))
	self.UI_1.btn_close:setTap(c_func(self.onCloseTap, self))
end

function LoginExceptionView:onOkTap()
	self:close()
	self.okAction()
end

function LoginExceptionView:onCloseTap()
	self:close()
end

function LoginExceptionView:close()
	self:startHide()
end

return LoginExceptionView
