--
-- Author: ZhangYanguang
-- Date: 2016-12-20
--
-- PVE 三星tool tip界面

local WorldStarTipView = class("WorldStarTipView", UIBase);

function WorldStarTipView:ctor(winName,raidId)
    WorldStarTipView.super.ctor(self, winName);

    self.curRaidId = raidId
end

function WorldStarTipView:loadUIComplete()
	self:registerEvent();
    self:registClickClose("out")

    self:updateUI()
end 

function WorldStarTipView:registerEvent()

end

function WorldStarTipView:initView()
	-- 基类需要四个箭头
	self.panel_left = self.panel_left
	self.panel_right = self.panel_right
	self.panel_up = self.panel_up
	self.panel_down = self.panel_down

	self.panel_right:setVisible(false)
	self.panel_up:setVisible(false)
	self.panel_down:setVisible(false)
end

function WorldStarTipView:updateUI()
	local raidScore,condArr = WorldModel:getBattleStarByRaidId(self.curRaidId)
	local raidData = FuncChapter.getRaidDataByRaidId(self.curRaidId)
	local starCondition = FuncCommon.getLevelStarCondition(raidData.level)

	for i=1,3 do
		local mcCond = self["mc_" .. i]
		local txtCond = self["txt_" .. i]

		-- 默认黑色
		mcCond:showFrame(2)
		if condArr[i] and condArr[i] == 1 then
			-- 点亮
			mcCond:showFrame(1)
		end

		local cond = starCondition[i]
		if cond then
			txtCond:setString(cond.tip)
		end
	end
end

return WorldStarTipView;