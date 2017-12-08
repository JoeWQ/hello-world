-- 伙伴系统左侧的伙伴按钮管理
-- 2016-12-6 16:32:44
-- Author:xiaohuaxiong
local PartnerBtnView = class("PartnerBtnView", UIBase)

function PartnerBtnView:ctor(_winName)
    PartnerBtnView.super.ctor(self, _winName)
    -- 默认进入伙伴系统
    self._type = "PARTNER_SYS"
    -- 当前的所有按钮
    self._partnerViewItem = { }
    -- 当前被选中的伙伴
    self._selectPartner = 1
    -- 当前所有的伙伴
    -- self._allPartners={}
    -- 关于 ParnterView的引用
    self._partnerView = nil
    -- 所有的单元组件
    self._childViews = { }
    --记录伙伴id与View之间的映射
    self._childIndiceMap={}
    --记录伙伴的次序关系
    self._partnerOrder  = 0
    --合成View
    self._combineView = nil
end

function PartnerBtnView:setPartnerView(_class)
    self._partnerView = _class
end
function PartnerBtnView:loadUIComplete()
    self:registerEvent()
    self:performPartner()
    -- 注册事件监听,伙伴系统中伙伴数目的变化,或者伙伴本身的变化
    EventControler:addEventListener(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT, self.notifyPartnerNumChanged, self)
    EventControler:addEventListener(PartnerEvent.PARTNER_INFO_CHANGE_EVENT, self.notifyPartnerInfoChanged, self)
    --监听升品,升级,升星的变化
    EventControler:addEventListener(PartnerEvent.PARTNER_STAR_LEVELUP_EVENT,self.notifyPartnerRedPoint,self) --星级
    EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_POSITION_CHANGE_EVENT,self.notifyPartnerRedPoint,self) --升品
    EventControler:addEventListener(PartnerEvent.PARTNER_LEVELUP_EVENT,self.notifyPartnerRedPoint,self) --升级
    --万能碎片,以及伙伴碎片
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.notifyItemChange,self)
end
function PartnerBtnView:notifyPartnerRedPoint(_param)
    local _partnerInfo = _param.params
    --找到相关的View
    local _index = self._childIndiceMap[_partnerInfo.id]
    if  _index then
        local _view = self._childViews[_index];
        --红点事件
            _view.panel_red:setVisible(self:isShowredPoint(_partnerInfo.id))
    end
end
--万能碎片,伙伴碎片
function PartnerBtnView:notifyItemChange(_param)
    local _dataItems = _param.params
    --检测是否有万能碎片变化
--    local _full_func = false
--    for _key,_value in pairs(_dataItems) do
--        if _key == FuncPartner.FullFuncItemId then--此时需要全部刷新
--            _full_func = true
--        end
--    end
--    if _full_func then
--        for _key,_value in pairs(self._childIndiceMap)do
--            local _view = self._childViews[_value]
--            _view.panel_red:setVisible(self:isShowredPoint(_key))
--        end
--    end
    --伙伴碎片
    self._combineView.panel_1:setVisible(self:isPartnerCombineRedPoint())
end
--判断伙伴合成红点是否应该显式
function PartnerBtnView:isPartnerCombineRedPoint()
    local _now_partners = PartnerModel:getAllPartner()
    local _partner_table = FuncPartner.getAllPartner()
    --逐个判断
    local _red_point = false
    for _key,_value in pairs(_partner_table)do
        if not _now_partners[_key] and not _red_point then
            _red_point = ItemsModel:getItemNumById(_key) >= _value.tity
        end
    end
    return _red_point
end
--设置UI进入的系统
function PartnerBtnView:setUIType(_type)
    self._type = _type
end
--判断某一个伙伴图标的红点是否应该显式
function PartnerBtnView:isShowredPoint(_partnerId)
    if self._type == "EQUIP_SYS" then
        local _tag1 = PartnerModel:isShowEquipRedPoint(_partnerId)--装备
        if _tag1 then 
            return true 
        end
    else
        local _tag1 = PartnerModel:isShowUpgradeRedPoint(_partnerId)--升级
        if _tag1 then return true end
        local _tag2 = PartnerModel:isShowStarRedPoint(_partnerId) --升星
        if _tag2 then return true end
        local _tag3 = PartnerModel:isShowQualityRedPoint(_partnerId) --升品
        if _tag3 then return true end
    end

    
    --万能碎片
--    local _item_count = ItemsModel:getItemNumById(FuncPartner.FullFuncItemId)
--    return _item_count > 0 
    return false
end
-- 处理所有的伙伴信息
function PartnerBtnView:performPartner()
    self._allPartners = { }
    -- 逆向映射表,可以使用id值快速查找到伙伴的信息
    self._reversePartners = { }
    local _originPartner = PartnerModel:getAllPartner();
    for _key, _value in pairs(_originPartner) do
        table.insert(self._allPartners, _value)
 --       self._reversePartners[_key] = #self._allPartners;
    end
    --对伙伴排序
    local function _table_sort(a,b)
        --已经上阵
        --品质
        if a.quality > b.quality then
            return true
        elseif a.quality < b.quality  then
            return false
        end
        --星级
        if a.star > b.star then
            return true
        elseif a.star < b.star then
            return false
        end
        --等级
        if a.level > b.level then
            return true
        elseif a.level < b.level then
            return false
        end
        return a.id < b.id 
    end
    table.sort(self._allPartners,_table_sort)
    for _index=1,#self._allPartners do
        self._reversePartners[tostring(self._allPartners[_index].id)] = _index;
    end
end
--尝试比较,如果数据刷新了,是否会导致伙伴的位置发生变化
function PartnerBtnView:tryComparePartner( )
    local _allPartners = { }
    -- 逆向映射表,可以使用id值快速查找到伙伴的信息
    local _reversePartners = { }
    local _originPartner = PartnerModel:getAllPartner();
    for _key, _value in pairs(_originPartner) do
        table.insert(_allPartners, _value)
 --       self._reversePartners[_key] = #self._allPartners;
    end
    --对伙伴排序
    local function _table_sort(a,b)
        --已经上阵
        --品质
        if a.quality > b.quality then
            return true
        elseif a.quality < b.quality  then
            return false
        end
        --星级
        if a.star > b.star then
            return true
        elseif a.star < b.star then
            return false
        end
        --等级
        if a.level > b.level then
            return true
        elseif a.level < b.level then
            return false
        end
        return a.id < b.id 
    end
    table.sort(_allPartners,_table_sort)
    for _index=1,#_allPartners do
        _reversePartners[tostring(_allPartners[_index].id)] = _index;
    end
    --重新计算当前的伙伴排列
    local _currentPartnerId = self._allPartners[self._selectPartner].id
    --重新计算当前的伙伴的id是否发生了变化
    local _now_select = _reversePartners[tostring(_currentPartnerId)]
    --位置发生了变化
    if _now_select ~= self._selectPartner then
        self._allPartners = _allPartners
        self._reversePartners = _reversePartners
        self._selectPartner = _now_select
        return true
    end
    return false
end
-- 伙伴的数目发生了变化,此时会导致伙伴系统列表发生变化
function PartnerBtnView:notifyPartnerNumChanged(_param)
--重新计算当前伙伴的索引
    local _currentPartnerId = self._allPartners[self._selectPartner].id
    self:performPartner()
    local _new_select = self._reversePartners[tostring(_currentPartnerId)]
    self._selectPartner = _new_select
    self:updateView()
    --红点
    self._combineView.panel_1:setVisible(self:isPartnerCombineRedPoint())
end
-- 某一个伙伴的信息发生了变化,必要时需要更新相关的数据结构,以及UI显示
function PartnerBtnView:notifyPartnerInfoChanged(_param)
    local _localPartner = _param.params;
--只有在必要的时候才会刷
    if self:tryComparePartner() then
        self:updateView()
        return
    end
    for _key, _value in pairs(_localPartner) do
        local _index = self._reversePartners[_key];
        local _view = self._childViews[_index]
        self:updateViewItem(_view, _value, _index)
    end
end
function PartnerBtnView:registerEvent()
    PartnerBtnView.super.registerEvent(self)
end
-- 伙伴跳转index
function PartnerBtnView:setCurrentPartner(_partnerId)
    if _partnerId then
        for i,v in pairs(self._allPartners) do
            if tostring(v.id) == tostring(_partnerId) then
                self._selectPartner = i
            end
        end
    end
    
end
-- 返回当前被选中的伙伴以及其索引
function PartnerBtnView:getCurrentPartner()
    return self._allPartners[self._selectPartner], self._selectPartner
end
-- 设置生成的每一个伙伴详情的页面
function PartnerBtnView:updateViewItem(_view, _item, _index)
--如果被选中了
    -- 品质
    local panel=_view
    panel.panel_smallflash:setVisible(false)--伙伴出站标志暂时隐藏
    panel.mc_2:showFrame(_item.quality)
    -- 伙伴的表格
    local _partnerInfo = FuncPartner.getPartnerById(_item.id);
    -- 伙伴的Icon
    local _ctn = panel.mc_2.currentView.ctn_1
    local _iconPath = FuncRes.iconHero(_partnerInfo.icon)
    local _spriteIcon = cc.Sprite:create(_iconPath)
    _ctn:removeAllChildren()
    _ctn:addChild(_spriteIcon)
    -- 等级
    panel.txt_3:setString(tostring(_item.level))
    -- 星级
    panel.mc_dou:showFrame(_item.star)
    -- 当前是否被选中
    panel.panel_1:setVisible(_index == self._selectPartner)
    -- 注册按钮回调事件
    panel:setTouchedFunc(c_func(self.onTouchCallFunc, self, _index) )
    panel:setTouchSwallowEnabled(true)
    --红点
    panel.panel_red:setVisible(self:isShowredPoint(_item.id))
end
--最下面的伙伴碎片合成按钮
function PartnerBtnView:updateCombineItemView(_item,_view)
    _view:setTouchedFunc(c_func(self.onTouchCombine,self))
    _view:setTouchSwallowEnabled(true)
    _view.panel_1:setVisible(self:isPartnerCombineRedPoint())
end
-- 按钮事件
function PartnerBtnView:onTouchCallFunc(_index)
    if self.scrollView:isMoving() then
        return
    end
    -- 只有在必要的时候才会刷新
    if (_index ~= self._selectPartner and not self._childViews[_index].ignore_event) then
        self._partnerView:changeUIInBtnView(self._allPartners[_index])
--现在暂时这么写,下星期策划回来的时候,让他修改
        self._childViews[self._selectPartner].panel_1:setVisible(false)
        self._childViews[_index].panel_1:setVisible(true)
        self._selectPartner = _index
    end
end
--碎片合成事件
function PartnerBtnView:onTouchCombine()
    WindowControler:showWindow("PartnerCombineView")
end
-- 当有数据变化时引起的UI的刷新
function PartnerBtnView:updateView()
    local _data_source = self._allPartners
    self.scrollView = self.panel_3.scroll_1
    self.panel_3.panel_1:setVisible(false)
    self.panel_3.panel_2:setVisible(false)

    local createFunc = function(_item, _index)
        local _view = UIBaseDef:cloneOneView(self.panel_3.panel_1)
        table.insert(self._childViews, _view) --与self._partnerOrder数据同步
       -- self._partnerOrder = self._partnerOrder +1
        self._childIndiceMap[_item.id] = #self._childViews
        self:updateViewItem(_view, _item, #self._childViews)
        return _view
    end
    
    local function updateCellFunc(_item,_view,_index)
        --重新映射,如果原来的位置已经被占用
        self._childIndiceMap[_item.id] = _index
        self._childViews[_index] = _view
        self:updateViewItem(_view,_item,_index)
    end
    ----目前这个函数暂时不使用,以免影响这的映射关系查询
    local function updateFunc(_item,_view,_index)
        self:updateViewItem(_view,_item,_index)
    end
    local _param = {
        data = _data_source,
        createFunc = createFunc,
        updateCellFunc = updateCellFunc,
 --       updateFunc = updateFunc,
        perNums = 1,
        offsetX = 0,
        offsetY = 0,
        widthGap = 0,
        heightGap = 0,
        itemRect = { x = 0, y = - 111.0, width = 112, height = 111 },
        perFrame = 1,
        cellWithGroup = 1,
    }
    local function createFunc2(_item,_index)
        local _view = UIBaseDef:cloneOneView(self.panel_3.panel_2)
        self:updateCombineItemView(_item,_view)
        self._combineView = _view
        return _view
    end
    local function updateCellFunc2(_item,_view,_index)
        self:updateCombineItemView(_item,_view)
        self._combineView = _view
    end
    local function updateFunc2(_item,_view,_index)
        self:updateCombineItemView(_item,_view)
    end
    local _param2 = {
        data = {"16"},
        createFunc = createFunc2,
        updateCellFunc = updateCellFunc2,
 --       updateFunc = updateFunc2,
        perNums =1,
        offsetX = 12,
        offsetY = 0,
        widthGap =0,
        heightGap = 4,
        itemRect = {x =0, y =-88,width = 88,height =88},
        perFrame = 1,
        cellWithGroup = 2,
    }
     self.scrollView:styleFill( { _param ,_param2,})

     self.scrollView:gotoTargetPos(self._selectPartner,1)
end

return PartnerBtnView