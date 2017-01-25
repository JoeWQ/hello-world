--
-- Author: ZhangYanguang
-- Date: 2015-12-18
-- 竞技场战斗回放界面

local ArenaBattlePlayBackView = class("ArenaBattlePlayBackView", UIBase)

function ArenaBattlePlayBackView:ctor(winName)
    ArenaBattlePlayBackView.super.ctor(self, winName)
end

function ArenaBattlePlayBackView:loadUIComplete()
	self:registerEvent()
	self.mc_battles.currentView.panel_dianfeng:visible(false)
	-- 隐藏item
	self.panel_battle_item:setVisible(false)

	self:initData()
	self:setViewAlign()

	self:pullBattleRecord()
end 

function ArenaBattlePlayBackView:setViewAlign()
	FuncCommUI.setViewAlign(self.btn_close, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.scale9_updi,UIAlignTypes.LeftTop);
    self.scale9_updi:setContentSize(cc.size(GameVars.width,self.scale9_updi:getContentSize().height));
end

function ArenaBattlePlayBackView:registerEvent()
	ArenaBattlePlayBackView.super.registerEvent()
    self.btn_close:setTap(c_func(self.close,self))
	-- EventControler:addEventListener(BattleEvent.BATTLEEVENT_REPLAY_GAME, self.onReplayEnd, self)
end

function ArenaBattlePlayBackView:onReplayEnd()
	--目前正在播放的战报数据
	local data = PVPModel:getCurrentReplayBattleData()
	if not data then
		return
	end
	--local result = Fight.result_win
	--if self:isUserSuccess(data) then
	--    result = Fight.result_lose
	--end
	WindowControler:showBattleWindow("ArenaBattleReplayResult")
	echo("ArenaBattlePlayBackView:onReplayEnd--------------------------------------------------")
end

function ArenaBattlePlayBackView:initData()
	self.normalBattleDatas = {}
end

-- 滚动配置
function ArenaBattlePlayBackView:initMyBattle(myBattleData)
	if not myBattleData or not next(myBattleData) then
		return
	end
	local sortByTime = function(a, b)
		return a.bTime > b.bTime
	end
	table.sort(myBattleData, sortByTime)

    local createNormalBattleFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_battle_item)
        self:initNormalBattleItem(view, itemData)
        return view
    end

	local params = {
        {
            data = myBattleData,
            createFunc = createNormalBattleFunc,
            perNums = 1,
            offsetX = 16,
            offsetY = 10,
            itemRect = {x=0,y=-140,width=834,height=140},
            heightGap = 5,
            perFrame = 1,
        },
    }
	self.scroll_list:styleFill(params)
end

-- 拉取战斗记录
function ArenaBattlePlayBackView:pullBattleRecord()
	PVPServer:pullBattleRecord(c_func(self.pullBattleRecordCallBack, self))
end

-- 拉取战斗记录回调
function ArenaBattlePlayBackView:pullBattleRecordCallBack(event)
	if event.result ~= nil then
		local serverData = event.result.data	
        self._battleInfo = event.result.data
        self:updateBattleView()
		-- 创建滚动列表
--		self:checkShowRightView(serverData)
--		if serverData then
--			self:initTopBattle(serverData.peakPvpBattle)
--			self:initMyBattle(serverData.commonPvpBattle)
--		end
	else
		WindowControler:showTips("战斗记录为空")
	end
end
--从得到的战斗记录创建视图
function ArenaBattlePlayBackView:updateBattleView()
    local _battleInfo = self._battleInfo
    self.panel_battle_item:setVisible(false)
    self._scrollView = self.mc_battles.currentView.scroll_list
    if not _battleInfo.peakPvpBattle or table.length(_battleInfo.peakPvpBattle) <=0 then --如果没有巅峰之战
        if not _battleInfo.commonPvpBattle or table.length(_battleInfo.commonPvpBattle) <=0 then
            self.mc_battles:showFrame(3)
            return
        else
            self.mc_battles:showFrame(2)
            self._scrollView = self.mc_battles.currentView.scroll_list
        end
    else --如果有巅峰之战,则初始化视图组件
        self:initTopBattle(_battleInfo.peakPvpBattle)
        --如果没有普通PVP,则返回
        if not _battleInfo.commonPvpBattle or table.length(_battleInfo.commonPvpBattle) <=0 then
            return
        end
    end
    local _data_source = {}
    for _key,_value in pairs(_battleInfo.commonPvpBattle)do
        table.insert(_data_source,_value)
    end
    local sortByTime = function(a, b)
		return a.bTime > b.bTime
	end
    table.sort(_data_source,sortByTime)
    local function createFunc(_item,_index)
        local _view = UIBaseDef:cloneOneView(self.panel_battle_item)
        self:initNormalBattleItem(_view,_item)
        return _view
    end
    local _param1 = {
        data  = _data_source,
        createFunc = createFunc,
        offsetX =0,
        offsetY = 0,
        widthGap =0,
        heighGap =2,
        perFrame =1,
        perNums =1,
        itemRect = {x =0, y= -148,width = 836,height = 148},
    }
    self._scrollView:styleFill({_param1})
end
function ArenaBattlePlayBackView:checkShowRightView(serverData)
	if not serverData then
		self.mc_battles:showFrame(3)
		return
	end
	if not serverData.peakPvpBattle or next(serverData.peakPvpBattle)==nil then
		self.mc_battles:showFrame(2)
	else
		self.mc_battles:showFrame(1)
	end
	self.scroll_list = self.mc_battles.currentView.scroll_list
end

-- 更新巅峰之战item
function ArenaBattlePlayBackView:initTopBattle(data)
	if not data then return end
	self.panel_dianfeng = self.mc_battles.currentView.panel_dianfeng
	self.panel_dianfeng:visible(true)
	local battleData = data
    local _attackInfo = json.decode(battleData.attackerInfo)
    local _defenderInfo = json.decode(battleData.defenderInfo)
    if _attackInfo.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
        _attackInfo = FuncPvp.getRobotDataById(_attackInfo._id)
    end
    if _defenderInfo.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
        _defenderInfo = FuncPvp.getRobotDataById(_defenderInfo._id)
    end
	local attackerName = _attackInfo.name ~= "" and _attackInfo.name or GameConfig.getLanguage("tid_common_2001")
    local  attackerLevel = _attackInfo.level --self:getPvpPlayerNameAndLevel(json.decode(battleData.attackerInfo))
--	local defenderName, defenderLevel = self:getPvpPlayerNameAndLevel(json.decode(battleData.defenderInfo))
    local defenderName= _defenderInfo.name ~= "" and _defenderInfo.name or GameConfig.getLanguage("tid_common_2001")
    local defenderLevel = _defenderInfo.level
	-- 攻击方名字
	self.panel_dianfeng.txt_name_1:setString(attackerName)
	self.panel_dianfeng.txt_level_1:setString(attackerLevel..'级')

	-- 防守方名字
	self.panel_dianfeng.txt_name_2:setString(defenderName)
	self.panel_dianfeng.txt_level_2:setString(defenderLevel..'级')
	-- 重播战斗
	--self.panel_dianfeng.btn_1:setTap(c_func(self.replayBattle, self, battleData))
    self.panel_dianfeng.btn_1:setTap(c_func(self.clickCellButtonPVPReport, self, battleData))
end

-- 更新普通战斗item
function ArenaBattlePlayBackView:initNormalBattleItem(itemView,data)
	local battleData = data
	local mcView = itemView.mc_result
	local isUserSuccess = self:isUserSuccess(battleData)
	-- 如果玩家胜利
	if isUserSuccess then
		mcView:showFrame(1)
	else
		mcView:showFrame(2)
	end

	local deltaRank = math.abs(battleData.attackerRank - battleData.defenderRank)
	-- 名次变化
	mcView.currentView.txt_1:setString(deltaRank)

	local enemyUsedTreasures = {}
	local level
	local info 
--	local treasureLists = json.decode(battleData.treasureLists)
	-- 对方是防守方
    --法宝数据
    local _treasure_source = {}
    --伙伴数据
    local _partner_source = {}
    local _formation
    local _rid=UserModel:rid();
	if UserModel:rid() == battleData.attackerId then
		local defenderInfo = json.decode(battleData.defenderInfo)
		info = defenderInfo
        _formation = defenderInfo
        --如果对方是机器人,则合成数据
        if defenderInfo.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
            info = FuncPvp.getRobotDataById(defenderInfo._id)
            _formation = info
        end
    --    _formation = json.decode(battleData.attackerInfo)
		-- 对方使用的法宝
		--enemyUsedTreasures = self:getUsedTreasureList(defenderInfo, treasureLists.defender)
		--玩家挑战别人，失败,没有排名变化
		if not isUserSuccess then
			mcView.currentView.txt_1:visible(false)
			mcView.currentView.panel_rank:visible(false)
		end
	else
		if isUserSuccess then
			mcView.currentView.txt_1:visible(false)
			mcView.currentView.panel_rank:visible(false)
		end
		-- 对方是攻击方
		local attackerInfo = json.decode(battleData.attackerInfo)
        if attackerInfo.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
            attackerInfo = FuncPvp.getRobotDataById(attackerInfo._id)
        end
		info = attackerInfo
        _formation = attackerInfo
		-- 对方使用的法宝
		--enemyUsedTreasures = self:getUsedTreasureList(attackerInfo, treasureLists.attacker)
	end
    local name = info.name
    local level = info.level
--	local name, level = self:getPvpPlayerNameAndLevel(info)
	--level
	itemView.txt_3:setString(level..'级')
	--name 
	itemView.txt_2:setString(name)
	
	-- 时间
	local battleTimeStr = FuncPvp.formatPvpBattleTime(TimeControler:getServerTime() - battleData.bTime)
	--local battleTimeStr = "12小时前"
	itemView.txt_4:setString(battleTimeStr)
	-- 分享按钮事件
--	itemView.btn_2:setTap(c_func(self.shareVideo, self))

	-- 重播战斗
	--itemView.btn_1:setTap(c_func(self.replayBattle, self, battleData.reportId))
    itemView.btn_1:setTap(c_func(self.clickCellButtonPVPReport, self, battleData))
    --集合法宝跟伙伴
    if _formation.treasures then
        for _key,_value in pairs(_formation.treasures)do
            local _temp = _value
            _temp.id = _key
            table.insert(_treasure_source,_value)
            if #_treasure_source >= 2 then
                break
            end
        end
    end
    if _formation.partners then
        for _key,_value in pairs(_formation.partners)do
            local _temp = _value
            _temp.id = _key
            table.insert(_partner_source,_temp)
        end
    end
    self:updateFormation(itemView,_partner_source,_treasure_source)
end
--更新伙伴,法宝的阵列
function ArenaBattlePlayBackView:updateFormation(_view,_partner_source,_treasure_source)
    --隐藏掉模板
    _view.panel_fbicon1:setVisible(false)
    _view.panel_fbicon2:setVisible(false)
    _view.panel_fbiconnew:setVisible(false)
    --更新法宝图标
    local function createFunc(_item,_index)
        local _sub_view = UIBaseDef:cloneOneView(_view.panel_fbicon1)
        self:updateTreasureView(_sub_view,_item)
        return _sub_view
    end
    local _param1 = {
        data = _treasure_source,
        createFunc = createFunc,
        offsetX =0,
        offsetY =0,
        widthGap =0,
        heightGap =0,
        perFrame =1,
        perNums = 1,
        itemRect = {x =0, y = -76,width = 82, height =76},
    }
    local function createFunc2(_item,_index)
        local _sub_view = UIBaseDef:cloneOneView(_view.panel_fbiconnew)
        self:updatePartnerView(_sub_view,_item)
        return _sub_view
    end
    local _param2 = {
        data = _partner_source,
        createFunc = createFunc2,
        offsetX =0,
        offsetY =0,
        widthGap =0,
        heightGap =0,
        perFrame = 1,
        perNums =1,
        itemRect = {x=0,y = -77, width = 85,height = 77,},
    }
    _view.scroll_1:styleFill({_param1,_param2})
end
--更新法宝图标
function ArenaBattlePlayBackView:updateTreasureView(_view,_item)
    --icon
    local _item_item = FuncTreasure.getTreasureById(_item.id)
    local _iconPath = FuncRes.iconTreasure(_item.id)
    local _iconSprite = cc.Sprite:create(_iconPath)
    _iconSprite:setScale(0.4)
    _view.panel_1.ctn_1:removeAllChildren()
    _view.panel_1.ctn_1:addChild(_iconSprite)
    --level
    _view.txt_3:setString(tostring(_item.level))
    _view.mc_dou:showFrame(_item.star or 1)
end
--更新伙伴图标
function ArenaBattlePlayBackView:updatePartnerView(_view,_item)
    local _partner_item = FuncPartner.getPartnerById(_item.id)
    --icon
    local _iconPath = FuncRes.iconHead(_partner_item.icon)
    local _iconSprite = cc.Sprite:create(_iconPath)
    _view.mc_2:showFrame(_item.quality or 1)
    _view.mc_2.currentView.ctn_1:removeAllChildren()
    _view.mc_2.currentView.ctn_1:addChild(_iconSprite)
    --level
    _view.txt_3:setString(tostring(_item.level))
    --star
    _view.mc_dou:showFrame(_item.star or 1)
end
--获取战报
function ArenaBattlePlayBackView:clickCellButtonPVPReport(battleData)
    PVPServer:requestPVPreport(battleData.reportId,c_func(self.onPVPReportEvent,self,battleData))
end
--返回
function ArenaBattlePlayBackView:onPVPReportEvent(originBattleData,_event)
    if _event.result ~= nil then
        local _battleData = _event.result.data.report
        local _battleDetail = json.decode(_battleData)
        local _attackData = _battleDetail.battleUsers[1]
        local _defenderData = _battleDetail.battleUsers[2]
        --检测是否有机器人
        if _attackData.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
            _attackData =FuncPvp.getRobotDataById(_attackData._id)
        end
        if _defenderData.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
            _defenderData = FuncPvp.getRobotDataById(_defenderData._id)
        end
        _battleDetail.battleUsers[1] = _attackData
        _battleDetail.battleUsers[2] = _defenderData
        _battleDetail.gameMode = Fight.gameMode_pvp
		_battleDetail.battleLabel = GameVars.battleLabels.pvp
        WindowControler:showBattleWindow("ArenaBattleLoading", _defenderData, _attackData)
	    PVPModel:setCurrentReplayBattleData(_battleDetail)
	    BattleControler:replayLastGame(_battleDetail)
    else
        echo("------ArenaBattlePlayBackView:onPVPReportEvent--------",_event.error.message)
    end
end
-- 重播战斗
function ArenaBattlePlayBackView:replayBattle(battleData)
--	battleData = self:decodeBattleData(battleData)
	local battleInfo = PVPModel:composeBattleInfoForReplay(battleData)
	local enemyCamp = battleInfo.battleUsers[2]
	local playerCamp = battleInfo.battleUsers[1]
	WindowControler:showBattleWindow("ArenaBattleLoading", enemyCamp, playerCamp)
	PVPModel:setCurrentReplayBattleData(battleData)
	BattleControler:replayLastGame(battleInfo)
end

-- 分享视频
function ArenaBattlePlayBackView:shareVideo()
	WindowControler:showTips("分享战斗视频")
end

function ArenaBattlePlayBackView:decodeBattleData(battleData)
--	local ret = {}
--	for k,v in pairs(battleData) do
--		ret[k] = json.decode(v)
--	end
--	return ret
    local   _ret = table.deep(battleData)
    --attack
    local  _attackInfo = json.decode(battleData.attackInfo)
    local _defenderInfo = json.decode(battleData.defenderInfo)
end

function ArenaBattlePlayBackView:isRobot(info)
	return info.userBattleType == Fight.people_type_robot
end

function ArenaBattlePlayBackView:getPvpPlayerNameAndLevel(info)
	local name
	local level 
	if self:isRobot(info) then 
		local nameId = info.name
		level = info.lv
		name = GameConfig.getLanguage(nameId)
	else
		level = info.level
		name = info.name
	end
	if not level then level = 0 end
	return name,level
end

-- 是否是玩家胜利
function ArenaBattlePlayBackView:isUserSuccess(battleData)
	-- 玩家战斗是否成功
	local isSuccess = false

	-- 1表示成功 2表示失败
	-- 攻击方胜利
	if battleData.result == 1 then
		-- 玩家为攻击方
		if battleData.attackerId == UserModel:rid() then
			isSuccess = true
		end
	-- 防守方胜利
	else 
		-- 玩家为防守方
		if battleData.defenderId == UserModel:rid() then
			isSuccess = true
		end
	end
	return isSuccess
end

function ArenaBattlePlayBackView:getUsedTreasureList(info, usedTreasureIds)
	local t = info.treasures
	local newt = {}
	if info.userBattleType == Fight.people_type_robot then
		for _, treasure in ipairs(info.treasures) do
			newt[treasure.id] = treasure
		end
		t = newt
	else
		newt = t
	end
	local used = {}
	usedTreasureIds = usedTreasureIds or {}
	for _,id in ipairs(usedTreasureIds) do
		if string.len(id) ~= 1 and newt[id]~=nil then
			table.insert(used, newt[id])
		end
	end
	return used
end

function ArenaBattlePlayBackView:close()
    self:startHide()
end

return ArenaBattlePlayBackView
