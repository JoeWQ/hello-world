
--
-- Author: xd
-- Date: 2016-05-11 18:00:00
-- 战斗 PVE 控制器


GameControlerPVP = class("GameControlerPVP",import(".GameControler"))

-- 初始化函数
function GameControlerPVP:ctor( ... )
	GameControlerPVP.super.ctor(self,...)
	self.gameMode = Fight.gameMode_pvp
end




return GameControlerPVP