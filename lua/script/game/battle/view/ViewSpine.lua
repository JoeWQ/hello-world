--
-- Author: XD
-- Date: 2015-11-16 11:08:36
--

--动画缓存
local spineCache = {}

--[[
	--缓存格式 按照动画的名称缓存
	{
		heroes_1 = {	
			spine1,spine2,...
		},
		heroes_2 = {
		}

		effect_hit = {
			spine1,spine2,...
		},
		
	}


]]




local function getSpineCache(armatureName )
	local arr = spineCache[armatureName] 
	if not arr then
		return nil
	end

	if #arr == 0 then
		return nil
	end

	local obj = arr[1]
	table.remove(arr,1)
	
	return obj
end


local function setSpineCache(armatureName,spineAni )
	if not spineCache[armatureName] then
		spineCache[armatureName] = {}
	end
	--插入actorObj
	table.insert(spineCache[armatureName],spineAni )
end






ViewSpine = class("ViewSpine",function (  )
	return display.newNode()
end)



function ViewSpine:clearSpineCache(  )
	for k,v in pairs(spineCache) do
		for kk,vv in pairs(v) do
			vv:cleanup()
			vv:release()
		end
	end
	spineCache = {}

end

ViewSpine.currentAni = nil
local disableView = false

--初始化
function ViewSpine:ctor( name, actions, defaultSkin, atlasName,isCache)
	if disableView then
		self.currentAni = display.newNode():addto(self)
		return
	end
	actions = actions or {}
	self.spineName = name
	self.currentLabel = "nil"
	isCache = false
	self.actions = actions
	--如果是缓存的
	if isCache then
		self._viewCache = true

		local ani = getSpineCache(name)
		if not ani then
			ani = pc.PCSkeletonAnimation:createWithFile(FuncRes.spine(name, atlasName)):addto(self)
			echo("创建缓存特效",name)
			ani:retain()
		else
			echo("拿的是缓存",name,tolua.isnull(ani))
			ani:parent(self)
		end

		self.currentAni = ani
	else
		self.currentAni = pc.PCSkeletonAnimation:createWithFile(FuncRes.spine(name, atlasName)):addto(self)
		
	end

	if defaultSkin then
		self.currentAni:setSkin(defaultSkin)
	end

	-- self.currentAni:setScale(0.4)
end

--设置子动画只播放一次
function ViewSpine:setIsCycle( value )
	if disableView then
		return
	end
	self.currentAni:setAnimation(0, self.currentLabel, value)
end


--手动刷新动画
function ViewSpine:updateFrame()
	self.currentAni:update(0.03333)
end


--判断某个动作是否存在
function ViewSpine:checkHasLabel( label )
    if self.actions[label] then
    	return true
    end

    return false
end

--[[
	treasure_b3 stand_1 是有 bug 的 特别大 why？
]]
function ViewSpine:getBoundingBox()
	if disableView then
		return {x=0,y=0,width =0, height=0}
	end
	return self.currentAni:getBoundingBox();
end


--获取某个标签的长度
function ViewSpine:getLabelFrames(label )
	if disableView then
		return 10
	end
	if not label then
		return self.currentAni:getAniTotalFrame()
	end


	return self.actions[label] or self.currentAni:getAniTotalFrame()
end

--播放某个动作 isLoop 默认 true
function ViewSpine:playLabel(label, isLoop ,hide)
	
	if self.currentLabel == label then
		return
	end
	
	label = label or self.currentLabel

	if isLoop ~= false then 
		isLoop = true;
	end 



	self.currentLabel = label

	if disableView then
		return
	end

	self.currentAni:setAnimation(0, label, isLoop)

	--如果不是循环的
	if not isLoop then
		if hide then
			local tempFunc = function (  )
				self:visible(false)
			end
			self:delayCall(tempFunc, self:getTotalFrames()/GAMEFRAMERATE )
		end

	end

end

function ViewSpine:getTotalFrames(  )
	return self:getLabelFrames(self.currentLabel)
end


function ViewSpine:getSkeletonAnimationNode()
	return self.currentAni;
end


--设置效果  目前只能设置一个效果
function ViewSpine:setFilter( filterName,params )
	-- body
	self.filter = {name =filterName,params = params}
end


--清除滤镜效果
function ViewSpine:clearFilter( )
	self.filter = nil
end



--设置主角换装
function ViewSpine:setSkin( skin )
	if disableView then
		return
	end
	self.currentAni:setSkin(skin)
end

--设置播放方式  1 正波 -1倒波 
function ViewSpine:setPlayType( t )
	if disableView then
		return
	end
	if t ==1 then
		self.currentAni:setReversePlay(false)
	else
		self.currentAni:setReversePlay(true)
	end

	return self
end

--暂停
function ViewSpine:stop(  )
	self._isPlay=false
	if disableView then
		return
	end

	self.currentAni:stopPlay()

end



--播放
function ViewSpine:play()
	if disableView then
		return
	end
    self._isPlay=true
    self.currentAni:resumePlay()
end



--播放到某一帧
function ViewSpine:gotoAndPlay( frame )
	if disableView then
		return
	end
	if frame > 0 then
		self.currentAni:gotoAndPlay(frame-1)
	else
		self.currentAni:gotoAndPlay(0)
	end
	
	return self
end


--停到某一帧
function ViewSpine:gotoAndStop(frame)
	if disableView then
		return
	end

	if frame >0  then
		self.currentAni:gotoAndStop(frame-1)
	else
		self.currentAni:gotoAndStop(0)
	end

	
	return self
end



--设置播放速度
function ViewSpine:setPlaySpeed(value )
	self.playSpeed = value
	if disableView then
		return
	end
	self.currentAni:setTimeScale(value * GAMEFRAMERATE /30 )
end

function ViewSpine:getCurrentFrame()
	if disableView then
		return 10
	end
	return self.currentAni:getCurFrameIndex()
end

--获得当前动画的帧数
function ViewSpine:getCurrentAnimTotalFrame()
	if disableView then
		return 10
	end
	return self.currentAni:getAniTotalFrame()
end


--播放一系列动画
--[[
	actionArr = {
		--label,动画标签 loop是否循环,startCall动画开始播放时的回调,endCall 动画播放一次的回调 
		,lastFrame 表示这个动作持续时间 如果有 就按照这个时间delayCall播放下一个动作, 如果没有 那么就按照这个动画的帧长度播放下一个动作
		{label = "stand",loop = false,startCall = func,endCall = func,lastFrame = nil }
	}

	示例: 播放一个从祭出开始 到祭出结束的过程
	local actionArr = { 
            {label = charView.actionArr.giveOutBS },
            {label = charView.actionArr.giveOutBM,loop = true,lastFrame = singTime } ,
            {label = charView.actionArr.giveOutBE} ,
            {label = charView.actionArr.stand,loop = true, startCall = c_func(playActionEnd, charView)} ,
           }
        charView:playActionArr( actionArr )

]]
function ViewSpine:playActionArr( actionArr )

	-- dump(actionArr, "----actionArr----")

	local labelInfo = actionArr[1]

	self:playLabel(labelInfo.label, labelInfo.loop)
	if labelInfo.startCall then
		labelInfo.startCall()
	end
	local labelFrame = self:getCurrentAnimTotalFrame() -1
	--如果有持续帧数的 那么就按持续帧数做
	if labelInfo.lastFrame  then
		labelFrame = labelInfo.lastFrame
	end
	if labelInfo.endCall then
		self:delayCall(labelInfo.endCall, labelFrame/GAMEFRAMERATE )
	end

	local newArr = {}
	for i=2,#actionArr do
		table.insert(newArr, actionArr[i])
	end

	if #newArr ==0 then
		return
	end

	
	self:delayCall(c_func(self.playActionArr,self,newArr ), labelFrame/GAMEFRAMERATE)

end


function ViewSpine:deleteMe()

	if self._viewCache then
		self.currentAni:removeFromParent(false)
		setSpineCache(self.spineName,self.currentAni)
	end
	self:removeFromParent()
end

--[[
加子动画子节点
node 要加的子节点
slotName 绑定在哪，决定绘制顺序
boneName 决定位置
]]
function ViewSpine:addSubNode(node, slotName, boneName)
	if disableView then
		return
	end
	self.currentAni:addSubNode(node, slotName, boneName);
end

--[[是
node 为空 则 删除 slotName 上所有 subNode
]]
function ViewSpine:delSubNode(slotName, node)
	if disableView then
		return
	end
	-- 下面的代码为啥被注释掉了？ guan 2016.02.01
	-- self.currentAni:removeSubNode(slotName, node);
	self.currentAni:removeSubNode(slotName);
end

--判断slot 是否存在
function ViewSpine:isSlotExist(slotName)
	if disableView then
		return false
	end
	return self.currentAni:isSlotExist(slotName)
end

--[[
	更换slotName下的图为散图，pngName为要替换后的图
	pngName 是一个数组先左后右,
]]
function ViewSpine:changeSlotTexuture(slotName, pngName)
	if disableView then
		return
	end
	self.currentAni:changeSlotTexture(slotName, pngName);
end

--[[
	type:武器类型	1剑,2双手剑,3弓, 4扇子,5浮沉,6伞
	pngName: 为要替换后的图,是一个数组先左后右,
]]
function ViewSpine:changeWeaponTexuture(type, pngName)
	if disableView then
		return
	end
	for i=1,2 do
		local slot = "weapon_z"..type
		if i == 2 then
			slot = "weapon_y"..type
		end
		for i=1,5 do
			local slotName = slot.."_"..i
			--echo("_______check slot",type,slotName,self.currentAni)
			if self:isSlotExist(slotName) then				
				local png = "icon/weapon/"..pngName[1]..".png"
				if pngName[i] then
					png = "icon/weapon/"..pngName[i]..".png"
				end
				--echo("_______ddfss",slotName,png)
				self.currentAni:changeSlotTexture(slotName, png)
			end
		end
	end
end

--直接用 node 的 setScale 就可以
-- function ViewSpine:setScale(scale)
-- 	if disableView then
-- 		return
-- 	end
-- 	self:setScale(scale);
-- end

--[[
	要把 size 搞到多大, bug有， 不要用了 getBoundingBox 不准
]]
function ViewSpine:size(width, height)
	if disableView then
		return
	end
	local spineBox = self:getBoundingBox();
	local spineWidth, spineHeight = spineBox.width, spineBox.height;

	echo("spineWidth " .. tostring(spineWidth))
	echo("spineHeight " .. tostring(spineHeight))

	echo("height " .. tostring(height))
	echo("width " .. tostring(width))

    local widthCoeffcient = width / spineWidth;
    local heightCoeffcient = height / spineHeight;

	echo("widthCoeffcient " .. tostring(widthCoeffcient))
	echo("heightCoeffcient " .. tostring(heightCoeffcient))

    self.currentAni:setScaleX(widthCoeffcient);
    self.currentAni:setScaleY(heightCoeffcient);
end

--[[
	局部换装复原
]]
function ViewSpine:resetSlotTexture(slotName)
	if disableView then
		return
	end
	self.currentAni:resetSlotTexture(slotName);
end

--[[
	得到骨头的相对root的 pos
]]
function ViewSpine:getBonePos(boneName)
	return self.currentAni:getBonePos(boneName);
end

function ViewSpine:getBoneTransformValue( boneName,key )
	return self.currentAni:getBoneTransformValue(boneName,key)
end


--[[
	有没有boneName的bone
]]
function ViewSpine:isBoneExist(boneName)
	return self.currentAni:isBoneExist(boneName) and true or false;
end


--[[
	是否显示影子 有可能不叫  shadow 叫 yinying 待统一 todo
]]
function ViewSpine:setShadowVisible(bool)
	self:setSlotVisible("shadow", bool);
end

--[[
	设置某个slot是否可见
]]
function ViewSpine:setSlotVisible(slotName, bool)
	self.currentAni:setSlotVisible(slotName, bool);
end


