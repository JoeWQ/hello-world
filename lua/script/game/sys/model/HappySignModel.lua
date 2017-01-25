--
-- Author: zq
-- Date: 2016-8-15 18:06:21
--




local HappySignModel  = class("HappySignModel ", BaseModel )

function HappySignModel:init( d )
    self._signedId = {}
    if d.receiveDays then
        self._signedId = number.splitByNum(d.receiveDays,2) --已签到的天数
    end
   
    self._onlinedDays = d.onlineDays

	self:checkShowRed()	
    
end

function HappySignModel:updateData(d)
    HappySignModel.super.updateData(self, d)
    if d.receiveDays then
        self._signedId = number.splitByNum(d.receiveDays,2) --已签到的天数
    end
    if d.onlineDays then
        self._onlinedDays = d.onlineDays   
    end

	self:checkShowRed()
    
--   EventControler:dispatchEvent(HappySignEvent.RED_POINT_EVENT,{show = self:checkShowRed()})
end

--排序
function HappySignModel:getSortItems( )
    local allData = FuncHappySign.getHappySignData()
    local _allDataSigned = {} --已经签到的
    local _allData = {} -- 还没签到
    for i,v in pairs(allData) do
        if self:isHappySign(v.hid) then
            v.isSign = true
            table.insert(_allDataSigned,v)
        else
            v.isSign = false
            table.insert(_allData,v)
        end
    end
    
	function comps(a,b)
        return tonumber(a.hid) < tonumber(b.hid)
    end
    table.sort(_allData,comps);
    table.sort(_allDataSigned,comps);

    for i,v in pairs(_allDataSigned) do
        table.insert(_allData,v)
    end
    
    return _allData;
end


--判断是否显示小红点
function HappySignModel:checkShowRed(  )
	local redPoint = false
    for i = 1,self._onlinedDays do
        if self._signedId[i] == nil or self._signedId[i] == 0 then
            redPoint = true
            break
        end
    end
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
        {redPointType = HomeModel.REDPOINT.ACTIVITY.HAPPY_SIGN, isShow = redPoint});

    --发送都签完了消息
    if self:isHappySignFinish() == true then 
        EventControler:dispatchEvent(HappySignEvent.FINISH_ALL_SIGN_EVENT, {});
    end 
end

--判断是否全部领取
function HappySignModel:isHappySignFinish( )
    for i = 1, 14 do
        if self._signedId[i] == 0 or self._signedId[i] == nil then
            return false
        end
    end

    return true
    
end
-- 判断 是否已签过
function HappySignModel:isHappySign( itemId )
    local a = self._signedId[tonumber(itemId)]
    if a == nil then
       a = 0
    end
	return a > 0
end
-- 再登陆几天 可领取
function HappySignModel:willSignDayNums(itemId)
     return tonumber(itemId) - tonumber(self._onlinedDays)
end

--
function HappySignModel:isCanSignForHome()
     
end

--判断 是否可以签到
function HappySignModel:canHappySign( itemId )
	return _yuan3(tonumber(self._onlinedDays) >= tonumber(itemId),true,false)
end

function HappySignModel:setHappySignId( itemId )
	self._signedId[tonumber(itemId)] = 1

end



return HappySignModel 