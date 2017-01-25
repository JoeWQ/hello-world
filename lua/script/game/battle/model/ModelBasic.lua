--
-- Author: dou
-- Date: 2014-02-28 16:59:55
--

--坐标系暂时采用cocos2d-x的坐标系
local Fight = Fight


ModelBasic = class("ModelBasic")


-- 指针数据
ModelBasic.controler =nil 		-- 游戏控制器
ModelBasic.myView = nil 		-- 视图  ViewBasic 对象
ModelBasic.shade = nil 			-- 影子 ModelShade对象
ModelBasic.effectArr = nil		-- 特效的数组
--[[
shakeInfo = {
		frame = frame, 			--震动帧数
		shakeType = shakeType , --震动类型
		range = 1,  			--震动半径
		
	}

]]
ModelBasic.shakeInfo = nil 		--自身震屏信息

ModelBasic.depthType = 0 		-- 深度排列的类型 	 同一y下的时候 根据这个决定深度 类型越高越在里面
ModelBasic.modelType = 0 		-- model类型 
ModelBasic.initCamp = nil  		--初始阵营,需要记录这个值 如果我方某个人被魅惑了 那么这个人是不能被攻击的 

ModelBasic.protectTime = nil   	--保护值,在这个时间内 是不受任何打断影响 

-- 游戏速度
ModelBasic.updateScale =1 		-- 刷新比率  如果scale>1 表示快动作  小于1 表示慢动作
ModelBasic.updateCount = 0 		-- 刷新计数 
ModelBasic.updateScaleCount = 0 -- 游戏速度
ModelBasic.lastScaleTime = -1   -- 加速时间计时

--各种暂停
ModelBasic.skillPause = false 	-- 技能导致暂停  
ModelBasic.selfPause = false 	-- 代码暂停

--在队伍数组中的位置
ModelBasic._campIdx = nil -- 在队伍中的索引

--[[
	StillInfo = class("StillInfo")
	StillInfo.time =0
	StillInfo.type = 0    	-- 1是普通硬直 2是抖动硬直
	StillInfo.x =0 			-- 记录当前的硬直抖动x范围
	StillInfo.y = 0 		-- y范围
	StillInfo.r =1 			-- 如果是抖动硬直的 那么就有一个抖动半径 默认只x方向抖动

]]--
ModelBasic.diedInfo = nil 		-- 死亡信息
ModelBasic.viewScale =  1 		-- 试图的scale
ModelBasic.stillInfo = nil 		-- 初始化硬直信息

--坐标和层级
ModelBasic.__zorder = 0 		-- zorder
ModelBasic.pos = nil 			--坐标 {x,y,z}

ModelBasic._isDied = false

--战队信息
ModelBasic.camp = 1 			--阵营
ModelBasic.way = 1 				--x的运动方向 初始化默认为1 就是朝右的

ModelBasic.campArr=nil 			--我的阵营队伍
ModelBasic.toArr = nil 			--敌人阵营数组  如果以后扩展多方阵营 那么会 扩展 更多toArr   和campArr 
ModelBasic.callFuncArr = nil 	

ModelBasic._viewScale = 1 		--视图缩放系数 

function ModelBasic:ctor( controler,obj )
	--self.countId = 0
 	self.controler = controler
 	self.logical = controler.logical

 	if self.modelType == Fight.modelType_heroes or self.modelType == Fight.modelType_missle then
 		self.controler._countId = self.controler._countId + 1
 		self.countId = self.controler._countId
 	end

 	self.diedInfo = {t=Fight.diedType_disappear,canDo = false} --死亡方式  如果是透明度下降死亡 那么 在2秒内消失

 	self.effectArr = {}
 	self.callFuncArr = {}
 	
 	self.stillInfo =  {time =0,type=0,x=0,y=0,r=1}    -- 初始化硬直信息
 	--现在坐标精简化 
 	self.pos = {x=0,y=0,z=0}	
 	self._campIdx = 1


 	if obj then
	 	self:initData(obj)
 	end
end


function ModelBasic:getViewData(obj)
	if self.modelType == Fight.modelType_summon then
		self.viewData  = FrameDatas.getSummonViewData(obj.curArmature)
	elseif self.modelType == Fight.modelType_heroes then
		if not obj.curArmature then
			echo("___________法宝没有配置spine名字",obj._curTreasureHid,obj.curArmature )
		end
		self.viewData =  FrameDatas.getViewData(true, obj.curArmature )
	else
		self.viewData =  FrameDatas.getViewData(false, obj.curArmature )
	end
	--dump(self.viewData)
end

--初始化数据
function ModelBasic:initData( obj )
	self.data = obj
	self:getViewData(obj)	
	return self
end

--设置死亡方式
function ModelBasic:setDiedType( t )
	self.diedInfo.t = t
	if t == Fight.diedType_alpha  then
		self.diedInfo.lastFrame = 20
		self.diedInfo.count = self.diedInfo.lastFrame 
		self.diedInfo.zhenfu = 0.1
	elseif t == Fight.diedType_alphades  then
		self.diedInfo.lastFrame = 20
		self.diedInfo.count = self.diedInfo.lastFrame 
	end
end

--设置阵营-   isInit 是否是初始化阵营 
function ModelBasic:setCamp( value,isInit )
	if isInit then
		self.initCamp = value
	end
	self.camp = value
	local controler = self.controler
	if value ==1 then
		self.toCamp = 2
		self.campArr = controler.campArr_1
		self.toArr  = controler.campArr_2
		self.way = 1
		self.diedArr = controler.diedArr_1
		self.toDiedArr = controler.diedArr_2
	elseif value ==2 then
		self.toCamp = 1
		self.campArr = controler.campArr_2
		self.toArr  = controler.campArr_1
		self.diedArr = controler.diedArr_2
		self.toDiedArr = controler.diedArr_1
		self.way = -1
	end
	-- 设置方向
	self:setWay(self.way)
end

function ModelBasic:changeView(viewName)
	if Fight.isDummy then
		return
	end

	local spbName = viewName
	if viewName == "0" then
		viewName = self.data.defArmature
		spbName = self.data.defSpbName
	end
	local oldZorder = self.myView:getLocalZOrder()

	--因为换视图需要重新获取一下动作的帧数据
	self.viewData =  FrameDatas.getViewData(true, viewName )

	local view = ViewSpine.new(spbName,{},nil,viewName)
	local old = self.myView 
	self.myView = view

	self.viewCtn:addChild(view)
	view:zorder(oldZorder)
	self:setViewScale(self.viewScale)
	-- 继续当前的动作,
	view:playLabel(self.data.sourceData.stand)
	view:gotoAndPlay(1)
	self:updateViewPlaySpeed()
	old:deleteMe()


	

	self:realPos()
end


function ModelBasic:initView(ctn,view,xpos,ypos,zpos )
	if Fight.isDummy then
		return
	end
	--容器层
	self.viewCtn = ctn
	self.myView = view
	ctn:addChild(self.myView)

	if self.myView.doAfterInit then
		self.myView:doAfterInit()
	end
	if xpos and ypos and zpos then
		self:setPos(xpos,ypos,zpos)
	end
	self:updateViewPlaySpeed()

	if self.modelType == Fight.modelType_heroes then
		if self.data.viewScale then
			local viewScale = self.data:viewScale() or 100
			self:setViewScale(viewScale/100)
		end
	end

	return self
end


--设置坐标
function ModelBasic:setPos(xpos ,ypos ,zpos  )
	if not xpos then xpos = 0 end
	if not ypos then ypos = 0 end
	if not zpos then zpos = 0 end
	self.pos.x= xpos
	self.pos.y = ypos
	self.pos.z = zpos
	self:realPos()
	return self
end

--设置刷新速度  比如快动作
function ModelBasic:setUpdateScale(scale,lastTime)

	lastTime = lastTime or -1

	self.updateScale = scale

	self.lastScaleTime = lastTime

	--初始化scale计数
	self.updateScaleCount = 0
	--更新播放速度
	self:updateViewPlaySpeed()
	
	return self
end

--更新视图速度
function ModelBasic:updateViewPlaySpeed( )
	if Fight.isDummy then
		return self
	end
	if self.myView.setPlaySpeed then
		--让视图设置对应的播放速度
		self.myView:setPlaySpeed(self.updateScale*self.controler.updateScale)
	end
end

--设置方位
function ModelBasic:setWay( way )
	if not way then
		return
	end

	self.way = way
	if self.myView then
		self:setViewScale(self.viewScale)
	end
end

--设置viewscale
function ModelBasic:setViewScale( value )
	self.viewScale = value
	if Fight.isDummy  then
		return
	end
	if not self.myView then
		return
	end
	if self.isWholeEff then
		return
	end
	self.myView:setScaleX(self.controler._mirrorPos*self.way*self.viewScale * Fight.wholeScale)
	self.myView:setScaleY(value* Fight.wholeScale)
end


--停止播放动作
function ModelBasic:stopFrame(  )
	self.selfPause = true
	self:checkCanPlayView()
end

--恢复播放动作
function ModelBasic:playFrame(  )
	self.selfPause = false
	self:checkCanPlayView()
end

--游戏暂停或者播放
function ModelBasic:gamePlayOrPause( value )
	self:checkCanPlayView()
end

--场景暂停或者播放
function ModelBasic:scenePlayOrPause( value )
	self.scenePause = value
	self:checkCanPlayView()
end

--设置技能导致暂停
function ModelBasic:setSkillPause(value  )
	self.skillPause = value
	self:checkCanPlayView()
end

--能否播放动画
function ModelBasic:checkCanPlayView( outAction  )
	
	if not self.myView then
		return false
	end
	
	local result = true
	--如果是硬直期间
	if self.stillInfo.time ~= 0 then
		result = false
	end

	--如果是游戏暂停的
	if self.controler._gamePause  then
		result = false
	end
	--如果是技能播放暂停的
	if self.skillPause then
		result = false
	end

	--如果是代码控制暂停
	if self.selfPause then
		result =false
	end

	--如果是场景暂停
	if self.controler.scenePause then
		result =false
	end

	if not self.myView.play then
		return result
	end
	
	if outAction then
		return result
	end
	
	if result then
		self.myView:play()
	else
		self.myView:stop()
	end
	

	return result
end

--震屏
--[[
	frame  震屏时间
	range 震屏力度
	shakeType 震屏类型 x震屏 y震屏 xy震屏
]]
function ModelBasic:shake( frame,range,shakeType  )
	if Fight.isDummy  then
		return
	end
	self.controler.layer:shake(frame,range,shakeType)
end	

--播放声音
function ModelBasic:sound( soundName )	
end


----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


--刷新函数
function ModelBasic:updateFrame( )
	--如果是正常速度
	--如果是 技能暂停
	if self.skillPause then
		return
	end



	local lastCount

	if self.lastScaleTime > 0 then
		self.lastScaleTime = self.lastScaleTime -1
		if self.lastScaleTime ==0 then
			self:setUpdateScale(1, -1)
		end
	end


	if self.updateScale == 1 then
		self:runBySpeedUpdate()
	--如果是降速的
	elseif self.updateScale < 1 then
		--判断多少帧刷新一次函数
		lastCount = math.round(self.updateScaleCount)
		self.updateScaleCount = self.updateScaleCount + self.updateScale
		if math.round(self.updateScaleCount) > lastCount then
			--如果是达到一次计数了 那么就做一次刷新函数
			self:runBySpeedUpdate()
		end
	else
		--先计算需要刷新多少次
		local count = math.floor(self.updateScale)
		for i=1,count do
			self:runBySpeedUpdate()
		end

		local leftCount = self.updateScale - count
		self.updateScaleCount = self.updateScaleCount+ count
		--如果不是整数倍数加速
		if leftCount > 0 then
			lastCount = math.round(self.updateScaleCount)
			self.updateScaleCount = self.updateScaleCount + leftCount

			--如果四舍五入后达到一次计数了 那么就做一次刷新函数
			if math.round(self.updateScaleCount) > lastCount then
				self:runBySpeedUpdate()
			end
		end
	end
end


--按照加速比率进行刷新
function ModelBasic:runBySpeedUpdate( ... )

	self.updateCount = self.updateCount + 1

	if not self.diedInfo.canDo then
		local stillInfo = self.stillInfo
		if(stillInfo.time ~= 0) then self:myStillMoment() end

		--判断帧事件 ----
		--以下很多事件都必须是在非硬直状态下执行的
		
		--帧事件的控制
		-- if (stillInfo.time ==0) then	self:dummyFrame()end
		self:dummyFrame()

		----先是自我控制 
		-- if (stillInfo.time ==0) then self:controlEvent() end
		self:controlEvent()

		--更新速度
		-- if (stillInfo.time ==0) then self:updateSpeed() end
		self:updateSpeed()

		
		self:moveXYZPos()

		-- 回调
		self:updateCallFunc()


		--碰撞检测 碰撞类的重写
		self:checkHit()	
	end

	-- if self.ttttt == true then
	-- 	echo("____pos__222____________",self.controler.updateCount,self.pos.x,self.speed.x)
	-- 	self.ttttt = false
	-- end
		
	-- 实现真实坐标body
	self:realPos()

	--做死亡函数
	self:doDiedFunc()
end

--硬直事件
function ModelBasic:myStillMoment( ... )
	if self.stillInfo.time <=0 then
		return
	end

	self.stillInfo.time = self.stillInfo.time-1
	if self.stillInfo.time> 0 then
		self:still()
	else
		self:outStill()
	end
end

--硬直事件
function ModelBasic:still()
	local stillInfo = self.stillInfo
	--如果硬直类型是0 也就是停止不动的 那么就不管
	if stillInfo.type == 0 then
		return
	end

	if stillInfo.type == 1 then
		stillInfo.x = (stillInfo.time %2 *2 -1) * stillInfo.r
	elseif stillInfo.type == 2 then
		stillInfo.y = (stillInfo.time %2 *2 -1) * stillInfo.r
	elseif stillInfo.type == 3 then
		stillInfo.x = (stillInfo.time %2 *2 -1) * stillInfo.r
		stillInfo.y = (stillInfo.time %2 *2 -1) * stillInfo.r
	end
end

--跳出硬直
function ModelBasic:outStill(  )
	self.stillInfo.time =0
	self:checkCanPlayView()
end

--设置硬直
--[[
	StillInfo = class("StillInfo")
	StillInfo.time =0
	StillInfo.type = 0    -- 0是普通硬直 1是x抖动硬直 2y抖动硬直 3xy抖动硬直
	StillInfo.x =0 	--记录当前的硬直抖动x范围
	StillInfo.y = 0 	--y范围
	StillInfo.r =1 			--如果是抖动硬直的 那么就有一个抖动半径 默认只x方向抖动

]]--
function ModelBasic:setStill(time,type,x,y,r )
	self.stillInfo.time = time or 0
	self.stillInfo.type = type or 0
	self.stillInfo.x = x or 0
	self.stillInfo.y = y or 0
	self.stillInfo.r = r or 0
	self:checkCanPlayView()
end

function ModelBasic:isStill(  )
	return  false
end

--抖动 	持续帧  力度    震屏方式 1,x 2,y 3 xy 方向震动
function ModelBasic:selfShake( frame,range,shakeType )
	
	range = range and range or 2
	frame = frame and frame or 6
	shakeType = shakeType and shakeType or "xy"
	self.shakeInfo = {
		frame = frame,
		shakeType = shakeType 
	}
	if shakeType == "x" then
		self.shakeInfo.range = {range,0}
	elseif shakeType == "y" then
		self.shakeInfo.range = {0,range}
	else
		self.shakeInfo.range = {range,range}
	end
end


--帧事件
function ModelBasic:dummyFrame( ... )
end

--一些控制事件 --供子类重写
function ModelBasic:controlEvent(  )
end

--更新速度
function ModelBasic:updateSpeed( ... )
end

--碰撞检测
function ModelBasic:checkHit( ... )
end

--移动坐标
function ModelBasic:moveXYZPos( ... )
end




--转换真实坐标
function ModelBasic:realPos( )

	local xpos = self.pos.x
	local ypos = self.pos.y + self.pos.z


	-- if self.stillInfo.type ~= 0 then
	-- 	xpos = xpos + self.stillInfo.x
	-- 	ypos = ypos + self.stillInfo.y
	-- end

	-- 如果是镜像站位就要计算位置
	if self.controler._mirrorPos == -1 then
		xpos = GAMEWIDTH - xpos
	end

	if self.shakeInfo then
		self.shakeInfo.frame = self.shakeInfo.frame-1

		local pianyi = (self.shakeInfo.frame %2 *2 -1 )
		xpos = xpos + pianyi*self.shakeInfo.range[1]
		ypos = ypos + pianyi*self.shakeInfo.range[2]

		if self.shakeInfo.frame == 0 then
			self.shakeInfo = nil
		end
	end

	--因为这里的坐标系是 参考flash坐标系
	if self.myView then
		self.myView:setPosition(math.round(xpos * Fight.screenScaleX),math.round(-ypos) )
	end 

	-- 需要影子配合
	if self.shade then
		self.shade:updateFrame()
	end
end

--开始死亡
function ModelBasic:startDoDiedFunc( diedType )
	self:stopFrame()
	diedType = diedType and diedType or Fight.diedType_disappear 
	self:setDiedType(diedType)
	self.diedInfo.canDo = true
	
	--FilterTools.setViewFilter(self.myView,FilterTools.colorMatrix_gray)
end

--开始执行死亡方式
function ModelBasic:doDiedFunc(  )	
	--如果是透明度下降死亡
	if not self.diedInfo.canDo  then
		return
	end

	--如果是 闪现透明度下降死亡
	if self.diedInfo.t == Fight.diedType_alpha  then
		self.diedInfo.count = self.diedInfo.count -1
		if self.myView then
			local targetAlpha= self.diedInfo.count/self.diedInfo.lastFrame
			if self.diedInfo.count %4 == 0 then
				self.myView:opacity ((targetAlpha + self.diedInfo.zhenfu)*255 )
			elseif self.diedInfo.count %4 == 2 then
				self.myView:opacity((targetAlpha - self.diedInfo.zhenfu) *255)
			end
		end
		
		--如果为0了  那么小时
		if self.diedInfo.count ==0 then
			self:deleteMe()
		end
	elseif self.diedInfo.t == Fight.diedType_alphades  then
		self.diedInfo.count = self.diedInfo.count -1
		if self.myView then
			local targetAlpha= self.diedInfo.count/self.diedInfo.lastFrame
			if self.diedInfo.count %4 == 0 then 
				self.myView:opacity(targetAlpha *255)
				
				-- 影子也需要渐隐消息
				if self.shade then
					self.shade.myView:opacity(targetAlpha *255)
				end
			end
		end
		--如果为0了  那么小时
		if self.diedInfo.count ==0 then
			self:deleteMe()
		end
	else
		self:deleteMe()
	end

end


function ModelBasic:deleteMe( ... )
	self._isDied = true

	if self.data and self.data.clear then
		self.data:clear()
	end

	if self.myView and  (not tolua.isnull(self.myView) ) then
		FilterTools.clearFilter( self.myView  )
		if self.myView.deleteMe then
			self.myView:deleteMe()
		else
			self.myView:clear()
		end

		self.myView = nil
	end

	if self.shade then
		self.shade:deleteMe()
	end

	if self.controler then
		self.controler:clearOneObject(self)
	end

	--清除自身的所有计时效果
	-- TimeUtils.clearTimeByObject(self)
	self.controler = nil
	self.campArr = nil
	self.toArr = nil
	self.viewCtn =nil
	self.callFuncArr = nil
end



----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------



--创建生命条
function ModelBasic:createHealthBar(x,y ,ctn,kind)
	kind = kind  or 2
	self.healthBar = ViewHealthBar.new( kind ):addto(ctn)
	self.healthBarPos = {x=x and x or 0,y = y and y or 0,z=self.data:hang() or 0}
	self.healthBar:setTarget(self,kind)
end


--创建特效数组 effArr,配表特效数组格式 	isCycle是否循环  effArr
function ModelBasic:createEffGroup( effArr,isCycle ,isBeUsed)
	local arr = {}
	local eff 
	if Fight.isDummy  then
		return
	end
	if not effArr then
		return
	end

	local isDebug = DEBUG 

	for i,v in ipairs(effArr) do

		--进行错误检查
		if isDebug then
			if v.l ~= -1 and v.l ~= -2 and v.l ~= 1 and v.l ~= 2 then
				echoWarn("特效层次配置错误,effName:%s,_layer:%d,hid:%s",tostring(v.name),v.l,self.data.hid)
			end
		end

		if isCycle then
			eff  = self:createEff(v.n,tonumber(v.x),tonumber(v.y),v.l,nil,true,v.f,isCycle,v.b,isBeUsed)
		else
			eff  = self:createEff(v.n,tonumber(v.x),tonumber(v.y),v.l,nil,nil,v.f,isCycle,v.b,isBeUsed)
		end
		
		table.insert(arr, eff)
	end

	return arr

end


local xxcount = 0
--创建打击特效  coeffX,coeffY 比例系数
--isBeUsed 是否是被作用的特效  
function ModelBasic:createEff( animation,coeffX, coeffY, showZorder, way, canRepeat,isFollow,isCycle,boneName,isBeUsed)
	if Fight.isDummy then
		return
	end

	showZorder= showZorder or 1

	if not canRepeat then
		if self.effectArr[animation] then
			self.effectArr[animation].myView:gotoAndPlay(1)	
			self.effectArr[animation].updateCount = 1
			return self.effectArr[animation]
		end
	end

	local ani = nil
	local pery = coeffY and coeffY/100 or Fight.hit_position
	coeffX = coeffX and coeffX/100 or 0
	local eff 
	eff = ModelEffectBasic.new(self.controler,nil)

	eff:setIsCycle(isCycle,nil)
	--如果是有跟随骨头的
	if boneName and boneName ~= "n" then
		eff:setFollowBoneName(boneName)
	else
		-- boneName = "foot"
	end

	

	ani = eff:getAniByType(animation,isCycle)
	local xpos = self.pos.x + self.data.viewSize[1]*coeffX
	local ypos = self.pos.y  
	local zpos = self.pos.z - self.data.viewSize[2]*pery + self.data:hang()
	
	-- 特殊判定  -2 表示是放在全屏中心的特效
	if coeffY  == -2 then
		local focusPos = self.controler.screen.focusPos
		xpos = focusPos.x
		ypos =focusPos.y 
		zpos = 0
		isFollow =false
		echo("__创建在屏幕中心的特效")
		--判断是全屏特效的
		eff.isWholeEff = true
	end
	eff:setFollow(isFollow)
	local ctn
	local zorder= 0
	local pianyiY = 0
	--如果是在所有人后面
	if showZorder == -2 then
		ctn = self.controler.layer:getGameCtn(2)
		zorder = - Fight.zorder_front
		pianyiY =  -1
	--如果是在自己后面
	elseif showZorder == -1 then
		ctn = self.viewCtn
		zorder = -1
		pianyiY =  -1
	elseif showZorder == 1 then
		zorder = 1
		ctn = self.viewCtn
		pianyiY =  1
	--显示在最前面 
	elseif showZorder == 2 then
		zorder = Fight.zorder_front
		ctn =  self.controler.layer:getGameCtn(3) --self.viewCtn
		pianyiY =  1
	end
	eff:setTarget(self,self.data.viewSize[1]*coeffX,pianyiY,-self.data.viewSize[2]*pery + self.data:hang(),zorder)
	eff:initView(ctn,ani,xpos,ypos,zpos)
	eff:checkCanPlayView()
	--如果是黑屏期间
	if self.controler.skillPauseInfo.left > 0 then
		eff.myView:zorder(zorder + self.__zorder + Fight.zorder_blackChar)
	end
	-- eff.myView:zorder(zorder + self.__zorder)
	way = way or self.way
	eff:setWay(way)
	if isBeUsed then
		if coeffY ~= -2 then
			eff:setViewScale(self.data:beusedScale() /100  )
		else
			--镜头永远正
			-- eff.myView:setScaleX(1 )
		end
		
	else
		eff:setViewScale(self.viewScale)
	end
	
	-- ani:setScaleX(self.controler._mirrorPos*way * Fight.wholeScale )
	-- ani:setScaleY(Fight.wholeScale)
 	self.controler:insertOneObject(eff)
 	if not canRepeat then
 		self.effectArr[animation] = eff
 	end

 	if self.controler.skillPauseInfo.left == 0 then
		self.controler.sortControler:sortDepth(true)
	end
 	
	return eff
end

function ModelBasic:removeOneEffect(aniName)
	if self.effectArr[aniName] then
		self.effectArr[aniName] = nil
	end
end



--创建影子
function ModelBasic:createShade( textureName, isAni )
	if Fight.isDummy then
		return
	end

	local ctn = self.controler.layer:getGameCtn(3)
	self.shade = ModelShade.new(self.controler)

	local view = nil
	if not isAni then
		view = ViewBasic.new(textureName)
	else
		view = ViewArmature.new(textureName)
	end

	self.shade:initView(self.viewCtn,view)
	self.shade:setFollowTarget(self,0,0,isAni)
	view:zorder(self.__zorder-1)
	--self.shade:updateFrame()

	return self
end


--创建数字特效
function ModelBasic:createNumEff( type,num,showZorder )
	--模拟计算的时候  是不需要创建特效的
	if Fight.isDummy then
		return
	end
	
	--如果
	if math.round(num) ==0 then
		return
	end

	local eff = ModelEffectNum.new(self.controler)
	--eff:setInfo(self, self.controler.layer:getGameCtn(3),type,num)
	eff:setInfo(self, self.controler.layer:getGameCtn(3),type,num)
	eff.myView:zorder(9999)
	-- if showZorder ~= 2 then
	-- 	showZorder = showZorder or 1
	-- 	eff.myView:zorder(self.__zorder+showZorder)
	-- else
	-- 	local ctn = self.controler.layer:getGameCtn(3)
	-- 	eff.myView:parent(ctn)
	-- end

	self.controler:insertOneObject(eff)
end


--添加残影
function ModelBasic:addPhantom( alpha,time )
	local phantom = ModelPhantom.new(self.controler,{})

	local ctn = self.controler.layer:getGameCtn(2)

	phantom:setTarget(self,ctn)
	
	self.controler:insertOneObject(phantom)

end


--创建子弹 初始位置偏移
--carrier 载体 因为有可能是在missle的基础上创建载体,所以出现点应该是从载体出发
function ModelBasic:createMissle( missleObj,skill,atkTarget,carrier)

	-- if skill.hid == "40901" or skill.hid == "50601" then
	-- 	echo("___@@@@@_______ddd",missleObj.hid,missleObj:sta_showFront())
	-- end
	--如果敌方阵营已经全部挂彩了
	if #self.toArr ==0 then
		return nil
	end


	local bullet = ModelMissle.new(self.controler,missleObj,skill)
	--dump(bullet.viewData)
	local ctn
	local zorder= 0
	local pianyiY = 0
	if not Fight.isDummy then
		local view 
		if bullet.viewData.spine then
			view = ViewSpine.new(bullet.viewData.spine,nil)
			view:playLabel(bullet.viewData.image, true)
		else
			view = ViewArmature.new(bullet.viewData.image)
		end

		if not Fight.isDummy  then
			-- 子弹是最上层
			local offsetY = 0
			local showZorder = missleObj:sta_showFront() or 1
			local zorderAdd = 0

			--如果是在所有人后面
			if showZorder == -2 then
				ctn = self.controler.layer:getGameCtn(1)
				zorder = - Fight.zorder_front
				pianyiY =  -1
			--如果是在自己后面
			elseif showZorder == -1 then
				ctn = self.controler.layer:getGameCtn(2)
				zorder = -1
				pianyiY =  -1
			elseif showZorder == 1 then
				zorder = 1
				ctn = self.controler.layer:getGameCtn(2)
				pianyiY =  1
			--显示在最前面 
			elseif showZorder == 2 then
				zorder = Fight.zorder_front
				ctn =  self.controler.layer:getGameCtn(3) --self.viewCtn
				pianyiY =  1
			else
				echoWarn("___showZorder配置错误:%s,showZorder:%d",missleObj.hid,showZorder)
			end
			bullet:initView(ctn, view)
			bullet._zorderAdd = zorderAdd

			if self.controler.skillPauseInfo.left > 0 then
				bullet.myView:zorder(zorder + self.__zorder + Fight.zorder_blackChar)
			end

		end
	end
	
	bullet:setCamp(self.camp,true)
	bullet:setTarget(self,atkTarget,carrier,pianyiY)	
	self.controler:insertOneObject(bullet)
	return bullet
end


function ModelBasic:pushOneCallFunc( delayFrame,func,params )
	
	if delayFrame ==0 then
		if type(func) == "string" then
			if params then
				self[func](self,unpack(params))
			else
				self[func](self)
			end
		else
			if params then
				func(unpack(params))
			else
				func()
			end
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


function ModelBasic:updateCallFunc(  )
	local callInfo
	for i=#self.callFuncArr,1,-1 do
		callInfo = self.callFuncArr[i]
		--@测试
		if not callInfo then
			dump(self.callFuncArr)
			echo("____________________ddd",i,self.data.hid,#self.callFuncArr)
			return
		end
		if callInfo.left > 0 then
			callInfo.left = callInfo.left - 1
			
			if callInfo.left ==0 then			
				--必须先移除这个回调信息 因为回调函数里面可能继续有回调
				table.remove(self.callFuncArr,i)
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

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

--闪光
function ModelBasic:flash(time,interval, color  )
	if Fight.isDummy then
		return
	end

	--如果身上有滤镜样式  不执行
	if self:checkHasFilterStyle() then
		return 
	end

	time = time or 10
	interval = interval or 3
	color = "red"
	FilterTools.flash_colorTransform(self.myView,time,interval,color)
end

--判断是否有滤镜样式 供子类重写
function ModelBasic:checkHasFilterStyle(  )
	return false
end


--创建残影 组
function ModelBasic:createGhostGroup(times,interval, offset, zorder,ctn ,alpha, lastTime)
	if not self.myView then
		return
	end

	local tempFunc = function (  )
		local curHp = self.data:hp()
		if  curHp > 0 then
			local node = self:createGhost(self.pos.x+30*offset,-self.pos.y,zorder,ctn,alpha, lastTime)
			node:setScaleX(self.controler._mirrorPos*self.way)
		end
	end

	for i=1,times do	
		self.myView:delayCall(tempFunc,interval*i)
	end
	tempFunc()
end


--创建残影
function ModelBasic:createGhost( x, y, zorder,ctn ,alpha, lastTime)
	alpha = alpha or 0.3
	lastTime = lastTime or 0.2
	x = x or self.pos.x-30*self.way
	y = y or -self.pos.y
	local ghostNode = pc.PCNode2Sprite:getInstance():spriteCreate(self.myView.currentAni)
	ghostNode:pos(x,y)
    ghostNode:setCascadeOpacityEnabled(true)
    ghostNode:setOpacity(alpha *  255)
    ghostNode:anchor(0.5,0)
    ghostNode:addto(ctn):zorder(zorder or 0)

    local call = function (  )
        ghostNode:removeFromParent(true)
    end

    --
    local act_alpha = cc.FadeTo:create(lastTime,0)
    local act_call = cc.CallFunc:create(call)

    local seq = cc.Sequence:create({act_alpha,act_call})
    ghostNode:runAction(seq)

    return ghostNode
end

--显示或者隐藏view
function ModelBasic:setVisible( value )
	self.myView:visible(value)
	if value then
		self:playFrame()
	else
		self:stopFrame()
	end
end


function ModelBasic:tostring(  )
	if self.data.tostring then
		return self.data:tostring()
	end
	return "className:"..self.__cname.."_id:"..tostring(self.data.id) .."_pos:"..self.pos.x.."_"..self.pos.y.."_"..self.pos.z
end

return ModelBasic