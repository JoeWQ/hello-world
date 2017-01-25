local YongAnGambleView = class("YongAnGambleView", UIBase)
function YongAnGambleView:ctor(winName)
	YongAnGambleView.super.ctor(self, winName)
--//获得成就奖励的面板的显示当前成就奖励次数的宽度
    self.panelWidth=64;
end

function YongAnGambleView:loadUIComplete()
	self:setViewAlign()
	self:adjustBgs()
	self:registerEvent()
	self:updateCount()
	--根据当前状态显示对应mc view
	self:updateGambleDeskByStatus()
	self:setBonusTip()
	self:updateNpcTalks()
    self.mc_shuzi:setVisible(false);
	--进入天玑赌肆主界面的时候，检查是否达到某个成就
	self:checkShowAchieveNewBonusId()
end
--//上面的面板显示
function YongAnGambleView:updateDisplayPanel()
--//展示次数的组件再次显示
      self.mc_gamble:getViewByFrame(1).txt_cs_2:setVisible(true);
  --//面板播放动画
      self.panel_achievement:runAction(cc.MoveBy:create(1.0,cc.p(self.panelWidth+GameVars.UIOffsetX,0)));
--//从CTN上移除添加的flash动画
      self.panel_achievement.ctn_stay:removeAllChildren();
end
--//需要更新玩家的剩余次数
function  YongAnGambleView:updateTimesAfterAchieve()
--//隐藏展示数字
      self.panel_achievement.UI_number:setVisible(false);
      self.panel_achievement.panel_mao:setVisible(false);
--//播放动画
      local   _ctnNode=self.panel_achievement.ctn_stay;
      local    ani=self:createUIArmature("UI_dufang","UI_dufang_huanshuzi",_ctnNode,false,c_func(self.updateDisplayPanel,self));
--//因为flash动画与flash上的文本职位有一定的偏移,所以目前暂时不适用动画里面的二使用程序实现动画
      local    _bone=ani:getBone("layer9");
      _bone:setVisible(false);
--      local    _replace_bone=ani:getBone("layer7");
      local    _replace_view=self.mc_shuzi;--UIBaseDef:cloneOneView(self.mc_shuzi);
      self.gambleAchieveCount=9;
      _replace_view:showFrame(self.gambleAchieveCount);
      _replace_view:setVisible(true);
      _replace_view:pos(0,0);

      local   _sub_ani = ani:getBoneDisplay("layer7");
      FuncArmature.changeBoneDisplay(_sub_ani,"layer2",_replace_view);
 --//设置新的字符串
 	local leftCount = YongAnGambleModel:getGambleLeftCount()
	local max = YongAnGambleModel:getMaxGambleCount()
    self.oldString=string.format("%d/%d",leftCount,max);
 --//修正锚点,以使得放大缩小动画从文本的中心开始
     local    _origin_txt=self.mc_gamble:getViewByFrame(1).txt_cs_2;
     _origin_txt:setString(self.oldString)
     local  _size=_origin_txt:getContentSize();
     local  _originAnchor=_origin_txt.baseLabel:getAnchorPoint();
     _origin_txt.baseLabel:setPosition(cc.p(_origin_txt.baseLabel:getPositionX()+_size.width/2,_origin_txt.baseLabel:getPositionY()-_size.height/2));
     _origin_txt.baseLabel:setAnchorPoint(cc.p(0.5,0.5));
     local  function   _onLabelTimeVisible()
            local    _scale=cc.ScaleBy:create(0.3,1.6);
            local    _delayTime=cc.DelayTime:create(0.15);
            local    _reverse_scale=cc.ScaleBy:create(0.3,1.0/1.6);
            _origin_txt.baseLabel:runAction(cc.Sequence:create(_scale,_delayTime,_reverse_scale));
     end
     ani:registerFrameEventCallFunc(18,1,_onLabelTimeVisible);
end
function   YongAnGambleView:onAchieveFinished(_event)
     if(_event.result~=nil)then
            echo("------YongAnGambleView:onAchieveFinished-----finish--------");
     else
            echo("--------YongAnGambleView:onAchieveFinished---",_event.error.message);
     end
end
--//返回可以获取的最大的bonusId
function  YongAnGambleView:getMaxBonusId()
      local  last_bonusId=0;
      local bonusId = YongAnGambleModel:getNextBonusId()
	  local achieved = YongAnGambleModel:checkBonusAchieved(bonusId)
      local nextBonusId
      local bonusConfig
      while( achieved )do
          last_bonusId=bonusId;
          nextBonusId = bonusId + 1;
	      bonusConfig = FuncYongAnGamble.getBonusConfig(tostring(nextBonusId));
          if(bonusConfig ==nil)then
                 break;
          end
          bonusId=nextBonusId;
          achieved=YongAnGambleModel:checkBonusAchieved(bonusId)
     end
     return tonumber( last_bonusId);
end
function YongAnGambleView:checkShowAchieveNewBonusId()
	local bonusId = YongAnGambleModel:getNextBonusId()
	local achieved = YongAnGambleModel:checkBonusAchieved(bonusId)
--//如果获得了成就,不再弹出提示,而是向玩家展示特效
	if bonusId then
--		YongAnGambleServer:getAchievement(bonusId,c_func(self.onNewBonusIdUpdateOk, self))
        self.panel_achievement:setVisible(true);
        local  _template=GameConfig.getLanguage("gamble_extra_achievement_1002");
        local achieved, currentNum, needNum, gambleTimes, needQuality = YongAnGambleModel:checkBonusAchieved(bonusId);
        self.panel_achievement.txt_1:setString(_template:format(currentNum or 0,needNum or 0));
--//获取可以获得的成就奖励次数
       local   _gambleBonusId=self:getMaxBonusId();
--//如果成就奖励次数大于0,则显示奖励次数并且播放动画,否则对齐self.panel_achievement
       if(_gambleBonusId>0)then
              local   _gambleAchieveCount=_gambleBonusId-YongAnGambleModel:getCurrentBonusId();
              self.gambleAchieveCount=_gambleAchieveCount;
              self.panel_achievement.UI_number:setPower(self.gambleAchieveCount);
--//延迟一段时间
              local       _delayTime=cc.DelayTime:create(3);
              local       _callFunc=cc.CallFunc:create(c_func(self.updateTimesAfterAchieve,self));
              self.panel_achievement.UI_number:runAction(cc.Sequence:create(_delayTime,_callFunc));
--//同时发送协议
              YongAnGambleServer:getAchievement(_gambleBonusId,c_func(self.onAchieveFinished,self));
       else
              local   _originX=self.panel_achievement:getPositionX();
              self.panel_achievement:setPositionX(_originX+self.panelWidth+GameVars.UIOffsetX);
       end
    else
             self.panel_achievement:setVisible(false);
	end
end 

function YongAnGambleView:onNewBonusIdUpdateOk()
	local currentBonusId = YongAnGambleModel:getCurrentBonusId()
	self:updateCount()
	self:setBonusTip()
	self:updateGambleDeskByStatus()
	WindowControler:showWindow("YongAnNewBonusView", currentBonusId)
end

function YongAnGambleView:onGetNewBonus()
	self:setBonusTip()
	self:updateCount()
end

--上下板子适配
function YongAnGambleView:adjustBgs()
	local bg_scale_x = GameVars.width*1.0/self.panel_top_bg:getContainerBox().width
--	self.panel_bottom_bg:setScaleX(bg_scale_x)
	self.panel_top_bg:setScaleX(bg_scale_x)
end

function YongAnGambleView:setViewAlign()
	FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.btn_help, UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.panel_top_bg, UIAlignTypes.MiddleTop)
--	FuncCommUI.setViewAlign(self.panel_bottom_bg, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.panel_res, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.panel_count, UIAlignTypes.Right)
--	FuncCommUI.setViewAlign(self.panel_achievement, UIAlignTypes.Right)
end

function YongAnGambleView:registerEvent()
	self.btn_back:setTap(c_func(self.close, self))
	self.btn_help:setTap(c_func(self.showHelp, self	))
	self.mc_gamble:getViewByFrame(1).btn_begin_gamble:setTap(c_func(self.onBeginGambleTap, self))

	self.btn_end_gamble = self.mc_gamble:getViewByFrame(2).btn_end_gamble
	self.btn_end_gamble:setTap(c_func(self.onEndGambleTap, self))
	self.btn_change_fate = self.mc_gamble:getViewByFrame(2).btn_change_fate
	self.btn_change_fate:setTap(c_func(self.onChangeFateTap, self))

	EventControler:addEventListener(YongAnGambleEvent.GET_NEW_BONUS_OK, self.onGetNewBonus, self)
--//监听仙玉数目变化事件,VIP变化事件
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE,self.onResourceChanged,self);
    EventControler:addEventListener(UserEvent.USEREVENT_VIP_CHANGE,self.onResourceChanged,self);
end

function  YongAnGambleView:onResourceChanged()
   self:updateChangeFateCountOrCost();
   self:updateCount();
end
function YongAnGambleView:showHelp()
	WindowControler:showWindow("YongAnGambleHelpView")
end

--见好就收
function YongAnGambleView:onEndGambleTap()
	local currentStatus = YongAnGambleModel:getCurrentStatus()
	if tostring(currentStatus) == tostring(FuncYongAnGamble.ROLL_STATUS.INIT) then
		return
	end
	YongAnGambleServer:endGamble(c_func(self.onEndGambleBack, self))
	self.btn_end_gamble:disabled()
end

--
function YongAnGambleView:onEndGambleBack(serverData)
	self.btn_end_gamble:enabled(1)
	local rewards = self.rewards
	FuncCommUI.startRewardView(rewards)
	self:updateGambleDeskByStatus()
	self:updateNpcTalks()
end

--改投
function YongAnGambleView:onChangeFateTap()
--    if(true)then  self:playChangeFateAni()  return end
	if YongAnGambleModel:isMaxLuckAchieved() then
		WindowControler:showTips(GameConfig.getLanguage("tid_gamble_1011"))
		return
	end
	local freeCountLeft = YongAnGambleModel:getGambleFreeChangeLeftCount()
	if freeCountLeft <=0 then
		if YongAnGambleModel:isMaxVipChangeCountReached() then
			if FuncYongAnGamble.isHigherVipHasMoreGambleChangeCount() then
				WindowControler:showWindow("CompVipToChargeView", {tip=GameConfig.getLanguage("tid_gamble_1010"), title="升级VIP"})
			else
				WindowControler:showTips(GameConfig.getLanguage("tid_gamble_1009"))
			end
			return
		end
		local cost = FuncYongAnGamble.getChangeFateGoldCost()
		if not UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, cost, true) then
			return
		end
	end
    local function _delayCall()
 --         FilterTools.clearFilter( self.btn_change_fate);
          self.playChangeFateCoolDown=nil;
    end
    if(not  self.playChangeFateCoolDown)then
          self.playChangeFateCoolDown=true;
	      YongAnGambleServer:changeFate(c_func(self.playChangeFateAni, self));
          self.btn_change_fate:delayCall(_delayCall,0.8);
--    else
 --         WindowControler:showTips(GameConfig.getLanguage("gamble_extra_change_fate_frequency_1003"));
    end
end
--//玻化播放完毕之后的动作
function YongAnGambleView:resumeAfterPlayChangeFate(serverData)
   local    _parent_mc=self.mc_gamble:getViewByFrame(2)
   local arr =YongAnGambleModel:getDicesStatus()
	for index,frame in pairs(arr) do
        local   _parent_panel=_parent_mc["UI_dice_"..index];
        _parent_panel.mc_dice:setVisible(true);
        _parent_panel.mc_dice:showFrame(frame);
--//删除掉相关的动画
       if(_parent_panel.gamble_ani)then
              _parent_panel.gamble_ani:removeFromParent(true);
              _parent_panel.gamble_ani=nil;
        end
	end
    self:onChangeFateEnd(serverData);
end
--//播放改投动画
function  YongAnGambleView:playChangeFateAni(serverData)
--//执行动画上UI的替换
   local    _parent_mc=self.mc_gamble:getViewByFrame(2)
   local    _gamble_replace_view=_parent_mc.UI_dice_1.mc_dice;
    local arr = YongAnGambleModel:getDicesStatus()--//已经按照从大到小排序了
	for index, frame in ipairs(arr) do
		assert(frame <= FuncYongAnGamble.DICES_COUNT and index<=FuncYongAnGamble.DICES_COUNT) ;
        if(self.last_dice_status[index]<6)then--//如果上次的不是满吉
              local   _replace_view=UIBaseDef:cloneOneView(_gamble_replace_view);
             _replace_view:showFrame(frame);
             local   _parent_panel=_parent_mc["UI_dice_"..index];
            _parent_panel.mc_dice:setVisible(false);--//先暂时隐藏掉后面的筛子
            local   _func_flag= index==6--//如果是最后一个可以被替换的
            local   _gamble_ani=self:createUIArmature("UI_dufang","UI_dufang_zhuanshaizi",_parent_panel,false,_func_flag and c_func(self.resumeAfterPlayChangeFate,self,serverData) or GameVars.emptyFunc);
           _gamble_ani:pos(85/2,-85/2);
           FuncArmature.changeBoneDisplay(_gamble_ani,"layer2",_replace_view);
           _replace_view:pos(-85/2,85/2);
           _parent_panel.gamble_ani=_gamble_ani;
        end
	end
end
--改投结束
function YongAnGambleView:onChangeFateEnd(serverData)
	self:updateDicesView()
	self:updateCount()
	self:updateButtons()
	self:updateChangeFateCountOrCost()
	self:updateGambleRewardPreview()
	self:updateNpcTalks()
end

function YongAnGambleView:onBeginGambleTap()
--    self:onRoleDicesEnd();
	local leftCount = YongAnGambleModel:getGambleLeftCount()
	if leftCount <= 0 then
		WindowControler:showTips(GameConfig.getLanguage("tid_gamble_1008"))
		return
	end
	YongAnGambleServer:beginOneGamble(c_func(self.onRoleDicesEnd, self))
--   self:onRoleDicesEnd();
end

--投掷色子的动画播放完毕之后动作
function YongAnGambleView:afterPlayGambleAction(_gamble_ani)
--//删除掉动画
    self.mc_gamble:setVisible(true);
    local    _gamble_panel=self.mc_gamble:getViewByFrame(1).panel_shaizi;
 --   local    _parent=_gamble_panel:getParent();
   _gamble_ani:removeFromParent(true);
--//显示原来的面板
    _gamble_panel:setVisible(true);
--//刷新UI
	self.mc_gamble:showFrame(2)
	self:updateDicesView()
	self:updateButtons()
	self:updateCount()
	self:updateGambleRewardPreview()
	self:updateNpcTalks()

	EventControler:dispatchEvent(YongAnGambleEvent.YONGANGAMBLEEVENT_LEFT_PLAY_COUNT_CHANGE, {count = YongAnGambleModel:getGambleLeftCount()})
end
--//动画恢复原来的播放轨迹
function  YongAnGambleView:onGambleResume(_gamble_ani)
--    _gamble_ani:play();
    _gamble_ani:playWithIndex(1,false);
    _gamble_ani:doByLastFrame(true,false,c_func(self.afterPlayGambleAction,self,_gamble_ani));
end
--//动画的触屏事件
function YongAnGambleView:onTouchEventGambleEnded(_gamble_ani,_touch,_event)
--//动画先还原坐标,再执行动作
    local     _speedx=400;--//每秒400像素
    local     x=_touch:getLocationInView().x;
    local   _child_panel=_gamble_ani;--_gamble_ani:getBoneDisplay("layer2");
    local   _costTime=math.abs(_child_panel:getPositionX()-_child_panel.originPositionX)/_speedx;
    local   _moveBy=cc.MoveBy:create(_costTime,cc.p(_child_panel.originPositionX-_child_panel:getPositionX(),0));
    local   _delayCall=cc.CallFunc:create(c_func(self.onGambleResume,self,_gamble_ani));
--//删除手指移动特效
   _child_panel.arrow_ani:removeFromParent(true);
   _child_panel.arrow_ani_flip:removeFromParent(true);
   _child_panel.gesture_ani:removeFromParent(true);
--//并且解除掉动画上的触屏事件
   _child_panel.maskEventNode:getEventDispatcher():removeEventListener(_child_panel.maskListener);
    _child_panel.maskEventNode:removeFromParent(true);
    _child_panel.maskEventNode=nil;
    _child_panel:runAction(cc.Sequence:create(_moveBy,_delayCall));
end
--//起始函数
function YongAnGambleView:onTouchEventGambleBegan(_gamble_ani,_touch,_event)
    local   _child_panel=_gamble_ani--_gamble_ani:getBoneDisplay("layer2");
    _child_panel.offsetPositionX=_touch:getLocationInView().x;
    return true;
end
--//拖动函数
function YongAnGambleView:onTouchEventGambleMoved(_gamble_ani,_touch,_event)
    local   _child_panel=_gamble_ani--//_gamble_ani:getBoneDisplay("layer2");
    local   _x=_touch:getLocationInView().x;
    local   _offsetX=_x - _child_panel.offsetPositionX;
--//设置坐标,并且限定范围为水平240像素
    local    _max_moved_h=240;
    local    _now_offset=_child_panel.nowPositionX+_offsetX;
    if(math.abs(_child_panel.originPositionX-_now_offset)>240)then
           _child_panel.offsetPositionX=_x;
           return;
    end
    _child_panel.nowPositionX=_now_offset--;;_child_panel.nowPositionX+_offsetX;
    _child_panel:pos(_child_panel.nowPositionX,_child_panel.originPositionY);
--//
    _child_panel.offsetPositionX=_x;
end
--//头筛子动画播放到第56帧时暂停,注册触屏事件,等待事件触发完毕之后再执行展示结果动作
function YongAnGambleView:pauseGambleAni(_gamble_ani)
 --   _gamble_ani:pause();--//暂停动画的播放
--//,创建一个相同的Node,注册事件
    local   _child_panel=_gamble_ani;
    _child_panel.originPositionX,_child_panel.originPositionY=_child_panel:getPosition();
    _child_panel.nowPositionX=_child_panel:getPositionX();
    _child_panel.offsetPositionX=0;
--//手工注册事件
    local   _event_listener=cc.EventListenerTouchOneByOne:create();
    _event_listener:registerScriptHandler(c_func(self.onTouchEventGambleBegan,self,_gamble_ani), cc.Handler.EVENT_TOUCH_BEGAN);
    _event_listener:registerScriptHandler(c_func(self.onTouchEventGambleMoved,self,_gamble_ani), cc.Handler.EVENT_TOUCH_MOVED);
    _event_listener:registerScriptHandler(c_func(self.onTouchEventGambleEnded,self,_gamble_ani), cc.Handler.EVENT_TOUCH_ENDED);
    _event_listener:setSwallowTouches(true);
    _gamble_ani.maskListener=_event_listener;
    _gamble_ani.maskEventNode:getEventDispatcher():addEventListenerWithFixedPriority(_event_listener,-12);
--//加载手势特效,这是一个组合动画
    local   _ctnNode=self.ctn_mask;
    _ctnNode:zorder(2);
    local   _image_width=137;--//摇色子的图片的宽度
    local   _arrow_ani=self:createUIArmature("UI_dufang","UI_dufang_jiantoudong",_ctnNode,true,GameVars.emptyFunc);
    _arrow_ani:pos(-120,0);--//左侧
    local   _arrow_ani_flip=self:createUIArmature("UI_dufang","UI_dufang_jiantoudong",_ctnNode,true,GameVars.emptyFunc);
    _arrow_ani_flip:setScaleX(-1);
    _arrow_ani_flip:pos(120,0);
--//手指
    local   _gesture_ani=self:createUIArmature("UI_dufang","UI_dufang_huashouzhi",_ctnNode,true,GameVars.emptyFunc);
--//记录动画的引用
   _gamble_ani.arrow_ani=_arrow_ani;
   _gamble_ani.arrow_ani_flip=_arrow_ani_flip;
   _gamble_ani.gesture_ani=_gesture_ani;
end
--每一轮初始投掷结束
function YongAnGambleView:onRoleDicesEnd(serverData)
--//首先隐藏掉投掷筛子的panel
    local    _gamble_panel=self.mc_gamble:getViewByFrame(1).panel_shaizi;
    _gamble_panel:setVisible(false);
    local    _pointx,_pointy=_gamble_panel:getPosition();
    local    _parent=_gamble_panel:getParent();
--//加载动画
    local   _gamble_ani=self.gamble_ani--self:createUIArmature("UI_dufang","UI_dufang_shaizi",nil,false,GameVars.emptyFunc);
--    local   _other_parent=self.mc_gamble:getParent();
--    local   x,y=self.mc_gamble:getPosition();
--    _gamble_ani:pos(x,y);
--    _other_parent:addChild(_gamble_ani,2,0x57);
    _gamble_ani:registerFrameEventCallFunc(55,1,c_func(self.pauseGambleAni,self,_gamble_ani));
    _gamble_ani:playWithIndex(0,false);
--//执行动画上UI的替换
   local    _gamble_replace_view=self.mc_gamble:getViewByFrame(2).UI_dice_1.mc_dice;
    local arr = YongAnGambleModel:getDicesStatus()
	for index, frame in ipairs(arr) do
		assert(frame <= FuncYongAnGamble.DICES_COUNT and index<=FuncYongAnGamble.DICES_COUNT) ;
        local   _replace_view=UIBaseDef:cloneOneView(_gamble_replace_view);
        _replace_view:showFrame(frame);
        FuncArmature.changeBoneDisplay(_gamble_ani,"node"..index,_replace_view);
	end
    local    _maskEventNode=cc.Node:create();
    _maskEventNode:setContentSize(cc.size(426.5,193.25));
--    _maskEventNode:setAnchorPoint(cc.p(0,1));
    self.mc_gamble:setVisible(false);
    _parent:addChild(_maskEventNode,2);
    _maskEventNode:setPosition(cc.p(_pointx,_pointy-193.25));
    _gamble_ani.maskEventNode=_maskEventNode;
 --   self.gambleThrowAni=_gamble_ani;
--    local  _sprite=cc.Sprite:create("uipng/activity_img_icon.png");
--    _maskEventNode:addChild(_sprite);
end
--结果预览
function YongAnGambleView:updateGambleRewardPreview()
	local status_arr = YongAnGambleModel:getDicesStatus()
	local rewards = FuncYongAnGamble.getRewardsByStatus(status_arr)
	self.rewards = rewards
    local needNums,hasNums,isEnough,resType = UserModel:getResInfo(rewards[1])
	self.mc_gamble.currentView.panel_get.txt_2:setString(needNums)
end

--更新桌面
function YongAnGambleView:updateGambleDeskByStatus()
	local status, luckCount = YongAnGambleModel:getCurrentStatus()
	local frame = 1
	if status == FuncYongAnGamble.ROLL_STATUS.CHANGE then
		frame = 2
	end
	self.mc_gamble:showFrame(frame)
	if frame ==2 then
		self:updateDicesView()
		self:updateButtons()
		self:updateGambleRewardPreview()
	else
		local leftCount = YongAnGambleModel:getGambleLeftCount()
		local btn_begin_gamble = self.mc_gamble.currentView.btn_begin_gamble
		if leftCount <= 0 then
			FilterTools.setGrayFilter(btn_begin_gamble)
		else
			FilterTools.clearFilter(btn_begin_gamble)
		end
        local   _gamble_ani=self:createUIArmature("UI_dufang","UI_dufang_shaizi",nil,false,GameVars.emptyFunc);
        local   _other_parent=self.mc_gamble:getParent();
        local   x,y=self.mc_gamble:getPosition();
        _gamble_ani:pos(x,y);
       _other_parent:addChild(_gamble_ani);
--//动画停止在第一帧
       _gamble_ani:gotoAndPause(1);
       self.gamble_ani=_gamble_ani;
--//隐藏背景
       self.mc_gamble.currentView.panel_shaizi:setVisible(false);
	end
	self:updateChangeFateCountOrCost()
end


--更新骰子
function YongAnGambleView:updateDicesView()
	local arr = YongAnGambleModel:getDicesStatus()
    self.last_dice_status=arr;
--//统计有多少个满吉
    local   _gamble_complete=0;
	for index, frame in ipairs(arr) do
		if index > FuncYongAnGamble.DICES_COUNT then
			break
		end
		local ui_dice = self.mc_gamble.currentView["UI_dice_"..index]
		ui_dice:showPoint(frame)
        _gamble_complete = _gamble_complete +(frame==6 and 1 or 0);
	end
--//如果已经达到六个吉,则因为再无改进的空间,所以灰化掉
--       local   _gamble_btn_change=self.mc_gamble:getViewByFrame(2).btn_change_fate;
--    if(_gamble_complete>=6)then
----         _gamble_btn_change:enable(false);
--         FilterTools.setGrayFilter(_gamble_btn_change);
--    else
--         FilterTools.clearFilter(_gamble_btn_change);
--    end
end

--更新改投按钮状态，文字、置灰与否、是否可点击
function YongAnGambleView:updateButtons()
	local setGray = false
	if YongAnGambleModel:isMaxLuckAchieved() then
		setGray = true
	else
		setGray = false
		self.btn_change_fate:enabled(true)
	end
	local freeCountLeft = YongAnGambleModel:getGambleFreeChangeLeftCount()
	local btnTextTid = "tid_gamble_1001"
	if freeCountLeft <=0 then
		btnTextTid = "tid_gamble_1002"
		--付费改投次数也用完了
		if YongAnGambleModel:isMaxVipChangeCountReached() then
			--并且更高级vip不能提供更过的付费改投次数
			if not FuncYongAnGamble.isHigherVipHasMoreGambleChangeCount() then
				setGray = true
			end
		end
	end

	if setGray then
		FilterTools.setGrayFilter(self.btn_change_fate,2)
	else
		FilterTools.clearFilter(self.btn_change_fate,2)
	end

	self.btn_change_fate:setBtnStr(GameConfig.getLanguage(btnTextTid))
end

--更新改投按钮上方的免费次数或者元宝消耗信息
function YongAnGambleView:updateChangeFateCountOrCost()
	local mc = self.mc_gamble:getViewByFrame(2).mc_changefate_info
	local freeChangeCount = YongAnGambleModel:getGambleFreeChangeLeftCount()
	local freeChangeDailyMaxCount = FuncYongAnGamble.getDailyFreeChangeCount()
	if freeChangeCount <= 0 then
		mc:showFrame(2)
		local cost = FuncYongAnGamble.getChangeFateGoldCost()
		local isEnough = cost < UserModel:getGold()
		local txt = mc.currentView.txt_2
		txt:setString(cost)
		if not isEnough then
			txt:setColor(FuncCommUI.COLORS.TEXT_RED)
        else
           txt:setColor(FuncCommUI.COLORS.TEXT_WHITE);
		end
	else
		mc:showFrame(1)
		mc.currentView.txt_2:setString(string.format("(%s/%s)", freeChangeCount, freeChangeDailyMaxCount))
	end

end

--更新右上次数显示
function YongAnGambleView:updateCount()
--玩法次数
	local leftCount = YongAnGambleModel:getGambleLeftCount()
	local max = YongAnGambleModel:getMaxGambleCount()
--	local countStr = string.format("%s/%s", leftCount, max)
--	self.panel_count.txt_play_count:setString(countStr)
--    local    _template_string=GameConfig.getLanguage("gamble_extra_play_times_1001");

--剩余免费改投次数
	local freeChangeCount = YongAnGambleModel:getGambleFreeChangeLeftCount()
    local maxFreeChangeCount=FuncYongAnGamble.getDailyFreeChangeCount();
    self.oldString=string.format("%d/%d",leftCount,max);
   self.mc_gamble:getViewByFrame(1).txt_cs_2:setString(self.oldString);
--	if freeChangeCount > 0 then
--		self.panel_count.txt_free_change_count:setString(string.format("%s次", freeChangeCount))
      self.mc_gamble:getViewByFrame(2).mc_changefate_info:getViewByFrame(1).txt_2:setString(string.format("(%d/%d)",freeChangeCount,maxFreeChangeCount));
--	else
--		local chargeLeftCount = YongAnGambleModel:getGambleChargeChangeLeftCount()
--		self.panel_count.txt_free_change_count:setString(chargeLeftCount..'次')
--		self.panel_count.txt_2:setString(GameConfig.getLanguage("tid_gamble_1012"))
--        self.mc_gameble:getViewByFrame(2).mc_changefate_info:getViewByFrame(2).txt_2:setString();
--	end
end

function YongAnGambleView:setBonusTip()
	local nextBonusId = YongAnGambleModel:getNextBonusId()
	if nextBonusId then
--		self.panel_achievement.txt_1:setString(YongAnGambleModel:getBonusDescription(nextBonusId))
	else
--		self.panel_achievement:visible(false)
	end
end

function YongAnGambleView:close()
	self:startHide()
end

--npc根据当前骰子状态显示随机气泡
function YongAnGambleView:updateNpcTalks()
	local talk_content = YongAnGambleModel:getRandomNpcTalks()
	local panel_talk = self.panel_talk
	panel_talk.txt_1:setString(talk_content)
	local scalePos = cc.p(280,-105)
	local scaleTime = 0.5
	panel_talk:runAction(panel_talk:getFromToScaleAction(scaleTime, 0.1, 0.1, 1, 1, false, scalePos))
end

return YongAnGambleView
