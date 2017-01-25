--
-- Author: xd
-- Date: 2016-02-11 18:44:41
--动态背景框2 
local DynamicBgView2 = class("DynamicBgView2", BackGroundBase);

--[[
    self.panel_1,
    self.panel_2,
    self.scale9_1,
    self.scale9_2,
]]

function DynamicBgView2:ctor(winName)
    DynamicBgView2.super.ctor(self, winName);
end

function DynamicBgView2:loadUIComplete()
	DynamicBgView2.super.loadUIComplete(self)
	self:registerEvent();
end 

function DynamicBgView2:registerEvent()
	DynamicBgView2.super.registerEvent();

end





function DynamicBgView2:updateUI()
	
end


return DynamicBgView2;
