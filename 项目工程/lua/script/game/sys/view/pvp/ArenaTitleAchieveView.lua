local ArenaTitleAchieveView = class("ArenaTitleAchieveView", UIBase)

function ArenaTitleAchieveView:ctor(winName, titleId)
	ArenaTitleAchieveView.super.ctor(self, winName)
	self.titleId = titleId
end

function ArenaTitleAchieveView:loadUIComplete()
	self:setViewAlign()
	self:initUIElements()
	self:showTitleAnim()
end

function ArenaTitleAchieveView:initUIElements()
	self.txt_new_title:runAction(act.fadeto(0, 0))
	self.txt_go:runAction(act.fadeto(0, 0))
	self.mc_1:showFrame(tonumber(self.titleId))
	self.mc_1:runAction(act.fadeto(0, 0))
	self.panel_attr:visible(false)
	self.panel_mana:visible(false)



	local attrInfo = FuncPvp.getAttrEffectByTitleId(self.titleId)
	self.attrStr = attrInfo.effectStr
	self.addManaStr = string.format("+%s", attrInfo.mana)
end

function ArenaTitleAchieveView:showTitleAnim()
	-- 黑色背景
	FuncCommUI.addBlackBg(self._root)
    -- 奖品特效
    local anim = FuncCommUI.playSuccessArmature(self.UI_1,FuncCommUI.SUCCESS_TYPE.GET,1)
    self:delayCall(c_func(self.onTitleAnimOk, self), 30/GAMEFRAMERATE )
end

function ArenaTitleAchieveView:setViewAlign()
	FuncCommUI.setViewAlign(self.UI_1.panel_1, UIAlignTypes.MiddleTop)
	-- FuncCommUI.setViewAlign(self.UI_1.ctn_1, UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.txt_go, UIAlignTypes.MiddleBottom)
end

function ArenaTitleAchieveView:onTitleAnimOk()
	self.mc_1:runAction(act.fadeto(0.3, 255))
	self:delayCall(c_func(self.onTitleMarkShow, self), 0.3)
end

function ArenaTitleAchieveView:onTitleMarkShow()

	local onEffectDisplayOver = function()
		self.txt_go:runAction(act.fadeto(0.2, 255))
		self:registerEvent()
	end
	-- 初始法力增加值
	local manaEnterFunc = function()
		local animEffect = self:createUIArmature("UI_common", "UI_common_ruchang", self.ctn_mana, false, onEffectDisplayOver)
		local panel_mana = UIBaseDef:cloneOneView(self.panel_mana)
		local manaBox = panel_mana:getContainerBox()
		panel_mana:pos(-manaBox.width/2+15, manaBox.height/2)
		panel_mana.txt_1:setString(self.addManaStr)
		FuncArmature.changeBoneDisplay(animEffect, "node", panel_mana)
		animEffect:getBoneDisplay("layer1"):visible(false)
		animEffect:startPlay(false)
	end
	-- 属性加成右侧进入
	local animEffect = self:createUIArmature("UI_common", "UI_common_ruchang", self.ctn_attr, false, manaEnterFunc)
	local panel_attr = UIBaseDef:cloneOneView(self.panel_attr)
	panel_attr.txt_attr_effect:setString(self.attrStr)
	local attrBox = self.panel_attr:getContainerBox()
	panel_attr:pos(-attrBox.width/2+15, attrBox.height/2)
	FuncArmature.changeBoneDisplay(animEffect, "node", panel_attr)
	animEffect:getBoneDisplay("layer1"):visible(false)
	animEffect:startPlay(false)


	self.txt_new_title:runAction(act.fadeto(0.3, 255))
end

function ArenaTitleAchieveView:registerEvent()
	self:registClickClose()
end

function ArenaTitleAchieveView:updateUI()
	
end

return ArenaTitleAchieveView

