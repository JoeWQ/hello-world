local ArenaBuyCountView = class("ArenaBuyCountView", UIBase)

function ArenaBuyCountView:ctor(winName)
	ArenaBuyCountView.super.ctor(self, winName)
end

function ArenaBuyCountView:loadUIComplete()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_pvp_1013"))
	self.UI_1.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguage("tid_common_1008"))

	local cost = PVPModel:getNextBuyCost()
    self._buyCost = cost
	self.txt_1:setString(GameConfig.getLanguage("tid_pvp_1009"))
	self.txt_2:setString(cost)
	self.txt_3:setString(GameConfig.getLanguage("tid_pvp_1010"))
	local buyCount = CountModel:getPVPBuyCount()
--	local maxBuyCount = FuncPvp.getPVPMaxBuyTimes()
    --只显示已经购买的次数
	self.txt_4:setString(GameConfig.getLanguage("tid_pvp_1011"):format( buyCount))

	self.txt_5:setString(GameConfig.getLanguage("tid_pvp_1012"))
	--不让有vip
	self.txt_5:setVisible(false);
	
	self:registerEvent()
end

function ArenaBuyCountView:registerEvent()
	self.UI_1.btn_close:setTap(c_func(self.startHide, self))
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.onBuyTap, self))
	self:registClickClose("out")
end

function ArenaBuyCountView:onBuyTap()
    --目前购买资格已经取消了限制
--    local    _user_vip=UserModel:vip();
--    if(_user_vip <3)then
--          WindowControler:showTips(GameConfig.getLanguage("pvp_buy_operate_need_vip3_1002"));
--          self:startHide();
--          return;
--    end
    --检测,是否仙玉足够
    local _user_gold = UserModel:getGold()
    if _user_gold < self._buyCost then
        WindowControler:showTips(GameConfig.getLanguage("tid_shop_1030"))
        return
    end
	PVPServer:buyPVP(c_func(self.onBuyPvpCountOk, self))
end

function ArenaBuyCountView:onBuyPvpCountOk(event)
    if event.result ~= nil then
	    EventControler:dispatchEvent(PvpEvent.PVPEVENT_BUY_CHALLENGE_COUNT_OK)
	    WindowControler:showTips(GameConfig.getLanguage("tid_common_1009"))
    else
        echo("-----ArenaBuyCountView:onBuyPvpCountOk------",event.error.message)
    end
	self:startHide()
end

return ArenaBuyCountView

