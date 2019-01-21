--guan
--2015.1.7

local GuildInviteView = class("GuildInviteView", UIBase);

--[[
    self.UI_chenggong,
    self.btn_close,
    self.panel_yaoqingtiao1.btn_yaoqing1,
    self.panel_yaoqingtiao1.panel_playerkuang2,
    self.panel_yaoqingtiao1.scale9_tiaodi1,
    self.panel_yaoqingtiao1.txt_lv,
    self.panel_yaoqingtiao1.txt_palyername,
    self.panel_yaoqingtiao1.txt_zhandouli,
    self.panel_yaoqingtiao1.txt_zhandouzhi,
    self.scale9_cgdi1,
    self.scroll_list,
    self.txt_guanggao,
]]

function GuildInviteView:ctor(winName, inviters)
    GuildInviteView.super.ctor(self, winName);
    self._inviters = inviters;
    dump(inviters, "inviters");
end

function GuildInviteView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function GuildInviteView:registerEvent()
	GuildInviteView.super.registerEvent();
    self.btn_close:setTap(c_func(self.press_btn_close, self));
end

function GuildInviteView:initUI()
    self.panel_yaoqingtiao1:setVisible(false);

    local adapter = GridViewAdapter.new(self._inviters);
    adapter:setUIView(self);

    self.scroll_list:recreateUI(adapter);
end

function GuildInviteView:press_btn_close()
    self:startHide();
end


function GuildInviteView:updateUI()
	
end


return GuildInviteView;
