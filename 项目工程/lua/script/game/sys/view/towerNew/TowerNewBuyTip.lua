-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
  
local TowerNewBuyTip = class("TowerNewBuyTip", UIBase)

function TowerNewBuyTip:ctor(winName)
    TowerNewBuyTip.super.ctor(self, winName)
    
end 

function TowerNewBuyTip:loadUIComplete()
    self:registerEvent()
    self:setViewAlign()
    self:updataUI()
end
function TowerNewBuyTip:registerEvent()
    TowerNewBuyTip.super.registerEvent()
    self:registClickClose("out");
    self.UI_elite_buy.btn_close:setTap(c_func(self.onBtnBackTap,self))
    
end
function TowerNewBuyTip:setViewAlign()

end
function TowerNewBuyTip:updataUI()
    self.UI_elite_buy.txt_1:setString("重置")
    self.txt_3:setVisible(false)

    local str = ""
    local _type = 0
    local cost = TowerNewModel:getTowerResetCost() or 0
    local haveGold = UserModel:getGold() or 0
    if cost == 0 then
        str = "是否重置锁妖塔？"
        _type = 1
    elseif  tonumber(haveGold) >= tonumber(cost) then 
        str = "是否花费"..cost.."仙玉，重置锁妖塔？"
        _type = 2
    else 
        str = "仙玉不足  是否前往充值？"
        _type = 3
    end
    self.txt_1:setString(str)
    if _type == 1 or _type == 2 then
        self.UI_elite_buy.mc_1:showFrame(2)
        self.UI_elite_buy.mc_1.currentView.btn_1:setTap(c_func(function ()
            EventControler:dispatchEvent("CHONGZHITISHI")
            self:onBtnBackTap()
        end,self))
        self.UI_elite_buy.mc_1.currentView.btn_2:setTap(c_func(self.onBtnBackTap,self))
    elseif _type == 3 then
        self.UI_elite_buy.mc_1:showFrame(2)
        self.UI_elite_buy.mc_1.currentView.btn_1:setTap(c_func(function ()
            WindowControler:showWindow("RechargeMainView")
            self:onBtnBackTap()
        end,self))
        self.UI_elite_buy.mc_1.currentView.btn_2:setTap(c_func(self.onBtnBackTap,self))
    end
   
   
end

function TowerNewBuyTip:onBtnBackTap()
    self:startHide()
end
return TowerNewBuyTip 
-- endregion 
