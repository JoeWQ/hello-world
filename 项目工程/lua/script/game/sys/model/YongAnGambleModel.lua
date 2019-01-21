
local YongAnGambleModel=class("YongAnGambleModel", BaseModel)

function YongAnGambleModel:init(d)
	YongAnGambleModel.super.init(self, d)
	self._datakeys = {
		bonusId = 0, --成就id
		count = 0, --吉的数量
		random = "111111", --剩余几个骰子的点数
		status = 0, --当前状态，初始投掷，可以改投
	}
	self:createKeyFunc()
end

function YongAnGambleModel:updateData(serverData)
	YongAnGambleModel.super.updateData(self, serverData)
end

function YongAnGambleModel:getMaxGambleCount()
	local initial = FuncYongAnGamble.getInitialGambleCount() 
	local add = self:getBonusAddCount()
	local max = initial + add
	return max
end

--剩余投掷次数
function YongAnGambleModel:getGambleLeftCount()
	local count = CountModel:getYongAnGmableCount()
	local max = self:getMaxGambleCount()
	local left = max - count
	if left <= 0 then
		left = 0
	end
	return left
end

function YongAnGambleModel:getBonusAddCount()
	local bonusId = self:get("bonusId", 0)
	local count = FuncYongAnGamble.getBonusAddGambleCount(bonusId)
	return count
end

--剩余免费改投次数
function YongAnGambleModel:getGambleFreeChangeLeftCount()
	local count = CountModel:getYongAnGmableChangeFateCount()
	local max = FuncYongAnGamble.getDailyFreeChangeCount()
	local left = max - count
	if left <= 0 then
		left = 0
	end
	return left
end

--付费改投剩余次数
function YongAnGambleModel:getGambleChargeChangeLeftCount()
	local freeLeft = self:getGambleFreeChangeLeftCount()
	local chargeMax = FuncYongAnGamble.getDailyChargeChangeCount()
	if freeLeft >0 then
		return chargeMax
	end
	local freeMax = FuncYongAnGamble.getDailyFreeChangeCount()
	local count = CountModel:getYongAnGmableChangeFateCount()
	local chargeLeft = (freeMax + chargeMax) - count
	chargeLeft = _yuan3(chargeLeft<0, 0, chargeLeft)
	return chargeLeft
end

function YongAnGambleModel:getCurrentStatus()
	return self:get("status", 0)
end

--返回六个骰子的点数数组
function YongAnGambleModel:getDicesStatus()
	local count = self:get("count")
	local random = self:get("random")
	local ret = {}
	for i=1,count do
		ret[i] = 6
	end
	for v in string.gmatch(random, "%d") do
		if #ret >= FuncYongAnGamble.DICES_COUNT then
			break
		end
		local point = tonumber(v)
		if point == 6 then
			count = count + 1
		end
		table.insert(ret, point)
	end
    local function _table_sort(a,b)
          return a>b;
    end
    table.sort(ret,_table_sort);
	return ret, count
end

--是否是全部是吉
function YongAnGambleModel:isMaxLuckAchieved()
	local status_arr = self:getDicesStatus()
	if #status_arr < 6 then
		return false
	end
	for _, v in ipairs(status_arr) do
		if tonumber(v) ~= 6 then
			return false
		end
	end
	return true
end

--付费改命次数到达
function YongAnGambleModel:isMaxVipChangeCountReached()
	local count = CountModel:getYongAnGmableChangeFateCount()
	local free = FuncYongAnGamble.getDailyFreeChangeCount()
	local charge = FuncYongAnGamble.getDailyChargeChangeCount()
	if count >= free + charge then
		return true
	end
	return false
end


function YongAnGambleModel:getCurrentBonusId()
	return self:get("bonusId", 0)
end

--获取下个成就
function YongAnGambleModel:getNextBonusId()
	local bonusId = self:getCurrentBonusId()
	local nextBonusId = (tonumber(bonusId) + 1)..''
	local bonusConfig = FuncYongAnGamble.getBonusConfig(nextBonusId)
	if not bonusConfig then return nil end
	return nextBonusId
end

function YongAnGambleModel:getBonusDescription(bonusId)
	local desc = ""
	local config = FuncYongAnGamble.getBonusConfig(bonusId)
	if not config then return desc end

	local achieved, currentNum, totalNeedNum, gambleTimes = self:checkBonusAchieved(bonusId)
	local preConfig = FuncYongAnGamble.getBonusConfig((tonumber(bonusId)-1).."")
	local preGambleTimes = 0
	if preConfig then
		preGambleTimes = preConfig.gambleTimes
	end

	local treasureQuality = config.treasureQuality
	local addGambleTimes = gambleTimes - preGambleTimes
	if treasureQuality > 0 then
		local descTid = "tid_gamble_1004"
		desc = GameConfig.getLanguageWithSwap(descTid, treasureQuality, currentNum, totalNeedNum, addGambleTimes)
	else
		local descTid = "tid_gamble_1003"
		desc = GameConfig.getLanguageWithSwap(descTid, currentNum, totalNeedNum, addGambleTimes)
	end
	return desc
end

function YongAnGambleModel:checkBonusAchieved(bonusId)
	bonusId = tostring(bonusId)
	if not bonusId then return false end
	local config = FuncYongAnGamble.getBonusConfig(bonusId)

	if not config then
		return false
	end
	local treasureNum = config.treasureNum
	local treasureQuality = config.treasureQuality
	local gambleTimes = config.gambleTimes
	local currentNum = 0
	local totalNum = treasureNum
	local needQuality = treasureQuality
	if treasureQuality > 0 then
		currentNum = TreasuresModel:getOwnTreasureCountByQuality(treasureQuality) + TreasuresModel:getDestroyTreasureCountByQuality(treasureQuality)
	else
		local allTreasures = TreasuresModel:getAllTreasure()
		currentNum = TreasuresModel:getOwnTreasureCount() + TreasuresModel:getDestroyTreasureCount()
	end
	return currentNum >= totalNum, currentNum, totalNum, gambleTimes, needQuality
end

function YongAnGambleModel:getNpcTalkStatus()
	local leftGambleCount = self:getGambleLeftCount()
	local gambleStatus = self:getCurrentStatus()
	local status
	if gambleStatus == FuncYongAnGamble.ROLL_STATUS.INIT then
		if leftGambleCount <= 0 then
			status = 1
		else
			status = 2
		end
	else
		local dices_status, luckCount = self:getDicesStatus()
		status = 3 + luckCount
	end
	return status
end

function YongAnGambleModel:getRandomNpcTalks()
	local npcStatus = self:getNpcTalkStatus()
	local talk = FuncYongAnGamble.getRandomNpcTalks(npcStatus)
	return talk
end

return YongAnGambleModel
