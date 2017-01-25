--guan 
--2016.4.27

local NpcContentWidget = class("NpcContentWidget", UIBase);

--[[
    self.panel_npcAndWord.ctn_npc,
    self.panel_npcAndWord.panel_word,
]]

function NpcContentWidget:ctor(winName)
    NpcContentWidget.super.ctor(self, winName);
end

function NpcContentWidget:loadUIComplete()
	self:registerEvent();
end 

function NpcContentWidget:registerEvent()
	NpcContentWidget.super.registerEvent();

end



function NpcContentWidget:updateUI()
	
end


return NpcContentWidget;
