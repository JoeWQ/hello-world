--
-- Author: ZhangYanguang
-- Date: 2015-11-29
-- 背包、背包列表数据类

--背包数据类
local Item = class("Item",BaseModel)
function Item:init( d )
	Item.super.init(self,d)

	--注册函数  keyData
	self._datakeys = {
		id = "1001" , 				--id
		num = numEncrypt:ns0(),		--数量
	}

	self:createKeyFunc()

	self:initStaticProp()
end

function Item:getType()
	return self.type
end

function Item:getSubType()
	return self.subType
end

function Item:getQuality()
	return tonumber(self.quality) or 1
end

-- 初始化静态属性
function Item:initStaticProp()
	local id = self:id()
	id = tostring(id)

	self.type = FuncItem.getItemPropByKey(id,"type")
	self.subType = FuncItem.getItemPropByKey(id,"subType")
	self.quality = FuncItem.getItemPropByKey(id,"quality")
end

--[[
	- 背包列表数据类
]]
local ItemsModel = class("ItemsModel",BaseModel)

function ItemsModel:init(data)
	self.modelName = "items"
    ItemsModel.super.init(self,data)
    self._items = {}

    self.boxType = {
    	TYPE_BOX_NUM_ONE = 1,
    	TYPE_BOX_NUM_TEN = 10,
	}

    -- 背包类型枚举
    self.itemType = {
    	ITEM_TYPE_ALL = 0,         		--所有
    	ITEM_TYPE_BOX = 1,				--宝箱
    	ITEM_TYPE_PIECE = 2,			--碎片
        ITEM_TYPE_MATERIAL = 3,         --材料
	}

	-- 背包子类型枚举
    self.itemSubTypes = {
    	ITEM_SUBTYPE_201 = 201,     	--合成
    	ITEM_SUBTYPE_202 = 202,			--合成或使用,伙伴碎片
    }

    self._datakeys = {
    	items = nil,                	--背包列表
	}
	self:createKeyFunc()

	self:updateData(data,true)

	self:sendRedStatusMsg()
end

--更新数据
function ItemsModel:updateData(data,isInit )
	if not isInit then
		table.deepMerge(self._dada,data)
	end
	
	for k,v in pairs(data) do
		if FuncItem.isValid(k) then
			if self._items[k] == nil then
				self._items[k] = Item.new()
				self._items[k]:init(v)
			else
				self._items[k]:updateData(v)
			end
		end
	end

	if not isInit then
		EventControler:dispatchEvent(ItemEvent.ITEMEVENT_ITEM_CHANGE,data);
	end

	self:sendRedStatusMsg()
end

-- 发送小红点状态消息
function ItemsModel:sendRedStatusMsg() 
	-- 是否有可以使用的宝箱
	if ItemsModel:hasCanUseBox() then
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            {redPointType = HomeModel.REDPOINT.DOWNBTN.BAG, isShow = true});
	else
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            {redPointType = HomeModel.REDPOINT.DOWNBTN.BAG, isShow = false});
	end
end

--删除数据
function ItemsModel:deleteData(data) 
	--深度删除 key
	for k,v in pairs(data) do
		if self._items[k] then
			self._items[k] = nil;
		end
	end

	table.deepDelKey(self._data, data, 1)

	EventControler:dispatchEvent(ItemEvent.ITEMEVENT_ITEM_CHANGE, data);

	self:sendRedStatusMsg()
end

-- 通过ID获取item
function ItemsModel:getItemById(itemId)
	for k, v in pairs(self._items) do
		if tostring(k) == tostring(itemId) then
			return v
		end
	end

	return nil
end

-- 通过ID获取item的数量
function ItemsModel:getItemNumById(itemId)
	local item = self:getItemById(itemId)
	if item ~= nil then
		return item:num()
	end

	return 0
end

-- 背包是否是空的，一个道具都没有
function ItemsModel:isBagEmpty()
	local data = {};
	for k, v in pairs(self._items) do
		return false
	end

	return true
end

-- 获取道具种类的总数量
function ItemsModel:getItemTotalTypeNum()
	local totalNum = 0
	for k, v in pairs(self._items) do
		totalNum = totalNum + 1
	end

	return totalNum
end

-- 获取所有道具
function ItemsModel:getAllItems()
	local data = {};
	for k, v in pairs(self._items) do
		table.insert(data, v);
	end

	self:sortItems(data)
	return data;
end

-- 通过类型获取道具
function ItemsModel:getItemsByType(itemType)
	local data = {};
	for k, v in pairs(self._items) do
		local itype = FuncItem.getItemPropByKey(k,"type")
		if tostring(itype) == tostring(itemType) then
			table.insert(data, v);
		end
	end

	self:sortItems(data)

	return data;
end

function ItemsModel:getAllItemSubTypes()
	return self.itemSubTypes
end

-- 通过子类型获取背包中的物品
function ItemsModel:getItemsBySubType(itemSubtype)
	local ret = {}
	for k, v in pairs(self._items) do
		local itype = FuncItem.getItemPropByKey(k, "subType")
		if tostring(itype) == tostring(itemSubtype) then
			table.insert(ret, v)
		end
	end
	self:sortItems(ret)
	return ret
end

-- 道具排序
function ItemsModel:sortItems(data)
	table.sort(data,function(a,b)
		local aQuality = a:getQuality()
		local aType = a:getType()
		local aSubType = a:getSubType()
		local aId = a:id()

		local bQuality = b:getQuality()
		local bType = b:getType()
		local bSubType = b:getSubType()
		local bId = b:id()
		
		-- 先按照类型排序
		if aType < bType then
			return true
		elseif aType == bType then
			if aQuality > bQuality then
				return true
			elseif aQuality == bQuality then
				if aType > bType then
					return true
				elseif aType == bType then
					if aSubType > bSubType then
						return true
					elseif aSubType == bSubType then
						if aId > bId then
							return true
						end
					else 
						return false
					end
				end
			end
		end
		
		return false
    end)
end

-- 根据Id判断道具是否是宝箱
function ItemsModel:isBox(itemId)
	local itemData = FuncItem.getItemData(itemId)
	if tonumber(itemData.type) == self.itemType.ITEM_TYPE_BOX then
		return true
	end
	return false
end

-- 是否有可以使用的宝箱
function ItemsModel:hasCanUseBox()
	local itemTypeBox = self.itemType.ITEM_TYPE_BOX
	for k, v in pairs(self._items) do
		local itemId = k
		local itype = FuncItem.getItemPropByKey(k,"type")
		if tostring(itype) == tostring(itemTypeBox) then
			return true
		end
	end

	return false
end

-- 检查道具是否满足使用条件
function ItemsModel:checkItemUseCondition(itemId,itemNum)
	local canUse = false
	local itemTypeBox = self.itemType.ITEM_TYPE_BOX

	if itemNum == nil then
		itemNum = 1
	end

	local itype = FuncItem.getItemPropByKey(itemId,"type")

	-- 宝箱都为可用
	if tostring(itype) == tostring(itemTypeBox) then
		canUse = true

		local ownItemNum = self:getItemNumById(itemId)
		if ownItemNum < itemNum then
			canUse = false
		end
	end

	return canUse
end

-- 检查打开宝箱条件是否满足
function ItemsModel:checkUseBoxCondition(itemId,itemNum)
	if itemNum == nil then
		itemNum = 1
	end

	local itemData = FuncItem.getItemData(itemId)
	local canUse = itemData.use

	if canUse ~= nil and tonumber(canUse) == 1 then
		if itemData.useCondition ~= nil then
			local itemCondition = itemData.useCondition[1]
			if itemCondition ~= nil then
				local needItemCond = string.split(itemCondition,",")
				local needItemId = needItemCond[1]
				local needItemNum = needItemCond[2]
				local needItemTotalNum = needItemNum * itemNum
				if self:getItemNumById(needItemId) >= needItemTotalNum then
					return true,needItemId
				else
					return false,needItemId
				end
			end
		end
	end
	return false,nil
end

-- 获取道具使用效果
function ItemsModel:getItemUseEffect(itemId)
	local itemData = FuncItem.getItemData(itemId)
	local useEffect = itemData.useEffect
	if useEffect ~= nil then
		return useEffect[1]
	end
	return nil
end

-- 获取道具数量上限
function ItemsModel:getItemSuperLimit(itemId)
	local limitNum = FuncItem.getItemPropByKey(itemId,"Superposition") 
	return limitNum
end

-- 格式化item数量
function ItemsModel:getFormatItemNum(itemId)
	local itemNum = self:getItemNumById(itemId)
	local itemLimitNum = FuncItem.getItemPropByKey(itemId,"Superposition") 
	if itemNum > itemLimitNum then
        itemNum = itemLimitNum 
    end

	return itemNum
end

-- 获取途径数据排序
function ItemsModel:sortGetWayListData(getWayListData)
	if getWayListData == nil or #getWayListData == 0 then
		return
	end
	
	-- 获取途径id降序排
    table.sort(getWayListData, function(getWayId_1,getWayId_2)
        local getWayData_1 = FuncCommon.getGetWayDataById(getWayId_1)
        local getWayData_2 = FuncCommon.getGetWayDataById(getWayId_2)

        local open_1 = 0
        local open_2 = 0

        if FuncCommon.isSystemOpen(getWayData_1.index,getWayData_1.condition) then
            open_1 = 1
        end

        if FuncCommon.isSystemOpen(getWayData_2.index,getWayData_2.condition) then
            open_2 = 1
        end

        if open_1 > open_2 then
            return true
        elseif open_1 == open_2 then
            if getWayId_1 < getWayId_2 then
                return true
            else
                return false
            end
        end
    end )
end

--是不是法宝碎片
function ItemsModel:isTreasurePiece(resType, itemId)
	if tostring(resType) == UserModel.RES_TYPE.ITEM then 
		local itemType = FuncItem.getItemType(itemId);
		local subType = FuncItem.getItemSubType(itemId);
		if itemType == self.itemType.ITEM_TYPE_PIECE and 
				subType == self.itemSubTypes.ITEM_SUBTYPE_201 then 
			return true;
		else 
			return false;
		end 
	else 
		return false
	end 
end

--是不是伙伴碎片
function ItemsModel:isPartnerPiece(resType, itemId)
	if tostring(resType) == UserModel.RES_TYPE.ITEM then 
		local itemType = FuncItem.getItemType(itemId);
		local subType = FuncItem.getItemSubType(itemId);
		if itemType == self.itemType.ITEM_TYPE_PIECE and 
				subType == self.itemSubTypes.ITEM_SUBTYPE_202 then 
			return true;
		else 
			return false;
		end 
	else 
		return false
	end 	
end

return ItemsModel











