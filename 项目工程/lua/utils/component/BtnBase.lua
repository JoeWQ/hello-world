
local BtnBase = class("BtnBase", function()
	--设置contentSize0,0 可以修复缩放的bug
    return display.newNode()
end)

BtnBase.TAP_THRESHOLD = 30 -- 超过该数值不响应tap
BtnBase.TOUCH_PRIORITY = 0 --touch优先级(兼容CCMenu改成-128，兼容CCControl改成1)
BtnBase.centerPos = nil
--[[
-- Usage: 按钮基类
-- 内部变量说明：
	self.__stat = nil -- 过程中的所有临时数值存在这里
	self._root = nil -- 根节点(唯一子节点)
	self.__rect = nil -- 用于判定点击范围的rect
	-- 外部设置的回调函数
	self.__tapFunc = nil
]]
function BtnBase:ctor()
    
    -- self:addTouchEventListener(touchFunc  )
    self.__enabled = true -- 是否有效(默认有效)
    --self:initEventListener()
    self.__canClick = true  
    -- self:setTouchEnabled(true)
    self:setTap(GameVars.emptyFunc)
    if self._clickNode then
        self._clickNode:setTouchSwallowEnabled(false)
    end
end

function BtnBase:getContainerBox()
    return self:_rect()
end


-- -- public functions
--enabledInWorldRect: 当btn点击点处于rect范围内才有效(用于屏蔽滚动条滚动到隐藏范围时)
function BtnBase:setTap(handler,enabledInWorldRect)

    self:initEventListener()
    if self._clickNode then
        self._clickNode:setTouchSwallowEnabled(true)
        if enabledInWorldRect then
            self:setRect(enabledInWorldRect)
        end
    end
    self.__tapFunc = handler
    self.__enabledInWorldRect = enabledInWorldRect
    return self
end


--初始化点击事件
function BtnBase:initEventListener(  )
    if self.__hasInitEvent then
        return
    end
    self.__hasInitEvent =true
    local touchFunc = function ( event )
        local result = self:__onTouch(event.name,event.x,event.y)
        return result
    end
    local clickNode = display.newNode():addto(self,2)
    clickNode:setTouchEnabled(true)
    self._clickNode = clickNode
    
    clickNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, touchFunc)
end


function BtnBase:setBegan(handler)
	self.__beganFunc = handler
	return self
end
function BtnBase:setMoved(handler)
	self.__movedFunc = handler
	return self
end
function BtnBase:setEnded(handler)
	self.__endedFunc = handler
	return self
end
function BtnBase:setCancelled(handler)
	self.__cancelledFunc = handler
	return self
end
--设置tap时的音效函数
function BtnBase:setTapSound(handler)
	self.__tapSoundFunc = handler
	return self
end

--设置按钮是否可点
function BtnBase:enabled(v)
    if(v==nil) then return self.__enabled end -- enabled()
    if(v==true or v==1) then v = true
    else v = false end
    self.__enabled = v
    self._clickNode:setTouchEnabled(v)
    return self
end




--自定义响应区域
function BtnBase:setRect(rect)
	self._myRect = rect

    local clickNode = self._clickNode
    clickNode.x = rect.x
    clickNode.y = -rect.y
    clickNode:setContentSize(cc.size(rect.width,rect.height))
    clickNode:anchor(-rect.x/rect.width,-rect.y/rect.height)

    self:setCenterPos(cc.p(rect.x+rect.width/2,rect.y + rect.height /2) )
end

--设置按钮中心点
function BtnBase:setCenterPos( pos )
    self.centerPos = pos
end

--自定义不响应的区域
function BtnBase:setUnRect(_rect)
	if not self._myUnRects then
		self._myUnRects = {}
	end
	table.insert(self._myUnRects,_rect)
end
-- -- protect functions
function BtnBase:_setRoot(node)
    self._root = node
    self:addChild(self._root)
    return self
end
-- protect override functions 子类覆盖以下方法实现不同按钮效果
function BtnBase:_onBegan() end
function BtnBase:_onMoved() end
function BtnBase:_onCancelled() end
function BtnBase:_onEnded(x, y)

    if  LoginControler:isStartPlay() == true and
         TutorialManager.getInstance():isAllFinish() == false and 
          TutorialManager.getInstance():isTutoring() == true and
           TutorialManager.getInstance():isInBtnClickArea(x, y) == false then 
        return
    end

    if(self.__endedFunc) then self.__endedFunc(x,y) end --外部事件
    if not self.__stat then return end
    if self.__stat.isTap then
        self:_onTaped() -- 子类继承方法
        if self.__tapSoundFunc then self.__tapSoundFunc() end--tap音效

        local tempFunc = function (  )
            self.__canClick = true
        end

        if self.__tapFunc and self.__tapFunc ~= GameVars.emptyFunc then 
            if not self.__canClick then
                return 
            end

            self.__canClick =false
            self:_playSound()
            -- self.__tapFunc()
            --0.1秒后可以再次点击
            self:delayCall(self.__tapFunc, 0.0001)
            self:delayCall(tempFunc, 0.2)
            
        end --点击事件
    end
    self.__stat = nil

end
function BtnBase:_onTaped() end
-- 根节点_root是空node的时候需要覆盖该方法(有可能_root的sprite子节点anchor不是(0,0)点)
function BtnBase:_rect() 
    if self._myRect then return self._myRect end
    self._myRect = self:getConatinexBox()
    return self._myRect
end

-- -- private functions
function BtnBase:__onTouch(event,x,y)
    if not self.__enabled then return end -- 未启用
    if not self._root then return end -- 没有子节点，还判断球
    if(event=="began") then
        return self:__onTouchBegan(x,y)
    elseif(event=="moved") then
        self:__onTouchMoved(x,y)
    elseif(event=="ended") then
        self:__onTouchEnded(x,y)
    end
    return true
end

function BtnBase:__onTouchBegan(x,y)
    -- if true then
    --     self.__stat = {
    --         startX = x,
    --         startY = y,
    --         isTap = true,
    --     }
    --      self:_onBegan(x,y) -- 子类继承方法
    --     if(self.__beganFunc) then self.__beganFunc(x,y) end 
    --     return true
    -- end

    if  LoginControler:isStartPlay() == true and
         TutorialManager.getInstance():isAllFinish() == false and 
          TutorialManager.getInstance():isTutoring() == true and
           TutorialManager.getInstance():isInBtnClickArea(x, y) == false then 
        return false;
    end


    if not self:__chkContains(x,y) then return false end -- 没进入范围，跳过
    if self.__enabledInWorldRect then
	    if not rectEx.contain(self.__enabledInWorldRect, x, y)  then --有效范围外，跳过
		    return false
	    end
    end
    self.__stat = {
        startX = x,
        startY = y,
        isTap = true,
    }
    self:_onBegan(x,y) -- 子类继承方法
    if(self.__beganFunc) then self.__beganFunc(x,y) end --外部事件
    return true
end
function BtnBase:__onTouchMoved(x,y)
	if not self.__stat then return end
    -- 判断tap
    if (self.__stat.isTap) then
        local _offset = math.max(math.abs(x - self.__stat.startX),math.abs(y - self.__stat.startY))
        if(_offset>BtnBase.TAP_THRESHOLD) then
            self.__stat.isTap = false
            self:_onCancelled() -- 子类继承方法
            if(self.__cancelledFunc) then self.__cancelledFunc() end --外部事件
        end
    end
    self:_onMoved(x,y) -- 子类继承方法
    if(self.__movedFunc) then self.__movedFunc(x,y) end --外部事件
end
function BtnBase:__onTouchEnded(x,y)
    self:_onEnded(x, y) -- 子类继承方法

    -- self:delayCall( c_func(self._onEnded,self) )
end

function BtnBase:__chkContains(x,y)
	local point = self._root:convertToNodeSpace(cc.p(x, y)) 
    point.x = point.x + self.centerPos.x
    point.y = point.y + self.centerPos.y
	if self._myUnRects then
		for _,unRect in ipairs(self._myUnRects) do
			if  rectEx.contain(unRect,point.x,point.y) then
				return false
			end
		end
	end
    return rectEx.contain(self:_rect(),point.x,point.y)
end


--矩形工具
rectEx= rectEx or {}
--是否包含一个点rect格式 x,y,w,h r = {x= x,y=y,w =w,h = h},    border 检测边界
function rectEx.contain(r,x,y ,border)
    border = border  and border or 0
    r.w = r.w or r.width
    r.h = r.h or r.height
    if x <r.x - border or x >r.x+r.w + border or y < r.y -border or y > r.y + r.h +border then
        return false
    end
    return true

end

return BtnBase
