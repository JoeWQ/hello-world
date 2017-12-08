--
-- Author: xd
-- Date: 2016-01-15 17:00:23
--

--shop相关函数
FuncShop = FuncShop or {}

local shopData =  nil 		--商店配置表
local goodsData = nil 		--道具配置表

local buyData = nil 		--购买配置
local config_pvp_shop = nil --pvp商城
local config_char_shop = nil --侠义值商店

--策划说暂时隐藏掉 4,6这两个商店
FuncShop.SHOP_TYPES = {
	NORMAL_SHOP_1 = "1", -- 永安商店
	NORMAL_SHOP_2 = "2", -- 璎珞斋中级
	NORMAL_SHOP_3 = "3", -- 承天建台商店
	SMELT_SHOP = "4",	 -- 熔炼商店
	PVP_SHOP = "5",      -- pvp商店
	CHAR_SHOP = "6", -- 侠义值商店
	LOTTER_PARTNER_SHOP = "7", -- 抽奖伙伴商店
	LOTTER_MAGIC_SHOP = "8",	--抽奖法宝商店

}

FuncShop.NO_RAND_SHOP_IDS = {
	FuncShop.SHOP_TYPES.CHAR_SHOP,
	FuncShop.SHOP_TYPES.PVP_SHOP,
}

FuncShop.SHOP_NAMES = {
	["1"] = "tid_shop_1033",
	["2"] = "tid_shop_1034",
	["3"] = "tid_shop_1035",
	["4"] = "tid_shop_1036",
	["5"] = "tid_shop_1037",
	["6"] = "tid_shop_1038",
}


--初始化
function FuncShop.init(  )
	shopData = require("shop.Shop")
	goodsData = require("shop.Goods")
	buyData = require("shop.BuyShopFlush")
	config_pvp_shop = require('shop.PvpShop')
	config_char_shop = require('shop.CharShop')
end

function FuncShop.getPvpShopGoods()
	local config = config_pvp_shop
	local sortById = function(a, b)
		return a.id < b.id
	end
	local keys = table.sortedKeys(config, sortById)
	local ret = {}
	for _, key in ipairs(keys) do
		table.insert(ret, config[key])
	end
	return ret
end

function FuncShop.isNoRandShop(shopId)
	if table.find(FuncShop.NO_RAND_SHOP_IDS, shopId) then
		return true
	end
	return false
end

function FuncShop.getNoRandShopCoinType(shopId)
	local ALLTYPES = FuncShop.SHOP_TYPES
	if shopId == ALLTYPES.PVP_SHOP then
		return FuncDataResource.RES_TYPE.ARENACOIN
	elseif shopId == ALLTYPES.CHAR_SHOP then
		return FuncDataResource.RES_TYPE.CHIVALROUS
	end
end

function FuncShop.getCharShopGoods()
	local config = config_char_shop
	local sortById = function(a, b)
		return a.id < b.id
	end
	local keys = table.sortedKeys(config, sortById)
	local ret = {}
	for _, key in ipairs(keys) do
		table.insert(ret, config[key])
	end
	return ret
end

--needtodaytime = true的话，返回的是今日刷新时间
function FuncShop.getNoRandShopRefreshTime(shopId, needTodayTime)
	local ALLTYPES = FuncShop.SHOP_TYPES
	local countType = nil
	if shopId == ALLTYPES.PVP_SHOP then
		countType = FuncCount.COUNT_TYPE.COUNT_TYPE_PVP_SHOP_REFRESH_TIMES
	elseif shopId == ALLTYPES.CHAR_SHOP then
		countType = FuncCount.COUNT_TYPE.COUNT_TYPE_CHAR_SHOP_REFRESH_TIMES
	end
	local now = TimeControler:getServerTime()
	--配置表中商店的刷新时间m:minute, h:hour
	local m = FuncCount.getMinute(countType)
	local h = tonumber(FuncCount.getHour(countType))
	local d = os.date("*t", now)
	d.hour = h
	d.min = m
	d.sec = 0
	local t1 = os.time(d)
	local refresh_t = t1
	local isToday = true
	--如果不需要返回今日时间，会返回约定的下一次自动刷新时间
	if now > t1 and not needTodayTime then
		refresh_t = t1 + 86400
		isToday = false
	end
	return refresh_t, isToday
end

--获取道具购买信息
function FuncShop.getGoodsInfo(shopId, goodsId)
	local data = goodsData
	local ALLTYPES = FuncShop.SHOP_TYPES
	if shopId == ALLTYPES.SMELT_SHOP then
		data = FuncSmelt.getSmeltShopGoodsData()
	elseif shopId==ALLTYPES.CHAR_SHOP then
		data = config_char_shop
	elseif shopId == ALLTYPES.PVP_SHOP then
		data = config_pvp_shop
	end
	local info = data[goodsId]
	if not info then
		echoError("没有这个道具信息,goodsId:"..tostring(goodsId))
	end
	return info
end

--获取商店名称
function FuncShop.getShopNameById(shopId)
	if not shopId then return "" end
	local shopNameTids = FuncShop.SHOP_NAMES
	local tid = shopNameTids[shopId]
	local str = GameConfig.getLanguage(tid)
	return str
end


--获取道具价值 返回 类型_价格 字符串
function FuncShop.getGoodsCost(shopId, id)
	local info = FuncShop.getGoodsInfo(shopId, id)
	cost = info.cost[1]
	return cost
end

--获取商店信息
function FuncShop.getShopInfo( shopId )
	local info = shopData[shopId]
	if not info then
		echoError("没有这个商店信息,id:"..tostring(shopId))
	end
	return info
end


--获取商店开启条件
function FuncShop.getShopOpenCond( shopId )
	local info = FuncShop.getShopInfo(shopId)
	return info.condition
end

--获取商店开启花费
function FuncShop.getShopOpenCost( shopId )
	local info = FuncShop.getShopInfo(shopId)
	return info.openCostGold
end

--获取商店刷新时间
function FuncShop.getShopRefresh(shopId )
	local info =  FuncShop.getShopInfo(shopId)
	return info.ShopTime
end

-- for shop
function FuncShop.getShopOpenVipLevel(shopId)
	local condition = FuncShop.getShopOpenCond(shopId)
	if not condition then return 0 end
    local conditionGroup = numEncrypt:decodeObject(condition) 
    local v = conditionGroup[1]
    local vlevel = v.v
    return vlevel
end

--根据level or vip level 检查是否显示对应商店的按钮
function FuncShop.checkShopBtnCanShowByLevel(shopId)
	local ALLTYPES = FuncShop.SHOP_TYPES
	if shopId == ALLTYPES.NORMAL_SHOP_1 then --普通商店
		return true
	elseif shopId == ALLTYPES.NORMAL_SHOP_2 or shopId == ALLTYPES.NORMAL_SHOP_3 then --vip shop
		local vipLevel = UserModel:vip()
		local openVipLevel = FuncShop.getShopOpenVipLevel(shopId) 
		return openVipLevel <= vipLevel
	elseif shopId == ALLTYPES.SMELT_SHOP then
		local smeltOpen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SMELT)
		return smeltOpen
	elseif shopId == ALLTYPES.PVP_SHOP then
		local arenaIsOpen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PVP)
		return arenaIsOpen
	elseif shopId == ALLTYPES.CHAR_SHOP then
		return true
	end
	return false
end

function FuncShop.checkVipShopCanOpen(shopId)
	local condition = FuncShop.getShopOpenCond(shopId)
	local canOpen = not UserModel:checkCondition(condition)
	return canOpen
end

function FuncShop.getShopKaiqiDisplayItems(shopId)
	local shopInfo = shopData[shopId..'']
	return shopInfo.displayBetterGoods
end

--获取商店 对应刷新次数的花费
function FuncShop.getRefreshCost( shopId,times )
	times = tostring(times)
	local info = buyData[shopId]
	--没有获取到 就拿0对应的数字
	if not info[times] then
		info = info["0"]
	else
		info = info[times]
	end

	--[1是货币类型  2是需要的货币单位]
	return info.cost[1];
end

function FuncShop.getShopItemResCostInfo(shopId, shopData)
    local shopItemId = shopData.id
    local costInfo = FuncShop.getGoodsCost(shopId, shopItemId)
    local needNums,hasNums,isEnough,resType = UserModel:getResInfo(costInfo)
    return resType, needNums
end

function FuncShop.isShopItemSoldOut(shopId, shopData)
	if shopData.buyTimes > 0 then
		return true
	end
	return false
end

function FuncShop.isVipShop(shopId)
	shopId = tostring(shopId)
	if shopId == FuncShop.SHOP_TYPES.NORMAL_SHOP_2 or shopId == FuncShop.SHOP_TYPES.NORMAL_SHOP_3 then
		return true
	end
	return false
end
