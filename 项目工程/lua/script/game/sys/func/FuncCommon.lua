--
-- Author: ZhangYanguang
-- Date: 2015-12-16
--
-- Vip 配表表工具类

FuncCommon = FuncCommon or { }

FuncCommon.SYSTEM_NAME = {
    MAIN_LINE_QUEST = "mainlineQuest",
    -- 主线任务
    EVERY_DAY_QUEST = "everydayQuest",
    -- 每日任务
    TOWER = "tower",
    -- 爬塔
    TRAIL = "trial",
    -- 商城
    SHOP_1 = "shop1",
    -- 试炼
    TREASURE_COMBINE = "treasureCombine",
    -- 法宝合成
    PVP = "pvp",                    -- 竞技场
    PULSE = "pulse",                -- 主角灵脉
    NATAL = "treasureNatal",        --本命法宝
    TALENT = "talent",              --天赋
    GAMBLE = "gamb",                --赌坊

    STARLIGHT = "starlight",--星耀
    
    --好友系统
    FRIEND="friend",
    --聊天
    CHAT="chat",
	SMELT = "smelt", -- 熔炼
    BAG = "bag", --包裹
    ROMANCE = "elite", --奇缘
    GOD = "god", --神明
    CHAR = "char", --奇缘
    LOTTERY = "lottery", --铸宝
    SIGN = "sign", --签到
}

-- 二进制位表示战斗结果的星级及完成了哪个条件
FuncCommon.battleStarCfg = {
    -- 一星
    [1] = {1,{0,0,1}},
    [2] = {1,{0,1,0}},
    [4] = {1,{1,0,0}},

    -- 二星
    [3] = {2,{0,1,1}},
    [5] = {2,{1,0,1}},
    [6] = {2,{1,1,0}},

    -- 三星
    [7] = {3,{1,1,1}},
} 

FuncCommon.numMap = {
    [0] = "十",
    [1] = "一",
    [2] = "二",
    [3] = "三",
    [4] = "四",
    [5] = "五",
    [6] = "六",
    [7] = "七",
    [8] = "八",
    [9] = "九",
}

local vipData = nil
local cdData = nil
local countData = nil
local getMethodData = nil
local npcData = nil
local systemOpenData = nil
local maxVipLevel = nil
-- //体力价格
local SpPrice = nil;
-- //npc图标与对话内容
local npcIconDialog = nil;
-- //购买铜钱的价格
local coinPrice = nil;
-- 关卡星级条件枚举数据
local levelConditon = nil;

function FuncCommon.init()
    vipData = require("common.Vip")
    cdData = require("common.Cd")
    countData = require("common.Count")
    getMethodData = require("common.GetMethod")
    npcData = require("common.Npc")
    systemOpenData = require('common.SystemOpen')
    SpPrice = require("common.BuySp");
    npcIconDialog = require("home.CommonPopup");
    coinPrice = require("common.Goldcount");
    config_Recharge = require("common.Recharge")
    levelConditon = require("common.LevelCondition")
end

function FuncCommon.getSysOpenData()
    return systemOpenData;
end

function FuncCommon.getSysOpenValue(id, key)
    local valueRow = systemOpenData[tostring(id)];
    if valueRow == nil then 
        echo("error: FuncCommon.getSysOpenValue id " .. 
            tostring(id) .. " is nil;");
        return nil;
    end 

    local value = valueRow[tostring(key)];
    if value == nil then 
        echo("error: FuncCommon.getSysOpenValue key " .. 
            tostring(key) .. " is nil");
    end 
    return value;
end

function FuncCommon.getSysOpenContent(id)
    return FuncCommon.getSysOpenValue(id, "content");
end

function FuncCommon.getSysOpensysname(id)
    return FuncCommon.getSysOpenValue(id, "sysname");
end

function FuncCommon.getSysOpenxtname(id)
    return FuncCommon.getSysOpenValue(id, "xtname");
end

function FuncCommon.getAdInt(id)
    return FuncCommon.getSysOpenValue(id, "adInt");
end

-- //用给定的ID,获取npc的图标路径,和对话内容
function FuncCommon.getNpcIconDialog(_id)
    local _item = npcIconDialog[tostring(_id)];
    if (_item ~= nil) then
        return "icon/other/" .. _item.npc .. ".png", GameConfig.getLanguage(_item.tips);
    end
    return nil, nil;
end
-- //给定购买次数来获取体力的价格
function FuncCommon.getSpPriceByTimes(_times)
    local _item = SpPrice[tostring(_times)];
    if (_item ~= nil) then
        return _item["buySpCost"];
    end
--    local _num = table.length(SpPrice);
    _item = SpPrice["0"];
    return _item["buySpCost"];
end
-- //给定购买次数获取购买铜钱的价格和所能获得的铜钱数目
function FuncCommon.getCoinPriceByTimes(_times)
    local _item = coinPrice[tostring(_times)];
    if (_item ~= nil) then
        return _item.Price, _item.quantity;
    end
    local _num = table.length(coinPrice);
    _item = coinPrice["0"];
    -- //Goldcount.csv建表不太规范
    return _item.Price, _item.quantity;
end
function FuncCommon.getNpcDataById(npcId)
    local data = npcData[tostring(npcId)]
    if data == nil then
        echo("FuncCommon.getNpcDataById not found id ", npcId)
        return
    end

    return data
end

function FuncCommon.getNpcName(npcId)
    return FuncCommon.getNpcDataById(npcId).name;
end

function FuncCommon.getNpcIcon(npcId)
    return FuncCommon.getNpcDataById(npcId).icon;
end

function FuncCommon.getNpcSpineBody(npcId)
    return FuncCommon.getNpcDataById(npcId).spineBody;
end

-- 根据id，获取途径数据
function FuncCommon.getGetWayDataById(getWayId)
    local data = getMethodData[tostring(getWayId)]
    if data == nil then
        echo("FuncCommon.getGetWayDataById not found id ", getWayId)
        return
    end

    return data
end


-- 根据vipLevel和key值获取属性值
function FuncCommon.getVipPropByKey(vipLevel, key)
    local vipCfg = vipData[tostring(vipLevel)]
    if vipCfg then
        return vipCfg[key]
    end

    return nil
end

-- 获得vip可达到的最大数值
function FuncCommon.getMaxVipLevel()
    if maxVipLevel then return maxVipLevel end

    local keys = table.keys(vipData)
    local sortByLevel = function(a, b)
        return tonumber(a) < tonumber(b)
    end
    table.sort(keys, sortByLevel)
    maxVipLevel = tonumber(keys[#keys])
    return maxVipLevel
end

-- 根据viplevel获取熔炼商店刷新的最大次数
function FuncCommon.getSmeltShopRefreshMaxTime(vipLevel)
    return FuncCommon.getVipPropByKey(vipLevel, "refreshNum")
end

-- 根据vipLevel 获取每天最多可以购买几次互动次数
function FuncCommon.getInteractTimes(vipLevel)
    return FuncCommon.getVipPropByKey(vipLevel, "interactTimes")
end

function FuncCommon.getGambleChangeCount(vipLevel)
	return FuncCommon.getVipPropByKey(vipLevel, "gambleChangeTimes")
end

-- 获得vip级别对应的能购买的pvp挑战次数
function FuncCommon.getPVPBuyCount(vipLevel)
    return FuncCommon.getVipPropByKey(vipLevel, "buySn")
end
-- 根据Id，获取cd数据
function FuncCommon.getCdCostById(id, leftCd)
    local data = cdData[tostring(id)]
    if data then
        local costType = data.costType
        local cdCost = nil
        -- 固定消费
        if tonumber(costType) == 1 then
            cdCost = data.cost
            -- 动态消费
        elseif tonumber(costType) == 2 then
            if not leftCd then leftCd = data.cdPlus end
            cdCost = math.ceil(leftCd * 1.0 / data.cost)
        end
        return cdCost
    else
        echo("getCdCostById not found")
        return nil
    end
end

-- 根据Id，获取cd时间
function FuncCommon.getCdTimeById(id)
    local data = cdData[tostring(id)]
    if data then
        return data.cdPlus
    else
        echo("getCdTimeById not found")
        return nil
    end
end


-- 根据countId获取 数据
function FuncCommon.getCountData(countId)
    local data = countData[tostring(countId)]
    if not data then
        echoError("没有这个countId的数据:", countId)
    end
    return data
end

local colorToQuality 

if not DEBUG_SERVICES then
    colorToQuality = {
        cc.c3b(255,255,255),
        cc.c3b(0,255,0),
        cc.c3b(0,0,255),
        cc.c3b(0xcc,0x33,0xff),
        cc.c3b(0xff,0x99,0),
    }
end



--
local colorNumToQuality = {
    "ffffff",
    "65ff73",
    "65faff",
    "ff58c2",
    "ffdb4c",
}


-- 根据品质 获取对应的颜色 c3b
function FuncCommon.getColorByQuality(quality)
    local color = colorToQuality[quality]
    if not color then
        echoError("错误的品质:", quality)
        return colorToQuality[1]
    end
    return color

end

-- 获取对应的颜色值 
function FuncCommon.getColorStrByQuality(quality)
    local color = colorNumToQuality[quality]
    if not color then
        echoError("错误的品质:", quality)
        return colorNumToQuality[1]
    end
    return color
end

function FuncCommon.dumpSystemOpen()
    dump(systemOpenData, "---systemOpenData---");
end

function FuncCommon.isSystemOpen(sysName, openCondition)

    if systemOpenData[sysName] == nil then 
        echo("error!!! ----common.SystemOpen sysName----", sysName, "is 没有配置");
        return false, 100, 1; 
    end 

    local level = UserModel:level()
    -- local openLevel = tonumber(systemOpenData[sysName].lv)
    -- openLevel = openLevel or 0
    local condition = nil

    if openCondition ~= nil then
        condition = openCondition
    else
        condition = systemOpenData[sysName].condition
    end

    local conditionType = condition[1].t
    local conditionValue = condition[1].v

    local rt = UserModel:checkCondition(condition)
    if rt == nil then
        return true, conditionValue, conditionType
    else
        return false, conditionValue, conditionType
    end
end

-- 判断是否是通用材质
function FuncCommon.isCommonTexture(texture)
    if texture == "UI_common" then
        return true
    end
    return false
end

--玩家名为空，用这个默认名字代替
function FuncCommon.getPlayerDefaultName()
	return GameConfig.getLanguage("tid_common_2001")
end

function FuncCommon.getRechargeConfig()
    return config_Recharge
end

function FuncCommon.getSysBtnOrder(sysName)
    local order = systemOpenData[sysName].orderNum;
    if order == nil then 
        echo("error!!!--common.SystemOpen orderNum--", sysName, " is nil!");
    end 
    return order or 1;
end

--随机取loading动画name
function FuncCommon.getLoadingAniName()
    math.randomseed(os.time())
    local index = math.random(1,4)
    local name = "UI_zhuanjuhua_lo"..tostring(index);
    echo("loadingAniName ========= ".. name)
    return name
end

function FuncCommon.getLeveLCondition()
    return levelConditon
end

-- todo
-- 完善数字转换方法
function FuncCommon.getCapitalNum(num)
    return FuncCommon.numMap[num]
end

-- 通过关卡Id，获取关卡星级条件
-- 1，顺利通关 2，死亡角色少于三人 4,表示回合数少于多少判定成功
function FuncCommon.getLevelStarCondition(levelId)
    local levelData = require("level.Level");
    -- 获取第一波配置
    local firstWaveData = levelData[tostring(levelId)]["1"]

    local starCondCfg = firstWaveData.starTime

    local starCondArr = {}

    for i=1,#starCondCfg do
        local condId = starCondCfg[i].type
        local condValue = starCondCfg[i].value

        local condDescTid = levelConditon[tostring(condId)].translate
        local condDescTip = nil
        if condId == 1 then
            condDescTip = GameConfig.getLanguage(condDescTid)
        elseif condId == 2 then
            if condValue == 1 then
                -- 无角色死亡
                condDescTip = GameConfig.getLanguage("#tid1555")
            else
                condDescTip = GameConfig.getLanguageWithSwap(condDescTid,FuncCommon.getCapitalNum(condValue))
            end
        elseif condId == 4 then
            condDescTip = GameConfig.getLanguageWithSwap(condDescTid,FuncCommon.getCapitalNum(condValue))
        end

        starCondArr[i] = {id = condId,tip = condDescTip}
    end

    return starCondArr
end

-- 将战斗结果值，转为星级数据
-- battleResult:战斗结果值，3位二进制表示星级及完成了哪个条件，取值范围 1-7
-- 返回值：星级star,完成的条件数组
function FuncCommon:getBattleStar(battleResult)
    local star = 0
    local condArr = {}

    local battleRt = tonumber(battleResult)
    if battleRt >= 1 and battleRt <= 7 then
        local starData = FuncCommon.battleStarCfg[battleRt]
        star = starData[1]
        -- 反转数组元素，使condArr中的条件顺序修改为从易到难
        condArr = table.reverse(starData[2])
    end

    return star,condArr
end
