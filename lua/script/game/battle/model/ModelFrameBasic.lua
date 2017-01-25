--
-- Author: Your Name
-- Date: 2014-03-06 20:12:30
--
ModelFrameBasic = class("ModelFrameBasic", ModelHitBasic)

ModelFrameBasic.label = Fight.actions.action_stand   --动作标签 1站立 默认标签

ModelFrameBasic.frame = 0 		--当前帧数

--[[ 每一个动作的属性     
							
	actionFrame = {2,2} 1表示readyFrame, 2表示 finishFrame,3表示returnFrame(也就是这个动作的帧长度) 在哪一帧可以被操作打断 比如 按攻击键的时候 至少要到第4帧才可以进行ready跳转
	第一个数表示能被ready打断的帧数  第2个数表示能被finish级别打断的帧数
]]
ModelFrameBasic.actionFrame = nil 		
ModelFrameBasic.actionFinish = nil  --主要用来标记 动作恢复 是否需要等这个动画播放完毕才恢复为站立

--当前事件数据
ModelFrameBasic.eventData = nil 	--当前事件数据
--是否帧事件改变了动作
ModelFrameBasic.eventChangeAction = false
--记录当前动作已经执行过的函数
ModelFrameBasic.noteFrameEvent = nil 
--判断是否启动frame 有些 召唤物 也是有生命的  但是 不需要  启用 这个动画管理类
ModelFrameBasic.isFrameAction = true -- 判断是否需要多动作管理

--记录跟随主角动作的特效数组 
--[[
	stand = aniArr

]]
ModelFrameBasic.followActionAniObj  = nil

function ModelFrameBasic:ctor( ... )
	self.actionFinish = false
	self.noteFrameEvent = {}
	self.actionFrame = {}
	self.followActionAniObj = {}
	ModelFrameBasic.super.ctor(self,...)
end


function ModelFrameBasic:initData( data )
	ModelFrameBasic.super.initData(self,data)

	--如果不是多动画的对象
	if not self.viewData.actionFrames then
		self.isFrameAction =false
	end

	if not self.isFrameAction then
		return
	end

	self:changeActionInitFramDatas(Fight.actions.action_stand , 1, true)
	
	return self
end


--判断是否具有某个label --根据配置数据判断 不要根据 试图判断
function ModelFrameBasic:checkHasLabel( label )
	if not self.isFrameAction then
		return false
	end

	if self.viewData.actionFrames[self.sourceData[label] ] then
		return true
	end
	return false
end


------------------------------------------------------------------------------
--帧事件
function ModelFrameBasic:dummyFrame( )
	--如果是动画停帧的
	if self.selfPause then
		return
	end

	if not self.isFrameAction then
		return
	end

	self.frame = self.frame + 1

	if self.frame >= self.actionFrame[1] then
		self.actionFinish =  true
	end


	--是否循环播放 如果想看到最后一帧 那么 就等到最后一帧大于0的时候恢复帧为0
	if self.frame > self.totalFrames then
		self:resumeEvent()
		self:initFrameParameter(true)

		self.frame = 1
	end

	self:frameEvent()
end

------------------------------------------------------------------------------
--- 播放二段胜利动画
function ModelFrameBasic:aniPlayNextIndex()
	self.myView.currentAni:getAnimation():playWithIndex(1,0,1)
end
--动作还原
function ModelFrameBasic:resumeEvent(  )
	if not self.isFrameAction then
		return
	end

	if not self.actionFinish then
		return
	end

	if self.label == Fight.actions.action_stand then
		if self.logical.currentCamp ~= self.camp then
			self:gotoFrame(Fight.actions.action_stand2 )
		end
	end

	-- 如果是循环动作不复原
	if self:checkIsCysAtcion(self.label) then
		return
	end

	if self.myState =="stand" then
		self:gotoFrame(Fight.actions.action_stand )
	elseif self.myState =="walk" then
		self:gotoFrame(Fight.actions.action_run )
	end
end


--判断是否是循环动作
function ModelFrameBasic:checkIsCysAtcion( label )
	if label == Fight.actions.action_run or label == Fight.actions.action_walk 
		or label == Fight.actions.action_giveOutBM or label == Fight.actions.action_win
		or label == Fight.actions.action_readyLoop or label == Fight.actions.action_standSkillLoop
		then
		return true
	end
	return false
end

------------------------------------------------------------------------------
--帧事件
function ModelFrameBasic:frameEvent( )	
	local eventData =self.eventData
	if not eventData then
		return 
	end

	self.eventChangeAction =false
	local funcArr,frameArr,i,j,k
	local targetFrame
	for i,info in ipairs(eventData) do
		local firstPara = info[1]
		--帧数组
		local frameArr = info[2]
		funcArr = info[3]
		--如果是数字  那么就表示当前帧
		--如果是1表示 指定帧做什么事情
		if firstPara==1 then
			for j,k in ipairs(frameArr) do
				targetFrame = k < 0 and  self.totalFrames+ k +1  or k 
				if targetFrame==self.frame then
					self:runFuncArr(funcArr)
					--如果改变动作了					
					if self.eventChangeAction then
						return
					end
				end
			end

		--如果是连续帧做什么事情
		elseif firstPara == 2 then
			local frame1 = frameArr[1]
			frame1 = frame1 <0 and self.totalFrames + frame1 +1 or frame1
			local frame2 = frameArr[2]
			frame2 = frame2 < 0 and self.totalFrames+frame2 + 1 or frame2
			local interval = frameArr[3] and frameArr[3]  or 1

			--必须当前帧数在中间
			if self.frame>=frame1 and self.frame <= frame2 then
				
				--必须达到执行间隔
				if (self.frame - frame1) % interval ==0 then
					self:runFuncArr(funcArr)
					--如果改变动作了
					if self.eventChangeAction then
						return
					end
				end
			end
		end
	end
end

--运行函数数组 有info[3]循环动作也会只做一次事件
function ModelFrameBasic:runFuncArr( funArr )
	
	for i,info in ipairs(funArr) do
		local func = self[info[1]]
		local params = info[2]
		if not func then
			echoError("这个对象这个函数:",info[1])
		end
		--如果表示在改变动作之前 该函数只执行一次 那么就return
		if not info[3] or table.indexof(self.noteFrameEvent, info[1])  == false  then
			local turn 
			if params then
				if type(params) ~= "table" then
					func(self,params)
				else
					func(self,unpack(params))
				end
			else
				func(self)
			end
		end

		if info[3] then
			table.insert(self.noteFrameEvent, info[1])
		end

	end	
end

------------------------------------------------------------------------------


--改变动作
--where 跳转到的动作
-- what用哪种方式跳转
--whichframe 跳转到那一帧
--all 是否可以重复跳转到相同的动作 true 表示一样的动作也跳转
function ModelFrameBasic:changeAction(where,whatFunc,whichFrame,all)
	if not whatFuc then
		whatFunc = "gotoFrame"
	end

	if not whichFrame then whichFrame = 1 	end
	self[whatFunc](self,where,whichFrame,all)
end

-- 最普通的跳转动作
function ModelFrameBasic:gotoFrame(where,whichFrame ,all)

	--普通跳转条件
	if not self.actionFinish then
		return
	end

	--如果当前已经是这个动作		
	if self.label == where then
		--如果是不能跳转到当前动作的那么return
		if not all then
			return
		end
		self:sycFrameAction(whichFrame)
		return
	end
	
	self:changeActionInitFramDatas(where,whichFrame)

end

--切换跳转  比如攻击的时候  需要进行readyFrame判断
function ModelFrameBasic:readyFrame( where,whichFrame,all )
	--普通跳转条件
	if not self.actionFinish then
		return
	end

	--如果当前已经是这个动作		
	if self.label == where then
		--如果是不能跳转到当前动作的那么return
		if not all then
			return
		end
		self:sycFrameAction(whichFrame)
		return
	end

	self:changeActionInitFramDatas(where,whichFrame)
end

--强制跳转
function ModelFrameBasic:justFrame(where,whichFrame,all )
	--如果当前已经是这个动作		
	if self.label == where then
		--如果是不能跳转到当前动作的那么return
		if not all then
			return
		end
		self:sycFrameAction(whichFrame)
		return
	end
	self:changeActionInitFramDatas(where,whichFrame)
end

--循环跳转
function ModelFrameBasic:sycFrameAction( whichFrame )
	whichFrame = whichFrame or 1
	whichFrame = whichFrame <1 and 1 or whichFrame
	whichFrame = whichFrame > self.totalFrames and self.totalFrames or whichFrame
	if  self.myView and self.myView.gotoAndPlay then
		self.myView:gotoAndPlay(whichFrame)
	end
	self.frame = whichFrame
	self:frameEvent()
end

--初始化frame数据 暂停分2种  一种是 游戏暂停 一种是对象自身的暂停
function ModelFrameBasic:changeActionInitFramDatas(where,whichFrame )
	if not where then
		echoError("__________没有这个动作")
		return
	end
	
	
	if where == Fight.actions.action_stand then
		if self.logical.currentCamp ~= self.camp then
			--如果是敌方方回合 跳转到 站立2
			where = Fight.actions.action_stand2
		end
	end
	--隐藏上一个label
	self:showOrHideFollowActionAni(self.label,false)
	--显示当前的label特效
	self:showOrHideFollowActionAni(where,true)
    whichFrame = whichFrame or 1
	whichFrame = whichFrame < 1 and 1 or whichFrame
	self.frame = whichFrame
	self.label = where



	if not self.isFrameAction then
		return
	end

	if #self.noteFrameEvent ~= 0 then
		self.noteFrameEvent ={}
	end



	if self.myView then
		self:updateView(where,whichFrame)
	end

	self.selfPause = false

	self:initFrameDatas(self.label)
	self:initFrameParameter(false)
	self:initAtkGadLevel()

    self:frameEvent()

	self.eventChangeAction = true
	--改变动作后需要判断行是否能播放动作
	self:checkCanPlayView()
end

-- 视图跳转动作
function ModelFrameBasic:updateView(where,whichFrame)	
	whichFrame = whichFrame < 1 and 1 or whichFrame
	self.label = where
	self.frame = whichFrame	
	if self.myView  then
		where = self.data.sourceData[where]
		self.myView:playLabel(where)
		self.myView:gotoAndPlay(whichFrame)
	end	
end


function ModelFrameBasic:initFrameDatas( where )
	local key = where
	local data = FrameDatas.getCommonActionData(key)
	--获取当前帧数
	self.totalFrames = self:getTotalFrames()
	if not self.totalFrames then
		-- dump(self.viewData.actionFrames,"___actionFrames")
		-- dump(self.data.sourceData,"sourceData")
		echoError("___没有导出动画配置数据__sourceid:%s_,当前动作动作:%s,跳转动作:,where%s,key:%s ",self.data.sourceData.hid,self.label,where,key)
		if not DEBUG_SERVICES  then
			cc.Director:getInstance():pause()
		end
		
		return
	end

	--记录动作帧数
	self.actionFrame = {data[1][1] == -1 and self.totalFrames or data[1][1], data[1][2] == -1 and self.totalFrames or data[1][2], self.totalFrames  }

	self.eventData = data[2]
	
end


function ModelFrameBasic:getTotalFrames(label)
	label = label or self.label
	local frame = self.viewData.actionFrames[self.data.sourceData[ label ] ]
	if not frame then
		echoWarn("没有找到对应动作的帧数,label:",label,self.data.sourceData[label], "_hid",self.data.hid,"treasureHid:", self.data._curTreasureHid)
		return nil
	end
	if frame <= 1 then
		frame = 2
	end
	return frame
end


--初始化动作finish参数
function ModelFrameBasic:initFrameParameter( isResume )
	if self.actionFrame[1] ==1 then
		self.actionFinish = true
	else
		self.actionFinish = false
	end
	-- 动作特效
	if isResume then
		return
	end

	if not self.data.getActionEx then
		return
	end
	local key = self.label
	local ex = self.data:getActionEx(key)
	if ex then
		if not Fight.isDummy then
			local aniFrame  = ex.aniFrame
			if aniFrame and ex.aniArr then
				--如果是循环动作 那么创建跟随动作特效
				if self:checkIsCysAtcion(self.label) then
					self:pushOneCallFunc(tonumber(aniFrame),"creatFollowActionAni",{ex.aniArr})
				else
					self:pushOneCallFunc(tonumber(aniFrame),"createEffGroup",{ex.aniArr})
				end
				
			end
			
			if ex.shake then
				self:pushOneCallFunc(tonumber(ex.shake[1]),"shake", {ex.shake[2],ex.shake[3],ex.shake[4]})
			end
			if ex.ghost then	
				local interval = tonumber(ex.ghost[2])/100
				local offset = tonumber(ex.ghost[3])*self.way
				local zod = tonumber(ex.ghost[4])
				local alhpa = tonumber(ex.ghost[5])/100
				local last = tonumber(ex.ghost[6])/100
				self:createGhostGroup(tonumber(ex.ghost[1]),interval,offset,self.__zorder+zod,self.viewCtn,alhpa,last)
			end
		end
		
	end
end


--初始化攻击防御等级参数 子类扩展的
function ModelFrameBasic:initAtkGadLevel( )
end


------------------------------------------------------------------------------

--站立动作
function ModelFrameBasic:standAction(  )
	self:gotoFrame(Fight.actions.action_stand,1)
	self:initStand()
end


--行走动作
function ModelFrameBasic:walkAction( xSpeed,ySpeed )
	self:initMove(xSpeed,ySpeed)
	self:gotoFrame(Fight.actions.action_run,  1)
end

--帧上事件 
--跳跃状态下停住
function ModelFrameBasic:jumpStopFrame(  )
	if self.myState ~= Fight.state_jump  then
		return
	end
	self:stopFrame(  )
end

--重写运动到点
function ModelFrameBasic:overTargetPoint( )
	ModelFrameBasic.super.overTargetPoint(self)
	self:gotoFrame(Fight.actions.action_stand)
end

--创建跟随动作的特效
function ModelFrameBasic:creatFollowActionAni( aniArr )
	if self.followActionAniObj[self.label] then
		return
	end
	-- dump(aniArr,self.data.posIndex.."__data")
	local effArr = self:createEffGroup(aniArr, true)

	self.followActionAniObj[self.label] = effArr

end

--隐藏或者显示一组动作跟随特效
function ModelFrameBasic:showOrHideFollowActionAni( label,visible )
	local aniArr = self.followActionAniObj[label]
	if not aniArr then
		return
	end
	for i,v in ipairs(aniArr) do
		--必须是没有被销毁的
		if not v._isDied then
			v.myView.currentAni:visible(visible)
			--如果是显示的那么帧数同步
			if visible then
				v.myView:play()
				--跳转到当前帧数
				v.myView:playLabel(nil,true)
				
				
			else
				
				v.myView:stop()
			end
		end
	end

end



return ModelFrameBasic