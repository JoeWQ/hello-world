--guan
--2016.3.2

local TreasurePlusStarView = class("TreasurePlusStarView", UIBase);

--[[
    self.UI_1,
    self.UI_2,
    self.UI_treasure_shengxing,
    self.mc_xing,
    self.txt_1,
    self.txt_2,
    self.txt_3,
]]

function TreasurePlusStarView:ctor(winName, treasure)
    TreasurePlusStarView.super.ctor(self, winName);
    self._treasure = treasure;
    self._treasureId = treasure:getId();
end

function TreasurePlusStarView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function TreasurePlusStarView:registerEvent()
	TreasurePlusStarView.super.registerEvent();
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.confirmClick, self));
    self.UI_1.btn_close:setTap(c_func(self.startHide, self));

    self:registClickClose("out");

    --金币增加
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, 
        self.coinChangeCallBack, self);
end

function TreasurePlusStarView:coinChangeCallBack(event)
    local changeNum = event.params.coinChange;
    -- echo("----changeNum---", changeNum);
    if changeNum > 0 then 
        self:initUI();
    end 
end

function TreasurePlusStarView:initUI()
    --法宝属性
    self:setTreasureInfo();

    --消耗
    local coinNeed = self._treasure:getUpStarCoinCost();
    self.txt_6:setString(coinNeed);

    local haveCoin = UserModel:getCoin();
    if coinNeed > haveCoin then 
        self.txt_6:setColor(cc.c3b(255, 0, 0));
    else 
        self.txt_6:setColor(cc.c3b(92, 55, 23)); --5c3717
    end 
    --标题描述
    self.UI_1.txt_1:setString(GameConfig.getLanguage("treasure_upStar"));

    --btn描述
    self.UI_1.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("treasure_upStar"));

    --增加威能
    local curPower = self._treasure:getPower();

    local nextPower = TreasuresModel:getPower(self._treasureId, 
        self._treasure:level(), self._treasure:star() + 1, self._treasure:state());
    self.txt_2:setString("战力:" .. tostring( curPower) );
    self.txt_1:setString("战力:" .. tostring( curPower));

    self.txt_3:setString(nextPower - curPower);
end

function TreasurePlusStarView:setTreasureInfo()
    --星级
    local starNum = self._treasure:star();
    self.mc_xing:showFrame(starNum);

    --前后
    local posIndex = self._treasure:getPosIndex();
    self.UI_2.mc_biaoqian:showFrame(posIndex);
 

    -- todo 法宝图标
    local iconPath = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, self._treasureId);
    local spriteTreasureIcon = display.newSprite(iconPath); 
    self.UI_2.ctn_icon:removeAllChildren();
    self.UI_2.ctn_icon:addChild(spriteTreasureIcon);
    spriteTreasureIcon:size(self.UI_2.ctn_icon.ctnWidth, 
        self.UI_2.ctn_icon.ctnHeight);

    --底盘
    self.UI_2.mc_di:showFrame(self._treasure:state());

    --什么品
    local quality = FuncTreasure.getValueByKeyTD(self._treasureId, "quality");
    if quality >= 6 then 
        quality = 5;
    end 
    self.UI_2.mc_zizhi:showFrame(quality);

    self:initRightTreasure();

    self:createUIArmature("UI_common","UI_common_lvjiantou", self.ctn_2, true);
end

function TreasurePlusStarView:initRightTreasure()
    --星级
    local starNum = self._treasure:star();
    self.mc_xing2:showFrame(starNum + 1);

    --前后
    local posIndex = self._treasure:getPosIndex();
    self.UI_3.mc_biaoqian:showFrame(posIndex);

    -- todo 法宝图标
    local iconPath = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, self._treasureId);
    local spriteTreasureIcon = display.newSprite(iconPath); 
    self.UI_3.ctn_icon:removeAllChildren();
    self.UI_3.ctn_icon:addChild(spriteTreasureIcon);
    spriteTreasureIcon:size(self.UI_3.ctn_icon.ctnWidth, 
        self.UI_3.ctn_icon.ctnHeight);

    --底盘
    self.UI_3.mc_di:showFrame(self._treasure:state());

    --什么品
    local quality = FuncTreasure.getValueByKeyTD(self._treasureId, "quality");
    if quality >= 6 then 
        quality = 5;
    end 
    self.UI_3.mc_zizhi:showFrame(quality);
end

function TreasurePlusStarView:confirmClick()

    --消耗
    local coinNeed = self._treasure:getUpStarCoinCost();
    local haveCoin = UserModel:getCoin();

    if haveCoin >= coinNeed then 
        TreasureServer:plusStar(self._treasureId, 
            c_func(self.upStarClickCallBack, self));
    else 
        local ui = WindowControler:showWindow("CompBuyCoinMainView");
        ui:buyCoin();
    end 
end

function TreasurePlusStarView:upStarClickCallBack(event)
    if event.error == nil then
        AudioModel:playSound("s_treasure_shengxing");
        AudioModel:playSound("s_com_numChange");
        EventControler:dispatchEvent(TreasureEvent.PLUS_STAR_SUCCESS_EVENT, 
            {treasure = self._treasure});
        self:startHide();
    end
end

function TreasurePlusStarView:updateUI()
	
end


return TreasurePlusStarView;
