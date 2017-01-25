--竞技场排名兑换
--2017-1-11 16:45:08
--@Author:xiaohuaxiong
local ArenaRankExchangeView = class("ArenaRankExchangeView",UIBase)

function ArenaRankExchangeView:ctor(_window_name)
    ArenaRankExchangeView.super.ctor(self,_window_name)
    self.greenColor = cc.c3b(0x7E,0xFF,0x0)
    self.redColor = cc.c3b(0xFF,0x0,0x0)
end

function ArenaRankExchangeView:loadUIComplete()
    self:registerEvent()
    FuncCommUI.setViewAlign(self.panel_title,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.btn_close,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.scale9_updi,UIAlignTypes.LeftTop);
    self.scale9_updi:setContentSize(cc.size(GameVars.width,self.scale9_updi:getContentSize().height));

    self:performStatic()
    self:updateRankView()
end

function ArenaRankExchangeView:registerEvent()
    ArenaRankExchangeView.super.registerEvent(self)
    self.btn_close:setTap(c_func(self.clickButtonClose,self))
    --监听竞技场货币的变化
    EventControler:addEventListener(UserEvent.USEREVENT_PVP_COIN_CHANGE,self.notifyPvpCoinChangedEvent,self)
    --监听竞技场排名奖励发生变化
    EventControler:addEventListener(PvpEvent.RANK_EXCHANGE_CHANGED_EVENT,self.notifyPvpRankExchangeEvent,self)
end
--竞技场货币变化通知
function ArenaRankExchangeView:notifyPvpCoinChangedEvent(_param)
    local _data = _param.params
    --刷新所有的组件
    for _key,_value in pairs(self._childIndiceMap)do
        local _index = _value
        local _item = self._rankData[ self._reverseMap[_key] ]
        local _view = self._childView[_index]
        self:updatePvpCoinOnly(_view,_item)
    end
end
--竞技场排名兑换奖励变化
function ArenaRankExchangeView:notifyPvpRankExchangeEvent(_param)
    local _data = _param.params
    local _itemId 
    --单个键值
    for _key,_value in pairs(_data) do
        _itemId = _key
    end
    --查找相关的组件
    local _index = self._childIndiceMap[_itemId]
    local _item_index = self._reverseMap[_itemId]
    self:updateEveryRankItem(self._childView[_index],self._rankData[_item_index])
    --同时遍历所有的奖励
    local _rank_item = FuncPvp.getRankExchange(_itemId)
    local _reward_set = {}
    for _key,_value in pairs(_rank_item.reward)do
        table.insert(_reward_set,_value)
    end
    FuncCommUI.startRewardView(_reward_set)
    self:performStatic()
    self:updateRankView()
end
--整合所有的数据
function ArenaRankExchangeView:performStatic()
    --所有的排名兑换奖励数据
    local _rank_data = FuncPvp.getAllRankExchanges()
    local _now_rank_data = {}
    for _key,_value in pairs(_rank_data) do
        table.insert(_now_rank_data,_value)
    end
    local _now_ranks = PVPModel:getAllRankExchanges() --已经获得的排名兑换数据
    local function _table_sort(a,b)
        --如果已经领取过了,排名靠下
        if _now_ranks[a.id] then
            if not _now_ranks[b.id]  then
                return false
            end
        else
            if _now_ranks[b.id] then
                return true
            end
        end
        return tonumber(a.id) < tonumber(b.id)
    end
    table.sort(_now_rank_data,_table_sort)
    self._rankData = _now_rank_data
    --建立逆向映射表
    local _reverse_map = {}
    for _index=1, # _now_rank_data do
        _reverse_map[_now_rank_data[_index].id ] = _index
    end
    self._reverseMap = _reverse_map
    self._childIndiceMap = {}
    self._childView = {}
    --数据历史记录
    self._historyMap = {}
end

function ArenaRankExchangeView:clickButtonClose()
    self:startHide()
end
--更新所有的组件
function ArenaRankExchangeView:updateRankView()
    local _data_source = self._rankData
    self.panel_1:setVisible(false)
    local __private_id_nums = 1
    --create function
    local function createFunc(_item,_index)
        local _view = UIBaseDef:cloneOneView(self.panel_1)
        _view.__private_id = __private_id_nums
        self:updateEveryRankItem(_view,_item)
        self._childView[_index] = _view
        self._childIndiceMap[_item.id] = _index
        self._historyMap[ __private_id_nums] = _item.id
        __private_id_nums = __private_id_nums +1
        return _view
    end
    --
    local function updateCellFunc(_item,_view,_index)
        self:updateEveryRankItem(_view,_item)
        --剔除掉原来的数据
        local _private_key = _view.__private_id
        local  _old_item_id = self._historyMap[_private_key]
        if  _old_item_id ~= nil then
            local _old_index = self._childIndiceMap[_old_item_id]
            self._childView[_old_index] = nil
            self._childIndiceMap[_old_item_id] = nil
        end
        self._childView[_index]  =_view
        self._childIndiceMap[_item.id] = _index
        self._historyMap[_private_key] = _item.id
    end
    local _param = {
        data = _data_source,
        createFunc = createFunc,
        updateCellFunc = updateCellFunc,
        offsetX =0,
        offsetY = 0,
        perNums = 1,
        widthGap =0,
        heightGap = 0,
        perFrame =1,
        itemRect = {x=0,y=-141.4,width = 842,height = 141.4},
    }
    self.scroll_1:styleFill({_param})
end

function ArenaRankExchangeView:updateEveryRankItem(_view,_item)
    --设置道具的图标
    _view.UI_1:setRewardItemData({reward=_item.reward[1]})
    local _reward =string.split( _item.reward[1],",")
    local _item_item = FuncItem.getItemData(_reward[2])
    --道具的品质
    _view.mc_zi:showFrame(_item_item.quality)
    --道具的名字
    _view.mc_zi.currentView.txt_1:setString(GameConfig.getLanguage(_item_item.name))
    --兑换这个奖励需要达到的兑换条件
    _view.txt_2:setString(tostring(_item.condition))
    --当前是否已经领取了
    local _now_ranks = PVPModel:getAllRankExchanges() --已经获得的排名兑换数据
    --当前是否已经达到
    if _now_ranks[_item.id] then
        _view.mc_1:showFrame(2)
        _view.txt_2:setColor(self.greenColor)
        return
    end
    local _rank = PVPModel:getHistoryTopRank()
    _view.mc_1:showFrame(1)
    local _panel = _view.mc_1.currentView
    if _rank <= _item.condition then --如果已经达到条件
        _view.txt_2:setColor(self.greenColor)
        _panel.btn_1:setTap(c_func(self.clickButtonExchange,self,_item))
    else
        _view.txt_2:setColor(self.redColor)
        _panel.btn_1:setTap(c_func(self.clickButtonRankCondition,self))
    end
    --兑换时需要花费的资源
    local _user_money = UserModel:getArenaCoin()
    local _cost_data = string.split(_item.cost[1],",")
    if _user_money < tonumber(_cost_data[2]) then--竞技场货币不足
        _panel.panel_xian.mc_1:showFrame(2)
    else
        _panel.panel_xian.mc_1:showFrame(1)
    end
    _panel.panel_xian.mc_1.currentView.txt_1:setString(_cost_data[2])
end
--只更新与竞技场货币的显示相关的组件
function ArenaRankExchangeView:updatePvpCoinOnly(_view,_item)
    --当前是否已经领取了
    local _now_ranks = PVPModel:getAllRankExchanges() --已经获得的排名兑换数据
    --当前是否已经达到,如果达到了,就直接返回,无需再更新了
    if _now_ranks[_item.id] then
        return
    end
    local _panel = _view.mc_1.currentView
    --兑换时需要花费的资源
    local _user_money = UserModel:getArenaCoin()
    local _cost_data = string.split(_item.cost[1],",")
    if _user_money < tonumber(_cost_data[2]) then--竞技场货币不足
        _panel.panel_xian.mc_1:showFrame(2)
    else
        _panel.panel_xian.mc_1:showFrame(1)
    end
    _panel.panel_xian.mc_1.currentView.txt_1:setString(_cost_data[2])
end
--排名条件不足
function ArenaRankExchangeView:clickButtonRankCondition()
    WindowControler:showTips(GameConfig.getLanguage("pvp_rank_condition_not_satisfy_1002"))
end
--点击兑换
function ArenaRankExchangeView:clickButtonExchange(_item)
    local _user_money = UserModel:getArenaCoin()
    local _cost_data = string.split(_item.cost[1],",")
    if _user_money < tonumber(_cost_data[2]) then
        WindowControler:showTips(GameConfig.getLanguage("pvp_coin_not_enough_1001"))
        return
    end
    PVPServer:requestRankExchange(_item.id,c_func(self.onExchangeEvent,self,_item))
end

function ArenaRankExchangeView:onExchangeEvent(_item,_event)
    if _event.result ~= nil then
        
    end
end
return  ArenaRankExchangeView