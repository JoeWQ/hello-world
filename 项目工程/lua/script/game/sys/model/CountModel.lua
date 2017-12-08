--
-- Author: xd
-- Date: 2016-01-18 11:28:35
--

local CountModel = class("CountModel", BaseModel )
local PVP_CHANGE_ADD_COUNT_PER_TIME = 1 --每购买一次挑战，增加五次挑战机会

--[[

    "count"      = 1
    "expireTime" = 1454274000
    "id"         = "10"

]]

function CountModel:init(d)
	CountModel.super.init(self,d)

	self.countType = FuncCount.COUNT_TYPE
    --判断下时间是否过期  过期了 那么就恢复次数为0
    local serverTime = TimeControler:getServerTime()
    for i,v in pairs(self.countType) do

        d[v] = d[v] or {}
        local modelData = d[v] 
        local expireTime = modelData.expireTime or 0
        modelData.id = modelData.id or v
        if serverTime > expireTime then
            modelData.count = 0
        end

        local data = FuncCommon.getCountData( v )

        --测试时间用
        -- local defChar = "*"
        -- data.m = 15
        -- data.h = 16
        -- data.w = defChar
        -- data.j = defChar

        --开启下次刷新时间
        modelData.expireTime = TimeControler:countNextRefreshTime( data.m,data.h,data.w,data.j )

        local leftTime = modelData.expireTime -  serverTime

        --添加对应的侦听
        TimeControler:startOneCd(i,leftTime)
        --同时添加对应的事件 
        EventControler:addEventListener(i, self.pressTimeOut, self)
        
    end
end

--某种计数刷新时间到了----
function CountModel:pressTimeOut(e  )
    --需要刷新次数
    echo("刷新时间到了----",e.name)
    local v= self.countType[e.name]
    local modelData = {}
    local data = FuncCommon.getCountData( v )



    modelData.count = 0
    --开启下次刷新时间
    modelData.expireTime = TimeControler:countNextRefreshTime( data.m,data.h,data.w,data.j )

    --更新数据
    self:updateData({[v] = modelData})

end


-- 通过type，获取counts二级属性
function CountModel:getCountByType(type)
    local countsTab = self._data
    if countsTab then
        local countTab = countsTab[tostring(type)]
        if countTab then
            return countTab.count
        end
    end
    return 0
end


--获取商店刷新次数
function CountModel:getShopRefresh(shopId)
    shopId = tostring(shopId)
    if shopId == FuncShop.SHOP_TYPES.NORMAL_SHOP_1 then
        return self:getCountByType(self.countType.COUNT_TYPE_JUNIOR_SHOP_FLUSH_TIMES) -- 低级普通商店
    elseif shopId == FuncShop.SHOP_TYPES.NORMAL_SHOP_2 then
        return self:getCountByType(self.countType.COUNT_TYPE_MEDIUM_SHOP_FLUSH_TIMES) -- 中级普通商店
	elseif shopId == FuncShop.SHOP_TYPES.NORMAL_SHOP_3 then
        return self:getCountByType(self.countType.COUNT_TYPE_SENIOR_SHOP_FLUSH_TIMES) -- 高级普通商店
	elseif shopId == FuncShop.SHOP_TYPES.PVP_SHOP then
		return self:getCountByType(self.countType.COUNT_TYPE_PVP_SHOP_REFRESH_TIMES) -- 竞技场商店
	elseif shopId == FuncShop.SHOP_TYPES.CHAR_SHOP then
		return self:getCountByType(self.countType.COUNT_TYPE_CHAR_SHOP_REFRESH_TIMES) -- 侠义值商店
    end
end


-- 获得体力当前购买次数
function CountModel:getSpBuyCount()
    local buyCount = self:getCountByType(self.countType.COUNT_TYPE_BUY_SP)
    if buyCount == nil then
        return 0
    end
    return buyCount
end
--//获取铜钱购买次数
function      CountModel:getCoinBuyTimes()
    local       _buy_count=self:getCountByType(self.countType.COUNT_TYPE_USER_BUY_COIN_TIMES);
    if( _buy_count==nil)then
        return  0;
    end
    return    _buy_count;
end

--获取灵力事件购买次数
function CountModel:getMagicEventFinishCount()
    local buyCount = self:getCountByType(self.countType.COUNT_TYPE_BUY_MP)
    return buyCount
end

-- 获得PVP购买次数
function CountModel:getPVPBuyCount()
    local buyCount = self:getCountByType(self.countType.COUNT_TYPE_BUY_PVP)
    return buyCount/PVP_CHANGE_ADD_COUNT_PER_TIME
end

--获得购买过的pvp 挑战次数
function CountModel:getPVPBuyChallengeCount()
    return self:getCountByType(self.countType.COUNT_TYPE_BUY_PVP)
end

function CountModel:getPVPChallengeCount()
	local count = self:getCountByType(self.countType.COUNT_TYPE_PVPCHALLENGE)
	return count
end
--获取爬塔剩余扫荡重置次数
function CountModel:getTowerResetCount()
    return self:getCountByType(self.countType.COUNT_TYPE_TOWER_RESET)
end

function CountModel:getSmeltShopRefreshCount()
	return self:getCountByType(self.countType.COUNT_TYPE_SMELT_REFRESH_TIMES_SOUL)
end

--天玑赌肆投掷次数
function CountModel:getYongAnGmableCount()
	return self:getCountByType(self.countType.COUNT_TYPE_GAMBLE_COUNT)
end

--天玑赌肆改投次数
function CountModel:getYongAnGmableChangeFateCount()
	return self:getCountByType(self.countType.COUNT_TYPE_GAMBLE_CHANGE_FATE_COUNT)
end

--神明铜钱强化次数
function CountModel:getGodUpgradeCoinCount()
	return self:getCountByType(self.countType.COUNT_TYPE_GODUPGRADE_COIN_TIMES)
end
--神明仙玉强化次数
function CountModel:getGodUpgradeGlodCount()
	return self:getCountByType(self.countType.COUNT_TYPE_GODUPGRADE_GLOD_TIMES)
end

-- 判断能否购买竞技场挑战次数
--目前已经和VIP的关系脱离了
function CountModel:canBuyPVPSn()
 --   local vipLevel = UserModel:vip()
--    local maxBuyTimes = FuncCommon.getVipPropByKey(vipLevel,"buySn")

--    local buyCount = self:getCountByType(self.countType.COUNT_TYPE_BUY_PVP)

--    if tonumber(buyCount/PVP_CHANGE_ADD_COUNT_PER_TIME) >= tonumber(maxBuyTimes) then
--        return false
--    end
 --   return vipLevel>=3;
 return true
end
--//判断最大铜钱可以购买的次数
function CountModel:getMaxCoinBuyTimes()
	local _vip_level = UserModel:vip()
	return FuncCommon.getVipPropByKey(_vip_level, "buyGoldLimit")
end

--更新事件
function CountModel:updateData ( data )
	CountModel.super.updateData(self,data)
	EventControler:dispatchEvent(CountEvent.COUNTEVENT_MODEL_UPDATE,data)
end


function CountModel:getTrialCountTime(kind)
    return self:getCountByType(self.countType["COUNT_TYPE_TRIAL_TYPE_TIMES_" .. tostring(kind)]);
end

function CountModel:getHonorCountTime()
    return self:getCountByType(self.countType.COUNT_TYPE_HONOR_COUNT);
end
function CountModel:getDefenderCountTime()
    -- return self:getCountByType(self.countType.COUNT_TYPE_DEFENDER_COUNT);
    return 0
end
--获取伙伴技能点购买次数
function CountModel:getPartnerSkillPointTime()
    return self:getCountByType(self.countType.COUNT_TYPE_PARTNER_SKILL_POINT_TIMES)
end

--获取免费抽奖次数
function CountModel:getLotteryfreeCount()
   return self:getCountByType(self.countType.COUNT_TYPE_NEWLOTTERY_FREE_TIMES);
end
--获取元宝免费抽奖次数
function CountModel:getLotteryGoldFreeCount()
   return self:getCountByType(self.countType.COUNT_TYPE_NEWLOTTERY_GOLD_FREE_TIMES);
end
--获取元宝付费单抽抽奖次数
function CountModel:getLotteryGoldPayCount()
   return self:getCountByType(self.countType.COUNT_TYPE_NEWLOTTERY_GOLD_FAY_TIMES);
end
--获得铜钱刷新次数
function CountModel:getLotterymanyrefreshCount()
    return self:getCountByType(self.countType.COUNT_TYPE_NEWLOTTERY_MANY_REFRESH_TIMES);
end

return CountModel
