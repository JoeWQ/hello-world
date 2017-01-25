--
-- Author: XD
-- Date: 2014-07-24 10:48:11
--主要处理释放法宝 释放技能这块的逻辑
--
local Fight = Fight

ModelAutoFight = class("ModelAutoFight", ModelCreatureBasic)

ModelAutoFight.isArrive = false 		-- 判断是否到达  如果到达之后 那么 就不需要进行 运动检测了  只有在有敌人死亡的时候 才需要进行 运动检测
ModelAutoFight.isWaiting = false 		-- 是否是等待当中
ModelAutoFight.idleInfo = nil 			-- 闲置信息
ModelAutoFight.treasuresInfo = nil 		-- 当前法宝剩余时间信息
ModelAutoFight.currentSkill = nil 		-- 当前释放的技能
ModelAutoFight.nextSkillIndex = 1 		--下一个技能index

ModelAutoFight.currentComb =  1 		--当前连击

ModelAutoFight.hasAttacked = false 		--标记当前回合是否攻击过



function ModelAutoFight:ctor( ... )
	ModelAutoFight.super.ctor(self,...)
	-- self.nextSkillIndex = Fight.skillIndex_normal
	self.nextSkillIndex = Fight.skillIndex_small

end
 

--初始化数据
function ModelAutoFight:initData( data )
	ModelAutoFight.super.initData(self, data )
end

---------------------------技能相关---------------------------------
---------------------------技能相关---------------------------------
---------------------------技能相关---------------------------------


--创建技能特效分上下层
function ModelAutoFight:createSkillEff(skill)	
	if not Fight.isDummy then
		local aniEff = skill:sta_aniArr()
		skill.__skillEffArr = self:createEffGroup(aniEff, false)
		if skill.__skillEffArr then
			for i=1,#skill.__skillEffArr do
				skill.__skillEffArr[i]:setSkillEffect(i)
			end
		end
    end
end

-- t=底层特效, 2 上层特效, 3警示区域
function ModelAutoFight:clearSkillEff( t )
	if not self.currentSkill then
		return
	end
	if self.currentSkill.__skillEffArr then
		table.removebyvalue(self.currentSkill.__skillEffArr,t)
		-- table.remove(self.currentSkill.__skillEffArr,t)
		if #self.currentSkill.__skillEffArr == 0 then
			self.currentSkill.__skillEffArr = nil
		end
	end
end

--释放一个技能
function ModelAutoFight:giveOutOneSkill( skill,skillIndex,isChangeTreasure)
	self.currentSkill = skill

	local xpos,ypos = AttackChooseType:getSkillAttackPos( self.controler,self, skill )
	local firstHero = AttackChooseType:findHeroByPosIndex(skill.firstHeroPosIndex,self.campArr)
	self.logical:doChanceFunc( {camp = self.camp,attacker = self,chance = Fight.chance_atkStart,defender = firstHero} )
	if not Fight.isDummy then
		-- 技能震屏
		local sk = skill:sta_shake()
	 	if sk then
	 		self:shake(sk[1],sk[2],sk[3])
	 	end
	
		if not isChangeTreasure then
			--判断透明度
			self.controler.logical:checkRelation(self,skill)
			if skillIndex == 3 then
				self:playMaxSkillEff(skill)
			end
			
		end
		

		local enterTypeInfo = skill:sta_enterType() or {0,0}
		local enterType = enterTypeInfo[1]
		--入场速度
		local enterSpeed = enterTypeInfo[2] or 0
		--如果没有出场效果
		if enterType == 0 then
			self:moveToSkillPos(skill,Fight.actions.action_run,xpos,ypos,enterSpeed)
		--小技能出场 播放race2
		elseif enterType == 1 then
			if not isChangeTreasure then
				self:justFrame(Fight.actions.action_treaOn2 , nil, true)
				self:pushOneCallFunc(self.totalFrames, "moveToSkillPos", {skill,Fight.actions.action_race2,xpos,ypos,enterSpeed })
			else
				self:moveToSkillPos(skill,Fight.actions.action_race2,xpos,ypos,enterSpeed)
			end
			-- self:moveToSkillPos(skill,Fight.actions.action_race2,xpos,ypos)
		--大招入场效果
		elseif enterType == 2 then
			--如果是0 那么立马切换过去
			if speed == 0 then
				speed = 999999
			end
			if not isChangeTreasure then
				self:justFrame(Fight.actions.action_treaOn3 , nil, true)
				self:pushOneCallFunc(self.totalFrames, "moveToSkillPos", {skill,Fight.actions.action_race3,xpos,ypos,enterSpeed })
			else
				self:moveToSkillPos(skill,Fight.actions.action_race3,xpos,ypos,enterSpeed)
			end
		end
		
		local enterEff = skill:sta_enterEff()
		if enterEff then
			self:createEffGroup(enterEff, false)
		end
	else

		--直接达到技能目标点
		self:onMoveAttackPos(skill)

	end
end

--让自己跑到对应的位置上去
function ModelAutoFight:moveToSkillPos( skill,action,xpos,ypos,speed )
	self.logical.isSkillMoving = false
	self.logical:removeFromQuene(self)

	action = action or Fight.actions.action_run
	--判断屏幕运动和镜头 运动和速度相关的逻辑 放到 moveModel里面去
	self:checkScreenCamera(skill,xpos,ypos,speed)
	
	--如果攻击的时候 需要隐藏


	

	if skill:sta_appear() == Fight.skill_appear_myplace  then
		self:onMoveAttackPos(skill,true)
	--如果没有任何坐标偏移
	elseif xpos == self.pos.x and ypos == self.pos.y then
		self:onMoveAttackPos(skill,true)
	else
		local pointParams = {
			x = xpos,
			y = ypos + 2,
			call = {"onMoveAttackPos",{skill}}
		}
		if not speed or  speed == 0 then
			pointParams.speed = self:countSpeed(xpos,ypos+2)
		else
			pointParams.speed  = speed
		end
		
		self:setWay(self:getWayByPos(xpos))
		self:moveToPoint(pointParams)
		if self.moveType ~= 0 then
			self:justFrame(action)
		end
	end

	
	local  blackFrame = skill:sta_blackFrame() or 0
	if blackFrame > 0 and (not Fight.isDummy)  then
		--隐藏黑屏 如果没有大招展示的
		-- if not skill:sta_attackPerformanceType() then
			
		-- end
		self.controler:pushOneCallFunc(blackFrame, "hideBlackScene")
	end

	
end

--到达攻击点
function ModelAutoFight:onMoveAttackPos( skill ,isOldPlace )


	--插入帧事件
	local attackInfos = skill.attackInfos
	local missleInfos = skill.missleInfos

	if not Fight.isDummy then
		-- if skill.showTotalDamage then
		-- 	self.controler.camera:scaleBySpineAction("eff_treasure30007_jingtou","eff_treasure30007_jingtou","jingtou")
		-- end
		-- self:checkScreenCamera(skill,0,0,0)
		self:checkScreenCameraMax(skill)

		--如果出现方式是我面前 那么得转向
		if not isOldPlace and(  skill:sta_appear() == Fight.skill_appear_myFirst or skill:sta_appear() == Fight.skill_appear_myMiddle) then
			self:setWay(self.way* - 1)
		else
			
		end

		--开始改变动作
		local action = skill:sta_action()
		
		--这里需要根据是否按照帧长度走
		local lastFrame = skill:sta_lastFrame() or 0
		if  lastFrame > 0 then
			self:justFrame(Fight.actions.action_giveOutBS )
			--然后确定多少帧后跳转到结束
			--local frame1 = self:getTotalFrames(Fight.actions.action_giveOutBS)
			local frame3 = self:getTotalFrames(Fight.actions.action_giveOutBE)
			local delayFrame = lastFrame - frame3
			if delayFrame < 0 then
				echoWarn("当前法宝配置的持续帧太短:,giveOutBE:%02d,lastFrame:%d",frame3,lastFrame)
			end
			delayFrame = delayFrame < 1 and 1 or delayFrame
			--这么多帧以后跳转到end上面去
			self:pushOneCallFunc(delayFrame, "justFrame", {Fight.actions.action_giveOutBE })
		else
			self:justFrame(action)
		end
		if not Fight.isDummy then
			self.controler.gameUi:setAttackSign(nil)
		end
		--那么延迟这么多帧
		for i,v in ipairs(attackInfos) do
			if v[2] > self.totalFrames and  lastFrame == 0 then
				echoError("____这个技能检测帧大于当前动作长度,label:%s,动作长度:%d,检测帧:%d, hid:%s,skill:%s,",self.label,self.totalFrames,v[2],self.data.hid,skill.hid)
			end
			self:pushOneCallFunc(v[2], "checkSkillInfo", {v,skill,i})
		end
		
		for i,v in ipairs(missleInfos) do
			self:pushOneCallFunc(v[2], "checkSkillInfo", {v,skill})
		end

		-- 技能特效
		self:createSkillEff(skill)

		--如果是将要暂停的
		-- if self.logical.willPauseScene then

		-- 	-- self.controler:scenePlayOrPause(true,20)
		-- 	self.controler.gameUi:setAttackSign(self.logical.attackSign,true)
		-- 	self.logical.willPauseScene = false
		-- end

	else
		--直接检测帧
		for i,v in ipairs(attackInfos) do
			self:checkSkillInfo(v,skill)
		end

		for i,v in ipairs(missleInfos) do
			self:checkSkillInfo(v,skill)
		end
	end

end

--判断技能攻击检测
function ModelAutoFight:checkSkillInfo(info,skill,atkIndex)
	if not skill then
		echo("__________________为什么没有技能？？？？")
		return
	end

	--如果已经出结果了 那么不应该检测技能了
	if self.controler.__gameStep == Fight.gameStep.result then
		return
	end

	--如果敌方已经死光了 那么也不需要判断
	if #self.toArr == 0 then
		return
	end
	local atkData = info[3]
	--如果是攻击包
	if info[1] == Fight.skill_type_attack  then
		self:checkAttack(atkData,skill)
	elseif info[1] == Fight.skill_type_missle then
		self:createMissle( info[3],skill)
	else
		echoWarn("错误的技能类型",info[1])
	end

	if skill.showTotalDamage and atkIndex and self.camp == 1  then
	-- if atkIndex then
		local damage = StatisticsControler:getRidDamage(self.data.rid)
		local chance 
		--如果是1 
		if atkIndex ==1 then
			chance = 1
		elseif atkIndex == #skill.attackInfos then
			chance = 3
		else
			chance = 2
		end
		if atkIndex == #skill.attackInfos and atkIndex == 1  then
			chance = 4
		end
		if damage > 0 then
			-- echo(atkIndex,chance,#skill.attackInfos,"__播放技能总伤害")
			
		else
			-- echo(atkIndex,chance,#skill.attackInfos,"__还没有伤害",info[3].hid)
		end
		if atkData:sta_dmg() then
			ModelEffectNum:createSkillDamage(damage,chance)
		end
		
	end

end

--技能动作播放完毕
function ModelAutoFight:onSkillActionComplete(  )
	--如果杀人了

	--拿到坐标偏移
	local skillOffset = self.currentSkill:sta_atkOffset()
	if skillOffset then
		--那么进行坐标偏移
		self:setPos(self.pos.x +skillOffset,self.pos.y,self.pos.z )
	end

	if self.hasKillEnemy and self.camp == 1 then
		--取消杀人属性  然后 20帧后 播放
		self.hasKillEnemy =false
		self:standAction()

		--10帧以后播放powerup
		self:pushOneCallFunc(10, "justFrame", {Fight.actions.action_powerup})
	else
		self:movetoInitPos(1)
	end

	-- self:movetoInitPos(1)
end




--即将位置复原 t 类型 1表示 是攻击完毕后 回到起点 
--2表示起身后回到起点  或者从别的位置回到起点 不做其他事
--3表示复活后回调起点
function ModelAutoFight:movetoInitPos( t ,speed)
	--显示或者隐藏buffani
	self:showOrHideBuffAni(true)

	t = t and t or 1
	--如果确定没人了 那么直接攻击完毕
	if self:checkIsNoPerson() and t ==1 then
		self.controler.logical:onAttackComplete(self.camp,self.data.posIndex)
		return
	end

	if Fight.isDummy then
		self:initPosComplete(t)
	else
		self:setWay(self:getWayByPos(self._initPos.x))
		local posParams = {
			x = self._initPos.x,
			y = self._initPos.y,
			call = {"initPosComplete",{t}},
			speed = speed or  self:countSpeed(self._initPos.x, self._initPos.y)
		}
		self:moveToPoint(posParams)
	end
	
	--必须是有一定距离才回到起点
	if self.moveType ~= 0 then
		self:justFrame(Fight.actions.action_run, nil)
	end
	
	if t ==1 then
		self.logical:doChanceFunc({camp = self.camp,chance = Fight.chance_atkend,attacker = heroModel})
		--判断下被动技能
		self:checkPassive()
		self.controler.logical:onAttackComplete(self.camp,self.data.posIndex)

	end
	
end

--判断下被动技能
function ModelAutoFight:checkPassive( )
	local skillIndex = self.currentSkill.skillIndex
	--被动技能
	local passiveSkill = self.data.curTreasure.skill8
	if not passiveSkill then
		return
	end
	--判定是否激活被动技
	if not passiveSkill:checkCanTrig(skillIndex) then
		return
	end
	echo(passiveSkill.useStyle,"___开始触发被动技了",skillIndex)
	--如果是简单做攻击包
	if passiveSkill.useStyle == 1 then
		passiveSkill:usePassiveAtkDatas(nil)
	else
		--把这个技能放到控制器里
		self.logical:insertPassiveSkill(passiveSkill)
	end



end


--初始化坐标结束
function ModelAutoFight:initPosComplete( t )
	if self.camp == 1 then
		self:setWay(1)
	else
		self:setWay(-1)
	end
	self:checkUseFilterStyle()
	--判断是否取消连击
	t = t and t or 1
	if t == 1 then
		self.logical:checkCancleComb()
	--如果是复活回来,判断是否有法宝崩溃结束
	elseif t == 3 then
		self:checkTreasureEnd()
	end

end


--根据回合数判断应该用什么技能
function ModelAutoFight:checkSkill(skill,comb,isChangeTreasure)
	-- local skillIndex = self.nextSkillIndex
	--除了大招就一定是小技能
	--走到这里表示本回合攻击过
	self.hasAttacked = true

	local skillIndex = Fight.skillIndex_small 
	if not skill then
		--只有是默认法宝 才会判定大招
		if self.data:isDefaultTreasure() or true then
			--如果能量满而且能够释放技能的
			if self.data:checkCanGiveSkill() then
				--而且必须有大招的
				if self.data:hasMaxSkill() then
					skillIndex = Fight.skillIndex_max
				end
			end
		end
		
		skill = self.data.curTreasure["skill"..skillIndex]
	else
		skillIndex = 1
	end
	
	if not skill then
		echoWarn("没有对应技能:","skill"..skillIndex,"法宝id:",self.data.curTreasure.hid)
	end
	self.currentComb = comb
	
	if not isChangeTreasure then

		local skillEffCall = function (  )
			AttackChooseType:getSkillAttackPos( self.controler,self, skill )
			if self.logical:checkRelation(self, skill,nil,true ) then
				self:pushOneCallFunc(Fight.attackSignFrame, "onAttackSignToSkill",{skill,skillIndex,isChangeTreasure})
			else
				self:onAttackSignToSkill(skill,skillIndex, isChangeTreasure)
			end
		end

		skillEffCall()
		
		
	else
		self:onAttackSignToSkill(skill,skillIndex, isChangeTreasure)

	end

end

function ModelAutoFight:onAttackSignToSkill(skill,skillIndex, isChangeTreasure)
	if not isChangeTreasure then
		self.controler:hideBlackScene()
	end
	local energy = self.data:energy()
	--不是大招才增加怒气
	if skillIndex ~= Fight.skillIndex_max then
		--先增加怒气
		local resumeEnergy = skill:sta_resumeEnergy() or 0
		self.data:changeValue(Fight.value_energy, resumeEnergy)
	else
		if not Fight.debugFullEnergy then
			self.data:changeValue(Fight.value_energy , -energy)
		end
		
	end


	self:giveOutOneSkill(skill,skillIndex,isChangeTreasure)

	self:setFootLight(0)
	self:showOrHideBuffAni(false)

	--如果是小技能  那么让下一个小技能index为 1
	if skillIndex == Fight.skillIndex_small  then
		self.data:onGiveSmallSkill()
		-- self.nextSkillIndex = 1
	end

end




--获取下一个技能队列的位置偏移
function ModelAutoFight:getSkillQuePos( )
	if not self.nextOperationInfo then
		return nil
	end
	local t = self.nextOperationInfo.type
	local skill
	--如果是给技能
	if t == Fight.operationType_giveSkill  then
		--如果能量满了
		local skillIndex  = self.nextSkillIndex
		if self.data:energy() >= self.data:maxenergy() then
			skillIndex = Fight.skillIndex_max 
		end
		skill = self.data.curTreasure["skill"..skillIndex]
	else
		local treasureIndex = self.nextOperationInfo.params
		local treasureObj = self.data.treasures[treasureIndex+1]
		skill = treasureObj.onSkill or treasureObj.skill1
	end
	return skill:sta_quePos()
end





--获取下一个将要释放的技能
function ModelAutoFight:getNextSkill(  )
	local skillIndex = self.nextSkillIndex
	local skill
	--只有是默认法宝 才会判定大招
	if self.data:isDefaultTreasure() then
		--如果能量满了  那么 优先用最后一个技能 就是大招
		--如果能量满而且能够释放技能的
		if self.data:checkCanGiveSkill() then
			skillIndex = Fight.skillIndex_max
		end
	end
	
	skill = self.data.curTreasure["skill"..skillIndex]
	return skill,skillIndex
end


--------------------------------------法宝相关--------------------------------
--------------------------------------法宝相关--------------------------------
--------------------------------------法宝相关--------------------------------


--当B类法宝祭出结束时
function ModelAutoFight:onGiveoutBE(  )

	echo("释放B类法宝结束 还原回去--",self.data.curTreasure.treasureLabel,self.data.curTreasure.hid)
	--如果是b类法宝 那么放完变成素颜就回去
	local  treasureObj = self.data.curTreasure
	if treasureObj.treasureLabel == Fight.treasureLabel_b  then
		-- 这个时候 需要换回素颜 
		echo("______播放法宝崩溃动作")
		self:justFrame(Fight.actions.action_treaOver)
	else
		self:movetoInitPos(1)
	end
end


--切换法宝
function ModelAutoFight:checkTreasure(treasureIndex,comb  )
	--如果不是默认法宝 
	if treasureIndex >= 1 then
		--那么 消耗光能量
		self.data:changeValue(Fight.value_energy , -self.data:maxenergy())
	end
	
	self.currentComb = comb
	

	local treasureObj = self.data.treasures[treasureIndex+1]
	local skill = treasureObj.onSkill or treasureObj.skill1
	

	if not Fight.isDummy then
		self:setFootLight(0)

		local skillEffCall = function (  )
			if self.logical:checkRelation(self, skill,nil,true ) then
				self:pushOneCallFunc(Fight.attackSignFrame, "onAttackSignToTreasure",{skill,treasureIndex})
			else
				self:onAttackSignToTreasure(skill,treasureIndex)
			end
		end
		skillEffCall()
		

	else
		self.logical:checkRelation(self, skill,nil,true )
		self:onGiveOutTreasureEnd(treasureIndex,true)
	end
	
end

--播放大招特写
function ModelAutoFight:playMaxSkillEff( skill )
	if Fight.isDummy  then
		return
	end

	if true then
		return
	end

	local aniInfoArr = {

	}

	if self.data.hid == "30008" then
		aniInfoArr = { {name = "dazhaoceshi_lixiaoyao",action = "eff_dazhaotishi",type = "spine",layer = self.controler.layer.a122 } }
	 
	elseif self.data.hid == "30005" then
		aniInfoArr = { {name = "dazhaoceshi_linyueru",action = "texie_hou",type = "spine" ,layer = self.controler.layer.a122} ,
						{name = "dazhaoceshi_linyueru",action = "texie_qian",type = "spine" ,layer = self.controler.layer.a124} ,
					}
	else
		aniInfoArr = { {name = "UI_dazhaotishi_linyueru",type = "flash",layer = self.controler.layer.a122 } }
	end 
	self:onSkillBlack(Fight.zorder_blackChar +100)
	for i,v in ipairs(aniInfoArr) do
		local eff = ModelEffectBasic.new(self.controler)
		eff:setIsCycle(false)
		eff:setFollow(false)
		eff:setTarget(self,0,0,0,0)
		local focusPos = self.controler.screen.focusPos
		-- local ani = ViewArmature.new("UI_dazhaotishi_linyueru")
		local ani
		if v.type == "spine" then
			ani = ViewSpine.new(v.name)
			ani:playLabel(v.action)
		else
			ani = ViewArmature.new(v.name)
		end

		ani:setScaleX(Fight.cameraWay * self.way *0.8)
		ani:setScaleY(0.8)
		eff:initView(v.layer ,ani,focusPos.x ,focusPos.y ,0)
		
		eff.myView:zorder(Fight.zorder_blackChar+100 + self.__zorder - 1 )
		self.controler:insertOneObject(eff)
	end


	

	if callBack then
		self:pushOneCallFunc(20, callBack)
	end
	

end

--播放大招镜头
function ModelAutoFight:playMaxSkillCamrea(skill  )
	if skill.hid == "300073" or skill.hid  == "3000731" then
		
	end
end




function ModelAutoFight:onAttackSignToTreasure( skill,treasureIndex)
	--直接播放祭出动作
	self.controler:hideBlackScene()
	self:justFrame(Fight.actions.action_treaOn3, 1)
	--判定操作相关人员
	self.logical:checkRelation(self, skill )

	--播放大招特写
	if treasureIndex >= 1 then
		self:playMaxSkillEff(skill)
	end

	self:pushOneCallFunc(self.totalFrames, "onGiveOutTreasureEnd", {treasureIndex,true})
end




--法宝祭出结束
function ModelAutoFight:onGiveOutTreasureEnd(treasureIndex ,doSkill )
	
	--比较2个法宝是否是同一个对象 或者是否需要换装
	local oldSpineName = self.data.curSpbName
	local treasureObj = self.data.treasures[treasureIndex+1]
	self.data:useTreasure(treasureObj,treasureIndex)
	if oldSpineName ~= self.data.curSpbName then
		self:changeView(self.data.curSpbName)
	end
	if self.camp == 1 then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CHANGETREASURE,treasureIndex)
	end
	
	if self.data.curTreasure.onSkill then
		self:checkSkill(self.data.curTreasure.onSkill,self.currentComb ,true )
	else
		--那么默认放第一个技能
		self:checkSkill(self.data.curTreasure.skill1,self.currentComb ,true)
	end
	echo(treasureIndex,"_____更换法宝--------------")
	
end

--法宝崩溃结束
function ModelAutoFight:onTreasureOverEnd(  )
	
	local  treasureIndex =0
	echo("___法宝崩溃完毕")
	local oldTrasure = self.data.curTreasure
	--比较2个法宝是否是同一个对象 或者是否需要换装
	local oldSpineName = self.data.curSpbName
	--如果是boss变身的
	if self.transbodyInfo then
		treasureIndex = self.data:insterTreasure(self.transbodyInfo.id)
	end

	local treasureObj = self.data.treasures[treasureIndex+1]
	self.data:useTreasure(treasureObj,treasureIndex)
	if oldSpineName ~= self.data.curSpbName then
		self:changeView(self.data.curSpbName)
	end

	--如果是b类法宝 那么放完变成素颜就回去
	if oldTrasure.treasureLabel == Fight.treasureLabel_b  then
		echo("__跑到初始位置")
		self:movetoInitPos(1)
	else
		echo("A类法宝崩溃 播放original")
		if Fight.isDummy  then
			self:onOriginalEnd()
		else
			--切换成素颜的时候  需要播放 original动作
			self:justFrame(Fight.actions.action_original)
			self:pushOneCallFunc(self.totalFrames, "onOriginalEnd")
		end
		
	end
	--删除变身信息
	self.transbodyInfo = nil
	--切换成素颜  只有我方切换的时候 才做这个事情
	if self.camp == 1 then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CHANGETREASURE,treasureIndex)
	end
	
end

--崩溃结束
function ModelAutoFight:onOriginalEnd(  )
	--这个时候让自己在单独做一次 特殊技 回合开始前判定
	self.data:checkChanceTrigger({camp = self.camp,chance =Fight.chance_roundStart})
	self:checkSummonEnd()
end


-----------------------------------------回合相关-------------------------------------------
-----------------------------------------回合相关-------------------------------------------
-----------------------------------------回合相关-------------------------------------------

--回合前做的事情
--回合前的流程 依次先判断 复活, 法宝treaover,召唤, 
function ModelAutoFight:doRoundFirst(  )

	self.hasAttacked = false
	self.data:updateRoundFirst()
	--初始化伤害结果判定
	self.damageResultInfo = {}

	--如果是将要复活的
	if self.reliveState == 1 then

		echo("_设置ready状态为false---")
		--设置回合readyFalse
		self:setRoundReady(false)
		--先做复活功能
	else
		self:checkTreasureEnd()
	end

end



--做复活行为
function ModelAutoFight:doReliveAction(  )
	
	--把我插入进数组
	local campArr = self.campArr
	table.insert(campArr, self)
	local diedArr = self.diedArr
	--移除自己
	table.removebyvalue(diedArr, self)

	self.hasHealthDied =false

	self.logical:sortCampPos(self.camp)
	--重新加入数组排序
	
	self:justFrame(Fight.actions.action_relive,nil,true)
	--复活完成了 
	self:pushOneCallFunc(self.totalFrames, "onReliveComplete")

end

--复活完毕
function ModelAutoFight:onReliveComplete(  )
	--改变复活状态
	self.reliveState = 2
	--取消标记死亡
		
	--判断是否在原地
	echo("_复活完毕-------statte:%s,是否原地:%s",self.myState,self.pos.x == self._initPos.x)
	if self.pos.x ~= self._initPos.x then
		--3表示复活起身
		self:movetoInitPos(3)
	else
		self:checkTreasureEnd()
	end

end




--判断是否法宝崩溃
function ModelAutoFight:checkTreasureEnd(  )

	self:checkFootLight()
	if self.data.curTreasure.leftRound  > 0 then
		--减少法宝使用次数
		self.data.curTreasure.leftRound = self.data.curTreasure.leftRound-1
	end
	
	--如果是变身的
	if self.data.curTreasure.leftRound == 0 or self.transbodyInfo then
		--如果是清除控制形buff的 ,那么需要清除晕眩冰冻和沉默
		if self.transbodyInfo and  self.transbodyInfo.params1 == 1 then
			self.data:clearGroupBuff(Fight.buffType_xuanyun )
			self.data:clearGroupBuff(Fight.buffType_bingdong )
			self.data:clearGroupBuff(Fight.buffType_chenmo  )
		end
		if self.data:checkHasOneBuff(Fight.buffType_bingdong) then
			return
		end
		--设置回合readyFals
		self:setRoundReady(false)
		if Fight.isDummy  then
			--直接over
			self:onTreasureOverEnd()
		else
			self:justFrame(Fight.actions.action_treaOver)
			self:pushOneCallFunc(self.totalFrames, "onTreasureOverEnd")
		end
		
		echo("____法宝崩溃,当前法宝位置:",self.data.curTreasureIndex)
	else
		--判断是否有召唤
		self:checkSummonEnd()
		--设置roundReady
		-- self:setRoundReady(true)
	end
end


--判断是否有召唤
function ModelAutoFight:checkSummonEnd(  )
	if not self.summonSkill then
		-- self:checkTreasureEnd()
		--那么回合准备完毕
		self:setRoundReady(true)
	else
		--那么让自己没有准备好
		self:setRoundReady(false)

		self.currentSkill = self.summonSkill
		self:onMoveAttackPos(self.summonSkill)
		--召唤完毕后判定 roundReady完毕
		if Fight.isDummy  then
			self:setRoundReady(true )
		else
			self:pushOneCallFunc(self.totalFrames,"setRoundReady",{true} )
		end
		
		self.summonSkill = nil
	end
end

--敌方回合前做什么事情
function ModelAutoFight:doToRoundFirst(  )
	self:checkFootLight()
end

--我方回合后做的事情
function ModelAutoFight:doRoundEnd(  )
	self.data:updateRoundEnd()
end

--敌方回合后做的事情
function ModelAutoFight:doToRoundEnd(  )
	self.data:updateToRoundEnd()
end

--轮到我的回合 随机选择一个操作
function ModelAutoFight:chooseOneAutoHandle(delayFrame  )
	local operationInfo = {index = self.data.posIndex ,camp = self.camp}
	--先判断是否是主角
	if self.data.isCharacter then
		local treasureIndex = self.data.curTreasureIndex
		--如果能量满了
		if self.data:energy() >= self.data:maxenergy() then
			if treasureIndex == 0 then
				treasureIndex = 1
			elseif  treasureIndex ==1 then
				treasureIndex = 2
			elseif  treasureIndex ==2 then
				treasureIndex = 1
			end
			operationInfo.type = Fight.operationType_giveTreasure
			operationInfo.params = treasureIndex
		else
			operationInfo.type = Fight.operationType_giveSkill
		end
	else
		operationInfo.type = Fight.operationType_giveSkill
	end
	return  operationInfo
	-- self.logical:insterOneHandle(self.camp,self.data.posIndex,operationInfo.type,operationInfo.params,delayFrame)
end


--激活击杀技
function ModelAutoFight:activityKillSkill( killedHero )
	local killSkill = self.data.curTreasure.skill7
	if not killSkill then
		return 
	end
	echo("___触发击杀技能",killSkill.hid)
	killSkill:doAtkDataFunc()
end


--判断是否给别人助攻奖励
function ModelAutoFight:checkZhugong(  )
	local buffInfo = self.data.buffInfo
	for k,v in pairs(buffInfo) do
		for kk,vv in pairs(v) do
			--判断是否有助攻奖励
			local rewardEnergy = vv:sta_rewardEnergy()
			if rewardEnergy and rewardEnergy > 0  then
				local hero = vv.hero
				--改变能量
				hero.data:changeValue(Fight.value_energy , rewardEnergy)
				--助攻奖励文字
				hero:insterEffWord({2,31,Fight.buffKind_hao }, isDelay)
				-- echo("__助攻成功")
			end
		end
	end

end


