--guan
--2015.12.15
--2016.02.12 换一次界面
--2016.06.25 换二次界面
--2016.07.22 为下面btn添加开启动画，抽出ui HomeMainCompoment 

require("game.sys.view.home.init");  

local HomeMainView = class("HomeMainView", UIBase);

function HomeMainView:ctor(winName)
    HomeMainView.super.ctor(self, winName);
    --全屏ui的数量 当全屏ui的数量为0的时候 那么应该显示自己
    self._fullUINums = 0

    self._pushSystemIdQueue = {};
end

function HomeMainView:onBecomeTopView()
    local currentSound = AudioModel:getCurrentMusic();
    if currentSound ~= MusicConfig.m_scene_main then 
        AudioModel:playMusic(MusicConfig.m_scene_main, true)
    end 
end


function HomeMainView:loadUIComplete()
	AudioModel:playMusic(MusicConfig.m_scene_main, true)

    self.panel_playerTitle:setVisible(false);
    self.panel_otherPlayerTitle:setVisible(false);

    self.panel_otherLvl:setVisible(false);
    
	self:registerEvent();
    -- self:initBtns();
    self:initPlayer();
    --只是上面红点和左侧红点
    self:initRedPoint();
    self:initPlayerInfo();
    self:initInvitationBar();
    self:initSysWillOpenUI();

    self:initTestBtn();

    --是否已经起名字了
    self:initNameView();

    FuncCommUI.setViewAlign(self.UI_downBtns,UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.panel_zuoshang,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.panel_youla,UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.UI_upBtns, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.ctn_OtherIcon, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.ctn_battleInvitation, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.panel_qian, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.UI_lamp,UIAlignTypes.MiddleTop)

    --发送事件，显示主界面，第一次显示时候主动调用
    EventControler:dispatchEvent(HomeEvent.SHOW_HOME_VIEW);

    --收到要匹配事件
    EventControler:addEventListener("notify_match_intive_906", 
        self.matchIntiveCallBack, self);

    --收到匹配时间到
    EventControler:addEventListener(HomeEvent.CHANGE_INAITATION_MATCH_ID_EVENT, 
        self.changeInvitationIdCallBack, self);

    --等级或名字发生变化或vip
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
        self.LvlChangeCallBack, self)
    EventControler:addEventListener(UserEvent.USEREVENT_NAME_CHANGE_OK, 
        self.nameChangeCallBack, self)
    EventControler:addEventListener(UserEvent.USEREVENT_SET_NAME_OK, 
        self.nameChangeCallBack, self)

    EventControler:addEventListener(UserEvent.USEREVENT_VIP_CHANGE, 
        self.vipChangeCallBack, self)

    EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, 
        self.goldChangeCallBack, self)

	--音乐设置变化
	EventControler:addEventListener(SettingEvent.SETTINGEVENT_MUSIC_SETTING_CHANGE, self.onMusicStatusChange, self)

    EventControler:addEventListener(LoginEvent.LOGINEVENT_LOG_OUT, self.lognOut, self)


    EventControler:addEventListener(HomeEvent.HOMEEVENT_COME_BACK_TO_MAIN_VIEW, 
        self.onHomeShow, self); 

    EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT, 
        self.onRechargeCallBack, self);

    EventControler:addEventListener(UserEvent.USEREVENT_PLAYER_POWER_CHANGE, 
        self.powerChange, self);


    if UserModel:isLvlUp() == true then 
        if UserModel:isNewSystemOpenByLevel( UserModel:level() ) == true then
            local sysNameKey = FuncChar.getCharLevelUpValueByLv(
                UserModel:level(), "sysNameKey");

            EventControler:dispatchEvent(
                HomeEvent.SYSTEM_OPEN_EVENT, {sysNameKey = sysNameKey});
        end 
    end 


end 

function HomeMainView:goldChangeCallBack()
    self:initPlayerInfo();
end

function HomeMainView:powerChange()
    self:setPlayerPower();
end

function HomeMainView:onRechargeCallBack()
    if VipModel:getNextVipGiltToBuy() ~= -1 then 
        self.panel_zuoshang.panel_red:setVisible(true);
    else 
        self.panel_zuoshang.panel_red:setVisible(false);
    end 
end 

function HomeMainView:onHomeShow()
    echo("----------------come home now---------------");
    WindowControler:clearUnusedTexture();

    self._mapNode:playAllSpine();
    self:visible(true)
    self:comeBackToThisView();

end

--//调整消息通知提示UI结构
function HomeMainView:notifyLampShow(_param)
      local   _lamps=_param.params;
      for _index=1,#_lamps do
               self.UI_lamp:insertMessage(_lamps[_index]);
      end
end

function HomeMainView:initNameView()
    local isNameInited = UserModel:isNameInited();
    local isAllFinish = TutorialManager.getInstance():isAllFinish();

    if isNameInited == false and IS_OPEN_TURORIAL == true and 
        isAllFinish == true then 
        self:delayCall(function ( ... )
           WindowControler:showWindow("PlayerRenameView");
        end)
    end 
end

function HomeMainView:lognOut()
    echo("0000000000000000000000000000000000000000------lognOut------");
    self:startHide();
end

function HomeMainView:vipChangeCallBack()
    self:initPlayerInfo();
end

function HomeMainView:nameChangeCallBack()
    self:initPlayerInfo();
end

function HomeMainView:LvlChangeCallBack()
    self:initPlayerInfo();
    self:initSysWillOpenUI();
end

function HomeMainView:initSysWillOpenUI()
    local willOpenName, sysOpenLvl = HomeModel:getWillOpenSysName();

    if sysOpenLvl == nil then 
        self.panel_youla.panel_4:setVisible(false);
    else 
        local panel = self.panel_youla.panel_4.btn_sysicon:getUpPanel();
        local ctn = panel.ctn_sysicon;
        ctn:removeAllChildren();
        local spPath = FuncRes.iconSys(willOpenName);

        local sp = display.newSprite(spPath);
        ctn:addChild(sp);

        sp:size(ctn.ctnWidth, ctn.ctnHeight);
        self.panel_youla.panel_4.btn_sysicon:setTap(c_func(self.pressWillOpenSys, 
            self, willOpenName, sysOpenLvl));

        local tidName = FuncCommon.getSysOpensysname(willOpenName);
        panel.txt_1:setString(GameConfig.getLanguage(tidName));

        --等级
        local lvlArray = number.split(sysOpenLvl);
        if table.length(lvlArray) == 1 then 
            --前10级
            panel.mc_qshu:setVisible(false);
            panel.mc_hshu:showFrame(lvlArray[1] + 1);
        else 
            panel.mc_qshu:setVisible(true);
            panel.mc_qshu:showFrame(lvlArray[1] + 1);
            panel.mc_hshu:showFrame(lvlArray[2] + 1);
        end 

    end
end

function HomeMainView:pressWillOpenSys(willOpenName, sysOpenLvl)
    WindowControler:showWindow("SysWillOpenView", willOpenName, sysOpenLvl);
end

function HomeMainView:onMusicStatusChange(event)
	local music_st = LS:pub():get(StorageCode.setting_music_st, FuncSetting.SWITCH_STATES.ON)
	if music_st == FuncSetting.SWITCH_STATES.ON then
		if audio.isMusicPlaying() then
			AudioModel:resumeMusic()
		else
			AudioModel:playMusic("m_scene_main", true)
		end
	end
end

function HomeMainView:initInvitationBar()
    self._isShowingInvatationBar = false;
end

function HomeMainView:createBattleInvitationView()
    local invitationBar = WindowsTools:createWindow("BattleInvitationView");
    self.ctn_battleInvitation:addChild(invitationBar);
    self._invitationBarWidth = invitationBar:getContainerBox().width;
    invitationBar:setPositionX( -self._invitationBarWidth);

    return invitationBar;
end

function HomeMainView:initRedPoint()

    self.panel_youla.panel_3.panel_red:setVisible(false);
    self.panel_youla.panel_2.panel_red:setVisible(HomeModel:isRedPointShow(HomeModel.REDPOINT.LEFTMARGIN.CHAT));
    self.panel_youla.panel_1.panel_red:setVisible(HomeModel:isRedPointShow(HomeModel.REDPOINT.LEFTMARGIN.FRIEND));

end

function HomeMainView:initPlayerInfo()
    self.panel_zuoshang:setTouchedFunc(c_func(self.clickPlayerInfo, self));
    self.panel_zuoshang:setTouchSwallowEnabled(true);

    local name = UserModel:name();
    self.panel_zuoshang.txt_1:setString(name);
    --等级
    local lvl = UserModel:level();

    if lvl < 10 then 
        self.panel_zuoshang.mc_2:showFrame(1);
    elseif lvl < 100 then
        self.panel_zuoshang.mc_2:showFrame(2);
    else 
        self.panel_zuoshang.mc_2:showFrame(3);
    end 
    self.panel_zuoshang.mc_2:getCurFrameView().txt_2:setString(lvl);

    --vip
    local vip = UserModel:vip();
    self.panel_zuoshang.mc_1:showFrame(vip + 1);
    self.panel_zuoshang.mc_1:setTouchedFunc(c_func(self.gotoVipView, self));
    self.panel_zuoshang.mc_1:setTouchSwallowEnabled(true);

    if VipModel:getNextVipGiltToBuy() ~= -1 then 
        self.panel_zuoshang.panel_red:setVisible(true);
    else 
        self.panel_zuoshang.panel_red:setVisible(false);
    end 

    --战力
    self:setPlayerPower();

    --头像
    local charIcon = CharModel:getCharIconSp();
    self.panel_zuoshang.ctn_touxiang:addChild(charIcon)
end

function HomeMainView:gotoVipView()
    local pageView = VipModel:getNextVipGiltToBuy();
    if pageView == -1 then 
        pageView = UserModel:vip();
    end 
    WindowControler:showWindow("VipMainView", false, pageView);
end

function HomeMainView:setPowerNum(nums)
    local len = table.length(nums);

    if len > 6 then 
        echo("-----------warning: power is over 999999!!!----------");
        return;
    end 

    self.panel_zuoshang.panel_zhanli.mc_shuzi:showFrame(len);

    for k, v in pairs(nums) do
        local mcs = self.panel_zuoshang.panel_zhanli.mc_shuzi:getCurFrameView();
        mcs["mc_" .. tostring(k)]:showFrame(v + 1);
    end
end

function HomeMainView:setPlayerPower()
    local power = UserModel:getAbility();
    local powerValueTable = number.split(power);

    self:setPowerNum(powerValueTable);
end

function HomeMainView:clickPlayerInfo()
    AudioModel:playSound("s_com_click1")
    echo("--clickPlayerInfo--");
    WindowControler:showWindow("PlayerInfoView");
end

function HomeMainView:initPlayer()
    local mapNode = HomeMapLayer.new(self);
    self._mapNode = mapNode;
    self:addChild(mapNode, -1);  
    echo("----HomeMainView:initPlayer---");
end

function HomeMainView:registerEvent()

	HomeMainView.super.registerEvent();

    --这里需要延迟2帧注册时间 因为上一个ui关闭的时候 也会接受到这个事件
    local tempFunc = function (  )
        EventControler:addEventListener(UIEvent.UIEVENT_SHOWCOMP ,self.onUIShowComp,self)
    end

    self:delayCall(tempFunc, 0.04)
	EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, self.onModelUpdateEnd, self)
    EventControler:addEventListener(HomeEvent.RED_POINT_EVENT,self.onFriendEventChanged,self);
    --左边两个btn
    self.panel_youla.panel_1.btn_1:setTouchedFunc(c_func(self.back, self));
    self.panel_youla.panel_1.btn_1:setTouchSwallowEnabled(true);

    self.panel_youla.panel_2.btn_1:setTouchedFunc(c_func(self.chatBtnClick, self));
    self.panel_youla.panel_2.btn_1:setTouchSwallowEnabled(true);
--//注册走马灯消息推送接收事件
    EventControler:addEventListener(HomeEvent.TROT_LAMP_EVENT,self.notifyLampShow,self);


    self.panel_youla.panel_3.btn_1:setTouchedFunc(c_func(self.changeMap, self));
end

function HomeMainView:changeMap()
    self._mapNode:changeMap();
end

--//好友事件变化
function HomeMainView:onFriendEventChanged(_event)
    local     _param=_event.params;
    if(_param.redPointType==HomeModel.REDPOINT.LEFTMARGIN.FRIEND)then
         self.panel_youla.panel_1.panel_red:setVisible(_param.isShow);
    end
end
function HomeMainView:chatBtnClick()
    echo("chatBtnClick");
--//设置等级限制
--chat_common_level_not_reach_1014
   local   _open,_level=FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.CHAT);
   local   _user_level=UserModel:level();
   if(_user_level<_level)then
           WindowControler:showTips(GameConfig.getLanguage("chat_common_level_not_reach_1014"):format(_level));
           return;
   end
   local   _select_index=1;
   if(ChatModel:isChatFlag())then
        _select_index=3;
   end
    local  chatUI=WindowControler:showTopWindow("ChatMainView",_select_index);

end

function HomeMainView:onModelUpdateEnd()
	self:initPlayerInfo()
end


--当一个ui开始显示的时候
--todo 判断是不是全屏界面  HOMEEVENT_COME_BACK_TO_MAIN_VIEW
function HomeMainView:onUIShowComp( e )
    local targetUI = e.params.ui
    if targetUI:checkIsFullUI() then
        self:visible(false)
        self:otherViewOnHome();
        --主界面人物不动
        self._mapNode:pauseAllSpine();
        self:resetBtnsCompoment();
    end
end

--其他界面在 home 上面
function HomeMainView:otherViewOnHome()
    EventControler:dispatchEvent(HomeEvent.OTHER_VIEW_ON_HOME);
end


--又返回这个界面执行的函数, 这个是全屏界面才做的判断
function HomeMainView:comeBackToThisView()
    -- echo("------HomeMainView:comeBackThisView--------");
    self._mapNode:updateNpcUI();
end

function HomeMainView:resetBtnsCompoment()
    echo("---HomeMainView:resetBtnsCompoment---");
    --有新的btn出现进行重置
    if self.UI_downBtns._isNeedReSetDownBtns == true then 
        self.UI_downBtns._isNeedReSetDownBtns = false;
        self.UI_downBtns:resetBtns();
    end 
end

function HomeMainView:back()
--    WindowControler:showWindow("CharNatalView");
--   FuncCommUI.startRewardView({[1]="2,15",[2]="2,20",[3]="2,30"});
   FriendViewControler:showView();
-- local   _lamp={};
-- _lamp.id="7"
-- _lamp.name="2016年5月23日，李克强总理考察湖北十堰市民服务中心，细询营改增实施效果，并再次重申“所有行业税负只减不增”。 　　3月18日召开的国务院常务会议决定，为进一步减轻企业负担，促进经济结构转型升级，从今年5月1日起，将营改增试点范围扩大到建筑业、房地产业、金融业和生活服务业，并将所有企业新增不动产所含增值税纳入抵扣范围。4月30日，国务院印发《关于做好全面推开营改增试点工作的通知》和《全面推开营改增试点后调整中央与地方增值税收入划分过渡方案的通知》，要求各级政府平稳、有序开展工作，确保各行业税负只减不增。"
-- self.UI_lamp:insertMessage(_lamp);
end

function HomeMainView:matchIntiveCallBack(e)
    echo("---------收到战斗邀请————————————");
    dump(e.params, "------eeeee----");
    local matchData = e.params.params.data;

    --队列中直接加个 matchId
    HomeModel:addMatchId(matchData.poolSystem);
    
    -- 是否已经显示了 邀请战斗 条
    if self._isShowingInvatationBar ~= true then 
        local matchId = HomeModel:getLastestMatchId();
        local uniqueId = HomeModel:getLastestUniqueId();
        echo("------matchId-------" .. tostring(matchId));
        -- echo("------uniqueId-------" .. tostring(uniqueId));

        HomeModel:deleteQueneValueByUniqueId(uniqueId);
        self:showInvitationBar(matchId, uniqueId);

    end 
end

local ActionDuraringTime = 0.3;

function HomeMainView:showInvitationBar(matchId, uniqueId)
    HomeModel:setCurShowUniqueId(uniqueId);
    
    self._invitationBar = self:createBattleInvitationView();
    self._invitationBar:updateUI(matchId);

    --动画
    local moveAction = cc.MoveTo:create(ActionDuraringTime, 
        cc.p(0, self._invitationBar:getPositionY()));

    self._invitationBar:runAction(moveAction);
    self._isShowingInvatationBar = true;
end

function HomeMainView:changeInvitationIdCallBack()
    self._isShowingInvatationBar = false;
    echo("---------changeInvitationIdCallBack-------");

    local oldInvitationBar = self._invitationBar;
    --删除老的
    if oldInvitationBar ~= nil then
        local fadeAction = cc.FadeTo:create(ActionDuraringTime, 0);

        oldInvitationBar:runAction(cc.Sequence:create(fadeAction, cc.CallFunc:create(
                function ()
                    self:delayCall(
                        function ( ... )
                            echo("--oldInvitationBar removeFromParent--");
                            oldInvitationBar:removeFromParent();
                        end
                    )
                end
                )
            )
        );

        self._invitationBar = nil;
    end 

    local matchId = HomeModel:getLastestMatchId();
    local uniqueId = HomeModel:getLastestUniqueId();

    if matchId ~= nil then 
        self:showInvitationBar(matchId, uniqueId);
    end 
end

function HomeMainView:initTestBtn()
    if DEBUG_ENTER_SCENE_TEST == true then 
        self.btn_goToTest:setTap(c_func(self.gototest, self));
    else 
         self.btn_goToTest:setVisible(false);
    end 
end

function HomeMainView:gototest()
    self:startHide();
end

function HomeMainView:deleteMe()
    self._mapNode:dispose();
    HomeMainView.super.deleteMe(self);

    UserModel:cacheUserData();
end 

return HomeMainView;











