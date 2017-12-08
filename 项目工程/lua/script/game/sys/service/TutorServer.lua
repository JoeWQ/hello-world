--
-- Author: guanfeng
-- Date: 2016-4-28
--

local TutorServer = class("TutorServer")

--完成每日任务
function TutorServer:finishTutorStep(groupId, callBack)
	echo("TutorServer " .. tostring(groupId));

	local params = {
		key = groupId
	}
	Server:sendRequest(params, 
		MethodCode.tutor_finish_groupId_333, callBack)
end

return TutorServer
