local ActivityRecord = class("ActivityRecord")

function ActivityRecord:init(data)
	self.data = data
end

function ActivityRecord:getActId()
	return self.data.actInfo.id
end

function ActivityRecord:getActInfo()
	return self.data.actInfo
end

function ActivityRecord:getTimeInfo()
	return self.data.timeInfo
end

function ActivityRecord:getDisplayLeftTime()
	local timeInfo = self:getTimeInfo()
	local now = TimeControler:getServerTime()
	local left = timeInfo.show_end_t - now
	if left <0 then
		left =0
	end
	return left
end

function ActivityRecord:getSortOrder()
	return self.data.actInfo.order
end

function ActivityRecord:getActTitle()
	return GameConfig.getLanguage(self.data.actInfo.title)
end

function ActivityRecord:getActDesc()
	return GameConfig.getLanguage(self.data.actInfo.desc)
end

--活动在开启期间
function ActivityRecord:isActInActivePeriod()
	local now = TimeControler:getServerTime()
	local timeInfo = self:getTimeInfo()
	return now >= timeInfo.start_t and now <= timeInfo.end_t
end

function ActivityRecord:isActInShowPeroid()
	local now = TimeControler:getServerTime()
	local timeInfo = self:getTimeInfo()
	return now>= timeInfo.show_start_t and now < timeInfo.show_end_t
end

function ActivityRecord:isActCanReceiveAfterEnd()
	return FuncActivity.isDisplayedActCanReceiveAfterActEnd(self:getOnlineId())
end

function ActivityRecord:getActIcon()
	return self.data.actInfo.icon
end

function ActivityRecord:getActType()
	return self.data.actType
end

function ActivityRecord:getOnlineId()
	return self.data.onlineInfo.id
end

function ActivityRecord:getDisplayedTaskIds()
	local ids = FuncActivity.getActDisplayedTaskIds(self.data.actInfo.id)
	return ids
end

--是否有可做的内容，用于显示小红点
function ActivityRecord:hasTodoThings()
	if self:getActType() == FuncActivity.ACT_TYPE.EXCHANGE then
		return false
	end
	local isActActive = self:isActInActivePeriod()
	if not isActActive and not self:isActCanReceiveAfterEnd() then
		return false
	end
	local ids = self:getDisplayedTaskIds()
	local hasTodo = false
	for _, taskId in pairs(ids) do
		local onlineId = self:getOnlineId()
		local conditionOk = ActConditionModel:isTaskConditionOk(onlineId, taskId, self:getActType())
		if conditionOk then
			local finished = ActTaskModel:isTaskFinished(onlineId, taskId, self:getActInfo())
			if not finished then
				hasTodo = true
			end
		end
	end
	return hasTodo
end


local ActTaskModel = class("ActTaskModel", BaseModel)

function ActTaskModel:init(d)
	ActTaskModel.super.init(self, d)
	EventControler:addEventListener(InitEvent.INITEVENT_FUNC_INIT, self.onFuncInit, self)
end

function ActTaskModel:onFuncInit(event)
	local params = event.params
	local funcname = params.funcname
	if funcname == "FuncActivity" then
		self:checkAndDoInitOnlineActs()
		self:checkTodoNums()
	end
end

function ActTaskModel:checkAndDoInitOnlineActs()
	if self._online_acts_inited then return end
	self.onlineActs = FuncActivity.getOnlineActs()
	self._online_acts_inited = true
end

function ActTaskModel:tryFinishTask(onlineId, taskId)
	ActivityServer:finishTask(onlineId, taskId, c_func(self.onFinishTaskOk, self, onlineId, taskId))
end

function ActTaskModel:onFinishTaskOk(onlineId, taskId, serverData)
	local result = serverData.result
	if result.data and result.data.reward then
		FuncCommUI.startRewardView(result.data.reward)
	end
	EventControler:dispatchEvent(ActivityEvent.ACTEVENT_FINISH_TASK_OK, {taskId= taskId, onlineId = onlineId})
	self:checkTodoNums()
end

function ActTaskModel:updateData(data)
	ActTaskModel.super.updateData(self, data)
end

function ActTaskModel:checkTodoNums()
	local showHomeRedPoint = function(show)
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, {redPointType = HomeModel.REDPOINT.ACTIVITY.ACTIVITY, isShow = show})
	end
	if not self.onlineActs then 
		showHomeRedPoint(false)
		return
	end
	for _, record in pairs(self.onlineActs) do
		if record:hasTodoThings() then
			showHomeRedPoint(true)
			return
		end
	end
	showHomeRedPoint(false)
end

--活动的每项任务是否领取了
function ActTaskModel:isTaskFinished(onlineId, taskId, actInfo)
	local key = string.format("%s_%s", onlineId, taskId)
	local data = self._data[key]
	local candoNum = FuncActivity.getTaskCanDoNum(taskId)

	if not data then return false, candoNum end
	local receiveTimes = self:getTaskReceiveTimes(onlineId, taskId, actInfo)
	local leftCanDoNum = candoNum - receiveTimes
	leftCanDoNum = _yuan3(leftCanDoNum<=0, 0, leftCanDoNum)
	return leftCanDoNum <=0, leftCanDoNum
end

function ActTaskModel:getTaskReceiveTimes(onlineId, taskId, actInfo)
	local key = string.format("%s_%s", onlineId, taskId)
	local data = self._data[key]
	local count = data.receiveTimes or 0
	if FuncActivity.isActCanReset(actInfo) then
		local now = TimeControler:getServerTime()
		if now > (data.expireTime or 0 ) then
			count = 0
		end
	end
	return count
end


function ActTaskModel:getDataKey(onlineId, taskId)
	return string.format("%s_%s", onlineId, taskId)
end


function ActTaskModel:genActivityRecord(data)
	local record = ActivityRecord.new()
	record:init(data)
	return record
end

function ActTaskModel:jumpToTaskLinkView(taskId)
	local link = FuncActivity.getTaskJumpLink(taskId)
	local linkParams = FuncActivity.getTaskLinkParams(taskId)
	local uiName = WindowsTools:getWindowNameByUIName(link)
	--echo(uiName, link, 'jumpToTaskLinkView000000000000000000000000000000')
	if uiName then
		WindowControler:showWindow(uiName, unpack(linkParams))
	end
end

return ActTaskModel
