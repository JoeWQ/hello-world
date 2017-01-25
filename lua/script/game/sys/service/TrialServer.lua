
local TrialServer = class("TrialServer")

function TrialServer:init()
	echo("TrialServer:init");

    --匹配战斗收到战斗结果
    EventControler:addEventListener("notify_trial_match_battle_end_1810", 
        self.MatchBattleEndCallBack, self);

    --主动离开战斗
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_USER_LEAVE, 
        self.onBattleLeave, self);

    --单人战斗结束，上报结果
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT, 
        self.blockBattleEnd, self);


    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,
        self.showDeblockActionCallBack, self);

end 

function TrialServer:showDeblockActionCallBack( ... )
	echo("-------------------------------------------------------------------");
	echo("-------======TrialServer:showDeblockActionCallBack=======---------");
	echo("-------------------------------------------------------------------");

end

--单人战斗结束，上报战斗结果
function TrialServer:blockBattleEnd(data) 
    echo("------TrialDetailView:blockBattleEnd(data)-------");

    local matchSystem = BattleControler:getBattleLabel();
	if self:isTrailBattle(matchSystem) == true then 
	    dump(data.params, "TrialServer:blockBattleEnd");

	    local battleParams = {}
	    battleParams.frame = data.params.frame
	    battleParams.fragment = data.params.fragment
	    battleParams.operation = data.params.operation
	    battleParams.rt = data.params.rt
	    battleParams.battleId = self._battleId;
	    
	    self._result = data.params.rt;

	    self:endBattle(c_func(self.endBattleCallback, self), 
	        battleParams);
	end 
end

function TrialServer:setBattleId(battleId)
	self._battleId = battleId;
end

function TrialServer:getBattleId()
	return self._battleId
end

function TrialServer:onBattleLeave(data)
	echo("---TrialServer:onBattleLeave----")

	local matchSystem = BattleControler:getBattleLabel();
	if self:isTrailBattle(matchSystem) == true then 
	    echo("---TrialServer:onBattleLeave == true ----")
	    local battleParams = {}
	    battleParams.frame = data.params.frame
	    battleParams.fragment = data.params.fragment
	    battleParams.operation = data.params.operation
	    battleParams.rt = data.params.rt
	    battleParams.battleId = self._battleId;

	    self._result = data.params.rt;

	    self:endBattle(c_func(self.endBattleCallback, self), 
	        battleParams);
	end 
end

function TrialServer:isTrailBattle(matchSystem)
	echo("---matchSystem---", matchSystem);
	if matchSystem == GameVars.battleLabels.trailPve or 
		matchSystem == GameVars.battleLabels.trailPve2 or
			matchSystem == GameVars.battleLabels.trailPve3 or  
				matchSystem == GameVars.battleLabels.trailGve1 or  
					matchSystem == GameVars.battleLabels.trailGve2 or  
						matchSystem == GameVars.battleLabels.trailGve3 or  
							matchSystem == GameVars.poolSystem.trail1 or  
								matchSystem == GameVars.poolSystem.trail2 or  
									matchSystem == GameVars.poolSystem.trail3 then 
		return true;
	else 
		return false;
	end 
end

function TrialServer:MatchBattleEndCallBack(event)
    local matchSystem = BattleControler:getPoolSystem();
    
    echo(" ---------MatchBattleEndCallBack-------- " .. tostring(matchSystem));

    if self:isTrailBattle(matchSystem) == true then 
	    dump(event.params, "MatchBattleEndCallBack event");

	    local preExp = UserModel:getCacheUserData().preExp;
	    local preLv = UserModel:getCacheUserData().preLv;

	    local isWin = event.params.params.data.result == "1" and true or false;
	    local expChange = 0;
	    local battleId = BattleControler:getPoolType();

	    if isWin == true then 
	    	expChange = FuncTrail.getTrailData(battleId, "winCostSp");
	    else 
	    	expChange = FuncTrail.getTrailData(battleId, "lossCostSp");
	    end 

	    echo("expChange " .. tostring(expChange));

	    BattleControler:showReward( {reward = event.params.params.data.reward,
	        result = tonumber(event.params.params.data.result), 
	        addExp = expChange, preExp = preExp, preLv = preLv}); 
	end   
end

--战斗开始
function TrialServer:startBattle(callBack, id, battleType)
	UserModel:cacheUserData();

	echo("startBattle " .. tostring(id));
	local params = {
		trialId = id,
		battleType = battleType
	}
	-- 1是单人，2是匹配
	if battleType == 1 then 
		Server:sendRequest(params, 
			MethodCode.trial_start_battle_1801, callBack )
	else 
		Server:sendRequest(params, 
			MethodCode.trial_normal_battle_1805, callBack )
	end 

end

--战斗结束
function TrialServer:endBattle(callBack, battleParams)
	echo("----TrialServer:endBattle-----");
	dump(battleParams, "__battleParams_");
	local params = {
		battleParams = battleParams
	}
	Server:sendRequest(params, MethodCode.trial_end_battle_1803, callBack);
end

function TrialServer:sweep(callBack, id, leftCount)
	echo("sweepBegin " .. tostring(id));
	echo("leftCount " .. tostring(leftCount));

	UserModel:cacheUserData();

	local params = {
		trialId = id,
		count = leftCount
	}

	Server:sendRequest(params, MethodCode.trial_sweep_battle_1807, callBack);
end

function TrialServer:endBattleCallback(event)
    echo("endBattleCallback");
    dump(event.result.data, "_____endBattleCallback-----");

    local reward = {};
    if event.result.data ~= nil then 
        reward = event.result.data.data;
    end 

    BattleControler:showReward( {reward = reward,
        result = self._result});
end


TrialServer:init();

return TrialServer





