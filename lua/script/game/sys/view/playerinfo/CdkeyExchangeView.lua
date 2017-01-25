local CdkeyExchangeView = class("CdkeyExchangeView", UIBase)

function CdkeyExchangeView:ctor(winName)
	CdkeyExchangeView.super.ctor(self, winName)
end

function CdkeyExchangeView:loadUIComplete()
	self:registerEvent()
end

function CdkeyExchangeView:registerEvent()
	self:registClickClose("out")
	self.btn_close:setTap(c_func(self.close, self))
	self.btn_confirm:setTap(c_func(self.tryExchangeCdkey, self))
end

function CdkeyExchangeView:tryExchangeCdkey()
	local cdkey = self.input_cdkey:getText()
	local ok,tip = FuncSetting.checkCdkeyStr(cdkey)
	if not ok then
		WindowControler:showTips(tip)
		return
	end
	UserServer:exchangeCdkey(cdkey, c_func(self.onCdkeyExchangeOk, self))
end

function CdkeyExchangeView:onCdkeyExchangeOk(serverData)
	if not serverData or not serverData.result or not serverData.result.data then
		return
	end
	self:close()
	local rewards = serverData.result.data.reward
	WindowControler:showWindow("CdkeyExchangeResult", rewards)
end

function CdkeyExchangeView:close()
	self:startHide()
end

return CdkeyExchangeView

