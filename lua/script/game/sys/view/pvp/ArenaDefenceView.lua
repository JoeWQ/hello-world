--竞技场玩家自己防守阵容
--2017-1-10 11:42:55
--@Author:xiaohuaxiong
local ArenaDefenceView = class("PvpDefenceView",UIBase)

function ArenaDefenceView:ctor(_window_name,_playerInfo)
    ArenaDefenceView.super.ctor(self,_window_name)
    self._playerInfo = _playerInfo
end

function ArenaDefenceView:loadUIComplete()
    self:registerEvent()
    self:updatePlayerDetail()
end

function ArenaDefenceView:registerEvent()
    ArenaDefenceView.super.registerEvent(self)
    self.btn_back:setTap(c_func(self.clickButtonBack,self))
    self.btn_1:setTap(c_func(self.clickButtonBack,self))
    self.btn_2:setTap(c_func(self.clickButtonSetting,self))
    --需要增加对玩家自己的伙伴,法宝阵列变化的监听
end

function ArenaDefenceView:clickButtonBack()
    self:startHide()
end
--update ui,真实玩家
function ArenaDefenceView:updatePlayerDetail()
    local _playerInfo = self._playerInfo
    local _player_item = FuncChar.getHeroData(_playerInfo.avatar)
    local _iconPath = FuncRes.iconHead(_player_item.icon)
    self.panel_fbiconnew.mc_1:showFrame(_player_item.aptitude)--资质
    self.panel_fbiconnew.mc_1.currentView.ctn_1:addChild(cc.Sprite:create(_iconPath))--icon
    --level
    self.panel_fbiconnew.txt_3:setString(tostring(_playerInfo.level))
    --player name
    self.txt_name_1:setString(_playerInfo.name)
    --战力
    self.UI_comp_powerNum:setPower(_playerInfo.ability)
    --排名
    self.txt_rank_2:setString(_playerInfo.rank)
    --仙盟
    self.txt_2:setString("暂无仙盟")
    --伙伴出战阵容
    for _index =1,6  do 
        local _partnerId = _playerInfo.formations.partnerFormation["p".._index]
        local _panel = self.panel_1["panel_fbiconnew".._index]
        if _partnerId ~= nil then   --此处有伙伴
            local _partnerInfo = _playerInfo.partners[_partnerId]
            self:updateEveryPartnerView(_partnerInfo,_panel)
        else--否则隐藏槽位
            _panel:setVisible(false)
        end
    end
    --法宝阵容,只有两个
    for _index=1,2 do
        local _treasureId = _playerInfo.formations.treasureFormation["p".._index]
        local _view = self.panel_1["panel_fbicon".._index]
        if _treasureId ~= nil then
            local _treasureInfo = _playerInfo.treasures[_treasureId]
            self:updateEveryTreasureView(_treasureInfo,_view)
        else
            _view:setVisible(false)
        end
    end
end
--更新伙伴面板
function ArenaDefenceView:updateEveryPartnerView(_partnerInfo,_view)
    local _partner_item = FuncPartner.getPartnerById(_partnerInfo.id)
    --品质
    _view.mc_2:showFrame(_partnerInfo.quality)
    --icon
    local _iconPath = FuncRes.iconHead(_partner_item.icon)
    local _iconSprite = cc.Sprite:create(_iconPath)
    _view.mc_2.currentView.ctn_1:addChild(_iconSprite)
    --等级
    _view.txt_3:setString(tostring(_partnerInfo.level))
    --星级
    _view.mc_dou:showFrame(_partnerInfo.star)
end
--更新法宝
function ArenaDefenceView:updateEveryTreasureView(_treasureInfo,_view)
    local _item_item = FuncItem.getItemData(_treasureInfo.id)
    --icon
    local _iconPath = FuncRes.iconItem(_item_item.id)
    local _iconSprite = cc.Sprite:create(_iconPath)
    _view.panel_1.ctn_1:addChild(_iconSprite)
    --等级
    _view.txt_3:setString(tonumber(_treasureInfo.level))
    --星级
    _view.mc_dou:showFrame(_treasureInfo.star)
end
--重新设置布阵
function ArenaDefenceView:clickButtonSetting()

end

return PvpDefenceView