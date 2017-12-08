local ActivityServer = class("ActivityServer")

function ActivityServer:finishTask(scheduleId, taskId, callBack)
	local params = {scheduleId = scheduleId, taskId = taskId}
	Server:sendRequest(params, MethodCode.act_finish_task_3601, callBack)
end

return ActivityServer
