local SmeltServer = class("SmeltServer")

function SmeltServer:buyGoods(goodsId, callBack)
	local params = {id = goodsId}
	Server:sendRequest(params, MethodCode.smelt_shop_buy_item_2307, callBack)
end

--熔炼物品
--item是 {id=num, id=num} map
function SmeltServer:smeltItems(items, callBack)
	local params = {items = items}
	Server:sendRequest(params, MethodCode.smelt_smelt_items_2301, callBack)
end

function SmeltServer:flushShop(callBack)
	Server:sendRequest({}, MethodCode.smelt_flush_shop_info_2305, callBack)
end

--奇宝阁兑换物品
function SmeltServer:exchangeByTitle(id, callBack)
	local params = {id = id}
	Server:sendRequest(params, MethodCode.smelt_exchange_items_2303, callBack)
end

return SmeltServer
