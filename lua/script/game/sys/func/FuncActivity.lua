FuncActivity = FuncActivity or {}

FuncActivity.ACT_PLATFORMS = {
	IOS = "1",
	ANDROID = "2",
	DEV = "dev",
	ALL = nil,
}

FuncActivity.ACT_OPEN_SERVER_TYPE = {
	ALL = "1", --全区服开启
	INCLUDE = "2", --包含某些区服
	EXCLUDE = "3", --不包含某些区服
}

FuncActivity.ACT_OPEN_STATUS = {
	CLOSE = 0,
	OPEN = 1,
}

FuncActivity.ACT_TIME_LIMIT_TYPE = {
	SERVEROPEN_T = 1, --开服时间
	USERINIT_T = 2, --玩家创建角色时间
	NATURAL_T =3, --自然时间戳
}

FuncActivity.ACT_TYPE = {
	TASK = 1,
	EXCHANGE = 2,
}

FuncActivity.ACT_RESET_TYPE = {
	RESET = 1,
	NORESET = 0,
}

FuncActivity.TRACE_TYPE = {
	TRACE = 1,
	NOTRACE = 0,
}

--活动结束后，是否可领
FuncActivity.ACT_END_RECEIVE_TYPE = {
	ON = 1,
	OFF = 0,
}

FuncActivity.TRACE_TASK_FUNCS = {
	[500] = "userLevel",
	[1516] = "treasureMaxLevel",
}

local sortByOrder = function(a, b)
	return tonumber(a:getSortOrder()) < tonumber(b:getSortOrder())
end

local config_acts = nil
local config_acts_conditions = nil
local config_acts_tasks = nil
local config_acts_online = nil

function FuncActivity.init()
	config_acts = require("activity.Activity")
	config_acts_conditions = require("activity.ActivityCondition")
	config_acts_tasks = require("activity.ActivityTask")
	config_acts_online = require("activity.ActivityOnline")
end

function FuncActivity.getActsConfig()
	return config_acts
end


--获得能展示活动
function FuncActivity.getOnlineActs()
	local config = config_acts_online
	local activeActs = {}
    local  _version=AppInformation:getAppPlatform();
	for id, info in pairs(config) do
		local actId = info.actId
--//手工排除掉版署版本的活动
		local open = FuncActivity.checkActShouldShow(info)
		local actInfo = config_acts[actId]
		if info.platform==_version and open and actInfo then
			local start_t, end_t, show_start_t, show_end_t = FuncActivity.getOnlineActTime(info)
			local data = {
				onlineInfo = info,
				actInfo = actInfo,
				order = actInfo.order,
				actType = FuncActivity.getActType(actInfo.id),
				timeInfo = {
					start_t = start_t,
					end_t = end_t,
					show_start_t = show_start_t,
					show_end_t = show_end_t,
				}
			}
			table.insert(activeActs, ActTaskModel:genActivityRecord(data))
		end
	end
	table.sort(activeActs, sortByOrder)
	return activeActs
end

function FuncActivity.getActivityTaskConfig(actTaskId) 
	local config = config_acts_tasks[actTaskId]
	if not config then
		echoError(string.format('activityTask:%s config is nil', actTaskId))
	end
	return config
end

function FuncActivity.getOnlineConfig(onlineId)
	local config = config_acts_online[onlineId]
	if not config then
		echoError(string.format('activityOnline:%s config is nil', onlineId))
	end
	return config
end

-- 根据actId获取onlineConfig
function FuncActivity.getOnlineConfigByActId(actId)
	local onlineConfig = nil

	for id,info in pairs(config_acts_online) do
		if info.actId == tostring(actId) then
			onlineConfig = info
		end
	end

	return onlineConfig
end

--活动结束后，展示期之前，已完成活动项是否可领取
function FuncActivity.isDisplayedActCanReceiveAfterActEnd(onlineId)
	local onlineConfig = FuncActivity.getOnlineConfig(onlineId)
	return onlineConfig.last == FuncActivity.ACT_END_RECEIVE_TYPE.ON
end

--限制条件有：平台、渠道、区服、展示的起止时间，活动的起止时间是否开启开关
function FuncActivity.checkActShouldShow(onlineInfo)
	local info = onlineInfo

	local debugReturnFast = false --开启提前返回
	
	local actVisibleByLevel = FuncActivity.checkActivityLevelVisibility(info.actId)
	if debugReturnFast and not actVisibleByLevel then return false end

	local isOpen = FuncActivity.onlineActVisibleOpenCondition(info)
	if debugReturnFast and not isOpen then return false end

	local platformOk = FuncActivity.onlineActVisiblePlatformCondition(info)
	if debugReturnFast and not platformOk then return false end

	local channelOk = FuncActivity.onlineActVisibleChannelCondition(info)
	if debugReturnFast and not channelOk then return false end

	local timeOk = FuncActivity.onlineActVisibleTimeCondition(info)
	if debugReturnFast and not timeOk then return false end

	local serverOk = FuncActivity.onlineActVisibleServerCondition(info)
	if debugReturnFast and not serverOk then return false end

	local show = actVisibleByLevel and isOpen and platformOk and channelOk and timeOk and serverOk
	--echo(info.id, actVisibleByLevel, isOpen, platformOk,channelOk, timeOk, serverOk, 'checkActShouldShow')
	return show
	--return true
end

function FuncActivity.checkActivityLevelVisibility(actId)
	local config = FuncActivity.getActConfigById(actId)
	local level = config.level or 0
	return level <= UserModel:level()
end

function FuncActivity.onlineActVisibleOpenCondition(info)
	--检查一键开关
	if info.shutDown == FuncActivity.ACT_OPEN_STATUS.OPEN then
		return true
	end
	return false
end

function FuncActivity.onlineActVisiblePlatformCondition(info)
	--平台判断
	if info.platform then
		if info.platform == FuncActivity.ACT_PLATFORMS.IOS then
			if device.platform ~= "ios" then
				return false
			end
		elseif info.platform == FuncActivity.ACT_PLATFORMS.ANDROID then
			if device.platform ~= "android" then
				return false
			end
		elseif info.platform == FuncActivity.ACT_PLATFORMS.DEV then
			if AppInformation:getAppPlatform() ~= FuncActivity.ACT_PLATFORMS.DEV then
				return false
			end
		end
	end
	return true
end

function FuncActivity.onlineActVisibleChannelCondition(info)
	--渠道判断
	if info.channel then
		if info.channel ~= UserModel:getChannelName() then
			return false
		end
	end
	return true
end

function FuncActivity.onlineActVisibleServerCondition(info)
	--区服判断
	local serverId = LoginControler:getServerId()..''
	local servers = info.server or {}
	if info.serverType == FuncActivity.ACT_OPEN_SERVER_TYPE.INCLUDE then
		if not table.find(servers, serverId) then
			return false
		end
	elseif info.serverType == FuncActivity.ACT_OPEN_SERVER_TYPE.EXCLUDE then
		if table.find(servers, serverId) then
			return false
		end
	end
	return true
end

function FuncActivity.onlineActVisibleTimeCondition(info)
	--时间限制
	local now = TimeControler:getServerTime()
	local start_t, end_t, show_start_t, show_end_t = FuncActivity.getOnlineActTime(info)
	if now < show_start_t or now > show_end_t  then
		return false
	end

	return true
end

function FuncActivity.getOnlineActTime(info)
	local start_t = info['start'] or 0
	local end_t = info['end'] or 0
	if info.timeType == FuncActivity.ACT_TIME_LIMIT_TYPE.SERVEROPEN_T then
		local serverInfo = LoginControler:getServerInfo()
		start_t = tonumber(serverInfo.openTime)
		end_t = start_t + end_t
	elseif info.timeType == FuncActivity.ACT_TIME_LIMIT_TYPE.USERINIT_T then
		start_t = UserModel:ctime() --获取用户的初始化时间
		end_t = start_t + end_t
	elseif info.timeType == FuncActivity.ACT_TIME_LIMIT_TYPE.NATURAL_T then
	end
	local show_start_t = start_t - info.showStart
	local show_end_t = end_t + info.showEnd
	return start_t, end_t, show_start_t, show_end_t
end

function FuncActivity.getActConfigById(actId)
	local info = config_acts[actId]
	if not info then
		echoError(string.format('activity:%s config is nil', actId))
		return
	end
	return info
end

function FuncActivity.getActConfigByOnlineId(onlineId)
	local onlineConfig = FuncActivity.getOnlineConfig(onlineId)
	local actId = onlineConfig.actId
	return FuncActivity.getActConfigById(actId)
end

function FuncActivity.getActType(actId)
	local taskList = FuncActivity.getActTaskIds(actId)
	if not taskList then
		echoError(string.format("tasklist is nil, activity:%s", actId))
		return
	end
	local taskId = taskList[1]
	local taskInfo = config_acts_tasks[taskId]
	if not taskInfo then
		echoError(string.format("taskInfo is nil, taskId: %s", taskId))
		return
	end
	if taskInfo.type == FuncActivity.ACT_TYPE.EXCHANGE then
		return FuncActivity.ACT_TYPE.EXCHANGE
	end
	return FuncActivity.ACT_TYPE.TASK
end

--活动是否每天能重置
function FuncActivity.isActCanReset(actInfo)
	local reset = actInfo.reset
	if reset == FuncActivity.ACT_RESET_TYPE.NORESET then
		return false
	end
	return true
end

function FuncActivity.getActTaskIds(actId)
	local config = FuncActivity.getActConfigById(actId)
	return config.taskList
end

function FuncActivity.getActTaskConfigById(taskId)
	local config = config_acts_tasks[taskId]
	if not config then
		echoError(string.format("task config is nil, taskId: %s", taskId))
		return
	end
	return config
end

function FuncActivity.getActDisplayedTaskIds(actId)
	local taskIds = FuncActivity.getActTaskIds(actId)
	local ret = {}
	for _, taskId in pairs(taskIds) do
		local taskShouldShow = FuncActivity.checkTaskShouldShow(taskId)
		if taskShouldShow then
			table.insert(ret, taskId)
		end
	end
	return ret
end

--检查任务项是否可以显示
function FuncActivity.checkTaskShouldShow(taskId)
	local config = FuncActivity.getActTaskConfigById(taskId)
	local levelLimit = config.levelLimit
	local level = config.level
	local vipLevel = config.vip
	if vipLevel then
		if tonumber(UserModel:vip()) < vipLevel then
			return false
		end
	end
	if level then
		if tonumber(UserModel:level()) < level then
			return false
		end
	end
	return true
end

--检查任务项是否可做
function FuncActivity.checkTaskCanDoByLevel(taskId)
	local config = FuncActivity.getActTaskConfigById(taskId)
	local levelLimit = config.levelLimit
	if levelLimit then
		if tonumber(UserModel:level()) < levelLimit then
			return false
		end
	end
	return true
end

function FuncActivity.getTaskCanDoNum(taskId)
	local isLevelCando = FuncActivity.checkTaskCanDoByLevel(taskId)
	if not isLevelCando then
		return 0
	end
	local taskConfig = FuncActivity.getActTaskConfigById(taskId)
	local candoNum = taskConfig.times
	return candoNum
end

function FuncActivity.getTaskConditionId(taskId)
	local taskConfig = FuncActivity.getActTaskConfigById(taskId)
	return taskConfig.condition
end

function FuncActivity.getTaskConditionNum(taskId)
	local taskConfig = FuncActivity.getActTaskConfigById(taskId)
	return taskConfig.conditionNum
end

function FuncActivity.getTaskConditionParam(taskId)
	local taskConfig = FuncActivity.getActTaskConfigById(taskId)
	return taskConfig.conditionParam
end

function FuncActivity.getTaskCondition(taskId)
	local conditionId = FuncActivity.getTaskConditionId(taskId)
	local config = FuncActivity.getConditionById(conditionId)
	return config
end

--任务的跳转配置
function FuncActivity.getTaskJumpLink(taskId)
	local conditionConfig = FuncActivity.getTaskCondition(taskId)
	local link = conditionConfig.link
	return link
end

function FuncActivity.getTaskLinkParams(taskId)
	local conditionConfig = FuncActivity.getTaskCondition(taskId)
	return conditionConfig.linkParams or {}
end

function FuncActivity.getConditionById(conditionId)
	local config = config_acts_conditions[conditionId..'']
	if not config then
		echoError(string.format("condition is nil, conditionId : %s", conditionId))
	end
	return config
end

--task 是否是追溯的
function FuncActivity.isTaskDataTrace(taskId)
	local config = FuncActivity.getTaskCondition(taskId)
	if tonumber(config.trace) == FuncActivity.TRACE_TYPE.TRACE then
		return true
	else
		return false
	end
end

-- 根据条件ID，获取ActivityTask列表
function FuncActivity.getActivityTaskListByCondition(condId)
	local actTaskList = {}

	for actId,info in pairs(config_acts_tasks) do
		if info.condition and tonumber(info.condition) == tonumber(condId) then
			actTaskList[#actTaskList+1] = actId
		end
	end

	return actTaskList
end

function FuncActivity.getActivityIdByActTaskId(actTaskId)
	local actIdList = {}

	for id,info in pairs(config_acts) do
		if info.taskList then
			local taskList = info.taskList
			for i=1,#taskList do
				if taskList[i] == tostring(actTaskId) then
					actIdList[#actIdList+1] = id
				end
			end
		end
	end

	return actIdList
end

-- 根据ActivityTaskId判断其是否在线
function FuncActivity.isActivityTaskOnline(actTaskId)
	local actIdList = FuncActivity.getActivityIdByActTaskId(actTaskId)
	local platform = AppInformation:getAppPlatform()

	for i=1,#actIdList do
		local actId = actIdList[i]
		local onlineConfig = FuncActivity.getOnlineConfigByActId(actId)

		local open = FuncActivity.checkActShouldShow(onlineConfig)
		if onlineConfig.platform == platform and open then
			return true
		end
	end

	return false
end


