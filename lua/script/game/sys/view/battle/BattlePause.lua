local BattlePause = class("BattlePause", UIBase);

--[[
    self.btn_1,
    self.btn_2,
    self.btn_close,
    self.panel_1.mc_1,
    self.panel_1.mc_2,
    self.panel_bg,
    self.panel_bg.scale9_1,
    self.txt_1,
]]


function BattlePause:ctor(winName,controler)
    BattlePause.super.ctor(self, winName);
    self.controler = controler
end

function BattlePause:loadUIComplete()
    local coverView = WindowControler:createCoverLayer(nil, nil, GameVars.bgAlphaColor ):addto(self,-2)
	self:registerEvent();
end 

function BattlePause:registerEvent()
	BattlePause.super.registerEvent();
    self.btn_close:setTap(c_func(self.press_btn_close, self));
    self.btn_1:setTap(c_func(self.press_btn_1, self));
    self.btn_2:setTap(c_func(self.press_btn_2, self));
    self.panel_1.mc_2.currentView.btn_1:setTap(c_func(self.pressAutoFight, self));
end

--关闭按钮
function BattlePause:press_btn_close()
    self:startHide()
    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_GAMEPAUSE )
end

--退出战斗
function BattlePause:press_btn_1()
    self:startHide()
    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SUREQUIT )
end

--恢复暂停
function BattlePause:press_btn_2()
    self:startHide()
    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_GAMEPAUSE )
end


--自动战斗
function BattlePause:pressAutoFight()
    self:startHide()
    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_GAMEPAUSE )
    self.controler.logical:setAutoFight(true)
end



function BattlePause:updateUI() 
    
end


return BattlePause;
