local EliteTipsView = class("EliteTipsView", UIBase)

function EliteTipsView:ctor(winName)
	EliteTipsView.super.ctor(self, winName)
end

function EliteTipsView:loadUIComplete()
    self.UI_1.txt_1:setString("提示")
    self.UI_1.mc_1:showFrame(1)
    self.VIPBtn = self.UI_1.mc_1.currentView.btn_1
	self:setAlignment()

	self:registerEvent()
end



function EliteTipsView:setAlignment()
	--设置对齐方式

end


function EliteTipsView:registerEvent()
	EliteTipsView.super.registerEvent()
    self.UI_1.btn_close:setTap(c_func(self.onBtnBackTap, self));
    self:registClickClose("out");
    self.UI_1.mc_1:showFrame(1)
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.onBtnVIPTap, self));
	
end


-- 打开VIP 充值
function EliteTipsView:onBtnVIPTap()
	WindowControler:showWindow("RechargeMainView")
end

--返回 
function EliteTipsView:onBtnBackTap()
	self:startHide()
end

return EliteTipsView
