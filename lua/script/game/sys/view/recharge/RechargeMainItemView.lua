local RechargeMainItemView = class("RechargeMainItemView", UIBase)

function RechargeMainItemView:ctor(winName)
	RechargeMainItemView.super.ctor(self, winName)
end

function RechargeMainItemView:setInfoConfig(info)
	self.info = info

 -- { "firstGiftGold" = 6480
 --     "giftGold"      = 650
 --     "gold"          = 6480
 --     "id"            = "7"
 --     "introduce"     = "#tid2306"
 --     "locate"        = 7
 --     "rmb"           = 648
 -- }

 	-- dump(UserModel:buyProductTimes(), "---buyProductTimes---");

 	EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT, 
		self.onRechargeCallBack, self);
end

function RechargeMainItemView:onRechargeCallBack( ... )
	self:updateUI();
end

function RechargeMainItemView:updateUI()
	self.btn_anniu:getUpPanel().txt_price:setString(self.info.rmb) 
	
	self.btn_anniu:getUpPanel().mc_price:showFrame(tonumber(self.info.id))

   	self.btn_anniu:setTap(c_func(self.clickRecharge, self));

   	--元宝图标
   	self.btn_anniu:getUpPanel().mc_gold:showFrame(tonumber(self.info.id));

   	--是否首冲
	local getGoldText = GameConfig.getLanguageWithSwap(self.info.introduce, self.info.gold)	

   	if RechargeModel:isFirstBuy(self.info.id) == true then 
   		self.btn_anniu:getUpPanel().mc_costdouble:setVisible(true);
		self.btn_anniu:getUpPanel().txt_presentgold:setString(getGoldText)

		if tonumber(self.info.rmb) == 30 then 
			local str30 = GameConfig.getLanguageWithSwap("#tid2308", self.info.gold)
			self.btn_anniu:getUpPanel().txt_presentgold:setString(str30);
		elseif tonumber(self.info.rmb) == 98 then 
			local str98 = GameConfig.getLanguageWithSwap("#tid2309", self.info.gold)
			self.btn_anniu:getUpPanel().txt_presentgold:setString(str98);
		else 

		end 
   	else 
   		self.btn_anniu:getUpPanel().mc_costdouble:setVisible(false);
		self.btn_anniu:getUpPanel().txt_presentgold:setString("")
   	end 
end

function RechargeMainItemView:clickRecharge()
	RechargeServer:recharge(self.info.id, c_func(self.rechargeOk, self));
end

function RechargeMainItemView:rechargeOk(event)
    if event.error == nil then
    	echo("---finishRecharge---");
    	WindowControler:showTips("充值成功");
        EventControler:dispatchEvent(RechargeEvent.FINISH_RECHARGE_EVENT, {});

       	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, 
            {redPointType = HomeModel.REDPOINT.ACTIVITY.FIRST_CHARGE, isShow = true});

	end 
end


return RechargeMainItemView




