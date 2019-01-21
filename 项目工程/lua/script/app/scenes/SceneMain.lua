--
-- Author: xd
-- Date: 2015-11-26 15:03:42
-- 主场景  登入进去以后就是主场景

SceneMain = class("SceneMain", SceneBase)

function SceneMain:ctor(...)
    SceneMain.super.ctor(self, ...)
    -- 战斗root
    self._battleRoot = display.newNode()
    self.__doc:addChild(self._battleRoot);

    --新手引导层
    self._tutoralRoot = display.newNode():addto(self.__doc)

    --置顶的root
    self._topRoot = display.newNode()

    self.__doc:addChild(self._topRoot)

    if not DEBUG_ENTER_SCENE_TEST then
        -- 初始化login界面背景
        self:initLoginLoadingViewBg()
    end
end

function SceneMain:initLoginLoadingViewBg()
    local cfg = WindowsTools:getUiCfg("LoginLoadingView")
    local loginBg = display.newSprite("bg/" .. cfg.bg)
    loginBg:anchor(0.5,0.5)
    loginBg:pos(GameVars.cx,GameVars.cy)
    self.__doc:addChild(loginBg,-1)
end

-- 进入场景
function SceneMain:onEnter()
    SceneMain.super.onEnter(self)

    -- 注册事件
    self:registEvent()
    -- 最先需要初始化的
    self:initFirst()
    
    -- 如果是自动登录
    if self.autoLogin then
        -- self:doAutoLogin()
    else
        self:showLoading()
    end
end

-- 在登入之前需要初始化的东西放在这里
function SceneMain:initFirst()
    FuncArmature.loadOneArmatureTexture("UI_zhuanjuhua", nil, true)
    --初始化随机因子
    RandomControl.setOneRandomYinzi(TimeControler:getTime(),0)

    -- AudioModel初始化
    AudioModel:init()
     -- 是否显示点击坐标
    if SHOW_CLICK_POS == true then 
        self:showClickPos();
    end

    if DEBUG_ENTER_SCENE_TEST then
        self:initCommonRes()
    end
end

-- 注册事件
function SceneMain:registEvent()
    EventControler:addEventListener(LoginEvent.LOGINEVENT_LOG_OUT, self.onLogoutComplete, self)
    EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, self.onLoginComplete, self);
end

-- 执行自动登录
function SceneMain:doAutoLogin()
    --开发模式下开启,自动登录
    if self.autoLogin then
        EventControler:addEventListener(LoginEvent.LOGINEVENT_GET_SERVER_LIST_OK, self.onGetServerListOk, self)
        EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, self.onLoginModelUpdateComplete, self);
        LoginControler:doLogin(self.userId,self.password)
    end
end

-- 登录完成回调
function SceneMain:onLoginComplete()
    -- 空实现
end

-- 登出完成回调
function SceneMain:onLogoutComplete()
    -- 空实现
end

-- Login Model 更新完成回调
function SceneMain:onLoginModelUpdateComplete()
    GameLuaLoader:loadGameSysFuncs()
    GameLuaLoader:loadGameBattleInit()
end

-- 进入登录loading界面
function SceneMain:showLoading()
    WindowControler:showWindow("LoginLoadingView")
end

--用于开发
function SceneMain:onGetServerListOk()
    local list = LoginControler:getServerList()
    for _, info in ipairs(list) do
        if info._id == "dev" then
            LoginControler:setServerInfo(info)
            LoginControler:doSelectZone()
            break
        end
    end
end

-- 显示点击坐标
function SceneMain:showClickPos()
    self._layer = cc.Node:create();
    self:addChild(self._layer);

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    if self._tutoriallistener == nil then 
        self._tutoriallistener = cc.EventListenerTouchOneByOne:create();
    end 

    -- self._tutoriallistener:setSwallowTouches(true);

    local function onTouchBegan(touch, event)
        local uiPos = touch:getLocationInView()

        local clickPosGL = Tool:convertToGL({x = uiPos.x, y = uiPos.y}); 

        -- echo("click pos x: " .. tostring(clickPosGL.x) .. " y: " .. tostring(clickPosGL.y));
        -- dump(clickPosGL, "--gl--pos");
        return true
    end

    local function onTouchEnded(touch, event)  
        local uiPos = touch:getLocationInView();
        -- dump(uiPos, "--pos---onTouchEnded");
    end

    self._tutoriallistener:registerScriptHandler(onTouchEnded,
        cc.Handler.EVENT_TOUCH_ENDED);
    self._tutoriallistener:registerScriptHandler(onTouchBegan, 
        cc.Handler.EVENT_TOUCH_BEGAN);

    eventDispatcher:addEventListenerWithSceneGraphPriority(
        self._tutoriallistener, self._layer); 
end

playSound = true
--创建点击屏幕特效
function SceneMain:createClickEff(  )
    FuncArmature.loadOneArmatureTexture("UI_ClickEffect", nil, true)
    --注册全屏点击特效
    --目前最多创建3个clickEff 循环使用

    local clickNode = display.newNode():addto(self,100):size(GameVars.width,GameVars.height )
    clickNode:anchor(0,0):pos(GameVars.sceneOffsetX ,GameVars.sceneOffsetY)

    local clickEffArr = {}
    local getClickkEff = function ( index )
        if not clickEffArr[index] then
            clickEffArr[index] =  FuncArmature.createArmature("UI_ClickEffect", self._topRoot, false, GameVars.emptyFunc)
           
        end
        local ani = clickEffArr[index]
        ani:visible(true)
        ani:playWithIndex(0, false)
        ani:doByLastFrame(false, true)
        return ani
    end

    local clickIndex = 0

    --点击屏幕创建 特效
    local tempFunc = function (e  )

        local index = clickIndex%3 +1
        clickIndex = clickIndex+ 1
        local clickEff = getClickkEff(index)
        
        local turnPos = self._topRoot:convertToNodeSpace(e)
        clickEff:pos(turnPos.x,turnPos.y)

        if playSound == true then
            AudioModel:playSound("s_com_click2")
        end 
    end



    clickNode:setTouchedFunc(GameVars.emptyFunc, cc.rect(0 ,0,GameVars.width,GameVars.height ), 
        false, tempFunc, nil, false)
end

-- ===================================================== 对外接口 =====================================================

function SceneMain:initCommonRes()
    self:createClickEff()
     -- 需要加载通用ui特效
    FuncArmature.loadOneArmatureTexture("UI_common", nil, true)
    FuncArmature.loadOneArmatureTexture("common", nil, true)
end


-- 获取战斗root
function SceneMain:getBattleRoot()
    return self._battleRoot
end

-- 显示战斗root 那么就需要隐藏 root
function SceneMain:showBattleRoot()
    self._root:visible(false)
    self._battleRoot:visible(true)
end

-- 显示主root
function SceneMain:showRoot()
    self._root:visible(true)
    self._battleRoot:visible(false)
end

-- 显示玩家基本信息
function SceneMain:showUserInfo()
    -- 空实现
end

return SceneMain
