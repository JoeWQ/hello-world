--guan
--2016.1.15

local GuildChangeIconView = class("GuildChangeIconView", UIBase);

--[[
    self.btn_close,
    self.btn_queding1,
    self.panel_biaozhi.panel_1,
    self.panel_biaozhi.panel_2,
    self.scale9_biaozhidi,
    self.scale9_dikuang,
    self.scroll_list,
    self.txt_xiugaibiaozhi,
]]

function GuildChangeIconView:ctor(winName)
    GuildChangeIconView.super.ctor(self, winName);
end

function GuildChangeIconView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function GuildChangeIconView:registerEvent()
	GuildChangeIconView.super.registerEvent();
    self.btn_queding1:setTap(c_func(self.press_btn_queding1, self));
    self.btn_close:setTap(c_func(self.press_btn_close, self));

    EventControler:addEventListener(GuildEvent.GUILD_MODITY_CONFIG_OK_EVENT,
        self.press_btn_close, self);
end

function GuildChangeIconView:press_btn_queding1()
    local iconId = self._adapter:getSelectIndex();
    
    echo("确定 " .. tostring(iconId));

    EventControler:dispatchEvent(GuildEvent.GUILD_MODITY_CONFIG_EVENT, 
        {configs = {icon = iconId}}); 
end

function GuildChangeIconView:press_btn_close()
    self:startHide();
end


function GuildChangeIconView:updateUI()
	
end

function GuildChangeIconView:initUI()
    self.panel_biaozhi:setVisible(false);

    local data = {3,3,3,33,3,3,3,3,33};
    self._adapter = GridViewAdapter.new(data);
    self._adapter:setUIView(self);

    self.scroll_list:recreateUI(self._adapter);
end


return GuildChangeIconView;














