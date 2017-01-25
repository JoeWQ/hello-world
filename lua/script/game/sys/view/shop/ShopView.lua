local ShopView = class("ShopView", UIBase)
ShopView.updateCount =0
local ITEM_MOVE_DISTANCE = 180

local PANEL_RES_MC_MAP = {
	[FuncShop.SHOP_TYPES.NORMAL_SHOP_1] = 1,
	[FuncShop.SHOP_TYPES.NORMAL_SHOP_2] = 1,
	[FuncShop.SHOP_TYPES.NORMAL_SHOP_3] = 1,
	[FuncShop.SHOP_TYPES.SMELT_SHOP] = 2, --策划说先屏蔽掉这个值
	[FuncShop.SHOP_TYPES.PVP_SHOP] = 3,
	[FuncShop.SHOP_TYPES.CHAR_SHOP] = 4, --暂时屏蔽掉
}
--//背板类型
local   BACK_PANEL_MC_MAP={
	[FuncShop.SHOP_TYPES.NORMAL_SHOP_1] = 1,
	[FuncShop.SHOP_TYPES.NORMAL_SHOP_2] = 2,
	[FuncShop.SHOP_TYPES.NORMAL_SHOP_3] = 3,
	[FuncShop.SHOP_TYPES.SMELT_SHOP] = 4,
	[FuncShop.SHOP_TYPES.PVP_SHOP] = 4,
	[FuncShop.SHOP_TYPES.CHAR_SHOP] = 4,
}

--//商店显示flash动画类型
local   ANI_SHOW_MAP={
   [FuncShop.SHOP_TYPES.NORMAL_SHOP_1]=1,
   [FuncShop.SHOP_TYPES.NORMAL_SHOP_2]=2,
   [FuncShop.SHOP_TYPES.NORMAL_SHOP_3]=3,
   [FuncShop.SHOP_TYPES.SMELT_SHOP] = 4,
   [FuncShop.SHOP_TYPES.PVP_SHOP] = 5,
   [FuncShop.SHOP_TYPES.CHAR_SHOP] = 6,
}

function ShopView:ctor(winName, defaultShopId)
    ShopView.super.ctor(self, winName)
    if defaultShopId then
    	self.defaultShopId = defaultShopId
    else
    	self.defaultShopId = FuncShop.SHOP_TYPES.NORMAL_SHOP_1
	end
	self.shop_showed = {}
    self.scroll_effect={}--//记录ScrollView缓动的情况
end

function ShopView:loadUIComplete()
	self._anim_move_items = {}

	self.scrollOriginRect = table.deepCopy(self.scroll_list:getViewRect())
	self.scrollOriginPosX, self.scrollOriginPosY = self.scroll_list:getPosition()
	self:setViewAlign()

	self:registerEvent()
	self._curshopId = self.defaultShopId
	self.UI_shop_btns:setMainView(self)
	self.UI_shop_btns:selectShop(self._curshopId)
	self:updateUI()
	--@测试 版署包 暂时屏蔽掉商店刷新功能
	if APP_PLAT == 10001 then
		self.mc_shuaxin:visible(false)
	end
	
	ShopModel:setShopIsShow(true)
--//边缘模糊
    self.scroll_list:enableMarginBluring();
end

function ShopView:updateShopBtnStatusInfo(shopId, key, value)
	local info = self.shopBtns[shopId]
	info[key]= value
end

function ShopView:setViewAlign()
	FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.UI_shop_btns, UIAlignTypes.Left,0.7)
    self.UI_shop_btns.scroll_1:setBarBgWay(-1);
	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.mc_res, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.scale9_titledi,UIAlignTypes.LeftTop);
 --   FuncCommUI.setViewAlign(self.panel_zhui,UIAlignTypes.Left,0.9);
    self.scale9_titledi:setContentSize(cc.size(GameVars.width,self.scale9_titledi:getContentSize().height));
end

function ShopView:registerEvent()
	ShopView.super.registerEvent(self)
	--刷新按钮
	for i=1,3 do
		local btn_refresh = self.mc_shuaxin:getViewByFrame(i).btn_refresh
		btn_refresh:setTap(c_func(self.onRefreshTap, self))
		btn_refresh:setTouchSwallowEnabled(true)
	end

    self.btn_back:setTap(c_func(self.press_btn_back, self))

    --根据策划需要 判断是否需要变动的剩余时间
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self),0)

    --注册商店刷新事件 直接刷新ui
    --
	--EventControler:addEventListener(ShopEvent.SHOPEVENT_BUY_ITEM_END, self.onBuyItemEnd, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_REFRESH_SHOP_END, self.onRefreshEnd, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_GET_SHOP_END, self.onGetShopInfoEnd, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_SHOP_JIEFENG_END, self.onShopJiefeng, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_SHOP_JIEFENG_VIEW_CLOSE, self.onShopJiefengClose, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_SMELT_SHOP_REFRESHED, self.onSmeltShopRefreshed, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_NORAND_SHOP_REFRESHED, self.onNoRandShopRefreshed, self)
--//监听角色的等级,VIP变化  
    EventControler:addEventListener(UserEvent.USEREVENT_VIP_CHANGE,self.onShopJiefeng,self);
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE,self.onShopJiefeng,self);
end

function ShopView:onNoRandShopRefreshed(event)
	local shopId = self._curshopId
	if FuncShop.isNoRandShop(shopId) then
		self._is_refresh_show = true
		self:updateUI()
		self:showShop(shopId)
	end
end

--熔炼商店购买成功后
function ShopView:onSmeltShopRefreshed()
	local shopType = FuncShop.SHOP_TYPES.SMELT_SHOP
	if self._curshopId ~= shopType then
		return
	end
	self._is_refresh_show = true
	self:updateUI()
	self:showShop(shopType)
end

function ShopView:onShopJiefeng(event)
	local shopId = event.params
	self.UI_shop_btns:refreshBtns()
	self.UI_shop_btns:selectShop(shopId)
	self:updateUI()
end

function ShopView:onShopJiefengClose(event)
	local shopId = event.params
end

function ShopView:onBuyItemEnd()
	self:updateUI()
end

function ShopView:onRefreshEnd()
	self._is_refresh_show = true
	self:updateUI()
	self:showShop(self._curshopId)
end

function ShopView:onGetShopInfoEnd()
	self:updateUI()
end

function ShopView:updateFrame(dt)
    self.updateCount = self.updateCount +1
    --一秒刷新一次
    if self.updateCount % GAMEFRAMERATE  == 0 then
        self:updateBottomPanelInfo()
    end
end

function ShopView:updateBottomPanelInfo()
	local shopId = self._curshopId
	if shopId == FuncShop.SHOP_TYPES.SMELT_SHOP then
		self:updateSmeltShopBottomPanel()
	elseif FuncShop.isNoRandShop(shopId) then
		self:updateNoRandomShopBottomPanel(shopId)
	else
		self:updateNormalShopBottomPanel()
	end
end

function ShopView:updateNoRandomShopBottomPanel()
	self.mc_shuaxin:showFrame(3)
	local countType = FuncCount.COUNT_TYPE.COUNT_TYPE_PVP_SHOP_REFRESH_TIMES
	if shopId == FuncShop.SHOP_TYPES.CHAR_SHOP then
		countType = FuncCount.COUNT_TYPE.COUNT_TYPE_CHAR_SHOP_REFRESH_TIMES
	end
	local m = FuncCount.getMinute(countType)
	local h = FuncCount.getHour(countType)
	h = tonumber(h)
	--刷新时间显示
	local pre = "今日"
	local now = TimeControler:getServerTime()
	local d = os.date("*t", now)
	local refresh_t, isToday = FuncShop.getNoRandShopRefreshTime(self._curshopId)
	if not isToday then
		pre = "明日"
	end
	local timeStr = string.format("%s%02d:%02d", pre, h, m)
	local txt_refresh = self.mc_shuaxin.currentView.txt_refresh
	txt_refresh:setString(GameConfig.getLanguageWithSwap("tid_pvp_1031", timeStr))
end

--底部刷新时间显示
function ShopView:updateNormalShopBottomPanel()
	local shopId = self._curshopId
	local panel_time = self.mc_shuaxin.currentView.panel_time
	if not panel_time then return end

	local isTempShop = ShopModel:isTempShop(shopId)
	local timeToShow = 0
	if isTempShop then
		timeToShow = ShopModel:getTempShopLeftTime(shopId)
		local shopName = FuncShop.getShopNameById(shopId)
		panel_time.txt_time_tip:setString(GameConfig.getLanguageWithSwap("tid_shop_1021", shopName))
		panel_time.txt_refresh_time:setString(fmtSecToHHMMSS(timeToShow))
--//注意一下的代码会将程序陷入死递归,实际上是不应该有的,档外部系统进入临时商店的时候需要实现[判断一下商店是否已经关闭了,而不是进入商店后在判断
		if timeToShow == 0 then
--            assert(false,"User should judge whether temple shop is opened.");
			self._curshopId = self.defaultShopId
			self:updateUI()
		end
	else
		--非临时商店显示的是下次刷新时间
		local targetTime,left = ShopModel:getNextRefreshTime(shopId) 
		timeToShow = targetTime
		panel_time.txt_time_tip:setString(GameConfig.getLanguage("tid_shop_1020"))
		panel_time.txt_refresh_time:setString(fmtSecToHHMM(timeToShow))
	end
end

--底部panel
function ShopView:updateSmeltShopBottomPanel()
	self.mc_shuaxin:showFrame(2)
	local contentView = self.mc_shuaxin.currentView
	--刷新次数
	local leftCount = SmeltModel:getShopRefreshLeftCount()
	contentView.txt_count:setString(GameConfig.getLanguageWithSwap("tid_common_2004", leftCount))
	if UserModel:getSoulCopper() > 0 then
		contentView.mc_cost:showFrame(2)
	else
		contentView.mc_cost:showFrame(1)
		local refreshCost = FuncSmelt.getShopRefreshSoulNum()
		local num_txt = contentView.mc_cost.currentView.txt_2
		num_txt:setString(refreshCost)
		if refreshCost > UserModel:getSoulCoin() then
			num_txt:setColor(FuncCommUI.COLORS.TEXT_RED)
		else
			num_txt:setColor(num_txt:getOriginColor())
		end
	end
end

function ShopView:onSmeltShopRefreshTap()
	local leftCount = SmeltModel:getShopRefreshLeftCount()
	if leftCount <=0 then
		WindowControler:showWindow("ShopSmeltNoRefreshView")
		return
	end
	local refreshCost = FuncSmelt.getShopRefreshSoulNum()
	local currentSoulNum = UserModel:getSoulCoin()
	if tonumber(refreshCost) > tonumber(currentSoulNum) then
		WindowControler:showTips(GameConfig.getLanguage("tid_smelt_1006"))
		return 
	end
	
	SmeltServer:flushShop(c_func(self.onSmeltShopRefreshOk, self))
end

function ShopView:onSmeltShopRefreshOk(serverData)
	WindowControler:showTips(GameConfig.getLanguage("tid_common_1010"))
	self._is_refresh_show = true
	self:updateUI()
end

--返回按钮
function ShopView:press_btn_back()
	ShopModel:setShopIsShow(false)
    self:startHide()
end

function ShopView:onRefreshTap()
	local currentShopId = self._curshopId
	local SHOP_TYPES = FuncShop.SHOP_TYPES
	if currentShopId == SHOP_TYPES.SMELT_SHOP then
		self:onSmeltShopRefreshTap()
	else
		WindowControler:showWindow("ShopRefreshView", currentShopId)
	end
end

--刷新ui
function ShopView:updateUI()
	self:updateBottomPanelInfo()
end

function ShopView:getItemDataByShopData(shopData)
	local currentShopId = self._curshopId
	local data = {}
	if FuncShop.isNoRandShop(currentShopId) then
		local cost = shopData.cost
		data = {
            shopId=currentShopId,
			itemId = shopData.itemId,
			num = shopData.num,
			costInfo = string.format("%s,%s", FuncShop.getNoRandShopCoinType(currentShopId), cost),
			soldOut = shopData.soldOut,
			shopGoodsId = shopData.id,
		}
	else
		local shopGoodsId = shopData.id
		local shopGoodsData = FuncShop.getGoodsInfo(currentShopId, shopGoodsId)
		local itemId = shopGoodsData.itemId
		local buyTimes = shopData.buyTimes or 0
		local costInfo = ""
		local num = shopGoodsData.goodsNumber
		data = {
            shopId = currentShopId,
			itemId = shopGoodsData.itemId,
			num = num,
			costInfo = shopGoodsData.cost[1],
			itemIndex = shopData.index,
			soldOut = buyTimes > 0,
			shopGoodsId = shopGoodsId,
            specials=shopGoodsData.specials,
		}
		if currentShopId == FuncShop.SHOP_TYPES.SMELT_SHOP then
			data.num = shopGoodsData.num
			data.label = shopGoodsData.label
		end
	end
	return data
end

function ShopView:sortItemList(itemList)
	local curShopId = self._curshopId
	if curShopId == FuncShop.SHOP_TYPES.SMELT_SHOP then
		local rare_index_arr = {1,4,2,3,5,6}
		local common_arr = {}
		local ret = {}
		for _, info in ipairs(itemList) do
			local id = info.id
			local data = FuncShop.getGoodsInfo(curShopId, id)
			if tonumber(data.label) == FuncSmelt.RARITY_LABEL.RARE then
				local index = table.remove(rare_index_arr, 1)
				ret[index] = info
			else
				table.insert(common_arr, info)
			end
		end
		table.sort(rare_index_arr)
		for _, info in pairs(common_arr) do
			local index = table.remove(rare_index_arr, 1)
			ret[index] = info
		end
		return ret
	else
		return itemList
	end
end

function ShopView:showShop(shopId)
	local isOpen = ShopModel:checkIsOpen(shopId) 
    self._curshopId = shopId

	self:updateShopCoinPanel(shopId)
	self:updateBottomRefreshPanel(shopId)

	self:updateBottomPanelInfo()
	self.scroll_list:visible(true)

	--获取商店列表
	local itemList = self:getShopItemList(shopId)
	--itemList = self:sortItemList(itemList)

	self._anim_move_items = {}
	self.shop_data_list = itemList
	local itemNum = #itemList
	local createFunc = function (shopData, index)
		local data = self:getItemDataByShopData(shopData)
        local global_index=BACK_PANEL_MC_MAP[shopId];
		local item = WindowsTools:createWindow("CompShopItemView",  data, index,global_index,ANI_SHOW_MAP[shopId])
		item.btn_1:setTap(c_func(self.pressBuyItem, self, item, shopData.index, shopData))
--		self:checkAnimInitMoveItems(item, itemNum)
		return item
	end

	local updateFunc = function (shopData,view)
		if self._is_refresh_show then
			self:animShowItem(view, shopData)
		else
			local data = self:getItemDataByShopData(shopData)
			view:setItemData(data)
			view:updateUI()
		end
	end
	local offsetX, offsetY, widthGap, heightGap = self:getItemScrollValues(#itemList)
	local params = {
		{
			data = itemList,
			createFunc = createFunc,
			updateFunc= updateFunc,
			perNums = 3,
			offsetX = offsetX,
			offsetY = offsetY,
			widthGap = widthGap,
			heightGap = heightGap,
			itemRect = {x=0,y= -202,width = 259.5,height = 202},
			perFrame=3
		}
	}
    self.scroll_list:setFillEaseTime(0.3);
    self.scroll_list:setItemAppearType(1, self.scroll_effect[shopId]);
	self.scroll_list:styleFill(params)
	self.scroll_list:easeMoveto(0,0,0)
    self.scroll_effect[shopId]=true
--[[	if #itemList <= 6 then
		self.scroll_list:setCanScroll(false)
	else
		self.scroll_list:setCanScroll(true)
	end]]
    self.scroll_list:setCanScroll(true)
end

function ShopView:checkAnimInitMoveItems(item, totalNum)
	if self.shop_showed[self._curshopId]~=nil then
		return false
	end
	local items = self._anim_move_items
	local num = 6
	if totalNum >6 then
		num = 9
		if num > totalNum then
			num = totalNum
		end
	else
		if num < totalNum then
			num = totalNum
		end
	end
	if #items < num then
		table.insert(items, item)
		local count = math.floor(#items/3) + 1
		if #items%3 == 0 then
			count = count - 1
		end
		item:visible(false)
		item:runAction(act.moveby(0, 0, -ITEM_MOVE_DISTANCE*count))
	end
	if #items >= num then
		self:doAnimMoveItems(items, num)
	end
end

function ShopView:doAnimMoveItems(items, num)
	local count = 0
	for i=1,num,3 do
		count = count + 1
		for j=i,i+2 do
			local item = items[j]
			if item ~= nil then
				item:visible(true)
				item:runAction(self:makeItemMoveAction(count, item))
			end
		end
	end
	self.shop_showed[self._curshopId] = true
end

function ShopView:makeItemMoveAction(count, item)
	local frameTime = 1.0/GAMEFRAMERATE
	--local itemVisible = function()
	--    --item:visible(true)
	--end
	local offset = 1*(count-1)
	local act = act.sequence(
		--act.callfunc(itemVisible),
		act.delaytime((count-1)*2*frameTime),
		act.easebackout(act.moveby(frameTime*6, 0, ITEM_MOVE_DISTANCE*count-5-offset)),
		act.moveby(frameTime*3, 0, 10+offset*2),
		act.moveby(frameTime*2, 0, -5-offset)
	)
	return act
end

function ShopView:getShopItemList(shopId)
	local TYPES = FuncShop.SHOP_TYPES
	local shop_data_in_shop_model_ids = {TYPES.NORMAL_SHOP_1, TYPES.NORMAL_SHOP_2, TYPES.NORMAL_SHOP_3, TYPES.SMELT_SHOP}
	if table.find(shop_data_in_shop_model_ids, shopId) then
		return ShopModel:getShopItemList(shopId)
	elseif shopId == TYPES.PVP_SHOP then
		return NoRandShopModel:getShopGoodsInfo(TYPES.PVP_SHOP)
	elseif shopId == TYPES.CHAR_SHOP then
		return NoRandShopModel:getShopGoodsInfo(TYPES.CHAR_SHOP)
	end
	
end

function ShopView:updateShopCoinPanel(shopId)
	local mcFrame = PANEL_RES_MC_MAP[shopId]
	if not mcFrame then mcFrame = 1 end
	self.mc_res:showFrame(mcFrame)
end

function ShopView:updateBottomRefreshPanel(shopId)
	if shopId == FuncShop.SHOP_TYPES.SMELT_SHOP then
		self.mc_shuaxin:showFrame(2)
	else
		self.mc_shuaxin:showFrame(1)
	end
	
end

function ShopView:animShowItem(item, shopData)
	local data = self:getItemDataByShopData(shopData)
	local scalePos = cc.p(250/2,-203/2)
	local scaleTime = 0.1
	local setData = act.callfunc(c_func(item.setItemData, item, data))
	local updateItemUI = act.callfunc(c_func(item.updateUI, item))
	local scaleBig = item:getFromToScaleAction(scaleTime, 0.1, 0.1, 1, 1, false, scalePos)
	item:runAction(act.sequence(setData, updateItemUI, scaleBig))
	if item:getItemIndex() >= #self.shop_data_list then
		self._is_refresh_show = false
	end
end

-- return ffsetx, offsety, widthgap, heightgap
function ShopView:getItemScrollValues(itemNum)
	if itemNum <= 6 then
		return 0, 30, 1, 0 
	else
		return 0, 10, 1, 0
	end
end

--购买道具
function ShopView:pressBuyItem(itemView, index, shopData)
    if self.scroll_list:isMoving() then
        return
    end
	local data = self:getItemDataByShopData(shopData)
    local currentShopId = self._curshopId
    local soldOut = data.soldOut
	if soldOut then
		WindowControler:showTips({text = GameConfig.getLanguage("tid_shop_1008")})
		return
	end
	local costInfo = data.costInfo
	local needNum,hasNum,isEnough,resType,resId = UserModel:getResInfo(costInfo)
	local itemId = data.itemId

	local buyFunc = function()
		if not UserModel:tryCost(resType, needNum, true) then
			return
		end
		self:buyItemAction(data, shopData, index, itemId, itemView) 
	end

	local params = {
		itemId = itemId,
		costInfo = costInfo,
		viewType = FuncItem.ITEM_VIEW_TYPE.SHOP,
		itemNum = data.num,
		okAction = c_func(buyFunc),
		closeManual = true, 
	}
--//注意,在弹出这个窗口的同时也需要监听商店刷新事件,商店自动刷新的那一刻,就需要关闭这个打开的UI
	self.goodsDetailView = WindowControler:showWindow("CompGoodItemView",  params)
end

function ShopView:buyItemAction(data, shopData, index, itemId, itemView)
	local onBuyBack = c_func(self.buyItemBack, self, itemId, data, shopData, itemView)
	local currentShopId = self._curshopId
	if currentShopId == FuncShop.SHOP_TYPES.SMELT_SHOP then
		SmeltServer:buyGoods(index, onBuyBack)
	elseif FuncShop.isNoRandShop(currentShopId) then
		ShopServer:noRandShopBuyGoods(currentShopId, data.shopGoodsId, onBuyBack)
	else
		ShopServer:buyGoods(self._curshopId, data.shopGoodsId, index, onBuyBack)
	end
end

--购买道具返回
function ShopView:buyItemBack(itemId, data, shopData, itemView, serverData)
	if self.goodsDetailView then
		self.goodsDetailView:close()
		self.goodsDetailView = nil
	end
	data.soldOut = true
	shopData.soldOut = true
	itemView:setItemData(data)
	itemView:playSoldOutAnim()
	
	local rewardStr = string.format("%s,%s,%s", FuncDataResource.RES_TYPE.ITEM, data.itemId, data.num)
	FuncCommUI.startRewardView({rewardStr})

	EventControler:dispatchEvent(ShopEvent.SHOPEVENT_BUY_ITEM_END,data)
end

return ShopView
