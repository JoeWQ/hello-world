--
-- Author: xiangdu
-- Date: 2014-01-02 10:21:52
--

CameraControler = class("CameraControler")
CameraControler.targetView = nil 	--当前锁定的视角
CameraControler.layer = nil 		--需要放缩的容器层
CameraControler.currentState = 1           --当前状态 1表示保持在原始大小 2表示 在缩放缩小中  3 表示在保持在缩放大小 4表示恢复大小中
CameraControler.currentScale = 1    --当前的缩放 系数   针对

CameraControler.minScale = 0.8        --最小缩放系数 
CameraControler.maxScale = 1.2        --最大缩放系数为1.5倍  就是2个人物非常接近的时候

CameraControler.maxDistance = 800           --最大判定距离为960 
CameraControler.minDistance = 200           --最小判定距离


CameraControler.easeNum = 0.05           --缓动系数 距离缩放缓动
CameraControler.scaleInfo = nil         --当前缩放信息
--[[
    根据最大判定距离  960 scale为0.8
    最小判定距离   480  scale 为 maxDistanceScale = 1.5


]]

local startP = {x=CameraControler.minDistance,y=CameraControler.maxScale}
local endP = {x=CameraControler.maxDistance,y=CameraControler.minScale}

--创建线性方程
local scaleLine = Equation.creat_1_1_b( startP, endP)





CameraControler.targetScaleByDistance = 1      --目标scale 因为这里的scale 一定是缓动过去的
CameraControler.currentScaleByDistance = 1    --游戏根据人的距离产生的 镜头缩放  这个不能和  放大招产生的缩放产生冲突 




function CameraControler:ctor( controler )
	self.controler = controler
    self.layer = controler.layer
    --缩放点
    self.scalePos =  {x=GAMEHALFWIDTH ,y=480 }
    self.scaleInfo = {
        left = 0,
        scale = 1,
        lastScale = 1,         --记录上次的scale
        initScale = 1,       --记录初始的scale
        time = 0,         --持续的帧数 记录下来     
    }
    self:initInfo()
end





-- 让镜头缓动缩放到某个值
--[[
    info 
    [1] = 缩放的帧数
    [2] = 缩放的目标值
]]
function CameraControler:setScaleTo( info,scalePos )
    self.scalePos = {
        x = scalePos.x,
        y = scalePos.y
    }
    --每次缩放的时候都需要记录下初始scale ,因为可能在期间出现返回调用scaleTo的情况 
    local lastScale = self.scaleInfo.scale
    self.scaleInfo = {
        left = info[1],
        scale = info[2],
        lastScale = lastScale,         --记录上次的scale
        initScale = self.currentScale ,      --记录初始的scale
        time = info[1],         --持续的帧数 记录下来     
    }
end

--恢复大小
function CameraControler:initInfo(  )
   
    self:countScale()

end


--做每个状态各自的事



function CameraControler:updateFrame()
    --如果是等待状态的时间是小于0的
    if  self:checkNormalScale() then
        self:countScale()
    end 
    self:checkSpineActionCamera()
end


--判断大招镜头特写
function CameraControler:checkSpineActionCamera(  )
    if not self._cameraSpine then
        return
    end

    self._cameraSpine.frameLength = self._cameraSpine.frameLength - 1
    local layer = self.controler.layer.a1
    if self._cameraSpine.frameLength == 0 then
        self._cameraSpine:deleteMe()
        self._cameraSpine = nil
        layer:moveTo(0.2, 0, 0)
        -- layer:pos(0,0)
        layer:scaleTo(0.2,1)
        -- layer:setRotation(0)
    else
        -- local bonePos = self._cameraSpine:getBonePos(self._cameraSpine.boneName)
        -- layer:pos(bonePos.x,bonePos.y)
        local x = self._cameraSpine:getBoneTransformValue(self._cameraSpine.boneName,"x")
        local y = self._cameraSpine:getBoneTransformValue(self._cameraSpine.boneName,"y")
        local sx = self._cameraSpine:getBoneTransformValue(self._cameraSpine.boneName,"sx")
        local sy = self._cameraSpine:getBoneTransformValue(self._cameraSpine.boneName,"sy")
        
        local offsetX = GameVars.width/2*(1-sx);
        local offsetY = GameVars.height/2*(1-sy);
        
        layer:setScaleX(sx)
        layer:setScaleY(sy)
        layer:pos(x   ,y )
        layer:pos(x +offsetX  ,y - offsetY)
        -- echo(x,y,sx,sy,offsetX,offsetY,"____坐标信息")
    end


end




--普通放大招的镜头缩放
function CameraControler:checkNormalScale(  )
    if self.scaleInfo.left > 0 then
        self.scaleInfo.left = self.scaleInfo.left - 1
        --计算目标scale
        local disScale = self.scaleInfo.scale - self.scaleInfo.initScale

        self.currentScale = self.scaleInfo.scale - disScale/self.scaleInfo.time * self.scaleInfo.left
        return true
    end

    return false
end



--开始缩放容器
function CameraControler:countScale(  )

    
    --这里分  大招镜头缩放 和 人物距离缩放2个概念
    local resultScale = self.currentScale  --* Fight.wholeScale


    -- local initXpos = self.scalePos.x - self.controler.screen.focusPos.x + GAMEHALFWIDTH
    local initXpos = self.scalePos.x 

    local xpos = math.round( initXpos - initXpos * resultScale)
    local ypos = math.round( self.scalePos.y - self.scalePos.y  * resultScale )
 
    self.layer.a12b:pos(xpos,-ypos)
    --self.layer:pos(xpos,-ypos)
    self.layer.a12b:scale(resultScale)

    if self.controler.map then
        self.controler.map:updateScale(resultScale,{x = initXpos,y = self.scalePos.y})
    end 
end


--让屏幕随着动画scale缩放
function CameraControler:scaleBySpineAction( spineName,spineAction ,boneName )
    if self._cameraSpine then
        self._cameraSpine:deleteMe()
    end
    self._cameraSpine = ViewSpine.new(spineName)
    self._cameraSpine:playLabel(spineAction,false)
    self._cameraSpine.boneName = boneName
    self._cameraSpine.frameLength = self._cameraSpine:getTotalFrames()
    local topRoot = WindowControler:getScene()._topRoot
    self._cameraSpine:addTo(topRoot):pos(GameVars.cx,GameVars.cy )
end


