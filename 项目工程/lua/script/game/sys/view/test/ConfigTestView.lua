local ConfigTestView = class("ConfigTestView", function() 
	return display.newNode()
end)

local BTN_WIDTH = 160
local BTN_HEIGHT = 70
local hangNums = 5

function ConfigTestView:ctor()
	self.btn_num = 0
    self._root = display.newNode():addto(self)
    local layer = WindowControler:createCoverLayer(0,GameVars.height ,cc.c4b(99,99,99,255)):addto(self,-1)
	self:createTestBtns()
end

function ConfigTestView:createTestBtns()
	self:createBtn("返回", c_func(self.back, self))
	self:createBtn("活动系统", c_func(self.testActivity, self))
	self:createBtn("奇缘系统", c_func(self.testRomance, self))
	self:createBtn("商店系统", c_func(self.testShop, self))
	self:createBtn("战斗系统", c_func(self.testBattle, self))
	self:createBtn("熔炼系统", c_func(self.testSmelt, self))
end

function ConfigTestView:back()
	self:clear()
end

function ConfigTestView:testActivity()
	local actInspect = require("game.sys.config_inspect.ActInspect").new()
	actInspect:run()
end

function ConfigTestView:testRomance()
--	local romanceInspect = require("game.sys.config_inspect.RomanceInspect").new()
--	romanceInspect:run()
end

function ConfigTestView:testShop()
	local shopInspect = require("game.sys.config_inspect.ShopInspect").new()
	shopInspect:run()
end

function ConfigTestView:testBattle()
	local shopInspect = require("game.sys.config_inspect.BattleInspect").new()
	shopInspect:run()
end

function ConfigTestView:testSmelt()
	local smeltInspect = require("game.sys.config_inspect.SmeltInspect").new()
	smeltInspect:run()
end



--创建一个测试按钮只用传递一个显示文本和一个点击函数即可,目前是自动排列
function ConfigTestView:createBtn(text, clickFunc)
    self.btn_num = self.btn_num + 1
    local xIndex =  self.btn_num %hangNums 
    xIndex = xIndex == 0 and hangNums or xIndex
    local yIndex = math.ceil( self.btn_num/hangNums )
    local xpos = GameVars.UIOffsetX +  (xIndex-1) * BTN_WIDTH  + 30

	local ypos = GameVars.height - GameVars.UIOffsetY-(yIndex-1) * BTN_HEIGHT - 70
    local sp = display.newNode():addto(self._root):pos(xpos,ypos):anchor(0,0)
    sp:size(130,50)
    display.newRect(cc.rect(0, 0,130, 50),
        {fillColor = cc.c4f(1,1,1,0.8), borderColor = cc.c4f(0,1,0,1), borderWidth = 1}):addto(sp)

    display.newTTFLabel({text = text, size = 20, color = cc.c3b(255,0,0)})
            :align(display.CENTER, sp:getContentSize().width/2, sp:getContentSize().height/2)
            :addTo(sp):pos(65,25)
    sp:setTouchedFunc(clickFunc,cc.rect(0,0,127,64))
end

function ConfigTestView:loadUIComplete()
	self:registerEvent()
end

function ConfigTestView:registerEvent()
end

function ConfigTestView:close()
	self:startHide()
end
return ConfigTestView
