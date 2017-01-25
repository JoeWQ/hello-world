--[[
	guan 
	2016.8.22
]]

local ActivityFirstRechargeView = class("ActivityFirstRechargeView", UIBase)

function ActivityFirstRechargeView:ctor(winName)
	ActivityFirstRechargeView.super.ctor(self, winName)
end

function ActivityFirstRechargeView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end

function ActivityFirstRechargeView:registerEvent()
	self.btn_x:setTap(c_func(self.onBackTap, self))
    FuncCommUI.setViewAlign(self.btn_x, UIAlignTypes.Right);

    local scaleX = GameVars.width / GAMEWIDTH;
    self.panel_bg:setScaleX(scaleX);
    -- (GameVars.width  - GAMEWIDTH )
	-- 充值成功消息 现在还没有 
	EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT, self.onRechargeCallBack, self);
end

function ActivityFirstRechargeView:onRechargeCallBack(event)
	self.mc_1:showFrame(2);
end

function ActivityFirstRechargeView:initUI()
	self:initReward();
	self:initAni();
	self:initBtn();
end

function ActivityFirstRechargeView:initBtn()
	self.mc_1:showFrame(1);
	local gotoBtn = self.mc_1.currentView.btn_1;
	gotoBtn:setTap(c_func(self.onGoToRechargeView, self));

	self.mc_1:showFrame(2);
	local getBtn = self.mc_1.currentView.btn_1;
	getBtn:setTap(c_func(self.onShowRewardView, self));

	--没有充过值
	echo("--UserModel:goldTotal()--", UserModel:goldTotal());
	if tonumber(UserModel:goldTotal()) ~= 0 then 
		self.mc_1:showFrame(2);
		--加个特效
		local ctn = self.mc_1.currentView.btn_1:getUpPanel().ctn_sweep;
		ctn:setScaleX(1.40);
		ctn:setScaleY(1.25);

	    self:createUIArmature("UI_common",
	        "UI_common_saoguang", ctn, true);
	else 
		self.mc_1:showFrame(1);
	end 
end

function ActivityFirstRechargeView:onShowRewardView()
    self:disabledUIClick();
    echo("-----onShowRewardView-----");
    FirstRechargeServer:getReward(c_func(self.rewardCallBack, self));
end

function ActivityFirstRechargeView:rewardCallBack(event)

    if event.error == nil then
		self:close()
		local rewardsStr = FuncDataSetting.getDataByHid("Firstchargereward").str;
		local rewardArray = string.split(rewardsStr, ";");
		FuncCommUI.startFullScreenRewardView(rewardArray);

		EventControler:dispatchEvent(ChargeEvent.GET_FIRST_CHARGE_REWARD_EVENT, {})
	else 
    	self:resumeUIClick();
	end 
end


function ActivityFirstRechargeView:onGoToRechargeView()
    WindowControler:showWindow("RechargeMainView");
end

function ActivityFirstRechargeView:initAni()
	self:createUIArmature("UI_huodong","UI_huodong_guangxiao", 
        self.ctn_jian, true)

	self:createUIArmature("UI_huodong","UI_huodong_5", 
        self.ctn_glow, true)
end

function ActivityFirstRechargeView:initReward()
	local rewardsStr = FuncDataSetting.getDataByHid("Firstchargereward").str;
	local rewardArray = string.split(rewardsStr, ";");

	for i = 1, 4 do
		local reward = string.split(rewardArray[i], ",");
		local rewardType = reward[1];
		local rewardNum = reward[table.length(reward)];
		local rewardId = reward[table.length(reward) - 1];

		local commonUI = self.panel_1["UI_" .. tostring(i)];
		commonUI:setResItemData({reward = rewardArray[i]});
		commonUI:showResItemName(false);
		commonUI:showResItemRedPoint(false);
        FuncCommUI.regesitShowResView(commonUI,
            rewardType, rewardNum, rewardId, rewardArray[i], true, true);
	end
end


function ActivityFirstRechargeView:onBackTap()
	self:close()
end

function ActivityFirstRechargeView:close()
	self:startHide()
end

return ActivityFirstRechargeView









