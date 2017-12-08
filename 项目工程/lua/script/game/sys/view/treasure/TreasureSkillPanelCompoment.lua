local TreasureSkillPanelCompoment = class("TreasureSkillPanelCompoment", UIBase);

--[[
    self.ctn_2,
    self.panel_1,
    self.panel_1.ctn_1,
    self.panel_1.panel_ljt,
    self.panel_1.panel_suo,
    self.panel_2.mc_st1,
    self.panel_2.txt_1,
]]

function TreasureSkillPanelCompoment:ctor(winName)
    TreasureSkillPanelCompoment.super.ctor(self, winName);
end

function TreasureSkillPanelCompoment:loadUIComplete()
	self:registerEvent();
end 

function TreasureSkillPanelCompoment:registerEvent()
	TreasureSkillPanelCompoment.super.registerEvent();

end



function TreasureSkillPanelCompoment:updateUI()
	
end


return TreasureSkillPanelCompoment;
