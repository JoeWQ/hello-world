local CompGoodItemView = class("CompGoodItemView", UIBase)

local COST_TO_MC_INDEX = {
	[FuncDataResource.RES_TYPE.COIN] = 1,
	[FuncDataResource.RES_TYPE.DIAMOND] = 2,
	[FuncDataResource.RES_TYPE.ARENACOIN] = 3,
	[FuncDataResource.RES_TYPE.SOUL] = 4,
	[FuncDataResource.RES_TYPE.CHIVALROUS] = 5,
}

function CompGoodItemView:ctor(winName, params)
	CompGoodItemView.super.ctor(self, winName)
	self.params = params
	local itemId = params.itemId or ""
	self.itemId = tostring(itemId)
	self.costInfo = params.costInfo
	self.viewType = params.viewType
	self.itemNum = params.itemNum
	self.okAction = params.okAction
	self.closeManual = params.closeManual -- 手动关闭

	--签到需要
	self.itemResType = params.itemResType
	self.desStr = params.desStr;
end

function CompGoodItemView:loadUIComplete()
	self:registerEvent()
	self:initItemData()
	self:initItemInfoView()
	self:initCommonInfo()
	self:initBottomInfo()
end

function CompGoodItemView:updateUI()
	
end

function CompGoodItemView:createReward()
	if self.itemResType == FuncDataResource.RES_TYPE.ITEM then 
	    return string.format("1,%d,%d", self.itemId, self.itemNum);
	else 
		return string.format("%d,%d", self.itemResType, self.itemNum);
	end 	
end

function CompGoodItemView:initItemData()
	if self.viewType == FuncItem.ITEM_VIEW_TYPE.SHOP then
		self.hasNum = ItemsModel:getItemNumById(self.itemId);
		self.des = GameConfig.getLanguageWithSwap(FuncItem.getItemData(self.itemId).des 
			or "tid_shop_1002"), self.itemId;

		self.iconName = FuncRes.iconRes(UserModel.RES_TYPE.ITEM, self.itemId)

		self.itemType = FuncItem.getItemType(self.itemId)
    	self.itemName =FuncItem.getItemName(self.itemId)

	elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.SIGN then

		if self.itemResType == FuncDataResource.RES_TYPE.ITEM then 
			self.hasNum = ItemsModel:getItemNumById(self.itemId);
		elseif self.itemResType == FuncDataResource.RES_TYPE.COIN then 
			self.hasNum = UserModel:getCoin();
		elseif self.itemResType == FuncDataResource.RES_TYPE.DIAMOND then 
			self.hasNum = UserModel:getGold();
		elseif self.itemResType == FuncDataResource.RES_TYPE.SOUL then
			self.hasNum = UserModel:getSoulCoin();
		else 
			self.hasNum = 0;
		end 
		self.itemName = FuncDataResource.getResNameById(self.itemResType, self.itemId);
		self.des = FuncDataResource.getResDescrib(self.itemResType, self.itemId);
	elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.ONLYDETAIL then
		if self.itemResType == FuncDataResource.RES_TYPE.ITEM then 
			self.hasNum = ItemsModel:getItemNumById(self.itemId);
		elseif self.itemResType == FuncDataResource.RES_TYPE.COIN then 
			self.hasNum = UserModel:getCoin();
		elseif self.itemResType == FuncDataResource.RES_TYPE.DIAMOND then 
			self.hasNum = UserModel:getGold();
		else 
			self.hasNum = 0;
		end 
		self.itemName = FuncDataResource.getResNameById(self.itemResType, self.itemId);
		self.des = FuncDataResource.getResDescrib(self.itemResType, self.itemId);
	end
end

function CompGoodItemView:registerEvent()
	self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.close, self))
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.onOkTap, self))
--//注册事件监听,主角的资源产生了变化
    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE,self.initBuyInfo,self);
--//监听商店刷新事件
    EventControler:addEventListener(ShopEvent.SHOPEVENT_REFRESH_SHOP_END,self.close,self);
    EventControler:addEventListener(ShopEvent.SHOPEVENT_SMELT_SHOP_REFRESHED,self.close,self);
end
function CompGoodItemView:onOkTap()
	if self.okAction then
		self.okAction()
	end
	if not self.closeManual then
		self:close()
	end
end

function CompGoodItemView:initBottomInfo()
	if self.viewType == FuncItem.ITEM_VIEW_TYPE.SHOP then
		self.mc_2:showFrame(1)
		self:initBuyInfo()
	elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.SIGN then
		self.mc_2:showFrame(2)
		self:initSignInfo();
	elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.ONLYDETAIL then
		--self.mc_2:showFrame(2)
		self.mc_2:visible(false)
	end
end

function CompGoodItemView:initSignInfo()
	echo("self.desStr", tostring(self.desStr));
	self.mc_2.currentView.txt_1:setString(self.desStr);
end

function CompGoodItemView:initBuyInfo()
    local costInfo = self.costInfo
    local needNums,hasNums,isEnough,resType = UserModel:getResInfo(costInfo)
    local infoView = self.mc_2.currentView.panel_1
	infoView.txt_1:setString(GameConfig.getLanguage("tid_shop_1022"))
	infoView.txt_2:setString(self.itemNum)
	infoView.txt_3:setString(GameConfig.getLanguage("tid_shop_1024"))

	local index = COST_TO_MC_INDEX[resType]
	if index then
		infoView.panel_1.mc_1:showFrame(index)
	end

    infoView.panel_1.txt_1:setString(needNums)
    if not isEnough then
		infoView.panel_1.txt_1:setColor(FuncCommUI.COLORS.TEXT_RED)
    else
        infoView.panel_1.txt_1:setColor(cc.c3b(0x01,0xbb,0x47));
	end
end

function CompGoodItemView:initItemInfoView()

    --商品名字
	self.txt_1:setString(string.format("%s x %d", self.itemName, self.itemNum))
    --拥有数量
    self.rich_2:setString(GameConfig.getLanguageWithSwap("tid_shop_1001", self.hasNum))
    --商品描述
	self.txt_3:setString(self.des);

	self:setIconAndQuality()
end

--设置按钮和标题
function CompGoodItemView:initCommonInfo()
	local titleView = self.UI_1.txt_1
	if self.viewType == FuncItem.ITEM_VIEW_TYPE.SHOP then
		self.UI_1.txt_1:setString(GameConfig.getLanguageWithSwap("tid_shop_1009"))
		self.UI_1.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguageWithSwap("tid_shop_1010"))
	elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.SIGN then
		--TODO 签到处理
		self.UI_1.txt_1:setString(GameConfig.getLanguageWithSwap("sign_detail_title"))
		self.UI_1.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguageWithSwap("sign_detail_ok"))
	elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.ONLYDETAIL then
		self.UI_1.txt_1:setString(GameConfig.getLanguageWithSwap("tid_shop_1009"))
		self.UI_1.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguageWithSwap("tid_common_2007"))
	end
end

function CompGoodItemView:setIconAndQuality()

	if self.viewType == FuncItem.ITEM_VIEW_TYPE.SHOP then
		local str = string.format("1,%d,%d", self.itemId, self.itemNum);
    	self.UI_2:setResItemData({reward = str});
    elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.SIGN then
    	local str = self:createReward();
    	self.UI_2:setResItemData({reward = str});
    elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.ONLYDETAIL then
		local str = string.format("1,%d,%d", self.itemId, self.itemNum);
    	self.UI_2:setResItemData({reward = str});
    end 
	self.UI_2:showResItemNum(false)

end

function CompGoodItemView:close()
	self:startHide()
end

return CompGoodItemView

