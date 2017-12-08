local WorldExtraRewardView = class("WorldExtraRewardView", UIBase);

function WorldExtraRewardView:ctor(winName,raidId,status)
    WorldExtraRewardView.super.ctor(self, winName);

    self.raidData = FuncChapter.getRaidDataByRaidId(raidId)
    local rewardArr = self.raidData.extraBonus

    self.raidId = raidId
    self.rewardData = rewardArr
    self.maxRewardNum = 3

    self.status = status
    -- 奖品数量
    self.rewardNum = #self.rewardData
end

function WorldExtraRewardView:loadUIComplete()
	self:registerEvent();
	-- FuncCommUI.addBlackBg(self._root)
    self:registClickClose("out")
    
	self:updateUI()
end 

function WorldExtraRewardView:registerEvent()
	WorldExtraRewardView.super.registerEvent();

    self.btn_close:setTap(c_func(self.startHide,self))
    self.mc_1:setTouchedFunc(c_func(self.openExtraBox,self))
end

function WorldExtraRewardView:updateUI()
	for i=1,self.rewardNum do
		local itemView = self["UI_" .. i]
        local rewardStr = self.rewardData[i]
        local params = {
            reward = rewardStr,
        }
        itemView:setRewardItemData(params)
        itemView:showResItemName(true)
        itemView:showResItemNum(false)
	end

	for i=self.rewardNum  + 1,self.maxRewardNum do
		local itemView = self["UI_" .. i]
        itemView:setVisible(false)
	end

    local tip = self:getRewardTip()
    self.txt_2:setString(tip)

    -- 宝箱状态
    local status = self.status
    if status == WorldModel.starBoxStatus.STATUS_NOT_ENOUGH then
        self.mc_1:showFrame(2)
    elseif status == WorldModel.starBoxStatus.STATUS_ENOUGH then
       self.mc_1:showFrame(1)
    elseif status == WorldModel.starBoxStatus.STATUS_USED then
       self.mc_1:showFrame(3)
    end
end

-- 打开额外宝箱
function WorldExtraRewardView:openExtraBox()
    if self.status == WorldModel.starBoxStatus.STATUS_ENOUGH then
        WorldServer:openExtraBox(self.raidId,c_func(self.openExtraBoxCallBack,self))
    else
        self:startHide()
    end
end

function WorldExtraRewardView:openExtraBoxCallBack(event)
    if event.result ~= nil then
        self:startHide()
        local rewardData = event.result.data.reward
        FuncCommUI.startRewardView(rewardData)

        EventControler:dispatchEvent(WorldEvent.WORLDEVENT_OPEN_EXTRA_BOXES,{raidId = self.raidId})
    end
end

function WorldExtraRewardView:getRewardTip()
    local storyId = self.raidData.chapter
    local storyData = FuncChapter.getStoryDataByStoryId(storyId)

    local chapter = storyData.chapter
    local section = self.raidData.section
    local raidName = GameConfig.getLanguage(self.raidData.name)

    local tip = GameConfig.getLanguageWithSwap("#tid1552",chapter .. "-" .. section)
    return tip
end

function WorldExtraRewardView:registerCloseAction()
	self:registClickClose()
end

return WorldExtraRewardView;
