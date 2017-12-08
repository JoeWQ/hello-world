--
-- Author: ZhangYanguang
-- Date: 2015-11-28
--
--主角模块，网络服务类
local QuestServer = class("QuestServer")

--完成每日任务
function QuestServer:getEveryQuestReward(everydayQuestId, callBack)
	echo("getEveryQuestReward " .. tostring(everydayQuestId));
	UserModel:cacheUserData();

	local params = {
		everydayQuestId = everydayQuestId
	}
	Server:sendRequest(params, 
		MethodCode.quest_getDailyQuest_reward_2503, callBack )
end


--完成主线任务
function QuestServer:getMainQuestReward(mainQuestId, callBack)
	echo("getMainQuestReward " .. tostring(mainQuestId));
	UserModel:cacheUserData();
	
	local params = {
		mainlineQuestId = mainQuestId
	}
	Server:sendRequest(params, 
		MethodCode.quest_getMainLineQuest_reward_2501, callBack)
end


return QuestServer
