--guan
--2016.03.26

FuncQuest = FuncQuest or {}

--初始化
function FuncQuest.init(  )
	dailyQuest = require("quest.EverydayQuest")
	mainQuest = require("quest.MainlineQuest")
end

--读表
function FuncQuest.readEverydayQuest(id, key, isShowWarning)
	local data = dailyQuest[tostring(id)];
	if data == nil then 
		if isShowWarning ~= false then 
			echo("FuncQuest.readEverydayQuest id " .. tostring(id) .. " is nil.");
		end 
		return nil;
	else 	
		local ret = data[key];
		if ret == nil then 
			if isShowWarning ~= false then 
				echo("FuncQuest.readEverydayQuest id " 
					.. tostring(id) .. " key " .. tostring(key) .. " is nil.");
			end 
			return nil;
		else 
			return ret;
		end 
	end 
end

function FuncQuest.readMainlineQuest(id, key, isShowWarning)
	local data = mainQuest[tostring(id)];
	if data == nil then 
		if isShowWarning ~= false then 
			echo("FuncQuest.readMainlineQuest id " .. tostring(id) .. " is nil.");
		end 
		return nil;
	else 	
		local ret = data[key];
		if ret == nil then 
			if isShowWarning ~= false then 
				echo("FuncQuest.readMainlineQuest id " 
					.. tostring(id) .. " key " .. tostring(key) .. " is nil.");
			end 
			return nil;
		else 
			return ret;
		end 
	end
end

--[[
	所有每日任务id获得
]]
function FuncQuest.getAllDailyQuestIds()
	local ids = {};
	for k, v in pairs(dailyQuest) do
		ids[k] = k;
	end
	return ids;
end

--[[
	得到某类型的所有任务
]]
function FuncQuest.getAllDailyByType(questType)
	local allDailyQuestIds = FuncQuest.getAllDailyQuestIds();
	local ids = {};

	for k, v in pairs(allDailyQuestIds) do
		if FuncQuest.readEverydayQuest(k, "conditionType") == questType then 
			ids[k] = k;
		end 
	end

	return ids;
end

--任务名字
function FuncQuest.getQuestName(questType, questId)
	if questType == 1 then 
		return FuncQuest.readMainlineQuest(questId, "name");
	else 
		return FuncQuest.readEverydayQuest(questId, "name");
	end 
end

--任务描述
function FuncQuest.getQuestDes(questType, questId)
	if questType == 1 then 
		return FuncQuest.readMainlineQuest(questId, "taskDescription");
	else 
		return FuncQuest.readEverydayQuest(questId, "taskDescription");
	end 
end

--任务奖励
function FuncQuest.getQuestReward(questType, questId)
	if questType == 1 then 
		return FuncQuest.readMainlineQuest(questId, "taskReward");
	else 
		return FuncQuest.readEverydayQuest(questId, "taskReward");
	end 
end

--任务icon
function FuncQuest.getQuestIcon(questType, questId)
	if questType == 1 then 
		return FuncQuest.readMainlineQuest(questId, "icon");
	else 
		return FuncQuest.readEverydayQuest(questId, "icon");
	end 
end

--任务icon边框
function FuncQuest.getQuestColor(questType, questId)
	if questType == 1 then 
		return FuncQuest.readMainlineQuest(questId, "color");
	else 
		return FuncQuest.readEverydayQuest(questId, "color");
	end 
end

function FuncQuest.getPostTask(questId)
	return FuncQuest.readMainlineQuest(questId, "postTask") or {};
end
















