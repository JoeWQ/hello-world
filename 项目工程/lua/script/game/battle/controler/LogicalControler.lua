--
-- Author: xd
-- Date: 2016-09-13 16:30:11
--逻辑控制器
LogicalControler  = class("LogicalControler")

--回合计数
LogicalControler.roundCount =0
--操作信息表
--[[
	waves = {
		roundCount = {
			order = {
				{index = posIndex,type = 1,params=1,camp =1,comb = 2}
			}
		}
	}  
	   
]]
LogicalControler.operationMap = nil 

--当前是哪一方
LogicalControler.currentCamp = 1
--是否正在攻击中
LogicalControler.isAttacking =false
--是否在技能运动中
LogicalControler.isSkillMoving = false

--当前回合已经攻击的人的数量	
LogicalControler.attackNums = 0

--排队队列数组
LogicalControler.queneArr_1 = nil 
LogicalControler.queneArr_2 = nil 

--当前的连击数
LogicalControler.currentComb = 0
--剩余连击时间 0 表示连击中断 > 0 表示连击中 可以连击计时 连击间隔是 2秒也就是60帧
LogicalControler.leftCombFrame = -1

--剩余自动战斗时间
LogicalControler.leftAutoFrame = -1
 
LogicalControler.logsInfo = ""
  
--中断连击
LogicalControler.breakComb = false
--是否在回合中
LogicalControler.isInRound = false 


--被动技能数组
LogicalControler.passiveGroup = nil


function LogicalControler:ctor( controler )
	self.controler = controler
	self.operationMap = {{},{},{} }
	--当前阵营 默认是左方  以后有新规则在修改
	self.currentCamp = 1
	self.roundCount  = 1
	self.queneArr_1 ={}
	self.queneArr_2 ={}
	self.logsInfo =""
	self.breakComb =false
	self.isInRound = false
	self.passiveGroup = {}
	if Fight.isDummy then
		self.autoFight = true
	end
end

--初始化一波数据
function LogicalControler:initWaveData(  )
	self.roundCount = 1
	self.currentCamp = 1
	self.isAttacking =false
	self.breakComb =false
	self.queneArr_1 ={}
	self.queneArr_2 ={}
end


--每帧刷新函数 主要是一些及时操作
function LogicalControler:updateFrame()
	--更新剩余自动战斗时间
	self:updateAutoFrame()
	-- self:updateCombFrame()
end

--更新剩余comb时间
function LogicalControler:updateCombFrame(  )
	if self.leftCombFrame > 0 then
		self.leftCombFrame = self.leftCombFrame -1
		--如果剩余帧数为0了 那么 取消连击
		if self.leftCombFrame == 0 then
			-- self.breakComb = true
			-- self:changeComb(0)
		end
	end
end




--更新剩余自动战斗时间
function LogicalControler:updateAutoFrame(  )
	-- 如果是敌方阵营的
	if self.currentCamp == 2 then
		return
	end
	if self.leftAutoFrame > 0 then
		self.leftAutoFrame = self.leftAutoFrame -1
		if self.leftAutoFrame == 0 then
			--那么做自动战斗 必须是我方阵营的时候 做自动战斗
			if not self.autoFight and self.currentCamp == 1 then
				echo("_____自动战斗-----------")
				self:setAutoFight(true)
				self:doAutoFightAi(self.currentCamp)
			end
		end
	end
end

--改变连击数
function LogicalControler:changeComb( value )
	self.currentComb = value
	--发送一个连击改变的侦听 0表示连击中段
	-- FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_COMBCHANGE,value)
end

--获取连击伤害系数
function LogicalControler:getCombDamageRatio( comb )
	if not comb then
		comb = self.currentComb
	end
	local ratioArr = Fight.combDmgRatio
	if comb == 0 then
		comb = 1
	elseif comb > #ratioArr then
		echoError("错误的comb:",comb)
		comb = #ratioArr
	end
	return  ratioArr[comb]
end



--开始一回合
function LogicalControler:startRound(  )
	echo("_________strtRound",self.currentCamp)
	--开始的时候不做连击计时

	--开始时 随机确定小技能
	--首回合最少给2个skill
	SkillChooseExpand:sureSkillIndex(self, self.currentCamp  )

	--先清除被动技能序列
	self:clearPassiveSkill()

	self.leftCombFrame = -1
	--连击数为0
	self.currentComb = 0
	self.breakComb = false

	--做回合前的事情
	self.attackNums = 0
	--回合前血条全量
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = 0,visible = true})
	-- FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = self.currentCamp ==1 and 2 or 1,visible = true})
	self:toRoundStr()
	self:doRoundFirst(self.currentCamp)
	if not Fight.isDummy then
		--第一回合 直接直接开始
		if self.roundCount == 1 then
			self:delayStartRound()
		else
			self.controler:pushOneCallFunc(20, c_func(self.oneHeroReady,self))
		end
		
	else
		self:delayStartRound()
	end
	
end

--one heroRead
function LogicalControler:oneHeroReady(  )
	--如果已经是在回合中了 那么不判断了
	if self.isInRound then
		return
	end
	local campArr = self.currentCamp == 1 and self.controler.campArr_1 or self.controler.campArr_2

	if Fight.isDummy then
		return 
	end
	if self:checkCampHasRelive(1) then
		return 
	end

	--遍历所有人 判定是否ready
	for i,v in ipairs(campArr) do
		if not v.isRoundReady then
			return 
		end
	end


	self:delayStartRound()

end


--回合开始前 需要延迟一会才开打 比如可能会延迟受伤  buff 等等
function LogicalControler:delayStartRound(  )
	--如果已经出结果了
	if self.controler.__gameStep == Fight.gameStep.result then
		return
	end
	self.controler:setGameStep(Fight.gameStep.battle)
	self.isInRound = true

	--回合前的自动战斗时间为20秒
	self.leftAutoFrame = Fight.autoFightFrame1

	-- echo("开始新的回合---------",self.currentCamp)
	--发送回合开始事件  如果超时 就设置为自动 
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ROUNDSTART,self.currentCamp)

	--首先分配指令,记录谁去打谁
	--如果回合前没有人能够攻击
	local hero = self:findNextHero(self.currentCamp)
	if not hero then
		self:doRoundEnd(self.currentCamp)
		--结束完毕 
		self.isInRound =false
		if not Fight.isDummy then
			self.controler:pushOneCallFunc(30, c_func(self.enterNextRound,self) )
		else
			self:enterNextRound()
		end
		
		return
	end


	--如果是重播的
	local handle = self:getOneHandle(self.currentCamp,1)
	if handle then
		echo("__已经有操作了")
		self:checkAttack(handle)
	else
		--如果是自动战斗的
		if self:checkIsAutoAttack(self.currentCamp) then
			self:doAutoFightAi(self.currentCamp)
		end
	end

	
end

--本回合自动战斗
function LogicalControler:doAutoFightAi( camp  )
	if self.currentCamp ~= camp then
		return
	end
	
	if self.controler.__gameStep ~= Fight.gameStep.battle then
		return
	end

	local campArr = self.currentCamp == 1  and self.controler.campArr_1 or self.controler.campArr_2
	local nums = 0
	for i,v in ipairs(campArr) do
		--必须是能攻击的 而且本回合没有攻击的
		if v.data:checkCanAttack() then
			if not self:checkRoundHasAttack(self.currentCamp,v.data.posIndex) then
				local opInfo = v:chooseOneAutoHandle()
				nums = nums +1
				if nums > 1 then
					self:insterOneHandle(opInfo.camp,opInfo.index,opInfo.type,opInfo.params,(nums-1)*5)
				else
					self:insterOneHandle(opInfo.camp,opInfo.index,opInfo.type,opInfo.params)
				end
			end
		end
	end

	--插入操作完毕后 如果是dummy跑的 那么需要做一次 checkAttack 因为在checkAttack里面会自我递归
	if Fight.isDummy then
		self:checkAttack(self:getOneHandle(self.currentCamp,1))
	end


end


--回合前做些事
function LogicalControler:doRoundFirst( camp )
	local campArr = self.controler["campArr_"..camp]
	local length = #campArr

	if camp == 1 then
		self:doChanceFunc({camp = 1,chance =Fight.chance_roundStart})
		self:doChanceFunc({camp = 2,chance = Fight.chance_toStart})
	else
		self:doChanceFunc({camp = 2,chance =Fight.chance_roundStart})
		self:doChanceFunc({camp = 1,chance = Fight.chance_toStart})
	end
	
	--判断是否主角需要崩溃 或者buff死亡
	for i=length,1,-1 do
		local hero = campArr[i]
		hero:doRoundFirst()
	end

	local diedArr = self.controler["diedArr_"..camp]

	for i=#diedArr,1,-1 do
		diedArr[i]:doRoundFirst()
	end

	local toArr = camp == 1 and self.controler.campArr_2 or self.controler.campArr_1
	for k,v in pairs(toArr) do
		v:doToRoundFirst()
	end
	
end



--回合结束后做什么事
function LogicalControler:doRoundEnd( camp )

	--回合结束后应该让对方阵营 

	local campArr = self.controler["campArr_"..camp]
	local toCamp = camp ==1 and 2 or 1
	local toArr = self.controler["campArr_"..toCamp]
	--判断是否主角攻击类法宝需要崩溃
	local length =#campArr
	for i=length,1,-1 do
		local hero = campArr[i]
		hero:doRoundEnd()
	end
	length = #toArr
	for i=length,1,-1 do
		local hero = toArr[i]
		hero:doToRoundEnd()
	end

	--发送回合后
	if camp == 1 then
		self:doChanceFunc({camp = 1,chance =Fight.chance_roundEnd})
		self:doChanceFunc({camp = 2,chance = Fight.chance_toEnd})
	else
		self:doChanceFunc({camp = 2,chance =Fight.chance_roundEnd})
		self:doChanceFunc({camp = 1,chance = Fight.chance_toEnd})
	end
	self:hideAllAttackFlag()
end


--判断进入下一回合
function LogicalControler:enterNextRound(  )
	self:setAttackSign(nil)
	self.leftAutoFrame = -1
	-- echo(self.currentCamp,"___进入下一回合")
	self.roundCount = self.roundCount +1
	if self.currentCamp == 1 then
		self.currentCamp = 2
	else
		self.currentCamp = 1
	end

	--如果是最后一回合了
	if self.roundCount == Fight.maxRound then
		self.controler:enterGameLose()
		echo("____-游戏超时")
		return
	end

	self.controler:checkNewRoud()

	-- self:startRound()
end


--指派谁开始攻击
function LogicalControler:checkAttack(operationInfo)

	--如果不是战斗状态是不允许攻击的
	if self.controler.__gameStep ~= Fight.gameStep.battle then
		return
	end

	local camp = operationInfo.camp
	local posIndex = operationInfo.index
	local handleType = operationInfo.type
	local params = operationInfo.params
	local comb = operationInfo.comb


	--判断敌方是否人数为0了
	local toArr = camp == 1 and self.controler.campArr_2 or self.controler.campArr_1
	
	if #toArr == 0 then
		--如果对方没人了 但是有复活的对象  那么return 同时需要返回initPos
		if self:checkCampHasRelive(camp ==1 and 2 or 1) then
			echo("_____对方有复活的人的时候 就让我方Quene还原")
			self:clearQueneAndInitPos(camp)
		end
		return 
	end

	local heroModel = self:findHeroModel(camp,posIndex)
	if heroModel then

		if not self:checkIsAutoAttack(camp) then
			self.leftAutoFrame = -1
		end
		--攻击前判断是否有被动技能
		self:giveHeroPassiveSkill(heroModel)
		-- self:removeFromQuene(heroModel)
		self.isAttacking = true
		self.attackNums = self.attackNums +1
		self.isSkillMoving = true
		--会发送一个事件出去 

		-- if not Fight.isDummy then
		-- 	self.controler.gameUi:setAttackSign(nil)
		-- end
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_COMBCHANGE,operationInfo.comb)
		if handleType == Fight.operationType_giveSkill then
			heroModel:checkSkill(nil,operationInfo.comb)
		elseif handleType == Fight.operationType_giveTreasure then
			heroModel:checkTreasure(params,operationInfo.comb)
		end

		self:hideAllHeroOffSideAttack()
		--开始攻击隐藏剑
		heroModel:hideCanAttack()
		--heroModel:hideOffSideAttack()
		heroModel:hideAttackNum()
		--隐藏主角法宝
		heroModel:hideMainHeroTreas()

		heroModel:hideJiHuoHand()

		


	end
end


--[[
攻击目标死了。需要重新选择敌人的时候
]]
function LogicalControler:checkNewTarget(  )
	for k,v in pairs(self.controler.campArr_1) do
		if not self:checkRoundHasAttack(1,v.data.posIndex) then
			v:checkCanOffSideAttack()
			v:checkMainHeroEnergyFull()
		end
	end
end

--[[
回合结束 隐藏所有的标示
]]
function LogicalControler:hideAllAttackFlag(  )
	if Fight.isDummy  then
		return
	end
	for k,v in pairs(self.controler.campArr_1) do
		v:hideCanAttack()
		v:hideAttackNum()
		v:hideOffSideAttack()
		v:hideMainHeroTreas()
	end
end



--[[
切换到自动战斗
]]
function LogicalControler:hideAllAttackFlagWithOutNum(  )
	if Fight.isDummy  then
		return
	end
	for k,v in pairs(self.controler.campArr_1) do
		v:hideCanAttack()
		--v:hideAttackNum()
		v:hideOffSideAttack()
	end
end


--[[
隐藏所有的操作表示
]]
function LogicalControler:hideAllHeroOffSideAttack(  )
	for k,v in pairs(self.controler.campArr_1) do
		v:checkAttackView()
		v:hideOffSideAttack()
	end
end




--[[
寻找 能达到hero的我方角色
如果找不到，则寻找不我们角色的第一排对应的人
]]
function LogicalControler:findCanBeAttackedHero( hero )
	--1：判断有没有集火目标
	local firstHero,isHoupai,heroArr
	local toArr = hero.toArr
	if #toArr == 0 then
		return 
	end
	local beSignArr = {}
	local canBeAttackArr = {}
	--找到能够打到我的人 不管是集火还是非集火
	for i,v in ipairs(toArr) do
		--比如是没有攻击过的人 而且能攻击
		if not self:checkRoundHasAttack(v.camp, v.data.posIndex) and v.data:checkCanAttack() then
			local canAttack,isSign = AttackChooseType:checkSkillCanAtkEnemy( v,v:getNextSkill(),hero )
			--如果集火的目标是我 
			if isSign then
				if  not table.indexof(beSignArr, v) then
					table.insert(beSignArr, v)
				end
			end
			if canAttack then
				if  not table.indexof(canBeAttackArr, v) then
					table.insert(canBeAttackArr, v)
				end
			end
		end
	end

	--找到对位的
	local duiweiHero = AttackChooseType:findFirstYposHero( hero,hero.toArr )

	if not self.attackSign then
		--如果能被标记的数组大于0
		if #beSignArr > 0 then
			beSignArr[1]:showJiHuoHand()
		else
			--显示不能被集火
			duiweiHero:showCannotJiHuo()
		end
	else
		--如果已经有集火目标了
		--如果点击的集火目标是hero
		if self.attackSign == hero then
			--如果被打的人数量不为0
			if #canBeAttackArr > 0 then
				-- canBeAttackArr[1]:showJiHuoHand()
				canBeAttackArr[1]:pressClickView()
				return
			end
		else
			if #canBeAttackArr > 0 then
				canBeAttackArr[1]:showJiHuoHand()
			else
				--这里应该显示不能被打
				duiweiHero:showCannotGongji()
			end
		end
	end

	self:setHeroViewAlpha(canBeAttackArr, hero,true)

end





--一个攻击完成
function LogicalControler:onAttackComplete( camp,posIndex )
	self.isAttacking =false
	--如果不是自动战斗的 那么开始倒计时
	if not self:checkIsAutoAttack(camp) then
		self.leftAutoFrame = Fight.autoFightFrame2
	end

	--每一个人攻击完毕都判定胜负
	-- self.controler:checkGameResult()
	--如果已经出结果了
	if self.controler.__gameStep == Fight.gameStep.result then
		return 
	end
	if not Fight.isDummy  then
		self.controler.screen:setFollowType(2,{x=self.controler.middlePos,y = GAMEHALFHEIGHT})
		self.controler.camera:setScaleTo({10,1},{x=self.controler.middlePos,y = Fight.initYpos_3 })
	end
	
	--判断是否回合结束
	local hero = self:findNextHero(camp)
	if hero  then
		--判断是否有累积起来的操作
		local operation = self:getOneHandle(camp,self.attackNums +1)
		--如果是有操作的
		if operation then
			self:checkAttack(operation)
		else
			--判断游戏模式  如果是自动的 那么直接攻击
			if not self:checkIsAutoAttack(camp) then
				self:resumeViewAlpha()
				--让屏幕焦点移到中心去
				-- self.controler.screen:setFollowType(2,{x=self.controler.screen.focusPos.x,y = GAMEHALFHEIGHT})
				
				-- self.controler:pushOneCallFunc(60, "enterNextRound")
				echo(self.currentCamp,"____攻击完毕")
				FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = 0,visible = true})
				-- FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = self.currentCamp ==1 and 2 or 1,visible = true})
			end
		end
	else
		self.currentComb = 0
		self.isInRound =false
		--取消集火目标
		self:setAttackSign(nil)
		--这里需要延迟一会才进入下一回合 因为 这个时候 可能有人还没有恢复过来
		if Fight.isDummy then
			self:enterNextRound()
		else
			--如果对方有将要复活的人 那么就复原位置
			if self:checkCampHasRelive(camp == 1 and 2 or 1) then
				self:clearQueneAndInitPos(camp)
			end

			self:resumeViewAlpha(true)
			--让屏幕焦点移到中心去
			self.controler.screen:setFollowType(2,{x=self.controler.middlePos,y = GAMEHALFHEIGHT})
			self.controler.camera:setScaleTo({10,1},{x=self.controler.middlePos,y = Fight.initYpos_3 })
			local totalDamage = StatisticsControler:getRoundTotalDamage()
			
			--只有我方的时候才统计总伤害
			if totalDamage > 0 and self.currentCamp == 1 then
				ModelEffectNum:createTotalDamage(totalDamage)
			end
			
			FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ROUNDEND)
			self:doRoundEnd(self.currentCamp)
			self.controler:pushOneCallFunc(30, c_func(self.enterNextRound,self)  )
		end
	end
end


--找到下一个可攻击英雄 返回nil 表示是最后一个人了
function LogicalControler:findNextHero(camp )
	local campArr = self.controler["campArr_"..camp]
	local toArr = camp == 1 and self.controler.campArr_2 or self.controler.campArr_1
	--如果敌方没人了 那么返回空
	if #toArr ==0 then
		return nil
	end
	local handleInfo = self:getOneHandle(camp,self.attackNums+1)
	local posIndex 
	if handleInfo then
		posIndex = handleInfo.index
		return self:findHeroModel(camp,posIndex)
	else
		local hero = self:findNextCanAttackHero(camp)
		if hero then
			return hero
		end
	end
	return nil
end

--找没有进入攻击状态而且可以攻击的英雄
function LogicalControler:findNextCanAttackHero( camp )
	local campArr = self.controler["campArr_"..camp]
	--遍历数组 如果
	for i,v in ipairs(campArr) do
		--必须是这个人能够攻击
		if v.data:checkCanAttack() then
			--如果这回合没有攻击
			if not self:checkRoundHasAttack(camp,v.data.posIndex) then
				return v
			end
		end
	end
	return nil
end


--判断一个英雄是否已经在操作里了
function LogicalControler:checkRoundHasAttack( camp,posIndex )
	local countStr = tostring(self.roundCount)
	local info = self.operationMap[self.controler.__currentWave][countStr]
	if not info then
		return false
	end
	
	for k,v in pairs(info.order) do
		if v.index == posIndex and v.camp == camp then
			return true
		end
	end
	return false
end


--根据posIndex 找到指定的heroModel
function LogicalControler:findHeroModel( camp,posIndex ,containerDied )
	local campArr = self.controler["campArr_"..camp]
	for i,v in ipairs(campArr) do
		if v.data.posIndex == posIndex then
			return v
		end
	end
	if containerDied then
		local diedArr = self.controler["diedArr_"..camp]
		for i,v in ipairs(diedArr) do
			if v.data.posIndex == posIndex then
				return v
			end
		end
	end

	return nil
end


--判断是否是自动
function LogicalControler:checkIsAutoAttack( camp )
	if Fight.isDummy then
		return true
	end
	if camp == 2 then
		return true
	end
	if self.controler:checkCanHandle() then
		--如果点击自动按钮 获取超时了
		if self.autoFight then
			return true
		end
	else
		return true
	end

	return false
end



--插入一个人的操作 handleType 1是放技能 2 是放法宝,params对应法宝序列 1或者2 
--delayFrame 延迟多少帧 执行 检测攻击行为 
function LogicalControler:insterOneHandle(camp, posIndex,handleType,params, delayFrame )
	handleType = handleType or Fight.operationType_giveSkill
	local countStr = tostring(self.roundCount)
	if not self.operationMap[self.controler.__currentWave][countStr] then
		self.operationMap[self.controler.__currentWave][countStr] = {order = {},camp = camp}
	end
	local comb = self.currentComb
	--如果是中断连击了 那么只是不加连击值
	if self.breakComb then
		self.breakComb = false
	else
		--让连击数加1
		self:changeComb(self.currentComb +1)
	end
	comb = self.currentComb
	if comb > 6 then
		echoError("错误的comb:",comb)
	end

	local operationInfo = {index=posIndex,type = handleType,camp = camp,comb = comb, params =params}

	table.insert(self.operationMap[self.controler.__currentWave][countStr].order,operationInfo )

	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ONEHEROATTACK,operationInfo)
	local campArr = camp == 1 and self.controler.campArr_1 or self.controler.campArr_2
	--判断是否是这个回合的最后一次攻击
	local hero = self:findNextCanAttackHero(camp)

	if not hero then
		self.leftAutoFrame = -1
	else
		if not self:checkIsAutoAttack(camp) then
			-- self.leftCombFrame = Fight.combHandleFrame
			-- self.leftAutoFrame = Fight.autoFightFrame2
		end
	end
	--让这个操作的人 隐藏脚下光环
	hero = self:findHeroModel(camp, posIndex)
	hero:showAttackNum(#self.operationMap[self.controler.__currentWave][countStr].order)
	hero:setFootLight(0)
	hero.nextOperationInfo = operationInfo

	

	--如果是模拟跑的 需要放到循环外去做
	if Fight.isDummy then
		-- self:checkAttack(operationInfo)
	else
		local tempFunc = function (  )
			--如果当前是正在攻击中
			if self.isAttacking then
				--走到黑块中间去
				local hero = self:findHeroModel(camp, posIndex)
				--跳转到准备阶段
				hero:justFrame(Fight.actions.action_readyStart)

				--如果是在技能运动中 
				-- echo(#self["queneArr_"..camp],"queneArr_aaaaaaaaaaaaa")
				if self.isSkillMoving then
					self:insertToMoveQuene(hero)
					return
				end
				self:moveToQuenePos(hero)
				return
			end
			--如果是不在回合中的 
			if not self.isInRound then
				return
			end
			--如果是没有攻击目标的
			if not self.attackSign then
				hero:justFrame(Fight.actions.action_readyStart)
			end

			self:checkAttack(operationInfo)
		end
		if delayFrame  then
			self.controler:pushOneCallFunc(delayFrame, tempFunc)
		else
			tempFunc()
		end
	end
end

--插入一个英雄
function LogicalControler:insertToMoveQuene( hero )
	local arr = hero.camp ==1 and self.queneArr_1 or self.queneArr_2
	table.insert(arr, hero)
	hero:showOrHideBuffAni(false)
end

--让英雄运动到 队列里面去
function LogicalControler:moveToQuenePos(hero )
	self:insertToMoveQuene(hero)
	local arr = hero.camp ==1 and self.queneArr_1 or self.queneArr_2
	self:adjustQuenePos(arr,hero.toCamp)

end

--判断英雄是否在队列里面
function LogicalControler:checkIsInQuene( hero )
	local arr = hero.camp ==1 and self.queneArr_1 or self.queneArr_2
	if table.indexof(arr, hero) then
		return true
	end
	return false
end


--然后所有的队列清除
function LogicalControler:clearQueneAndInitPos( camp )
	local arr = camp ==1 and self.queneArr_1 or self.queneArr_2
	for i,v in ipairs(arr) do
		v:movetoInitPos(2)
		--显示buff特效
		v:showOrHideBuffAni(true)
	end
	--把他们清除
	table.clear(arr)
end


--调整英雄队列
function LogicalControler:adjustQuenePos( arr,toCamp )
	local targetMiddlePos = self:getAttackMiddlePos(toCamp)
	local camp = toCamp == 1 and 2 or 1

	--暂时不显示队列
	if true then
		return
	end
	--如果不需要调整队列的
	if not self.controler.levelInfo:checkEnterQueneGroup(camp,self.controler.__currentWave) then
		return 
	end

	for i,v in ipairs(arr) do
		--根据数组长度 获取目标点 
		local tagertXpos = targetMiddlePos - v.way*(Fight.position_queneDistance + (i -1)*30 )
		local targetYpos = -20* ( (i-1) % 2 ) + Fight.initYpos_3  - 60
		if i == 1 then
			targetYpos = Fight.initYpos_3 
			tagertXpos = targetMiddlePos - v.way * Fight.position_queneDistance
			local posOff = v:getSkillQuePos()
			if posOff then
				tagertXpos = posOff[1] + tagertXpos
				targetYpos = posOff[2] + targetYpos
			end
		else
			tagertXpos = targetMiddlePos - v.way*(Fight.position_queneDistance  + 20 + (i -1)*15 )
		end
		

		local speed = v:countSpeed(tagertXpos, targetYpos,15,10)
		local posParams = {
			x = tagertXpos,
			y = targetYpos,
			speed = speed,
			call = {"standAction"},
		}
		v:moveToPoint(posParams)
		--如果太近 不需要改变动作
		if v.moveType ~= 0 then
			v:justFrame(Fight.actions.action_run)
		end
	end
end

--移除某个英雄队列
function LogicalControler:removeFromQuene( hero )
	local arr = hero.camp ==1 and self.queneArr_1 or self.queneArr_2
	table.removebyvalue(arr, hero)
	self:adjustQuenePos(arr,hero.toCamp)
end


--判断是否取消连击
function LogicalControler:checkCancleComb(  )
	local operation = self:getOneHandle(camp,self.attackNums +1)
	
	--如果最后一个人攻击完毕了  那么 就取消连击
	if not operation and not self.isAttacking then
		self.breakComb = true
		-- self.attackSign = hero
		--如果断开了 那么就显示攻击目标
		if self.attackSign and (not Fight.isDummy) then
			--只有敌方才显示攻击目标
			if self.attackSign.camp == 2 then
				self.controler.gameUi:setAttackSign(self.attackSign)
			end
			
		end
	end
end


--获取某个位置操作
function LogicalControler:getOneHandle( camp,index )
	local countStr = tostring(self.roundCount)
	if not self.operationMap[self.controler.__currentWave][countStr] then
		return nil
	end
	return self.operationMap[self.controler.__currentWave][countStr].order[index]
end

--获取某个人是在第几个操作位 0表示不在操作序列
function LogicalControler:getHeroHandleIndex( hero )
	if hero.camp ~= self.currentCamp then
		return 0
	end
	local countStr = tostring(self.roundCount)
	--如果没有当前回合的操作
	if not self.operationMap[self.controler.__currentWave][countStr] then
		return 0
	end

	local orderArr = self.operationMap[self.controler.__currentWave][countStr].order
	for i,v in ipairs(orderArr) do
		--如果是同一个位置 返回这个序号
		if v.index == hero.data.posIndex then
			return i
		end
	end
	return 0


end



--设置或者取消自动 true  是自动  false  是不自动
function LogicalControler:setAutoFight( value )
	self.autoFight = value
	--如果是我方阵营 那么剩余自动战斗时间为 -1
	if self.currentCamp == 1 then
		if value  then
			self.leftAutoFrame = -1
		end
	end
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CHANGEAUTOFIGHT)
	--开始自动战斗所有的都隐藏
	if value then
		self:hideAllAttackFlagWithOutNum()
	end
end

--半透当前回合 非相关操作人员
function LogicalControler:checkRelation(hero, skill,outBlack ,onlySign )
	if Fight.isDummy then
		return
	end

	local heroArr = {}
	local blackFrame  = skill:sta_blackFrame() or 0
	
	if not onlySign then
		if not outBlack then
			FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = self.currentCamp == 1 and 2 or 1,visible = false})
		else
			-- AttackChooseType:getSkillAttackPos(self.controler,hero,skill)
		end
	end
	
	if outBlack then
		blackFrame = 0
	end
	if onlySign then
		blackFrame = 20
	end
	if Fight.isDummy then
		blackFrame = 0
	end

	local attackInfos = skill.attackInfos
	local heroArr = AttackChooseType:getSkillCanAtkEnemy( hero,skill )
	local firstHero = AttackChooseType:getSkillAttackSign(hero, skill)
	if outBlack then
		if not self.attackSign then
			if firstHero  then
				self.controler.gameUi:setAttackSign(firstHero)
			end
		end
	else
		if not self.attackSign then
			if firstHero  then
				self:setAttackSign(firstHero)
			end
		end
	end
	for i,v in ipairs(heroArr) do
		if blackFrame > 0 and not onlySign then
			v:onSkillBlack()
		end
	end
	

	--如果是紧紧显示集火目标的
	if onlySign then
		--如果是pve 直接返回false
		if self.controler.gameMode == Fight.gameMode_pve  then
			if self.currentCamp == 2 then
				self.hasSetAttackSign =false
				return false
			end
		end
		if self.hasSetAttackSign  then
			heroArr = {hero,self.attackSign}
			if self.attackSign then
				self.attackSign:onSkillBlack()
				self.hasSetAttackSign = false
			else
				echoWarn("___没有集火目标为什么还黑屏显示集火")
			end
		else
			return false
		end
	end
		
	if Fight.isDummy  then
		return true
	end
	--如果黑屏
	if blackFrame > 0 then
		hero:onSkillBlack()
		self.controler:showBlackScene()
	end

	

	self:setHeroViewAlpha(heroArr,hero,outBlack)
	return true
end

--让相关人员亮  无关人员按
function LogicalControler:setHeroViewAlpha( heroArr,hero ,outBlack )
	local targetOff = 0.3 * 255
	if hero.camp == 1 then
		--那么要比其他人亮一些
		targetOff = 0.7* 255
	end
	local targetOff2 = 0.3 * 255
	for k,v in pairs(hero.campArr) do
		if not table.indexof(heroArr,v) then
			if  v ~= hero then
				--如果已经攻击了 那么需要更暗一些
				if self.currentCamp == v.camp  and  self:checkRoundHasAttack(v.camp, v.data.posIndex) and (not self:checkIsInQuene(v) ) then
					v:tinyToColor(0.2, targetOff2)
				else
					v:tinyToColor(0.2, targetOff)
				end
				
			else
				v:tinyToColor(0.2, 255)
			end
			if not outBlack then
				v.data:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = v.camp,visible = false})
			end
			
		else
			v:tinyToColor(0.2, 255)
			if not outBlack then
				v.data:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = v.camp,visible = true})
			end
		end
	end

	for k,v in pairs(hero.toArr) do
		if not  table.indexof(heroArr,v) and v ~= hero then
			v:tinyToColor(0.2, targetOff2)
			if not outBlack then
				v.data:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = v.camp,visible = false})
			end
		else
			v:tinyToColor(0.2, 255)
			if not outBlack then
				v.data:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = v.camp,visible = true})
			end
		end
	end
end



--回合结束 复原透明度
function LogicalControler:resumeViewAlpha( isEndRound )
	if Fight.isDummy then
		return
	end


	local attakedLight= 0.5 * 255

	if isEndRound then
		
	end
	local targetLight = 255
	for k,v in pairs(self.controler.campArr_1) do
		if isEndRound then
			v:tinyToColor(0.2,targetLight)
		else
			--如果已经有攻击而且不在队列里面
			if self:checkRoundHasAttack(v.camp, v.data.posIndex) and (not self:checkIsInQuene(v) ) then
				v:tinyToColor(0.2,attakedLight)
			else
				v:tinyToColor(0.2,targetLight)
			end
		end
		
	end

	for k,v in pairs(self.controler.campArr_2) do
		v:tinyToColor(0.2,targetLight)
	end

end

--获取站位中线
function LogicalControler:getAttackMiddlePos(camp  )
	local middlePos = self.controler.middlePos
	--需要计算敌方最前面一个人的位置
	local campArr = camp == 1 and self.controler.campArr_1 or self.controler.campArr_2
	if #campArr == 0 then
		return middlePos
	end
	local hero = campArr[1]
	local way = camp == 1 and 1 or -1
	--计算缩减量 
	local reduce = 0 --  - 50* way --* (math.ceil( hero.data.posIndex/2 ) -1 )  
	-- echo(reduce,middlePos,"________________aaaaaaa获取攻击中线",way,camp)
	return middlePos + reduce
end

--设置标记对象
function LogicalControler:setAttackSign( hero )
	self.attackSign = hero
	-- echoError("____hero"..tostring(hero))
	if not Fight.isDummy then
		
		if hero then
			--设置将要暂停scenepause
			-- self.willPauseScene = true
			if hero.camp == 2 then
				self.controler.gameUi:setAttackSign(hero,true)
				--标记 设置了 atkSign
				self.hasSetAttackSign = true
			end
			
			-- self.controler:pushOneCallFunc(1, "scenePlayOrPause", {true,20})
		else
			self.controler.gameUi:setAttackSign(nil)
		end
	end
end


--判断是否有将要复活的人
function LogicalControler:checkCampHasRelive( camp )
	local diedArr = camp ==1 and self.controler.diedArr_1 or self.controler.diedArr_2
	return #diedArr > 0
end


--给某个阵营排序
function LogicalControler:sortCampPos( camp )
	local campArr = camp == 1 and self.controler.campArr_1 or self.controler.campArr_2
	local sortFunc = function (h1,h2  )
		if h1.data.posIndex < h2.data.posIndex then
			return true
		end
		return false
	end
	table.sort(campArr,sortFunc)
end


--执行某个时机行为
---- 时机触发事件  {camp(阵营) ,chance(时机类型),attacker(触发目标),defender(防守放)  }
function LogicalControler:doChanceFunc( chanceEvent )
	local arr
	if chanceEvent.camp == 1 then
		arr = {
			self.controler.campArr_1,
			self.controler.diedArr_1,
		}
	elseif chanceEvent.camp == 2  then
		arr = {
			self.controler.campArr_2,
			self.controler.diedArr_2,
		}
	else
		arr = {
			self.controler.campArr_1,
			self.controler.diedArr_1,
			self.controler.campArr_2,
			self.controler.diedArr_2,
		}
	end
	for i,v in ipairs(arr) do
		local length = #v
		for ii=length,1 ,-1 do
			local hero = v[ii]
			hero.data:checkChanceTrigger(chanceEvent)
		end
	end
end


--被动技能管理区域---------------------------------
--被动技能管理区域---------------------------------
--被动技能管理区域---------------------------------
function LogicalControler:insertPassiveSkill( passiveSkill )
	table.insert(self.passiveGroup, passiveSkill)
end

--清空被动技能作用
function LogicalControler:clearPassiveSkill(  )
	table.clear(self.passiveGroup)
end

--给一个英雄作用被动技
function LogicalControler:giveHeroPassiveSkill( hero )
	local length = #self.passiveGroup
	for i=length,1,-1 do
		local passiveSkill = self.passiveGroup[i]
		passiveSkill:usePassiveAtkDatas(hero)
		if passiveSkill.leftUseTimes == 0 then
			table.remove(self.passiveGroup,i)
		end
	end
end

--轮空机制：
--在首回合内，小怪全清并且进攻方有未出手的角色，则未出手的角色在过图的时候获得1000点额外怒气的奖励
function LogicalControler:beforNextWave(  )
	--如果回合数大于1 就不执行
	if self.roundCount ~= 2 then
		return
	end
	--拿到所有人的操作信息
	local campArr = self.controler.campArr_1
	for i,v in ipairs(campArr) do
		if not v.hasAttacked then
			--必须是能攻击的 
			if v.data:checkCanAttack() then
				--让他能量满
				-- echo("__让我满能量,",v.data.posIndex)
				v.data:changeValue(Fight.value_energy , v.data:maxenergy() )
				--轮空奖励
				v:insterEffWord( {2,29,Fight.buffKind_hao}	)
			end
			
		end
	end


end

--输入回合前的日志信息
function LogicalControler:toRoundStr(  )
	local str = "回合:"..self.roundCount..";"
	
	str = str .. "阵营:"..self.currentCamp.."\n"
	local campArr = self.controler["campArr_"..self.currentCamp]
	for i,v in ipairs(campArr) do
		str = str .. "id:"..v.data.hid..",pos:"..v.data.posIndex..",hp:"..v.data:hp()..",bf:"..v.data:getBuffNums( ) .."\n"
	end
	self.logsInfo = self.logsInfo ..str
	return str

end