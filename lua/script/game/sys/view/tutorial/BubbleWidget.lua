--guan
--2016.5.25

local BubbleWidget = class("BubbleWidget", UIBase);

--[[
    self.mc_bubble,
    self.txt_1,
]]

function BubbleWidget:ctor(winName)
    BubbleWidget.super.ctor(self, winName);
end

function BubbleWidget:loadUIComplete()
	self:registerEvent();
end 

function BubbleWidget:registerEvent()
	BubbleWidget.super.registerEvent();

end



function BubbleWidget:updateUI()
	
end


return BubbleWidget;
