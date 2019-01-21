--伙伴系统,仙魂
--2016-12-10 11:27:10
--Author:小花熊
local  PartnerSoulView = class("PartnerSoulView",UIBase)

function PartnerSoulView:ctor(_winName)
    PartnerSoulView.super.ctor(self,_winName)
    --当前选中仙魂的索引
    self._currentSoul = 1
    self._quality = 0
end

function PartnerSoulView:loadUIComplete()
    self:registerEvent();
end

function PartnerSoulView:registerEvent()
    PartnerSoulView.super.registerEvent(self);
    --监听仙魂变化
    EventControler:addEventListener(PartnerEvent.PARTNER_SOUL_CHANGE_EVENT,self.notifyPartnerSoulView,self)
end
--伙伴仙魂的信息发生了变化
function PartnerSoulView:notifyPartnerSoulView(_param)
    local _soulInfo = _param.params
    if not self._partnerInfo  or _soulInfo.id ~= self._partnerInfo.id then 
        return 
    end
 --   for _key,_value in pairs(_soulInfo.souls)do --键是字符串
        local _index = self._reverseSoul[_soulInfo.souls.id]
        local _newSoul = self._soulInfo[_index]
        _newSoul.exp = _soulInfo.souls.exp
        _newSoul.level = _soulInfo.souls.level
        self:updateSoulViewItem(self["panel_".._index],_newSoul,_index)
        if self._currentSoul == _index then
            self:onTouchSoulEvent(self["panel_".._index],_newSoul,_index)
        end
 --   end
    --战力重新计算
    local _ability = FuncPartner.getPartnerAvatar(self._partnerInfo)
    self.UI_number:setPower(_ability)
end
--设置伙伴信息
function PartnerSoulView:updateUIWithPartner(_partnerInfo)
    local _hasChanged=false
    if self._partnerInfo ==nil or self._partnerInfo.id ~= _partnerInfo.id then
        _hasChanged = true
    else--判断仙魂是否发生了变化,或者品质是否发生了变化
        if table.length(self._partnerInfo.souls) ~= table.length(_partnerInfo.souls) or self._quality ~= _partnerInfo.quality then
            _hasChanged = true
        else
            for _key,_value in pairs(_partnerInfo.souls)do--检测仙魂id是否发生了变,或者仙魂的等级
                local _nowSoul = _partnerInfo.souls[_key]
                local _oldSoul = self._partnerInfo.souls[_key]
                if not _oldSoul  or not _nowSoul    or _nowSoul.level ~= _oldSoul.level or _nowSoul.exp ~= _oldSoul.exp then
                    _hasChanged = true
                    break
                end
            end
        end
    end
    if not _hasChanged then   return end
    self._quality = _partnerInfo.quality
    self._partnerInfo = _partnerInfo
    local _ability = FuncPartner.getPartnerAvatar(self._partnerInfo)
    self.UI_number:setPower(_ability)
    --重新建立相关的信息
    self:buildSoulStatic()
    --刷新相关的UI
    for _index=1,4 do--逐个遍历组件
            self:updateSoulViewItem(self["panel_".._index],self._soulInfo[_index],_index)--这个目前应该是不正确的,现在只是为了测试
    end
    --设置默认的选中
    self:onTouchSoulEvent(self["panel_"..self._currentSoul],self._soulInfo[self._currentSoul],self._currentSoul)
end
--统计表格
function PartnerSoulView:buildSoulStatic()
    --获取所有的关于仙魂的数据
    local _soul_table = FuncPartner.getAllPartnerSouls();
    self._soulTable={}
    self._reverseTable={}--逆向查找表,记录所有的仙魂
    for _key,_value in pairs(_soul_table)do
        self._soulTable[_key] = _value
        table.insert(self._reverseTable,tonumber(_key))
    end
    --对逆向查找表进行排序
    local function _table_sort(a,b)
        return tonumber(a) < tonumber(b)
    end
    table.sort(self._reverseTable,_table_sort)
    --伙伴的品质,以及在这个品质之下,仙魂是否开启
    local _quality_table = FuncPartner.getPartnerQuality(self._partnerInfo.id);
    --计算当前的伙伴的下,可以开启的仙魂的id
    self._usefulQuality={}
    for _key,_value in pairs(_quality_table)do
        if(_value.soulId ~=nil)then
            self._usefulQuality[_value.soulId] = tonumber(_key)--仙魂与需要的品质
        end
    end
    self._quality_table = _quality_table
    --统计实际的仙魂信息
    self._soulInfo={}
    for _key,_value in pairs(self._partnerInfo.souls)do
        table.insert(self._soulInfo,_value)
    end
    local function _soul_sort(a,b)
        return a.id < b.id
    end
    table.sort(self._soulInfo,_soul_sort)--对仙魂排序
    self._reverseSoul={}--快速查找表
    for _index=1,#self._soulInfo  do
        self._reverseSoul[self._soulInfo[_index].id] = _index
    end
    --再加上没有开启的仙魂
    for _index=#self._soulInfo+1, 4 do
        table.insert(self._soulInfo ,{id = self._reverseTable[_index],level = nil}  )
        self._reverseSoul[self._soulInfo[_index].id] = _index
    end
end
--更新每一个绝技图标
function PartnerSoulView:updateSoulViewItem(_view,_item,_index)
    --绝技显示
    _view.mc_1:setVisible(_index==1)
    --当前绝技是否解锁了
    local _quality=self._usefulQuality[tonumber(_item.id)]
    --比较当前的伙伴的品质是否达到要求
    if  self._partnerInfo.quality<_quality then
        _view.panel_1:setVisible(true)
        self["txt_".._index]:setVisible(true)
        --设置所需要的品质颜色与品质数值
        self["txt_".._index]:setString(GameConfig.getLanguage("partner_soul_quality_open_1001"):format(FuncPartner.QualityToColor[_quality]))
        self["txt_skill".._index]:setVisible(false)
    else--否则开启
        _view.panel_1:setVisible(false)
        self["txt_".._index]:setVisible(false)
        self["txt_skill".._index]:setVisible(true)
        self["txt_skill".._index]:setString(GameConfig.getLanguage("natal_talent_level_1005"):format(_item.level))
    end
    --显示绝技
    _view.mc_1:showFrame(2)
    --图标
    local _soul_table =FuncPartner.getSoulInfo(_item.id)
    local _soul_item = _soul_table[tostring(_item.level or 1)]
    local _iconPath=FuncRes.iconSkill(_soul_item.icon);--没有开启的仙魂没有等级,但是还是可以有图标
    local _icon = cc.Sprite:create(_iconPath);
    _view.ctn_1:removeAllChildren()
    _view.ctn_1:addChild(_icon)
    --MC组件,是否要添加监听,或者已经达到圆满
    _view:setTouchedFunc(c_func(self.onTouchSoulEvent,self,_view,_item,_index))
end

--图标点击事件
function PartnerSoulView:onTouchSoulEvent(_view,_item,_index)
    --优化,减少不惜要的刷新
   -- if _index == self._currentSoul then  return   end
    --技能图标
    local _panel = self.panel_5
    _panel.ctn_1:removeAllChildren()
    local _quality_item = self._soulTable[tostring(_item.id)][tostring(_item.level or 1)]
    local _iconPath = FuncRes.iconSkill(_quality_item.icon)
    _panel.ctn_1:addChild(cc.Sprite:create(_iconPath))
    --名字
    _panel.txt_1:setString(GameConfig.getLanguage(_quality_item.name))
    --说明
    _panel.txt_3:setString(GameConfig.getLanguage(_quality_item.describe))
    --按钮或者满级显示
    --未开启
    if self._partnerInfo.quality < self._usefulQuality[tonumber(_item.id)] then
        _panel.txt_2:setVisible(false)--等级隐藏
        self.mc_1:showFrame(1)
        FilterTools.setGrayFilter(self.mc_1.currentView.btn_1)
        self.mc_1.currentView.btn_1:setTap(c_func(self.clickButtonLack,self))
    else
        _panel.txt_2:setString(GameConfig.getLanguage("natal_talent_level_1005"):format(_item.level or 1))--技能等级
        local _soul_table = FuncPartner.getSoulInfo(_item.id)
        --是否达到满级
        if( _item.level or 1) <table.length(_soul_table) then
            self.mc_1:showFrame(1)
            FilterTools.clearFilter(self.mc_1.currentView.btn_1)
            self.mc_1.currentView.btn_1:enabled(true)
            self.mc_1.currentView.btn_1:setTap(c_func(self.clickButtonLevelup,self,_item,_view,_index))
        else
            self.mc_1:showFrame(2)
        end
    end
    --设置当前选中的仙魂
    self._currentSoul = _index
end
--点击升级按钮
function PartnerSoulView:clickButtonLevelup(_item ,_view,_index)
    WindowControler:showWindow("PartnerSoulUpView",_item,self._partnerInfo.id)
end

function PartnerSoulView:clickButtonLack()
    WindowControler:showTips(GameConfig.getLanguage("partner_soul_quality_lack_1015"))
end
return PartnerSoulView
