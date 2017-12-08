--guan
--2016.3.1
--2016.6.7 继续换
--2016.6.25 优化继续
--边上滚动栏实现 详情 强化 精炼 都一个界面ui，全局变量，进入全局界面换则换


local TreasureDetailView = class("TreasureDetailView", UIBase);

g_TreasureLeftList = nil;
g_TreasureLeftPosY = 0;

function TreasureDetailView:ctor(winName, treasure)
    echo("TreasureDetailView:ctor");
    TreasureDetailView.super.ctor(self, winName);
    self._treasure = treasure;
    self._treasureId = treasure:getId();
    g_TreasureLeftList = nil;
end

function TreasureDetailView:loadUIComplete()

    g_TreasureLeftPosY = self.mc_st1:getCurFrameView().UI_c1.panel_1.panel_ljt:getPositionY();
    self.panel_power.mc_num:visible(false);

	self:registerEvent();
    self:initUIWithoutLeftList();
    self:initLeftListUI();

    --分辨率适配
    FuncCommUI.setViewAlign(self.btn_close, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.ctn_leftAni, UIAlignTypes.Left);

    FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop);

    FuncCommUI.setViewAlign(self.ctn_btnCloseAni, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.ctn_fabaoAni, UIAlignTypes.LeftTop);

    --入场动画动画动画动画动画
    self:showEntryAnim();
end 

function TreasureDetailView:registerEvent()
    TreasureDetailView.super.registerEvent();
    self.btn_close:setTap(c_func(self.press_btn_close, self));

    --升星成功
    EventControler:addEventListener(TreasureEvent.PLUS_STAR_SUCCESS_EVENT,
        self.plueStarSuccess, self);

    --强化成功
    EventControler:addEventListener(TreasureEvent.ENHANCE_SUCCESS_EVENT,
        self.enhanceSuccess, self);

    --精炼成功
    EventControler:addEventListener(TreasureEvent.REFINE_SUCCESS_EVENT,
        self.refineSuccess, self);

    --切换界面
    EventControler:addEventListener(TutorialEvent.TUTORIALEVENT_VIEW_CHANGE, 
        self.onCheckWhenCloseWindow, self);

    --切换界面
    EventControler:addEventListener(TreasureEvent.CHANGE_SELECT, 
        self.onChangeTreasure, self, 1, true);

    EventControler:addEventListener(TreasureEvent.FABAO_SUIPIAN, 
        self.onUpDataTreasureSuipian, self, 1, true);

    --金币增加
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, 
        self.coinChangeCallBack, self);

    --道具变化
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.itemChangeCallBack, self);
    
end

function TreasureDetailView:coinChangeCallBack(event)
    local changeNum = event.params.coinChange;
    -- echo("----changeNum---", changeNum);
    if changeNum > 0 then 
        self:coinOrItemChangeCallBack();
    end 
end

function TreasureDetailView:coinOrItemChangeCallBack()
    --跟新升级部分
    self:initStarFragment();
    --更新法宝强化btn
    self:initBtns();
end

function TreasureDetailView:itemChangeCallBack(event)
    self:coinOrItemChangeCallBack();
end

function TreasureDetailView:onUpDataTreasureSuipian(event)
    local treasures = TreasuresModel:getAllTreasureWithoutKeyAfterSort()
    for i,v in pairs(treasures) do
        if v:getId() == self._treasureId then
            self._treasure = v;
            break
        end
    end
    self:initUIWithoutLeftList();
end

function TreasureDetailView:onChangeTreasure(event)
    self._treasure = event.params.treasure;
    self._treasureId = self._treasure:getId();
    self:initUIWithoutLeftList();
end

--回来后把list放回来
function TreasureDetailView:onCheckWhenCloseWindow(event)
    local winName = event.params.viewName;
    if winName == "TreasureDetailView" then 
        echo("comeback");
        g_TreasureLeftList:parent(self.ctn_leftAni);
    end 
end

function TreasureDetailView:showEntryAnim()
    --要屎了 麻烦屎了 
    local skillAniConfig = {
        ["1"] = {haloHide = {"tu1", "tu2", "tu3", "tu4", "tu5", "tu6"}, 
               iconHide = {"lstb1", "lstb2", "lstb3", "lstb4", "lstb5", "lstb6"},
               beanHide = {"danqing1", "danqing2", "danqing3", "danqing4", "danqing5", "danqing6"},

               changePanel = {UI_c1 = {"lstb7", "danqing7"}},
            },
        ["2"] = {haloHide = {"tu1", "tu2", "tu3", "tu4", "tu7"}, 
               iconHide = {"lstb1", "lstb2", "lstb3", "lstb4", "lstb7"},
               beanHide = {"danqing1", "danqing2", "danqing3", "danqing4", "danqing7"},

               changePanel = {UI_c1 = {"lstb5", "danqing5"}, 
                              UI_c2 = {"lstb6", "danqing6"}, 
                             },
            },
        ["3"] = {haloHide = {"tu1", "tu2", "tu5", "tu6"}, 
               iconHide = {"lstb1", "lstb2", "lstb5", "lstb6"},
               beanHide = {"danqing1", "danqing2", "danqing5", "danqing6"},

               changePanel = {UI_c2 = {"lstb3", "danqing3"}, 
                              UI_c3 = {"lstb4", "danqing4"}, 
                              UI_c1 = {"lstb7", "danqing7"}, 
                             },
            },
        ["4"] = {haloHide = {"tu1", "tu2", "tu7"}, 
               iconHide = {"lstb1", "lstb2", "lstb7"},
               beanHide = {"danqing1", "danqing2", "danqing7"},

               changePanel = {UI_c4 = {"lstb4", "danqing4"}, 
                              UI_c3 = {"lstb3", "danqing3"}, 
                              UI_c1 = {"lstb5", "danqing5"}, 
                              UI_c2 = {"lstb6", "danqing6"}, 
                             },
            },
        ["5"] = {haloHide = {"tu6", "tu5"}, 
               iconHide = {"lstb5", "lstb6"},
               beanHide = {"danqing5", "danqing6"},

               changePanel = {UI_c4 = {"lstb2", "danqing2"}, 
                              UI_c2 = {"lstb3", "danqing3"}, 
                              UI_c1 = {"lstb7", "danqing7"}, 
                              UI_c3 = {"lstb4", "danqing4"}, 
                              UI_c5 = {"lstb1", "danqing1"}, 
                             },
            },
        ["6"] = {haloHide = {"tu7"}, 
               iconHide = {"lstb7"},
               beanHide = {"danqing7"},

               changePanel = {UI_c4 = {"lstb4", "danqing4"}, 
                              UI_c2 = {"lstb6", "danqing6"}, 
                              UI_c1 = {"lstb5", "danqing5"}, 
                              UI_c3 = {"lstb3", "danqing3"}, 
                              UI_c5 = {"lstb2", "danqing2"}, 
                              UI_c6 = {"lstb1", "danqing1"}, 
                             },
            },
    }

    --威能发散动效
    function showSkillFlyAni()
        local skillFlyAni = self:createUIArmature("UI_xiangqing",
            "UI_xiangqing_shengtong", self.ctn_skillFlyAni, false);


        local allSkills = TreasuresModel:getAllSkillByIdAfterSort(self._treasureId);
        local skillCount = table.length(allSkills);
        --{node = {parent = , pox = {x = , y =}}}
        local preNodeInfoTable = {};

        local curConfig = skillAniConfig[tostring(skillCount)];
        for k, v in pairs(curConfig.haloHide) do
            skillFlyAni:getBone(v):setVisible(false);
        end

        for k, v in pairs(curConfig.iconHide) do
            skillFlyAni:getBone(v):setVisible(false);
        end

        for k, v in pairs(curConfig.beanHide) do
            skillFlyAni:getBone(v):setVisible(false);
        end

        for panel, v in pairs(curConfig.changePanel) do
            local icon = self.mc_st1:getCurFrameView()[panel].panel_1;
            preNodeInfoTable[icon] = {parent = icon:getParent(),
                pos = {x = icon:getPositionX(), y = icon:getPositionY()}};
            icon:setPosition(0, 0);
            FuncArmature.changeBoneDisplay(skillFlyAni, v[1], icon);

            local des = self.mc_st1:getCurFrameView()[panel].panel_2;
            preNodeInfoTable[des] = {parent = des:getParent(),
                pos = {x = des:getPositionX(), y = des:getPositionY()}};
            des:setPosition(0, 0);
            FuncArmature.changeBoneDisplay(skillFlyAni, v[2], des);
        end

        skillFlyAni:registerFrameEventCallFunc(35, 1, 
            function ( ... )
                for node, info in pairs(preNodeInfoTable) do
                    FuncArmature.takeNodeFromBoneToParent(node, info.parent);
                    node:setPosition(info.pos.x, info.pos.y);
                    skillFlyAni:setVisible(false);
                end
            end);
    end

    --左边滚动
    local listParent = g_TreasureLeftList:getParent();
    local listX, listY = g_TreasureLeftList:getPosition()
    self._listAni = self:createUIArmature("UI_xiangqing","UI_xiangqing_zuoliebiao", self.ctn_leftAni, 
        false, GameVars.emptyFunc);
    g_TreasureLeftList:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(self._listAni, "a", g_TreasureLeftList);

    g_listBackFunc = function ( ... )
        echo("--g_listBackFunc--g_listBackFunc--");
        if self._listAni ~= nil then 
            FuncArmature.takeNodeFromBoneToParent(g_TreasureLeftList, listParent);
            g_TreasureLeftList:setPosition(listX, listY);
            self:resumeUIClick();
            self._listAni = nil;
        end 
    end

    self._listAni:doByLastFrame(true, true, g_listBackFunc)

    --星星动画
    local starAni = self:createUIArmature("UI_xiangqing","UI_xiangqing_xing", self.ctn_starAni, 
        false, GameVars.emptyFunc);
    self.panel_star:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(starAni, "xing", self.panel_star);

    --威能动画
    showSkillFlyAni();

    --法宝icon动画
    local iconParent = self.ctn_1:getParent();
    local iconX, iconY = self.ctn_1:getPosition()
    local iconAni = self:createUIArmature("UI_xiangqing","UI_xiangqing_fabao", self.ctn_iconAni, 
        false, GameVars.emptyFunc);
    self.ctn_1:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(iconAni, "node1", self.ctn_1);
    self.ctn_2:setVisible(false);

    iconAni:doByLastFrame(true, true, function ( ... )
        FuncArmature.takeNodeFromBoneToParent(self.ctn_1, iconParent);
        self.ctn_1:setPosition(iconX, iconY);
    end)
    
    local growAni = self:createUIArmature("UI_fabao_common","UI_fabao_common_liuguang", 
    self.ctn_iconAni, true);
    self.ctn_2:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(growAni, "layer4", self.ctn_2);
    -- self.ctn_2:setVisible(false);
    self.ctn_iconAni:zorder(6);
    self._growAni = growAni;

    --蓝粒子
    self:createUIArmature("UI_fabao_common", "UI_fabao_common_ssyw", self.ctn_iconAni, true);

    --底座
    local potAni = self:createUIArmature("UI_xiangqing","UI_xiangqing_dituo", self.ctn_potAni, 
        false, GameVars.emptyFunc);
    self.mc_3:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(potAni, "node2", self.mc_3);

    --品级
    local lvlAni = self:createUIArmature("UI_xiangqing","UI_xiangqing_pingji", self.ctn_lvlAni, 
        false, GameVars.emptyFunc);
    self.mc_2:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(lvlAni, "node3", self.mc_2);
    self.ctn_lvlAni:zorder(9)

    local powerPreX, powerPreY = self.panel_power:getPosition();
    local preParent = self.panel_power:getParent();
    --威力
    local powerAni = self:createUIArmature("UI_xiangqing","UI_xiangqing_weili", self.ctn_powerAni, 
        false, function ( ... )
            FuncArmature.takeNodeFromBoneToParent(self.panel_power, preParent);
            self.panel_power:setPosition(powerPreX, powerPreY);
        end);
    self.panel_power:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(powerAni, "youweili", self.panel_power);

    self.panel_d5:setVisible(false);

    local btnAni = self:createUIArmature("UI_common","UI_common_btn2", self.ctn_btnAni, 
        false, GameVars.emptyFunc);
    self.panel_d5:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(btnAni, "qhfb", self.panel_d5);

    --上面closebtn动画
    self._closeAni = self:createUIArmature("UI_common","UI_common_zuozi", self.ctn_btnCloseAni, 
        false, function ( ... )
            self.btn_close:setVisible(true);
            self._closeAni:setVisible(false);
        end);

    -- self.btn_close:setVisible(false);
    -- self.btn_close:setPosition(0, 0);

    --换不了了，why？？？ 空 node 都不行 todo fixme 
    FuncArmature.changeBoneDisplay(self._closeAni, "youfanhui", display.newNode(), false, GameVars.emptyFunc);  

    --上面中间标题的动画
    local titleAni = self:createUIArmature("UI_common","UI_common_biaotiluoxia", self.ctn_tittleAni, 
        false, GameVars.emptyFunc);
    self.panel_topInfo:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(titleAni, "biaoti", self.panel_topInfo);

    --上面右边标题的动画
    local rightAni = self:createUIArmature("UI_common","UI_common_youzi", self.ctn_fabaoAni, 
        false, GameVars.emptyFunc);
    self.panel_title:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(rightAni, "zuozi", self.panel_title); 


    self:createUIArmature("UI_fabao_common","UI_fabao_common_beijing", 
            self.ctn_bg, true);
end

function TreasureDetailView:initUIWithoutLeftList()
    self:setPower(false);
    self:initTreasureInfo();
    self:initStarFragment();
    self:initBtns();
    self:initSkill();
    self:initStar();

    FuncCommUI.regesitShowPowerTipView(self.panel_power, self._treasureId);
end

--[[
    初始化左边的list
]]
function TreasureDetailView:initLeftListUI()
    g_TreasureLeftList = WindowsTools:createWindow(
            "TreasureLeftListCompoment", self._treasure);

    g_TreasureLeftList._root:retain();

    self.ctn_leftAni:addChild(g_TreasureLeftList);
end

function TreasureDetailView:refineSuccess()
    echo("--TreasureDetailView:refineSuccess--");

    self:initUIWithoutLeftList();
    --音效在精炼成功界面播放
end

function TreasureDetailView:enhanceSuccess()
    echo("--TreasureDetailView:enhanceSuccess--");
    self:setPower(false);
    self:initBtns();

    self.panel_topInfo.txt_3:setString(
        self._treasure:level() .. tostring("级"));

    if self._treasure:isCurStageMaxLvl() == true then 
        self:initBtns();
        self:initSkill();
    end 

    AudioModel:playSound("s_treasure_qianghuaOK");

end

function TreasureDetailView:plueStarSuccess()
    echo("--TreasureDetailView:plueStarSuccess--");

    self:disabledUIClick();

    self:initStarFragment();
    self:initTreasureInfo();

    --隐藏升星按钮
    self.panel_star.panel_jindu.mc_shengxing:setVisible(false)
    self.panel_star.ctn_6:setVisible(false);

    local starNum = self._treasure:star();
    local ctn = self["ctn_texiao" .. tostring(starNum)];

    function callBakFunc()
        self:initStar();
        self:setPower(true);
        self._huijuAni:setVisible(false);
        --底部发光
        self:createUIArmature("UI_fabao_common","UI_fabao_common_bagua", 
            self.ctn_dipan, false);
    end

    self.panel_star:zorder(101);
    self.ctn_starAni:zorder(101);

    local starNum = self._treasure:star();
    local ctn = self.panel_star["ctn_texiao" .. tostring(starNum)];
    ctn:removeAllChildren();

    --汇聚发射
    self._huijuAni = self:createUIArmature("UI_shengxing","UI_shengxing_huiju", 
        ctn, false, callBakFunc);

    --星星光
    local starAni = self:createUIArmature("UI_shengxing","UI_shengxing_xingxing", 
        ctn, false, GameVars.emptyFunc);

    starAni:doByLastFrame(false, true, function ( ... )
            self:resumeUIClick();
        end);

    --能量条
    self:createUIArmature("UI_shengxing","UI_shengxing_nengliangtiao", 
        self.panel_star.panel_jindu.ctn_tiao, false);

    local id = self._treasure:getId();
    local iconPath = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, id);
    local spriteTreasureIcon = display.newSprite(iconPath); 
    local spriteTreasureIcon2 = display.newSprite(iconPath); 

    local fabaoAni = self:createUIArmature("UI_shengxing","UI_shengxing_fabaozhuangtai", 
        self.ctn_iconAni, false);

    spriteTreasureIcon:setPosition(0, 0)
    spriteTreasureIcon2:setPosition(0, 0)
    FuncArmature.changeBoneDisplay(fabaoAni, "node3", spriteTreasureIcon); 
    FuncArmature.changeBoneDisplay(fabaoAni, "node4", spriteTreasureIcon2); 


    AudioModel:playSound("s_treasure_shengxingOK");
end

function TreasureDetailView:initBtns()
    --精炼强化btn
    if self._treasure:isMaxPower() == true then 
        self.panel_d5.mc_xqbtn:showFrame(3);
        self.panel_d5.panel_red:setVisible(false);
    elseif self._treasure:isCurStageMaxLvl() == true then   
        --进入精炼界面
        if self._treasure:canRefine() == true then 
            self.panel_d5.panel_red:setVisible(true);
        else 
            self.panel_d5.panel_red:setVisible(false);
        end 
        --注册事件
        self.panel_d5.mc_xqbtn:showFrame(2);
        self.panel_d5.mc_xqbtn:getCurFrameView().btn_1:setTap(
            c_func(self.reFineClick, self));
    else 
        --进入强化界面
        if self._treasure:canEnhance() == true then 
            self.panel_d5.panel_red:setVisible(true);
        else 
            self.panel_d5.panel_red:setVisible(false);
        end 

        --注册事件
        self.panel_d5.mc_xqbtn:showFrame(1);
        self.panel_d5.mc_xqbtn:getCurFrameView().btn_1:setTap(
            c_func(self.enhanceClick, self));
    end 
end

function TreasureDetailView:reFineClick()
    echo("reFineClick");
    if self._listAni ~= nil then 
        local listParent = g_TreasureLeftList:getParent();
        local listX, listY = g_TreasureLeftList:getPosition()
        FuncArmature.takeNodeFromBoneToParent(g_TreasureLeftList, listParent);
        g_TreasureLeftList:setPosition(listX, listY);
        self._listAni = nil ;
        
    end 

    WindowControler:showWindow("TreasureReFineView", 
        self._treasure, true, self);
end

function TreasureDetailView:enhanceClick()
    echo("enhanceClick");
    if self._listAni ~= nil then 
        local listParent = g_TreasureLeftList:getParent();
        local listX, listY = g_TreasureLeftList:getPosition()
        FuncArmature.takeNodeFromBoneToParent(g_TreasureLeftList, listParent);
        g_TreasureLeftList:setPosition(listX, listY);
        self._listAni = nil ;
    end 

    WindowControler:showWindow("TreasureEnhanceView", 
        self._treasure, true, self);
end

function TreasureDetailView:searchForFragmentClick()
    echo("searchForFragmentClick");
    WindowControler:showWindow("GetWayListView", self._treasure:getId());
end

--
function TreasureDetailView:upStarClick()
    echo("upStarClick");
    WindowControler:showWindow("TreasurePlusStarView", self._treasure);
end

function TreasureDetailView:setPowerNum(nums)
    local len = table.length(nums);
    self.panel_power.mc_shuzi:showFrame(len);

    for k, v in pairs(nums) do
        local mcs = self.panel_power.mc_shuzi:getCurFrameView();
        mcs["mc_" .. tostring(k)]:showFrame(v + 1);
    end
end

--设置威能 isWithAnimation 是否动画跳过去
function TreasureDetailView:setPower(isWithAnimation)
    local power = self._treasure:getPower();
    local powerValueTable = number.split(power);

    if isWithAnimation ~= true then 
        self:setPowerNum(powerValueTable);
    else 
        TreasureUICommon.setPowerWithAni(self);
    end 

    self._beforePowerNum = power;
end

--顶上的 panel info 名字 等级 描述
function TreasureDetailView:initTopInfo()
    local id = self._treasure:getId();
    --todo change me
    self.panel_topInfo.txt_3:setString(
        self._treasure:level() .. tostring("级"));

    --作用描述
    self.panel_topInfo.mc_dingwei:showFrame(2);
    local label3 = self.panel_topInfo.mc_dingwei:getCurFrameView().txt_1;
    label3:setString(FuncTreasure.getLabel3(id));

    --名字
    local name = self._treasure:getName();
    self.panel_topInfo.txt_1:setString(name);

    --前中后
    local posIndex = self._treasure:getPosIndex();
    self.panel_topInfo.mc_1:showFrame(posIndex);

end

function TreasureDetailView:initTreasureInfo()
    self:initTopInfo();
    local id = self._treasure:getId();

    local state = self._treasure:state();
    self.mc_3:showFrame(state);

    --todo 法宝图标
    local iconPath = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, id);
    local spriteTreasureIcon = display.newSprite(iconPath); 
    local spriteTreasureIcon2 = display.newSprite(iconPath); 

    self.ctn_1:removeAllChildren();
    spriteTreasureIcon:size(self.ctn_1.ctnWidth, 
        self.ctn_1.ctnHeight);
    self.ctn_1:addChild(spriteTreasureIcon);

    self.ctn_2:removeAllChildren();
    spriteTreasureIcon2:size(self.ctn_2.ctnWidth, 
        self.ctn_2.ctnHeight);
    self.ctn_2:addChild(spriteTreasureIcon2);

    --什么品
    local quality = FuncTreasure.getValueByKeyTD(self._treasureId, "quality");
    if quality >= 6 then 
        quality = 5;
    end 
    self.mc_2:showFrame(quality);
    self.mc_2:setVisible(true);

    self.ctn_1:setTouchedFunc(c_func(self.showTreasureInfo, self));

    --圆满光环
    self.ctn_yuanman:removeAllChildren();
    if self._treasure:isMaxPower() == true then 
        self:createUIArmature("UI_yuanman","UI_yuanman_yanwu", self.ctn_yuanman, true);
        self.panel_yuanman:setVisible(true);
        --hehe
        self.panel_yuanman:zorder(999);
    else 
        self.panel_yuanman:setVisible(false);
    end 
end

function TreasureDetailView:showTreasureInfo()
    AudioModel:playSound("s_com_click1")
    WindowControler:showWindow("TreasureInfoView", self._treasureId);
end

function TreasureDetailView:initStar()
    --星级
    local star = self._treasure:star();

    for i = 1, 5 do
        local mc = self.panel_star["mc_bigxing" .. tostring(i)];
        if star >= i then 
            mc:showFrame(2);
        else 
            mc:showFrame(1);
        end 
    end
end

function TreasureDetailView:setProgressEmpty()
    self.panel_star.panel_jindu.mc_man:getCurFrameView().txt_1:setVisible(false);
    self.panel_star.panel_jindu.progress_1:stopTween();
    self.panel_star.panel_jindu.progress_1:setPercent(0);
end

function TreasureDetailView:initStarFragment()
    local progressBar = self.panel_star.panel_jindu.progress_1;
    local needFragment = self._treasure:getUpStarNeedFragment();
    local haveFragment = ItemsModel:getItemNumById(self._treasureId);

    function initBarArmature()
        if  needFragment <= haveFragment then 
            --充能动画
            self.panel_star.panel_jindu.ctn_tiao:removeAllChildren();
            self:createUIArmature("UI_common","UI_common_ jingyantiao", self.panel_star.panel_jindu.ctn_tiao, true);
        else 
            self.panel_star.panel_jindu.ctn_tiao:removeAllChildren();
        end 
    end

    --删除升星特效
    self.panel_star.ctn_6:removeAllChildren();

    if self._treasure:isMaxStar() == true then
        self.panel_star.panel_jindu:setVisible(false);
        self.panel_star.ctn_6:setVisible(false);
    else
        self.panel_star.ctn_6:setVisible(true);
        self.panel_star.panel_jindu:setVisible(true);
        self.panel_star.panel_jindu.mc_shengxing:setVisible(true);

        --可以升星
        if needFragment <= haveFragment then 
            self.panel_star.panel_jindu.mc_shengxing:showFrame(2);
            --事件
            self.panel_star.panel_jindu.mc_shengxing:getCurFrameView():setTouchedFunc(
                c_func(self.upStarClick, self));

            --钱够不够
            if self._treasure:isCoinEnoughToUpStar() == true then 
                self.panel_star.panel_jindu.mc_shengxing:getCurFrameView().panel_red:setVisible(true);
            else 
                self.panel_star.panel_jindu.mc_shengxing:getCurFrameView().panel_red:setVisible(false);
            end 
        else 
            self.panel_star.panel_jindu.mc_shengxing:showFrame(1);
            self.panel_star.panel_jindu.mc_shengxing:getCurFrameView():setTouchedFunc(
                c_func(self.searchForFragmentClick, self));
        end 
        
        progressBar:setPercent((haveFragment / needFragment) * 100);
        initBarArmature();
        
        --数量
        self.panel_star.panel_jindu.mc_man:showFrame(1);
        local txtLabel = self.panel_star.panel_jindu.mc_man:getCurFrameView().txt_1;
        txtLabel:setString(tostring(haveFragment) .. "/" .. tostring(needFragment));
    end

end

--异能
function TreasureDetailView:initSkill()
    local allSkills = TreasuresModel:getAllSkillByIdAfterSort(self._treasureId);

    if table.length(allSkills) ~= 0 then 
        self.mc_st1:setVisible(true);
        self.mc_st1:showFrame(table.length(allSkills));
    else 
        self.mc_st1:setVisible(false);
    end 

    local i = 1;
    for _, value in pairs(allSkills) do
        local id = value.id;
        local maxLvl = value.level;

        local stonePanel = self.mc_st1:getCurFrameView()["UI_c" .. tostring(i)];
        --icon
        local lvl = self._treasure:getSkillLvl(id);
        if lvl == 0 then 
            stonePanel.panel_1.panel_suo:setVisible(true)
        else 
            stonePanel.panel_1.panel_suo:setVisible(false)
        end 
        stonePanel.panel_1.ctn_1:removeAllChildren();
        local sprite = FuncTreasure.getSkillSprite(id, lvl);
        stonePanel.panel_1.ctn_1:addChild(sprite);
        sprite:size(stonePanel.panel_1.ctn_1.ctnWidth, 
            stonePanel.panel_1.ctn_1.ctnHeight);  

        FuncCommUI.regesitShowSkillTipView( stonePanel.panel_1,
            {skillId = id, level = lvl, treasure = self._treasure});

        if self._treasure:isSkillActive(id) == false then 
            --置灰
            FilterTools.setGrayFilter(sprite);
        else 
            FilterTools.clearFilter(sprite);
        end  
        local maxFrame = stonePanel.panel_2.mc_st1:getTotalFrameNum();
        stonePanel.panel_2.mc_st1:showFrame(maxLvl);

        stonePanel.panel_1.panel_ljt:setVisible(false)

        stonePanel.panel_1.panel_ljt:setPositionY(g_TreasureLeftPosY);

        for j = 1, maxLvl do
            local ctn = stonePanel.panel_2.mc_st1:getCurFrameView()["ctn_" .. tostring(j)];
            ctn:removeAllChildren();

            if lvl >= j then --绿豆
                stonePanel.panel_2.mc_st1:getCurFrameView()["mc_" .. tostring(j)]:showFrame(1);
                self:createUIArmature("UI_xiangqing","UI_xiangqing_shentongliuguang", ctn, true);
            elseif self._treasure:isShowEnhanceArrow(id) == true and (j == (lvl + 1)) then 
                stonePanel.panel_2.mc_st1:getCurFrameView()["mc_" .. tostring(j)]:showFrame(2);
                stonePanel.panel_1.panel_ljt:setVisible(true)

                -- local moveUpAction = cc.MoveBy:create(0.3, cc.p(0, 10));
                -- local moveDownAction = cc.MoveBy:create(0.3, cc.p(0, -10));

                -- local sequenceAction = cc.Sequence:create(moveUpAction, moveDownAction);
                -- stonePanel.panel_1.panel_ljt:runAction(cc.RepeatForever:create(sequenceAction));

            else 
                stonePanel.panel_2.mc_st1:getCurFrameView()["mc_" .. tostring(j)]:showFrame(3);
            end 
        end
        i = i + 1;

        --名字
        local nameStr = FuncTreasure.getSkillNameById(id, 1);
        local nameLabel = stonePanel.panel_2.txt_1:setString(nameStr);
    end

end

function TreasureDetailView:press_btn_close()
    echo("press_btn_close");
    self:startHide()
end

function TreasureDetailView:setStarEmpty()
    for i = 1, 5 do
        local mc = self.panel_star["mc_bigxing" .. tostring(i)];
        mc:showFrame(1);
    end
end

--关闭界面传参数 坑啊，当年周鹏程让传的参数
function TreasureDetailView:onHideCompData()
    return {treasureLvl = self._treasure:state() - 1};
end

function TreasureDetailView:setTreasure(treasure)
    self._treasure = treasure;
    self._treasureId = treasure:getId();
end

function TreasureDetailView:deleteMe()
    g_TreasureLeftList._root:release();

    TreasureDetailView.super.deleteMe(self);
end

return TreasureDetailView;






