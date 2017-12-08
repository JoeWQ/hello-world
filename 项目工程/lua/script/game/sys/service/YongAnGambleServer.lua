local YongAnGambleServer = YongAnGambleServer or {}

function YongAnGambleServer:beginOneGamble(callBack)
	local params = {}
	Server:sendRequest(params, MethodCode.yongan_gamble_roll_the_dice_3203, callBack)
end

--见好就收
function YongAnGambleServer:endGamble(callBack)
	local params = {}
	Server:sendRequest(params, MethodCode.yongan_gamble_end_role_3207, callBack)
end

--记录成就
function YongAnGambleServer:getAchievement(_bonusId,callBack)
	local params = {   bonusId=_bonusId    }
	Server:sendRequest(params, MethodCode.yongan_gamble_get_achievement_3201, callBack,nil,nil,true)
end

--改投
function YongAnGambleServer:changeFate(callBack)
	local params = {}
	Server:sendRequest(params, MethodCode.yongan_gamble_change_role_fate_3205, callBack)
end


return YongAnGambleServer
