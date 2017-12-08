local CompResTopHunpaiView = class("CompResTopHunpaiView", UIBase)

function CompResTopHunpaiView:ctor(winName)
	CompResTopHunpaiView.super.ctor(self, winName)
end

function CompResTopHunpaiView:loadUIComplete()
	self:registerEvent()
	self.txt_1:setString(UserModel:getSoulCopper())
end

function CompResTopHunpaiView:registerEvent()
	self.btn_xianyujiahao:setTap(c_func(self.onAddTap, self))
	self._root:setTouchedFunc(c_func(self.onAddTap, self))
    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end

function CompResTopHunpaiView:onAddTap()
	WindowControler:showWindow("GetWayListView", FuncDataResource.RES_TYPE.COPPER)
end

function CompResTopHunpaiView:updateUI()
	self.txt_1:setString(UserModel:getSoulCopper())
end

function CompResTopHunpaiView:close()
	self:startHide()
end

return CompResTopHunpaiView
