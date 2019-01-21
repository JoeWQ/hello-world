--竞技场排名积分奖励
--2017-1-13 15:57:46
--@Author:xiaohuaxiong
local ArenaScoreRewardView = class("ArenaScoreRewardView",UIBase)

function ArenaScoreRewardView:ctor(_window_name)
    ArenaScoreRewardView.super.ctor(self,_window_name)
end

function ArenaScoreRewardView:loadUIComplete()
    self:registerEvent()
    self:alignView()
    self:performStatic()
    self:updateScoreView()
    self:updateScoreInfo()
end

function ArenaScoreRewardView:registerEvent()
    ArenaScoreRewardView.super.registerEvent(self)
    self.btn_close:setTap(c_func(self.clickButtonClose,self))
    --竞技场积分变化通知
    EventControler:addEventListener(PvpEvent.SCORE_REWARD_CHANGED_EVENT,self.notifyScoreRewardChanged,self)
end

function ArenaScoreRewardView:alignView()
    FuncCommUI.setViewAlign(self.panel_title,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.btn_close,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.scale9_updi,UIAlignTypes.LeftTop);
    self.scale9_updi:setContentSize(cc.size(GameVars.width,self.scale9_updi:getContentSize().height));
    FuncCommUI.setScrollAlign(  self.scroll_1,UIAlignTypes.Middle,1,0 ,1)
end
--竞技场积分变化通知
function ArenaScoreRewardView:notifyScoreRewardChanged(_param)
    local _change_score_items = _param.params
    --遍历self._notAchieve
    local _reward_set = {}
    self:updateScoreInfo()
    for _key,_value in pairs(_change_score_items)do
        local _score_item = FuncPvp.getIntegralRewradData(_key)
        for _key2 ,_value2 in pairs(_score_item.reward) do
            table.insert(_reward_set,_value2)
        end
        --更新相关的组件
        local _index = self._childIndiceMap[_key]
        local _view = self._childView[_index]
        local _item = self._reverseMap[_key]
        if _view ~= nil then
            self:updateScoreItemView(_view,_item)
        end
    end
    FuncCommUI.startRewardView(_reward_set)
    --奖励
    self:updateScoreView()
end
--data source
function ArenaScoreRewardView:performStatic()
    local _integral_score = FuncPvp.getIntegralRewards()
    local _integralScore ={}
    for _key,_value in pairs(_integral_score)do
        table.insert(_integralScore,_value)
    end
    local function _table_sort(a,b)
        return tonumber(a.id) < tonumber(b.id)
    end
    table.sort(_integralScore,_table_sort)
    --建立逆向映射表
    local _reverseMap = {}
    for _key,_value in pairs(_integralScore)do
        _reverseMap[_value.id] = _value
    end
    self._integralScore = _integralScore
    self._reverseMap = _reverseMap
    self._childView = {}
    self._childIndiceMap = {}
    self._historyMap = {}
end
--close
function ArenaScoreRewardView:clickButtonClose()
    self:startHide()
end

function ArenaScoreRewardView:updateScoreView()
    self.mc_ten:setVisible(false)
    local _data_source = self._integralScore
    local __private_key = 1
    local function createFunc(_item,_index)
        local _view = UIBaseDef:cloneOneView(self.mc_ten)
        self:updateScoreItemView(_view,_item)
        self._childView[_index] = _view
        self._childIndiceMap[_item.id] = _index
        _view.__private_key = __private_key
        self._historyMap[__private_key] = _item.id
        __private_key = __private_key +1
        return _view
    end
    -- update cell 
    local function updateCellFunc(_item,_view,_index)
        --检测是否存在冲突
        local _old_key = self._historyMap[_view.__private_key]
        if _old_key ~= nil then--剔除掉原来的影响
            local _old_index = self._childIndiceMap[_old_key]
            self._childView[_old_index] =nil
            self._childIndiceMap[_old_key] = nil
        end
        self._historyMap[_view.__private_key] = _item.id
        self._childView[_index] = _view
        self._childIndiceMap[_item.id] = _index
        self:updateScoreItemView(_view,_item)
    end
    local _param = {
        data = _data_source,
        createFunc = createFunc,
        updateCellFunc = updateCellFunc,
        offsetX =0,
        offsetY =0,
        perNums =1,
        widthGap = 20,
        heightGap =0,
        perFrame =1,
        itemRect = {x = 0,y=-285,width =150,height = 285},
    }
    self.scroll_1:styleFill({_param})
end
--更新UI的底板
function ArenaScoreRewardView:updateScoreInfo()
    --获取所有的已经获得的积分
    local _scoreReward = PVPModel:getAllScoreRewards()
    --统计当前在竞技场中已经打过的战斗的数目
    local _length = CountModel:getPVPChallengeCount()
    self.panel_1.txt_2:setString(GameConfig.getLanguage("pvp_score_reward_times_1003"):format(_length))
    --检测是否还有没有领取的奖励
    local _now_count = CountModel:getPVPChallengeCount()
    --逐个遍历
    local _not_rechieve = {}
    for _key,_value in pairs(self._integralScore) do
        --如果达到了次数限制,并且还没有领取
        if _now_count >= _value.condition and not _scoreReward[_value.id] then
            table.insert(_not_rechieve,_value.id)
        end
    end
    if #_not_rechieve <=0 then--此时或者没有到达任何一个领取条件,或者已经领取完毕
        FilterTools.setGrayFilter(self.btn_lq)
        self.btn_lq:setTap(c_func(self.clickButtonNotAchieve,self))
    else
        self.btn_lq:setTap(c_func(self.clickButtonOneKey,self))--一键领取
    end
    self._notAchieve = _not_rechieve
end
--
function ArenaScoreRewardView:clickButtonNotAchieve()
    --提示,尚未达到领取条件
    WindowControler:showTips(GameConfig.getLanguage("pvp_score_reward_not_any_1004"))
end
--一键领取
function ArenaScoreRewardView:clickButtonOneKey()
    --发送协议
    local _param = {
        scoreIds = self._notAchieve,--积分奖励的id
    }
    PVPServer:requestScoreReward(_param,c_func(self.onAchieveRewardEvent,self))
end
--领取积分奖励请求
function ArenaScoreRewardView:onAchieveRewardEvent(_event)
    if _event.result ~= nil then
        echo("-----ArenaScoreRewardView:onAchieveRewardEvent------")
    else
        echo("-----error------ArenaScoreRewardView:onAchieveRewardEvent--,",_event.error.message)
    end
end
--update item
function ArenaScoreRewardView:updateScoreItemView(_view,_item)
    local _index = tonumber(_item.id)
    _view:showFrame(_index)
    local _panel = _view.currentView
    for _idx = 1, #_item.reward do
        local _subUI = _panel["UI_".._idx]
        if _subUI ~= nil then
            _subUI:setRewardItemData({reward = _item.reward[_idx]})
        end
    end
    local _panel = _view.currentView
    --检测该积分的状态
    local _score_item = FuncPvp.getIntegralRewradData(_item.id)
    --检测是否还有没有领取的奖励
    local _now_count = CountModel:getPVPChallengeCount()
    local _scoreReward = PVPModel:getAllScoreRewards()
    if not _scoreReward[_item.id] and _now_count>=_score_item.condition then --如果没有领取,并且要求的场次已经达到
        _panel.mc_1:showFrame(2)
        _panel.mc_1.currentView.btn_1:setTap(c_func(self.clickCellButtonReward,self,_item))
    elseif  _scoreReward[_item.id]      then --如果已经领取
        _panel.mc_1:showFrame(3)
    else --如果没有领取,但是还没有达到要求
        _panel.mc_1:showFrame(1)
        _panel.mc_1.currentView.mc_1:showFrame(_index)
    end
end
--点击领取相关的奖励
function ArenaScoreRewardView:clickCellButtonReward(_item)
    --发送协议
    local _param = {
        scoreIds = {_item.id},--积分奖励的id
    }
    PVPServer:requestScoreReward(_param,c_func(self.onAchieveRewardEvent,self))
end
return ArenaScoreRewardView