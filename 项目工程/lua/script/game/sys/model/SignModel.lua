--guan
--2016.1.22

local SignModel = class("SignModel");

function SignModel:ctor()

end

function SignModel:init()
    --vip等级发生变化
    EventControler:addEventListener(UserEvent.USEREVENT_VIP_CHANGE, 
        self.vipChange, self)  
	
    EventControler:addEventListener(InitEvent.INITEVENT_FUNC_INIT, self.onFuncInit, self)  
end

function SignModel:onFuncInit(event)
	local params = event.params
	local funcname = params.funcname
	if funcname ~= "FuncSign" then
		return
	end
    self:homeRedPointCheck();
end

SignModel.Month30Days = {4,6,9,11};
SignModel.Month31Days = {1,3,5,7,8,10,12};

function SignModel:homeRedPointCheck()
    if self:isHomeSignRedPointShow() == true then 
        --echo("发送签到消息----------")
        EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            {redPointType = HomeModel.REDPOINT.NPC.SIGN, isShow = true})

        -- EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
        --     {redPointType = HomeModel.REDPOINT.ACTIVITY.SIGN, isShow = true}); 
    else 
        --echo("发送签到消息----------")
        EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            {redPointType = HomeModel.REDPOINT.NPC.SIGN, isShow = false})
         -- EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
         --    {redPointType = HomeModel.REDPOINT.ACTIVITY.SIGN, isShow = false});        
    end 
end

function SignModel:vipChange( )
    self:homeRedPointCheck();
end

--[[
    参数是时间戳偏移，比如三点刷新
]]
function SignModel:getDayNumInCurrentMonth()
    local year, month = self:getYearAndMonth();
    local totalDays = 0;

    if table.isValueIn(SignModel.Month30Days, month) == true then 
        totalDays = 30;
    elseif table.isValueIn(SignModel.Month31Days, month) == true then 
        totalDays =  31;
    else 
        if year % 4 == 0 then 
            totalDays = 29;
        else 
            totalDays = 28;
        end 
    end 

    return totalDays;
end

function SignModel:getYearAndMonth()
    local serverTime = TimeControler:getServerTime();
    --todo 读表3
    local timestampOffset = -5 * 60 * 60;
    local relativeTime = serverTime + (timestampOffset or 0);
    --几月
    local dates = os.date("*t", relativeTime);
    local month = dates.month;
    local year = dates.year;
    return year, month;
end

--当月所有签到资源
function SignModel:getSignItems()
    local days = self:getDayNumInCurrentMonth();
    local year, month = self:getYearAndMonth();
    local data = {};
    for i = 1, days do
        local t = {};
        t.vip = FuncSign.getMonthValue(year, month, i, "vip");
        t.reward = FuncSign.getMonthValue(year, month, i, "reward");
        t.index = i;
        table.insert(data, t);
    end
    return data;
end

--今天签没签到
function SignModel:todaySignCount()
    local Count = UserModel:counts()["9"];
    if Count == nil then 
        return 0;
    else 
        return Count.count;
    end 
end

--这个月总共签到次数
function SignModel:monthSignCount()
    local Count = UserModel:counts()["10"];
    if Count == nil then 
        return 0;
    else 

        return Count.count;
    end
end

--从出生一直签到的次数
function SignModel:totalSignCount()
    return UserExtModel:totalSignDays() or 0;
end

--本次的奖励
function SignModel:curTotalSignReward()
    local targetKey = self:curTotalSignTargetDayCount();
    return FuncSign.getTotalSign(targetKey, "reward");
end

--本次累计签到目标天数
function SignModel:curTotalSignTargetDayCount()
    local preSignTargetDayCount = UserExtModel:totalSignDaysReceive() or 0;
    --0echo("ssssssssssssssssssssss",preSignTargetDayCount,"=============")
    return FuncSign.getNextDay(preSignTargetDayCount);
end


--获取真是的累积签到目标天数
function SignModel:getRealTotalSignTargetDay(  )
    local preSignTargetDayCount = UserExtModel:totalSignDaysReceive() or 0
    return FuncSign.getNextRealDay(preSignTargetDayCount)
end

--今天需要多少vip等级
function SignModel:curNeedVip()
    local year, month = self:getYearAndMonth();

    local day = self:todaySignIndex();
    
    return FuncSign.getMonthValue(year, month, day, "vip") or 0;
end

--今天是这个月第几次签到
function SignModel:todaySignIndex()
    local monthTotal = self:monthSignCount();
    local day = monthTotal + 1;
    if self:todaySignCount() ~= 0 then
        day = day - 1;
    end 
    return day;
end

function SignModel:todayReward()
    local index = SignModel:todaySignIndex();
    local listData = SignModel:getSignItems();
    
    return listData[index];
end

function SignModel:isDayRedPointShow()
    local ret = false;
    --没有签到
    if self:todaySignCount() == 0 then 
        ret = true;
    elseif self:todaySignCount() == 1 then
        --签到一次
        if SignModel:curNeedVip() == 0 then 
            --不需要vip
            ret = false;
        else 
            --需要vip
            if self:curNeedVip() <= UserModel:vip() then 
                --vip够
                ret = true;
            else 
                ret = false;
            end 
        end 
    else  
        ret = false;
    end  

    return ret;
end

function SignModel:isTotalRedPointShow()
    local totalSign = self:totalSignCount();
    local targetCount = self:getRealTotalSignTargetDay();

    if totalSign < targetCount then 
        return false;
    else 
        return true;
    end   
end

function SignModel:isHomeSignRedPointShow()
    if self:isTotalRedPointShow() == true or 
        self:isDayRedPointShow() == true then 
        return true;
    else 
        return false;
    end 
end

return SignModel;





















