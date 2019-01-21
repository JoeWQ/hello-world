local TreasureItem = class("TreasureItem", UIBase);

--[[
    self.UI_fb1,
    self.UI_treasure_tiao,
    self.mc_btn,
    self.mc_tiao,
    self.mc_xing,
    self.panel_red,
    self.panel_shentong1,
    self.panel_shentong1.ctn_sticon,
    self.panel_shentong1.panel_lvjiantou,
    self.panel_shentong2,
    self.panel_shentong2.ctn_sticon,
    self.panel_shentong2.panel_lvjiantou,
    self.panel_shentong3,
    self.panel_shentong3.ctn_sticon,
    self.panel_shentong3.panel_lvjiantou,
    self.panel_shentong4,
    self.panel_shentong4.ctn_sticon,
    self.panel_shentong4.panel_lvjiantou,
    self.panel_shentong5,
    self.panel_shentong5.ctn_sticon,
    self.panel_shentong5.panel_lvjiantou,
    self.panel_shentong6,
    self.panel_shentong6.ctn_sticon,
    self.panel_shentong6.panel_lvjiantou,
    self.scale9_1,
    self.txt_1,
    self.txt_2,
]]

function TreasureItem:ctor(winName)
    TreasureItem.super.ctor(self, winName);
end

function TreasureItem:loadUIComplete()
	self:registerEvent();
end 

function TreasureItem:registerEvent()
	TreasureItem.super.registerEvent();

end



function TreasureItem:updateUI()
	
end


return TreasureItem;
