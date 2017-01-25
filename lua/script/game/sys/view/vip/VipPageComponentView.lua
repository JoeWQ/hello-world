--guan 
--2016.9.8

local VipPageComponentView = class("VipPageComponentView", UIBase)

function VipPageComponentView:ctor(winName)
	VipPageComponentView.super.ctor(self, winName)
end

function VipPageComponentView:setInfoConfig(vipLevel)
	self._vipLevel = tonumber(vipLevel);

	EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT, 
		self.initBuyBtn, self);

    EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE,
   		self.initBuyBtn, self);


end

function VipPageComponentView:initBuyBtn()
 	self.panel_1.panel_1.ctn_saoguang:removeAllChildren();

 	if VipModel:isAlreadyBuyThatVipGift(self._vipLevel) == true then 
		self.panel_1.panel_1.mc_1:showFrame(2);
		self.panel_1.panel_1.panel_red:setVisible(false)
	else 
		local curVip = UserModel:vip();
		self.panel_1.panel_1.mc_1:showFrame(1);
		local btn = self.panel_1.panel_1.mc_1:getCurFrameView().btn_2;
		if curVip >= self._vipLevel and 
				VipModel:isGoldEnoughToBuyGift(self._vipLevel) == true then 
			btn:setTap(c_func(self.buyGift, self));
			self.panel_1.panel_1.panel_red:setVisible(true)
			--特效
			FilterTools.clearFilter(btn);
			self:createUIArmature("UI_common",
	        	"UI_common_saoguang", self.panel_1.panel_1.ctn_saoguang, true);
		else 
			btn:setTap(c_func(self.buyGift, self));
			self.panel_1.panel_1.panel_red:setVisible(false)

			FilterTools.setGrayFilter(btn);
		end 
 	end 
end

function VipPageComponentView:updateUI()
 	self.panel_1.txt_2:setString("VIP" .. tostring(self._vipLevel) .. "特权");

	self.panel_1.panel_1:setVisible(true);
	local preCost = FuncCommon.getVipPropByKey(
		self._vipLevel, "originalprice");
	self.panel_1.panel_1.panel_1.txt_2:setString(preCost);

	local curCost = FuncCommon.getVipPropByKey(
		self._vipLevel, "Discountprice");
	self.panel_1.panel_1.panel_1.txt_4:setString(curCost);

	self.panel_1.panel_1.txt_1:setString(
		"VIP" .. tostring(self._vipLevel) .. "礼包包含如下内容：");

	local rewardArray = FuncCommon.getVipPropByKey(
		self._vipLevel, "gift");

	for i, v in pairs(rewardArray) do
		local reward = string.split(v, ",");
		local rewardType = reward[1];
		local rewardNum = reward[table.length(reward)];
		local rewardId = reward[table.length(reward) - 1];

		local commonUI = self.panel_1.panel_1["UI_" .. tostring(i)];
		commonUI:setResItemData({reward = v});
		commonUI:showResItemName(false);
		commonUI:showResItemRedPoint(false);
        FuncCommUI.regesitShowResView(commonUI,
            rewardType, rewardNum, rewardId, v, true, true);
	end

	for i = table.length(rewardArray) + 1, 4 do
		local commonUI = self.panel_1.panel_1["UI_" .. tostring(i)];
		commonUI:setVisible(false);
	end

	self:initBuyBtn();

 	--闪光
 	local configIconAnim = FuncCommon.getVipPropByKey(self._vipLevel, "lighting");
 	for k, v in pairs(configIconAnim) do
 		local uiIcon = self.panel_1.panel_1["UI_" .. tostring(v)];
 		local ctn = self.panel_1.panel_1["ctn_icon" .. tostring(v)];

 		local reward = string.split(rewardArray[tonumber(v)], ",");

 		local ani = nil;
 		if self:isFragment(reward[1], reward[2]) == true then 
        	ani = self:createUIArmature("UI_shop","UI_shop_yuan", ctn, true)
        else 
        	ani = self:createUIArmature("UI_shop","UI_shop_fang", ctn, true)
 		end 

        uiIcon:setPosition(0, 0);
        FuncArmature.changeBoneDisplay(ani, "node1", uiIcon);
 	end

 	--描述放到滚动中
	local createFunc = function ()
	 	local richWidget = self.panel_1.rich_1;
		richWidget:setVisible(false);
		local cloneWidget = UIBaseDef:cloneOneView(richWidget);

 		local vipDes = FuncCommon.getVipPropByKey(self._vipLevel, "Vdescribe");
	 	local stringContent = GameConfig.getLanguage(vipDes);
	 	cloneWidget:setString(stringContent);
		return cloneWidget;
	end

	local params = {
		{
			data = {1},
			createFunc = createFunc,
			perNums = 1,
			offsetX = 0,
			offsetY = 0,
			widthGap = 0,
			heigthGap = 0,
			itemRect = {x = 0, y =-247, width = 247, height = 247},
			perFrame = 1
		}
	}
	self.panel_1.scroll_1:styleFill(params)
	self.panel_1.scroll_1:hideDragBar()

end

function VipPageComponentView:buyGift()
	local curVip = UserModel:vip();

	echo("-----buyGift----");

	if curVip >= self._vipLevel and VipModel:isGoldEnoughToBuyGift(self._vipLevel) == true then
		self:disabledUIClick();
		VipServer:bugGift(self._vipLevel, c_func(self.buyCallBack, self));
	else
		--vip不足
		if curVip < self._vipLevel then 
			local ui = WindowControler:showWindow("CompGotoRechargeView");
			ui:setContentStr("vip等级不足，是否前往充值");
		else 
			WindowControler:showWindow("CompGotoRechargeView");
		end 
	end 
end

function VipPageComponentView:buyCallBack(event)
    self:resumeUIClick();
 	self.panel_1.panel_1.ctn_saoguang:removeAllChildren();

	if event.error == nil then
		--弹奖励 
         local rewards = FuncCommon.getVipPropByKey(
 			self._vipLevel, "gift");
        FuncCommUI.startFullScreenRewardView(rewards);

		--刷新界面
		self.panel_1.panel_1.mc_1:showFrame(2);
		self.panel_1.panel_1.panel_red:setVisible(false);
	end 
end

function VipPageComponentView:isFragment(itemType, itemId)
    if itemType == FuncDataResource.RES_TYPE.ITEM then 
        local subType = FuncItem.getItemType(itemId);
        if subType == ItemsModel.itemType.ITEM_TYPE_PIECE then 
            return true;
        else 
            return false;
        end 
    else 
        return false;
    end 
end

return VipPageComponentView












