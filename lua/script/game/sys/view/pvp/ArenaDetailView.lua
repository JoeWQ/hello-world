--竞技场查看对手详情
--2017-1-11 15:57:33
--@Author:小花熊

local ArenaDetailView = class("ArenaDetailView",UIBase)

function ArenaDetailView:ctor(_window_name,_playerInfo,_pvp_class)
    ArenaDetailView.super.ctor(self,_window_name)
    self._playerInfo = _playerInfo
    self._pvpClass = _pvp_class
end

function ArenaDetailView:loadUIComplete()
    self:registerEvent()
    self:updatePlayerDetail()
end

function ArenaDetailView:registerEvent()
    ArenaDetailView.super.registerEvent(self)
    self:registClickClose("out")
    self.btn_close:setTap(c_func(self.clickButtonClose,self))
    --按钮显示
    local _user_rid =UserModel:rid()
    if self._playerInfo.rid == _user_rid then
        self.mc_3:showFrame(2)
        self.mc_3.currentView.btn_1:setTap(c_func(self.clickButtonClose,self))
        self.mc_3.currentView.btn_2:setTap(c_func(self.clickButtonSetting,self))
        --对竞技场阵容变化通知监听
        EventControler:addEventListener(PvpEvent.PVP_FORMATION_CHANGED_EVENT,self.notifyPVPFormationChanged,self)
    else
        self._challengeCost = FuncPvp.getChallenge5TimesCost()
        local _panel_btn
        if self._playerInfo.rank > PVPModel:getUserRank() then--需要挑战5次
            self.mc_3.currentView.mc_1:showFrame(2)
            local _pvp_need_level  = FuncDataSetting.getDataByConstantName("PvpFive")
            if UserModel:level() >= _pvp_need_level then --需要多少等级该功能开启
                self.mc_3.currentView.mc_1.currentView.btn_3:setTap(c_func(self.clickButtonChallenge5Times,self))
            else
                self.mc_3.currentView.mc_1.currentView.btn_3:setTap(c_func(self.clickButtonChallengeOpen,self))
            end
            _panel_btn = self.mc_3.currentView
            local _panel = self.mc_3.currentView.mc_1.currentView.btn_3:getUpPanel()
            _panel.txt_2:setString(tostring(self._challengeCost))
            --冷却时间
            EventControler:addEventListener("CD_ID_PVP_UP_LEVEL",self.notifyChallenge5Cost,self)
        else--正常的挑战S
            --查看当前的挑战资格
            local _challenge_count_left = FuncPvp.getPvpChallengeLeftCount()
            local _user_rank = PVPModel:getUserRank()
            --第4名之后,或者自己进入了前10名
            if self._playerInfo.rank >=FuncPvp.SHOW_SELF_MIN_RANK or (self._playerInfo.rank <FuncPvp.SHOW_SELF_MIN_RANK and _user_rank<=10)then 
                self.mc_3:showFrame(1)
                _panel_btn = self.mc_3.currentView
                self.mc_3.currentView.mc_1:showFrame(1)
                self.mc_3.currentView.mc_1.currentView.btn_3:setTap(c_func(self.clickButtonChallenge,self))
            else
                self.mc_3:showFrame(3)
                _panel_btn = self.mc_3.currentView
            end
        end
        _panel_btn.btn_1:setTap(c_func(self.clickButtonChat,self))
        _panel_btn.btn_2:setTap(c_func(self.clickButtonFriend,self))
    end
end
--竞技场阵容变化监听
function ArenaDetailView:notifyPVPFormationChanged(_param)
    local _playerInfo = self._playerInfo
    _playerInfo.formations = TeamFormationModel:getPVPFormation()
    self:updatePlayerDetail()
end
--update ui,真实玩家
function ArenaDetailView:updatePlayerDetail()
    local _playerInfo = self._playerInfo
    local _player_item = FuncChar.getHeroData(_playerInfo.avatar)
    local _iconPath = FuncRes.iconHead(_player_item.icon)
    self.panel_fbiconnew.mc_2:showFrame(_player_item.quality or 1)--资质
    self.panel_fbiconnew.mc_2.currentView.ctn_1:removeAllChildren()
    self.panel_fbiconnew.mc_2.currentView.ctn_1:addChild(cc.Sprite:create(_iconPath))--icon
    --level
    self.panel_fbiconnew.txt_3:setString(tostring(_playerInfo.level))
    --player name
    self.txt_name_1:setString(_playerInfo.name)
    --战力
    self.UI_comp_powerNum:setPower(_playerInfo.ability)
    --排名
    self.txt_rank_2:setString(_playerInfo.rank)
    --星级
    self.panel_fbiconnew.mc_dou:showFrame(_playerInfo.star or 1)
    --仙盟
    self.txt_2:setString(_playerInfo.guildName ~= "" and _playerInfo.guildName or GameConfig.getLanguage("chat_own_no_league_1013"))
    --伙伴出战阵容
    for _index =1,6  do 
        local _partnerId = _playerInfo.formations.partnerFormation["p".._index]
        local _panel = self.panel_1["panel_fbiconnew".._index] 
        _panel:setVisible(true)
        if _partnerId ~= nil then   --此处有伙伴
            _partnerId = tostring(_partnerId)
            if _partnerId ~= FuncPvp.ONESELE_VALUE and _partnerId ~= FuncPvp.INVALIDE_VALUE then
                local _partnerInfo = _playerInfo.partners[_partnerId]
                self:updateEveryPartnerView(_partnerInfo,_panel)
            elseif _partnerId == FuncPvp.ONESELE_VALUE then
                self:updateOneself(_panel)
            else
                _panel:setVisible(false)
            end
        else--否则隐藏槽位
            _panel:setVisible(false)
        end
    end
    --法宝阵容,只有两个
    for _index=1,2 do
        local _treasureId = _playerInfo.formations.treasureFormation["p".._index]
        local _view = self.panel_1["panel_fbicon".._index]
        _view:setVisible(true)
        if _treasureId and _treasureId ~= FuncPvp.INVALIDE_VALUE then
            _treasureId = tostring(_treasureId)
            local _treasureInfo = _playerInfo.treasures[_treasureId]
            self:updateEveryTreasureView(_treasureInfo,_view)
        else
            _view:setVisible(false)
        end
    end
end
--更新挑战5次的花费
function ArenaDetailView:notifyChallenge5Cost()
    local _user_rank = PVPModel:getUserRank()
    if self._playerInfo.rank > _user_rank then
        self._challengeCost = FuncPvp.getChallenge5TimesCost()
         local _panel = self.mc_3.currentView.mc_1.currentView.btn_3:getUpPanel()
         _panel.txt_2:setString(tostring(self._challengeCost))
    end
end
--更新伙伴面板
function ArenaDetailView:updateEveryPartnerView(_partnerInfo,_view)
    local _partner_item = FuncPartner.getPartnerById(_partnerInfo.id)
    --品质
    _view.mc_2:showFrame(_partnerInfo.quality)
    --icon
    local _iconPath = FuncRes.iconHead(_partner_item.icon)
    _view.mc_2.currentView.ctn_1:removeAllChildren()
    local _iconSprite = cc.Sprite:create(_iconPath)
    _view.mc_2.currentView.ctn_1:addChild(_iconSprite)
    --等级
    _view.txt_3:setString(tostring(_partnerInfo.level))
    --星级
    _view.mc_dou:showFrame(_partnerInfo.star)
end
--更新法宝
function ArenaDetailView:updateEveryTreasureView(_treasureInfo,_view)
    local _item_item = FuncTreasure.getTreasureById(_treasureInfo.id)
    --icon
    local _iconPath = FuncRes.iconTreasure(_treasureInfo.id)
    local _iconSprite = cc.Sprite:create(_iconPath)
    _iconSprite:setScale(0.4)
    _view.panel_1.ctn_1:removeAllChildren()
    _view.panel_1.ctn_1:addChild(_iconSprite)
    --等级
    _view.txt_3:setString(tonumber(_treasureInfo.level))
    --星级
    _view.mc_dou:showFrame(_treasureInfo.star)
end

function ArenaDetailView:updateOneself(_view)
    local _char_item = FuncChar.getHeroData(self._playerInfo.avatar)
    local _iconPath = FuncRes.iconHead(_char_item.icon)
    local _iconSprite = cc.Sprite:create(_iconPath)
    _view.mc_2:showFrame(self._playerInfo.quality or 1)
    --icon
    _view.mc_2.currentView.ctn_1:removeAllChildren()
    _view.mc_2.currentView.ctn_1:addChild( _iconSprite)
    _view.mc_dou:showFrame(self._playerInfo.star or 1)
    --level
    _view.txt_3:setString(tostring(self._playerInfo.level))
end
function ArenaDetailView:clickButtonClose()
    self:startHide()
end
--私聊
function ArenaDetailView:clickButtonChat()

end
--加为好友,或者删除好友
function ArenaDetailView:clickButtonFriend()

end

--重新设置布阵
function ArenaDetailView:clickButtonSetting()
    self:startHide()
    WindowControler:showWindow("TeamFormationView",nil,FuncTeamFormation.formation.pvp_defend)
end
--提示挑战5次需要等级
function ArenaDetailView:clickButtonChallengeOpen()
    local _pvp_need_level  = FuncDataSetting.getDataByConstantName("PvpFive")
    WindowControler:showTips(GameConfig.getLanguage("pvp_need_level_open_1006"):format(_pvp_need_level))
end
--挑战
function ArenaDetailView:clickButtonChallengeAfter()
    --检测是否还有挑战次数
    local _times_left = FuncPvp.getPvpChallengeLeftCount()
    if _times_left <= 0 then
        WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1042"))
        return
    end
    --构建数据结构
    local _user_formation = table.deepCopy(TeamFormationModel:getPVPFormation())
    local _formation = {
        treasureFormation = table.deepCopy(_user_formation.treasureFormation),
        partnerFormation = table.deepCopy(_user_formation.partnerFormation),
    }
    local _param = {
        opponentRid = self._playerInfo.rid_back, --对手的rid
        opponentRank = self._playerInfo.rank , --对手的排名
        userRank = PVPModel:getUserRank(), --玩家自己的排名
        formation = _formation, --玩家自己的PVP阵列
    }
--    dump(_param,"---_param----")
    PVPServer:requestChallenge(_param,c_func(self.onChallengeEvent,self))
end
--封装函数
function ArenaDetailView:clickButtonChallenge()
    --检测是否有挑战的资格
    local _user_rank = PVPModel:getUserRank()
    if _user_rank>10 and self._playerInfo.rank <FuncPvp.SHOW_SELF_MIN_RANK then --require top 10
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
        PVPModel:tryShowBuyPvpView()
       -- WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1042"))
        return
    end
    --此时关闭自身UI
    self:startHide()
    WindowControler:showWindow(     
        "TeamFormationView",
        nil,
        FuncTeamFormation.formation.pvp_attack,
        self._playerInfo
       )
end
function ArenaDetailView:onChallengeEvent(_event)
    local _playerInfo = self._playerInfo
    if _event.result ~= nil then
        --存储战斗结果
        PVPModel:setLastFightResult(_event.result.data)
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
        local _CampSelf ={
            rid = UserModel:rid(),
       --     partners = PartnerModel:getAllPartner(),
       --     treasures = _treasure,
        --    formations = TeamFormationModel:getPVPFormation(), --玩家自己的PVP阵列
        }
        --敌方阵营
        local _CampEnemy = {
            rid = self._playerInfo.rid,
            treasures = self._playerInfo.treasures,
            formations = self._playerInfo.formation,
        }
        local _battleInfo = {
            battleLabel = GameVars.battleLabels.pvp,
            camp1 = _CampSelf, --表示己方
            camp2 = self._playerInfo,--,_CampEnemy,--表示敌方
            report = _event.result.data,
        }
        _battleInfo = _event.result.data
        _battleInfo.battleLabel = GameVars.battleLabels.pvp
        echo("pvp战斗的battleInifo---------------")
        dump(_battleInfo)
        echo("pvp战斗的battleInifo---------------")
--        self:startHide()
        WindowControler:showBattleWindow("ArenaBattleLoading", _playerInfo)
        BattleControler:startBattleInfo(_event.result.data)
        --同时刷新主场景
        --self:delayCall(c_func(self.refreshMainViewClose,self,_event),0.001)
    else
        echo("-----ArenaDetailView:onChallengeEvent-----:",_event.error.message)
    end
    local errorData = _event.error
	if errorData then
		--战斗异常1.对手正在战斗 2. 对手排名变化 3 玩家排名变化
		local code = tonumber(errorData.code)
		local code_white_list = {110501, 110502, 110506}
        local   _refresh=false
        if(  _event.error.message=="user_pvprank_changed"  )then
            WindowControler:showTips(GameConfig.getLanguage("pvp_self_rank_changed_1001"));
            _refresh=true
        elseif(_event.error.message=="opponent_rank_have_changed")then
             WindowControler:showTip(GameConfig.getLanguage("pvp_enemy_rank_change_1002"));
              _refresh=true
        elseif(_event.error.message=="opponent_in_challenge")then
              WindowControler:showTips(GameConfig.getLanguage("pvp_enemy_fall_changing_1003"));
              _refresh=true
		end
	end
end
--挑战5次
function ArenaDetailView:clickButtonChallenge5Times()
    --检测仙玉是否足够
    local _user_gold = UserModel:getGold()
    echo("--------------需要花费:",self._challengeCost,"------现在拥有:,",_user_gold)
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
        opponentRid = self._playerInfo.rid_back, --对手的rid
        formation = _formation, --自己的布阵内容
        userRank = PVPModel:getUserRank(),
    }
    PVPServer:requestChallenge5Times(_param,c_func(self.onChallenge5TimesEvent,self))
--    local _userInfo = {
--        avatar = UserModel:avatar(),
--        level = UserModel:level(),
--        vip = UserModel:vip(),
--        quality = UserModel:quality(),
--        star = 1,--UserModel:star(),
--    }
--    self:startHide()
--    WindowControler:showWindow("ArenaChallenge5View",_userInfo,self._playerInfo,{1,1,1,1,1})
end
function ArenaDetailView:onChallenge5TimesEvent(_event)
    if _event.result ~= nil then
        local _playerInfo = self._playerInfo
        local _userInfo = {
            avatar = UserModel:avatar(),
            level = UserModel:level(),
            vip = UserModel:vip(),
            quality = UserModel:quality(),
            star = 1,--UserModel:star(),
        }
        WindowControler:showWindow("ArenaChallenge5View",_userInfo,_playerInfo,_event.result.data.results)
        --在下方同时刷新UI
        self:delayCall(c_func(self.refreshMainView,self,_event),0.001)
    else
        echo("----ArenaPlayerView:onChallenge5Event------",_event.error.message)
    end
end
--刷新主场景
function ArenaDetailView:refreshMainView(_event)
--     self:startHide()
    self._pvpClass:onCloudDisappear(_event)
    self:startHide()
end
--刷新主场景,同时关闭UI
function ArenaDetailView:refreshMainViewClose(_event)
    self:startHide()
    self._pvpClass:onCloudDisappear(_event)
end
return ArenaDetailView