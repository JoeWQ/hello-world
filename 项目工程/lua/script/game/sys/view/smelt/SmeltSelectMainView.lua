local SmeltSelectMainView = class("SmeltSelectMainView", UIBase)

local SMELT_ITEM_CATEGORY = {
	ALL = 1,
	MATERIALS = 2,
	PIECES = 3,
}

function SmeltSelectMainView:ctor(winName, piece_items, material_items)
	SmeltSelectMainView.super.ctor(self, winName)
	self.item_types = ItemsModel.itemType
	self._selected_item_this_time = {}
	self.piece_items = piece_items
	self.material_items = material_items
end

function SmeltSelectMainView:loadUIComplete()
	self:setViewAlign()
	self:initMcButtons()
	self:registerEvent()
	self.UI_item:visible(false)
	self.panel_seperator:visible(false)
	self.UI_selected:setMainView(self)
	self:selectCategory(SMELT_ITEM_CATEGORY.ALL)
	self:doLeftAppearAnim()
	self:doRightSelectedAnim()

	SmeltModel:backUpSelectedCache()
end

function SmeltSelectMainView:initMcButtons()
	self.mc_buttons = {}
	for _, index in pairs(SMELT_ITEM_CATEGORY) do
		local mc = self.panel_left.panel_category["mc_category_"..index]
		self.mc_buttons[index] = mc
	end
	if #self.piece_items == 0 then
		self.mc_buttons[SMELT_ITEM_CATEGORY.PIECES]:visible(false)
	end
	if #self.material_items==0 then
		local piece_mc = self.mc_buttons[SMELT_ITEM_CATEGORY.PIECES]
		local material_mc = self.mc_buttons[SMELT_ITEM_CATEGORY.MATERIALS]
		local x,y = material_mc:getPosition()
		material_mc:visible(false)
		piece_mc:pos(cc.p(x,y))
	end
end

function SmeltSelectMainView:doRightSelectedAnim()
    local ui_selected_width = 368

    local ui_selected = self.UI_selected
    
    local x,y = ui_selected:getPosition()
    if self.ui_selectedX == nil then
        self.ui_selectedX = x
    end

    -- 出现动画（移动+渐现)
    ui_selected:pos(self.ui_selectedX + ui_selected_width,y)
    ui_selected:opacity(0)

    local moveAction = act.moveto(0.3,self.ui_selectedX,y)
    local alphaAction = act.fadein(0.6)
    local appearAnim = cc.Spawn:create(moveAction,alphaAction)

    ui_selected:stopAllActions()
    ui_selected:runAction(
        cc.Sequence:create(appearAnim)
    )
	
end

--左侧动画，跟背包行为一样
function SmeltSelectMainView:doLeftAppearAnim()
    local itemLeftWidth = 600

    local panelLeft = self.panel_left

    local x,y = panelLeft:getPosition()
    if self.panelLeftViewX == nil then
        self.panelLeftViewX = x
    end

    -- 出现动画（移动+渐现)
    panelLeft:pos(self.panelLeftViewX - itemLeftWidth,y)
    panelLeft:opacity(0)
    local moveAction = act.moveto(0.3,self.panelLeftViewX,y)
    local alphaAction = act.fadein(0.6)
    local appearAnim = cc.Spawn:create(moveAction,alphaAction) 

    panelLeft:stopAllActions()
    panelLeft:runAction(
        cc.Sequence:create(appearAnim)
    )
end


function SmeltSelectMainView:setViewAlign()
	FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
end

function SmeltSelectMainView:registerEvent()
	self.btn_back:setTap(c_func(self.backClose, self))
	for index,mc in pairs(self.mc_buttons) do
		mc:setTouchedFunc(c_func(self.selectCategory, self, index))
	end

	EventControler:addEventListener(SmeltEvent.SMELTEVENT_SELECTE_ITEM_CHANGED, self.onSelectedItemChange, self)
end

function SmeltSelectMainView:onSelectedItemChange(event)
	local params = event.params
	local selected = self._selected_item_this_time
	local index = params.index
	if params.change_type == "remove" then
		selected[index] = nil
	else
		selected[index] = params.itemId
	end
end

function SmeltSelectMainView:selectCategory(index)
	local current_category = self._current_category or 0
	if index == current_category then return end
	for i, mc in ipairs(self.mc_buttons) do
		if i == index then
			mc:showFrame(2)
		else
			mc:showFrame(1)
		end
	end
	self._current_category = index
	self:doShowCategory(index)
end

function SmeltSelectMainView:doShowCategory(index)
	local content_scroll_list = self.panel_left.panel_content.scroll_list
	local piece_items = self.piece_items
	local material_items = self.material_items
	SmeltModel:sortItems(piece_items)
	SmeltModel:sortItems(material_items)

	if index == SMELT_ITEM_CATEGORY.ALL then
		local params = self:getSmeltAllScrollParams(piece_items, material_items)
		content_scroll_list:styleFill(params)
	elseif index == SMELT_ITEM_CATEGORY.MATERIALS then
		if #material_items > 0 then
			local params = self:getSmeltMaterialScrollParams(material_items)
			content_scroll_list:styleFill({params})
		end
	elseif index == SMELT_ITEM_CATEGORY.PIECES then
		if #piece_items > 0 then
			local params = self:getSmeltPieceScrollParams(piece_items)
			content_scroll_list:styleFill({params})
		end
	end
	content_scroll_list:easeMoveto(0,0)
end


function SmeltSelectMainView:getSmeltMaterialScrollParams(material_items)
	local createFuncMaterial = function(itemData)
		local view = UIBaseDef:cloneOneView(self.UI_item)
		view:setItemData(itemData)
		view:updateUI()
		return view
	end
	local material_params = {
		data = material_items,
		createFunc = createFuncMaterial,
		perNums = 4,
		offsetX = -24,
		offsetY = 5,
		widthGap = 7,
		heightGap = 8 ,
		itemRect = {x=0,y=-98,width = 98,height = 98},
		perFrame=1
	}
	return material_params
end

function SmeltSelectMainView:getSmeltPieceScrollParams(piece_items)
	local createFuncPiece = function(itemData)
		local view = UIBaseDef:cloneOneView(self.UI_item)
		view:setItemData(itemData)
		view:updateUI()
		return view
	end
	local pieces_params = {
		data = piece_items,
		createFunc = createFuncPiece,
		perNums = 4,
		offsetX = -32,
		offsetY = 0,
		widthGap = 11,
		heightGap = 8 ,
		itemRect = {x=0,y= -98,width = 98,height = 98},
		perFrame=1,
	}

	return pieces_params
end

function SmeltSelectMainView:getSmeltAllScrollParams(piece_items, material_items)
	local createFuncSeperator = function(itemData)
		local view = UIBaseDef:cloneOneView(self.panel_seperator)
		return view
	end

	local params = {}
	local seperator_params = {
		data = {1},
		createFunc = createFuncSeperator,
		perNums = 1,
		offsetX = 34,
		offsetY = 10,
		widthGap = 0,
		heightGap = 0 ,
		itemRect = {x=0,y= -30,width = 450,height = 30},
		perFrame=1
	}
	if #material_items > 0 then
		local material_params = self:getSmeltMaterialScrollParams(material_items)
		table.insert(params, material_params)
	end
	if #piece_items > 0 then
		if #material_items > 0 then
			table.insert(params, seperator_params)
		end
		local pieces_params = self:getSmeltPieceScrollParams(piece_items)
		table.insert(params, pieces_params)
	end
	return params
end

function SmeltSelectMainView:backClose()
	SmeltModel:restoreCacheItems()
	EventControler:dispatchEvent(SmeltEvent.SMELTEVENT_SELECT_CANCEL)
	self:startHide()
end

function SmeltSelectMainView:close()
	self:startHide()
end

return SmeltSelectMainView
