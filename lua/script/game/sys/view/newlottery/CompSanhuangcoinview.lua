--三皇抽奖系统
--2016-1-10 15:43
--@Author:wukai
local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompSanhuangcoinview = class("CompSanhuangcoinview", ResTopBase)
function CompSanhuangcoinview:ctor(winName)
	CompSanhuangcoinview.super.ctor(self, winName)
end


function CompSanhuangcoinview:loadUIComplete()
	CompSanhuangcoinview.super.loadUIComplete(self)
	self.btn_tilijiahao:setTap(c_func(self.getpathview,self))
	self:registerEvent();
	self:setupdataUI()

end
function CompSanhuangcoinview:registerEvent()

	EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.setupdataUI, self)
	EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, self.setupdataUI, self)

end
function CompSanhuangcoinview:setupdataUI()
	
	local number = UserModel:goldConsumeCoin()
	if number == nil then
		number = 0
	end
	self.txt_tili:setString(number)
	-- self.txt_zongtili:setString("")

end
function CompSanhuangcoinview:getpathview()
	-- echo("获取三皇造物符的路径")
	WindowControler:showTips("获取途径暂未开启")
	-- WindowControler:showWindow("GetWayListView", FuncDataResource.RES_TYPE.ARENACOIN)
	
end


return CompSanhuangcoinview




