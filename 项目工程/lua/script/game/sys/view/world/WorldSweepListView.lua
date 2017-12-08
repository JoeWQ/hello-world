--
-- Author: ZhangYanguang
-- Date: 2016-12-21
--
-- 扫荡奖品展示列表界面

local WorldSweepListView = class("WorldSweepListView", UIBase);

--[[
-- params结构
{
	rewardData = rewardData, 			--扫荡奖品
	targetData = targetData,	--目标数据
	raidId = raidId 			--关卡ID
}

-- targetData结构
{
	targetId = targetId,
	needNum = needNum,
}
--]]
function WorldSweepListView:ctor(winName,params)
    WorldSweepListView.super.ctor(self, winName);

    self.rewardData = params.rewardData
    self.targetData = params.targetData
    self.raidId = params.raidId
end

function WorldSweepListView:loadUIComplete()
	self:initData()
	self:initView()
	self:registerEvent()

	self:updateUI()
end

function WorldSweepListView:registerEvent()
	self.btn_close:setTap(c_func(self.onClose, self));
	self.btnConfirm:setTap(c_func(self.onClose, self));
end

-- 初始化数据
function WorldSweepListView:initData()
	-- 每次扫荡奖品最多数量
	self.rewardNumPerRow = 5
	
	local raidData = FuncChapter.getRaidDataByRaidId(self.raidId)
	-- 金币
	self.sweepCoin = raidData.coin
	-- 消耗的体力转经验值
    self.sweepExp = raidData.spCost

    self.sweepTimes = #self.rewardData
    self.totalSweepCoin = self.sweepCoin * self.sweepTimes
    self.totalSweepExp = self.sweepExp * self.sweepTimes

    -- todo 删除测试数据
	-- self.rewardData = {
	-- 	{
	-- 		reward = {"1,402,1","1,303,1","1,601,1","1,9601,1"},
	-- 		sweepReward = {"1,601,1","1,602,1"},
	-- 	},

	-- 	{
	-- 		reward = {"1,601,1","1,302,1","1,202,1","1,9603,1"},
	-- 		sweepReward = {"1,601,1","1,602,1","1,402,1","1,303,1"},
	-- 	},
	-- }

	self:resetData()
end

-- 重置数据
function WorldSweepListView:resetData()
	-- 行展示延迟秒
	self.rowDelaySec = 0.2
	-- 每个奖品展示延迟秒
	self.cellDelaySec = 0.2
	-- 滚动条行滚动时间
	self.scrollTime = self.rowDelaySec
	-- FadeIn动画时间
	self.rowFadeInTime = 0.2
	self.rewardFadeInTime = 0.2

	-- 是否展示中
	self.isShowing = false
	self.isSpeedUp = false
end

-- 初始化滚动条配置
function WorldSweepListView:initScrollCfg()
	local createItemView = function(itemView,rewardData)
		self:setRewardRowItemView(itemView,rewardData)
		-- 默认隐藏滚动条内容
		itemView:setVisible(false)
		itemView:setTouchedFunc(c_func(self.doSpeedUp,self))
		return itemView
	end

	-- 创建一次扫荡奖品
	local createRewardRowItemViewFunc = function(rewardData)
		local mcItemView = UIBaseDef:cloneOneView(self.mcItemView)
		mcItemView:showFrame(1)
		if #rewardData.reward > self.rewardNumPerRow then
			mcItemView:showFrame(2)
		end
		
		return createItemView(mcItemView.currentView,rewardData)
	end

	-- 创建总计扫荡奖品
	local createRewardRowTotalItemViewFunc = function(rewardData)
		local mcItemView = UIBaseDef:cloneOneView(self.mcItemTotalView)
		mcItemView:showFrame(1)
		if #rewardData.reward > self.rewardNumPerRow then
			mcItemView:showFrame(2)
		end

		return createItemView(mcItemView.currentView,rewardData)
	end

	-- 创建额外奖励
	local createExtraRewardRowItemViewFunc = function(rewardData)
		local itemView = UIBaseDef:cloneOneView(self.panelItemExtraView)
		return createItemView(itemView,rewardData)
	end

	-- 一行配置
	self.oneRowItemView = {
		data = nil,
        createFunc = createRewardRowItemViewFunc,
        itemRect = {x=0,y=0,width = 464,height = 147},
        perNums= 1,
        offsetX = 0,
        offsetY = 0,
        widthGap = 0,
        heightGap = 0,
        perFrame = 1000,
        test = 1,
	}

	-- 两行配置
	self.twoRowItemView = {
		data = nil,
        createFunc = createRewardRowItemViewFunc,
        itemRect = {x=0,y=0,width = 464,height = 231},
        perNums= 1,
        offsetX = 8,
        offsetY = 0,
        widthGap = 0,
        heightGap = 0,
        perFrame = 1000,
	}

	-- 总计奖励获得一行配置
	self.oneRowTotalItemView = {
		data = nil,
        createFunc = createRewardRowTotalItemViewFunc,
        itemRect = {x=0,y=0,width = 464,height = 150},
        perNums= 1,
        offsetX = 3,
        offsetY = 0,
        widthGap = 0,
        heightGap = 0,
        perFrame = 1000,
        test = 1,
	}

	-- 总计奖励获得两行配置
	self.twoRowTotalItemView = {
		data = nil,
        createFunc = createRewardRowTotalItemViewFunc,
        itemRect = {x=0,y=0,width = 464,height = 233},
        perNums= 1,
        offsetX = 3,
        offsetY = 0,
        widthGap = 0,
        heightGap = 0,
        perFrame = 1000,
        test = 1,
	}

	-- 额外奖励一行配置
	self.oneRowExtraItemView = {
		data = nil,
        createFunc = createExtraRewardRowItemViewFunc,
        itemRect = {x=0,y=0,width = 464,height = 147},
        perNums= 1,
        offsetX = 3,
        offsetY = 0,
        widthGap = 0,
        heightGap = 0,
        perFrame = 1000,
        test = 1,
	}
end

-- 初始化View
function WorldSweepListView:initView()
	-- 奖品滚动条
	self.scrollItemList = self.scroll_1

	-- 一次扫荡itemView
	self.mcItemView = self.mc_gc
	self.mcItemView:setVisible(false)

	-- 扫荡总结itemView
	self.mcItemTotalView = self.mc_zj
	self.mcItemTotalView:setVisible(false)

	-- 额外奖励itemView
	self.panelItemExtraView = self.panel_ew
	self.panelItemExtraView:setVisible(false)

	-- 确定按钮
	self.btnConfirm = self.btn_1
	self.btnConfirm:setVisible(false)

	-- 展示目标道具状态
	self.panelItemView_1 = self.panel_small1
	self.panelItemView_2 = self.panel_small2

	-- 初始化滚动配置
	self:initScrollCfg()

	self:initGlobalTouch()
end

-- 注册全局点击事件
function WorldSweepListView:initGlobalTouch()
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
	local listener = cc.EventListenerTouchOneByOne:create();

	local function onTouchBegan(touch, event)
		self:doSpeedUp()
	end
	
	listener:registerScriptHandler(onTouchBegan, 
            cc.Handler.EVENT_TOUCH_BEGAN);

	eventDispatcher:addEventListenerWithSceneGraphPriority(
            listener, self);
end

-- 更新UI
function WorldSweepListView:updateUI()
	-- 处理奖品数据
	self:processRewardData(self.rewardData)
	-- 获取展示目标道具
	self.targetItemsInfo = self:getSweepTargetItemsInfo(self.rewardData)
	self:initTargetItemsView()

	self.__listParams = self:buildItemScrollParams()
	self.scrollItemList:styleFill(self.__listParams)

	self.isShowing = true
	self:playRowRewardAnim()
end

-- 获得需要展示的目标道具
function WorldSweepListView:getSweepTargetItemsInfo(rewardData)
	local targetItemInfo = {}

	if self.targetData then
		local curItemInfo = table.deepCopy(self.targetData)
		-- 扫荡获取的数据
		local sweepNum = self:getSweepNum(curItemInfo.targetId)
		-- 扫荡前数量
		curItemInfo.ownNum = ItemsModel:getItemNumById(self.targetData.targetId) - sweepNum

		targetItemInfo[#targetItemInfo+1] = curItemInfo
	else
		local targetItems = WorldModel:getSweepTargetItems(rewardData)

		for i=1,#targetItems do
			local itemId = targetItems[i]
			-- 最多取2个
			if i > 2 then
				break 
			end

			-- todo 调用第三方系统接口获取
			local needNum = WorldModel:getPartnerPiecesNeedNum(itemId)
			-- 扫荡获取的数据
			local sweepNum = self:getSweepNum(itemId)
			-- 扫荡前数量
			local ownNum = ItemsModel:getItemNumById(itemId) - sweepNum

			targetItemInfo[#targetItemInfo+1] = {
				targetId = itemId,
				needNum = needNum,
				ownNum = ownNum
			}
		end
	end

	return targetItemInfo
end

-- 获得扫荡出该道具的总数量
function WorldSweepListView:getSweepNum(itemId)
	local countNum = function(rewardData,itemId)
		for i=1,#rewardData do
			local rewardStr = rewardData[i]
			local rewardArr = string.split(rewardStr,",")

			if tostring(rewardArr[2]) == tostring(itemId) then
				return rewardArr[3]
			end
		end

		return 0
	end

	local totalNum = countNum(self.totalReward,itemId)
	totalNum = totalNum + countNum(self.totalSweepReward,itemId)

	return totalNum
end

-- 处理原始奖品数据
-- 排序，统计累计奖品及额外获得(sweepReward)
function WorldSweepListView:processRewardData(rewardData)
	WorldModel:sortSweepRewards(self.rewardData)
	local totalReward,totalSweepReward = WorldModel:getCountRewards(self.rewardData)
	self.rewardData[#self.rewardData+1] = {reward = totalReward}
	self.rewardData[#self.rewardData+1] = {reward = totalSweepReward}

	self.totalReward = totalReward
	self.totalSweepReward = totalSweepReward
end

-- 动态构建滚动配置
function WorldSweepListView:buildItemScrollParams()
	local listParams = {}

	local oneRowItemView = nil
	local twoRowItemView = nil

	for i=1,#self.rewardData do
		local rewardNum = #self.rewardData[i].reward

		local rowParams = nil
		-- 倒数第二行，总计
		if i > 1 and i == #self.rewardData - 1 then
			oneRowItemView = self.oneRowTotalItemView
			twoRowItemView = self.twoRowTotalItemView
		elseif i > 1 and i == #self.rewardData then
			oneRowItemView = self.oneRowExtraItemView
		else
			oneRowItemView = self.oneRowItemView
			twoRowItemView = self.twoRowItemView
		end

		if rewardNum <= self.rewardNumPerRow then
			rowParams = table.deepCopy(oneRowItemView)
		else
			rowParams = table.deepCopy(twoRowItemView)
		end

		-- 位置修正
		if i==1 then
			rowParams.offsetY = 30
		end

		rowParams.data = {self.rewardData[i]}

		listParams[#listParams+1] = rowParams
	end

	return listParams
end

-- 动画加速
function WorldSweepListView:doSpeedUp()
	if self.isShowing then
		local scale = 5
		self.isSpeedUp = true

		-- self.rowDelaySec = self.rowDelaySec / 5
		self.cellDelaySec = self.cellDelaySec / scale
		self.scrollTime = self.rowDelaySec
	end
end

-- 初始化目标Items
function WorldSweepListView:initTargetItemsView()
	self.tempTargetItemNum = {}
	local targetItemNum = 0
	if self.targetItemsInfo then
		targetItemNum = #self.targetItemsInfo
	end

	for i=1,targetItemNum do
		local targetItem = self.targetItemsInfo[i]
		local targetId = targetItem.targetId
		local needNum = targetItem.needNum
		local ownNum = targetItem.ownNum

		local panelItem = self["panel_small" .. i]
		panelItem:setVisible(true)

		local rewardStr = self:findTargetReward(targetId)

		local compResItemView = panelItem["UI_1"]
		compResItemView:setResItemData({reward = rewardStr})
		compResItemView:showResItemName(false)
		compResItemView:showResItemNum(false)

		self.tempTargetItemNum[targetId] = ownNum
		self:updateOneTargetItemView(panelItem,ownNum,needNum)
	end

	if targetItemNum < 2 then
		for i=targetItemNum+1,2 do
			local panelItem = self["panel_small" .. i]
			panelItem:setVisible(false)
		end
	end
end

-- 更新目标Items
function WorldSweepListView:updateTargetItem(rewardStr)
	local sweepItemId = nil
	local sweepItemNum = nil

	if rewardStr then
		local rewardArr = string.split(rewardStr,",")
		if #rewardArr == 2 then
			sweepItemId = rewardArr[1]
			sweepItemNum = rewardArr[2]
		else
			sweepItemId = rewardArr[2]
			sweepItemNum = rewardArr[3]
		end

		if self.targetItemsInfo then
			for i=1,#self.targetItemsInfo do
				local targetItem = self.targetItemsInfo[i]
				local targetId = targetItem.targetId
				if tostring(sweepItemId) == tostring(targetId) then
					local panelItem = self["panel_small" .. i]
					panelItem:setVisible(true)

					local needNum = targetItem.needNum
					local ownNum = self.tempTargetItemNum[targetId] + sweepItemNum

					self:updateOneTargetItemView(panelItem,ownNum,needNum)
					self.tempTargetItemNum[targetId] = ownNum
				end
			end
		end
	end
end

-- 更新一个目标item
function WorldSweepListView:updateOneTargetItemView(panelItem,ownNUm,needNum)
	panelItem.mc_1:showFrame(1)
	if ownNUm < needNum then
		panelItem.mc_1:showFrame(2)
	end

	panelItem.mc_1.currentView.txt_1:setString(ownNUm .. "/" .. needNum)
	-- panelItem.txt_2:setString(needNum)
end

-- 根据itemId查找奖品字符串
function WorldSweepListView:findTargetReward(itemId)
	local findItem = function(rewardStr,itemId)
		local rewardArr = string.split(rewardStr,",")
		if tostring(rewardArr[2]) == tostring(itemId) then
			return true
		end

		return false
	end

	local rewardStr = nil
	for i=1,#self.totalReward do
		rewardStr = self.totalReward[i]
		if findItem(rewardStr,itemId) then
			return rewardStr
		end
	end

	for i=1,#self.totalSweepReward do
		rewardStr = self.totalSweepReward[i]
		if findItem(rewardStr,itemId) then
			return rewardStr
		end
	end

	return rewardStr
end

-- 动画播放结束
function WorldSweepListView:onPlayRewardAnimFinish()
	echo("动画播放结束")
	self:resetData()

	self.btnConfirm:setVisible(true)
end

-- 一个奖品展示完毕
function WorldSweepListView:onOneRewardUpdateFinish(rewardStr)
	self:updateTargetItem(rewardStr)
end

-- 展示扫荡结果中一行奖品动画
function WorldSweepListView:playRowRewardAnim()
	if not self.isShowing then
		return
	end

	if self.rowNum == nil then
		self.rowNum = 1
	end

	if self.rowNum > #self.__listParams then
		self:onPlayRewardAnimFinish()
		return
	end

	local rewardData = nil
	local rowItemView = nil

	local callBack = function()
		rowItemView:setVisible(true)
		self:gotoScrollTargetPos(self.rowNum,self.scrollTime)
		self.rowNum = self.rowNum + 1
	end

	-- 如果是加速
	if self.isSpeedUp then
		for i=1,(#self.__listParams - self.rowNum) + 1 do
			rewardData = self.__listParams[self.rowNum].data[1]
			rowItemView = self.scrollItemList:getViewByData(rewardData)

			self:showRowRewardItemView(rowItemView,rewardData,true)
			-- self.scrollItemList:gotoTargetPos(1,self.rowNum,1,self.scrollTime * i)
			self:gotoScrollTargetPos(self.rowNum,self.scrollTime,self.scrollTime * i)

			self.rowNum = self.rowNum + 1
		end
	else
		rewardData = self.__listParams[self.rowNum].data[1]
		rowItemView = self.scrollItemList:getViewByData(rewardData)
		FuncCommUI.playFadeInAnim(rowItemView,self.rowFadeInTime,callBack)
	end

	-- 总计及额外奖励，需要一次显示完所有奖品
	if self.rowNum == #self.__listParams - 1 then
		-- self.cellDelaySec = 0
		self.isSpeedUp = true
	end

	self:playOneRewardAnim(rowItemView,rewardData,1)
end

-- 跳转到滚动条指定位置
function WorldSweepListView:gotoScrollTargetPos(whichNum,scrollTime,delayTime)
	local callBack = function()
		self.scrollItemList:gotoTargetPos(1,whichNum,1,scrollTime)
	end

	if delayTime and delayTime > 0 then
		self:delayCall(c_func(callBack),delayTime)
	else
		callBack()
	end
end

-- 展示一次扫荡内容
function WorldSweepListView:showRowRewardItemView(rowItemView,rewardData,visible)
	rowItemView:setVisible(visible)
	for i=1,#rewardData.reward do
		rowItemView["UI_" .. i]:setVisible(visible)
	end
end

-- 展示扫荡结果中一个奖品的动画
function WorldSweepListView:playOneRewardAnim(rowItemView,rewardData,index)
	if not self.isShowing then
		return
	end

	if index > #rewardData.reward then
		self:delayCall(c_func(self.playRowRewardAnim,self), self.rowDelaySec)
		return
	end

	local nextIndex = nil

	-- 如果是加速
	if self.isSpeedUp then
		for i=index,#rewardData.reward do
			rowItemView["UI_" .. i]:setVisible(true)
			self:onOneRewardUpdateFinish(rewardData.reward[i])
		end

		nextIndex = #rewardData.reward + 1
		self:delayCall(c_func(self.playOneRewardAnim,self,rowItemView,rewardData,nextIndex), self.cellDelaySec)
	else
		local callBack = function()
			self:onOneRewardUpdateFinish(rewardData.reward[index])
			nextIndex = index + 1
			self:delayCall(c_func(self.playOneRewardAnim,self,rowItemView,rewardData,nextIndex), self.cellDelaySec)
		end

		-- nextIndex = index + 1
		-- rowItemView["UI_" .. index]:setVisible(true)
		-- self:delayCall(c_func(self.playOneRewardAnim,self,rowItemView,rewardData,nextIndex), self.cellDelaySec)

		-- 播放展示动画
		FuncCommUI.playFadeInAnim(rowItemView["UI_" .. index],self.rewardFadeInTime,callBack)
	end
end

-- 更新一行奖品（一次扫荡内容）
function WorldSweepListView:setRewardRowItemView(rowItemView,rowRewardData)
	local rewardArr = rowRewardData.reward

	-- 第几次扫荡
	local whichSweep = self:getDataIndex(rowRewardData)

	-- if rowItemView.txt_2 and rowItemView.txt_3 then
	if whichSweep <= self.sweepTimes then
		-- 第几次
		rowItemView.txt_1:setString(GameConfig.getLanguageWithSwap("#tid10100",WorldModel:convertSweepTime(whichSweep)))
		-- 经验
		rowItemView.txt_2:setString(self.sweepExp)
		-- 铜钱
		rowItemView.txt_3:setString(self.sweepCoin)

	-- 总结奖励
	elseif whichSweep ==  self.sweepTimes + 1 then
		-- 经验
		rowItemView.txt_1:setString(self.totalSweepExp)
		-- 铜钱
		rowItemView.txt_2:setString(self.totalSweepCoin)
	end
	
	self:hideAllItemView(rowItemView)

	for i=1,#rewardArr do
		local itemData = rewardArr[i]
		local itemView = rowItemView["UI_" .. i]
		self:updateOneItemView(itemView,itemData)
	end
end

-- 更新一个奖品道具ItemView
function WorldSweepListView:updateOneItemView(itemView,itemData)
	local data = {
		reward = itemData
	}
	itemView:setResItemData(data)
	itemView:showResItemName(false)
end

-- 根据奖品数据获取是第几次
function WorldSweepListView:getDataIndex(rowRewardData)
	for i=1,#self.rewardData do
		if self.rewardData[i] == rowRewardData then
			return i
		end
	end
end

-- 隐藏一行奖品中所有奖品itemView
function WorldSweepListView:hideAllItemView(rowItemView)
	for i=1,self.rewardNumPerRow * 2 do
		local compResItemView = rowItemView["UI_" .. i]
		if compResItemView then
			compResItemView:setVisible(false)
		end
	end
end

function WorldSweepListView:onClose()
	if self.isShowing then
		return
	end

	self:startHide()
end

return WorldSweepListView
