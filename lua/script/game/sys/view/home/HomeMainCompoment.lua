--[[
    guan
    2016.7.22
]]

local HomeMainCompoment = class("HomeMainCompoment", UIBase);
local btnTag = 945;

--btnName btn 名字 orderId 是 顺序，最右面是1
HomeMainCompoment.BTN_SYS_NAME_MAP = {
    treasure = {btnName = "btn_treasure", orderId = 8, sysName = "treasure"}, 
    char = {btnName = "btn_char", orderId = 7, sysName = "char"},  
    god = {btnName = "btn_holy", orderId = 6, sysName = "god"}, 
    -- friend = {btnName = "btn_friend", orderId = 5, sysName = "friend"}, 
    partner = {btnName = "btn_friend", orderId = 5, sysName = "partner"}, 
    bag = {btnName = "btn_bag", orderId = 4, sysName = "bag"},  
    elite = {btnName = "btn_ronmance", orderId = 3, sysName = "romance"},  
    -- guild = {btnName = "btn_guild", orderId = 2, sysName = "guild"},  
    pvp = {btnName = "btn_arena", orderId = 1, sysName = "Pvp"},  --登仙台 对应挑战
    partnerEquipment = {btnName = "btn_equipment", orderId = 9, sysName = "partnerEquipment"},  --装备
};

function HomeMainCompoment:ctor(winName)
    HomeMainCompoment.super.ctor(self, winName);

    self._cloneCtns = {};
end

function HomeMainCompoment:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function HomeMainCompoment:registerEvent()
	HomeMainCompoment.super.registerEvent();

    --todo  应该是有功能开启事件
    EventControler:addEventListener(HomeEvent.SYSTEM_OPEN_EVENT, 
        self.newSystemOpenCallBack, self)

    --显示了主界面
    EventControler:addEventListener(HomeEvent.HOMEEVENT_COME_BACK_TO_MAIN_VIEW, 
        self.onHomeShow, self); 

    --红点检查
    EventControler:addEventListener(HomeEvent.RED_POINT_EVENT,
        self.redPointDateUpate, self, 1); 


    EventControler:addEventListener(BattleEvent.BATTLEEVENT_ONBATTLEENTER, 
        self.onBattlleEnter, self)
end

function HomeMainCompoment:onBattlleEnter( ... )
    echo("------------------------------");
    echo("----onBattlleEnter------");
    echo("------------------------------");

    HomeModel:setOpenSysCache(self:getOpenSys());
end

function HomeMainCompoment:redPointDateUpate(data)
    local redPointType = data.params.redPointType;
    -- local isShow = data.params.isShow or false;
    local isShow = HomeModel:isRedPointShow(redPointType);

    if redPointType == HomeModel.REDPOINT.DOWNBTN.WORLD then 
        self.btn_world:getUpPanel().panel_red:setVisible(isShow);
        return;
    end     

    if HomeMainCompoment.BTN_SYS_NAME_MAP[redPointType] ~= nil then 
        for k, v in pairs(self._cloneCtns) do
            if v.name == redPointType then 
                local btnWidget = v.widget:getChildByTag(btnTag);
                local panel = btnWidget:getUpPanel();
                panel.panel_red:setVisible(isShow);
                return;
            end 
        end
    end 
end

function HomeMainCompoment:newSystemOpenCallBack(event)    
    local openSysName = event.params.sysNameKey;

    echo("---HomeMainCompoment:newSystemOpenCallBack---", openSysName);

    function isNewBtnShow(openSysName)
        if openSysName ~= nil and 
                HomeMainCompoment.BTN_SYS_NAME_MAP[openSysName] ~= nil then 
            return true;
        else 
            return false;
        end  
    end
    
    if isNewBtnShow(openSysName) == true then 
        self._isNeedShowAni = true;
        self._newSysName = openSysName;
    end 
end

function HomeMainCompoment:onHomeShow()
    -- echo("---HomeMainCompoment:onHomeShow---");
    if self._isNeedShowAni == true then 
        self:donwResChange(self._newSysName);
        self._isNeedShowAni = false;
    end 
end

--展示新图标出现动画
function HomeMainCompoment:donwResChange(openSysName)
    local apartWidth = 90;

    local orderIndex = FuncCommon.getSysBtnOrder(openSysName);

    --新的btn放上
    local btnInfo = HomeMainCompoment.BTN_SYS_NAME_MAP[openSysName];
    local widget = self:createSingleBtn(btnInfo, orderIndex);

    --从这个orderIndex到最后一个，搞成一个 大 node
    local nodeCtn = display.newNode();

    local i = 0;
    for k, v in pairs(self._cloneCtns) do
        if k >= orderIndex then 
            v.widget:parent(nodeCtn, -i - 1);
            v.widget:setPosition(-i * apartWidth, 0);
            i = i + 1;
        end 
    end

    self:addChild(nodeCtn);
    
    FuncArmature.loadOneArmatureTexture("UI_zhujiemian", nil, true)
    local downAni = self:createUIArmature("UI_zhujiemian", "UI_zhujiemian_xingongneng", 
        self["ctn_" .. tostring(orderIndex)], false, function ( ... )
            --播完了，在展示新开启的标签
            -- local unforcedTutorialManager = UnforcedTutorialManager.getInstance();
            -- unforcedTutorialManager:showAllBubbles();
            self._isNeedReSetDownBtns = true;
        end);

    widget:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(downAni, "Layer3", widget);
    nodeCtn:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(downAni, "Layer5", nodeCtn);

    self._downAni = downAni;
end

--删除特效 重新搞下面的btn, 为下个功能开启做准备
function HomeMainCompoment:resetBtns()
    echo("---resetBtns---");
    self:initBtns();
end

function HomeMainCompoment:initUI()

    function setBtnUnVIsible()
        self.btn_arena:setVisible(false);
        self.btn_guild:setVisible(false);
        self.btn_ronmance:setVisible(false);
        self.btn_bag:setVisible(false);
        self.btn_friend:setVisible(false);
        self.btn_holy:setVisible(false);
        self.btn_char:setVisible(false);
        self.btn_treasure:setVisible(false);
        self.btn_equipment:setVisible(false);
    end
    
    self:initFunc();
    setBtnUnVIsible();
    self:initBtns();
end

function HomeMainCompoment:clearCloneWidget()
    --[[
        self._cloneCtns = {};
    ]]
    for k,v in pairs(self._cloneCtns) do
        v.widget:removeFromParent();
    end

    if self._downAni ~= nil then 
        self._downAni:removeFromParent();
        self._downAni = nil;
    end 

    self._cloneCtns = {};
end

function HomeMainCompoment:initBtns()
    self:clearCloneWidget();

    --世界 这个不变！永远在那
    local btnWorld = self.btn_world;
    btnWorld:setTouchedFunc(c_func(self.clickWorld, self));
    btnWorld:setTouchSwallowEnabled(true);

    if HomeModel:isRedPointShow(HomeModel.REDPOINT.DOWNBTN.WORLD) == true then
        btnWorld:getUpPanel().panel_red:setVisible(true);
    else 
        btnWorld:getUpPanel().panel_red:setVisible(false);
    end 

    local openSys = self:getOpenSys();

    if HomeModel:getOpenSysCache() ~= nil then 
        openSys = HomeModel:getOpenSysCache();
    end 
    -- dump(openSys, "-----openSys------");

    for index, v in pairs(openSys) do
        local btnInCtnWidget = self:createSingleBtn(v, index);
        local btnWidget = btnInCtnWidget:getChildByTag(btnTag);

        --给合成单独判断下，它没有model，比较特殊
        if v.sysName == "treasure" then 
            if CombineControl:isHaveCanCombineTreasure() == false and 
                    TreasuresModel:isRedPointShow() == false then  
                btnWidget:getUpPanel().panel_red:setVisible(false);
            else 
                btnWidget:getUpPanel().panel_red:setVisible(true);
            end 
        elseif v.sysName == "Pvp" then
            local isShow = ChallengeModel:checkShowRed();
            btnWidget:getUpPanel().panel_red:setVisible(isShow);
        else 
            if HomeModel:isRedPointShow(v.sysName) == true then 
                btnWidget:getUpPanel().panel_red:setVisible(true);
            else 
                btnWidget:getUpPanel().panel_red:setVisible(false);
            end 
        end 


        table.insert(self._cloneCtns, 
            {widget = btnInCtnWidget, name = v.sysName});

        --hehe 要不加 -btnIndex，点击区域有问题~
        self:addChild(btnInCtnWidget, -index);
    end

    HomeModel:setOpenSysCache(nil)
end

function HomeMainCompoment:getOpenSys()
    local btnOpenSys = {};

    for sysName, v in pairs(HomeMainCompoment.BTN_SYS_NAME_MAP) do
        local isOpen = FuncCommon.isSystemOpen(sysName);
        if isOpen == true then 
            table.insert(btnOpenSys, v);
        end 
    end

    --orderId 从小到大，排序
    function sortFunc(p1, p2)
        if p1.orderId < p2.orderId then 
            return true;
        else 
            return false;
        end 
    end

    table.sort(btnOpenSys, sortFunc);

    return btnOpenSys;
end


function HomeMainCompoment:createSingleBtn(btnInfo, btnIndex)
    local cloneBtn = UIBaseDef:cloneOneView(self[btnInfo.btnName]);

    cloneBtn:getUpPanel().panel_red:setVisible(false);

    cloneBtn:setVisible(true);
    cloneBtn:setPosition(0, 0);

    --绑方法
    cloneBtn:setTouchedFunc(c_func(self._btnFuncs[btnInfo.sysName], self));
    cloneBtn:setTouchSwallowEnabled(true); 

    local cloneCtn = UIBaseDef:cloneOneView(
        self["ctn_" .. tostring(btnIndex)]);
    cloneCtn:addChild(cloneBtn, 1, btnTag);

    return cloneCtn;
end

function HomeMainCompoment:initFunc()
    self._btnFuncs = {
        Pvp = self.clickChallenge,
        guild = self.clickGuild,
        romance = self.clickRomance,
        bag = self.clickBag,
        partner = self.clickPartner,
        god = self.clickGod,
        char = self.clickChar,
        treasure = self.clickTreasure,
        partnerEquipment = self.clickEquipment,
    };
end

function HomeMainCompoment:clickGuild()
    echo("---------clickGuild---------");
    WindowControler:showTips("功能未开启");
end

function HomeMainCompoment:clickGod()
    echo("---------clickGod---------");
   WindowControler:showTips("功能未开启");
--    WindowControler:showWindow("GodView")
    -- WindowControler:showWindow("PartnerEquipView")
    
end

function HomeMainCompoment:clickEquipment()
    echo("---------clickEquipment---------");
    WindowControler:showWindow("PartnerEquipView")
end

function HomeMainCompoment:clickRomance()
    echo("-----romance-------");
    WindowControler:showWindow("EliteView")
end

function HomeMainCompoment:clickChar()
    WindowControler:showWindow("CharMainView");
end

function HomeMainCompoment:clickChallenge()
    echo("-----clickChallenge-----");  
    WindowControler:showWindow("ChallengeView");
end

function HomeMainCompoment:clickTreasure()
    echo("-----clickTreasure-----");
    WindowControler:showWindow("TreasureView");
end

function HomeMainCompoment:clickPartner()
    echo("-----clickPartner-----");
    WindowControler:showWindow("PartnerView");
end

function HomeMainCompoment:clickWorld()
    echo("-----clickWorld-----");
    WindowControler:showWindow("WorldPVEMainView");
end

function HomeMainCompoment:clickBag()
    echo("-----clickBag-----");
    WindowControler:showWindow("ItemListView");
end

return HomeMainCompoment;








