--[[
	guan
	2016.4.25
]]

local GMEnterView = class("GMEnterView", UIBase);

--[[
    self.panel_3.mc_1,
    self.panel_3.mc_2,
]]

function GMEnterView:ctor(winName)
    GMEnterView.super.ctor(self, winName);
    self._isMoved = false;
    self.lastX = 0
    self.lastY =0
end

function GMEnterView:loadUIComplete()
	self:registerEvent();
end 

function GMEnterView:registerEvent()
	GMEnterView.super.registerEvent();

    self.panel_3:setTouchedFunc(c_func(self.showOrHideLogsView,self),
        nil, true, c_func(self.switchMcDragBegin,self), c_func(self.switchMcDragMove,self));

    self.panel_3.mc_1:getCurFrameView().txt_1:setString("gm-v" .. AppInformation:getVersion() or "test")
end

function GMEnterView:switchMcDragMove(event)
    local x = event.x
    local y = event.y
    
    local turnPos = self._root:convertToNodeSpace(cc.p(x,y))
    x = turnPos.x
    y = turnPos.y


    local moveX = x - self.lastX
    local moveY = y - self.lastY

    local switchMcX,switchMcY = self._root:pos()
    
    local newPosX = switchMcX + moveX
    local newPosY = switchMcY + moveY

    local newLogPanelX = newPosX
    local newLogPanelY = newPosY

    local offsetX = 50
    local offsetY = 20

    if newLogPanelX <= -GameVars.UIOffsetX then
        newLogPanelX = -GameVars.UIOffsetX
    elseif newLogPanelX >= (GameVars.width - offsetX) then
        newLogPanelX = (GameVars.width - offsetX)
    end

    if newLogPanelY <= (-(GameVars.height) + offsetY) then
        newLogPanelY = (-(GameVars.height) + offsetY)
    elseif newLogPanelY >= 0 then
        newLogPanelY = 0
    end

    self._root:pos(newLogPanelX,newLogPanelY)

    -- echo(self.lastX, self.lastY, x, y);

    if self.lastX ~= x or self.lastY ~= y then 
    	self._isMoved = true;
    else 
    	self._isMoved = false;
    end 
end


function GMEnterView:switchMcDragBegin(event)
    local turnPos = self._root:convertToNodeSpace(cc.p(event.x,event.y))
    self.lastX = turnPos.x
    self.lastY = turnPos.y
    self._isMoved = false
end

-- 显示或关闭logsView
function GMEnterView:showOrHideLogsView()
	echo("showOrHideLogsView");
	if self._isMoved == false then 
		WindowControler:showWindow("TestConnView");
	end 
	self._isMoved = false;
end

function GMEnterView:updateUI()
	
end


return GMEnterView;
