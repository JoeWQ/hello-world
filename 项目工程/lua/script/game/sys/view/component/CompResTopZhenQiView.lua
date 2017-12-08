local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompResTopZhenQiView = class("CompResTopZhenQiView", ResTopBase)
function CompResTopZhenQiView:ctor(winName)
	CompResTopZhenQiView.super.ctor(self, winName)
end

function CompResTopZhenQiView:loadUIComplete()
	self:registerEvent()
	self:updatePreNum(UserModel:getPulseCoin())
	self:updateUI()
end

function CompResTopZhenQiView:registerEvent()
	self.btn_xianyujiahao:setTap(c_func(self.onAddTap, self))
	self._root:setTouchedFunc(c_func(self.onAddTap, self))
    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end

function CompResTopZhenQiView:updateUI()
	local current = UserModel:getPulseCoin()
	local preNum = self:getPreNum()
	if preNum < current then
		if not self:isManualUpdateNum() then
			self:playNumChangeEffect(preNum, current)
		end
	else
		self.txt_xianyu:setString(self:getDisplayNumStr(current))
		self:updatePreNum(current)
	end
end

function CompResTopZhenQiView:getAnimTextNode()
	return self.txt_xianyu
end

function CompResTopZhenQiView:getNumChangeEffecCtn()
	return self.ctn_1
end

function CompResTopZhenQiView:getIconAnimCtn()
	return self.ctn_2
end

function CompResTopZhenQiView:getIconNode()
end

function CompResTopZhenQiView:getIconAnimName()
end

function CompResTopZhenQiView:onAddTap()
	WindowControler:showWindow("GetWayListView", FuncDataResource.RES_TYPE.PULSECOIN)
end

function CompResTopZhenQiView:close()
	self:startHide()
end
return CompResTopZhenQiView
