--2016.02.12
--2016.9.7
--guan

local HomeModel = class("HomeModel");

HomeModel.REDPOINT = {
    --上面活动栏的红点
    ACTIVITY = {
        MAIL = "mail",   --邮件
        ACTIVITY = "activity",  --活动
        GIFT = "gift",  --礼物
        CHARGE = "charge",  --充值
        FIRST_CHARGE = "firstCharge",  --首冲
        HAPPY_SIGN = "happySign",       --签到
    },

    --导航栏的红点, 下面就是注释的，
    --没有这个导航了，之后要干掉
    NAVIGATION = {
    },

    NPC = {
        QUEST = FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST,
        SHOP = FuncCommon.SYSTEM_NAME.SHOP_1,
        GAMBLE = FuncCommon.SYSTEM_NAME.GAMBLE,
        LOTTERY = FuncCommon.SYSTEM_NAME.LOTTERY,
        SIGN = FuncCommon.SYSTEM_NAME.SIGN,
        SMELT = FuncCommon.SYSTEM_NAME.SMELT,
    },

    --左侧的聊天, 好友系统, 写死就2个不会变
    LEFTMARGIN = {
         FRIEND = "panel_youla.panel_1.panel_red",--好友
         CHAT = "panel_youla.panel_2.panel_red",  --聊天
    },

    DOWNBTN = {
        TREASURE = "treasure", --法宝
        CHAR = "pulse",        --主角
        GOD = "god",           --神明
        PARTNER = "partner",     --伙伴
        BAG = "bag",           --包裹
        ROMANCE = "romance",   --奇缘
        PVP = "pvp",           --挑战
        GUILD = "guild",       --公会
        WORLD = "world",       --寻仙
        EQUIPMENT = "partnerEquipment",       --装备
    },

};

function HomeModel:init()
    --作弊一下，偷偷require
    require("game.sys.func.FuncHome");
    FuncHome.init();

    self._showMap = {};
    self:registListenEvent();
    self._openSys = self:sortOpenSysByOpenLvl();

    self._romanceOpen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.ROMANCE);

end

function HomeModel:registListenEvent()
    EventControler:addEventListener(HomeEvent.RED_POINT_EVENT,
        self.redPointDateUpate, self, 10); 

    EventControler:addEventListener(TreasureEvent.OPERATION_STATE_CHANGE,
        self.treasureOperationChange, self); 

    EventControler:addEventListener(CombineEvent.OPERATION_STATE_CHANGE,
        self.combineOperationChange, self); 

    --副本通关消息 弹新功能开启界面 开奇缘
    EventControler:addEventListener(WorldEvent.WORLDEVENT_PVE_BATTLE_WIN,
        self.romanceOpenCallBack, self);   
end

--得到主城上的显示活动btn 
function HomeModel:getShowActivity()
    --得到所有活动
    --[[
        {
           sysName = {sysName = v},
           sysName = {sysName = v},
           sysName = {sysName = v}
        }
    ]]
    local allActivityArray = {};
    for k, v in pairs(HomeModel.REDPOINT.ACTIVITY) do
        allActivityArray[v] = {sysName = v};
    end

    --是不是完成首冲了 
    if HomeModel:isFinishFirstCharge() == true then 
        allActivityArray[HomeModel.REDPOINT.ACTIVITY.FIRST_CHARGE] = nil;
    end 

    --是不是完成了欢乐签到
    if HappySignModel:isHappySignFinish() == true then 
        allActivityArray[HomeModel.REDPOINT.ACTIVITY.HAPPY_SIGN] = nil;
    end 

    allActivityArray[HomeModel.REDPOINT.ACTIVITY.ACTIVITY] = nil;

    local retArray = {};
    for k, v in pairs(allActivityArray) do
        table.insert(retArray, k);
    end

    local sortFunc = function (p1, p2)
        -- echo("---p1---", p1);
        local p1Order = FuncHome.getValue(p1, "order");
        local p2Order = FuncHome.getValue(p2, "order");
        if p1Order < p2Order then 
            return true;
        else 
            return false;
        end 
    end

    table.sort(retArray, sortFunc);

    return retArray;
end

function HomeModel:romanceOpenCallBack(event)
    local raidId = event.params.raidId;

    echo("----romanceOpenCallBack-----", raidId);
    local getOpenRaidId = FuncCommon.getSysOpenData()[FuncCommon.SYSTEM_NAME.ROMANCE].condition[1].v;
    echo("----getOpenRaidId-----", getOpenRaidId);
    
    -- if tonumber(raidId) == tonumber(getOpenRaidId) and self._romanceOpen ~= true then 
    --     WindowControler:showWindow("SystemOpenView", FuncCommon.SYSTEM_NAME.ROMANCE);
    --     self._romanceOpen = true;
    -- end 
end

function HomeModel:isMainViewEventId(id)
    local nameArray = string.split(id, ".");

    if table.length(nameArray) > 1 then 
        return true;
    else 
        return false;
    end 
end

function HomeModel:isYoulaEventId(id)
    local nameArray = string.split(id, ".");

    if table.length(nameArray) > 2 then 
        return true;
    else 
        return false;
    end 
end

function HomeModel:redPointDateUpate(data)
    local id = data.params.redPointType;
    local isShow = data.params.isShow or false;

    if id ~= nil then 

        if isShow == false then 
            self._showMap[id] = isShow;
        else 
            self._showMap[id] = true;
        end 

    end 
end

function HomeModel:combineOperationChange(data)
    local isShow = data.params.isShow or false;
    local treasureTypeId = HomeModel.REDPOINT.DOWNBTN.TREASURE;

    if isShow == true then
        if self._showMap[treasureTypeId] == false or self._showMap[treasureTypeId] == nil then  
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                {redPointType = HomeModel.REDPOINT.DOWNBTN.TREASURE, isShow = true});
        end 
    else 
        if TreasuresModel:isRedPointShow() == false and 
               self._showMap[treasureTypeId] == true then 
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                {redPointType = HomeModel.REDPOINT.DOWNBTN.TREASURE, isShow = false});
        end      
    end 
end

function HomeModel:treasureOperationChange(data)
    local isShow = data.params.isShow or false;
    local treasureTypeId = HomeModel.REDPOINT.DOWNBTN.TREASURE;

    if isShow == true then
        if self._showMap[treasureTypeId] == false or self._showMap[treasureTypeId] == nil then  
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                {redPointType = HomeModel.REDPOINT.DOWNBTN.TREASURE, isShow = true});
        end 
    else 
        if CombineControl:isHaveCanCombineTreasure() == false and 
               self._showMap[treasureTypeId] == true then 
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                {redPointType = HomeModel.REDPOINT.DOWNBTN.TREASURE, isShow = false});
        end 
    end 
end

function HomeModel:redPontsDump()
    -- echo("-------------HomeModel:redPontsDump-----------");
    -- dump(self._showMap, "---self._showMap--");
end

function HomeModel:isRedPointShow(redPointType)
    return self._showMap[redPointType] == true and true or false;
end

--用于存 mathId 的 相关方法
--用于createUniqueId的书，简单递增
local IncreaseNum = 0;
--每一个matchId存活时间 单位为秒
local MatchIdSurvialTime = 5;
--最大的队列长度
local MaxQueueLength = 10;

--保存的machId双端队列, hehe 先删先进的，先显示后进的，只能存1个其实…… 
--[[
    {uniqueId = ,  matchId = },
    {uniqueId = ,  matchId = },
    {uniqueId = ,  matchId = },
]]
local matchIdDequeue = {};
local curUniqueId = nil;

function HomeModel:getCurShowUniqueId()
    return self._curUniqueId;
end

function HomeModel:setCurShowUniqueId(uniqueId)
    self._curUniqueId = uniqueId;
end

function HomeModel:getLastestMatchId()
    local tableLength = table.length(matchIdDequeue);
    if tableLength ~= 0 then
        -- dump(matchIdDequeue, "--getLastestMatchId--");
        local data = matchIdDequeue[tableLength];
        return data.matchId;
    else 
        return nil;
    end 
end

function HomeModel:getLastestUniqueId()
    local tableLength = table.length(matchIdDequeue);
    if tableLength ~= 0 then
        -- dump(matchIdDequeue, "--getLastestMatchId--");
        local data = matchIdDequeue[tableLength];
        return data.uniqueId;
    else 
        return nil;
    end 
end

function HomeModel:addMatchId(matchId)  
    --超出队列最大长度了, 删一个
    if table.length(matchIdDequeue) >= MaxQueueLength then 
        --删除最老的id 
        table.remove(matchIdDequeue, 1);
    end 

    --创建一个唯一码
    function createUniqueId( ... )
        IncreaseNum = IncreaseNum + 1; 
        return IncreaseNum;
    end

    --加入队列
    local uniqueId = createUniqueId();
    table.insert(matchIdDequeue, 
        {uniqueId = uniqueId, matchId = matchId});

    --启动计时器
    TimeControler:startOneCd(uniqueId, MatchIdSurvialTime);

    EventControler:addEventListener(uniqueId,
        self.survialMaxTimeReachCallBack, self); 
end 

function HomeModel:survialMaxTimeReachCallBack(event)
    --eventName 就是 curUniqueId
    local eventName = event.name;
    local curUniqueId = self:getCurShowUniqueId();
    -- echo('-----')
    -- echo("---survialMaxTime---", eventName);
    -- echo("---curUniqueId---", curUniqueId);

    self:deleteQueneValueByUniqueId(eventName);

    --删除这个event
    if curUniqueId == eventName then 
        --发个信号给主界面，更新 invitationMatchId  主界面响应这个
        EventControler:dispatchEvent(HomeEvent.CHANGE_INAITATION_MATCH_ID_EVENT);
    end 
end

function HomeModel:deleteQueneValueByUniqueId( uniqueId )
    for k, v in pairs(matchIdDequeue) do
        if v.uniqueId == uniqueId then
            -- matchIdDequeue[k] = nil;
            table.remove(matchIdDequeue, k);
            break;
        end
    end
end

--主动点击时候干掉的从matchIdDequeue干掉的项 matchId
function HomeModel:deleteQueneValueByMatchId( matchId )
    for k, v in pairs(matchIdDequeue) do
        if v.matchId == matchId then
            table.remove(matchIdDequeue, k);
            break;
        end
    end
end

--[[
    功能名按开启等级排序
]]
function HomeModel:sortOpenSysByOpenLvl()
    local sysOpenTable = FuncCommon.getSysOpenData();
    local ret = {};
    for sysName, value in pairs(sysOpenTable) do
        local cond = value.condition;
        if cond ~= nil and cond[1].t == 1 and cond[1].v ~= 1 then 
            table.insert(ret, {sysName = sysName, lvl = cond[1].v});
        end  
    end

    function sortTable(a, b)
        if a.lvl >= b.lvl then 
            return false;
        else 
            return true;
        end 
        return true;
    end
    table.sort(ret, sortTable);
    return ret;
end

function HomeModel:getOpenSysByNameLevel(lvl)
    for _, v in pairs(self._openSys) do
        if lvl == v.lvl then 
            return v.sysName;
        end 
    end
    return nil;
end 

function HomeModel:getWillOpenSysName()
    local playerLvl = UserModel:level();

    for _, v in pairs(self._openSys) do
        local sysOpenLvl = v.lvl;
        if sysOpenLvl > playerLvl then 
            return v.sysName, sysOpenLvl;
        end 
    end

    return;
end

function HomeModel:setOpenSysCache(cache)
    self._openSysCache = cache;
end

function HomeModel:getOpenSysCache()
    return self._openSysCache;
end

--是不是完成了首冲
function HomeModel:isFinishFirstCharge()
    if tonumber(UserModel:goldTotal()) ~= 0 and 
            tonumber(UserExtModel:firstRechargeGift()) == 1 then 
        return true;
    else 
        return false;
    end 
end

--是不是显示首冲红点
function HomeModel:isShowFirstChargeRedPoint()
    if tonumber(UserModel:goldTotal()) ~= 0 and 
            tonumber(UserExtModel:firstRechargeGift()) ~= 1 then 
        return true;
    else 
        return false;
    end 
end

return HomeModel;












