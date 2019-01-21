--2015.7.21 guan
--2016.4.20 guan 

TutoralLayer = class("TutoralLayer", function()
    return display.newNode();
end)

local ENUM_LAYOUT_POLICY = {
    ["CENTER"] = 0,
    ["LEFT"] = 2,
    ["RIGHT"] = 1,
    ["UP"] = 2,
    ["DOWN"] = 1,
};

function TutoralLayer:ctor()
    FuncArmature.loadOneArmatureTexture("UI_qiangzhitishi", nil, true);
    FuncArmature.loadOneArmatureTexture("UI_main_img_shou", nil, true);

    self._tutorialManager = TutorialManager.getInstance();
    self._tutorialId = 1;

    self:initUI();
    self:initClick();
end

function TutoralLayer:initUI() 
    self._touchNode = display.newLayer();
    self:addChild(self._touchNode, -1);
    self._touchNode:setTag(123);

    self._grayLayer = self:createGrayLayer();
    self:addChild(self._grayLayer, -1);

    self._npcContent = self:createNpcContent();
    self:addChild(self._npcContent, 1);

    self._arrowSprite = nil;
end

function TutoralLayer:createArrow(arrowName)
    local ani = FuncArmature.createArmature("UI_main_img_shou_sz", nil, true);
    return ani;
end

function TutoralLayer:createNpcContent()
    local widget = WindowsTools:createWindow("NpcContentWidget");
    widget:setVisible(false);

    return widget;
end

--临时的有色点击提示区域
function TutoralLayer:createRectTempNode()
    local node = display.newNode();
    return node;
end

function TutoralLayer:createGrayLayer()

    local _ellipse = cc.ClippingEllipse:create();
    _ellipse:setMaskColor(cc.c4f(0.0,0.0,0.0,120/255.0));
    _ellipse:setContentSize(cc.size(GameVars.width,GameVars.height));
    _ellipse:setEllipsePosition(cc.p(240,300));
    _ellipse:setEllipseSize(cc.size(200,150));
    _ellipse:setColorEasePercent(0.2);

    _ellipse:pos(0, 0);

    return _ellipse
end

function TutoralLayer:initClick()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();

    --setTouchedFunc 中的点击事件第二针才有效 擦
    local function onTouchBegan(event)
        local uiPos = cc.p(event.x, event.y);

        self.__beginEvent = event;

        if self:isInClickArea(uiPos.x, uiPos.y) == true then 
            self._isBeginIn = true;
        else  
            -- 不在点击区域
            self._isBeginIn = false;
        end 
        return true
    end

    local function onTouchEnded(event) 
        local uiPos = cc.p(event.x, event.y);

        local isEndIn = self:isInClickArea(uiPos.x, uiPos.y)

        -- echo("-------------------self._isBeginIn == true--", self._isBeginIn);
        -- echo("---begin-- xy", self.__beginEvent.x, self.__beginEvent.y);
        -- echo("-------------------self._isEndIn----", isEndIn);
        -- echo("--end-- xy", event.x, event.y);

        if isEndIn == true and self._isBeginIn == true then
            --完成这步引导
            self:setChildUnvisible();
            self._tutorialManager:finishCurTutorialId();
        else 
            --没有按新手引导进行
            self:showWrongClickTips()
        end 
    end

    self._touchNode:setTouchedFunc(onTouchEnded, nil, false, 
        onTouchBegan);
    self._touchNode:setTouchEnabled(true);
end

function TutoralLayer:setChildUnvisible()
    self._grayLayer:setVisible(false);
    self._npcContent:setVisible(false);
end

function TutoralLayer:showWrongClickTips()
    local str = GameConfig.getLanguage("guide_wrong_click_tips"); 
    WindowControler:showTips(str);

    --目前最多创建3个clickEff 循环使用 下面是抄袭的~
    local clickEffArr = {}
    local getClickkEff = function ( index )
        if not clickEffArr[index] then
            clickEffArr[index] = FuncArmature.createArmature("UI_qiangzhitishi_tishi", 
                self, false, GameVars.emptyFunc)
        end
        local ani = clickEffArr[index]
        ani:visible(true)
        ani:playWithIndex(0, false)
        ani:doByLastFrame(false, true)
        ani:setLocalZOrder(300);
        return ani
    end

    local clickIndex = 0

    local index = clickIndex%3 +1
    clickIndex = clickIndex+ 1
    local clickEff = getClickkEff(index)
    
    local pos = self:getTargetPos();
    clickEff:setPosition(pos.x, pos.y);

end

function TutoralLayer:isInClickArea(x, y, isNeedToGL)
    if self:isCanClickEverwhere() == true then 
        echo("---self:isCanClickEverwhere() == true----");
        return true;
    end 

    local clickPosGL =  {x = x, y = y};  

    if isNeedToGL then 
        clickPosGL = self:convertToGL({x = x, y = y});  
    end 

    local configClickRect = FuncGuide.getRect(self._groupId, self._tutorialId);

    local width, height = configClickRect[1], configClickRect[2];

    local pos = self:getTargetPos();

    local rect = cc.rect(pos.x - width / 2, 
        pos.y - height / 2, width, height);

    return cc.rectContainsPoint(rect, cc.p(clickPosGL.x, clickPosGL.y));
end 

function TutoralLayer:getTargetPos()
    local configClickPos = FuncGuide.getClickPos(self._groupId, self._tutorialId);

    local horizontalLayout, verticalLayout, scaleX, scaleY = 
        FuncGuide.getAdaptation(self._groupId, self._tutorialId);
    local pos = self:adjustToCurPos({x = configClickPos[1], y = configClickPos[2]}, 
        horizontalLayout, verticalLayout, scaleX, scaleY);

    return pos;
end

function TutoralLayer:setUIByTurtoralId(gid, tid)
    self._tutorialId = tid;
    self._groupId = gid;

    --是否有剧情
    local plotId = FuncGuide.getPlotId(self._groupId, self._tutorialId);
    if plotId ~= nil then 
        self:setPlotUI(plotId);
    else 
        self:setGuildUI();
    end 
end

--灰色蒙版有没有 
function TutoralLayer:setMaskSkin()
    local maskSkin = FuncGuide.getMaskskin(self._groupId, self._tutorialId);
    
    if maskSkin == "0" then 
        self._grayLayer:setVisible(false);
    else 
        self._grayLayer:setVisible(true);
    end 
end

function TutoralLayer:setGuildUI()
    local curWinName = FuncGuide.getWinName(
        self._groupId, self._tutorialId);

    --主界面场景坐标
    if curWinName == "HomeMainView" then
        local posX = FuncGuide.getCameraPosX(self._groupId, self._tutorialId);        
        if posX ~= nil then 
            EventControler:dispatchEvent(HomeEvent.CHANGE_CAMERA_POSX, 
                {posX = posX});
        end 
    end 

    self:setClickUI();
    self:setNpcContentUI();
end

--时候是点击任意位置有效
function TutoralLayer:isCanClickEverwhere()
    local mode = FuncGuide.getMode(self._groupId, 
        self._tutorialId);
    return mode == "1" and true or false;
end

function TutoralLayer:setClickUI()
    if self._arrowSprite ~= nil then 
        self._arrowSprite:removeFromParent();
        self._arrowSprite = nil;
    end 

    if self:isCanClickEverwhere() == true then
        self._grayLayer:setVisible(false);
    else 
        self._grayLayer:setVisible(true);
    end

    -- --点击位置
    local configClickRect = FuncGuide.getRect(self._groupId, self._tutorialId);
    local width, height = configClickRect[1], configClickRect[2];

    local pos = self:getTargetPos();
    self._grayLayer:setEllipseSize(cc.size(width, height));
    self._grayLayer:setEllipsePosition(cc.p(pos.x, pos.y));

    --箭头文件
    local arrowName = FuncGuide.getArrowPicName(self._groupId, self._tutorialId);
    
    --没有手指
    if arrowName ~= nil then 
        local spriteArrow = self:createArrow(arrowName);
        self._arrowSprite = spriteArrow;
        self:addChild(self._arrowSprite, 200);
        self._arrowSprite:setPosition(pos.x, pos.y);  

        local rotate = FuncGuide.getArrowDirection(self._groupId, self._tutorialId);
        self._arrowSprite:rotation(rotate);
        self._arrowSprite:setVisible(true)
    end 

end

function TutoralLayer:setNpcContentUI()
    local spineName = FuncGuide.getNpcskin(self._groupId, 
        self._tutorialId);

    if spineName ~= nil then 

        self._npcContent:setVisible(true);

        local npcPos = FuncGuide.getNpcPos(self._groupId, 
            self._tutorialId);
        if npcPos == nil then 
            npcPos = self:getMiddlePos();
        end 
       
        self._npcContent:setPosition(npcPos[1], npcPos[2]);

        --显示内容
        local tid = FuncGuide.getTextcontentIndex(self._groupId, 
            self._tutorialId);
        self._npcContent.panel_npcAndWord.panel_word.txt_1:setString(
            GameConfig.getLanguage(tid));
    end
end

function TutoralLayer:getMiddlePos()
    local winWidth = GameVars.width;
    local winHeight = GameVars.height;

    local widgetRect = self._npcContent.panel_npcAndWord:getContainerBox();
    -- local anchorPoint = self._npcContent.panel_npcAndWord:getAnchorPoint();
    -- dump(anchorPoint, "---anchorPoint-----");
   
    return {winWidth / 2 - widgetRect.width / 2, 
        winHeight / 2  + widgetRect.height / 2};
end

function TutoralLayer:setPlotUI(plotId)
    self._touchNode:setTouchEnabled(false);
    self:setVisible(false);

    PlotDialogControl:init();
    local onUserAction = function(ud)
        if ud.step == -1 and ud.index == -1 then
            self:setGuildUI();
            self._touchNode:setTouchEnabled(true);
            self:setVisible(true);
        end
    end
    PlotDialogControl:showPlotDialog(plotId, onUserAction)
    PlotDialogControl:setSkipButtonVisbale(true);
end

function TutoralLayer:getTouchNode()
    return self._touchNode;
end

function TutoralLayer:convertToGL(pos)
    local glView = cc.Director:getInstance():getOpenGLView();

    local designResolutionSize = glView:getDesignResolutionSize();

    pos = cc.Director:getInstance():convertToGL(
        {x = pos.x, y = pos.y}); 

    if designResolutionSize.width > GameVars.maxScreenWidth then 
    	pos.x = pos.x - (designResolutionSize.width - GameVars.maxScreenWidth) / 2;
    elseif designResolutionSize.height > GameVars.maxScreenHeight then 
    	pos.y = pos.y - (designResolutionSize.height - GameVars.maxScreenHeight) / 2;
    end 

    return pos;
end

--得到坐标差
function TutoralLayer:getDifXandY()

    local diffWidth = GameVars.width - CONFIG_SCREEN_WIDTH;
    local difHeight = GameVars.height - CONFIG_SCREEN_HEIGHT;

    return diffWidth, difHeight;
end

--从960*640到当前机器的坐标
function TutoralLayer:adjustToCurPos(pos, horizontalLayout, verticalLayout, scaleX, scaleY)
    -- echo("adjustToCurPos", horizontalLayout, verticalLayout);

    local difX, difY = self:getDifXandY();

    if horizontalLayout == ENUM_LAYOUT_POLICY.LEFT and verticalLayout == ENUM_LAYOUT_POLICY.CENTER then
        if scaleX ~= 1 then 
    	   return {x = pos.x + (scaleX / 2) * difX / 2, y = pos.y + difY / 2};
        else 
           return {x = pos.x, y = pos.y + difY / 2};
        end
    elseif horizontalLayout == ENUM_LAYOUT_POLICY.LEFT and verticalLayout == ENUM_LAYOUT_POLICY.UP then
        --左上 done

        if scaleX ~= 1 then 
           return {x = pos.x + (scaleX / 2) * difX / 2, y = pos.y + difY};
        else 
            return {x = pos.x, y = pos.y + difY};
        end

    elseif horizontalLayout == ENUM_LAYOUT_POLICY.LEFT and verticalLayout == ENUM_LAYOUT_POLICY.DOWN then 
        --左下 done
        return { x = pos.x, y = pos.y};
    elseif horizontalLayout == ENUM_LAYOUT_POLICY.CENTER and verticalLayout == ENUM_LAYOUT_POLICY.UP then
        --上对齐 done
        return { x = pos.x + difX / 2, y = pos.y + difY};
    elseif horizontalLayout == ENUM_LAYOUT_POLICY.CENTER and verticalLayout == ENUM_LAYOUT_POLICY.DOWN then
        --下对齐 done
        return {x = pos.x + difX / 2, y = pos.y};
    elseif horizontalLayout == ENUM_LAYOUT_POLICY.RIGHT and verticalLayout == ENUM_LAYOUT_POLICY.CENTER then
        --右对齐 done
        return {x = pos.x + difX, y = pos.y + difY / 2};
    elseif horizontalLayout == ENUM_LAYOUT_POLICY.RIGHT and verticalLayout == ENUM_LAYOUT_POLICY.UP then
        --右上对齐 done
        return {x = pos.x + difX, y = pos.y + difY};
    elseif horizontalLayout == ENUM_LAYOUT_POLICY.RIGHT and verticalLayout == ENUM_LAYOUT_POLICY.DOWN then
        --右下 done
        -- echo(horizontalLayout, horizontalLayout);
        return {x = pos.x + difX, y = pos.y};
    else 
        --CENTER CENTER
    	return {x = pos.x + difX / 2, y = pos.y + difY / 2};
    end 
end

function TutoralLayer:dispose()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();

    FuncArmature.clearOneArmatureTexture("UI_qiangzhitishi", true);
    FuncArmature.clearOneArmatureTexture("UI_main_img_shou", true);

end


