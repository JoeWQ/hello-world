--[[
	guan
	2016.6.15
]]

local TreasurePowerTips = class("TreasurePowerTips", InfoTipsBase);

--[[
    self.rich_1,
    self.scale9_tips,
]]

function TreasurePowerTips:ctor(winName, treasureId)
    TreasurePowerTips.super.ctor(self, winName);
    self._treasureId = treasureId;
end

function TreasurePowerTips:loadUIComplete()
	self:registerEvent();
	self:updateUI();
end 

function TreasurePowerTips:registerEvent()
	TreasurePowerTips.super.registerEvent();

end

function TreasurePowerTips:updateUI()
	local str = FuncTreasure.getLabel4(self._treasureId);
	echo("--str---", str);
	echo("--self._treasureId---", self._treasureId);
	self.rich_1:setString(str);
end


return TreasurePowerTips;
