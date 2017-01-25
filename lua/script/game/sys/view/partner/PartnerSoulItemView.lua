--仙魂道具UI
--2016-12-15 17:43:54
--小花熊
local PartnerSoulItemView = class("PartnerSoulItemView",UIBase)

function PartnerSoulItemView:ctor(_winName,_itemInfo)
    PartnerSoulItemView.super.ctor(self,_winName)
    self._soulItemInfo = _itemInfo
end

function PartnerSoulItemView:registerEvent()
    PartnerSoulItemView.super.registerEvent(self)
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.notifySoulItemChanged,self)
end

function PartnerSoulItemView:loadUIComplete()
    self:registerEvent()
end
--设置回调函数
function PartnerSoulItemView:addTouchListener(_listener)
    self._callbackListener = _listener
end
--设置仙魂升级道具
function PartnerSoulItemView:setSoulInfo(_soulItemInfo)
    self._soulItemInfo = _soulItemInfo
end
--更新UI
function PartnerSoulItemView:updateSoulItemView()
    --玩家是否拥有此道具
    local _count = ItemsModel:getItemNumById(self._soulItemInfo.id)
    self._oldCount = _count
    self.panel_jia:setVisible(_count <=0)
    --道具的图标
    local _panel = self.btn_1:getUpPanel().panel_1
    --图标 
    _panel.ctn_1:removeAllChildren()
    local _item = FuncItem.getItemData(self._soulItemInfo.id)
    local _iconPath = FuncRes.iconItem(_item.id)
    local _iconSprite = cc.Sprite:create(_iconPath)
    _panel.ctn_1:addChild(_iconSprite)
    --数目
    _panel.txt_goodsshuliang:setString(tonumber(_count))
    --当前道具是否可用
    _panel.panel_red:setVisible(_count>0)
    --注册按钮事件
    self.btn_1:setTap(c_func(self.clickButtonCallback,self))
end
--按钮事件
function PartnerSoulItemView:clickButtonCallback()
    --如果这个道具数量为0
    if self._oldCount<=0 then
        WindowControler:showWindow("GetWayListView", self._soulItemInfo.id);
        return
    end
    self._callbackListener()
end
--强制刷新
function PartnerSoulItemView:forceButtonCallback()
    self._callbackListener(true)
end
--监听道具的变化
function PartnerSoulItemView:notifySoulItemChanged(_param)
    --检测该道具的数目是否发生了变化
    local _dataItems = _param.params
    for _key,_value in pairs(_dataItems)do
        if  _key == self._soulItemInfo.id then
            local _newCount = ItemsModel :getItemNumById(_key)
            self._oldCount = _newCount
            --self.panel_jia:setVisible(self._oldCount<=0)--是否应该隐藏加号
            self:updateSoulItemView()
            --强制刷新
            self:forceButtonCallback()
        end
    end
end

return PartnerSoulItemView