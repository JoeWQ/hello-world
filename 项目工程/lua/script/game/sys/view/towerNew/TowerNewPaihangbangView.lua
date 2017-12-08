-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
  
local TowerNewPaihangbangView = class("TowerNewPaihangbangView", UIBase)

function TowerNewPaihangbangView:ctor(winName,data)
    TowerNewPaihangbangView.super.ctor(self, winName)
    self.data = data
end

function TowerNewPaihangbangView:loadUIComplete()
    self:setViewCfg()
    self:registerEvent()
    self:updateUI()
end

-- 适配 
function TowerNewPaihangbangView:setViewCfg()
    
end 


function TowerNewPaihangbangView:updateUI()
    dump(self.data,"爬塔排行榜")
    if self.data then
        for k,v in pairs(self.data) do
            local panelItem = UIBaseDef:cloneOneView(self.panel_1)
            panelItem:setPositionY(self.panel_1:getPositionY() - 80 * (k - 1))
            self:addChild(panelItem,100+k)
            if v.name == "" then
                v.name = "少侠"
            end
            panelItem.txt_1:setString(v.name)
            panelItem.txt_2:setString(v.floor.."层")
            panelItem.mc_1:showFrame(tonumber(k))
        end
    end
    
    self.panel_1:setVisible(false)
end 


function TowerNewPaihangbangView:registerEvent()
    self.btn_close:setTap(c_func(self.close, self))
    self:registClickClose("out");
end 

function TowerNewPaihangbangView:close()

	self:startHide()
end

return TowerNewPaihangbangView  
