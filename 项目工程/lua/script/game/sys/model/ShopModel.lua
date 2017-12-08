--
-- Author: xd
-- Date: 2016-01-15 14:38:41
--

--商城相关
local ShopModel=class("ShopModel", BaseModel)

local OtherValideShop ={["7"] = {},
                                           ["8"]={},
}

function ShopModel:init( d )
	ShopModel.super.init(self,d)
	-- dump(d,"__shopData")
	--商店对应的cd事件
	self.shopToCDEventMap = {
		["1"] ={event= TimeEvent.TIMEEVENT_CDSHOP_1, cdEndFunc="onShopCd1"},
		["2"] ={event= TimeEvent.TIMEEVENT_CDSHOP_2, cdEndFunc="onShopCd2"},
		["3"] ={event= TimeEvent.TIMEEVENT_CDSHOP_3, cdEndFunc="onShopCd3"}, 
	}

	--初始化开启刷新倒计时
	for shopType,info in pairs(self.shopToCDEventMap) do
		local event = info.event
		local func = self[info.cdEndFunc]
		EventControler:addEventListener(event, func, self)
		self:countInitLeftRefreshTime(shopType)
	end
	EventControler:addEventListener(HomeEvent.HOMEEVENT_COME_BACK_TO_MAIN_VIEW, self.onComeBackToMainView, self)
	EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, self.onUserLevelChange, self)
end

function ShopModel:onShopCd1()
	self:onShopCd("1")
end

function ShopModel:onShopCd2()
	self:onShopCd("2")
end

function ShopModel:onShopCd3()
	self:onShopCd("3")
end

--商店的某个cd到了
function ShopModel:onShopCd(shopType)
	--延迟一帧请求刷新商店,如果成功会修改底层数据
	WindowControler:globalDelayCall(c_func(ShopServer.getShopInfo, ShopServer, c_func(self.onRefreshShopEnd, self)))
end

function ShopModel:onComeBackToMainView()
	local shopType = self:getCurrentNewOpenTempShop()
	--if  shopType then
	--    WindowControler:showWindow("ShopKaiqi", shopType)
	--end
end

function ShopModel:onRefreshShopEnd()
	EventControler:dispatchEvent(ShopEvent.SHOPEVENT_REFRESH_SHOP_END)
end

--判断shop是否开启，包括临时开启
function ShopModel:checkIsOpen(shopId )
	local data = self._data[shopId]
	if not data then
		return false
	end
	local now = TimeControler:getServerTime()
	if data.isTempShop == 1  then 
		local expireTime = data.expireTime or 0
		if now >= expireTime then
			return false
		end
	end
	return true
end

--获取某个商店的列表信息
function ShopModel:getShopItemList(shopId)
	local data = self._data[shopId]
	local ret = {}
	if data then
		data = data.goodsList
	end
	local keys = table.keys(data)
	local sortById = function(a, b)
		return tonumber(a) < tonumber(b)
	end
	table.sort(keys, sortById)
	for i, index in ipairs(keys) do
		data[index].index = i
		table.insert(ret, data[index])
	end
	return ret
-- 	"shops":{
-- "1":{"goodsList":{
-- "1":{"id":"2006","buyTimes":0},
-- "2":{"id":"104","buyTimes":0},
-- "3":{"id":"2009","buyTimes":0},
-- "4":{"id":"2003","buyTimes":0},
-- "5":{"id":"2001","buyTimes":0},
-- "6":{"id":"2004","buyTimes":0}}
-- ,"lastFlushTime":1452935298}},

end

function ShopModel:isShopItemAllSoldOut(shopId)
	shopId = tostring(shopId)
	local data = self._data[shopId]
	if data == nil then return false end
	local goods = data.goodsList
	local soldOut = true
	for k,v in pairs(goods) do
		if v.buyTimes<=0 then
			soldOut = false
		end
	end
	return soldOut
end
--//判断某个给定的商品是否已经售出
function ShopModel:isSomeItemSoldOut(shopId,_goodsId)
  local   shop_data=self._data[shopId];
  if(shop_data == nil)then  return false end;
--  assert(shop_data ~=nil,"error on query shop data ,param is illegal.");
  for key,value in pairs(shop_data.goodsList)do
       if(value.id== _goodsId )then
                 return   value.buyTimes<=0;
       end
  end
  return false;
 --// assert(false,"gooldsId is illegal :".._goodsId);
end
function ShopModel:setCurrentNewOpenTempShop(shopType)
	self._new_open_temp_shop = shopType
end

function ShopModel:getCurrentNewOpenTempShop()
	return self._new_open_temp_shop 
end

function ShopModel:clearCurrentNewOpenTempShop()
	self._new_open_temp_shop = nil
end

--获取某个商店上次更新时间
function ShopModel:getLastRefreshTime( shopId )

	if not self:checkIsOpen(shopId) then
		return 0
	end

	return self._data[shopId].lastFlushTime
end

--获取初始化某个商店剩余刷新时间 并开启倒计时
function ShopModel:countInitLeftRefreshTime(shopId)
	local targetTime,leftTime = self:getNextRefreshTime(shopId)

	if leftTime < 0 then
		return 
	end

	if leftTime ==0 then
		self:onShopCd()
		return
	end

	--开启计时
	local eventName = self.shopToCDEventMap[shopId].event
	TimeControler:startOneCd(eventName, leftTime)
end

function ShopModel:_getDayInitTimeStamp(time)
	local d = os.date("*t", time)
	d.hour = 0
	d.min = 0
	d.sec = 0
	return os.time(d)
end


--获取商店下次刷新时间
function ShopModel:getNextRefreshTime(shopId )
	--如果是未开启的  返回0
	if not self:checkIsOpen(shopId) then
		return 0 ,-1
	end
	local now = TimeControler:getServerTime()
	local todayBegin = self:_getDayInitTimeStamp(now)
	local refreshTimes 
    if OtherValideShop[shopId] then
        return 0,-1
    end
     refreshTimes= FuncShop.getShopRefresh(shopId)
	local targetTime = 0
--	for k,timeOffset in ipairs(refreshTimes) do
    local    _select_index=0;
    for  k=1,#refreshTimes do
        local   timeOffset=refreshTimes[k];
		targetTime = timeOffset
		local t = todayBegin+timeOffset
		if t > now then
           _select_index=k;
			break
		end
	end
	local targetAbsoluteTime = 0
	if _select_index==0 then
		local nextDayBegin = self:_getDayInitTimeStamp(now + 86400)
		targetTime = refreshTimes[1]
		targetAbsoluteTime = targetTime + nextDayBegin
	else
		targetAbsoluteTime = targetTime + todayBegin
	end
	local leftTime = targetAbsoluteTime - now
	return targetTime, leftTime
end

function ShopModel:updateData(data)
	ShopModel.super.updateData(self,data)

	for k,v in pairs(data) do
		--如果商店倒计时发生变化
		if k ~= FuncShop.SHOP_TYPES.SMELT_SHOP then
			if v.lastFlushTime then
				--那么重新启动商店倒计时
				self:countInitLeftRefreshTime(tostring(k))
			end
		end
		--有可能购买的时候，灵宝殿购买完了，那么会带回来一批新的商店数据
		if k == FuncShop.SHOP_TYPES.SMELT_SHOP then
			if v.lastFlushTime then
				EventControler:dispatchEvent(ShopEvent.SHOPEVENT_SMELT_SHOP_REFRESHED)
			end
		end
		if FuncShop.isVipShop(k) and self:isTempShop(k) then
			self:setCurrentNewOpenTempShop(k)
			if not self:isShopViewShowing() then
				EventControler:dispatchEvent(ShopEvent.SHOPEVENT_TEMP_SHOP_OPEN, {shopType=k})
			end
		end
	end

	--商店数据刷新, 那么通知ui界面刷新 可能包括道具 倒计时 等等
	EventControler:dispatchEvent(ShopEvent.SHOPEVENT_MODEL_UPDATE, data)
end

function ShopModel:getTempShopLeftTime(shopId)
	local expireTime = self._data[shopId].expireTime
	local now = TimeControler:getServerTime()
	local delta = expireTime - now
	if delta <0 then delta = 0 end
	return delta
end

--根据数据判断商店是否临时开启
function ShopModel:isTempShop(shopId)
	local data = self._data[shopId]
	if not data then return false end

	if data.isTempShop or data.expireTime then 
		return true
	end

	return false
end

function ShopModel:onUserLevelChange()
	self:tryGetShopInfo()
end

function ShopModel:tryGetShopInfo()
	local open, value, valueType = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SHOP_1)
	if open then
		ShopServer:getShopInfo()
	end
end

function ShopModel:setShopIsShow(show)
	self._shop_is_show = show
end

function ShopModel:isShopViewShowing()
	return self._shop_is_show == true
end

return ShopModel
