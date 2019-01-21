local SmeltSelectedView = class("SmeltSelectedView", UIBase)

function SmeltSelectedView:ctor(winName)
	SmeltSelectedView.super.ctor(self, winName)
end

function SmeltSelectedView:loadUIComplete()
	self:updateUI()
	self:registerEvent()
end

function SmeltSelectedView:registerEvent()
	self.btn_ok:setTap(c_func(self.onOkTap, self))
	EventControler:addEventListener(SmeltEvent.SMELTEVENT_SELECTE_ITEM_CHANGED, self.onSelectedItemChange, self)
end

function SmeltSelectedView:onOkTap()
	if self.mainView then
		self.mainView:close()
	end
	EventControler:dispatchEvent(SmeltEvent.SMELTEVENT_SELECT_OK)
end

function SmeltSelectedView:setMainView(mainView)
	self.mainView = mainView
end

function SmeltSelectedView:onSelectedItemChange()
	self:updateUI()
end

function SmeltSelectedView:updateUI()
	local selected = SmeltModel:getSelectedItemsIdList()
	local ids = table.values(selected)
	table.sort(ids, function(a, b) return tonumber(a)<tonumber(b) end)
	local max = SmeltModel:getMaxCanSelectNum() 
	for i=1,max do
		local id = ids[i]
		local ui = self["UI_item_"..i]
		if id then
			echo('SmeltSelectedView,updateUI', id)
			ui:setItemData(ItemsModel:getItemById(id))
			ui:visible(true)
			ui:updateUI()
		else
			ui:visible(false)
		end
	end
end

function SmeltSelectedView:close()
	self:startHide()
end

return SmeltSelectedView
