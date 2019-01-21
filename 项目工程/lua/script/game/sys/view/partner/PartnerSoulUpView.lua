--仙魂升级
--2016年12月12日17:28:14
--Author:xiaohuaxiong
local PartnerSoulUpView = class("PartnerSoulUpView",UIBase)
--传入,仙魂的信息
--包括,伙伴id,仙魂id,仙魂等级,进度
--浮点数误差修正
local  Math_EPS = 0.000001
function PartnerSoulUpView:ctor(_winName,_soulInfo,_partnerId)
    PartnerSoulUpView.super.ctor(self,_winName)
    self._soulInfo = _soulInfo
    self._partnerId = _partnerId
    self._currentSoulItem = 0--当前选中的仙魂升级道具索引
end

function PartnerSoulUpView:loadUIComplete()
    self:registerEvent() 
    --滑块,建立抽象层
    self._buttonView = self.panel_1.panel_1.btn_1;
    --进度条的长度
    self._buttonView.progressLength = self.panel_1.panel_1.progress_1:getContainerBox().width
    --记录进度条上面的按钮的原始位置
    self._buttonView.originX = self._buttonView:getPositionX()
    --按钮的宽度
    local _size = self._buttonView:getContainerBox()
    self._buttonView.realWidth = _size.width
    self._buttonView.realHeight = _size.height
    --以上数据会在进度条按钮拖动的时候使用
    local _touchEvent = cc.EventListenerTouchOneByOne:create()--这个数据需要在UI关闭的时候销毁
    _touchEvent:registerScriptHandler(c_func(self.onTouchBegan,self,self._buttonView),cc.Handler.EVENT_TOUCH_BEGAN)
    _touchEvent:registerScriptHandler(c_func(self.onTouchMoved,self,self._buttonView),cc.Handler.EVENT_TOUCH_MOVED)
    _touchEvent:registerScriptHandler(c_func(self.onTouchEnded,self,self._buttonView),cc.Handler.EVENT_TOUCH_ENDED)
    _touchEvent:setSwallowTouches(true)
    self._buttonView:getEventDispatcher():addEventListenerWithFixedPriority(_touchEvent,2)
    self._buttonViewListener = _touchEvent
    --当前滑块的相对位置
    self._buttonView.offsetX =0
    --是否禁止滑块滑动
    self._buttonView.enable = true
    self:buildLevelupExp()
    self:updateSoul()
    --刷新子UI
    self:updateItemView()
    self.panel_1.btn_zsqh:enabled(false)
    FilterTools.setGrayFilter(self.panel_1.btn_zsqh)
end
--刷新每个道具
function PartnerSoulUpView:updateItemView()
    for _index=1,4 do
        local _childView = self["UI_".._index]
        _childView:setSoulInfo(self._soulItems[_index])
        --设置监听器
        _childView:addTouchListener( c_func(self.updateProgressPanel,self,self._soulItems[_index],_index) )
        _childView:updateSoulItemView()
    end
    --主动刷新
    self:updateProgressPanel(self._soulItems[1],1)
end
--自定义事件
function PartnerSoulUpView:onTouchBegan(_buttonView,_touch,_event)
    local _point = _touch:getLocation()
    local _point2 =_buttonView:convertToNodeSpace(_point)
--    local _point3 =_buttonView:convertToWorldSpace(cc.p(0,0))
--    local _point4 = _buttonView:convertToWorldSpace(cc.p(_buttonView.realWidth,-_buttonView.realHeight))
    _buttonView.offsetX = _point.x
    local  y=-_point2.y
    return _buttonView.enable  and _point2.x>=0 and _point2.x<=_buttonView.realWidth and y>=0 and y<=_buttonView.realHeight--这个返回值决定按钮是否响应滑动事件
end
function PartnerSoulUpView:onTouchMoved(_buttonView,_touch,_event)
    local nowView = _buttonView
    local offsetX = _touch:getLocation().x
    --判断是否超过了边界
    local _realWidth = offsetX - nowView.offsetX
    local nowPositionX = nowView:getPositionX()
    local _realProgressWidth = nowView.progressLength - nowView.realWidth/2
    if nowPositionX+_realWidth<nowView.originX then--左边界
        _realWidth = nowView.originX - nowPositionX
    elseif nowPositionX + _realWidth>nowView.originX +_realProgressWidth  then--右边界
        _realWidth = nowView.originX + _realProgressWidth - nowPositionX
    end
    --修正坐标
    local _realPositionX = nowView:getPositionX()+_realWidth
    nowView:setPositionX(_realPositionX)
    nowView.offsetX =_realWidth + nowView.offsetX
    --设置进度条
    local _percent = (_realPositionX - nowView.originX)/_realProgressWidth
    self.panel_1.panel_1.progress_1:setPercent(_percent*100)
    --分发事件
    if self._slider_listener_func then
        self._slider_listener_func(_percent)--输出滑块在当前的进度条所占据的比例
    end
end
function PartnerSoulUpView:onTouchEnded(_buttonView,_touch,_event)
    local nowView = _buttonView
    --还原
    nowView.offsetX =0
end
--统计数值,从第一级到最高级所需要的经验
function PartnerSoulUpView:buildLevelupExp()
    local _upSoulExp={}
    --数值分为两层,,第一层为从这个级别升到下一级别所需要的经验,第二层为从这个级别升到满级所需要的经验
    local _soul_item = FuncPartner.getSoulInfo(self._soulInfo.id)
    local _soul_length = table.length(_soul_item)
    for _index = _soul_length,1,-1 do
        local _upSoulItem ={}
        _upSoulItem[1] = _soul_item[tostring(_index)].exp or 0
        if #_upSoulExp>0 then
            _upSoulItem[2] = _upSoulExp[1][2] + _upSoulItem[1] --将上一个的经验消耗累加
        else
            _upSoulItem[2] = _upSoulItem[1] --总经验消耗就是升到满级的消耗
        end
        table.insert(_upSoulExp,1,_upSoulItem)
    end
    self._upSoulExp = _upSoulExp
    --升级道具
    local _soulItems={}
    for _index=1,#FuncPartner.SoulItemId do
        local _soulItem={}
        _soulItem.id = FuncPartner.SoulItemId[_index]
        table.insert(_soulItems,_soulItem)
    end
    self._soulItems= _soulItems
end
--注册滑块监听事件
function PartnerSoulUpView:registerSliderChangedListener( _func)
    self._slider_listener_func = _func
end
--更新上方的指示进度条
function PartnerSoulUpView:updateDirectProgress(_percent)
    local _item_item = FuncItem.getItemData(self._soulItems[self._currentSoulItem].id)
    local _item_count = ItemsModel:getItemNumById(self._soulItems[self._currentSoulItem].id)
    local _incExp = number.roundfloor(_percent * _item_count) * tonumber(_item_item.useEffect)
    --向上遍历最大值
    local _right_index = self._soulInfo.level
    local _origin_level = self._soulInfo.level
    local _total_exp = _incExp + self._soulInfo.exp
    local _exp_left = _total_exp
    for _index=self._soulInfo.level +1,#self._upSoulExp do
        if _total_exp > self._upSoulExp[_origin_level][2] - self._upSoulExp[_index][2] then --判断从这个级别升到下一个级别
            _right_index = _index ;
            _exp_left = _total_exp - (self._upSoulExp[_origin_level][2] - self._upSoulExp[_index][2] )
        end
    end
    _right_index = _right_index>#self._upSoulExp and #self._upSoulExp or _right_index
    --如果已经达到尽头
    if _right_index>= #self._upSoulExp and _total_exp>= self._upSoulExp[_origin_level][2] then
        self.txt_2:setString(GameConfig.getLanguage("natal_talent_level_1005"):format(_right_index))--设置满级
        self.panel_blue.progress_2:setPercent(100)
        self.panel_blue.txt_1:setString( GameConfig.getLanguage("partner_soul_up_max_1002"))--self._upSoulExp[_right_index][1].."/"..self._upSoulExp[_right_index][1])
        return
    end
    --取余
    local _remindExp = _exp_left % self._upSoulExp[_right_index][1]--(self._soulInfo.exp + _incExp)%self._upSoulExp[_right_index][1]
    if _exp_left  <= self._upSoulExp[_right_index][1]then
        _remindExp = _exp_left
    end
    --计算进度条的进度
    self.panel_blue.progress_2:setPercent(_remindExp/self._upSoulExp[_right_index][1]*100)
    --更新进度指示上面的标签
    self.panel_blue.txt_1:setString(_remindExp.."/"..self._upSoulExp[_right_index][1])
    --级别指示
    self.txt_2:setString(GameConfig.getLanguage("natal_talent_level_1005"):format(_right_index))
end
--设置滑块在进度条上所占据的比例
function PartnerSoulUpView:setSliderPercent(_percent)
    assert(_percent>=0.0 and _percent<=1.0)
    local _realWidth = (self._buttonView.progressLength - self._buttonView.realWidth/2)*_percent
    self._buttonView:setPositionX(self._buttonView.originX + _realWidth)
    self.panel_1.panel_1.progress_1:setPercent(_percent*100)
    --最上方的指示进度条也会跟着变动
    self:updateDirectProgress(_percent)
end
--获取滑块当前的百分比
function PartnerSoulUpView:getSliderPercent()
    local _width = self._buttonView:getPositionX() - self._buttonView.originX
    local _percent = _width / (self._buttonView.progressLength - self._buttonView.realWidth/2)
    if _percent>1 then _percent=1 
    elseif _percent<0 then _percent=0 end
    return _percent
end
--升级后事件监听
function PartnerSoulUpView:getMaxReachLevel(_item,_percent)
    
end
--设置滑块的可用状态
function PartnerSoulUpView:setSliderEnabled(_enable)
    self._buttonView.enable = _enable
end
function PartnerSoulUpView:registerEvent()
    PartnerSoulUpView.super.registerEvent(self)
    self.btn_1:setTap(c_func(self.onClose,self))
    --添加事件监听,道具的变化,仙魂发生了变化
    EventControler:addEventListener(PartnerEvent.PARTNER_SOUL_CHANGE_EVENT,self.notifySoulChange,self)
end
--监听仙魂变化
function PartnerSoulUpView:notifySoulChange(_param)
    local _soul = _param.params
    if self._partnerId ~= _soul.id or self._soulInfo.id ~= _soul.souls.id then--伙伴id相同,仙魂id相同才能引起UI刷新
        return
    end
    local _newSoul = self._soulInfo
    _newSoul.level = _soul.souls.level
    _newSoul.exp = _soul.souls.exp
    self:updateSoul()
end
--
function PartnerSoulUpView:updateSoul()
    --技能图标
    local _soul_table = FuncPartner.getSoulInfo(self._soulInfo.id)
    local _soul_item = _soul_table[tostring(self._soulInfo.level or 1)];
    local _iconPath = FuncRes.iconSkill(_soul_item.icon)
    self.ctn_1:removeAllChildren()
    local _iconSprite = cc.Sprite:create(_iconPath)
    self.ctn_1:addChild(_iconSprite)
    --名字
    self.txt_1:setString(GameConfig.getLanguage(_soul_item.name))
    --级别
    self.txt_2:setString(tostring(self._soulInfo.level or 1))
    --经验,所占据的百分比
    if self._soulInfo.level >= table.length(_soul_table) then
        self.panel_blue.txt_1:setString( GameConfig.getLanguage("partner_soul_up_max_1002"))
        self.panel_blue.progress_1:setPercent(100)
    else
        self.panel_blue.txt_1:setString( (self._soulInfo.exp or 0).."/".._soul_item.exp) 
        self.panel_blue.progress_1:setPercent((self._soulInfo.exp or 0)/_soul_item.exp*100)
    end
end
--更新右侧的面板上的信息
function PartnerSoulUpView:updateProgressPanel(_item, _index,_flag)
    --优化,减少不必要的刷新
    if not _flag and _index == self._currentSoulItem then return end
    self._currentSoulItem = _index
    --道具的名字
    local _item_item = FuncItem.getItemData(_item.id)
    self.panel_1.txt_1:setString(GameConfig.getLanguage(_item_item.name))
    --如果道具的数目为0
    local _item_count = ItemsModel:getItemNumById(_item.id)
    self.panel_1.mc_qory:showFrame(1)
    if _item_count <=0 then
        self.panel_1.txt_3:setString("0")--可供添加的经验
        self.panel_1.txt_5:setString("0/0") --已经添加的经验
        --禁止操作进度条,以及相关的按钮
        self:setSliderEnabled(false)
        self:setSliderPercent(0)
        --解除滑块的回调函数
        self:registerSliderChangedListener(nil)
        --灰化另外两个按钮
      --  FilterTools.setGrayFilter(self.panel_1.btn_zsqh)
        FilterTools.setGrayFilter(self.panel_1.btn_qh)
      --  self.panel_1.btn_zsqh:enabled(false)
       -- self.panel_1.mc_qory.currentView.btn_qh:enabled(false)
        --灰化增加/减少按钮
        FilterTools.setGrayFilter(self.panel_1.btn_jian)
        FilterTools.setGrayFilter(self.panel_1.btn_jia)
        self.panel_1.btn_jian:enabled(false)
        self.panel_1.btn_jia:enabled(false)
        self.panel_1.mc_qory.currentView.btn_qh:setTap(c_func(self.clickButtonNoItem,self))
    else
        local _item_data = FuncItem.getItemData(_item.id)--获取道具的详细信息
        self.panel_1.txt_3:setString(_item_data.useEffect) --单个道具可提供的经验
        self.panel_1.txt_5:setString("0/".._item_count)      --目前已经选中的道具数目/道具的总数目
        self:setSliderPercent(0)--将滑块移动到最左边
        self:setSliderEnabled(true)--开启滑块功能
        self:registerSliderChangedListener(c_func(self.sliderChangeEvent,self,_item))--注册滑块滑动监听器
        --减少道具
        self.panel_1.btn_jian:enabled(true)
        FilterTools.clearFilter(self.panel_1.btn_jian)
        self.panel_1.btn_jian:setTap(c_func(self.clickButtonDecreaseItem,self,_item))
        --增加道具
        self.panel_1.btn_jia:enabled(true)
        FilterTools.clearFilter(self.panel_1.btn_jia)
        self.panel_1.btn_jia:setTap(c_func(self.clickButtonIncreaseItem,self,_item))
        --注册道具强化仙魂事件
        self.panel_1.mc_qory.currentView.btn_qh:enabled(true)
        FilterTools.clearFilter(self.panel_1.mc_qory.currentView.btn_qh)
        self.panel_1.mc_qory.currentView.btn_qh:setTap(c_func(self.clickButtonStrength,self,_item,_index))
    end
    --最上面的进度条指示
    self:updateDirectProgress(0)
    --将最上面的进度指示设置为当前实际的进度
    self.panel_blue.txt_1:setString(self._soulInfo.exp.."/"..self._upSoulExp[self._soulInfo.level][1])
    --如果当前仙魂已经达到最大等级
    local _soul_item = FuncPartner.getSoulInfo(self._soulInfo.id)
    if self._soulInfo.level >= table.length(_soul_item) then
        --所有按钮禁止,并且灰化
        self.panel_1.mc_qory:showFrame(2)
        self.panel_1.btn_jia:enabled(false)
        self.panel_1.btn_jian:enabled(false)
       -- FilterTools.setGrayFilter(self.panel_1.btn_qh)
        FilterTools.setGrayFilter(self.panel_1.btn_jia)
        FilterTools.setGrayFilter(self.panel_1.btn_jian)
        --上侧的进度条标签提示
        self.panel_blue.txt_1:setString(GameConfig.getLanguage("partner_soul_up_max_1002"))
    end
    --当前级别指示
    self.txt_2:setString(GameConfig.getLanguage("natal_talent_level_1005"):format(self._soulInfo.level))
    --钻石强化
 --   self.panel_1.btn_zsqh:setTap(c_func(self.clickButtonStrengthByDiamond,self))
end
--滑块滑动事件
function PartnerSoulUpView:sliderChangeEvent(_item,_percent)
    --道具的总数目
    local _item_count = ItemsModel:getItemNumById(_item.id)
    local _item_item =FuncItem.getItemData(_item.id)
    --根据目前的百分比推断这个数值是否合法
    local _every_cost = tonumber(_item_item.useEffect) --每一个道具的消耗
    local _total_cost = self._upSoulExp[self._soulInfo.level][2]
    --计算升到满级所需要的道具的上确界
    local _max_item_count = number.roundceil((_total_cost - self._soulInfo.exp)/_every_cost)
    local _max_percent = _max_item_count/_item_count
    local _newPercent = _percent<=_max_percent and _percent or _max_percent
    local _select_count = number.roundfloor(_newPercent * _item_count)
    --设置字符串
    self.panel_1.txt_5:setString(_select_count.."/".._item_count)
    --其他事件
    self:updateDirectProgress(_percent)
    if _percent ~= _newPercent then
        self:setSliderPercent(_newPercent)
    end
end
--减少道具
function PartnerSoulUpView:clickButtonDecreaseItem(_item)
    local _nowPercent = self:getSliderPercent()
    local _item_count = ItemsModel:getItemNumById(_item.id)
    --向下取整,此时道具的数目必定大于0,优先使用百分比
    local _real_count = _nowPercent * _item_count
    local _fractValue = number.fract(_real_count)
    local _newPercent = _fractValue>0 and number.precisefloat(_real_count -_fractValue)/_item_count or  (_real_count - 1)/_item_count
    --截断  
    _newPercent = _newPercent>=0 and _newPercent or 0
    self:setSliderPercent(_newPercent)
    --设置数目
    self.panel_1.txt_5:setString(  number.precisefloat( _newPercent * _item_count) .."/".._item_count)
end
--增加道具
function PartnerSoulUpView:clickButtonIncreaseItem(_item)
    local _nowPercent =self:getSliderPercent()
    local _item_count = ItemsModel:getItemNumById(_item.id)
    --首次截断
    local _item_item = FuncItem.getItemData(_item.id)
    local _real_count = _nowPercent * _item_count
    local _fractValue = number.fract(_real_count)
    local _newPercent =_fractValue>0 and number.precisefloat( _real_count +1 -_fractValue)/_item_count or (_real_count +1)/_item_count
    _newPercent = _newPercent<=1 and _newPercent or 1

    --根据目前的百分比推断这个数值是否合法
    local _every_cost = tonumber(_item_item.useEffect) --每一个道具的消耗
    local _total_cost = self._upSoulExp[self._soulInfo.level][2]
    --计算升到满级所需要的道具的上确界
    local _max_item_count = number.roundceil((_total_cost - self._soulInfo.exp)/_every_cost)
    local _max_percent = _max_item_count/_item_count
    --总体向上取整
    _newPercent = _newPercent<=_max_percent and _newPercent or _max_percent

    self:setSliderPercent(_newPercent)
    --设置数目
    self.panel_1.txt_5:setString(  number.precisefloat(_newPercent*_item_count) .."/".._item_count)
end
function PartnerSoulUpView:onClose()
    self:startHide()
end
function PartnerSoulUpView:deleteMe()
    self._buttonView:getEventDispatcher():removeEventListener(self._buttonViewListener);
    PartnerSoulUpView.super.deleteMe(self)
end
--没有道具时的弹出提示
function PartnerSoulUpView:clickButtonNoItem()
    WindowControler:showTips(GameConfig.getLanguage("partner_soul_no_items_1017"))
end
--进度条事件
function PartnerSoulUpView:onProgressEvent(_percent,_total_exp)--输入百分比,以及增加的经验

end
--道具强化
function PartnerSoulUpView:clickButtonStrength(_item,_index)
    if not _item then
        WindowControler:showTips(GameConfig.getLanguage("partner_soul_no_item_1005"))
        return
    end
    --获取进度条百分比
    local _percent = self:getSliderPercent()
    --道具
    local _item_item = FuncItem.getItemData(_item.id)
    local _item_count  = ItemsModel:getItemNumById(_item.id)
    --取下界
    local _new_count = _percent * _item_count
    local _real_count = number.roundoff(_new_count)
    --如果没有选中道具
    if _real_count <=0 then
        WindowControler:showTips(GameConfig.getLanguage("partner_soul_no_item_1005"))
        return
    end
    --填写数据
    local _item_param={}
    _item_param[_item.id] = _real_count
    local _param={
        partnerId = self._partnerId,
        soulId = self._soulInfo.id,
        items = _item_param,
    }
    --发送协议
    PartnerServer:soulLevelupRequest(_param,c_func(self.onSoulStrengthEvent,self,_item))
end
--仙魂强化回复
function PartnerSoulUpView:onSoulStrengthEvent(_item,_event)
    if _event.result ~=nil then
        echo("-------PartnerSoulUpView:onSoulStrengthEvent---------------")
        self:setSliderPercent(0)
        self:sliderChangeEvent(_item,0)
        --判断级别
        local _soul_table = FuncPartner.getSoulInfo(self._soulInfo.id)
        if self._soulInfo.level >= table.length(_soul_table)then--已经达到最高级别,同时禁止所有的按钮
            self.panel_1.mc_qory:showFrame(2)
            self:setSliderEnabled(false)
            self.panel_1.btn_jia:enabled(false)
            self.panel_1.btn_jian:enabled(false)
            FilterTools.setGrayFilter(self.panel_1.btn_jia)
            FilterTools.setGrayFilter(self.panel_1.btn_jian)
        end
    end
end
--钻石强化
function PartnerSoulUpView:clickButtonStrengthByDiamond(_item,_index)

end
return PartnerSoulUpView