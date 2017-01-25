--2016.5.17
--guan
--非强制引导

--如果触发的是强制引导，则直接进入强制引导

--[[
	2016.8.1
	todo1 有改动 如果第一步配置的是主界面npc，则直接激活强制新手下一步, 强制要记录多个步骤和界面名字
	todo2 下面btn开启后，让整个界面不可点击，动画完事后在让他可以点
]]

require("game.sys.view.tutorial.UnforcedTutorialLayer")

UnforcedTutorialManager = class("UnforcedTutorialManager");

local _UnforcedTutorialManager = nil;

function UnforcedTutorialManager.getInstance()
	if _UnforcedTutorialManager == nil then 
		_UnforcedTutorialManager = UnforcedTutorialManager.new();
		return _UnforcedTutorialManager;	
	end
	return _UnforcedTutorialManager;
end

function UnforcedTutorialManager:ctor()
	--已经完成的引导
	self._finishIds = {};

	--已经激活的引导，发事件激活的激活的引导id先放到这, 到了主界面再加到self._showingIds
	self._openIds = {};

	--已经显示出来的引导
	self._showingIds = {};

	--[[
		10001 = Pvp,
		10002 = char,
		10000 = smelt, 
		……
	]]
	self._gidSysNameMap = {};

	self._tutorialManager = TutorialManager.getInstance();

	EventControler:addEventListener(HomeEvent.CLICK_NPC_EVENT, 
        self.finishNpcTurtualFirstStep, self) 

	--初始化数据
	self:initData();
end

function UnforcedTutorialManager:initData()
	--得到所有要显示的引导
	self._openIds = self:getAllShowingGid();
	dump(self._openIds, "----self._openIds self._openIds---");
end

--开始新手引导监听
function UnforcedTutorialManager:startWork()
	echo("----UnforcedTutorialManager startWork-----");

	self._UIlayer = UnforcedTutorialLayer.new();

	WindowControler:getScene()._root:addChild(self._UIlayer, 2);

	self:registerEvent();
end

--得到所有的开启引导id
function UnforcedTutorialManager:getAllShowTriggerGroups()
	return self._openIds;
end

function UnforcedTutorialManager:registerEvent()
	--主界面被其他界面盖住 todo 现在是全屏界面，改成非全局界面
  	EventControler:addEventListener(HomeEvent.OTHER_VIEW_ON_HOME, 
  		self.onOherViewOnHomeView, self);

  	--主界面显示出来
   	EventControler:addEventListener(HomeEvent.HOMEEVENT_COME_BACK_TO_MAIN_VIEW, 
  		self.onHomeShow, self);	
   	EventControler:addEventListener(HomeEvent.SHOW_HOME_VIEW, 
  		self.onHomeFisrtShow, self);

  	-- EventControler:addEventListener(UIEvent.UIEVENT_SHOWCOMP, 
  	-- 	self.onCheckWhenShowWindow, self)

  	--非强制引导事件， 在升级新功能开启时发消息
  	EventControler:addEventListener(TutorialEvent.TUTORIALEVENT_SYSTEM_OPEN, 
  		self.triggerTutorial, self);
end

function UnforcedTutorialManager:onHomeShow(event)
	echo("---UnforcedTutorialManager:onHomeShow---");
	-- 特效播完后掉这个
	-- self:showAllBubbles();
	self:showLayer();
end

function UnforcedTutorialManager:onHomeFisrtShow()
	echo("---UnforcedTutorialManager:onHomeFisrtShow---");
	self:showAllBubbles();
	self:showNpcGlow();
end

-- function UnforcedTutorialManager:onCheckWhenShowWindow(event)
-- 	local winName = event.params.ui.windowName;
-- 	if winName == "HomeMainView" then 
-- 		self:onHomeShow();
-- 	end 
-- end

function UnforcedTutorialManager:onOherViewOnHomeView(event)
	self:hideLayer();
end

--触发类型的新手 这只是记录所有要展示的新手
function UnforcedTutorialManager:triggerTutorial(event)
	local groupId = event.params.id;
	self:writeToDB(groupId);
	self._openIds = self:getAllShowingGid();

	--是npc引导的话，就直接显示在主界面了
	if self:isTutorOnBtn(groupId) == false then 
		self._showingIds[groupId] = true;
	end 

	local sysName = event.params.sysName;

	self._gidSysNameMap[groupId] = sysName;
end

function UnforcedTutorialManager:isGroupIdInDB(groupId)
	local showingGroups = LS:prv():get(
		StorageCode.tutorial_showing_triggerGroup, "");

	local gids = string.split(showingGroups, ",");

	local isValueIn = table.isValueIn(gids, groupId);

	return isValueIn;
end

--写进数据库 下次进入游戏好进行引导
function UnforcedTutorialManager:writeToDB(groupId)
	if self:isGroupIdInDB(groupId) == true then 
		return;
	end 

	local showingGroups = LS:prv():get(
		StorageCode.tutorial_showing_triggerGroup, "");

	if showingGroups == "" then 
		showingGroups = string.format("%d", groupId);
	else 
		--数据库中已经有了，放到后面
		showingGroups = string.format("%s,%d", showingGroups, groupId);
	end 
	
	LS:prv():set(StorageCode.tutorial_showing_triggerGroup, showingGroups);
end

function UnforcedTutorialManager:deleteFromDB(groupId)
	local showingGroups = LS:prv():get(StorageCode.tutorial_showing_triggerGroup, "");
	local gids = string.split(showingGroups, ",");
	local curGroups = "";

	for k, v in pairs(gids) do
		--排除相等的
		if v ~= tostring(groupId) then
			if curGroups == "" then 
				curGroups = string.format("%d", v);
			else 
				curGroups = string.format("%s,%d", curGroups, v);
			end 
		end 
	end

	LS:prv():set(StorageCode.tutorial_showing_triggerGroup, curGroups);
end

function UnforcedTutorialManager:getAllShowingGid()
	local showingGroups = LS:prv():get(StorageCode.tutorial_showing_triggerGroup, "");
	if showingGroups == "" then 
		return {};
	else 
		return string.split(showingGroups, ",");
	end 
end

function UnforcedTutorialManager:showAllBubbles()
	local allShowBubble = self:getAllShowTriggerGroups();
	for k, groupId in pairs(allShowBubble) do
		--没有已经显示，就show
		if self._showingIds[groupId] ~= true and 
				self:isTutorOnBtn(groupId) == true then 
			echo("--showAllBubbles:groupId--", groupId);
			self:showBubble(groupId);
		end 
	end
end

function UnforcedTutorialManager:showNpcGlow()
	local allShowBubble = self:getAllShowTriggerGroups();
	for k, groupId in pairs(allShowBubble) do
		if self:isTutorOnBtn(groupId) == false then 
			echo("---showNpcGlow---", groupId);
			local sysName = FuncChar.getSysNameByGid(groupId);
			echo("---sysName---", sysName);
			if sysName ~= nil then 
                EventControler:dispatchEvent(HomeEvent.TELL_HOME_VIEW_ADD_NPC_HEAD_GLOW_EVENT, 
                    {sysName = sysName});
			end 
		end 
	end	
end

function UnforcedTutorialManager:showLayer()
	self._UIlayer:setVisible(true);
	self._UIlayer:getTouchOneByOneListener():setEnabled(true);
end

function UnforcedTutorialManager:hideLayer()
	self._UIlayer:setVisible(false);
	self._UIlayer:getTouchOneByOneListener():setEnabled(false);
end

--再多显示一个bubble id
function UnforcedTutorialManager:showBubble(groupId)
	echo("--groupId--", groupId);
	self._UIlayer:setUIByUnforcedTutoralId(groupId, "1");
	self._showingIds[groupId] = true;
end

--完事了，干掉 bubble 层
function UnforcedTutorialManager:removeBubble(groupId)
	self._showingIds[groupId] = nil;
end

--完成当前小步, 在 TutoralLayer 层调用
function UnforcedTutorialManager:finishCurTutorialId(gid)
	echo("-------finishCurTutorialId----");

	FuncCommUI.setCanScroll(true);

	--每次开始引导，启动强制引导 manager
	self._tutorialManager:startWork();

	--去强制引导层
	self._tutorialManager:setCurGroupId(gid);

	if self:isTutorOnBtn(gid) == true then 
		--btn上的引导从第2步开始强制
		self._tutorialManager:setCurStepId(2);
	else 
		--npc上的引导从第1步开始强制
		self._tutorialManager:setCurStepId(1);
	end 
	
	self._tutorialManager:setIsTriggerGuide(true);
end

function UnforcedTutorialManager:finishNpcTurtualFirstStep(event)
	local sysName = event.params.npcKey;
	echo("---sysName---", sysName);
	for _, gid in pairs(self._openIds) do
		local name = FuncChar.getSysNameByGid(gid);
		echo("---name---", name);
		echo("---gid---", gid);
		if name == sysName then 
			self:finishCurTutorialId(gid);
			self._showingIds[gid] = true;
			return;
		end 
	end
end

--完成关键步骤才删除
function UnforcedTutorialManager:finishKeyPoint(gid)
	self:deleteFromDB(gid);
	self:removeBubble(gid);

	self._openIds = self:getAllShowingGid();
end

--todo 等策划定了那个gid是最后一步, 再改这个函数
function UnforcedTutorialManager:isAllFinish()
	return false;
end

--是不是底部的btn上的引导
function UnforcedTutorialManager:isTutorOnBtn(gid)
	local curWinName = FuncGuide.getWinName(gid, 1);
	return curWinName == "HomeMainView" and true or false;
end
















