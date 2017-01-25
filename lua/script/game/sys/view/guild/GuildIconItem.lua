--guan
--2016.1.16

local GuildIconItem = class("GuildIconItem", UIBase);

--[[
    self.panel_1,
    self.panel_2,
]]

function GuildIconItem:ctor(winName)
    GuildIconItem.super.ctor(self, winName);
end

function GuildIconItem:loadUIComplete()
	self:registerEvent();
end 

function GuildIconItem:registerEvent()
	GuildIconItem.super.registerEvent();

end

function GuildIconItem:updateUI(index, adapter)
	--点击事件
    self:setTouchedFunc(c_func(GuildIconItem.setSelect, self));
    self._index = index;
    self._adapter = adapter;

	return self;
end

function GuildIconItem:setSelect()
	echo("setSelect " .. tostring(self._index));
	self._adapter:setSelectIndex(self._index);
end


return GuildIconItem;
