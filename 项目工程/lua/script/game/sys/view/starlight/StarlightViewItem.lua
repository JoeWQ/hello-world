-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成


local StarlightViewItem = class("StarlightViewItem", UIBase)


function StarlightViewItem:ctor(winName, _sire)
    StarlightViewItem.super.ctor(self, winName)

    self.map_frame={};
    self.map_frame[2]=1;
    self.map_frame[3]=2;
    self.map_frame[4]=3;
    self.map_frame[5]=4;
end
 

-- 刷新单个Item 用于单个Item修改时刷新-- 精炼信息 文字提示
function StarlightViewItem:setItemData(data)
    local _len = #data.Require/2-1
    local _panel = self.btn_1.spUp.panel_1
    _panel.panel_1:setVisible(false)
    if tonumber(UserModel:level()) < data.UnlockLevel then
        _panel.panel_1:setVisible(true)
    end
    _panel.txt_3:setVisible(data.activate)
    _panel.mc_2:showFrame(data.Bg)
    _panel.mc_1:showFrame(_len )
    local _myTreasuresVer = TreasuresModel:getAllTreasure()

    if(not data.activate)then
            _panel.mc_3:showFrame(2);
    end
--    _panel.mc_3:showFrame(_yuan3(data.activate, 2, 1))
 --   local _text = FuncChar.getAttributeById(data.AttConv)["order"]
    local   _treasure=FuncTreasure.getStarlightData();
    local  _text=_treasure[tostring(data.Id)].Num;
    _panel.mc_3.currentView.txt_2:setString("+".. _text)
    _panel.mc_3.currentView.txt_1:setString(GameConfig.getLanguage(data.Desc))

    for i = 1, #data.Require,2 do
--        local _rId = string.split(data.Require[i], ",")
        local   _rId1=data.Require[i];
        local   _rId2=data.Require[i+1];
        local _resName = FuncRes.iconTreasure(_rId1)
        local   _panel_temp=_panel.mc_1.currentView["panel_" .. (i+1)/2]
        local   _node=_panel_temp.ctn_1
        _node:removeAllChildren()
        local _sprite = display.newSprite(_resName):size(_node.ctnWidth, _node.ctnHeight)
        _sprite:addto(_node)
        --        local maxLvl = FuncTreasure.getValueByKeyTD(_rId[1], "lvLimit");
        local _text = ""
        if _myTreasuresVer[_rId1] ~= nil  then--//如果有法宝,或者没有法宝但是已经激活了
            _text = string.format("%s/%s级", _myTreasuresVer[_rId1]:level(), _rId2)
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

 
function StarlightViewItem:deleteMe()
    StarlightViewItem.super.deleteMe(self)
    self.controler = nil
end

return StarlightViewItem  
-- endregion
