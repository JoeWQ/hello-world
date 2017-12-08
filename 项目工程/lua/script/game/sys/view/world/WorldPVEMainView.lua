--
-- Author: ZhangYanguang
-- Date: 2016-08-16
-- 副本主界面
local WorldPVEMainView = class("WorldPVEMainView", UIBase);

function WorldPVEMainView:ctor(winName)
    WorldPVEMainView.super.ctor(self, winName);
end

function WorldPVEMainView:loadUIComplete()
	self:playPVEMusic()

	self:registerEvent();
	self:initView()
	self:initData()
	self:initScrollCfg()

	self:updateUI()
end 

function WorldPVEMainView:playPVEMusic()
	AudioModel:stopMusic()
	AudioModel:playMusic(MusicConfig.m_scene_pve, true)
end

function WorldPVEMainView:registerEvent()
	self.btn_back:setTap(c_func(self.onClose, self));
	-- 阵容按钮
	self.btn_zhen:setTap(c_func(self.onEmbattle,self))
	-- 领取宝箱
    EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES,self.updateStarBoxes,self)

    -- 成绩更新
    -- EventControler:addEventListener(WorldEvent.WORLDEVENT_CHAPTER_STAGE_SCORE_UPDATE, self.updateUI, self)
    -- EventControler:addEventListener(WorldEvent.WORLDEVENT_CHAPTER_STAGE_SCORE_DELETE, self.updateUI, self)
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,self.onBattleClose,self)

    -- 额外宝箱更新
    EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_EXTRA_BOXES, self.onExtraBoxUpdate, self)
    -- 星级宝箱更新
    EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES, self.updateStarBoxes, self)

    -- 关闭关卡明细
    EventControler:addEventListener(WorldEvent.WORLDEVENT_PVE_CLOSE_LEVEL_VIEW,self.onCloseLevelView,self)

    local lastBtn = self.btn_left
    local nextBtn = self.btn_right
    lastBtn:setTap(c_func(self.goLastStory,self))
    nextBtn:setTap(c_func(self.goNextStory,self))
end

function WorldPVEMainView:initView()
	-- UI适配
    FuncCommUI.setViewAlign(self.panel_liujie,UIAlignTypes.LeftTop) 
    FuncCommUI.setViewAlign(self.btn_back,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.panel_qian,UIAlignTypes.MiddleTop)
    FuncCommUI.setViewAlign(self.panel_jdt,UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.btn_zhen,UIAlignTypes.RightTop)

    FuncCommUI.setScale9Align(self.panel_bg.scale9_heidai,UIAlignTypes.MiddleTop, 1, 0)

    -- 滚动条适配
    self.raidGroupScroller = self.scroll_1
    FuncCommUI.setScrollAlign(self.raidGroupScroller,UIAlignTypes.MiddleBottom,1,0)

    -- 开启新章云动画
    self.ctnStoryCloud = self.ctn_dayun

    -- 模板view
    -- 场景模板view
    self.panelGroup = self.panel_scene
    self.panelGroup:setVisible(false)

    -- 普通关卡view
    self.panelRaid = self.panel_pu
    self.panelRaid:setVisible(false)

    -- boss关卡view
    self.panelBossRaid = self.panel_boss
    self.panelBossRaid:setVisible(false)

    -- self:initAnim()
end

function WorldPVEMainView:initAnim()
	-- FuncArmature.loadOneArmatureTexture("UI_xunxian", nil, true)
end

function WorldPVEMainView:initData()
	self.nextGoalRaidId = WorldModel:findNextGoalRaidId(WorldModel:getUnLockMaxPVERaidId())

	self.curStoryId = WorldModel:getUnLockMaxMainStoryId()

	-- 是否是章初始化
	self.isStoryInit = true
	-- 模拟小场景数据
	-- self.raidGroupInfo = {
	-- 	{
	-- 		index = 1,
	-- 		rids = {10101}
	-- 	},
	-- 	{
	-- 		index = 2,
	-- 		rids = {10102,10103,10104}
	-- 	},
	-- 	{
	-- 		index = 3,
	-- 		rids = {10105}
	-- 	},
	-- 	{
	-- 		index = 4,
	-- 		rids = {10106}
	-- 	},
	-- }
end

function WorldPVEMainView:getNpcSound(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	local sound = "s_npc_common"
	if raidData and raidData.sectionMsc then
		sound = raidData.sectionMsc
	end

	return sound
end

function WorldPVEMainView:reInitData()
	self.isStoryInit = true
end

-- 初始化滚动配置
function WorldPVEMainView:initScrollCfg()
	local createRaidGroupFunc = function(itemData)
		local itemView = self:createRaidGroupItemView(itemData)
		return itemView
	end

	self.raidGroupInfo = WorldModel:getStoryGroupList(self.curStoryId)

	-- item分割线参数配置
    self.raidGroupListParams = {
	    {
	    	data = self.raidGroupInfo,
	        createFunc = createRaidGroupFunc,
	        itemRect = {x=0,y=-400,width = 550,height = 400},
	        perNums= 1,
	        offsetX = 0,
	        offsetY = 30,
	        widthGap = 7,
	        heightGap = 0,
	        -- Zhangyanguang 2017.01.09 每帧创建一个group
	        perFrame = 1
		}
    }

    self.raidGroupScroller:setOnCreateCompFunc(c_func(self.onScrollerCreated,self))
    -- 滚动条初始化
    self.raidGroupScroller:hideDragBar()
end

function WorldPVEMainView:onScrollerCreated()
	echo("onScrollerCreated")
end

function WorldPVEMainView:onBattleClose()
	if WorldModel:isPVEBattleWin() then
		self.onRaidChange = true
	end

	if self.onRaidChange then
		self.nextGoalRaidId = WorldModel:findNextGoalRaidId(WorldModel:getUnLockMaxPVERaidId())
		self:updateGlobalUI()
		echo("onRaidChange 执行各种动画逻辑...")
		self:playRaidChangeAnim()
	end
end

function WorldPVEMainView:onBecomeTopView()
	if WorldModel:isBackFromPVEBattle() then
		self:playPVEMusic()
		WorldModel:setEnterPVEBattle(false)
	end
end

function WorldPVEMainView:onRaidChangeAnimComplete()
	self.onRaidChange = false

	self:updateNextGoalRaidView()
end

-- 更新下一个关卡开启功能提醒
function WorldPVEMainView:updateNextGoalRaidView()
	if self.nextGoalRaidId then
		local raidView = self:findRaidView(self.nextGoalRaidId)
		if raidView then
			self:updateOneRaidView(raidView, self.nextGoalRaidId)
		end
	end
end

function WorldPVEMainView:updateGlobalUI()
	-- todo 暂时屏蔽龙的状态 by Zhangyanguang 01.01
	 -- 龙状态
    -- local isStoryFinal = WorldModel:isStoryFinal(self.curStoryId)
    -- if isStoryFinal then
    -- 	self.mc_long:showFrame(2)
    -- else
    -- 	self.mc_long:showFrame(1)
    -- end
    self.mc_long:showFrame(1)

	self:updateStoryInfo()
	self:updateActionStatus()
end

function WorldPVEMainView:updateUI()
	self:updateGlobalUI()

	self.raidGroupInfo = WorldModel:getStoryGroupList(self.curStoryId)
	-- 更新滚动条
    self.raidGroupListParams[1].data = self.raidGroupInfo

	-- 更新滚动条
	self:updateRaidGroupList()

	-- -- 做各种动画逻辑
	-- if self.onRaidChange then
	-- 	echo("onRaidChange 执行各种动画逻辑...")
	-- 	-- self:playRaidChangeAnim()
	-- 	-- self:delayCall(c_func(self.updateRaidGroupList,self),1.5)
	-- else
	-- 	-- 更新滚动条
	-- 	self:updateRaidGroupList()
	-- end
end

-- 播放节点变更动画逻辑
function WorldPVEMainView:playRaidChangeAnim()
	-- 刚通过的RaidId
	-- local curRaidId = UserExtModel:getMainStageId()
	local curRaidId = WorldModel:getPVEBattleCache().raidId
	local nextRaidId = WorldModel:getPVENextRaidId()
	local curGroupIndex = self:findGroupInex(curRaidId)
	
	local curRaidView = self:findRaidView(curRaidId)

	if not self:isFirstWin() then
		local raidView = self:findRaidView(curRaidId)
		self:updateOneRaidView(raidView, curRaidId)
		self:playScoreAnim(curRaidId,raidView)
		return
	end

	self.isPlayAnim = true
	-- 播放关闭动画
	self:delayCall(c_func(self.playRaidCloseAnim,self,curRaidId,curRaidView), 0.2)

	-- 刚通过的节点不是最后一节
	if not WorldModel:isLastRaidId(curRaidId) then
		local nextGroupIndex = self:findGroupInex(nextRaidId)
		-- 是同一分组
		if curGroupIndex == nextGroupIndex then
			local nextRaidView = self:findRaidView(nextRaidId)
			self:delayCall(c_func(self.playRaidOpenAnim,self,nextRaidId,nextRaidView), 0.6)

			self:delayCall(c_func(self.onPlayAnimComplete,self), 0.6)

			self:checkOpenShopByDelayTime(1.3)
		else
			-- 不是同一组，先播放分组云动画，再播放解锁动画
			local nextRaidView = self:findRaidView(nextRaidId)
			self:delayCall(c_func(self.playSceneCloudOpenAnim,self,nextRaidId), 0.6)
			self:delayCall(c_func(self.playRaidOpenAnim,self,nextRaidId,nextRaidView), 2.3)
			self:delayCall(c_func(self.onPlayAnimComplete,self), 2.3)

			self:checkOpenShopByDelayTime(3.0)
		end
	else
		-- 下一章开启了
		if self:checkGoNextStory() then
			-- 自动切换到下一章
			self:delayCall(c_func(self.autoGoNextStory,self), 0.5)
			self:delayCall(c_func(self.onPlayAnimComplete,self), 4)

			self:checkOpenShopByDelayTime(1.2)
		else
			self.isPlayAnim = false
			-- 下一章还没有开启
			self:onRaidChangeAnimComplete()
			self:checkOpenShopByDelayTime()
		end
	end
end

function WorldPVEMainView:onPlayAnimComplete()
	self.isPlayAnim = false
end

-- 检查临时商店是否开启
function WorldPVEMainView:checkOpenShopByDelayTime(delayTime)
    local openShop = function()
    	local openShopType = WorldModel:getOpenShopType()
	    if openShopType ~= nil then
	        WindowControler:showWindow("ShopKaiqi", openShopType)
	    end
	end

	if delayTime == nil or delayTime == 0 then
		openShop()
	else
		self:delayCall(c_func(openShop), delayTime)
	end
end

-- 判断关卡是否是首次通关
function WorldPVEMainView:isFirstWin()
	local cacheScore = WorldModel:getPVEBattleCache().raidScore
	if cacheScore == WorldModel.stageScore.SCORE_LOCK then
		return true
	else
		return false
	end
end

-- 自动切换章
function WorldPVEMainView:autoGoNextStory()
	-- 播放关闭当前章，开启下一章的云动画
	self:playStoryCloudOpenAnim()
	-- 播放动画期间，刷新下一章内容
	self:autoUpdateNextStory()

	-- 下一章第一个关卡ID
	local nextRaidId = WorldModel:getNextPVERaidId()
	-- 播放下一章小场景开启动画
	self:delayCall(c_func(self.playSceneCloudOpenAnim,self,nextRaidId), 0.8)

	-- 播放下一章第一个关卡开启动画
	local raidView = self:findRaidView(nextRaidId)
	self:delayCall(c_func(self.playRaidOpenAnim,self,nextRaidId,raidView), 2.0)
end

-- 自动刷新下一章内容，但是不执行动画
function WorldPVEMainView:autoUpdateNextStory()
	-- self:reInitData()
	local nextStoryId = WorldModel:getNextStoryId(self.curStoryId)
	self.curStoryId = nextStoryId

	self:updateUI()
end

function WorldPVEMainView:onClose()
	AudioModel:stopMusic()
	self:startHide()
	-- local raidId = "10401"
	-- local raidView = self:findRaidView(raidId)
	-- self:playRaidCloseAnim(anim,raidView)
	-- self:playScoreAnim(raidId,raidView)
end

-- 播放节点开启
function WorldPVEMainView:playRaidOpenAnim(raidId,raidView)
	if self.onRaidChange then
		-- 更新状态
		self:updateOneRaidView(raidView, raidId)
		self:delayCall(c_func(self.onRaidChangeAnimComplete,self), 0.5)
	end

	local raidKind = WorldModel:getRaidKind(raidId)
	if raidKind == WorldModel.kind.KIND_BOSS then
		self:createBossRaidOpenAnim(raidId,raidView)
	else
		self:createRaidOpenAnim(raidId,raidView)
	end
end

-- todo 需要根据新需求来做
-- 播放成绩动画
function WorldPVEMainView:playScoreAnim(raidId,raidView)
	-- local mcRaid = raidView.btn_pu:getUpPanel().mc_pu1
	-- local raidScore = WorldModel:getBattleStarByRaidId(raidId)

	-- local mcScore = mcRaid.currentView.mc_fbpz
	-- local ctnScoreAnim = mcRaid.currentView.ctn_pingji

	-- local anim = self:createUIArmature("UI_xunxian","UI_xunxian_dengji",ctnScoreAnim, false, GameVars.emptyFunc)
	-- anim:pos(0,0)
	-- FuncArmature.changeBoneDisplay(anim , "node2", mcScore.currentView)
	-- anim:startPlay(false)
end

-- 创建boss关卡节点解锁动画
function WorldPVEMainView:createBossRaidOpenAnim(raidId,raidView)
	local ctnArrow = raidView.ctn_jian
	local mcRaid = raidView.btn_pu:getUpPanel().mc_pu1
	-- local ctnAnim = mcRaid.currentView.ctn_gh
	local ctnShineAnim = mcRaid.currentView.ctn_guang

	-- ctnAnim:removeAllChildren()
	ctnShineAnim:removeAllChildren()

	local lightAnim = self:createUIArmature("UI_xunxian","UI_xunxian_bossguanka",ctnShineAnim, false, GameVars.emptyFunc)
	lightAnim:setScale(1)
	lightAnim:pos(-18,-95)
	-- lightAnim:startPlay(false)

	lightAnim:runEndToNextLabel(0,1,true)

	local arrowAnim = self:createUIArmature("UI_xunxian","UI_xunxian_jiantou",ctnArrow, true, GameVars.emptyFunc)
	arrowAnim:pos(0,0)
end

-- 创建节点解锁动画
function WorldPVEMainView:createRaidOpenAnim(raidId,raidView)
	local ctnAnim = raidView.btn_pu:getUpPanel().ctn_gh
	if ctnAnim:getChildrenCount() > 0 then
		return
	end

	local mcRaid = raidView.btn_pu:getUpPanel().mc_pu1
	local anim = self:createUIArmature("UI_xunxian","UI_xunxian_guanka",ctnAnim, false, GameVars.emptyFunc)
    anim:pos(0,0)

    -- todo
    -- 临时修改动画到头像框的底层 by Zhangyanguang 2016.12.28 
    -- mcRaid.currentView:pos(-60,60)
   	-- FuncArmature.changeBoneDisplay(anim , "node", mcRaid.currentView)
	anim:playWithIndex(0,false)
end

-- 播放关闭开启
function WorldPVEMainView:playRaidCloseAnim(raidId,raidView)
	local mcRaid = raidView.btn_pu:getUpPanel().mc_pu1
	local raidKind = WorldModel:getRaidKind(raidId)

	local callBack = function()
		self:updateOneRaidView(raidView, raidId)
		self:playScoreAnim(raidId,raidView)
	end

	if raidKind == WorldModel.kind.KIND_BOSS then
		callBack()
	else
		local ctnAnim = raidView.btn_pu:getUpPanel().ctn_gh
		if ctnAnim then
			local anim = ctnAnim:getChildren()[1]
			anim:playWithIndex(1,false)

		    anim:registerFrameEventCallFunc(10, 1, c_func(callBack))
		end
	end
end

-- 播放关闭开启
-- todo
function WorldPVEMainView:playRaidCloseAnim_old(raidId,raidView)
	local mcRaid = raidView.btn_pu:getUpPanel().mc_pu1
	local ctnAnim = raidView.btn_pu:getUpPanel().ctn_gh

	if ctnAnim then
		FuncArmature.takeNodeFromBoneToParent(mcRaid.currentView,raidView)
		ctnAnim:removeAllChildren()

		local anim = self:createUIArmature("UI_xunxian","UI_xunxian_guanbi",ctnAnim, false, GameVars.emptyFunc)
	    anim:pos(0,0)
	    FuncArmature.changeBoneDisplay(anim , "node", mcRaid.currentView)
	    anim:startPlay(false)

	    local callBack = function()
	    	self:updateOneRaidView(raidView, raidId)
	    	self:playScoreAnim(raidId,raidView)
		end
	    anim:registerFrameEventCallFunc(anim.totalFrame, 1, c_func(callBack))
	end
end

-- 创建节点解锁动画
-- todo
function WorldPVEMainView:createRaidOpenAnim_old(raidId,raidView)
	local ctnAnim = raidView.btn_pu:getUpPanel().ctn_gh
	if ctnAnim:getChildrenCount() > 0 then
		return
	end

	local mcRaid = raidView.btn_pu:getUpPanel().mc_pu1
	local anim = self:createUIArmature("UI_xunxian","UI_xunxian_kaiqi",ctnAnim, false, GameVars.emptyFunc)
    anim:pos(0,0)

    local nodeAnim = anim:getBoneDisplay("node")
    nodeAnim:pos(0,0)
    mcRaid.currentView:pos(-100,100)
    FuncArmature.changeBoneDisplay(nodeAnim , "layer5", mcRaid.currentView)
    anim:startPlay(false)
end

-- 播放章开启云动画
function WorldPVEMainView:playStoryCloudOpenAnim()
	if self.storyCloudAnim then
		 self.storyCloudAnim:startPlay(false)
		 return
	end

	local anim = self:createUIArmature("UI_xunxian","UI_xunxian_yundakai",self.ctnStoryCloud, false, GameVars.emptyFunc)
    anim:pos(0,0)
    anim:startPlay(false)

    self.storyCloudAnim = anim
end

-- 播放场景开启云动画
-- frame 60
function WorldPVEMainView:playSceneCloudOpenAnim(raidId)
	self:setCurGroupInListCenter()

	local groupView = self:findGroupView(raidId)
	local ctnCloud = groupView.ctn_1

	local cloudAnim = nil
	if ctnCloud:getChildren() then
		cloudAnim = ctnCloud:getChildren()[1]
		if cloudAnim then
			cloudAnim:startPlay(false)
		else
			cloudAnim = self:createUIArmature("UI_xunxian","UI_xunxian_zubiekaiqi",ctnCloud, false, GameVars.emptyFunc)
		    cloudAnim:pos(0,0)
		    cloudAnim:startPlay(false)
		end
	end
end

-- 更新章信息
function WorldPVEMainView:updateStoryInfo()
	-- 下一个解锁的关卡
	self.nextUnLockRaidId = WorldModel:getPVENextRaidId()
	self.storyData = FuncChapter.getStoryDataByStoryId(self.curStoryId)
	local chapter = self.storyData["chapter"]

	local storyName = self.storyData["name"]
	storyName = GameConfig.getLanguage(storyName)

	local txtStory = self.mc_long.currentView.btn_1:getUpPanel().txt_1
	local txtName = self.mc_long.currentView.btn_1:getUpPanel().txt_2

	-- 第几章
	if chapter == 0 then
		txtStory:setString("序章")
	else
		txtStory:setString(GameConfig.getLanguageWithSwap("#tid10104",WorldModel:getChapterNum(chapter)))
	end

	-- 章名称
	txtName:setString(storyName)

	-- 更新星级宝箱状态
	self:updateStarBoxes()
end

-- 更新滚动条
function WorldPVEMainView:updateRaidGroupList()
	self.raidGroupScroller:cancleCacheView()
    self.raidGroupScroller:styleFill(self.raidGroupListParams)
    -- self.raidGroupScroller:setScrollBorder(-220)
    --朝中心适配border
    self.raidGroupScroller:setScrollBorder( -self.raidGroupScroller.viewRect_.width/2 + self.raidGroupListParams[1].itemRect.width/2  )

    self:setCurGroupInListCenter()
end

-- 更新星级宝箱
function WorldPVEMainView:updateStarBoxes()
	-- 宝箱
    local boxPanel = self.panel_jdt
    self.boxPanel = boxPanel

    local storyData = self.storyData

    -- 已拥有宝箱数量
    self.ownStar = WorldModel:getTotalStarNum(self.curStoryId)

    for i=1,3 do
        -- 宝箱数量
        local needStarNum = storyData.bonusCon[i]
        local panelBox = boxPanel["panel_box"..i]

        -- 星星mc
        local mcStar = panelBox.mc_1

        -- 需要三星的总数量
        panelBox.txt_1:setString(needStarNum)
       
        -- 判断宝箱状态
        local boxIndex = i
        local boxStatus = WorldModel:getStarBoxStatus(self.curStoryId,self.ownStar,needStarNum,boxIndex)

        -- 默认点亮星星
        mcStar:showFrame(1)

        -- 不满足开宝箱条件
        if boxStatus == WorldModel.starBoxStatus.STATUS_NOT_ENOUGH then
        	mcStar:showFrame(1)
            panelBox.mc_box:showFrame(1)
            self:playStarBoxAnim(panelBox,false)
        -- 满足开宝箱条件
        elseif boxStatus == WorldModel.starBoxStatus.STATUS_ENOUGH then
        	panelBox.mc_box:showFrame(2)
        	self:playStarBoxAnim(panelBox,true)
        elseif boxStatus == WorldModel.starBoxStatus.STATUS_USED then
            -- 显示已领取
            panelBox.mc_box:showFrame(3)
            self:playStarBoxAnim(panelBox,false)
        end
        
        panelBox:setTouchSwallowEnabled(true)
        panelBox:setTouchedFunc(c_func(self.openStarBoxes,self,boxIndex,needStarNum))
    end

     -- 设置进度条
    local preogress = boxPanel.panel_jin.progress_huang
    local percent = self.ownStar / storyData.bonusCon[3] * 100

    preogress:setDirection(ProgressBar.l_r)
    preogress:setPercent(percent)
    -- 更新云的进度
    self:updateProgressCloud(preogress,percent)
end

-- isPlay,true表示播放动画；false表示不播放动画，如果ctn已经有动画，需要做换装的反动作，并删除动画
function WorldPVEMainView:playStarBoxAnim(panelBox,isPlay)
	local ctnBox = panelBox.ctn_xing1
	if isPlay then
		if ctnBox:getChildrenCount() == 0 then
			panelBox.mc_box:setVisible(false)
			local mcView = UIBaseDef:cloneOneView(panelBox.mc_box)
			local anim = self:createUIArmature("UI_xunxian","UI_xunxian_xingjibaoxiang",ctnBox, false, GameVars.emptyFunc)
	    	-- anim:pos(0,0)
	    	mcView.currentView:pos(-1,5)
	    	FuncArmature.changeBoneDisplay(anim,"node",mcView)
	    	anim:startPlay(true)
		end
	else
		if ctnBox:getChildrenCount() > 0 then
			panelBox.mc_box:setVisible(true)
			ctnBox:removeAllChildren()
		end
	end
end

function WorldPVEMainView:updateProgressCloud(progressView,percent)
	local box = progressView:getContainerBox()
	-- local totalWidth = box.width
	local totalWidth = 398
	local x = math.ceil(percent)*1.0/100 * totalWidth-12
	local y = -box.height/2 + 15
	self.boxPanel.panel_jin.panel_cloud:pos(x,y)
end

function WorldPVEMainView:createRaidGroupItemView(itemData)
	local index = itemData.index

	local itemView = UIBaseDef:cloneOneView(self.panelGroup)
	itemView:setVisible(true)

	self:updateOneGroupView(itemView,itemData)
	return itemView
end

-- 更新一个小场景GroupView
function WorldPVEMainView:updateOneGroupView(groupView,itemData)
	-- 关卡数量
	local raidNum = #itemData.rids
	if raidNum == 0 then
		return
	end

	-- 小场景配置数据
	local sceneData = FuncChapter.getOneSceneData(self.curStoryId,itemData.index)

	-- 场景背景图片
	local sceneBgIconName = sceneData.bgName
	-- 背景坐标
	local sceneBgPos = {x=0,y=0}
	if sceneData.bgPos and sceneData.bgPos[1] then
		sceneBgPos = sceneData.bgPos[1]
	end

	-- 名称坐标
	local namePos = {x=0,y=0}
	if sceneData.namePos and sceneData.namePos[1] then
		namePos = sceneData.namePos[1]
	end

	-- 节点坐标数组
	local raidPosArr = sceneData.position
	local sceneName = sceneData.name

	-- 场景名称
	groupView.panel_name:pos(namePos.x,-namePos.y)
	groupView.panel_name.txt_1:setString(GameConfig.getLanguage(sceneName))
	-- 场景背景
	local sceneBgIconPath = FuncRes.iconPVE(sceneBgIconName)
	local sceneBgIcon = display.newSprite(sceneBgIconPath)
	-- 设置背景坐标
	sceneBgIcon:pos(sceneBgPos.x,-sceneBgPos.y)
	sceneBgIcon:setAnchorPoint(cc.p(0.5,0))
	groupView.ctn_bg:addChild(sceneBgIcon)

	-- 更新场景云遮罩
	local storyUnlockMaxRaidId = WorldModel:getUnLockMaxPVERaididByStoryId(self.curStoryId)
	local groupIndex = 0

	if not WorldModel:isLastRaidId(storyUnlockMaxRaidId) then
		groupIndex = self:findGroupInex(storyUnlockMaxRaidId)
	else
		groupIndex = #self.raidGroupInfo
	end

	-- 云动画停到第一帧，实现云遮罩，
	if tonumber(itemData.index) > groupIndex then
		local ctnCloud = groupView.ctn_1
		local cloudAnim = self:createUIArmature("UI_xunxian","UI_xunxian_zubiekaiqi",ctnCloud, false, GameVars.emptyFunc)
	    cloudAnim:pos(0,0)
	    cloudAnim:gotoAndPause(0)
	end

	-- 创建小场景中的关卡节点
	for i=1,raidNum do
		local curRaidId = itemData.rids[i]
		local curRaidPos = raidPosArr[i]

		-- 创建panel
		local curRaidView = self:createRaidView(curRaidId)
		groupView:addChild(curRaidView)
		curRaidView:pos(curRaidPos.x,-curRaidPos.y)
		-- 为新创建的panel命名
		groupView["panel_" .. i] = curRaidView
		self:updateOneRaidView(curRaidView, curRaidId)
	end


	if itemData.index == #self.raidGroupInfo then
		self:onRaidCreateComplete()
	end
end

-- 关卡创建完成
function WorldPVEMainView:onRaidCreateComplete()
	if self.isStoryInit then
		self.isStoryInit = false
	end
end

-- 创建RaidView
function WorldPVEMainView:createRaidView(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	-- 关卡类型及额外宝箱
    local raidKind = raidData.kind

    local raidView = nil
    if raidKind == WorldModel.kind.KIND_BOSS then
    	raidView = UIBaseDef:cloneOneView(self.panelBossRaid)
    else
    	raidView = UIBaseDef:cloneOneView(self.panelRaid)
    end

    raidView:setVisible(true)
    return raidView
end

-- 更新一个关卡RaidView
function WorldPVEMainView:updateOneRaidView(raidView,raidId)
	-- 如果是首尾关卡
	if raidView.btn_pu == nil then
		return
	end
	
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	-- 关卡类型及额外宝箱
    local raidKind = raidData.kind
	local isLock = false

	local mcRaid = raidView.btn_pu:getUpPanel().mc_pu1
	local mcBox = raidView.btn_box:getUpPanel().mc_box1

	-- 下一关通关解锁提醒
	local mcNextRaidOpenTip = raidView.mc_shangxia
	mcNextRaidOpenTip:setVisible(false)
	mcNextRaidOpenTip:showFrame(1)

	-- 头像缩放比例
	local headScale = 0.7
	local passMaxRaidId = UserExtModel:getMainStageId()
	-- 通关的
    if tonumber(raidId) < tonumber(self.nextUnLockRaidId) or tonumber(raidId) == tonumber(passMaxRaidId) then
    	mcRaid:showFrame(3)
    -- 当前关卡
    elseif tonumber(raidId) == tonumber(self.nextUnLockRaidId) then
    	mcRaid:showFrame(2)
    	headScale = 0.85

    	self.curRaidId = raidId
    	-- echo("self.curRaidId=",self.curRaidId)
    	-- 关卡名称
		local txtRaidName = mcRaid.currentView.txt_1
		local raidName = GameConfig.getLanguage(raidData.name)
		txtRaidName:setString(raidName)

		if self.isStoryInit then
			if raidKind == WorldModel.kind.KIND_BOSS then
				self:createBossRaidOpenAnim(raidId,raidView)
			else
				self:createRaidOpenAnim(raidId,raidView)
			end
		end

		-- boss关卡始终使用第一帧
		if raidKind ~= WorldModel.kind.KIND_BOSS then
			mcNextRaidOpenTip:showFrame(2)
		end
    -- 没有解锁的
    else
    	mcRaid:showFrame(1)
    	isLock = true
    end

    if tonumber(raidId) == tonumber(self.nextGoalRaidId) then
    	mcNextRaidOpenTip:setVisible(true)
		local goalTid = raidData["goal"]
		if goalTid then
			local tipStr = GameConfig.getLanguage(raidData["goal"])
			mcNextRaidOpenTip.currentView.panel_1.txt_1:setString(tipStr)
		end
	end

	-- 设置boss头像或动画
    if raidKind == WorldModel.kind.KIND_BOSS then
    	-- boss动画
    	local ctnBoss = mcRaid.currentView.ctn_boss
		if ctnBoss then
			local npcAnim = self:createNpcSpineAnim(raidId)
			ctnBoss:removeAllChildren()
			ctnBoss:addChild(npcAnim)
		end
    else
    	-- boss头像
    	local ctnHead = mcRaid.currentView.ctn_small
	    if ctnHead then
			-- boss头像
			local heroIconPath = FuncChapter.getRaidAttrByKey(raidId,"sectionImg")
			local heroIcon = display.newSprite(FuncRes.iconHead(heroIconPath))
			-- heroIcon:setRotationSkewY(180);
			heroIcon:pos(0,0)
			ctnHead:removeAllChildren()
			ctnHead:setScale(headScale)
			ctnHead:addChild(heroIcon)
		end
    end

	-- 设置头像框状态及更新额外宝箱状态
	if raidKind == WorldModel.kind.KIND_NORMAL then
		-- 头像圈
    	local mcHeadBg = mcRaid.currentView.mc_kuang
    	mcHeadBg:showFrame(1)

		mcBox:setVisible(false)
	elseif raidKind == WorldModel.kind.KIND_ELITE then
		-- 头像圈
    	local mcHeadBg = mcRaid.currentView.mc_kuang
    	mcHeadBg:showFrame(2)
		mcBox:setVisible(true)

		-- 更新额外宝箱状态
		self:updateExtraBoxStatus(mcBox,raidId)
	elseif raidKind == WorldModel.kind.KIND_BOSS then
		mcBox:setVisible(true)

		-- 更新额外宝箱状态
		self:updateExtraBoxStatus(mcBox,raidId)
	end

	if isLock then
		FilterTools.setFlashColor(mcRaid.currentView,"pveRaidLight")
	else
		FilterTools.clearFilter(mcRaid.currentView)
	end

	raidView.btn_pu:setTap(c_func(self.onClickRaidView, self,raidId,isLock));

	-- 更新成绩
	self:updateRaidScore(raidView,raidId)
end

-- 监听到领取额外宝箱成功的消息
function WorldPVEMainView:onExtraBoxUpdate(event)
	local raidId = event.params.raidId

	local raidView = self:findRaidView(raidId)
	self:updateOneRaidView(raidView, raidId)
end

function WorldPVEMainView:updateExtraBoxStatus(mcBox,raidId)
	local status = WorldModel:getExtraBoxStatus(raidId)
	-- echo("status,raidId===",status,raidId)
	
	mcBox:setVisible(true)
	if status == WorldModel.starBoxStatus.STATUS_NOT_ENOUGH then
		mcBox:showFrame(1)
	elseif status == WorldModel.starBoxStatus.STATUS_ENOUGH then
		-- 第2帧，没有宝箱图片，使用动画
		mcBox:showFrame(2)
		local ctnBoxAnim = mcBox.currentView.ctn_bc
		self:playExtraBoxAnim(ctnBoxAnim)
	elseif status == WorldModel.starBoxStatus.STATUS_USED then
		mcBox:showFrame(3)
	end

	mcBox:setTouchedFunc(c_func(self.onClickExtraBox, self,raidId,status),nil,true);
end

function WorldPVEMainView:playExtraBoxAnim(ctnBox)
	ctnBox:setVisible(true)
	if ctnBox:getChildrenCount() == 0 then
		local anim = self:createUIArmature("UI_xunxian","UI_xunxian_ewaijianglibaoxiang",ctnBox, false, GameVars.emptyFunc)
    	anim:pos(-5,0)
    	anim:startPlay(true)
	end
end

function WorldPVEMainView:onClickExtraBox(raidId,status)
	if self.raidGroupScroller:isMoving() then
        return
    end
	WindowControler:showWindow("WorldExtraRewardView",raidId,status)
end

function WorldPVEMainView:onClickRaidView(raidId,isLock)
	if isLock then
		return
	end

	if self.raidGroupScroller:isMoving() then
        return
    end

    AudioModel:playSound(self:getNpcSound(raidId))

    local isLock = WorldModel:isRaidLock(raidId)
    if isLock then
    	-- WindowControler:showTips("还没有解锁")
    	return
    end

    self:showPVELevelView(raidId)
end

function WorldPVEMainView:showPVELevelView(raidId)
	local ctnLevelView = self.ctn_zhangbo
	ctnLevelView:removeAllChildren()

	-- 创建事件遮罩层
	local coverView = self:createCoverLayer()
	ctnLevelView:addChild(coverView)

	local levelView = WindowsTools:createWindow("WorldPVELevelView",raidId)
	ctnLevelView:addChild(levelView)
end

function WorldPVEMainView:onCloseLevelView()
	local ctnLevelView = self.ctn_zhangbo
	ctnLevelView:removeAllChildren()
end

-- 更新关卡成绩
function WorldPVEMainView:updateRaidScore(raidView,raidId)
	local mcRaid = raidView.btn_pu:getUpPanel().mc_pu1
	local raidScore = WorldModel:getBattleStarByRaidId(raidId)

	if mcRaid then
		-- 成绩星级mc
		local mcScore = mcRaid.currentView.mc_star
		if mcScore then
			mcScore:setVisible(true)
		    -- 一星
		    if raidScore == WorldModel.stageScore.SCORE_ONE_STAR then
		        mcScore:showFrame(1)
		    -- 二星
		    elseif raidScore == WorldModel.stageScore.SCORE_TWO_STAR then
		        mcScore:showFrame(2)
		    -- 三星
		   	elseif raidScore == WorldModel.stageScore.SCORE_THREE_STAR then
		        mcScore:showFrame(3)
		    elseif raidScore == WorldModel.stageScore.SCORE_LOCK then
		    	-- 三个黑色星星
		    	mcScore:setVisible(false)
		    end
		end
	end
end

-- 创建npc动画
function WorldPVEMainView:createNpcSpineAnim(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)

    local npcImgId = raidData.npcImg2
    local npcSourceData = FuncTreasure.getSourceDataById(npcImgId)
    if not npcSourceData then
    	echoWarn(npcImgId ,"_WorldPVEMainView界面,对应的soruceData暂时不存在_")
    	npcSourceData = FuncTreasure.getSourceDataById("1")
    end
    local npcAnimName = npcSourceData.spine
    local npcAnimLabel = npcSourceData.stand

    local npcAnim = nil
    if npcImgId == nil or npcAnimName == nil or npcAnimLabel == nil then
        echoError("npcImgId =",npcImgId,",npcAnimName=",npcAnimName,",npcAnimLabel=",npcAnimLabel)
    else
    	local spbName = npcAnimName .. "Extract";
        npcAnim = ViewSpine.new(spbName, {}, nil,npcAnimName);
        npcAnim:playLabel(npcAnimLabel);
        -- npcAnim:setRotationSkewY(180);
        npcAnim:pos(-10,-100)
        
        local npcImg2Zoom = raidData.npcImg2Zoom
        if npcImg2Zoom == nil then
            echoError("WorldPVEMainView:initView npcImg2Zoom is nil")
        end
        local npcScale = (npcImg2Zoom and npcImg2Zoom / 100) or 1.2
        npcAnim:setScale(npcScale)
    end

    return npcAnim
end

function WorldPVEMainView:checkGoNextStory()
	if WorldModel:isLastChapter(self.curStoryId) then
		return false
	end

	if not WorldModel:isPassStory(self.curStoryId) then
		return false
	end

	-- 判断章是否开启
	local nextStoryId = WorldModel:getNextStoryId(self.curStoryId)
	if self:checkOpenStory(nextStoryId) then
		return true
	end

	return false
end

-- 切换到上一章
function WorldPVEMainView:goLastStory()
	if self.isPlayAnim then
		return
	end

	if WorldModel:isFirstChapter(self.curStoryId) then
		-- 已经是第一章
		WindowControler:showTips(GameConfig.getLanguage("#tid10105"))
		return
	end

	self:reInitData()
	local lastStoryId = WorldModel:getLastStoryId(self.curStoryId)
	self.curStoryId = lastStoryId

	self:updateUI()
end

-- 切换到下一章
function WorldPVEMainView:goNextStory()
	if self.isPlayAnim then
		return
	end

	if WorldModel:isLastChapter(self.curStoryId) then
		-- 已经是最后一章
		WindowControler:showTips(GameConfig.getLanguage("#tid10106"))
		return
	end

	if not WorldModel:isPassStory(self.curStoryId) then
		-- 本章还没有通关
		WindowControler:showTips(GameConfig.getLanguage("#tid10107"))	
		return
	end

	self:reInitData()
	-- 判断章是否开启
	local nextStoryId = WorldModel:getNextStoryId(self.curStoryId)
	if self:checkOpenStory(nextStoryId) then
		self.curStoryId = nextStoryId
		self:updateUI()
	end
end

function WorldPVEMainView:checkOpenStory(storyId)
	local isLock,condition,locKLevel = WorldModel:isStoryLock(storyId)
	if isLock then
		self:showLockStoryTip(locKLevel)
		return false
	else
		return true
	end
end

function WorldPVEMainView:showLockStoryTip(lockLevel)
	self.panel_tishi:setVisible(true)
	-- 角色等级达到多少级开启新章节
	local tip = GameConfig.getLanguageWithSwap("#tid10108",lockLevel)
	self.panel_tishi.txt_1:setString(tip)
end

-- 将当前解锁的关卡设置为list的中心
function WorldPVEMainView:setCurGroupInListCenter()
	-- local raidId = self.nextUnLockRaidId
	local raidId = WorldModel:getUnLockMaxPVERaididByStoryId(self.curStoryId)
	local goupIndex = self:findGroupInex(raidId)

	local easeTime = 0
	if self.onRaidChange then
		easeTime = 0.5
	end
    self.raidGroupScroller:gotoTargetPos(goupIndex,1,1,easeTime)
end

-- 更新操作按钮状态
function WorldPVEMainView:updateActionStatus()
	local storyId = self.curStoryId

	self.btn_left:setVisible(true)
	self.btn_right:setVisible(true)

	if WorldModel:isFirstChapter(storyId) then
		self.btn_left:setVisible(false)
	elseif WorldModel:isLastChapter(storyId) then
		self.btn_right:setVisible(false)
	end

	local nextStoryId = WorldModel:getNextStoryId(self.curStoryId)
	local isLock,condition,lockLevel = WorldModel:isStoryLock(nextStoryId)
	if isLock then
		-- self.btn_right:setVisible(false)
		self.panel_tishi:setVisible(false)
		local tip = GameConfig.getLanguageWithSwap("#tid10108",lockLevel)
		self.panel_tishi.txt_1:setString(tip)
	else
		self.panel_tishi:setVisible(false)
	end
end

-- 开宝箱
function WorldPVEMainView:openStarBoxes(index,needStarNum)
    local data = {}
    data.boxIndex = index
    data.needStarNum = needStarNum
    data.storyId = self.curStoryId

    data.ownStar = WorldModel:getTotalStarNum(self.curStoryId)
    WindowControler:showWindow("WorldStarRewardView", data)
end

-- 根据RaidId查找groupView
function WorldPVEMainView:findGroupView(raidId)
	local groupData = self:findGroupData(raidId)
	local groupView = self.raidGroupScroller:getViewByData(groupData)
	return groupView
end

-- 根据RaidId查找groupView中的raidView
function WorldPVEMainView:findRaidView(raidId)
	local groupView = self:findGroupView(raidId)
	local raidIndex = self:findRaidInex(raidId)

	local raidView = nil
	if groupView and raidIndex then
		raidView = groupView["panel_" .. raidIndex]
	end
	
	return raidView
end

-- 根据raidId，查找列表中的groupData
function WorldPVEMainView:findGroupData(raidId)
	local groupIndex = self:findGroupInex(raidId)
	local groupData = self.raidGroupInfo[groupIndex]
	return groupData
end

-- 根据raidId查找raid index
function WorldPVEMainView:findRaidInex(raidId)
	local groupData = self:findGroupData(raidId)
	local rids = groupData.rids
	for i=1,#rids do
		if tonumber(raidId) == tonumber(rids[i]) then
			return i
		end
	end
end

-- 根据raidId查找group index
function WorldPVEMainView:findGroupInex(raidId)
	for i=1,#self.raidGroupInfo do
		local rids = self.raidGroupInfo[i].rids
		for j=1,#rids do
			if tonumber(raidId) == tonumber(rids[j]) then
				return i
			end
		end
	end

	echoError("findGroupInex not find raidId",raidId)
	dump(self.raidGroupInfo)
	return #self.raidGroupInfo
end

-- 阵容
function WorldPVEMainView:onEmbattle()
	WindowControler:showWindow("TeamFormationView",nil,FuncTeamFormation.formation.pve)
end

--创建一个覆盖的层，用来覆盖底下的点击事件
function WorldPVEMainView:createCoverLayer(color)
	local x =  - GameVars.UIOffsetX
	local y = GameVars.UIOffsetY
	color = cc.c4b(0,0,0,0)
	local layer = display.newColorLayer(color):pos(x,y)
	layer:setName("BgLayer");
	layer:setContentSize(cc.size(GameVars.width,GameVars.height))
	layer:anchor(0,1)
    layer:setTouchEnabled(true)
    layer:setTouchSwallowEnabled(true)
    return layer
end

return WorldPVEMainView;
