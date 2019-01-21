--竞技场挑战5次
--2017-1-14 10:14:38
--@Author:xiaohuaxiong
local ArenaChallenge5View = class("ArenaChallenge5View",UIBase)
--角色自己的信息,
--对手的信息
--战斗的结果(5次)
function ArenaChallenge5View:ctor(_window_name,_playerInfo,_enemyInfo,_result_array)
    ArenaChallenge5View.super.ctor(self,_window_name) 
    self._playInfo = _playerInfo
    self._enemyInfo = _enemyInfo
    self._resultInfo = _result_array
end
--
function ArenaChallenge5View:loadUIComplete()
    self:registerEvent()
    self:updateChallengeView()
end
--
function ArenaChallenge5View:registerEvent()
    ArenaChallenge5View.super.registerEvent(self)
    self:registClickClose("out")
    self.btn_close:setTap(c_func(self.clickButtonClose,self))
    self.mc_1.currentView.btn_1:setTap(c_func(self.clickButtonClose,self))
end

function ArenaChallenge5View:clickButtonClose()
    self:startHide()
end

function ArenaChallenge5View:updateChallengeView()
    self.panel_1:setVisible(false)
    local _data_source = self._resultInfo
    local function createFunc(_item,_index)
        local _view = UIBaseDef:cloneOneView(self.panel_1)
        self:updateChallengeItemView(_view,_index)
        return _view
    end
    local function updateCellFunc(_item,_view,_index)
        self:updateChallengeItemView(_view,_index)
    end
    local _param = {
        data = _data_source,
        createFunc = createFunc,
  --      updateCellFunc = updateCellFunc,
        offsetX = 0,
        offsetY = 0,
        widthGap = 0,
        heightGap =0,
        perNums =1,
        perFrame =1,
        itemRect = {x =0,y = -138, width = 418,height = 138,},
    }
    self.scroll_1:styleFill({_param})
end
--更新结果
function ArenaChallenge5View:updateChallengeItemView(_view,_index)
    --第N回
    _view.txt_1:setString(GameConfig.getLanguage("pvp_challenge_times_1005"):format(_index))
    --self
    self:updatePlayer(_view.panel_fbiconnew,self._playInfo)
    --enemy
    self:updatePlayer(_view.panel_fbiconnew2,self._enemyInfo)
    --win of failed
    self.mc_1:showFrame(self._resultInfo[_index])
end
--更新角色信息
function ArenaChallenge5View:updatePlayer(_view,_playerInfo)
    --品质
    _view.mc_2:showFrame(_playerInfo.quality or 1)
    --icon
    local _char_item = FuncChar.getHeroData(_playerInfo.avatar)
    local _iconPath = FuncRes.iconHead(_char_item.icon)
    local _iconSprite = cc.Sprite:create(_iconPath)
    _view.mc_2.currentView.ctn_1:addChild(_iconSprite)
    --star
    _view.mc_dou:showFrame(_playerInfo.star or 1)
    --level
    _view.txt_3:setString(tostring(_playerInfo.level))
end

return ArenaChallenge5View