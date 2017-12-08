local RankMainView = class("RankMainView", UIBase);

function RankMainView:ctor(winName,data)
    RankMainView.super.ctor(self, winName);
    if data then
        self:initData(data)
    else
        WindowControler:showTips("RankMainView data is nil")
    end
end

function RankMainView:loadUIComplete()
    self:registerEvent();
    
    self:initScrollCfg()
    self:showRankListByTagType(self.tagType.TAG_TYPE_ABILITY)

    self.scroll_list:styleFill(self.scrollParams)
    self.scroll_list:onScroll(c_func(self.refreshRankData,self))
end 

function RankMainView:registerEvent()
    RankMainView.super.registerEvent();
    self.btn_back:setTap(c_func(self.press_btn_back, self));
    self.panel_5.btn_1:setTap(c_func(self.press_panel_5_btn_1, self));

    self.mc_1.currentView:setTouchedFunc(c_func(self.showRankListByTagType, self , self.tagType.TAG_TYPE_ABILITY));
    self.mc_2.currentView:setTouchedFunc(c_func(self.showRankListByTagType, self , self.tagType.TAG_TYPE_LEVEL));
    self.mc_3.currentView:setTouchedFunc(c_func(self.showRankListByTagType, self , self.tagType.TAG_TYPE_ENEGY));
    self.mc_4.currentView:setTouchedFunc(c_func(self.showRankListByTagType, self , self.tagType.TAG_TYPE_GUILD));
end

-- 滚动配置
function RankMainView:initScrollCfg()
    self.panel_5:setVisible(false)

    local createRankItemFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_5)
        self:updateRank(view,itemData)
        return view
    end

    self.scrollParams = {
        {
            data = self.rankListData,
            createFunc = createRankItemFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 0,
            itemRect = {x=147,y=-59,width=700,height=59},
            heightGap = 0,
            perFrame = 3,
        },
    }
end

-- 初始化常量数据等
function RankMainView:initData(data)
    -- 排行榜枚举类型，与服务端保持一致
    self.rankType = {
        RANK_TYPE_LEVEL = 1,
        RANK_TYPE_ABILITY = 2,
        RANK_TYPE_ENEGY = 3,
        RANK_TYPE_GUILD = 4
    }

    -- tag标签枚举类型
    self.tagType = {
        TAG_TYPE_ABILITY = 1,
        TAG_TYPE_LEVEL = 2,
        TAG_TYPE_ENEGY = 3,
        TAG_TYPE_GUILD = 4
    }

    -- 是否是初始化
    self.isInit = true

    -- 排名数据缓存
    self.rankListCache = {}

    -- 是否正在刷新
    self.isRefresh = false

    -- 最多50名
    self.maxRank = 50
    -- 仙盟最多显示10名
    self.maxGuildRank = 10

    -- 每次刷新的个数
    self.numPerRefresh = 10

    -- 前3名
    self.top3 = 3

    -- 排行榜类型数量
    self.maxRankTypeNum = 4

    -- 玩家自己的排名
    self.myRank = data.rank
    -- 玩家的自己的值（战斗力、威能值等)
    self.myScore = data.score

    -- 格式化排名数据
    self:initRankData(data.list)
end 

-- 初始化排名数据
function RankMainView:initRankData(rankList)
    self.rankListData = self:getFormatRankData(rankList)
    self.top3RankList = {}

    local endIdx = self.top3
    if #self.rankListData < endIdx then
        endIdx = #self.rankListData
    end

    -- 前3名的数据
    for i=1,endIdx do
        self.top3RankList[#self.top3RankList+1] = self.rankListData[i]
    end

    -- 第4名之后的数据
    for i=1,endIdx do
        table.remove(self.rankListData,1)
    end
end

-- 格式化排名数据，并排序
function RankMainView:getFormatRankData(rankList)
    local rankDataArr = {}
    if rankList then
        for k,v in pairs(rankList) do
            local idx = #rankDataArr+1
            rankDataArr[idx] = v
            rankDataArr[idx].id = k
        end
    end

    -- key排序
    table.sort(rankDataArr,function(a,b)
        return a.rank < b.rank
    end)

    return rankDataArr
end

-- 追加新的排名数据
function RankMainView:appendRankData(newRankList)
    local rankDataArr = self:getFormatRankData(newRankList)

    for i=1,#rankDataArr do
        self.rankListData[#self.rankListData+1] = rankDataArr[i]
    end
end

-- 滚动到底部再次刷新
function RankMainView:refreshRankData(event)
    if self.isRefresh then
        return
    end

    -- 最大排名数据
    local maxRank = self.maxRank

    -- 公会排行帮
    if self.curRankType == self.rankType.RANK_TYPE_GUILD then
        maxRank = self.maxGuildRank
    end

    -- 起始名次
    local beginRank = #self.top3RankList + #self.rankListData + 1
    -- 全部排名数据刷新完成
    if beginRank > maxRank then
        -- 缓存排名数据列表
        self:cacheRankListData(self.curRankType,self.rankListData)
        return
    end

    local groupIdx,posIdx = self.scroll_list:getGroupPos()
    -- 2表示剩余两条就开始刷新
    if posIdx < (#self.rankListData - 2) then
        return
    end

    -- 设置刷新标记为true
    self.isRefresh = true

    -- 结束名次
    local endRank = beginRank + self.numPerRefresh - 1
    if endRank >= maxRank then
        endRank = maxRank
    end

    -- 刷新回调
    local callBack = function(serverData)
        self.isRefresh = false
        -- dump(serverData)
        -- 刷新列表
        self:appendRankData(serverData.result.data.list)
        self:updateUI(false)
        self.scroll_list:gotoTargetPos(posIdx,1,2,false)
    end
    -- 刷新排名数据
    RankServer:getRankList(self.curRankType,beginRank,endRank,c_func(callBack))
end

-- 根据tag类型，展示排名列表
function RankMainView:showRankListByTagType(tagType)
    if self.curTagType == tagType then
        return
    end

    self.curTagType = tagType

    local rankType = self:getRankTypeByTagType(tagType)
    self.curRankType = rankType
    self:showRankList(rankType)
end

-- tagType转换为rankType
function RankMainView:getRankTypeByTagType(tagType)
    local rankType = nil
    if tagType == self.tagType.TAG_TYPE_ABILITY then
        rankType = self.rankType.RANK_TYPE_ABILITY
    elseif tagType == self.tagType.TAG_TYPE_LEVEL then
        rankType = self.rankType.RANK_TYPE_LEVEL
    elseif tagType == self.tagType.TAG_TYPE_ENEGY then
        rankType = self.rankType.RANK_TYPE_ENEGY
    elseif tagType == self.tagType.TAG_TYPE_GUILD then
        rankType = self.rankType.RANK_TYPE_GUILD
    end

    return rankType
end

-- 根据排名类型，展示排名列表
function RankMainView:showRankList(rankType)
    -- 如果是初始化，界面打开时已经获取了排名数据
    if self.isInit then
        self.isInit = false
        self:updateUI(false)
    else
        local rankList = self.rankListCache[rankType]
        -- 从缓存中获取排名数据
        if rankList ~= nil then
            self.rankListData = rankList
            self.scrollParams[1].data = self.rankListData
            self:updateUI(true)
        else
            RankServer:getRankList(rankType,1,self.numPerRefresh,c_func(self.getRankListCallBack,self))
        end
    end
end

-- 拉取排名数据回调
function RankMainView:getRankListCallBack(serverData)
    if serverData.result then
        -- 刷新排名列表
        self:initRankData(serverData.result.data.list)
        self:updateUI(true)
    else
        WindowControler:showTips("获取排名数据失败")
    end
end

-- 缓存排名数据
function RankMainView:cacheRankListData(rankType,rankListData)
    if self.rankListCache[rankType] == nil then
        self.rankListCache[rankType] = table.copy(rankListData)
    end
end

-- isGoFirst:刷新滚动条后，是否跳转到第一个item
function RankMainView:updateUI(isGoFirst)
    self:updateStatus()
    self:updateRankTop3()
    self:updateMyRank()

    self.scrollParams[1].data = self.rankListData
    self.scroll_list:styleFill(self.scrollParams)

    if isGoFirst then
        self.scroll_list:gotoTargetPos(1,1,0,false)
    end
end

-- 更新前3名玩家信息
function RankMainView:updateRankTop3()
    local endIdx = self.top3
    if #self.top3RankList < endIdx then
        endIdx = #self.top3RankList
    end

    -- 如果是仙盟，并且无排行榜数据
    if self.curRankType == self.rankType.RANK_TYPE_GUILD and #self.top3RankList == 0 then
        self.panel_kong:setVisible(true)
    else
        self.panel_kong:setVisible(false)
    end

    for i=1,endIdx do
        local playerData = self.top3RankList[i]
        local playerMc = self["mc_zhanshi"..i]
        playerMc:setVisible(true)

        -- 如果是仙盟
        if self.curRankType == self.rankType.RANK_TYPE_GUILD then
            playerMc:showFrame(2)
            local playerIconCtn = playerMc.currentView.panel_1.panel_tubiao.ctn_1
            local playerIcon = display.newSprite(FuncRes.iconGuild(playerData.id)):anchor(0,1)
            playerIcon:setScale(0.8)
            playerIconCtn:addChild(playerIcon)
        else
            playerMc:showFrame(1)
            local playerIconCtn = playerMc.currentView.panel_1.ctn_1
            local playerIcon = display.newSprite(FuncRes.iconHero(playerData.id)):anchor(0,1)
            playerIcon:setScale(1.5)
            playerIconCtn:addChild(playerIcon)
        end

        local playerPanel = playerMc.currentView.panel_1

        local playerName = playerData.name
        if playerName == nil or playerName == "" then
            playerName = "无"
        end

        -- 名称
        playerPanel.rich_1:setString(playerName)

        local rankKey = self:getLanguageKeyByTagType(self.curTagType)
        local rankValue = GameConfig.getLanguageWithSwap(rankKey,playerData.score)
        -- 排名数值
        playerPanel.rich_2:setString(rankValue)

        -- 点击展示玩家明细
        playerPanel:setTouchedFunc(c_func(self.showDetailInfo, self, playerData.id))
    end

    -- 排名数量少于3个，隐藏展示组件
    if endIdx < self.top3 then
        for i = (endIdx + 1),self.top3 do
            local playerMc = self["mc_zhanshi"..i]
            playerMc:setVisible(false)
        end
    end
end

-- 更新排名数据
function RankMainView:updateRank(itemView,data)
    local playerName = data.name
    if playerName == nil or playerName == "" then
        playerName = "无"
    end

    itemView.txt_1:setString(data.rank)
    itemView.txt_2:setString(playerName)

    local rankKey = self:getLanguageKeyByTagType(self.curTagType)
    local rankValue = GameConfig.getLanguageWithSwap(rankKey,data.score)
    itemView.txt_3:setString(rankValue)

    -- 测试数据
    local playerId = data.id
    itemView.btn_1:setTap(c_func(self.showDetailInfo, self, playerId))
end

function RankMainView:getLanguageKeyByTagType(tagType)
    local rankKey = nil
    if tagType == self.tagType.TAG_TYPE_ABILITY then
        rankKey = "tid_rank_1001"
    elseif tagType == self.tagType.TAG_TYPE_LEVEL then
        rankKey = "tid_rank_1002"
    elseif tagType == self.tagType.TAG_TYPE_ENEGY then
        rankKey = "tid_rank_1003"
    elseif tagType == self.tagType.TAG_TYPE_GUILD then
        rankKey = "tid_rank_1004"
    end
    return rankKey
end

-- 更新玩家自己的排名信息
function RankMainView:updateMyRank()
    local playerName = UserModel:name()
    if playerName == nil or playerName == "" then
        playerName = "无"
    end

    if self.curRankType == self.rankType.RANK_TYPE_GUILD then
        -- 玩家没有加入公会或者排行榜无任何数据
        if self.myRank == 0 or #self.top3RankList == 0 then
            self.mc_myInfo:showFrame(2)
            return
        end
    else
        self.mc_myInfo:showFrame(1)
    end
    
    if not self.myRank then
        self.myRank = 0
    end

    if not self.myScore then
        self.myScore = 0
    end
    self.mc_myInfo.currentView.txt_1:setString(self.myRank)
    self.mc_myInfo.currentView.txt_2:setString(playerName)

    local rankKey = self:getLanguageKeyByTagType(self.curTagType)
    local rankValue = GameConfig.getLanguageWithSwap(rankKey,self.myScore)
    self.mc_myInfo.currentView.txt_3:setString(rankValue)
end

-- 更新显示状态
function RankMainView:updateStatus()
    -- echo("self.curTagType=",self.curTagType)
    for i=1,self.maxRankTypeNum do
        if self.curTagType == i then
            self["mc_"..i]:showFrame(2);
        else
            self["mc_"..i]:showFrame(1);
        end
    end
end

-- 显示玩家明细
function RankMainView:showDetailInfo(targetId)
    if self.curRankType == self.rankType.RANK_TYPE_GUILD then
        local guildId = targetId
        self:showGuildDetail(guildId)
    else
        local playerId = targetId
        self:showPlayerDetail(playerId)
    end
end

-- 显示玩家明细
function RankMainView:showPlayerDetail(playerId)
    -- echo("showPlayerDetail")
    local callBack = function(serverData)
        if serverData.result then
            local playerData = serverData.result.data.data
            -- dump(playerData)
            WindowControler:showWindow("PlayerDetailView",playerData)
        else
            WindowControler:showTips("获取玩家信息失败")
        end
    end

    RankServer:getPlayInfo(playerId,c_func(callBack))
end

-- 显示公会明细
function RankMainView:showGuildDetail(guildId)
    -- echo("showGuildDetail guildId=",guildId)
    local callBack = function(serverData)
        if serverData.result then
            -- dump(serverData.result)
            local guildData = serverData.result.data.guild
            -- WindowControler:showWindow("PlayerDetailView",playerData)
            WindowControler:showWindow("GuildDetailView",guildData)
        else
            WindowControler:showTips("该仙盟已不存在")
        end
    end

    RankServer:getGuildInfo(guildId,callBack)
end

function RankMainView:press_btn_back()
    self:startHide();
end

function RankMainView:press_panel_5_btn_1()

end


return RankMainView;
