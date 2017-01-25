local WorldStarRewardView = class("WorldStarRewardView", UIBase);

function WorldStarRewardView:ctor(winName,data)
    WorldStarRewardView.super.ctor(self, winName);

    self:initData(data)
end

function WorldStarRewardView:loadUIComplete()
	self:registerEvent();
    self:registClickClose("out")

    self:updateUI()
end 

function WorldStarRewardView:registerEvent()
	WorldStarRewardView.super.registerEvent();
    self.panel_bg.btn_close:setTap(c_func(self.press_panel_bg_btn_close, self));
end

function WorldStarRewardView:initData(data)
    self.maxRewardNum = 6

    -- 已获得星总数量
    self.ownStar = data.ownStar
    -- 解锁宝箱需求的总数量
    self.needStarNum = data.needStarNum
    self.storyId = data.storyId
    self.boxIndex = data.boxIndex

    -- 获取奖励数据
    self.storyData = FuncChapter.getStoryDataByStoryId(self.storyId)
    self.rewardData = self.storyData["bonus" .. self.boxIndex]
end 


function WorldStarRewardView:updateUI()
	local rewardNum = #self.rewardData

    for i=1,rewardNum do
        local itemView = self.panel_1["UI_"..i]
        itemView:setVisible(true)

        if i <= rewardNum then
            local rewardStr = self.rewardData[i]
            local params = {
                reward = rewardStr,
            }
            itemView:setRewardItemData(params)
            itemView:showResItemName(true)
            itemView:showResItemNum(false)
        else
            itemView:setVisible(false)
        end
    end

    for i=rewardNum+1,self.maxRewardNum do
        local itemView = self.panel_1["UI_"..i]
        itemView:setVisible(false)
    end

    -- 显示宝箱数量
    -- self.panel_3.txt_1:setString(GameConfig.getLanguageWithSwap("tid_common_1006",self.ownStar,self.needStarNum))
    
    -- local starTip = GameConfig.getLanguageWithSwap("tid_common_1006",self.ownStar,self.needStarNum)
    -- local rewardTip = "领取条件：副本评价达到" .. starTip .. "个特等"
    local rewardTip = GameConfig.getLanguageWithSwap("#tid1551",self.needStarNum)
    self.txt_1:setString(rewardTip)

    -- 根据宝箱状态，显示操作按钮的状态
    local boxStatus = WorldModel:getStarBoxStatus(self.storyId,self.ownStar,self.needStarNum,self.boxIndex)
    if boxStatus == WorldModel.starBoxStatus.STATUS_NOT_ENOUGH then
        self.mc_1:showFrame(2)
    elseif boxStatus == WorldModel.starBoxStatus.STATUS_ENOUGH then
        self.mc_1:showFrame(1)
    elseif boxStatus == WorldModel.starBoxStatus.STATUS_USED then
        self.mc_1:showFrame(3)
    end

    self.mc_1:setTouchedFunc(c_func(self.pressBtnAction,self,boxStatus))
end

function WorldStarRewardView:pressBtnAction(status)
    echo("pressBtnAction ==",status)
    if status == WorldModel.starBoxStatus.STATUS_NOT_ENOUGH or
        status == WorldModel.starBoxStatus.STATUS_USED then
        self:startHide()
    else
        echo("领取奖励")
        WorldServer:openStarBox(self.storyId,self.boxIndex,c_func(self.openStarBoxCallBack,self))
    end
end

function WorldStarRewardView:openStarBoxCallBack(event)
    echo("\n\nopenStarBoxCallBack =======")
    dump(event.result)

    if event.result ~= nil then
        self:startHide()

        local rewardData = event.result.data.reward
        FuncCommUI.startRewardView(rewardData)

        EventControler:dispatchEvent(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES)
    end
end

-- FuncCommUI.startRewardView(info.reward)

function WorldStarRewardView:press_panel_bg_btn_close()
    self:startHide()
end


return WorldStarRewardView;
