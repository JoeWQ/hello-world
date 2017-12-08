--guan
--2016.12.26
--第三版主角升级界面

local CharLevelUpView = class("CharLevelUpView", UIBase);

function CharLevelUpView:ctor(winName, lvl,isInBattle)
    CharLevelUpView.super.ctor(self, winName);
    -- 升到的新等级
    self.newLevel = lvl;
    self.isInBattle = isInBattle
end

function CharLevelUpView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function CharLevelUpView:registerEvent()
	CharLevelUpView.super.registerEvent();
end

function CharLevelUpView:initUI()
    self:disabledUIClick();

    self.panel_txt:setVisible(false);
    self.txt_bai:setVisible(false);
    self.txt_lv:setVisible(false);
    self.txt_bai:setVisible(false);
    self.panel_aniTxt:setVisible(false);
    self.txt_jixu:setVisible(false);

    self:initOpenSystemUI();
    self:showArmature(); 

    AudioModel:playSound(MusicConfig.s_com_lvl_up);

end

--升级后要显示的ui
function CharLevelUpView:initOpenSystemUI()
    self._desPanel = UIBaseDef:cloneOneView(self.panel_txt);
    self._aniPanel = UIBaseDef:cloneOneView(self.panel_aniTxt);
    self._sysIcon = nil;

    if UserModel:isNewSystemOpenByLevel( self.newLevel ) == true then 

        local sysNameTid = FuncChar.getCharLevelUpValueByLv(
            self.newLevel, "name");
        local sysNameStr = GameConfig.getLanguage(sysNameTid);
        self._aniPanel.txt_1:setString(sysNameStr);


        local openSysName = FuncChar.getCharLevelUpValueByLv(
            self.newLevel, "sysNameKey");
        local tidDesName = FuncCommon.getSysOpensysname(openSysName);
        local desNameStr = GameConfig.getLanguage(tidDesName);
        self._desPanel.txt_name:setString(desNameStr);

        local mainDesTid = FuncCommon.getSysOpenContent(openSysName);
        local mainDesStr = GameConfig.getLanguage(mainDesTid);
        self._desPanel.txt_miao:setString(mainDesStr);

        local spPath = FuncRes.iconSys(openSysName);
        self._sysIcon = display.newSprite(spPath);

        self._openSysName = openSysName;

    end 

    --升级前最大的体力
    local preMaxSp = UserModel:getMaxSpLimitByLevel(self.newLevel - 1);
    self._preMaxString = UIBaseDef:cloneOneView(self.txt_bai);
    self._preMaxString:setString(preMaxSp);

    --升级后最大体力
    local curMaxSp = UserModel:getMaxSpLimitByLevel(self.newLevel);
    self._curMaxString = UIBaseDef:cloneOneView(self.txt_lv);
    self._curMaxString:setString(curMaxSp);

    --升级后等级  
    self._curLvl = UIBaseDef:cloneOneView(self.txt_lv);
    self._curLvl:setString(self.newLevel);

    --升级前等级
    self._preLvl = UIBaseDef:cloneOneView(self.txt_bai);
    self._preLvl:setString(self.newLevel - 1);

    --升级后的体力 
    local curSp = UserExtModel:sp();
    self._curSp = UIBaseDef:cloneOneView(self.txt_lv);
    self._curSp:setString(curSp);

    --升级前的体力
    local spAdd = FuncChar.getCharLevelValueByLv(self.newLevel - 1, "lvUpAddSp");
    preSp = curSp - spAdd;
    self._preSp = UIBaseDef:cloneOneView(self.txt_bai);
    self._preSp:setString(preSp);

end

function CharLevelUpView:showArmature()
    FuncCommUI.addBlackBg(self._root);


    local mainAni = nil;
    if UserModel:isNewSystemOpenByLevel( self.newLevel ) == true then 
        mainAni = self:createUIArmature("UI_zhujueshengji", "UI_zhujueshengji_shengji_b", self.ctn_ani, 
            false, GameVars.emptyFunc);

        --开启信息
        local openAni = mainAni:getBoneDisplay("layer6");
        openAni:playWithIndex(0, 0); 
        openAni:getBoneDisplay("a1"):playWithIndex(0, 0);
        openAni:getBoneDisplay("a4"):playWithIndex(0, 0);
        openAni:getBoneDisplay("a5"):playWithIndex(0, 0);
        self._aniPanel:setPosition(0, 0);
        FuncArmature.changeBoneDisplay(openAni, "a4", self._aniPanel); 
        self._desPanel:setPosition(0, 0);
        FuncArmature.changeBoneDisplay(openAni, "a1", self._desPanel); 
        local a5 = openAni:getBoneDisplay("a5");
        self._sysIcon:setPosition(0, 0);
        self._sysIcon:setScale(0.5);
        FuncArmature.changeBoneDisplay(a5, "layer5", self._sysIcon); 

    else 
        mainAni = self:createUIArmature("UI_zhujueshengji", "UI_zhujueshengji_shengji_a", self.ctn_ani, 
            false, GameVars.emptyFunc);        
    end 

    --升级啦
    local lvUpAni = mainAni:getBoneDisplay("sjl");
    lvUpAni:playWithIndex(0, 0); 

    --猪脚小人   
    local charAni = mainAni:getBoneDisplay("zj");
    charAni:playWithIndex(0, 0);  

    local charPath = FuncRes.iconChar(tonumber( UserModel:sex() ));

    local charSp = display.newSprite(charPath);
    charSp:setPosition(0, 0);

    local p1 = charAni:getBoneDisplay("zhujue");
    FuncArmature.changeBoneDisplay(p1, "layer1", charSp); 


    --各种等级体力信息
    local baseInfoAni = mainAni:getBoneDisplay("zaa");
    baseInfoAni:playWithIndex(0, 0);

    local posY = 16;
    --之前的猪脚等级
    self._preLvl:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(baseInfoAni, "node1", self._preLvl); 
    --现在猪脚等级
    self._curLvl:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(baseInfoAni, "node2", self._curLvl); 
    --之前的体力上限
    self._preMaxString:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(baseInfoAni, "node3", self._preMaxString); 
    --现在的体力上限
    self._curMaxString:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(baseInfoAni, "node4", self._curMaxString); 
    --之前的体力
    self._preSp:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(baseInfoAni, "node5", self._preSp); 
    --之后的体力
    self._curSp:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(baseInfoAni, "node6", self._curSp); 

    
    --45帧的时候
    mainAni:registerFrameEventCallFunc(50, 1, function ( ... )
        self:aniOver();
    end);

end

function CharLevelUpView:aniOver()
    self:resumeUIClick();
    self.txt_jixu:setVisible(true);

    self:setTouchedFunc(c_func(self.closeFunc, self));

    if UserModel:isNewSystemOpenByLevel(self.newLevel) == true then
        --发事件
        local guideId = FuncChar.getCharLevelUpValueByLv(
            self.newLevel, "guideId");
        local sysName = FuncChar.getCharLevelUpValueByLv(
            self.newLevel, "sysNameKey");
        
        if guideId ~= nil then 
            -- EventControler:dispatchEvent(TutorialEvent.TUTORIALEVENT_SYSTEM_OPEN, 
            --     {id = guideId, sysName = sysName});
        end 
    end 
end

function CharLevelUpView:closeFunc()
    
    if self.isInBattle then
        echo("发送消息---------------------------------关闭")
        self:startHide();
        FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
    else
          self:startHide();
         if UserModel:isNewSystemOpenByLevel(self.newLevel) == true then
            local sysNameKey = FuncChar.getCharLevelUpValueByLv(
                self.newLevel, "sysNameKey");
            
            EventControler:dispatchEvent(
                HomeEvent.SYSTEM_OPEN_EVENT, {sysNameKey = self._openSysName});
            WindowControler:goBackToHomeView()

        end 
    end
    
    -- if UserModel:isNewSystemOpenByLevel(self.newLevel) == true then
    --     local sysNameKey = FuncChar.getCharLevelUpValueByLv(
    --         self.newLevel, "sysNameKey");
        
    --     EventControler:dispatchEvent(
    --         HomeEvent.SYSTEM_OPEN_EVENT, {sysNameKey = self._openSysName});
    --     WindowControler:goBackToHomeView()

    -- end 

end

return CharLevelUpView;



















