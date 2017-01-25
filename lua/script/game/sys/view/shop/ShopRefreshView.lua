local ShopRefreshView = class("ShopRefreshView", UIBase)

local RES_MC_MAP = {
	[FuncDataResource.RES_TYPE.DIAMOND] = 1,
	[FuncDataResource.RES_TYPE.ARENACOIN] = 2,
	[FuncDataResource.RES_TYPE.CHIVALROUS] = 3,
}

function ShopRefreshView:ctor(winName, shopId)
	ShopRefreshView.super.ctor(self, winName)
	self.shopId = shopId
end

function ShopRefreshView:loadUIComplete()
	self:registerEvent()
	local refreshTimes = CountModel:getShopRefresh(self.shopId) or 0
	local needMoneyInfo = FuncShop.getRefreshCost(self.shopId, refreshTimes+1)
	local needNum,hasNum,isEnough,resType = UserModel:getResInfo(needMoneyInfo)

	self:setResIcon(resType)

	local title = GameConfig.getLanguageWithSwap("tid_shop_1005")
	self.UI_1.txt_1:setString(title)

	self.txt_1:setString(GameConfig.getLanguage("tid_shop_1006"))

	self.UI_1.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguageWithSwap("tid_shop_1012"))
	self.txt_2:setString(needNum)
	if not isEnough then
		self.txt_2:setColor(FuncCommUI.COLORS.TEXT_RED)
	end
	self.txt_3:setString(GameConfig.getLanguage("tid_shop_1025"))
	local refreshTimesStr = GameConfig.getLanguageWithSwap("tid_shop_1011", refreshTimes)
	self.txt_4:setString(refreshTimesStr)
end

function ShopRefreshView:setResIcon(resType)
	local mcFrame = RES_MC_MAP[resType]
	if mcFrame == nil then mcFrame = 1 end
	self.mc_1:showFrame(mcFrame)
end

function ShopRefreshView:onBtnRefreshTap()
    local refreshTimes = CountModel:getShopRefresh(self.shopId) or 0
    --每次都需要+1
    local needMoneyInfo = FuncShop.getRefreshCost(self.shopId, refreshTimes+ 1)
    local needNum,hasNum,isEnough,resType = UserModel:getResInfo(needMoneyInfo)
    local shopId = self.shopId
	if not UserModel:tryCost(resType, needNum, true) then
		self:startHide()
	else
		if FuncShop.isNoRandShop(shopId) then
			ShopServer:flushNoRandShop(shopId, c_func(self.onRefreshOk, self))
		else
			--刷新
			ShopServer:refreshShop(shopId, c_func(self.onRefreshOk, self))
		end
	end
end

function ShopRefreshView:onRefreshOk()
	WindowControler:showTips(GameConfig.getLanguage("tid_common_1010"))
	EventControler:dispatchEvent(ShopEvent.SHOPEVENT_REFRESH_SHOP_END)
	self:startHide()
end

function ShopRefreshView:onBtnCloseTap()
    self:startHide()
end

function ShopRefreshView:setShopId(shopId)
	self.shopId = shopId
end

--按钮事件
function ShopRefreshView:registerEvent()
	ShopRefreshView.super.registerEvent()
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.onBtnRefreshTap, self))
	self.UI_1.btn_close:setTap(c_func(self.onBtnCloseTap, self))
	self:registClickClose("out")
end

return ShopRefreshView
