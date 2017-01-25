local SmeltMainItemView = class("SmeltMainItemView", UIBase)
local INDEX_ANIM_MAP = {
	"UI_ronglian_huangse",
	"UI_ronglian_huangse",
	"UI_ronglian_huangse",
	"UI_ronglian_huangse",
	"UI_ronglian_huangse",
}

function SmeltMainItemView:ctor(winName)
	SmeltMainItemView.super.ctor(self, winName)
end

function SmeltMainItemView:loadUIComplete()
	self:showDeleteButton(false)
	self:registerEvent()
end

function SmeltMainItemView:registerEvent()
	self.btn_add:setTap(c_func(self.onAddTap, self))
	EventControler:addEventListener(SmeltEvent.SMELTEVENT_SELECTE_ITEM_CHANGED, self.onSelectedItemChange, self)
	EventControler:addEventListener(SmeltEvent.SMELTEVENT_SELECT_CANCEL, self.onSmeltSelectViewClose, self)
	EventControler:addEventListener(SmeltEvent.SMELTEVENT_SELECT_OK, self.onSmeltSelectOk, self)
	EventControler:addEventListener(SmeltEvent.SMELTEVENT_ONEKEY_ADD_OK, self.onOneKeyAddOk, self)
end

function SmeltMainItemView:onOneKeyAddOk()
	if self.index == nil then return end
	self:checkShowItemAnim()
end

function SmeltMainItemView:onSmeltSelectOk()
	if self.index == nil then return end
	self:checkShowItemAnim()
end

function SmeltMainItemView:onSmeltSelectViewClose(event)
	if self.index == nil then return end
	local selected = SmeltModel:getSelectedItemsIdList()
	local itemId = selected[self.index]
	if itemId == self._cur_item_id then
		return
	end
	if itemId then
		self:showSelectItem(itemId)
	else
		self:reInitView()
	end
	self:checkShowItemAnim()
end

function SmeltMainItemView:reInitView()
	self.ctn_icon:removeAllChildren()
	self._pre_item_id = nil
	self._cur_item_id = nil
	self.item_icon = nil
	self.item_icon_name = nil
	self.btn_delete:visible(false)
	self.btn_add:visible(true)
end

function SmeltMainItemView:getItemIcon()
	return self.item_icon, self.item_icon_name
end

function SmeltMainItemView:onSelectedItemChange(event)
	local params = event.params
	local index = params.index
	if index ~= self.index then return end
	local itemId = params.itemId
	if params.change_type == 'remove' then
		self:reInitView()
	else
		self:showSelectItem(itemId)
	end
end

function SmeltMainItemView:showSelectItem(itemId)
	self._cur_item_id = itemId
	self.ctn_icon:removeAllChildren()

	local ui_item = WindowsTools:createWindow("CompResItemView")
	ui_item:setResItemData({itemId = itemId, itemNum = ItemsModel:getItemNumById(itemId)})
	ui_item:addTo(self.ctn_icon)
	local itemRect = ui_item:getContainerBox()
	ui_item:hideTreasureOrPieceQuality(true)
	ui_item:setTouchedFunc(c_func(self.onItemTap, self))

	self.item_icon = nil
	self.item_icon = ui_item
	self.item_icon_name = FuncRes.iconTreasure(itemId)

	self.btn_delete:visible(true)
	self.btn_delete:setTap(c_func(self.onDeleteTap, self, itemId))
	self.btn_add:visible(false)
end

function SmeltMainItemView:checkShowItemAnim()
	local cur_id = self._cur_item_id 
	local pre_id = self._pre_item_id
	if cur_id and cur_id ~= pre_id  then
		self:doShowIndexEffect()
		self._pre_item_id = cur_id
	end
end

function SmeltMainItemView:doShowIndexEffect()
	local animName = INDEX_ANIM_MAP[self.index]
	local colorAnim 
	local posx = 0
	local posy = 0
	posx = -44
	posy = 42
	if not self.colorAnim then
		colorAnim = self:createUIArmature("UI_ronglian", animName, self.ctn_q_effect, false, GameVars.emptyFunc)
		self.colorAnim = colorAnim
	else
		colorAnim = self.colorAnim
	end

	local onColorAnimEnd = function()
		colorAnim:visible(false)
	end
	colorAnim:gotoAndPause(1)
	colorAnim:visible(true)
	colorAnim:registerFrameEventCallFunc(33, 1, c_func(onColorAnimEnd))
	colorAnim:startPlay(false)

	local itemAnim = self:createUIArmature("UI_ronglian", "UI_ronglian_fabao", self.ctn_icon, false, GameVars.emptyFunc)
	FuncArmature.changeBoneDisplay(itemAnim, "fabao", self.item_icon)
	self.item_icon:pos(posx, posy)
end

function SmeltMainItemView:close()
	self:startHide()
end

function SmeltMainItemView:setIndex(index)
	self.index = index
end

--show select item view 
function SmeltMainItemView:onAddTap()
	self:tryShowSelectItemView()
end

function SmeltMainItemView:onItemTap()
	self:tryShowSelectItemView()
end

function SmeltMainItemView:tryShowSelectItemView()
	SmeltModel:setCurrentSelectIndex(self.index)
	local piece_items = SmeltModel:getAllSmeltPieces()
	local material_items = SmeltModel:getAllSmeltMaterails()
	if #piece_items==0 and #material_items==0 then
		WindowControler:showTips(GameConfig.getLanguage("tid_smelt_1002"))
		return
	end
    WindowControler:showWindow("SmeltSelectMainView", piece_items, material_items)
end

function SmeltMainItemView:onDeleteTap(itemId)
	self.ctn_icon:removeAllChildren()
	SmeltModel:removeFromSelectedCache(itemId)
end

function SmeltMainItemView:showDeleteButton(show)
	self.btn_delete:visible(show)
end

return SmeltMainItemView
