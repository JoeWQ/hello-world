local ItemBoxRewardView = class("ItemBoxRewardView", UIBase);

function ItemBoxRewardView:ctor(winName,data)
    ItemBoxRewardView.super.ctor(self, winName);
    -- 开宝箱
    self.rewardData = data.reward
    self.boxId = data.itemId
    self.openBoxType = data.itemNum

    self.leftBoxNum = ItemsModel:getItemNumById(self.boxId)
    -- 是否正在开宝箱中
    self.isOpeningBox = false
end

function ItemBoxRewardView:loadUIComplete()
	self:registerEvent();
    self:initData()
    self:initView()
    self:updateUI()

end 

function ItemBoxRewardView:initData()
    self.itemNum = #self.rewardData
end

function ItemBoxRewardView:initView()
    FuncCommUI.addBlackBg(self._root)

    self:initAnim()
end

function ItemBoxRewardView:initAnim()
    --加载特效
    -- FuncArmature.loadOneArmatureTexture("UI_common", nil, true)
end

function ItemBoxRewardView:registerEvent()
	ItemBoxRewardView.super.registerEvent();
end

function ItemBoxRewardView:updateUI()
    AudioModel:playSound(MusicConfig.s_com_reward);

    self.mc_shuliang:showFrame(self.itemNum)
    self.itemPanels = self.mc_shuliang.currentView
    
    self:showActionBtn(false)
    self:hideAllItem()

    self.UI_1.ctn_1:removeAllChildren()
    self.UI_1.ctn_3:removeAllChildren()
    FuncCommUI.playSuccessArmature(self.UI_1,FuncCommUI.SUCCESS_TYPE.GET,1)

    self:delayCall(c_func(self.showRewards,self),0.1)
end

function ItemBoxRewardView:showRewards()
    for i=1,self.itemNum do
        local itemView = self.itemPanels["panel_" .. i]
        local rewardStr = self.rewardData[i]

        local intervalTime = 2 / ARMATURERATE
        local delayTime = intervalTime * i

        self:delayShowItem(itemView,rewardStr,delayTime)

        if i == self.itemNum then
            self:delayCall(c_func(self.showActionBtn,self,true),delayTime + intervalTime)
        end
    end
end

function ItemBoxRewardView:showActionBtn(visible)
    -- 更新宝箱剩余数量
    self.leftBoxNum = ItemsModel:getItemNumById(self.boxId)
    if self.leftBoxNum == 0 then
        self.mc_1:showFrame(2)
        self.mc_1.currentView.btn_2:setTap(c_func(self.close, self));
    else
        self.mc_1:showFrame(1)
        self.mc_1.currentView.btn_1:setTap(c_func(self.openBoxes, self));
        self.mc_1.currentView.btn_2:setTap(c_func(self.close, self));

        if self.openBoxType == ItemsModel.boxType.TYPE_BOX_NUM_ONE then
            self.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguage("tid_bag_1001"))
        elseif self.openBoxType == ItemsModel.boxType.TYPE_BOX_NUM_TEN then
            local showBoxNum = ItemsModel.boxType.TYPE_BOX_NUM_TEN
            if self.leftBoxNum < showBoxNum then
                showBoxNum = self.leftBoxNum
            end
            self.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguageWithSwap("tid_bag_1002",showBoxNum))
        end
    end

    self.mc_1:setVisible(visible)
end

-- 延迟显示item
function ItemBoxRewardView:delayShowItem(itemView,rewardStr,delayTime)
    local callBack = function()
        local params = {
            reward = rewardStr
        }
        itemView.UI_1:setResItemData(params)
        itemView.UI_1:showResItemName(true,true,1)
        itemView:setVisible(true)

        itemView.UI_1:pos(7,-5)
        FuncCommUI.playRewardItemAnim(itemView.ctn_1,itemView.UI_1)
    end

    self:delayCall(c_func(callBack, self),delayTime)
end

-- 隐藏所有item
function ItemBoxRewardView:hideAllItem()
    for i=1,self.itemNum do
        self.itemPanels["panel_" .. i]:setVisible(false)
    end
end

-- 再开宝箱
function ItemBoxRewardView:openBoxes()
    if self.isOpeningBox then
        return
    end

    local leftBoxNum = ItemsModel:getItemNumById(self.boxId)
    local costBoxNum = 1
    -- 没有宝箱，关闭窗口
    if leftBoxNum < 1 then
        self:close()
        return 
    end

    -- 再抽之前先隐藏items
    self:hideAllItem()

    if self.openBoxType == ItemsModel.boxType.TYPE_BOX_NUM_ONE then
        costBoxNum = ItemsModel.boxType.TYPE_BOX_NUM_ONE
        local canUse = ItemsModel:checkItemUseCondition(self.boxId,costBoxNum)
        if canUse then
            self.isOpeningBox = true
            ItemServer:customItems(self.boxId, costBoxNum,c_func(self.openBoxesCallBack,self))
        end
    elseif self.openBoxType == ItemsModel.boxType.TYPE_BOX_NUM_TEN then
        costBoxNum = ItemsModel.boxType.TYPE_BOX_NUM_TEN
        local canUse = ItemsModel:checkItemUseCondition(self.boxId,costBoxNum)
        if not canUse then
            -- 不足10个宝箱，有几个开几个
            costBoxNum = leftBoxNum
        end

        self.isOpeningBox = true
        ItemServer:customItems(self.boxId, costBoxNum,c_func(self.openBoxesCallBack,self))
    end
end

-- 再开宝箱回调
function ItemBoxRewardView:openBoxesCallBack(event)
    self.isOpeningBox = false
    
    if event.result then
        self.rewardData = event.result.data.reward
        self.itemNum = #self.rewardData
        self:updateUI()
    end
end

function ItemBoxRewardView:close()
    self:startHide()
end


return ItemBoxRewardView;
