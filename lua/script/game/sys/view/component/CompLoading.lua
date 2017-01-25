local CompLoading = class("CompLoading", UIBase)

local DEFAULT_BG = "bg_denglu.png"

local BG_IMAGES = {
	[2]="bg_denglu.png",
	[3]="bg_denglu.png",
	[4]="bg_denglu.png",
	[5]="bg_denglu.png",
}

function CompLoading:ctor(winName, initTweenPercentInfo, processActions, processEndCfunc)
	CompLoading.super.ctor(self, winName)
	local serverInfo = LoginControler:getServerInfo() 
	local openTime = tonumber(serverInfo.openTime or  TimeControler:getServerTime() )
	local now = TimeControler:getServerTime()
	local day = math.ceil((now - openTime)*1.0/86400)
	if day <1 then day = 1 end
	self.day = day
	self.initTweenPercentInfo = initTweenPercentInfo or {percent=25, frame=20}
	self.processActions = processActions
	self.processEndCfunc = processEndCfunc 
end

function CompLoading:setViewAlign()
	FuncCommUI.setViewAlign(self.panel_loading, UIAlignTypes.MiddleBottom)
	--FuncCommUI.setViewAlign(self.mc_content, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.txt_tip1, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.txt_random_tips, UIAlignTypes.MiddleBottom)
end

function CompLoading:loadUIComplete()
	self:setViewAlign()

	if APP_PLAT == 1001 then
		if self.txt_fangchenmi then
			self.txt_fangchenmi:setVisible(true)
			FuncCommUI.setViewAlign(self.txt_fangchenmi, UIAlignTypes.MiddleTop)
		end
	else
		if self.txt_fangchenmi then
			self.txt_fangchenmi:setVisible(false)
		end
	end

	self.progressBar = self.panel_loading.panel_1.progress_1
	-- 设置初始进度
	self.progressBar:setPercent(0)

	self.progressBarBox = self.progressBar:getContainerBox()
	self:scheduleUpdateWithPriorityLua(c_func(self.frameUpdate, self) ,1)

	local initPercentInfo = self.initTweenPercentInfo
	self:tweenToPercentWithAction(initPercentInfo.percent, initPercentInfo.frame)

	local bgImage = FuncLoading.getResLoadingType(self.day, self:getUserHitSex())

	self:initBg(bgImage)
	self:showRandomTips()
	self:registerEvent()

	self:delayCall(c_func(self.startLoad, self), 1.0/GAMEFRAMERATE*20)
end

function CompLoading:frameUpdate()
	local percent = self.progressBar:getPercent()
	self.panel_loading.panel_1.txt_percent:setString(math.ceil(percent).."%")
	self:updateProgressCloud(percent)
end

function CompLoading:updateProgressCloud(percent)
	local box = self.progressBarBox
	local totalWidth = box.width
	self.panel_loading.panel_cloud:pos(math.ceil(percent)*1.0/100 * totalWidth-10, -box.height/2)
end

function CompLoading:getUserHitSex()
	local avatar = UserModel:avatar()
	local sex = FuncChar.getHeroSex(tostring(avatar))
	local hitSex = "man"
	if sex == "b" then
		hitSex = "woman"
	end
	return hitSex
end

function CompLoading:initBg(bgImage)
	local xoffset =(GameVars.width - GameVars.maxResWidth)/2
	local yoffset = (GameVars.height - GameVars.maxResHeight)/2
	local scalex = GameVars.width/GameVars.maxResWidth
	local scaley = GameVars.height/GameVars.maxResHeight
	local bgImagePath = FuncRes.iconBg(bgImage)
	local bgImageSprite = display.newSprite(bgImagePath)
	self._bgImage = bgImage
	--bgImageSprite:setScaleX(scalex)
	--bgImageSprite:setScaleY(scaley)

	self.ctn_bg:addChild(bgImageSprite)
end

function CompLoading:registerEvent()

end

function CompLoading:showRandomTips()
	local tips = FuncLoading.getRandomTips()
	self.txt_random_tips:setString(tips)
	self:delayCall(c_func(self.showRandomTips, self), 3)
end

function CompLoading:startLoad()
	local processActions = self.processActions
	local frame = 0
	for _, info in ipairs(processActions) do
		if frame  == 0 then
			self:tweenToPercentWithAction(info.percent, info.frame, info.action)
		else
			self:delayCall(c_func(self.tweenToPercentWithAction,self,info.percent, info.frame, info.action), frame/GAMEFRAMERATE )
		end
		frame = frame + info.frame
		
	end
end

function CompLoading:tweenToPercentWithAction(percent, frame, actionCFunc)
	local tweenArgs = {percent, frame}
	if percent == 100 then
		local endFunc = c_func(function() 
			if self.processEndCfunc then
				self.processEndCfunc()
			end
			self:close()
		end)
		table.insert(tweenArgs, endFunc)
	end
	-- echo(percent,frame,"__________compLoading",os.clock())
	self.progressBar:tweenToPercent(unpack(tweenArgs))

	if actionCFunc then
		actionCFunc()
	end
end

function CompLoading:finishLoading(frame,actionCFunc)
	local percent = self.progressBar:getPercent()
	self.progressBar:stopTween()
	local percent = 100
	self.progressBar:tweenToPercent(percent,frame,actionCFunc)
end

function CompLoading:close()
	self:startHide()
end

function CompLoading:deleteMe(  )
	FuncRes.removeBgTexture(self._bgImage)
	CompLoading.super.deleteMe(self)

end

return CompLoading
