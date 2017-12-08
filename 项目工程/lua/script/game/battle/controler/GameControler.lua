
--
-- Author: xiangdu
-- Date: 2014-01-01 16:01:28
--

--游戏世界的坐标系 采用  flash 坐标系  最终转化成cocos 坐标系,容器的初始化顶点在左上角

--campArr  里面的人物对象 会按照 相对中心x的距离排序  这样可以减少逻辑中经常需要用到的排序算法 减少重复排序

--所有的对象数组

GameControler = class("GameControler")

GameControler.allModelArr = nil 	--所有对象数组
GameControler.depthModelArr = nil 	--只需要进行深度排列的数组
GameControler.campArr_1 = nil 		--1我放成员数组
GameControler.campArr_2 = nil 		--2敌方成员数组
GameControler._pvpDummy = true 		-- pvp战斗不需要备份

GameControler.character = nil
--

GameControler.diedArr_1 = nil 		--死亡即将被复活的数组
GameControler.diedArr_2 = nil 		--死亡即将被复活的数组2

GameControler.screen = nil


GameControler.replayGame = 0       -- 游戏 replayGame 0 正常战斗 1 回放当前战斗 2 回放已经打完的战斗	
GameControler.scenePause = false	   --普通场景暂停 考虑到追打造技能状态  那么 这个时候 是暂停普通场景的
GameControler.scenePauseLeft = - 1 		--剩余场景暂停时间						
GameControler.skillPauseInfo = nil  --技能播放暂停信息



GameControler.callFuncArr = nil 		--回调队列 因为初始化的人物一定要分帧创建 否则会非常卡



GameControler._gamePause = false 	-- 是否游戏暂停  考虑到 游戏模拟场景  

GameControler.gameSpeed = 1   		-- 当前游戏播放速度  
GameControler.updateCount = 0   	-- 刷新间隔
GameControler.updateScale = 1 		-- 游戏速度放缩
GameControler.updateDt = 0
GameControler.lastScale = 1  		-- 上次播放的游戏速度 做一个保存  这个是全局的
GameControler.updateScaleCount = 0 	-- scale计数
GameControler.middlePos = 0

GameControler._gameResult = 0 		--游戏结果   0 还未分胜负 1 胜利  2 失败
GameControler.__gameStep = Fight.gameStep.wait 	--英雄当前运动阶段  1表示 等待  2表示前进中 3表示开始遇敌 4进入战斗中
GameControler.gameMode = 1 			--游戏模式  1是普通 2是竞技场
GameControler.gameLeftTime = -1 	--游戏剩余时间
GameControler.__currentWave = 0 		--第几批怪物

GameControler._conditions = 1 			-- 战斗进入1 正常，2重连，3中途加入
GameControler._mirrorPos = 1 			-- 控制视图左右互换 1 正常 -1互换
GameControler._battleStar = nil			-- 战斗星级 0特等,往后加

GameControler._loadingComplete = false -- 自己加载完成 
GameControler._countId = 0



GameControler._sceenRoot = nil
--@测试变量
GameControler.runGameIndex = 0 			--当前跑的游戏次数 备份多少次就需要跑多少变

GameControler.useOperateInfo = nil		-- 文件中存储的操作信息

function GameControler:ctor( root )
	self.allModelArr = {}
	self.depthModelArr = {}
	self.campArr_1 = {}
	self.campArr_2 = {}
	self.diedArr_1 = {}
	self.diedArr_2 = {}
	self.callFuncArr = {}
	self.skillPauseInfo = {left=0}
	self._sceenRoot = root
	--逻辑控制器
	self.logical = LogicalControler.new(self)
	echo("_____创建游戏--------")
end

function GameControler:initCountId( count )
    count = count and count or 0
    self._countId = count
end

function GameControler:getGlobalCountId()
    return self._countId
end

-------------------------------------------------------------------------
----------------------- load 加载阶段,材质加载 -------------------------------
-------------------------------------------------------------------------

--判断加载材质
function GameControler:checkLoadTexture( )
	if not Fight.isDummy  then
		local layer= LayerManager.new(self)
		self.layer = layer
		self._sceenRoot:addChild(layer.a)

		-- 缓存材质
		self.resControler = GameResControler.new(self)
		self.resControler:cacheResource(self.levelInfo.cacheObjectHeroArr,c_func(self.initFirst,self))
	else
		--self._sceenRoot:delayCall(c_func(self.initFirst, self), 0.1)	
		self:initFirst()
	end
end

function GameControler:initGameData( objectLevel )
	self.levelInfo = objectLevel
	self.userRid = self.levelInfo.userRid
	--敌对的rid  这个也要记录下 做显示
	self.enemyRid = self.levelInfo.enemyRid

	self._battleStar = 1

	-- 控制视图互换位置
	self._mirrorPos = 1

	-- 进入加载步骤
	-- self:setGameStep(Fight.gameStep.load)
end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-----------------------  等待状态,创建人物--------------------------------
-------------------------------------------------------------------------
-- 创建人物
function GameControler:enterCreateStep()
	BattleDebug("________第一步______________进入创建人物步骤",self.updateCount,self.userRid)
	--设置状态
	self:setGameStep(Fight.gameStep.wait)

	self.__currentWave = self.__currentWave + 1
	self.middlePos = self.levelInfo.__midPos[self.__currentWave]

	--显示名字
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWNAME,true)

	

	

	--开始游戏
	echo("_开始游戏")

	--如果是pvp 那么直接60帧后开战
	if self.gameMode == Fight.gameMode_pvp  then
		self.reFreshControler:distributionOneCamp(self.levelInfo.campData1,Fight.camp_1,1,Fight.enterType_runIn )
		self.reFreshControler:distributionOneCamp(self.levelInfo.waveDatas[1],Fight.camp_2,1,Fight.enterType_runIn)
		if self.screen then
			self.screen:setFocus(self.middlePos, self.screen.focusPos.y)
		end
		
		
		--初始化双方的天赋 以及光环之类的
		self:onDistributionComplete(1)
		self:onDistributionComplete(2)
		if Fight.isDummy  then
			self.logical:startRound()
		else
			self:pushOneCallFunc(60, c_func(self.logical.startRound, self.logical))
		end
		
	else
		self.reFreshControler:distributionOneCamp(self.levelInfo.campData1,Fight.camp_1,1,Fight.enterType_stand )
		self.reFreshControler:distributionOneCamp(self.levelInfo.waveDatas[1],Fight.camp_2,1,self.levelInfo.enterType)
		--初始化双方的天赋 以及光环之类的
		self:onDistributionComplete(1)
		self:onDistributionComplete(2)
		if Fight.isDummy  then
			self.logical:startRound()
		else
			self:pushOneCallFunc(20, "setCampMoveFront")
		end

	end
	
	if self.gameUi then
		self.gameUi:initGameComplete()
	end

	-- 第一回合 是30秒后开始下一回合
	
	--开始回合
	-- self.logical:startRound()
end

--阵营初始化完毕后 开始做天赋技能,包括被动buff之类的
function GameControler:onDistributionComplete(camp )
	local campArr = camp == 1 and self.campArr_1 or self.campArr_2
	for i,v in ipairs(campArr) do
		--初始化光环
		v.data:initAure()
	end
end


--进入下一波
function GameControler:enterNextWave(  )
	
	self.__currentWave = self.__currentWave + 1
	self.middlePos = self.levelInfo.__midPos[self.__currentWave]
	self.reFreshControler:distributionOneCamp(self.levelInfo.waveDatas[self.__currentWave],Fight.camp_2,2,self.levelInfo.enterType)
	--初始化阵营的天赋技
	self:onDistributionComplete(2)
	self.logical:initWaveData()
	--过图 回复能量
	for i,v in ipairs(self.campArr_1) do
		v.data:changeValue(Fight.value_energy , Fight.waveEnergyResume)
	end
	--发送一个 进入下一波的通知
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_NEXTWAVE)
	--如果是 普通pve
	if self.gameMode == Fight.gameMode_pve  then
		--让我方所有人向右运动
		self:setCampMoveFront()
	end

end

--让我方所有人向右运动
function GameControler:setCampMoveFront(  )
	if Fight.isDummy then
		self.logical:startRound()
	else

		--计算距离 速度 算出进入下一波的时间
		for i,v in ipairs(self.campArr_1) do
			local newx,newy = self.reFreshControler:turnPosition(1,v.data.posIndex,v.data:figure(),self.middlePos)
			v._initPos = {x= newx,y = newy}
			local posParams = {x= newx,y = newy,speed = Fight.enterSpeed,call = {"standAction" }}
			v:setWay(1)
			v:justFrame(Fight.actions.action_run )
			v:moveToPoint(posParams)
		end
		local currentFocusPos = self.screen.focusPos.x
		local dx = self.middlePos - currentFocusPos
		local rmax = 0.07 		--缓动系数 越大 表示运动越快
		local rmin = 0.04
		local f = (rmin-rmax) / (1200-960) * (dx - 960) + rmax
		f = f > rmax and rmax  or f
		f = f < rmin and rmin or f
		self.screen:setFollowType(2,{x=self.middlePos,y = GAMEHALFHEIGHT,speed = 15,f = f,minSpeed = 15})

		local delayFrame = math.floor(dx / Fight.enterSpeed /2)
		delayFrame = delayFrame <= 1 and 1 or delayFrame
		local delayFrame2 = delayFrame * 2
		--根据大概速度判定多少帧后让开始入场
		self:pushOneCallFunc(delayFrame, "startPlayInAction",{1})
		self:pushOneCallFunc(delayFrame2, "startPlayInAction",{2})

	end
end

--播放入场动画 或者 跑动入场  1表示筛选跑动入场 2表示做入场动作
function GameControler:startPlayInAction( t )
	local maxFrame = 20
	for i,v in ipairs(self.campArr_2) do
		if t == 1 then
			if not v.data.sourceData.inAction then
				--跑到初始位置
				v:movetoInitPos(2,Fight.enterSpeed)
			end
		elseif t == 2 then
			if v.data.sourceData.inAction then
				v:justFrame(Fight.actions.action_inAction)
				v.myView:visible(true)
				maxFrame = math.max(v.totalFrames+10,maxFrame)
			end
		end
		
	end
	if t == 2 then
		--等所有人入场动作播放完毕后直接开始回合
		self:pushOneCallFunc(maxFrame, c_func(self.logical.startRound, self.logical))
	end
	
end

-- 检测对话. 第一波的对话和中间的对话不同
function GameControler:checkDialogue( plotId,callFunc,funcParams )
	-- 对话
	--local plotId = self.levelInfo:sta_beforeDialogue(self.__currentWave)
	self._isDialog = true
	for i=1,#self.campArr_1 do
		local hero = self.campArr_1[i]
		hero:createEff("common_jing_ya",0,0,1)
	end

	self:pushOneCallFunc(10,"showPlotDialog",{ plotId, callFunc,funcParams }) -- 这10帧是惊讶的时间
end

function GameControler:showPlotDialog( plotId,funcName,funcParams)
	--local plotId = self.levelInfo:sta_beforeDialogue(self.__currentWave)
	--echo("_____________________站前对话")
	self._isDialog = true
	local callFunc 
	if funcName then
		callFunc = self[funcName]
	end

	funcParams = funcParams or {}
	local callBack = function (  )
		self._isDialog =false
		callFunc(self,unpack(funcParams) )
	end

	PlotDialogControl:showPlotDialog(plotId, callBack);
end
----------------------------------------------------
----------------------- 加载完成,开始主循环 ----------------------------
-------------------------------------------------------------------------
function GameControler:initFirst()
	BattleDebug("_______________________initFirst",self.__currentWave)
	-- 如果是回放的话,不管是不是竞技场,这个变量都会变成false.
	if self.replayGame > 0 then
		self._pvpDummy = false
		self.logical:setAutoFight(true)
		echo("__这是重播的自动战斗")
	end

	-- if self.gameMode == Fight.gameMode_pvp and self._pvpDummy then
	-- 	Fight.isDummy = true
	-- end
	
	-- 初始化变量
	self.middlePos = self.levelInfo.__midPos[1]

	self.reFreshControler = RefreshEnemyControler.new(self)
	self.updateDt = Fight.dummyUpdata


	
	-- 排序站位控制器
	self.sortControler = GameSortControler.new(self)

	if not Fight.isDummy then
		self.screen = ScreenControler.new(self,self.layer.a12)	
		self.screen:setFocus(GAMEHALFWIDTH, self.screen.focusPos.y)
		--ui在最上层  a4  a2是
		self.gameUi = WindowControler:showBattleWindow("BattleView")
		self.gameUi:setControler(self)
		self.map = MapControler.new(self.layer.a11,self.layer.a13,self.levelInfo.__mapId,1 )
		-- 初始化镜头
		self.camera = CameraControler.new(self)
		-- self.screen:setFollowType(2,{x=self.middlePos,y = GAMEHALFHEIGHT})

	end
	
	--创建heroes
	self:initCountId(0)
	-- 初始化事件
	self:initEvents()
	--告诉loading页面, 战斗回放也需要这个消息	
	EventControler:dispatchEvent(LoadEvent.LOADEVENT_USERCOMPLETE,{rid = self.userRid} )

	local plotId = self.levelInfo:sta_beforeDialogue(1)
	if plotId and not Fight.isDummy and self.gameMode ~= Fight.gameMode_gve then 
		-- self:checkDialogue(plotId,"enterCreateStep")
		--暂时直接进入游戏
		self:enterCreateStep()
		-- self:pushOneCallFunc(30,"enterCreateStep")
	else
		--是为了讲loading页面关闭后才能看到人物的创建
		-- self:pushOneCallFunc(30,"enterCreateStep")
		self:enterCreateStep()
	end

	--开始刷新,只是刷新的时候判断是否开战
	self:startBattleLoop()
	-- testGolbalKey()
end

--启动战斗刷新
function GameControler:startBattleLoop()
	-- 加载资源完成,发送事件给loading,--去掉这个是因为可能是重播或者回放,就要将关闭loading页面
	echo("============================")
	echo("============================")
	EventControler:dispatchEvent(LoadEvent.LOADEVENT_BATTLELOADCOMP, {result = 1})
	-- 刷新函数
	local listener = function( dt )
		if Fight.low_fps then
			self:updateFrame(dt)
			return
		end
		
		--更新下dt 
		self.updateDt = self.updateDt + (dt - Fight.dummyUpdata)
		if self.updateDt > Fight.dummyUpdata then
			local loop = math.floor(self.updateDt/Fight.dummyUpdata)
			for i=1,loop do
				self:updateFrame(Fight.dummyUpdata) 
			end
			self.updateDt = self.updateDt - Fight.dummyUpdata*loop
		end
		self:updateFrame(Fight.dummyUpdata)
	end

	if DEBUG_SERVICES  then
		local time = os.clock()
		local index = 0
		for i=1,Fight.dum_frame_num do
			self:updateFrame(0)
			if self.__gameStep == Fight.gameStep.result then
				break
			end
		end
		echo("___________time_____",os.clock()-time,self.updateCount)
	else
		
		if not Fight.isDummy then
			self.schedulerId = self._sceenRoot:scheduleUpdateWithPriorityLua(listener, 0)
		end 
	end
end



function GameControler:updateFrame( dt )

	local lastCount
	-- 正常速度
	if self.updateScale == 1 then
		self:runBySpeedUpdate(dt)
	--如果是降速的
	elseif self.updateScale < 1 then
		--判断多少帧刷新一次函数
		lastCount = math.round(self.updateScaleCount)
		self.updateScaleCount = self.updateScaleCount + self.updateScale
		if math.round(self.updateScaleCount) > lastCount then
			--如果是达到一次计数了 那么就做一次刷新函数
			self:runBySpeedUpdate(dt)
		end
	else
		--先计算需要刷新多少次
		local count = math.floor(self.updateScale)
		for i=1,count do
			self:runBySpeedUpdate(dt)
		end

		local leftCount = self.updateScale - count
		self.updateScaleCount = self.updateScaleCount+ count
		--如果不是整数倍数加速
		if leftCount > 0 then
			lastCount = math.round(self.updateScaleCount)
			self.updateScaleCount = self.updateScaleCount + leftCount

			--如果四舍五入后达到一次计数了 那么就做一次刷新函数
			if math.round(self.updateScaleCount) > lastCount then
				self:runBySpeedUpdate(dt)
			end
		end
	end
end

--[[
设置逐帧播放
]]
function GameControler:testFramePlay(val)
	self._isFramePlay = val
end

--总刷新函数
function GameControler:runBySpeedUpdate( dt )
	if self._isFramePlay == 1 then
		return
	end

	if self._gamePause then
		return
	end
	
	-- 要求刚开始就要刷怪
	self.updateCount = self.updateCount + 1

	-- 首先刷新事件,放在最前面是因为可能用来分帧创建英雄
	if not self.scenePause then
		self:updateCallFunc()
		self.logical:updateFrame()
		self:runObjUpdate(dt)
	end
	
	if self.camera then
		self.camera:updateFrame()
	end

	self:someUpdateInfo()
	if not Fight.isDummy then

		self.screen:updateFrame(dt)

		if self.gameUi  then
			self.gameUi:updateFrame()
		end
		--只有等于0的时候 才需要深度排列
		if self.skillPauseInfo.left == 0 then
			self.sortControler:sortDepth()
		end
	
		if self.layer then
			self.layer:updateFrame(dt)
		end
	end

	if self._isFramePlay == 2 then
		self._isFramePlay = 1
	end

end


--获取2组的最远距离
function GameControler:getGroupDistance(  )
	return self.camera.minDistance
end

-------------------------------------------------------------------------
----------------------- 刷新游戏时间 ------------------------------------
-------------------------------------------------------------------------
-- 星级判断
function GameControler:checkBattleStar()
	--拿到星级评价

    local starInfo = self.levelInfo.__starInfo
    -- echo("BattleStar-----------------")
    -- dump(starInfo)
    -- echo("BattleStar-----------------")
    -- if not starInfo then
    -- 	return
    -- end

    -- local second = math.round(self.gameLeftTime/GAMEFRAMERATE)
    -- local idx = 2 - self._battleStar

    -- if starInfo[idx] == second then
    -- 	self._battleStar = self._battleStar + 1
    -- end
    -- 1，顺利通关 2，死亡角色少于三人 3，无角色死亡 {type:1,value:0},{type:2,value:3}
    --类型1 表示顺利通关 无参数,类型2表示死亡人数少于value的时候,.type4,表示回合数少于
    
    local diedCnt =  #self.levelInfo.campData1 - #self.campArr_1
    --游戏存活，我方有存活
    local checkIsLive = function ( val )
    	if #self.campArr_1 >0 then
    	 	return true
    	 end 
    	 return false
    end

    --死亡角色<val个
    local checkLiveCnt = function ( val )

    	--echo("checkLiveCnt:#self.diedArr_1----",#self.diedArr_1,"val:",val,"-------------")
    	
    	if diedCnt<val then
    		return true
    	end
    	return false
    end
    --所有全部存活
    local checkAllHeroLive = function ( val )
    	--local diedCnt =  #self.levelInfo.campData1 - #self.campArr_1
    	--echo("checkAllHeroLive:#self.diedArr_1----",#self.diedArr_1,"val:",val,"-------------")
    	if diedCnt<=0 then
    		return true
    	end
    	return false
    end

    --进行了多少回合
    local checkRoundCnt = function ( val )
    	--echo("checkRoundCnt:#self.diedArr_1----",#self.diedArr_1,"val:",val,"-------------")
    	if self.logical.roundCount< val then
    		return true
    	end
    	return false
    end



    local star = {}
    --从三到一进行判断
    for i=3,1,-1 do
    	-- echo("1: 存活人数",#self.campArr_1,"==============")
    	-- echo("2: 死亡人数",diedCnt,"==============")
    	-- echo("3:回合数",self.logical.roundCount,"==============")
		if starInfo[i].type == 1 then
			if checkIsLive() then
				--echo("全部存活---------",i,"-----")
				--self._battleStar = i
				star[i] = 1
				--break
			else
				star[i] = 0
				--todo
			end
			--echo("i:",star[i],"------")
    	elseif starInfo[i].type == 2 then
    		if checkLiveCnt(starInfo[i].value) then
    			--echo("存活数量--------",i,"-----")
    			--self._battleStar = i
    			--break
    			star[i] = 1
    		else
    			star[i] = 0	
    		end
    		--echo("i:",star[i],"------")
    	elseif starInfo[i].type == 3 then
    		if checkAllHeroLive(starInfo[i].value) then
    			--echo("所有的或者------",i,"-----")
    			--self._battleStar = i
    			star[i] = 1
    		else
    			star[i] = 0
    		end
    		--echo("i:",star[i],"------")
    	elseif starInfo[i].type == 4 then
    		if checkRoundCnt(starInfo[i].value) then
    			--echo("回合数--------",i,"-----")
    			--self._battleStar = i
    			star[i] = 1
    		else
    			star[i] = 0
    		end
    		--echo("i:",star[i],"------")
    	end
    end

    self._battleStar = math.pow(2,0)*star[1] + math.pow(2,1)*star[2] + math.pow(2,2)*star[3]

end


-------------------------------------------------------------------------
----------------------- 刷新对象 ----------------------------------------
-------------------------------------------------------------------------
--执行对象的刷新函数
function GameControler:runObjUpdate( dt )

	--在启动刷新函数之前做的事
	local obj
	for i=#self.allModelArr,1,-1 do
		obj = self.allModelArr[i]
		if obj.updateFirst then
			obj:updateFirst()
		end
	end
	
	-- 有可能在中间过程中删除游戏
	for i=#self.allModelArr,1,-1 do
		obj = self.allModelArr[i]	
		if obj.updateFrame then
			obj:updateFrame(0)
		end
	end

    --刷新函数完毕之后做的事w
 -- 	for i=#self.allModelArr,1,-1 do
	-- 	obj = self.allModelArr[i]
	-- 	if obj.updateLast then
	-- 		obj:updateLast()
	-- 	end
	-- end
end

-- 通过 rid 获取到英雄
function GameControler:getHeroModelByRid( rid )
	for j=#self.allModelArr,1,-1 do
		local mdl = self.allModelArr[j]
		if mdl.modelType == Fight.modelType_heroes then
			if rid == mdl.data.rid then
				return mdl
			end
		end
	end
	return nil
end


------------------------------------------------------------------------
-------------------------------------------------------------------------
----------------------- 事件及处理 --------------------------------------
-------------------------------------------------------------------------
--注册一些侦听
function GameControler:initEvents(  )
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_GAMEPAUSE,self.checkGamePause,self )
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SUREQUIT,self.pressGameQuit,self )
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CLOSE_REWARD,self.closeRewardWindow,self )
end

-- 战斗新手引导
function GameControler:checkTutorial(event)
	echo("________新手引导__释放法宝")

	-- 调用引导接口位置
	if not Fight.isDummy then
		LS:prv():set("StorageCode.tutorial_use_treasure",self.levelInfo._tutorial)
		self:scenePlayOrPause(true)
		--PlotDialogControl:showPlotDialog(plotId, c_func(self.checkEnterGameBattleStep,self));
		self.gameUi:showTutorial(event.params)
	end
end


-- 测试,为了快速胜利
function GameControler:quickVictory( star )
	echo("___________点击快速结束战斗按钮",self.updateCount)
	if self.__gameStep == Fight.gameStep.result then
		return
	end
	echo("star----------",star)
	if star == -1 then
		--竞技场胜利
		self._gameResult = Fight.result_win
		self:processGameResult(Fight.result_win)
		return
	end

	if star == -2 then
		--竞技场失败
		self._gameResult = Fight.result_lose
		self:processGameResult(Fight.result_lose)
		return
	end

	self._battleStar = star or 0
	
	-- self:scenePlayOrPause(true)
	if star  == 0 then
		self._gameResult = Fight.result_lose
		self:processGameResult(Fight.result_lose)
	else
		self._gameResult = Fight.result_win
		self:processGameResult(Fight.result_win)
	end
	
	-- self:playVictoryAction()
end

-- 退出按钮
function GameControler:pressGameQuit( e )
	--是否已经出结果了 
	if conditions then
		--todo
	end
	if self.gameMode == Fight.gameMode_pve   then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_GAMEPAUSE )
		self:quickVictory(0)
		return
	end
	self:closeRewardWindow()
end

-- 关闭奖励界面
function GameControler:closeRewardWindow( ... )
	self._sceenRoot:unscheduleUpdate()
	BattleControler:onExitBattle()	
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
---------------------  数组管理   ---------------------------------------------
-------------------------------------------------------------------------------

--清除一个对象
function GameControler:clearOneObject( target )

	table.removebyvalue(self.allModelArr,target,true)
	table.removebyvalue(self.depthModelArr,target,true)

	table.removebyvalue(self["campArr_"..target.camp],target,true)	
end

--添加一个对象
function GameControler:insertOneObject(target ,outSort)

	if table.indexof(self.allModelArr, target) == false then
		table.insert(self.allModelArr, target)
	end

	if target.modelType == Fight.modelType_heroes then
		local campArr = self["campArr_"..target.camp]		
		if table.indexof(campArr, target) == false then
			table.insert(campArr, target)
		end
		
	end

	if not outSort then
		table.insert(self.depthModelArr, target)
	end
end


-------------------------------------------------------------------------
----------------------- 操作相关 ----------------------------------------
-------------------------------------------------------------------------

-- 界面设置手动自动状态
function GameControler:viewSetAutoFight( )
	self:checkGamePause()
end

-- 设置某个英雄自动
function GameControler:setHeroAutoFight(updateCount,rid, operate)
	
end

-- 某个英雄在线状态
function GameControler:setHeroOnlineState(updateCount,rid, operate)
	
end


-------------------------------------------------------------------------
-----------------------  操作相关 ------------------------------
-------------------------------------------------------------------------



-------------------------------------------------------------------------
----------------------- 一些信息刷新 ------------------------------------
-------------------------------------------------------------------------
--一些更新信息,黑屏时间, 超时等
function GameControler:someUpdateInfo(  )
	if not self.scenePause then		
		if self.skillPauseInfo.left > 0  then
			self.skillPauseInfo.left  = self.skillPauseInfo.left - 1
			--如果达到技能恢复的时间了  那么 让所有人恢复技能暂停
			if self.skillPauseInfo.left == 0 then
				self:hideBlackScene()
			end
		end
	end

	if self.scenePause then
		if self.scenePauseLeft > 0 then
			self.scenePauseLeft = self.scenePauseLeft - 1
			if self.scenePauseLeft == 0 then
				--取消场景暂停
				self:scenePlayOrPause(false)
			end
		end
	end

end


function GameControler:showBlackScene(  )
	-- if true then
	-- 	return
	-- end
	if not Fight.isDummy  then
		self.layer:showBlackImage(self.middlePos,-GAMEHALFHEIGHT )
		self.skillPauseInfo.left = 99999
		--让所有的特效判定一次深度
		for i,v in ipairs(self.allModelArr) do
			if v.modelType == Fight.modelType_effect and v.onSkillBlack  then
				v:onSkillBlack()
			end
		end

	end



end

--隐藏黑屏
function GameControler:hideBlackScene()
	if not Fight.isDummy  then
		self.layer:hideBlackImage()
	end
	self.skillPauseInfo.left = 0
	-- for i,v in ipairs(self.allModelArr) do
	-- 	v:setSkillPause(false)
	-- end
end




-------------------------------------------------------------------------
----------------------- 回调函数信息 ------------------------------------
-------------------------------------------------------------------------
--更新回调
function GameControler:updateCallFunc(  )
	--执行一些回调
	local callInfo
	for i=#self.callFuncArr,1,-1 do
		callInfo = self.callFuncArr[i]
		if callInfo.left > 0 then
			callInfo.left = callInfo.left -1
			if callInfo.left ==0 then
				--必须先移除这个回调信息 因为回调函数里面可能继续有回调
				table.remove(self.callFuncArr,i)
				--如果回调是字符串
				if type(callInfo.func) == "string" then
					if callInfo.params then
						self[callInfo.func](self,unpack(callInfo.params))
					else
						self[callInfo.func](self)
					end
				else
					if callInfo.params then
						callInfo.func(unpack(callInfo.params))
					else
						callInfo.func()
					end
				end
				
			end
		end
	end
end


--一个英雄生命值为0了
function GameControler:oneHeroeHealthDied( who )	
	local index = table.indexof(who.campArr, who)
	--如果没有index 说明是已经删除过了
	if not index then
		return
	end
	table.remove(who.campArr,index)
	--发送英雄死亡事件
	self.logical:doChanceFunc({camp = 0,chance = Fight.chance_onDied,defender = who })
	--如果是将要复活的 存到diedArr里面去
	if who:checkWillBeRelive() then
		local diedArr = who.diedArr
		table.insert(diedArr, who)
	else
		--取消光环作用
		who.data:cancleAure()
	end

	if self.logical.attackSign  == who then
		--取消当前标记的英雄   死人了   集火目标死了
		self.logical:setAttackSign(nil)
		--集火目标的设置
		if self.gameUi.UI_treasure then
			self.gameUi.UI_treasure:onPlayChooseTargetAni()
		end

	end
	who:onRemoveCamp()
	self:checkGameResult()
end

--把一个英雄放进复活数组里面
function GameControler:saveReliveHero( hero )
	local diedArr = hero.camp == 1 and self.diedArr_1 or self.diedArr_2
	hero.willRelive = true
end


--复活一个英雄
function GameControler:reliveOneHero( hero )
	
end


--判断胜负
function GameControler:checkGameResult()

	--如果是最后一波  那么死一个人就要判定一次胜负
	--echo("胜负判定---------",self.__currentWave == self.levelInfo.maxWaves,self.__currentWave,self.levelInfo.maxWaves)



	if self.__currentWave == self.levelInfo.maxWaves then
		local rst = self.levelInfo:checkGameResult(self)
		--暂时这么处理
		if rst == Fight.result_win or rst == Fight.result_lose then
			if BattleControler.battleLabel == GameVars.battleLabels.pvp then
				if rst == Fight.result_win then
					--self:checkBattleStar()
					self:enterGameWin()
					for i,v in ipairs(self.campArr_2) do
						--做退场行为
						v:doExitGameAction()
					end
				end

				if rst == Fight.result_lose then
					self:enterGameLose()
				end


				--BattleControler:showReward({result = rst})
				return 
			end
		end
		if rst == Fight.result_win  then
			echo("____游戏胜利")
			self:checkBattleStar()
			self:enterGameWin()
			for i,v in ipairs(self.campArr_2) do
				--做退场行为
				v:doExitGameAction()
			end

			return
		elseif rst == Fight.result_lose  then
			echo("____游戏失败")
			self:enterGameLose()
			-- for i,v in ipairs(self.campArr_2) do
			-- 	v:standAction()
			-- end
			return
		end
	end

	
end

function GameControler:checkNewRoud(  )
	--如果敌方阵营没人了
	if #self.campArr_2 == 0 and #self.diedArr_2 ==0 then
		self:setGameStep(Fight.gameStep.wait)
		self.logical:beforNextWave()
		for i,v in ipairs(self.campArr_1) do
			--清除负面buff
			v.data:clearBuffByKind(Fight.buffKind_huai )
			--进入下一波的时候 记得让buff次数减1
			v:doToRoundEnd()
		end

		self:pushOneCallFunc(20, "enterNextWave", params)
		return
	end
	if self.logical.currentCamp == 1 then
		self:playSwitchRoundEff()
	end
	
	self.logical:startRound()
end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------

function GameControler:checkReplay(  )
	self.runGameIndex = self.runGameIndex + 1
	self:gameReplay()
end

function GameControler:gameReplay()
	echo("_________________重新战斗")
	self._sceenRoot:unscheduleUpdate()

	-- 竞技场时会进行一次重播.
	if self.gameMode == Fight.gameMode_pvp then
		Fight.isDummy = false
	end
	self:deleteAll()
	self.updateCount = 0
	self.replayGame = 1
	self.__currentWave = 0
	self.gameLeftTime = -1

	-- 改变游戏状态
	self:setGameStep(Fight.gameStep.load)

	self:initFirst()	
end
------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------

function GameControler:processGameResult(result, quit)
	if self.__gameStep == Fight.gameStep.result then
		return
	end

	self:setGameStep(Fight.gameStep.result)
	-- 
	
	self:doGameResultEff()

	if not Fight.debugCloneFrame then
		echo("____gameResult_____".. result,self.updateCount.."  "..UserModel:rid())
	end
	
	
	self._gameResult = result

	if quit then
		self:submitGameResult(true)
	else
		if self._gameResult == Fight.result_win and not Fight.isDummy then
			-- self:checkAfterBattleDialog(c_func(self.playVictoryAction,self))
			self:playVictoryAction({step = -1,index = -1})
		else
			self:playVictoryAction({step = -1,index = -1})
		end
	end
end

--播放胜利或者失败慢镜头
function GameControler:doGameResultEff(  )
	-- self:changeGameSpeed(0.3)

	self:pushOneCallFunc(3, "changeGameSpeed", {0.3})
	--隐掉血条
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = 0,visible = false})
	--如果是失败 
	if self._gameResult == Fight.result_lose then
		return
	end
	-- 场景 节奏
	local blackBg1 = FilterTools.turnColorTranform(0,0,0,1,0,0,0,0  )
	local whiteBg1 = FilterTools.turnColorTranform(0,0,0,1,1,1,1,0  )
	local redhero1 =FilterTools.turnColorTranform(0.01,0.01,0.01,1,0/255,0,0,0  )
	local blackhero1 =FilterTools.turnColorTranform(0.01,0.01,0.01,1,0,0,0,0  )

	local filterParams = {
		{0,whiteBg1, whiteBg1, 2 , self.layer.a11 },
		-- {2,blackBg1,whiteBg1,4, self.layer.a11 },

		{0,blackhero1, blackhero1, 2 , self.layer.a12 },
		-- {2,blackhero1,blackhero1,4, self.layer.a12},
	}
	self.screen:setFollowType(2,{x= self.middlePos ,y = GAMEHALFHEIGHT} )
	--让镜头也适当缩放一下
	self.camera:setScaleTo({10,1.2},{x=self.middlePos,y = Fight.initYpos_3 })

	--40帧后播放绝杀特效
	local creatJuesha = function (  )
		local jueShaAni = ViewSpine.new("eff_juesha")
		jueShaAni:playLabel("eff_juesha",false)
		jueShaAni:addTo(self.gameUi._root,0):pos(GAMEHALFWIDTH ,-GAMEHALFHEIGHT )
	end


	local tuwenFunc = function (frame, fromColor,toColor,ctn )
		FilterTools.flash_easeBetween(ctn,frame,nil,fromColor,toColor,false )	
	end
	self.layer.a11:delayCall(creatJuesha, 40/GAMEFRAMERATE )
	for i,v in ipairs(filterParams) do
		if v[1] == 0 then
			tuwenFunc(v[4],v[2],v[3],v[5] )
		else
			self.layer.a11:delayCall(c_func(tuwenFunc,v[4],v[2],v[3],v[5] ), v[1]/GAMEFRAMERATE )
		end
		
	end

	--把场景变灰
	--FilterTools.flash_easeBetween(self.layer.layer,tweenFrame,perLoopFrame,fromColor,toColor,isResume, callFunc )

end

-- 胜利
function GameControler:enterGameWin(  )
	self:processGameResult(Fight.result_win)
end

-- 失败
function GameControler:enterGameLose(  )
	self:processGameResult(Fight.result_lose)
end

-- 超时
function GameControler:enterGameTimeUp(  )
	self:enterGameLose()
end


function GameControler:checkAfterBattleDialog(callback)
	if self.gameMode == Fight.gameMode_gve then
		callback({step = -1,index = -1})
		return
	end

	local plotId = self.levelInfo:sta_lastDialogue(self.__currentWave)
	if plotId then
		PlotDialogControl:showPlotDialog(plotId, callback)
	else
		callback({step = -1,index = -1})
	end
end

--播放胜利失败动作后 2-3s胜利失败
function GameControler:playVictoryAction()
	if #self.campArr_1 > 0 then
		for i=1,#self.campArr_1 do
			local hero = self.campArr_1[i]
			-- hero:initStand()
			if self._gameResult == 1 then
				-- hero:justFrame(Fight.actions.action_win)
			end
		end
	end
	if Fight.isDummy then
		self:submitGameResult(false)
	else
		if self._gameResult == Fight.result_win then
			self:pushOneCallFunc(30,"submitGameResult",{false})
		else
			self:pushOneCallFunc(40,"submitGameResult",{false})
		end
		
		--self._sceenRoot:delayCall(c_func(self.submitGameResult,self,false),2.5)
	end
end


function GameControler:submitGameResult(quit)
	if DEBUG_SERVICES then
		return
	end
	--echo("提交战斗结果-------------------------")
	--如果是测试模式下 直接显示战斗结果 不需要联网
	if not LoginControler  or (not LoginControler:isLogin()) then
		BattleControler:showReward({reward = {"3,100"},result = self._gameResult})
		return
	end
	




	if Fight.allways_lose then
		self._gameResult = 2
	end
	-- 单人战斗告诉分系统结果
	local resultInfo = {}
	resultInfo.frame 		= self.updateCount 		--记录结束帧数 
	resultInfo.operation  	= json.encode(self.logical.operationMap)

	if not resultInfo.operation then
		resultInfo.operation = {}
	end
	--检查星级
	-- if not quit then
	-- 	self:checkBattleStar()
	-- end
	
	resultInfo.rt 			= self._gameResult 
	resultInfo.battleStar 	= self._battleStar 			--战斗星级
	resultInfo.gameMode 	= self.gameMode 			--游戏模式
	resultInfo.resultInfo 	= BattleControler:getBattleDatas()
	resultInfo.fragment 	= ""

	-- 多人战斗提交结果
	if self.gameMode == Fight.gameMode_gve then
		if not quit then
			BattleServer:submitGameResult(self.updateCount,fragment,self._gameResult,resultInfo)
		else
			BattleServer:quitBattle()
		end
	else
		-- 如果是主动退出战斗,永离
		if quit then	
		    EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_USER_LEAVE,resultInfo)
		    BattleDebug("------------个人战斗,主动退出战斗",self.updateCount)     
		   	return
		end

		-- 根据不同的类型发送不同的结果
		if self.gameMode == Fight.gameMode_pvp  then
			--BattleDebug("_______________竞技场无视图运行结果",self.updateCount)\
			BattleControler:showReward({result = self._gameResult })

		elseif self.replayGame > 0 then
			BattleDebug("_______________战斗回放出结果",self.updateCount)
			EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_REPLAY_GAME,resultInfo  )

		else
			echo("_______________正常战斗结果",self.updateCount,BattleRandomControl.getCurStep())
			EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_BATTLE_RESULT,resultInfo )
		end
	end
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
--设置英雄的 整体行动阶段   
function GameControler:setGameStep( value )
	self.__gameStep = value
end

--各种暂停操做
--暂停按钮的回调
function GameControler:checkGamePause(event  )
	if self.__gameStep == Fight.gameStep.result then
		return
	end

	-- 只有单人战斗才能暂停
	if self.gameMode == Fight.gameMode_pve then	
		if self._gamePause then
			self:playOrPause(true)
		else
			self:playOrPause(false)
		end
	end	
end

--根据模式判断是否可操作
function GameControler:checkCanHandle(  )
	--目前暂定只有pve可以操作
	if not self.logical.isInRound then
		return false
	end
	if self.gameMode ==Fight.gameMode_pve then
		return true
	end
	return false
end


--播放或者暂停游戏
function GameControler:playOrPause(value,delay )

	self._gamePause = not value
	--让所有的事件停止

	for i,v in ipairs(self.allModelArr) do
		v:gamePlayOrPause(value)
	end
end

--普通战斗场景播放或者暂停
function GameControler:scenePlayOrPause( value,lastFrame )
	--虚拟跑的不需要场景暂停
	if Fight.isDummy  then
		return
	end
	-- echo("设置场景暂停:",value,lastFrame)
	self.scenePause = value
	for i,v in ipairs(self.allModelArr) do
		v:scenePlayOrPause(value)
	end
	if lastFrame then
		self.scenePauseLeft = lastFrame
	end
end


function GameControler:pushOneCallFunc( delayFrame,func,params )
	if not func then
		error("___空函数")
	end
	if delayFrame ==0 then
		if params then
			self[func](self,unpack(params))
		else
			self[func](self)
		end
		return
	end

	local info = {
		left = delayFrame,
		func = func,
		params = params,
	}
	--插入到最前面
	table.insert(self.callFuncArr,1, info)
end

function GameControler:deleteAll()

	for i=#self.allModelArr,1 ,-1 do
		if self.allModelArr[i].deleteMe then
			self.allModelArr[i]:deleteMe()
		end
	end

	if self.gameUi then
		self.gameUi:startHide()
		self.gameUi = nil
	end

	if self.map then
		self.map:deleteMe()
		self.map = nil
	end


	--清除掉所有的事件
	FightEvent:clearAllEvent()

	self.screen = nil
	self.camera = nil
	self.depthModelArr = {}
	self.allModelArr ={}
	self.campArr_1 = {}
	self.campArr_2 = {}
	self.character = nil
end

--删除自己----------
function GameControler:deleteMe( )
	if self._isDied then
		echo("__游戏已经删除了 又重复删除了")
		return 
	end
	self._isDied = true
	self:deleteAll()
	if self._sceenRoot then
		self._sceenRoot:unscheduleUpdate()
		self._sceenRoot = nil
	end
	if self.resControler then
		self.resControler:clearResource()
	end

	if self.gameBackup then
		self.gameBackup:deleteMe()
		self.gameBackup = nil
	end

	if self.layer then
		self.layer:deleteMe()
		self.layer = nil
	end
	echo("________销毁游戏----------")
	self.callFuncArr = nil
	FightEvent:clearOneObjEvent(self)
	EventControler:clearOneObjEvent(self)
end


--播放切回合特效
function GameControler:playSwitchRoundEff(  )
	
	local eff = ModelEffectBasic.new(self)
	eff:setIsCycle(false)
	eff:setFollow(false)
	-- local ani = ViewArmature.new("UI_zhandou_huihetishi")
	local ani = ViewSpine.new("eff_huihetishi")
	ani:playLabel("eff_huihetishi")
	eff:initView(self.layer.a3 ,ani,GAMEHALFWIDTH ,GAMEHALFHEIGHT + GameVars.UIOffsetY ,0)
	ani:setScaleX(self._mirrorPos*Fight.cameraWay )
	self:insertOneObject(eff)
end


----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------

--加速按钮
function GameControler:changeGameSpeed(scale )
	if self.updateScale ==scale then
		return
	end
	
	--记录上次调整过的时间 因为每次初始化游戏的时候 可能需要记录这个速度
	self.lastScale = self.updateScale
	-- 改变速度
	if scale > 1 then
		-- scale = 4
	end
	self.updateScale = scale
	-- 初始化计数
	self.updateScaleCount = 0
	--更新所有对象的viewPlayspeed
	for i,v in ipairs(self.allModelArr) do
		if v.updateViewPlaySpeed then
			v:updateViewPlaySpeed()
		end
	end
end

return GameControler

