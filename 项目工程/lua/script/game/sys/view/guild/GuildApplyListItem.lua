--guan
--2016.1.12

local GuildApplyListItem = class("GuildApplyListItem", UIBase);

--[[
    self.btn_jujue1,
    self.btn_tongyi1,
    self.mc_player1,
    self.panel_playkuang1,
    self.scale9_sqditiao,
    self.txt_lv1,
    self.txt_name1,
    self.txt_zhandouli,
    self.txt_zhandouzhi,
]]

function GuildApplyListItem:ctor(winName)
    GuildApplyListItem.super.ctor(self, winName);
end

function GuildApplyListItem:loadUIComplete()
	self:registerEvent();
end 

function GuildApplyListItem:registerEvent()
	GuildApplyListItem.super.registerEvent();
    self.btn_tongyi1:setTap(c_func(self.press_btn_tongyi1, self));
    self.btn_jujue1:setTap(c_func(self.press_btn_jujue1, self));

    EventControler:addEventListener(GuildEvent.GUILD_APPLY_JUDGE_OK_EVENT,
        self.judgeCallBack, self);
    
end

function GuildApplyListItem:press_btn_tongyi1()

end

function GuildApplyListItem:press_btn_jujue1()

end


function GuildApplyListItem:updateUI(index, adapter)
    local itemData = adapter:getDataByIndex(index);
    dump(itemData, "__GuildApplyListItem");
    self._index = index;
    self._adapter = adapter;
	--名字
    self.txt_name1:setString(itemData._id);
    -- self.txt_name1:setString(itemData.name);

    --点击事件
    self.btn_tongyi1:setTouchedFunc(
        c_func(self.btnOkClick, self, index, itemData._id));

    self.btn_jujue1:setTouchedFunc(
        c_func(self.btnNoClick, self, index,  itemData._id));

    return self;
end

function GuildApplyListItem:btnOkClick(index, userId)
    echo("index ok:" .. tostring(index));
    echo("userId ok:" .. tostring(userId));
    --1 是同意
    EventControler:dispatchEvent(GuildEvent.GUILD_APPLY_JUDGE_EVENT, 
        {userId = userId, index = index, isAdpot = 1});
end

function GuildApplyListItem:btnNoClick(index, userId)
    echo("userId no:" .. tostring(userId));
    echo("index no:" .. tostring(index));
    EventControler:dispatchEvent(GuildEvent.GUILD_APPLY_JUDGE_EVENT, 
        {userId = userId, index = index, isAdpot = 0});
end

function GuildApplyListItem:judgeCallBack(data)
    local index = data.params.index;
    if index == self._index then 
        local isAdpot = data.params.isAdpot;
        if isAdpot == 1 then 
            local member = data.params.newMember;

            dump(member, "__member__");
            GuildModel:addMembersInfo(member);

            EventControler:dispatchEvent(GuildEvent.GUILD_MEMBER_CHANGE_EVENT, 
                {});           
        end 
        --删除本条信息
        self._adapter:delItemByIndex(index);
    end 
end

return GuildApplyListItem;







