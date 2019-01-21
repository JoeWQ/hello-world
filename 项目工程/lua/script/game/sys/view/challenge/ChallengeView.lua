--2016.8.11
--ZQ


local ChallengeView = class("ChallengeView", UIBase);


function ChallengeView:ctor(winName)
    ChallengeView.super.ctor(self, winName);
end

function ChallengeView:loadUIComplete()
	self:registerEvent();

	
	--关闭按钮右上
	FuncCommUI.setViewAlign(self.btn_fanhui,UIAlignTypes.RightTop) 
    FuncCommUI.setViewAlign(self.panel_UI,UIAlignTypes.RightTop) 
    FuncCommUI.setScale9Align(self.scale9_heidai,UIAlignTypes.MiddleTop, 1, 0)
    FuncCommUI.setViewAlign(self.panel_tz,UIAlignTypes.LeftTop) 
    FuncCommUI.setScrollAlign(self.scroll_1,UIAlignTypes.MiddleBottom,1,0)

	--初始化更新ui
--	self:updateUI()

    --
--    self.panel_1:setVisible(false)
    self:initScrollView()
end 

function ChallengeView:initScrollView()
    local createFunc = function ( itemData )
		local view = self.panel_1
        self:updateUI(view)
		return view
    end
    local createBgFunc1 = function ( groupIndex,width,height )
		local view = display.newSprite("bg/arena_bg.png")
        view:setContentSize(cc.size(1280,640))
        view:setAnchorPoint(cc.p(0,1))
		return view
    end
    local configData = {1}
	local _scrollParams = {
			{
				data = configData,
				createFunc= createFunc,
				perFrame = 1,
				offsetX =0,
				offsetY =0,
				itemRect = {x=0,y= -514,width=1280,height = 514},
				widthGap = 0,
                heightGap = 0,
                perNums = 1,
--                createBgFunc =createBgFunc1,
			}
		}
    self.scroll_1:styleFill(_scrollParams);
	self.scroll_1:hideDragBar()
end

function ChallengeView:registerEvent()
    self.btn_fanhui:setTap(c_func(self.press_btn_close, self));
    EventControler:addEventListener(PvpEvent.PVPEVENT_REPORT_RESULT_OK, self.onPVPReportResultOk, self)
    EventControler:addEventListener(TrialEvent.BATTLE_SUCCESSS_EVENT,self.onTrialReportResultOk, self);
    EventControler:addEventListener("CHALLENGE_TOWER_CAN_RESET_RED_POINT",self.onTowerReportResultOk, self);
--//On Event PVP Challenge
    EventControler:addEventListener(PvpEvent.COUNT_TYPE_BUY_PVP,self.onPvpChallengeCountChange,self);
    EventControler:addEventListener(PvpEvent.PVPEVENT_BUY_CHALLENGE_COUNT_OK,self.onPvpChallengeCountChange,self);
end
--//竞技场剩余次数发生变化
function ChallengeView:onPvpChallengeCountChange()
    local    _pvpView=self.panel_1.mc_dengxian:getViewByFrame(2);
    local    _challengeTimesLeft=FuncPvp.getPvpChallengeLeftCount();
    _pvpView.btn_1:getUpPanel().panel_red:setVisible(_challengeTimesLeft>0);
    _pvpView.btn_1:getUpPanel().txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), _challengeTimesLeft));
end
function ChallengeView:onPVPReportResultOk()
    local dayTimes = ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.PVP) 
    self.panel_1.mc_dengxian:showFrame(2)
    self.panel_1.mc_dengxian.currentView.btn_1:getUpPanel().txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), dayTimes))
    self:onPvpChallengeCountChange();
end
function ChallengeView:onTrialReportResultOk()
    local dayTimes = ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.TRIAL)
    self.panel_1.mc_slk:showFrame(2)
    self.panel_1.mc_slk.currentView.btn_1:getUpPanel().panel_red:setVisible(dayTimes>0);
    self.panel_1.mc_slk.currentView.btn_1:getUpPanel().txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), dayTimes))
end
function ChallengeView:onTowerReportResultOk()
    local dayTimes = ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.TOWER);
    self.panel_1.mc_syt:showFrame(2);
    self.panel_1.mc_syt.currentView.btn_1:getUpPanel().panel_red:setVisible(tonumber(dayTimes)>0);
    self.panel_1.mc_syt.currentView.btn_1:getUpPanel().txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), dayTimes))
end
function ChallengeView:onDefenderReportResultOk()
   local dayTimes = ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.DEFENDER);
    self.panel_1.mc_shzx:showFrame(2);
    self.panel_1.mc_shzx.currentView.btn_1:getUpPanel().panel_red:setVisible(tonumber(dayTimes)>0);
    self.panel_1.mc_shzx.currentView.btn_1:getUpPanel().txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), dayTimes))

end
function ChallengeView:press_btn_close()
	self:startHide()
end

function ChallengeView:updateUI( view )
    self:delayCall(c_func(self.initTower,self,view),1/30)
    self:delayCall(c_func(self.initPVP,self,view),2/30)
    self:delayCall(c_func(self.initTrail,self,view),3/30)
    self:delayCall(c_func(self.initDefender,self,view),4/30)
--	self:initTower(view)
--    self:initPVP(view)
--    self:initTrail(view)
--    self:initDefender(view)
    
end

function ChallengeView:initCommon(view,typeId)
    local isOpen1 , isOpen2 = ChallengeModel:isSystemOpen(typeId)
    local icons = ChallengeModel:getIconsBySystemId(typeId)
    local mcInfo
    local viewEnterName -- 功能入口
    local dayTimes --
    if typeId == ChallengeModel.KEYS.TOWER then
        mcInfo = view.mc_syt
        viewEnterName = "TowerNewMainView" 
        dayTimes = ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.TOWER)
    elseif typeId == ChallengeModel.KEYS.PVP then 
        mcInfo = view.mc_dengxian
        viewEnterName = "ArenaMainView" 
        dayTimes = ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.PVP)
--//红点显示是否
        local   _panel_red=mcInfo:getViewByFrame(2).btn_1:getUpPanel().panel_red;
        _panel_red:setVisible(FuncPvp.getPvpChallengeLeftCount()>0);
    elseif typeId == ChallengeModel.KEYS.TRIAL then 
        mcInfo = view.mc_slk
        viewEnterName = "TrialEntranceView" 
        dayTimes = ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.TRIAL)
    elseif typeId == ChallengeModel.KEYS.DEFENDER then
        mcInfo = view.mc_shzx
        viewEnterName = "DefenderMainView" 
        dayTimes = ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.DEFENDER)
    end
    if isOpen1 == nil then
        FilterTools.clearFilter(mcInfo)
        mcInfo:showFrame(2)
        local infoUI = mcInfo.currentView.btn_1
        -- 剩余次数
        infoUI:getUpPanel().txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), dayTimes))
        if dayTimes > 0 then
            --红点显示
            infoUI:getUpPanel().panel_red:setVisible(true)
        else
            infoUI:getUpPanel().panel_red:setVisible(false)
        end
        --可得到的物品 列表

        for i,v in pairs(icons) do
           
            local rewardView = infoUI:getUpPanel()["UI_"..i]
            local itemData = v
            rewardView:setResItemData({reward = itemData})
		    rewardView:showResItemName(false)
            rewardView:showResItemNum(false)
            
        end

        mcInfo.currentView.btn_1:setTap(c_func(function ()
            if typeId == ChallengeModel.KEYS.TOWER or typeId == ChallengeModel.KEYS.TRIAL or typeId == ChallengeModel.KEYS.DEFENDER then
                WindowControler:showTips( "功能暂未开启" )
            else
                WindowControler:showWindow(viewEnterName)
            end
--            WindowControler:showWindow(viewEnterName)
             
        end, self));
    else
        FilterTools.setGrayFilter(mcInfo)
        mcInfo:showFrame(1)
        mcInfo.currentView.btn_1:setTap(c_func(function ()
             -- 开启条件不满足提示
             local _level = ChallengeModel:getOpenLevel(typeId);
             local _ll = GameConfig.getLanguage("challenge_open_system_level");
             local _str = string.format(_ll,tonumber(_level))
             WindowControler:showTips( _str )
        end, self));
    end
end

function ChallengeView:initTower(view)
    self:initCommon(view,ChallengeModel.KEYS.TOWER)
end

function ChallengeView:initPVP(view)
    self:initCommon(view,ChallengeModel.KEYS.PVP)
end

function ChallengeView:initTrail(view)
    self:initCommon(view,ChallengeModel.KEYS.TRIAL)
end

function ChallengeView:initDefender(view)
   self:initCommon(view,ChallengeModel.KEYS.DEFENDER)
end

return ChallengeView;
