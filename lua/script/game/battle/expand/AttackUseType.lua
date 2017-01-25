
local Fight = Fight
AttackUseType = {}

function AttackUseType:addPower(treasure, ratio)
	local manaCost = tonumber(treasure:sta_manaC())
	if ratio < 33 then
		return math.floor(manaCost/2)-1
	elseif ratio <= 66 then
		return math.floor(manaCost/2)
	else
		return math.floor(manaCost/2)+1
	end
end

--真正的attack包逻辑.
function AttackUseType:expand(attacker,defender, atkData,skill)
	local useType = nil
	local atkResult,damage 


	atkResult = defender:getDamageResult(attacker,skill)
	-- echo(atkResult,"_______________________atkResult")
	--先做攻击
	local comb = attacker.currentComb

	if atkData:sta_buffs() then
		self:buffs(atkResult,damage,attacker,defender, atkData,skill,atkData:sta_buffs())
	end

	if atkData:sta_dmg() then
		damage  = Formula:skillDamage(attacker,defender,skill,atkData,atkResult,comb)
		self:damageHit(atkResult,damage,attacker,defender, atkData,skill)
	end

	--如果是净化或者驱散效果
	if atkData:sta_purify() then
		self:purify(attacker,defender, atkData,skill,atkData:sta_purify())
	end

	if atkData:sta_addHp() then
		damage  = Formula:skillTreat(attacker,defender,skill,atkData,atkResult,comb  )
		self:addHp(atkResult,damage ,attacker,defender, atkData,skill)
	end

	

	local aniArr = atkData:sta_aniArr()
	if aniArr then
		defender:createEffGroup(aniArr, false)
	end
	self:checkAtkBlow(defender,atkData,skill ,attacker,atkResult)
	--发送全局生命值改变事件 主要是通知ui变化
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CHANGEHEALTH )

	return atkResult
end

--判断击飞
function AttackUseType:checkAtkBlow(defender,atkData,skill ,attacker ,atkResult)
	
	--如果有冰冻或者 霸体 那么是不击飞的 除非是死亡
	--必须是伤害行为才执行击飞
	if not atkData:sta_dmg() then
		return
	end

	--如果防守方阵营就是当前攻击阵营  那么不应该被击飞 
	if defender.camp == defender.logical.currentCamp then
		return
	end

	local movePos = atkData:sta_move()
	self:checkClearHeroFromArr(defender,atkData,skill,attacker)
	--blowState 0表示随配置 1表示身体不能被控制  霸体和冰冻状态 是不受击的 2表示格挡
	local blowState = 0
	-- echo(defender.data:checkHasOneBuffType(Fight.buffType_bingdong ) ,"是否有冰冻")
	--如果是有冰冻buff的  那么不能击飞 那么直接让 movePos 置空
	if defender.data:checkHasOneBuffType(Fight.buffType_bingdong )  then
		movePos = nil
		blowState = 1
	end
	--如果有豁免事件 0表示不豁免  1表示豁免击飞 2永久霸体
	if defender.data:immunity() == 2 then
		blowState = 1
		movePos = nil
	elseif defender.data:immunity() == 1 then
		movePos = nil
	--如果是格挡 做格挡动作
	elseif atkResult == Fight.damageResult_gedang or atkResult == Fight.damageResult_baojigedang  then
		if blowState == 0 then
			blowState = 2
		end
		
		movePos = nil
	end

	

	if movePos  then
		self:blowHero(defender,movePos,atkData)
	else
		--如果小于0 那么直接把他从数组清除,死亡时要移除数组防止,做死亡动作时候,还会被攻击检测.
		if defender.data:hp() <= 0 then
			--必须不是在空中的时候 才执行下面的操作
			if defender.myState ~= "jump" then
				if atkData.isFinal then
					if defender.reliveState == 1 then
						echo("这个人将要被复活")
						defender:justFrame(Fight.actions.action_blow3, nil, true)
					else
						defender:justFrame(Fight.actions.action_die, nil, true)
					end
				else
					if blowState == 0 then
						defender:justFrame(Fight.actions.action_hit, nil, true)
					end
				end
			end
		else
			--必须不在空中的时候 才能挨打
			if defender.myState ~= "jump" then
				if blowState == 0 then
					defender:justFrame(Fight.actions.action_hit, nil, true)
				--如果是格挡
				elseif blowState == 2 then
					defender:justFrame(Fight.actions.action_block, nil, true)
				end
			end
			
		end
	end
end


--击飞某个英雄
function AttackUseType:blowHero( hero,movePos,atkData )
	--先判断英雄当前的高度 也许英雄当前就是在空中

	

	--强制跳转到 击飞 允许循环

	local dz = -movePos[2] - hero.pos.z
	--如果目标高度 比现在低
	if dz > 0 then
		dz = 0
	end
	local vz = 0
	local t1 =0
	local t2 = 0
	local vx = 0
	local dx = -movePos[1] * hero.way
	--如果是击飞
	if dz < 0 then
		hero:initMoveType()

		local moveFrame = movePos[3] or 0
		--先计算下 加速度
		if moveFrame == 0 then
			hero.addSpeed.z =  Fight.moveType_g
		else
			hero.addSpeed.z = math.ceil( movePos[2]/(moveFrame*moveFrame) *2)
		end

		--得把整个路程分成2段
		vx,vz = Equation.countSpeedXZBySEHG(hero.pos.x,hero.pos.z,hero.pos.x + dx ,0,hero.addSpeed.z,hero.pos.z + dz )
		
		hero:initMove(vx,0)
		hero:initJump(vz)

		if hero.label == Fight.actions.action_blow1 or hero.label == Fight.actions.action_blow2 then
			hero:justFrame(Fight.actions.action_blow1, 1, true)
		else
			hero:justFrame(Fight.actions.action_blow1, nil, true)
		end

	else
		--如果是在空中的 而且只是水平位移 那么不执行
		if hero.myState == "jump" then
			return
		end
		if hero.data:hp() <= 0 then
			if atkData.isFinal then
				--如果是即将复活的
				if hero.reliveState == 1 then
					echo("_________滚动状态复活")
					hero:justFrame(Fight.actions.action_blow3, nil, true)
				else
					hero:justFrame(Fight.actions.action_die, nil, true)
				end
				
				return
			else
				if hero.label == Fight.actions.action_blow1 or hero.label == Fight.actions.action_blow2 then
					hero:justFrame(Fight.actions.action_blow1, 1, true)
				else
					hero:justFrame(Fight.actions.action_blow1, nil, true)
				end
			end
			
			return
		else
			if hero.label == Fight.actions.action_blow1 or hero.label == Fight.actions.action_blow2 then
				hero:justFrame(Fight.actions.action_blow1, 1, true)
			else
				hero:justFrame(Fight.actions.action_blow1, nil, true)
			end
		end
		--如果没有z速度 就水平击退 默认是击退开始动作加5帧
		local moveFrame = hero.totalFrames + 5
		vx = dx / moveFrame
		hero:initMove(vx,0)
		
	end
end


--判断是否应该从数组剔除这个人物 
function AttackUseType:checkClearHeroFromArr( hero,atkData,skill,attacker )
	if hero.data:hp()> 0 then
		return
	end

	if not hero.hasHealthDied then
		--判断是否是这个技能的最后一个攻击包
		if atkData.isFinal then
			hero.hasHealthDied = true

			--是否击杀 追击者
			local isKillSign = hero == hero.logical.attackSign 
			
			hero.controler:oneHeroeHealthDied(hero)
			
			local logical = hero.controler.logical

			if hero.data:beKill() then
				attacker.hasKillEnemy = true
			end

			attacker.data:changeValue(Fight.value_energy, Fight.killEnergyResume)
			attacker:checkZhugong()
			--标记这个英雄 杀了人  在动作完毕的时候 需要等待 然后播放power动作后 在跑回原位
			
			if not Fight.isDummy then
				--只有右方的人死亡才给提示
				if hero.camp == 2  then
					--击杀奖励文字
					if isKillSign then
						--击杀特效
						-- attacker:insterEffWord( {2,21,Fight.buffKind_hao  })
						--怒气特效
						attacker:insterEffWord( {2,12,Fight.buffKind_hao  })

						logical:checkNewTarget()

						--绝技激活特效
						-- attacker:insterEffWord( {2,22,Fight.buffKind_hao  })
					else
						--怒气特效
						attacker:insterEffWord( {2,12,Fight.buffKind_hao  })
					end

					
				end
				
			end
			-- if isKillSign then
			-- 	--判断击杀技
			-- 	self:checkKillSkill(hero,atkData,skill,attacker)
			-- end
			hero:beKilled(attacker)
			--让attacker激活击杀技能
			attacker:activityKillSkill(hero)
		end
	end
end

--判断击杀绝技
function AttackUseType:checkKillSkill(hero,atkData,skill,attacker  )
	local killSkill = attacker.data.curTreasure.skill7
	if not killSkill then
		return 
	end
	echo("___触发击杀技能",killSkill.hid)
	killSkill:doAtkDataFunc()

end


-- 通过类型判定调用伤害计算公式

--多次减血数组
function AttackUseType:checkkMultyAttackEffect(model,atkData,numType,damage, showZorder)
	if Fight.isDummy then
		return
	end
	local scoreT =  1--atkData:sta_scoreT()
	local scoreD = 1-- atkData:sta_scoreD()

	local perDamage = math.ceil( damage)
	-- for i=1,scoreT do
	-- 	model:pushOneCallFunc((i-1)*scoreD,"createNumEff",{numType,perDamage,showZorder})
	-- end
	model:createNumEff(numType,perDamage,showZorder)
end

-- 1 打击
-- 说明: A:首先判断法宝能抵挡多少伤害; B 然后减血, C如果血量为零就直接跳过通过重创后仰击退来最后运行到死亡动作.
function AttackUseType:damageHit(atkResult,damage,attacker,defender, atkData,skill)
	local isWudi = defender.data:checkHasOneBuffType( Fight.buffType_wudi )
	local value = damage 
	value =value <1 and 1 or value
	--一管血对应1.5管怒气
	local ratio = value / defender.data:maxhp() * 1.5 
	--挨打加能量
	if ratio < 0.001 then
		ratio = 0.001
	elseif ratio > 1 then
		ratio = 1
	end

	defender.data:changeValue(Fight.value_health, -value, 1, 0)

	--挨打需要恢复能量
	defender.data:changeValue(Fight.value_energy, ratio*1000)
	--普通攻击或者格挡
	if atkResult == Fight.damageResult_normal or atkResult == Fight.damageResult_gedang   then
		AttackUseType:checkkMultyAttackEffect(defender,atkData,Fight.hitType_shanghai ,-value,1)
	else
		AttackUseType:checkkMultyAttackEffect(defender,atkData,Fight.hitType_baoji  ,-value,1)
	end
	
	--统计伤害---
	StatisticsControler:statisticsdamage(attacker,defender,skill,value)
	defender:flash()
end
--2
function AttackUseType:addHp(atkResult,hp,attacker,defender, atkData,skill)	
	defender.data:changeValue(Fight.value_health,hp,1,0)
	AttackUseType:checkkMultyAttackEffect(defender,atkData,Fight.hitType_zhiliao ,hp,1)
end

-- 净化或者驱散
function AttackUseType:purify(attacker,defender, atkData,skill,params)
	--净化
	if params == 1 then
		defender.data:clearBuffByKind(Fight.buffKind_huai)
	else
		--驱散好的
		if not defender.data:checkHasOneBuffType( Fight.buffType_wudi ) then
			defender.data:clearBuffByKind(Fight.buffKind_hao)
		end
	end
end

--作用buff
function AttackUseType:buffs(atkResult,damage,attacker,defender, atkData,skill,buffs)
	if buffs and #buffs >0 then
		for i,v in ipairs(buffs) do
			defender:checkCreateBuff(v,attacker)
		end
	end
	
end





--=================================================================================================
--=================================================================================================
--=================================================================================================
--=================================================================================================
--攻击包上额外创建的missle
--addMissle chooseArr选择到的目标 
function AttackUseType:createAttackMissle( addMissle, chooseArr,player,skill, carrier )
	for i,v in ipairs(addMissle) do
		local missleId = v.id
		local t = v.t
		--如果是1表示把选中的一个攻击攻击目标指派给missle,
		if t == 1 then
			--遍历选择到的目标 一个目标创建一个missle
			for ii,vv in ipairs(chooseArr) do
				player:createMissle(ObjectMissle.new(missleId), skill,vv,carrier)
			end

		--0表示创建一个独立的missle
		elseif t ==0 then
			player:createMissle(ObjectMissle.new(missleId), skill,nil,carrier)
		end
	end
end




return AttackUseType