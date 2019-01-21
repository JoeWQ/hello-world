--
-- User: zhangyanguang
-- Date: 2015/6/10
-- scene基类，实现处理偏移、黑边填充等基本功能

local SceneBase = class("SceneBase", function()
		return display.newScene("SceneBase")
	end 
 )

function SceneBase:ctor()
	self._root = display.newNode();
	self:anchor(0,0)

	--这里创建一个doc的原因是因为  scene 是不能缩放的 缩放scene会出bug 这个是cocos底层的 原造成的
	self.__doc = display.newNode():addto(self)--:scale(GameVars.rootScale)

	--self:scale(GameVars.rootScale);

	--测试用背景图
	-- local bg = display.newSprite("test/bgimage01.png"):opacity(255);
	-- bg:anchor(0,0):pos(GameVars.sceneOffsetX - GameVars.bgOffsetX,GameVars.sceneOffsetY - GameVars.bgOffsetY) 
	-- self.__doc:addChild(bg,0);

	self.__doc:addChild(self._root)

	--根容器偏移
	self.__doc:setPositionX(GameVars.sceneOffsetX)
	self.__doc:setPositionY(GameVars.sceneOffsetY)
	
	--填充黑边
	self:fillBlackBorder();
end

--填充黑边
function SceneBase:fillBlackBorder()
    local screenOffsetX = GameVars.sceneOffsetX;
    if screenOffsetX > 0 then
    	local leftBorderBg = cc.LayerColor:create(cc.c4b(255,0,255,255))
	    -- :size(screenOffsetX, display.height)
	    :size(screenOffsetX, GameVars.scaleHeight)
	    :pos(0, 0);
	    self:addChild(leftBorderBg);

	    local rightBorderBg = cc.LayerColor:create(cc.c4b(255,0,255,255))
	    :size(screenOffsetX, GameVars.scaleHeight)
	    :pos(GameVars.scaleWidth-screenOffsetX, 0);
	    self:addChild(rightBorderBg);
    end

    local screenOffsetY = GameVars.sceneOffsetY;
    if screenOffsetY > 0 then
    	local topBorderBg = cc.LayerColor:create(cc.c4b(255,0,255,255))
	    :size(GameVars.scaleWidth, screenOffsetY)
	    :pos(0, GameVars.scaleHeight - screenOffsetY);
	    self:addChild(topBorderBg,2);

	    local bottomBorderBg = cc.LayerColor:create(cc.c4b(255,0,255,255))
	    :size(GameVars.scaleWidth, screenOffsetY)
	    :pos(0, 0 );
	    self:addChild(bottomBorderBg);
    end
end

function SceneBase:onEnter()
	if DEBUG == 0 or  not DEBUG  then
		return
	end

	FuncCommUI.addLogsView()
	
	-- if AppInformation:getAppPlatform()~="dev" then
	-- 	return
	-- end

	FuncCommUI.addGmEnterView()
end

function SceneBase:onExit()
	--清理所有ui
	WindowControler:clearAllWindow()

	--清理掉所有的子ui 以及没有清理完毕的
	UIBase.deleteAllChild(self )
end

--开始清除场景 --子类扩展
function SceneBase:startClear(  )
	
end


return SceneBase