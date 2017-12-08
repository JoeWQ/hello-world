-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local StarlightView = class("StarlightView", UIBase)

function StarlightView:ctor(winName, _sire,_clipRect)
    StarlightView.super.ctor(self, winName)
    self.sire = _sire
    self.itemDataCache = { }
    self.showIdx = 5
    -- 默认最显示5个
    self.index = -1
    self.length = 0
    self.clipRect=_clipRect;
end

function StarlightView:adaptationScrollList()

    local scrollPreRect = self.scroll_1:getViewRect();
    self.scroll_1:updateViewRect(self.clipRect); 

    --创建剪裁区域
    local clipNode = display.newClippingRectangleNode(
        cc.rect(0, 0, scrollPreRect.width, scrollPreRect.height));

    clipNode:setPosition(0, -scrollPreRect.height);

    self.ctn_aciton:addChild(clipNode);

    self._ClipNode = clipNode;
end
--//刷新
function StarlightView:freshAllStarlight()
    for key,value in pairs(self.starLightData) do
          local  _cell=self.scroll_1:getViewByData(value);
          if(_cell~=nil)then
                  self:updateItem(_cell,value);
          end
    end
end
function StarlightView:initData(data)

    self.starLightData = StarlightModel.starLightData or { }
    self:updateUI(false)

--    function _callFunc()
--        for i = 1, #self.itemDataCache do
--            self.itemDataCache[i]:setVisible(true)
--        end
--        self.scroll_ani:clear()
--    end
--    self.scroll_ani = self:createUIArmature(nil,
--        "UI_fabaodaoju_cj_359*480", nil, false, _callFunc):pos(0, 0)

--    for i = 1, 5 do
--        if self.starLightData[i] == nil then
--            if i == 5 and table.length(self.starLightData) > 2 then
--                local changeNode = UIBaseDef:cloneOneView(self.UI_item):pos(0, 0);
--                changeNode:setVisible(true);
--                FuncArmature.changeBoneDisplay(self.scroll_ani,
--                    "element_" .. tostring(i), changeNode);
--            else
--                FuncArmature.changeBoneDisplay(self.scroll_ani,
--                    "element_" .. tostring(i), display.newNode());
--            end
--        else
--            local changeNode = UIBaseDef:cloneOneView(self.UI_item):pos(0, 0);
--            self:updateItem(changeNode, self.starLightData[i], true)
--            changeNode:setVisible(true);

--            FuncArmature.changeBoneDisplay(self.scroll_ani,
--                "element_" .. tostring(i), changeNode);
--        end
--    end

--    -- --self.scroll_ani:addto(self.scroll_1.innerContainer)
--    self.scroll_ani:setPosition(0, self.scroll_1:getViewRect().height);

--    self._ClipNode:addChild(self.scroll_ani);
end 
-- 刷新单个Item 用于单个Item修改时刷新-- 精炼信息 文字提示
function StarlightView:updateSignItem()

    local _data = self.starLightData[self.index]
    local   _starLight=StarlightModel:getStarlights();
    if _starLight[tonumber(_data.Id)] ~= nil then
        _data.activate = true
    end
    local _view = self.scroll_1:getViewByData(_data)
    self:updateItem(_view, _data)

end 

function StarlightView:updateItem(view, data)
    local _panel = view.btn_1.spUp.panel_1

    local _len = #data.Require/2-1
    
    _panel.panel_1:setVisible(false)

    if tonumber(UserModel:level()) < data.UnlockLevel then
        _panel.panel_1:setVisible(true)
    end
    _panel.txt_3:setVisible(data.activate)
    _panel.mc_2:showFrame(data.Bg)
    _panel.mc_1:showFrame(_len )
    local _myTreasuresVer = TreasuresModel:getAllTreasure()

 --   _panel.mc_3:showFrame(_yuan3(data.activate, 2, 1))
     if(not data.activate)then
            _panel.mc_3:showFrame(2);
    else
            _panel.mc_3:showFrame(1);
    end

    local   _treasure=FuncTreasure.getStarlightData();
    local  _text=_treasure[tostring(data.Id)].Num;
    _panel.mc_3.currentView.txt_2:setString("+".. _text)

    _panel.mc_3.currentView.txt_1:setString(GameConfig.getLanguage(data.Desc))

    for i = 1, #data.Require ,2 do
--        local _rId = string.split(data.Require[i], ",")
        local   _rid1=data.Require[i];
        local   _rId2=data.Require[i+1];
        local _resName = FuncRes.iconTreasure(_rid1)
        local  _node=_panel.mc_1.currentView["panel_" .. (i+1)/2].ctn_1
        local _sprite = display.newSprite(_resName):size(_node.ctnWidth, _node.ctnHeight)
        _node:removeAllChildren();
        _sprite:addto(_node)
        --        local maxLvl = FuncTreasure.getValueByKeyTD(_rId[1], "lvLimit");
        local _text = ""
        if _myTreasuresVer[_rid1] ~= nil then
            _text = string.format("%s/%s级", _myTreasuresVer[_rid1]:level(), _rId2)
            FilterTools.clearFilter(_sprite);
        else
            if(data.activate)then
                _text = string.format("%s/%s级", _rId2, _rId2)
                FilterTools.clearFilter(_sprite);
            else
               _text = string.format("%s/%s级", 0, _rId2)
               FilterTools.setGrayFilter(_sprite);
            end
        end
        _panel.mc_1.currentView["panel_" .. (i+1)/2].txt_1:setString(_text)
    end
end 
 
function StarlightView:loadUIComplete()
    self:registerEvent()
    FuncCommUI.setViewAlign(self.scroll_1, UIAlignTypes.Left)
    FuncCommUI.setViewAlign(self.ctn_aciton, UIAlignTypes.Left)

     self.UI_item:visible(false);   
     self:adaptationScrollList();
     self:initData()
end

function StarlightView:registerEvent()

    EventControler:addEventListener(StarlightEvent.STARLIGHT_EVENT_UPDATE, self.updateSignItem, self)
    EventControler:addEventListener(TreasureEvent.STARLIGHT_UPDATE_ITEM,self.onStarlightItemChanged,self);
end 
--//通知给页面法宝已经发生了变化
function StarlightView:onStarlightItemChanged(_params)
    local   _data=_params.params.data;
    if(_data ~=nil )then
            local   _cell=self.scroll_1:getViewByData(_data);
            if(_cell~=nil)then
                       self:updateItem(_cell,_data);
            end
    end
end

function StarlightView:updateUI(isShow)

    if _G.next(self.starLightData) ~= nil then
        -- self.scroll_1:visible(true)

        local itemData = { }
        local _myTreasuresVer = TreasuresModel:getAllTreasure()
        local  _starLight=StarlightModel:getStarlights();
        for k, v in pairs(self.starLightData) do
            local _activate = false
            if _starLight[v.Id] ~= nil then
                _activate = true
            end
            v.activate = _activate
            
            local _canActivate = true
--//将Require实现转换成另一种格式
            local      _require={};
            for _index=1,#v.Require do
                      local    _rid=v.Require[_index]:split(",");
                      table.insert(_require,_rid[1]);
                      table.insert(_require,_rid[2]);
            end
            v.Require=_require;
            for i = 1, #v.Require,2 do
--                local _rId = string.split(v.Require[i], ",")
                local     _rId1=v.Require[i];
                local     _rId2=v.Require[i+1];
                --                local maxLvl = FuncTreasure.getValueByKeyTD(_rId[1], "lvLimit");
                if _myTreasuresVer[_rId1] == nil or _myTreasuresVer[_rId1]:level() < tonumber(_rId2) then
                    _canActivate = false
                    break
                end
            end
            v.canActivate = _canActivate
            table.insert(itemData, v)
        end
        local _idx = 1
        local createFunc = function(_itemdata)
            local _itemView = UIBaseDef:cloneOneView(self.UI_item)
--            if _idx <= self.showIdx then
--                _itemView:setVisible(isShow)
--                table.insert(self.itemDataCache, _itemView)
--            end
            _idx = _idx + 1
            _itemView:setItemData(_itemdata)

            local index
            for k, v in pairs(self.starLightData) do
                if v == _itemdata then
                    index = toint(k)
                    break
                end
            end

            _itemView:setTouchedFunc(c_func(self.chooseItem, self, _itemView, index, _itemdata))
            return _itemView
        end


        local updateCellFunc = function ( data,view )
            view:setItemData(data)
            local index = table.indexof(self.starLightData,data)
            if not index then 
                dump(data,"__data")
                echoWarn("没有找到数据索引---")
            end
            view:setTouchedFunc(c_func(self.chooseItem, self, view, index, data))
        end


        local params = {
            {
                data = itemData,
                createFunc = createFunc,
                perNums = 1,
                offsetX = -1,
                offsetY = -1,
                widthGap = 14,
                heightGap = heightGap,
                itemRect = { x = 0, y = - 200, width = 359, height = 200 },
                perFrame = 1,
                updateCellFunc = updateCellFunc
            }
        }
        self.scroll_1:styleFill(params)
 --       self.scroll_1:easeMoveto(0, 0, 0)
    else
        self.scroll_1:visible(false) 
    end

end
 
function StarlightView:findItemDataFromListData(itemId)

    local targetItemData = nil
    for i = 1, #self.ownedTreasureDebris do
        local data = self.ownedTreasureDebris[i]
        if tostring(data.id) == tostring(itemId) then
            targetItemData = data
            return targetItemData
        end

    end
    return targetItemData
end

function StarlightView:chooseItem(itemView, index, _itemdata)
    if self.scroll_1:isMoving() then
        return
    end
    self.index = index
    if tonumber(UserModel:level()) < _itemdata.UnlockLevel then
        local _str = string.format("需要%s级才可以解锁哦~", _itemdata.UnlockLevel)
        WindowControler:showTips(_str)
        return
    end
    WindowControler:showWindow("StarlightTipView", self):initData(_itemdata)
end


function StarlightView:deleteMe()
--//分段删除所有的组件
    StarlightView.super.deleteMe(self)
    self.controler = nil
end

return StarlightView  
-- endregion
