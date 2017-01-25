--guan 
--2016.9.8

local VipMainView = class("VipMainView", UIBase)

function VipMainView:ctor(winName, isComeFromRecharge, showVipPage)
	VipMainView.super.ctor(self,winName)
	self._isComeFromRecharge = false;
	-- self._showVipPage = showVipPage or 0;

	self._curPage = (showVipPage or 0) + 1;

	echo("----VipMainView-----", self._curPage);
end

function VipMainView:loadUIComplete()
	self:registerEvent()
	self:initUI();
	self.UI_clone:setVisible(false);

	-- self._curPage = self._showVipPage + 1;

	self:setViewAlgin();
end

function VipMainView:registerEvent()
	self.btn_back:setTap(c_func(self.close, self));

	self.btn_left:setTap(c_func(self.goPre, self));
	self.btn_right:setTap(c_func(self.goNext, self));
	
	self.btn_1:setTap(c_func(self.gotoRechargeView, self));
	EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT, 
		self.onRechargeCallBack, self);
end

function VipMainView:goPre()
	if self._curPage ~= 1 then 
		self.scroll_1:pageEaseMoveTo(self._curPage - 1, 1, 0.3);
		self._curPage = self._curPage - 1;
	end 
end

function VipMainView:goNext()
	if self._curPage ~= 16 then 
		self.scroll_1:pageEaseMoveTo(self._curPage + 1, 1, 0.3);
		self._curPage = self._curPage + 1;
	end
end

function VipMainView:gotoRechargeView()
	echo("---VipMainView:gotoRechargeView---");
    WindowControler:showWindow("RechargeMainView");
end

function VipMainView:setViewAlgin()
    FuncCommUI.setScale9Align(self.scale9_1, UIAlignTypes.MiddleTop, 1, nil)
	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)

	FuncCommUI.setViewAlign(self.panel_he, UIAlignTypes.RightTop)

	FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
end

function VipMainView:initUI()
	self:initVipInfo();
	self:initList();
end

function VipMainView:initList()
	local createFunc = function (vipId)
		local pageContent = UIBaseDef:cloneOneView(self.UI_clone);
		pageContent:setInfoConfig(vipId);
		pageContent:updateUI()
		return pageContent;
	end

	local dataSource = {};
	for i = 0, 15 do
		table.insert(dataSource, i);
	end

	local params = {
		{
			data = dataSource,
			createFunc = createFunc,
			perNums = 1,
			offsetX = 0,
			offsetY = 0,
			widthGap = 0,
			heigthGap = 0,
			itemRect = {x = 0, y =-426, width = 868, height = 426},
			perFrame = 1
		}
	}
	self.scroll_1:setScrollPage(1, nil, 
		0, {scale = 0.7,wave = 0}, c_func(self.scrollMoveEndCallBack, self))
	self.scroll_1:styleFill(params)
	self.scroll_1:pageEaseMoveTo(self._curPage, 1, 0);
	self.scroll_1:hideDragBar()

end

function VipMainView:scrollMoveEndCallBack(itemIndex, groupIndex)
	echo("---itemIndex,groupIndex---", itemIndex,groupIndex);
	self._curPage = tonumber(itemIndex);

end

function VipMainView:initVipInfo()

	local curVip = UserModel:vip();
	self.mc_7:showFrame(curVip + 1);

	local diff, need, totalNum = self:getNeedGoldToNextVip();

	if curVip ~= 15 then 

		local nextVip = UserModel:vip() + 1;
		self.mc_8:showFrame(nextVip + 1);
		self.txt_1:setString(diff);
	else 
		self.panel_f:setVisible(false)
		self.panel_33:setVisible(false)
		self.txt_1:setVisible(false)
		self.panel_g:setVisible(false)
		self.panel_32:setVisible(false)
		self.mc_8:setVisible(false)
	end 

	self:initProcess(totalNum, need);

end

function VipMainView:initProcess(totalNum, need)
	self.panel_lan.txt_1:setString(string.format("%d/%d", totalNum, need));
	local processWidget = self.panel_lan.progress_1;
	processWidget:setPercent((totalNum / need) * 100 );
end

function VipMainView:getNeedGoldToNextVip()
	local totalNum = UserModel:goldTotal();
	local curVip = UserModel:vip();

	if curVip == 15 then 
		curVip = 14
	end 

	local need = FuncCommon.getVipPropByKey(curVip + 1, "cost");
	local diff = tonumber(need) - totalNum;

	return diff, need, totalNum;
end


function VipMainView:onRechargeCallBack()
	self:initUI();
end


function VipMainView:close()
	self:startHide()
end

return VipMainView










