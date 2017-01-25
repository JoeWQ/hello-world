--guan
--精炼成功界面

--2016.6.27 大改

local TreasureReFineSuccessView = class("TreasureReFineSuccessView", UIBase);

function TreasureReFineSuccessView:ctor(winName, treasure, news, ups, upPowerStr)
    TreasureReFineSuccessView.super.ctor(self, winName);
    self._treasure = treasure;
    self._news = news;
    self._ups = ups;
    self._treasureId = treasure:getId();
    self._upPowerStr = upPowerStr
end

function TreasureReFineSuccessView:loadUIComplete()
	self:registerEvent();
    self:prepareUI();
    self:initArmature();
end 

function TreasureReFineSuccessView:registerEvent()
    TreasureReFineSuccessView.super.registerEvent();
end

--动画
function TreasureReFineSuccessView:initArmature()
    --title 动画

    local bgAni = FuncCommUI.createSuccessArmature(FuncCommUI.SUCCESS_TYPE.REFINE)
    self.ctn_tittle:addChild(bgAni);

    bgAni:getBone("di2"):setVisible(false);


    --法宝变化
    local treasureAni = self:createUIArmature("UI_jinglian_chenggong",
        "UI_jinglian_chenggong_fabao", self.ctn_treasure, false, GameVars.emptyFunc);

    treasureAni:registerFrameEventCallFunc(50, 1, function ( ... )
            self:registClickClose(nil ,c_func(self.closeView, self));
        end);

    --右法宝
    local rightSubAni = treasureAni:getBoneDisplay("zuofabao");
    --icon
    self._rightCommonUITreasureView.ctn_icon:setScale(1.4);
    self._rightCommonUITreasureView.ctn_icon:setPosition(100, -100);
    FuncArmature.changeBoneDisplay(rightSubAni, "layer2", 
        self._rightCommonUITreasureView.ctn_icon);

    --玄天
    self._rightCommonUITreasureView.mc_zizhi:setPosition(0, 9);
    self._rightCommonUITreasureView.mc_zizhi:setScale(1);
    FuncArmature.changeBoneDisplay(rightSubAni, "layer4", 
        self._rightCommonUITreasureView.mc_zizhi);

    self._rightCommonUITreasureView.mc_di:setPosition(0, 0);
    self._rightCommonUITreasureView.mc_di:setScale(1);
    FuncArmature.changeBoneDisplay(rightSubAni, "layer3", 
        self._rightCommonUITreasureView.mc_di);

    --提升
    self:createUIArmature("UI_jinglian_chenggong",
        "UI_jinglian_chenggong_zi", self.ctn_arrow, false, GameVars.emptyFunc);

    self.panel_power:setPosition(0, 0);
    local weiliAni = self:createUIArmature("UI_jinglian_chenggong",
        "UI_jinglian_chenggong_weili", self.ctn_power, false, GameVars.emptyFunc);
    FuncArmature.changeBoneDisplay(weiliAni, "youweili", self.panel_power);


    self:showSkills();
end


function TreasureReFineSuccessView:setPowerNum(nums)
    local len = table.length(nums);
    self.panel_power.mc_shuzi:showFrame(len);

    for k, v in pairs(nums) do
        local mcs = self.panel_power.mc_shuzi:getCurFrameView();
        mcs["mc_" .. tostring(k)]:showFrame(v + 1);
    end
end

--设置威能 isWithAnimation 是否动画跳过去
function TreasureReFineSuccessView:setPower(isWithAnimation)
    local power = self._treasure:getPower();
    local powerValueTable = number.split(power);

    if isWithAnimation ~= true then 
        self:setPowerNum(powerValueTable);
    else 
        TreasureUICommon.setPowerWithAni(self);
    end 
end

function TreasureReFineSuccessView:prepareUI()
    self.panel_5:setVisible(false);
    self.panel_skill:setVisible(false);

    self:disabledUIClick();

    local graylayer = cc.LayerColor:create(
        cc.c4b(0, 0, 0, 200), GameVars.width, GameVars.height):pos(
            -GameVars.UIOffsetX, -640);
    graylayer:setTouchEnabled(false);

    self:addChild(graylayer, -1);

    AudioModel:playSound("s_treasure_jinglianOK");

    local state = self._treasure:state();

    self._leftCommonUITreasureView = self:createTreasureView(state - 1);
    self._rightCommonUITreasureView = self:createTreasureView(state);

    self:setPower();

    self.panel_power.mc_num:setVisible(false);
end

function TreasureReFineSuccessView:showSkills()
    
    function showSubSkillAni(id, i, isShowNewLabel)
        local skillCtns = self.mc_1:getCurFrameView();
        local openSkills = self._treasure:getAddOnSkill();

        local viewClone = UIBaseDef:cloneOneView(self.panel_skill);
        local ctn = skillCtns["ctn_" .. tostring(i)];
        local lvl = openSkills[id];
        viewClone.mc_st1:showFrame(lvl);

        for i = 1, lvl - 1 do
            local glowCtn = viewClone.mc_st1:getCurFrameView().panel_down1["ctn_" .. tostring(i)];
            self:createUIArmature("UI_xiangqing","UI_xiangqing_shentongliuguang", glowCtn, true);
        end

        local glowCtn = viewClone.mc_st1:getCurFrameView().panel_down1["ctn_" .. tostring(lvl)];
        local lastMc = viewClone.mc_st1:getCurFrameView().panel_down1["mc_" .. tostring(lvl)];
        lastMc:setVisible(false)

        local glowAni = self:createUIArmature("UI_jinglian_chenggong",
            "UI_jinglian_chenggong_kaiqishentong", glowCtn, false, GameVars.emptyFunc);
        glowAni:doByLastFrame(true, true, function ( ... )

        end);
        
        glowAni:registerFrameEventCallFunc(35, 1, 
            function ( ... )
                lastMc:setVisible(true);
                self:createUIArmature("UI_xiangqing","UI_xiangqing_shentongliuguang", glowCtn, true);
            end);
        if isShowNewLabel == true then 
            viewClone.panel_1.txt_1:setVisible(true);
        else 
            viewClone.panel_1.txt_1:setVisible(false);
        end 
        --icon 
        viewClone.panel_1.ctn_1:removeAllChildren();
        local sprite = FuncTreasure.getSkillSprite(id, lvl);
        viewClone.panel_1.ctn_1:addChild(sprite);
        sprite:size(viewClone.panel_1.ctn_1.ctnWidth, 
            viewClone.panel_1.ctn_1.ctnHeight);

        local ani = self:createUIArmature("UI_jinglian_chenggong",
            "UI_jinglian_chenggong_shengtong", ctn, false, GameVars.emptyFunc);

        viewClone.panel_1:setPosition(0, 0);
        FuncArmature.changeBoneDisplay(ani, "layer13", viewClone.panel_1);
        viewClone.mc_st1:getCurFrameView().panel_down1:setPosition(0, 0);
        FuncArmature.changeBoneDisplay(ani, "layer14", 
            viewClone.mc_st1:getCurFrameView().panel_down1);
    end

    local upTreasureNum = table.length(self._ups);
    local newTreasureNum = table.length(self._news);
    local totalChange = newTreasureNum + upTreasureNum;

    if totalChange > 0 then 
        self.mc_1:showFrame(totalChange);
        local i = 0;

        --升级的特效
        if upTreasureNum ~= 0 then 
            echo("upTreasureNum");
            for id, _ in pairs(self._ups) do
                i = i + 1;
                showSubSkillAni(id, i, false);
            end
        end 

        if newTreasureNum ~= 0 then 
            for id, v in pairs(self._news) do
                i = i + 1;
                showSubSkillAni(id, i, true);
            end

        end 
    end 
end

--精炼之前的法宝
function TreasureReFineSuccessView:createTreasureView(state)
    local retView = UIBaseDef:cloneOneView(self.panel_5);

     --前中后
    local posIndex = self._treasure:getPosIndex();
    retView.mc_biaoqian:showFrame(posIndex);

    --什么品
    local quality = FuncTreasure.getValueByKeyTD(self._treasureId, "quality");
    if quality >= 6 then 
        quality = 5;
    end 
    retView.mc_zizhi:showFrame(quality);

    --法宝图标
    local iconPath = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, 
        self._treasureId);
    local spriteTreasureIcon = display.newSprite(iconPath); 
    retView.ctn_icon:removeAllChildren();
    retView.ctn_icon:addChild(spriteTreasureIcon);
    spriteTreasureIcon:size(retView.ctn_icon.ctnWidth, 
        retView.ctn_icon.ctnHeight);

    --底盘
    retView.mc_di:showFrame(state);   

    return retView;
end

function TreasureReFineSuccessView:closeView()
    self:startHide();
    if self._treasure:isMaxPower() == true then 
        
        --此时给合成发消息 刷新合成条件
        EventControler:dispatchEvent(TreasureEvent.FABAO_YUANMAN, { }) 
        WindowControler:showWindow("TreasureMaxView", self._treasure);
    end
end

return TreasureReFineSuccessView;













