--2015.7.21 guan
--2016.4.22 guan

-- todo

require("game.sys.view.tutorial.TutoralLayer")

TutorialManager = class("TutorialManager");

local _tutorialManager = nil;

function TutorialManager.getInstance()
	if _tutorialManager == nil then 
		_tutorialManager = TutorialManager.new();
		return _tutorialManager;	
	end
	return _tutorialManager;
end

function TutorialManager:isTutoring()
	local isVisible = self._tutorialLayer:isVisible();
	if isVisible == true and self._curViewName ~= "CompServerOverTimeTipView" then 
		return true;
	else 
		return false;
	end 
end

function TutorialManager:getTutorialLayer()
	return self._tutorialLayer;
end

function TutorialManager:isInBtnClickArea(x, y)
    -- echo("---TutorialManager---xy-------", x, y);

    if x == nil or y == nil then 
    	return false;
    end 

	local ret = self._tutorialLayer:isInClickArea(x, y);

	if ret == false then 
        WindowControler:globalDelayCall(function ( ... )
			self._tutorialLayer:showWrongClickTips()
        end, 0.001)
	end 

	return ret;
end

function TutorialManager:isInSetTouchClickArea(x, y)
    if x == nil or y == nil then 
    	return false;
    end 

	local ret = self._tutorialLayer:isInClickArea(x, y);

	if ret == false then 
        WindowControler:globalDelayCall(function ( ... )
			self._tutorialLayer:showWrongClickTips()
        end, 0.001)
	end 

	return ret;
end

function TutorialManager:ctor()
	--大步id 当前正在进行的 groupId
	self._groupId = nil;
	-- self._groupId = 100;
	--小步id
	self._tutorialId = 1;
	--是否在引导中
	self._isTuroring = false;
	--所有完成的大步id
	self._finishIds = {};
	--新手引导层
	self._tutorialLayer = nil;

	self._preIsDone = true;

	self._isShowLayer = false;

	self._isTriggerGuide = false;
end

function TutorialManager:setCurGroupId(groupId)
	self._groupId = groupId;
end

function TutorialManager:setCurStepId(stepId)
	self._tutorialId = stepId;
end

--开始新手引导监听
function TutorialManager:startWork()
	echo("----TutorialManager startWork-----");

	self._groupId = UserExtModel:guide() + 1;
	self._tutorialLayer = TutoralLayer.new();
	
	WindowControler:getScene()._tutoralRoot:addChild(self._tutorialLayer, 
		WindowControler.ZORDER_Tutorial);

	self:registerEvent();
	self:hideTutorialLayer();
end

function TutorialManager:registerEvent()

	--不能是 UIEVENT_SHOWCOMP, windowCfg.style的话，有可能没有发出 UIEVENT_SHOWCOMP，就已经可以点了
  	EventControler:addEventListener(UIEvent.UIEVENT_STARTSHOW, 
  		self.onCheckWhenShowWindow, self)

  	EventControler:addEventListener(TutorialEvent.TUTORIALEVENT_VIEW_CHANGE, 
  		self.onCheckWhenCloseWindow, self)

end

function TutorialManager:onCheckWhenShowWindow(event)
	self._curViewName = event.params.ui.windowName;
	self:onCheck();
end

function TutorialManager:onCheckWhenCloseWindow(event)
	self._curViewName = event.params.viewName;
	self:onCheck();
end

--[[
	新新手引导大步激活，下一步是否激活。第一个引导也是通过此来激活的
]]
function TutorialManager:onCheck() 
	echo("-----onStateCheck _curViewName------" .. tostring(self._curViewName));
	if self._preIsDone == true and self._groupId ~= nil then 
		if self._isTuroring == true then 
			local viewName = self:getCurStepViewName();
			if self._curViewName == viewName then 
				self:showTuroral();
			end 
		else 
			self:openCheck(self._curViewName);
		end 
	end 
end

--完全完成当前大步
function TutorialManager:finishCurGroupId()
	echo("-------------finishCurGroupId-----------", self._tutorialId);
	self._isTuroring = false;
	self._finishIds[self._groupId] = true;

	--是非强制引导
	if self._isTriggerGuide == true then 	
		self:hideTutorialLayer();
		self._groupId = nil;
	else --是强制引导
	    if self:isAllFinish() == true then
	    	--弹个起名框
	    	WindowControler:showWindow("PlayerRenameView")
	    	--完成所有引导消息
	        self:dispose()
            EventControler:dispatchEvent(TutorialEvent.TUTORIALEVENT_FINISH_ALL, {});
	    else 
	    	self._tutorialId = 1;
			self._groupId = self._groupId + 1;
			--再检查一下有没有新的大步开启
			self:openCheck(self._curViewName);
	    end
	end 
end

function TutorialManager:finishProcess()
	self._preIsDone = true;
	--隐藏新手引导
	self:hideTutorialLayer();

	local isJumpToHome = self:isJumpToHome(self._tutorialId);
	-- local sleepTime = FuncGuide.getTime(self._groupId, self._tutorialId);

	if isJumpToHome == true then 
		WindowControler:goBackToHomeView();
	end 
	
	if self:isFinshCurActive() == true then 
		--完成了这个大步
		self:finishCurGroupId();
	else 
		--还有下一步
		local curId = self._tutorialId;
		self._tutorialId = self:getNextStepId();

		--todo 或者是其他条件
		if self:isShowNextStepNow(curId) == true then 
			--直接换界面
			self:showTuroral();
		end 
	end 
end

--完成当前小步, 在 TutoralLayer 层调用
function TutorialManager:finishCurTutorialId()
	local uniqueId = FuncGuide.getToCenterId(self._groupId, 
		self._tutorialId);
	echo(" finishCurTutorialId ", uniqueId);

	ClientActionControler:sendTutoralStepToWebCenter(uniqueId);
	
	FuncCommUI.setCanScroll(true);

	if self._isTriggerGuide == true then 
		--完成非强制引导
		if self:isNeedToSendFinishRequestAfterFinish() == true then 
			UnforcedTutorialManager.getInstance():finishKeyPoint(self._groupId);
		end 
		self:finishProcess();
	else  
		--完成强制引导
		if self:isNeedToSendFinishRequestAfterFinish() == true then 
			TutorServer:finishTutorStep(self._groupId, 
				c_func(self.finishCallback, self));
		else 
			self:finishProcess();
		end
	end 
end

function TutorialManager:finishCallback(event)
	echo("--finishCallback--");
    if event.error == nil then
    	self:finishProcess();
    end 
end

function TutorialManager:isShowNextStepNow(curId)
	local isNextTutorialChangeView = self:isNextTutorialChangeView(curId);
	local isJumpToHome = self:isJumpToHome(curId);

	if isNextTutorialChangeView == false and 
		isJumpToHome == false then
		return true;
	else 
		return false;
	end 
end

function TutorialManager:isJumpToHome(curId)
	return FuncGuide.getJump(self._groupId, curId) ~= nil and true or false;
end

--下一步是否换ui了
function TutorialManager:isNextTutorialChangeView(curId)
	local nextStep = curId + 1;
	local nextView = FuncGuide.getWinName(self._groupId, nextStep);
	return nextView ~= self._curViewName and true or false;
end

--是否需呀发送完成任务请求
function TutorialManager:isNeedToSendFinishRequestAfterFinish()
	local keyPoint = FuncGuide.getKeypoint(self._groupId, self._tutorialId);
	return keyPoint == 1 and true or false;
end

function TutorialManager:isNeedToSendFinishRequestAtBegin()
	local keyPoint = FuncGuide.getKeypoint(self._groupId, self._tutorialId);
	return keyPoint == 2 and true or false;
end

function TutorialManager:isAllFinish()
	-- echo("self._groupId", self._groupId);
	if IS_OPEN_TURORIAL == false then 
		return true;
	end 

	if self._groupId == nil then 
		self._groupId = UserExtModel:guide() + 1;
	end 

	if FuncGuide.isGroundExist(self._groupId) == false then 
		-- echo("t(self._groupId) == false");
		return true;
	else 
		if self._finishIds[self._groupId] ~= nil then 
			local nextGroupId = self._groupId + 1;
			return FuncGuide.isGroundExist(nextGroupId) == false and true or false;
		else 
			return false;
		end 
	end 

end

function TutorialManager:isFinshCurActive()
	local last = FuncGuide.getValueByKey(self._groupId, self._tutorialId, "last");
	return last ~= nil and true or false;
end

function TutorialManager:getNextStepId()
	return self._tutorialId + 1;
end

function TutorialManager:openCheck(viewName)
	if viewName == self:getCurStepViewName() then 
		self:showTuroral();
		return;
	end
end

--[[
	显示新手引导层
]]
function TutorialManager:showTutorialLayer()
	echo("--showTutorialLayer--");
    if self._isSleepTimeOn ~= true then 
   		self._tutorialLayer:setVisible(true);
   	end 
    self._isShowLayer = true;
end

--[[
	隐藏新手引导层 getTouchNode
]]
function TutorialManager:hideTutorialLayer()
	echo("--hideTutorialLayer--");
    self._tutorialLayer:setVisible(false);
    self._isShowLayer = false
end

--开始显示新手引导
function TutorialManager:showTuroral()
	self._preIsDone = false;

	FuncCommUI.setCanScroll(false);

	if self:isNeedToSendFinishRequestAtBegin() == true then 
		TutorServer:finishTutorStep(self._groupId, 
			c_func(self.finishCallback, self));
	end

	self:showStepId();

	self._isTuroring = true;
	self:showTutorialLayer();
	self._tutorialLayer:setUIByTurtoralId(self._groupId, 
		self._tutorialId);

	--不显示时间
	local sleepTime = FuncGuide.getTime(self._groupId, self._tutorialId);

	if sleepTime ~= nil and self._isTuroring == true then  
		-- echo("----isShowLayer----", isShowLayer);
		self._tutorialLayer:setVisible(false);
		self:setUItouchable(false);
		self._isSleepTimeOn = true;

		WindowControler:globalDelayCall( function ( ... )
			if self._isShowLayer == true then 
				self._tutorialLayer:setVisible(true);
			end 
			self:setUItouchable(true);
			self._isSleepTimeOn = false;
		end, sleepTime);
	end 
	
end

function TutorialManager:reomveTutorialLayer()
	if self._tutorialLayer ~= nil then 
		self._tutorialLayer:dispose();
		self._tutorialLayer:removeFromParent();
		self._tutorialLayer = nil;
	end 
end

--当前引导id 触发界面
function TutorialManager:getCurStepViewName()
	-- self:showStepId();
	return FuncGuide.getWinName(self._groupId, self._tutorialId);
end

--析构
function TutorialManager:dispose()
	echo("-----TutorialManager:dispose----");
	FuncCommUI.setCanScroll(true);
	
	EventControler:clearOneObjEvent(self);
	self:reomveTutorialLayer();
	_tutorialManager = nil;
end

function TutorialManager:showStepId()
	echo("--_tutorialId ", tostring(self._tutorialId));
	echo("--_groupId ", tostring(self._groupId));
end

--整个游戏能否响应点击 
function TutorialManager:setUItouchable(isCanTouch)
	WindowControler:setUIClickable(isCanTouch);
end 

--给非强制引导用的
function TutorialManager:setIsTriggerGuide(isTrigger)
	self._isTriggerGuide = isTrigger;
end







