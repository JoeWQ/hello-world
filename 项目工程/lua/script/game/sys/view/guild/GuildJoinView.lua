--guan
--2015.1.9

local GuildJoinView = class("GuildJoinView", UIBase);

--[[
    self.UI_jiaru,
    self.btn_close,
    self.mc_addzhongbu1,
    self.panel_waiwei1,
    self.panel_waiwei1.btn_chazhao1,
    self.panel_waiwei1.input_sousuoid,
    self.panel_waiwei1.mc_gouxuan1,
    self.panel_waiwei1.mc_qiehuanxianshi,
    self.panel_waiwei1.scale9_chazhaokuang,
]]

function GuildJoinView:ctor(winName, guilds)
    GuildJoinView.super.ctor(self, winName);
    self._guilds = guilds;
    -- dump(guilds, "guilds");
end

function GuildJoinView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function GuildJoinView:registerEvent()
    GuildJoinView.super.registerEvent();
    self.panel_waiwei1.btn_chazhao1:setTap(c_func(self.press_panel_waiwei1_btn_chazhao1, self));
    self.btn_close:setTap(c_func(self.press_btn_close, self));

    --bug why ??
    -- EventControler:addEventListener(GuildEvent.CLOSE_GUILD_JOIN_VIEW_EVENT,
    --     self.press_btn_close, self);

    EventControler:addEventListener(GuildEvent.CLOSE_GUILD_JOIN_VIEW_EVENT,
        self.closeDelay, self);

    EventControler:addEventListener(GuildEvent.LIST_GUILD_OK_EVENT,
        self.listGuildCallback, self, 1);

    EventControler:addEventListener(GuildEvent.FIND_GUILD_OK_EVENT,
        self.findGuildCallback, self, 1);

end

function GuildJoinView:initUI()
    self:initSelectUI();
    self:initMiddleUI();
end 

function GuildJoinView:initMiddleUI()
    --没有科加入的仙盟
    if table.length(self._guilds) == 0 then 
        self:showNoJoinableGuildUI();
    else 
        self:showList(self._guilds);
    end 
end

function GuildJoinView:isShowAllNow()
    return self.panel_waiwei1.mc_gouxuan1.currentFrame == 2 and true or false;
end

function GuildJoinView:showNoJoinableGuildUI()
    self.mc_addzhongbu1:showFrame(4);
    local btn = self.mc_addzhongbu1.currentView.panel_add41.btn_quchuangjian2;

    btn:setTouchedFunc(
        c_func(function ()
            echo("创建");
            self:startHide();
            WindowControler:showWindow("GuildCreateView");
            EventControler:dispatchEvent(GuildEvent.CLOSE_GUILD_BLANK_VIEW_EVENT, {});
        end)
    );
end

function GuildJoinView:showEmptyGUildsUI()
    self.mc_addzhongbu1:showFrame(3);
    local btn = self.mc_addzhongbu1.currentView.panel_add31.btn_quchuangjian1;
    btn:setTouchedFunc(
        c_func(function ()
            echo("创建");
            self:startHide();
            WindowControler:showWindow("GuildCreateView");
            EventControler:dispatchEvent(GuildEvent.CLOSE_GUILD_BLANK_VIEW_EVENT, {});
        end)
    );
end

function GuildJoinView:listGuildCallback(data)
    local guilds = data.params.guilds;
    if table.length(guilds) ~= 0 then 
        self:showList(guilds);
    else 
        if self:isShowAllNow() == false then 
            self:showNoJoinableGuildUI();
        else 
            self:showEmptyGUildsUI();
        end 
    end 
end

function GuildJoinView:findGuildCallback(data)
   local guild = data.params.guildEntity;
   dump(guild, "__findGuildCallback__");
   if table.length(guild) == 0 then 
        WindowControler:showTips({text = "没有找到该公会"});
   else
        self:showFindGuildUI(guild);
   end
end

function GuildJoinView:showFindGuildUI(guild)
    self.mc_addzhongbu1:showFrame(2);

    --初始化这个列表
    local btn = self.mc_addzhongbu1.currentView.panel_add21.btn_chakanqita1;
 
     btn:setTouchedFunc(
        c_func(function ()
            echo("返回");
            self.mc_addzhongbu1:showFrame(1);
        end)
    );   

    local listPanel = self.mc_addzhongbu1.currentView.panel_add21.panel_add2;

    listPanel.txt_name:setString(guild._id);

    if GuildModel:isAppliedTheGuild(guild._id) == true then 
        listPanel.mc_jiaru1:showFrame(3);
    elseif guild.members == 50 then
        -- 满了 
        listPanel.mc_jiaru1:showFrame(4);
    elseif guild.needApply == 0 then 
        listPanel.mc_jiaru1:showFrame(1);
    else  
        listPanel.mc_jiaru1:showFrame(2);
    end 

    listPanel.mc_jiaru1.currentView:setTouchedFunc(
        c_func(self.joinBtnClick, self, guild));
end

function GuildJoinView:joinBtnClick(guild)
    echo("joinBtnClick");

end

--显示公会列表
function GuildJoinView:showList(guildList)
    self.mc_addzhongbu1:showFrame(1);

    -- local data = {3, 3, 3, 3};
    local data = guildList;

    --排列，已申请的在前面
    data = self:sortData(data);

    local adapter = GridViewAdapter.new(data);
    adapter:setUIView(self);

    self.mc_addzhongbu1.currentView.scroll_list:recreateUI(adapter);
end

function GuildJoinView:sortData(data)
    local applyData = {};

    for k, v in pairs(data) do
        if GuildModel:isAppliedTheGuild(v._id) == true then 
            table.insert(applyData, v);
        end 
    end

    for k,v in pairs(data) do
        if GuildModel:isAppliedTheGuild(v._id) ~= true then 
            table.insert(applyData, v);
        end 
    end

    return applyData;
end

function GuildJoinView:setSelectUIAllorJoinable(isShowAll)
    if isShowAll == true then 
        self.panel_waiwei1.mc_gouxuan1:showFrame(2);
    else 
        self.panel_waiwei1.mc_gouxuan1:showFrame(1);
    end
end

function GuildJoinView:initSelectUI()
    --注册点击事件
    self.panel_waiwei1.mc_gouxuan1:showFrame(1);

    self.panel_waiwei1.mc_gouxuan1.currentView:setTouchedFunc(
        c_func(GuildJoinView.showAllList, self));

    self.panel_waiwei1.mc_gouxuan1:showFrame(2);

    self.panel_waiwei1.mc_gouxuan1.currentView:setTouchedFunc(
        c_func(GuildJoinView.showJonableList, self));

    self.panel_waiwei1.mc_gouxuan1:showFrame(1);

    self:setSelectUIAllorJoinable(false);
end

function GuildJoinView:showJonableList()
    echo("showJonableList");
    self:setSelectUIAllorJoinable(false);
    --发消息
    EventControler:dispatchEvent(GuildEvent.LIST_GUILD_EVENT, 
        {isAll = 0, page = 1});
end

function GuildJoinView:showAllList()
    echo("showAllList");
    self:setSelectUIAllorJoinable(true);
    --发消息
    EventControler:dispatchEvent(GuildEvent.LIST_GUILD_EVENT, 
        {isAll = 1, page = 1});
end

function GuildJoinView:press_panel_waiwei1_btn_chazhao1()
    echo("查找");
    local guildId = self.panel_waiwei1.input_sousuoid:getText();
    echo("输入的是:" .. guildId);

    EventControler:dispatchEvent(GuildEvent.FIND_GUILD_EVENT, 
        {guildId = guildId});
end

function GuildJoinView:press_btn_close()
    echo("press_btn_close");
    self:startHide();
end

function GuildJoinView:closeDelay()
    echo("closeDelay");
    
    self:delayCall( c_func(self.press_btn_close, self));
end

function GuildJoinView:updateUI()
	
end

return GuildJoinView;









