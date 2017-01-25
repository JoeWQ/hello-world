local SmeltModel = class("SmeltModel", BaseModel)
local MAX_SELECT_NUM = 5

function SmeltModel:init(d)
	SmeltModel.super.init(self, d)
	self._cache_selected_items = {}
	EventControler:addEventListener(InitEvent.INITEVENT_FUNC_INIT, self.onFuncInit, self)
    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.onUserModelUpdate, self)
end

function SmeltModel:updateData(data)
	SmeltModel.super.updateData(data)
end

function SmeltModel:onFuncInit(event)
	local params = event.params
	local funcname = params.funcname
	if funcname == "FuncSmelt" then
		self:checkHasNewTitleToBuy()
	end
end

function SmeltModel:onUserModelUpdate()
	if _G['FuncSmelt'] then
		self:checkHasNewTitleToBuy()
	end
end

function SmeltModel:setCurrentSelectIndex(index)
	self._current_select_index = index
end

function SmeltModel:getCurrentSelectedIndex()
	return self._current_select_index
end

function SmeltModel:checkHasNewTitleToBuy()
	local totalSoul = UserExtModel:totalSoul()
	local smelts = UserModel:smelts()
	local rewards = FuncSmelt.getSmeltRewardsData()
	local has = false
	for id,info in pairs(rewards) do
		if totalSoul > info.totalSoul and smelts[id] == nil then
			has = true
		end
	end
	--TODO dispatchEvent home red point event
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, {redPointType=HomeModel.REDPOINT.NAVIGATION.SMELT, isShow = has})
	return has
end

function SmeltModel:addToSelectedCache(itemId)
	local keys = table.keys(self._cache_selected_items)
	if #keys >= MAX_SELECT_NUM then
		return false
	end
	local items = self._cache_selected_items
	local currentIndex = self:getCurrentSelectedIndex()
	local addIndex = currentIndex
	if items[currentIndex] == nil then
		items[currentIndex] = itemId
	else
		for i=1, MAX_SELECT_NUM do
			if items[i] ==nil then
				items[i] = itemId
				addIndex = i
				break
			end
		end
	end
	EventControler:dispatchEvent(SmeltEvent.SMELTEVENT_SELECTE_ITEM_CHANGED, {change_type="add", itemId = itemId, index = addIndex})
	return true
end

function SmeltModel:backUpSelectedCache()
	self._cache_selected_items_back = table.deepCopy(self._cache_selected_items)
end

function SmeltModel:restoreCacheItems()
	if self._cache_selected_items_back then
		self._cache_selected_items = self._cache_selected_items_back
	end
end

function SmeltModel:removeFromSelectedCache(itemId)
	local items = self._cache_selected_items
	local index = table.find(items, itemId)
	if not index then
		return
	else
		items[index] = nil
		EventControler:dispatchEvent(SmeltEvent.SMELTEVENT_SELECTE_ITEM_CHANGED, {change_type="remove", itemId = itemId, index = index})
	end
end

function SmeltModel:clearSelectedCache()
	self._cache_selected_items = {}
end

function SmeltModel:getSelectedItemsIdList()
	return table.deepCopy(self._cache_selected_items)
end

function SmeltModel:getSelectedItemsInfo()
	local ids = self:getSelectedItemsIdList()
	local ret = {}
	for _, id in pairs(ids) do
		ret[tostring(id)] = ItemsModel:getItemNumById(id)
	end
	return ret
end

function SmeltModel:isItemInSelectedCache(itemId)
	local items = self._cache_selected_items
	local found = table.find(items, itemId) 
	local inCache = _yuan3(not found, false, true)
	return inCache
end

function SmeltModel:calCurentSelectItemSoulNum()
	local items = self._cache_selected_items
	local num = 0
	for _, id in pairs(items) do
		local id = tostring(id)
		local haveNum = ItemsModel:getItemNumById(id) or 0
		local soulNumPerItem = FuncItem.getSmeltPrice(id) or 0
		num = num + haveNum * soulNumPerItem
	end
	return num
end

function SmeltModel:getMaxCanSelectNum()
	return MAX_SELECT_NUM
end

function SmeltModel:sortItems(items)
	local sortItems = function(a, b)
		local aQuality = a:getQuality()
		local aId = a:id()

		local bQuality = b:getQuality()
		local bId = b:id()
		if aQuality < bQuality then
			return true
		elseif aQuality == bQuality then
			if aId < bId then
				return true
			else
				return false
			end
		else
			return false
		end
	end
	table.sort(items, sortItems)
end

function SmeltModel:oneKeyAdd()

	local piece_items = self:getAllSmeltPieces()
	local material_items = self:getAllSmeltMaterails()
	if #piece_items==0 and #material_items==0 then
		WindowControler:showTips(GameConfig.getLanguage("tid_smelt_1002"))
		return
	end

	table.insertto(piece_items, material_items, #piece_items+1)
	local allitems = piece_items
	local items = self._cache_selected_items
	local count = 1
	local totalCount = 0
	for index=1, MAX_SELECT_NUM do
		if items[index] == nil then
			for j=count,#allitems do
				local oneItem = allitems[count]
				if not oneItem then
					break
				end
				local id = oneItem:id()
				if not table.find(items, id) then
					items[index] = id
					EventControler:dispatchEvent(SmeltEvent.SMELTEVENT_SELECTE_ITEM_CHANGED, {change_type="add", itemId = id, index = index})
					totalCount = totalCount + 1
					count = 1
					break
				else
					count = j+1
				end
			end
		end
	end
	if totalCount > 0 then
		EventControler:dispatchEvent(SmeltEvent.SMELTEVENT_ONEKEY_ADD_OK)
	end
end

function SmeltModel:getShopRefreshLeftCount()
	local max = FuncCommon.getSmeltShopRefreshMaxTime(UserModel:vip())
	local count = CountModel:getSmeltShopRefreshCount()
	local left = max - count
	left = _yuan3(left<0, 0, left)
	return left
end

--获得可以熔炼的碎片
--1. 必须拥有对应整法宝
--2. 对应整法宝必须满星
--3. 法宝A消失后，其碎片可参与熔炼
function SmeltModel:getAllSmeltPieces()
	local piece_items = ItemsModel:getItemsByType(ItemsModel.itemType.ITEM_TYPE_PIECE)
	local ret = {}
	for _, piece in pairs(piece_items) do
		local piece_id = tostring(piece:id())
		local treasure = TreasuresModel:getTreasureById(piece_id)
		local canCombine = FuncTreasure.isCanCombine(piece_id)
		local canSmelt  = false
		if treasure ~= nil and treasure:isMaxStar() then
			canSmelt = true
		end
		local destroyedTreasure = TreasuresModel:getDestroyedTreasureById(piece_id) 
		if destroyedTreasure~=nil then
			canSmelt = true
		end
		if canSmelt then
			table.insert(ret, piece)
		end
	end
	self:sortItems(ret)
	return ret
end

--获得可熔炼的材料
--1. 是否可熔炼
--2. 熔炼条件
--3. 熔炼单价
function SmeltModel:getAllSmeltMaterails()
	local material_items = ItemsModel:getItemsByType(ItemsModel.itemType.ITEM_TYPE_MATERIAL)
	local ret = {}
	for _, materail in pairs(material_items) do
		local id = tostring(materail:id())
		local canSmelt = FuncItem.canSmelt(id)
		if canSmelt then
			table.insert(ret, materail)
		end
	end
	self:sortItems(ret)
	return ret
end


return SmeltModel
