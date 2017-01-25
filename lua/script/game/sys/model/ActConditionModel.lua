local ActConditionModel = class("ActConditionModel", BaseModel)

function ActConditionModel:init(d)
	--dump(d,'==dmx==ActConditionModel:init==dmx==')
	ActConditionModel.super.init(self, d)
end

function ActConditionModel:updateData(d)
	ActConditionModel.super.updateData(self, d)
end

--scheduleId, taskId, 活动类型(兑换/领取)
function ActConditionModel:isTaskConditionOk(onlineId, taskId, actType)
	local conditionId = FuncActivity.getTaskConditionId(taskId)
	if not FuncActivity.checkTaskCanDoByLevel(taskId) then
		return false
	end
	local key = string.format("%s_%s", onlineId, conditionId)
	if actType == FuncActivity.ACT_TYPE.EXCHANGE then  --兑换类
		local conditionParam = FuncActivity.getTaskConditionParam(taskId)
		for _, res in pairs(conditionParam) do
			local needNum,hasNum,isEnough,resType,resId = UserModel:getResInfo(res)
			if not isEnough then
				return false
			end
		end
		return true
	elseif actType == FuncActivity.ACT_TYPE.TASK then  --完成任务领取类的(追溯、非追溯)
		local currentCondition = self:getConditionByKey(key)
		local configConditionNum = FuncActivity.getTaskConditionNum(taskId)
		local dataIsTrace = FuncActivity.isTaskDataTrace(taskId)
		if dataIsTrace then
			--追溯类的，单独处理
			local conditionId = FuncActivity.getTaskConditionId(taskId)
			local handleFuncKey = FuncActivity.TRACE_TASK_FUNCS[tonumber(conditionId)]
			local funcKey = nil
			if handleFuncKey then
				funcKey = string.format("%sConditionOk", handleFuncKey)
			end
			if handleFuncKey and self[funcKey] then
				local func = self[funcKey]
				local isOk = func(self, configConditionNum)
				return isOk
			end
		else
			--非追溯的读取服务器的进度
			if tonumber(configConditionNum) <= currentCondition then
				return true
			else
				return false
			end
		end
	end
	return false
end

--每一项的结构是：
--scheduleId
--conditionId
--count
--params
--expireTime
function ActConditionModel:getConditionByKey(key)
	local data = self._data[key]
	if not data then return 0 end
	local num = data.count or 0
	if data.expireTime then
		if data.expireTime < TimeControler:getServerTime() then
			num = 0
		end
	end
	return num
end

--只针对领取类任务的
function ActConditionModel:getTaskConditionProgress(onlineId, taskId)
	local conditionId = FuncActivity.getTaskConditionId(taskId)
	local key = string.format("%s_%s", onlineId, conditionId)
	local dataIsTrace = FuncActivity.isTaskDataTrace(taskId)
	local configConditionNum = FuncActivity.getTaskConditionNum(taskId)
	local count = 0
	if dataIsTrace then --追溯类的，单独处理
		local conditionId = FuncActivity.getTaskConditionId(taskId)
		local handleFuncKey = FuncActivity.TRACE_TASK_FUNCS[tonumber(conditionId)]
		local funcKey = nil
		if handleFuncKey then
			funcKey = string.format("%sCurrentConditionNum", handleFuncKey)
		end
		if handleFuncKey and self[funcKey] then
			local func = self[funcKey]
			count = func(self, configConditionNum)
		end
	else --非追溯的读取服务器的进度
		count = self:getConditionByKey(key)
	end
	return count, configConditionNum
end


--玩家等级
function ActConditionModel:userLevelCurrentConditionNum()
	return UserModel:level()
end

function ActConditionModel:userLevelConditionOk(conditionNum)
	local current = self:userLevelCurrentConditionNum()
	if current >= tonumber(conditionNum) then
		return true
	end
	return false
end

--法宝最高等级
function ActConditionModel:treasureMaxLevelCurrentConditionNum()
	return TreasuresModel:calStatisticMaxLevel()
end

function ActConditionModel:treasureMaxLevelConditionOk(conditionNum)
	local current = self:treasureMaxLevelCurrentConditionNum()
	return current >= tonumber(conditionNum)
end


return ActConditionModel
