local CdkeyExchangeResult = class("CdkeyExchangeResult", UIBase)

local MAX_ITEM_NUM = 10

function CdkeyExchangeResult:ctor(winName, rewards)
	CdkeyExchangeResult.super.ctor(self, winName)
	self.rewards = rewards
end

function CdkeyExchangeResult:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self.btn_ok:visible(false)
	self:initData()
	self:initItemsMC()
	self:initTitleAnim()
end

function CdkeyExchangeResult:setViewAlign()
	FuncCommUI.setViewAlign(self.UI_1.panel_1, UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.UI_1.ctn_1, UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.btn_ok, UIAlignTypes.MiddleBottom)
end

function CdkeyExchangeResult:initData()
	self.item_num = #self.rewards
	if self.item_num > MAX_ITEM_NUM then
		self.item_num = MAX_ITEM_NUM
	end
end

function CdkeyExchangeResult:initTitleAnim()
    -- FuncArmature.loadOneArmatureTexture("UI_common", nil, true)
	-- local onTitleAnimEnd = function()
		self:onTitleAnimEnd()
	-- end

	FuncCommUI.addBlackBg(self._root)
    -- 奖品特效
    FuncCommUI.playSuccessArmature(self.UI_1,FuncCommUI.SUCCESS_TYPE.GET,1)
end

function CdkeyExchangeResult:onTitleAnimEnd()
	self:beganShowItems()
end

function CdkeyExchangeResult:showItemByIndex(index)
	local itemView = self.itemsPanel['panel_'..index]
	itemView:visible(true)
	
	local rewardStr = self.rewards[index]
	local params = {
	    reward = rewardStr,
	}
	itemView.UI_1:setResItemData(params)
	itemView.UI_1:showResItemName(true, true)
	
	local itemAnimEndFunc = function()
		if index == self.item_num then
			self:showBottomBtn()
		end
	end
	local itemAnim = self:createUIArmature("UI_common", "UI_common_chouka",itemView.ctn_2, false, itemAnimEndFunc)
	itemAnim:pos(0,0)
	itemAnim:startPlay(false)
end

function CdkeyExchangeResult:showBottomBtn()
	self.btn_ok:visible(true)
end

function CdkeyExchangeResult:beganShowItems()
	local num = self.item_num
	local intervalTime = 0.3
	for i=1,num do
        local delayTime = intervalTime * i
		self:delayCall(c_func(self.showItemByIndex, self, i), delayTime)
	end
end

function CdkeyExchangeResult:initItemsMC()
	local num = self.item_num
	self.mc_items:showFrame(num)
	self.itemsPanel = self.mc_items.currentView
	for i=1,num do 
		self.itemsPanel["panel_"..i]:visible(false)
	end
end

function CdkeyExchangeResult:registerEvent()
	self.btn_ok:setTap(c_func(self.close, self))
end

function CdkeyExchangeResult:close()
	self:startHide()
end

return CdkeyExchangeResult
