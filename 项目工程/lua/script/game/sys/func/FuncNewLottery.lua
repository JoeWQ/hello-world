--三皇抽奖系统
--Date  2016-12-27 10:40
--@Author:wukai


local lotteryData = nil
local lotterypartnershop = nil
local lotterytreasureshop = nil
FuncNewLottery = FuncNewLottery or {}
FuncNewLottery.rewardquality = {
	white = 1, --白
	green = 2, --绿
	blue = 3, --蓝
	purple = 4, --紫
	gold = 5, --金
}

FuncNewLottery.freeerrorString = {
	[1] = "抽卡冷却中",
	[2] = "普通造物券不足,无法造物",
	[3] = "免费次数不足",
}
FuncNewLottery.RMBerrorString = {
	[1] = "消费第一次免费",
	[2] = "高级卷不足,无法造物",
	[3] = "仙玉不足，无法造物",
}
FuncNewLottery.lotterytypetable = {
	[1] = 1,
	[2] = 2,
}
function FuncNewLottery.init()

	lotteryData = require("lottery.Lottery")   -------获取抽奖本地数据
	lotterypartnershop = require("lottery.LotteryPartnerShop")  --- 伙伴商店
	lotterytreasureshop = require("lottery.LotteryTreasureShop") --- 法宝商店

end
--获取免费单抽抽卡次数
function FuncNewLottery.getFreecardnumber()
	local number = FuncDataSetting.getDataByConstantName("LotteryFreeNum") 
	return number
end
function FuncNewLottery.getIDLotteryData(lotteryID)
	if lotteryID ==nil then
		echo("不存在该抽奖ID",lotteryID)
		return
	end
	local data = lotteryData[tostring(lotteryID)]
	return  data
end

--获取免费单抽CD
function FuncNewLottery.getfreeCDtime()
	local time = FuncCommon.getCdTimeById(1)
	return time
end
--满足所需等级
function FuncNewLottery.getawardLevelopenfree()
	local level = FuncDataSetting.getDataByConstantName("LotteryTreasureOpen")
	return level 
end

--元宝单抽，每次消耗RMB
function FuncNewLottery.consumeOnceRMB()
	local RMBnumber = FuncDataSetting.getDataByConstantName("LotteryCommonConsume")
	return RMBnumber 
end
--元宝十抽，每次消耗RMB
function FuncNewLottery.consumeTenRMB()
	local RMBnumber = FuncDataSetting.getDataByConstantName("LotteryGoldConsume")
	return  RMBnumber
end

--消耗造物普通体验券
function FuncNewLottery.Ordninaryfreecardnumber()
	return 1 
end
--消耗造物高级体验券
function FuncNewLottery.SeniorRMBcardnumber()
	return 1 
end
function FuncNewLottery:getOrdninaryID()
	local id = FuncDataSetting.getDataByConstantName("LotteryOrdninaryCard")
	return id
end
function FuncNewLottery:getSeniorcardID()
	local id = FuncDataSetting.getDataByConstantName("LotterySeniorCard")
	return id
end


--获得刷新消耗铜钱次数
function FuncNewLottery.getlotteryShoprefreshitems()
	local numberstring = FuncDataSetting.getDataVector("LotteryRefreshCost")
	-- dump(numberstring,"刷新金币数量")
	local refreshitems =  tonumber(CountModel:getLotterymanyrefreshCount())
	local  sumnumber = 0
	for k,v in pairs(numberstring) do
		sumnumber = sumnumber + 1
	end
	-- echo("===========refreshitems=======",refreshitems)
	local index = nil --math.fmod(refreshitems,sumnumber)
	if refreshitems >=  3 then
  		index = 0
  	elseif refreshitems == 0 then
  		index = 1
  	elseif refreshitems == 1 then
  		index = 2
  	elseif refreshitems == 2 then
  		index = 3
	end
	-- echo("======获得刷新消耗次数=index==",refreshitems,sumnumber,index,numberstring[tostring(index)])
	return numberstring[tostring(index)]
end

-- function FuncNewLottery.setselectlotteryitems(itmes)
-- 	self.selectlotteryitem = itmes
-- end
-- function FuncNewLottery.getselectlotteryitems()
-- 	return self.selectlotteryitem
-- end


--根据伙伴商店ID获得伙伴（伙伴碎片）
function FuncNewLottery.getpartnerdata(partnerid)
	local partnerdata = {
		award = nil,
		cost = 0,
	}
	local id = tostring(partnerid)
	if  lotterypartnershop[id] ~= nil then
		local reward = lotterypartnershop[id].reward
		partnerdata.award = reward
		partnerdata.cost = lotterypartnershop[id].cost
	end
	return partnerdata
end
---获得法宝
function FuncNewLottery.getTreasuredata(treasureid)
	local treasuredata = {
		award = nil,
		cost = 0,
	}
	local id = tostring(treasureid)
	if  lotterytreasureshop[id] ~= nil then
		local reward = lotterytreasureshop[id].reward
		treasuredata.award = reward
		treasuredata.cost = lotterytreasureshop[id].cost
	end
	return treasuredata
end
--免费抽奖类型（1）（5）
function FuncNewLottery.setlotteryFreeType( typeitmes )
	FuncNewLottery.lotteryFreeitems = typeitmes

end

function FuncNewLottery.getlotteryFreeType()
	return FuncNewLottery.lotteryFreeitems 
end

--元宝抽奖类型（1）（10)
function FuncNewLottery.setlotteryRMBType( typeitmes )
	FuncNewLottery.lotteryRMBitems = typeitmes
end

function FuncNewLottery.getlotteryRMBType()
	return FuncNewLottery.lotteryRMBitems 
end

--- 抽奖商店类型
function FuncNewLottery.setTouchawardtype(awardtype)
	if tonumber(awardtype) ==  1 then 
		FuncNewLottery.shoptype = FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP
	elseif tonumber(awardtype) ==  2 then
		FuncNewLottery.shoptype = FuncShop.SHOP_TYPES.LOTTER_MAGIC_SHOP
	end
	echo("========FuncNewLottery.shoptype=============",FuncNewLottery.shoptype)
end
function FuncNewLottery.getTouchawardtype()
	return FuncNewLottery.shoptype
end

--设置抽奖类型
function FuncNewLottery.setlotterytype(typeid)
	FuncNewLottery.lotterytype = typeid
end
--获得抽奖类型
function FuncNewLottery.getlotterytype()
	return FuncNewLottery.lotterytype
end
function FuncNewLottery.getfreeIDerror(errorid)
	if errorid ~= nil then
		local errorstring = FuncNewLottery.freeerrorString[tonumber(errorid)]
		WindowControler:showTips(errorstring)
	end
end

function FuncNewLottery.getRMBIDerror(errorid)
	if errorid ~= nil then
		local errorstring = FuncNewLottery.RMBerrorString[tonumber(errorid)]
		WindowControler:showTips(errorstring)
	end
end
-------------------- 初始NPC ---------------------
function FuncNewLottery.initNpc(_partnerId)
    local t1 = os.clock()
    local partnerData = FuncPartner.getPartnerById(_partnerId);
    local bossConfig = partnerData.dynamic
    local arr = string.split(bossConfig, ",");
--    local sp = ViewSpine.new(arr[1], {}, arr[1]);
    local sp = FuncPartner.getHeroSpine(_partnerId)
    if arr[3] == "1" then 
        sp:setRotationSkewY(180);
    end 
    if arr[4] ~= nil then -- 缩放
        local scaleNum = tonumber(arr[4])
        if scaleNum > 0 then
            scaleNum = 0 - scaleNum    
        end
        sp:setScaleX(scaleNum)
        sp:setScaleY(-scaleNum)
    end
    if arr[5] ~= nil then -- x轴偏移
        sp:setPositionX(sp:getPositionX() + tonumber(arr[5]))
    end
    if arr[6] ~= nil then -- y轴偏移
        sp:setPositionY(sp:getPositionY() + tonumber(arr[6]))
    end
    
    sp:setShadowVisible(false)
    -- echo(os.clock() - t1,"-------- spin ddddd 消耗时间");
    return sp
end
function FuncNewLottery.CachePartnerdata()
	local data = PartnerModel:getAllPartner()
	FuncNewLottery.PartnerData = {}
	for k,v in pairs(data) do
		FuncNewLottery.PartnerData[tostring(k)] = k
	end
end
function FuncNewLottery.addCachePartnerdata(partnermodeoID)
	local partnermodeo = {}
	-- partnermodeo[tostring(partnermodeoID)] = partnermodeoID
	-- table.insert(FuncNewLottery.PartnerData,partnermodeo)
	FuncNewLottery.PartnerData[tostring(partnermodeoID)] = tostring(partnermodeoID)
end
--设置提换的位置
function FuncNewLottery.tihuangIndex(index)
	FuncNewLottery.tihuangobjectIndex = index
end
--获得提换的位置
function FuncNewLottery.gettihuangIndex()
	return tonumber(FuncNewLottery.tihuangobjectIndex)
end




