-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local TowerServer = { }

function TowerServer:init()
	 -- 战斗结束侦听
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT, self.onPVEBattleComplete, self)
    -- 中途手动退出战斗
	EventControler:addEventListener(BattleEvent.BATTLEEVENT_USER_LEAVE, self.onBattleQuit, self)
end 


function TowerServer:setBattleID( id )
	self.battleID  = id 
end 

--设置
function TowerServer:getBattleID()
	return self.battleID 
end 

-- 战斗结束
function TowerServer:onPVEBattleComplete(event)
    
    -- 发送战斗结果
    if BattleControler:getBattleLabel() == GameVars.battleLabels.towerPve then
        self.fightResult = event.params.rt
        if self.fightResult == 1 then
            Cache:set("PaTaTiaozhanjieguo",1)
        else
            Cache:set("PaTaTiaozhanjieguo",-1)
        end
        self:requestTowerFightOverResult( {
            battleParams =
            {
                battleId = self:getBattleID(),
                frame = event.params.frame,
                fragment = event.params.fragment,
                operation = event.params.operation,
                rt =  self.fightResult,
                etime = TimeControler:getTime(),
                resultInfo = event.params.resultInfo,
                buffInfo = TowerNewModel:getSelectedShuxing()
            }
        } , c_func(self.fightOveCallBack, self))
    end 
end 

-- 服务器返回下一步的信息 包括选项事件
function TowerServer:fightOveCallBack(serverData)
    if serverData.result ~= nil then
        local rewardData = {}
        if serverData.result.data then
            rewardData.reward = serverData.result.data.reward;
        end
	    rewardData.inBattleDrop = nil;
	    rewardData.result = self.fightResult;

        dump(rewardData,"爬塔战斗结束奖励")
	    BattleControler:showReward(rewardData)
    end
   
end 
                     
function TowerServer:onBattleQuit(event)
	local params = event.params
	params.rt = Fight.result_lose
	self:onPVEBattleComplete(event)
end


--重置战斗次数
function TowerServer:requestResetFightCount(_param,_callback)

	Server:sendRequest( _param, MethodCode.tower_reset_fight_count_2603, _callback)
end 
--开启宝箱
function TowerServer:requestOpenTeasuerBox(_param , _callback)
	Server:sendRequest( _param, MethodCode.tower_open_teasuer_box_2609, _callback)
end 

--开始探索
function TowerServer:exploreWithOption(_param , _callback)
	Server:sendRequest( _param, MethodCode.tower_start_fight_2601, _callback)
end 

-- 请求排行榜
function TowerServer:requestPaihangbang(_param , _callback)
	Server:sendRequest( _param, MethodCode.tower_request_paihangbang_2615, _callback)
end 

--开始扫塔
function TowerServer:requestAutoFight(_param , _callback)
	Server:sendRequest( _param, MethodCode.tower_start_auto_fight_2605, _callback)
end 

--领取扫荡奖励
function TowerServer:requestAutoFightFinish(_param , _callback)
	Server:sendRequest( _param, MethodCode.tower_auto_fight_finish_2607, _callback)
end 

--领取成就奖励
function TowerServer:requestAchievementReward(_param , _callback)
	Server:sendRequest( _param, MethodCode.tower_achievement_reward_2613, _callback)
end 

--爬塔战斗结束，提交战斗结果
function TowerServer:requestTowerFightOverResult(_param , _callback)
	Server:sendRequest( _param, MethodCode.tower_fight_Over_result_2611, _callback)
end 
TowerServer:init()

return TowerServer

-- endregion
