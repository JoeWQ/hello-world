--伙伴系统技能UI
--2016-12-9 10:32:22
--Author:xiaohuaxiong

local PartnerSkillView = class("PartnerSkillView" ,UIBase)

function PartnerSkillView:ctor(_winName)
    PartnerSkillView.super.ctor(self,_winName)
    --记录该技能页面所对应的伙伴
    self._partnerInfo = nil
    --伙伴的技能,这个映射是对self._partnerInfo.skill数据的统计
    self._skillValue={}
    --数据与组件之间的映射
    self._childView={}
    --满级的技能点数目,目前暂时定为20,后面这个值的上限将会跟VIP挂钩
    self._maxSkillPoint =20
    self._textColor = cc.c3b(0xAD,0x73,0x42)
    --每隔0.5秒刷新一次
    self._maxRefreshTime =0.5
    self._nowRefreshTime =0
end

function PartnerSkillView:loadUIComplete()
    self:registerEvent()
    --技能点上限
    local _newVIP = UserModel:vip() 
    self._maxSkillPoint = FuncCommon.getVipPropByKey(_newVIP,"partnerSkillMax")
    self:scheduleUpdateWithPriorityLua(c_func(self.updateFuncCall,self),0)
end

function PartnerSkillView:registerEvent()
    PartnerSkillView.super.registerEvent(self)
    --注册事件监听,伙伴的信息发生了变化
    EventControler:addEventListener(PartnerEvent.PARTNER_SKILL_CHANGED_EVENT,self.notifyPartnerSkillChanged,self)
    --铜钱发生了变化
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE,self.notifyCoinChange,self);
    --星级变化
    --EventControler:addEventListener(PartnerEvent.PARTNER_LEVELUP_EVENT,self.notifyPartnerSkillChanged)
    --技能点变化
    EventControler:addEventListener(PartnerEvent.PARTNER_SKILL_POINT_CHANGED,self.notifySkillPointChanged,self)
    --VIP变化
    EventControler:addEventListener(UserEvent.USEREVENT_VIP_CHANGE,self.notifyVIPChanged,self)
end
--VIP变化
function PartnerSkillView:notifyVIPChanged(_param)
    --重新计算技能点上限
    local _newVIP = UserModel:vip()
    self._maxSkillPoint = FuncCommon.getVipPropByKey(_newVIP,"partnerSkillMax")
end
--监听铜钱发生变化
function PartnerSkillView:notifyCoinChange( _param)
 --   local _partnerInfo = _param.params;
    if not self._partnerInfo  then 
        return
    end
    local   _coinNum =UserModel:getCoin();
    for _key,_value in pairs(self._childView) do
        --获取关于该技能的信息
 --       local  _skillInfo = FuncPartner.getSkillInfo(_key)
        local  _view = _value
        --必须是已经开启的
        if self._skillValue[_key] ~= nil then
            self:updateItemViewOnlyFont(_key,_view)
        end
    end
end
--监听函数,监听伙伴的技能信息
function PartnerSkillView:notifyPartnerSkillChanged( _param)
--如果还没有伙伴,或者伙伴的id与当前的伙伴不是同一个直接返回
    local   _skillsInfo = _param.params;
    if(not self._partnerInfo or _skillsInfo.id ~=self._partnerInfo.id)then
        return
    end
--否则开始检索
   -- for _key,_value in pairs(_skillsInfo.skills) do
        local _skill_item = tostring(_skillsInfo.skills.id)
        local _view = self._childView[_skill_item]
        --更新数据
        self._skillValue[_skill_item] = _skillsInfo.skills.level
        self:updateViewItem( _skill_item,_view)
--    end
   local _ability = FuncPartner.getPartnerAvatar(self._partnerInfo)
   self.panel_5.UI_number:setPower(_ability)
end
--监听技能点变化
function PartnerSkillView:notifySkillPointChanged(_param)
    local _skillPoint = _param.params
    self.panel_5.txt_4:setString(tostring(_skillPoint))
    --是否已经达到满级
--    if _skillPoint >= self._maxSkillPoint then
--        self.panel_5.txt_5:setVisible(true)
--    else
--        self.panel_5.txt_5:setVisible(false)
--    end
end
--伙伴信息
function PartnerSkillView:setPartnerInfo( _partnerInfo)
    local   _partner_table_item = FuncPartner.getPartnerById(_partnerInfo.id)
    --伙伴名字
    self.panel_5.txt_1:setString(GameConfig.getLanguage(_partner_table_item.name).."  "..GameConfig.getLanguage("natal_talent_level_1005"):format(_partnerInfo.level))
    --等级
--    self.panel_5.txt_2:setString(GameConfig.getLanguage("natal_talent_level_1005"):format(_partnerInfo.level))
    --战力
 --       local _attr = FuncPartner.getPartnerAttr(self._partnerInfo)
    local _ability = FuncPartner.getPartnerAvatar(self._partnerInfo)
    self.panel_5.UI_number:setPower(_ability)
    --技能点数
    local _skillPoint=UserExtModel:getPartnerSkillPoint();
    self.panel_5.txt_4:setString(tostring(_skillPoint))
    --是否已经达到满级
--    if _skillPoint >= self._maxSkillPoint then
--        self.panel_5.txt_5:setVisible(true)
--    else
--        self.panel_5.txt_5:setVisible(false)
--    end
end
--update call function 
function PartnerSkillView:updateFuncCall(deltaTime)
    self._nowRefreshTime = self._nowRefreshTime +deltaTime
    if self._nowRefreshTime< self._maxRefreshTime then
        return
    end
    if not self._partnerInfo then
        return
    end
    --如果已经达到了最高级
    local _nowSkillPoint = UserExtModel:getPartnerSkillPoint()
    if _nowSkillPoint >= self._maxSkillPoint then
        self.panel_5.txt_5:setString(GameConfig.getLanguage("partner_skill_point_full_1009"))
    else
        local leftTime = UserExtModel:getSkillPointResumeTime()
        local hour = math.floor(leftTime/60)
        local second = math.floor(leftTime%60)
        if hour>0 then
            self.panel_5.txt_5:setString(GameConfig.getLanguage("partner_skill_point_time_left_1010"):format(hour,second))
        else
            self.panel_5.txt_5:setString(GameConfig.getLanguage("partner_skill_point_time_left_1012"):format(second))
        end
    end
end
--必须实现的函数,以供 PartnerView.lua统一调用
function PartnerSkillView:updateUIWithPartner( _partnerInfo)
--只有在必要的时候才会刷新
      local  _hasChanged=false
      if(not self._partnerInfo or self._partnerInfo.id ~= _partnerInfo.id)then--如果原来没有目标伙伴
          self._partnerInfo = _partnerInfo;
          _hasChanged=true
      else --否则开始计算两者之间的差异
        for _key,_value in pairs(_partnerInfo.skills)do
            if(self._partnerInfo.skills[_key] ~= _value )then
                _hasChanged = true
                 break;
            end
        end
        self._partnerInfo = _partnerInfo
      end
    self:setPartnerInfo(_partnerInfo)
--如果没有发生任何的变化,则直接返回
    if not _hasChanged then
        return
    end
    --星级与技能的关系统计
    local _starSkillCondition={}
    local _starInfos = FuncPartner.getStarsByPartnerId(self._partnerInfo.id)
    for _key,_value in pairs(_starInfos) do
        if _value.skillId ~= nil then
            _starSkillCondition[_value.skillId] = tonumber(_key) --键为字符串,值为int32
        end
    end
    self._starSkillCondition = _starSkillCondition
--否则,开始进行UI的更新
    self._scrollView = self.panel_5.scroll_1
    self._panelTemp = self.panel_5.panel_1 --模板panel
--创建单元格函数,更新单元格函数
    local  function createFunc(_item,_index)
          local _view = UIBaseDef:cloneOneView(self._panelTemp)
          self:updateViewItem(_item,_view,_index)
          self._childView[_item] = _view
          return _view
    end
    --update func
    local function updateFunc(_item,_view)
          self:updateViewItem(_item,_view)
    end

    self._panelTemp:setVisible(false)
    --获取所有的技能信息
    local _partnerInfo = FuncPartner.getPartnerById(self._partnerInfo.id)
    local _skillInfos = _partnerInfo.skill
    local _excludeSkill = {}--需要加以排除的技能
    --建立统计模型,统计伙伴的技能Id
    self._skillValue={}
    local  _dataSource={}
    for _key,_value in pairs(self._partnerInfo.skills) do
         self._skillValue[_key] = _value
         table.insert(_dataSource,_key)
         _excludeSkill[_key] = true
    end
    --追加没有开启的技能数据
    for _key,_value in pairs(_skillInfos) do
        if not  _excludeSkill[_value] then
            table.insert(_dataSource,_value)
        end
    end
    --建立新的数据结构
    local    param = {
            data = _dataSource,
            createFunc = createFunc,
            updateFunc = updateFunc,
            perNums =2,
            offsetX = 0,
            offsetY =  0,
            widthGap = 4,
            heightGap =4,
            itemRect = {x =0,y = -94.25,width = 356,height = 94.25},
            perFrame =2,
    }
    self._scrollView:styleFill({param})
--
end
--更新单元格,注意item是一个数值,表示技能的Id
function PartnerSkillView:updateViewItem(_item,_view,_index )
    local _skillId = _item
--技能的等级
    local  _skillLevel = self._skillValue[_skillId];
    local  _close_tag = false
    --如果没有查找到等级,就说明这个技能还没有开启
    if not _skillLevel then
        _view.panel_xian.panel_1:setVisible(true)
        _close_tag = true
        _skillLevel = 1 --没有开启就设定为1级
    else
        _view.panel_xian.panel_1:setVisible(false)
    end
--获取关于该技能的基本信息
    local  _skillInfo = FuncPartner.getSkillInfo(_skillId)
    local  _skillInfo2 = FuncPartner.getSkillCostInfo(_skillInfo.quality)
    local  _skillCost = _skillInfo2[tostring(_skillLevel)]

    _view.txt_2:setString(GameConfig.getLanguage("natal_talent_level_1005"):format(_skillLevel)) --level
    _view.panel_xian.ctn_1:removeAllChildren();
    if _index ~=nil then
        _view.panel_xian.mc_1:setVisible(_index==1 or _index==2)
    end
--技能图标
    local  _iconPath = FuncRes.iconSkill(_skillInfo.icon)
    local  _iconSprite = cc.Sprite:create(_iconPath)
    _view.panel_xian.ctn_1:addChild(_iconSprite)
--技能名称
    _view.txt_1:setString(GameConfig.getLanguage(_skillInfo.name))
--消耗铜钱的数目,如果开启了
    if not _close_tag then
        _view.mc_tongqian:showFrame(1)
        _view.mc_tongqian.currentView.txt_3:setString(tostring(_skillCost.coin))
    else
        _view.mc_tongqian:showFrame(2)
        _view.mc_tongqian.currentView.txt_3:setString(GameConfig.getLanguage("partner_skill_open_lock_1006"):format(self._starSkillCondition[_skillId]))
    end
    --按钮是否可用,与可用的铜钱的数目挂钩
    local   _coinNum =UserModel:getCoin();
    _view.mc_tongqian:setVisible(true)
    _view.mc_jia:setVisible(true)
    --没有开启
    if _close_tag then
--        _view.mc_jia:showFrame(1)
--        _view.mc_jia.currentView.btn_1:enabled(false)
--        FilterTools.setGrayFilter(_view.mc_jia.currentView.btn_1)
        _view.mc_jia:setVisible(false)
    elseif(  _skillLevel>= table.length(_skillInfo2)  )then--最高级
        --按钮置换成第二帧
        _view.mc_jia:showFrame(2)
        _view.mc_tongqian:setVisible(false)
    elseif _coinNum<_skillCost.coin then --铜钱不足
        _view.mc_jia:showFrame(1)
       -- _view.mc_jia.currentView.btn_1:enabled(false)
        FilterTools.setGrayFilter(_view.mc_jia.currentView.btn_1)
        _view.mc_tongqian.currentView.txt_3:setColor(FuncCommUI.COLORS.TEXT_RED)--红色
        _view.mc_jia.currentView.btn_1:setTap(c_func(self.clickButtonSkillLevelup,self,_skillId))  
    else
        _view.mc_jia:showFrame(1)
        _view.mc_jia.currentView.btn_1:enabled(true)
        FilterTools.clearFilter( _view.mc_jia.currentView.btn_1)
        --给按钮注册事件
        _view.mc_jia.currentView.btn_1:setTap(c_func(self.clickButtonSkillLevelup,self,_skillId))  
        _view.mc_tongqian.currentView.txt_3:setColor(self._textColor)
    end
    _view.panel_xian:setTouchedFunc(c_func(self.onTouchSkillView,self,_skillId,_view))
end
--只更新字体颜色
function PartnerSkillView:updateItemViewOnlyFont(_item,_view)
    local _skillId = _item
--技能的等级,不会为空
    local  _skillLevel = self._skillValue[_skillId];
--获取关于该技能的信息
    local  _skillInfo = FuncPartner.getSkillInfo(_skillId)
    local  _skillInfo2 = FuncPartner.getSkillCostInfo(_skillInfo.quality)
    local  _skillCost = _skillInfo2[tostring(_skillLevel)]

    --铜钱消耗
    local   _coinNum =UserModel:getCoin();
    --没有达到满级
    if _skillLevel <  table.length(_skillInfo2) then
        if _coinNum<_skillCost.coin then --铜钱不足
            _view.mc_tongqian.currentView.txt_3:setColor(FuncCommUI.COLORS.TEXT_RED)--红色
            _view.mc_jia.currentView.btn_1:enabled(false)
            FilterTools.setGrayFilter(_view.mc_jia.currentView.btn_1)
        else
            _view.mc_tongqian.currentView.txt_3:setColor(self._textColor)
            _view.mc_jia.currentView.btn_1:enabled(true)
            FilterTools.clearFilter(_view.mc_jia.currentView.btn_1)
        end
    end
end
--按钮点击事件
function PartnerSkillView:clickButtonSkillLevelup(_skillId)
    local  _param={
        partnerId = self._partnerInfo.id,
        skillId = _skillId,
        level = 1,--将要增加的级别,比如如果从3级升到7级,这个数值就置成4
    }
    local _skill_item = FuncPartner.getSkillInfo(_skillId)
    local _skill_info = FuncPartner.getSkillCostInfo(_skill_item.quality)
    --是否已经达到满级
    if self._skillValue[_skillId] >= table.length(_skill_info) then
        WindowControler:showTips(GameConfig.getLanguage("partner_skill_reach_max_1004"))
        return
    end
    --约束判断
    if self._skillValue[_skillId] >= self._partnerInfo.level then --等级约束
        WindowControler:showTips(GameConfig.getLanguage("partner_skill_level_limit_1003"))
        return
    end
    local _skillCost = _skill_info[tostring(self._skillValue[_skillId])]
    if  UserModel:getCoin()<_skillCost.coin then --铜钱不足
        WindowControler:showTips(GameConfig.getLanguage("tid_common_1016"))
        return
    end
    --技能点不足
    if UserExtModel:getPartnerSkillPoint() <= 0 then
        WindowControler:showWindow("PartnerSkillPointView")
        return
    end
    self._nowSkillId = _skillId
    PartnerServer:skillLevelupRequest(_param,c_func(self.onSkillLevelupCallback,self,_skillId))
end
--技能升级回调
function PartnerSkillView:onSkillLevelupCallback(_skillId,_event)
    if(_event.result ~=nil )then
        --数目增加
        --self:onUIRefresh(  _skillId )
        echo("-----Partner Skill Levelup Success------")
    elseif _event.error.message=="partner_skill_not_enough" then
        WindowControler:showTips(GameConfig.getLanguage("partner_skill_point_less_1008"))
    end
end
--技能升级之后的UI刷新与特效回放
--目前UI刷新已经在监听函数里面做了,这里只需要做特效的播放就行了
function PartnerSkillView:onUIRefresh(   _skillId   )
    local _view = self._childView[_skillId]
    --增加级别
    self._skillValue[_skillId] = self._skillValue[_skillId] +1
    self:updateViewItem(_skillId , _view) 
end

function PartnerSkillView:onTouchSkillView( _skillId,_view)
    --获取组件的位置
    local _rect = _view.panel_xian:getContainerBox()
    _rect.width = _rect.width * _view.panel_xian:getScaleX()
    _rect.height = _rect.height * _view.panel_xian:getScaleY()
    local _worldPoint = _view.panel_xian:convertToWorldSpace(cc.p(0,0))
    WindowControler:showWindow("PartnerSkillDetailView",{id = _skillId,level = self._skillValue[_skillId] or 1},cc.p(_worldPoint.x + _rect.width/2,_worldPoint.y - _rect.height/2))
end
return PartnerSkillView