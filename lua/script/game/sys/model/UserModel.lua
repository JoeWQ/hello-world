
local UserModel = class("UserModel",BaseModel)
UserModel.USER_TYPE = {
	NORMAL = "1", --正常
	TEST = "2", --测试
}
--DataResource表
UserModel.RES_TYPE = FuncDataResource.RES_TYPE

--满足的条件
UserModel.CONDITION_TYPE = {
    LEVEL = 1,      --等级条件
    STATE = 2,      --境界    
    VIP = 3,        --vip 级别
    STAGE = 4,      --主线进度
    ELITE = 5,      --精英进度
    INTERACT = 6,        --奇缘指定NPC是否开启

}

--不知为啥要有这个，为啥不是nil？
UserModel.DEFAUTL_RID = "1";

--Player={};
function UserModel:init(d)

	self.modelName = "user"
    UserModel.super.init(self,d)
--    Player.roleInfo=d;
    self._datakeys = {
		avatar = "",                --char id
        _id = "",                   --角色ID
        --_it = "",                   --初始化时间init time
        ctime = 0,					---初始化时间戳
        uid = "",                   --账号ID
        uidMark = "",				--显示给玩家的id
        name = GameConfig.getLanguage("tid_common_2006"),              --玩家名默认是 少侠
        vip = numEncrypt:ns0(),     --VIP等级
        level = numEncrypt:ns0(),     --等级
        exp = numEncrypt:ns0(),       --经验
        state = numEncrypt:ns0(),     --境界
        quality = numEncrypt:ns1(),   --品阶

        gold = numEncrypt:ns0(),      --钻石数量（充值）
        giftGold = numEncrypt:ns0(),  --累计钻石数量（非充值)
        goldTotal = numEncrypt:ns0(), --累计钻石数量（充值）
        giftGoldTotal = numEncrypt:ns0(), --累计钻石数量（非充值)
        starLights ={},
        finance = {},               --货币

        counts = {},    --次数列表
        score = {},                   --战力表

        -- 一些列表
        states = {},                 --境界列表
        treasureFormula = {},        --防守法宝阵型

        -- server端没有的字段
        stateName = "啥是境界名称",   --境界名称
        factionName = "朱雀门",
        factionID = 123456,

        events = {},
        type = "", --用户类型，是一个逗号分割的串， "1,2,3,4" ; 1正常/2测试

        guildExt = {},
        guildId = "",

		smelts = {},  --熔炼的成就
        trials = {},
        trialPoints = {},

        -- 章节成绩等数据
        chapters = {},
        -- 快乐签到
        happySign = {},

        -- 问情
        romances = {},
        romanceInteracts = {},

        --商品购买次数
        buyProductTimes = {},

        --战力
        ability = {},
        goldConsumeCoin = 0,
    }

   self:createKeyFunc()
end

--[[
    从出生到现在一共消耗的钻石数
]]
function UserModel:totalCostGold()
    return self:giftGoldTotal() + self:goldTotal() - self:gold() - self:giftGold();
end

--登陆游戏后，所有model都初始化后执行 LoginControler:doGetUserInfoBack 中执行
function UserModel:initPlayerPower()
    self._playerPower = self:getAbility();
end

function UserModel:updatePlayerPower()
    local oldPower = self._playerPower;
    self._playerPower = self:getAbility();

    if oldPower == nil then 
        echo("warning!!! UserModel:updatePlayerPower oldPower is nil!");
    end 

    if oldPower ~= self._playerPower then 
        EventControler:dispatchEvent(UserEvent.USEREVENT_PLAYER_POWER_CHANGE, 
            {prePower = oldPower, curPower = self._playerPower}); 
    end 

    if oldPower < self._playerPower then 
        --播放动画
        FuncCommUI.showPowerChangeArmature(oldPower or 10, self._playerPower or 10);
    end 
end

function UserModel:getUserData(  )
    return self._data
end

--是否设置过名字
function UserModel:isNameInited()
	local name = self._data.name
	if name =="" or name ==nil then
		return false
	end
	return true
end
--//主角的性别,返回 1:男,2:nv
function    UserModel:sex()
    local     _id=self:avatar();
    local     _sex_map={a=1,b=2};
    local     _sex_item = FuncChar.getHeroData(_id);

    return   _sex_map[_sex_item.sex];
end
--获取用户的名字
function UserModel:name(  )
    if self._data.name =="" or not self._data.name then
        return GameConfig.getLanguage("tid_common_2001")
    end
    return  self._data.name
end

--更新data数据
function UserModel:updateData(data)
    local  old_coin=self:getCoin();
    local  _old_level=self:level();
    local  _old_exp=self:exp();
    local  _old_vip=self:vip();
    local  _old_coin=self:getCoin();
    local  _old_pluscoin=self:getPulseCoin();
    local  _old_gold = self:getGold();
    local  _old_ability=self:getAbility();
    local _old_quality = self:quality();

    UserModel.super.updateData(self, data);

    -- 发送升级消息
    if data.level ~= nil and data.level ~=_old_level and IS_SHOW_LEVEL_UP_VIEW_IMMEDIATELY == true then
        EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE, {level = data.level}); 
    end
--//exp发生变化
    if(data.exp ~=nil and data.exp ~=_old_exp)then
        EventControler:dispatchEvent(UserEvent.USEREVENT_EXP_CHANGE,{exp = data.exp});
    end
    if data.vip ~= nil and data.vip ~=_old_vip then 
        EventControler:dispatchEvent(UserEvent.USEREVENT_VIP_CHANGE, 
            {vip = data.vip}); 
    end 

--//铜钱发生变化
    if  data.finance  then
        if(data.finance.coin and  data.finance.coin ~=_old_coin)then
               EventControler:dispatchEvent(UserEvent.USEREVENT_COIN_CHANGE,{coinChange=data.finance.coin-old_coin});
        end
        --竞技场货币
        if data.finance.arenaCoin then
            EventControler:dispatchEvent(UserEvent.USEREVENT_PVP_COIN_CHANGE,data.finance.arenaCoin)
        end
    -- 真气发生更新
        if  data.finance.pulseCoin and data.finance.pulseCoin~=_old_pluscoin then
               EventControler:dispatchEvent(UserEvent.USEREVENT_PULSECOIN_CHANGE); 
        end
    end

    --仙玉变化
    if data.giftGold ~= nil or data.gold ~= nil  and (_old_gold~=(data.giftGold or 0)+(data.gold or 0))then 
        EventControler:dispatchEvent(UserEvent.USEREVENT_GOLD_CHANGE); 
    end 


    if data.chapters ~= nil then
        for k,v in pairs(data.chapters) do
            if v.stages ~= nil then
                EventControler:dispatchEvent(WorldEvent.WORLDEVENT_CHAPTER_STAGE_SCORE_UPDATE, {data.chapters}); 
            end
        end
    end

    --战力变化
    if data.ability ~= nil and data.ability.total ~= nil and (_old_ability~=data.ability.total)  then 
        self:updatePlayerPower();
    end 

    -- 主角品阶变化
    if data.quality ~= nil and (_old_quality ~= data.quality)  then 
        EventControler:dispatchEvent(UserEvent.USEREVENT_QUALITY_CHANGE); 
    end 

    EventControler:dispatchEvent(UserEvent.USEREVENT_MODEL_UPDATE);
end

--删除数据
function UserModel:deleteData( keyData ) 
    -- dump(keyData, "deleteData");
    --深度删除 key
    table.deepDelKey(self._data, keyData, 1)

    if keyData.chapters ~= nil then
        -- 从非特等变化为特等消息
        for k,v in pairs(keyData.chapters) do
            if type(v) == "table" and v.stages ~= nil then
                EventControler:dispatchEvent(WorldEvent.WORLDEVENT_CHAPTER_STAGE_SCORE_DELETE, {keyData.chapters}); 
            end
        end
    end

    EventControler:dispatchEvent(UserEvent.USEREVENT_MODEL_UPDATE);
end

-- 战斗前缓存用户数据
function UserModel:cacheUserData( ) 
    if self._cacheUserData == nil then
        self._cacheUserData = {}
    end

    self._cacheUserData.preExp = self:exp()
    self._cacheUserData.preLv = self:level()
end

-- 获取战斗前缓存数据
function UserModel:getCacheUserData( ) 
    return self._cacheUserData
end

--[[
    资源是否足够
    resTable = {[1]="1,1001,20",[2]="1,1002,20",[3]="1,1003,20",[4]="2,30009",}

    <1,1001,20;1,1002,20;1,1003,20;2,30000>配表中形态 

    都满足return true 否则返回不足的资源类型
]]
function UserModel:isResEnough(resTable)
    for _, v in pairs(resTable) do
        local needNum,hasNum,isEnough, resType = self:getResInfo(v)
        if hasNum < tonumber(needNum) then
            return resType;
        end 
    end
    return true;
end

--获取某种资源 信息, 返回5个值, 需要量, 拥有量,是否满足,资源类型,resId(如果是道具)    ------    ,resStr 格式 1,100 如果是道具  是1,10001,1,
function UserModel:getResInfo( resStr )
    if not resStr then
        echoError("没有传入资源信息")
        return 0,0,false,0
    end
    local res =  string.split(resStr, ",") 
    local resType = res[1];
    local hasNum;
    local needNum = 0;
    local resId;

    if resType == UserModel.RES_TYPE.ITEM then 
        hasNum = ItemsModel:getItemNumById(res[2]);
        resId = res[2]
        needNum = res[3];
    elseif resType == UserModel.RES_TYPE.EXP then 
        hasNum = self:exp();
        needNum = res[2];    
    elseif resType == UserModel.RES_TYPE.COIN then
        hasNum = self:getCoin();
        needNum = res[2];
    elseif resType == UserModel.RES_TYPE.DIAMOND or 
            resType == UserModel.RES_TYPE.GIFTGOLD then
        hasNum = self:getGold();
        needNum = res[2];
    elseif resType == UserModel.RES_TYPE.SP then
        hasNum = UserExtModel:sp();
        needNum = res[2];        

    --法力
    elseif resType == UserModel.RES_TYPE.MP then
        hasNum = self:getMp();
        needNum = res[2];        

    --竞技场币
    elseif resType == UserModel.RES_TYPE.ARENACOIN then
        hasNum = self:getArenaCoin();
        needNum = res[2];  
    --侠义值
    elseif resType == UserModel.RES_TYPE.CHIVALROUS then
		hasNum = self:getRescueCoin()
		needNum = res[2]
    --工会比
    elseif resType == UserModel.RES_TYPE.GUILDCOIN then
        hasNum = self:getGuildCoin();
        needNum = res[2];  

    --法宝
    elseif resType == UserModel.RES_TYPE.TREASURE then
        hasNum = 0
        resId = res[2]
        needNum = 1;  
    --灵气
    elseif resType == UserModel.RES_TYPE.PULSECOIN then
        hasNum = self:getPulseCoin()
        needNum = res[2] 
    elseif resType == UserModel.RES_TYPE.SOUL then
		hasNum = self:getSoulCoin()
		needNum = res[2]
	elseif resType == UserModel.RES_TYPE.COPPER then
		hasNum = self:getSoulCopper()
		needNum = res[2]
	--好感度
	elseif resType == UserModel.RES_TYPE.ROMANCEEXP then 
		hasNum = 0
		needNum = res[2]
    elseif resType == UserModel.RES_TYPE.TALENTPOINT then
        hasNum=UserModel:getTalentPoint();
        needNum=res[2];
    elseif resType == UserModel.RES_TYPE.HUANGTONG then
        hasNum=UserModel:getTalentPoint();
        needNum=res[2];
    else 
        hasNum = 0
        needNum =0
        --todo 继续定义
        echoError("warning! UserModel:isResEnough undefined resType " 
            .. tostring(resType));
    end
    
    needNum = needNum or 0

    --添加补丁 needNum解析出来有空字符串的情况
    if needNum == "" then
        needNum = 0
    end
    needNum = tonumber(needNum)
    local isEnough = hasNum >= needNum 
    return  needNum,hasNum,isEnough ,resType,resId
end



--判断某种条件是否满足 传入的结构  { {t= 1,v = 2 }  ,...     }  返回 不满足的类型 按照顺序 只用返回一个
function UserModel:checkCondition( conditionGroup )
    --如果没有任何开启条件的 返回true
    if not conditionGroup then
        return nil
    end
    --先解密
    conditionGroup = numEncrypt:decodeObject(conditionGroup) 
    for k,v in pairs(conditionGroup) do
        local t = v.t
        local value = v.v


        --等级判断
        if t == self.CONDITION_TYPE.LEVEL then
            if self:level() < value then
                return t
            end
        --境界是否满足
        elseif t == self.CONDITION_TYPE.STATE then
            if self:state() < value then
                return t
            end
        --vip是否达到条件
        elseif t == self.CONDITION_TYPE.VIP then
            if self:vip() < value then
                return t
            end
        elseif t == self.CONDITION_TYPE.STAGE then
            local needRaidId = value
            -- 已经完成的
            local unLockMaxRaidId = UserExtModel:getMainStageId()
            if tonumber(unLockMaxRaidId) < tonumber(needRaidId) then
                return t
            end
        elseif t == self.CONDITION_TYPE.ELITE then
            local needRaidId = value
            -- 已经完成的
            local unLockMaxRaidId = UserExtModel:getEliteStageId()
            if tonumber(unLockMaxRaidId) < tonumber(needRaidId) then
                return t
            end
        elseif t == self.CONDITION_TYPE.INTERACT then
            if not EliteModel:isOpenXiaoGuanById(value) then
                return t
            end
        end

    end

    --返回空表示满足
    return nil
end


-- 计算总战力
-- 计算公式：主角战力=【初始+等级*《星级索引出的等级成长》】+法宝战力+主角品质战力+主角技能战力+天赋战力+伙伴战力(所有伙伴战力之和)
function UserModel:getAbility()
    local charId = self:getCharId()
    local level = self:level()
    local quality = self:quality()
    
    local charAbility = 0
    -- 初始战力
    local initAbility = tonumber(FuncChar.getCharInitAbility(charId))
    -- 品阶战力
    local qualityAbility = tonumber(FuncChar.getCharQualityAbility(quality))
    -- todo
    local starRatio = 0
    -- 星级战力
    local starAbility = level * starRatio
    -- 天赋战力
    local talentAbility = 0
    -- 技能战力
    local skillAbility = 0
    -- 法宝战力
    local treasureAbility = 0
    -- 伙伴战力
    local partnerAbility = PartnerModel:getAllPartnerAbility()

    charAbility = initAbility + starAbility 
                  + treasureAbility + qualityAbility
                  + skillAbility + talentAbility 
                  + partnerAbility
    return charAbility
end

-- 获取总钻石数量
function UserModel:getGold()
    local gold = self:gold() + self:giftGold()
    return gold
end

-- 通过key，获取货币finance的二级属性
--[[
    coin                --银币
    mp                  --法力
    arenaCoin           --竞技场货币
    guildCoin           --公会声望货币
    token               --抽卡系统令牌
]]
function UserModel:getFinanceByKey(key,defaultValue)
    return self:get2d("finance",key,defaultValue)
end

-- 获取灵脉货币灵气数量
function UserModel:getPulseCoin()
    return self:getFinanceByKey("pulseCoin",0)
end

-- 熔炼宝物精华货币数量
function UserModel:getSoulCoin()
	return self:getFinanceByKey("soul", 0)
end

-- 侠义值
function UserModel:getRescueCoin()
	return self:getFinanceByKey('rescueCoin', 0)
end

--熔炼商店刷新令牌
function UserModel:getSoulCopper()
	return self:getFinanceByKey("copper", 0)
end
--//获取天赋点数
function UserModel:getTalentPoint()
   return self:getFinanceByKey("talentPoint",0);
end
-- 获取灵石(银币)数量
function UserModel:getCoin()
    return self:getFinanceByKey("coin",0)
end

-- 获取法力数量
function UserModel:getMp()
    return self:getFinanceByKey("mp",0)
end

-- 获取竞技场货币
function UserModel:getArenaCoin()
	return self:getFinanceByKey("arenaCoin",0)
end

-- 获取公会声望货币
function UserModel:getGuildCoin()
    return self:getFinanceByKey("guildCoin",0)
end

-- 获取抽卡令牌
function UserModel:getToken()
    return self:getFinanceByKey("token",0)
end
-- 获取抽卡刷新令
function UserModel:getShopToken()
    return self:getFinanceByKey("lotteryShopToken",0)
end


--花费货币的时候都走这里
--将来可能加入充值弹窗的弹出
function UserModel:tryCost(resType, needNum, isShowTip)
	local RES_TYPES = UserModel.RES_TYPE -- ==FuncDataResource.RES_TYPE
	if isShowTip==nil then
		isShowTip = true
	end
	local hasNum = 0
	local tip = nil
	local tipWindow = nil
	if resType == RES_TYPES.COIN then --金币
		hasNum = self:getCoin()
		--tip = GameConfig.getLanguage("tid_common_1006")
		tipWindow = "CompBuyCoinMainView"
	elseif resType == RES_TYPES.ARENACOIN then --竞技场货币
		hasNum = self:getArenaCoin()
		tip = GameConfig.getLanguage("tid_common_1015")
	elseif resType == RES_TYPES.DIAMOND then --钻石
		--tip = GameConfig.getLanguage("tid_common_1001")
		hasNum = self:getGold()
		tipWindow = "CompGotoRechargeView"
	elseif resType == RES_TYPES.CHIVALROUS then -- 侠义值
		hasNum = UserModel:getRescueCoin()
		tip = GameConfig.getLanguage("tid_char_1010")
	elseif resType == RES_TYPES.SOUL then --宝物精华
		hasNum = UserModel:getSoulCoin()
		tip = GameConfig.getLanguage("tid_smelt_1006")
	elseif resType == RES_TYPES.SP then --体力
		hasNum = UserExtModel:sp()
		tipWindow = "CompBuySpMainView"
	end
	local isEnough = hasNum >= needNum

	--不足并且需要tip提示不足时
	if not isEnough and isShowTip then
		if tip then
			WindowControler:showTips(tip)
		end
		if tipWindow then
			WindowControler:showWindow(tipWindow)
		end
	end
	return isEnough
end

--获取资源根据id
function UserModel:getRes(resId )
    
end

--是否为测试用户
function UserModel:isTest()
	local userType = self:type()
	local arr = string.split(userType, ',')
	if table.find(arr, UserModel.USER_TYPE.TEST) then
		return true
	end
	return false
end

--获取主角形象
function UserModel:getCharSpine(action)

end

--用户的 uid
function UserModel:uid(  )
    if self._data then
        return self._data.uid
    end

    return "111"
end


--角色id
function UserModel:rid()
    if not self._data then
        return UserModel.DEFAUTL_RID;
    end
    return self._data._id or UserModel.DEFAUTL_RID;
end

-- 主角id
function UserModel:getCharId()
    return self._data.avatar or "101"
end

-- 获取行动力上限增量
function UserModel:getSpLimit()
    local vipLevel = self:vip()
    local spLimit = FuncCommon.getVipPropByKey(vipLevel,"spLimit")
    return spLimit
end

-- 根据等级获取体力上限值
function UserModel:getMaxSpLimitByLevel(level)
    local homeCharSPBase = FuncDataSetting.getDataByConstantName("HomeCharSPBase")
    local vipSp = self:getSpLimit()
    local maxSpLimit = homeCharSPBase + level + vipSp

    return maxSpLimit
end

-- 获取最大Sp限制值
-- 计算方法：行动力结果 = 基础常量 + 虚拟主角等级 + Vip增量
function UserModel:getMaxSpLimit()
    -- local homeCharSPBase = FuncDataSetting.getDataByConstantName("HomeCharSPBase")
    -- local level = self:level()
    -- local vipSp = self:getSpLimit()
    -- local maxSpLimit = homeCharSPBase + level + vipSp
    -- return maxSpLimit

    local level = self:level()
    return self:getMaxSpLimitByLevel(level)
end


-- 获得体力最大购买次数
function UserModel:getSpMaxBuyTimes()
    local vipLevel = self:vip()
    local maxBuyTimes = FuncCommon.getVipPropByKey(vipLevel,"buyEnLimit")
    return maxBuyTimes
end


--一共可以搞多少次灵力事件
function UserModel:getTotalEventCount()
    local level = self:level();

    if level < FuncDataSetting.getDataByConstantName("HomeMPEventUnlockLevel1") then 
        return 0;
    elseif level < FuncDataSetting.getDataByConstantName("HomeMPEventUnlockLevel2") then
        return 1;
    elseif level < FuncDataSetting.getDataByConstantName("HomeMPEventUnlockLevel3") then
        return 2;
    elseif level < FuncDataSetting.getDataByConstantName("HomeMPEventUnlockLevel4") then
        return 3;
    else 
        return 4;
    end 
end

-- 获取用户法宝阵型
function UserModel:getTreasureFormula()
    local treasureFormula = self:treasureFormula()
    if treasureFormula == nil then
        treasureFormula = {}
    end

    return treasureFormula
end


--是否有新功能开启了
function UserModel:isNewSystemOpenByLevel(level)
    if FuncChar.getCharLevelUpValueByLvWithOutError(level, "level") == nil then 
        echo("isNewSystemOpenByLevel false");
        return false;
    else 
        echo("isNewSystemOpenByLevel true");
        return true;
    end 
end

--[[
    得到主角的spine形象
    animation, 主角要播放的动作 默认 stand_1
    返回 ViewSpine.new 出来的对象
]]
function UserModel:getPlayerSpineNode(animation)
    local avatar = self:avatar()
    echo("avatar " .. tostring(avatar));
    --todo checkme 若下面不加self:level()，进战斗，出战斗，白人都没了
    local spinaAni = FuncChar.getSpineAni(avatar, self:level());
    
    spinaAni:playLabel(animation or "stand_1")
    return spinaAni
end

--是否达到最大vip等级
function UserModel:isMaxVipLevel()
	local maxVipLevel = FuncCommon.getMaxVipLevel()
	local currentVip = self:vip()
	return tonumber(currentVip) >= tonumber(maxVipLevel)
end

--[[
    是否升级
]]
function UserModel:isLvlUp()
    local preLv = UserModel:getCacheUserData().preLv;
    local curLv = UserModel:level();
    if preLv ~= curLv then 
        return true;
    else 
        return false;
    end 
end


--[[
--竞技场战斗需要提供的数据
{
    level = 1,      --等级
    state =1,       --境界
    states = {      --境界归属数据
        ["1"] = {   
            advId = 1,
            points= {
                101 = {
                    id = 101,
                    level =1,
                }
            }
        },

        ["2"] = {
            ...
        }
    }
    _id = dev_29,       --id
    treasure = {
                {hid="101",state = 1,star = 1,level = 2},
                {hid="102",state = 1,star = 1,level = 2},
                {hid="103",state = 2,star = 1,level = 2},
              }, 
}
]]
function UserModel:getChannelName()
	--TODO 获取渠道名 
	local channel = "360"
	channel = "All-In"
	return channel
end

-- 获取主角穿戴法宝动画
function UserModel:getCharOnTreasure(treaHid, isWhole)
    local avatar = self:avatar()
    local level = self:level()

    avatar = "101"
    local charView = FuncChar.getCharOnTreasure(avatar,level,treaHid, isWhole)
    return charView
end

return UserModel




