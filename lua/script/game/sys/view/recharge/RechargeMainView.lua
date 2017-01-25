local RechargeMainView = class("RechargeMainView", UIBase)
local ITEM_WIDTH = 259.3
local ITEM_HEIGHT = 202

function RechargeMainView:ctor(winName)
	RechargeMainView.super.ctor(self,winName)
end

function RechargeMainView:loadUIComplete()
	echo("-----RechargeMainView:loadUIComplete---");
	self.UI_liebiao1:visible(false)
	-- self.btn_1:setVisible(false)

	self:registerEvent()
	self:rechargeContent()
	self:setViewAlgin()
	self:initVipInfo();

	self.mc_1:showFrame(1);
	self.mc_2:showFrame(2);

end

function RechargeMainView:registerEvent()
	self.btn_back:setTap(c_func(self.close,self))
	self.btn_1:setTap(c_func(self.gotoVipView, self))

	EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT, 
		self.onRechargeCallBack, self);
end

function RechargeMainView:setViewAlgin()
    FuncCommUI.setScale9Align(self.scale9_1, UIAlignTypes.MiddleTop, 1, nil)

	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.UI_gold, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)

	FuncCommUI.setViewAlign(self.UI_2, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.UI_1, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.UI_3, UIAlignTypes.RightTop)
end

function RechargeMainView:gotoVipView()

    local pageView = VipModel:getNextVipGiltToBuy();
    if pageView == -1 then 
        pageView = UserModel:vip();
    end 
    
    WindowControler:showWindow("VipMainView", true, pageView);
end

function RechargeMainView:getItemPosByIndex(index, offsetX, offsetY, widthGap, heightGap)
	local delta = index%3
	delta = _yuan3(delta==0, 2,delta-1)
	local ui_x = delta * ITEM_WIDTH + offsetX + delta*widthGap
	local ui_y = 0
	if index>3 then
		ui_y = -ITEM_HEIGHT - heightGap
	end
	ui_y = ui_y - offsetY
	return ui_x, ui_y
end

function RechargeMainView:rechargeContent()
	local rechargeConfig = FuncCommon.getRechargeConfig()
	local dataSource = self:getScrollDataSource()
	local scrollViewRect = self.scroll_1:getViewRect()
	local scrollViewWidth = scrollViewRect.width
	local scrollViewHeight = scrollViewRect.height
	local itemOffsetX = (scrollViewWidth - 3 * ITEM_WIDTH)*1.0/6
	local itemOffsetY = (scrollViewHeight - 2* ITEM_HEIGHT)*1.0/4
	local itemWidthGap = itemOffsetX*2
	local itemHeightGap = itemOffsetY*2

	local createFunc = function(info)
		local node = display:newNode()
		node:setContentSize(scrollViewRect)
		for i, id in ipairs(info) do
			local ui = UIBaseDef:cloneOneView(self.UI_liebiao1)
			ui:setInfoConfig(rechargeConfig[id])
			ui:updateUI()
			local ui_x, ui_y = self:getItemPosByIndex(i, itemOffsetX, itemOffsetY, itemWidthGap, itemHeightGap)
			ui:addTo(node):pos(ui_x, ui_y)
		end
		return node
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
			itemRect = {x = 0,y =-scrollViewHeight, width = scrollViewWidth, height = scrollViewHeight},
			perFrame = 1
		}
	}
	self.scroll_1:setScrollPage(1, 10, 
		0,{scale = 0.7,wave = 0.3}, c_func(self.scrollMoveEndCallBack, self))
	self.scroll_1:styleFill(params)
	self.scroll_1:easeMoveto(0,0,0)
	self.scroll_1:hideDragBar()
end

function RechargeMainView:scrollMoveEndCallBack(itemIndex,groupIndex)
	echo("---itemIndex,groupIndex---", itemIndex,groupIndex);

	if tonumber(itemIndex) == 1 then 
		self.mc_1:showFrame(1);
		self.mc_2:showFrame(2);
	else 
		self.mc_1:showFrame(2);
		self.mc_2:showFrame(1);
	end 
end

function RechargeMainView:getScrollDataSource()
	local rechargeConfig = FuncCommon.getRechargeConfig()
	local rechargeArr = table.keys(rechargeConfig)
	local sortByLocate = function (aid,bid)
		local alocate = rechargeConfig[aid].locate
		local blocate = rechargeConfig[bid].locate
		return alocate < blocate
	end
	table.sort(rechargeArr,sortByLocate)
	local dataSource = {}
	local step = 6
	local totalNum = #rechargeArr
	for i=1,totalNum,step do
		local info = {}
		for j=i,i+step-1 do
			if j<= totalNum then
				table.insert(info, rechargeArr[j])
			end
		end
		table.insert(dataSource, info)
	end
	return dataSource
end

function RechargeMainView:getNeedGoldToNextVip()
	local totalNum = UserModel:goldTotal();
	local curVip = UserModel:vip();

	if curVip == 15 then 
		curVip = 14
	end 

	local need = FuncCommon.getVipPropByKey(curVip + 1, "cost");
	local diff = tonumber(need) - totalNum;

	-- echo("---need---", need);
	-- echo("---totalNum---", totalNum);

	return diff, need, totalNum;
end


function RechargeMainView:initVipInfo()
	echo("------------initVipInfo-------------");

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

function RechargeMainView:initProcess(totalNum, need)
	self.panel_1.txt_1:setString(string.format("%d/%d", totalNum, need));
	local processWidget = self.panel_1.progress_1;
	processWidget:setPercent((totalNum / need) * 100 );
end

function RechargeMainView:onRechargeCallBack()
	self:initVipInfo();

	local diff, need, totalNum = self:getNeedGoldToNextVip();
	self:initProcess(totalNum, need);

end

function RechargeMainView:close()
	self:startHide()
end

return RechargeMainView
