--guan
--2016.4.18 换界面
--2016.6.1  又换界面

local SignView = class("SignView", UIBase);

--第几天必须送法宝
local TreasureDay = 2;

function SignView:ctor(winName)
    SignView.super.ctor(self, winName);
end

function SignView:loadUIComplete()
	self:registerEvent();
    self:uiAdjust();
    self:initUI();
end 

function SignView:registerEvent()
	SignView.super.registerEvent();
    self.panel_1.btn_1:setTap(c_func(self.press_btn_1, self));
    self.btn_close:setTap(c_func(self.press_btn_close, self));
end

function SignView:initUI()
    self:initList();
    self:downInfoUI();

    self:totalSignUI();
end

--分辨率适配
function SignView:uiAdjust()
    FuncCommUI.setViewAlign(self.btn_close, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop);   
    FuncCommUI.setViewAlign(self.panel_res, UIAlignTypes.RightTop);  
    --FuncCommUI.setViewAlign(self.scale9_ding,UIAlignTypes.MiddleTop) 
    FuncCommUI.setScale9Align( self.scale9_ding,UIAlignTypes.MiddleTop,1 )
end

--下面的签到信息 本月签到送啥
function SignView:downInfoUI()
    --本月送啥
    local year, month = SignModel:getYearAndMonth();
    local rewards = FuncSign.getMonthValue(year, month, TreasureDay, "reward")[1];
    local rewardTable = string.split(rewards, ",");

    if table.length(rewardTable) ~= 3 then 
        self.txt_4:setString("第" .. tostring(TreasureDay) .. "天表配错了");
    else
        local itemName = FuncTreasure.getName(rewardTable[2]);
        self.txt_4:setString(itemName);
        self.txt_4:setTouchedFunc(function ( ... )
            --WindowControler:showWindow("LotteryTreasureDetail", rewardTable[2]);
            -- echo("奖励表")
            -- dump(rewardTable[2])
            -- echo("奖励表")
            --TreasuresModel:getTreasureById(id)
            --todo test
            WindowControler:showWindow("TreasureInfoView", rewardTable[2]);
        end);
    end 

    --累计几次了
    local num = SignModel:monthSignCount();
    self.txt_6:setString(num);

    --签到btn
    if SignModel:todaySignCount() == 0 then 
        self.mc_qiandao:showFrame(1);
        self.mc_qiandao:setTouchedFunc(c_func(self.signClick, self));
        self.mc_qiandao:setTouchEnabled(true);
        --加特效
        local ctn = self.mc_qiandao.currentView.btn_1.spUp.ctn_ani;
        local ani = self:createUIArmature("UI_common", "UI_common_zhonganniu", ctn, true);
        ani:setScale(1.05)
        --FuncArmature.setArmaturePlaySpeed( ani , 0.6)
        FuncArmature.setArmaturePlaySpeed( ani , 1)

    elseif SignModel:todaySignCount() == 1 and SignModel:curNeedVip() ~= 0 then 
        self.mc_qiandao:showFrame(2);
        self.mc_qiandao:setTouchedFunc(c_func(self.signClick, self));
        self.mc_qiandao:setTouchEnabled(true);

        if SignModel:curNeedVip() <= UserModel:vip() then 
            local ctn = self.mc_qiandao.currentView.btn_1.spUp.ctn_ani;
            local ani = self:createUIArmature("UI_common", "UI_common_zhonganniu", ctn, true);
            ani:setScale(1.05)
            --FuncArmature.setArmaturePlaySpeed( ani , 0.6)
            FuncArmature.setArmaturePlaySpeed( ani , 1)
        end 
    else 
        self.mc_qiandao:showFrame(3);
        self.mc_qiandao:setTouchEnabled(false);
    end     

    self:redPointCheck();

end

function SignView:signClick()
    if SignModel:todaySignCount() == 0 then 
        --echo("签到");
        SignServer:mark(c_func(self.markCallBack, self));
    elseif SignModel:todaySignCount() == 1 then
        if SignModel:curNeedVip() <= UserModel:vip() then 
            --echo("再签到");
            self._isSingAgain = true;
            SignServer:mark(c_func(self.markCallBack, self));
        else 
            WindowControler:showTips({text="vip等级不足"});
        end
    end
end

function SignView:markCallBack(event)
    --echo("markCallBack");
    if event.error == nil then 
        local num = SignModel:todaySignIndex();
        --echo("markCallback ok " .. tostring(num));
        --更新 cell 
        local cellData = self._listData[num];

        local cell = self.scroll_list:getViewByData(cellData);
        self:updateItem(cell, cellData);

        cell:getUpPanel().ctn_ani:removeAllChildren();
        cell:getUpPanel().ctn_ani2:removeAllChildren();

        self:downInfoUI();

        self:totalSignUI();

        local reward = SignModel:todayReward().reward;

        --弹奖励
        if SignModel:todaySignCount() == 1 then
            FuncCommUI.startRewardView(reward);
        elseif SignModel:todaySignCount() == 2 and self._isSingAgain ~= true then 
            --两倍
            FuncCommUI.startRewardView(reward);
            FuncCommUI.startRewardView(reward);
        else 
            FuncCommUI.startRewardView(reward);
        end 

        self:redPointCheck();

    end 
end

function SignView:updateItem(view, itemData)

    -- view:setRect(cc.rect(0,-90,90,90 ))

    function getRewardInfo(itemData)
        local rewardTable = string.split(itemData.reward[1], ",");
        
        local id = nil;
        local num = nil;
        local itemType = nil;

        if table.length(rewardTable) == 2 then
            id = rewardTable[1];
            num = rewardTable[2];
            itemType = id;
        else 
            id = rewardTable[2];
            num = rewardTable[3];
            itemType = rewardTable[1];        
        end 

        return id, num, itemType;
    end

    function setInnerBtnTouchDisable(outMc)
        outMc:showFrame(1);
        local btn = outMc:getCurFrameView().btn_1;
        btn:enabled(false);

        outMc:showFrame(2);
        local btn = outMc:getCurFrameView().btn_1;
        btn:enabled(false);
    end
    
    function showBlackBg(innerPanel, rewardType, rewardId)
        local isPiece = isPiece(rewardId, rewardType);

        if isPiece == true then 
            innerPanel.mc_2:showFrame(2);
        else 
            innerPanel.mc_2:showFrame(1);
        end 
        innerPanel.mc_2:setVisible(true);
    end
    --判断是否是碎片
    function isPiece(id, rewardType)
        if FuncDataResource.RES_TYPE.ITEM == rewardType and 
            FuncItem.getItemType(id) == ItemsModel.itemType.ITEM_TYPE_PIECE then 
            return true;
        else 
            return false;
        end 
    end

    local innerPanel = view:getUpPanel().panel_1;
    setInnerBtnTouchDisable(innerPanel.UI_1.mc_1);

    local itemAniCtn1 = view:getUpPanel().ctn_ani;
    local itemAniCtn2 = view:getUpPanel().ctn_ani2;

    local rewardId, rewardNum, rewardType = getRewardInfo(itemData);

    local totalSignCount = SignModel:todaySignIndex();
    local index = itemData.index;
    
    if totalSignCount > index then 
        --已经签过了
        innerPanel.mc_1:showFrame(1);
        showBlackBg(innerPanel, rewardType, rewardId);
    elseif totalSignCount == index then
        --今天签到
        if SignModel:todaySignCount() == 1 then
            --只签到1次
            if SignModel:curNeedVip() == 0 then 
                --不需要vip
                showBlackBg(innerPanel, rewardType, rewardId);
                innerPanel.mc_1:showFrame(1);
                innerPanel.mc_1:setVisible(true);
            else 
                --继续签到
                innerPanel.mc_1:showFrame(2);
                innerPanel.mc_1:setVisible(true);
                showBlackBg(innerPanel, rewardType, rewardId);

                if SignModel:curNeedVip() <= UserModel:vip() then 
                    if isPiece(rewardId, rewardType) == false then 
                        self:createUIArmature("UI_sign",
                            "UI_sign_zhuanguang", itemAniCtn1, true);
                    else 
                        self:createUIArmature("UI_sign",
                            "UI_sign_zhuanguang", itemAniCtn2, true);
                    end 
                end 
            end
        elseif SignModel:todaySignCount() == 2 then
            --已经签过了
            innerPanel.mc_1:showFrame(1);
            innerPanel.mc_1:setVisible(true);
            showBlackBg(innerPanel, rewardType, rewardId);        
        else 
            --没有签到呢
            innerPanel.mc_1:setVisible(false);
            innerPanel.mc_2:setVisible(false);   
            if isPiece(rewardId, rewardType) == false then 
                self:createUIArmature("UI_sign",
                    "UI_sign_zhuanguang", itemAniCtn1, true);
            else 
                self:createUIArmature("UI_sign",
                    "UI_sign_zhuanguang", itemAniCtn2, true);
            end    
        end
    else 
        innerPanel.mc_2:setVisible(false);
        innerPanel.mc_1:setVisible(false);
    end 

    --双倍
    if itemData.vip == nil or itemData.vip == 0 then 
        --不显示双倍
        innerPanel.mc_3:setVisible(false);
    else 
        --判断是不是碎片
        if self:isFragment() == true then 
            innerPanel.mc_3:showFrame(2);
        else 
            innerPanel.mc_3:showFrame(1);
        end 
        innerPanel.mc_3:getCurFrameView().panel_1.mc_1:showFrame(itemData.vip);
    end 

    innerPanel.UI_1:setResItemData({reward = itemData.reward[1]});

     innerPanel.UI_1:setTouchedFunc(function (...)  end);
     innerPanel.UI_1:setTouchSwallowEnabled(true);

    local rect = {width = 10, height = 10, x = 0, y = -10};
    local desStr = GameConfig.getLanguageWithSwap("sign_target_count", index);
    --view:setTouchedFunc(c_func(self.showDetail, self, rewardType, 
    --    rewardId, rewardNum, itemData.reward[1], desStr));
    -- innerPanel.UI_1:setTouchedFunc(c_func(self.showDetail, self, rewardType, 
    --     rewardId, rewardNum, itemData.reward[1], desStr));
    -- innerPanel.UI_1:setTouchSwallowEnabled(true);
    
    view:setTap(c_func(self.showDetail, self, rewardType, 
        rewardId, rewardNum, itemData.reward[1], desStr))
    view:resetRect()

end

function SignView:isFragment(itemType, itemId)
    if itemType == FuncDataResource.RES_TYPE.ITEM then 
        local subType = FuncItem.getItemType(itemId);
        if subType == ItemsModel.itemType.ITEM_TYPE_PIECE then 
            return true;
        else 
            return false;
        end 
    else 
        return false;
    end 
end

function SignView:showDetail(rewardType, rewardId, rewardNum, reward, desStr)
    --echo(desStr, "----");
    if self.scroll_list:isMoving() == false then 
        --echo("showDetail");
        local params = {
            itemResType = rewardType,
            itemId = rewardId,
            viewType = FuncItem.ITEM_VIEW_TYPE.SIGN,
            itemNum = rewardNum,
            desStr = desStr,
        };
        WindowControler:showWindow("CompGoodItemView", params);
    end 
end

function SignView:initList()
    self.btn_Cell:setVisible(false);

    --[[
        {
            {reward = {}, vip = },
            {reward = {}, vip = },
            {reward = {}, vip = },
        }
    ]]
    local listData = SignModel:getSignItems();
    self._listData = listData;

    local createCellFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.btn_Cell);
        self:updateItem(view, itemData)
        return view;
    end

    self._scrollParams = {
        {
            data = listData,
            createFunc = createCellFunc,
            perNums = 5,
            offsetX = 28,
            offsetY = 11,
            widthGap = 22,
            heightGap = 10,
            itemRect = {x = 0, y = -103.5, width = 107.6, height = 103.5},
            perFrame = 5,
        }
    }

    self.scroll_list:styleFill(self._scrollParams);
    --self.scroll_list:enableMarginBluring();       --这里会和动画冲突  暂时不使用
    local totalSignCount = SignModel:todaySignIndex();
    self.scroll_list:gotoTargetPos(totalSignCount - 5, 1)
end

--左面累计签到界面
function SignView:totalSignUI()
    --真是的签到天数
    local totalSign = SignModel:totalSignCount();
    --目标签到天数
    local targetCount = SignModel:getRealTotalSignTargetDay();
    --echo("totalSign,",totalSign,"targetCount,",targetCount,"=======XXXXXXXXXXXXXXXXXXXXXXXXXXX")
    self.panel_1.txt_2:setString(
        tostring(totalSign) .. "/" .. tostring(targetCount));



    --奖励
    local rewards = SignModel:curTotalSignReward();
    self._totalReward = rewards;
    -- dump(rewards, "___totalUIsign__");
    for k, rewardStr in pairs(rewards) do
        --数量和id
        local id = nil;
        local num = nil;
        local itemType = nil;
        local reward = string.split(rewardStr, ",");
        if table.length(reward) == 2 then 
            id = reward[1];
            num = reward[2];
            itemType = id;
        else 
            id = reward[2];
            num = reward[3];
            itemType = reward[1];
        end 
        local view = self.panel_1["btn_leiji" .. tostring(k)];
        local innerPanel = view:getUpPanel().panel_1;
        local desStr = GameConfig.getLanguageWithSwap("sign_totalTarget_count", targetCount);

        local rect = {width = 10, height = 10, x = 0, y = -10};
        innerPanel.mc_2:setVisible(false);
        innerPanel.mc_3:setVisible(false);
        innerPanel.mc_1:setVisible(false);

        -- self:updateCompItemCell(innerPanel.UI_1, id, num, itemType);
        innerPanel.UI_1:setResItemData({reward = rewardStr});



        
        view:setTap(c_func(self.showDetail, self, 
            itemType, id, num, rewardStr, desStr))
        view:resetRect()

    end

    if totalSign < targetCount then 
        self.panel_1.btn_1:setVisible(false);
    else 
        self.panel_1.btn_1:setVisible(true);
        --加特效
        local ctn = self.panel_1.btn_1.spUp.ctn_ani;
        --解决 累计多天不领取，领取完成后动画重复添加。在添加之前删除之前动画
        ctn:removeAllChildren()
        local ani = self:createUIArmature("UI_common","UI_common_xiaoanniu", ctn, true);
        ani:setScale(0.84,1.02)
        FuncArmature.setArmaturePlaySpeed( ani , 1)
    end 

end

--这个是累计签到领取btn
function SignView:press_btn_1()
    --echo("累计签到领取");
    local totalSign = SignModel:totalSignCount();
    local targetCount = SignModel:getRealTotalSignTargetDay();

    if totalSign < targetCount then 
        WindowControler:showTips({text = "累计次数没到"});
        return ;
    else 
        SignServer:totalMark(c_func(self.totalMarkCallBack, self), targetCount);
    end 
end

function SignView:totalMarkCallBack(event)
    --echo("totalMarkCallBack");
    if event.error == nil then 
        --显示reward
        FuncCommUI.startRewardView(self._totalReward);
        self:totalSignUI();

        self:redPointCheck();
    end   
end

function SignView:press_btn_close()
    self:startHide();
end

function SignView:redPointCheck()
    --右侧btn
    local isDayRedPointShow = SignModel:isDayRedPointShow();
    self.panel_DayRed:setVisible(isDayRedPointShow);

    --左侧btn
    local isTotalRedPointShow = SignModel:isTotalRedPointShow();
    self.panel_1.panel_TotalRed:setVisible(isTotalRedPointShow);
    SignModel:homeRedPointCheck()
    -- if SignModel:isHomeSignRedPointShow() == true then 
    --     echo("发送 显示红点-------")
    --     EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
    --         {redPointType = HomeModel.REDPOINT.ACTIVITY.SIGN, isShow = true}); 
    -- else 
    --     echo("发送不显示红点=-======")
    --      EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
    --         {redPointType = HomeModel.REDPOINT.ACTIVITY.SIGN, isShow = false});        
    -- end  
end

return SignView;






