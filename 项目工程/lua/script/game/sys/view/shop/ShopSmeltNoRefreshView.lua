local ShopSmeltNoRefreshView = class("ShopSmeltNoRefreshView", UIBase)

function ShopSmeltNoRefreshView:ctor(winName)
	ShopSmeltNoRefreshView.super.ctor(self, winName)
end

function ShopSmeltNoRefreshView:loadUIComplete()
	self:registerEvent()

	local title = GameConfig.getLanguageWithSwap("tid_shop_1005")
	self.UI_1.txt_1:setString(title)
	if UserModel:isMaxVipLevel() then
		self.mc_1:showFrame(2)
	else
		self.mc_1:showFrame(1)
		local vip = tonumber(UserModel:vip())
		self.mc_1.currentView.mc_vip:showFrame(vip+2)
		local txt_3 = self.mc_1.currentView.txt_3
		local max = FuncCommon.getSmeltShopRefreshMaxTime(vip+1)
		txt_3:setString(GameConfig.getLanguageWithSwap("tid_shop_1032", max))
		if vip + 1 >= 10 then
			txt_3:runAction(act.moveby(0, 10, 0))
		end
	end
end

function ShopSmeltNoRefreshView:registerEvent()
	self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.close, self))
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.close, self))
end

function ShopSmeltNoRefreshView:close()
	self:startHide()
end

return ShopSmeltNoRefreshView
