--
-- Author: ZhangYanguang
-- Date: 2015-12-08
--
--道具模块，网络服务类
local ItemServer = class("ItemServer")

-- 使用道具
function ItemServer:customItems(itemId,itemNum,callBack)
	echo("···ItemServer:customItems")
	local params = {
		itemId = itemId,
		num = itemNum
	}
	Server:sendRequest(params,MethodCode.item_customItem_801, callBack ,false,false,true)
end

-- 购买钥匙
function ItemServer:buyKeys(itemId,itemNum,callBack)
	local params = {
		itemId = itemId,
		num = itemNum
	}
	Server:sendRequest(params,MethodCode.item_buyKey_803, callBack)
end

return ItemServer