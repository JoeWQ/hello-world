--guan
--2016.3.26
--2017.1.18 

local MainLineQuestModel = class("DailyQuestModel", BaseModel)

QuestType = {
    MainLine = 1,
    Daily = 2,
}

MainLineQuestModel.Type = {
	RAID = 1,  		--主线进度
	RAID_ELITE = 2, --精英进度
	CHAR_LVL = 3,   --主角等级
	
	CHAR_STAR = 4,  --主角星级  todo
	CHAR_QUALITY = 5, --主角品质 todo
	CHAR_SKILL = 6,  --主角技能 todo

	PARTNER_LVL = 7, --伙伴等级 todo
	PARTNER_QUALITY = 8, --伙伴品质 todo
	PARTNER_STAR = 9, --伙伴星级 todo
	PARTNER_COLLECT = 10, --伙伴数量 todo  

	TREASURE_COLLECT = 11, --法宝数量
	TREASURE_LVL = 12,  --法宝等级   
	TREASURE_STAR = 13, --法宝星级
	TREASURE_MAKE = 14, --法宝合成
	TOWER = 15, 		--爬塔
	GUILD = 16,		    --公会

	TRIAL_SHAN = 17,    --山神试炼
	TRIAL_HUO = 19,     --火神试炼
	TRIAL_XUE  = 20,    --雪妖试炼
};

MainLineQuestModel.FIRST_QUEST_ID = {
	["1"] = "1001",  		--主线进度
	["2"] = "2001", 	    --精英进度
	["3"] = "3001",  	    --主角等级
	["4"] = "4001", 		--主角星级
	["5"] = "5001" ,         --主角品质

	["6"] = "6001",          --主角技能 没配表先隐藏它
	
	["7"] = "7001",          --伙伴等级
	["8"] = "8001", 		--伙伴品质
	["9"] = "9001",          --伙伴星级
	["10"] = "10001",          --伙伴数量
	["11"] = "11001",          --法宝收集
	["12"] = "12001",          --法宝等级
	["13"] = "13001",          --法宝星级
	["14"] = "14001",          --法宝合成
	["15"] = "15001",          --爬塔
	["16"] = "16001",          --加入公会
	["17"] = "17001",          --山神
	["18"] = "18001",          --火神
	["19"] = "19001",          --雪妖

};

MainLineQuestModel.JUMP_VIEW = {
	["1"] = {viewName = "WorldPVEMainView"},
	["2"] = {viewName = "EliteView"},
	["3"] = {viewName = "WorldPVEMainView"},
	["4"] = {viewName = "CharMainView"},
	["5"] = {viewName = "CharMainView"},
	["6"] = {viewName = "CharMainView"},
	["7"] = {viewName = "PartnerView"},
	["8"] = {viewName = "PartnerView"},
	["9"] = {viewName = "PartnerView"},
	["10"] = {viewName = "PartnerView"},
	["11"] = {viewName = "TreasureView"},
	["12"] = {viewName = "TreasureView"},
	["13"] = {viewName = "TreasureView"},
	["14"] = {viewName = "TreasureView"},

};

function MainLineQuestModel:init(data)
	self.modelName = "MainLineQuestModel"
    MainLineQuestModel.super.init(self, data)

    --各个线任务的进度
    self._datakeys = {
   		mainlineQuests = {},
	};

	self:createKeyFunc()

    EventControler:addEventListener(InitEvent.INITEVENT_FUNC_INIT, 
    	self.onFuncInit, self)  

    --主线变化事件
    EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
        self.mainQuestChangeCallBack, self);

    --升级事件
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE,
        self.mainQuestChangeCallBack, self);

    --伙伴相关事件
    EventControler:addEventListener(PartnerEvent.PARTNER_STAR_LEVELUP_EVENT,
        self.sendMainLineChangeEvent, self);
    EventControler:addEventListener(PartnerEvent.PARTNER_LEVELUP_EVENT,
        self.sendMainLineChangeEvent, self);
    EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_CHANGE_EVENT,
        self.sendMainLineChangeEvent, self);  
    EventControler:addEventListener(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT,
        self.sendMainLineChangeEvent, self);  

    --主角品质提升
    EventControler:addEventListener(UserEvent.USEREVENT_QUALITY_CHANGE,
        self.sendMainLineChangeEvent, self); 

end

function MainLineQuestModel:sendMainLineChangeEvent()
	EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {});
end

function MainLineQuestModel:onFuncInit(event)
	local params = event.params
	local funcname = params.funcname
	if funcname ~= "FuncQuest" then
		return
	end
	self:updateData(self._data);

end

--更新数据
--[[
	后端记录的是各线任务进度，空是第一个任务，否则是正在进行的任务
	{
		3001 = {3002 = 3002}
		4001 = {4004 = 4004}
	}
]]
function MainLineQuestModel:updateData(data)
	-- dump(data, "----MainLineQuestModel:updateData-----");

	if data ~= nil then 
		for k, v in pairs(data) do
			self._datakeys.mainlineQuests[k] = v;
		end
	end

	--有完成的，就显示红点 todo 没有完成的呢，红点消失呢？
	if self:isHaveFinishQuest() == true and 
			FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST) == true then 
		
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = true});

		echo("------MainLineQuestModel:updateData(data)-------", HomeModel.REDPOINT.NPC.QUEST);
	end
end

--删除数据
function MainLineQuestModel:deleteData( keyData ) 
	-- dump(keyData, "---MainLineQuestModel:deleteData---");
	for k, vt in pairs(keyData) do
		local preVt = self._datakeys.mainlineQuests[k];
		for k, v in pairs(vt) do
			preVt[k] = nil;
		end
	end

end

function MainLineQuestModel:mainLineQuestOpenCheck(questId)
	local openCondition = FuncQuest.readMainlineQuest(questId, "openCondition");
	local isReachCondition = UserModel:checkCondition( openCondition )
	return isReachCondition == nil and true or false;
end

function MainLineQuestModel:isHideQuest(id)
	local isHide = FuncQuest.readMainlineQuest(id, "Hide", false);
	return isHide == 1 and true or false;
end

function MainLineQuestModel:isNeedShow(id)
	local isHide = self:isHideQuest(id);
	local isFinish = self:isMainLineQuestFinish(id);

	if isHide == false then 
		return true;
	else
		if isFinish == true then 
			return true;
		else
			return false;
		end 
	end 
end

--[[
	所有显示的主线任务, 如果上次完成的
	后续任务没有完成，则放到最后
]]
function MainLineQuestModel:getAllShowMainQuestId()
	local allShowQuests = {};
	
	for i = 1, 19 do
		if i ~= 6 and i ~= 17 and i ~= 18 and i ~= 19 then --6.17.18.19 类型没配表

			local firstQuestId = MainLineQuestModel.FIRST_QUEST_ID[tostring(i)];

			--这线任务一个也没有完成
			if self._datakeys.mainlineQuests[firstQuestId] == nil then 
				if self:mainLineQuestOpenCheck(firstQuestId) == true and 
						self:isNeedShow(firstQuestId) == true then 
					table.insert(allShowQuests, firstQuestId);
				end 
			else 
				--这线任务有完成的，从后端返回的数据中取
				for k, v in pairs(self._datakeys.mainlineQuests[firstQuestId]) do
					if self:mainLineQuestOpenCheck(k) == true  and 
							self:isNeedShow(k) == true then 
						table.insert(allShowQuests, k);
					end 
				end
			end 

		end 
	end

	--完成的放到前面
	function sortFunc(id1, id2)
		local id1IsFinish = self:isMainLineQuestFinish(id1);
		local id2IsFinish = self:isMainLineQuestFinish(id2);

		id1IsFinish = id1IsFinish == true and 1 or 0;
		id2IsFinish = id2IsFinish == true and 1 or 0;

		if id1IsFinish > id2IsFinish then 
			return true
		elseif id1IsFinish == id2IsFinish then 
			if tonumber(id1) < tonumber(id2) then 
				return true  
			else 
				return false;
			end 
		else
			return false;
		end 
	end

	table.sort(allShowQuests, sortFunc);

	local recommendQuestId = self:getRecommendQuestId();

	--把推荐任务放到第一个，不管完没完成
	for k, v in pairs(allShowQuests) do
		if v == recommendQuestId then 
			table.remove(allShowQuests, k);
			break;
		end 
	end

	if recommendQuestId ~= nil then 
		table.insert(allShowQuests, 1, recommendQuestId);
	end 

	return allShowQuests;
end

function MainLineQuestModel:getLastFinishQuestKey()
	return self._lastFinishKey;
end

--[[
	任务是否完成
]]
function MainLineQuestModel:isMainLineQuestFinish(id)
	--主线是否完成
	function isFinishRaid(id)
		local curRaid = UserExtModel:getMainStageId();
		local targetRaid = FuncQuest.readMainlineQuest(id, "completeCondition")[1];

		return tonumber(curRaid) >= tonumber(targetRaid) and true or false;
	end

	--精英副本是否完成
	function isFinishElite( id )
		local curRaid = UserExtModel:getEliteStageId();
		local targetRaid = FuncQuest.readMainlineQuest(id, "completeCondition")[1];

		return tonumber(curRaid) >= tonumber(targetRaid) and true or false;
	end

	--法宝数量
	function isFinishTreasureNum(id)
		local needNum = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		local haveNum = TreasuresModel:getAllTreasureCount();
		
		return haveNum >= tonumber(needNum);
	end

	--法宝等级
	function isFinishTreasureLvl(id)
		local condition = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		return TreasuresModel:isCompleteLvlCondition(condition);
	end

	--法宝星级
	function isFinishTreasureStar(id)
		local condition = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		return TreasuresModel:isCompleteStarCondition(condition);
	end

	--有没有法宝
	function isFinishTreasureMake(id)
		local needId = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		local treasure = TreasuresModel:getTreasureById(needId);
		return treasure ~= nil and true or false;
	end

	--爬塔是否完成
	function isFinishTower(id)
		local needNum = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		local floorNum = TowerNewModel:maxFloor();

		return floorNum >= tonumber(needNum);
	end

	--主角等级
	function isFinishCharLvl(id)
		local targetLvl = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		local curLvl = UserModel:level();
		return curLvl >= tonumber(targetLvl) and true or false;
	end

	--主角星级
	function isFinishCharStar(id)
		return false;
	end

	--主角品质
	function isFinishCharQuality(id)
		local target = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		local quality = UserModel:quality();
		return quality >= tonumber(target) and true or false;
	end 

	--主角天赋技能
	function isFinishCharSkill(id)
		return false;
	end 

	--伙伴等级
	function isFinishPartnerLvl(id)
		local target = FuncQuest.readMainlineQuest(id, "completeCondition")[1];

		local tables = string.split(target, ",");
		local needNum = tonumber(tables[1]);
		local level = tonumber(tables[2]);

		--获得有几个大于level参数级别的伙伴
		local haveNum = PartnerModel:partnerNumGreaterThenParamLvl(level - 1); 

		return haveNum >= needNum and true or false;

		-- return false;
	end

	--伙伴品质
	function isFinishPartnerQuality(id)
		local target = FuncQuest.readMainlineQuest(id, "completeCondition")[1];

		local tables = string.split(target, ",");
		local needNum = tonumber(tables[1]);
		local quality = tonumber(tables[2]);

		--获得有几个大于quality参数品质的伙伴
		local haveNum = PartnerModel:partnerNumGreaterThenParamQuality(quality - 1);

		return haveNum >= needNum and true or false;

		-- return false;
	end

	--伙伴
	function isFinishPartnerStar(id)
		local target = FuncQuest.readMainlineQuest(id, "completeCondition")[1];

		local tables = string.split(target, ",");
		local needNum = tonumber(tables[1]);
		local star = tonumber(tables[2]);

		--获得有几个大于star参数星级的伙伴
		local haveNum = PartnerModel:partnerNumGreaterThenParamStar(star - 1); 

		return haveNum >= needNum and true or false;
		-- return false;

	end

	function isFinishPartnerNum(id)
		local target = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		local cur = PartnerModel:getPartnerNum()
		return cur >= tonumber(target) and true or false;
	end

	local questType = FuncQuest.readMainlineQuest(id, "conditionType");

	--分19个类型分别判断是否完成
	if questType == MainLineQuestModel.Type.RAID then --主线剧情
		return isFinishRaid(id);
	elseif questType == MainLineQuestModel.Type.RAID_ELITE then --精英剧情
		return isFinishElite(id);
	elseif questType == MainLineQuestModel.Type.CHAR_LVL then --主角等级
		return isFinishCharLvl(id);
	elseif questType == MainLineQuestModel.Type.CHAR_STAR then --主角等级
		return isFinishCharStar(id);
	elseif questType == MainLineQuestModel.Type.CHAR_QUALITY then --主角品质
		return isFinishCharQuality(id);
	elseif questType == MainLineQuestModel.Type.CHAR_SKILL then --主角品质
		return isFinishCharSkill(id);

	elseif questType == MainLineQuestModel.Type.PARTNER_LVL then --伙伴等级
		return isFinishPartnerLvl(id);
	elseif questType == MainLineQuestModel.Type.PARTNER_QUALITY then --伙伴品质
		return isFinishPartnerQuality(id);		
	elseif questType == MainLineQuestModel.Type.PARTNER_STAR then --伙伴品质
		return isFinishPartnerStar(id);
	elseif questType == MainLineQuestModel.Type.PARTNER_COLLECT then --伙伴品质
		return isFinishPartnerNum(id);

	elseif questType == MainLineQuestModel.Type.TREASURE_COLLECT then --法宝数量
		return isFinishTreasureNum(id);
	elseif questType == MainLineQuestModel.Type.TREASURE_LVL then --法宝等级
		return isFinishTreasureLvl(id);
	elseif questType == MainLineQuestModel.Type.TREASURE_STAR then --法宝星级
		return isFinishTreasureStar(id);
	elseif questType == MainLineQuestModel.Type.TREASURE_MAKE then --有没有法宝
		return isFinishTreasureMake(id);
	elseif questType == MainLineQuestModel.Type.TOWER then --爬塔
		return isFinishTower(id);
	elseif questType == MainLineQuestModel.Type.GUILD then --公会
		return false;

	elseif questType == MainLineQuestModel.Type.TRIAL_SHAN then --公会
		return false;

	elseif questType == MainLineQuestModel.Type.TRIAL_HUO then --公会
		return false;

	elseif questType == MainLineQuestModel.Type.TRIAL_XUE then --公会
		return false;

	else 
		echoWarn("---no this quest type, questId is---" .. tostring(id));
		return false;
	end 
end

--[[
	是否有完成的任务
]]
function MainLineQuestModel:isHaveFinishQuest()
	local allShowQuests = self:getAllShowMainQuestId();
	for k, v in pairs(allShowQuests) do
		if self:isMainLineQuestFinish(v) == true then 
			return true;
		end 
	end
	return false;
end

--[[
	是否显示右边的进度和前往
]]
function MainLineQuestModel:isShowNumInfo(id)
	local num = FuncQuest.readMainlineQuest(id, "num", false);
	return (num ~= 0 and num ~= nil) and true or false;	
end

--[[
	需要数量
]]
function MainLineQuestModel:needCount(questId)
	local num = FuncQuest.readMainlineQuest(questId, "num", false);
	return num;
end

--[[
	完成数量
]]
function MainLineQuestModel:finishCount(questId)
	local questType = FuncQuest.readMainlineQuest(questId, "conditionType");
	local condition = FuncQuest.readMainlineQuest(questId, "completeCondition")[1];

	if questType == MainLineQuestModel.Type.CHAR_LVL then 
		local lvl = UserModel:level();
		return lvl;
	elseif questType == MainLineQuestModel.Type.TREASURE_COLLECT then
		return TreasuresModel:getAllTreasureCount();
	elseif questType == MainLineQuestModel.Type.TREASURE_LVL then
		local _, num = TreasuresModel:isCompleteLvlCondition(condition);
		return num;
	elseif questType == MainLineQuestModel.Type.TREASURE_STAR then
		local _, num = TreasuresModel:isCompleteStarCondition(condition);
		return num;
	elseif questType == MainLineQuestModel.Type.TOWER then
		local floorNum = TowerNewModel:maxFloor();
		return floorNum;
	else 
		return 0;
	end 
end

--[[
	得到推荐任务
]]
function MainLineQuestModel:getRecommendQuestId()
	local allShowQuests = {};
	
	for i = 1, 3 do
		local firstQuestId = MainLineQuestModel.FIRST_QUEST_ID[tostring(i)];
		if self._datakeys.mainlineQuests[firstQuestId] == nil then 
			if self:mainLineQuestOpenCheck(firstQuestId) == true then 
				return firstQuestId;
			end 
		else 
			for k, v in pairs(self._datakeys.mainlineQuests[firstQuestId]) do
				if self:mainLineQuestOpenCheck(k) == true then 
					return k;
				end 
			end
		end 
	end

	return nil;
end

--[[
	是否是推荐任务
]]
function MainLineQuestModel:isRecommendQuest(questId)
	local recommandId = self:getRecommendQuestId();
	if tonumber(recommandId) == tonumber(questId) then 
		return true;
	else 
		return false;
	end 
end

--任务发生变化
function MainLineQuestModel:mainQuestChangeCallBack()
	echo("-----MainLineQuestModel:mainQuestChangeCallBack----");
	local isShow = false;

	if self:isHaveFinishQuest() == true then 
		isShow = true 
	else 
		if DailyQuestModel ~= nil and DailyQuestModel:isHaveFinishQuest() == true then 
			isShow = true;
		end 
	end 

	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
        {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = isShow});
end

return MainLineQuestModel








