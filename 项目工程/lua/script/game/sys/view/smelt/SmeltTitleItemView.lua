local SmeltTitleItemView = class("SmeltTitleItemView", UIBase)
function SmeltTitleItemView:ctor(winName, id)
	SmeltTitleItemView.super.ctor(self, winName)
	self.id = id
	self.config = FuncSmelt.getSmeltReward(id)
end

function SmeltTitleItemView:loadUIComplete()
	self:registerEvent()
end

function SmeltTitleItemView:registerEvent()
	self.btn_buy = self.mc_1:getViewByFrame(1).btn_1
	self.btn_buy:setTap(c_func(self.onBuyTap, self))
	if self.id then
		EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.onUserModelUpdate, self)
	end
end

function SmeltTitleItemView:onUserModelUpdate()
	if not self:isSelfHasExchange() then
		self:setCostInfo()
	end
	self:setButton()
end

function SmeltTitleItemView:onBuyTap()
	if not self:isConditionOk() then
		WindowControler:showTips(GameConfig.getLanguage("tid_smelt_1005"))
		return
	end
	local config = self.config
	local price = config.price
	if UserModel:getSoulCoin() < price then
		WindowControler:showTips(GameConfig.getLanguage("tid_smelt_1006"))
		return 
	end
	
	SmeltServer:exchangeByTitle(self.id, c_func(self.onExchangeOk, self))
end

function SmeltTitleItemView:onExchangeOk(serverData)
	WindowControler:showTips(GameConfig.getLanguage("tid_common_1009"))
	self.mc_1:showFrame(2)
	self.mc_1.currentView.panel_buy:visible(false)
	local animCtn = self.mc_1.currentView.ctn_buy
	local onBuyAnimEnd = function()
		EventControler:dispatchEvent(SmeltEvent.SMELTEVENT_BUY_TITLE_OK, {view = self})
	end
	local anim = self:createUIArmature("UI_ronglian", "UI_ronglian_yilingqu", animCtn, false, GameVars.emptyFunc)
	anim:registerFrameEventCallFunc(7, 1, c_func(onBuyAnimEnd))
end

function SmeltTitleItemView:updateUI()
	local config = self.config
	local needTotalSoul = config.totalSoul
	self.txt_1:setString(GameConfig.getLanguageWithSwap("tid_smelt_1004", needTotalSoul))

	self:setCostInfo()

	local num, hasNum, isEnough, resType, resId = UserModel:getResInfo(config.reward)
	local data = {
		itemId = resId,
		itemNum = num,
	}
	self.UI_1:setItemData(data)
	self.UI_1:setClickBtnCallback(c_func(self.showItemDetail, self, resId, num))
	self.UI_1:setResItemClickEnable(true)
	self.UI_1:showResItemName(false)
	self:setButton()
end

function SmeltTitleItemView:showItemDetail(itemId, itemNum)
	local params = {
		itemId = itemId,
		viewType = FuncItem.ITEM_VIEW_TYPE.ONLYDETAIL,
		itemNum = itemNum,
		itemResType =FuncDataResource.RES_TYPE.ITEM,
	}
	WindowControler:showWindow("CompGoodItemView",  params)
end

function SmeltTitleItemView:setButton()
	if self:isSelfHasExchange() then
		self.mc_1:showFrame(2)
	else
		if not self:isConditionOk() then
			FilterTools.setGrayFilter(self.btn_buy)
			self.btn_buy:getUpPanel().panel_red:visible(false)
		else
			local price = self.config.price
			if price > UserModel:getSoulCoin() then
				self.btn_buy:getUpPanel().panel_red:visible(false)
			end
		end
	end
end

function SmeltTitleItemView:setCostInfo()
	local txt = self.txt_2
	local price = self.config.price
	txt:setString(price)
	if not self:isSelfHasExchange() and price > UserModel:getSoulCoin() then
		txt:setColor(FuncCommUI.COLORS.TEXT_RED)
	end
end

function SmeltTitleItemView:isConditionOk()
	local needTotalSoul = self.config.totalSoul
	if needTotalSoul > UserExtModel:totalSoul() then
		return false
	end
	return true
end

--是否已经兑换
function SmeltTitleItemView:isSelfHasExchange()
	--是否已兑换
	local smelts = UserModel:smelts()
	return smelts[self.id..'']~=nil
end

function SmeltTitleItemView:close()
	self:startHide()
end
return SmeltTitleItemView
