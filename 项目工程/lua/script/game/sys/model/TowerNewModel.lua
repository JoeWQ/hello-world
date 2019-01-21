local TowerNewModel = class("TowerNewModel", BaseModel)

function TowerNewModel:init(data)

	TowerNewModel.super.init(self, data)

	self._datakeys = {
		maxFloor = 0,            -- 最高层数 到第10层了，这个是9
		achievementReward = {}, -- 爬塔已经领取过的成就奖励 
		resetStatus = 0,         -- 重置状态 (1,未重置 ，不可扫荡；2，已重置，可扫荡)
		firstTime = 0,           -- 爬塔功能开启时间(玩家第一次玩这个玩法的时间)
        currentFloor = 1,
	}


	self:createKeyFunc()
	self.sortedAchievementArrConfig = {}
    EventControler:addEventListener(InitEvent.INITEVENT_FUNC_INIT, self.onFuncInit, self)  
end
function TowerNewModel:onFuncInit(event)
	local params = event.params
	local funcname = params.funcname
	if funcname == "FuncTower" then
		self:initData()
	end
end
function TowerNewModel:initData()
	local _data = FuncTower.getTowerAchievementConfig()
	for i, v in pairs(_data) do
		table.insert(self.sortedAchievementArrConfig, v)
	end

	function sortById(a, b)
		return tonumber(a.id) < tonumber(b.id)
	end
	table.sort(self.sortedAchievementArrConfig, sortById)


end
function TowerNewModel:getSortedAchievementConfig()
	return self.sortedAchievementArrConfig
end
-- 成就是否可领取
function TowerNewModel:getAchievementState()
    dump(self:achievementReward(),"成就领取")
    for i,v in pairs(self.sortedAchievementArrConfig) do
        if self:achievementReward()[v.id] == nil then
            if tonumber(self:maxFloor()) < tonumber(v.floor) then
                return false
            end
            return true
        end
        
    end
    return false
end


function TowerNewModel:updateData(data)
	local newFloor = data.maxFloor
	local oldFloor = self:maxFloor()
    TowerNewModel.super.updateData(self, data)
    dump(data,"爬塔回调")

    EventControler:dispatchEvent(TowerEvent.TOWERR_RED_POINT_UPDATA)
	

end

--是否玩过爬塔
function TowerNewModel:isFirstDayPlay()
	local time = self:firstTime()
	local now = TimeControler:getServerTime()
	local firstTimeInfo = os.date("*t", time)
	local todayInfo = os.date("*t", now)
	if time == 0 then
		return true
	end
	if firstTimeInfo.year == todayInfo.year and firstTimeInfo.month == todayInfo.month and firstTimeInfo.day == todayInfo.day then
		return true
	end
	return false
end

function TowerNewModel:isShowRed()
	local showRed = self:checkRedPoint()
	return showRed
end 

--在本层内的进度
function TowerNewModel:getTowerFloorProgress()
	
end

-----------------------------------------------------
-----------------------------------------------------
--宝箱逻辑
function TowerNewModel:getTreasureBoxKeys()
    local copper = ItemsModel:getItemNumById(FuncTower.KEYS.COPPER)
    local silver = ItemsModel:getItemNumById(FuncTower.KEYS.SILVER)
    local gold = ItemsModel:getItemNumById(FuncTower.KEYS.GOLD)
    --铜、银、金
    local keys = {copper, silver, gold}
    return keys
end

function TowerNewModel:getCanOpenBoxNumOnce(keyId)
    local leftKeyNum = ItemsModel:getItemNumById(keyId)
    if leftKeyNum > 10 then
    	return 10
    else
    	return leftKeyNum
	end
end

function TowerNewModel:checkRedPoint()
	--开宝箱红点
	local canOpen = self:_checkCanOpenBox()
	local newAchievement = self:_checkCanGetNewAchievement()

	
	local resetRedPoint = self:checkResetRedPoint()
	local newRedPoint = canOpen or newAchievement or canGetSweepReward or resetRedPoint
	if newRedPoint then
		-- do something
	end
	return newRedPoint
end
--单个品种钥匙数量 >= 1 时，提示红点
function TowerNewModel:_checkCanOpenBox()
	local keyTypes = FuncTower.KEY_TYPES
	local canOpenBox = false
	for _, keyType in pairs(keyTypes) do
		local keyId = FuncTower.KEYS[keyType]
		local num = ItemsModel:getItemNumById(keyId)
		if num >= 1 then
			canOpenBox = true
		end
	end
	return canOpenBox
end


function TowerNewModel:_checkCanGetNewAchievement()
	local data = self:achievementReward()
	local config = FuncTower.getTowerAchievementConfig()
	local sortById = function(a, b)
		return tonumber(a.id) < tonumber(b.id)
	end
	local newAchievement = false
	local keys = table.sortedKeys(config, sortById)
	for _, id in ipairs(keys) do
		if data[id] == nil and tonumber(config[id].floor) <= tonumber(self:maxFloor()) then
			newAchievement = true
			break
		end
	end
	EventControler:dispatchEvent(TowerEvent.TOWER_CAN_GET_NEW_ACHIEVEMENT, {canGet = newAchievement})
	return newAchievement
end

function TowerNewModel:getTowerResetCost()
    local vipLevel = UserModel:vip();
    local extra = FuncCommon.getVipPropByKey(vipLevel, "resettimes");
    if extra ~= nil and extra > 0 then
        local cost = FuncCommon.getVipPropByKey(vipLevel, "resetconsume");
        local alreadyResetCount = CountModel:getTowerResetCount()
        if alreadyResetCount >= self:getTowerResetMaxCount() then
            return 0
        else
            return cost[alreadyResetCount] or 0
        end
        
    else
        return 0
    end
    
    
end
-- 最大重置次数 
function TowerNewModel:getTowerResetMaxCount()
    local vipLevel = UserModel:vip();
    local extra = FuncCommon.getVipPropByKey(vipLevel, "resettimes") or 0;
    return FuncTower.MAX_RESET_COUNT + extra

end
-- 剩余重置次数
function TowerNewModel:getTowerResetLeftCount()
	local max = self:getTowerResetMaxCount()
	local alreadyResetCount = CountModel:getTowerResetCount()
	local left = max - alreadyResetCount
	return left
end

--根据状态计算当前应该显示第几层
function TowerNewModel:getCurrentShowFloor()
	local floor = self:currentFloor()
	
	return floor
end


function TowerNewModel:checkResetRedPoint()
	--local show = true
	local sweepStatus = self:resetStatus()
	local redPointShow = false
	if sweepStatus == 1 then
		local currentShowFloor = self:getCurrentShowFloor()
		local maxFloor = self:maxFloor() + 1
		if currentShowFloor+1 > 1 and currentShowFloor == maxFloor then
			redPointShow = self:getTowerResetLeftCount() > 0 
		end
	end
	if self:isFirstDayPlay() then
		redPointShow = false
	end
	EventControler:dispatchEvent(TowerEvent.TOWER_CAN_RESET_RED_POINT, redPointShow)
	return redPointShow
end


function TowerNewModel:showDetail(rewardType, rewardId, rewardNum)
	local params = {
		itemResType = rewardType,
		itemId = rewardId,
		viewType = FuncItem.ITEM_VIEW_TYPE.SIGN,
		itemNum = rewardNum,
		desStr  = "", 
	};
	WindowControler:showWindow("CompGoodItemView", params); 
end
--
function TowerNewModel:randomArr(count,arr)
    local selected={};
	math.random(0,#arr);
	math.randomseed(os.time());
	if #arr<=count then return unpack(arr) end
	while #selected < count do
		math.random(#arr);
		table.insert(selected,table.remove(arr,math.random(#arr)));
	end
    dump(selected,"選擇屬性")
	return selected
end

function TowerNewModel:setSelectedShuxing(shuxing)
    self.selectedShuxing = shuxing
end
function TowerNewModel:getSelectedShuxing()
    return self.selectedShuxing
end
function TowerNewModel:setLastFloor(floor)
    self.lastFloor = floor
end
function TowerNewModel:getLastFloor()
    return self.lastFloor
end


return TowerNewModel
