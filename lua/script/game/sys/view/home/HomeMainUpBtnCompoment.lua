    --[[
    guan
    2016.8.31
]]

local HomeMainUpBtnCompoment = class("HomeMainUpBtnCompoment", UIBase);


function HomeMainUpBtnCompoment:ctor(winName)
    HomeMainUpBtnCompoment.super.ctor(self, winName);

    self._cloneCtns = {};
    self._uiDic = {};
end

function HomeMainUpBtnCompoment:loadUIComplete()
    self:registerEvent();

    self.btn_todoClone:setVisible(false);

    self:initBtnClickFuncCall();

    self:initUI();
end 

function HomeMainUpBtnCompoment:registerEvent()
    HomeMainUpBtnCompoment.super.registerEvent();

    --主界面小红点消息
    EventControler:addEventListener(HomeEvent.RED_POINT_EVENT,
        self.redPointUpate, self); 

    EventControler:addEventListener(ChargeEvent.GET_FIRST_CHARGE_REWARD_EVENT,
        self.firstChargeChange, self); 

    EventControler:addEventListener(HappySignEvent.FINISH_ALL_SIGN_EVENT,
        self.happySignChange, self); 
end

function HomeMainUpBtnCompoment:initUI( )
	local activityArray = HomeModel:getShowActivity();
	self._uiDic = {};

	for _, v in pairs(activityArray) do
    	local btnWidget = UIBaseDef:cloneOneView(self.btn_todoClone);
    	local iconSp = FuncHome.getIconSp(v);
		btnWidget:getUpPanel().ctn_OtherIcon:addChild(iconSp);
		iconSp:setPositionY(-8);

		local isShowRedPoint = HomeModel:isRedPointShow(v);
		
		if v == HomeModel.REDPOINT.ACTIVITY.FIRST_CHARGE then 
			isShowRedPoint = HomeModel:isShowFirstChargeRedPoint();
		end 

		btnWidget:getUpPanel().panel_red:setVisible(isShowRedPoint);

		self._uiDic[v] = btnWidget;

		btnWidget:setTouchedFunc(c_func(self.activityFuncMap[v], self));
	end

	for k, v in pairs(activityArray) do
		local ctn = self["ctn_" .. tostring(k)];
		local widget = self._uiDic[v];
		widget:pos(0,0);
		widget:parent(ctn);
	end

end

--todo 动态搞 不要self._uiDic[HomeModel.REDPOINT.ACTIVITY.FIRST_CHARGE]:removeFromParent();
function HomeMainUpBtnCompoment:firstChargeChange()
	self._uiDic[HomeModel.REDPOINT.ACTIVITY.FIRST_CHARGE]:removeFromParent();
	self._uiDic[HomeModel.REDPOINT.ACTIVITY.FIRST_CHARGE] = nil;

	local activityArray = HomeModel:getShowActivity();

	for k, v in pairs(activityArray) do
		local ctn = self["ctn_" .. tostring(k)];
		local widget = self._uiDic[v];
		widget:pos(0,0);
		widget:parent(ctn);
	end
end

function HomeMainUpBtnCompoment:happySignChange( ... )
	self._uiDic[HomeModel.REDPOINT.ACTIVITY.HAPPY_SIGN]:removeFromParent();
	self._uiDic[HomeModel.REDPOINT.ACTIVITY.HAPPY_SIGN] = nil;

	local activityArray = HomeModel:getShowActivity();

	for k, v in pairs(activityArray) do
		local ctn = self["ctn_" .. tostring(k)];
		local widget = self._uiDic[v];
		widget:pos(0,0);
		widget:parent(ctn);
	end
end

function HomeMainUpBtnCompoment:redPointUpate(data)
	local uiName = data.params.redPointType;
    local isShow = data.params.isShow or false;

    if self._uiDic[uiName] ~= nil then 
    	self._uiDic[uiName]:getUpPanel().panel_red:setVisible(isShow);
    end 
end

function HomeMainUpBtnCompoment:initBtnClickFuncCall()
    self.activityFuncMap = {
        [HomeModel.REDPOINT.ACTIVITY.MAIL] = self.clickA1_mail, --消息
        [HomeModel.REDPOINT.ACTIVITY.ACTIVITY] = self.clickA2_activity, --活动
        [HomeModel.REDPOINT.ACTIVITY.GIFT] = self.clickA3_gift, --礼包
        [HomeModel.REDPOINT.ACTIVITY.CHARGE] = self.clickA4_charge, -- 充值
        [HomeModel.REDPOINT.ACTIVITY.FIRST_CHARGE] = self.clickA5_fisrtCharge, --首冲
        [HomeModel.REDPOINT.ACTIVITY.HAPPY_SIGN] = self.clickA6_sevenDay, --7天
    };
end

function HomeMainUpBtnCompoment:clickA1_mail()
    echo("clickA1_mail");
    WindowControler:showWindow("MailView")
end

function HomeMainUpBtnCompoment:clickA2_activity()
    echo("clickA2_activity");
    -- WindowControler:showTips("功能未开启");

    echo(HomeModel:isFinishFirstCharge());
end

function HomeMainUpBtnCompoment:clickA3_gift()
    echo("clickA3_gift");
    WindowControler:showTips("功能未开启");
end

function HomeMainUpBtnCompoment:clickA4_charge()
    echo("clickA4_charge");
    WindowControler:showWindow("RechargeMainView")
end

function HomeMainUpBtnCompoment:clickA5_fisrtCharge()
    echo("clickA5_fisrtCharge");
    if tonumber(UserExtModel:firstRechargeGift()) ~= 1 then 
        WindowControler:showWindow("ActivityFirstRechargeView")
    else 
        WindowControler:showTips("首冲已领取，我是礼包");
    end 
end

function HomeMainUpBtnCompoment:clickA6_sevenDay()
	echo("clickA6_sevenDay");
	WindowControler:showWindow("HappySignView");

end


return HomeMainUpBtnCompoment;






























