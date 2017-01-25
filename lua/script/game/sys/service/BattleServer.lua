--
-- Author: xd
-- Date: 2015-11-27 18:47:13
--
--战斗服务器交互
local BattleServer = {}


BattleServer.roomId = 32			--房间id
BattleServer.battleId = nil 		--战斗id

BattleServer.battleInfo= nil  		--战斗信息
BattleServer.timeLineFrames = nil
BattleServer.__reConnect = false 	-- 是否是重连
BattleServer._startBattle = false	-- 控制资源加载完毕开始战斗

BattleServer.__rewardInfo = nil

BattleServer._cacheMessageArr = nil 	--缓存的消息信息数组,比如可能在战斗还未开始就收到了 操作


--初始化传入控制器
function BattleServer:init( controler )
	
	self.battleId = nil
	EventControler:addEventListener("notify_battle_start_708", self.notify_battle_start_708, self)
	EventControler:addEventListener("notify_battle_pushTimeLine_710", self.notify_battle_pushTimeLine_710, self)
	EventControler:addEventListener("notify_battle_useTreasure_716", self.notify_battle_useTreasure_716, self)
	EventControler:addEventListener("notify_battle_gameResult_720", self.notify_battle_gameResult_720, self)
	
	EventControler:addEventListener("notify_battle_useAutoFight_724", self.notify_battle_useAutoFight_724, self)
	EventControler:addEventListener("notify_battle_userDrop_740", self.notify_battle_userDrop_740, self)
	EventControler:addEventListener("notify_battle_user_quit_battle_756", self.notify_battle_user_quit_battle_756, self)
	
	EventControler:addEventListener("notify_battle_loadBattleResOver_736", self.notify_battle_loadBattleResOver_736, self)
	EventControler:addEventListener("notify_battle_addOnePlayer_744", self.notify_battle_addOnePlayer_744, self)
	EventControler:addEventListener("notify_battle_addToBattle_748", self.notify_battle_addToBattle_748, self)
	EventControler:addEventListener("notify_battle_someOne_hasReady_760", self.notify_battle_someOne_hasReady_760, self)
	EventControler:addEventListener("notify_match_timeout_908", self.notify_match_timeout_908, self)

	-- 战斗结果信息
	--EventControler:addEventListener("notify_trial_match_battle_end_1810", self.notify_battle_reward, self)
	--EventControler:addEventListener("notify_world_gve_match_battle_end_1208", self.notify_battle_reward, self)
	--FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SUREQUIT,self.pressGameQuit,self )
end

----------------------------------处理通知-----------------------------------
-- 收到战斗结果的广播
function BattleServer:notify_battle_gameResult_720( ... )
	if not self.controler then
		echo("____________只有在重连的时候回出现这个问题",self.__reConnect)
		return
	end

	BattleControler:recvGameResult()
end

function BattleServer:notify_battle_reward(e)
	echo("___________战斗结果______notify_battle_reward")
	if not self.controler then
		echo("________(720)还没开始战斗,服务器发来 战斗结果 信息")
		--return 
	end

	self.__rewardInfo = true
	BattleControler:showReward( e.params )
end

-- 通知所有人新玩家加入
function BattleServer:notify_battle_addOnePlayer_744(e)
	-- if true then
	-- 	return
	-- end
	-- dump(e.params.params)
	local frame = e.params.params.data.frame
	local playerArr = e.params.params.data.battleUsers
	local num = #e.params.params.data.battleUsers
	echo("744_通知所有人新玩家加入(帧,数)",e.params.params.data.frame,num)
	if not self.controler then
		echo("________(744)还没开始战斗,服务器发来 新玩家 加入信息",num)
	end
	for i=1, num do
		local playerInfo = BattleControler:setDefaultAttr(nil,playerArr[i],self._battleInfo.battleLabel)
		echo("______________加入到人的rid",playerInfo.rid)

		self.controler:addPlayerInfo(frame,playerInfo.rid,playerInfo)
	end
end

-- 中途加入的战斗逻辑
function BattleServer:notify_battle_addToBattle_748(e)
	echo("748_中途加入战斗")
	local data = e.params.params.data
	--dump(data)
	self.__reConnect = true
	self:setBattleServer(data,Fight.conditions_nomal)
end

-- 通知某个人资源加载完毕
function BattleServer:notify_battle_someOne_hasReady_760(e)
	local data = e.params.params.data
	echo("760_战斗中人员加载完毕______",data.rid)
	if data.rid ~= self.controler.userRid then 
		EventControler:dispatchEvent(LoadEvent.LOADEVENT_USERCOMPLETE,data)
	end
end

-- 掉线与上线推送
function BattleServer:notify_battle_userDrop_740(e)
	local netData = e.params.params.data
	if not self.controler then
		echo("__________(740)还没开始战斗，服务器就发来掉线信息")
		return
	end
	echo("740__在线状态信息,type,frame,rid",self.controler.updateCount,netData.type,netData.frame,netData.rid)
	local status = Fight.state_show_zhengchang -- 2
	if netData.type == 1 then
		status = Fight.state_show_lixian -- 5
	end
	self.controler:setHeroOnlineState(netData.frame,netData.rid,status)
end

-- 退出战斗
function BattleServer:quitBattle(battleId)
	echo("753___主动退出战斗,放弃战斗")
	if battleId then
		Server:sendRequest({battleId = battleId},MethodCode.battle_user_quit_battle_753,c_func(self.quitBattleBack,self) )
	else
		Server:sendRequest({battleId = self.battleId},MethodCode.battle_user_quit_battle_753,c_func(self.quitBattleBack,self) )
	end
end
-- 退出战斗返回
function BattleServer:quitBattleBack(result)
	echo("754__主动退出战斗,服务器返回",result.result.serverInfo.serverTime)
	--dump(result.result)
	if self.controler then
		self.controler:closeRewardWindow()
	end
end

--玩家离开战斗
function BattleServer:notify_battle_user_quit_battle_756( e )	
	local netData = e.params.params.data
	echo("756__玩家退出战斗_______",self.controler.updateCount,netData.battleId,netData.rid)
	if netData.rid == UserModel:rid() then
		return
	end
	local arr = self.controler.allModelArr
	for i=1,#arr do
		if arr[i].modelType == Fight.modelType_heroes then
			if arr[i].data.rid == netData.rid then
				echo("_______________________发送永离通知")
				arr[i].data:dispatchEvent(BattleEvent.BATTLEEVENT_PLAYER_STATE,Fight.state_show_yongli)
				self.controler:setHeroAutoFight(netData.frame,netData.rid,Fight.fightState_smart)
				break
			end
		end
	end
end



-- 开始战斗
function BattleServer:startFight(startTime)
	if self.controler.__gameStep >= Fight.gameStep.load then
		-- 开始战斗清空奖励信息
		self.__rewardInfo = nil

		self._battleInfo.startTime = startTime
		self.controler:startBattle()
	else
		echo("战斗已经开始，服务器重复消息",self.controler.__gameStep,self.controler.updateCount)
		self._startBattle = true
	end
end

--战斗开始
function BattleServer:notify_battle_start_708( e )
	echo("708__战斗开始________battleid_",self.battleId)
	FuncCommUI.removePVEMatchView()
	local data = e.params.params.data
	self:setBattleServer(data,Fight.conditions_nomal)
end

-- 匹配超时
function BattleServer:notify_match_timeout_908( e )
	echo("908____________匹配超时")
	EventControler:dispatchEvent(LoadEvent.LOADEVENT_MATCH_TIME_OUT)
end


-- 开始战斗 conditions = 1 正常开始战斗,2 重连进入战斗, 3 中途加入人进入战斗
function BattleServer:setBattleServer( data, conditions )	
	if self.controler then
		echo("服务器重复信息_______开始加载资源,准备战斗")
		return
	end

	--dump(data)
	echo("setBattleServer-----",conditions)
	LogsControler:writeDumpToFile("setBattleServer--------------------------")
	LogsControler:writeDumpToFile(data)

	self.battleId = data.battleId
	--存储战斗开始的人物信息
	self._battleInfo = {} 	
	self._battleInfo.battleUsers = clone(data.battleUsers)
    self._battleInfo.randomSeed = data.randomSeed
    self._battleInfo.inBattleDrop = data.battleParams.inBattleDrop2
    self._battleInfo.poolType = data.battleParams.poolType

    self._battleInfo.battleLabel = FuncMatch.getBattleLabelByPoolType(data.battleParams.poolType)

    --这里需要根据 poolType  来获取是什么标签

    --dump(self._battleInfo.battleUsers)

	BattleControler:startGVE(self._battleInfo) -- 第一个参数是模式，1为普通战斗，2为竞技场
	self.controler = BattleControler.gameControler
	self.controler._conditions = conditions
	echo("_______开始加载资源,准备战斗",conditions)
end


--根据rid获取某个用户的信息
--[[

	如果key为空 那么返回这个用户的整个信息
	目前可选参数 key
	
	name,
]]
function BattleServer:getUserInfo( rid,key )

	for i=1,2 do
		local campArr = self._battleInfo["campArr_"..i]
		for i,v in ipairs(campArr) do
			if v.rid ==rid then
				if not key then
					return v
				else
					return v[key]
				end
			end
		end
	end
end

--服务器拉取时间片
function BattleServer:notify_battle_pushTimeLine_710(e )
	local netData = e.params.params.data
	if not self.controler then
		echo("____710_拉取时间片______self.controler为空,直接不处理了")
		return
	end

	echo("710_服务器拉取时间片信息battleId",self.controler.updateCount,netData.battleId,netData.frame)

	--dump(netData)
	if self.controler.gameBackup then
		self.controler.gameBackup:pushTimeLine(netData.frame)
	end

	-- 如果本地时间比服务器时间差距太大就要继续追
	-- local frameD= netData.frame-60
	-- if self.controler.updateCount < frameD then
	-- 	self.controler:pullTimeLine()
	-- end
end

--上报时间片
function BattleServer:pushTimeline(frame,info  )
	echo("711_上传时间片",frame,self.controler.updateCount)
	if type(info) ~= "table" then
		echo("_________上传的时间片信息不是 table")
	end
	local fragment = json.encode(info)
	if not fragment then
		dump(info)
	end
	
	Server:sendRequest({frame=frame,battleId = self.battleId,fragment =fragment  } ,MethodCode.battle_receiveFragment_711   ,nil,true )
end

--使用法宝
function BattleServer:notify_battle_useTreasure_716(e )
	local netData = e.params.params.data
	if not self.controler then
		echo("________(716)还没开始战斗，服务器就发来 放法宝  信息",netData.frame,netData.rid,info.treasureHid)
		--return
	end
	--dump(e.params.params)
	local info = json.decode(netData.magicInfo)
	self.controler:saveChangeTreasureInfo(netData.frame,netData.rid,info.treasureHid)
end




--处理请求------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
---------------重连部分-----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- 请求自身状态
function BattleServer:requestSelfState(login,serv)
	serv = serv and serv or "game"
	local params = {nodeServer = serv}
	echo("315_获取自身状态",serv)
	Server:sendRequest(params,MethodCode.user_state_315,c_func(self.requestSelfStateBack,self) )
end
-- 获取自身状态信息返回
function BattleServer:requestSelfStateBack(result)
	local netData = result.result.data
	if not netData then
		return
	end
	-- 说明掉线之前有一场战斗
	if netData.battleId then
		echo("316_应该处在战斗中,读战斗信息",netData.battleId)
		self:getBattleInfo(netData.battleId )
	else
		echo("316_没有处在战斗中")
	end
end

-- 获取战斗信息  749
function BattleServer:getBattleInfo(battleId)
	echo("749_获取战斗信息",battleId)
	Server:sendRequest({battleId = battleId},MethodCode.battle_getInfo_749,c_func(self.getBattleInfoBack,self) )
end

function BattleServer:getBattleInfoBack(result)
	local netData = result.result.data
	echo("750_通过战斗信息开始战斗,加载资源",netData.bTime)
	---dump(netData)
	if netData.isFinish and netData.isFinish==1 then
		echo("750____战斗已经结束_______")
		EventControler:dispatchEvent(LoadEvent.LOADEVENT_BATTLELOADCOMP, {result = 1})
		local scene = WindowControler:getCurrScene()
   		scene:showRoot()
		return
	end

	self.__reConnect = true

	if not netData.bTime then
		self:setBattleServer(netData,Fight.conditions_nomal)
	else
		self:setBattleServer(netData,Fight.conditions_repeat)		
	end
	self._battleInfo.startTime = netData.bTime
end
---  重连过程749---750---
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--通知服务器加载战斗资源完成
function BattleServer:loadBattleResOver( )
	if not self.battleId then
		return 
	end
	echo("733_资源加载完毕，向服务器发送通知")
	Server:sendRequest({battleId=self.battleId  } ,MethodCode.battle_loadBattleResOver_733,c_func(self.loadBattleResOverBack,self) )
end

-- 资源加载完毕,可能会带着时间片信息和操作
function BattleServer:loadBattleResOverBack( result )
	echo("734_加载资源完毕__是否重连==并检测快进",self.controler.updateCount,self.__reConnect,self._startBattle)
	
	--dump(result.result)
	local netData = result.result.data
	if netData and netData.isFinish and netData.isFinish == 1 then
		echo("734_______游戏已经结束")
		self.__reConnect = false
		self.controler._sceenRoot:unscheduleUpdate()
		BattleControler:onExitBattle()
		return
	end

	--计算游戏已经跑了多少帧,这个时候应该快进过去
	local bTime = result.result.data.bTime
	local dt = result.result.serverInfo.serverTime - bTime
	local frame = math.floor( dt/1000 * GAMEFRAMERATE ) 
	frame = frame < 0 and 0 or frame
	-- self.controler:setInitFrame(frame)

	self:adjustByTimeLine(result.result.data,result.result.serverInfo.serverTime)
	
	if self.__reConnect then
		--dump(result.result)
		--self:adjustByTimeLine(result.result.data,result.result.serverInfo.serverTime)
		echo("___5___是重连或者中途加入,直接开始战斗battleid",result.result.data.battleId)
		if not result.result.data then
			echo("______是重连或中途加入,但是没有data")
			dump(result.result)
		end
		self:startFight(result.result.data.bTime)
		self.__reConnect = false
	end
	if self._startBattle then
		--dump(result.result)
		echo("______收到736比较早所以加载完成就要开始战斗")
		self:startFight(result.result.data.bTime)
		self._startBattle = false
	end
end



-- 资源加载loading完成，开始战斗
function BattleServer:notify_battle_loadBattleResOver_736( e )
	echo("736_加载资源完毕，开始战斗",self.controler.updateCount,self.battleId,e.params.params.data.bTime )
	self:startFight(e.params.params.data.bTime)
end



--主动释放法宝
function BattleServer:giveOutTreasure( info,frame )
	echo("713_发送到服务器释放法宝",self.controler.updateCount)
	if self.controler.__gameStep < Fight.gameStep.result then
		Server:sendRequest({magicInfo= json.encode( info ),frame = frame,battleId =self.battleId  } ,MethodCode.battle_releaseMagic_713,nil,true ) 
	end
end

--切换操作
function BattleServer:changeHandle( info,frame )
	echo("721__自动手动操作___",self.controler.updateCount,info.fightState)
	Server:sendRequest({info = json.encode( info ),type =info.fightState, frame = frame,battleId =self.battleId  } ,MethodCode.battle_changeAutoBattleFlag_721,nil,true ) 
end

--切换自动战斗状态
function BattleServer:notify_battle_useAutoFight_724( e )
	echo("724_自动战斗通知",self.controler.updateCount)
	local netData = e.params.params.data
	--dump(netData)
	self.controler:setHeroAutoFight(netData.frame,netData.rid,netData.type)
end


-- 获取时间片信息
function BattleServer:pullTimeline(needUserInfo )
	echo("737_客户端获取时间信息_",self.controler.updateCount)
	Server:sendRequest({needUserInfo=needUserInfo,battleId = self.battleId} ,MethodCode.battle_pullTimeLine_737,c_func(self.pullTimelineBack,self) )
end

-- 获取时间片返回
function BattleServer:pullTimelineBack(result)
	echo("738_获得时间片信息",self.controler.updateCount)
	if not result.result.data then		
		echo("时间片内没有data信息")
		dump(result)
		return
	end
	--dump(result)
	self:adjustByTimeLine(result.result.data,result.result.serverInfo.serverTime)
end

function BattleServer:adjustByTimeLine(data,curTime)
	if not data then
		echo("______ 服务器为什么发来data为nil,需要检测一下")
		return
	end

	local fragment = nil
	local rstFragment = data.fragment
	local operation = data.operation

	if rstFragment then
		for k,v in pairs(rstFragment) do
			fragment = json.decode(v)
			break
		end
	else
		echo("获得时间片信息没有 rstFragment,从本地最新的时间片开始跑",self.controler.updateCount)
	end

	local curframe = 0
	if self._battleInfo.startTime then
		local timedif = curTime - self._battleInfo.startTime
		curframe = math.floor(timedif*30/1000)
		echo("___1___按照bTime计算当前帧(当前时间,开始时间,时间差,当期帧):",curTime,data.bTime,timedif,curframe)
	end

	echo("___2___当前是多少帧",self.controler.updateCount,curTime,self._battleInfo.startTime,curframe)

	if curframe > 0 then
		self.controler.gameBackup:setUpdateFrameInfo(fragment,operation,curframe)
	end
end

--上报战斗结果
function BattleServer:submitGameResult( frame,info,result,resultInfo )

	echo("717_ 上报战斗结果",frame,result)
	if self.__rewardInfo then
		echo("_______服务器已经广播过来战斗结果,奖励数据了")
		return
	end

	local frag = json.encode( info )
	if not frag then		
		frag = "json-encode err"
		echo("________________________",frag)
		echo(info)
	end	
	Server:sendRequest({fragment = frag, rt = result, frame = frame,battleId =self.battleId ,resultInfo = resultInfo } ,MethodCode.battle_reveiveBattleResult_717, nil, true ) 
	--Server:sendRequest({fragment = frag, rt = result, frame = frame,battleId =self.battleId  } ,MethodCode.battle_reveiveBattleResult_717 )
end


function BattleServer:deleteMe(  )
	EventControler:clearOneObjEvent(self)
end


--退出战斗
function BattleServer:onExitBattle(  )
	self.controler = nil
end


---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

--开始战斗
function BattleServer:startBattle( call )
	--如果已经开始了  返回
	if self.battleId then
		return
	end
	echo("705_向服务器发送开始战斗")
	Server:sendRequest({roomId=self.roomId  } ,MethodCode.battle_start_705  ,call )
end

--加入一个房间
function BattleServer:joinOneRoom(roomId, call )
	if roomId then
		self.roomId = roomId
	end
	local userInfo = {name = LoginControler:getUname( )  }
	Server:sendRequest({roomId=self.roomId,userInfo =  json.encode(userInfo)  } ,MethodCode.battle_joinRoom_701 ,call )
end

--退出一个房间
function BattleServer:quitOneRoom(roomId, call )
	local userInfo = {name = LoginControler:getUname( )  }
	Server:sendRequest({roomId=self.roomId} ,MethodCode.battle_quitRoom_729 ,call )
end

--,离开
function BattleServer:leaveOneRoom(userid )
	-- body
end

--离开房间返回
function BattleServer:leaveOneRoomBack(result )	
end


--开始战斗匹配
function BattleServer:startMatch(poolType,call )
	echo("901_向服务器请求匹配")
	poolType = poolType or "1"
	Server:sendRequest({poolType = poolType} ,MethodCode.match_battleStart_901 ,call  )
end


--0表示行侠仗义
-- 通过 matchsystem[loading] -> 
function BattleServer:joinMatch(poolSystem ,callBack)
	poolSystem = poolSystem 
	-- 打开loading页面
	-- local loadingId= FuncMatch.getLoadIdBySystem( poolSystem )
	-- echo("903_加入匹配池子",poolSystem,loadingId)
	-- BattleControler:setLoadingId(loadingId,2)
	--local localCallBack = function ( result )
		-- if result and result
		-- echo("点击气泡--执行加入操作的")
		-- --dump(result.)
		-- LogsControler:writeDumpToFile("点击气泡执行加入操作-----")
		-- LogsControler:writeDumpToFile(result)
		-- dump(result.result)
		-- echo("点击气泡--执行加入操作的")
		-- local loadingId= FuncMatch.getLoadIdBySystem( poolSystem )
		-- echo("903_加入匹配池子",poolSystem,loadingId)
		-- BattleControler:setLoadingId(loadingId,2)
		-- callBack(result)
	--	callBack(result,poolSystem)
	--end

	Server:sendRequest({poolSystem = poolSystem} ,MethodCode.match_joinIntive_903,callBack)
end

-- 重连后资源加载完毕
-- function BattleServer:battleLoadComplete()
-- 	echo("745_重连_资源加载完毕，向服务器发送通知")
-- 	Server:sendRequest({battleId = self.battleId },MethodCode.battle_repet_loadover_745,c_func(self.battleLoadCompleteBack,self) )
-- end
-- function BattleServer:battleLoadCompleteBack(result)	
-- 	local netData = result.result.data
-- 	dump(netData)
-- 	echo("746_重连后加载资源完毕，开始拉取时间片")
-- 	self.__reConnect = true
-- 	self:pullTimeline( false )
-- end409

--设置上次战斗id
function BattleServer:setLastBattleId( lastId )
	self._lastBattleId = lastId
end

--获取上次战斗id
function BattleServer:getLastBattleId(  )
	return self._lastBattleId
end



BattleServer:init()

return BattleServer
