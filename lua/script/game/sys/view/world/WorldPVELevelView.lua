local WorldPVELevelView = class("WorldPVELevelView", UIBase);

function WorldPVELevelView:ctor(winName,raidID)
    WorldPVELevelView.super.ctor(self, winName);

    self.curRaidId = raidID
    self.raidScore,self.condArr = WorldModel:getBattleStarByRaidId(self.curRaidId)
end

function WorldPVELevelView:loadUIComplete()
    WorldPVELevelView.super:loadUIComplete()
	self:registerEvent();
    self:registClickClose("out");

    self:initData()
    self:initView()
    self:updateUI()
end 

function WorldPVELevelView:registerEvent()
	WorldPVELevelView.super.registerEvent();
    self.btn_back:setTap(c_func(self.startHide, self));

    EventControler:addEventListener(UserEvent.USEREVENT_SP_CHANGE, self.onSpChange, self)

    -- 扫荡
    self.btn_sao:setTap(c_func(self.onSweepOne,self))

    -- 扫荡10次
    self.btn_sao10:setTap(c_func(self.onSweepTen,self))

    -- 进入战斗
    self.btn_zhan:setTap(c_func(self.onEnterBattle,self))
end

function WorldPVELevelView:initData()
    self.raidData = FuncChapter.getRaidDataByRaidId(self.curRaidId)
    self.spCost = self.raidData.spCost
    self.level = self.raidData.level
    
    self.maxRewardNum = 4

    self.sweetpType = {
        SWEEP_ONE = 1,
        SWEEP_TEN = 10
    }

    self.curSweepType = nil
end

function WorldPVELevelView:initView()
    FuncCommUI.setViewAlign(self.btn_back,UIAlignTypes.RightTop)

    self.npcId = self.raidData.npcMsg
    local npcInfo = FuncChapter.getNpcInfo(self.npcId)

    -- npc描述内容数组
    self.npcDescArr = self:getNpcDescContent(GameConfig.getLanguage(npcInfo.describe))
    self.mc_yidong:showFrame(#self.npcDescArr)

    -- 人物
    self.panel_ren = self.mc_yidong.currentView.panel_ren

    -- 立绘特效（背景特效，人物动画，人物动画上或下有特效）
    local npcImgId = self.raidData.npcImg2
    local npcSourceData = FuncTreasure.getSourceDataById(npcImgId)
    if not npcSourceData then
        echoWarn(npcImgId ,"_WorldPVEMainView界面,对应的soruceData暂时不存在_")
        npcSourceData = FuncTreasure.getSourceDataById("1")
    end
    local npcAnimName = npcSourceData.spine
    local npcAnimLabel = npcSourceData.stand

    if npcImgId == nil or npcAnimName == nil or npcAnimLabel == nil then
        echoError("npcImgId =",npcImgId,",npcAnimName=",npcAnimName,",npcAnimLabel=",npcAnimLabel)
    else
        local spbName = npcAnimName .. "Extract";
        local npcAnim = ViewSpine.new(spbName, {}, nil,npcAnimName);
        npcAnim:playLabel(npcAnimLabel);
        -- npcAnim:setRotationSkewY(180);
        npcAnim:pos(0,-70)
        
        local npcImg2Zoom = self.raidData.npcImg2Zoom
        if npcImg2Zoom == nil then
            echoError("WorldPVELevelView:initView npcImg2Zoom is nil")
        end
        local npcScale = (npcImg2Zoom and tonumber(npcImg2Zoom) / 100) or 1.2
        npcAnim:setScale(npcScale)

        -- Boss动画
        self.panel_ren.ctn_ren:addChild(npcAnim)
        -- 创建触摸Node
        local touchNode = display.newNode()
        touchNode:pos(-50,-100)
        touchNode:setContentSize(cc.size(150,200))
        self.panel_ren.ctn_ren:addChild(touchNode)
    end

    -- npc点击事件
    local npcId = self.raidData.npcMsg
    FuncCommUI.regesitShowNpcInfoTipView(self.panel_ren,npcId,true)
    -- 三星点击事件
    FuncCommUI.regesitShowStarTipView(self.mc_1,self.curRaidId)

    -- 更新奖品展示
    self:schedule(self.updateReward,1)
end

function WorldPVELevelView:updateUI()
    local namePanel = self.panel_1

    -- 背景图片
    local levelBgPath = FuncRes.iconPVE(self.raidData["levelImg"])
    local levelBgImg = display.newSprite(levelBgPath)
    self.ctn_gb:addChild(levelBgImg)

    local storyId  = self.raidData["chapter"]
    -- 章名字
    local storyData = FuncChapter.getStoryDataByStoryId(storyId)
    local chapter = storyData["chapter"]
    local storyName = storyData["name"]
    storyName = GameConfig.getLanguage(storyName)

    local raidName = self.raidData["name"]
    raidName = GameConfig.getLanguage(raidName)

    -- 节名字
    namePanel.txt_1:setString(raidName)

    -- 剧情介绍
    local raidDes = self.raidData["des"]
    raidDes = GameConfig.getLanguage(raidDes)
    self.txt_1:setString(raidDes)

    -- 三星mc
    local mcScore = self.mc_1
    if tonumber(self.raidScore) > 0 then
        mcScore:showFrame(self.raidScore)
    else
        -- 没有的成绩的怎么显示？
        mcScore:showFrame(4)
    end
    
    -- 描述
    self.panel_2 = self.mc_yidong.currentView.panel_2
    -- npc描述
    for i=1,2 do
        local txtDesc = self.panel_2["txt_" .. i]
        if txtDesc then
            txtDesc:setString(self.npcDescArr[i] or "")
        end
    end

    self:updateSpCost()
    self:updateSweepBtn()
    -- 普通奖励
    self:updateReward()
end

-- 获取npc描述内容
-- 如果描述内容超过1行，分割为两行
function WorldPVELevelView:getNpcDescContent(npcDescStr)
    local maxCharNumPerRow = 10
    local descArr = {}

    if string.utf8len(npcDescStr) <= maxCharNumPerRow then
        descArr[#descArr+1] = npcDescStr
    else
        descArr[#descArr+1] = string.subcn(npcDescStr,1,maxCharNumPerRow)
        descArr[#descArr+1] = string.subcn(npcDescStr,maxCharNumPerRow + 1,string.utf8len(npcDescStr))
    end

    return descArr
end

-- 更新奖品
function WorldPVELevelView:updateReward()
    local rewardArr = nil
    local rewardTip = ""

    -- 是否首次通关
    local isFirstPass = false
    if self.raidScore == WorldModel.stageScore.SCORE_LOCK then
        isFirstPass = true
        -- 首次通关奖励
        self.mc_ke:showFrame(1)
        rewardTip = GameConfig.getLanguage("#tid10101")
        rewardArr = self.raidData["firstBonus"]
    else
        -- 可能获得
        self.mc_ke:showFrame(2)
        rewardTip = GameConfig.getLanguage("#tid10102")
        rewardArr = self.raidData["bonusView"]
    end
    
    -- 奖励提醒
    self.mc_ke.currentView.txt_5:setString(rewardTip)

    local rewardNum = #rewardArr

    if rewardNum > self.maxRewardNum then
        rewardNum = self.maxRewardNum
    end

    -- 默认先隐藏全部
    for i=1,self.maxRewardNum do
        self["panel_daoju"..i]:setVisible(false)
    end

    for i=1,rewardNum do
        local rewardPanel = self["panel_daoju"..i]
        rewardPanel:setVisible(true)

        local rewardStr = rewardArr[i]
        local params = {
            reward=rewardStr,
        }
        rewardPanel.UI_1:setResItemData(params)
        rewardPanel.UI_1:setResItemClickEnable(true)
        if not isFirstPass then
            -- 隐藏数量
            rewardPanel.UI_1:showResItemNum(false)
        end

        local resNum,_,_ ,resType,resId = UserModel:getResInfo( rewardStr )
        FuncCommUI.regesitShowResView(rewardPanel.UI_1:getResItemIconCtn(),resType,resNum,resId,rewardStr)
    end

    -- 更新活动掉落倍数
    if not isFirstPass and WorldModel:isOpenDropActivity() then
        self:updateDropTimes(rewardNum,true)
    else
        self:updateDropTimes(rewardNum,false)
    end
end

-- 是否显示掉落倍数
function WorldPVELevelView:updateDropTimes(rewardNum,visible)
    local dropTimes = nil

    if visible then
        dropTimes = WorldModel:getDropTimes()
    end

    for i=1,rewardNum do
        local rewardPanel = self["panel_daoju"..i]
        local txtDropTimes = rewardPanel.txt_1

        txtDropTimes:setVisible(visible)
        if visible then
            txtDropTimes:setString("X" .. tostring(dropTimes))
        end
    end
end

-- 更新体力消耗
function WorldPVELevelView:updateSpCost()
    -- 更新体力展示
    local mySp = UserExtModel:sp()
    local txtSpCost = nil
    if mySp >= self.spCost then
        self.mc_red6:showFrame(1)
    else
        -- 不足
        self.mc_red6:showFrame(2)
    end

    txtSpCost = self.mc_red6.currentView.txt_1
    txtSpCost:setString(self.spCost)
end

-- 更新扫荡按钮
function WorldPVELevelView:updateSweepBtn()
    local times = 10
    local btnTip = nil

    -- 更新体力展示
    local mySp = UserExtModel:sp()
    -- 体力足够一次战斗
    if mySp >= self.spCost then
        local leftTimes = math.floor(mySp / self.spCost)
        -- 不足10次
        if leftTimes < times then
            times = leftTimes
        end
    end

    btnTip = GameConfig.getLanguageWithSwap("#tid10103",times)

    self.btn_sao10:setBtnStr(btnTip)
end

-- 当体力变化
function WorldPVELevelView:onSpChange()
    self:updateSpCost()
    self:updateSweepBtn()
end

-- 扫荡一次
-- todo 多语言ID
function WorldPVELevelView:onSweepOne()
    -- 扫荡次数
    local times = 1

    if not self:checkRaidStar() then
        return
    end

    local mySp = UserExtModel:sp()
    -- 体力不足
    if tonumber(mySp) < self.spCost then
        WindowControler:showWindow("CompBuySpMainView");
        return
    else
        self.curSweepType = self.sweetpType.SWEEP_ONE
        self:doSweep(self.curRaidId,times)
    end
end

-- 扫荡10次(体力不足，根据体力计算实际扫荡次数)
function WorldPVELevelView:onSweepTen()
    -- 扫荡次数
    local times = 10

    if not self:checkRaidStar() then
        return
    end

    local mySp = UserExtModel:sp()
     -- 体力不足
    if tonumber(mySp) < self.spCost then
        WindowControler:showWindow("CompBuySpMainView");
        return
    else
        self.curSweepType = self.sweetpType.SWEEP_TEN
        local leftTimes = math.floor(mySp / self.spCost)
        if leftTimes < times then
            times = leftTimes
        end
        self:doSweep(self.curRaidId,times)
    end
end

-- 扫荡
function WorldPVELevelView:doSweep(raidId,times)
    local sweepCallBack = function(serverData)
        if serverData and serverData.result ~= nil then
            local params = {
                rewardData = serverData.result.data.reward,
                targetData = nil,
                raidId = self.curRaidId
            }

            WindowControler:showWindow("WorldSweepListView",params)
        end
    end

    WorldServer:sweep(raidId,times,c_func(sweepCallBack))
end

-- 检查星级
function WorldPVELevelView:checkRaidStar()
    if self.raidScore == WorldModel.stageScore.SCORE_THREE_STAR then
        return true
    else
        -- 三星关卡才能扫荡
        local tipMsg = GameConfig.getLanguage("#tid10109")
        WindowControler:showTips(tipMsg)
        return false
    end
end

-- 开始战斗
function WorldPVELevelView:onEnterBattle()


    if not TeamFormationModel:checkInited(FuncTeamFormation.formation.pve) then
        --WindowControler:showTips("先设置上阵数据")
        --这是一种暂时的写法，因为新手引导回到阵容界面的
        TeamFormationModel:toInitializeFormation( FuncTeamFormation.formation.pve,c_func(self.doRealBattle,self) )
    else
        self:doRealBattle()
    end

	
end


--[[
真正执行战斗
]]
function WorldPVELevelView:doRealBattle(  )
    if not UserModel:tryCost(FuncDataResource.RES_TYPE.SP, tonumber(self.spCost), true) then
        return
    end

    WorldModel:setEnterPVEBattle(false)
    WorldServer:enterMainStage(self.curRaidId,c_func(self.enterMainStageCallBack,self))
end



-- 开始PVE战斗
function WorldPVELevelView:enterMainStageCallBack(event)
    if event.result ~= nil then
        self.battleId = event.result.data.battleInfo.battleId

        local battleInfo = {}
        battleInfo.battleUsers = event.result.data.battleInfo.battleUsers;
        battleInfo.randomSeed = event.result.data.battleInfo.randomSeed;
        battleInfo.inBattleDrop = event.result.data.battleInfo.battleParams.inBattleDrop;
        battleInfo.battleLabel = GameVars.battleLabels.worldPve
        
        -- dump(battleInfo.battleUsers)

        -- 缓存用户数据
        UserModel:cacheUserData()

        -- 保存当前战斗信息，战斗结算会用到
        local cacheBattleInfo = {}
        cacheBattleInfo.raidId = self.curRaidId
        cacheBattleInfo.battleId = self.battleId
        cacheBattleInfo.level = self.level
        -- 主角加经验(等于体力消耗)
        cacheBattleInfo.spCost = self.spCost
        -- 伙伴加经验
        cacheBattleInfo.heroAddExp = self.raidData.expPartner or 0

        WorldModel:resetDataBeforeBattle()
        WorldModel:setCurPVEBattleInfo(cacheBattleInfo)
        
        -- 设置关卡ID
        BattleControler:setLevelId(self.level,1);

         -- 初始化PVE战斗结果
        local cacheData = {
            battleRt = Fight.result_lose,
            raidId = self.curRaidId,
            -- 缓存关卡成绩
            raidScore = WorldModel:getBattleStarByRaidId(self.curRaidId)
        }
        WorldModel:setPVEBattleCache(cacheData)
        WorldModel:setEnterPVEBattle(true)

        -- 开始战斗
        BattleControler:startPVE(battleInfo)

        self:startHide()
    end
end

-- 报告战斗结果回调
function WorldPVELevelView:reportBattlResultCallBack(event)
    echo("reportBattlResultCallBack self.curRaidId=",self.curRaidId,self.battleRt,"serverData.data=",event.result)
    if event.result ~= nil then
        local serverData = event.result

        -- 额外奖励
        self.extraBonus = serverData.data.extraBonus

        -- 显示奖品列表界面
        local rewardData = {}
        rewardData.reward = serverData.data.reward
        rewardData.inBattleDrop = serverData.data.inBattleDrop
        rewardData.result = self.battleRt
        rewardData.star = self.battleStar
        -- zhangyg 服务器没有在该接口回传exp
        local cacheData = UserModel:getCacheUserData()
        if tonumber(Fight.result_win) == self.battleRt then
            rewardData.addExp = self.spCost
        else
            rewardData.addExp = 1
        end
        rewardData.preLv = cacheData.preLv
        rewardData.preExp = cacheData.preExp
        -- echo("rewardData==== pve")
        -- dump(rewardData)
        BattleControler:showReward(rewardData)
    end
end

function WorldPVELevelView:startHide()
    WorldPVELevelView.super:startHide()
    EventControler:dispatchEvent(WorldEvent.WORLDEVENT_PVE_CLOSE_LEVEL_VIEW); 
end

return WorldPVELevelView;
