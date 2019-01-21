--guan
--2016.4.29

local TreasureView = class("TreasureView", UIBase);

--local selectIndex = 1;

function TreasureView:ctor(winName)
    TreasureView.super.ctor(self, winName);
    self._isTreasureUIInitAlready = false;
    self._isCombineUIInitAlready = false;
    self._isStarlightUIInitAlready = false;
    self.selectIndex=1;
end

function TreasureView:loadUIComplete()

    --法宝合成，需要重新刷新界面
    EventControler:addEventListener(TreasureEvent.TREASURE_COMBINE_EVENT,
        self.combineCallBack, self);

    --金币增加
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, 
        self.coinChangeCallBack, self);

    EventControler:addEventListener(TreasureEvent.TREASUREEVENT_MODEL_NEW, 
        self.newTreasureCallBack, self);

	self:registerEvent();
    self:adjust();
    self:initUI();
end 

function TreasureView:coinChangeCallBack()
    self:redPointInit();
end

function TreasureView:combineCallBack()
    self:setTreasureNum();
end

function TreasureView:newTreasureCallBack( ... )
    self:setTreasureNum();
end

function TreasureView:adjust()
    FuncCommUI.setScale9Align(self.scale9_upbg,UIAlignTypes.MiddleTop, 1, nil)
    FuncCommUI.setViewAlign(self.btn_close, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.panel_res, UIAlignTypes.RightTop);

    FuncCommUI.setViewAlign(self.panel_left, UIAlignTypes.LeftTop, 0.7);
    FuncCommUI.setViewAlign(self.panel_zhui, UIAlignTypes.LeftTop, 0.7);
    
    FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.panel_upbg, UIAlignTypes.MiddleTop);
end

function TreasureView:redPointInit()
    --法宝的
    if TreasuresModel:isRedPointShow() == true then 
        self.panel_left.panel_red1:setVisible(true);
    else  
        self.panel_left.panel_red1:setVisible(false);
    end 

    --合成的
    if CombineControl:isHaveCanCombineTreasure() == true then 
        self.panel_left.panel_red2:setVisible(true);
    else  
        self.panel_left.panel_red2:setVisible(false);
    end 
end

function TreasureView:initUI()
    self:redPointInit();
    self._targetScrollPreRect = self.scroll_demo:getViewRect();

    -- dump(self._targetScrollPreRect, "===self._targetScrollPreRect===");

    self:initSelectView();

    self:setTreasureNum();

    if self.selectIndex == 1 then 
        self:pressTreasure();
    elseif self.selectIndex == 2 then 
        self:pressCombine();
    end 

end

function TreasureView:registerEvent()
	TreasureView.super.registerEvent();
    self.btn_close:setTap(c_func(self.press_btn_close, self));

    EventControler:addEventListener(TreasureEvent.CHANGE_TREASURE,
        self.pressTreasure, self);
    
end

function TreasureView:initSelectView()
    --点击treasure
    self.panel_left.mc_1:setTouchedFunc(c_func(self.pressTreasure, self));
    --点击combine
    self.panel_left.mc_2:setTouchedFunc(c_func(self.pressCombine, self));
end

function TreasureView:pressTreasure()
    self:setSelectUI(1);

    if self._isTreasureUIInitAlready == false then 
        self._isTreasureUIInitAlready = true;
        local treasureEntrance = WindowsTools:createWindow(
            "TreasureEntrance", self._targetScrollPreRect);

        treasureEntrance:setPosition(GameVars.UIOffsetX, 0);

        self.mc_ctn:getCurFrameView().ctn_1:addChild(treasureEntrance);
    end 

    self.selectIndex = 1;

end

function TreasureView:pressCombine()
    local open, value, valueType = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TREASURE_COMBINE)
    if not open then
        WindowControler:showTips(GameConfig.getLanguageWithSwap("tid_common_1013", value))
        return;
    end

    self:setSelectUI(2);

    if self._isCombineUIInitAlready == false then 
        self._isCombineUIInitAlready = true;

        --local combineScrollViewRect = cc.rect(self._targetScrollPreRect.x + 2,self._targetScrollPreRect.y,self._targetScrollPreRect.width - 28,self._targetScrollPreRect.height);

        local view = WindowsTools:createWindow(
            "CombineView", nil, self._targetScrollPreRect);
 
        view:setPosition(GameVars.UIOffsetX, 0);

        self.mc_ctn:getCurFrameView().ctn_1:addChild(view);
    else
        EventControler:dispatchEvent(TreasureEvent.CANCEL_EFFECT_LIUGUANG, {});
    end
    self.selectIndex = 2;
end

--星耀
function TreasureView:pressStarlight()
    local open, value, valueType = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.STARLIGHT)
    if not open then
        WindowControler:showTips(GameConfig.getLanguageWithSwap("tid_common_1013", value))
        return;
    end
    self:setSelectUI(3);
    if not self._isStarlightUIInitAlready then 
    self._isStarlightUIInitAlready = true

    local starlightScrollViewRect = cc.rect(self._targetScrollPreRect.x + 2,self._targetScrollPreRect.y,self._targetScrollPreRect.width - 28,self._targetScrollPreRect.height);
    local view = WindowsTools:createWindow(
        "StarlightView", nil, starlightScrollViewRect);

    view:setPosition(GameVars.UIOffsetX, 0);
    self.starlightView=view;
    self.mc_ctn:getCurFrameView().ctn_1:addChild(view);
    else--//否则刷新一下
          self.starlightView:freshAllStarlight();
    end 
    self.selectIndex = 3;
end

function TreasureView:setTreasureNum()
    self.txt_2:setString(TreasuresModel:getOwnTreasureCount());
end

function TreasureView:press_btn_close()
    local  function  onClose()
         self:startHide();
    end
    self:startHide();
end

function TreasureView:setSelectUI(index)
    if index == 1 then
        self.panel_left.mc_1:showFrame(2);
        self.panel_left.mc_2:showFrame(1);

        self.mc_ctn:showFrame(1);
        self:setIsDonwNumShow(true);

    elseif index == 2 then
        self.panel_left.mc_1:showFrame(1);

        self.panel_left.mc_2:showFrame(2);
        self.mc_ctn:showFrame(2);
        self:setIsDonwNumShow(false);
    end
end

function TreasureView:setIsDonwNumShow(isShow)
    self.txt_1:setVisible(isShow);
    self.txt_2:setVisible(isShow);
end


return TreasureView;











