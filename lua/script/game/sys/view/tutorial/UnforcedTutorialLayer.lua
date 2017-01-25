-- 2016.5.17
-- guan 
--[[
    主界面的点击是层是个 layer 用来接收点击和显示气泡
    进入强制引导，则用 TutorialManager

    --只有在主界面才做点击检测
]]

UnforcedTutorialLayer = class("UnforcedTutorialLayer", function()
    return display.newNode();
end)

--todo ui的显示和隐藏

local ENUM_LAYOUT_POLICY = {
    ["CENTER"] = 0,
    ["LEFT"] = -1,
    ["RIGHT"] = 1,
    ["UP"] = -1,
    ["DOWN"] = 1,
};

local _unforcedTutorialLayer = nil;

function UnforcedTutorialLayer:ctor()
    --[[
        {id = {widget = , colorNode = },
        {id = {widget = , colorNode = },
        {id = {widget = , colorNode = },
        {id = {widget = , colorNode = },
         }
    ]]
    self._bubbles = {};

    self._unforcedtutorialManager = UnforcedTutorialManager.getInstance();
    self._tutoriallistener = nil;
    self._tutorialId = 1;

    self:initClick();
    self:initUI();
end

function UnforcedTutorialLayer:initUI()

end

function UnforcedTutorialLayer:createColorNode()
    local graylayer = cc.LayerColor:create(
        cc.c4b(0, 255, 0, 200), 10, 10):pos(0, 0);
    graylayer:setTouchEnabled(false);
    return graylayer;
end

function UnforcedTutorialLayer:createBubble()
    local bubbleWidget = WindowsTools:createWindow("BubbleWidget");
    bubbleWidget:setVisible(false);
    return bubbleWidget;
end

function UnforcedTutorialLayer:initClick()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    if self._tutoriallistener == nil then 
        self._tutoriallistener = cc.EventListenerTouchOneByOne:create();
    end 	

    self._tutoriallistener:setSwallowTouches(false);

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnded(touch, event)  
        local uiPos = touch:getLocationInView();
        local isIn, groupId = self:isInClickArea(uiPos.x, uiPos.y); 
        if isIn == true then
            self._unforcedtutorialManager:finishCurTutorialId(groupId);

            if groupId ~= nil then 
                echo("---groupId----", groupId);
                self._bubbles[groupId].widget:removeFromParent();
                self._bubbles[groupId].colorNode:removeFromParent();
                self._bubbles[groupId] = nil;
            end 
        end 
    
    end

    self._tutoriallistener:registerScriptHandler(onTouchEnded,
        cc.Handler.EVENT_TOUCH_ENDED);
    self._tutoriallistener:registerScriptHandler(onTouchBegan, 
        cc.Handler.EVENT_TOUCH_BEGAN);

    eventDispatcher:addEventListenerWithSceneGraphPriority(
        self._tutoriallistener, self);
end

function UnforcedTutorialLayer:isInClickArea(x, y)
    local clickPosGL = self:convertToGL(
        {x = x, y = y});  

    local allShowGroups = self._unforcedtutorialManager:getAllShowTriggerGroups();

    for k, groupId in pairs(allShowGroups) do
        if self._unforcedtutorialManager:isTutorOnBtn(groupId) == true then 
            local configClickRect = FuncGuide.getRect(groupId, 1);

            local width, height = configClickRect[1], configClickRect[2];

            local pos = self:getTargetPos(
                FuncGuide.getClickPos(groupId, 1), groupId, 1);

            local rect = cc.rect(pos.x - width / 2, 
                pos.y - height / 2, width, height);

            local isIn = cc.rectContainsPoint(rect, cc.p(clickPosGL.x, clickPosGL.y));
            if isIn == true then
                return true, groupId;
            end
        end 
    end
    return false;
end 

function UnforcedTutorialLayer:getTargetPos(configClickPos, groupId, tutorialId)
    -- dump(configClickPos, "---UnforcedTutorialLayer configClickPos--");

    local horizontalLayout, verticalLayout = 
        FuncGuide.getAdaptation(groupId, tutorialId);
    local pos = self:adjustToCurPos({x = configClickPos[1], y = configClickPos[2]}, 
        horizontalLayout, verticalLayout);

    return pos;
end

function UnforcedTutorialLayer:setUIByUnforcedTutoralId(gid, tid)
    self._tutorialId = tid;
    self._groupId = gid;

    self:setBubbleUI(gid);
end

function UnforcedTutorialLayer:setBubbleUI(gid)
    echo("gid", gid);

    local bubbleWidget = self:createBubble();
    bubbleWidget:setVisible(true);

    self:addChild(bubbleWidget, 10);
    -- bubbleWidget:setglobalzorder(10000);

    local bubblePos = self:getTargetPos(FuncGuide.getBubblePosition(gid, 1), gid, 1);
    bubbleWidget:setPosition(bubblePos.x, bubblePos.y);

    self._bubbles[gid] = {};
    self._bubbles[gid].widget = bubbleWidget;

    --点击区域大小
    local rectNode = self:createColorNode();
    self:addChild(rectNode, 1);
    local configClickRect = FuncGuide.getRect(gid, 1);

    local width, height = configClickRect[1], configClickRect[2];
    rectNode:setContentSize(cc.size(width, height));

    --点击位置
    local pos = self:getTargetPos(FuncGuide.getClickPos(gid, 1), gid, 1);
    rectNode:setPosition(pos.x - width / 2, pos.y - height / 2);  

    self._bubbles[gid].colorNode = rectNode;

    --气泡文字
    -- local str = FuncGuide.getBubbleStr(gid, 1);
    -- bubbleWidget.txt_1:setString(str);
    bubbleWidget.txt_1:setVisible(false);

    --气泡方向
    local dirction = FuncGuide.getBubbleDirection(gid, 1);
    bubbleWidget.mc_bubble:showFrame(tonumber(dirction));
end

function UnforcedTutorialLayer:getTouchOneByOneListener()
    return self._tutoriallistener;
end

function UnforcedTutorialLayer:convertToGL(pos)
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
function UnforcedTutorialLayer:getDifXandY()

    local diffWidth = GameVars.width - CONFIG_SCREEN_WIDTH;
    local difHeight = GameVars.height - CONFIG_SCREEN_HEIGHT;

    return diffWidth, difHeight;
end

--从960*640到当前机器的坐标
function UnforcedTutorialLayer:adjustToCurPos(pos, horizontalLayout, verticalLayout)
    -- echo("adjustToCurPos", horizontalLayout, horizontalLayout);

    local difX, difY = self:getDifXandY();

    if horizontalLayout == ENUM_LAYOUT_POLICY.LEFT and verticalLayout == ENUM_LAYOUT_POLICY.CENTER then
        --左中 done 
    	return {x = pos.x, y = pos.y + difY / 2};
    elseif horizontalLayout == ENUM_LAYOUT_POLICY.LEFT and verticalLayout == ENUM_LAYOUT_POLICY.UP then
        --左上 done
        return {x = pos.x, y = pos.y + difY};
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


function UnforcedTutorialLayer:getTouchOneByOneListener()
    return self._tutoriallistener;
end


--删除一些东西
function UnforcedTutorialLayer:deleteMe()
    
end



