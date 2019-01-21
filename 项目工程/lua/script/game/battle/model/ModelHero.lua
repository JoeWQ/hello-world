--
-- Author: XD
-- Date: 2014-07-10 12:03:53
--主要处理一些特殊功能 表现相关
--
local Fight = Fight
local FuncDataSetting  = FuncDataSetting
ModelHero = class("ModelHero", ModelAutoFight)

ModelHero._reFreshPos = nil -- 如果是怪物，需要记住怪物的刷新点
ModelHero._fightState = nil -- 战斗方式

ModelHero._onlineState = Fight.state_show_zhengchang -- 正常在线

--是否回合钱准备好了
ModelHero.isRoundReady = true
 
ModelHero.transbodyInfo = nil 		--将要变身的hid 针对boss


ModelHero.hasKillEnemy = false 		--是否杀人了


--
ModelHero.effectWordInfo = nil 		--飘字管理
ModelHero.effectWordLeftFrame = -1

function ModelHero:ctor( controler,obj )
    self.modelType = Fight.modelType_heroes
	ModelHero.super.ctor(self,controler,obj)

    self._hasArriveReadyPos = false

    self._interTreasure = "bzd" 
    self._reFreshPos = 0
    self._fightState = Fight.fightState_handle 
    self.usedTreasures = {}
    self.showTreasures = {}

    --回合开始   法宝如果存在就消失
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR, self.endFadeInTrea, self)

    self.effectWordInfo = {}
    self.effectWordLeftFrame = -1

end

--判断是否是主要的英雄 如果是我方 那么应该是主角  如果是地方 那么应该是 敌人的boss
function ModelHero:checkIsMainHero(  )
	if self.camp == 1 then
		if self.data.rid == self.controler.userRid then
			return true
		end
	else
		if self.data.rid ==self.controler.enemyRid then
			return true
		end
	end
	return false
end


--初始化完毕
function ModelHero:onInitComplete( )

	if not Fight.isDummy then
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
	end
	--注册点击事件
	if self.camp == 1 then
		self:setClickFunc()
	elseif self.camp == 2 then
		self:checkCreateHeadBuff()
		self:setClickFunc()
	end
	
end

--判断头上顶特殊buff
function ModelHero:checkCreateHeadBuff(  )
	if Fight.isDummy  then
		return
	end
	local beKillInfo = self.data:beKill()
	if not beKillInfo then
		return
	end

	local iconType = beKillInfo[3]
	local aniName = "UI_zhandou_buff"
	if iconType == "1" then
		--todo
	end
	self._headBuffEff = self:createEff(aniName, 0, 100, 1, 1, true, true, true)
	self._headBuffEff.pianyiPos.z = -self.data.viewSize[2]+ self.data:hang() - 50
end

--当被杀死的时候
function ModelHero:beKilled( attacker )
	local beKillInfo = self.data:beKill()
	if not beKillInfo then
		return
	end



	if not attacker then
		if not self._headBuffEff then
			return
		end
		self._headBuffEff:deleteMe()
		self._headBuffEff = nil
	else
		--如果是做攻击包
		self:doBeKillEnemyBuff(beKillInfo,attacker)
		
	end
end


function ModelHero:doBeKillEnemyBuff( beKillInfo,attacker )
	if not beKillInfo then
		return
	end
	--如果是做攻击包
	if beKillInfo[1] == "1" then
		local atkData = ObjectAttack.new(beKillInfo[2])
		attacker:checkAttack(atkData,attacker.data.curTreasure.skill1)
	end

	if not self._headBuffEff then
		return
	end

	local target = attacker
	local fromPos = {x = self.pos.x, y = self.pos.y}	
	--如果不是我自己吃的buff
	if attacker ~= self then
		local modelEnergy = ModelEffectEnergy.new(self.controler)
		modelEnergy:setTarget(target,fromPos)
		self.controler:insertOneObject(modelEnergy)
	end
	

	local dx = attacker.pos.x - self.pos.x
	local dy = attacker.pos.y - self.pos.y 
	-- self._headBuffEff:setFollow(false)

	local actDelay = act.delaytime(1.5)
	local act1 = act.moveto(0.2, dx, -dy-self.data.viewSize[2]/2)
	local act2 = act.fadeto(0.2,0)
	local actque = act.sequence(actDelay,act1,act2)
	self._headBuffEff.myView.currentAni:runAction(actque)
	self._headBuffEff:pushOneCallFunc(50, "startDoDiedFunc")
	self._headBuffEff = nil

end


--[[
回合开始前
]]
function ModelHero:doRoundFirst(  )
	ModelHero.super.doRoundFirst(self)

	self:checkAttackView()
	self:checkCanOffSideAttack()
	self:checkMainHeroEnergyFull()
	--self:showAttackNum()
end



--[[
回合结束
]]
function ModelHero:doRoundEnd(  )
	ModelHero.super.doRoundEnd(self)
	self:hideCanAttack()
end




--[[
检查是否可攻击
在身上显示两把剑
]]
function ModelHero:checkAttackView( ... )
    local canAttack = true
    if self.controler.logical.currentCamp ~= 1 then
        canAttack = false
    end

     if self.controler.logical.autoFight then
     	canAttack = false
     end

    --当前在回合中  这里有问题
 --    if not self.controler.logical.isInRound then
 --    	echo("222222")
	-- 	canAttack = false
	-- end
	--只有pvek可以操作
	if self.controler.gameMode ~=Fight.gameMode_pve then
		canAttack = false
	end
    
    if not self.data:checkCanAttack() then
        canAttack = false
    end
    if self.data:hp()<=0 then
        canAttack = false
    end

    --如果已经 攻击了
    if self.controler.logical:checkRoundHasAttack(self.camp,self.data.posIndex) then
        canAttack = false
    end

    if canAttack then
    	--传入view的宽度和高度
    	self.healthBar:showCanAttack(self.data.viewSize[1],(self.data.viewSize[2]+self.data:hang() ) * Fight.wholeScale)
    else
    	self.healthBar:hideCanAttack()
    end
end

--[[
隐藏剑
]]
function ModelHero:hideCanAttack(  )
	if self.healthBar then
		self.healthBar:hideCanAttack()
	end
end


--[[
判断是否可以越位攻击
如果可以越位攻击 则显示 头像 头像  
]]
function ModelHero:checkCanOffSideAttack(  )
	if self.controler.logical.autoFight then
		return
	end
	if self.camp == 2 then
		return
	end

	local targetHero,isHouPai = AttackChooseType:getSkillFirstAtkEnemy(self,self:getNextSkill())
	if targetHero ~= nil and isHouPai then
		--echo("能够攻打后排")
		--echo( targetHero.data:icon(),"========能攻打到的icon是",targetHero.data.hid )
		self.healthBar:showCanOffSideAttack(FuncRes.iconHero(targetHero.data:icon()),self.data.viewSize[1],(self.data.viewSize[2]+self.data:hang() ) * Fight.wholeScale )
	end
end

function ModelHero:hideOffSideAttack(  )
	self.healthBar:hidCanOffSideAttack()
end


--[[
判断是否是主句，如果是主角，则检查是否怒气满，如果怒气满
则挂 法宝
]]
function ModelHero:checkMainHeroEnergyFull(  )

	if self.camp == 2 then
		return
	end
	if self:checkIsMainHero() then
		--每次都让怒气满
		--self.data:changeValue(Fight.value_energy ,self.data:maxenergy())
		if self.data:energy() == self.data:maxenergy() then
			local leftTreaIcon
			local rightTreaicon
			local index = 0
			--treasure可以展示
			local treas = self.data.treasures
			for k,v in ipairs(treas) do
				if v.treaType ~= "base" then
					index = index+1
					if v then
						local icon = FuncRes.iconEnemyTreasure(v:sta_icon())
						if index +1 == 2 then
							leftTreaIcon = icon
						end
						if index + 1 == 3 then
							rightTreaicon = icon
						end
					end
				end
			end
			--data.gridPos.x
			self.healthBar:showTrea(c_func(self.doTreaClick,self),self.data.gridPos.y,leftTreaIcon,rightTreaicon,self.data.viewSize[1],(self.data.viewSize[2]+self.data:hang() ) * Fight.wholeScale)
		end
	end
end


--[[
点击法宝的回调方法
]]
function ModelHero:doTreaClick( index )
	--echo("点击法宝",index,"====================")
	self.controler.logical:insterOneHandle(1,self.data.posIndex,Fight.operationType_giveTreasure,index)
end





function ModelHero:hideMainHeroTreas(  )
	if self.healthBar then
		self.healthBar:hideTrea()
	end
end


--[[
点击hero显示 攻击次序
]]
function ModelHero:showAttackNum(num)
	--echo("aaaaaaaaaaaaaaaaa")
	local canAttack = true
    if self.controler.logical.currentCamp ~= 1 then
        canAttack = false
    end
    -- if self.controler.logical.autoFight then
    -- 	canAttack = false
    -- end

 --    --当前在回合中  这里有问题
 -- --    if not self.controler.logical.isInRound then
 -- --    	echo("222222")
	-- -- 	canAttack = false
	-- -- end
	-- --只有pvek可以操作
	-- if self.controler.gameMode ~=Fight.gameMode_pve then
	-- 	canAttack = false
	-- end
    
 --    if not self.data:checkCanAttack() then
 --        canAttack = false
 --    end
 --    if self.data:hp()<=0 then
 --        canAttack = false
 --    end

    --如果已经 攻击了
    -- if self.controler.logical:checkRoundHasAttack(self.camp,self.data.posIndex) then
    --     canAttack = false
    --     echo("55555555555555555555")
    -- end


    if canAttack then
		--local num = self.controler.logical:getHeroHandleIndex(self)
		--echo("num",num,"=-==============")
		if num>=2 and num<=6 then
			self.healthBar:showAttackNum(num,self.data.viewSize[1],(self.data.viewSize[2]+self.data:hang() ) * Fight.wholeScale)
		end
	end
end







--[[
隐藏操作数字
]]
function ModelHero:hideAttackNum(  )
	--echo("攻击发生了。隐藏掉 数字")
	self.healthBar:hideAttackNum()
end




--给场上英雄注册点击事件 点击后显示 明按
function ModelHero:setClickFunc(  )

	if Fight.isDummy then
		return
	end
	--如果是敌方的 不给点击事件
	-- if self.camp == 2 then
	-- 	return
	-- end

	local nd = display.newNode()
	local viewSize 
	local figure = self.data:figure()
	local wid = math.ceil(figure/2)
	local hei = figure >1 and 2 or 1
	wid = wid *Fight.position_xdistance
	hei = 110 * hei + 80

	nd:setContentSize(cc.size(wid,hei) )
	nd:addto(self.healthBar)
	--nd:pos()
	--注册点全部放到脚下
	nd:anchor(0,0)
	nd:pos(-wid* 0.5,-hei * 0.1 - 80 - (self.data.viewSize[2]+self.data:hang()*Fight.wholeScale ) )

	nd:setTouchedFunc(c_func(self.pressClickView,self), nil, true, c_func(self.pressClickViewDown, self), c_func(self.pressClickViewMove, self),false,c_func(self.pressClickViewUp, self) )
	
end

--点击英雄人物 应该发起攻击
function ModelHero:pressClickView(  )
	if self.camp == 2 then
		--点击的是地方   选择我方人员

		return
	end
	if not self.controler:checkCanHandle() then
		return
	end

	if self.logical.currentCamp ~= self.camp then
		return
	end

	if not self.data:checkCanAttack() then
        return
    end
    if self.data:hp()<=0 then
        return 
    end

    --如果已经 攻击了
    if self.controler.logical:checkRoundHasAttack(self.camp,self.data.posIndex) then
        return 
    end

    --如果是主角
    if self:checkIsMainHero() then
    	--如果是能力满的
    	if self.data:energy() >= self.data:maxenergy() then
    		self.controler.logical:insterOneHandle(1,self.data.posIndex,Fight.operationType_giveTreasure,1)
    	else
    		
    		self.controler.logical:insterOneHandle(1,self.data.posIndex,Fight.operationType_giveSkill)
    		--self:showAttackNum()
    	end

    else
    	
    	self.controler.logical:insterOneHandle(1,self.data.posIndex,Fight.operationType_giveSkill)
    	--self:showAttackNum()
    end

end



function ModelHero:pressClickViewDown(  )
	--必须是站立状态
	if self.myState ~= "stand" then
		return
	end

	if not self.logical.isInRound then
		return
	end

	if self.logical:checkRoundHasAttack(self.camp, self.data.posIndex) then
		return
	end
	--必须是我方阵营回合才行
	-- if self.logical.currentCamp ~= self.camp then
	-- 	return
	-- end

	--如果攻击数量大于0 表示在回合中了 那么也是不能点的
	-- if self.logical.attackNums > 0 then
	-- 	return 
	-- end

	if self.logical.isAttacking	then
		return
	end 

	--如果不是在初始位置 也不能
	if self.pos.x ~= self._initPos.x then
		return
	end
	--必须是 战斗阶段才行
	if self.controler.__gameStep ~= Fight.gameStep.battle then
		return
	end

	if self.camp == 2 then
		--echo("点击敌方人员---------")
		self.logical:findCanBeAttackedHero(self)
		return
	end

	if self:checkIsMainHero() then

		local treasureIndex = self.data.curTreasureIndex
		--echo("treasureIndex",treasureIndex,"=============================")
		--如果能量满了
		if self.data:energy() >= self.data:maxenergy() then
			--这个时候要循环播放左侧法宝和右侧法宝亮
			self:beginFadeInTrea()
		else
			--能量没有满
			local treasureObj = self.data.treasures[treasureIndex+1]
			local skill = treasureObj.onSkill or treasureObj.skill1
			self.logical:checkRelation(self,skill,true)
		end
	else
		self:pressHeroDown()
	end

end


--[[
显示我方人物  在头像显示     手指特效
]]
function ModelHero:showJiHuoHand(  )
	-- body
	self:hideAllFlags()
	self.healthBar:showJiHuoHandAni(self.data.viewSize[1],(self.data.viewSize[2]+self.data:hang())*Fight.wholeScale)
end


function ModelHero:hideJiHuoHand(  )
	self.healthBar:hideJiHuoHandAni()
end


--[[
选择我方人物，在头像上显示   无法攻打此敌
]]
function ModelHero:showCannotJiHuo(  )
	self:hideAllFlags()
	self.healthBar:showCannotJiHuo(self.data.viewSize[1],(self.data.viewSize[2]+self.data:hang())*Fight.wholeScale)
end

--[[
隐藏攻打此敌 选择我方人物，在头像上显
]]
function ModelHero:hideCannotJiHuo(  )
	self.healthBar:hideCannotJiHuo()
end

--[[
不能攻打此敌
]]
function ModelHero:showCannotGongji(  )
	self:hideAllFlags()
	self.healthBar:showCannotGongji( self.data.viewSize[1],(self.data.viewSize[2]+self.data:hang())*Fight.wholeScale )
end


function ModelHero:hideCannotGongji(  )
	self.healthBar:hideCannotGongji()
end


--[[
隐藏所有标示
]]
function ModelHero:hideAllFlags(  )
	for k,v in pairs(self.controler.campArr_1) do
		v:hideJiHuoHand()
		v:hideCannotGongji()
		v:hideCannotJiHuo()
	end

	for k,v in pairs(self.controler.campArr_2) do
		v:hideJiHuoHand()
		v:hideCannotGongji()
		v:hideCannotJiHuo()
	end
end



--[[
开始渐显法宝
]]
function ModelHero:beginFadeInTrea(  )
	--echo("开始显示法宝----------")
	self.fadeInShowing = true
	self:changeFadeInTrea()
end

--[[
切换法宝显示
]]
function ModelHero:changeFadeInTrea(  )
	if self.fadeInShowing then
		local treasureIndex = 1
		if self.fadeInTrea and self.fadeInTrea.index then
			treasureIndex = self.fadeInTrea.index
			if treasureIndex == 1 then treasureIndex = 2 else treasureIndex = 1 end
		end
		local treasure = self.data.treasures[treasureIndex+1]
		if self.fadeInTrea then
			self.fadeInTrea:clear()
			self.fadeInTrea = nil
		end
		--显示对应法宝的 攻击对象
		local skill = treasure.onSkill or treasure.skill1
		self.logical:checkRelation(self,skill,true)
		
		local icon = FuncRes.iconEnemyTreasure(treasure:sta_icon())
		self.fadeInTrea = display.newSprite(icon):addto(self.healthBar):pos(0,0)
		self.fadeInTrea:scale(0.3):opacity(0)
		--local _zorder = self.healthBar:zorder()
		--self.fadeInTrea:zorder(200)
		self.fadeInTrea.index = treasureIndex
		self.fadeInTrea:runAction(
		cc.Sequence:create(
				cc.FadeIn:create(0.3),
				cc.DelayTime:create(2.4),
				cc.FadeOut:create(0.3)
			)
		)
		self.fadeInTrea:delayCall(c_func(self.changeFadeInTrea,self),3)
	else
		if self.fadeInTrea then
			self.fadeInTrea:clear()
			self.fadeInTrea = nil
		end
	end
end


--[[
结束渐显法宝
]]
function ModelHero:endFadeInTrea(  )
	self.fadeInShowing = false
	if self.fadeInTrea then
		self.fadeInTrea:stopAllActions()
		self.fadeInTrea:runAction(
			cc.FadeIn:create(0.3)
			)
		self.fadeInTrea:delayCall(c_func(self.changeFadeInTrea,self,0.3))
	end
end


--普通英雄点击
function ModelHero:pressHeroDown( )
	--获取下一个技能
	local skill = self:getNextSkill()
	--显示明暗
	self.logical:checkRelation(self,skill,true)

end

--主角点击
function ModelHero:pressCharDown(  )
	-- body
end


function ModelHero:pressClickViewMove(  )
	if self.logical.attackNums > 0 then
		return
	end
end


function ModelHero:pressClickViewUp(  )
	-- if self.logical.attackNums > 0 then
	-- 	return
	-- end
	if not self.logical.isInRound then
		return
	end

	if self.logical:checkRoundHasAttack(self.camp, self.data.posIndex) then
		return
	end
	
	if self.logical.isAttacking then
		return
	end
	--必须是 战斗阶段才行
	if self.controler.__gameStep ~= Fight.gameStep.battle then
		return
	end

	self.logical:resumeViewAlpha()
	if not self.logical.attackSign then
		self.controler.gameUi:setAttackSign(nil)
	end
	self:endFadeInTrea()
end

--设置是否回合准备好了
function ModelHero:setRoundReady( value )
	local oldReady = self.isRoundReady
	self.isRoundReady = value
	--如果是设置准备好  而且 自身是能操作的
	if value == true and self.data:checkCanGiveSkill() then
		self:justFrame(Fight.actions.action_standSkillStart)
	end


	if value and not oldReady then
		--通知逻辑控制器 ready完毕
		echo("___通知控制器ready完毕")
		self.logical:oneHeroReady()
	end
end

--召唤行为技能
function ModelHero:setSummonAction( skill )
	self.summonSkill = skill
end

--回合初变身 针对boss
function ModelHero:setTransbodyTreasureInfo( info )
	self.transbodyInfo = info
end


function ModelHero:controlEvent()
	ModelHero.super.controlEvent(self)
	self:updateEffectWord()
	


end

--更新头顶飘字动画
function ModelHero:updateEffectWord(  )
	if Fight.isDummy  then
		return
	end
	if self.effectWordLeftFrame > 0 then
		self.effectWordLeftFrame = self.effectWordLeftFrame- 1
		if self.effectWordLeftFrame == 0 then
			self:checkPlayEffWord()
		end
	end

	local length = #self.effectWordInfo
	if length > 0 then
		for i=length,1 ,-1 do
			local info = self.effectWordInfo[i]
			if info.left > 0 then
				info.left = info.left - 1
				if info.left == 0  then
					table.remove(self.effectWordInfo,i)
				end
			end
		end
	end

end


--做退场行为 
function ModelHero:doExitGameAction(  )
	--默认 直接原地死亡
	echo("____输了应该退场了")
	--清除所有buff
	self.data:clearAllBuff()
	--暂时直接stand
	self:justFrame(Fight.actions.action_stand)
end


--插入一个飘字文字
function ModelHero:insterEffWord( params,isDelay )
	if Fight.isDummy  then
		return
	end

	if not  isDelay then
		--如果是杀人了 那么需要延时几帧
		if self.hasKillEnemy then
			self:pushOneCallFunc(Fight.killEnemyFrame, "insterEffWord", {params,true})
			return
		end
	end
	--插入到头上去
	table.insert(self.effectWordInfo,1,{p = params,left = 30,isPlay =false})
	if self.effectWordLeftFrame <= 0 then
		self:checkPlayEffWord()
	end
	
end



--判断是否出特效
function ModelHero:checkPlayEffWord(  )
	if #self.effectWordInfo == 0 then
		return
	end
	--倒着遍历
	local length = #self.effectWordInfo
	for i=length,1,-1 do
		local v = self.effectWordInfo[i]
		if not v.isPlay then
			v.isPlay = true
			local info = v.p
			--如果是创建头顶特效的
			if info[1] == 1 then
				 v.eff = ModelEffectBasic:createCommonHeadEff( info[2],self )
			elseif info[1]==2 then
				 v.eff =ModelEffectBasic:createBuffWordEff( info[2],info[3] ,self)
			end
			self.effectWordLeftFrame = 5

			--如果插入了一条 那么 先头的特效得依次网上偏移
			for ii=i+1,length do
				local vv = self.effectWordInfo[ii]
				if vv.eff then
					--让子特效依次位移上去
					vv.eff.myView.currentAni:pos(0,(ii-i) * 25)
				end
			end

			break
		end
	end
end


