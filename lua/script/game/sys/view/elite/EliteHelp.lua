local EliteHelp = class("EliteHelp", UIBase)

function EliteHelp:ctor(winName)
	EliteHelp.super.ctor(self, winName)
end

function EliteHelp:loadUIComplete()
	self:setAlignment()

	self:registerEvent()
end

function EliteHelp:setAlignment()
	--设置对齐方式
	FuncCommUI.setScale9Align(self.scale9_1,UIAlignTypes.MiddleTop, 1, 0)
    FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
end



function EliteHelp:registerEvent()
	EliteHelp.super.registerEvent()
    self.btn_1:setTap(c_func(self.onBtnBackTap, self));
end


function EliteHelp:onBtnBackTap()
	self:startHide()
end

return EliteHelp
