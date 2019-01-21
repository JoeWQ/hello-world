
FuncDataResource = FuncDataResource or {}

FuncDataResource.RES_TYPE = {
    ITEM = "1",             -- 道具
    EXP = "2",              --经验
    COIN = "3",             --金币
    DIAMOND = "4",          --钻石
    SP = "5",               --行动力
    MP = "6" ,              --法力
    ARENACOIN = "7" ,       --竞技场货币
    GUILDCOIN = "8" ,       --工会商店
    HUANGTONG = "9" ,        --9 某玩法货币，预留 -- 熔炼需要的黄铜
    TREASURE = "10",        --完整法宝
    GIFTGOLD = "11",		--代币 赠送钻石
    COPPER ="12",			--熔炼商店魂牌
    SOUL = "13",			--宝物精华
    PULSECOIN = "14",		--灵脉系统灵气
    ROMANCEEXP = "15",		--奇缘好感度
    TALENTPOINT = "16",     --天赋点
	CHIVALROUS = "17",		--侠义值
	PARTNER = "18",			--完整伙伴
}


local dataRes = require("common.DataResource")

--[[
	获得货币资源的名字
]]
function FuncDataResource.getResName(id)
	local tid = FuncDataResource.getDataByID(id).translateId;
	return GameConfig.getLanguage(tid);
end

-- 获取英雄静态数据
function FuncDataResource.getDataByID(id)
	local data = dataRes[tostring(id) ]
	if not data then
		echoError("没有这个resID:"..tostring(id))
	end
    return data
end

-- 获取资源获取途径
function FuncDataResource.getDataAccessWay(id)
	local data = FuncDataResource.getDataByID(tostring(id))
	return data.accessWay
end

--获取资源的名字 资源可能是 道具 法宝 或者货币
function FuncDataResource.getResNameById(resType,resId)
	resType = tostring(resType)
	if resType == FuncDataResource.RES_TYPE.ITEM  then
		return FuncItem.getItemName(resId)
	elseif resType ==FuncDataResource.RES_TYPE.TREASURE then
		return GameConfig.getLanguage(FuncTreasure.getValueByKeyTD(resId,"name") )
	end

    return FuncDataResource.getResName(resType);
end

--获取icon
function FuncDataResource.getIconPathById( id )
	local data = FuncDataResource.getDataByID(tostring(id))
	local iconPath = data.icon
	return iconPath
end

--获取资源品质 
function FuncDataResource.getQualityById( resType,resId )
	if resType == FuncDataResource.RES_TYPE.ITEM then
		return FuncItem.getItemQuality(resId)
	elseif resType == FuncDataResource.RES_TYPE.TREASURE then
		--那么是获取法宝品质
		return FuncTreasure.getValueByKeyTD(resId,"quality")  
	end
	--否则就是获取其他的品阶
	local data = FuncDataResource.getDataByID(resType)
	if not data.quality then
		echoError("resType:",resType,"resId:",resId,'没有配置quality')
	end
	return data.quality
end


--获取资源描述
function FuncDataResource.getResDescrib(resType, resId )
	if resType == FuncDataResource.RES_TYPE.ITEM then
		return FuncItem.getItemDescrib(resId)
	elseif resType == FuncDataResource.RES_TYPE.TREASURE then
		return FuncTreasure.getTreasureDes(resId);

	end

	--否则就是获取其他的品阶
	local data = FuncDataResource.getDataByID(resType)
	local tid = data.des
	if not tid then
		echoWarn("没有为这个资源配置描述:",resType,resId)
		return "还没有配置描述" ..tostring(resType) 
	end
	return  GameConfig.getLanguage(tid) 
end




