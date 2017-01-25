--guan
--2016.03.26
--2016.06.05 换ui 特效

local QuestView = class("QuestView", UIBase);

local lastSelect = 1;
local scrollMoveTime = 0.3;

--forceSelectType 1 主线 2 每日
function QuestView:ctor(winName, forceSelectType)
    QuestView.super.ctor(self, winName);
    
    --点击才初始化，只初始化一次
    self._isMainQuestInit = false;
    self._isDailyQuestInit = false;

    self._lastGotoMainLineQuestId = nil;
    self._lastGotoDailyQuestId = nil;

    --动画只播一次
    self._mainLineNeedAnim = true;
    self._dailyLineNeedAnim = true;

    self._forceSelectType = forceSelectType;
end

function QuestView:loadUIComplete()
    self._cellRect = self.btn_1:getContainerBox();

    self._mainLineList = self.panel_mainline.scroll_1;
    self._mainLineListBar = self.panel_mainline.panel_xubian; 

    self._dailyList = self.panel_dailyQuest.scroll_1;
    self._dailyListBar = self.panel_dailyQuest.panel_xubian; 

    self:registerEvent();

    self:viewAdjust();

    self:initUI();
end

function QuestView:registerEvent()
    QuestView.super.registerEvent();
    self.btn_back:setTap(c_func(self.press_btn_back, self));

    self.panel_yeqian.mc_1:setTouchedFunc(c_func(self.clickMainQuestBtn, self));
    self.panel_yeqian.mc_2:setTouchedFunc(c_func(self.clickDailyQuestBtn, self));

    --每日任务有变化
    EventControler:addEventListener(QuestEvent.DAILY_QUEST_CHANGE_EVENT,
        self.dailyQuestChangeCallBack, self);

    --主线任务有变化
    EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
        self.mainQuestChangeCallBack, self);

    --接受sp任务发生变化的事件
    EventControler:addEventListener(QuestEvent.QUEST_CHECK_SP_EVENT,
        self.spCheckCallBack, self, 1);
end

--适配
function QuestView:viewAdjust()
    FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop);
    
    FuncCommUI.setViewAlign(self.panel_1, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.panel_yeqian, UIAlignTypes.LeftTop, 0.7);
    FuncCommUI.setViewAlign(self.panel_zhui, UIAlignTypes.LeftTop,0.7);

    FuncCommUI.setScale9Align(self.scale9_resdi, UIAlignTypes.MiddleTop, 1, nil);
end

function QuestView:initLastSelect()
    if self._forceSelectType ~= nil then 
        lastSelect = self._forceSelectType;
        return
    end 

    local isMainQuestHaveFinish = MainLineQuestModel:isHaveFinishQuest();
    local isDailyQuestHaveFinish = DailyQuestModel:isHaveFinishQuest();

    if isMainQuestHaveFinish == true then 
        lastSelect = 1; 
    elseif isDailyQuestHaveFinish == true then 
        lastSelect = 2;
    else
    
    end 
end

function QuestView:initUI()
    self.panel_2:setVisible(false);
    --隐藏cell
    self.btn_1:setVisible(false); 

    self:initLastSelect();

    if DailyQuestModel:isOpen() == false then 
        self.panel_yeqian.mc_2:setVisible(false);
    end 

    self:setSelectViewByQuestTpye(lastSelect);

    if lastSelect == 1 then 
        self:clickMainQuestBtn();
    else 
        self:clickDailyQuestBtn();
    end 
end

--初始化主线任务
function QuestView:initMainQuest()
    if self._isDailyQuestInit == true then 
        --更新所有cell
        return;
    end 

    self:showQuestType(1);
    self:initMainLineList();
    self:rewPointCheck();

    self._isDailyQuestInit = true;
end

--初始化每日任务
function QuestView:initDailyQuest()
    if self._isMainQuestInit == true then 
        --更新cell
        return;
    end 

    self:showQuestType(2);

    self._isMainQuestInit = true;
    self:initDailyList(true);
    self:rewPointCheck();
end

--[[
    初始化主线任务的list
]]
function QuestView:initMainLineList()

    local allMainLineQuestIds = MainLineQuestModel:getAllShowMainQuestId();

    -- dump(allMainLineQuestIds, "----QuestView:initMainLineList-----");

    local createRankItemFunc = function(itemData)
        local baseCell = UIBaseDef:cloneOneView(self.btn_1);
        self:updateMainLineListCell(baseCell, itemData)
        return baseCell;
    end

    self._mainLineScrollParams = {
        {
            data = allMainLineQuestIds,
            createFunc = createRankItemFunc,
            perNums = 1,
            offsetX = 12,
            offsetY = 30,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -134, width = 756, height = 134},
            perFrame = 1,
        }
    }    
    
    self._mainLineList:setItemAppearType(1, true);
    self._mainLineList:styleFill(self._mainLineScrollParams);
    -- self._mainLineList:clearCacheView(); --???? 可以干掉吗

    self._mainLineList.isMainLine = true;
    self._mainLineList:enableMarginBluring();
end

function QuestView:updateMainLineListCell(baseCell, questId)
    --是否完成
    local isFinish = MainLineQuestModel:isMainLineQuestFinish(questId); 
    self:initCellWithoutRightBtn(baseCell, questId, true, isFinish);
    baseCell = baseCell:getUpPanel().panel_cell; 

    if MainLineQuestModel:isRecommendQuest(questId) == true then 
        baseCell.mc_3:showFrame(2);
        baseCell.panel_tuijian:setVisible(true);
    else
        baseCell.mc_3:showFrame(1);
        baseCell.panel_tuijian:setVisible(false);

        if baseCell.isAlreadyOffset ~= true then 
            local posY = baseCell:getPositionY();
            baseCell:setPositionY(posY - 15);

            baseCell.isAlreadyOffset = true
        end 
    end  

    if isFinish == true then 
        baseCell.mc_2:showFrame(1);
        local finishBtn = baseCell.mc_2:getCurFrameView().panel_3.btn_finish;
        finishBtn:setTouchSwallowEnabled(true);

        local btnAniCtn = baseCell.mc_2:getCurFrameView().panel_3.btn_finish.spUp.ctn_ani;
        btnAniCtn:removeAllChildren();
        self:createUIArmature("UI_common",
            "UI_common_saoguang", btnAniCtn, true);

        baseCell.ctn_finish:removeAllChildren();
        -- --加个特效
        -- local finishAni = self:createUIArmature("UI_task",
        --     "UI_task_9", baseCell.ctn_finish, true); 

        -- finishAni:setScaleX(1 + 0.01);
        -- finishAni:setScaleY(1 - 0.03);

        local childcount = table.length( baseCell.ctn_finish:getChildren() ); 
        baseCell.txt_4:setVisible(false); 

        finishBtn:setTap(c_func(self.finishMainLineBtnClick, self, questId, 
            baseCell.mc_2)); 
        finishBtn:setTouchSwallowEnabled(true); 

    else 

        baseCell.mc_2:setVisible(true);
        baseCell.mc_2:showFrame(2);
        
        local countLabel = baseCell.txt_4;
        local goBtn = baseCell.mc_2:getCurFrameView().btn_1;

        local needCount = MainLineQuestModel:needCount(questId);
        local completeCount = MainLineQuestModel:finishCount(questId);

        local showStr = GameConfig.getLanguageWithSwap(
            "quest_complete_count", completeCount, needCount);

        if MainLineQuestModel:isShowNumInfo(questId) == false then 
            countLabel:setVisible(false);
        else 
            countLabel:setVisible(true);
            countLabel:setString(showStr);
        end 

        --注册btn
        goBtn:setTap(c_func(self.goToMainlineView, self, questId));
        goBtn:setTouchSwallowEnabled(true);
    end 

    return baseCell;
end

function QuestView:initDailyList()

    local allDailyQuestIds = DailyQuestModel:getAllShowDailyQuestId();

    local createRankItemFunc = function(itemData)
        local baseCell = UIBaseDef:cloneOneView(self.btn_1);
        self:updateDailyListCell(baseCell, itemData, true)
        return baseCell;
    end

    self._dailyScrollParams = {
        {
            data = allDailyQuestIds,
            createFunc = createRankItemFunc,
            perNums = 1,
            offsetX = 12,
            offsetY = 10,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -134, width = 756, height = 134},
            perFrame = 1,
        }
    }

    self._dailyList:setItemAppearType(1, true);
    self._dailyList:styleFill(self._dailyScrollParams);
    self._dailyList:enableMarginBluring();
end

--[[
    初始化信息，除了最左边的信息
]]
function QuestView:initCellWithoutRightBtn(baseCell, questId, isMainLine, isFinish)
    if baseCell == nil then
        return;
    end 

    if isMainLine == true then 
        if isFinish == true then 
            baseCell:setTap(c_func(self.finishMainLineBtnClick, self, questId, 
                baseCell:getUpPanel().panel_cell.mc_2));
        else
            baseCell:setTap(c_func(self.goToMainlineView, self, questId));
        end 
    else 
        if isFinish == true then 
            baseCell:setTap(c_func(self.finishDailyBtnClick, self, questId, 
                baseCell:getUpPanel().panel_cell.mc_2));
        else 
            baseCell:setTap(c_func(self.goToDailyView, self, questId));
        end 
    end 

    baseCell = baseCell:getUpPanel().panel_cell;

    local typeIndex = isMainLine == true and 1 or 2;
    --初始化基本信息
    --任务名字
    local questNameId = FuncQuest.getQuestName(typeIndex, questId);
    baseCell.txt_1:setString(GameConfig.getLanguage(questNameId));
    --描述
    local desId = FuncQuest.getQuestDes(typeIndex, questId);
    baseCell.txt_2:setString(GameConfig.getLanguage(desId));  

    --奖励
    local rewards = FuncQuest.getQuestReward(typeIndex, questId);

    --最多2个奖励
    for i = 1, 2 do
        local mcReward = baseCell["mc_reward" .. tostring(i)];
        if rewards[i] == nil then 
            mcReward:setVisible(false);
        else 
            self:initRewardMc(mcReward, rewards[i]);
        end 
    end

    function isExpReward(reward)

        local itemType = nil;
        local itemId = nil;
        local itemNum = nil;

        local reward = string.split(reward, ",");

        --是货币
        if tostring( reward[1] ) == FuncDataResource.RES_TYPE.EXP then 
            return true;
        else 
            return false;
        end 

    end

    --是不是经验
    if  isExpReward(rewards[1]) then 
        -- baseCell.UI_1:setVisible(false);
        baseCell.mc_ui:showFrame(2);
    else 
        baseCell.mc_ui:showFrame(1);

        local iconUI = baseCell.mc_ui.currentView.UI_1;

        iconUI:setResItemData({reward = rewards[1]});
        iconUI:showResItemNum(false);
    end 

end

--[[
    传入任务id
]]
function QuestView:updateDailyListCell(baseCell, questId)
    if baseCell == nil then 
        return ;
    end 
    --是否完成
    local isFinish = DailyQuestModel:isDailyQuestFinish(questId); 
    self:initCellWithoutRightBtn(baseCell, questId, false, isFinish);

    baseCell = baseCell:getUpPanel().panel_cell;
    baseCell.panel_tuijian:setVisible(false);

    if isFinish == true then 
        baseCell.mc_2:showFrame(1);
        local finishBtn = baseCell.mc_2:getCurFrameView().panel_3.btn_finish;
        finishBtn:setTouchSwallowEnabled(true);

        local btnAniCtn = baseCell.mc_2:getCurFrameView().panel_3.btn_finish.spUp.ctn_ani;
        btnAniCtn:removeAllChildren();
        self:createUIArmature("UI_common",
            "UI_common_saoguang", btnAniCtn, true);  

        baseCell.ctn_finish:removeAllChildren();
        
        -- --加个特效
        -- local finishAni = self:createUIArmature("UI_task",
        --     "UI_task_9", baseCell.ctn_finish, true);  
        -- finishAni:setScaleX(1 + 0.01);
        -- finishAni:setScaleY(1 - 0.03);
        
        baseCell.txt_4:setVisible(false); 

        finishBtn:setTap(c_func(self.finishDailyBtnClick, self, questId, 
            baseCell.mc_2));   
    else 

        if DailyQuestModel:isSpQuest(questId) == true then
            --应该显示时间未到 todo
            baseCell.mc_2:setVisible(false);
            baseCell.txt_4:setVisible(false);
        else 
            baseCell.txt_4:setVisible(true);
            baseCell.mc_2:setVisible(true);
            baseCell.mc_2:showFrame(2);
            local countLabel = baseCell.txt_4;
            local goBtn = baseCell.mc_2:getCurFrameView().btn_1;

            local needCount = DailyQuestModel:needCount(questId);
            local completeCount = DailyQuestModel:finishCount(questId);

            local showStr = GameConfig.getLanguageWithSwap(
                "quest_complete_count", completeCount, needCount);

            countLabel:setString(showStr);

            --注册btn
            goBtn:setTap(c_func(self.goToDailyView, self, questId));
            goBtn:setTouchSwallowEnabled(true);
        end  
    end 

    return baseCell;
end

function QuestView:finishMainLineBtnClick(questId, cell)
    echo("finishMainLineBtnClick " .. tostring(questId));

    if MainLineQuestModel:isMainLineQuestFinish(questId) == true then
        cell:getCurFrameView().panel_3.btn_finish:setVisible(false);
        UserModel:cacheUserData()
        self._lastFinishQuest = questId;
        self:disabledUIClick();
        self._lastFinishCtn = cell:getCurFrameView().ctn_stamp;

        QuestServer:getMainQuestReward(questId, c_func(self.finishMainLineCallBack, self))
    else 
        WindowControler:showTips( { text = "未完成" });
    end 
end

function QuestView:finishDailyBtnClick(questId, cell)
    echo("finishDailyBtnClick " .. tostring(questId));
    if DailyQuestModel:isDailyQuestFinish(questId) == true then 
        UserModel:cacheUserData()

        cell:getCurFrameView().panel_3.btn_finish:setVisible(false);

        self._lastFinishQuest = questId;
        self:disabledUIClick();

        self._notActionToEvent = true;
        self._lastFinishCtn = cell:getCurFrameView().ctn_stamp;

        QuestServer:getEveryQuestReward(questId, c_func(self.finishDailyCallBack, self))

        self._preX = self._dailyList.position_.x;
        self._preY = self._dailyList.position_.y;
    else 
        WindowControler:showTips( { text = "未完成" });
    end 
end

--[[
    主线任务完成回调
]]
function QuestView:finishMainLineCallBack(event)
    function callBack()
        echo("finishMainLineCallBack " .. tostring(self._lastFinishQuest)); 
        
        local rewards = FuncQuest.getQuestReward(1, self._lastFinishQuest);
        FuncCommUI.startFullScreenRewardView(rewards, c_func(self.lvlUpCheck, self));

        --任务列表
        self:mainLineScrollUpdate();


        self:resumeUIClick();
        self:rewPointCheck();

        if MainLineQuestModel:isHaveFinishQuest() == true or 
            DailyQuestModel:isHaveFinishQuest() == true then 
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = true});
        else 
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = false});
        end 
    end

    if event.error == nil then
        local ani = self:createUIArmature("UI_task",
            "UI_task_yilingqu", self._lastFinishCtn, true); 

        ani:registerFrameEventCallFunc(12, 1, function ( ... )
            ani:gotoAndPause(6);
            callBack();
        end );
    end     
end

function QuestView:mainLineScrollUpdate()
    echo("-----mainLineScrollUpdate-----");

    local allMainLineQuestIds = MainLineQuestModel:getAllShowMainQuestId();
    self._mainLineScrollParams[1].data = allMainLineQuestIds;

    self._mainLineList:styleFill(self._mainLineScrollParams);

    for k, v in pairs(allMainLineQuestIds) do
        local cellView = self._mainLineList:getViewByData(v);
        if cellView ~= nil then 
            self:updateMainLineListCell(cellView, v);
        end 
    end
end

function QuestView:finishDailyCallBack(event)
    function callBack()
        self._notActionToEvent = false;

        echo("finishDailyCallBack " .. tostring(self._lastFinishQuest)); 

        local rewards = FuncQuest.getQuestReward(2, self._lastFinishQuest);
        FuncCommUI.startFullScreenRewardView(rewards, c_func(self.lvlUpCheck, self));

        self:dailyScrollUpdate();
        self:resumeUIClick();

        if MainLineQuestModel:isHaveFinishQuest() == true or 
            DailyQuestModel:isHaveFinishQuest() == true then 
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = true});
        else 
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = false});
        end 
    end

    if event.error == nil then
        echo("self._lastFinishCtn", self._lastFinishCtn);
        local ani = self:createUIArmature("UI_task",
            "UI_task_yilingqu", self._lastFinishCtn, true); 

        ani:registerFrameEventCallFunc(12, 1, function ( ... )
            ani:gotoAndPause(6);
            callBack();
        end );
    end 
end

function QuestView:dailyScrollUpdate()
    echo("-----dailyScrollUpdate-----");

    local allDailyQuestIds = DailyQuestModel:getAllShowDailyQuestId();
    self._dailyScrollParams[1].data = allDailyQuestIds;

    self._dailyList:styleFill(self._dailyScrollParams);

    
    for k, v in pairs(allDailyQuestIds) do
        local cellView = self._dailyList:getViewByData(v);
        if cellView ~= nil then 
            self:updateDailyListCell(cellView, v);
        end 
    end
end

function QuestView:goToMainlineView(questId)
    echo("goToView " .. tostring(questId));
    local questType = FuncQuest.readMainlineQuest(questId, "conditionType");

    local jumpInfo = MainLineQuestModel.JUMP_VIEW[tostring(questType)];

    if jumpInfo ~= nil then 
        echo("jumpView.viewName " .. tostring(jumpInfo.viewName));
        if jumpInfo.viewName ~= nil then 
            WindowControler:showWindow(jumpInfo.viewName);
        elseif jumpInfo.funName ~= nil  then 
            jumpInfo.funName();
        else 
            -- self:startHide();
        end 
    else 
        WindowControler:showTips("功能未开启");
    end 

    self._lastGotoMainLineQuestId = questId;
end

function QuestView:goToDailyView(questId)
    -- echo("goToView " .. tostring(questId));
    local questType = FuncQuest.readEverydayQuest(questId, "conditionType");
    -- echo("questType " .. tostring(questType));

    local jumpInfo = DailyQuestModel.JUMP_VIEW[tostring(questType)];
    if jumpInfo ~= nil then 
        echo("jumpView.viewName " .. tostring(jumpInfo.viewName));
        if jumpInfo.jumpFunc ~= nil then 
            jumpInfo.jumpFunc();
        else 
            WindowControler:showWindow(jumpInfo.viewName);
        end 
    else 
        WindowControler:showTips("功能未开启");
    end 

    self._lastGotoDailyQuestId = questId;
end

--[[
    初始化奖励弹框
]]
function QuestView:initRewardMc(mcReward, reward)
    local itemType = nil;
    local itemId = nil;
    local itemNum = nil;

    local reward = string.split(reward, ",")

    local isCurrency = false;
    --是货币
    if table.length(reward) == 2 then 
        itemType = reward[1];
        itemId = reward[1];
        itemNum = reward[2];
    else 
        itemType = reward[1];
        itemId = reward[2];
        itemNum = reward[3];
    end 

    if FuncDataResource.RES_TYPE.ITEM ~= itemType then 
        isCurrency = true;
    else 
        isCurrency = false;
    end 

    mcReward:showFrame(1);

    local iconPath = FuncRes.iconRes(itemType, itemId);

    -- echo("-----iconPath----" .. tostring(iconPath));

    local sp = display.newSprite(iconPath);
    local ctn = mcReward.currentView.ctn_1;

    if self._ctnPosX == nil then 
        self._ctnPosX = ctn:getPositionX();
    end 

    if self._txtPosX == nil then 
        self._txtPosX = mcReward.currentView.txt_1:getPositionX();
    end 

    ctn:removeAllChildren();
    ctn:addChild(sp);
    if FuncDataResource.RES_TYPE.EXP ~= itemType then 
        sp:size(ctn.ctnWidth, ctn.ctnHeight);
    else 
        mcReward.currentView.txt_1:setPositionX(self._txtPosX + 50);
        ctn:setPositionX(self._ctnPosX + 20);
    end 
    --数量
    mcReward.currentView.txt_1:setString("x " .. tostring(itemNum));

end

function QuestView:clickMainQuestBtn()
    echo(" clickMainQuestBtn ");

    lastSelect = 1;
    self:setSelectViewByQuestTpye(lastSelect);

    self:showQuestType(lastSelect);
    self:initMainQuest();

    self:rewPointCheck();
    self.panel_yeqian.panel_red1:setVisible(false);

end

function QuestView:clickDailyQuestBtn()
    echo(" clickDailyQuestBtn  ");
    local isOpen, needLvl = DailyQuestModel:isOpen()

    if isOpen == false then 
        openLvlStr = GameConfig.getLanguageWithSwap("quest_open_lvl", needLvl);
        WindowControler:showTips(openLvlStr);
        return;
    end 

    lastSelect = 2;
    self:setSelectViewByQuestTpye(lastSelect);
    self:showQuestType(lastSelect);  

    self:initDailyQuest();
    self:rewPointCheck();
    self.panel_yeqian.panel_red2:setVisible(false);

end

--选择select样子
function QuestView:setSelectViewByQuestTpye(questType)
    --显示主线任务
    if questType == 1 then 
        self.panel_yeqian.mc_1:showFrame(2);
        self.panel_yeqian.mc_2:showFrame(1);
        self:showQuestType(1);
    else 
        self.panel_yeqian.mc_1:showFrame(1);
        self.panel_yeqian.mc_2:showFrame(2);
        self:showQuestType(2);
    end 
end

function QuestView:showQuestType(questType)
    if questType == 1 then 
        self.panel_mainline:setVisible(true);
        self.panel_dailyQuest:setVisible(false);
    else 
        self.panel_mainline:setVisible(false);
        self.panel_dailyQuest:setVisible(true);
    end 
end

function QuestView:press_btn_back()
    self:startHide();
end

function QuestView:dailyQuestChangeCallBack()
    echo("----dailyQuestChangeCallBack----");
    if self._notActionToEvent ~= true and self._lastGotoDailyQuestId ~= nil then 

        self:dailyScrollUpdate();
        self:setSelectViewByQuestTpye(lastSelect);

        if DailyQuestModel:isDailyQuestFinish(self._lastGotoDailyQuestId) == true then 
            --滚到最上
            self._dailyList:gotoTargetPos(1, 1);
        end 
    end 

    self:rewPointCheck();
end

function QuestView:mainQuestChangeCallBack()
    echo("---------------QuestView:mainQuestChangeCallBack-----------------" 
        .. tostring(self._lastGotoMainLineQuestId));

    if self._lastGotoMainLineQuestId ~= nil then 
        self:mainLineScrollUpdate();

        self:setSelectViewByQuestTpye(lastSelect);

        if MainLineQuestModel:isMainLineQuestFinish(self._lastGotoMainLineQuestId) == true then 
            --滚到最上
            echo("gotoTargetPos mainQuestChangeCallBack");
            self._mainLineList:gotoTargetPos(1, 1);
        end
    end 

    self:rewPointCheck();
end

--这个是自己的界面红点check
function QuestView:rewPointCheck()
    if lastSelect == 1 then 
        if DailyQuestModel:isHaveFinishQuest() == true then 
            self.panel_yeqian.panel_red2:setVisible(true);
        else
            self.panel_yeqian.panel_red2:setVisible(false);
        end
    else 
        if MainLineQuestModel:isHaveFinishQuest() == true then 
            self.panel_yeqian.panel_red1:setVisible(true);
        else 
            self.panel_yeqian.panel_red1:setVisible(false);
        end
    end 
end

function QuestView:spCheckCallBack()
    echo("--QuestView:spCheckCallBack--");
    self:initDailyList();
    self:rewPointCheck(); 
end

function QuestView:lvlUpCheck()
    -- echo("lvlUpCheck");
    -- if UserModel:isLvlUp() == true then 
    --     EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE, 
    --         {level = UserModel:level()}); 
    -- end 
end

return QuestView;















