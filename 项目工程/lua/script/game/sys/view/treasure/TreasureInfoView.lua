--guan
--2016.3

local TreasureInfoView = class("TreasureInfoView", UIBase);


function TreasureInfoView:ctor(winName, treasureId)
    echo("---treasureId--", treasureId);
    TreasureInfoView.super.ctor(self, winName);
    self._treasureId = treasureId
end

function TreasureInfoView:loadUIComplete()
	self:registerEvent();
	self:initUI();
end 

function TreasureInfoView:registerEvent()
	TreasureInfoView.super.registerEvent();
    self.btn_1:setTouchedFunc(c_func(self.closeView, self));
    self:registClickClose("out", c_func(self.closeView, self));
end

function TreasureInfoView:closeView()
    FuncChar.deleteCharOnTreasure(self._showView);
    self:startHide();
end

function TreasureInfoView:initUI()
    --文本描述
    self:initTexts();
    self:initShowAction();

    --法宝图标
    local iconPath = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, 
        self._treasureId);
    local spriteTreasureIcon = display.newSprite(iconPath);
    self.ctn_1:addChild(spriteTreasureIcon);
    spriteTreasureIcon:setScale(2);

    spriteTreasureIcon:setColor(cc.c3b(255, 204, 148));

    spriteTreasureIcon:setOpacity(22.5)
end
 
function TreasureInfoView:initTexts()
    self.txt_name:setString(FuncTreasure.getName(self._treasureId));

    local desStr = FuncTreasure.getTreasureDes(self._treasureId);
    self.panel_txts.txt_1:setString(desStr); 
    
    local quality = FuncTreasure.getValueByKeyTD(self._treasureId, "quality")
    echo("--quality--", quality);
    local qualityStr = FuncTreasure.getQualityName(quality);

    echo("--qualityStr--", qualityStr);
    self.panel_txts.txt_2:setString(qualityStr);

    local levelMaxStr = FuncTreasure.getTreasureMaxLvl(self._treasureId);

    --todo fix hehe
    self.panel_txts.txt_3:setString("可强化至" .. tostring(levelMaxStr) .. "级");

    local label3Str = FuncTreasure.getLabel3(self._treasureId);
    self.panel_txts.txt_4:setString(label3Str);

    local battleDesStr = FuncTreasure.getUseDes(self._treasureId);
    self.panel_txts.txt_5:setString(battleDesStr);

    local nextId = FuncTreasure.getValueByKeyTD(self._treasureId, "combine");
    if nextId == nil then 
        self.panel_txts.txt_7:setVisible(false);
        self.panel_txts.txt_6:setVisible(false);
    else 
        self.panel_txts.txt_7:setString(FuncTreasure.getName(nextId));
        self.panel_txts.txt_6:setVisible(true);

    end 
end

function TreasureInfoView:initShowAction()
    function touchEndCallBack()
        FuncChar.playNextAction(self._actionView);
    end

    local avatar = UserModel:avatar();
    local level = UserModel:level();

    local view = FuncChar.getCharOnTreasure(tostring(avatar), 
        level, tostring(self._treasureId),true);
    view:addto(self.ctn_npc);
    view:setPositionY(view:getPositionY() - 100);
    -- view:setPosition(480, 50)
    self._actionView = view;
    self._showView = view;

    self._showView:setScale(1.5);

    --为了上来就播攻击，来了个playNextAction…… cuiweibo的主意……
    FuncChar.playNextAction(self._actionView);

    self:setTouchedFunc(touchEndCallBack);
end

return TreasureInfoView;










