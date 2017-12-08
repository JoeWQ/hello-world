local GridItem = class("GridItem", UIBase);

--[[
    self.ctn_daoju,
    self.mc_daojukuang,
    self.UI_itemTest,
    self.txt_daojushuliang,
    self.panel_hongdian,
]]

function GridItem:ctor(winName)
	-- echo(" GridItem:ctor")
    GridItem.super.ctor(self, winName);
end

function GridItem:loadUIComplete()
	self:registerEvent();
end 

function GridItem:registerEvent()

end

function GridItem:updateUI(index, adapter)

	local itemData = adapter:getDataByIndex(index);
	--点击事件
	local func = function (itemNode, index)
		-- echo("func");
		if itemNode:checkCanClick() then
			local txt = adapter:getDataByIndex(index);
			echo("删除" .. tostring(index) .. ":" .. txt);
			adapter:delItemByIndex(index);
		end 
	end

	-- echo("updateUI:" .. tostring(index))

    self:getChildByName("txt_daojushuliang"):setString(itemData);
    self:setTouchedFunc(c_func(func, self, index));

    return self;
end

return GridItem;






