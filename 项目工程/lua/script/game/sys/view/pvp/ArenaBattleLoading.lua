local ArenaBattleLoading = class("ArenaBattleLoading", UIBase)

function ArenaBattleLoading:ctor(winName, enemyInfo, myInfo)
	ArenaBattleLoading.super.ctor(self, winName)
	self.enemyInfo = enemyInfo
	self.myInfo = myInfo
	if not self.myInfo then
		self.myInfo = FuncPvp.getPlayerRankInfo(PVPModel:getUserRank())
	end
    self.myInfo.name=self.myInfo.name=="" and GameConfig.getLanguage("tid_common_2006") or self.myInfo.name;
end

function ArenaBattleLoading:loadUIComplete()
	self.progress_bar = self.panel_loading_progress.progress_loading
	self.total_process = 100
	self.progress = 0
	self.progress_cloud = self.panel_loading_progress.panel_cloud
	self.progress_cloud_box = self.progress_cloud:getContainerBox()
	self.progress_box = self.panel_loading_progress.progress_loading:getContainerBox()
	self.progress_bar:setPercent(0)
	
	self:registerEvent()
	self:setViewAlign()
	
	self:scheduleUpdateWithPriorityLua(c_func(self.frameUpdate, self) ,1)

	self.panel_my:visible(false)
	self.panel_enemy:visible(false)

	self:initPlayerInfos()
	self:animShowPlayerPanel()

	local addPercent = self:getOneProcess(10)
	self:tweenProgress(addPercent, 5)

    --//榛戣壊鐨勯伄缃?
    local    _colorLayer=display.newColorLayer(cc.c4b(0,0,0,255*0.7));
    _colorLayer.__layer:setContentSize(cc.size(GameVars.width+200,GameVars.height+100));
    local    _worldPointX,_worldPointY=self.ctn_mask_stay:getPosition();
    _colorLayer:setPosition(cc.p(-_worldPointX-100,_worldPointY));
    self.ctn_mask_stay:addChild(_colorLayer);
end

function ArenaBattleLoading:getOneProcess(num)
	if num < self.total_process then
		self.total_process = self.total_process - num
		return num
	end
end

function ArenaBattleLoading:frameUpdate()
	self:updateProgressCloud()
end

function ArenaBattleLoading:getLeftProcessToShow()
	return self.total_process
end

function ArenaBattleLoading:registerEvent()
    EventControler:addEventListener(LoadEvent.LOADEVENT_BATTLELOADCOMP, self.onBattleResLoadOver, self)
end

function ArenaBattleLoading:onBattleResLoadOver()
	self:tweenProgress(self:getLeftProcessToShow(), 15)
end

function ArenaBattleLoading:updateProgressCloud()
	if not self.progress_bar then return end
	local percent = self.progress_bar:getPercent()
	local totalWidth = self.progress_box.width
	self.progress_cloud:pos(percent*1.0/100 * totalWidth, -self.progress_box.height/2)

	if percent >= 100 then
		self:startHide()
		return
	end
end

function ArenaBattleLoading:setViewAlign()
--	FuncCommUI.setViewAlign(self.panel_enemy, UIAlignTypes.Right)
--	FuncCommUI.setViewAlign(self.panel_my, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.panel_loading_progress, UIAlignTypes.MiddleBottom)
end

function ArenaBattleLoading:initPlayerInfos()
	local enemyName = self.enemyInfo.name
	if self.enemyInfo.type == FuncPvp.PLAYER_TYPE_ROBOT then
		enemyName = GameConfig.getLanguage(enemyName)
	elseif enemyName == "" or not enemyName then
		enemyName =FuncCommon.getPlayerDefaultName()
	end
	self.panel_enemy.panel_info.txt_name:setString(enemyName)
	self.panel_enemy.panel_info.txt_rank:setString(self.enemyInfo.rank)
    local  _sexMap={a=1,b=2};
    local   _sex=FuncChar.getHeroSex(self.enemyInfo.avatar..'');
    self.panel_enemy.panel_info.mc_1:showFrame(_sexMap[_sex]);
--	local enemyIconSpriteFilePath = FuncChar.icon(self.enemyInfo.avatar..'')
--	local enemyHeadIcon = display.newSprite(enemyIconSpriteFilePath)
--	enemyHeadIcon:setAnchorPoint(cc.p(0.5, 0))
--	self.panel_enemy.panel_info.ctn_1:addChild(enemyHeadIcon)

	local selfName = self.myInfo.name
	if selfName =="" or not selfName then
		selfName =FuncCommon.getPlayerDefaultName()
	end

	self.panel_my.panel_info.txt_name:setString(selfName)
	self.panel_my.panel_info.txt_rank:setString(self.myInfo.rank)
    _sex=FuncChar.getHeroSex(self.myInfo.avatar..'');
    self.panel_my.panel_info.mc_1:showFrame(_sexMap[_sex]);
--	local myHeadIcon = display.newSprite(FuncChar.icon(self.myInfo.avatar..''))
--	myHeadIcon:setAnchorPoint(cc.p(0.5, 0))
--	self.panel_my.panel_info.ctn_1:addChild(myHeadIcon)
end

function ArenaBattleLoading:tweenProgress(addPercent, frame)
	self.progress =  self.progress + addPercent
	self.progress_bar:tweenToPercent(self.progress, frame)
end

function ArenaBattleLoading:animShowPlayerPanel()
	self.panel_my:visible(false)
	self.panel_enemy:visible(false)
	local showProgress = function()
		local addPercent = self:getOneProcess(45)
		self:tweenProgress(addPercent, 20)
	end
--	local anim =  self:createUIArmature("UI_arenaLoading","UI_arenaLoading_dongxiao", self.ctn_ruchang, false, GameVars.emptyFunc)
--	anim:registerFrameEventCallFunc(8, 1, c_func(showProgress))
--	FuncArmature.changeBoneDisplay(anim, "layer1", self.panel_enemy)
--	FuncArmature.changeBoneDisplay(anim, "layer8", self.panel_my)
--	local enemyBox = self.panel_enemy:getContainerBox()
--	local myBox = self.panel_my:getContainerBox()
--	local widthDelta = GameVars.width - GameVars.maxResWidth
--	self.panel_enemy:pos(widthDelta/2,-enemyBox.height/2)
--	self.panel_my:pos(-widthDelta/2,enemyBox.height/2)
--	anim:gotoAndPause(1)
--	anim:startPlay(false)
    local anim =  self:createUIArmature("UI_arenaLoading", "UI_arenaLoading_duizhan", self.ctn_ruchang, false, GameVars.emptyFunc)

    anim:pos(0,0);
--        local  _node2=anim:getBoneDisplay("node2");
--    local  _node3=anim:getBoneDisplay("node3");

--    local  _nodePosition2X,_nodePosition2Y=_node2:pos(); 
--    local  _nodePosition3X,_nodePosition3Y=_node3:pos();

	anim:registerFrameEventCallFunc(18, 1, c_func(showProgress))
   self.panel_enemy:pos(0,0);
   self.panel_my:pos(0,0);

    FuncArmature.changeBoneDisplay(anim, "node2", self.panel_enemy)
    FuncArmature.changeBoneDisplay(anim, "node3", self.panel_my)
end

return ArenaBattleLoading

