local CompVipToChargeView = class("CompVipToChargeView", UIBase)

function CompVipToChargeView:ctor(winName, params)
	CompVipToChargeView.super.ctor(self, winName)
	self.tip = params.tip or ""
	self.btnStr = params.btnStr or "确定"
	self.title = params.title or "次数不足"
end

function CompVipToChargeView:loadUIComplete()
	self.txt_1:setString(self.tip)
	self.UI_1.txt_1:setString(self.title)

	self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.close, self))
	local okBtn = self.UI_1.mc_1.currentView.btn_1
	okBtn:setTap(c_func(self.onOkTap, self))
end

function CompVipToChargeView:onOkTap()
	--TODO 此处应该跳往充值界面
	WindowControler:showTips("去充值")
	self:startHide()
end

function CompVipToChargeView:close()
	self:startHide()
end

return CompVipToChargeView

