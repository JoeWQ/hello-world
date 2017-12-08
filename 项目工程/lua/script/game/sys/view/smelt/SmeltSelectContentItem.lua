local SmeltSelectContentItem = class("SmeltSelectContentItem", UIBase)

function SmeltSelectContentItem:ctor(winName)
	SmeltSelectContentItem.super.ctor(self, winName)
end

function SmeltSelectContentItem:loadUIComplete()
	self.btn_delete:visible(false)
	self.panel_selected:visible(false)
	self.panel_mark_pieces:visible(false)
	self.panel_mark_material:visible(false)
	self._is_selected = false
	self.UI_item:setResItemClickEnable(true)
	self:registerEvent()
end

function SmeltSelectContentItem:registerEvent()
	self.btn_delete:setTap(c_func(self.onDeleteTap, self))
	EventControler:addEventListener(SmeltEvent.SMELTEVENT_SELECTE_ITEM_CHANGED, self.onSelectedItemChange, self)
end

function SmeltSelectContentItem:onSelectedItemChange(event)
	if self.itemData == nil then return end
	local params = event.params
	if params.itemId ~= self.itemData:id() then
		return
	end
	if params.change_type == "remove" then
		self._is_selected = false
	else
		self._is_selected = true
	end
	self:updateSelectedState()
	--end
end

function SmeltSelectContentItem:onDeleteTap()
	self._is_selected = false
	local itemId = self.itemData:id()
	SmeltModel:removeFromSelectedCache(itemId)
	self:updateSelectedState()
end


function SmeltSelectContentItem:setItemData(data)
	self.itemData = data
end

function SmeltSelectContentItem:updateUI()
	local num = self.itemData:num()
	local id = self.itemData:id()
	local info = {
		itemId = id,
		itemNum = num,
	}
	self.UI_item:setItemData(info)
	self.UI_item:setResItemClickEnable(true)
	self.UI_item:setClickBtnCallback(c_func(self.onItemTap, self))
	if SmeltModel:isItemInSelectedCache(id) then
		self._is_selected = true
		self:updateSelectedState()
	end
end

function SmeltSelectContentItem:onItemTap()
	self._is_selected = not self._is_selected
	local itemId = self.itemData:id()
	local isSelected = self._is_selected
	if isSelected then
		local ok = SmeltModel:addToSelectedCache(itemId)
		if not ok then
			self._is_selected = false
			WindowControler:showTips(GameConfig.getLanguageWithSwap("tid_smelt_1001", SmeltModel:getMaxCanSelectNum()))
			return
		end
	else
		SmeltModel:removeFromSelectedCache(itemId)
	end
	self:updateSelectedState()
end

function SmeltSelectContentItem:updateSelectedState()
	local isSelected = self._is_selected
	local selected_mark = "panel_mark_material"
	local another_mark = "panel_mark_pieces"
	if self.itemData:getType() == ItemsModel.itemType.ITEM_TYPE_PIECE then
		selected_mark = "panel_mark_pieces"
		another_mark = "panel_mark_material"
	end

	self[selected_mark]:visible(isSelected)
	self[another_mark]:visible(false)

	self.panel_selected:visible(isSelected)
	if isSelected then
		self.UI_item:setClickBtnCallback(c_func(self.onDeleteTap, self))
	else
		self.UI_item:setClickBtnCallback(c_func(self.onItemTap, self))
	end
end

return SmeltSelectContentItem
