-- 1.最少匀速转10圈
-- 2.服务没回来之前一直匀速转圈
-- 3.服务器来了之后开始匀减速， 服务器数据来了之后 根据拖动的速度判定 要继续转的圈数。
-- 如果拖动的越快 继续转的圈数越高 ，最多给20圈，做匀减速运动，刚好让模型运动到指定的图标上去
-- 如果拖动速度太慢 那么让他还原 不发送服务器消息
local EllipseType  = class("EllipseType",function ()
	return display.newNode()
end)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
--[[
local configs = {
	
	--椭圆中心 
	EllipseCenter = {x = nil,y = nil}
    --椭圆的长轴
	EllipselengthA = nil,
	--椭圆的短轴
	EllipseshortB = nil,
	--逆转还是顺时针旋转
	DirectionRotation  = 1, ---1是顺时针 -1是逆时针
	--对象个数
	ObjectNumber = nil,
	--移动距离
	moveXlength = 1,
	--是否逆时针运动
	moveInAnticlockwise = true

}
--]]
local tlength = {}   ---每个对象的角度
local addandreduce = true   --负数fasle 正数true
local touchtime = 3    --点击时间
local M_PI = 3.141596253    ---π 值
local TurnSumLength = 200 -- 设置滑动位置的最大值

local DIRECTION_HORIZONTAL	=  2  --- 水平方向
-- ellipse.moveviewRect = {width = ,height = ,}
-- self.movelength = 200  --- 最大移动固定距离 
local  AcceleratedRotation = false ---加速转动是否开启
local Scalenumber = 0.6
local selectTenReward = 10  --选择20次抽奖
local selectOneReward = 1      --选择20次抽奖
local huadongMaxJuli = 300

--初始化设置
function EllipseType:ctor(object,config,bg)
	


	self.isXuanZhuangStop = false
	self.scrollSpeed = 2.0
	self.localPos = { x= 0 ,y = 0}
	self.speed = {x= 0,y = 0}
	self.rotateangle = 0
	self._scrollDistance = 1
	self.maxscale = 0.8
	self.minsclale = 0.4
	self.touchmovelength = 20   ---滑动的距离

	if object == nil  then
		echo("object is nil")
		return false
	end 
	if config == nil  then
		echo("config is nil")
		return false
	end 


	self.direction = DIRECTION_HORIZONTAL
	self.movepoint = {x=nil,y=nil}
	self.firstobjectangle = nil --第一个对象的角度
	self.EllipselengthA = config.EllipselengthA 
	self.EllipseshortB  = config.EllipseshortB
	self.DirectionRotation = config.DirectionRotation
	self.ObjectNumber = config.ObjectNumber or 6 --默认6个
	self.moveXlength = config.moveXlength or 0.2
	self.moveInAnticlockwise = config.moveInAnticlockwise or true
	self.bg = bg
	self.movelength = 200
	TurnSumLength = config.EllipselengthA/3
	self.sendserverdsts = false
	self.choujiangstart = true


	self.wirte = FuncRes.a_white( 170*4,36*9.5)
	self.wirte:setPosition(cc.p(55,-140))
	self:addChild(self.wirte,10)
	self.wirte:setTouchEnabled(true)
	self.wirte:setTouchSwallowEnabled(true)

	self.wirte:opacity(0)
	self.wirte:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		-- dump(event)
		local result = self:onTouch_(event)
        return result or false
	end)


	self:createEllipse(object)
	math.randomseed(os.time())
	self:addEventListeners()



end
----特效加载
function EllipseType:getMianviewself(handlers)
	self.handlers = handlers
	self.handlers:insterArmatureTexture("UI_chouka_a")

end

function EllipseType:updata(data)
	--TODO
	-- dump(data,"登录数据抽奖数据")
	self.data = data
	for i=1,#self.newObjectTable do
		-- self.newObjectTable[i]:visible(true)
		if self.newObjectTable[i].currentView.mc_1 ~= nil then
			self.newObjectTable[i].currentView.mc_1:visible(true)
		else
			self.newObjectTable[i].currentView.UI_1:visible(true)
			self.newObjectTable[i].currentView.panel_1:visible(true)
			-- self.newObjectTable[i]:showFrame(5)
		end
		-- self.newObjectTable[i].currentView.mc_1:visible(true)
		if type(data[i].type) == "number" then
			self.newObjectTable[i]:showFrame(data[i].type)
			local view = self.newObjectTable[i]:getViewByFrame(tonumber(data[i].type)).mc_1
			view:showFrame(tonumber(data[i].quality))
			self:addEffectInTolottery(data[i].type,tonumber(data[i].quality),view,i)
		else
			--替换成资源图片
			self.newObjectTable[i]:showFrame(5)
			local viewUI = self.newObjectTable[i]:getViewByFrame(5).UI_1 
			viewUI:setResItemData({ reward = data[i]})
		end
		if tonumber(data[i].quality) ~= 5 then
			self.newObjectTable[i]:setTouchEnabled(true)
			self.newObjectTable[i]:setTouchSwallowEnabled(false)
			self.newObjectTable[i]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
				-- echo("==============================",i)
				-- if event.name == "began" then
				-- 	self.objectismove = false
				-- 	return true 
				-- elseif event.name == "ended" then
				-- 	if self.objectismove == false then
				--   		local Data = self.data[i]
				--  		WindowControler:showWindow("NewLotteryRewardShowUI",Data)
				--  	end
			 -- 	end
			end)
		end
	end
	-- self:objectTouch()
end
function EllipseType:objectTouch()
	for i=1,#self.newObjectTable do
		self.newObjectTable[i]:setTouchEnabled(true)
		self.newObjectTable[i]:setTouchSwallowEnabled(false)
		self.newObjectTable[i]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			-- echo("==============================",i)
			if event.name == "began" then
				self.objectismove = false
				return true 
			elseif event.name == "ended" then
				if self.objectismove == false then
			  		local Data = self.data[i]
			 		WindowControler:showWindow("NewLotteryRewardShowUI",Data)
			 	end
		 	end
		end)
	end
end

function EllipseType:addEffectInTolottery(typeID,qualitys,view,index)

    -- echo("=======typeID===qualitys=======",typeID,qualitys)
    local lockAni = nil
    if tonumber(qualitys) == 5 then
    	local ctn = view:getViewByFrame(tonumber(qualitys)).ctn_1
        if typeID == 1 then --
            lockAni = self.handlers:createUIArmature("UI_chouka_a","UI_chouka_a_wenhao", nil, true, GameVars.emptyFunc)
            lockAni:setScale(0.9)
        elseif typeID == 2 then
            lockAni = self.handlers:createUIArmature("UI_chouka_a","UI_chouka_a_huoban", nil, true, GameVars.emptyFunc)
            lockAni:setScale(0.9)
        elseif typeID == 3 then
            lockAni = self.handlers:createUIArmature("UI_chouka_a","UI_chouka_a_fabao", nil, true, GameVars.emptyFunc)
            lockAni:setScale(0.9)
        elseif typeID == 4 then
            lockAni = self.handlers:createUIArmature("UI_chouka_a","UI_chouka_a_cailiao", nil, true, GameVars.emptyFunc)
            lockAni:setScale(0.9)
        end
        ctn:removeAllChildren()
        local node = display.newNode()
	    node:setContentSize(300, 300)
	    node:anchor(0.5,0.5)
	    ctn:addChild(node,5)
        ctn:addChild(lockAni,3)
	    node:setTouchEnabled(true)
		node:setTouchSwallowEnabled(true)
		node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			-- if event.name == "began" then
			-- 	self.objectismove = false
			-- 	return true 
			-- elseif event.name == "ended" then
			-- 	if self.objectismove == false then
			--   		local Data = self.data[index]
			--  		WindowControler:showWindow("NewLotteryRewardShowUI",Data)
			--  	end
		 -- 	end
		end)
    end
    
end


function EllipseType:getIconBytype(reward)
	local icon = nil
	local typeid = reward[1]
	local awardid = reward[2]
	local sprite= nil
	if typeid == 1 then
		icon = FuncItem.getIconPathById( awardid )
		sprite = FuncRes.iconItemWithImage(icon)
	elseif typeid == 10 then
		icon =  FuncTreasure.getTreasureAllConfig()[tostring(awardid)].icon
		sprite = FuncRes.iconEnemyTreasure(icon)
	elseif typeid == 18 then
		icon = FuncPartner.getPartnerById(rewardID).icon
		sprite = FuncRes.iconHero(icon)
	end
	return icon
end
--初始化椭圆
function EllipseType:createEllipse(object)
	--椭圆函数 (x*x)/(a*a)+(y*y)/(b*b) = 1
	self:CloneObject(object)
	self:SetbjectPoint()

	self:openAction()
	self:StopRotateAndDeceleration()

end
function EllipseType:openAction()
	self:scheduleUpdateWithPriorityLua(handler(self, 
        self.update), 0);
end

local angletable = {
	[1] = 0,
	[2] = 60,
	[3] = 120,
	[4] = 180,
	[5] = 240,
	[6] = 300,
}

function EllipseType:CloneObject(object)
	self.newObjectTable = {}
	for i=1,#object do
		local newobject = object[i]
		self.newObjectTable[i] = newobject
	end
end

--添加对象和设置坐标
function EllipseType:SetbjectPoint()
	---从funcecilpse 中获取点的位置
	local point = self:AccordingAngleSetPoint()
	-- local maxscale = 0.9
	-- local minsclale = 0.4
	-- dump(point,nil,6)
	for i=1,#self.newObjectTable do
		self.newObjectTable[i]:setPosition(cc.p(point[i].x,point[i].y))
		self.newObjectTable[i]:setAnchorPoint(cc.p(0.5,0.5))
		self:addChild(self.newObjectTable[i])
		self.newObjectTable[i]:setScale(self:getobjectScale(i))
		tlength[i] = angletable[i]
	end
	self.firstobjectangle = 0
end
function EllipseType:getobjectScale(index)
	-- local maxscale = 0.8
	-- local minsclale = 0.4
	local scale = self.maxscale - (self.maxscale-self.minsclale)/2
	local Radian = self:angleToRadian(angletable[index]+180)
	local newscale = scale +  0.2 * math.sin(Radian)

	return newscale
end


function EllipseType:AccordingAngleSetPoint()
		--- y = b*sin() -- x = a * cos()
		local point = {}
		for i=1,#angletable do
			point[i] = {}
			local Angle = angletable[i]
			point[i].x = self:getEllipsePointX(Angle)
			point[i].y = self:getEllipsePointY(Angle)
		end
		return point
end


--计时器
function EllipseType:update()

	for i=1,#self.newObjectTable do
		self:AutomAticaCtionMove(self.newObjectTable[i],i)
	end
end

function EllipseType:addEventListeners()
	EventControler:addEventListener(NewLotteryEvent.REFRESH_MAIN_UI,self.addEffectAndRefreshMainUI,self)
	EventControler:addEventListener(NewLotteryEvent.ADD_EILLPSE_EFFECT,self.addEffectAndRefreshMainUI,self)

end


function EllipseType:addEffectAndRefreshMainUI()
    --转动停止 特效添加 然后继续转动

    -- local lockAnione = self:createUIArmature("UI_chouka_b","UI_chouka_b_xianshichuxian", ctn_1.currentView.ctn_1, false,function ()
    -- end)
    -- lockAnione:registerFrameEventCallFunc(15,1,function ()
    --     self:bdactionBlack2()
    --     self:dailyrefreshAllui()
    -- end)
    -- lockAnione:doByLastFrame( true, true ,function () end)

    self:setopscheduleUpdate()
    self.wirte:setTouchEnabled(false)
    self:delayCall(c_func(self.RefreshNewData, self),0.5)

end
function EllipseType:RefreshNewData()
	
	local index  = tonumber(FuncNewLottery.gettihuangIndex())
	-- echo("==========index==============",index)
	local ctn_1 =  self.newObjectTable[tonumber(index)].currentView.ctn_1
	-- if self.newObjectTable[index].currentView.mc_1 ~= nil then
	-- 	self.newObjectTable[index].currentView.mc_1:visible(false)
	-- else
	-- 	self.newObjectTable[index].currentView.UI_1:visible(false)
	-- 	self.newObjectTable[index].currentView.panel_1:visible(false)
	-- end
	local selecttype = FuncNewLottery.getlotterytype()
	local lockAnione = self.handlers:createUIArmature("UI_chouka_b","UI_chouka_b_xianshichuxian", ctn_1, false,function ()
    end)
    lockAnione:registerFrameEventCallFunc(5,1,function ()
    	if self.newObjectTable[index].currentView.mc_1 ~= nil then
			self.newObjectTable[index].currentView.mc_1:visible(false)
		else
			self.newObjectTable[index].currentView.UI_1:visible(false)
			self.newObjectTable[index].currentView.panel_1:visible(false)
		end
	end)

    lockAnione:registerFrameEventCallFunc(12,1,function ()
        if selecttype == 1 then
	    	local data = NewLotteryModel:getfreeawardpool()
	    	self:updata(data)
	    else
	    	local data = NewLotteryModel:getRMBawardpool()
	    	-- dump(data,"==========")
	    	self:updata(data)
	    end
	    self:delayCall(function ()
	    	self:openAction()
			self.wirte:setTouchEnabled(true)    	
	    end,1.0)
    end)
    lockAnione:doByLastFrame( true, true ,function () end)


    -- self:openAction()
end

function EllipseType:AutomAticaCtionMove(object,index)


	if self.moveInAnticlockwise then ---逆时针转
		--角度计算
		self.firstobjectangle = self.firstobjectangle  + self.moveXlength

	else --顺时针转
		self.firstobjectangle = self.firstobjectangle - self.moveXlength
	end

	local x = self:getEllipsePointX((360/6) * (index-1) + self.firstobjectangle ) 
	local y = self:getEllipsePointY((360/6) * (index-1) + self.firstobjectangle )
	object:setPosition(cc.p(x  ,y ))
	object:setScale(self:moveScales((360/6) * (index-1) + self.firstobjectangle))

	-- object:setScale()
	--设置Z值
	local y = object:getPositionY()
	if y < 0 then
		object:setLocalZOrder(20)
	else
		object:setLocalZOrder(-10)
	end
end
function EllipseType:moveScales(angle)
	local scale = self.maxscale - (self.maxscale-self.minsclale)/2
	local Radian = self:angleToRadian(angle+180)
	local newscale = scale +  0.2 * math.sin(Radian)
	return newscale
end

--获取对象的角度
function EllipseType:getObjectangle(object)
	local angle = nil
	local objectpointX, objectpointY= self:getobjectPoint(object)
	if objectpointY == 0 then
		if objectpointX < 0 then
			angle = 180
		else
			angle = 0
		end
	elseif objectpointX == 0 then
		if objectpointY > 0 then
			angle = 90
		else
			angle = 270
		end
	else
		if objectpointX > 0 then
			local mathtan = math.abs(math.tan(objectpointY/(objectpointX*1.0)))

			if objectpointY > 0 then
				angle = math.deg(math.atan(mathtan))
			else
				angle = 360 - math.deg(math.atan(mathtan))
			end

		elseif objectpointX < 0 then
			local mathtan = math.abs(math.tan(objectpointY/(objectpointX*1.0)))

			if objectpointY > 0 then
				angle = 360 - math.deg(math.atan(mathtan))
			else
				angle = 180 + math.deg(math.atan(mathtan))
			end
		end
	end

	return angle
end

--获取对象坐标
function EllipseType:getobjectPoint(object)
	local objectX
	local objectY    
	if object == nil then
		echo("get object point error!")
		return false
	end

	objectX = object:getPositionX()
	objectY = object:getPositionY()

	return objectX,objectY
end

--获取椭圆的X点
function EllipseType:getEllipsePointX(angle)
	local newangle = self:angleToRadian(angle)
	local x = self.EllipselengthA * math.cos(newangle)
	return  x
end

--获取椭圆的Y点
function EllipseType:getEllipsePointY(angle)
	-- return self.EllipseshortB*math.sin(self:angleToRadian(angle))
	local newangle = self:angleToRadian(angle)
	local y = self.EllipseshortB* math.sin(newangle)

	return  y
end


--点击屏幕停止旋转且减速
function EllipseType:StopRotateAndDeceleration()
	-- self:setTouchEnabled(true)
	-- self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
	-- 		local result = self:onTouch_(event)
	--         return result or false
	--     end)
end
local begantouchtime =nil
local endedtoychtime = nil

function EllipseType:onTouch_( event )

	
	self.localPosX = event.x
	if event.name == "began" then
		self.movttoout = false
		self.movewaibianjie = true
		self.chubianjiele = false
		self.chubianjielediaoyong = false
		self.localPos.x  = event.x
		self.localPos.y = event.y
		-- dump(self.localPos)
		if self.choujiangstart then
			begantouchtime = os.clock() --os.date("%S")
			self:CloseSscheduler()
			self.begagpoint = {x = event.x,y = event.y}
			self.starpoint = event.x
			return true
		else
			return false
		end
	elseif event.name == "moved" then
		--TODO --移动位置计算
		self.isXuanZhuangStop = true
		self:SelecTouchMove(event)
		if math.abs(event.x - self.localPos.x) >= 15 or math.abs(event.y - self.localPos.y) >= 15 then
			self.objectismove = true
		end

	elseif  event.name == "ended" then
		self:SelecTouchEnd(event)
	end
	
end
function EllipseType:SelecTouchMove(event)
	-- self.isXuanZhuangStop = true
	if self.isXuanZhuangStop then
		self:TouchMoved(event)

	end
end


function EllipseType:SelecTouchEnd(event)
	self:TouchMoved(event)
end

function EllipseType:huadongbianjieweizhi(event)
-- height
	if event.name == "moved" then
		local kuandedaxiaoweizhiR = display.width - (display.width - 680)/2 + 25
		local kuandedaxiaoweizhiL = (display.width - 680)/2
		if self.chubianjiele == false then
			if event.x > kuandedaxiaoweizhiR  then
				-- echo("移除边界")
				if self.movepoint.x > -self.touchmovelength and self.movepoint.x < self.touchmovelength then
					self.movttoout = true
					self.movewaibianjie = false
					self.chubianjiele = true
					self.chubianjielediaoyong = true
					return false
				end
			elseif event.x < kuandedaxiaoweizhiL then
				if self.movepoint.x > -self.touchmovelength and self.movepoint.x < self.touchmovelength then
					self.movttoout = true
					self.movewaibianjie	 = false
					self.chubianjiele = true
					self.chubianjielediaoyong = true
					return false
				end
			end
		end
	end
	return true

end

--点击状态移动
function EllipseType:TouchMoved(event)
	-- self.begagpoint
	if event.name == "moved" then
		if self.movttoout == false then
			self.movepoint.x = event.x - self.begagpoint.x
			self.begagpoint.x = event.x
			self.speed.x =  self.localPosX - event.prevX
			self:moveScroll(self.movepoint.x/4.0)
		end
		-- self.movepoint.x = event.x - self.begagpoint.x

		-- echo("========self.localPos.x - event.x=======",self.localPos.x - event.x)
		if self.chubianjiele == false then
				self:huadongbianjieweizhi(event) 
				if math.abs(self.localPos.x - event.x) >= huadongMaxJuli then   ---超过滑动距离
					if self.movewaibianjie then
						if self.speed.x > 0 then
							self.moveInAnticlockwise = true
						else
							self.moveInAnticlockwise = false
						end

						if self.movepoint.x > -self.touchmovelength and self.movepoint.x < self.touchmovelength then
							-- print('返回到原位置，力度都不够')
							WindowControler:showTips('滑动力度太小,转不动')
							-- if self.speed.x > 0 then
							-- 	self.speed.x = math.random(30,100)
							-- else
							-- 	self.speed.x = math.random(30,100)
							-- 	self.speed.x = -self.speed.x
							-- end
							self.movelidu = false
						elseif self.movepoint.x > -150 and self.movepoint.x < 150 then
							if self.speed.x > 0 then
								self.speed.x = math.random(30,100)
							else
								self.speed.x = math.random(30,100)
								self.speed.x = -self.speed.x
							end
							self.movelidu = true
						elseif self.movepoint.x > -200 and self.movepoint.x < 1000 then
							if self.speed.x > 0 then
								self.speed.x = math.random(150,250)
							else
								self.speed.x = math.random(150,250)
								self.speed.x = -self.speed.x
							end
							self.movelidu = true
						end
						if self.movelidu then
							local file = self:judgeLotteryType()
							self.movttoout = true
							self.movewaibianjie = false
							self.choujiangstart  = false
							if file then
								self._scrollDistance = 0
								echo("===========time===============",os.clock())
								self:twiningScroll()
								EventControler:dispatchEvent(NewLotteryEvent.START_LOTTERY)   --开始抽奖
							else
								-- self.wirte:setTouchEnabled(false)
								-- self:delayCall(function ()
								-- 	self.wirte:setTouchEnabled(true)
								-- end,0.5)
							end
						else
							self.movttoout = true
							self.movewaibianjie = false
							self:openAction()
						end
					end

				end
			
		else
			if self.chubianjielediaoyong then    --出边界的时候
				WindowControler:showTips("滑动力度太小,转不动")
				self.movttoout = true
				self.movewaibianjie = false
				self.chubianjielediaoyong = false
				self:openAction()
			end
		end

	elseif  event.name == "ended" then
		-- 先判断是否在转，如果没有，就开始转，如果有，就不让其转动
		--TODO  开始转
		---获取是选择抽奖几次 来得知显示第一个对象
		-- local selectRewardItems =   10
		
		if self.movttoout == false then
			self.endmovespoint = self.localPos.x - event.x
			if math.abs(self.endmovespoint) > huadongMaxJuli then
				if self.movepoint.x > -self.touchmovelength and self.movepoint.x < self.touchmovelength then
					WindowControler:showTips('滑动力度太小,转不动')
					if self.speed.x > 0 then
						self.moveInAnticlockwise = true
					else
						self.moveInAnticlockwise = false
					end
					self:openAction()
				else
					-- self:judgeLotteryType()
					-- self._scrollDistance = 0
					-- self.choujiangstart  = false
					-- self:twiningScroll()
					-- EventControler:dispatchEvent(NewLotteryEvent.START_LOTTERY)   --开始抽奖
				end
			else
				if self.speed.x > 0 then
					self.moveInAnticlockwise = true
				else
					self.moveInAnticlockwise = false
				end
				self:openAction()
				if  math.abs(begantouchtime - os.clock())  > 0.2 then
					WindowControler:showTips("滑动距离太短,转不动")
				end
			end
		else
			self.movttoout = false
		end
		self.choujiangstart = true
		self.chubianjiele = false
	end
end
function EllipseType:judgeLotteryType()
	--发送抽奖协议
		local lottterytype= nil
		local types = FuncNewLottery.getlotterytype()

		if types == FuncNewLottery.lotterytypetable[1] then   ---免费抽 0 1 5
			local successfile,errorid = NewLotteryModel:FreeCanlottery()
			if successfile then
				local items = FuncNewLottery.getlotteryFreeType()   -- 1 ，5
				local time = NewLotteryModel:getCDtime()
				if items == 1 then    ----1次
					if time == 0 then
						if NewLotteryModel:getLotterynumber() >= 5 then
							lottterytype = 1
						else
							lottterytype = 0
						end
					else
						local card = NewLotteryModel:getordinaryDrawcard()
						lottterytype = 1
					end
				else     ---5次
					lottterytype = 5
				end
				local newsuccessfile,errorid = NewLotteryModel:FreeCanlottery()
				if newsuccessfile == true then
				-- echo("===sendserver================",lottterytype)
					NewLotteryServer:freeDrawcard(lottterytype,c_func(self.lotteryFreeResult,self))
					return true
				else
					return false
				end
			else
				if self.speed.x > 0 then
					self.moveInAnticlockwise = true
				else
					self.moveInAnticlockwise = false
				end
				FuncNewLottery.getfreeIDerror(errorid)
				self:openAction()
				return false
			end
		elseif types ==  FuncNewLottery.lotterytypetable[2] then ---元宝抽
			local RMBCanlottery,errorid = NewLotteryModel:RMBCanlottery()
			if RMBCanlottery then
				local isGold = nil
				local types = nil
				local seniorDrawcard = NewLotteryModel:getseniorDrawcard()   --高级抽奖卡
			    local RMBonce = NewLotteryModel:getRMBoneLottery() --是否花费元宝抽抽奖
			    local RMBfirstlottery =  NewLotteryModel:getRMBPayLottery()   ---第一次元宝抽
			    local items = FuncNewLottery.getlotteryRMBType()   -- 1 ，10
			    if items == 1 then
				    if RMBonce ~= 0 then
				    	if seniorDrawcard > 0 then
				    		types = 1
				    		isGold = false
				    	else
				    		types = 1
				    		isGold = true
				    	end
				    else
				    	types  = 0
				    	isGold = false
				    end
			   	else
			   		if seniorDrawcard > 10 then
			   			types = 10
			   			isGold = false
			   		else
			   			if UserModel:getGold() > FuncNewLottery.consumeTenRMB() then
			   				types = 10
			   				isGold = true
			   			else
			   				types = 10
			   				isGold = false
			   			end
			   		end
			   	end
			   	-- echo("=====sendserver===================",types,isGold)
			   	local RMBCanlotterys,errorid = NewLotteryModel:RMBCanlottery()
			   	if RMBCanlotterys == true then
					NewLotteryServer:consumeDrawcard(types,isGold,c_func(self.lotteryRMBResult,self))
					return true
				else
					return false
				end
			else
				if self.speed.x > 0 then
					self.moveInAnticlockwise = true
				else
					self.moveInAnticlockwise = false
				end
				self:openAction()
				FuncNewLottery.getRMBIDerror(errorid)
				return false
			end
		end

end
function EllipseType:lotteryFreeResult(result)
	-- dump(self.data,"上一次的数据")
	self.result = result
	-- dump(result,"免费抽获得的结果")
	if result.error ~= nil then
		self.serverdata = true
		WindowControler:showTips("服务器返回错误 code ="..result.error.code)
		self:GetServerDataobjectID(math.random(1,6))
		return
	end
	local objectdata = result.result.data.reward
	local objectId = nil
	-- for k,v in pairs(objectdata) do
	-- 	objectId = tonumber(k)
	-- end
	local freedata =  NewLotteryModel:getfreeawardpool()
	local selects = FuncNewLottery.getlotteryFreeType()
	if selects == 1 then
		for k,v in pairs(result.result.data.dirtyList.u.lotteryCommonPools) do
			objectId = tonumber(k)
			newserverdata = result.result.data.dirtyList.u.lotteryCommonPools
			tihuangID = tonumber(k)
		end
		-- NewLotteryModel:settihuangAward(newserverdata,objectId)
	else
		if #objectdata == 1 then 	
			for k,v in pairs(freedata) do
				if v == objectdata[1][1] then
					objectId = k
				end
			end
		else
			for k,v in pairs(freedata) do
				objectId = k
			end
		end 
		-- NewLotteryModel:settihuangAward(newserverdata,objectId)
	end
	NewLotteryModel:settihuangAward(newserverdata,objectId)
	local cds  = result.result.data.dirtyList.cds
	local starttime = result.result.serverInfo.serverTime
	local expiretime = nil
	if cds ~= nil then
		expiretime = cds[tostring(1)].expireTime
		NewLotteryModel:setCDStime(starttime,expiretime)
	end
	-- echo("============freeobjectId=========",objectId)
	self:GetServerDataobjectID(objectId)
	NewLotteryModel:setServerData(objectdata)
	EventControler:dispatchEvent(NewLotteryEvent.REFRESH_FREE_UI)---刷新界面数据
end
function EllipseType:lotteryRMBResult(result)
	-- dump(self.data,"上一次的数据")
	-- dump(result,"元宝抽获得的结果")
	self.result = result
	if result.error ~= nil then
		self.serverdata = true
		self:GetServerDataobjectID(math.random(1,6))
		WindowControler:showTips("服务器返回错误 code ="..result.error.code)
		return
	end
	local objectdata = result.result.data.reward
	local objectId = nil

	local selects = FuncNewLottery.getlotteryRMBType()
	local freedata =  NewLotteryModel:getRMBawardpool()
	local tihuangID = nil
	local newserverdata = nil
	if selects == 1 then
		for k,v in pairs(result.result.data.dirtyList.u.lotteryGoldPools) do
			objectId = tonumber(k)
			newserverdata = result.result.data.dirtyList.u.lotteryGoldPools
			tihuangID = tonumber(k)
		end
		
	else
		if #objectdata == 1 then
			for k,v in pairs(freedata) do
				if v == objectdata[1][1] then
					objectId = k
				end
			end
		else
			for k,v in pairs(freedata) do
				objectId = k
			end
		end 
	end

	NewLotteryModel:settihuangAward(newserverdata,objectId)
	-- echo("============RMBobjectId=========",objectId)
	self:GetServerDataobjectID(objectId)
	NewLotteryModel:setServerData(objectdata)
	EventControler:dispatchEvent(NewLotteryEvent.REFRESH_RMBPAY_UI)---刷新界面数据
	

end
---设置速度【2】
function EllipseType:scrollSpeed(Speedvaluer)
	self.scrollSpeed = Speedvaluer
	return self.scrollSpeed
end
function EllipseType:twiningScroll()
	-- echo("===222222222==========",self.speed.x)
	
	self._scrollDistance =  self.speed.x * self.scrollSpeed
	self.serverdata = false
	local randoms = nil

	if math.abs(self.speed.x) > 150 then
		self.maxquanshu = math.random(4,6)  --测试数据
		randoms = math.random(3,5)
	else
		self.maxquanshu = math.random(2,4)
		randoms = math.random(3,4)
	end

	if self.speed.x > 0 then
		if math.abs(self._scrollDistance) > TurnSumLength then
			self._scrollDistance = TurnSumLength
		end
	else
		if math.abs(self._scrollDistance) > TurnSumLength then
			self._scrollDistance = -TurnSumLength
		end
	end

	self.movejuli = self._scrollDistance/randoms
	self.tianjiaxuanzhuaneffect = true
	self.XunzhaunlockAnione = nil
	self:scheduleUpdateWithPriorityLua(handler(self, 
        self.deaccelerateScrolling), 0);
	 self:setsprinttouchu(false)
	-- self:addXuanzhuangEffect()

end
function EllipseType:addXuanzhuangEffect()
   -- self.panel_fangda
   AudioModel:stopMusic()
   audio.pauseAllSounds()
   AudioModel:playSound(MusicConfig.s_scene_Luck_turn,false)

   self.XunzhaunlockAnione = self.handlers:createUIArmature("UI_chouka_a","UI_chouka_a_xuzhuanfeng", self.handlers.panel_fangda, true,function ()end)
   -- self.XunzhaunlockAnione:doByLastFrame( true, true ,function () end)
   self.XunzhaunlockAnione:setPosition(cc.p(360,-125))
   
	if self.moveInAnticlockwise then
		self.XunzhaunlockAnione:runAction(act.scaleto(1,1.2,1.2))
	else
		self.XunzhaunlockAnione:setScaleX(-1)
		self.XunzhaunlockAnione:runAction(act.scaleto(1,-1.2,1.2))
	end


end
function EllipseType:setsprinttouchu(file)
	self.wirte:setTouchEnabled(file)
end
--获得服务器的数据
function EllipseType:GetServerDataobjectID(objectID)
	if objectID == nil then
		-- math.randomseed(os.time())
		objectID = math.random(1,6)
		-- objectID = 1
	end
	self.objectindexPointID = objectID
	-- TODO
	local yidongjiaodu = 270
	local angle = 360/6*(objectID - 1) + self.firstobjectangle
	local objectangle =  math.fmod(math.floor(angle),360)
	local pianyi = nil
	-- echo("===========self._scrollDistance===================",self._scrollDistance)
	if self._scrollDistance > 0 then  --向右转
		if objectangle > yidongjiaodu then
			objectangle = 360 - objectangle + yidongjiaodu
		else
			objectangle =  yidongjiaodu - objectangle
		end
		pianyi = -3
	else    --向左转
		if objectangle > yidongjiaodu then
			objectangle = objectangle - yidongjiaodu
		else
			objectangle =  objectangle + 90
		end
		pianyi = -14

	end
	--获得加速度
	self.acceleration =  (self.movejuli * self.movejuli)/(2*(360*self.maxquanshu+objectangle-pianyi))
	self.serverdata = true
	-- self:addfiveAndTenceEffect(5)
	local lotteryfreeitmes = FuncNewLottery.getlotteryFreeType()
	local lotteryrmbitems =  FuncNewLottery.getlotteryRMBType()
	local electtype = FuncNewLottery.getlotterytype()
	if electtype == 1 then  --免费
			if lotteryfreeitmes == 1 then
				-- self:effectshow()
			else
				self:addfiveAndTenceEffect(5)
				-- WindowControler:showWindow("NewLotteryJieGuoView")
			end

	else   --元宝
		if lotteryrmbitems == 1 then
			-- self:effectshow()
		else
			self:addfiveAndTenceEffect(10)
			-- WindowControler:showWindow("NewLotteryJieGuoView")
		end
	end
end
function EllipseType:ReturnToOriginalPosition()  --回到目标位置
	local angle = 360/6*(self.objectindexPointID - 1) + self.firstobjectangle
	local objectangle =  math.fmod(math.floor(angle),360)
	if self.firstobjectangle > 0 then
		if objectangle >= 260 then
			
			self.blackmovejuli = 1
			self:setopscheduleUpdate()
			self:xiaoshitubiao(self.objectindexPointID)
			self:choujiangkaishi()
		else
			self.blackmovejuli = self.blackmovejuli + 0.005
		end
	else
		if math.abs(objectangle) <= 98 then
			self.blackmovejuli = 1
			self:setopscheduleUpdate()
			self:xiaoshitubiao(self.objectindexPointID)
			self:choujiangkaishi()
		else
			self.blackmovejuli = self.blackmovejuli + 0.005
		end
	end
	-- self:choujiangkaishi()
	self:moveScroll(self.blackmovejuli)

end
function EllipseType:xiaoshitubiao( index )
	if self.newObjectTable[tonumber(index)].currentView.mc_1 ~= nil then
		self.newObjectTable[tonumber(index)].currentView.mc_1:visible(false)
	else
		-- self.newObjectTable[i].currentView.UI_1:visible(false)
		self.newObjectTable[tonumber(index)].currentView.UI_1:visible(false)
		self.newObjectTable[tonumber(index)].currentView.panel_1:visible(false)
		-- self.newObjectTable[i]:showFrame(5)
	end
end
function EllipseType:choujiangkaishi() 
	if self.result.result ~= nil then
		-- WindowControler:showTips("显示获奖界面")

		local lotteryfreeitmes = FuncNewLottery.getlotteryFreeType()
		local lotteryrmbitems =  FuncNewLottery.getlotteryRMBType()
		local electtype = FuncNewLottery.getlotterytype()
		if electtype == 1 then  --免费
				if lotteryfreeitmes == 1 then
					self:effectshow()
					-- if self.XunzhaunlockAnione ~= nil then
						-- self.XunzhaunlockAnione:doByLastFrame( true, true ,function () end)
						-- self.XunzhaunlockAnione = nil
					-- end
				else
				-- WindowControler:showWindow("NewLotteryJieGuoView")
				end

		else   --元宝
			if lotteryrmbitems == 1 then
				self:effectshow()
				-- if self.XunzhaunlockAnione ~= nil then
					-- self.XunzhaunlockAnione:doByLastFrame( true, true ,function () end)
					-- self.XunzhaunlockAnione = nil
				-- end
			else
				-- WindowControler:showWindow("NewLotteryJieGuoView")
			end
		end
	else
		EventControler:dispatchEvent(NewLotteryEvent.BLACK_LOTTERY_MAIN)
	end
end
function EllipseType:ReturnToOriginalPositionFS() --向左开始 -
	local angle = 360/6*(self.objectindexPointID - 1) + self.firstobjectangle
	local objectangle =  math.fmod(math.floor(angle),360)
	if self.firstobjectangle > 0 then
		if objectangle <= 260 then
			
			self.blackmovejuli = -1
			self:setopscheduleUpdate()
			self:xiaoshitubiao(self.objectindexPointID)
			self:Lchoujiangkaishi()
		else
			self.blackmovejuli = self.blackmovejuli - 0.005
		end
	else
		if math.abs(objectangle) >= 95 then
			self.blackmovejuli = -1
			self:setopscheduleUpdate()
			self:xiaoshitubiao(self.objectindexPointID)
			self:Lchoujiangkaishi()
		else
			self.blackmovejuli = self.blackmovejuli - 0.005

		end
	end
	self:moveScroll(self.blackmovejuli)

end
function EllipseType:Lchoujiangkaishi()
	if self.result.result ~= nil then
	-- WindowControler:showTips("显示获奖界面")
	-- WindowControler:showWindow("NewLotteryJieGuoView")

		local lotteryfreeitmes = FuncNewLottery.getlotteryFreeType()
		local lotteryrmbitems =  FuncNewLottery.getlotteryRMBType()
		local electtype = FuncNewLottery.getlotterytype()
		if electtype == 1 then  --免费
				if lotteryfreeitmes == 1 then
					self:effectshow()
				else
				end

		else   --元宝
			if lotteryrmbitems == 1 then
				self:effectshow()
			else
			end
		end
	else
		EventControler:dispatchEvent(NewLotteryEvent.BLACK_LOTTERY_MAIN)
	end

end
function EllipseType:XunzhaunlockAnionerunAction()
	-- self.__bgView:runAction(scaleAnim)
	if self.XunzhaunlockAnione ~= nil then
		local fadeout = act.fadeout(0.2)
		local fadinAnim = act.sequence(fadeout,act.callfunc(function ()
			self.XunzhaunlockAnione:doByLastFrame( true, true ,function () end)
			self.XunzhaunlockAnione = nil
		end))
		self.XunzhaunlockAnione:runAction(fadinAnim)
		
	end
end
--缓动
local alreadangle = 0
function EllipseType:deaccelerateScrolling()
	
	if self._scrollDistance > 0 then   ---向右
		--想判断转了多少圈
		--获得服务器数据开始匀减速
		if self.serverdata then
			self.movejuli = self.movejuli - self.acceleration

			if self.movejuli <= 1.5 then
				self:setopscheduleUpdate()
				self.sendserverdsts = false 
				-- self:setTouchEnabled(true)
				self.serverdata = false
				self.choujiangstart = true
				-- echo("============self.firstobjectangle=========",self.firstobjectangle)
				-- slef.objectindexPointID
				local angle = 360/6*(self.objectindexPointID - 1) + self.firstobjectangle
				local objectangle =  math.fmod(math.floor(angle),360)
				self:XunzhaunlockAnionerunAction()
				self.blackmovejuli = 1 
				self:scheduleUpdateWithPriorityLua(handler(self, self.ReturnToOriginalPosition), 0);
			elseif self.movejuli <= 5 then
				FuncArmature.setArmaturePlaySpeed(self.XunzhaunlockAnione,0.5)
			end
		else
			---没有服务器数据，开始匀速旋转
			self.movejuli = self.movejuli
		end
	else
		--想判断转了多少圈
		--获得服务器数据开始匀减速
		if self.serverdata then
			self.movejuli = self.movejuli + self.acceleration

			if self.movejuli >= -3 then
				-- self:setTouchEnabled(true)
				-- echo("============self.firstobjectangle=========",self.firstobjectangle)
				self.sendserverdsts = false
				self:setopscheduleUpdate()
				self.serverdata = false
				self.choujiangstart = true
				local angle = 360/6*(self.objectindexPointID - 1) + self.firstobjectangle
				local objectangle =  math.fmod(math.floor(angle),360)
				FuncArmature.setArmaturePlaySpeed(self.XunzhaunlockAnione,0.5)
				self:XunzhaunlockAnionerunAction()
				self.blackmovejuli = -1 
				self:scheduleUpdateWithPriorityLua(handler(self, self.ReturnToOriginalPositionFS), 0);	
			elseif self.movejuli >= -8 then
				FuncArmature.setArmaturePlaySpeed(self.XunzhaunlockAnione,0.5)
				
			end
			-- self:Lchoujiangkaishi()

		else
			---没有服务器数据，开始匀速旋转
			self.movejuli = self.movejuli
		end

	
	end
	self:moveScroll(self.movejuli)
	if self.tianjiaxuanzhuaneffect then
		self:addXuanzhuangEffect()
		self.tianjiaxuanzhuaneffect = false
	end
end
local effevtname = {
	[1] = "UI_chouka_b_bai",
	[2] = "UI_chouka_b_lv",
	[3] = "UI_chouka_b_lan",
	[4] = "UI_chouka_b_zi",
	[5] = "UI_chouka_b_jin",

}
local Scalenumbertable = {
	[1] = 1.0,
	[2] = 0.8,
	[3] = 0.6,
	[4] = 0.5,
	[5] = 0.6,
	[6] = 0.8,
}
function EllipseType:addfiveAndTenceEffect(number)
		-- self.result
		-- audio.pauseAllSounds()
		self.showeffectqulity = {}
		local data = self.result.result.data.lotteryIds
		-- dump(self.result.result)
		-- dump( self.result.result.data.reward)
		for i=1,#data do
			self.showeffectqulity[i] =  FuncNewLottery.getIDLotteryData(data[i]).quality
		end
		-- FuncNewLottery.getlotteryFreeType()
		local rmbselecttype = FuncNewLottery.getlotteryRMBType()
		local selecttype = FuncNewLottery.getlotterytype()
		if selecttype == 2 then
			if rmbselecttype == 10 then
				if #data ~= 10 then
					local numbers = 10-#data
					for i=1,numbers do
						self.showeffectqulity[#data+i] = 5
					end
				end
			end
		end
		-- local effectpoint = math.random(1,10)

		self.newctn = {
			[1] = self.handlers.panel_fangda.ctn_s1,
			[2] = self.handlers.panel_fangda.ctn_s2,
			[3] = self.handlers.panel_fangda.ctn_s3,
			[4] = self.handlers.panel_fangda.ctn_s4,
			[5] = self.handlers.panel_fangda.ctn_s5,
			[6] = self.handlers.panel_fangda.ctn_s6,
		}


		-- local lockAni = self.handlers:createUIArmature("UI_chouka_b","UI_chouka_b_jin", ctn_1, false,function () end)
		self.lastindex = {}
		self:PlayfiveAndTenEffect(1,number)

end
function EllipseType:PlayfiveAndTenEffect(index,number)
	if index > number then
		return
	end
	-- dump(self.showeffectqulity)
	local effectnames = effevtname[tonumber(self.showeffectqulity[index])]
	-- echo("=================",effectnames)
	-- local ctn_1 = index-- showeffectqulity[index]
	local freeitems = FuncNewLottery.getlotteryFreeType()
	local selecttype = FuncNewLottery.getlotterytype()
	local randoms = math.random(1,6)
	if selecttype == 1 then
		if freeitems == 5 then
			for i=1,#self.lastindex do
				if randoms == self.lastindex[i] then
					randoms = randoms + 1
					if randoms > 6 then
						randoms = randoms - 1
					end
					if randoms <= 0 then
						randoms = randoms + 1 
					end
				end
			end
		end
	end
	if tonumber(self.showeffectqulity[index]) >= 4 then
		randoms = math.random(1,3)
		if randoms == 3 then
			randoms = 6
		end
	end
	self.lastindex[index] = randoms
	self.ctn = self.newctn[randoms]
	self.ctn:setLocalZOrder(20)
	-- AudioModel:playSound(MusicConfig.s_scene_luck_single)
	local lockAni = self.handlers:createUIArmature("UI_chouka_b",effectnames, self.ctn, false,function () 
			if index > number then
				if self.XunzhaunlockAnione ~= nil then
					self.XunzhaunlockAnione:visible(false)
					self.XunzhaunlockAnione:doByLastFrame( true, true ,function () end)
				end
				audio.pauseAllSounds()

				self:JumpToNewLotteryJieGuoView()
				-- WindowControler:showWindow("NewLotteryJieGuoView")
				return
			end
	end)
	lockAni:setScale(Scalenumbertable[randoms])
	FuncArmature.setArmaturePlaySpeed(lockAni,1.5)
	lockAni:doByLastFrame( true, true ,function () end)
	index = index + 1

	self:delayCall(c_func(self.PlayfiveAndTenEffect, self,index,number,showeffectqulity),0.15)


end
--跳转到结果界面
function EllipseType:JumpToNewLotteryJieGuoView()
	-- if audio.isMusicPlaying() then
 --        AudioModel:stopMusic()
 --    end
    AudioModel:stopMusic()
    -- audio.pauseAllSounds()
	WindowControler:showWindow("NewLotteryJieGuoView")
end
function EllipseType:effectshow()
	-- s_scene_luck_single
	-- audio.setSoundsVolume(0.3)
	-- self:delayCall(function ()
		audio.pauseAllSounds()
	-- 	audio.setSoundsVolume(1)
	-- end,0.5)

	AudioModel:playSound(MusicConfig.s_scene_luck_single)
	local index,quality = NewLotteryModel:getihuangIndex()
	local ctn_1 = self.newObjectTable[tonumber(index)].currentView.ctn_1
    local lockAni = self.handlers:createUIArmature("UI_chouka_b","UI_chouka_b_jin", ctn_1, false,function ()
        self:JumpToNewLotteryJieGuoView()
    end)
    lockAni:registerFrameEventCallFunc(35, 1, function ()
    	-- self:JumpToNewLotteryJieGuoView()
    end)
	lockAni:registerFrameEventCallFunc(5,1,function ()
		if self.newObjectTable[tonumber(index)].currentView.mc_1 ~= nil then
			self.newObjectTable[tonumber(index)].currentView.mc_1:visible(false)
		else
			self.newObjectTable[tonumber(index)].currentView.UI_1:visible(false)
			self.newObjectTable[tonumber(index)].currentView.panel_1:visible(false)
		end
	end)
	lockAni:doByLastFrame( true, true ,function () end)

end

function EllipseType:moveScroll(length)
	
	--长度转换成角度 偏移角度
	local angle = self:getAngleFromOffset(length)
	-- -- --传入角度

	self:RotatePosition(length)



end

--停止转动
function EllipseType:StopTurning()

	AcceleratedRotation = true

end

--获得偏移角
function EllipseType:getAngleFromOffset(offset)
	if (offset ~= 0)  then
		return self:radianToAngle(math.atan(offset/self.EllipseshortB*0.1)) --//偏移角  
    else 
    	return 0; 
    end
end

--点击状态结束
function EllipseType:TouchEnded()
	-- body
end
--移动旋转位置
local x= 0
function EllipseType:RotatePosition(angle)
	-- tlength[i] = tlength[i]  + angle

	self.firstobjectangle = self.firstobjectangle  + angle
	for i=1,#self.newObjectTable do
		-- self.newObjectTable[i]:setPosition(self:gettuoyuanPointAt(tlength[i]))
		local x = self:getEllipsePointX((360/6) * (i-1) + self.firstobjectangle ) 
		local y = self:getEllipsePointY((360/6) * (i-1) + self.firstobjectangle )
		self.newObjectTable[i]:setPosition(cc.p(x  ,y ))
		self.newObjectTable[i]:setScale(self:moveScales((360/6) * (i-1) + self.firstobjectangle))

		local x = self.newObjectTable[i]:getPositionX()
		local y = self.newObjectTable[i]:getPositionY()
		if y < 0 then
			self.newObjectTable[i]:setLocalZOrder(20)--setLocalZOrder
		else
			self.newObjectTable[i]:setLocalZOrder(-10)
		end
	end
end
function EllipseType:gettuoyuanPointAt(angle)
	local x = self:getEllipsePointX(angle)
	local y = self:getEllipsePointY(angle)
	return cc.p(x,y)

end


--获取点击屏幕点
function EllipseType:getTouchpingmuPoint(event)
	return event.x, event.y
end

--判断回到原始位置
function EllipseType:judgeBackToPoint()
	-- local blackfile = false
	local zuijingpoint = nil
	local indexobject = nil
	for i=1,#self.newObjectTable do
		local pointX = self.newObjectTable[i]:getPositionX()
		local pointY = self.newObjectTable[i]:getPositionY()
		if pointY <= 0 then
			if zuijingpoint == nil then
				zuijingpoint = pointX
				indexobject = i
			else
				if pointX < 0 then
					if math.abs(pointX) < math.abs(zuijingpoint) then
						zuijingpoint = pointX
						indexobject = i
					end
				end
			end
		end
	end
	return self.newObjectTable[indexobject]
end
--退出关闭计时器
function EllipseType:CloseSscheduler(touchlongtime)
	self:setopscheduleUpdate()
end


--点击时间未到开启旋转
-- 回到原始位置
function EllipseType:TouchOpenAction(openfile)
	if  openfile == false then
		self.openfile = openfile
		self:openAction()
	else
		self.blacklength = 0
		self.openfile = openfile
		self:openAction()
		-- self:scheduleUpdateWithPriorityLua(handler(self, 
  --       self.everymoveScroll), 0);
	end
end
function EllipseType:setopscheduleUpdate()
	self:unscheduleUpdate()
end
--获得服务器的数据
function EllipseType:getobjectIDpoint(objectID)
	if objectID == nil then
		objectID = 1
	end
	-- TODO
	self.severDataobject = self.newObjectTable[objectID]

end
function EllipseType:everymoveScroll()
		

	local newangle  = self:getAngleFromOffset(self.blacklength)

	local oldangle  = 270 - (self:getObjectangle(self.zuiijngobject)-5)
	if newangle  > oldangle then
		self.blacklength = 0
		self:setopscheduleUpdate()
		-- self.zuiijngobject:setScale(0.8)
	end
	self.blacklength = self.blacklength + 1

	self:moveScroll(self.blacklength)


end

-- 弧度转换到角度  
function EllipseType:radianToAngle(radian) 
	return radian * 180 / M_PI; 
end
-- 角度转换到弧度
function EllipseType:angleToRadian(angle)
	return angle * M_PI / 180;
end
return EllipseType