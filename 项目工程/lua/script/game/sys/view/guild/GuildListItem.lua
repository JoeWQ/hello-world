--guan
--2016.1.9

--加入仙盟的那个表

local GuildListItem = class("GuildListItem", UIBase);

--[[
    self.UI_addItem,
    self.panel_kuang1.panel_1,
    self.panel_kuang1.panel_2,
    self.scale9_addditiao,
    self.txt_lv,
    self.txt_name,
    self.txt_number,
    self.txt_xuanyan,
]]

function GuildListItem:ctor(winName)
    GuildListItem.super.ctor(self, winName);
end

function GuildListItem:loadUIComplete()
	self:registerEvent();
end 

function GuildListItem:registerEvent()
	GuildListItem.super.registerEvent();

    EventControler:addEventListener(GuildEvent.GUILD_APPLY_OK_EVENT,
        self.joinGuildOkCallBack, self);

    EventControler:addEventListener(GuildEvent.GUILD_CANCEL_APPLY_OK_EVENT,
        self.cancleApplyOkCallBack, self);  
end

function GuildListItem:updateUI(index, adapter)
    local itemData = adapter:getDataByIndex(index);
    -- dump(itemData, "__itemData__");
    self._index = index;
    self._adapter = adapter;

    --已经申请
    if GuildModel:isAppliedTheGuild(itemData._id) == true then 
        self.mc_jiaru1:showFrame(3);
    elseif itemData.members == 50 then
        -- 满了 
        self.mc_jiaru1:showFrame(4);
    elseif itemData.needApply == 0 then 
        self.mc_jiaru1:showFrame(1);
    else  
        self.mc_jiaru1:showFrame(2);
    end 

    self.mc_jiaru1.currentView:setTouchedFunc(
        c_func(self.btnClick, self, index, adapter));

    self:initInfo(itemData);

    return self;
end

function GuildListItem:initInfo(itemData)
    echo("initInfo");
    --名字
    self.txt_name:setString(itemData.name);
    -- 等级
    self.txt_lv:setString( GameConfig.getLanguageWithSwap("tid_common_2015",tostring(itemData.level))  );
    -- 宣言
    self.txt_xuanyan:setString(itemData.desc or "没有宣言");
    --人数 
    self.txt_number:setString(tostring(itemData.members) .. "/20");
end

function GuildListItem:btnClick(index, adapter)
    if self:checkCanClick() then
        local data = adapter:getDataByIndex(index);

        echo("点击");
        dump(data, "btnClick");

        if GuildModel:isAppliedTheGuild(data._id) == true then 
            --取消申请
            EventControler:dispatchEvent(GuildEvent.GUILD_CANCEL_APPLY_EVENT, 
                {guildId = data._id, index = index});
        elseif data.members == 50 then
            -- 满了 
            self.mc_jiaru1:showFrame(4);
        elseif data.needApply == 0 then 
            self.mc_jiaru1:showFrame(1);
            
            EventControler:dispatchEvent(GuildEvent.GUILD_APPLY_EVENT, 
                {guildId = data._id, index = index, isNeedApply = data.needApply});
        else  
            self.mc_jiaru1:showFrame(2);
            EventControler:dispatchEvent(GuildEvent.GUILD_APPLY_EVENT, 
                {guildId = data._id, index = index, isNeedApply = data.needApply});
        end 

    end    
end

function GuildListItem:cancleApplyOkCallBack(data)
    local index = data.params.index;
    if index == self._index then
        echo("cancleApplyOkCallBack");

        dump(UserModel:guildExt().applys, "___"); 
        
        self:updateUI(self._index, self._adapter); 
    end  
end

function GuildListItem:joinGuildOkCallBack(data)
    local index = data.params.index;
    dump(data.params, "__joinGuildOkCallBack__");
    if index == self._index then 
        if data.params.isNeedApply == 0 then 
            echo("joinGuildOkCallBack isNeedApply 0")
            EventControler:dispatchEvent(GuildEvent.CLOSE_GUILD_JOIN_VIEW_EVENT, {});
            EventControler:dispatchEvent(GuildEvent.CLOSE_GUILD_BLANK_VIEW_EVENT, {});

            EventControler:dispatchEvent(GuildEvent.GUILD_GET_MEMBERS_EVENT, 
                {});  
        else 
            echo("joinGuildOkCallBack isNeedApply 1")
            self:updateUI(self._index, self._adapter); 
        end 
    end 
end

return GuildListItem;















