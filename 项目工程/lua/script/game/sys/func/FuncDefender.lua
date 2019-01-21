FuncDefender= FuncDefender or {}

local itemData = nil

--用于显示最大挑战次数
FuncDefender.MAX_RESET_COUNT = 1
--再次领取奖励消耗的钻石
FuncDefender.MAX_GOLDCOST_COUNT = 100
function FuncDefender.init()
	-- itemData = require("items.Item")
	itemData = require("defender.DefendeRoundReward")

	-- dump(itemData,nil,6)
end

function FuncDefender.getItemData()  ----- 获得本地所有守护的波数奖励
    return itemData
end
function FuncDefender.getIDAward(awardID)   ----守护到第几关的奖励
	if awardID == nil then
		awardID = 1 
	end
	if itemData[tostring(awardID)] ~= nil then
		return itemData[tostring(awardID)]
	else
		echo("守护紫萱玩法,不存在该波数的奖励")
	end
end




function FuncDefender.getcontentInftext()
	local string = "  你也有过这样的情绪吧，因为讨厌一个样，由着自己的情绪和喜好去判断对错；也不是一无是处。我常常觉得，相比喜欢，讨厌、憎恨一类的情绪更有力量，在地去处理问题。"
	return string
end
function FuncDefender.gettitleText()   ---简介标题
	local text = "守护紫萱的玩法简介"
	return text 
end
function FuncDefender.getstageText()    
	local text = "【守护紫萱】"
	return text 
end
function FuncDefender:getstageInfText()
	local string = "因为讨厌一个样，由着自己的情绪和喜好去判断对错"
	return string
end
function FuncDefender:getAgainAwardNeedVIP()  -----获的再次领取奖励的vip条件
	local VIP = 5
	return VIP
end




