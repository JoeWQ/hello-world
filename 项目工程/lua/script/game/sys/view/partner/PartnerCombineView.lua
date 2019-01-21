--伙伴碎片合成
--2016-12-21 19:57:00
--@Author:xiaohuaixong
local PartnerCombineView = class("PartnerCombineView",UIBase)

function PartnerCombineView:ctor(_name)
    PartnerCombineView.super.ctor(self,_name)
end

function PartnerCombineView:loadUIComplete()
    self:registerEvent()
    self:buildPartnerStatic()
    self:updateCombineView()
end
--统计所有有关伙伴的信息
function PartnerCombineView:buildPartnerStatic()
    --有关伙伴的表格数据
    local _partnerTable = FuncPartner.getAllPartner()
    --所有现在存在的伙伴数据
    local _nowPartners = PartnerModel:getAllPartner()
    --
    local _combinePartner = {} --待合成的伙伴的集合
    local _reversePartner = {} --快速查找表
    for _key,_value in pairs(_partnerTable) do
        if not _nowPartners[_key] then--如果该伙伴还没有被合成
            table.insert( _combinePartner,_key )
        end
    end
    local function _table_sort(a,b)
        local _partnerInfo1 = FuncPartner.getPartnerById(a)
        local _partnerInfo2 = FuncPartner.getPartnerById(b)

        local _count1 = ItemsModel:getItemNumById(a)
        local _count2 = ItemsModel:getItemNumById(b)

        if _count1 >= _partnerInfo1.tity   then
            if _count2>= _partnerInfo2.tity then
                return _partnerInfo1.id < _partnerInfo2.id
            end
            return true
        else
            if _count2 >= _partnerInfo2.tity then
                return false
            end
            return _partnerInfo1.id < _partnerInfo2.id
        end
    end
    table.sort(_combinePartner,_table_sort)
    self._combinePartner = _combinePartner
    --记录所有的组件
    self._childView = {}
    --记录组件的索引
    self._childIndiceMap={}
end

function PartnerCombineView:registerEvent()
    PartnerCombineView.super.registerEvent(self)
    --道具变化监听
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.notifyItemChangeEvent,self)
    --伙伴的数目发生了变化
    EventControler:addEventListener(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT,self.notifyPartnerChangeEvent,self)
    --关闭
    self.panel_1.btn_1:setTap(c_func(self.onClose,self))
end

function PartnerCombineView:notifyItemChangeEvent(_param)
    local _items = _param.params;
    for _key,_value in pairs(_items)do
        --检测是否是伙伴碎片发生了变化
        local _view = self._childView[_key]
        if _view ~= nil then
            self:updateEveryItemView(_key,_view)
        end 
    end
end
--伙伴数目监听
function PartnerCombineView:notifyPartnerChangeEvent(_param)
    --伙伴的数目只可能增加,相应的待合成的伙伴就会减少
    local _partners = _param.params
--    for _key,_value in pairs(_partners)do
--        --如果有相关的道具发生了变化
--        local _view = self._childView[_key]
--        if _view ~= nil then--此时删除这个组件从ScrollVie w中
            self:buildPartnerStatic()
            self:updateCombineView()
--        end
--    end
end
--刷新UI
function PartnerCombineView:updateCombineView()
    local _data_source = self._combinePartner
    local _template_panel = self.panel_1.panel_1
    _template_panel:setVisible(false)
    --创建函数
    local function createFunc(_item,_index)
        local _view = UIBaseDef:cloneOneView(_template_panel)
        self:updateEveryItemView(_item,_view)
        self._childView[_item] = _view
        self._childIndiceMap[_item] = _index
        return _view
    end
    --更新函数
    local function updateFunc(_item,_view)
        self:updateEveryItemView(_item,_view)
    end
    --updateCellFunc
    local function updateCellFunc(_item,_view,_index)
        self._childView[_item] = _view
        self._childIndiceMap[_item] = _index
        self:updateEveryItemView(_item,_view)
    end
    --param
    local _param = {
        data = _data_source,
        createFunc = createFunc,
        updateCellFunc = updateCellFunc,
        perNums = 2,
        offsetX =0,
        offsetY =0,
        widthGap = 4,
        heightGap = 4,
        itemRect = {x=0,y=-159.4, width = 410,height = 159.4},
        perFrame = 2,
    }
    self.panel_1.UI_1:setVisible(#_data_source<=0)
    self.panel_1.scroll_1:styleFill({_param})
end
--每组件更新函数
function PartnerCombineView:updateEveryItemView(_item,_view)
    local _partnerId = _item
    --图标
    local _partner_item = FuncPartner.getPartnerById(_partnerId)
    local _iconPath = FuncRes.iconHead(_partner_item.icon)
    _view.mc_2:showFrame(1)
    _view.mc_2.currentView.ctn_1:removeAllChildren()
    _view.mc_2.currentView.ctn_1:addChild(cc.Sprite:create(_iconPath))
    --初始星级
    _view.mc_dou:showFrame(_partner_item.initStar)
    --名字
    _view.txt_1:setString(GameConfig.getLanguage(_partner_item.name))
    --攻防辅
    _view.UI_dashen:showFrame(_partner_item.type)
    --实际碎片的数目
    local _real_frag = ItemsModel:getItemNumById(_partnerId)
    _view.txt_2:setString(GameConfig.getLanguage("partner_combine_frag_direct_1007"):format(_real_frag,_partner_item.tity))
    --是否可以打开强化
    if _real_frag>= _partner_item.tity then
        _view.mc_1:showFrame(1)
        _view.mc_1.currentView.btn_1:setTap(c_func(self.clickButtonCombinePartner,self,_item))
        --红点
        _view.panel_1:setVisible(true)
    else
        _view.mc_1:showFrame(2)
        _view.mc_1.currentView.btn_1:setTap(c_func(self.clickButtonGetSource,self,_item))
        _view.panel_1:setVisible(false)
    end
    _view.mc_2:setTouchedFunc(c_func(function()
        WindowControler:showWindow("PartnerInfoUI",_partnerId)
    end,self))
end
--碎片合成伙伴
function PartnerCombineView:clickButtonCombinePartner(_item)
    PartnerServer:partnerCombineRequest(_item,c_func(self.onCombineEvent,self,_item))
end
--点击碎片的来源
function PartnerCombineView:clickButtonGetSource(_item)
    WindowControler:showWindow("GetWayListView", _item);
end
--碎片合成反馈
function PartnerCombineView:onCombineEvent(_item,_event)
    if _event.result ~=nil then
        echo("----PartnerCombineView:onCombineEvent-----")
       -- WindowControler:showWindow("PartnerNewPartnerView",_item)
       WindowControler:showWindow("NewLotteryShowHeroUI",_item)
    end
end

function PartnerCombineView:onClose()
    self:startHide()
end
return PartnerCombineView
