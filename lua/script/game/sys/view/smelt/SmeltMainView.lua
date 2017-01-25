local SmeltMainView = class("SmeltMainView", UIBase)
function SmeltMainView:ctor(winName)
	SmeltMainView.super.ctor(self, winName)
end

function SmeltMainView:setViewAlign()
	FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.UI_res, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
end

function SmeltMainView:loadUIComplete()
	self:setViewAlign()
	self:updateItemsIndex()
	self:updateGetSoulNum()
	self:updateQibaoBtnRedPoint()
	self:registerEvent()
	self:initSmeltGetPos()
	self:playTaijiAnim()
	self.btn_ok_to_smelt:visible(false)
	self:delayCall(c_func(self.playSmeltBtnAnim, self), 1.0/GAMEFRAMERATE*21)
	self:playSmeltShopBtnAnim()
	--取消自动播放跳数字动画
	self.UI_res:setUpdateNumManual()
end

function SmeltMainView:playTaijiAnim()
	local anim = self:createUIArmature("UI_ronglian", "UI_ronglian_taiji", self.ctn_taiji, false, GameVars.emptyFunc)
	local clipNode = self:makeClippingNode(anim)
	local slotAnim = anim:getBoneDisplay("dituo")

	local onSlotBtnAnimEnd = function()
		for i=1,5 do
			local ui_item = self["UI_item_"..i]
			FuncArmature.changeBoneDisplay(slotAnim, "dituob"..i, ui_item)
			ui_item:pos(cc.p(-51,52))
		end
	end
	local onAnimShowEnd = function()
		anim:pause()
	end
	anim:registerFrameEventCallFunc(2, 1, c_func(onSlotBtnAnimEnd))
	anim:registerFrameEventCallFunc(33, 1, c_func(onAnimShowEnd))
	self.anim_taiji = anim
	self.taiji_bg = anim:getBoneDisplay("dituo"):getBone("layer2")
end

function SmeltMainView:makeClippingNode(anim)
	local stencilWidth = 600
	local scaley = GameVars.height*1.0/GameVars.maxResHeight
	local ui_top_panel_height = 54  * scaley
	local stencilHeight = GameVars.height - ui_top_panel_height
	local rectNode = cc.LayerColor:create(cc.c4b(0, 255, 0, 200), stencilWidth, stencilHeight)
    local clipNode = cc.ClippingNode:create()
    clipNode:setStencil(rectNode)
	rectNode:setPosition(-stencilWidth/2, -stencilHeight/2-ui_top_panel_height/2-6)
	self.ctn_taiji:addChild(clipNode)
	anim:parent(clipNode)
	-- anim:retain()
	-- anim:removeFromParent()
	-- clipNode:addChild(anim)
	-- anim:release()
    clipNode:setPosition(0, 0)
end

function SmeltMainView:playSmeltBtnAnim()
	self.btn_ok_to_smelt:visible(true)
	local anim = self:createUIArmature("UI_common", "UI_common_btn2", self.ctn_smelt_btn, false, GameVars.emptyFunc)
	FuncArmature.changeBoneDisplay(anim, "qhfb", self.btn_ok_to_smelt)
	self.btn_ok_to_smelt:pos(cc.p(-232/2,125/2))
end

function SmeltMainView:playSmeltShopBtnAnim()
	local anim = self:createUIArmature("UI_ronglian", "UI_ronglian_btn1", self.ctn_right_btn, false, GameVars.emptyFunc)
	FuncArmature.changeBoneDisplay(anim, "layer3", self.btn_shop_lingbao)
	FuncArmature.changeBoneDisplay(anim, "layer2", self.btn_shop_qibao)
	self.btn_shop_lingbao:pos(cc.p(-55,50))
	self.btn_shop_qibao:pos(cc.p(-55,50))
end

--播放粒子效果
function SmeltMainView:playSoulParticles()
	local effectPlist = FuncRes.getParticlePath()..'ronglianlizi.plist'
	local particleNode = cc.ParticleSystemQuad:create(effectPlist)
	particleNode:setTotalParticles(200)
	self.ctn_lizi:addChild(particleNode)
	particleNode:pos(cc.p(0,0))
	local resWorldPos = self.UI_res:convertToWorldSpace(cc.p(0,0))
	local particleNodeWorldPos = particleNode:convertToWorldSpace(resWorldPos)

	local xoffset = particleNodeWorldPos.x-resWorldPos.x-90
	local yoffset = particleNodeWorldPos.y-resWorldPos.y-40

	--particleNode:runAction(act.moveby(particleLifeTime, xoffset, yoffset))
	local bezierPosArr = {  
		cc.p(0, 0),  
		cc.p(xoffset/2, yoffset*1.2),  
		cc.p(xoffset, yoffset),  
	}  
	local deleteParticle = function()
		self.ctn_lizi:removeAllChildren()
	end
	local showSoulNumAddEffect = function()
		self.UI_res:manualPlayNumChangeAnim()
	end
	local acts = {
		cc.BezierTo:create(1, bezierPosArr),
		act.callfunc(showSoulNumAddEffect),
		act.delaytime(1.0/GAMEFRAMERATE*15),
		act.moveby(0.05, 300, 300),
		act.delaytime(1.2),
		act.callfunc(deleteParticle),
	}
	particleNode:runAction(act.sequence(unpack(acts)))
end

--熔炼特效
function SmeltMainView:playSmeltAnim(serverData)

	local animEnd = function()
		self.ctn_small_taiji:removeAllChildren()
		if self.taiji_bg then
			self.taiji_bg:visible(true)
		end
		self:onSmeltAnimEnd(serverData)
	end
	
	local onExplosion = function()
		self:playSoulParticles()
	end

	local onShake = function()
		local smeltShake = true
		self:playShakeAnim(smeltShake)
	end

	local anim = self:createUIArmature("UI_ronglian", "UI_ronglian_ronglian", self.ctn_small_taiji, false, animEnd)
	if self.taiji_bg then
		self.taiji_bg:visible(false)
	end

	anim:registerFrameEventCallFunc(61, 1, c_func(onShake))
	anim:registerFrameEventCallFunc(64, 1, c_func(onExplosion))

	for i=1, SmeltModel:getMaxCanSelectNum() do
		local ui_item = self["UI_item_"..i]
		local icon,iconName = ui_item:getItemIcon() 
		local subAnim = anim:getBoneDisplay("node"..i)
		if icon ~= nil then
			FuncArmature.changeBoneDisplay(subAnim, "fabao", icon)
			icon:pos(cc.p(-44,42))
			local iconShan = display.newSprite(iconName)
			iconShan:setScale(0.7)
			FuncArmature.changeBoneDisplay(subAnim, "fabao_shan", iconShan)
			iconShan:pos(cc.p(0,0))
		else
			subAnim:getBone("fabao_shan"):visible(false)
			subAnim:getBone("fabao"):visible(false)
		end
		ui_item:visible(false)
	end
end

function SmeltMainView:onSmeltAnimEnd()
	self:reInitItems()
	self:updateGetSoulNum()
	WindowControler:showTips(GameConfig.getLanguage("tid_smelt_1003"))
	AudioModel:playSound("s_treasure_ronglian")
	EventControler:dispatchEvent(SmeltEvent.SMELTEVENT_SMELT_OK)
end

--熔炼可获得的宝物精华数量位置信息
function SmeltMainView:initSmeltGetPos()
	local x,y = self.panel_huode.panel_num:getPosition()
	self.smelt_get_origin_x = x
	self.smelt_get_origin_y = y
	self.origin_smelt_get_num_len = FuncCommUI.getStringWidth("99999999", 24, GameVars.systemFontName)
end

function SmeltMainView:updateQibaoBtnRedPoint()
	local showRedPoint = SmeltModel:checkHasNewTitleToBuy()
	self.btn_shop_qibao:getUpPanel().panel_red:visible(showRedPoint)
end

function SmeltMainView:registerEvent()
	self.btn_back:setTap(c_func(self.close, self))
	self.btn_onekey_add:setTap(c_func(self.onOneKeyAddTap, self))
	self.btn_shop_lingbao:setTap(c_func(self.onLingBaoShopTap, self))
	self.btn_shop_qibao:setTap(c_func(self.onQibaoShopTap, self))
	self.btn_ok_to_smelt:setTap(c_func(self.onSmeltBtnTap, self))

	EventControler:addEventListener(SmeltEvent.SMELTEVENT_SELECTE_ITEM_CHANGED, self.onSelectedItemChange, self)
    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.onJinghunNumChange, self)
	EventControler:addEventListener(SmeltEvent.SMELTEVENT_SELECT_CANCEL, self.onSelectedItemChange, self)
	EventControler:addEventListener(SmeltEvent.SMELTEVENT_ONEKEY_ADD_OK, self.onOneKeyAddOk, self)
	EventControler:addEventListener(SmeltEvent.SMELTEVENT_SELECT_OK, self.onSelectItemOk, self)
end

function SmeltMainView:onSelectItemOk(event)
	self:playShakeAnim()
end

function SmeltMainView:onOneKeyAddOk(event)
	self:playShakeAnim()
end

function SmeltMainView:playShakeAnim(smeltShake)
	local anim = self.anim_taiji
	anim:playWithIndex(1, false)
	local slotAnim = anim:getBoneDisplay("dipian2")
	self.taiji_bg = slotAnim:getBone("layer2")
	if not smeltShake then
		for i=1,5 do
			local ui_item = self["UI_item_"..i]
			FuncArmature.changeBoneDisplay(slotAnim, "dituob"..i, ui_item)
			ui_item:visible(true)
			ui_item:pos(cc.p(-51,52))
		end
	end

	local onEnd = function()
		anim:pause()
	end
	anim:registerFrameEventCallFunc(33, 1, c_func(onEnd))
end

function SmeltMainView:onJinghunNumChange()
	self:updateQibaoBtnRedPoint()
end

function SmeltMainView:onSelectedItemChange()
	self:updateGetSoulNum()
end

--显示这次熔炼可以获得的宝物精华
function SmeltMainView:updateGetSoulNum()
	local num = SmeltModel:calCurentSelectItemSoulNum()
	if num <= 0 then
		self.panel_huode:visible(false)
		FilterTools.setGrayFilter(self.btn_ok_to_smelt)
		self.btn_ok_to_smelt:getUpPanel().panel_red:visible(false)
	else
		self.panel_huode:visible(true)
		local numLen = FuncCommUI.getStringWidth(num..'', 24, GameVars.systemFontName)
		local delta = (self.origin_smelt_get_num_len - numLen)/2
		local x = self.smelt_get_origin_x + delta
		local y = self.smelt_get_origin_y
		self.panel_huode.panel_num:setPosition(cc.p(x,y))
		self.panel_huode.panel_num.txt_2:setString(num)
		FilterTools.clearFilter(self.btn_ok_to_smelt)
		self.btn_ok_to_smelt:getUpPanel().panel_red:visible(true)
	end
end

function SmeltMainView:onSmeltBtnTap()
	local itemsInfo = SmeltModel:getSelectedItemsInfo()
	if table.length(itemsInfo) <= 0 then
		WindowControler:showTips(GameConfig.getLanguage("tid_smelt_1002"))
		return
	end
	SmeltServer:smeltItems(itemsInfo, c_func(self.onSmeltOk, self))

	--self:onSmeltOk()
end

function SmeltMainView:onSmeltOk(serverData)
	SmeltModel:clearSelectedCache()
	self:playSmeltAnim(serverData)
end

function SmeltMainView:reInitItems()
	for i=1, SmeltModel:getMaxCanSelectNum() do
		local ui_item = self["UI_item_"..i]
		if ui_item then
			ui_item:reInitView()
			ui_item:visible(true)
		end
	end
end

function SmeltMainView:onQibaoShopTap()
	WindowControler:showWindow("SmeltTitleView")
end

function SmeltMainView:onLingBaoShopTap()
	WindowControler:showWindow("ShopView", FuncShop.SHOP_TYPES.SMELT_SHOP)
end

function SmeltMainView:onOneKeyAddTap()
	SmeltModel:oneKeyAdd()
end

function SmeltMainView:updateItemsIndex()
	for i=1, SmeltModel:getMaxCanSelectNum() do
		self["UI_item_"..i]:setIndex(i)
	end
end

function SmeltMainView:close()
	SmeltModel:clearSelectedCache()
	self:startHide()
end

return SmeltMainView
