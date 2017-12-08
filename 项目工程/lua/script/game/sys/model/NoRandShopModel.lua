local NoRandShopModel = class("NoRandShopModel", BaseModel)
local NO_RAND_SHOP_TIME_EVENTS = {
	[FuncShop.SHOP_TYPES.PVP_SHOP] = TimeEvent.TIMEEVENT_PVP_SHOP_REFRESH_CD,
	[FuncShop.SHOP_TYPES.CHAR_SHOP] = TimeEvent.TIMEEVENT_CHAR_SHOP_REFRESH_CD,
}

--目前pvp和侠义商店都是这种
function NoRandShopModel:init(d)
	NoRandShopModel.super.init(self, d)
	self:registerEvent()
	self:startShopRefreshCd()
end

function NoRandShopModel:registerEvent()
	for shopId, event in pairs(NO_RAND_SHOP_TIME_EVENTS) do
		EventControler:addEventListener(event, self.onShopCd, self)
	end
end

function NoRandShopModel:onShopCd(event)
	local shopId
	if event.name == TimeEvent.TIMEEVENT_PVP_SHOP_REFRESH_CD then
		shopId = FuncShop.SHOP_TYPES.PVP_SHOP
	elseif event.name == TimeEvent.TIMEEVENT_CHAR_SHOP_REFRESH_CD then
		shopId = FuncShop.SHOP_TYPES.CHAR_SHOP
	end
	if shopId then
		self:clearBuyedGoods(shopId)
		EventControler:dispatchEvent(ShopEvent.SHOPEVENT_NORAND_SHOP_REFRESHED)
		WindowControler:globalDelayCall( c_func(self.startShopRefreshCd, self, shopId),1)
	end
end

function NoRandShopModel:clearBuyedGoods(shopId)
	local data = self:getShopData(shopId)
	data.buyGoodsTimes = {}
end

function NoRandShopModel:startShopRefreshCd(targetShopId)
	local ids = FuncShop.NO_RAND_SHOP_IDS
	if targetShopId then
		ids = {targetShopId}
	end
	local now = TimeControler:getServerTime()
	for _, shopId in pairs(ids) do
		local r_time = FuncShop.getNoRandShopRefreshTime(shopId)
		local left = r_time - now
		local event = NO_RAND_SHOP_TIME_EVENTS[shopId]
		if event then
			TimeControler:startOneCd(event, left)
		end
	end
end

function NoRandShopModel:updateData(d)
	NoRandShopModel.super.updateData(self, d)
end

function NoRandShopModel:getShopData(shopId)
	return self._data[shopId] or {}
end

function NoRandShopModel:getShopLastFlushTime(shopId)
	local data = self:getShopData(shopId)
	return data.lastFlushTime or 0
end

function NoRandShopModel:getBuyGoodsTimes(shopId)
	local data = self:getShopData(shopId)
	return data.buyGoodsTimes or {}
end

function NoRandShopModel:getShopGoodsInfo(shopId)
	local lastFlushTime = self:getShopLastFlushTime(shopId)
	local buyGoodsTimes = self:getBuyGoodsTimes(shopId)

	local auto_refresh_t, isToday = FuncShop.getNoRandShopRefreshTime(shopId, true)
	local now = TimeControler:getServerTime()
	--如果当前时间大于当天约定的刷新时间，并且上一次刷新时间在约定刷新时间之前,客户端
	--清空已买列表
	local todayInfo = os.date("*t", now)
	local lastFlushDayInfo = os.date("*t", lastFlushTime)
	if lastFlushTime == 0 then
		if  now >= auto_refresh_t then
			buyGoodsTimes = {}
		end
	else
		--不是一天
		if todayInfo.yday > lastFlushDayInfo.yday then
			buyGoodsTimes = {}
		elseif todayInfo.yday == lastFlushDayInfo.yday then
			--同一天
			if  now >= auto_refresh_t and lastFlushTime < auto_refresh_t then
				buyGoodsTimes = {}
			end
		end
	end
	local shopBuyGoodsIds = table.keys(buyGoodsTimes)
	local shopInfo = self:getConfigShopGoods(shopId)
	local ret = {}
	for _, info in ipairs(shopInfo) do
		info.soldOut = nil
		if table.find(shopBuyGoodsIds, tostring(info.id)) then
			info.soldOut = true
		end
		table.insert(ret, info)
	end
	return ret
end

function NoRandShopModel:getConfigShopGoods(shopId)
	if shopId == FuncShop.SHOP_TYPES.CHAR_SHOP then
		return FuncShop.getCharShopGoods()
	elseif shopId == FuncShop.SHOP_TYPES.PVP_SHOP then
		return FuncShop.getPvpShopGoods()
	end
end

return NoRandShopModel
