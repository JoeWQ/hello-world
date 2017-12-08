-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成


local CombineItemIntensify = class("CombineItemIntensify", UIBase)


function CombineItemIntensify:ctor(winName , _sire)
    CombineItemIntensify.super.ctor(self, winName)
    self.sire = _sire

end
function CombineItemIntensify:initData(data , idx )
  self.itemData = data 
  self.index = idx
  self:updateUI()
end 
function CombineItemIntensify:loadUIComplete()
   self:registerEvent()
end

function CombineItemIntensify:registerEvent()
    self:registClickClose(-1, c_func( function()
        self:startHide()
    end , self))

    --guan todo 跳转到强化有bug，屏蔽
--    self.UI_1.mc_1:setVisible(false);

    self.UI_1.btn_close:setTap(c_func( function()
       AudioModel:playSound("s_com_click1")
        self:startHide()
    end , self));
    self.UI_1.mc_1:showFrame(1)
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func( function()
        local _myTreasuresVer = TreasuresModel:getAllTreasure()

        local refineLv = FuncTreasure.getTreasureRefineMaxLvl(self.itemData.needGoodsIcon[self.index]._id)
        if _myTreasuresVer[tostring(self.itemData.needGoodsIcon[self.index]._id)]:state() == refineLv then
            AudioModel:playSound("s_com_click1")
            self:startHide()
        else
            WindowControler:showWindow("TreasureDetailView", _myTreasuresVer[tostring(self.itemData.needGoodsIcon[self.index]._id)]);
            AudioModel:playSound("s_com_click1")
            self:startHide()
        
        end

    end , self));


end 
function CombineItemIntensify:updateCombineState()
   --更新数据
end 
function CombineItemIntensify:updateUI()
     if self.itemData == nil  then return end 
    self.UI_2.mc_di:showFrame(self.itemData.needGoodsIcon[self.index]._quality)
    
    local _mId = self.itemData.needGoodsIcon[self.index]._id
    local _maxLv = FuncTreasure.getTreasureMaxLvl(_mId)
    --提示文字  combine_needTreasureLvl ci
	local _text = string.format(GameConfig.getLanguage("combine_needTreasureLvl"),tostring(_maxLv))
    self.rich_1:setString(_text)
    
    display.newSprite(self.itemData.needGoodsIcon[self.index]._iconName):addto(self.UI_2.ctn_icon):size(self.UI_2.ctn_icon.ctnWidth,self.UI_2.ctn_icon.ctnHeight)
    --资质
    local _quality = FuncTreasure.getValueByKeyTD(_mId, "quality")
    self.UI_2.mc_zizhi:showFrame(_quality)
    --位置
    local _pos = FuncTreasure.getValueByKeyTD(_mId, "label1")
    _pos = _yuan3(_pos < 3, _pos, 1)
   
    self.UI_2.mc_biaoqian:showFrame(_pos)
    local _myTreasuresVer = TreasuresModel:getAllTreasure()
    --当前星级以及 
    local _color = ""
    local _colorEnd = ""
     if _myTreasuresVer[tostring(_mId)]:level() <  _maxLv then 
        _color = "<color=ff2700>"
        _colorEnd = "<->"
     end 
    local _info = string.format(GameConfig.getLanguage("combine_currenLvl"),_color.._myTreasuresVer[tostring(_mId)]:level(),_maxLv.._colorEnd)
    self.rich_2:setString(_info)
    local refineLv = FuncTreasure.getTreasureRefineMaxLvl(_mId)
    local _satisfy = _yuan3(_myTreasuresVer[tostring(_mId)]:state() == refineLv,true,false)

    self.UI_1.txt_1:setString(_yuan3( _satisfy,GameConfig.getLanguage("combine_Intensify_Tip2") ,GameConfig.getLanguage("combine_Intensify_Tip")))
    self.mc_1:showFrame(_yuan3(_satisfy ,2 ,1))
    self.UI_1.mc_1:showFrame(1)

    self.UI_1.mc_1.currentView["btn_1"].spUp.txt_1:setString(_yuan3(_satisfy,GameConfig.getLanguage("combine_Intensify_Btn_Text2"),GameConfig.getLanguage("combine_Intensify_Btn_Text")))
end


function CombineItemIntensify:deleteMe()
    CombineItemIntensify.super.deleteMe(self)
    self.controler = nil
end


return CombineItemIntensify  
-- endregion
