--
-- Author: Your Name
-- Date: 2014-03-19 17:45:18
--具备生命的对象的基类
--
local Fight = Fight
ModelCreatureBasic = class("ModelCreatureBasic", ModelFrameBasic)

ModelCreatureBasic.actionExTarget = nil -- 为了身外的法宝

ModelCreatureBasic._footRootPos  = nil 		--脚下骨头坐标 为了绑定附着在人身上的 所有特效和影子等等

--[[
	{
		样式id:对应的次数 如果为0 表示取消样式
	}	
]]
ModelCreatureBasic.filterStyleInfo = nil 		--滤镜样式管理器

--存储中的每个技能的暴击闪避等
--[[
	{
	[attacker.hid .. skill.hid] = attackResult

	}
	

]]
ModelCreatureBasic.damageResultInfo = nil
--复活阶段 0表示正常状态 1表示将要复活 2表示复活成功 已经复活过的人不能被再次复活
ModelCreatureBasic.reliveState = 0

function ModelCreatureBasic:ctor( ...)
	ModelCreatureBasic.super.ctor(self,...)
	self.hitBorderAble = true

	--具有生命的 对象 深度排列id为3
	self.depthType =  3
	self._footRootPos = {x=0,y=0}
	self.filterStyleInfo = {
		[Fight.filterStyle_fire] = 0,
		[Fight.filterStyle_ice] = 0,
	}

	self.damageResultInfo = {}

end




function ModelCreatureBasic:initView(...)
	ModelCreatureBasic.super.initView(self,...)

	self.myView:playLabel(self.data.sourceData[self.label])
	
	-- 创建血条
	local kind = 2  -- 1 主角 2 除了小怪和召唤物 3 小怪
	if self.data.isCharacter then
		kind = 1
	end

	local peopleType = self.data:peopleType()
	if peopleType == Fight.people_type_monster then
		kind = 3
	end
	self:createHealthBar(0,self.data.viewSize[2],self.controler.layer:getGameCtn(2),kind)
	return self
end


function ModelCreatureBasic:controlEvent()
	ModelCreatureBasic.super.controlEvent(self)	

	if self.data.updateFrame then
		self.data:updateFrame()
	end
end


function ModelCreatureBasic:realPos()
	ModelCreatureBasic.super.realPos(self)

	if  self.myView then
		if self.myState ~= "stand" then
			--需要计算scale
			self:countScale()
		end
		

		local isExist = self.myView:isBoneExist("foot")
		if isExist then
			self._footRootPos = self.myView:getBonePos("foot")
			self._footRootPos.x = self._footRootPos.x * Fight.wholeScale 
			self._footRootPos.y = self._footRootPos.y * Fight.wholeScale 
		end
	end
end


--重写setWay
function ModelCreatureBasic:setWay( way )
	self.way = way
	self:countScale()
end

--重新计算view的scale
function ModelCreatureBasic:countScale( )
	local ypos =self.pos.y 
	local scale = (ypos - Fight.initYpos_2)/ Fight.initScaleSlope + 1 
	self.myView:setScaleY(scale*self.viewScale * Fight.wholeScale)
	self.myView:setScaleX(self.controler._mirrorPos*self.way*self.viewScale * scale* Fight.wholeScale)

	--在initYpos2 上的scale是1   initYpos1上的是0.8
end

--检测攻击   
function ModelCreatureBasic:checkAttack(atkData,skill)
	if self.data:hp() <= 0 then
		return 
	end
	--如果攻击行为附带召唤
	if atkData:sta_summon() then
		echo("_____开始召唤-----------------------------",self.data.hid)
		self:doSummonAtkData(atkData)
	end
	-- 通过选择类型来选择人
	local chooseArr = AttackChooseType:atkChooseByType(self, atkData,nil,self.campArr,self.toArr,skill)


	if not chooseArr then
		-- echoWarn("在对方没有人的情况下 还检测攻击了----skillHid:",skill.hid,atkData.hid,self.logical.roundCount,#self.toArr)
		return
	end
	--如果需要创建missle的 
	-- local addMissle  = atkData:sta_addMissle()
	-- if addMissle then
	-- 	AttackUseType:createAttackMissle( addMissle, chooseArr,self,skill )
	-- end

	for i=1,#chooseArr do
		self:sureAttackObj(chooseArr[i],atkData,skill)
	end
end

--执行挨打函数
function ModelCreatureBasic:runBeHitedFunc(attacker,atkData,skill)

	if self.controler.__gameStep == Fight.gameStep.result then
		return
	end

	--因为现在可以鞭尸 所以需要取消这个判断
	-- if self.data:hp() <= 0 then
	-- 	return
	-- end

	self:checkDamageResult(attacker,atkData,skill)

	-- 根据attack计算效果
	AttackUseType:expand(attacker, self, atkData, skill)

	-- 震屏
	local sk = atkData:sta_shake()
	if sk then
		self:shake(sk[1],sk[2],sk[3])
	end
end

--初始化判定伤害结果
function ModelCreatureBasic:checkDamageResult(attacker,atkData,skill  )
	--根据伤害判定是否有过闪避暴击
	local hidKey = attacker.data.hid.. skill.hid
	if not self.damageResultInfo[hidKey] then
		local result = Formula:countDamageResult(attacker,self,skill)
		--如果没有伤害行为 那么不能被暴击
		if not atkData:sta_dmg() then
			result = Fight.damageResult_normal 
		end
		self.damageResultInfo[hidKey] = result
		if result == Fight.damageResult_gedang  or result == Fight.damageResult_baojigedang  then
			self:insterEffWord( {2,28,Fight.buffKind_hao  })
		end
		self.logical:doChanceFunc({camp = self.camp,attacker = attacker,chance = Fight.chance_defStart,defender = self})
	end
end

--获取伤害结果
function ModelCreatureBasic:getDamageResult( attacker,skill )
	local hidKey = attacker.data.hid.. skill.hid
	return self.damageResultInfo[hidKey]
end



--改变生命值
function ModelCreatureBasic:checkHealth()
	local curhp = self.data:hp()
	if curhp <= 0 then

		if not self.hasHealthDied then
			self.hasHealthDied = true
			self.controler:oneHeroeHealthDied(self)
			--如果是在空中的 那么不执行
			if self.myState == "jump" then
				return
			end
			self:initStand()
			self:justFrame(Fight.actions.action_die, nil, true)
		end

	end
end


--做召唤行为
function ModelCreatureBasic:doSummonAtkData( atkData )
	local summonInfo = atkData:sta_summon()
	for i,v in ipairs(summonInfo) do
		local pos = v.pos
		--必须判定对应位置上没人,而且没有将要复活的人
		local targetHero = self.logical:findHeroModel(self.camp,pos,true)
		if not targetHero then
			local id = v.id
			local enemyInfo  =  EnemyInfo.new(id)
			enemyInfo.attr.rid = enemyInfo.hid.."_".. pos.."_"..  self.controler.__currentWave
			enemyInfo.attr.posIndex = pos
			local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
			local hero = self.controler.reFreshControler:createHeroes(objHero,self.camp,pos,Fight.enterType_summon )
			--如果是有出场特效的
			if atkData:sta_aniArr() then
				hero:createEffGroup(atkData:sta_aniArr(),false)
			end

		end
	end
	--然后排序
	self.logical:sortCampPos(self.camp)

end

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--从数组移除的时候 做的事情
function ModelCreatureBasic:onRemoveCamp(  )
	--清除所有的负面buff
	self.data:clearBuffByKind(Fight.buffKind_huai )
	--隐藏buff特效
	self:showOrHideBuffAni(false)
	self:setFootLight(0)
end


--判断动作最后一帧死亡,彻底清除
function ModelCreatureBasic:alreadyDead(  )
	
	if self.healthBar then
		self.healthBar:setVisible(false)
	end
	self:startDoDiedFunc(Fight.diedType_alphades)
end


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-------------------- 创建buff部分    -----------------------------------------------
------------------------------------------------------------------------------------

--判断是否需要创建buff动画
function ModelCreatureBasic:checkCreateBuff( buffHid,attacker,skill )
	attacker = attacker or self
	skill = skill or attacker.currentSkill
	local buffObj = ObjectBuff.new(buffHid,skill)
    local kind = buffObj.kind
    local buffType = buffObj.type

    --如果血量为0了 那么不设置buff了
    if self.data:hp() <= 0 and buffType ~= Fight.buffType_relive  then
    	return 
    end
    --判断概率
    local random = BattleRandomControl.getOneRandomFromArea(0,10000)
    --如果 不在概率范围内 那么不命中这个buff
    if random > buffObj.ratio then
    	return
    end

    --如果是复活
   	if buffObj.type == Fight.buffType_relive  then
   		echo(self.reliveState,"____复活state_")
   		--如果已经复活过了 那么不不执行
   		if self.reliveState ~= 0 then
   			return
   		end
   	end

	--无敌时 的负面buff 不能给加
	if self.data:checkHasOneBuffType( Fight.buffType_wudi ) then
		if kind == Fight.buffKind_huai then
			return 
		end
	end

	--buffObj 特效数组
	local buffAniArr

	local enterAniArr
	--如果有出场的
	if buffObj:sta_enterAni() then
		enterAniArr = self:createEffGroup(buffObj:sta_enterAni(), false,true)
	end

	if buffObj:sta_aniArr() then

		buffAniArr = self:createEffGroup(buffObj:sta_aniArr(), true,true)
		buffObj.aniArr = buffAniArr
		--如果有出场动画的 先隐藏掉循环动画
		if enterAniArr then

			for i,v in ipairs(buffAniArr) do
				v:stopFrame()
				v.myView.currentAni:visible(false)
			end

			local tempFunc = function (  )
				if buffObj.aniArr then
					for i,v in ipairs(buffObj.aniArr) do
						v:playFrame()
						v.myView.currentAni:visible(true)
					end
				end
			end

			enterAniArr[1]:setCallFunc(tempFunc)
		end
	end
	--记录buff的释放着 是攻击方
	buffObj.hero = attacker
	--buff的作用着  是自己
	buffObj.useHero = self

	local time = buffObj:sta_time() or  0

	--如果是复活技能 而且是清掉buff的
	if buffObj.type ==Fight.buffType_relive  then
		if buffObj.expandParams[5] == 0 then
			--清除所有buff
			self.data:clearBuffByKind(Fight.buffKind_hao )
			self.data:clearBuffByKind(Fight.buffKind_huai )
			echo("_清除所有buff")
		end
		--标记为复活状态 在回合前判定
		self.reliveState = 1
	end
	self.data:setBuff(buffObj)
	

end


--判断是否将要被复活
function ModelCreatureBasic:checkWillBeRelive(  )
	return self.reliveState == 1
end



--一个buff消失, 这儿一定会传送一个buffObj过来
function ModelCreatureBasic:oneBuffClear( buffType,buffObj )  
end





--帧事件-----

--击飞相关-----------------------
--击飞相关-----------------------
--击飞相关-----------------------

--击飞开始之后 进入击飞循环 如果没有跳跃 那么直接进入击飞起身
function ModelCreatureBasic:enterBlowMiddle(  )
	--如果是跳跃状态 才进入击飞循环
	if self.myState  == "jump" then
		self:stopFrame()
	else
		self:justFrame(Fight.actions.action_stand )
		self:onBlowUp()
	end
end

--落地以后做的事情
function ModelCreatureBasic:checkLandStopMove(  )
	if self.label ==Fight.actions.action_blow1 then
		self:justFrame(Fight.actions.action_blow3,nil,true)
	else
		self:justFrame(Fight.actions.action_stand )
	end
	self:initStand()
end

--击飞落地
function ModelCreatureBasic:onBlowUp(  )
	if self.data:hp()> 0 then
		self:movetoInitPos(2)
	else
		--那么执行死亡事件 停止动画
		--判断是否从队列里面移除了 同时判断是否是复活状态
		--必须不是复活状态
		if self.reliveState ~= 1 then
			if not table.indexof(self.campArr, self) then
				self:alreadyDead()
			end
		end
		self:stopFrame()
	end
end


--身上的滤镜效果样式相关
function ModelCreatureBasic:changeFilterStyleNums( style,value )
	self.filterStyleInfo[style] =  self.filterStyleInfo[style] + value
	if self.filterStyleInfo[style] < 0 then
		echoWarn("不应该存在小于0的样式:",style,value,"hid:",self.data.hid)
		self.filterStyleInfo[style] = 0
	end
	-- echo(style,value,"_________冰冻效果----------")
	self:checkUseFilterStyle()
	
end

--判断滤镜效果
function ModelCreatureBasic:checkUseFilterStyle(  )
	if Fight.isDummy then
		return
	end
	local styleMapFilterParams = {
		[Fight.filterStyle_fire] = FilterTools.colorMatrix_fire,
		[Fight.filterStyle_ice] = FilterTools.colorMatrix_ice,
	}

	local paramsArr = {}
	--开始使用滤镜
	for i,v in pairs(self.filterStyleInfo) do
		if v > 0  then
			table.insert(paramsArr, styleMapFilterParams[i])
		end
	end

	--如果没有滤镜效果
	if #paramsArr ==0 then
		--恢复动画播放
		self:playFrame()
		FilterTools.clearFilter(self.myView,10)
	else
		--这里需要判断优先级
		--判断顺序冰火毒
		if self.filterStyleInfo[Fight.filterStyle_ice] > 0 then
			FilterTools.setViewFilter(self.myView,FilterTools.colorMatrix_ice,10)
			--必须是站立状态 才 停帧 因为可能这个时候被击飞了
			if self.myState == "stand" then
				if self.pos.x == self._initPos.x then
					self:stopFrame()
				else
					echo("__不再初始位置 不能冰冻")
				end
				
			end
		elseif self.filterStyleInfo[Fight.filterStyle_fire] > 0 then
			FilterTools.setViewFilter(self.myView,FilterTools.filterStyle_fire,10)
		end
	end
end        

--判断是否有滤镜样式
function ModelCreatureBasic:checkHasFilterStyle( style )
	for k,v in pairs(self.filterStyleInfo) do
		if not style then
			if v > 0 then
				return true
			end
		else
			if v> 0 and k == style then
				return true
			end
		end
		
	end
	return false
end


--判断对方是否没人了
function ModelCreatureBasic:checkIsNoPerson(  )
	return #self.toArr == 0 and #self.toDiedArr == 0
end

--判断脚下光环
--lightType 0表示取消脚下光环 1是 小技能光环 2 是boss光环
function ModelCreatureBasic:setFootLight( lightType )
	if Fight.isDummy then
		return
	end

	if lightType == 0 then
		if self.ani_lightSkill1 then
			self.ani_lightSkill1:setVisible(false)
		end
		if self.ani_lightSkill2 then
			self.ani_lightSkill2:setVisible(false)
		end
		--满怒气大招
		if self.ani_lightSkill22 then
			self.ani_lightSkill22:setVisible(false)
		end


	--如果是小技能
	elseif lightType == 1 then
		if self.ani_lightSkill2 then
			self.ani_lightSkill2:setVisible(false)
		end

		if self.ani_lightSkill22 then
			self.ani_lightSkill22:setVisible(false)
		end

		-- if  not self.ani_lightSkill1 then
		-- 	self.ani_lightSkill1 = self:createEff("UI_zhandou_xuanzhonga", 0, 0, -1, 1, nil, true, true,nil,true)
		-- end


		-- self.ani_lightSkill1:setVisible(true)
	--如果是大招技能
	elseif lightType == 2 then
		if self.ani_lightSkill1 then
			self.ani_lightSkill1:setVisible(false)
		end
		if  not self.ani_lightSkill2 then
			self.ani_lightSkill2 = self:createEff("eff_jinengtishi_dajineng", 0, 0, -1, 1, nil, true, true,nil,true)
		end
		self.ani_lightSkill2:setVisible(true)

		-- if  not self.ani_lightSkill22 then
		-- 	self.ani_lightSkill22 = self:createEff("UI_zhandou_mannvqi", 0, 50, 1, 1, nil, true, true,nil,true)
		-- end
		-- self.ani_lightSkill22:setVisible(true)
	end

end

function ModelCreatureBasic:checkFootLight(  )
	local lightType
	if self.data:energy() >= self.data:maxenergy() and self.data:hasMaxSkill() then
		lightType = 2
	elseif self.nextSkillIndex == 2 then
		lightType = 0
	else
		lightType = 0
	end
	self:setFootLight(lightType)
end


--当技能黑屏的时候 需要同步zorder显示
function ModelCreatureBasic:onSkillBlack(zorder  )
	zorder = zorder or Fight.zorder_blackChar
	self.myView:zorder(self.__zorder + zorder)
	self.healthBar:zorder(self.__zorder + zorder)
end


--显示或者隐藏buffaini
function ModelCreatureBasic:showOrHideBuffAni( value )
	--如果是buff的
	if value then
		for k,v in pairs(self.data.buffInfo) do
			self.data:useLastBuffAni(k)
		end
	else
		for k,v in pairs(self.data.buffInfo) do
			self.data:hideOneBuffAni(k)
		end
	end

end

--让与我相关的特效 都变暗或者恢复
function ModelCreatureBasic:tinyToColor( time,color )
	if Fight.isDummy  then
		return
	end
	self.myView.currentAni:stopAllActions()
	self.myView.currentAni:tintTo(time, color,color,color)
	self.healthBar:stopAllActions()
	-- self.healthBar:tintTo(time, color,color,color)
	-- self.healthBar:fadeTo(time, color)
	local mul = color/255
	if mul == 1 then
		FilterTools.clearFilter(self.healthBar._rootNode)
	else
		FilterTools.setColorTransForm(self.healthBar._rootNode,mul,mul,mul,1,0,0,0,0)
	end
	

	if self.ani_lightSkill1 then
		-- self.ani_lightSkill1.myView.currentAni:stopAllActions()
		-- self.ani_lightSkill1.myView.currentAni:tintTo(time, color,color,color)
		FilterTools.setColorTransForm(self.ani_lightSkill1.myView.currentAni,mul,mul,mul,1,0,0,0,0)
	end
	if self.ani_lightSkill2 then
		-- self.ani_lightSkill2.myView.currentAni:stopAllActions()
		-- self.ani_lightSkill2.myView.currentAni:tintTo(time, color,color,color)
		FilterTools.setColorTransForm(self.ani_lightSkill2.myView.currentAni,mul,mul,mul,1,0,0,0,0)
	end
	if self.ani_lightSkill22 then
		-- self.ani_lightSkill22.myView.currentAni:stopAllActions()
		-- self.ani_lightSkill22.myView.currentAni:tintTo(time, color,color,color)
		FilterTools.setColorTransForm(self.ani_lightSkill22.myView.currentAni,mul,mul,mul,1,0,0,0,0)
	end

	for k,v in pairs(self.data.buffInfo) do
		for ii,vv in ipairs(v) do
			if vv.aniArr then
				for iii,vvv in ipairs(vv.aniArr) do
					FilterTools.setColorTransForm(vvv.myView.currentAni,mul,mul,mul,1,0,0,0,0)
				end
			end
		end
	end

end



-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- --一些set方法-------------------------------------------------------------

-- 法宝的model
function ModelCreatureBasic:setActionExTarget(target)
	-- 如果原先有一个法宝
    if self.actionExTarget then
        self.actionExTarget:deleteMe()
    end
    self.actionExTarget = target
end

return ModelCreatureBasic





