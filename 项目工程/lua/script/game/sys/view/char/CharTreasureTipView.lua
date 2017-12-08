-- Author: ZhangYanguang
-- Date: 2017-01-11
-- 主角属性法宝详情界面

local CharTreasureTipView = class("CharTreasureTipView", InfoTipsBase);

function CharTreasureTipView:ctor(winName,treasureId)
    CharTreasureTipView.super.ctor(self, winName);

    self.treasureId = treasureId
end

function CharTreasureTipView:loadUIComplete()
	self:registerEvent()
	self:updateUI()
end 

function CharTreasureTipView:registerEvent()

end

function CharTreasureTipView:updateUI()
	local panelInfo = self.panel_1
	-- 法宝icon
	local treasureIcon = display.newSprite(FuncRes.iconTreasure(self.treasureId))
	treasureIcon:setScale(0.5)
	panelInfo.panel_fb.ctn_1:addChild(treasureIcon)

	-- 法宝名称
	local treasureName = FuncTreasure.getName(self.treasureId)
	panelInfo.txt_1:setString(treasureName)

	-- 技能名称
	panelInfo.txt_2:setString("技能名称")

	-- 技能描述
	-- panelInfo.panel_1
end

return CharTreasureTipView