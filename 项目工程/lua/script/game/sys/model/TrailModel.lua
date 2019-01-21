--guan
--todo WorldEvent.WORLDEVENT_TRAIL_RED_POINT_UPDATE 红点

local TrailModel = class("TrailModel");

TrailModel.TrailType = {
    ATTACK = 1,  --攻击
    DEFAND = 2,  --防御
    DODGE = 3,   --闪避
};

function TrailModel:ctor()

end

function TrailModel:init()
    UserModel:cacheUserData();
    EventControler:dispatchEvent(WorldEvent.WORLDEVENT_TRAIL_RED_POINT_UPDATE, false);
end

--现在某试炼类型trailKind是否开启
function TrailModel:isTrialTypeOpenCurrentTime(trailKind)

    --试炼全部开启
    return true;

    --根据时间开启
--    local serverTime = TimeControler:getServerTime();

--    local offsetHour = FuncCount.getHour(trailKind + 10);

--    echo("offsetHour " .. tostring(offsetHour));

--    local timestampOffset = -offsetHour * 60 * 60;
--    local relativeTime = serverTime + (timestampOffset or 0);
--    --relativeTime 时间是星期几
--    local dates = os.date("*t", relativeTime);

--    -- dump(dates, "--isTrialTypeOpenCurrentTime--")

--    local wday = (dates.wday - 1) % 7; --周日是第一天
--    if wday == 0 then 
--        wday = 7;
--    end 

--    local openDays = self:getTrialKindOpenDays(trailKind);

--    if table.isValueIn(openDays, wday) == true then 
--        return true;
--    else 
--        return false;
--    end 
end

--临时
function TrailModel:getTrialKindOpenDays(trailKind)
    if trailKind == 1 then 
        return {1, 4, 7};
    elseif trailKind == 2 then
        return {2, 5, 7};
    else 
        return {3, 6, 7};
    end 
end

function TrailModel:getTrialPointsByKind(trailKind)
    return UserModel:trialPoints()[tostring(trailKind)] or 0;
end

--某试炼种类的试炼难度是否开启扫荡了
function TrailModel:isSweepOpenThatKindAndLvl(trailKind, lvl)
    local id = self:getIdByTypeAndLvl(trailKind, lvl);
    local needPoint = FuncTrail.getTrailData(id, "openSweep");
    local havePoint = self:getPointsByType(trailKind);
    local haveCount = self:getLeftCounts(trailKind)
    echo(" 难度 == " .. lvl .. "  需要 == " .. needPoint .. " 已有 == " .. havePoint .. " 剩余挑战次数 == " .. haveCount .. "类型 == " .. trailKind)
    if haveCount > 0 and haveCount < self:getTotalCount() and needPoint <= havePoint then 
        return true;
    else 
        return false;
    end 
end

--某种试炼的某种等级是否达到了试炼点数
function TrailModel:isTrailPointEnough( trailKind, lvl )
    local id = self:getIdByTypeAndLvl(trailKind, lvl);
    local needPoint = FuncTrail.getTrailData(id, "openSweep");
    local havePoint = self:getPointsByType(trailKind);
    if needPoint <= havePoint then 
        return true;
    else 
        return false;
    end   
end

--某种类型的试炼 某种难度是否 解封 了
function TrailModel:isDeblockThanKindAndLvl(trailKind, lvl)
    local id = self:getIdByTypeAndLvl(trailKind, lvl);
    local isDeBlock = UserModel:trials()[tostring(id)];

    if isDeBlock == nil or isDeBlock == false or isDeBlock == 0 then 
        return false
    else 
        return true;
    end 
end

function TrailModel:getIdByTypeAndLvl(kind, lvl)
    return (kind - 1) * 5 + lvl + 3000;
end

function TrailModel:getPointsByType(kind)
    return UserModel:trialPoints()[tostring(kind)] or 0;
end

function TrailModel:getLeftCounts(kind)
   local leftTime = CountModel:getTrialCountTime(kind);
   return self:getTotalCount() - leftTime;
end

function TrailModel:isTrailOpen(kind, difficult)
    local playerLvl = UserModel:level();
    local id = self:getIdByTypeAndLvl(kind, difficult);
    local needLvl = FuncTrail.getTrailData(id, "startLevel");
    local isOpen = true;
    if playerLvl < needLvl then 
        isOpen = false;
    end 
    return isOpen, needLvl;
end 

--现在开启的试炼类型
function TrailModel:getOpenKind()
    local ret = {};
    for i = 1, 3 do
        if self:isTrialTypeOpenCurrentTime(i) == true then 
            table.insert(ret, i);
        end 
    end
    return ret;
end

function TrailModel:isRedPointShow()
    local openKind = self:getOpenKind();
    for k, kind in pairs(openKind) do
        if self:getLeftCounts(kind) > 0 then 
            return false;
        end 
    end
    return false;
end

function TrailModel:getTotalCount()
    return FuncTrail.getTotalTimes("3001");
end

return TrailModel;





















