--
-- Author: cuiweibo
-- Date: 2016-05-24 12:01:00
-- 战斗 GVE 控制器


GameControlerGVE = class("GameControlerGVE",import(".GameControler"))

-- 初始化函数
function GameControlerGVE:ctor( ... )
	GameControlerGVE.super.ctor(self,...)
end


-- function GameControlerGVE:jumpToFragment()
-- 	self.gameBackup:jumpToFragment()
-- 	self.controler.backUp = false
-- 	--self:scenePlayOrPause(true)-- 测试用的暂停
-- 	self.controler:checkGameResult()
-- end


return GameControlerGVE