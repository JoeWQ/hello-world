-- //购买体力,源文件被误删
-- //2016-4-22
local CompBuySpMainView = class("CompBuySpMainView", UIBase);

function CompBuySpMainView:ctor(_winName)
    CompBuySpMainView.super.ctor(self, _winName);
    self.hasInit=false;
end
--
function CompBuySpMainView:loadUIComplete()
    self:registerEvent();
    self:registClickClose("out");
    self.btn_quxiao:setTap(c_func(self.clickButtonClose, self));
    self.btn_close:setTap(c_func(self.startHide,self));
    self:buyStrength();
end
function CompBuySpMainView:clickButtonClose()
    self:startHide();
end
function CompBuySpMainView:registerEvent()
    CompBuySpMainView.super.registerEvent(self);
    EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE,self.onEventRefresh,self);--//仙玉发生了变化
end

function  CompBuySpMainView:onEventRefresh()
    self.hasInit=false;
    self:buyStrength();
end
-- //购买体力页面
function CompBuySpMainView:buyStrength()
   if(self.hasInit)then
           return;
   end
   self.hasInit=true;
    -- 标题
--    local title = GameConfig.getLanguage("tid_buy_sp_title_1007");
 --   self.panel_bg.UI_bg.txt_1:setString(title);
    -- //npc icon ,dialog
--    local _npcIcon, _npcDialog = FuncCommon.getNpcIconDialog(2);
    self.panel_1.panel_talk.txt_1:setString(GameConfig.getLanguage("#tid2006"));--//NPC体力购买提示
--    local _node = self.panel_1.ctn_1;
--    local _sprite = display.newSprite("#global_img_anu.png");--:size(_node.ctnWidth, _node.ctnHeight);
 --   _sprite:setAnchorPoint(cc.p(0.5, 0.5));
   -- _node:addChild(_sprite);
    -- //购买的次数和总次数
    self.buyTimes = CountModel:getSpBuyCount();
    self.maxTimes = UserModel:getSpMaxBuyTimes();
    self.panel_1.txt_3:setString("" .. self.buyTimes .. "/");
    self.panel_1.txt_4:setString("" .. self.maxTimes);
    self.panel_1.txt_3:setVisible(false);
    self.panel_1.txt_4:setVisible(false);
    local content = GameConfig.getLanguage("tid_buy_times_1002");
    self.panel_1.txt_1:setString(content:format(self.buyTimes, self.maxTimes));
    -- //花费的钻石数目和能购买的体力
    self.diamondCost = FuncCommon.getSpPriceByTimes(self.buyTimes + 1);
    self.spFixedNum = FuncDataSetting.getDataByConstantName("HomeCharBuySP");
    -- //固定的体力
    self.panel_1.panel_zhuanhuan.txt_1:setString("" .. self.diamondCost);
    self.panel_1.panel_zhuanhuan.txt_2:setString("" .. self.spFixedNum);
    if(self.diamondCost>UserModel:getGold())then
         self.panel_1.panel_zhuanhuan.txt_1:setColor(cc.c3b(255,0,0));
    else
         self.panel_1.panel_zhuanhuan.txt_1:setColor(cc.c3b(0x8E,0x5F,0x35));
    end
    -- //注册按钮回调
    self.btn_queding:setTap(c_func(self.clickConfirmButton, self));
end
-- //购买按钮
function CompBuySpMainView:clickConfirmButton()
    -- //次数
    if (self.buyTimes >= self.maxTimes) then
        local tips = GameConfig.getLanguage("tid_buy_limit_1003");
        WindowControler:showTips(tips);
        return;
    end
    -- //购买后体力是否超过了上限
    local _maxSpNum = FuncDataSetting.getDataByConstantName("HomeCharBuySPMax");
    if (UserExtModel:sp() + self.spFixedNum > _maxSpNum) then
        local tips = GameConfig.getLanguage("tid_buy_sp_max_1008") .. _maxSpNum;
        WindowControler:showTips(tips);
        return;
    end
    -- //资源
	if not UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, self.diamondCost, true) then
		return
	end
    self:requestBuySp();
end
-- //发起联网请求
function CompBuySpMainView:requestBuySp()
    local function _callback(_param)
        local tips = nil;
        if (_param.result ~= nil) then
--            tips = GameConfig.getLanguage("tid_buy_sp_success_1000");
--            WindowControler:showTips(tips);
            local    _tip_content=GameConfig.getLanguage("com_buy_sp_some_success");
            local    _flutter_label=cc.Label:createWithSystemFont(_tip_content..self.spFixedNum,GameVars.systemFontName,24);
            _flutter_label:setAnchorPoint(cc.p(0,1));
            local    _ani=self:createUIArmature("UI_buycoin","UI_buycoin_piaodong",nil,false,_remove_self);
            FuncArmature.changeBoneDisplay(_ani, "layer1", _flutter_label);
             _flutter_label:setColor(cc.c3b(255,255,255));
             _flutter_label:enableOutline(cc.c4b(0x48,0x48,0x48,0x48),2);
             self.ctn_ss:addChild(_ani);
            -- //购买成功后页面需要刷新
  --          self.buyTimes = self.buyTimes + 1;
            local content = GameConfig.getLanguage("tid_buy_times_1002");
            self.panel_1.txt_1:setString(content:format(self.buyTimes, self.maxTimes));
            self.diamondCost = FuncCommon.getSpPriceByTimes(self.buyTimes + 1);
            self.spFixedNum = FuncDataSetting.getDataByConstantName("HomeCharBuySP");
            -- //固定的体力
            self.panel_1.panel_zhuanhuan.txt_1:setString("" .. self.diamondCost);
            self.panel_1.panel_zhuanhuan.txt_2:setString("" .. self.spFixedNum);
        else
            tips = GameConfig.getLanguage("tid_buy_sp_failed_1009");
            WindowControler:showTips(tips);
        end
    end
    UserServer:buySp(_callback);
end
return CompBuySpMainView;
