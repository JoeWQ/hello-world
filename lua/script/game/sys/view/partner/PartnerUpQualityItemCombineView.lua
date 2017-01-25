--伙伴系统伙伴合成
--2016-12-10 15:18:50
--Author:xiaohuaxiong
local PartnerUpQualityItemCombineView = class("PartnerUpQualityItemCombineView",UIBase)

function PartnerUpQualityItemCombineView:ctor(_winName,itemId,partnerId)
    PartnerUpQualityItemCombineView.super.ctor(self,_winName)
    self.itemEquipId = itemId
    self.partnerId = partnerId
end

function PartnerUpQualityItemCombineView:loadUIComplete()
    self:registerEvent()
    self:initEquipUI(self.itemEquipId)
end

--装备显示
function PartnerUpQualityItemCombineView:initEquipUI(_itemId)
     local itemCombineData = FuncPartner.getConbineResById(_itemId)
     local itemData = FuncItem.getItemData(_itemId)

     ------------ 装备显示 -----------
     -- 显示
     self.panel_1.UI_1:setResource({itemId = _itemId,num = 0 ,frame = 5,isShowNum = false})
     -- 名称
     self.panel_1.txt_1:setString(GameConfig.getLanguage(itemData.name))
     -- 数量
     local num = ItemsModel:getItemNumById(_itemId);
     self.panel_1.txt_3:setString(num)
     if num > 9999 then
        num = 9999
    end
    self.initTxt4PosX = self.panel_1.txt_4:getPositionX()
    local numArr = number.split( num )
    echo("weishu ======= "..#numArr)
    self.panel_1.txt_4:setPositionX(self.initTxt4PosX - (4 - #numArr) * 12)
     -- 描述
     self.panel_1.txt_5:setString(GameConfig.getLanguage(itemData.des))   
     -- 属性
     local plusVec = itemCombineData.attr  
     self.panel_1.panel_1.txt_1:visible(false)    
     self.panel_1.panel_1.txt_2:visible(false)
     self.panel_1.panel_1.txt_3:visible(false)
     for i,v in pairs(plusVec) do
        self.panel_1.panel_1["txt_"..i]:visible(true)    
        self.panel_1.panel_1["txt_"..i]:setString(PartnerModel:getDesStahe(v))
     end
end

function PartnerUpQualityItemCombineView:initUI(_itemId)
     self.itemId = _itemId
     local itemCombineData = FuncPartner.getConbineResById(_itemId)
     local itemData = FuncItem.getItemData(_itemId)

     ------------合成显示-------------
     local combineCostVec = itemCombineData.cost;
     local frameNum = 3 - #combineCostVec + 2
     dump(combineCostVec,"combineCostVec")
     self.panel_1.panel_2.mc_1:showFrame(frameNum)
     for i = 1, (#combineCostVec + 1) do
        local  _id;
        local frame;
        if i == 1 then
            _id = self.itemId
            frame = 5
        else
            local idStr = combineCostVec[i-1]
            local idStrVec = string.split(idStr,",");
            if tonumber(idStrVec[1]) == 1 then
                _id = idStrVec[2]
                frame = PartnerModel:getItemFrame(idStrVec[2],self.itemId,self.partnerId)
            elseif tonumber(idStrVec[1]) == 3 then
                if UserModel:getCoin() >= tonumber(idStrVec[2]) then
                    self.panel_1.panel_2.mc_tong:showFrame(1)
                else
                    self.panel_1.panel_2.mc_tong:showFrame(2)
                end
                self.panel_1.panel_2.mc_tong.currentView.txt_1:setString(idStrVec[2])
            end
        end
        if i ~= (#combineCostVec + 1)  then
            self.panel_1.panel_2.mc_1.currentView["UI_"..i]:setResource({parentItemId = self.itemId,itemId = _id,num = 0 ,frame = frame,partnerId = self.partnerId,isShowNum = true})
        end
        
     end
     
     --道具名字
     self.panel_1.panel_2.txt_1:setString(GameConfig.getLanguage(itemData.name))

     ------------------- 刷新按钮 ---------------------
     self:btnFresh()
     ------------------- 刷新顶部提示 ----------------------
     self:combineTop()
end
function PartnerUpQualityItemCombineView:getItemFrame(itemId,partnerId)
    local positions = {}
    local value = 8
    while value ~= 0 do
		local num = value % 2;
		table.insert(positions, 1, num);
		value = math.floor(value / 2);
	end
    -- 判断是否已装备

    if positions[index] and positions[index] == 1 then
        return 1 
    end
    -- 判断是否可装备
    if ItemsModel:getItemNumById(itemId) > 0 then
        return 2
    end
    -- 判断是否可合成
    local enough = PartnerModel:isCombineQualityItem(itemId)
    if enough == 1 then
        return 4
    end
    
    return 3

end

--按钮 刷新
 function PartnerUpQualityItemCombineView:btnFresh()
    -- 合成按钮
    local btn2 = self.panel_1.panel_2.btn_2
    -- 判断是否可合成

    local canCombine = PartnerModel:isCombineQualityItem(self.itemId)
    
    if canCombine == 3 then
        FilterTools.clearFilter(btn2);
        btn2:setTap(c_func(self.combineTap,self))
    elseif canCombine == 1 then 
        FilterTools.setGrayFilter(btn2);
        btn2:setTap(c_func(function ()
            WindowControler:showTips(GameConfig.getLanguage("#tid1561"))
        end,self))
    elseif canCombine == 2 then 
        FilterTools.setGrayFilter(btn2);
        btn2:setTap(c_func(function ()
            WindowControler:showTips(GameConfig.getLanguage("#tid1557"))
        end,self))
    end
    -- 装备按钮
    local btn1 = self.panel_1.btn_1
    if ItemsModel:getItemNumById(self.itemEquipId) > 0 then
        if PartnerModel:upQualityEquiped(self.itemEquipId,self.itemEquipId,self.partnerId) then
            FilterTools.setGrayFilter(btn1);
            btn1:setTap(c_func(function ()
                WindowControler:showTips("已装备")
            end,self))
        else
            FilterTools.clearFilter(btn1); 
            btn1:setTap(c_func(self.equipTap,self))
        end
        
    else
        FilterTools.setGrayFilter(btn1);
        btn1:setTap(c_func(function ()
            WindowControler:showTips("装备条件不满足")
        end,self))
    end
    
 end
 function PartnerUpQualityItemCombineView:combineTap()
    local canCombine = PartnerModel:isCombineQualityItem(self.itemId)
    if canCombine == 1 then
        WindowControler:showTips("碎片不足！")
    elseif canCombine == 2 then 
        WindowControler:showTips("金币不足！")
    elseif canCombine == 3 then 
        echo("--------------合成之前 数量 "..self.itemId.." = ".. ItemsModel:getItemNumById(self.itemId) )
        PartnerServer:qualityItemLevelupRequest(self.itemId, c_func(self.combineCallBack,self))
    end
 end
 function PartnerUpQualityItemCombineView:combineCallBack(event)
    echo("++++++++++++++++++ 服务器返回------------------")
    if event.error == nil then
        local num = ItemsModel:getItemNumById(self.itemEquipId);
        if num > 9999 then
            num = 9999
        end
        local numArr = number.split( num )
        self.panel_1.txt_4:setPositionX(self.initTxt4PosX - (4 - #numArr) * 10)
        self.panel_1.txt_3:setString(num)
        self:initUI(self.itemId)
        EventControler:dispatchEvent(PartnerEvent.PARTNER_QUALITY_ITEM_COMBINE_EVENT)
    end
 end

 --装备
 function PartnerUpQualityItemCombineView:equipTap()
    local pos = PartnerModel:getUpqualityPosition(self.itemEquipId,self.partnerId);
    if pos >= 0 and pos < 4 then
        PartnerServer:qualityItemEquipRequest({ position = tostring(pos),partnerId = tostring(self.partnerId) }, c_func(self.equipTapCallBack,self))
    else
        WindowControler:showTips("位置取得有问题")
    end
    
 end
 function PartnerUpQualityItemCombineView:equipTapCallBack(event)
    echo("++++++++++++++++++ 服务器返回------------------")
    if event.error == nil then
--        local num = ItemsModel:getItemNumById(self.itemEquipId);
--        self.panel_1.txt_3:setString(num)
--        local btn1 = self.panel_1.btn_1
--        if ItemsModel:getItemNumById(self.itemEquipId) > 0 then
--            if PartnerModel:getItemFrame(self.itemEquipId,self.itemEquipId,self.partnerId) == 1 then
--                FilterTools.setGrayFilter(btn1);
--                btn1:setTap(c_func(function ()
--                    WindowControler:showTips("已装备")
--                end,self))
--            else
--                FilterTools.clearFilter(btn1); 
--                btn1:setTap(c_func(self.equipTap,self))
--            end

--        else
--            FilterTools.setGrayFilter(btn1);
--            btn1:setTap(c_func(function ()
--                WindowControler:showTips("装备条件不满足")
--            end,self))
--        end
        PartnerModel:clearCombine()
        EventControler:dispatchEvent(PartnerEvent.PARTNER_QUALITY_ITEM_COMBINE_EVENT)
        self:startHide()
    end
 end
 -- 合成顶部列表
 function PartnerUpQualityItemCombineView:combineTop()
    local itemVec = PartnerModel:getCombineItemId()
    self.panel_1.panel_2.mc_duo:showFrame(#itemVec)
    for i,v in pairs(itemVec) do
        self.panel_1.panel_2.mc_duo.currentView["UI_"..i]:setResource({itemId = v,num = 0 ,frame = 5,partnerId = self.partnerId ,isShowNum = false})
    end
    
 end

function PartnerUpQualityItemCombineView:registerEvent()
    PartnerUpQualityItemCombineView.super.registerEvent(self)
    self.panel_1.btn_back:setTap(c_func(function ()
        PartnerModel:deleteCombineItemId(self.itemId)
        local _id = PartnerModel:getCombineLastItemId()
        if _id == nil then
            PartnerModel:clearCombine()
            self:startHide()
        else
            self.itemId = _id
            self:initUI(self.itemId)
        end
        
    end,self))
    
end

return PartnerUpQualityItemCombineView