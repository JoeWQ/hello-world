local ArenaPlayerView = class("ArenaPlayerView", UIBase)

function ArenaPlayerView:ctor(winName)
	ArenaPlayerView.super.ctor(self, winName)
end

function ArenaPlayerView:loadUIComplete()
	self:registerEvent()
end

function ArenaPlayerView:registerEvent()
end

function ArenaPlayerView:setPlayerInfo(info)
	self.info = info
    local hid = self.info.avatar
    if info.type == FuncPvp.PLAYER_TYPE_ROBOT then
        local _robot_item = FuncPvp.getRobotById(info.rid)
        local _char_item = FuncChar.getHeroData(_robot_item.avatar)
        hid = _robot_item.avatar
        self.info.ability = _robot_item.ability
        self.info.level = _robot_item.lv
        self.info.avatar = _robot_item.avatar
        self.info.name = FuncAccountUtil.getRobotName(self.info.rid)
    end
	self.treasureSourceData = FuncChar.getDefaultTreasureSourceData(hid..'')
end
--只有角色本身才可以调用的函数

function ArenaPlayerView:setArenaMainView(mainView)
	self.arenaMainView = mainView
end

function ArenaPlayerView:isTopThree()
	local rank = self.info.rank or 20001
	return rank <= 3
end
--当调用这个函数的时候,一定是柱子上的Player View
function ArenaPlayerView:updateUI(showAnim)
	if not self.info then return end
    self.mc_info:showFrame(1)
    local _panel_item = self.mc_info.currentView.panel_1
    --判断是否为自己,以及是否为达到了前三名
    local _userId =UserModel:rid()
    --挑战5次功能需要满足这个条件限制
    local _user_level = UserModel:level()
    local _require_level = FuncDataSetting.getDataByConstantName("PvpFive")
    local _visibility = false
    if self.info.rid == _userId  then--前三名
        if self.info.rank < FuncPvp.SHOW_SELF_MIN_RANK then
            _panel_item.mc_g200:showFrame(3)
            _panel_item.mc_g200.currentView.btn_jian:setTap(c_func(self.clickButtonDefence,self))
            _panel_item.mc_g200:setVisible(true)
        else
          _panel_item.mc_g200:setVisible(false)
           _visibility = true
        end
    elseif self.info.rank > PVPModel:getUserRank() and _user_level >=_require_level then --排名在角色之后,且满足等级要求
        _panel_item.mc_g200:showFrame(2)
        _panel_item.mc_g200.currentView.btn_jian:setTap(c_func(self.clickButtonChallenge5Times,self))
        self._challengeCost = FuncPvp.getChallenge5TimesCost()
        _panel_item.mc_g200.currentView.panel_200.txt_1:setString(tostring(self._challengeCost)) --花费
        --玩家购买了挑战次数
        EventControler:addEventListener(PvpEvent.PVPEVENT_BUY_CHALLENGE_COUNT_OK,self.notifyChallengeTimes,self)
        --自己的已经经过的挑战次数发生了变化
        EventControler:addEventListener(FuncCount.COUNT_TYPE.COUNT_TYPE_PVPCHALLENGE,self.notifyChallengeTimes,self)
        --冷却时间发生了变化
        EventControler:addEventListener(PvpEvent.PVPEVENT_CLEAR_CHALLENGE_CD_OK,self.notifyChallengeTimes,self)
        EventControler:addEventListener("CD_ID_PVP_UP_LEVEL",self.notifyChallengeTimes,self)
    else
        --如果自己小于前10名,则不可挑战前10名的
        if self.info.rank < 10 and PVPModel:getUserRank() >10 then
            _panel_item.mc_g200:setVisible(false)
        else
            _panel_item.mc_g200:showFrame(1)
            _panel_item.mc_g200.currentView.btn_jian:setTap(c_func(self.clickButtonChallenge,self))
        end
    end
    _panel_item.btn_fs:visible(_visibility) --其他UI直接隐藏
    if  _visibility then
        _panel_item.btn_fs:setTap(c_func(self.clickButtonDefence,self))
    end
	self:setPlayerName(self.info.name)
	self:initAvatar(showAnim)
	--战力
	self:setAbility()
--	self:initTitle()
	self:setRank()
    --设置按钮事件
    if self.info.rid == _userId then--如果是自己,点击弹出防御阵容
        _panel_item.btn_1:setTap(c_func(self.clickButtonViewSelf,self))
    else--否则弹出角色展示
         _panel_item.btn_1:setTap(c_func(self.clickButtonPlayerDetail,self))
    end
end
--竞技场挑战次数花费产生变化
function ArenaPlayerView:notifyChallengeTimes()
    --排名必须必玩家自己的低
    local _user_rank = PVPModel:getUserRank()
    local _user_level = UserModel:level()
    local _need_pvp_level = FuncDataSetting.getDataByConstantName("PvpFive")
    if self.info and self.info.rank > _user_rank and _user_level >= _need_pvp_level then
        local _panel_item = self.mc_info.currentView.panel_1
        self._challengeCost = FuncPvp.getChallenge5TimesCost()
        _panel_item.mc_g200.currentView.panel_200.txt_1:setString(tostring(self._challengeCost)) --花费
    end
end
--展示玩家自己的防御阵容
function ArenaPlayerView:clickButtonViewSelf()
        local _treasure ={}
        local _treasures = TreasuresModel:getAllTreasure()
        for _key,_value in pairs(_treasures) do
            _treasure[_key] = {
                id = _key,
                level = _value:level(),
                state = _value:state(),
                star = _value:star(),
                status = _value:status(),
            }
        end
        local _playerInfo ={
            rid_back = self.info.rid,
            rid = self.info.rid,
            rank = self.info.rank,
            ability = self.info.ability,
            name = self.info.name ~= "" and  self.info.name or FuncCommon.getPlayerDefaultName(),
            level = UserModel:level(),
            avatar = self.info.avatar,
            vip = UserModel:vip(),
            guildName = "",
            quality = UserModel:quality(),
            star = 1,--UserModel:star(), --现在因为主角没有星级,所以就暂时设置为1
            treasures = _treasure,
            partners = PartnerModel:getAllPartner(),
            formations = TeamFormationModel:getPVPDefenceFormation(),
        }
        _playerInfo.formations.partnerFormation = _playerInfo.formations.partnerFormation or {}
        _playerInfo.formations.treasureFormation = _playerInfo.formations.treasureFormation or {}
        WindowControler:showWindow("ArenaDetailView",_playerInfo,self.arenaMainView)
end
--玩家详情展示
function ArenaPlayerView:clickButtonPlayerDetail()
    local _playerInfo = self.info
    if _playerInfo.type == FuncPvp.PLAYER_TYPE_ROBOT then--如果是机器人
        self:displayRobot()
        return
    end
    --发送协议,获取玩家的信息
    PVPServer:requestPlayerDetail(self.info.rid,c_func(self.onPlayerDetailEvent,self))
end
function ArenaPlayerView:onPlayerDetailEvent(_event)
    if _event.result ~= nil then
        local _playerInfo = _event.result.data
        _playerInfo.rank = self.info.rank --将排名数据增加进去,后面要用到
        _playerInfo.ability = self.info.ability
        _playerInfo.rid_back = self.info.rid
        _playerInfo.name = self.info.name~= "" and  self.info.name or FuncCommon.getPlayerDefaultName()
        WindowControler:showWindow("ArenaDetailView",_playerInfo,self.arenaMainView)
    else
        echo("---------ArenaPlayerView:onPlayerDetailEvent------",_event.error.message)
    end
end
--如果是机器人,则构造信息并直接调用相关UI
function ArenaPlayerView:displayRobot()
    --读取表格 config/robot/
    local _robot_item = FuncPvp.getRobotById(self.info.rid)
    --所携带的法宝,以及和法宝相关的槽位
    local _treasureInfos = {
    }
    local _treasureFormation = {}
    for _key,_value in pairs( _robot_item.treasures) do
        _treasureInfos[tostring(_value.id)] = _value
        if table.length(_treasureFormation) < 2 then
            _treasureFormation["p"..(table.length(_treasureFormation)+1)] = tostring(_value.id)
        end
    end
    --伙伴以及伙伴的阵型
    local _partners = {
    }
    local _partnerFormation={}
    for _index=1,6 do
        local _partnerInfo = _robot_item["showPart".._index]
        if _partnerInfo ~=nil then
            _partners[_partnerInfo[1] ] ={
                id = tonumber(_partnerInfo[1]),
                level = tonumber(_partnerInfo[2]),
                star = tonumber(_partnerInfo[3]),
                quality = tonumber(_partnerInfo[4]),
            }
            _partnerFormation["p".._index] = _partnerInfo[1]
        end
    end
    --有关伙伴,法宝的槽位
    local _formations ={
        partnerFormation = _partnerFormation,
        treasureFormation = _treasureFormation,
    }
    --数据的整合
    local _playerInfo = {
        rid_back =self.info.rid_back,
        rid = self.info.rid,
        name = self.info.name,
        rank = self.info.rank,
        level = _robot_item.lv,
        avatar = self.info.avatar,
        ability = self.info.ability,
        vip = 0,    --vip统一为0
        guildName = nil,--没有公会名字

        treasures = _treasureInfos,
        partners = _partners,
        formations = _formations,
    }
    WindowControler:showWindow("ArenaDetailView",_playerInfo,self.arenaMainView)
end
--弹出防守阵容UI
function ArenaPlayerView:clickButtonDefence()
    --发送协议,获取玩家的信息
 --   PVPServer:requestPlayerDetail(self.info.rid,c_func(self.displayPlayerEvent,self))
--    self:displayPlayerEvent()
    WindowControler:showWindow("TeamFormationView",nil,FuncTeamFormation.formation.pvp_defend)
end
--展示玩家自己的防御阵容
function ArenaPlayerView:displayPlayerEvent(_event)
    if _event.result ~= nil then 
        local _playerInfo = _event.result.data
        _playerInfo.rid_back =self.info.rid_back
        _playerInfo.rank = self.info.rank
        _playerInfo.ability = self.info.ability
        _playerInfo.name = self.info.name ~= "" and  self.info.name or FuncCommon.getPlayerDefaultName()
        WindowControler:showWindow("ArenaDetailView",_playerInfo)
    else
        echo("-----error in ArenaPlayerView:displayPlayerEvent-------",_event.error.message);
    end
--        local _treasure ={}
--        local _treasures = TreasuresModel:getAllTreasure()
--        for _key,_value in pairs(_treasures) do
--            _treasure[_key] = {
--                id = _key,
--                level = _value:level(),
--                state = _value:state(),
--                star = _value:star(),
--                status = _value:status(),
--            }
--        end
--        local _playerInfo ={
--            rid = self.info.rid,
--            rank = self.info.rank,
--            ability = self.info.ability,
--            name = self.info.name ~= "" and  self.info.name or FuncCommon.getPlayerDefaultName(),
--            level = UserModel:level(),
--            avatar = self.info.avatar,
--            vip = UserModel:vip(),
--            guildName = "",
--            treasures = _treasure,
--            partners = PartnerModel:getAllPartner(),
--            formations = TeamFormationModel:getFormation(GameVars.battleLabels.pvp) or {},
--        }
--        _playerInfo.formations.partnerFormation = _playerInfo.formations.partnerFormation or {}
--        _playerInfo.formations.treasureFormation = _playerInfo.formations.treasureFormation or {}
--        WindowControler:showWindow("ArenaDetailView",_playerInfo)
end
--挑战5次
function ArenaPlayerView:clickButtonChallenge5Times()
    --检测仙玉是否足够
    local _user_gold = UserModel:getGold()
    if _user_gold < self._challengeCost then
        WindowControler:showTips(GameConfig.getLanguage("tid_shop_1030"))
        return
    end
    local _user_formation = table.deepCopy(TeamFormationModel:getPVPFormation())
    local _formation = {
        treasureFormation = table.deepCopy(_user_formation.treasureFormation),
        partnerFormation = table.deepCopy(_user_formation.partnerFormation),
    }
    local _param = {
        opponentRid = self.info.rid_back, --对手的rid
        userRank = PVPModel:getUserRank(),
        formation = _formation, --自己的布阵内容
    }
    PVPServer:requestChallenge5Times(_param,c_func(self.onChallenge5Event,self))
end
--挑战5次返回
function ArenaPlayerView:onChallenge5Event(_event)
    if _event.result ~= nil then
        local _playerInfo = _event.result.data
        local _userInfo = {
            avatar = UserModel:avatar(),
            level = UserModel:level(),
            vip = UserModel:vip(),
            quality = UserModel:quality(),
            star = 1,--UserModel:star(),
        }
        WindowControler:showWindow("ArenaChallenge5View",_userInfo,self.info,_event.result.data.results)
        --在下方同时刷新UI
        self:delayCall(c_func(self.refreshMainView,self,_event),0.001)
    elseif _event.error.message == "user_gold_not_enough" then
        WindowControler:showTips(GameConfig.getLanguage("tid_shop_1030")) --仙玉不足
    else
        echo("----ArenaPlayerView:onChallenge5Event------",_event.error.message)
    end
end
function ArenaPlayerView:refreshMainView(_event)
    self.arenaMainView:onCloudDisappear(_event)
 --   self:startHide()
end
--挑战
function ArenaPlayerView:clickButtonChallenge()
     --检测是否有挑战的资格
    local _user_rank = PVPModel:getUserRank()
    if _user_rank>10 and self.info.rank <FuncPvp.SHOW_SELF_MIN_RANK then --require top 10
        WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1043"));
        return
    end
    --检测是否有冷却行为
    local _time_left = FuncPvp.getPvpCdLeftTime()
    if _time_left > 0 then
        WindowControler:showWindow("ArenaClearChallengeCdPop")
        return
    end
     --检测是否还有挑战次数
    local _times_left = FuncPvp.getPvpChallengeLeftCount()
    if _times_left <= 0 then
        WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1042"))
        return
    end
    WindowControler:showWindow(     
        "TeamFormationView",
        nil,
        FuncTeamFormation.formation.pvp_attack,
        self.info
       )
end

function ArenaPlayerView:setAbility()
    local infoUI = self.mc_info.currentView.panel_1

    local numArray = number.split(self.info.ability);
    local len = table.length(numArray);

    if len > 7 then 
        echoWarn("------error: setPower len > 7 !!!-----");
    end 
    if len > 0 then
        infoUI.mc_3:showFrame(len);
        for k, v in pairs(numArray) do
            local mcs = infoUI.mc_3:getCurFrameView();
            mcs["mc_zi" .. tostring(k)]:showFrame(v + 1);
        end
    else
        echo("self.info.rank = "..self.info.ability)
        echo("self.info.rankLen = "..len)
        echoWarn("------error: setPower len <= 0 !!!-----");
    end
end

function ArenaPlayerView:setRank()
	local rank = tonumber(self.info.rank)
	--排名
    local _user_rank = PVPModel:getUserRank()
--    local _userId = UserModel:rid()
    local _player_item = self.info
    local _panel_rank = self.mc_info.currentView.panel_1
    if _player_item.rank>3 then --第3名以上,统一为程序字
        _panel_rank.mc_2:showFrame(1);
        _panel_rank.mc_2.currentView.txt_1:setString(tostring(_player_item.rank))
    else
        _panel_rank.mc_2:showFrame(_player_item.rank+ 1)
    end

	local rankBgFrame = _yuan3(rank<=3,2,1)
	self.mc_info:getViewByFrame(1).panel_1.mc_1:showFrame(rankBgFrame)
--//英雄的底部的底座显示
    local    _viewBottom=self.mc_info:getViewByFrame(1).panel_1.mc_bottom;
   -- _viewBottom:setVisible(self.info.rank~=1);--//第一名底座消失
--    if(self.info.rank<=10)then
--            _viewBottom:showFrame(1);
--    elseif(self.info.rank<=100)then
--            _viewBottom:showFrame(2);
--    else
--            _viewBottom:showFrame(3);
--    end
       local _frame = self.info.rank >3 and 4 or self.info.rank
       _viewBottom:showFrame( 4 - _frame +1)
end

function ArenaPlayerView:getTalkCtn()
	return self.mc_info.currentView.panel_1.ctn_talk
end

function ArenaPlayerView:showRandomTalk()
	if not self.arenaMainView then
		return
	end
	local scalePos = cc.p(0,-40)
	local scaleTime = 0.2
	local talkContent = FuncPvp.getRandomTalk(self.info.rank)
	if self.talkView then
		self.talkView:visible(true)
	else
		local arenaMain = self.arenaMainView
		self.talkView = UIBaseDef:cloneOneView(arenaMain.UI_player_talk)
		local talkCtn = self:getTalkCtn()
		local newPos = talkCtn:convertLocalToNodeLocalPos(arenaMain, cc.p(0,0))
		self.talkView:addTo(arenaMain):pos(newPos)
	end
	self.talkView:setTalkContent(talkContent)
	self.talkView:runAction(self.talkView:getFromToScaleAction(scaleTime, 0.1, 0.1, 1, 1, true, scalePos))

	--TODO 播放动作崩溃
	self:playTalkAction()
	--
	self:delayCall(c_func(self.talkView.visible, self.talkView, false), 2)
	return self.talkView
end

--播放攻击、施法动作
function ArenaPlayerView:playTalkAction()
    --删掉其他动作
--	local keys = {"atkNear", "giveOutA"}
--	local index = RandomControl.getOneRandomInt(#keys+1, 1)
--	local actionKey = keys[index]
	--echo(index, 'ArenaPlayerView,index')
	local label = self.treasureSourceData[actionKey]
--	if label and self.viewSpine then
    if  self.viewSpine then
   --     self.viewSpine:playLabel(label, false)
		FuncChar.playNextAction(self.viewSpine); --     self.viewSpine:playLabel(label, false)
		local frame = self.viewSpine:getCurrentAnimTotalFrame()
		local onActionOver = function()
			self.viewSpine:playLabel(self.treasureSourceData['stand'], true)
		end
		self.viewSpine:delayCall(onActionOver, 1.0/GAMEFRAMERATE*frame)
	end
end


function ArenaPlayerView:adjustTalkViewPos(deltaY)
	local talkView = self.talkView
	if talkView then
		local x,y = talkView:getPosition()
		talkView:pos(cc.p(x, y + deltaY))
	end
end

function ArenaPlayerView:hideTalk()
	if self.talkView then
		self.talkView:visible(false)
	end
end

function ArenaPlayerView:showTopThreeMark()
	self.mc_info:showFrame(5 - tonumber(self.info.rank))
end

function ArenaPlayerView:initTitle()
--PVP 称号功能砍掉
    self.mc_info.currentView.panel_1.mc_title:visible(false)
--	local ability = self.info.ability
--	local titleId = FuncPvp.getTitleByAbility(ability)
--	local mc_title = self.mc_info.currentView.panel_1.mc_title
--	local ctn_title = self.mc_info.currentView.panel_1.ctn_title
--	if titleId == nil then
--		mc_title:visible(false)
--	else
--		mc_title:visible(true)
--		mc_title:showFrame(tonumber(titleId))
--		local titleAnim = self:createUIArmature("UI_arena","UI_arena_waikuang", ctn_title, true, GameVars.emptyFunc)
--	end
end

function ArenaPlayerView:setPlayerName(name)
	name = name or ""
	if self.info.type ~= FuncPvp.PLAYER_TYPE_ROBOT then
		name = _yuan3(name == "", FuncCommon.getPlayerDefaultName(), name)
	end
	self.mc_info.currentView.panel_1.txt_playername:setString(name)
end

function ArenaPlayerView:setTapFunc(tapCFunc)
	self.mc_info.currentView.panel_1.btn_1:setTap(tapCFunc)
end

function ArenaPlayerView:initAvatar(showAnim)
	local avatarId = self.info.avatar
	local ctn = self.mc_info.currentView.panel_1.btn_1:getUpPanel().ctn_1
	local showArtSpine = function()
        if self.viewSpine then
               FuncChar.deleteCharOnTreasure(self.viewSpine);
               self.viewSpine=nil;
        end
        self:updatePlayerAttachState(true);
    	ctn:removeAllChildren()
        local  sp;
        local  other_flag=nil
        local     _rid=UserModel:rid();
        local     other_flag=   _rid ~= self.info.rid
        if(self.info.pvpTreasureNatal~=nil)then
            sp= FuncChar.getCharOnTreasure( tostring(avatarId),self.info.level or 1, self.info.pvpTreasureNatal,   false ):addto(ctn)
        else
		   -- sp = FuncChar.getSpineAni(avatarId..'', self.info.level or 1):addto(ctn)
            sp= FuncChar.getCharOnTreasure( tostring(avatarId),self.info.level or 1, tostring(tonumber(avatarId)-100),   false ):addto(ctn)
        end
		self.viewSpine = sp
        --非主角,可以播放站立动作
        if(other_flag)then
	     	sp:playLabel(self.treasureSourceData['stand'], true)
        end
		sp:setSkin("zi_se")
		sp:setScale(1.2)
		if self.playerBgAnim == nil then
			local ctn_bottom =  self.mc_info.currentView.panel_1.ctn_bottom
            local      ani_name="UI_arena_lihuishenhou_lanse"
            if(self.info.rank<=10)then
                   ani_name="UI_arena_lihuishenhou_huangse"
            elseif(self.info.rank<=100)then
                   ani_name="UI_arena_lihuishenhou_zise"
            end
			self.playerBgAnim = self:createUIArmature("UI_arena",ani_name, ctn_bottom, true, GameVars.emptyFunc)
		end
	end
    local    function   _delayCallFunc()
        local ctn_texiao = self.mc_info.currentView.panel_1.ctn_chuxian_texiao
		if not self.chuxianAnim then
			local chuxianAnim = self:createUIArmature("UI_chuchangguang","UI_chuchangguang", ctn_texiao, false, GameVars.emptyFunc)
			self.chuxianAnim = chuxianAnim
		end

		self.chuxianAnim:registerFrameEventCallFunc(12, 1, c_func(showArtSpine))
		self.chuxianAnim:gotoAndPause(1)
		self.chuxianAnim:startPlay(false)
    end
	if showAnim then
        if self.viewSpine then
               FuncChar.deleteCharOnTreasure(self.viewSpine);
               self.viewSpine=nil;
        end
        ctn:removeAllChildren();
        self:delayCall(_delayCallFunc,0.3);
	else
		showArtSpine()
	end
end
--//清除角色
function    ArenaPlayerView:removeOriginPlayer()
    local   _panel=self.mc_info.currentView.panel_1.btn_1:getUpPanel();
    local ctn = _panel.ctn_1
     if self.viewSpine then
           FuncChar.deleteCharOnTreasure(self.viewSpine);
           self.viewSpine=nil;
    end
    self:updatePlayerAttachState(false);
    ctn:removeAllChildren()
end
function   ArenaPlayerView:updatePlayerAttachState( isShow)
    local   _panel=self.mc_info.currentView.panel_1;
    _panel.mc_1:setVisible(isShow);
    _panel.mc_2:setVisible(isShow);
    _panel.txt_playername:setVisible(isShow);
    _panel.mc_3:setVisible(isShow);
--    _panel.mc_bottom:setVisible(isShow)
    local _user_rid = UserModel:rid()
    local _user_rank = PVPModel:getUserRank()
    --可以操作挑战按钮的条件
    local _operate_condition =false
    if not self.info then
        _operate_condition = true
    elseif _user_rid ~= self.info.rid then
        if self.info.rank >= FuncPvp.SHOW_SELF_MIN_RANK then
            _operate_condition = true
        elseif _user_rank <= 10 then --挑战资格
            _operate_condition = true
        end
    end
    if _operate_condition then
        _panel.mc_g200:setVisible(isShow)
    end
    _panel.panel_zhandi:setVisible(isShow)
    if(not isShow and self.talkView )then
           self.talkView:setVisible(false);
    end
end
function ArenaPlayerView:tryToChallenge()
	
	----点自己没反应
	if self.info.rid..'' == UserModel:rid()..'' then
		return
	end

	--不能打比自己排名低的
	if PVPModel:getUserRank() < tonumber(self.info.rank) then
		WindowControler:showTips(GameConfig.getLanguage('tid_pvp_1044'))
		return 
	end
	--检查是否能挑战前三
	if not FuncPvp.canChallengeTop3(PVPModel:getUserRank(), self.info.rank) then
		WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1043"))
		return
	end
        local  _user_vip=UserModel:vip();
	--检查剩余挑战次数
	local leftCount = FuncPvp.getPvpChallengeLeftCount()
	if leftCount <= 0   then--//VIP 3或者以上可以购买剩余挑战次数
       if( _user_vip>=3)then
		      PVPModel:tryShowBuyPvpView()
       else
		     WindowControler:showTips(GameConfig.getLanguage("pvp_today_times_useup_1001"))
       end
        return--//无论以上两种情况哪一种发生,都需要直接返回
	end

	--检查cd
    if(_user_vip<6)then--VIP 小于6会出现CD
	       local cdLeft = FuncPvp.getPvpCdLeftTime()
	      if cdLeft > 0 then
		         WindowControler:showWindow("ArenaClearChallengeCdPop")
	             return
	     end
    end


	local info = self.info 
	--WindowControler:showTips("开始挑战")
	PVPServer:startChallenge(info.rid, info.rank, c_func(self.onStartChallengeEnd, self))
end

function ArenaPlayerView:onStartChallengeEnd(event)
	local errorData = event.error
	if errorData then
		--战斗异常1.对手正在战斗 2. 对手排名变化 3 玩家排名变化
		local code = tonumber(errorData.code)
		local code_white_list = {110501, 110502, 110506}
        local   _refresh=false
        if(  event.error.message=="user_pvprank_changed"  )then
            WindowControler:showTips(GameConfig.getLanguage("pvp_self_rank_changed_1001"));
            _refresh=true
        elseif(event.error.message=="opponent_rank_have_changed")then
             WindowControler:showTip(GameConfig.getLanguage("pvp_enemy_rank_change_1002"));
              _refresh=true
        elseif(event.error.message=="opponent_in_challenge")then
              WindowControler:showTips(GameConfig.getLanguage("pvp_enemy_fall_changing_1003"));
              _refresh=true
--		elseif table.find(code_white_list, code) then
--			--重新拉取排行信息
--			EventControler:dispatchEvent(PvpEvent.PVPEVENT_PVP_FIGHT_EXCEPTION)
		end
        if( _refresh  )then
                EventControler:dispatchEvent(PvpEvent.PVPEVENT_PVP_FIGHT_EXCEPTION)
        end
	else
		WindowControler:showBattleWindow("ArenaBattleLoading", self.info)
		--获取玩家信息ok，可以进行本地战斗
		--玩家的战斗属性，战斗中用
		local data = event.result.data
		local info = self:createBattleInfo(data)
		PVPModel:setCurrentPvpBattleInfo(info)
        info.battleLabels = GameVars.battleLabels.pvp
		BattleControler:startPVP(info)
		--self:testShowPvpBattle(battleInfo)
	end
end

--构造pvp战斗需要的数据
function ArenaPlayerView:createBattleInfo(data)
	local enemyInfo = data.opponentBattleInfo
	local myInfo = data.userBattleInfo
	if myInfo.rank then
		PVPModel:setUserRank(tonumber(myInfo.rank))
	end

	enemyInfo.team = 2
	if enemyInfo.userBattleType == Fight.people_type_robot then
		local treasures =enemyInfo.treasures
		local t = {}
		for _, treasure in ipairs(treasures) do
			t[treasure.id] = treasure
		end
		enemyInfo.treasures = t
		enemyInfo.name = GameConfig.getLanguage(enemyInfo.name)
	end


	myInfo.team = 1
	myInfo.titleId = FuncPvp.getTitleByAbility(UserModel:getAbility() or 0)
	enemyInfo.titleId = FuncPvp.getTitleByAbility(enemyInfo.ability or 0)
	local battleInfo = {
		battleUsers = {
			myInfo,
			enemyInfo, 
		},
		randomSeed = data.randomSeed,
		battleId = data.battleId,
		battleLabel = GameVars.battleLabels.pvp,
	}
	return battleInfo
end


function ArenaPlayerView:testShowPvpBattle(battleInfo)
	PVPModel:testOnPvpChallengeBattleEnd(battleInfo)
end

return ArenaPlayerView

