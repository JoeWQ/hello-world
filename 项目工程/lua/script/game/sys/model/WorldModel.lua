--
-- Author: ZhangYanguang
-- Date: 2016-03-07
-- world系统数据类

local WorldModel = class("WorldModel",BaseModel)

function WorldModel:init(d)
	self.modelName = "world"

	self:initData()
	self:registerEvent()
end

function WorldModel:initData()
	-- 战斗结果最大值
	self.maxBattleRt = 7
	
	self.arabMap = {
		[0] = "十",
		[1] = "一",
		[2] = "二",
		[3] = "三",
		[4] = "四",
		[5] = "五",
		[6] = "六",
		[7] = "七",
		[8] = "八",
		[9] = "九",
	}

	self.sweepTimesMap = {
		[1] = "一",
		[2] = "二",
		[3] = "三",
		[4] = "四",
		[5] = "五",
		[6] = "六",
		[7] = "七",
		[8] = "八",
		[9] = "九",
		[10] = "十"
	}

	self.activity = {
		-- 副本掉落次数
		ACTIVITY_DROP_TIMES = 605
	}

	self.stageScore = {
		SCORE_LOCK = 0, 			--未解锁的成绩为0
		SCORE_ONE_STAR = 1,			--一星
		SCORE_TWO_STAR = 2,			--二星
		SCORE_THREE_STAR = 3, 		--三星
	}

	self.starBoxStatus = {
		STATUS_NOT_ENOUGH = 0,  --不足
		STATUS_ENOUGH = 1, 		--足够，未领取
		STATUS_USED = 2,		--已领取
	}

	self.storyStatus = {
		STATUS_LOCK = 1,  		--锁定
		STATUS_UNLOCK = 2, 		--解锁
		STATUS_PASS = 3,		--通关
	}

	self.kind = {
		KIND_NORMAL = 1,		--普通关卡
		KIND_ELITE = 2,			--额外宝箱关卡
		KIND_BOSS = 3			--boss关卡
	}

	-- 章分组数据缓存
	self.groupListCache = {}

	-- 缓存用户数据
	UserModel:cacheUserData()
	
	self:sendRedStatusMsg()
end

--更新数据
function WorldModel:updateData(data)
	WorldModel.super.updateData(self,data);
end

--删除数据
function WorldModel:deleteData( data ) 
	
end

function WorldModel:registerEvent()
	-- 商店开启消息
    EventControler:addEventListener(ShopEvent.SHOPEVENT_TEMP_SHOP_OPEN,self.onOpenShop,self)
    -- 开启宝箱
    EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES, self.sendRedStatusMsg, self)
    -- 开启额外宝箱
    EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_EXTRA_BOXES, self.sendRedStatusMsg, self)
    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.sendRedStatusMsg, self)
end

-- 发送小红点状态消息
function WorldModel:sendRedStatusMsg() 
	local isShowRedPoint = self:hasStarBoxes() or self:hasExtraBoxes()
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT
			, {redPointType = HomeModel.REDPOINT.DOWNBTN.WORLD, isShow = isShowRedPoint})
end

-- 临时商店开启
function WorldModel:onOpenShop(event)
	self.shopType = event.params.shopType
end

function WorldModel:getOpenShopType()
	return self.shopType
end

-- 战斗前重置状态
function WorldModel:resetDataBeforeBattle()
	self.shopType = nil
end

-- 保存当前战斗PVE 信息
function WorldModel:setCurPVEBattleInfo(battleInfo)
	self.curPVEBattleInfo = battleInfo
end

-- 获取当前战斗PVE RaidId
function WorldModel:getCurPVEBattleInfo()
	return self.curPVEBattleInfo
end

-- 是否是最后一章
function WorldModel:isLastChapter(storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local chapter = storyData.chapter
	local chapterType = storyData.type

	local allStoryData = FuncChapter.getStoryData()
	for k,v in pairs(allStoryData) do
		if v.type == chapterType then
			if tonumber(v.chapter) >  tonumber(chapter) then
				return false
			end
		end
	end

	return true
end

-- 是否是最后一节
function WorldModel:isLastRaidId(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	if raidData == nil then
		return false
	end
	-- 第几节
	local curSection = raidData.section

	local storyId = raidData.chapter
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local totalSection = storyData.section

	if tonumber(curSection) == tonumber(totalSection) then
		return true
	else
		return false
	end
end

function WorldModel:getStoryIdByTypeAndChapter(type,chapter)
	local allStoryData = FuncChapter.getStoryData()
	for k,v in pairs(allStoryData) do
		if tonumber(v.type) == tonumber(type) and tonumber(v.chapter) ==  tonumber(chapter) then
			return k
		end
	end

	return nil
end

-- 是否是第一章
function WorldModel:isFirstChapter(storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	return tonumber(storyId) == tonumber(self:getFirstStoryId())
end

-- 获取pve下一个解锁的节点（已经解锁）
function WorldModel:getPVENextRaidId()
	local raidId = self:getNextUnLockRaidId(FuncChapter.stageType.TYPE_STAGE_MAIN)
	return raidId
end

-- 获取已经解锁的最大GVEid
function WorldModel:getUnLockMaxGVERaidId()
	return self:getNextUnLockRaidId(FuncChapter.stageType.TYPE_STAGE_ELITE)
end

-- 获取已经解锁的最大PVE id
function WorldModel:getUnLockMaxPVERaidId()
	return self:getNextUnLockRaidId(FuncChapter.stageType.TYPE_STAGE_MAIN)
end

-- 获取指定章解锁的最大raidId
function WorldModel:getUnLockMaxPVERaididByStoryId(storyId)
	local unLockMaxRaidId = self:getUnLockMaxPVERaidId()

	local lastRaidId = FuncChapter.getLastRaidIdByStoryId(storyId)
	if tostring(unLockMaxRaidId) > tostring(lastRaidId) then
		return lastRaidId
	else
		return unLockMaxRaidId
	end
end

-- 获取PV已完成节点的下一个raidId，无论是否已解锁
function WorldModel:getNextPVERaidId()
	local unLockMaxRaidId = self:getUnLockMaxPVERaidId()
	local passMaxRaidId = UserExtModel:getMainStageId()

	local nextRaidId = unLockMaxRaidId

	-- 完成的最大节点就是已解锁的最大节点
	if tonumber(unLockMaxRaidId) == tonumber(passMaxRaidId) then
		nextRaidId = self:getNexRaidIdById(unLockMaxRaidId)
	end

	return nextRaidId
end

-- 根据RaidId获取其下一个节点，无论是否解锁
function WorldModel:getNexRaidIdById(raidId)
	local curRaidData = FuncChapter.getRaidDataByRaidId(raidId)
	local curSection = curRaidData.section
	local curChapter = curRaidData.chapter

	local nextRaidId = raidId
	local maxSection = FuncChapter.getMaxSectionByStoryId(curChapter)
	if tonumber(curSection) < tonumber(maxSection) then
		nextRaidId = tonumber(raidId) + 1
	else
		local nextStory = tonumber(curChapter) + 1
		local storyData = FuncChapter.getStoryDataByStoryId(nextStory)
		if storyData ~= nil then
			-- 获取下一章的第一节
			nextRaidId = FuncChapter.getRaidIdByStoryId(nextStory,1)
		end
	end

	return nextRaidId
end

-- 根据stageType获取下一个已解锁的raidId
function WorldModel:getNextUnLockRaidId(stageType)
	local raidId = nil
	local nextRaidId = nil

	if tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_MAIN then
        raidId = UserExtModel:getMainStageId()
    elseif tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_ELITE then
        raidId = UserExtModel:getEliteStageId()
    end

    if raidId == 0 then
    	raidId = self:getFirstRaidId(stageType)
    else
    	local storyId = FuncChapter.getStoryIdByRaidId(raidId)
    	local maxSection = FuncChapter.getMaxSectionByStoryId(storyId)
    	local curSection = FuncChapter.getRaidAttrByKey(raidId,"section")

    	local nextSection = nil
    	if tonumber(curSection) >= tonumber(maxSection) then
    		nextSection = maxSection
    		if not self:isLastChapter(storyId) then
    			local nextStoryId = storyId + 1
    			-- 开启下一章第一节
    			raidId = FuncChapter.getRaidIdByStoryId(nextStoryId,1)
    		end
    	else
    		nextSection = curSection + 1
    		raidId = FuncChapter.getRaidIdByStoryId(storyId,nextSection)
    	end
    end

    if raidId == 0 then
    	nextRaidId = 0
    else
    	if self:isRaidLock(raidId) then
    		if tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_MAIN then
		        nextRaidId = UserExtModel:getMainStageId()
		    elseif tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_ELITE then
		        nextRaidId = UserExtModel:getEliteStageId()
		    end
		else
			nextRaidId = raidId
    	end
    end

    if nextRaidId == nil then
    	echoError("WorldModel:getNextUnLockRaidId nextRaidId is nil")
    end

    return nextRaidId
end

-- 判断章是否开启，限制章开启的是等级
function WorldModel:isStoryLock(storyId)
	local firstRaidId = FuncChapter.getRaidIdByStoryId(storyId,1)
	local isLock,condition = self:isRaidLock(firstRaidId)

	local lockLevel = 1
	if condition then
		for i=1,#condition do
			local cond = condition[i]
			if cond.t == UserModel.CONDITION_TYPE.LEVEL then
				lockLevel = cond.v
				break
			end
		end
	end
	return isLock,condition,lockLevel
end

-- 判断raid是否已解锁，未解锁返回解锁条件
function WorldModel:isRaidLock(raidId)
	local isLock = true

	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	if raidData == nil then
		echoError("WorldModel:isRaidLock raidId=",raidId)
		return true,nil
	end
	local condition = raidData.condition

	local rt = UserModel:checkCondition(condition)
	if rt == nil then
		isLock = false
	end

	return isLock,condition
end

-- 根据type，获取第一个RaidId
function WorldModel:getFirstRaidId(type)
	local firstStoryId = self:getFirstStoryId()
	local firstRaidId = FuncChapter.getRaidIdByStoryId(firstStoryId,1)
	return firstRaidId
end

function WorldModel:getFirstStoryId()
	if self.minStoryId then
		return self.minStoryId
	end

	local allStoryData = FuncChapter.getStoryData()
	local minStoryId = nil
	for k,_ in pairs(allStoryData) do
		if minStoryId == nil then
			minStoryId = k
		else
			if tonumber(k) < tonumber(minStoryId) then
				minStoryId = k
			end
		end
	end

	self.minStoryId = minStoryId

	return self.minStoryId
end

-- 根据storyId，获取PVE所有节数据
function WorldModel:getMainRaidListByStoryId(storyId)
	local raidList = {}

	local raidData = FuncChapter.getRaidData()
	for k,v in pairs(raidData) do
		if tostring(v.chapter) == tostring(storyId) then
			raidList[#raidList+1] = v
		end
	end

	-- 按照section排序
	table.sort(raidList,function(a,b)
		return a.section < b.section
	end)

	-- 当前已完成的RaidId
	local curRaidId =  UserExtModel:getMainStageId()
	local endRaidId = self:getMainRaidListEndId(curRaidId,raidList)
	-- echo("curRaidId,endRaidId===",curRaidId,endRaidId)
	local newRaidList = {}
	-- 去除掉endRaidId之后的raid
	for i=1,#raidList do
		local curRaid = raidList[i]
		local curRaidId = curRaid.id
		if tonumber(curRaidId) <= tonumber(endRaidId) then
			-- 计算raid的成绩值
			curRaid.raidScore = self:getBattleStarByRaidId(curRaidId)
			-- 节点是否有额外宝箱
			if curRaid.extraBonus ~= nil then
				curRaid.hasExtraBonus = true
			else
				curRaid.hasExtraBonus = false
			end
			newRaidList[#newRaidList+1] = curRaid
			-- echo("####raidId=",curRaidId,curRaid.raidScore)
		end
	end

	return newRaidList
end

-- 获取特等星级的数量
function WorldModel:getTotalThreeStarNum(storyId)
	local stagesList = self:getMainStageList(storyId)

	local maxSection = self:getStoryMaxSection(storyId)
	local starNum = 0

	-- 如果通关
	if self:isPassStory(storyId) then
		if stagesList ~= nil then
			local length = table.length(stagesList)
			starNum = maxSection - length
		else
			starNum = maxSection
		end
	else
		-- 当前已完成的raidId
		local passMaxRaidId = UserExtModel:getMainStageId()
		-- 一个节点都没打过
		if tonumber(passMaxRaidId) == 0 then
			return starNum
		end

		local raidData = FuncChapter.getRaidDataByRaidId(passMaxRaidId)
		local passSection = raidData.section
		local curChapter = raidData.chapter

		-- curChapter是storyId对应的上一章，storyId刚开启，一个节点都没完成
		if tonumber(curChapter) <  tonumber(storyId) then
			starNum = 0
		elseif tonumber(curChapter) ==  tonumber(storyId) then
			if stagesList ~= nil then
				local length = table.length(stagesList)
				starNum = passSection - length
			else
				starNum = passSection
			end
		end
	end

	return starNum
end

-- 获取已得star总数量
function WorldModel:getTotalStarNum(storyId)
	local starNum = 0
	-- 当前已完成的raidId
	local passMaxRaidId = UserExtModel:getMainStageId()
	-- 一个节点都没打过
	if tonumber(passMaxRaidId) == 0 then
		return starNum
	end

	local raidData = FuncChapter.getRaidDataByRaidId(passMaxRaidId)
	local curChapter = raidData.chapter

	if tonumber(curChapter) >=  tonumber(storyId) then
		local allRaidData = FuncChapter.getRaidData()
		for k,v in pairs(allRaidData) do
			if tonumber(v.chapter) == tonumber(storyId) and tonumber(k) <= passMaxRaidId then
				local battleRt = self:getRaidBattleResult(tonumber(k))
				local star,_ = FuncCommon:getBattleStar(battleRt)
				-- echo("star=======")
				-- echo(star)
				-- echo(k)
				starNum = starNum + star
			end
		end
	end

	return starNum
end

-- 判断旧的回忆是否有未领取的宝箱
function WorldModel:hasStarBoxes()
	local unlockMaxStoryId = self:getUnLockMaxStoryId(FuncChapter.stageType.TYPE_STAGE_MAIN)

	local storyData = FuncChapter.getStoryDataByStoryId(unlockMaxStoryId)
	local chapterNum = storyData.chapter

	local result = false
	for i=0,chapterNum-1 do
		local curStoryId = unlockMaxStoryId - i
		result = self:hasStarBoxesByStoryId(curStoryId)
		if result then
			return result
		end
	end

	return result
end

-- 是否有未领取的额外宝箱
function WorldModel:hasExtraBoxes()
	local unlockMaxStoryId = self:getUnLockMaxStoryId(FuncChapter.stageType.TYPE_STAGE_MAIN)
	local storyData = FuncChapter.getStoryDataByStoryId(unlockMaxStoryId)
	local chapterNum = storyData.chapter

	local result = false
	for i=0,chapterNum-1 do
		local curStoryId = unlockMaxStoryId - i
		result = self:hasExtraBoxesByStoryId(curStoryId)
		if result then
			return result
		end
	end

	return result
end

-- 判断指定章是否有未领取的额外宝箱
function WorldModel:hasExtraBoxesByStoryId(storyId)
	local serverChaptersData = UserModel:chapters()
	local result = false

	if serverChaptersData ~= nil then
		local bonusData = serverChaptersData[tostring(storyId)]
		if bonusData ~= nil then
			local extraBounusData = bonusData.extraBonus
			if extraBounusData ~= nil then
				for k,_ in pairs(extraBounusData) do
					result = true
					break
				end
			end
		end
	end

	return result
end

-- 判断指定章是否有未领取的星级宝箱
function WorldModel:hasStarBoxesByStoryId(storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local storyChapter = storyData.chapter
	local bonusConArr = storyData.bonusCon

	local ownStrNum = WorldModel:getTotalStarNum(storyId)

	local result = false
	local serverChaptersData = UserModel:chapters()

	-- 固定3个宝箱
	for i=1,3 do
		local needStar = bonusConArr[i]
		-- 满足领取条件
		if ownStrNum >= needStar then
			-- 再判断是否已领取
			if serverChaptersData ~= nil then
				local bonusData = serverChaptersData[tostring(storyId)]
				if bonusData ~= nil then
					-- 满足，未领取
					if bonusData["bonus"..i] ~= nil then
						result = true
						break
					-- 已经领取
					else
						result = false
					end
				end
			end
		end
	end

	return result
end

-- 星级宝箱状态
function WorldModel:getStarBoxStatus(storyId,ownStar,needStar,boxIndex)
	local status = self.starBoxStatus.STATUS_NOT_ENOUGH
	if ownStar < needStar then
		status = self.starBoxStatus.STATUS_NOT_ENOUGH
	else
		local serverChaptersData = UserModel:chapters()
		-- dump(serverChaptersData)
		if serverChaptersData ~= nil then
			local bonusData = serverChaptersData[tostring(storyId)]
			-- dump(bonusData)

			if bonusData ~= nil then
				-- 满足，未领取
				if bonusData["bonus"..boxIndex] ~= nil then
					status = self.starBoxStatus.STATUS_ENOUGH
				else
					status = self.starBoxStatus.STATUS_USED
				end
			else
				status = self.starBoxStatus.STATUS_USED
			end
		end
	end

	return status
end

-- 额外宝箱状态
function WorldModel:getExtraBoxStatus(raidId)
	local status = self.starBoxStatus.STATUS_NOT_ENOUGH

	if raidId == nil or raidId == "" then
		return status
	end

	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	local storyId = raidData.chapter

	if raidData.extraBonus == nil then
		return status
	end

	local passMaxRaidId = UserExtModel:getMainStageId()
	-- 未通过，不可以领取
	if tostring(raidId) > tostring(passMaxRaidId) then
		return status
	else
		status = self.starBoxStatus.STATUS_ENOUGH
	end

	-- 判断是否已经领取
	local serverChaptersData = UserModel:chapters()
	if serverChaptersData ~= nil then
		local bonusData = serverChaptersData[tostring(storyId)]

		-- 有未领取的
		if bonusData ~= nil then
			local extraBounusData = bonusData.extraBonus
			if extraBounusData ~= nil then
				for k,v in  pairs(extraBounusData) do
					-- 还没有领取
					if tostring(k) == tostring(raidId) then
						return status
					end
				end

				-- 已经领取
				status = self.starBoxStatus.STATUS_USED
				return status
			else
				status = self.starBoxStatus.STATUS_NOT_ENOUGH
			end
		else
			-- 全部领取完毕
			status = self.starBoxStatus.STATUS_USED
		end
	end

	return status
end

-- 获取关卡战斗结果值
function WorldModel:getRaidBattleResult(curRaidId)
	local raidData = FuncChapter.getRaidDataByRaidId(curRaidId)
	local storyId = raidData.chapter

	-- 已经完成的最大节点id
	local passMaxRaidId = UserExtModel:getMainStageId()

	local serverChaptersData = UserModel:chapters()
	-- 服务器记录的各节点成绩数据，如果结果是三星,服务端会删除数据
	local stagesList = self:getMainStageList(storyId)

	local battleResult = nil
	-- 服务器没有数据，说明全是三星或者是本章一个节点都没通关
	if stagesList == nil or table.length(stagesList) <= 0 then
		-- 通过了节点，服务器没有记录，说明成绩是三星
		if tonumber(curRaidId) <= tonumber(passMaxRaidId) then
			battleResult = self.maxBattleRt
		end
	else
		battleResult = stagesList[tostring(curRaidId)]
		-- 通过了节点，服务器没有记录，说明打了特等
		if battleResult == nil and tonumber(curRaidId) <= tonumber(passMaxRaidId) then
			-- 战斗结果7表示是三星
			battleResult = self.maxBattleRt
		end
	end

	-- 0表示没有成绩
	if battleResult == nil then
		battleResult = 0
	end

	return battleResult
end

-- 通关关卡ID，获取关卡战斗星级数据
function WorldModel:getBattleStarByRaidId(curRaidId)
	local battleResult = self:getRaidBattleResult(curRaidId)
	local star,condArr = FuncCommon:getBattleStar(battleResult)

	return star,condArr
end

-- 通关战斗结果，获取关卡战斗星级数据
function WorldModel:getBattleStar(battleResult)
	local star,condArr = FuncCommon:getBattleStar(battleResult)
	return star,condArr
end

-- 获取服务器记录的节点成绩列表
function WorldModel:getMainStageList(storyId)
	local stagesList = nil
	local serverChaptersData = UserModel:chapters()
	if serverChaptersData ~= nil then
		local storyChapter = serverChaptersData[tostring(storyId)]
		if storyChapter ~= nil then
			stagesList = storyChapter.stages
		end
	end

	return stagesList
end

-- 计算出raidList展示时最后一个id
-- 规则是,大于当前raidId的下一个有额外奖励的raidId
function WorldModel:getMainRaidListEndId(_curRaidId,sortedRaidList)
	local curRaidId = _curRaidId
	-- 第一次进入pve副本
	if tonumber(curRaidId) == 0 then
		curRaidId = sortedRaidList[1].id
	end

	for i=1,#sortedRaidList do
		local curRaidData = sortedRaidList[i]
		if tonumber(curRaidData.id) > tonumber(curRaidId) and curRaidData.extraBonus ~= nil then
			return curRaidData.id
		end
	end

	-- 返回最后一个
	curRaidData = sortedRaidList[#sortedRaidList]
	return curRaidData.id
end

-- 小写数字转大写数字(最大支持到99)
function WorldModel:getChapterNum(num)
	local numStr = ""
	local len = 0

	if num == nil or tonumber(num) == 0 then
		return numStr,len
	else
		local modNum = num % 10 
		local divNum = math.floor(num / 10)

		if modNum == 0 then
			if divNum ~= 0 then
				if divNum == 1 then
					numStr = self.arabMap[0]
					len = 1
				else
					numStr = self.arabMap[divNum] .. self.arabMap[0]
					len = 2
				end
			end
		else
			if divNum ~= 0 then
				if divNum > 1 then
					numStr = self.arabMap[divNum] .. self.arabMap[0] .. self.arabMap[modNum]
					len = 3
				else
					numStr = self.arabMap[0] .. self.arabMap[modNum]
					len = 2
				end
			else
				numStr = self.arabMap[modNum]
				len = 1
			end
		end
	end

	return numStr,len
end

-- 获取上一章Id
-- 如果当前是第一章，返回当前章Id
function WorldModel:getLastStoryId(storyId)
	if self:isFirstChapter(storyId) then
		return storyId
	end

	local curStoryData = FuncChapter.getStoryDataByStoryId(storyId)
	local curChapterNum = curStoryData.chapter
	local curStageType = curStoryData.type

	local lastChapterNum = tonumber(curChapterNum) - 1

	local storyData = FuncChapter.getStoryData()
	for k,v in pairs(storyData) do
		if tonumber(v.type) == tonumber(curStageType) and tonumber(v.chapter) == tonumber(lastChapterNum) then
			return k
		end
	end

	return nil
end

-- 获取下一章Id
-- 如果当前是最后一章，返回当前章Id
function WorldModel:getNextStoryId(storyId)
	local curStoryData = FuncChapter.getStoryDataByStoryId(storyId)
	local curChapterNum = curStoryData.chapter
	local curStageType = curStoryData.type

	local maxStoryId = WorldModel:getMaxStoryId(curStageType)
	local maxStoryData = FuncChapter.getStoryDataByStoryId(maxStoryId)
	local maxChapterNum = maxStoryData.chapter

	if tonumber(curChapterNum) >= tonumber(maxChapterNum) then
		return storyId
	end

	local lastChapterNum = tonumber(curChapterNum) + 1

	local storyData = FuncChapter.getStoryData()
	for k,v in pairs(storyData) do
		if tonumber(v.type) == tonumber(curStageType) and tonumber(v.chapter) == tonumber(lastChapterNum) then
			return k
		end
	end

	return nil
end

-- 获取最大章id
function WorldModel:getMaxStoryId(stageType)
	local storyData = FuncChapter.getStoryData()

	local maxStoryId = nil
	for k,v in pairs(storyData) do
		if tonumber(v.type) == tonumber(stageType) then
			if maxStoryId == nil then
				maxStoryId = k
			end

			if tonumber(maxStoryId) < tonumber(k) then
				maxStoryId = k
			end
		end
	end

	return maxStoryId
end

-- 判断是否通关全章
function WorldModel:isPassStory(storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)

	local stageType = storyData.type
	local raidId = nil
	if tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_MAIN then
        raidId = UserExtModel:getMainStageId()
    elseif tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_ELITE then
        raidId = UserExtModel:getEliteStageId()
    end

    local maxRaidId = self:getStoryMaxRaidId(storyId)
    if tonumber(raidId) >= tonumber(maxRaidId) then
    	return true
    else
    	return false
    end
end

-- 获取章状态
function WorldModel:getStoryStatus(storyId)
	local curStatus = nil
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)

	local stageType = storyData.type

	local unlockMaxStoryId = self:getUnLockMaxStoryId(stageType)

	-- 未解锁
	if tonumber(storyId) > tonumber(unlockMaxStoryId) then
		curStatus = self.storyStatus.STATUS_LOCK
	elseif tonumber(storyId) == tonumber(unlockMaxStoryId) then
		curStatus = self.storyStatus.STATUS_UNLOCK
	elseif tonumber(storyId) < tonumber(unlockMaxStoryId) then
		curStatus = self.storyStatus.STATUS_PASS
	end
    
    return curStatus
end

-- 判断章是否圆满:通关 and 领取了所有星级宝箱 and 领取了所有额外宝箱
function WorldModel:isStoryFinal(storyId)
	local isFinal = false
	if storyId == nil or storyId == "" then
		return isFinal
	else
		-- local isPass = self:isPassStory(storyId)
		-- echo("isPass,==",isPass)

		-- local hasStarBoxs = self:hasStarBoxesByStoryId(storyId)
		-- echo("hasStarBoxs,==",hasStarBoxs)

		-- local hasExtraBoxs = self:hasExtraBoxesByStoryId(storyId)
		-- echo("hasExtraBoxs,==",hasExtraBoxs)
		isFinal = self:isPassStory(storyId) and (not self:hasStarBoxesByStoryId(storyId)) and (not self:hasExtraBoxesByStoryId(storyId))
	end

	return isFinal
end

-- 获取PVE已经解锁的章列表
function WorldModel:getUnLockMainStoryList()
	self.nextUnLockRaidId = WorldModel:getPVENextRaidId()
	local raidData = FuncChapter.getRaidDataByRaidId(self.nextUnLockRaidId)
	local storyId = raidData.chapter

	local storyList = {}

	local allStoryData = FuncChapter.getStoryData()
	for k,v in pairs(allStoryData) do
		if tostring(k) <= tostring(storyId) then
			table.insert(storyList, k)
		end
	end

	table.sort(storyList,function(a,b)
		if a < b then
			return true
		else
			return false
		end
	end)

	return storyList
end

-- 获取已经解锁的主线最大章id
function WorldModel:getUnLockMaxMainStoryId()
	return self:getUnLockMaxStoryId(FuncChapter.stageType.TYPE_STAGE_MAIN)
end

-- 获取已经解锁的最大章id
function WorldModel:getUnLockMaxStoryId(stageType)
	local raidId = WorldModel:getNextUnLockRaidId(stageType)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)

	-- 本章已经是最后一章
	if raidData == nil then
		return nil
	end

	local unLockChapter = raidData.chapter

	return unLockChapter
end

-- 获取章中最大节数
function WorldModel:getStoryMaxSection(storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	return storyData.section
end

-- 获取章中最大RaidId
function WorldModel:getStoryMaxRaidId(storyId)
	local maxSection = self:getStoryMaxSection(storyId)
	local raidData = FuncChapter.getRaidData()

	for k,v in pairs(raidData) do
		if tostring(v.chapter) == tostring(storyId) and tonumber(v.section) == tonumber(maxSection) then
			return k
		end
	end

	return nil
end


-- 获取章小场景分组数据列表
-- group与scene概念相同
function WorldModel:getStoryGroupList(storyId)
	local groupList = self.groupListCache[storyId]
	if groupList then
		return groupList
	end

	groupList = {}
	local allSceneData = FuncChapter.getSceneDataByStoryId(storyId)
	local orderList = FuncChapter.getSceneOrderList(storyId)
	local raidList = FuncChapter.getOrderRaidList(storyId)

	local beginIndex = 1

	for i=1,#orderList do
		local group = {}
		local groupIndex = i

		group.rids = {}
		group.index = groupIndex
		groupList[groupIndex] = group

		local curSceneOrder = orderList[i]
		local curSceneData = allSceneData[curSceneOrder]
		local raidNum = curSceneData.num
		local endIndex = beginIndex + raidNum - 1

		for i=beginIndex,endIndex do
			local raidId = raidList[i]
			table.insert(group.rids,raidId)
		end

		beginIndex = beginIndex + raidNum
	end

	-- 缓存数据
	self.groupListCache[storyId] = groupList
	return groupList
end

function WorldModel:getRaidKind(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	return raidData.kind
end

-- 战斗前缓存
function WorldModel:setPVEBattleCache(cacheData)
	self.pveBattleCache = cacheData
	self:resetDataBeforeBattle()
end

function WorldModel:getPVEBattleCache()
	return self.pveBattleCache
end

function WorldModel:isPVEBattleWin()
	if self.pveBattleCache then
		local battleRt = self.pveBattleCache.battleRt
		return battleRt == Fight.result_win
	end

	return false
end

-- 设置是否进入PVE战斗
function WorldModel:setEnterPVEBattle(isEnter)
	self.isInPVEBattle = isEnter
end

function WorldModel:isBackFromPVEBattle(isEnter)
	return self.isInPVEBattle
end

-- 倒数次数小写转大写
function WorldModel:convertSweepTime(whichSweep)
	return self.sweepTimesMap[whichSweep]
end

-- 奖品累计
function WorldModel:getCountRewards(rewardData)
	local totalReard = {}
	local totalSweepReward = {}

	local addReward = function(totalReard,curRewardStr)
		local rewardArr = string.split(curRewardStr,",")

		local find = false
		for i=1,#totalReard do
			local curRewardArr = totalReard[i]

			-- 找到相同的奖品
			if #rewardArr == 2 and rewardArr[1] == curRewardArr[1] then
				-- 数量相加
				curRewardArr[2] = curRewardArr[2] + rewardArr[2]
				find = true
			elseif #rewardArr == 3 and rewardArr[1] == curRewardArr[1] and rewardArr[2] == curRewardArr[2] then
				curRewardArr[3] = curRewardArr[3] + rewardArr[3]
				find = true
			end
		end

		if not find then
			-- 存储数组格式奖品
			totalReard[#totalReard+1] = rewardArr
		end
	end

	local addRewardArr = function(totalReard,rewardArr)
		for i=1,#rewardArr do
			local curRewardStr = rewardArr[i]
			addReward(totalReard,curRewardStr)
		end
	end

	for i=1,#rewardData do
		local rewardArr = rewardData[i].reward
		local sweepRewardArr = rewardData[i].sweepReward

		addRewardArr(totalReard,rewardArr)
		addRewardArr(totalSweepReward,sweepRewardArr)
	end

	self:convertRewardArrayToString(totalReard)
	self:convertRewardArrayToString(totalSweepReward)

	return totalReard,totalSweepReward
end

-- 奖品数组转字符串格式
function WorldModel:convertRewardArrayToString(rewardData)
	for i=1,#rewardData do
		local curRewardArr = rewardData[i]
		local rewardStr = ""
		for j=1,#curRewardArr do
			rewardStr = rewardStr .. curRewardArr[j]
			if j < #curRewardArr then
				rewardStr = rewardStr .. ","
			end
		end

		rewardData[i] = rewardStr
	end
end

-- 扫荡奖品排序表
-- 排序规则：限时掉落配置顺序，品质降序，道具id升序
function WorldModel:sortSweepRewards(rewardData)
	local sortReward = function(data)

		table.sort(data,function(a,b)
			local aRewardArr = string.split(a,",")
			local bRewardArr = string.split(b,",")
			
			local aItemId = aRewardArr[2]
			local bItemId = bRewardArr[2]

			local aLimitDropOrder = FuncDataSetting.getPVELimitDropOrder(aItemId)
			local bLimitDropOrder = FuncDataSetting.getPVELimitDropOrder(bItemId)

			local aQuality = FuncItem.getItemData(aItemId).quality
			local bQuality = FuncItem.getItemData(bItemId).quality

			if aLimitDropOrder < bLimitDropOrder then
				return true
			elseif aLimitDropOrder == bLimitDropOrder then
				if aQuality > bQuality then
					return true
				elseif aQuality == bQuality then
					if aItemId < bItemId then
						return true
					else
						return false
					end
				end
			end

	    end)
	end

	for i=1,#rewardData do
		local rewardArr = rewardData[i].reward
		local sweepRewardArr = rewardData[i].sweepReward
		sortReward(rewardArr)
		sortReward(sweepRewardArr)
	end
end

-- 是不是扫荡中需要展示的目标道具
function WorldModel:isSweepTargetItem(itemId)
	if itemId == nil or itemId == "" then
		return false
	end

	local itemSubTypeArr = FuncDataSetting.getPVESweepTargetItemSubType()
	for i=1,#itemSubTypeArr do
		local itemData = FuncItem.getItemData(itemId)
		if tostring(itemData.subType) == tostring(itemSubTypeArr[i]) then
			return true
		end
	end

	return false
end

function WorldModel:getSweepTargetItems(rewardData)
	local findTargetItems = function(rewardData,targetItems)

		for i=1,#rewardData do
			local rewardStr = rewardData[i]
			local rewardArr = string.split(rewardStr,",")
			local itemId = rewardArr[2]
			-- echo("\n\n findTargetItems============itemId=" .. itemId)

			if self:isSweepTargetItem(itemId) then
				if not table.isValueIn(targetItems,itemId) then
					targetItems[#targetItems+1] = itemId
				end
			end
		end

	end

	local targetItems = {}

	for i=1,#rewardData do
		local rewardArr = rewardData[i].reward
		local sweepRewardArr = rewardData[i].sweepReward
		if rewardArr then
			findTargetItems(rewardArr,targetItems)
		end
		
		if sweepRewardArr then
			findTargetItems(sweepRewardArr,targetItems)
		end
	end

	return targetItems
end

-- 获取碎片需求数量
-- 如果没有合成，返回合成英雄需要的数量
-- 如果合成了，返回升星需要的数量
function WorldModel:getPartnerPiecesNeedNum(itemId)
	if PartnerModel:isHavedPatnner(itemId) then
		return PartnerModel:getUpStarNeedPartnerNum(itemId) or 0
	else
		return PartnerModel:getCombineNeedPartnerNum(itemId) or 0
	end
end

-- 查找下一个解锁提醒
function WorldModel:findNextGoalRaidId(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	local storyId = raidData.chapter

	local goalRaidId = nil
	local raidArr = FuncChapter.getOrderRaidList(storyId)

	for i=1,#raidArr do
		local curRaidData = FuncChapter.getRaidDataByRaidId(raidArr[i])
		if curRaidData.goal ~= nil and tostring(raidArr[i]) >= tostring(raidId) then
			goalRaidId = raidArr[i]
			return goalRaidId
		end
	end

	return goalRaidId
end

-- 是否开启掉落活动
function WorldModel:isOpenDropActivity()
	local actTaskIdList = FuncActivity.getActivityTaskListByCondition(self.activity.ACTIVITY_DROP_TIMES)
	local actId = nil

	for i=1,#actTaskIdList do
		local actTaskId = actTaskIdList[i]
		if FuncActivity.isActivityTaskOnline(actTaskId) then
			actId = actTaskId

			return true,actId
		end
	end

	return false
end

-- 获取掉落倍数
function WorldModel:getDropTimes()
	local dropTimes = 1
	local open,actTaskId = self:isOpenDropActivity()
	if open and actTaskId then
		local activityConfig = FuncActivity.getActivityTaskConfig(actTaskId)
		dropTimes = activityConfig.conditionNum
	end

	return dropTimes
end

return WorldModel
