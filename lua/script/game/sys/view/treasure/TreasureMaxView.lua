--guan
--2016.3.2

local TreasureMaxView = class("TreasureMaxView", UIBase);

--[[
    self.UI_treasure_manji,
    self.panel_1,
    self.panel_2,
    self.panel_3,
    self.rich_1,
    self.txt_1,
]]

function TreasureMaxView:ctor(winName, treasure)
    TreasureMaxView.super.ctor(self, winName);
    self._treasure = treasure;
    self._treasureId = treasure:getId();
    -- FuncArmature.loadOneArmatureTexture("UI_yuanman", nil, true)
end

function TreasureMaxView:loadUIComplete()
    self.panel_5:setVisible(false);
    self.panel_3to:setVisible(false);

	self:registerEvent();
    self:initUI();
end 

function TreasureMaxView:registerEvent()
	TreasureMaxView.super.registerEvent();
    self:setTouchedFunc(c_func(self.startHide, self))

end

function TreasureMaxView:initUI( )
    self.panel_52:setScale(1.2);
    --设置名字
    local name = self._treasure:getName();
    self.panel_3to.txt_3:setString(name);

    local nameLength = string.len(name) / 3;
    -- echo("nameLength " .. tostring(nameLength))
    --没办法，只能写死30;
    local offsetX = 30 * nameLength + 2;
    self.panel_3to.txt_4:setPositionX(
        self.panel_3to.txt_3:getPositionX() + offsetX + 2 );
    -- 奖品特效
    FuncCommUI.playSuccessArmature(self.UI_1,FuncCommUI.SUCCESS_TYPE.FINAL, 1, true);

    FuncCommUI.addBlackBg(self._root);

    local treasureItem = self:createTreasureView();
    local treasureAni = self:createUIArmature("UI_yuanman",
        "UI_yuanman_fabao", self.panel_52.ctn_1, false, GameVars.emptyFunc);

    treasureAni:registerFrameEventCallFunc(15, 1, function ( ... )
            local diAni = self:createUIArmature("UI_yuanman","UI_yuanman_yanwu", 
                self.panel_52.ctn_didi, true);
            diAni:setScale(0.8)
        end);

    treasureAni:registerFrameEventCallFunc(45, 1, function ( ... )
          --echo("guanbiUI+++++++++++++++++++++++++++++++++")
            self:registClickClose()
        end);
    --右法宝
    local rightSubAni = treasureAni:getBoneDisplay("zuofabao");
    --icon
    treasureItem.ctn_icon:setScale(1.4);
    treasureItem.ctn_icon:setPosition(100, -100);

    
    FuncArmature.changeBoneDisplay(rightSubAni, "layer2", treasureItem.ctn_icon);

    --玄天
    treasureItem.mc_zizhi:setPosition(0, 9);
    treasureItem.mc_zizhi:setScale(1);
    FuncArmature.changeBoneDisplay(rightSubAni, "layer4", 
        treasureItem.mc_zizhi);

    treasureItem.mc_di:setPosition(0, 0);
    treasureItem.mc_di:setScale(1);
    FuncArmature.changeBoneDisplay(rightSubAni, "layer3", 
        treasureItem.mc_di); 

    --圆满文字
    self.panel_3to:setPosition(0, 0);
    local yuanmanAni = self:createUIArmature("UI_yuanman",
        "UI_yuanman_zi", self.ctn_str, false, GameVars.emptyFunc);
    FuncArmature.changeBoneDisplay(yuanmanAni, "shentong", self.panel_3to);
    
end

function TreasureMaxView:createTreasureView()
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
    retView.mc_di:showFrame(self._treasure:state());   

    return retView;
end

return TreasureMaxView;


















