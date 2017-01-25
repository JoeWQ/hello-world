-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成


local CombineView = class("CombineView", UIBase)


function CombineView:ctor(winName, _sire, scrollRect)
    CombineView.super.ctor(self, winName)
    self.sire = _sire
    self.itemDataCache = {}
    self.showIdx = 5 --默认最显示5个
    self.index = -1
    self.length  = 0
    self._scrollRect = scrollRect
end


function CombineView:initData()

    --self.scroll_1:setVisible(false);

    self.ownedTreasureDebris = CombineControl:checkCombineState()
    self:updateUI(false)
    -- 法宝碎片数据
    -- todo 
--    FuncArmature.loadOneArmatureTexture("UI_fabaodaoju_2", nil, true);
--    self:updateUI(false)
--    self.length = #self.ownedTreasureDebris

--    function _callFunc()       
--       for i = 1 , #self.itemDataCache do
--            self.itemDataCache[i]:setVisible(true)
--       end 
--        self.scroll_1:setVisible(true);
--        self.scroll_ani:visible(false);
--        self.scroll_ani:clear();        
--    end

--    self.scroll_ani = FuncArmature.createArmature(
--        "UI_fabaodaoju_2_cj", nil, false, _callFunc):pos(0,0);

--    for i = 1, 5 do
--        if self.ownedTreasureDebris[i] == nil then
--            if i == 5 and table.length(self.ownedTreasureDebris) > 4 then
--                local changeNode = UIBaseDef:cloneOneView(self.UI_3):pos(0, 0);
--                changeNode:setVisible(true);
--                FuncArmature.changeBoneDisplay(self.scroll_ani,
--                    "element_" .. tostring(i), changeNode);
--            else
--                FuncArmature.changeBoneDisplay(self.scroll_ani,
--                    "element_" .. tostring(i), display.newNode());
--            end
--        else
--            local changeNode = UIBaseDef:cloneOneView(self.UI_3):pos(0, 0);

--            self:updateItem(changeNode, self.ownedTreasureDebris[i], true)
--            changeNode:setVisible(true);

--            FuncArmature.changeBoneDisplay(self.scroll_ani,
--                "element_" .. tostring(i), changeNode);
--        end
--    end

--    -- self.scroll_ani:addto(self.scroll_1.innerContainer)
--    self.scroll_ani:setPosition(0, self.scroll_1:getViewRect().height);
--    self._ClipNode:addChild(self.scroll_ani);
end 

--刷新单个Item 用于单个Item修改时刷新-- 精炼信息 文字提示
function CombineView:updateSignItem( data )
   local _data = self.ownedTreasureDebris[self.index]
--   local _view = self.scroll_11:getViewByData(_data)
----   _data = self.sire:getTeasureItemData(_data.id)
--   self:updateItem(_view,_data)

--   self.scroll_11:refreshCellView(1);
end 

function CombineView:updateItem(view, _itemData, is)
    if _itemData == nil then return end
    -- 物品图标
    local _sprite = display.newSprite(_itemData.mainIcon):size(
        view.btn_1.spUp.panel_1["ctn_1"].ctnWidth,
        view.btn_1.spUp.panel_1["ctn_1"].ctnHeight)

    view.btn_1.spUp.panel_1["ctn_1"]:removeAllChildren();
    
    _sprite:parent(view.btn_1.spUp.panel_1["ctn_1"])

    -- 资质
    view.btn_1.spUp.panel_1.mc_1:showFrame(_itemData.quality)
    -- 物品名称
    view.btn_1.spUp.panel_1["txt_1"]:setString(GameConfig.getLanguage(_itemData.name))
    -- 需要的碎片数量
    view.btn_1.spUp.rich_1:setString(_itemData.goodsNum)
    -- 法宝位置icon
    if _itemData.pos ~= 0 then 
    view.btn_1.spUp.panel_1["mc_2"]:showFrame(_itemData.pos)
    else 
    view.btn_1.spUp.panel_1["mc_2"]:setVisible(false)
    end 
    -- 需要的完整法宝
    local _ngs = _itemData.needGoodssatisfy
    local _nicon = _itemData.needGoodsIcon
    for i = 1, #_ngs do
        local _sprite = display.newSprite(_nicon[i]._iconName)
        _sprite:setScale(0.5)
        view.btn_1.spUp.mc_1:showFrame(#_ngs + 1)
        local _cuview = view.btn_1.spUp.mc_1.currentView["panel_" .. i]
        _cuview.ctn_1:removeAllChildren();
        _sprite:parent(_cuview.ctn_1)
        if not _nicon[i]._own then
            -- 没有该法宝置灰
            FilterTools.setGrayFilter(_sprite);
            _cuview.mc_2:showFrame(3)
        end
      local _refineLv = FuncTreasure.getTreasureRefineMaxLvl(_nicon[i]._id)
         _cuview.mc_1:showFrame(_refineLv) 
        -- 是否圆满
        if _ngs[i] then
            _cuview.mc_2:showFrame(2)
        end
    end
    -- 红点提示
    view.btn_1.spUp.panel_red:setVisible(_itemData.isSatisfy)
end 
 

function CombineView:loadUIComplete()
    self:registerEvent()
    FuncCommUI.setViewAlignByDown(self.UI_2, UIAlignTypes.center)
    self.UI_3:visible(false)
    self:adaptationScrollList();
    self:initData()

    FuncCommUI.setViewAlign(self.scroll_11, UIAlignTypes.Left)
--    FuncCommUI.setViewAlign(self.ctn_aciton, UIAlignTypes.Left);   

end

function CombineView:registerEvent() 
    EventControler:addEventListener(CombineEvent.TREASURE_COMBINE_UPDATE_LIST, self.updateCombineState, self)
    EventControler:addEventListener(CombineEvent.TREASURE_COMBINE_UPDATE_SIGN_DATA, self.updateSignItem, self)
    EventControler:addEventListener(TreasureEvent.FABAO_YUANMAN, self.updateCombineState, self)

     --金币增加
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, 
        self.updateCombineState, self);

    --道具变化
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.updateCombineState, self);
    
    -- 有新的法宝
    EventControler:addEventListener(TreasureEvent.TREASUREEVENT_MODEL_NEW, 
        self.updateCombineState, self);
end 


function CombineView:adaptationScrollList()

    self.scroll_11:updateViewRect(self._scrollRect); 

    --创建剪裁区域
--    local clipNode = display.newClippingRectangleNode(
--        cc.rect(0, 0, self._scrollRect.width, self._scrollRect.height));

--    clipNode:setPosition(0, -self._scrollRect.height);

--    self.ctn_aciton:addChild(clipNode);

--    self._ClipNode = clipNode;
end

function CombineView:updateCombineState()
    self.ownedTreasureDebris = CombineControl:checkCombineState() or { }
    self:updateUI(true)

    if self.length == #self.ownedTreasureDebris then 
        if self.index == -1 then
            return
        end
        self.scroll_11:gotoTargetPos(self.index,1) 
        self.length =  #self.ownedTreasureDebris
    end 
    -- 更新数据
    self.scroll_11:refreshCellView(1);
end 

function CombineView:updateUI(isShow)

    if _G.next(self.ownedTreasureDebris) ~= nil then
        self.scroll_11:visible(true)
        self.panel_2:visible(false)
        local itemData = { }
    
        for k, v in pairs(self.ownedTreasureDebris) do
            table.insert(itemData, v)
        end

        local createFunc = function(_itemdata)
            local _itemView = UIBaseDef:cloneOneView(self.UI_3) 

            _itemView:setItemData(_itemdata)

            _itemView:setTouchedFunc(c_func(self.chooseItem, self, _itemView , _itemdata))
            return _itemView
        end

        local reuseUpdateCellFunc = function(_itemdata, _itemView)

            _itemView:setItemData(_itemdata)

            _itemView:setTouchedFunc(c_func(self.chooseItem, self, _itemView, _itemdata))
            return _itemView
        end
        self.scroll_11:setCanScroll(true);
        local params = {
            {
                data = itemData,
                createFunc = createFunc,
                perNums = 3,
                offsetX = 1,
                offsetY = 0,
                widthGap = 4,
                heightGap = 0,
                itemRect = { x = 0, y = - 287, width = 255, height = 287 },
                perFrame = 1,
                updateCellFunc = reuseUpdateCellFunc,
            }
        }
        self.scroll_11:styleFill(params)
        self.scroll_11:enableMarginBluring()
    else
        self.scroll_11:visible(false)
        self.panel_2:visible(true)
    end

end


--function CombineView:findItemDataFromListData(itemId)

--    local targetItemData = nil
--        for i=1,#self.ownedTreasureDebris do
--            local data = self.ownedTreasureDebris[i]
--                if tostring(data.id) == tostring(itemId) then
--                    targetItemData = data
--                    return targetItemData
--                end

--        end 
--    return targetItemData
--end

function CombineView:chooseItem(itemView, _itemdata)
    if self.scroll_11:isMoving() == false then
        -- 是否满足条件
        for i,v in pairs( self.ownedTreasureDebris) do
            if v == _itemdata  then
                self.index = i
            end
        end
        
        self.view = WindowControler:showWindow("CombineItemTip", self, { bgAlpha = 0 });
        self.view:setCombineData(_itemdata)
    end
   
end 


function CombineView:deleteMe()
    CombineView.super.deleteMe(self)
    self.controler = nil
end

return CombineView  
-- endregion
