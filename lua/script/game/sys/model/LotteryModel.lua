--
-- Author: ZhangYanguang
-- Date: 2016-02-01
-- 抽卡数据类

local LotteryModel = class("LotteryModel",BaseModel)

function LotteryModel:init( d )
	LotteryModel.super.init(self,d)

	self.maxTimes = 10  		--钻石抽累计出法宝的最大次数
	self.tokenOneCost = 1		--令牌单抽消耗
	self.tokenFiveCost = 5		--令牌五连抽消耗

	self.lotteryType = {
		TYPE_TOKEN = 1, 		--令牌抽
		TYPE_GOLD = 2, 			--令牌抽
	}

	self.lotteryActionType = {
		TYPE_TOKEN_FREE = 1, 	--免费令牌抽
		TYPE_GOLD_FREE = 2, 	--免费钻石抽

		TYPE_TOKEN_ONE = 3, 	--令牌抽
		TYPE_TOKEN_FIVE = 4, 	--令牌连抽
		TYPE_GOLD_ONE = 5,  	--钻石单抽
		TYPE_GOLD_TEN = 6,  	--钻石十连抽
	}

	--注册函数  keyData
	self._datakeys = {
		freeTimes = 0,
		oneTimes = 0,
		tenTimes = 0,
	}

	self:createKeyFunc()

	self:sendRedStatusMsg()
end

-- 发送小红点状态消息
function LotteryModel:sendRedStatusMsg() 
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT
			, {redPointType = HomeModel.REDPOINT.NAVIGATION.CARD, isShow = self:hasFreeLottory()})
end

-- 是否有免费抽卡
function LotteryModel:hasFreeLottory()
	local leftTokenCdSecond = TimeControler:getCdLeftime("CD_ID_LOTTERY_TOKEN_FREE")
    local leftGoldCdSecond = TimeControler:getCdLeftime("CD_ID_LOTTERY_GOLD_FREE")

    if leftTokenCdSecond <= 0 or leftGoldCdSecond <= 0 then
    	return true
    else
    	return false
    end
end

-- 检查令牌是否足够
function LotteryModel:isTokenEnough(_times)
	local times = _times or 1
	local userToken = UserModel:getToken()
    local costToken = self:getTokenLotteryOneCost() * times
    if tonumber(userToken) < tonumber(costToken) then
    	return false
    else
    	return true
    end
end

-- 检查钻石是否足够
function LotteryModel:isGoldEnough(_times)
	local times = _times or 1
	local goldCost = 0

	local userGold = UserModel:getGold()
	if times == 1 then
		goldCost = self:getGoldLotteryOneCost()
	elseif times == 10 then
		goldCost = self:getGoldLotteryTenCost()
	end

    if tonumber(userGold) < tonumber(goldCost) then
    	return false
    else
    	return true
    end
end


function LotteryModel:isGoldLotteryInCd()
	local cd_id = "CD_ID_LOTTERY_GOLD_FREE"
	local leftTime = TimeControler:getCdLeftime(cd_id)
	return leftTime > 0
end

function LotteryModel:isTokenLotteryInCd()
	local cd_id = "CD_ID_LOTTERY_TOKEN_FREE"
	local leftTime = TimeControler:getCdLeftime(cd_id)
	return leftTime > 0
end

function LotteryModel:updateData( data )
	LotteryModel.super.updateData(self,data);
end

-- 获取令牌抽卡cd时间
function LotteryModel:getTokenLotteryCdTime()
	-- if true then
	-- 	local serverTime = TimeControler:getServerTime()
	-- 	return serverTime + 30
	-- end
	local cdSecond = FuncCommon.getCdTimeById(CdModel.CD_ID.CD_ID_LOTTERY_TOKEN_FREE)
	return cdSecond
end

-- 获取钻石抽卡cd时间
function LotteryModel:getGoldLotteryCdTime()
	-- if true then
	-- 	local serverTime = TimeControler:getServerTime()
	-- 	return serverTime + 30
	-- end

	local cdSecond = FuncCommon.getCdTimeById(CdModel.CD_ID.LOTTERY_GOLD_FREE)
	return cdSecond
end

-- 服务端不推送更新，自动加1更新
function LotteryModel:addTokenLotteryTimes()
	self._datakeys.freeTimes = self._datakeys.freeTimes + 1
end

-- 服务端不推送更新，自动加1更新
function LotteryModel:addGoldLotteryTimes()
	self._datakeys.oneTimes = self._datakeys.oneTimes + 1
end

-- 获取令牌抽免费次数
function LotteryModel:getTokenLotteryFreeTimes()
	return self:freeTimes()
end

-- 钻石单抽次数
function LotteryModel:getGoldLotteryOneTimes()
	return self:oneTimes()
end

-- 钻石十连抽次数
function LotteryModel:getGoldLotteryTenTimes()
	return self:tenTimes()
end

-- 获取令牌单抽花费
function LotteryModel:getTokenLotteryOneCost()
	return 1
end

-- 获取令牌单抽花费
function LotteryModel:getTokenLotteryFiveCost()
	return 5
end

-- 获取钻石单抽花费
function LotteryModel:getGoldLotteryOneCost()
	local costGold = FuncDataSetting.getDataByConstantName("LotteryConsume1")
	return costGold
end

-- 获取钻石十连抽花费
function LotteryModel:getGoldLotteryTenCost()
	local costGold = FuncDataSetting.getDataByConstantName("LotteryConsume2")
	return costGold
end

-- 获取钻石单抽累计必出法宝的次数
function LotteryModel:getGoldLotteryCountTimes()
	local countTimes = FuncDataSetting.getDataByConstantName("LotteryNumber")
	return countTimes
end

-- 判断treasure是否已在treasureList中
function LotteryModel:hasContain(treasureList,treasure)
	if treasureList == nil or #treasureList == 0 then
		return false
	end

	for i=1,#treasureList do
		local curTreasure = treasureList[i]
		if tostring(treasure.id) == tostring(curTreasure.id) and tostring(treasure.resType) == tostring(curTreasure.resType) then
			return true
		end
	end

	return false
end

-- 根据类型获取钻石抽奖品列表
function LotteryModel:getGoldLotteryRewardListByType(resType)
	local resList = {}
	local rewardList = self:getGoldLotteryRewardList()

	for i=1,#rewardList do
		local curReward = rewardList[i]
		if tonumber(resType) == tonumber(curReward.resType) then
			table.insert(resList,curReward)
		end
	end

	return resList
end

-- 根据类型获取令牌抽奖品列表
function LotteryModel:getTokenLotteryRewardListByType(resType)
	local resList = {}
	local rewardList = self:getTokenLotteryRewardList()

	for i=1,#rewardList do
		local curReward = rewardList[i]
		if tonumber(resType) == tonumber(curReward.resType) then
			table.insert(resList,curReward)
		end
	end

	return resList
end

-- 获取钻石抽奖品列表
function LotteryModel:getGoldLotteryRewardList()
	local rewardList = {}
	local lotteryOneData = FuncLottery.getLotteryOneData()
	local lotteryTenData = FuncLottery.getLotteryTenData()

	self:parseRewardList(rewardList,lotteryOneData)
	self:parseRewardList(rewardList,lotteryTenData)

	self:sortRewardList(rewardList)

	return rewardList
end

-- 获取令牌抽奖品列表
function LotteryModel:getTokenLotteryRewardList()
	local rewardList = {}
	local lotteryFreeData = FuncLottery.getLotteryFreeData()

	self:parseRewardList(rewardList,lotteryFreeData)
	self:sortRewardList(rewardList)

	return rewardList
end

-- 解析奖品配置，过滤同时相同的(条件：类型与id相同)
function LotteryModel:parseRewardList(rewardList,lotteryData)
	local lotteryFreeData = lotteryData
	for k,v in pairs(lotteryFreeData) do
		local reward = {}

		local rewardStr = v.reward[1]
		local rewardArr = string.split(rewardStr,",")
		
		local resType = rewardArr[1]
		local treasureId = rewardArr[2]
		local resNum = rewardArr[3]

		reward.id = treasureId
		reward.resType = resType
		reward.resNum = resNum

		-- 没有找到相同的id和resType奖品
		if not self:hasContain(rewardList, reward) then
			local quality = FuncTreasure.getValueByKeyTD(treasureId,"quality")
			local star = FuncTreasure.getValueByKeyTD(treasureId,"initStar")
			local state = FuncTreasure.getValueByKeyTD(treasureId,"initState")

			reward.quality = quality
			reward.star = star
			reward.state = state

			table.insert(rewardList, reward)
		end
	end
end

-- 奖品排序，类型->品阶->星级->id
function LotteryModel:sortRewardList(rewardList)
	table.sort(rewardList,function(a,b)
		if a.resType > b.resType then
			return true
		elseif a.resType == b.resType then
			if a.quality > b.quality then
				return true
			elseif a.quality == b.quality then
				if a.star > b.star then
					return true
				elseif a.star == b.star then
					if a.id > b.id then
						return true
					else
						return false
					end
				end
			end
		end
	end)
end


return LotteryModel
