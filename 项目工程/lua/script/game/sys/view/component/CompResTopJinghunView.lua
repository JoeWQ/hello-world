local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompResTopJinghunView = class("CompResTopJinghunView", ResTopBase)

function CompResTopJinghunView:ctor(winName)
	CompResTopJinghunView.super.ctor(self, winName)
end

function CompResTopJinghunView:loadUIComplete()
	self:registerEvent()
	self:updatePreNum(UserModel:getSoulCoin())
	self:updateNum()
end

function CompResTopJinghunView:registerEvent()
    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
	self.btn_tilijiahao:setTap(c_func(self.onAddTap, self))
	self._root:setTouchedFunc(c_func(self.onAddTap, self))
end

function CompResTopJinghunView:updateUI()
	self:updateNum()
end

function CompResTopJinghunView:onAddTap()
	WindowControler:showWindow("GetWayListView", FuncDataResource.RES_TYPE.SOUL)
end

function CompResTopJinghunView:updateNum()
	local current = UserModel:getSoulCoin()
	local preNum = self:getPreNum()
	if preNum < current then
		if not self:isManualUpdateNum() then
			self:playNumChangeEffect(preNum, current)
		end
	else
		self.txt_1:setString(self:getDisplayNumStr(current))
		self:updatePreNum(current)
	end
end

function CompResTopJinghunView:manualPlayNumChangeAnim()
	local num = UserModel:getSoulCoin()
	self:playNumChangeEffect(self.preNum, num)
end

function CompResTopJinghunView:close()
	self:startHide()
end

function CompResTopJinghunView:getAnimTextNode()
	return self.txt_1
end

function CompResTopJinghunView:getIconAnimCtn()
	return self.ctn_2
end

function CompResTopJinghunView:getIconNode()
	return self.panel_icon_jinghun
end

--TODO dmx 还没有动画文件
function CompResTopJinghunView:getIconAnimName()

end

function CompResTopJinghunView:getNumChangeEffecCtn()
	return self.ctn_1
end

return CompResTopJinghunView
