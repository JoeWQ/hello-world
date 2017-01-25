--guan

local SysWillOpenView = class("SysWillOpenView", UIBase);

function SysWillOpenView:ctor(winName, willOpenName, sysOpenLvl)
    SysWillOpenView.super.ctor(self, winName);
    self._willOpenName = willOpenName;
    self._sysOpenLvl = sysOpenLvl;
end

function SysWillOpenView:loadUIComplete()
	self:registerEvent();
    self:initUI();
    
    -- self:registClickClose();

    self.btn_close:setTap(c_func(self.startHide, self));

    FuncCommUI.setViewAlign(self.btn_close,UIAlignTypes.Right)

end 

function SysWillOpenView:registerEvent()
	SysWillOpenView.super.registerEvent();
end

function SysWillOpenView:initUI()
    local tidName = FuncCommon.getSysOpensysname(self._willOpenName);
    self.panel_txts.txt_name:setString(GameConfig.getLanguage(tidName));

    local tidDes = FuncCommon.getSysOpenContent(self._willOpenName);
    local desStr = GameConfig.getLanguage(tidDes) .. GameConfig.getLanguageWithSwap(GameVars.openLevelTid, self._sysOpenLvl)
    self.panel_txts.txt_miaoshu:setString(desStr);


    local adDes = FuncCommon.getAdInt(self._willOpenName);
    self.panel_txts.txt_miao:setString(GameConfig.getLanguage(adDes));

    self:initAni();
end

function SysWillOpenView:initAni()
    local ani = self:createUIArmature("UI_common","UI_common_xianfazhiren", self.ctn_ani, 
        false, GameVars.emptyFunc);

    --换描述
    self.panel_txts:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(ani, "layer2a", self.panel_txts);

    --换icon
    local spPath = FuncRes.iconSys(self._willOpenName);
    local sp = display.newSprite(spPath);
    sp:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(ani, "icon", sp);

    --换关闭按钮
    self.btn_close:setPosition(0, 0);
    FuncArmature.changeBoneDisplay(ani, "layer1", self.btn_close);   

    ani:registerFrameEventCallFunc(10, 1, function ()

    end);


    self.panel_zhanwei:setOpacity(1);
    self.panel_zhanwei:setTouchedFunc(function ( ... )
        echo(" setTouchedFunc setTouchedFunc setTouchedFunc");
    end);

    -- self.panel_zhanwei:setTouchSwallowEnabled(true);

    self.panel_zhanwei1:setOpacity(1);
    self.panel_zhanwei1:setTouchedFunc(function ( ... )
        self:startHide();
    end);

    self.panel_zhanwei2:setOpacity(1);
    self.panel_zhanwei2:setTouchedFunc(function ( ... )
        self:startHide();
    end);


end

return SysWillOpenView;







