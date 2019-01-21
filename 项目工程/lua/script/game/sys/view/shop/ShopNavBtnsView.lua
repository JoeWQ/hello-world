local ShopNavBtnsView = class("ShopNavBtnsView", UIBase)

local ALL_SHOP_TYPES = FuncShop.SHOP_TYPES
local sortBySortId = function(a, b)
	return tonumber(a.sortId) < tonumber(b.sortId)
end

function ShopNavBtnsView:ctor(winName)
	ShopNavBtnsView.super.ctor(self, winName)
	self:initData()
end

function ShopNavBtnsView:initData()
	local shopinfos = {}
    local _exclude_shops = {SMELT_SHOP = true,CHAR_SHOP = true,} --暂时排除掉的商店
	for shopType, shopId in pairs(ALL_SHOP_TYPES) do
		local info = {shopType = shopType, shopId = shopId, sortId = 10000+ tonumber(shopId)}
		local show = true
        
		if not FuncShop.checkShopBtnCanShowByLevel(shopId) then
			show = false
		end
		if FuncShop.isVipShop(shopId) then
			local hasOpen = ShopModel:checkIsOpen(shopId)
			if not hasOpen then
				info.sortId = info.sortId + 100
			else
				show = true
			end
		end
		if not _exclude_shops[shopType] and  show then
			table.insert(shopinfos, info)
		end
	end
	table.sort(shopinfos, sortBySortId)
	self.shopInfos = shopinfos
end

function ShopNavBtnsView:loadUIComplete()
	self:registerEvent()
	self.UI_shop_btn1:visible(false)
	self:adjustMainBg()
	self:initBtns()
end

function ShopNavBtnsView:refreshBtns()
	self:initData()
	self:initBtns()
end

function ShopNavBtnsView:initBtns()
	local shopBtnInfos = table.deepCopy(self.shopInfos)
	self.btns = {}
	local createFunc = function(btnInfo,_index)
		local btn = UIBaseDef:cloneOneView(self.UI_shop_btn1)
		btn:setBtnNavView(self)
		btn:setShopId(btnInfo.shopId)
		btn:updateUI()
		self.btns[btnInfo.shopId] = btn
  --      btn.panel_zhui:setVisible(_index==1);
		return btn
	end
	local params = {
		{
			data = shopBtnInfos,
			createFunc = createFunc,
			perNums = 1,
			offsetX =5,
			offsetY = 0,
			widthGap = 0,
			heightGap = -22,
			itemRect = {x=0,y= -162.5,width = 93,height = 162.5},
			perFrame=0
		}
	}
	self.scroll_1:hideDragBar()
	self.scroll_1:styleFill(params)
	if #shopBtnInfos <= 4 then
		self.scroll_1:setCanScroll(false)
	end
end

function ShopNavBtnsView:setMainView(shopMainView)
	self.shopMainView = shopMainView
end

function ShopNavBtnsView:registerEvent()
end

function ShopNavBtnsView:selectShop(shopId,touchfile)
	local btns = self.btns
	local lastShopId = self._last_shop_id
	--点击同一个商店，返回
	if shopId == lastShopId then
		return
	end
	if lastShopId ~= nil then
		if btns[lastShopId] then
			btns[lastShopId]:setSelected(false)
		end
	end
	if btns[shopId] then
		btns[shopId]:setSelected(true)
	end
	self._last_shop_id = shopId
	self:doShowShop(shopId)
	--- 选中都移动标签
	-- if touchfile == nil  then
	-- 	touchfile = false
	-- end
	-- if touchfile == false then
		self.scroll_1:pageEaseMoveTo( shopId,1,0.2 )
	-- end
	
end

function ShopNavBtnsView:doShowShop(shopId)
	if self.shopMainView then
		self.shopMainView:showShop(shopId)
	end
end

function ShopNavBtnsView:close()
	self:startHide()
end

function ShopNavBtnsView:adjustMainBg()
   local scalex = GameVars.width*1.0/GameVars.maxResWidth
   local scaley = GameVars.height*1.0/GameVars.maxResHeight

   --页签背景拉伸适配
--   local panelBgBox = self.panel_bg:getContainerBox()
 --  self.panel_bg:runAction(act.moveby(0, 0, panelBgBox.height*1.0*(scaley-1)/2))
--   self.panel_bg:setScaleY(scaley)

   FuncCommUI.setScrollAlign(self.scroll_1, UIAlignTypes.Middle, 0, 1)
end

return ShopNavBtnsView
