--guan
--2016.1.7
--创建公会界面

local GuildCreateView = class("GuildCreateView", UIBase);

--[[
    self.UI_chuangjian,
    self.btn_cj1,
    self.btn_close,
    self.input_shurumingzi,
    self.panel_biaozhi.panel_1,
    self.panel_biaozhi.panel_2,
    self.scale9_kuang1,
    self.scroll_list,
    self.txt_biaozhi,
    self.txt_mingzi,
    self.txt_xiaohao,
    self.txt_yongyou,
    self.txt_yongyouzhi,
]]

function GuildCreateView:ctor(winName)
    GuildCreateView.super.ctor(self, winName);
end

function GuildCreateView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function GuildCreateView:registerEvent()
	GuildCreateView.super.registerEvent();
    self.btn_close:setTap(c_func(self.press_btn_close, self));
    self.btn_cj1:setTap(c_func(self.press_btn_cj1, self));

    EventControler:addEventListener(GuildEvent.CREATE_GUILD_OK_EVENT,
        self.createGuildOk, self);
end

function GuildCreateView:initUI()
    --初始化滚动条
    self:initScrollUI();
    --隐藏个没用的
    self.panel_biaozhi:setVisible(false);
    --有的仙玉数
    local goldNum = UserModel:getGold();
    echo("goldNum:" .. tostring(goldNum));
    self.txt_yongyouzhi:setString(goldNum);
end

function GuildCreateView:initScrollUI()
    --临时
    local data = {"a", "b", "c", "d"};
    --创建adapter
    local adapter = GridViewAdapter.new(data);
    adapter:setUIView(self);

    self.scroll_list:recreateUI(adapter); 
end

function GuildCreateView:press_btn_close()
    self:startHide();
end

function GuildCreateView:press_btn_cj1()
    echo("press_btn_cj1");
    local guildName = self.input_shurumingzi:getText();
    echo("guildName:" .. tostring(guildName))
    local data = {["name"] = guildName, ["icon"] = 1};
    EventControler:dispatchEvent(GuildEvent.CREATE_GUILD_EVENT, 
        {param = data});
end

function GuildCreateView:createGuildOk(data)
    echo("createGuildOk");
    self:startHide();
    local inviters = data.params.inviters;

    -- WindowControler:showWindow("GuildHomeView");
    EventControler:dispatchEvent(GuildEvent.GUILD_GET_MEMBERS_EVENT, 
        {}); 

    WindowControler:globalDelayCall(function ( ... )
        WindowControler:showWindow("GuildInviteView", inviters)
    end);
end

function GuildCreateView:updateUI()
	
end

return GuildCreateView;







