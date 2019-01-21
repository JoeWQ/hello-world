-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成


local CombineItemConfTip = class("CombineItemConfTip", UIBase)


function CombineItemConfTip:ctor(winName , sire)
    CombineItemConfTip.super.ctor(self, winName)
    self.sire = sire

end
function CombineItemConfTip:initData(data)
    self.data = data
    self:updateUI()
end 
function CombineItemConfTip:loadUIComplete()
    self:registerEvent()  
end

function CombineItemConfTip:registerEvent()
    self:registClickClose(-1, c_func( function()
        self:startHide()
    end , self))

    self.UI_1.btn_close:setTap(c_func( function()
        self:startHide()
    end , self));

    self.UI_1.mc_1.currentView["btn_1"]:setTap(c_func( function()
        self.sire:combine()
        self:startHide()
    end , self));
end 
 
function CombineItemConfTip:updateUI()
    self.UI_1.txt_1:setString(GameConfig.getLanguage("combine_confirm"))
    local _len = #self.data
    self.rich_2:setString(string.format(GameConfig.getLanguage("combine_restitutionInfo"), self.data[1].name, self.data[1].num))
    local _text = string.format(GameConfig.getLanguage("combine_confirm_Info"), self.data[1].name,"")
      self.rich_3:setVisible(false)
    if _len == 2 then
        self.rich_3:setVisible(true)
        _text = string.format(GameConfig.getLanguage("combine_confirm_Info"), self.data[1].name, "、" .. self.data[2].name)
        self.rich_3:setString(string.format(GameConfig.getLanguage("combine_restitutionInfo"), self.data[2].name, self.data[2].num))
    end
      self.rich_1:setString(_text)
end

 

function CombineItemConfTip:deleteMe()
    CombineItemConfTip.super.deleteMe(self)
    self.controler = nil
end


return CombineItemConfTip  
-- endregion
