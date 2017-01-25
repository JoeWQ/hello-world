--
-- Author: xd
-- Date: 2016-01-14 18:06:21
--

--邮件信息
--[[
	 1 = {
[LUA-print] -                     "delTime"  = 1455165575
[LUA-print] -                     "get"      = 0
[LUA-print] -                     "param" = {
[LUA-print] -                         1 = "dev_30"
[LUA-print] -                         2 = 20001
[LUA-print] -                         3 = 11369
[LUA-print] -                     }
[LUA-print] -                     "personal" = 1
[LUA-print] -                     "reward" = {
[LUA-print] -                         1 = "3,100001"
[LUA-print] -                     }
[LUA-print] -                     "sendTime" = 1452573575
[LUA-print] -                     "tempId"   = 2
[LUA-print] -                 }

]]


--邮件model管理器
local MailModel  = class("MailModel ", BaseModel )

function MailModel:init( d )
    --延时发放邮件
    local data = self:updataBySendtime(d)
    -- 检查错误信息
    local _mail = self:checkErrorMailAll(data)
    -- 检查邮件是否超时
    local _mails = self:updataByDeleteTime(_mail)
	MailModel.super.init(self,_mails)
	self:checkShowRed()
end

function MailModel:checkErrorMailAll(data)
    local  mails = {};
    for i,v in pairs(data) do
        local isRight = true
        if v.reward then
            for m ,n in pairs(v.reward) do
                if not self:checkErrorMail(n) then
                    isRight = false
                    break
                end
            end
        end     
        if isRight then
            table.insert(mails,v)
        end
    end
    return mails
end

function MailModel:checkErrorMail(reward)
 
    local data = string.split(reward,",")
    local rewardType = data[1]
    local rewardId = nil

    -- 如果奖品是道具
    if tostring(rewardType) == UserModel.RES_TYPE.ITEM then
        rewardId = data[2]
    -- 奖品为非道具资源
    else
        -- 如果奖品是法宝
        if tostring(rewardType) == UserModel.RES_TYPE.TREASURE then
            rewardId = data[2]
        else
            rewardNum = data[2]
        end

        ---- 非道具类型资源，将道具id设置为nil
        rewardId = "feiziyuan"
    end
    if rewardId ~= "feiziyuan"  then
        local alltreasureData = FuncTreasure.getTreasureAllConfig()
        local t = alltreasureData[tostring(rewardId)];
        if t then
            return true
        else
            echoWarn ("error no find rewardType" .. rewardId)
            return false
        end
    end
    return true
end

function MailModel:updataBySendtime(d)
    self._hideData = {}
    if d then
      local data = {}
      for i,v in pairs(d) do
           if v.sendTime <= TimeControler:getServerTime()  then 
              table.insert(data,v)
           else
               table.insert(self._hideData,v)
               --实现一个倒计时的方法
               local _upDataMail = function ()
                   for k,n in pairs(self._hideData) do
                       if n.sendTime <= TimeControler:getServerTime() then
                           table.insert(self:data(),n)
                           table.remove(self._hideData,k)
                       end
                   end
                   self:checkShowRed()
               end
               WindowControler:globalDelayCall(c_func( _upDataMail),v.sendTime-TimeControler:getServerTime() )
           end
      end
      return data
    end
    return d
end
function MailModel:updataByDeleteTime(d)
    local delData = {}
    if d then
      self.willDellData = {}
      for i,v in pairs(d) do
           if v.delTime <= TimeControler:getServerTime()  then  -- 应该删除
              --
           else
               table.insert(self.willDellData,v)
               --实现一个倒计时的方法
               local _upDataMail = function ()
                   local data = {}
                   for k,n in pairs(self.willDellData) do
                       if n.delTime <= TimeControler:getServerTime() then
                           -- 删除此邮件
                       else
                           table.insert(data,n)
                       end
                   end
--                   self:setData(data)
                   self:updateData( data )
                   self:checkShowRed()
               end
               WindowControler:globalDelayCall(c_func( _upDataMail),v.delTime-TimeControler:getServerTime() )
           end
      end
      return self.willDellData
    end
    return d
end

 
--更新邮件
function MailModel:updateData( data )
	self:init(data)
	EventControler:dispatchEvent(MailEvent.MAILEVENT_UPDATEMAIL)
end


--邮件排序
function MailModel:getSortMail(  )
	local mails = table.copy( self:data() )

	--[[
		1.	邮件的排列顺序按照收件时间排列，收件时间由早到晚，由下至上排列 
		2.	未读邮件优先级大于已读邮件
		3.	同为未读，奖励类邮件排列优先级大于通知类邮件
		4.	未读邮件读取后变为已读邮件，位置置底（无需实时）
	]]
	-- read,sendTime,reward
	local sortFunc = function ( mail1,mail2 )


		local isReward1 = mail1.reward and 1 or 0
		local isReward2 = mail2.reward and 1 or 0

		local read1 = mail1.read or 0
		local read2 = mail2.read or 0


		if isReward1 > isReward2 then
			return true

		elseif isReward1 == isReward2 then
			if(read1 < read2 ) then 
				return true
			
			elseif  read1 == read2 then
				return mail1.sendTime > mail2.sendTime

			else
				return false

			end



			--邮件时间 越晚  越靠上
			-- if mail1.sendTime > mail2.sendTime then
			-- 	return true

			-- elseif mail1.sendTime == mail2.sendTime then
			-- 	local isReward1 = mail1.reward and 1 or 0
			-- 	local isReward2 = mail2.reward and 1 or 0
			-- 	return isReward1 > isReward2
			-- end
			-- return false


		else
			return false

		end

	end

	table.sort( mails, sortFunc )
	return mails

end


--判断是否显示小红点
function MailModel:checkShowRed(  )
	local data = self:data()
	local showRed = false
	for i,v in pairs(data) do
		if v.read ~= 1 then
			showRed = true
			break
		end

		if v.reward then
			showRed = true
			break
		end

	end
	--发送邮件小红点
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
  	 {redPointType = HomeModel.REDPOINT.ACTIVITY.MAIL, isShow = showRed});
	
end


--read一个邮件
function MailModel:readMail( mailId )
	local data = self:data()

	for k,v in pairs(data) do
		if v._id == mailId then
			local mailInfo = v
			if mailInfo then
				mailInfo.read = 1
			end
		end
	end

	self:checkShowRed()

end




--删除邮件 也用一样的 方法
function MailModel:deleteData( keydata )
	MailModel.super.deleteData(self,keydata)
	EventControler:dispatchEvent(MailEvent.MAILEVENT_DELMAIL)
	self:checkShowRed()
end


function MailModel:deleteMail( mailId )
	for i=#self._data,1,-1 do
		local info = self._data[i]
		if info._id ==mailId then
			table.remove(self._data,i)
		end
	end
	self:checkShowRed()
	EventControler:dispatchEvent(MailEvent.MAILEVENT_DELMAIL)
end


return MailModel 