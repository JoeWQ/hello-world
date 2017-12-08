-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成 
-- zhoupengcheng

--hehe  

local CombineItemView = class("CombineItemView", ItemBase)
 
function CombineItemView:ctor(winName)
    CombineItemView.super.ctor(self, winName)

end

function CombineItemView:loadUIComplete()
    FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
end
-- 初始化
function CombineItemView:initCfgData()
 
end

function CombineItemView:setViewAlign()
     
end

function CombineItemView:registerEvent()
    CombineItemView.super.registerEvent(self)
end

function CombineItemView:setItemData(itemData)
    CombineItemView.super.setItemData(self, itemData) 
    self:updateUI()

end 
 
function CombineItemView:updateUI()

    if self._itemData == nil then return end
    -- 物品图标
    local _view = self.btn_1:getUpPanel().panel_1.panel_icon12
    _view:setScale(0.9)
    local _sprite = display.newSprite(self._itemData.mainIcon):size(_view.UI_fb1.ctn_icon.ctnWidth,_view.UI_fb1.ctn_icon.ctnHeight)
    _view.UI_fb1.ctn_icon:removeAllChildren();
    _sprite:parent(_view.UI_fb1.ctn_icon)
    --资质
    _view.UI_fb1.mc_zizhi:showFrame(self._itemData.quality )
    -- 物品名称
    local _view1 = self.btn_1:getUpPanel().panel_1
    _view1.txt_1:setString(GameConfig.getLanguage(self._itemData.name))
    --self.btn_1.spUp.rich_1:setString(self._itemData.goodsNum)
    
    -- 法宝位置icon
    _view.UI_fb1.mc_biaoqian:setVisible(false)
    if self._itemData.pos ~= 0 then 
        _view1.mc_1:showFrame(self._itemData.pos)
    else
        _view1.mc_1:setVisible(false)
    end 

    _view1.txt_2:setVisible(false)

     --红点提示
   _view1.panel_red:setVisible(self._itemData.isSatisfy) 

    --需要碎片
    local  nums = string.split(self._itemData.goodsNum,"/")
    if self._itemData.debrisSatisfy then
        _view1.panel_tiaojian1.mc_1:showFrame(3)
        _view1.panel_tiaojian1.mc_1.currentView.txt_2:setString(self._itemData.goodsNum)
    else
        _view1.panel_tiaojian1.mc_1:showFrame(1)
        _view1.panel_tiaojian1.mc_1.currentView.txt_1:setString(self._itemData.goodsNum)
    end
    
    
    _view1.panel_tiaojian1["txt_1"]:setString(GameConfig.getLanguage(self._itemData.name).."碎片") --name


    -- 需要的完整法宝
    local _ngs = self._itemData.needGoodssatisfy
    local _nicon = self._itemData.needGoodsIcon

    

    _view1.panel_tiaojian2:setVisible(false)
    _view1.panel_tiaojian3:setVisible(false)
    for i = 1, #_ngs do 
        local _panel = _view1["panel_tiaojian"..(i+1)]
        _panel:setVisible(true)

        _panel["txt_1"]:setString(GameConfig.getLanguage(FuncTreasure.getValueByKeyTD(_nicon[i]._id, "name"))  )

        --判断是否拥有此法宝
        if not _nicon[i]._own then --没有该法宝
             _panel.mc_1:showFrame(1)
        elseif  _ngs[i] then 
            _panel.mc_1:showFrame(3) --拥有该法宝并且圆满 
        else
            _panel.mc_1:showFrame(2) --拥有该法宝但是未圆满 
        end 

     end
--        local _sprite = display.newSprite(_nicon[i]._iconName)
--        _sprite:setScale(0.5)
--        local _cuview = self.btn_1.spUp.mc_1.currentView["panel_" .. i]
--        _cuview.ctn_1:removeAllChildren();
--        _sprite:parent(_cuview.ctn_1) 
--        if not _nicon[i]._own then --没有该法宝置灰
--         FilterTools.setGrayFilter(_sprite);
--         _cuview.mc_2:showFrame(3)
--        end   
--        local _refineLv = FuncTreasure.getTreasureRefineMaxLvl(_nicon[i]._id)
--         _cuview.mc_1:showFrame(_refineLv)
--        --拥有该法宝并且圆满 
--        if  _nicon[i]._own and _ngs[i] then 
--         _cuview.mc_2:showFrame(2)
--       end 
--    end

end 

return CombineItemView


-- endregion
