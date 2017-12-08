--guan
--2016.3.26
--2017.1.19

local DailyQuestModel = class("DailyQuestModel", BaseModel)

DailyQuestModel.Type = {
	Vigour = "1", --领体力
	NewDay = "2", --新的一天
	ELiteExchange = "3",  --奇缘npc兑换
	Lottery = "4", --赤铜抽
	PartnerLvlUp = "5", --伙伴升级
	PartnerSKillUp = "6", --伙伴技能升级
	PartnerUniqueSkillUp = "7", --伙伴绝技升级
	PartnerQualityUp = "8",   --伙伴升品
	Trial = "9",   --试炼
	Tower = "10",   --爬塔
	Arena = "11",   --竞技场
	BuyVigour = "12", --买体力
	BuyCoin = "13", --买铜钱
	CostGold = "14", --花钻石
	MonthCard = "15", --领月卡
};

DailyQuestModel.JUMP_VIEW = {
	-- [DailyQuestModel.Type.Friend] = {viewName = "FriendMainView", jumpFunc = function ()
	-- 	FriendViewControler:forceShowFriendList();
	-- end},
	[DailyQuestModel.Type.Tower] = {viewName = "TowerNewMainView"},

	[DailyQuestModel.Type.Trial] = {viewName = "TrialEntranceView"},
	[DailyQuestModel.Type.Arena] = {viewName = "ArenaMainView"},

	[DailyQuestModel.Type.BuyCoin] = {viewName = "CompBuyCoinMainView"},
	[DailyQuestModel.Type.Lottery] = {viewName = "NewLotteryMainView"},
	[DailyQuestModel.Type.ELiteExchange] = {viewName = "EliteView"},
	
	[DailyQuestModel.Type.PartnerLvlUp] = {viewName = "PartnerView"},
	[DailyQuestModel.Type.PartnerSKillUp] = {viewName = "PartnerView"},
	[DailyQuestModel.Type.PartnerUniqueSkillUp] = {viewName = "PartnerView"},
	[DailyQuestModel.Type.PartnerQualityUp] = {viewName = "PartnerView"},

	[DailyQuestModel.Type.BuyVigour] = {viewName = "CompBuySpMainView"},
	[DailyQuestModel.Type.CostGold] = {viewName = "CompBuyCoinMainView"},

};

function DailyQuestModel:init(data)

	self.modelName = "DailyQuestModel"
    DailyQuestModel.super.init(self, data)

    self._datakeys = {
    	--过期时间
   		expireTime = 0,
   		--[[
			3 = 441,
			4 = 1,
   		]]
   		todayEverydayQuestCounts = {},
   		--[[
			1005 = 1005,
			1006 = 1006,
   		]]
   		receiveStatus = {},
	};

	self:createKeyFunc()
    EventControler:addEventListener(InitEvent.INITEVENT_FUNC_INIT, 
    	self.onFuncInit, self)  

    --仙玉发生变化
    EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, 
    	self.sendMainLineChangeEvent, self);
    --主角升级
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
    	self.sendMainLineChangeEvent, self);    
end

function DailyQuestModel:sendMainLineChangeEvent()
    EventControler:dispatchEvent(QuestEvent.DAILY_QUEST_CHANGE_EVENT, 
        {});
end

function DailyQuestModel:onFuncInit(event)
	local params = event.params
	local funcname = params.funcname

	if funcname ~= "FuncQuest" then
		return
	end

	self:updateData(self._data);

	self:initSpQuestCheck();

	--接受cd到了的事件
    EventControler:addEventListener(QuestEvent.QUEST_CHECK_SP_EVENT,
        self.spCheckCallBack, self, 2);

	if self:isHaveFinishQuest() == true then 
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = true});
	end 

end

--更新数据
function DailyQuestModel:updateData(data)
	if data.todayEverydayQuestCounts ~= nil then 
		for k, v in pairs(data.todayEverydayQuestCounts) do
			self._datakeys.todayEverydayQuestCounts[k] = v;
		end
	end

	if data.expireTime ~= nil then 
		self._datakeys.expireTime = data.expireTime;
	end 

	if data.receiveStatus ~= nil then 
		for k, v in pairs(data.receiveStatus) do
			self._datakeys.receiveStatus[k] = v;
		end
	end 

	--有变化就发个事件
    EventControler:dispatchEvent(QuestEvent.DAILY_QUEST_CHANGE_EVENT, 
        {});

	if self:isHaveFinishQuest() == true then 
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = true});		
	end 
end

--是否过期了 , 返回true就是过期了
function DailyQuestModel:isExpireTime()
	-- body
	local serverTime = TimeControler:getServerTime();
	if self._datakeys.expireTime < serverTime then 
		return true
	else 
		return false;
	end 
end

--删除数据
function DailyQuestModel:deleteData( keyData ) 
	-- dump(keyData, "---deleteData：keyData---");
	DailyQuestModel.super.deleteData(self, keydata)

	if keyData.todayEverydayQuestCounts ~= nil then 
		for k, v in pairs(keyData.todayEverydayQuestCounts) do
			self._datakeys.todayEverydayQuestCounts[k] = nil;
		end
	end 


	if keyData.receiveStatus ~= nil then 
		if keyData.receiveStatus == 1 then 
			keyData.receiveStatus = {};
		else
			for k, v in pairs(keyData.receiveStatus) do
				self._datakeys.receiveStatus[k] = nil;
			end
		end 
	end 


	--有变化就发个事件
    EventControler:dispatchEvent(QuestEvent.DAILY_QUEST_CHANGE_EVENT, 
        {});
end

--[[
	吃鸡任务是否满足时间开启
]]
function DailyQuestModel:isSpQuestIdTimeInOpenRange(id)
    local serverTime = TimeControler:getServerTime();

    local dates = os.date("*t", serverTime);   
    local curHour = dates.hour;

    function isCurHourInRegion(from, to)
    	if curHour >= from and curHour < to then 
    		return true;
    	else 
    		return false;
    	end 
    end

	local spCondition = FuncQuest.readEverydayQuest(id, "spCondition");

	if isCurHourInRegion(spCondition[1], spCondition[2]) == true then 
		return true;
	else 
		return false;
	end 
end

--[[
	当前要显示的吃鸡任务
]]
function DailyQuestModel:getCurShowSpQuest()
	local ids = FuncQuest.getAllDailyByType(1);

    local dates = os.date("*t", serverTime);   
    local curHour = dates.hour;

    for i = 1, 3 do
    	local questId = tostring(1000 + i);
    	local spCondition = FuncQuest.readEverydayQuest(questId, "spCondition");
    	-- dump(spCondition, "--spCondition--");
    	if curHour < spCondition[2] then 
    		if self:isExpireTime() == true then 
    			return questId;
    		else 
    			if self._datakeys.receiveStatus[questId] == nil then 
    				return questId;
    			end 
    		end 
    	end 
    end

    return nil;
end

function DailyQuestModel:isHideQuest(id)
	local isHide = FuncQuest.readEverydayQuest(id, "Hide", false);
	return isHide == 1 and true or false;
end

function DailyQuestModel:isNeedShow(id)
	local isHide = self:isHideQuest(id);
	local isFinish = self:isDailyQuestFinish(id);

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

--得到所有 每日任务
function DailyQuestModel:getAllShowDailyQuestId()
	local showIds = {};

	if self:getCurShowSpQuest() ~= nil then 
		table.insert(showIds, self:getCurShowSpQuest());
	end 

	local isExpireTime = self:isExpireTime();

	for i = 2, 15 do
		local ids = FuncQuest.getAllDailyByType(i);

		for k, v in pairs(ids) do
			if self:dailyQuestOpenCheck(k) == true and self:isNeedShow(k) == true then 
				if isExpireTime == true or self._datakeys.receiveStatus[tostring(k)] == nil then 
					table.insert(showIds, k);
				end 
			end 
		end

	end

	function sortFunc(id1, id2)
		local id1IsFinish = self:isDailyQuestFinish(id1);
		local id2IsFinish = self:isDailyQuestFinish(id2);

		id1IsFinish = id1IsFinish == true and 1 or 0;
		id2IsFinish = id2IsFinish == true and 1 or 0;

		if id1IsFinish > id2IsFinish then 
			return true
		elseif id1IsFinish == id2IsFinish then 
			if id1 < id2 then 
				return true  
			else 
				return false;
			end 
		else
			return false;
		end 
	end

	table.sort(showIds, sortFunc);

	return showIds;
end

--[[
	每日任务是否开启了
]]
function DailyQuestModel:dailyQuestOpenCheck(id)
	local openCondition = FuncQuest.readEverydayQuest(id, "openCondition");
	local isReachCondition = UserModel:checkCondition( openCondition )
	return isReachCondition == nil and true or false;
end

--[[今日花费的钻石数]]
function DailyQuestModel:todayCostGold()
	-- local totalCostGoldBeforeToday = self:finishCount(id);
	local totalCostGoldBeforeToday = self._datakeys.todayEverydayQuestCounts[DailyQuestModel.Type.CostGold] or 0;

	local totalCostGold = UserModel:totalCostGold();

	return totalCostGold - totalCostGoldBeforeToday;
end 

--[[
	花费钻石任务是否完成了
]]
function DailyQuestModel:isCostGoldQuestFinish(id)
	local todayCostGold = self:todayCostGold();
	local needCost = FuncQuest.readEverydayQuest(id, "completeCondition");
	return todayCostGold >= needCost and true or false;
end

--[[
	每日任务是否完成了
]]
function DailyQuestModel:isDailyQuestFinish(id)
	local questType = FuncQuest.readEverydayQuest(id, "conditionType");
	local ret = nil;
	if questType == 1 then --吃鸡
		ret = self:isSpQuestIdTimeInOpenRange(id);
	elseif questType == 14 then
		ret = self:isCostGoldQuestFinish(id);
	else 
		local needCount = FuncQuest.readEverydayQuest(id, "completeCondition");
		local finishCount = self:finishCount(id);

		-- echo("needCount " .. tostring(needCount));
		-- echo("finishCount " .. tostring(finishCount));
		-- echo("id " .. tostring(id));

		if finishCount >= needCount then 
			ret = true;
		else 
			ret = false;
		end 
	end 

	return ret;
end

--[[
	需要完成几次
]]
function DailyQuestModel:needCount( id )
	local needCount = FuncQuest.readEverydayQuest(id, "completeCondition");
	return needCount;
end

--[[
	已经完成了几次
]]
function DailyQuestModel:finishCount( id )
	local questType = FuncQuest.readEverydayQuest(id, "conditionType");

	if questType == tonumber(DailyQuestModel.Type.CostGold) then 
		return self:todayCostGold();
	else 

		if self:isExpireTime() == true then 
			return 0;
		end 

		local finishCount = self._datakeys.todayEverydayQuestCounts[tostring(questType)] or 0;	
		return finishCount;

	end 
end

--[[
	是否是买体力任务
]]
function DailyQuestModel:isSpQuest(id)
	local questType = FuncQuest.readEverydayQuest(id, "conditionType");
	return questType == 1 and true or false;
end

--[[
	是否有完成的任务
]]
function DailyQuestModel:isHaveFinishQuest()
	if self:isOpen() == false then 
		return false;
	end 

	local allShowQuests = self:getAllShowDailyQuestId();
	for k, v in pairs(allShowQuests) do
		if self:isDailyQuestFinish(v) == true then 
			return true;
		end 
	end
	return false;
end

--[[
	是否开启了
]]
function DailyQuestModel:isOpen()
    local isOpen, needLvl = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.EVERY_DAY_QUEST);
	return isOpen, needLvl;
end

--[[
	sp任务的事件
]]
function DailyQuestModel:initSpQuestCheck()

	function getLeftTime(date, targetHour)
		local curHour = date.hour;
		local curMin = date.min;
		local curSec = date.sec;
		--+10是为了预留10s
		return targetHour * 60 * 60 - (curHour * 60 * 60 + curMin * 60 + curSec) + 10;
		-- return 20;
	end

	local curSpQuest = self:getCurShowSpQuest();
	-- echo("curSpQuest " .. tostring(curSpQuest));
	if curSpQuest ~= nil then 

		local spCondition = FuncQuest.readEverydayQuest(curSpQuest, "spCondition");
		local leftTime = 0;
		local curTime = TimeControler:getServerTime();
		local dates = os.date("*t", curTime);
		-- dump(dates, "--dates");
		if self:isDailyQuestFinish(curSpQuest) == true then 
			--结束时刷新
			leftTime = getLeftTime(dates, spCondition[2]);
		else 
			--开始时刷新
			leftTime = getLeftTime(dates, spCondition[1]);
		end 

		TimeControler:startOneCd(QuestEvent.QUEST_CHECK_SP_EVENT, leftTime);
	end 	
end

function DailyQuestModel:spCheckCallBack()
	echo("---spCheckCallBack-----");

	self:initSpQuestCheck();
	local isShow = false;

	if self:isHaveFinishQuest() == true then 
		isShow = true 
	else 
		if MainLineQuestModel == nil or MainLineQuestModel:isHaveFinishQuest() == false then 
			isShow = false;
	    else 
	    	if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.EVERY_DAY_QUEST) == true then 
	    		isShow = true;
	    	end 
	    end 		
	end 

	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
        {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = isShow});
end

return DailyQuestModel













