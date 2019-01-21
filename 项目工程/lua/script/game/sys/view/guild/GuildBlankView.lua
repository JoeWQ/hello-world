--guan
--2016.1.7

local GuildBlankView = class("GuildBlankView", UIBase);

--[[
    self.UI_xianmeng,
    self.btn_chuangjian1,
    self.btn_close,
    self.btn_jiaru1,
]]

function GuildBlankView:ctor(winName)
    GuildBlankView.super.ctor(self, winName);
end

function GuildBlankView:loadUIComplete()
	self:registerEvent();
end 

function GuildBlankView:registerEvent()
	GuildBlankView.super.registerEvent();
    self.btn_chuangjian1:setTap(c_func(self.press_btn_chuangjian1, self));
    self.btn_jiaru1:setTap(c_func(self.press_btn_jiaru1, self));
    self.btn_close:setTap(c_func(self.press_btn_close, self));

    EventControler:addEventListener(GuildEvent.CREATE_GUILD_OK_EVENT,
        self.createGuildOk, self);

    EventControler:addEventListener(GuildEvent.LIST_GUILD_OK_EVENT,
        self.listGuildOk, self);

    EventControler:addEventListener(GuildEvent.CLOSE_GUILD_BLANK_VIEW_EVENT,
        self.press_btn_close, self);
end

function GuildBlankView:listGuildOk(data)
    echo("listGuildOk");
    local guilds = data.params.guilds;
    WindowControler:showWindow("GuildJoinView", guilds);
end

function GuildBlankView:press_btn_chuangjian1()
    --打开创建公会界面
    echo("press_btn_chuangjian1");
    WindowControler:showWindow("GuildCreateView");
end

function GuildBlankView:createGuildOk()
    self:startHide();
end

function GuildBlankView:press_btn_jiaru1()
    --申请加入公会
    echo("press_btn_jiaru1");
    -- WindowControler:showWindow("GuildJoinView");
    EventControler:dispatchEvent(GuildEvent.LIST_GUILD_EVENT, 
        {isAll = 0, page = 1});
end

function GuildBlankView:press_btn_close()
    self:startHide();
    
end


function GuildBlankView:updateUI()
	
end


return GuildBlankView;
