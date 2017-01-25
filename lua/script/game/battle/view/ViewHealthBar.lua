--
-- Author: Your Name
-- Date: 2014-12-23 10:47:45
--
ViewHealthBar = class("ViewHealthBar", function ( )
	return display.newNode()
end)
ViewHealthBar._initHealth =0
ViewHealthBar.data =nil
--剩余显示血条时间 每帧刷新 
ViewHealthBar._leftShowTime = 0

--主角头上角标显示事件
local charCueTime = 999
local charNameTime = 4 	--角色名显示时间

--血条持续时间
local barLastTime = 2*GAMEFRAMERATE  		

--血条的rootNode
ViewHealthBar._rootNode = nil   --rootNode是会所有的东西一起变暗的
ViewHealthBar._lightNode = nil --lightNode 是不需要变暗的



--血条有自己的逻辑  如果在一定时间内没有挨打 那么隐藏血条
function ViewHealthBar:ctor(info,health)


	self.allBlood=health
	self.blood=health
	self.data = info
	self._rootNode = display.newNode():addTo(self)
	self._lightNode = display.newNode():addTo(self)
	--self:visible(false)
end

--设置目标  barType  1是主角自己  2是敌方boss或者敌方玩家  3是小怪
function ViewHealthBar:setTarget( heroes,barType )

	self.barType = barType or 1

	self.target = heroes

	local viewName  = "panel_bar1"
	

	local barView = UIBaseDef:createPublicComponent( "UI_battle_public",viewName )

	if heroes.camp ==1 then
		barView.panel_1.mc_progress:showFrame(1)

	else
		--如果是敌人小怪
		-- if barType == 3 then
		-- 	viewName = "panel_bar3"
		-- else
		-- 	viewName = "panel_bar2"
		-- end
		barView.panel_1.mc_progress:showFrame(2)
	end


	self._barView = barView
	barView:addto(self._rootNode):pos(0,0)

	self._barView.panel_1:visible(false)

	local camp = heroes.camp
	if barView.mc_chatBall then
		barView.mc_chatBall:showFrame(camp)
		barView.mc_chatBall.currentView:visible(false)
	end
	
	--隐藏某个view
	local hideView = function ( view ,adjustPos)
		view:visible(false)
		if view.pause then
			view:pause()
		end
		if adjustPos then
			-- self._barView:pos(0,0)
		end

	end

	local name 
	if not heroes.data.name then
		name = "no name"
	else
		name = heroes.data:name()
	end
	if name =="" then
		name = GameConfig.getLanguage("tid_common_2006")
	end

	--如果是主角
	if self.barType == 1 then
		--创建 提示动画
		-- local ani = FuncArmature.createArmature("UI_battle_jiantou", self._barView.ctn_1, true)
		-- self._barView:delayCall(c_func(hideView,ani,true), charCueTime)
		-- self._barView:pos(0,45)
	end
	--一会延迟隐藏名称
	local peopleType = self.target.data:peopleType()
	if peopleType ~= Fight.people_type_monster then
		self._barView:delayCall(c_func(hideView,self._barView.txt_name), charNameTime)
		self._barView.txt_name:setString(name)
	else
		self._barView.txt_name:visible(false)
	end
	self._barView.txt_name:visible(false)
	
	self._initTxtPos ={}
	self._initTxtPos.x,self._initTxtPos.y = self._barView.txt_name:getPosition()
	self._barView.txt_name:pos(self._initTxtPos.x,self._initTxtPos.y-20)

	if Fight.cameraWay  == -1 then
		if self.target.camp == 1 then
			self._barView.panel_1.mc_progress.currentView.progress_1:setDirection(ProgressBar.r_l)
			self._barView.panel_1.mc_progress.currentView.progress_2:setDirection(ProgressBar.r_l)
			self._barView.panel_1.mc_progress.currentView.progress_3:setDirection(ProgressBar.r_l)
			self._barView.panel_1.mc_progress.currentView.progress_4:setDirection(ProgressBar.r_l)
			self._barView.panel_1.mc_progress.currentView.progress_3:setDirection(ProgressBar.l_r)
			self._barView.panel_1.mc_progress.currentView.progress_4:setDirection(ProgressBar.l_r)
		else
			self._barView.panel_1.mc_progress.currentView.progress_1:setDirection(ProgressBar.r_l)
			self._barView.panel_1.mc_progress.currentView.progress_2:setDirection(ProgressBar.r_l)
			-- self._barView.panel_1.progress_3:setDirection(ProgressBar.r_l)
			-- self._barView.panel_1.progress_4:setDirection(ProgressBar.r_l)
		end
		

	end

	self.target.data:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH , self.pressHealthChange ,self)
	if self.target.data:hasMaxSkill() then
		self.target.data:addEventListener(BattleEvent.BATTLEEVENT_CHANGEENEGRY , self.pressEnergyChange ,self)
		self:pressEnergyChange()
	else
		--取消缓动
		if self.target.camp == 1 then
			self._barView.panel_1.mc_progress.currentView.progress_3:setPercent(0)
			self._barView.panel_1.mc_progress.currentView.progress_4:setPercent(0)
		else
			self._barView.panel_1.mc_progress.currentView.progress_2:setPercent(0)
		end
	end
	
	self.target.data:addEventListener(BattleEvent.BATTLEEVENT_PLAYER_STATE , self.pressUserStateChange ,self)
	self.target.data:addEventListener(BattleEvent.BATTLEEVENT_TOPTALK , self.pressTopTalk ,self)


	self:pressHealthChange(nil)

	

	--FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SHOWNAME,c_func(self.pressShowName,self))
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SHOWNAME,self.pressShowName,self)
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,self.pressShowHP,self)
	
	self.target.data:addEventListener(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR , self.pressShowHP ,self)
end

function ViewHealthBar:pressTopTalk( e )
	local str = e.params
	if not str then
		return
	end
	local caseView = self._barView.mc_chatBall.currentView
	caseView:visible(true)
	caseView:stopAllActions()
	caseView.txt_chatBall:setString(str)
	caseView:scale(0.1)
	local onComplete = function (  )
		-- caseView:visible(false)
		caseView:delayCall(c_func(caseView.visible, caseView,false), 3)
	end
	transition.scaleTo(caseView,{scale=1,time = 0.2,easing="BACKIN",onComplete = onComplete })
end


function ViewHealthBar:pressShowName( e )
	local peopleType = self.target.data:peopleType()
	if peopleType == Fight.people_type_monster then
		return
	end
	self._barView.txt_name:visible(e.params)
end


--直接显示hp
function ViewHealthBar:pressShowHP( e )
	if e.params.camp == 0 then
		if e.params.visible == true then
			self._leftShowTime = -1
			self._barView.panel_1:visible(true)
		else
			self._barView.panel_1:visible(false)
		end
	else
		if self.target.camp ~= e.params.camp then
			self._barView.panel_1:visible(false)
		else
			if e.params.visible == true then
				self._leftShowTime = -1
				self._barView.panel_1:visible(true)
			else
				self._barView.panel_1:visible(false)
			end
		end
	end
	

	
	
end




--用户状态发生变化
function ViewHealthBar:pressUserStateChange( e )
	local state = e.params
	if self._barView.panel_1.mc_1 then
		-- echo(state,"______用户状态")
		--直接跳到对应帧上去
		self._barView.panel_1.mc_1:showFrame(state)
	end

end


--是否永久显示
function ViewHealthBar:setAlwaysShow( )
	self.alwaysShow = true
	self:visible(true)
end

--更新血条 不要不停用action了 
function ViewHealthBar:updateFrame(  )
	if self._leftShowTime > 0 then
		self._leftShowTime = self._leftShowTime -1
		if self._leftShowTime ==0 then
			self._barView.panel_1:visible(false)
		end
	end
end


--生命发生变化
function ViewHealthBar:pressHealthChange( event)

	--如果不是初始化
	if event then
		--让名字恢复位置
		self._barView.txt_name:pos(self._initTxtPos.x,self._initTxtPos.y)

		self._barView.panel_1:visible(true)
		self._leftShowTime = barLastTime

	end

	
	local percent = math.round( self.target.data:hp()/self.target.data:maxhp() * 100 )
	if event then
		self._barView.panel_1.mc_progress.currentView.progress_1:tweenToPercent(percent,10)
		self._barView.panel_1.mc_progress.currentView.progress_2:tweenToPercent(percent,10)
	else
		self._barView.panel_1.mc_progress.currentView.progress_1:setPercent(percent)
		self._barView.panel_1.mc_progress.currentView.progress_2:setPercent(percent)
	end
	-- if self.target.camp == 1 then
	-- 	self._barView.panel_1.mc_progress.currentView.progress_2:setPercent(percent)
	-- end
	if percent <=0 then
		self._barView.panel_1:visible(false)
	end
end

--能量发生变化
function ViewHealthBar:pressEnergyChange( event)

	-- if self.target.camp ~=1 then
	-- 	return
	-- end
	if event then
		--让名字恢复位置
		self._barView.txt_name:pos(self._initTxtPos.x,self._initTxtPos.y)
		self._barView.panel_1:visible(true)
		self._barView.panel_1:visible(true)
		self._leftShowTime = barLastTime
	end

	
	local percent = math.round( self.target.data:energy()/self.target.data:maxenergy() * 100 )

	if self.target.camp == 1 then
		if event then
			self._barView.panel_1.mc_progress.currentView.progress_3:tweenToPercent(percent,10)
		else
			self._barView.panel_1.mc_progress.currentView.progress_3:setPercent(percent)
		end
		if percent >= 1 then
			self._barView.panel_1.mc_progress.currentView.progress_4:setPercent(percent)
			self._barView.panel_1.mc_progress.currentView.progress_4:visible(true)
			self._barView.panel_1.mc_progress.currentView.progress_3:visible(false)
		else
			self._barView.panel_1.mc_progress.currentView.progress_4:visible(false)
			self._barView.panel_1.mc_progress.currentView.progress_3:visible(true)
		end
		
	end
	--取消缓动
	-- self._barView.panel_1.progress_3:setPercent(percent)
	-- self._barView.panel_1.progress_4:setPercent(percent)
end



--初始化时间
function ViewHealthBar:setInitTime( time )
	self.initTime = time
end

--改变时间
function ViewHealthBar:setTime( time )
	self.time = time
end


function ViewHealthBar:deleteMe( )
	self.target.data:clearOneObjEvent(self)
	FightEvent:clearOneObjEvent(self)
	--移除侦听
	self:removeFromParent()

end


--[[
显示可以攻击
]]
function ViewHealthBar:showCanAttack( viewSizeWith,viewSizeHeight )
	--echo("viewSizeWith   viewSizeHeight",    "---",viewSizeWith,viewSizeHeight)
	self:hideAttackNum()
	if not self.canAttackView  then
		self.canAttackView = UIBaseDef:createPublicComponent( "UI_battle","panel_zhan" ):addto(self._rootNode)
	end
	self.canAttackView:scale(1.5)
	--判断是否是攻击性技能
	if  self.target:getNextSkill().isAttackSkill then
		self.canAttackView.mc_biao:showFrame(1)
	else
		self.canAttackView.mc_biao:showFrame(2)
	end
	self.canAttackView:pos(0,-viewSizeHeight)
	self.canAttackView:visible(true)
end

--[[
隐藏可以攻击
]]
function ViewHealthBar:hideCanAttack(  )
	if self.canAttackView then
		self.canAttackView:visible(false)
	end
end




--[[
显示可以越位攻击
@icon 要显示的头像
@viewSizeWith  英雄的宽度
@viewSizeHeight 英雄的高度
]]
function ViewHealthBar:showCanOffSideAttack(icon,viewSizeWith,viewSizeHeight)
	if not self.offsetAttackView then
		self.offsetAttackView = UIBaseDef:createPublicComponent("UI_battle","panel_tou"):addto(self._rootNode)
	end
	
	self:hideCanAttack()
	self.offsetAttackView:visible(true)
	self.offsetAttackView:pos(0,-viewSizeHeight)
	if self.offsetAttackView.icon ~= icon then
		self.offsetAttackView.ctn_1:removeAllChildren()
		self.offsetAttackView.ctn_1:addChild(display.newSprite(icon):size(44,44):pos(0,-4))
		self.offsetAttackView.icon = icon
	end
	self.offsetAttackView:scale(1.7)
end


--[[
隐藏可以越位攻击
]]
function ViewHealthBar:hidCanOffSideAttack(  )
	if self.offsetAttackView then
		self.offsetAttackView:visible(false)
	end
end



--[[
显示法宝信息
@params gridFigure 法宝位置
@params leftTreaCallBack  点击左侧法宝回调事件
@params rightTreaCallBack 点击右侧法宝回调事件
]]
function ViewHealthBar:showTrea(callBack,gridFigure,leftTreaIcon,rightTreaIcon,viewSizeWith,viewSizeHeight)
	local x = 0
	local y = viewSizeHeight*(-1)-30
	if gridFigure%2 == 1 then
		y = 30
	end
	if not self.leftTreaView then
		self.leftTreaView =    UIBaseDef:createPublicComponent("UI_battle","panel_treaDemo"):addto(self._rootNode)
	end

	local touchLeftTrea=function (  )
		if callBack then
			callBack(1)
		end
	end


	--这里其实还需要更新法宝  todo dev 这里暂时不更新
	self.leftTreaView:visible(true)
	self.leftTreaView:scale(0.7)
	self.leftTreaView.ctn_trea:addChild( display.newSprite(leftTreaIcon):scale(0.5) )
	self.leftTreaView:pos(x-viewSizeWith/2-30,y)
	self.leftTreaView:setTouchedFunc(touchLeftTrea)
	 -- self.leftTreaView.ctn_tihuan:visible(false)  --:addChild(display.newSprite(leftTreaIcon):size(90,90))
	 -- sel.leftTreaView.panel_1:visible(fa)
	-- self.leftTreaView.mc_1:visible(false)
	-- self.leftTreaView.ctn_chu:visible(false)
	-- --self.leftTreaView.ctn_tihuan.mc_dou:visible(false)
	-- --self.leftTreaView.ctn_tihuan.mc_1:visible(false)
	-- sel.leftTreaView.ctn_tihuan.ctn_1:visible(false)
	local touchRightTrea = function (  )
		if callBack then
			callBack(2)
		end
	end

	if not self.rightTreaView then
		self.rightTreaView =  UIBaseDef:createPublicComponent("UI_battle","panel_treaDemo"):addto(self._rootNode)-- UIBaseDef:createPublicComponent("UI_battle","panel_daoju"):addto(self)
	end
	self.rightTreaView:visible(true)
	self.rightTreaView:scale(0.7)
	self.rightTreaView.ctn_trea:addChild( display.newSprite(rightTreaIcon):scale(0.5) )
	self.rightTreaView:pos(x+viewSizeWith/2+30,y)
	self.rightTreaView:setTouchedFunc(touchRightTrea)
	-- self.rightTreaView.ctn_tihuan:addChild(display.newSprite(rightTreaIcon):size(90,90))
	-- self.rightTreaView.mc_1:visible(false)
	-- self.rightTreaView.ctn_chu:visible(false)
	-- self.rightTreaView.ctn_tihuan.mc_dou:visible(false)
	-- sel.rightTreaView.ctn_tihuan.mc_1:visible(false)
	-- sel.rightTreaView.ctn_tihuan.ctn_1:visible(false)


	self:hideCanAttack()
end

--[[
隐藏法宝
]]
function ViewHealthBar:hideTrea(  )
	if self.leftTreaView then
		self.leftTreaView:visible(false)
		--self.leftTreaView:setTouchedFunc(nil)
	end
	if self.rightTreaView then
		self.rightTreaView:visible(false)
	end

end



--[[
显示英雄的攻击次序
这个人的操作次序
]]
function ViewHealthBar:showAttackNum( num,viewSizeWith,viewSizeHeight)
	if num>= 2 and num<=6 then
		self:hideCanAttack()
		self:hideTrea()
		if not self.attackNumView then
			self.attackNumView = UIBaseDef:createPublicComponent("UI_battle","mc_newnumber"):addto(self._rootNode)
		end
		self.attackNumView:pos(0,-viewSizeHeight)
		self.attackNumView:visible(true)
		self.attackNumView:setScaleX(Fight.cameraWay * 2)
		self.attackNumView:setScaleY( 2)
		self.attackNumView:showFrame(num-1)
	else
		self:hideAttackNum()
	end
end



--[[
隐藏英雄攻击测序
]]
function ViewHealthBar:hideAttackNum(  )
	if self.attackNumView then
		self.attackNumView:visible(false)
	end

end




--[[
显示 手型  可以攻打到目标Enemy的对象
]]
function ViewHealthBar:showJiHuoHandAni(viewWith,viewHeight)
	local callBack
	callBack = function (  )
		self.handAni:visible(false)
	end

	if not self.handAni then
		self.handAni = FuncArmature.createArmature("UI_main_img_shou_sz",self._lightNode,true):pos(0,-viewHeight*0.5)
		self.handAni:setRotation(-135)
		self.handAni:setScaleX(-1)
	end
	self.handAni:visible(true)
	self.handAni:stopAllActions()
	self.handAni:runAction(
		cc.Sequence:create(
				cc.DelayTime:create(1.5),
				cc.CallFunc:create(callBack)
			)
			
		) 
end


--[[
隐藏集火手动画
]]
function ViewHealthBar:hideJiHuoHandAni(  )
	if self.handAni then
		self.handAni:stopAllActions()
		self.handAni:visible(false)
	end
end




--[[
不能集火
]]
function ViewHealthBar:showCannotJiHuo( viewWith,viewHeight )
	
	local callBack
	callBack = function ()
		self.showCanotJiHuoAni:visible(false)
	end

	if self.showCanotJiHuoAni == nil then 
		self.showCanotJiHuoAni = FuncArmature.createArmature("UI_zhandou_wufagongji",self._lightNode,false):pos(0,0)
		self.showCanotJiHuoAni:setScaleX(Fight.cameraWay)
	end
	self.showCanotJiHuoAni:removeFrameCallFunc()
	self.showCanotJiHuoAni:visible(true)
	self.showCanotJiHuoAni:playWithIndex(0, false)
	self.showCanotJiHuoAni:getBoneDisplay("layer2"):playWithIndex(1,true)
	self.showCanotJiHuoAni:registerFrameEventCallFunc(nil, false, callBack)
end


--[[
不能攻打
]]
function ViewHealthBar:hideCannotJiHuo(  )
	if self.showCanotJiHuoAni then
		self.showCanotJiHuoAni:visible(false)
	end
end



function ViewHealthBar:showCannotGongji( viewWith,viewHeight )
	local callBack
	callBack = function ()
		self.showCanotGongjiAni:visible(false)
	end

	if self.showCanotGongjiAni == nil then 
		self.showCanotGongjiAni = FuncArmature.createArmature("UI_zhandou_wufagongji",self._lightNode,false):pos(0,0)
		self.showCanotGongjiAni:setScaleX(Fight.cameraWay)
	end
	self.showCanotGongjiAni:removeFrameCallFunc()
	self.showCanotGongjiAni:visible(true)
	self.showCanotGongjiAni:playWithIndex(1, false)
	self.showCanotGongjiAni:getBoneDisplay("layer2"):playWithIndex(0,true)
	self.showCanotGongjiAni:registerFrameEventCallFunc(nil, false, callBack)
end

function ViewHealthBar:hideCannotGongji(  )
	if self.showCanotGongjiAni then
		self.showCanotGongjiAni:visible(false)
	end
end


return ViewHealthBar