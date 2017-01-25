FuncItem= FuncItem or {}

local itemData = nil
local itemActionData = nil

--用于显示通用物品详情
FuncItem.ITEM_VIEW_TYPE ={
	SIGN = "SIGN",
	SHOP = "SHOP",
	ONLYDETAIL = "ONLYDETAIL",
}

function FuncItem.init(  )
	itemData = require("items.Item")
	itemActionData = require("items.ItemAction")
end

function FuncItem.getItemData(itemId)
	local item = itemData[tostring(itemId)]
	if item ~= nil then 
		return item
	else
		echo("FuncItem.getItemData item id " .. itemId .. " not found")
	end
    return nil
end

function FuncItem.getItemActionData(itemSubType)
	local curActionData = itemActionData[tostring(itemSubType)]
	if curActionData ~= nil then 
		return curActionData
	else
		echo("FuncItem.getItemActionData itemSubType " .. itemSubType .. " not found")
	end

    return nil
end

function FuncItem.getItemActionValue(itemSubType,keyName)
	local curActionData = FuncItem.getItemActionData(itemSubType)
	if curActionData then
		return curActionData[keyName]
	end
end

function FuncItem.isValid(itemId)
	local ret = true
	if itemId == nil or itemId == "" then
		ret =  false
	else
		local item = FuncItem.getItemData(itemId)
		if item == nil then
			ret =  false
		else
			ret = true
		end
	end

	if not ret then
		echoWarn("itemId=",itemId," is invalid")
	end

	return ret
end

function FuncItem.getItemPropByKey(itemId,key)
	local item = FuncItem.getItemData(itemId)
	if item ~= nil then
		return item[key]
	end
end

function FuncItem.getItemType(itemId)
	local item = FuncItem.getItemData(itemId)
	local itemType = item.type
	if itemType ~= nil then
		return itemType
	else
		echo("FuncItem.getItemType item id " .. itemId .. " not found")
		return nil
	end
end


function FuncItem.getItemSubType(itemId)
	local item = FuncItem.getItemData(itemId)
	local itemType = item.subType
	if itemType ~= nil then
		return itemType
	else
		echo("FuncItem.getItemSubType item id " .. itemId .. " not found")
		return nil
	end
end

-- 获取道具单价
function FuncItem.getItemBuyPrice(itemId)
	local itemData = FuncItem.getItemData(itemId)
	if itemData ~= nil then
		return itemData["buyPrice"]
	else
		echo("FuncItem.getItemBuyPrice item id " .. itemId .. " not found")
		return nil
	end
end

-- 获取道具名称
function FuncItem.getItemName(itemId)
	local itemData = FuncItem.getItemData(itemId)
	if itemData ~= nil then
		return GameConfig.getLanguage( itemData["name"])
	else
		echo("FuncItem.getItemName item id " .. itemId .. " not found")
		return nil
	end
end

--获取道具品质
function FuncItem.getItemQuality( itemId )
	local itemData = FuncItem.getItemData(itemId)
	local quality = numEncrypt:getNum(itemData.quality)
	if quality ==0 then
		echoWarn("这个道具的品质为0,itemId:",itemId)
		quality = 1
	end
	return quality
end

--获取icon
function FuncItem.getIconPathById( itemId )
	local itemData = FuncItem.getItemData(itemId)
	return itemData.icon
end


--获取道具描述
function FuncItem.getItemDescrib( itemId )
	local itemData = FuncItem.getItemData(itemId)
	local tid = itemData.des
	if not tid then
		echoWarn("没有为这个道具配置描述:",itemId)
		return "还没有配置描述" ..tostring(itemId) 
	end
	return  GameConfig.getLanguage(tid) 
end

--分割字符串 : 1,1001,2  类型,id,数量
function FuncItem.getItemInfoFromStr(infoStr)
	local ret = string.split(infoStr, ',')
	return ret[1], ret[2], tonumber(ret[3])
end

--是否可熔炼
function FuncItem.canSmelt(id)
	local id = tostring(id)
	local destroy = FuncItem.getItemPropByKey(id, "isSmelt")
	if destroy ==nil or destroy ~= 1 then
		return false
	end
	local condition = FuncItem.getItemPropByKey(id, "smeltCondition")
	if not condition then return true end
	local conditionOk = UserModel:checkCondition(condition)
	local canSmelt = (conditionOk == nil)
	return canSmelt
end

--获得熔炼单价
function FuncItem.getSmeltPrice(id)
	local id = tostring(id)
	local price = FuncItem.getItemPropByKey(id, "soul")
	return tonumber(price) or 0
end
