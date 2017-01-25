--guan
--2016.3.2
--2016.6.6 换界面
--精炼

local TreasureReFineView = class("TreasureReFineView", UIBase);

function TreasureReFineView:ctor(winName, treasure, isShowAction, detailView)
    TreasureReFineView.super.ctor(self, winName);
    self._treasure = treasure;
    self._treasureId = treasure:getId();
    self._isShowAction = isShowAction;
    self._detailView = detailView;
end

function TreasureReFineView:loadUIComplete()
    self.panel_power.mc_num:visible(false);

	self:registerEvent();
    self:initUI();
    self:initLeftListUI();
    self:showEntryAnim();

    --分辨率适配
    FuncCommUI.setViewAlign(self.btn_close, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.ctn_leftList, UIAlignTypes.Left);
    FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop);

end 

--入场动画
function TreasureReFineView:showEntryAnim()
    if self._isShowAction ~= true then 
        return 
    end 

    --4个飞入  
    local openAni = self:createUIArmature("UI_qianghua","UI_qianghua_chutubiao", 
        self.ctn_entryAni, false, GameVars.emptyFunc);
    self.panel_cailiao2:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(openAni, "node2", self.panel_cailiao2);
    self.panel_cailiao1:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(openAni, "node1", self.panel_cailiao1);

    self.panel_cailiao3:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(openAni, "node3", self.panel_cailiao3);
    self.panel_cailiao4:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(openAni, "node4", self.panel_cailiao4);

    --底部
    local downAni = self:createUIArmature("UI_qianghua","UI_qianghua_lankuang", self.ctn_downAni, 
        false, GameVars.emptyFunc);
    self.panel_down2:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(downAni, "lantiao", self.panel_down2);

    --品质
    local qualityAni = self:createUIArmature("UI_qianghua","UI_qianghua_pingjie", self.ctn_qualityAni, 
        false, GameVars.emptyFunc);
    self.mc_2:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(qualityAni, "pinji", self.mc_2);

    self:createUIArmature("UI_fabao_common","UI_fabao_common_ssyw", self.ctn_refineAni, true);

    self:createUIArmature("UI_fabao_common","UI_fabao_common_beijing", 
            self.ctn_bg, true);
end

--[[
    初始化左边的list
]]
function TreasureReFineView:initLeftListUI()
    --把哪个公共list放过来
    if not g_TreasureLeftList then
         g_TreasureLeftList = WindowsTools:createWindow("TreasureLeftListCompoment", self._treasure);
    end
    g_TreasureLeftList:parent(self.ctn_leftList);
    g_TreasureLeftList:setVisible(true);
end

function TreasureReFineView:registerEvent()
	TreasureReFineView.super.registerEvent();
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

function TreasureReFineView:coinChangeCallBack(event)
    local changeNum = event.params.coinChange;
    -- echo("----changeNum---", changeNum);
    if changeNum > 0 then 
        --刷新能否强化
        self:initRefineBtn();
        --刷新能金币数
        self:setRes();
    end 
end

function TreasureReFineView:itemChangeCallBack( ... )
    --刷新能否强化
    self:initRefineBtn();
    --刷新能金币数
    self:setRes();
end

function TreasureReFineView:onChangeTreasure(event)
    self._treasure = event.params.treasure;
    self._treasureId = self._treasure:getId();

    if self._treasure:getStrongType() == Treasure.StrongType.Refine then 
        self:initUI();
    else 
        --变到精炼界面
        self:startHide();
        WindowControler:showWindow("TreasureEnhanceView", 
            self._treasure, false, self._detailView);
    end 
end

function TreasureReFineView:initUI()
    self.panel_down2.panel_up1:setVisible(false);
    self:initTreasureBaseInfo();
    self:setPower();
    self:setRes();
    self:setDownInfo(); 

    FuncCommUI.regesitShowPowerTipView(
        self.panel_power, self._treasureId);
end

function TreasureReFineView:setDownInfo()
    --威能增加
    local curPower = self._treasure:getPower();
    local nextPower = TreasuresModel:getPower(
        self._treasureId, self._treasure:level(), 
        self._treasure:star(), self._treasure:state() + 1);
    local diff = nextPower - curPower;
    local a = self._treasure:state();
    local b = self._treasure:getMaxState()
    if self._treasure:state() + 1 >= self._treasure:getMaxState() then 
        --精炼后就圆满，强化上限不加了
        self.panel_down2.mc_1:showFrame(2);

        self.panel_down2.mc_1:getCurFrameView().txt_5:setString("+" .. tostring(diff));
    else 
        self.panel_down2.mc_1:showFrame(1);
        local panelInfo = self.panel_down2.mc_1:getCurFrameView().panel_3;
        panelInfo.txt_2:setString(self._treasure:state() * 10);
        panelInfo.txt_3:setString(self._treasure:state() * 10 + 10);
        panelInfo.txt_5:setString("+" .. tostring(diff));

        self:createUIArmature("UI_common","UI_common_lvjiantou", 
            panelInfo.ctn_1, true);
    end 

    --列表
    local upLvlTable, newActivateTable = self._treasure:skillDiffNextState();
    self._upLvlTable = upLvlTable;
    self._newActivateTable = newActivateTable;
    self._allSkill = TreasuresModel:getAllSkillByIdAfterSort(self._treasureId);
    self._openSkill = self._treasure:getAddOnSkill();
    self._powerAddNum = diff;

    local i = 0;
    self._tableSkillPanel = {};

    if table.length(upLvlTable) ~= 0 then
        echo("--upLvlTable--");
        for id, v in pairs(upLvlTable) do
            local skillPanel = UIBaseDef:cloneOneView(self.panel_down2.panel_up1);

            local curLvl = self._treasure:getSkillLvl(id);
            skillPanel.mc_st1:showFrame(curLvl + v);

            for i = 1, curLvl + v do
                skillPanel.mc_st1:getCurFrameView()["mc_" .. tostring(i)]:showFrame(1);
                if i > curLvl then 
                    --动画
                    local fadeShow = cc.FadeTo:create(0.3, 255);
                    local fadeHide = cc.FadeTo:create(0.3, 0);
                    local sequence = cc.Sequence:create(fadeShow, fadeHide);
                    skillPanel.mc_st1:getCurFrameView()["mc_" .. tostring(i)]:runAction(
                        cc.RepeatForever:create(sequence));
                end 
            end

            skillPanel.txt_1:setVisible(false);

            --icon
            skillPanel.ctn_1:removeAllChildren();
            local sprite = FuncTreasure.getSkillSprite(id, curLvl);
            skillPanel.ctn_1:addChild(sprite);
            sprite:size(skillPanel.ctn_1.ctnWidth, 
                skillPanel.ctn_1.ctnHeight);

            table.insert(self._tableSkillPanel, skillPanel);

            FuncCommUI.regesitShowSkillTipView(skillPanel,
                {skillId = id, level = curLvl + v, treasure = self._treasure});
        end
    end 

    if table.length(newActivateTable) ~= 0 then 
        echo("--newActivateTable--");
        for id, v in pairs(newActivateTable) do

            local skillPanel = UIBaseDef:cloneOneView(self.panel_down2.panel_up1);
            skillPanel.mc_st1:showFrame(1);
            skillPanel.mc_st1:getCurFrameView().mc_1:showFrame(1);

            local fadeShow = cc.FadeTo:create(0.3, 255);
            local fadeHide = cc.FadeTo:create(0.3, 0);
            local sequence = cc.Sequence:create(fadeShow, fadeHide);
            skillPanel.mc_st1:getCurFrameView().mc_1:runAction(
                cc.RepeatForever:create(sequence));

            local curLvl = self._treasure:getSkillLvl(id);

            --icon
            skillPanel.ctn_1:removeAllChildren();
            local sprite = FuncTreasure.getSkillSprite(id, curLvl);
            skillPanel.ctn_1:addChild(sprite);
            sprite:size(skillPanel.ctn_1.ctnWidth, 
                skillPanel.ctn_1.ctnHeight);

            table.insert(self._tableSkillPanel, skillPanel);

            FuncCommUI.regesitShowSkillTipView(skillPanel,
                {skillId = id, level = curLvl + v, treasureId = self._treasureId});
        end
    end 

    --init List 
    function createRankItemFunc(itemData)
        return itemData;
    end

    local scrollParams = {
        {
            data = self._tableSkillPanel,
            createFunc = createRankItemFunc,
            perNums = 1,
            offsetX = 50,
            offsetY = 60,
            widthGap = 10,
            itemRect = {x = 0, y = -126, width = 101.5, height = 126},
            perFrame = 6,
        }
    }

    self.panel_down2.scroll_list:styleFill(scrollParams);

    if self._treasure:isMaxLvl() then 
        self.panel_down2.mc_yuanman:showFrame(2);
    else
        self.panel_down2.mc_yuanman:showFrame(1);
    end 

    self:initRefineBtn();
end

function TreasureReFineView:initRefineBtn()
    --btn
    if self._treasure:canRefine() == true then 
        --显示红点
        self.panel_down2.panel_red:setVisible(true);
        --不置灰
        FilterTools.clearFilter(self.panel_down2.mc_yuanman);
    else 
        --不显示红点
        self.panel_down2.panel_red:setVisible(false);
        --置灰
        FilterTools.setGrayFilter(self.panel_down2.mc_yuanman);
    end     

    self.panel_down2.mc_yuanman:setTouchedFunc(c_func(self.clickReFine, self));
end

function TreasureReFineView:clickReFine()
    echo("clickReFine");
    if self._treasure:canRefine() == true then 

        TreasureServer:refine(self._treasureId, c_func(self.refineCallBack, self))
        -- self:refineCallBack({});
        AudioModel:playSound("s_treasure_jinglian");
        AudioModel:playSound("s_com_numChange");

    else 
        if self._treasure:isEnoughPlayerLvlToRefine() == false then 
            local lvl = self._treasure:refineNeedCharLvl();
            WindowControler:showTips({text = GameConfig.getLanguageWithSwap("treasure_needPlayerLvl", lvl)});
        else 

            if self._isCoinEnough == false then 
                local ui = WindowControler:showWindow("CompBuyCoinMainView");
                ui:buyCoin();
            else 
                WindowControler:showTips({text = self._lackItemName .. "不足，不可精炼"});
            end 
        end 
    end  
end

function TreasureReFineView:refineCallBack(event)
    if event.error == nil then
        echo("refineCallBack");
        self:disabledUIClick();

        --法宝亮一下
        local id = self._treasure:getId();
        local iconPath = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, id);
        local spriteTreasureIcon = display.newSprite(iconPath); 
        local spriteTreasureIcon2 = display.newSprite(iconPath); 

        local fabaoAni = self:createUIArmature("UI_jinglian","UI_jinglian_fabao", 
            self.ctn_growAni, false);

        spriteTreasureIcon:setPosition(0, 0)
        spriteTreasureIcon2:setPosition(0, 0)
        FuncArmature.changeBoneDisplay(fabaoAni, "node3", spriteTreasureIcon); 
        FuncArmature.changeBoneDisplay(fabaoAni, "node4", spriteTreasureIcon2);

        local bgAni = self:createUIArmature("UI_fabao_common","UI_fabao_common_beijing", 
            self.ctn_bg, false);

        function callBackFunc()
            EventControler:dispatchEvent(TreasureEvent.REFINE_SUCCESS_EVENT, 
                {treasure = self._treasure});
            self:startHide();

            WindowControler:showWindow("TreasureReFineSuccessView", 
                self._treasure, self._newActivateTable, self._upLvlTable, self._powerAddNum);
        end

        local upfunc = function ( ... )
                self:delayCall(function ( ... )
                    callBackFunc();
                end, 0.5);
                self._upupup:setVisible(false);
            end
         
        self._upupup = self:createUIArmature("UI_jinglian","UI_jinglian_shangsheng", 
            self.ctn_growAni, false, upfunc);

        --飞入
        local cailiaoAni = self:createUIArmature("UI_jinglian","UI_jinglian_huiju", 
            self.ctn_refineAni, false, GameVars.emptyFunc);

        cailiaoAni:registerFrameEventCallFunc(55, 1, function ( ... )
            echo("---registerFrameEventCallFunc 55----");
            self:setPower(true);
            --底部发光
            self:createUIArmature("UI_fabao_common","UI_fabao_common_bagua", 
                self.ctn_bagua, false);             
        end)

        cailiaoAni:registerFrameEventCallFunc(30, 1, function ( ... )
            echo("---registerFrameEventCallFunc 30----");
            self.panel_cailiao1.ctn_1:setVisible(false);
            self.panel_cailiao2.ctn_1:setVisible(false);
            self.panel_cailiao3.ctn_1:setVisible(false);
            self.panel_cailiao4.ctn_1:setVisible(false);

            self.panel_cailiao1.txt_1:setVisible(false);
            self.panel_cailiao2.txt_1:setVisible(false);
            self.panel_cailiao3.txt_1:setVisible(false);
            self.panel_cailiao4.txt_1:setVisible(false);
        end)

        local cailiaoSubAni = cailiaoAni:getBoneDisplay("node5");

        self.panel_cailiao1:setPosition(0, 0);
        FuncArmature.changeBoneDisplay(cailiaoSubAni, "Layer32", self.panel_cailiao1);
        self.panel_cailiao2:setPosition(0, 0);
        FuncArmature.changeBoneDisplay(cailiaoSubAni, "Layer26", self.panel_cailiao2);
        self.panel_cailiao3:setPosition(0, 0);
        FuncArmature.changeBoneDisplay(cailiaoSubAni, "Layer30", self.panel_cailiao3);
        self.panel_cailiao4:setPosition(0, 0);
        FuncArmature.changeBoneDisplay(cailiaoSubAni, "Layer28", self.panel_cailiao4);

        local state = self._treasure:state();
        local downAni = self:createUIArmature("UI_jinglian","UI_jinglian_dituo", 
            self.ctn_dizuo, false, GameVars.emptyFunc);

        self.mc_3:setPosition(0, 0);
        self.mc_3:setVisible(false);
        -- 之后的底框
        self.mc_3:showFrame(state)
        FuncArmature.changeBoneDisplay(downAni, "node2", self.mc_3);

        --之前的底框
        local changeMc = UIBaseDef:cloneOneView(self.mc_3);

        changeMc:showFrame(state - 1);
        changeMc:setPosition(0, 0);

        FuncArmature.changeBoneDisplay(downAni, "node1", changeMc);
    end
end

function TreasureReFineView:setRes()
    local stateId = self._treasure:getStateId();
    local needResArray = FuncTreasure.getValueByKeyTSD(stateId, "evoM");
    for i = 1, 4 do
        local panel = self["panel_cailiao" .. tostring(i)];
        if needResArray[i] ~= nil then
            local res = string.split(needResArray[i], ",");
            --需要数量
            local needNum = res[table.length(res)];
            local _, haveNum = UserModel:getResInfo( needResArray[i] );

            if tostring( res[1] ) ~= FuncDataResource.RES_TYPE.COIN then 
                panel.txt_1:setString(
                    tostring(haveNum) .. "/" .. tostring(needNum));
                panel.mc_1:setTouchedFunc(c_func(self.showGetWay, self, res[2]));
            else 
                --金币是否足够
                if tonumber(needNum) > tonumber(haveNum) then
                    self._isCoinEnough = false;
                else 
                    self._isCoinEnough = true;
                end     
                panel.txt_1:setString(tostring(needNum));
                panel.mc_1:setTouchedFunc(c_func(self.showGetWay, self, res[1]));
            end 
            
            if tonumber(needNum) > tonumber(haveNum) then 
                panel.txt_1:setColor(cc.c3b(255, 0, 0));
                self._lackItemName = FuncDataResource.getResNameById(res[1], 
                    res[2]);
            else 
                panel.txt_1:setColor(cc.c3b(255, 190, 90));
            end 

            panel.txt_1:setVisible(true);

            --icon
            local iconPath = FuncRes.iconRes(res[1], res[2]);
            local sp = display.newSprite(iconPath); 
            local ctn = panel.ctn_1;
            ctn:removeAllChildren();
            ctn:addChild(sp);
            sp:size(ctn.ctnWidth, ctn.ctnHeight);
            --边框
            local quality = FuncDataResource.getQualityById(res[1], res[2]);
            panel.mc_1:showFrame(quality);
        end 

    end
end

function TreasureReFineView:showGetWay(id)
    AudioModel:playSound("s_com_click1")
    echo("---need item id---", id);

    if id == FuncDataResource.RES_TYPE.COIN then 
        local ui = WindowControler:showWindow("CompBuyCoinMainView");
        ui:buyCoin();
    else 
        WindowControler:showWindow("GetWayListView", id);
    end 
end

function TreasureReFineView:setPowerNum( nums )
    local len = table.length(nums);
    self.panel_power.mc_shuzi:showFrame(len);

    for k, v in pairs(nums) do
        local mcs = self.panel_power.mc_shuzi:getCurFrameView();
        mcs["mc_" .. tostring(k)]:showFrame(v + 1);
    end
end

function TreasureReFineView:setPower(isWithAnimation)
    local power = self._treasure:getPower();
    local powerValueTable = number.split(power);

    if isWithAnimation ~= true then 
        self:setPowerNum(powerValueTable);
    else 
        TreasureUICommon.setPowerWithAni(self);
    end 

    self._beforePowerNum = power;
end

function TreasureReFineView:initTreasureBaseInfo()
    self.txt_3:setVisible(false);

    local id = self._treasure:getId();

    self.mc_dingwei:showFrame(1);
    --label3
    local label3 = self.mc_dingwei:getCurFrameView().txt_2;
    label3:setString(self._treasure:level() .. tostring("级"));

    --name 
    local nameStr = self._treasure:getName();
    self.txt_1:setString(nameStr);

    --前后 图片 底框
    local posIndex = self._treasure:getPosIndex();
    self.mc_1:showFrame(posIndex);

    local state = self._treasure:state();
    self.mc_3:showFrame(state);

    -- todo 法宝图标
    local iconPath = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, id);
    local spriteTreasureIcon = display.newSprite(iconPath); 
    self.ctn_icon:removeAllChildren();
    
    spriteTreasureIcon:size(self.ctn_icon.ctnWidth, 
        self.ctn_icon.ctnHeight);
    self.ctn_icon:addChild(spriteTreasureIcon);

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

    self.ctn_icon:setTouchedFunc(c_func(self.showTreasureInfo, self));
end

function TreasureReFineView:showTreasureInfo()
    AudioModel:playSound("s_com_click1")
    WindowControler:showWindow("TreasureInfoView", self._treasureId);
end

function TreasureReFineView:press_btn_close()
    self:startHide();
    if  self._detailView then
        self._detailView:setTreasure(self._treasure);
        self._detailView:initUIWithoutLeftList();
    end
end

return TreasureReFineView;








