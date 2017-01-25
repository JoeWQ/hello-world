local ArenaMainView = class("ArenaMainView", UIBase)

function ArenaMainView:ctor(winName)
    ArenaMainView.super.ctor(self, winName)
end

function ArenaMainView:loadUIComplete()
	self._anim_show_left_btns = true
	self.UI_topitem:visible(false)
	self.UI_commonitem:visible(false)
	self.UI_player:visible(false)
	self.UI_player_talk:visible(false)
--	self.btn_shuaxin:visible(false)

	self.pvp_list_inited = false
	self.talk_has_began = false
	self:adjustScrollRect()
	self:alignUIItems()
	self:registerEvent()
--	self:hideRightSideBtns()

	--初始化显示背景
	self:initPvpList({})

	self:showCloud()
	self:refreshMatch()
	self:checkCdTime()

	
	--检查小红点
	PVPModel:checkNewReport()
	self:scheduleUpdateWithPriorityLua(c_func(self.frameUpdate, self) ,0)
end

function ArenaMainView:hideRightSideBtns()
	local btns = {self.btn_shop, self.btn_huifang, self.btn_shuoming, self.btn_shuaxin}
	for i,btn in pairs(btns) do
		btn:visible(false)
	end
end

function ArenaMainView:showCloud()
	self.bigCloudAnim = self:createUIArmature("UI_arena","UI_arena_yunceng", self.ctn_big_cloud, false, GameVars.emptyFunc)
	self.bigCloudAnim:gotoAndPause(1)
end

function ArenaMainView:animShowButtons()
	if not self._anim_show_left_btns then
		return
	end
    --暂时屏蔽掉动画
    self._anim_show_left_btns = false
    if true then return end
    ----
	local btns = {self.btn_shop, self.btn_huifang, self.btn_shuoming,btn_jf}
	local posInfo = {
		{x=-33, y=34}, 
		{x=-33, y=43}, 
		{x=-33, y=55}, 
	}
	local anim = self:createUIArmature("UI_arena", "UI_arena_btns", self.ctn_btns, false, GameVars.emptyFunc)
	anim:gotoAndPause(1)
	for i,btn in ipairs(btns) do
		local pos = posInfo[i]
		btn:pos(pos.x, pos.y)
		FuncArmature.changeBoneDisplay(anim, "bone"..i, btn)
		btn:visible(true)
	end
	local onAllBtnShow = function()
		self._anim_show_left_btns = false
	end
	anim:registerFrameEventCallFunc(20, 1, c_func(onAllBtnShow))
	anim:startPlay(false)
end


--初始化玩家自己的信息
function ArenaMainView:updatePlayerUI(showAnim)
	local userRank = PVPModel:getUserRank()
	self.UI_player:visible(true)
	local info = FuncPvp.getPlayerRankInfo(userRank)
	self.UI_player:setPlayerInfo(info)
	if userRank < FuncPvp.SHOW_SELF_MIN_RANK  then
		self.UI_player:showTopThreeMark()
	else
		self.UI_player:updateUI(showAnim)
	end
end

function ArenaMainView:adjustScrollRect()
	--禁止回弹
	--self.scroll_arenalist:setBounceable(false)
	local viewRect = self.scroll_arenalist:getViewRect()
	viewRect.height = viewRect.height + (GameVars.height - GameVars.maxResHeight)
	viewRect.y = - viewRect.height
	self.originScrollViewRect = table.deepCopy(viewRect)
	--更新viewRect 的时候，要注意设置更新viewrect的y值
	viewRect.y = -viewRect.height
	self.scroll_arenalist_view_rect = viewRect
	self.scroll_arenalist:setBounceDistance(184*1.5)
	self.scroll_arenalist:setCanAutoScroll(false)
	self.scroll_arenalist:updateViewRect(viewRect)
end


function ArenaMainView:alignUIItems()
	FuncCommUI.setViewAlign(self.scroll_arenalist, UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.UI_player, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.UI_add_count, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.UI_refresh_cd, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.btn_huifang, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.ctn_btns, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.btn_shop, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.btn_shuoming, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.btn_jf,UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.btn_shuaxin, UIAlignTypes.Right)
    --问号
    FuncCommUI.setViewAlign(self.btn_wen,UIAlignTypes.Left)
    FuncCommUI.setViewAlign(self.scale9_longhei,UIAlignTypes.LeftTop);
    self.scale9_longhei:setContentSize(cc.size(GameVars.width,self.scale9_longhei:getContentSize().height));
end

function ArenaMainView:frameUpdate()
	self:updateRefreshBtn()
	self:adjustTalkViews()
end

function ArenaMainView:initPvpList(data)

	local topItems = data.topThree or {2}
	local commonItems = data.opponents or {1}
	local userRank = data.userRank

	local createTopItem = function(itemInfo)
		local view = UIBaseDef:cloneOneView(self.UI_topitem)
		view:setArenaList(self.scroll_arenalist)
		self.topPvpView = view
		return view
	end

	local createCommonItem = function(itemInfo)
		local view = UIBaseDef:cloneOneView(self.UI_commonitem)
		view:setArenaList(self.scroll_arenalist)
		self.commonPvpView = view
		return view
	end
	self.topViewHeight = 650
	self.bottomViewHeight = 920
	local scrollTopItemParam = {
		data = topItems,
		createFunc = createTopItem,
		perNums =1,
		--perFrame=1, --不要分帧
		offsetX = 0,
		offsetY = 0,
		widthGap = 0,
		heightGap = 0,
		itemRect = {x=0,y= -self.topViewHeight, width = 470,height = self.topViewHeight},
	}
	local scrollCommonItemParam = {
		data = commonItems,
		createFunc = createCommonItem,
		perNums =1,
		--perFrame=1, --不要分帧
		offsetX = 4,
		offsetY = 15,
		widthGap = 0,
		heightGap = 0,
		itemRect = {x=0,y= -self.bottomViewHeight, width = 470,height = self.bottomViewHeight},
	}

	local scroll_param = {scrollTopItemParam, scrollCommonItemParam}
	self.scroll_arenalist:hideDragBar()
    self.scroll_arenalist:cancleCacheView();
	self.scroll_arenalist:styleFill(scroll_param)
	self.pvp_list_inited = true
	self:updateScrollBehavior()
end

function ArenaMainView:makeWinScrollAction()
	if not PVPModel:isLastFightWin() then
		return
	end
	local viewRect = table.deepCopy(self.originScrollViewRect)
	local delta = 184*4
	viewRect.height = viewRect.height + delta
	viewRect.y = - viewRect.height
	self.scroll_arenalist:updateViewRect(viewRect)
	local distance = 184--184--*1.5 --+ 80
	self.scroll_arenalist:runAction(act.moveby(0, 0, distance))
    if(self._playerViews~=nil)then
	for _,playerView in pairs(self._playerViews) do
		playerView:visible(false)
	end
    end
	local restoreScrollRect = function()
        if(self._playerViews ~=nil)then
		     for _,playerView in pairs(self._playerViews) do
                --如果是低于 10001的排名,肯定是要隐藏的
                playerView:removeOriginPlayer();
			    playerView:visible(true)
		     end
        end
		self.scroll_arenalist:updateViewRect(self.originScrollViewRect)
--//战斗结束之后,会触发角色更新事件,所以这里就不用再刷新了,在onCloud函数里面会有相关的调用
 --       self:updatePvpList(PVPModel:getCacheRankList()
	end
	self.scroll_arenalist:runAction(act.sequence(act.moveby(0.5, 0, -distance), act.callfunc(restoreScrollRect)))
end

function ArenaMainView:registerEvent()
	ArenaMainView.super.registerEvent()

	self.btn_huifang:setTap(c_func(self.press_btn_huifang, self))
	self.btn_wen:setTap(c_func(self.press_btn_shuoming, self))
    self.btn_back:setTap(c_func(self.press_btn_back, self))
    --排名兑换将
    self.btn_shuoming:setTap(c_func(self.clickButtonRankExchg,self))
    --积分奖励
    self.btn_jf:setTap(c_func(self.clickButtonScore,self))
	self.btn_shop:setTap(c_func(self.press_btn_shop, self))
	self.btn_shuaxin:setTap(c_func(self.refreshMatch, self, true))
	--self.btn_shuaxin:setTouchSwallowEnabled(true)

    ---- 刷新匹配
    ---- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)

	EventControler:addEventListener(PvpEvent.PVPEVENT_CLEAR_CHALLENGE_CD_OK, self.onClearCdEnd, self)
	EventControler:addEventListener(PvpEvent.PVPEVENT_REPORT_RESULT_OK, self.onReportResultOk, self)
	EventControler:addEventListener(PvpEvent.PVPEVENT_PVP_FIGHT_EXCEPTION, self.onFightException, self)
    --冷却时间CD事件
	local pvpCdDownLevelTimeEvent = CdModel:getCdTimeEventKeyByCdId(CdModel.CD_ID.CD_ID_PVP_UP_LEVEL)
	EventControler:addEventListener(pvpCdDownLevelTimeEvent, self.onChallengeCdOver, self)
--	local pvpCdUpLevelTimeEvent = CdModel:getCdTimeEventKeyByCdId(CdModel.CD_ID.CD_ID_PVP_UP_LEVEL)
--	EventControler:addEventListener(pvpCdUpLevelTimeEvent, self.onChallengeCdOver, self)

	EventControler:addEventListener(TimeEvent.TIMEEVENT_PVP_FAST_REFRESH_CD, self.updateRefreshBtn, self)
	EventControler:addEventListener(PvpEvent.PVPEVENT_BUY_CHALLENGE_COUNT_OK, self.onBuyPvpCountOk, self)
	EventControler:addEventListener(PvpEvent.PVPEVENT_PVP_REPORT_RED_POINT, self.checkReportRedPoint, self)
--	EventControler:addEventListener(PvpEvent.PVPEVENT_RECORD_NEW_TITLE_OK, self.onRecordNewTitle, self)
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE, self.onBattleClose, self)
    --排名兑换
    EventControler:addEventListener(PvpEvent.RANK_EXCHANGE_CHANGED_EVENT,self.notifyRankXchgChanged,self)
    --积分兑换
    EventControler:addEventListener(PvpEvent.SCORE_REWARD_CHANGED_EVENT,self.notifyScoreRewardChanged,self)
    EventControler:addEventListener(CountEvent.COUNTEVENT_MODEL_UPDATE,self.notifyScoreRewardChanged,self)
    --需要注册一个从后台切换的监听函数
     local _cdListener = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",
                                c_func(self.checkCdTime,self));
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(_cdListener, 10)
    self.__cdListener=_cdListener;
    self:notifyScoreRewardChanged()
end
--//退出时删除监听器
function ArenaMainView:deleteMe()
--//删除监听器  
    cc.Director:getInstance():getEventDispatcher():removeEventListener(self.__cdListener);
    self.__cdListener=nil;
    ArenaMainView.super.deleteMe(self);
end
--战斗关闭,重新回到竞技场主界面
function ArenaMainView:onBattleClose()
	--胜利后进行柱子往下滚动的操作
	self:makeWinScrollAction()
end

function ArenaMainView:onRecordNewTitle()
--pvp称号功能去掉
--	local latestTitleId = PVPModel:getLatestAchievedTitle()
--	if latestTitleId then
--		WindowControler:showWindow("ArenaTitleAchieveView", latestTitleId)
--	end
end

function ArenaMainView:checkReportRedPoint(event)
	local isShow = event.params
	self.btn_huifang:getUpPanel().panel_red:visible(isShow)
end
--积分奖励红点
function ArenaMainView:notifyScoreRewardChanged(_param)
    local _scoreReward = PVPModel:getAllScoreRewards()
    --统计当前在竞技场中已经打过的战斗的数目
    --检测是否还有没有领取的奖励
    local _now_count = CountModel:getPVPChallengeCount()
    --逐个遍历
    local _real_count = 0
    local _integral_score = FuncPvp.getIntegralRewards()
    for _key,_value in pairs(_integral_score) do
        --如果达到了次数限制,并且还没有领取
        if _now_count >= _value.condition and not _scoreReward[_value.id] then
            _real_count = _real_count +1
        end
    end
    self.btn_jf:getUpPanel().panel_red:setVisible(_real_count >0)
end
--排名奖励事件
function ArenaMainView:notifyRankXchgChanged(_param)
    --所有的排名兑换奖励数据
    local _rank_data = FuncPvp.getAllRankExchanges()
    local _now_ranks = PVPModel:getAllRankExchanges() --已经获得的排名兑换数据
    local _rank = PVPModel:getHistoryTopRank()
    local _real_count =0
        --兑换时需要花费的资源
    local _user_money = UserModel:getArenaCoin()
    for _key,_value in pairs(_rank_data)do
        local _cost_data = string.split(_value.cost[1],",")
        --没有获取奖励,且满足排名要求,并且金钱足够
        if not _now_ranks[_key] and _rank <= _value.condition and _user_money >= tonumber(_cost_data[2]) then --如果已经达到条件
            _real_count = _real_count + 1
        end
    end
    self.btn_shuoming:getUpPanel().panel_red:setVisible(_real_count > 0)
end

function ArenaMainView:onBuyPvpCountOk()
	PVPModel:checkNewReport()
end

--战斗异常1.对手正在战斗 2. 对手排名变化 3 玩家排名变化
function ArenaMainView:onFightException()
	self:refreshMatch()
end

function ArenaMainView:onClearCdEnd(event)
	PVPModel:checkNewReport()
	self:checkCdTime()
end

function ArenaMainView:onChallengeCdOver(event)
	PVPModel:checkNewReport()
	self:checkCdTime()
end

--根据排名情况修改滚动视图行为
--前三名的时候就不滚动了
function ArenaMainView:updateScrollBehavior()

	if not self.pvp_list_inited then
		self.scroll_arenalist:gotoTargetPos(1, 2, 2)
		return
	end
	local userRank =  PVPModel:getUserRank()
	if userRank <= FuncPvp.SHOW_SELF_MIN_RANK then
		self.scroll_arenalist:gotoTargetPos(1, 1, 2)
		self.scroll_arenalist:setCanScroll(false)
		self.scroll_arenalist:onScroll(nil)
	else
		self.scroll_arenalist:setCanScroll(true)
		self.scroll_arenalist:onScroll(c_func(self.onArenaListScroll, self))
        self.scroll_arenalist:gotoTargetPos(1, 2, 2)
	end
end

--每一帧去检查
function ArenaMainView:adjustTalkViews()
	local x, y = self.scroll_arenalist:getCurrentPos()
	if not self._last_pos_y then
		self._last_pos_y = y
	end
	if self._playerViews then
		local delta = y - self._last_pos_y
		for _,playerView in pairs(self._playerViews) do
			playerView:adjustTalkViewPos(delta)
		end
		self._last_pos_y = y
	end
end

function ArenaMainView:onArenaListScroll(event)
	local y = event.y and math.floor(event.y) or 0
	if event.name == self.scroll_arenalist.EVENT_BEGAN then
		local x, y = self.scroll_arenalist:getCurrentPos()
		self._scroll_began_y = math.floor(y)
		self._last_pos_y = y
	end

	if event.name == self.scroll_arenalist.EVENT_SCROLLEND then
		local curx, cury = self.scroll_arenalist:getCurrentPos()
		local viewRect = self.scroll_arenalist_view_rect 
		if self._scroll_began_y < viewRect.height then 
			if cury > viewRect.height/3 then
				self.scroll_arenalist:gotoTargetPos(1,2,2, 0.2)
			end
		else
			if cury < (self.topViewHeight + self.bottomViewHeight - viewRect.height) - viewRect.height/4 then
				self.scroll_arenalist:gotoTargetPos(1,1,2, 0.2)
			end
		end
	end
end

function ArenaMainView:onReportResultOk(event)
	self:checkCdTime()
	local serverData = event.params
	local data = serverData.result.data
	if data.result == Fight.result_win then
		--胜利
		PVPModel:setUserRank(data.userRank)
		PVPModel:cacheRankList(data)
		self:updatePlayerUI()
	elseif data.result == Fight.result_lose then
		--失败

	end
end

function ArenaMainView:checkCdTime()
	local left = FuncPvp.getPvpCdLeftTime()
	local show = left > 0
	self.UI_refresh_cd:updateUI()
	self.UI_refresh_cd:visible(show)
    if(not show)then--//检查最上层的UI是否是 ArenaClearChallengeCdPop
       local  topWin=WindowControler:getCurrentWindowView();
       if(topWin.windowName=="ArenaClearChallengeCdPop")then
           --WindowControler:closeWindow("ArenaClearChallengeCdPop");
           topWin:startHide();
       end
    end
end

function ArenaMainView:refreshMatch(manul)
	if manul then
		local left = TimeControler:getCdLeftime(TimeEvent.TIMEEVENT_PVP_FAST_REFRESH_CD)
		if left > 0 then 
			WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1045"))
			return 
		end
		--记录刷新时间,防止过快频繁点击刷新
		if PVPModel:recordManulRefresh() then
			PVPServer:refreshPVP(c_func(self.onRefreshMatch,self))
		else
			TimeControler:startOneCd(TimeEvent.TIMEEVENT_PVP_FAST_REFRESH_CD, FuncPvp.REFRESH_TO_FAST_CD)
		end
	else
		local left = TimeControler:getCdLeftime(TimeEvent.TIMEEVENT_PVP_FAST_REFRESH_CD)
		--如果还有点击过快cd，加载缓存数据
		if left > 0 then
			self:onRefreshMatch({result = {data = PVPModel:getCacheRankList()}})
		else
			PVPServer:refreshPVP(c_func(self.onRefreshMatch,self))
		end
	end
end

function ArenaMainView:updateRefreshBtn()
	if self._anim_show_left_btns then
		return 
	end
	----前10名不显示换一批按钮
	if PVPModel:getUserRank() < FuncPvp.REFRESH_BTN_SHOW_MIN_LEVEL then
		self.btn_shuaxin:visible(false)
		return
	else
		self.btn_shuaxin:visible(true)
	end
	local groupIndex, itemIndex = self.scroll_arenalist:getGroupPos(1)
	if groupIndex == 1 then
		self.btn_shuaxin:visible(false)
		return
	end
	local left = TimeControler:getCdLeftime(TimeEvent.TIMEEVENT_PVP_FAST_REFRESH_CD)

	if left > 0 then
		self.btn_shuaxin:setBtnStr(string.format("00:%02d", left))
		FilterTools.setGrayFilter(self.btn_shuaxin)
	else
		self.btn_shuaxin:setBtnStr(GameConfig.getLanguage("tid_pvp_1046"))
		FilterTools.clearFilter(self.btn_shuaxin)
	end
end

function ArenaMainView:onRefreshMatch(event)
    --对
	if self.bigCloudAnim ~= nil then
		self.bigCloudAnim:doByLastFrame(true, true, c_func(self.onCloudDisappear, self, event, true))
		self.bigCloudAnim:startPlay(false)
		self.bigCloudAnim = nil
	else
		self:onCloudDisappear(event, false)
	end
end
function ArenaMainView:processRobot(_data)
    local _commItem = _data.opponents
    for _key,_value in pairs(_commItem) do
        _value.rid_back =_value.rid --留待以后的发送挑战对手协议时使用
        if _value.type == FuncPvp.PLAYER_TYPE_ROBOT then--如果是机器人
            _value.rid = FuncPvp.genRobotRid(_value.rid)
        end
    end
    local _topItem = _data.topThree
    for _key,_value in pairs(_topItem) do
        _value.rid_back =_value.rid --留待以后的发送挑战对手协议时使用
        if _value.type == FuncPvp.PLAYER_TYPE_ROBOT then--如果是机器人
            _value.rid = FuncPvp.genRobotRid(_value.rid)
        end
    end
end
function ArenaMainView:onCloudDisappear(event, playCloud)
	self:animShowButtons()
    if event.result ~= nil then
        --对数据进行预处理
        local data = event.result.data
        self:processRobot(data)
		PVPModel:setUserRank(data.userRank)
		PVPModel:cacheRankList(data)
        if not self.pvp_list_inited then
			self:initPvpList({})
		else
			self:updatePvpList()
		end
		self:updatePlayerUI(playCloud)
    else
        WindowControler:showTips("刷新匹配失败")
    end
    self:notifyRankXchgChanged();
end


function ArenaMainView:updatePvpList()
	local sortByRank = function(a, b)
		return tonumber(a.rank)<tonumber(b.rank)
	end
	local data = PVPModel:getCacheRankList()
	local topThree = data.topThree or {}
	local opponents = data.opponents or {}
	table.sort(topThree, sortByRank)
	table.sort(opponents, sortByRank)
	local players = {}
	for i=1,3 do
		local info = topThree[i]
		if info then
			players[i] = info
		else
			players[i] = -1
		end
	end
	for i=1,4 do -- 修改数据的数目
		local info = opponents[i]
		if info then
			players[i+3] = info
		else
			players[i+3] = -1
		end
	end
	local keys = {4,5,6,7,1,2,3}

	local count = 1
	self._playerViews = {}
	for _, i in ipairs(keys) do
		local index = i
		local view = self.commonPvpView
		local info = players[i]
		if i>3 then
			index = i-3
		else
			view = self.topPvpView
		end
		local playerView
		if type(info) ~= "table" then --此时玩家可能是第一次进入竞技场,由于排名最低,所以需要隐藏最后的一个
			playerView = view:updateOnePlayer(index, info, self)
			self._playerViews[index] = playerView 
		else
			local updateOnePlayer = function()
				playerView = view:updateOnePlayer(index, info, self)
				self._playerViews[i] = playerView
			end
			self:delayCall(c_func(updateOnePlayer), 0.3)--原来的是count*0.3
			count = count + 1
		end
	end
	self:updateScrollBehavior()
	--只执行一次
	if not self.talk_has_began then
		self:delayCall(c_func(self.beganShowTalk, self), 2)
		self.talk_has_began = true
	end
end

function ArenaMainView:beganShowTalk()
	local groupIndex, itemIndex = self.scroll_arenalist:getGroupPos(1)
	local index_keys = {1, 2, 3 }
	if groupIndex == 2 then
		index_keys = {4, 5, 6}
	end
	if self._last_talk_player then
		self._last_talk_player:hideTalk()
	end
	local rand_index = RandomControl.getOneRandomInt(4, 1)
	local key = index_keys[rand_index]
	local playerView = self._playerViews[key]
	if playerView then
		self._last_talk_player = playerView
		playerView:showRandomTalk()
	end
	self:delayCall(c_func(self.beganShowTalk, self), 5)
end

-- 刷新一批
function ArenaMainView:freshMatch()
    self:refreshMatch()
end
--积分奖励
function ArenaMainView:clickButtonScore()
    WindowControler:showWindow("ArenaScoreRewardView")
end
-- 打开规则说明界面
function ArenaMainView:press_btn_shuoming()
    WindowControler:showWindow("ArenaRulesView")
end
--弹出排名兑换奖励
function ArenaMainView:clickButtonRankExchg()
    WindowControler:showWindow("ArenaRankExchangeView")
end
-- 打开战斗回放界面
function ArenaMainView:press_btn_huifang()
	--清空战报提示
	PVPModel:clearCurrentFightReports()
	PVPModel:checkNewReport()
	WindowControler:showWindow("ArenaBattlePlayBackView")
end

-- 打开商店界面
function ArenaMainView:press_btn_shop()
    WindowControler:showWindow("ShopView", FuncShop.SHOP_TYPES.PVP_SHOP)
end

-- 返回
function ArenaMainView:press_btn_back()
    self:startHide()
end

return ArenaMainView
