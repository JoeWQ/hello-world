--2016.3.2
--guan
--强化界面

local TreasureEnhanceView = class("TreasureEnhanceView", UIBase);

--特效持续时间
local effectShowLastTime = 1;

function TreasureEnhanceView:ctor(winName, treasure, isShowAction, detailView)
    TreasureEnhanceView.super.ctor(self, winName);
    self._treasure = treasure;
    self._treasureId = treasure:getId();
    self._beforePowerNum = 0;
    self._detailView = detailView;
    self._isShowAction = isShowAction;
end

function TreasureEnhanceView:loadUIComplete()
	self.panel_power.mc_num:visible(false);

    self:registerEvent();
    self:initUI();

    self:initLeftListUI();

    self:showEntryAnim();

    --分辨率适配
    FuncCommUI.setViewAlign(self.btn_close, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.ctn_leftList, UIAlignTypes.Left);

end 

function TreasureEnhanceView:registerEvent()
	TreasureEnhanceView.super.registerEvent();
    self.btn_close:setTap(c_func(self.press_btn_close, self));

    --切换界面
    EventControler:addEventListener(TreasureEvent.CHANGE_SELECT, 
        self.onChangeTreasure, self, 2, true);

    --金币增加
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, 
        self.coinChangeCallBack, self);

    --道具变化
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.itemChangeCallBack, self);
end

function TreasureEnhanceView:itemChangeCallBack()
    --刷新能否强化
    self:setDownInfo();
    --刷新能金币数
    self:setNeedRes();
end

function TreasureEnhanceView:coinChangeCallBack(event)
    local changeNum = event.params.coinChange;
    -- echo("----changeNum---", changeNum);
    if changeNum > 0 then 
        --刷新能否强化
        self:setDownInfo();
        --刷新能金币数
        self:setNeedRes();
    end 
end

function TreasureEnhanceView:onChangeTreasure(event)
    self._treasure = event.params.treasure;
    self._treasureId = self._treasure:getId();

    if self._treasure:getStrongType() == Treasure.StrongType.Strength then 
        self:initUI();
    else 
        --变到精炼界面
        self:startHide();
        WindowControler:showWindow("TreasureReFineView", self._treasure, 
            false, self._detailView);
    end 
end

--打开动画
function TreasureEnhanceView:showEntryAnim()
    if self._isShowAction ~= true then 
        return 
    end 

    --入场动画
    local openAni = self:createUIArmature("UI_qianghua","UI_qianghua_chutubiao", self.ctn_kaichang, 
        false, GameVars.emptyFunc);
    self.panel_cailiao2:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(openAni, "node2", self.panel_cailiao2);
    self.panel_cailiao1:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(openAni, "node1", self.panel_cailiao1);

    openAni:getBone("node4"):setVisible(false);
    openAni:getBone("node3"):setVisible(false);
    openAni:getBone("tuo3"):setVisible(false);
    openAni:getBone("tuo4"):setVisible(false);

    --底框
    local downAni = self:createUIArmature("UI_qianghua","UI_qianghua_lankuang", self.ctn_donwAni, 
        false, GameVars.emptyFunc);
    self.panel_downPanel:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(downAni, "lantiao", self.panel_downPanel);

    local qualityAni = self:createUIArmature("UI_qianghua","UI_qianghua_pingjie", self.ctn_qualityAni, 
        false, GameVars.emptyFunc);
    self.mc_2:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(qualityAni, "pinji", self.mc_2);

    --蓝粒子
    self:createUIArmature("UI_fabao_common","UI_fabao_common_ssyw", self.ctn_middle_ani, true);

    self:createUIArmature("UI_fabao_common","UI_fabao_common_beijing", 
            self.ctn_bg, true);
end

function TreasureEnhanceView:initUI()
    self:setPower();
    self:initTreasureLvl();
    self:initTreasureBaseInfo();
    self:setDownInfo();
    self:setNeedRes();

    FuncCommUI.regesitShowPowerTipView(
        self.panel_power, self._treasureId);
end

function TreasureEnhanceView:initLeftListUI()
    --把哪个公共list放过来
    if not g_TreasureLeftList then
     g_TreasureLeftList = WindowsTools:createWindow(
            "TreasureLeftListCompoment", self._treasure);
    end
    g_TreasureLeftList:parent(self.ctn_leftList);
    g_TreasureLeftList:setVisible(true);
end

function TreasureEnhanceView:setResVisible(isVisible)
    self.panel_cailiao2.ctn_1:setVisible(isVisible)
    self.panel_cailiao2.txt_1:setVisible(isVisible)

    self.panel_cailiao1.ctn_1:setVisible(isVisible)
    self.panel_cailiao1.txt_1:setVisible(isVisible)
end

function TreasureEnhanceView:setNeedRes()
    if self._treasure:isMaxLvl() == true then 
        self:setResVisible(false);
        return true;
    else 
        self:setResVisible(true);
    end 

    local lvl = self._treasure:level();
    
    local needResArray = FuncTreasure.getValueByKeyTULD(
        self._treasureId, lvl, "cost");

    for i = 1, 2 do
        local res = string.split( needResArray[i] , "," );
        --需要数量
        local needNum = res[table.length(res)];
        local _, haveNum = UserModel:getResInfo( needResArray[i] );

        if tostring( res[1] ) ~= FuncDataResource.RES_TYPE.COIN then 
            self["panel_cailiao" .. tostring(i)].txt_1:setString(
                tostring(haveNum) .. "/" .. tostring(needNum));
            self["panel_cailiao" .. tostring(i)].mc_1:setTouchedFunc(c_func(self.showGetWay, self, res[2]));
        else
            --金币是否足够
            if tonumber(needNum) > tonumber(haveNum) then
                self._isCoinEnough = false;
            else 
                self._isCoinEnough = true;
            end 

            self["panel_cailiao" .. tostring(i)].txt_1:setString(tostring(needNum) );
            self["panel_cailiao" .. tostring(i)].mc_1:setTouchedFunc(c_func(self.showGetWay, self, res[1]));
        end

        if tonumber(needNum) > tonumber(haveNum) then 
            self["panel_cailiao" .. tostring(i)].txt_1:setColor(cc.c3b(255, 0, 0));
            self._lackItemName = FuncDataResource.getResNameById(res[1], res[2]);
        else 
            self["panel_cailiao" .. tostring(i)].txt_1:setColor(cc.c3b(255, 190, 90));
        end 

        self["panel_cailiao" .. tostring(i)].txt_1:setVisible(true);

        --icon
        local iconPath = FuncRes.iconRes(res[1], res[2]);
        local sp = display.newSprite(iconPath); 

        if i == 1 then 
            self._leftResIconPath = iconPath;
        else
            self._rightResIconPath = iconPath;
        end 

        local ctn = self["panel_cailiao" .. tostring(i)].ctn_1;
        ctn:removeAllChildren();
        ctn:addChild(sp);
        sp:size(ctn.ctnWidth, ctn.ctnHeight);
        --边框
        local quality = FuncDataResource.getQualityById(res[1], res[2]);
        self["panel_cailiao" .. tostring(i)].mc_1:showFrame(quality);
    end

end

function TreasureEnhanceView:showGetWay(id)
    AudioModel:playSound("s_com_click1")
    if id == FuncDataResource.RES_TYPE.COIN then 
        local ui = WindowControler:showWindow("CompBuyCoinMainView");
        ui:buyCoin();
    else 
        echo("--need item id--", id);
        WindowControler:showWindow("GetWayListView", id);
    end 
end

function TreasureEnhanceView:getTargetLvl()
    function sum(singleNeedStr, totalstrs)
        local singleRes = string.split(singleNeedStr, ",");
        for _, v in pairs(totalstrs) do
            local inTotalRes = string.split(v, ",");
            if table.length(singleRes) == 2 then 
                if inTotalRes[1] == singleRes[1] then
                    local count = tonumber(inTotalRes[2]) + tonumber(singleRes[2]);
                    local str = inTotalRes[1] .. "," .. tostring(count);
                    totalstrs[_] = str;
                    return totalstrs;
                end 
            else 
                --道具消耗
                if inTotalRes[2] == singleRes[2] then 
                    local count = tonumber(inTotalRes[3]) + tonumber(singleRes[3]);
                    local str = inTotalRes[1] .. "," ..inTotalRes[2] .. "," .. tostring(count);
                    totalstrs[_] = str;
                    return totalstrs;
                end 
            end

        end
        table.insert(totalstrs, singleNeedStr)
        return totalstrs
    end

    local treasureLvl = self._treasure:level();

    -- echo("---treasureLvl--", treasureLvl);

    local lvlAdd = 0;
    local totalNeed = {};

    for lvl = treasureLvl % 10, 9 do
        local lvlsum = (treasureLvl - treasureLvl % 10) + lvl;
        -- echo("---lvl--", lvl);

        if treasureLvl < 10 then 
            lvlsum = lvl;
        end

        -- echo("lvlsum--", lvlsum);

        local needRes = FuncTreasure.getValueByKeyTULD(
            self._treasureId, lvlsum, "cost");
        
        for _, v in pairs(needRes) do
            sum(v, totalNeed);
        end

        if UserModel:isResEnough(totalNeed) ~= true then 
            break;
        else 
            lvlAdd = lvlAdd + 1;
        end 
    end

    if lvlAdd == 0 then 
        lvlAdd = 1;
    end 

    return lvlAdd + treasureLvl;
end

function TreasureEnhanceView:setDownInfo()
    if self._treasure:isMaxLvl() == true then 
        self:setDonwInfoVisible(false);
        return ;
    else 
        self:setDonwInfoVisible(true);
    end 

    local treasureLvl = self._treasure:level();
    local playerLvl = UserModel:level();
    local targetLvl = 0;
    local powerAdd = 0;

    --一键强化
    if self._treasure:canQuicklyEnhance() == true then 
        --等级变化
        targetLvl = self:getTargetLvl();

        if self._treasure:canEnhance() == true then 
            self.panel_downPanel.mc_btn1:showFrame(2);
        else 
            self.panel_downPanel.mc_btn1:showFrame(1);
        end 
        
        local btn = self.panel_downPanel.mc_btn1:getCurFrameView().btn_1;
        btn:setTap(c_func(self.enhanceFiveclick, self, targetLvl));
    else 
        targetLvl = 1 + treasureLvl;
        
        self.panel_downPanel.mc_btn1:showFrame(1);
        local btn = self.panel_downPanel.mc_btn1:getCurFrameView().btn_1;
        btn:setTap(c_func(self.enhanceOneclick, self, 1));

    end    

    --红点
    if self._treasure:canEnhance() == true then 
        self.panel_downPanel.panel_red:setVisible(true);
        --不置灰 
        FilterTools.clearFilter(self.panel_downPanel.mc_btn1);
    else 
        self.panel_downPanel.panel_red:setVisible(false); 
        --置灰
        FilterTools.setGrayFilter(self.panel_downPanel.mc_btn1); 
    end 

    local increasePower = self._treasure:powerAddEachLevel() * (targetLvl - treasureLvl);
    self.panel_downPanel.txt_5:setString("+" .. tostring(increasePower));

    self.panel_downPanel.txt_2:setString(GameConfig.getLanguageWithSwap("treasure_lvl", treasureLvl));

    self.panel_downPanel.txt_3:setString(GameConfig.getLanguageWithSwap("treasure_lvl",targetLvl));

    local ctn = self.panel_downPanel.ctn_1;
    ctn:removeAllChildren();
    self:createUIArmature("UI_common","UI_common_lvjiantou", ctn, true);

end

function TreasureEnhanceView:enhanceOneclick(count)
    echo("enhanceOneclick");
    if self._treasure:canEnhance() == true then 
        self:setDonwInfoVisible(false);
        self:finishLastAni();
        TreasureServer:enhance(self._treasureId, count, 
            c_func(self.enhanceCallback, self));
        AudioModel:playSound("s_treasure_qianghua");
    else  
        if self._isCoinEnough == false then 
            local ui = WindowControler:showWindow("CompBuyCoinMainView");
            ui:buyCoin();
        else 
            WindowControler:showTips("材料不足，不可强化");
        end 
    end 
end

function TreasureEnhanceView:enhanceFiveclick(targetLvl)
    if self._treasure:canEnhance() == true then 
        local treasureLvl = self._treasure:level();
        self:setDonwInfoVisible(false);

        TreasureServer:enhance(self._treasureId, targetLvl - treasureLvl, 
            c_func(self.enhanceCallback, self));
        AudioModel:playSound("s_treasure_qianghua"); 
    else 
        if self._isCoinEnough == false then 
            local ui = WindowControler:showWindow("CompBuyCoinMainView");
            ui:buyCoin();
        else 
            WindowControler:showTips("材料不足，不可强化");
        end 
    end 
end

function TreasureEnhanceView:finishLastAni()
    if self._ani_xiaohao ~= nil then 
        self:setPower(false);
        self:initTreasureLvl();
        self:initUI();

        EventControler:dispatchEvent(TreasureEvent.ENHANCE_SUCCESS_EVENT, 
            {treasure = self._treasure});

        self._ani_xiaohao:removeFromParent(true);
        self._ani_xiaohao = nil;
    end 

    if self._ani_shangsheng ~= nil then 
        self._ani_shangsheng:removeFromParent(true);
        self._ani_shangsheng = nil;
    end 

    if self._ani_shangsheng ~= nil then
        self._ani_bagua:removeFromParent(true);
        self._ani_bagua = nil;
    end 

    if self._ani_beijing ~= nil then
        self._ani_beijing:removeFromParent(true);
        self._ani_beijing = nil;
    end 
end

function TreasureEnhanceView:enhanceCallback(event)
    function callBackFunc()
        self._ani_xiaohao:removeFromParent(true);
        self._ani_xiaohao = nil;
        
        self:delayCall(function ( ... )
            --如果满级 展示框，关界面
            if self._treasure:isCurStageMaxLvl() == true then --展示精炼界面
                WindowControler:showWindow("TreasureReFineView", 
                    self._treasure, true, self._detailView);
                self:press_btn_close();
                self:resumeUIClick();
            else 
                self:resumeUIClick();
            end         
        end, effectShowLastTime - 0.4); 
    end

    if event.error == nil then
        --可以精炼，不可点击
        if self._treasure:isCurStageMaxLvl() == true then 
            self:disabledUIClick();
        end 

        self._ani_beijing = self:createUIArmature("UI_fabao_common","UI_fabao_common_beijing", 
            self.ctn_bg, false, GameVars.emptyFunc);
        self._ani_beijing:doByLastFrame(true, true, function ( ... )
            self._ani_beijing = nil;
        end);

        self._ani_xiaohao = self:createUIArmature("UI_qianghua","UI_qianghua_xiaohao", 
            self.ctn_middle_ani, false, callBackFunc);

        self._ani_xiaohao:registerFrameEventCallFunc(10, 1, function ( ... )
            self:setPower(true);

            self:initTreasureLvl();
            self:initTreasureBaseInfo();
            self:setDownInfo();
            self:setNeedRes();
            
            --底部发光
            self._ani_bagua = self:createUIArmature("UI_fabao_common","UI_fabao_common_bagua", 
                self.ctn_bagua, false, GameVars.emptyFunc);
            self._ani_bagua:doByLastFrame(true, true, function ( ... )
                    self._ani_bagua = nil;
                end);

            EventControler:dispatchEvent(TreasureEvent.ENHANCE_SUCCESS_EVENT, 
                {treasure = self._treasure}); 

            --法宝亮一下………………
            local id = self._treasure:getId();
            local iconPath = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, id);
            local spriteTreasureIcon = display.newSprite(iconPath); 
            local spriteTreasureIcon2 = display.newSprite(iconPath); 

            local fabaoAni = self:createUIArmature("UI_qianghua","UI_qianghua_fabaosg", 
                self.ctn_middle_ani, false);

            spriteTreasureIcon:setPosition(0, 0)
            spriteTreasureIcon2:setPosition(0, 0)
            FuncArmature.changeBoneDisplay(fabaoAni, "node1", spriteTreasureIcon); 
            FuncArmature.changeBoneDisplay(fabaoAni, "node4", spriteTreasureIcon2); 
        end)
        
        self._ani_shangsheng = self:createUIArmature("UI_qianghua","UI_qianghua_shangsheng", 
            self.ctn_dipan, false, GameVars.emptyFunc);  
        self._ani_shangsheng:doByLastFrame(true, true, function ( ... )
                self._ani_shangsheng = nil;
            end);  
    end
end

-- self.panel_downPanel.txt_4:setVisible(isVisible);
-- self.panel_downPanel.txt_5:setVisible(isVisible);
-- self.panel_downPanel.txt_3:setVisible(isVisible);
-- self.panel_downPanel.ctn_1:setVisible(isVisible);
-- self.panel_downPanel.txt_2:setVisible(isVisible);
function TreasureEnhanceView:setDonwInfoVisible(isVisible)
    if isVisible == true then 
        self.panel_downPanel.txt_4:setOpacity(255);
        self.panel_downPanel.txt_5:setOpacity(255);
        self.panel_downPanel.txt_3:setOpacity(255);
        self.panel_downPanel.ctn_1:setOpacity(255);
        self.panel_downPanel.txt_2:setOpacity(255);
    else 
        -- self.panel_downPanel.txt_4:setOpacity(0);
        -- self.panel_downPanel.txt_5:setOpacity(0);
        -- self.panel_downPanel.txt_3:setOpacity(0);
        -- self.panel_downPanel.ctn_1:setOpacity(0);
        -- self.panel_downPanel.txt_2:setOpacity(0);
        self.panel_downPanel.txt_4:runAction(cc.FadeTo:create(0.2, 0));
        self.panel_downPanel.txt_5:runAction(cc.FadeTo:create(0.2, 0));
        self.panel_downPanel.txt_3:runAction(cc.FadeTo:create(0.2, 0));
        self.panel_downPanel.ctn_1:runAction(cc.FadeTo:create(0.2, 0));
        self.panel_downPanel.txt_2:runAction(cc.FadeTo:create(0.2, 0));
    end 
end

function TreasureEnhanceView:setPowerNum(nums)
    local len = table.length(nums);
    self.panel_power.mc_shuzi:showFrame(len);

    for k, v in pairs(nums) do
        local mcs = self.panel_power.mc_shuzi:getCurFrameView();
        mcs["mc_" .. tostring(k)]:showFrame(v + 1);
    end
end

function TreasureEnhanceView:setPower(isWithAnimation)
    local power = self._treasure:getPower();
    local powerValueTable = number.split(power);

    if isWithAnimation ~= true then 
        self:setPowerNum(powerValueTable);
    else 
        TreasureUICommon.setPowerWithAni(self);
    end 

    self._beforePowerNum = power;
end

function TreasureEnhanceView:initTreasureLvl()
    local label3 = self.mc_dingwei:getCurFrameView().txt_2;
    label3:setString(self._treasure:level() .. tostring("级"));
end

function TreasureEnhanceView:initTreasureBaseInfo()
    self.txt_3:setVisible(false);

    local id = self._treasure:getId();
    self.mc_dingwei:showFrame(1);
    --label3
    local label3 = self.mc_dingwei:getCurFrameView().txt_2;
    label3:setString(self._treasure:level() .. tostring("级"));

    --name 
    local nameStr =  self._treasure:getName();
    self.txt_1:setString(nameStr);
    --前后 图片 底框
    local id = self._treasure:getId();

    local posIndex = self._treasure:getPosIndex();
    self.mc_1:showFrame(posIndex);

    local state = self._treasure:state();
    self.mc_3:showFrame(state);

    -- todo 法宝图标
    local iconPath = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, id);
    local spriteTreasureIcon = display.newSprite(iconPath); 
    self.ctn_1:removeAllChildren();
    
    spriteTreasureIcon:size(self.ctn_1.ctnWidth, 
        self.ctn_1.ctnHeight);
    self.ctn_1:addChild(spriteTreasureIcon);
    --星级
    local star = self._treasure:star();
    for i = 1, 5 do
        local mc = self["mc_bigxing" .. tostring(i)];
        if star >= i then 
            mc:showFrame(2);
        else 
            mc:showFrame(1);
        end 
    end

    --什么品 
    local quality = FuncTreasure.getValueByKeyTD(id, "quality");
    if quality >= 6 then 
        quality = 5;
    end 
    self.mc_2:showFrame(quality);

    self.ctn_1:setTouchedFunc(c_func(self.showTreasureInfo, self));
end

function TreasureEnhanceView:showTreasureInfo()
    AudioModel:playSound("s_com_click1");
    WindowControler:showWindow("TreasureInfoView", self._treasureId);
end

function TreasureEnhanceView:press_btn_close()
    self:startHide();
    if self._detailView then
        self._detailView:setTreasure(self._treasure);
        self._detailView:initUIWithoutLeftList();
    end
    
end

return TreasureEnhanceView;





