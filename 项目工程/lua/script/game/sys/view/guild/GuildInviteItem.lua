--guan 
--2016.1.15

local GuildInviteItem = class("GuildInviteItem", UIBase);

--[[
    self.btn_yaoqing1,
    self.panel_playerkuang2.mc_palyer1,
    self.panel_playerkuang2.panel_kuang1,
    self.scale9_tiaodi1,
    self.txt_lv,
    self.txt_palyername,
    self.txt_zhandouli,
    self.txt_zhandouzhi,
]]

function GuildInviteItem:ctor(winName)
    GuildInviteItem.super.ctor(self, winName);
end

function GuildInviteItem:loadUIComplete()
	self:registerEvent();
end 

function GuildInviteItem:registerEvent()
	GuildInviteItem.super.registerEvent();
end

function GuildInviteItem:updateUI(index, adapter)
    local data = adapter:getDataByIndex(index);

    self._index = index;
    self._adapter = adapter;
	
    self.txt_palyername:setString(data._id);

    self.btn_yaoqing1:setTap(c_func(self.inviteBtnClick, self, data._id));

    return self;
end

function GuildInviteItem:inviteBtnClick(id)
    echo("inviteBtnClick:" .. tostring(id));

    self._adapter:delItemByIndex(self._index);

    EventControler:dispatchEvent(GuildEvent.GUILD_invite_EVENT, 
        {id = id});

end


return GuildInviteItem;












