--�������������ֽ���
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
    --���������ֱ仯֪ͨ
    EventControler:addEventListener(PvpEvent.SCORE_REWARD_CHANGED_EVENT,self.notifyScoreRewardChanged,self)
end

function ArenaScoreRewardView:alignView()
    FuncCommUI.setViewAlign(self.panel_title,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.btn_close,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.scale9_updi,UIAlignTypes.LeftTop);
    self.scale9_updi:setContentSize(cc.size(GameVars.width,self.scale9_updi:getContentSize().height));
    FuncCommUI.setScrollAlign(  self.scroll_1,UIAlignTypes.Middle,1,0 ,1)
end
--���������ֱ仯֪ͨ
function ArenaScoreRewardView:notifyScoreRewardChanged(_param)
    local _change_score_items = _param.params
    --����self._notAchieve
    local _reward_set = {}
    self:updateScoreInfo()
    for _key,_value in pairs(_change_score_items)do
        local _score_item = FuncPvp.getIntegralRewradData(_key)
        for _key2 ,_value2 in pairs(_score_item.reward) do
            table.insert(_reward_set,_value2)
        end
        --������ص����
        local _index = self._childIndiceMap[_key]
        local _view = self._childView[_index]
        local _item = self._reverseMap[_key]
        if _view ~= nil then
            self:updateScoreItemView(_view,_item)
        end
    end
    FuncCommUI.startRewardView(_reward_set)
    --����
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
    --��������ӳ���
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
        --����Ƿ���ڳ�ͻ
        local _old_key = self._historyMap[_view.__private_key]
        if _old_key ~= nil then--�޳���ԭ����Ӱ��
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
--����UI�ĵװ�
function ArenaScoreRewardView:updateScoreInfo()
    --��ȡ���е��Ѿ���õĻ���
    local _scoreReward = PVPModel:getAllScoreRewards()
    --ͳ�Ƶ�ǰ�ھ��������Ѿ������ս������Ŀ
    local _length = CountModel:getPVPChallengeCount()
    self.panel_1.txt_2:setString(GameConfig.getLanguage("pvp_score_reward_times_1003"):format(_length))
    --����Ƿ���û����ȡ�Ľ���
    local _now_count = CountModel:getPVPChallengeCount()
    --�������
    local _not_rechieve = {}
    for _key,_value in pairs(self._integralScore) do
        --����ﵽ�˴�������,���һ�û����ȡ
        if _now_count >= _value.condition and not _scoreReward[_value.id] then
            table.insert(_not_rechieve,_value.id)
        end
    end
    if #_not_rechieve <=0 then--��ʱ����û�е����κ�һ����ȡ����,�����Ѿ���ȡ���
        FilterTools.setGrayFilter(self.btn_lq)
        self.btn_lq:setTap(c_func(self.clickButtonNotAchieve,self))
    else
        self.btn_lq:setTap(c_func(self.clickButtonOneKey,self))--һ����ȡ
    end
    self._notAchieve = _not_rechieve
end
--
function ArenaScoreRewardView:clickButtonNotAchieve()
    --��ʾ,��δ�ﵽ��ȡ����
    WindowControler:showTips(GameConfig.getLanguage("pvp_score_reward_not_any_1004"))
end
--һ����ȡ
function ArenaScoreRewardView:clickButtonOneKey()
    --����Э��
    local _param = {
        scoreIds = self._notAchieve,--���ֽ�����id
    }
    PVPServer:requestScoreReward(_param,c_func(self.onAchieveRewardEvent,self))
end
--��ȡ���ֽ�������
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
    --���û��ֵ�״̬
    local _score_item = FuncPvp.getIntegralRewradData(_item.id)
    --����Ƿ���û����ȡ�Ľ���
    local _now_count = CountModel:getPVPChallengeCount()
    local _scoreReward = PVPModel:getAllScoreRewards()
    if not _scoreReward[_item.id] and _now_count>=_score_item.condition then --���û����ȡ,����Ҫ��ĳ����Ѿ��ﵽ
        _panel.mc_1:showFrame(2)
        _panel.mc_1.currentView.btn_1:setTap(c_func(self.clickCellButtonReward,self,_item))
    elseif  _scoreReward[_item.id]      then --����Ѿ���ȡ
        _panel.mc_1:showFrame(3)
    else --���û����ȡ,���ǻ�û�дﵽҪ��
        _panel.mc_1:showFrame(1)
        _panel.mc_1.currentView.mc_1:showFrame(_index)
    end
end
--�����ȡ��صĽ���
function ArenaScoreRewardView:clickCellButtonReward(_item)
    --����Э��
    local _param = {
        scoreIds = {_item.id},--���ֽ�����id
    }
    PVPServer:requestScoreReward(_param,c_func(self.onAchieveRewardEvent,self))
end
return ArenaScoreRewardView