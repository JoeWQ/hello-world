--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
 
  
local TowerNewTreasureShowAwardItemView = class("TowerNewTreasureShowAwardItemView", UIBase)


function TowerNewTreasureShowAwardItemView:ctor(winName, _sire)
    TowerNewTreasureShowAwardItemView.super.ctor(self, winName)
    self.sire = _sire

end
  
function TowerNewTreasureShowAwardItemView:setItemData(data)

end  

function TowerNewTreasureShowAwardItemView:loadUIComplete() 
   self:registerEvent()
end

function TowerNewTreasureShowAwardItemView:registerEvent() 
    --  EventControler:addEventListener(CombineEvent.TREASURE_COMBINE_UPDATE_LIST, self.updateCombineState, self)   
end  

function TowerNewTreasureShowAwardItemView:updateCombineState()
    self.ownedTreasureDebris = self.sire:sortTeasureItemData() or { }
    self:updateUI()
end 

function TowerNewTreasureShowAwardItemView:updateUI()

end

function TowerNewTreasureShowAwardItemView:deleteMe()   
    TowerNewTreasureShowAwardItemView.super.deleteMe(self)
    self.controler = nil
end

return TowerNewTreasureShowAwardItemView  
-- endregion 

