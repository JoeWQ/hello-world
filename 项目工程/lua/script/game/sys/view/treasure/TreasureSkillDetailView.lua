--guan
--2016.3.3
--新神通界面

local TreasureSkillDetailView = class("TreasureSkillDetailView", UIBase);

function TreasureSkillDetailView:ctor(winName, skillId, lvl, treasure)
    TreasureSkillDetailView.super.ctor(self, winName);
    self._skillId = skillId;
    self._lvl = lvl;
    self._treasure = treasure;
end

function TreasureSkillDetailView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function TreasureSkillDetailView:registerEvent()
	TreasureSkillDetailView.super.registerEvent();
end

function TreasureSkillDetailView:initUI()
    local lvl = self._lvl;

    self.panel_des:setVisible(false);
    --图标
    local skillPanel = self.panel_new1;

    skillPanel.ctn_1:removeAllChildren();
    local sprite = FuncTreasure.getSkillSprite(self._skillId, self._lvl);
    skillPanel.ctn_1:addChild(sprite);
    sprite:size(skillPanel.ctn_1.ctnWidth, skillPanel.ctn_1.ctnHeight);

    --特效
    -- 黑色背景
    FuncCommUI.addBlackBg(self._root)
    -- 奖品特效
    FuncCommUI.playSuccessArmature(self.UI_1,FuncCommUI.SUCCESS_TYPE.SKILL,1)
    
    self:setSKillVisible(false);

    rewardAnim:registerFrameEventCallFunc(20, 1, c_func(self.showStapAni, self));
end

function TreasureSkillDetailView:setSKillVisible(isVisible)
    --盖个章
    self.panel_new1.ctn_1:setVisible(isVisible);    
    self.panel_new1.txt_1:setVisible(isVisible);    
    self.panel_new1.mc_st1:setVisible(isVisible);    
    self.panel_new1.panel_bgb:setVisible(isVisible);    
end

function TreasureSkillDetailView:showStapAni(  )
    echo(" showStapAni ");

    local stapAnim = self:createUIArmature("UI_common","UI_common_st",
        self.panel_new1.ctn_ani, false, function ( ... )
            self:setSKillVisible(true);
            self:flyAni();
        end);

    -- local sprite = FuncTreasure.getSkillSprite(self._skillId, self._lvl);
    -- FuncArmature:changeBoneDisplay(stapAnim, "node", sprite);
end

function TreasureSkillDetailView:flyAni()
    --bug here
    local aniPower = self:createUIArmature("UI_common",
        "UI_common_ruchang", self.ctn_flyIn, false, function ( ... )
            self:setTouchedFunc(c_func(self.closeView, self));
        end);

    aniPower:setRotationSkewY(180);

    local changeBone = UIBaseDef:cloneOneView(self.panel_des);

    --名字 
    local name = FuncTreasure.getSkillNameById(self._skillId, lvl);
    changeBone.txt_1:setString(name);

    --描述
    local desStr = FuncTreasure.getSkillDes(self._skillId, lvl);
    changeBone.rich_2:setString(desStr);

    -- if changeBone.rich_2:checkIsOneLine() == true then
    --     changeBone.rich_2:setAlignment(cc.TEXT_ALIGNMENT_CENTER);
    -- else 
    --     changeBone.rich_2:setAlignment(cc.TEXT_ALIGNMENT_LEFT);
    -- end 

    changeBone:setPosition(0, 0);
    changeBone:setVisible(true);
    
    changeBone:setRotationSkewY(180); 

    FuncArmature.changeBoneDisplay(aniPower, "node", changeBone);
    changeBone:setVisible(false);

    self:delayCall( function ( ... )
        changeBone:setVisible(true);
    end)

    FuncArmature.changeBoneDisplay(aniPower, "layer1", display.newNode());
end

function TreasureSkillDetailView:closeView()
    self:startHide();
    if self._treasure:isMaxPower() == true then 
        WindowControler:showWindow("TreasureMaxView", self._treasure);
    end 
end

return TreasureSkillDetailView;











