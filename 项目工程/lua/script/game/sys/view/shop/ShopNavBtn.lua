local ShopNavBtn = class("ShopNavBtn", UIBase)
function ShopNavBtn:ctor(winName)
	ShopNavBtn.super.ctor(self, winName)
end

function ShopNavBtn:loadUIComplete()
	self:registerEvent()
end

function ShopNavBtn:setBtnNavView(navView)
	self.navView = navView
end

function ShopNavBtn:setShopId(shopId)
	self.shopId = shopId
end

function ShopNavBtn:updateUI()
	local shopId = self.shopId
	local shopName = FuncShop.getShopNameById(shopId)
	self.mc_1:getViewByFrame(1).btn_1:setBtnStr(shopName)
	self.mc_1:getViewByFrame(2).btn_2:setBtnStr(shopName)
	self:setLock()
	if FuncShop.isVipShop(shopId) and not ShopModel:checkIsOpen(shopId) then
		self.mc_1:getViewByFrame(1).btn_1:disabled()
	end
end

function ShopNavBtn:setLock()
	local shopId = self.shopId
	local lockHide = false
	if not FuncShop.isVipShop(shopId) then
		lockHide = true
	else
		if ShopModel:checkIsOpen(shopId) then
			lockHide = true
		end
	end
	self.mc_1:getViewByFrame(1).panel_1:visible(not lockHide)
	self.mc_1:getViewByFrame(2).panel_1:visible(not lockHide)
end

function ShopNavBtn:setSelected(selected)
	if selected then
		self.mc_1:showFrame(2)
	else
		self.mc_1:showFrame(1)
	end
end

function ShopNavBtn:registerEvent()
	self.mc_1:setTouchedFunc(c_func(self.onBtnMcTouched, self))
    self.mc_1:setTouchSwallowEnabled(true);
end

function ShopNavBtn:onBtnMcTouched()
	local shopId = self.shopId
	if not shopId or not self.navView then
		return
	end
	if self.navView.scroll_1:isMoving() then
		return
	end
	if FuncShop.isVipShop(shopId) and not ShopModel:checkIsOpen(shopId) then
		self:actionOnShopNotOpened(shopId)
		return
	end
	self.navView:selectShop(self.shopId,true)
end

function ShopNavBtn:actionOnShopNotOpened(shopId)
	local canOpen = FuncShop.checkVipShopCanOpen(shopId)
	--vip 级别达到，但是未解封
	if canOpen then
		--显示解封
		WindowControler:showWindow("ShopOpenConfirm", shopId)
	end
end

function ShopNavBtn:close()
	self:startHide()
end

return ShopNavBtn
