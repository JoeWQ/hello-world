--
-- Author: ZhangYanguang
-- 主场景  游戏logo界面

require("game.sys.view.tutorial.TutoralLayer")

SceneLogo = class("SceneLogo", SceneBase)

function SceneLogo:ctor(...)
	SceneLogo.super.ctor(self, ...)

	self._viewRoot = display.newNode()
	self._viewRoot:setPositionX(GameVars.sceneOffsetX)
    self._viewRoot:setPositionY(GameVars.sceneOffsetY)
    self.__doc:addChild(self._viewRoot);
end

function SceneLogo:onEnter()
    -- SceneLogo.super.onEnter(self)
    self:showCorpLogo();
end

-- 公司logo
function SceneLogo:showCorpLogo()
	local logoBg = display.newSprite("logo/logo.png")
	logoBg:anchor(0.5,0.5)
	logoBg:pos(GameVars.cx,GameVars.cy)

	-- print("GameVars.cx,GameVars.cy=",GameVars.cx,GameVars.cy)
	self.logoBg = logoBg
	self._viewRoot:addChild(logoBg)
	
	logoBg:opacity(0)
	local alphaInAction = act.fadein(0.5)
    logoBg:stopAllActions()
    logoBg:runAction(
        cc.Sequence:create(alphaInAction)
    )

    local logoDisappear = function()
    	local alphaOutAction = act.fadeout(0.5)
    	logoBg:stopAllActions()
	    logoBg:runAction(
	        cc.Sequence:create(alphaOutAction)
	    )
	end

	self._viewRoot:delayCall(handler(self, logoDisappear),1)
    self._viewRoot:delayCall(handler(self, self.showGameWarning),2)
end

-- 防沉迷提醒
function SceneLogo:showGameWarning()
	local warningBg = display.newSprite("logo/zhonggao.png")
	warningBg:anchor(0.5,0.5)
	warningBg:pos(GameVars.cx,GameVars.cy)

	self._viewRoot:addChild(warningBg)

	warningBg:opacity(0)
	local alphaInAction = act.fadein(0.5)
    local appearAnim = cc.Spawn:create(alphaInAction) 
    warningBg:stopAllActions()
    warningBg:runAction(
        cc.Sequence:create(alphaInAction)
    )

    self._viewRoot:delayCall(handler(self, self.enterGame),1)
end

function SceneLogo:enterGame()
	--告诉数据中心，显示 logo 完事了
    ClientActionControler:sendNewDeviceActionToWebCenter(
        ClientActionControler.NEW_DEVICE_ACTION.SHOW_LOGO_SUCCESS);
	-- WindowControler:chgScene("SceneMain")
	if not DEBUG_ENTER_SCENE_TEST then
        WindowControler:chgScene("SceneMain");
    else
        WindowControler:chgScene("SceneTest");
    end
end


return SceneLogo