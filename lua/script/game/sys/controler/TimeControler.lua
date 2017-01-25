--
-- Author: xd
-- Date: 2015-12-08 19:59:02
--
local TimeControler={}

TimeControler.timeType_mmss = 1				--获取 分分:秒秒的格式的时间
TimeControler.timeType_hhmmss = 2				--获取 时时:分分:秒秒的格式的时间
TimeControler.timeType_dhhmmss = 3			--获取 天 时时:分分:秒秒的格式的时间
TimeControler.timeType_dhhmm = 4				--获取 天 时时:分分的格式的时间
TimeControler.timeType_hhmm = 5 				--获取时时分分格式

--时区这个宏要与 c 那一致
TimeControler.TIME_ZONE = {
	GMT8 = 0, --北京
	--other
}

--时差秒数 这个 可能根据不同语言版本计算不同时差 --如果要通过取余计算当天的小时数 需要加上这个时差取余才能得到正确结果 
TimeControler.timeDifference = 8*3600  				

--记录一些cd的剩余时间 以秒为单位  用小数存储,考虑到切换后台在切换回来的时间差 ,用get方法返回的时候 向上取整
TimeControler._cdObj  = nil			


TimeControler._hasgesitTime =false

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
--计时器刷新
function TimeControler:init(  )

	--获取系统时间  这个是精确到秒的
	
	if not self._time then
		self._time = self:getTime()
	end
	self._cdObj = {}
	--初始化为true --因为在没有登入的时候 是 不需要开始计时的 这个时候 游戏从后台切换回来 不需要做任何处理
	self._hasinit = true

	

	--这里配置所有的 时间恢复事件
	self._eventObj = {
		[TimeEvent.TIMEEVENT_ONSP]= { 
		 	delay =  FuncDataSetting.getDataByConstantName("HomeSPRecoverSpeed")  ,		--体力恢复间隔 6分钟
		 	--func = c_func(dispatch, TimeEvent.TIMEEVENT_ONSP) ,
		 },

		["testMofa"] ={ 
			delay = 10,  				--测试魔法恢复时间 5秒一次
		  	--func = c_func(dispatch, "testMofa"), 
		},
	}

	self:restartCountTime()

	EventControler:addEventListener(SystemEvent.SYSTEMEVENT_APPENTERFOREGROUND   ,self. onEnterForeground, self)

	--scheduler.scheduleGlobal(c_func(self.updatePerSecond, self), 1)

	if not self._hasgesitTime then

		local requestFunc = function (  )
			
			if Server:checkIsSending() then
				return
			end
			Server:sendRequest({}, MethodCode.sys_heartBeat, nil, true, true)
		end

		self._heartbeatId = scheduler.scheduleGlobal(requestFunc,20)
		self._hasgesitTime = true
	end


	--注册全局计时
	self._updateId = scheduler.scheduleGlobal(c_func(self.registerTimeUpdate,self),1)

	--定时发事件
	self:addStaticTimeRegister();
	self:initToFireStaticTimeReachEvent();
end
--注册周期回调
function TimeControler:registerCycleCall(_event,_delay)
    self._eventObj[_event] = {delay = _delay,}
end
--注册全局刷新计时
function TimeControler:registerTimeUpdate( )
	self._time = self._time +1
	--同时更新下 带毫秒的时间
	self._miliTime = self._miliTime  + 1000
	for k,v in pairs(self._cdObj) do
		local leftTime = v
		if leftTime > 0 then
			leftTime = leftTime -1
			self._cdObj[k] = leftTime
			if leftTime <=0 then
				--销毁掉这个cdObj
				self._cdObj[k] = nil;
				--那么发送这个消息,表示时间到了
				--先销毁再发事件，因为发事件有可能再次注册这个事件 guan
				EventControler:dispatchEvent(k)
			end
		end
	end

	local yushu = self._time % 10
	if yushu == 0 then
		if not BattleControler:isInBattle() then
			WindowControler:clearUnusedTexture()
		end
	--10秒做一次垃圾回收 非战斗
	elseif yushu == 5 then
		if BattleControler and BattleControler:isInBattle() then
		else
			local t1 = os.clock() 
			collectgarbage("collect")
			if DEBUG > 0 then
				-- echo(os.clock() - t1,"_执行一次垃圾回收时间")
			end
			
		end
		
	end




end



--切换回来
function TimeControler:onEnterForeground(e )
	if not self._hasinit then
		return
	end

	--清除所有倒计时
	self:clearAllCount()

	local time = self:getServerTime()

	local dt = math.floor(e.params.dt)
	local lastTime = time - dt

	--计算应该恢复多少次体力
	for k,v in pairs(self._eventObj) do
		local ts = self:countIntervalTimes(v.delay,lastTime,time)
		--echo(ts,lastTime,time,time-lastTime,v.delay,e.params.dt)
		--如果ts 大于0 那么恢复 ts秒
		if ts > 0 then
			--echo(ts,"___ts______")
			self:dispatchEvent(k, ts)
		end
	end


	--同步时间戳
	self._time = self._time + dt

	--更新一些倒计时
	for k,v in pairs(self._cdObj) do
		local leftTime = v- dt
		if leftTime <=0 then
			--通知时间到了
			EventControler:dispatchEvent(k)
			leftTime =0
		end
		self._cdObj[k] = leftTime
	end


	--重起计时器
	self:restartCountTime()


	--延迟几帧 判断是否需要获取邮件列表 因为这个时候可能掉线了
	local checkMaill = function (  )
		if LoginControler:isLogin() then
			MailServer:requestMail(  )
		end
	end

	WindowControler:globalDelayCall(checkMaill, 0.1)
	

end




--测试刷新以及获取剩余时间计时  测试发现  dt每次的值都是大于1的 接近 1.003左右  但是当游戏切入到后台的时候 时间就不准了
function TimeControler:updatePerSecond( dt)
	
	--echo(self:getLeftResumeTime(TimeEvent.TIMEEVENT_ONSP),"____ leftTime",e)
end




--清除所有的计时器
function TimeControler:clearAllCount(  )
	if not self._eventObj then return end
	for k,v in pairs(self._eventObj) do
		if v.delayId then
			scheduler.unscheduleGlobal(v.delayId)
		end
		
		if v.funcId then
			scheduler.unscheduleGlobal(v.funcId)
		end
	end
end




--重启计时器
function TimeControler:restartCountTime( )

	if not self._hasinit then
		return
	end
	local time = self:getServerTime()


	local schedulerFunc = function (info,eventName )
		self:dispatchEvent(self,eventName,1)
		info.funcId = scheduler.scheduleGlobal(c_func(self.dispatchEvent,self, eventName,1),info.delay)
	end

	--根据这个时间  来分别判断 需要延迟多久开始计时 为了计算更精准
	for k,v in pairs(self._eventObj) do
		local delay = v.delay
		delay = time % delay
		delay = v.delay - delay
		v.delayId =  scheduler.performWithDelayGlobal( c_func(schedulerFunc,v,k ) ,delay  )
	end

end

--发送恢复事件和次数
function TimeControler:dispatchEvent( eventName,times )
	times = times or 1
	--echo(eventName,"____times:",times)
	EventControler:dispatchEvent(eventName,times)
end


--获取剩余刷新时间 接口   返回的是以秒为单位的时间 

--[[

timeType 获取时间类型  如果不传类型 那么返回的是秒数

]]
function TimeControler:getLeftResumeTime(eventName  ,timeType )
	local t = self:getServerTime()
	if not self._eventObj[eventName] then
		echo("TimeControler","错误的事件类型:",eventName)
		return 0
	end
	local delay = self._eventObj[eventName].delay
	local result = t%delay
	if (result ~= 0) then 
		result = delay - result
	end
	return self:turnTimeSec(result)

end

--转换时间描述
function TimeControler:turnTimeSec( second,timeType )
	if not timeType then
		return second

	elseif timeType == self.timeType_mmss then
		return fmtSecToMMSS(second)

	elseif timeType ==self.timeType_hhmmss then
		return fmtSecToHHMMSS(second)

	elseif timeType ==self.timeType_dhhmm then
		return fmtSecToLnDHM(second)

	elseif timeType == self.timeType_dhhmmss then
		return fmtSecToLnDHHMMSS(second)
	elseif timeType == self.timeType_hhmm then
		return fmtSecToHHMM(second)
	end

	return  second
end


--同步服务器时间
function TimeControler:updateServerTime( time,timeType )
	self._time = math.floor( time/1000 )
	--毫秒
	self._milisecond = time % 1000
	self._miliTime = time 	--带毫秒的时间戳
end

--设置时区
function TimeControler:setTimeZone(tz)
	pc.PCUtils:setTimeZone(tz);
end

--获取毫秒
function TimeControler:getMiliSecond(  )
	return self._milisecond
end


--计算时间戳差值 恢复次数  比如 上次
--[[
	interval 时间间隔 以秒为单位
	lastTime 上次更新时间 以秒为单位的时间戳
	currentTime 如果为空 表示取当前系统时间

]]
function TimeControler:countIntervalTimes(interval ,lastTime,currentTime )
	local usec
	if not currentTime then
		currentTime,usec = pc.PCUtils:getMicroTime()
	end

	lastTime = lastTime - lastTime % interval

	currentTime = currentTime - currentTime % interval



	local dx = currentTime -lastTime
	if dx < 0 then
		dx =0
	end

	local times = math.floor(dx/interval)
	return times


end




--[[

	cd 相关


]]

--timeType  获取时间描述类型 不传递 表示 获取剩余秒数
-- 1 2 3 4对应 四种  描述格式
function TimeControler:getCdLeftime( cdName ,timeType)
	local sec = self._cdObj[cdName]
	sec = sec or 0
	sec = math.floor(sec)
	return self:turnTimeSec(sec, timeType)
end



--开始一个cd 计时   cdName 对应 TimeEvent的某个cdkey, leftTime 表示开始时的剩余时间
--时间到了之后会发送一个 cd到了的事件

--示例 比如  TimeControler:startOneCd(TimeEvent.TimeEvent.TIMEEVENT_CDPVP,5*60) --每当挑战一次jjc以后 的剩余cd
function TimeControler:startOneCd( cdName,leftTime )
	self._cdObj[cdName] = leftTime
end




--计算下一次刷新时间 传递的是 配置表里面配的时间 
function TimeControler:countNextRefreshTime( m,h,w,j )
	-- local timeObj = os.date(self:getServerTime())
	local date = os.date("*t",self:getServerTime())
	-- local dateStr =date.year.."-"..date.month .."-"..date.day.." " ..date.hour ..":" ..date.min
	--从大到小判断
	--如果有月份中的第几天,比如签到
	local day

	--
	local resultTimeObj = table.copy(date)
	resultTimeObj.min = 0 
	resultTimeObj.sec = 0
	resultTimeObj.hour = 0

	local second = 0
	--判断是否已经是下一天了
	if m ~= "*"  then
		second = toint(m) * 60
		resultTimeObj.min = toint(m)
	end

	if h~= "*" then
		second = second + toint(h) * 3600
		resultTimeObj.hour = toint(h)
	end

	--判断当天是否过期了 那么计算时间需要从明天开始计算
	if date.hour * 3600 + date.min * 60 + date.sec > second then
		resultTimeObj.day = resultTimeObj.day + 1
		resultTimeObj.wday = resultTimeObj.wday+1
		if resultTimeObj.wday == 8 then
			resultTimeObj.wday =1
		end
	end




	if j ~= "*" then
		day = toint(j)
		--如果当前天数小于 日期	
		if resultTimeObj.day <= day then
			resultTimeObj.day = day
		else
			--那么说明是下一个月的
			resultTimeObj.day = day
			resultTimeObj.month = resultTimeObj.month +1
			--如果是明年的
			if resultTimeObj.month == 13 then
				resultTimeObj.month = 1
				resultTimeObj.year = resultTimeObj.year+1
			end
		end

	--如果是星期几
	elseif w ~="*" then
		--todo
		local wday = toint(w)
		wday = wday +1
		if wday ==8 then
			wday =1
		end
		--如果小于当前星期
		if wday < resultTimeObj.wday then
			resultTimeObj.day = resultTimeObj.day + (wday + 7 - resultTimeObj.wday)
		else
			resultTimeObj.day = resultTimeObj.day + (wday  - resultTimeObj.wday)
		end
		echo("wday",wday,"resultTimeObj.wday",resultTimeObj.wday)
	end

	local time = os.time(resultTimeObj)
	
	return time
end

--返回2个值  一个是秒的时间戳 一个是 6位的 1-999999之间的  微秒数
function TimeControler:getTime( )
	local time,usec = pc.PCUtils:getMicroTime()
	if not self._time then
		self._time = time
	end
	return self._time,usec
end


--获取本地时间 一个是秒的时间戳 一个是 6位的 1-999999之间的  微秒数
function TimeControler:getLocalTime( )
	return pc.PCUtils:getMicroTime()
end


--获取服务器时间
function TimeControler:getServerTime(  )
	if not self._hasinit then
		return pc.PCUtils:getMicroTime()
	end
	return math.round(self._time)
end


--获取带毫秒的服务器时间
function TimeControler:getServerMiliTime(  )
	return self._miliTime
end


--获取微秒
function TimeControler:getUsec(  )
	local _,usec =  pc.PCUtils:getMicroTime()
	return usec
end

--获取次日时间戳
function TimeControler:getNextDayTime(  )
	
end

--销毁计时器
function TimeControler:deleteMe(  )
	self:clearAllCount()
	--清除所有事件
	EventControler:clearOneObjEvent(self)
end

local daySecond = 86400;

function TimeControler:initToFireStaticTimeReachEvent()

	function convertToSecond(time)
		local splitTime = string.split(time, ":");
		
		local hour = tonumber(splitTime[1]);
		local minute = tonumber(splitTime[2]);
		local second = tonumber(splitTime[3]);

		local passTime = hour * 60 * 60 + minute * 60 + second;

		return passTime
	end

	local dates = os.date("*t", self:getServerTime());
	local todayTime = dates.hour * 60 * 60 + dates.min * 60 + dates.sec;

	for k, staticTime in pairs(GameVars.fireEventTime) do
		local targetSceond = convertToSecond(staticTime);
		local timeStr =  self:gsubColonStringToNil(staticTime);

		local leftTime = 0;
		if todayTime >= targetSceond then 
			--时间过了，明天继续
			leftTime = targetSceond + daySecond - todayTime;
		else 
			leftTime = targetSceond - todayTime;
		end 
		self:startOneCd(self:getEventName(timeStr), leftTime);

	end

end

function TimeControler:gsubColonStringToNil(str)
	return string.gsub(str, ":", "")
end

--注册事件，明天继续发
function TimeControler:addStaticTimeRegister()
	for k, staticTime in pairs(GameVars.fireEventTime) do
		local str = TimeControler:gsubColonStringToNil(staticTime);
		EventControler:addEventListener(self:getEventName(str), 
        	self.reRegisterStaticTime, self);
	end
end

function TimeControler:reRegisterStaticTime(event)
	
	function getStaticTime( eventName )
		local len = string.len(eventName);
		local strLasts = string.sub(eventName, len - 5, len);
		local hour = string.sub(strLasts, 1, 2);
		local minute = string.sub(strLasts, 3, 4);
		local second = string.sub(strLasts, 5, 6);
		return hour .. ":" .. minute .. ":" .. second;
	end

	local eventName = event.name;
	local staticTime = getStaticTime(eventName);

	-- echo("reRegisterStaticTime " .. tostring(event.name));
	-- echo("staticTime " .. tostring(staticTime));

	local timeStr =  self:gsubColonStringToNil(staticTime);

	self:startOneCd(self:getEventName(timeStr), daySecond);

    EventControler:dispatchEvent(TimeEvent.TIMEEVENT_STATIC_CLOCK_REACH_EVENT, 
        {clock = staticTime});
end

function TimeControler:getEventName(timeStr)
	return "TIMEEVENT_STATIC_TIME_REACH_" .. tostring(timeStr);
end

function TimeControler:destroyData()
	self:clearAllCount()
	self._hasinit = false
	self._time = nil
	self._cdObj = nil
	self._hasgesitTime = false
	if self._updateId then
		scheduler.unscheduleGlobal(self._updateId)
	end
	if self._heartbeatId then
		scheduler.unscheduleGlobal(self._heartbeatId)
	end
end

--测试代码
-- local defChar = "*"

-- local nextTime = TimeControler:countNextRefreshTime( 35,15,defChar,2 )
-- local data = os.date("*t", nextTime)
-- dump(data,'__data')

return TimeControler
