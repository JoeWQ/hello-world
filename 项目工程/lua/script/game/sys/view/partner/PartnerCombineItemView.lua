--伙伴系统伙伴合成
--2016-12-10 15:18:50
--Author:xiaohuaxiong
local PartnerCombineItemView = class("PartnerCombineItemView",UIBase)

function PartnerCombineItemView:ctor(_winName)
    PartnerCombineItemView.super.ctor(self,_winName)
end

function PartnerCombineItemView:loadUIComplete()
    self:registerEvent()
end

-- data.partnerId 道具属于的伙伴
-- data.itemId 道具ID
-- data.num 道具数
-- data.frame 合成状态
-- data.isShowNum 是否显示数量 只有第一帧时才有用
function PartnerCombineItemView:setResource(data)
    self.data = data
    local itemData = FuncItem.getItemData(data.itemId)
    self.partnerId = data.partnerId
    self.itemType = data.frame
    local _frame = data.frame
    if _frame >= 4 then
        _frame = 1
    end
    self.mc_1:showFrame(_frame)

    -- 道具品质
    self.mc_1.currentView.mc_3:showFrame(itemData.quality)
    -- 图标
    local itemIcon = display.newSprite(FuncRes.iconItem(data.itemId)):anchor(0.5,0.5)
    itemIcon:setScale(1.15)
    -- 判断是否是碎片
    if itemData.subType == 311 then
        -- 显示
        self.mc_1.currentView.txt_goodsshuliang:visible(false)
        self.mc_1.currentView.panel_1:visible(true)
        self.txt_1:visible(true)
        local needNum = self:getNumFrag(data.parentItemId,data.itemId)
        local hasNum = ItemsModel:getItemNumById(data.itemId)
        self.txt_1:setString(hasNum.."/"..needNum)
    else
        -- 隐藏
        self.mc_1.currentView.panel_1:visible(false)
        self.txt_1:visible(false)
        if _frame == 1 then
            if data.isShowNum then
                local num = ItemsModel:getItemNumById(data.itemId)
                self.mc_1.currentView.txt_goodsshuliang:setString(num)
                self.mc_1.currentView.txt_goodsshuliang:visible(true)
            else
                self.mc_1.currentView.txt_goodsshuliang:visible(false)
            end
        end
    end
    local iconCtn = self.mc_1.currentView.mc_3.currentView.ctn_1
    iconCtn:removeAllChildren()
    iconCtn:addChild(itemIcon)

    
    if itemData.subType == 311 then ----or itemData.subType == 314
        self.mc_1.currentView:setTouchedFunc(c_func(function()
            echo("------huoqulujing-----")
            WindowControler:showWindow("GetWayListView", data.itemId);
        end,self))
    elseif itemData.subType == 310 then
        if self.itemType == 5 then
        else    
            self.mc_1.currentView:setTouchedFunc(c_func(function()
                self:openCombineUI(data.itemId)
            end,self))
        end
    end

    if self.itemType == 1 then
        FilterTools.clearFilter(self);
    elseif self.itemType == 2 then -- 可装备
        FilterTools.clearFilter(self);
    elseif self.itemType == 3 then -- 可合成
        FilterTools.clearFilter(self);
    elseif self.itemType == 4 then -- 置灰
        FilterTools.setGrayFilter(self);
    elseif self.itemType == 5 then -- 正常显示
    elseif self.itemType == 6 then -- 正常显示
        
    end
    
end

--打开合成UI 
function PartnerCombineItemView:openCombineUI(_itemId)
    PartnerModel:addCombineItemId(_itemId)
    local _id = PartnerModel:getCombineLastItemId()
    local _ui = WindowControler:showWindow("PartnerUpQualityItemCombineView", _itemId,self.partnerId);
    _ui:initUI(_itemId)
    
end

--得到合成道具所需要的碎片数
function PartnerCombineItemView:getNumFrag(itemId,fragId)
    local itemCombineCostVec = FuncPartner.getConbineResById(itemId).cost
    for i,v in pairs(itemCombineCostVec) do
        local costStr = string.split(v,",")
        if tonumber(costStr[1]) == 1 then
            if tostring(costStr[2]) == tostring(fragId) then
                return tonumber(costStr[3])
            end
        end
    end
    return 0
end

function PartnerCombineItemView:registerEvent()
    PartnerCombineItemView.super.registerEvent(self) 

end

return PartnerCombineItemView