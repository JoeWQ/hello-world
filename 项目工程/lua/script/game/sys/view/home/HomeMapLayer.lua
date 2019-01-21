--guan
--2015.12.13
--主界面中间层

--todo 太多了 拆 怎么拆……

local HomeMapLayer = class("HomeMapLayer", function()
    return display.newLayer()
end)

--npc事件X坐标
local npcPosArray = {700, 550, 420, 280, 110};

local gambleNpcPos = 1400;

local honorNpcPos = 2370;

--最大屏幕
local maxWidth = 2880;

--npc的Y轴位置
local npcPosY = -(640 - 280);

local GLOW_TAG = 562;

function HomeMapLayer:ctor(homeView)
    self._homeView = homeView;
    self._homeView.panel_npc:setVisible(false);
    self._homeView.panel_entity:setVisible(false);

    self._homeView.panel_rongyao:setVisible(false);

    --是不是在封一下比较好
    self._isShowOtherPlayer = LS:pub():get(StorageCode.setting_show_player_st, 
        FuncSetting.SWITCH_STATES.OFF) == FuncSetting.SWITCH_STATES.OFF and true or false;

    --自身要 中下对齐
    self:pos(-GameVars.UIOffsetX, -GameVars.UIOffsetY * 2)

    self._mapPosX = 0;
    self._diffX = 0;

    self._lastMoveEndPos = {x = 0, y = 0};

    --过了多少帧了
    self._totalFrame = 1;

    self._player = nil; 
    --当前展示的npc
    self._cureShowNpcs = {};

    self._usedPos = {};
    self._friendPlayers ={};

    self._npsSpines = {};

    --主场景npc头上的新开启特效
    self._aniToDisposeArray = {};

    self._winSize = cc.Director:getInstance():getWinSize();

    self:initPlayerAndFriend();
    self:clickInit();

    self:initNpc();
    
    self:initHonorNpc();

    self:initFuncNpc();

    self:createLayerOnTop();

    self:initNpcRedPoint();

    EventControler:addEventListener(HomeEvent.GET_ONLINE_PLAYER_OK_EVENT,
        self.initFriend, self);  

    EventControler:addEventListener(HomeEvent.GET_ONLINE_PLAYER_EVENT_OK_AGAIN,
        self.updateFriend, self);     
    
    EventControler:addEventListener(TimeEvent.TIMEEVENT_STATIC_CLOCK_REACH_EVENT, 
        self.honorPlayerUpdate, self)

    EventControler:addEventListener(UserEvent.USEREVENT_NAME_CHANGE_OK, 
        self.nameChangeCallBack, self)

    EventControler:addEventListener(UserEvent.USEREVENT_SET_NAME_OK, 
        self.nameChangeCallBack, self)

    --进战斗收消息
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_ONBATTLEENTER, 
        self.pauseAllSpine, self)
    
    --出战斗收消息  
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE, 
        self.pauseAllSpine, self)

    EventControler:addEventListener(HomeEvent.CHANGE_CAMERA_POSX, 
        self.setCameraPos, self)

     EventControler:addEventListener(HomeEvent.SYSTEM_OPEN_EVENT, 
        self.newSystemOpenCallback, self)   

    EventControler:addEventListener(HomeEvent.HOMEEVENT_COME_BACK_TO_MAIN_VIEW, 
        self.onHomeShow, self); 

    EventControler:addEventListener(UIEvent.UIEVENT_SHOWCOMP, 
        self.onCheckWhenShowWindow, self)

    --显示或隐藏其他玩家
    EventControler:addEventListener(SettingEvent.SETTINGEVENT_SHOWPLSYER_SETTING_CHANGE, 
        self.onFriendSetting, self) 

    EventControler:addEventListener(HomeEvent.TELL_HOME_VIEW_ADD_NPC_HEAD_GLOW_EVENT, 
        self.onAddNpcGlowCallback, self) 

    EventControler:addEventListener(NatalEvent.NATAL_TRUESURE_CHANGLED, 
        self.onNatalChange, self) 

    EventControler:addEventListener(HomeEvent.RED_POINT_EVENT,
        self.redPointDateUpate, self); 

    --新手完成后让主界面其他玩家可以动
    EventControler:addEventListener(TutorialEvent.TUTORIALEVENT_FINISH_ALL, 
        self.onFinishTutorial, self) 

    self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)
end 

function HomeMapLayer:redPointDateUpate(data)
    local id = data.params.redPointType;
    local isShow = data.params.isShow or false;
    local value = self._npcPanelArray[id];

    if value ~= nil then 
        value.npcPanel.panel_red:setVisible(isShow);
    end 
end

function HomeMapLayer:initNpcRedPoint()
    self._homeView:delayCall(function ( ... )
        for k, v in pairs(self._npcPanelArray) do
            --开启才这样
            local isOpen, value = FuncCommon.isSystemOpen(k);
            if isOpen == true and HomeModel:isRedPointShow(k) == true then 
                v.npcPanel.panel_red:setVisible(true);
            else 
                v.npcPanel.panel_red:setVisible(false);
            end     
        end        
    end, 8 / GAMEFRAMERATE);
   
end

function HomeMapLayer:onNatalChange()
    local natalTid =  NatalModel:getNatalTreasure()["1"];
    if self._player:getNatalTid() ~= natalTid then 
        self._player:updateNatalTreasure();
    end 
end

function HomeMapLayer:onFriendSetting(event) 
    local preSetting = self._isShowOtherPlayer;
    echo("--event.params.state--" , event.params.state);
    self._isShowOtherPlayer = event.params.state == FuncSetting.SWITCH_STATES.OFF and true or false;
    
    echo("---preSetting---", preSetting);
    echo("---self._isShowOtherPlayer---", self._isShowOtherPlayer);

    if preSetting ~= self._isShowOtherPlayer then 
        if self._isShowOtherPlayer == true then 
            self:enablefriendShow();
        else 
            self:disablefriendShow();
        end 
    end 
end 

function HomeMapLayer:disablefriendShow()
    for k,v in pairs(self._friendPlayers) do 
        v:goAway(self._middleLayer);       
    end
    self._friendPlayers= {};
end 

function HomeMapLayer:enablefriendShow()
    EventControler:dispatchEvent(HomeEvent.GET_ONLINE_PLAYER_EVENT);
end 

function HomeMapLayer:newSystemOpenCallback(event)
    local openSysName = event.params.sysNameKey;
    -- echo("------openSysName-------", openSysName);
    if self._npcPanelArray[openSysName] ~= nil then 
        self._isShowOpenAni = true;
        self._openSysName = openSysName;
    end 
end

function HomeMapLayer:onAddNpcGlowCallback(event)
    local openSysName = event.params.sysName;
    echo("---onAddNpcGlowCallback:openSysName--", openSysName);

    if self._npcPanelArray[openSysName] ~= nil then 
        self._isShowOpenAni = true;
        self._openSysName = openSysName;
        self:onHomeShow();
    end 
end 

function HomeMapLayer:onCheckWhenShowWindow(event)
    local curViewName = event.params.ui.windowName;
    -- echo("-----onCheckWhenShowWindow---", curViewName);
    if curViewName ~= "HomeMainView" then
        if self._mapTutoriallistener ~= nil then 
            self._mapTutoriallistener:setEnabled(false);
        end
    end 
end

function HomeMapLayer:onHomeShow()
    echo("----HomeMapLayer:onHomeShow----");
    if self._mapTutoriallistener ~= nil then 
        self._mapTutoriallistener:setEnabled(true);
    end 

    if self._isShowOpenAni == true then 
        self._isShowOpenAni = false;

        local npcPanel = self._npcPanelArray[self._openSysName].npcPanel;
        local id =  self._npcPanelArray[self._openSysName].id;

        local iconName = FuncNpcPos.getPicOnHead(id);
        local iconPath = FuncRes.iconIconHome(iconName);
        local iconSp = display.newSprite(iconPath);
        
        npcPanel.panel_npc_bubble:setVisible(false);
        npcPanel.ctn_icon:setVisible(false);
        npcPanel.ctn_npcName:setVisible(true);

        local action = FuncArmature.createArmature("UI_common_gnzhuangguang", 
            npcPanel.ctn_ani, false, GameVars.emptyFunc);

        iconSp:setPosition(0, 0);
        iconSp:setVisible(true);
        FuncArmature.changeBoneDisplay(action, "layer6", iconSp);

        self._aniToDisposeArray[self._openSysName] = true;
    end

    if VipModel:getNextVipGiltToBuy() ~= -1 then 
        self._homeView.panel_zuoshang.panel_red:setVisible(true);
    else 
        self._homeView.panel_zuoshang.panel_red:setVisible(false);
    end 
    
end

function HomeMapLayer:setCameraPos(event)
    local posX = event.params.posX;
    self:setCameraPosX(posX);
end

function HomeMapLayer:createLayerOnTop()
    local topNodeToListenTouch = display.newNode();
    WindowControler:getScene()._topRoot:addChild(topNodeToListenTouch, 
        WindowControler.ZORDER_TopOnUI, WindowControler.ZORDER_TopOnUI);

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    if self._tutoriallistener == nil then 
        self._tutoriallistener = cc.EventListenerTouchOneByOne:create();
    end     

    self._tutoriallistener:setSwallowTouches(false);

    local function onTouchBegan(touch, event)
        if self._lastSelectPlayer ~= nil then 
            self._lastSelectPlayer:reoveGrowDown();
            self._lastSelectPlayer = nil;
        end 
        
        local currentView = WindowControler:getCurrentWindowView()
        local cname = currentView.__cname    

        if cname == "HomeMainView" then 
            AudioModel:playSound("s_com_click2")
        end 

        if self._npcGrowAni ~= nil and cname == "HomeMainView" then 
            self._npcGrowAni:removeFromParent();
            self._npcGrowAni = nil;
        end 

        return true
    end

    local function onTouchEnded(touch, event)
        if self._lastSelectPlayer == nil then
            self._homeView.ctn_OtherIcon:removeAllChildren();
        end 
    end

    self._tutoriallistener:registerScriptHandler(onTouchBegan, 
        cc.Handler.EVENT_TOUCH_BEGAN);

    self._tutoriallistener:registerScriptHandler(onTouchEnded, 
        cc.Handler.EVENT_TOUCH_ENDED);

    eventDispatcher:addEventListenerWithSceneGraphPriority(
        self._tutoriallistener, self);
end

function HomeMapLayer:nameChangeCallBack()
    self._player:setName(UserModel:name());
end

function HomeMapLayer:pauseAllSpine()
    --主角
    self._player:getShowNode():stop();

    --六界第一
    if self._kingNpc ~= nil then 
        self._kingNpc:stop();
    end 

    --npc 事件
    for _, npcPanel in pairs(self._cureShowNpcs) do
        npcPanel.ctn_npcNode:getChildByTag(1):stop();
    end

    --其他玩家 
    for _, friendPlayer in pairs(self._friendPlayers) do
        friendPlayer:getShowNode():stop();
    end  

    --功能npc
    for _, npcSpine in pairs(self._npsSpines) do
        npcSpine:stop();
    end

end

function HomeMapLayer:onFinishTutorial()
    echo("---onFinishTutorial---");
    for _, friendPlayer in pairs(self._friendPlayers) do
        friendPlayer:setTouchEnabled(true);
    end  
end

function HomeMapLayer:playAllSpine()
    --主角
    self._player:getShowNode():play();

    --六界第一
    if self._kingNpc ~= nil then 
        self._kingNpc:play();
    end 

    --npc 事件
    for _, npcPanel in pairs(self._cureShowNpcs) do
        npcPanel.ctn_npcNode:getChildByTag(1):play();
    end

    --其他玩家 
    for _, friendPlayer in pairs(self._friendPlayers) do
        friendPlayer:getShowNode():play();
    end  

    --功能npc
    for _, npcSpine in pairs(self._npsSpines) do
        npcSpine:play();
    end
end

function HomeMapLayer:honorPlayerUpdate(event)
    local clock = event.params.clock;
    echo("testCall " .. tostring(clock));
    --no good！！！！
    if clock == "22:00:00" then 
        -- self._isCheckHonorPlayer = true;
        -- self._checkHonorPlayerCount = 0;

    --         picAssetPath = "/work/heracles/Assets"
    -- picResPath = "/work/heracles/runtime"
    -- scriptPath = "/work/heracles/svn/Resources/script"
    
        self:initHonorNpc();
    end 
end

function HomeMapLayer:initHonorNpc()
    HomeServer:getDiaoestPlayer(c_func(self.initHonorNpcUI, self));
end

--此乃六界第一
function HomeMapLayer:initHonorNpcUI(event)
    if event.error == nil then 
        local worship = event.result.data.worship;
        
        dump(worship, "--worship--");

        if table.length(worship) ~= 0 then 
            local npc = FuncChar.getCharSkinSpine(
                tostring(worship.avatar), worship.level, worship.treasureNatal);

            npc:playLabel(npc.actionArr.stand);

            self._kingNpc = npc;


            local npcPanel = UIBaseDef:cloneOneView(self._homeView.panel_rongyao);
            npcPanel.ctn_npcNode:removeAllChildren();
            npcPanel.ctn_npcNode:addChild(npc)

            if string.sub(worship.name, 1, 1) == "#" then
                worship.name = GameConfig.getLanguage(worship.name);
            end 

            npcPanel.txt_playername:setString(worship.name);

            npcPanel:setPosition(honorNpcPos, npcPosY);

            self._middleLayer:addChild(npcPanel, 50);

            local touchEndCallBack = function (data)
                if self._isHonorMove == false then 
                    AudioModel:playSound("s_com_click1")
                    WindowControler:showWindow("HonorView", worship)
                end 
            end

            local toucMoveCallBack = function ()
                self._isHonorMove = true;
            end

            local touchBeginCallBack = function ()
                self._isHonorMove = false;
            end

            --加个白的
            local holder = FuncRes.a_alpha(70, 122);
            holder:setPositionY(122 / 2);
            npcPanel:addChild(holder);

            -- npcPanel:setTouchedFunc(touchEndCallBack);

            npcPanel:setTouchedFunc(touchEndCallBack, nil, true, 
                touchBeginCallBack, toucMoveCallBack);
            npcPanel:setTouchSwallowEnabled(true);
        end 

    else 
        echo("---er--error---");
    end 
end

function HomeMapLayer:initNpc()
    self._curEventIds = UserModel:events();

    -- dump(self._curEventIds, "---curEventIds--");
    
    for eventId, value in pairs(self._curEventIds) do
        local eventId = tonumber(eventId);
        self:addNpc(eventId, value == 2 and true or false);
    end 
end

function HomeMapLayer:addNpc(eventId, isLucky)
    --在一个地方来个固定的npc todo 配位置
    local spineResName = FuncNpcevent.getSpineName(eventId);
    local npc = ViewSpine.new(spineResName);
    npc:playLabel("stand", true);
    local npcPanel = UIBaseDef:cloneOneView(self._homeView.panel_npc);
    npcPanel.ctn_npcNode:addChild(npc, 1, 1); 

    self:setNpcToPosition(npcPanel);

    self._middleLayer:addChild(npcPanel, 50);

    local touchEndCallBack = function (data)
        if self._isNpcEventMove == false then 
            echo("npc touchEndCallBack");
            AudioModel:playSound("s_com_click1")

            HomeServer:getEventReward(eventId, c_func(self.npcEventCallback, 
                self, eventId, isLucky))
        end 
    end

    local toucMoveCallBack = function ()
        self._isNpcEventMove = true;
    end

    local touchBeginCallBack = function ()
        self._isNpcEventMove = false;
    end

    --加个白的
    local holder = FuncRes.a_alpha(70, 122);
    holder:setPositionY(122 / 2);
    npcPanel:addChild(holder);

    npcPanel:setTouchedFunc(touchEndCallBack, nil, true, 
        touchBeginCallBack, toucMoveCallBack);

    self._cureShowNpcs[eventId] = npcPanel;

    --加个白的
    local holder = FuncRes.a_alpha(70, 122);
    holder:setPositionY(122 / 2);
    npcPanel:addChild(holder);

end

function HomeMapLayer:clickSmelt(sysName, npcPanel)
    echo("click_Smelt");
    local open, value, valueType = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SMELT)
    if open then
        -- WindowControler:showWindow("SmeltMainView");

        WindowControler:showTips("功能未开启");

        if self._aniToDisposeArray[sysName] == true then 
            self._aniToDisposeArray[sysName] = false;
            npcPanel.ctn_ani:removeAllChildren();
            npcPanel.ctn_icon:setVisible(true);
            npcPanel.ctn_npcName:setVisible(true);
        end 
    else
        self:showFuncNotOpenBubbleTips(sysName, npcPanel);
    end
end

function HomeMapLayer:clickSign(sysName, npcPanel)
    echo("click_sign");
    WindowControler:showWindow("SignView");
    -- self:setCameraPosX(2010);
end

function HomeMapLayer:clickTask(sysName, npcPanel)
    echo("click_task");

    local isOpen, needLvl = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST);
    if isOpen == true then 
        WindowControler:showWindow("QuestView");
        if self._aniToDisposeArray[sysName] == true then 
            self._aniToDisposeArray[sysName] = false;
            npcPanel.ctn_ani:removeAllChildren();
            npcPanel.ctn_icon:setVisible(true);
            npcPanel.ctn_npcName:setVisible(true);
        end 
    else 
        self:showFuncNotOpenBubbleTips(sysName, npcPanel);
    end 
end

function HomeMapLayer:clickShop(sysName, npcPanel)
    echo("click_shop");
    local open, value, valueType = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SHOP_1)
    if open then
        WindowControler:showWindow("ShopView");
        if self._aniToDisposeArray[sysName] == true then 
            self._aniToDisposeArray[sysName] = false;
            npcPanel.ctn_ani:removeAllChildren();
            npcPanel.ctn_icon:setVisible(true);
            npcPanel.ctn_npcName:setVisible(true);
        end 
    else
        self:showFuncNotOpenBubbleTips(sysName, npcPanel);
    end
end

function HomeMapLayer:clickGamble(sysName, npcPanel)
    echo("click_gamble");
    local open, value, valueType = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.GAMBLE)
    if open then
        WindowControler:showWindow("YongAnGambleView")
        if self._aniToDisposeArray[sysName] == true then 
            self._aniToDisposeArray[sysName] = false;
            npcPanel.ctn_ani:removeAllChildren();
            npcPanel.ctn_icon:setVisible(true);
            npcPanel.ctn_npcName:setVisible(true);
        end 
    else
        self:showFuncNotOpenBubbleTips(sysName, npcPanel);
    end
end

function HomeMapLayer:clickLottery(sysName, npcPanel)
    echo("click_Lottery");
    WindowControler:showWindow("NewLotteryMainView")
end

function HomeMapLayer:showFuncNotOpenBubbleTips(sysName, npcPanel)
    npcPanel.panel_npc_bubble:setVisible(true);
    npcPanel.panel_npc_bubble:setOpacity(255);
    npcPanel.panel_npc_bubble:stopAllActions();

    local delayAction = cc.DelayTime:create(3);
    local fadeOutAction = cc.FadeOut:create(0.5);
    local sequenceAction = cc.Sequence:create(delayAction, fadeOutAction);

    npcPanel.panel_npc_bubble:runAction(sequenceAction);
end

function HomeMapLayer:initFuncNpc()
    local function createNpc(self, id, funNpcConfig)
        local npcId = FuncNpcPos.getNpcId(id)
        local iconName = FuncNpcPos.getPicOnHead(id)
        local npcPos = FuncNpcPos.getPos(id)

        local npcPanel = UIBaseDef:cloneOneView(self._homeView.panel_entity);

        local npcRes = FuncCommon.getNpcSpineBody(npcId);
        local npc = ViewSpine.new(npcRes);

        self._npsSpines[id] = npc;

        npc:playLabel("stand", true);
        npcPanel.ctn_npcNode:addChild(npc);
        npcPanel:setPosition(npcPos[1], -(640 - npcPos[2]));

        self._middleLayer:addChild(npcPanel, 50);

        self._npcPanelArray[funNpcConfig[id].sysName] = {npcPanel = npcPanel, id = id};

        --icon 
        local iconCtn = npcPanel.ctn_icon;
        local iconPath = FuncRes.iconIconHome(iconName);

        local iconSp = display.newSprite(iconPath)
        iconCtn:removeAllChildren();
        iconCtn:addChild(iconSp);

        local funcNameTid = FuncNpcPos.getFuncDes(id);

        local txtIconPath = FuncRes.iconIconHome(funcNameTid);
        local txtSp = display.newSprite(txtIconPath)
        npcPanel.ctn_npcName:removeAllChildren();
        npcPanel.ctn_npcName:addChild(txtSp);

        local isOpen, value = FuncCommon.isSystemOpen(funNpcConfig[id].sysName);

        local configDes = FuncNpcPos.getDes(id);
        local desStr = GameConfig.getLanguageWithSwap(configDes, value);
        npcPanel.panel_npc_bubble.txt_1:setString(desStr);

        npcPanel.panel_npc_bubble:setVisible(false);

        if isOpen == false and funNpcConfig[id].sysName ~= nil then 
            npcPanel.ctn_icon:setVisible(false);
            npcPanel.ctn_npcName:setVisible(false);
        end 

        npcPanel.panel_click:setOpacity(1);

        local function onTouchBegan(touch, event)
            self._isNpcClickMove = false;
            return true
        end

        local function onTouchMove(touch, event)
            if HomeMapLayer._isCanScroll == false then
                self._isNpcClickMove = false;
            else   
                self._isNpcClickMove = true
            end 
        end

        local function onTouchEnded(touch, event)  
            local chk = true
            if chk == true and self._isNpcClickMove == false then  
                self._diffX = 0;
                --告诉非强制新手，点npc了
                EventControler:dispatchEvent(HomeEvent.CLICK_NPC_EVENT, 
                    {npcKey = funNpcConfig[id].sysName});

                funNpcConfig[id].func(funNpcConfig[id].sysName, npcPanel);
                AudioModel:playSound("s_com_click1");

                npcPanel:removeChildByTag(GLOW_TAG, true)
                --加个光
                self._npcGrowAni = FuncArmature.createArmature("common_xuanzhongb", nil, true);
                npcPanel:addChild(self._npcGrowAni, -1, GLOW_TAG);
                self._npcGrowAni:setPositionY(self._npcGrowAni:getPositionY() + 10);
            end 
        end
        npcPanel.panel_click:setTouchedFunc(onTouchEnded, nil, true, 
                onTouchBegan, onTouchMove);
    end


    local funNpcConfig = {
        [1] = {name = "任务", func = c_func(self.clickTask, self), sysName = FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST},
        [2] = {name = "商店", func = c_func(self.clickShop, self), sysName = FuncCommon.SYSTEM_NAME.SHOP_1},
        [3] = {name = "赌肆", func = c_func(self.clickGamble, self), sysName = FuncCommon.SYSTEM_NAME.GAMBLE},
        [4] = {name = "铸宝", func = c_func(self.clickLottery, self), sysName = FuncCommon.SYSTEM_NAME.LOTTERY},
        [5] = {name = "签到", func = c_func(self.clickSign, self), sysName = FuncCommon.SYSTEM_NAME.SIGN},
        [6] = {name = "熔炼", func = c_func(self.clickSmelt, self), sysName = FuncCommon.SYSTEM_NAME.SMELT},
    };

    self._npcPanelArray = {};

    for id = 1, 6 do
        self._homeView:delayCall(c_func(createNpc, self, id, funNpcConfig), 
            (id - 1) / GAMEFRAMERATE);
        -- createNpc(self, id, funNpcConfig);
    end
end

function HomeMapLayer:npcEventCallback(eventId, isLucky, event)
    if event.error == nil then
        local plotId = FuncNpcevent.getNormalStoryId(eventId);
        local reward = FuncNpcevent.getNormalReward(eventId);

        if isLucky == true then 
            plotId = FuncNpcevent.getLuckyStoryId(eventId);
            reward = FuncNpcevent.getLuckyReward(eventId);
        end

        self:triggerPlot(plotId, reward, eventId);
    end 
end

function HomeMapLayer:setNpcToPosition(npcPanel)
    function getFreePositonX()
        for i = 1, 5 do
            if self._usedPos[i] == nil or self._usedPos[i] == false then 
                return npcPosArray[i], i;
            end 
        end
    end

    function setPostionXUsed(index)
        self._usedPos[index] = true;
    end

    local posX, index = getFreePositonX();
    
    npcPanel:setPosition(posX, npcPosY);
    npcPanel.posIndex = index;

    setPostionXUsed(index);
end

function HomeMapLayer:removeNpc(eventId)
    function setPostionXUnUsed(index)
        self._usedPos[index] = false;
    end

    echo("eventId" , tostring(eventId));

    local npcPanel = self._cureShowNpcs[eventId];

    setPostionXUnUsed(npcPanel.posIndex);

    echo("npcPanel", npcPanel);

    npcPanel:removeFromParent();

    self._cureShowNpcs[eventId] = nil;
end


function HomeMapLayer:initPlayerAndFriend()

    local mapLayer = display.newNode();
    self._mapLayer = mapLayer;
    mapLayer:setPosition(0, GameVars.UIOffsetY);

    self:addChild(mapLayer, 1);

    local frontLayer = display.newNode();
    local middleLayer = display.newNode();
    middleLayer:setPosition(cc.p(0, 0));

    self._middleLayer = middleLayer;

    local backLayer = display.newNode();

    self._player = Player.new();
    middleLayer:addChild(self._player, 200);

    mapLayer:addChild(backLayer, 1);
    mapLayer:addChild(middleLayer, 2);
    mapLayer:addChild(frontLayer, 3);
    
    self.map = MapControler.new(backLayer, frontLayer, "map_suzhoucheng", 1);

    self._backLayer = backLayer;
    self._frontLayer = frontLayer;

    self:setPlayerInitPosInMap(960);
    self._playerPosX = self._player:getPositionX();

    local playerNamePanel = UIBaseDef:cloneOneView(self._homeView.panel_playerTitle);
    self._player:setTitle(playerNamePanel, UserModel:name());

    --与后端通信给我几个人
    if self._isShowOtherPlayer == true then 
        EventControler:dispatchEvent(HomeEvent.GET_ONLINE_PLAYER_EVENT);
    end 
end

local allMap = {
    "map_linjianxiaodao",
    "map_lishushan",
    "map_meijie",
    "map_naiheqiao",
    "map_qionghuafeixu",
    "map_shilipo",
    "map_suoyaota",
    "map_suzhoucheng",
    "map_wanrengufeng",
    "map_xianlingdao",
}

local map_index = 1;

function HomeMapLayer:changeMap()
    local preMap = self.map;

    map_index = map_index + 1;

    if allMap[map_index] == nil then 
        map_index = 1;
    end 

    local mapStr = allMap[map_index];

    self.map = MapControler.new(self._backLayer, self._frontLayer, mapStr, 1);

    preMap:deleteMe();
end



--主角的出生地
function HomeMapLayer:setPlayerInitPosInMap(posX)
    self._player:birth(posX);
    local mapPosX = posX - self._winSize.width / 2;
    self:moveView(-mapPosX);

    self._player:setLocalZOrder(-self._player:getPositionY());
end

--把摄像机放到posX
function HomeMapLayer:setCameraPosX(posX)
    local minValue = self._winSize.width / 2;
    local maxValue = maxWidth - self._winSize.width / 2;

    --最左边
    if posX < minValue then 
        self.map:updatePos(0, 0);
        self._middleLayer:setPositionX(0);
        self._mapPosX = 0;
        return;
    end

    --最右边
    if posX >= maxValue then 
        self.map:updatePos(-maxValue, 0);
        self._middleLayer:setPositionX(-maxValue);
        self._mapPosX = -maxValue;
        return;
    end 

    local cameraPosX = posX - self._winSize.width / 2;

    self.map:updatePos(-cameraPosX, 0);
    self._middleLayer:setPositionX(-cameraPosX);
    self._mapPosX = -cameraPosX;   
end

function HomeMapLayer:frientPlayerCome(playerId, playerInfo)
    local avatarId = tostring(playerInfo.avatar or 101);

    -- local sp = FuncChar.getSpineAni(avatarId, playerInfo.level);
    local sp = FuncChar.getCharSkinSpine(
        avatarId, playerInfo.level, playerInfo.downtownTreasure);
    
    sp:playLabel(sp.actionArr.stand);

    local friendPlayer = FriendPlayer.new(sp, playerInfo);
    self._middleLayer:addChild(friendPlayer, 100);
    friendPlayer:birth(self._middleLayer);

    local cloneTitleUI = UIBaseDef:cloneOneView(self._homeView.panel_otherPlayerTitle);
    friendPlayer:setTitle(cloneTitleUI, playerInfo.name);

    friendPlayer:setLocalZOrder(-friendPlayer:getPositionY());

    self._friendPlayers[playerId] = friendPlayer;

    local touchEndCallBack = function (playerInfo, friendPlayer)
        local clonePanel = UIBaseDef:cloneOneView(self._homeView.panel_otherLvl);

        local action = FuncArmature.createArmature("UI_common_tubiaofeiru", 
            self._homeView.ctn_OtherIcon, false, GameVars.emptyFunc);

        clonePanel:setPosition(0, 0);
        clonePanel:setVisible(true);
        FuncArmature.changeBoneDisplay(action, "layer2", clonePanel);

        clonePanel.txt_lvl:setString(playerInfo.level);

        clonePanel:setTouchedFunc(GameVars.emptyFunc, nil, true, function () 
            FriendViewControler:showPlayer(playerInfo._id)
        end);

        clonePanel:setTouchSwallowEnabled(true);

        friendPlayer:addGrowDown();
        self._lastSelectPlayer = friendPlayer;

        AudioModel:playSound("s_com_click1")

        --icon 
        local iconHead = CharModel:getCharIconByHid( friendPlayer:getHid() );
        iconHead:setRotationSkewY(180);
        clonePanel.ctn_other:addChild(iconHead);
    end

    --坑 下面return false 后照样响应 touchEndCallBack，可以拦截…………
    -- local touchBeginCallBack = function ()
    --     if true then
    --         echo("----false----"); 
    --         return false;
    --     else 
    --         echo("----true----"); 
    --         return true;
    --     end 
    -- end

    --加个白的
    local holder = FuncRes.a_alpha(70, 10);
    holder:setPositionY(10 / 2);
    friendPlayer:addChild(holder);

    friendPlayer:setTouchedFunc(c_func(touchEndCallBack, playerInfo, friendPlayer));
    friendPlayer:setTouchSwallowEnabled(true);

    if TutorialManager.getInstance():isAllFinish() == false then 
        friendPlayer:setTouchEnabled(false);
    end 

end

function HomeMapLayer:initFriend(event)
    echo("--initFriend initFriend initFriend--");

    local onlinesPlayers = event.params.onLines;
    -- dump(onlinesPlayers, "--onlinesPlayers--");

	math.newrandomseed();
    self._friendPlayers = {};

    local i = 0;
    for playerId, v in pairs(onlinesPlayers) do

        self._homeView:delayCall(c_func(self.frientPlayerCome, self, playerId, v), 
            (i - 1) / GAMEFRAMERATE);
        i = i + 1;
    end
end

function HomeMapLayer:updateFriend(data)
    local onlinesPlayers = data.params.onLines;

    --走的人
    -- todo 从 self._middleLayer 把他 remove 了
    for playerId, v in pairs(self._friendPlayers) do
        if onlinesPlayers[playerId] == nil then 
            echo("go away playerId " .. tostring(playerId));
            v:goAway(self._middleLayer);            
            self._friendPlayers[playerId] = nil;
        end 
    end

    --新进来的人
    for playerId, v in pairs(onlinesPlayers) do
        if self._friendPlayers[playerId] == nil then 
            echo("new playerId " .. tostring(playerId));
            self:frientPlayerCome(playerId, v);
        end 
    end
    
end

--[[
    设置能否滚动
]]
function HomeMapLayer.setCanScroll(isCanScroll)
    HomeMapLayer._isCanScroll = isCanScroll;
end

--点击走路
function HomeMapLayer:clickInit()
    -- local rect = cc.rect(0, -GameVars.height + 120, 
    --     GameVars.width, GameVars.height - 120 - 150);

    local rect = cc.rect(100, 120, 
        GameVars.width, GameVars.height - 150 - 120);

    local touchEndCallBack = function (touch, event)  
        self._isMoveNow = false;
        self._isGoOnMove = false;
    end

    local touchBeginCallBack = function (touch, event)
        if HomeMapLayer._isCanScroll == false then 
            return false;
        end 
        -- echo("---touchBeginCallBack touchBeginCallBack touchBeginCallBack---");

        local point = touch:getLocation();
        -- dump(point, "-----point----");
        local chk = rectEx.contain(rect, point.x, point.y);
        if chk == true then 

            self._isGoOnMove = true;
            self._isMoveNow = false;
            self._lastMoveEndPos = self:convertToNodeSpace(touch:getLocation());
            self._lastClickBeginPos = self._lastMoveEndPos;

            -- echo("---touchBeginCallBack----");
            local uiPos = self:convertToNodeSpace(touch:getLocation());
            -- dump(uiPos, "----uiPos---");
            local point = self._player:convertToWorldSpace(cc.p(0,0));

            self._diffX = uiPos.x - point.x;

            if self._diffX ~= 0 then 
                if self._diffX < 0 then
                    self._player:getShowNode():setRotationSkewY(180);
                else 
                    self._player:getShowNode():setRotationSkewY(0);
                end
                self._player:getShowNode():playLabel(self._player:getShowNode().actionArr.run);
            end 
            return true;
        end 
    end

    local touchMoveCallBack = function (touch, event) 
        local point = self:convertToNodeSpace(touch:getLocation());
        local diffXBetweenMove = self._lastClickBeginPos.x - point.x;

        -- echo("---diffXBetweenMove---", diffXBetweenMove);

        --滚大于50个像素才算滚
        if diffXBetweenMove > 50 or diffXBetweenMove < -50 then 
            diffXBetweenMove = self._lastMoveEndPos.x - point.x;


            self._isGoOnMove = false;
            self._isMoveNow = true;
            self._lastMoveEndPos = {x = point.x, y = point.y};

            -- echo("--diffXBetweenMove--", diffXBetweenMove);
            --背景移动
            if diffXBetweenMove > 0 then  --右往左滑动
                diffXBetweenMove = -diffXBetweenMove;
                local targetPosX = self._mapPosX + diffXBetweenMove;

                --屏幕内才滚
                if targetPosX < 0 and targetPosX > -maxWidth + self._winSize.width then 
                    self:moveView(diffXBetweenMove);
                end

            elseif diffXBetweenMove < 0 then --左往右滑
                diffXBetweenMove = -diffXBetweenMove;
                local targetPosX = diffXBetweenMove + self._mapPosX;
                --屏幕内才滚
                if targetPosX < 0 then 
                    self:moveView(diffXBetweenMove);
                end 
            end 
        else
            self._lastMoveEndPos = {x = point.x, y = point.y};
        end 
    end

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    --注册有优先级的监听事件
    local tutoriallistener = cc.EventListenerTouchOneByOne:create();

    tutoriallistener:setSwallowTouches(false);


    tutoriallistener:registerScriptHandler(touchEndCallBack,
        cc.Handler.EVENT_TOUCH_ENDED);
    tutoriallistener:registerScriptHandler(touchBeginCallBack, 
        cc.Handler.EVENT_TOUCH_BEGAN);
    tutoriallistener:registerScriptHandler(touchMoveCallBack, 
        cc.Handler.EVENT_TOUCH_MOVED);

    eventDispatcher:addEventListenerWithFixedPriority(
        tutoriallistener, 9);

    self._mapTutoriallistener = tutoriallistener;
end

function HomeMapLayer:moveView( xoffize )
    self._mapPosX = self._mapPosX + xoffize;
    self.map:updatePos(self._mapPosX, 0);
    self._middleLayer:pos(self._mapPosX, 0);
end

--人物和地图的坐标差
function HomeMapLayer:getDiffXAbsBewteenPlayerAndMap()
    return math.abs( self._player:getPositionX() - self._mapPosX);
end

--主角是不是在屏幕中间
function HomeMapLayer:isPlayerInMapMiddle()
    local playerPosXRelativeToOrign = self._mapPosX + self._player:getPositionX();
    local diff = math.abs( playerPosXRelativeToOrign - self._winSize.width / 2 );

    if diff < 2 * self._player:getCurSpeed() and diff > -2 * self._player:getCurSpeed() then 
        return true
    else 
        return false;
    end 
end

function HomeMapLayer:setToPlayerToMiddle()
    self._player:setPositionX(-self._mapPosX + self._winSize.width / 2);
    --为毛要有这个变量？？？？？
    self._playerPosX = -self._mapPosX + self._winSize.width / 2
end

function HomeMapLayer:updateFrame()
    -- echo("--------updateFrame updateFrame updateFrame-------");
    self._totalFrame = self._totalFrame + 1;
    --todo 
    local playerWidth = 20;
    --移动相关
	local curSpeed = self._player:getCurSpeed();

    if self._diffX > 0 then  --往右走

        if self._isGoOnMove == false then 
            -- echo("---self._diffX > 0---");
            self._diffX = self._diffX - curSpeed;
        end 

        self._playerPosX = self._playerPosX + curSpeed;
        self._player:setPositionX(self._playerPosX);

        --屏幕内才滚
        if self._playerPosX < maxWidth - self._winSize.width / 2 + playerWidth/2 and 
            self._playerPosX > self._winSize.width / 2 - playerWidth/2 then 

            if self:isPlayerInMapMiddle() == true and self._isMoveNow == false then 
                self:moveView(-curSpeed);
                self:setToPlayerToMiddle();
            end 
        else 
            -- echo("--self._diffX > 0--");
            self._isGoOnMove = false;
        end 

        if self._diffX < 0 then 
        	self._diffX = 0;
        end 

    elseif self._diffX < 0 then --往左走
        if self._isGoOnMove == false then 
            -- echo("---self._diffX < 0---");

            self._diffX = self._diffX + curSpeed;
        end 

        self._playerPosX = self._playerPosX - curSpeed;
        self._player:setPositionX(self._playerPosX);

        --屏幕内才滚
        if self._playerPosX > self._winSize.width / 2 and 
            self._playerPosX < maxWidth - self._winSize.width / 2 then 
            if self:isPlayerInMapMiddle() == true and self._isMoveNow == false then 
                self:moveView(curSpeed);
                self:setToPlayerToMiddle();
            end
        else 
            -- echo("--self._diffX < 0--");

            self._isGoOnMove = false;
        end 

        if self._diffX > 0 then 
        	self._diffX = 0;
        end 

    else 
        self._player:getShowNode():playLabel(self._player:getShowNode().actionArr.stand);
    end 

    local isUpdateFriend = function ( ... )
        local isFrameReach = self._totalFrame % GameStatic._local_data.onLineUserHeart == 0;
        local isHomeViewShow = self._homeView:isVisible() == true;
        local isOtherFriendShow =  self._isShowOtherPlayer == true;

        if isFrameReach and isHomeViewShow and isOtherFriendShow then 
            return true;
        else
            return false;
        end
    end
 
    --人物进出相关 没 onLineUserHeart 帧率进行一次判断
    if isUpdateFriend() == true then 
        local rids = self:getRids();
        EventControler:dispatchEvent(HomeEvent.GET_ONLINE_PLAYER_EVENT_AGAIN,
            {rids = rids});
    end 
end

function HomeMapLayer:getRids()
    local rids = {};
    for k, v in pairs(self._friendPlayers) do
        table.insert(rids, k);
    end
    return rids;
end

function HomeMapLayer:triggerPlot(plotId, rewards, eventId)
    npcPanel = self._cureShowNpcs[eventId];
    npcPanel:setTouchEnabled(false);

    PlotDialogControl:init()

    local onUserAction = function(ud)
        --echo("-----RomanceActionBaseView:endTell------", ud.step, ud.index)
        if ud.step == -1 and ud.index == -1 then
            FuncCommUI.startRewardView({rewards});
            self:removeNpc(eventId);
        end
    end

    PlotDialogControl:showPlotDialog(plotId, onUserAction)
    PlotDialogControl:setSkipButtonVisbale(true);
    
end

function HomeMapLayer:updateNpcUI()
    local curEventIds = UserModel:events();
    for eventId, value in pairs(curEventIds) do
        if self._curEventIds[eventId] == nil then 
            local eventId = tonumber(eventId);
            self:addNpc(eventId, value == 2 and true or false);
        end 
    end

    self._curEventIds = curEventIds;
end

function HomeMapLayer:dispose()
    WindowControler:getScene()._topRoot:removeChildByTag(
        WindowControler.ZORDER_TopOnUI, true);

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();

    if self._mapTutoriallistener ~= nil then 
        eventDispatcher:removeEventListener(self._mapTutoriallistener);
        self._mapTutoriallistener = nil;
    end 

    self.map:deleteMe();
    EventControler:clearOneObjEvent(self)
    FightEvent:clearOneObjEvent(self)
end

return HomeMapLayer;





