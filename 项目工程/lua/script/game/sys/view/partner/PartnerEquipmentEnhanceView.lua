local PartnerEquipmentEnhanceView = class("PartnerEquipmentEnhanceView", UIBase)

function PartnerEquipmentEnhanceView:ctor(winName)
	PartnerEquipmentEnhanceView.super.ctor(self, winName)
end

function PartnerEquipmentEnhanceView:loadUIComplete()
	self:setAlignment()
	self:registerEvent()
end


function PartnerEquipmentEnhanceView:setAlignment()
end

function PartnerEquipmentEnhanceView:updateUIWithPartner(_partnerInfo)
    --更新UI信息
    self.data = _partnerInfo
    self.selectEquipmentId = nil
    self:setPartnerInfo(_partnerInfo)
   
end
--伙伴信息
function PartnerEquipmentEnhanceView:setPartnerInfo( _partnerInfo)
    self.partnerId = _partnerInfo.id
    local partnerData = FuncPartner.getPartnerById(_partnerInfo.id);
    -- name--品质
    self.panel_1.panel_1.txt_1:setString(GameConfig.getLanguage(partnerData.name).."+".._partnerInfo.quality)
    self.panel_1.panel_1.mc_2:showFrame(_partnerInfo.quality)
    --tpye -- 
    self.panel_1.panel_1.mc_g:showFrame(partnerData.type)
    --战力
--    local _ability = FuncPartner.getPartnerAvatar(_partnerInfo)
--    self.panel_1.UI_number:setPower(_ability)
    -- npc
    local ctn = self.panel_1.panel_1.ctn_1
    ctn:removeAllChildren();
    local sp = PartnerModel:initNpc(self.partnerId)
    sp:setScaleX(-1.2)
    sp:setScaleY(1.2)
    ctn:addChild(sp);

    local node = display.newLayer();
    node:setContentSize(cc.size(140,210))
    self.panel_1.panel_1:addChild(node,10000)
    node:setPositionY(-250)
    node:setPositionX(80)
    node:setTouchedFunc(c_func(self.openPartnerInfoUI,self))
    
    --初始化装备
    self:initEquipment(partnerData.equipment)
    self:refreshEquipmentInfo(self.selectEquipmentId)
end
function PartnerEquipmentEnhanceView:openPartnerInfoUI()
    WindowControler:showWindow("PartnerInfoUI",self.data.id)
end
function PartnerEquipmentEnhanceView:initEquipment(_equipmentData)
    self.equipmentVec = {}
    for i,v in pairs(_equipmentData) do
        local equData = FuncPartner.getEquipmentById(v)
        local equPanel = self.panel_1.panel_1["panel_"..i]
        local equipData = self:getEquipmentData(v)
        self.equipmentVec[v] = equPanel
        --判断是否开启
        if self:equipmentLockState(v) then
            equData = equData[tostring(equipData.level)]
            equPanel.panel_suo:visible(false)
            equPanel.txt_1:setString(equData.showLv[1].key)
            equPanel.txt_1:visible(true)
            equPanel.txt_2:visible(false)
            FilterTools.clearFilter(equPanel.mc_1)
            equPanel.mc_1:showFrame(equData.quality)
            -- 判断此装备是否可升级
            local isShowRed = self:equipmentCanUp(v)
            equPanel.panel_red:visible(isShowRed)
            --选择事件
            equPanel:setTouchedFunc(c_func(self.refreshEquipmentInfo,self,v))
        else
            --未开启 默认为1 级
            equData = equData[tostring(equipData.level)] 
            equPanel.panel_suo:visible(true)
            equPanel.txt_1:visible(false)
            equPanel.txt_2:visible(true)
            --装备解锁条件
            local strLock = GameConfig.getLanguageWithSwap("#tid1556",equData.needLv)
            equPanel.txt_2:setString(strLock)
            FilterTools.setGrayFilter(equPanel.mc_1)
            equPanel.mc_1:showFrame(equData.quality)
            equPanel.panel_red:visible(false)
            --选择事件
            equPanel:setTouchedFunc(c_func(function ()
                WindowControler:showTips("尚未开启")
            end,self))
        end
        local ctn = equPanel.mc_1.currentView.ctn_1
        local sprPath = FuncRes.iconPartnerEquipment(equData.icon)
        local spr = cc.Sprite:create(sprPath)
        spr:setScale(1.14)
        ctn:removeAllChildren()
        ctn:addChild(spr)
    end
end
-- 判断此装备是否可升级 或者 升品
function PartnerEquipmentEnhanceView:equipmentCanUp(equipId)
    local equData = self:getEquipmentData(equipId)
    local isShowRed = false
    if self:enhanceCostEnough(equData.level,equipId) == 0 and self:equipLevelLimit(equipId) then
        isShowRed = true
    end
    return isShowRed
end
-- 判断装备升级的等级限制条件
function PartnerEquipmentEnhanceView:equipLevelLimit(equipId)
    local equData = self:getEquipmentData(equipId)
    local equCfgData = FuncPartner.getEquipmentById(equipId)
    equCfgData = equCfgData[tostring(equData.level)]
    if self.data.level >= equCfgData.needLv then
        return true
    else
        return false
    end
end

-- 获取单个装备信息 
function PartnerEquipmentEnhanceView:getEquipmentData(_id)
    return self.data.equips[tostring(_id)]
end
--装备解锁状态
function PartnerEquipmentEnhanceView:equipmentLockState(equipmentId)
    return true
--    --当前伙伴id 
--    local level = self.data.level
--    --当前装备信息
--    local equipData = self:getEquipmentData(equipmentId)
--    --装备解锁限制条件
--    local equData = FuncPartner.getEquipmentById(equipmentId)
--    local needLevel = equData[tostring(equipData.level)].needLv or 0 
--    echo("equipmentId ==="..equipmentId.."---- needlevel == "..needLevel .. "   level == "..level)
--    if level >= needLevel then
--        return true   
--    else
--        return false
--    end
end
--装备选中状态
function PartnerEquipmentEnhanceView:refreshEquipmentSelectedSate()
    for i,v in pairs(self.equipmentVec) do
        if i == self.selectEquipmentId then
            v.panel_1:visible(true)
        else
            v.panel_1:visible(false)
        end
    end
    
end
--刷新装备详情 
function PartnerEquipmentEnhanceView:refreshEquipmentInfo(EquipmentId)
    if EquipmentId == nil then
        local partnerData = FuncPartner.getPartnerById(self.data.id).equipment;
        self.selectEquipmentId = FuncPartner.getPartnerById(self.data.id).equipment[1]
        EquipmentId = self.selectEquipmentId
    else
        self.selectEquipmentId = EquipmentId
    end

    --装备选中状态暂时放在这
    self:refreshEquipmentSelectedSate()
    
    local equipData = self:getEquipmentData(self.selectEquipmentId) 

    local equPanel = self.panel_1.panel_2
    local equLevel = equipData.level -- 装备等级
    local equData = FuncPartner.getEquipmentById(self.selectEquipmentId)
    equData = equData[tostring(equLevel)]
    --装备名称
    equPanel.txt_1:setString(GameConfig.getLanguage(equData.name))
    equPanel.mc_1:showFrame(equData.quality)
    local ctn = equPanel.mc_1.currentView.ctn_1
    local sprPath = FuncRes.iconPartnerEquipment(equData.icon)
    local spr = cc.Sprite:create(sprPath)
    spr:setScale(1.14)
    ctn:removeAllChildren()
    ctn:addChild(spr)
    --等级
    equPanel.txt_2:setString("等级: "..equData.showLv[1].key.."/"..equData.showLv[1].value)
    --加成
    plusVec = equData.subAttr or equData.subAttrPlus
    equPanel.panel_di:visible(false)
    local txtCtn = equPanel.ctn_1
    txtCtn:removeAllChildren()
    for i,v in pairs(plusVec) do
        local _panel = UIBaseDef:cloneOneView(equPanel.panel_di)
        _panel.txt_3:setString(PartnerModel:getDesStaheTable(v))
        txtCtn:addChild(_panel)
        _panel:setPositionY(_panel:getPositionY()-(i-1)*35)
    end
    

    --强化消耗
    local costPanel = self.panel_1.panel_3
    local costItemView = costPanel.mc_1
    costItemView:visible(false)
    costPanel.ctn_1:removeAllChildren()
    local costVec = equData.lvCost or equData.qualityCost;
    if costVec then
        for i,v in pairs(costVec) do
            local str = string.split(v,",")
            if tonumber(str[1]) == 1 then
                local itemView = UIBaseDef:cloneOneView(costItemView)
                itemView:setPositionX(itemView:getPositionX() + (i-1)*100)
                costPanel.ctn_1:addChild(itemView)
                self:initCostItem(itemView,str[2],tonumber(str[3]))
            elseif  tonumber(str[1]) == 3 then -- 铜钱   
                --判断等级是否满足
                if self:equipLevelLimit(self.selectEquipmentId) then
                    if tonumber(str[2]) > UserModel:getCoin() then
                        self.panel_1.mc_tong:showFrame(2)
                    else
                        self.panel_1.mc_tong:showFrame(1)
                    end
                    self.panel_1.mc_tong.currentView.txt_1:setString(str[2])
                else
                    self.panel_1.mc_tong:showFrame(3)
                    self.panel_1.mc_tong.currentView.txt_1:setString("需要"..equData.needLv.."级可强化")
                end
            end
        end
    end
    
    self:refreshBtn()
end

--消耗道具显示
function PartnerEquipmentEnhanceView:initCostItem(view,itemId,needNum)
    local num = ItemsModel:getItemNumById(itemId);
    view:showFrame(1)
    local _view = view.currentView

    local itemData = FuncItem.getItemData(itemId)
    _view.mc_1:showFrame(1)
    local ctn = _view.mc_1.currentView.ctn_1;
    local sprPath = FuncRes.iconItemWithImage(itemData.icon)
    local spr = cc.Sprite:create(sprPath)
    spr:setScale(1.14)
    ctn:removeAllChildren()
    ctn:addChild(spr)
    if num >= needNum then
        _view.panel_lv:visible(false)
        FilterTools.clearFilter(_view.mc_1)
        view.currentView.txt_1:setColor(cc.c3b(0x8E,0x5F,0x35));
    else
        _view.panel_lv:visible(true)
        FilterTools.setGrayFilter(_view.mc_1)
        view.currentView.txt_1:setColor(cc.c3b(255,0,0));
        _view.panel_lv:setTouchedFunc(c_func(function ()
            WindowControler:showWindow("GetWayListView", itemId);
        end,self))
    end
    view.currentView.txt_1:setString(num .."/"..needNum)
end
--按钮刷新
function PartnerEquipmentEnhanceView:refreshBtn()
    local equData = self:getEquipmentData(self.selectEquipmentId)
    --判断当前是否时升品状态
    local equCfgData = FuncPartner.getEquipmentById(self.selectEquipmentId)
    equCfgData = equCfgData[tostring(equData.level)]
    local isQuality = false
    local isMaxLevel = PartnerModel:equipLevelMax(self.selectEquipmentId,equData.level)
    if isMaxLevel then
        self.panel_1.btn_1:visible(false)
        self.panel_1.mc_1:showFrame(3)     
        self.panel_1.mc_tong:visible(false)
    else 
        self.panel_1.mc_tong:visible(true) 
        self.panel_1.btn_1:visible(true)  
        if equCfgData.showLv[1].key == equCfgData.showLv[1].value then
            --现在是升品状态
            self.panel_1.mc_1:showFrame(2)
            isQuality = true
        else
            self.panel_1.mc_1:showFrame(1)
        end

        if self:enhanceCostEnough(equData.level) == 0 and self:equipLevelLimit(self.selectEquipmentId) then
            if isQuality then
                FilterTools.setGrayFilter(self.panel_1.btn_1)
                self.panel_1.btn_1:getUpPanel().panel_red:visible(false)
            else
                FilterTools.clearFilter(self.panel_1.btn_1)
                self.panel_1.btn_1:getUpPanel().panel_red:visible(true)
            end
            FilterTools.clearFilter(self.panel_1.mc_1.currentView)
            self.panel_1.mc_1.currentView.panel_red:visible(true)
        else
            FilterTools.setGrayFilter(self.panel_1.btn_1)
            FilterTools.setGrayFilter(self.panel_1.mc_1.currentView) 
            self.panel_1.btn_1:getUpPanel().panel_red:visible(false)
            self.panel_1.mc_1.currentView.panel_red:visible(false) 
        end
    end
    self.panel_1.mc_1.currentView.btn_2:setTap(c_func(self.equipmentEnhanceTap,self,2))
end
--计算一键升级 最多可生的级数
function PartnerEquipmentEnhanceView:getMaxEnhance()
    local equData = FuncPartner.getEquipmentById(self.selectEquipmentId)
    local _equipData = self:getEquipmentData(self.selectEquipmentId)
    local addLevel = 0
    local isAdd = true
    local _level = _equipData.level
    local logs = {}
    while isAdd do
        local _equData = equData[tostring(_level)]
        if _equData.needLv > self.data.level or _equData.showLv[1].key == _equData.showLv[1].value then
            --伙伴等级判断  升品等级等级判断
            isAdd = false
            break
        end
        local costVec = _equData.lvCost or _equData.qualityCost;
        for i,v in pairs(costVec) do
            local str = string.split(v,",")
            if tonumber(str[1]) == 1 then
                local num = 0
                if logs[str[2]] then
                    if logs[str[2]] - tonumber(str[3]) < 0 then
                        isAdd = false
                    else
                        logs[str[2]] = logs[str[2]] - tonumber(str[3])
                    end
                else    
                    num = ItemsModel:getItemNumById(str[2]) - tonumber(str[3])
                    if num < 0 then
                        isAdd = false  
                    else
                        logs[str[2]] = num
                    end
                end
            elseif  tonumber(str[1]) == 3 then -- 铜钱   
                if logs[str[1]] then
                    if logs[str[1]] - tonumber(str[2]) < 0 then
                        isAdd = false
                    else
                        logs[str[1]] = logs[str[1]] - tonumber(str[2])
                    end
                else
                    local num = UserModel:getCoin() - tonumber(str[2])
                    if num < 0 then
                        isAdd = false
                    else
                        logs[str[1]] = num
                    end
                end
            end
        end
        if isAdd then
            _level = _level + 1
            addLevel = addLevel + 1
        end 
    end
    return addLevel
end
--道具强化 1一键满级 2强化
function PartnerEquipmentEnhanceView:equipmentEnhanceTap(_type)
    local equipData = self:getEquipmentData(self.selectEquipmentId)
    local costRes,itemId = self:enhanceCostEnough(equipData.level)
    local b = true -- 一键满级是否满足
    local equCfgData = FuncPartner.getEquipmentById(self.selectEquipmentId)
    equCfgData = equCfgData[tostring(equipData.level)]
    if _type == 1  then
        if equCfgData.showLv[1].key == equCfgData.showLv[1].value then
            b = false --现在是升品状态
        end
    end
    local isMaxLevel = PartnerModel:equipLevelMax(self.selectEquipmentId,equipData.level)
    if costRes == 0 and self:equipLevelLimit(self.selectEquipmentId) and b and isMaxLevel == false then --满足条件
        local addLevel = 1
        if _type == 1 then -- 一键满级
            addLevel = self:getMaxEnhance()
        elseif _type == 2 then -- 强化
            addLevel = 1
        end
        local _param = {}
        _param.partnerId = tostring(self.data.id)
        _param.equipId = self.selectEquipmentId
        _param.level = addLevel
        PartnerServer:equipUpgradeRequest(_param,c_func(self.equipmentEnhanceTapCallBack,self))
    else
        if isMaxLevel == true then --装备以满级
            WindowControler:showTips("装备已满级")
        elseif costRes == 1 or costRes == 11 then --道具不满足
            WindowControler:showTips(GameConfig.getLanguage("#tid1561"))
        elseif costRes == 2 or costRes == 12 then -- 金币不满足   
            WindowControler:showTips(GameConfig.getLanguage("#tid1557"))
        elseif self:equipLevelLimit(self.selectEquipmentId) == false then --等级条件
            WindowControler:showTips(GameConfig.getLanguage("#tid1559")) 
        elseif b == false then  -- 一键满级
            WindowControler:showTips(GameConfig.getLanguage("#tid1560")) 
        end
    end
end
function PartnerEquipmentEnhanceView:equipmentEnhanceTapCallBack(event)
    if event.error == nil then
        self.data = PartnerModel:getPartnerDataById(self.data.id)
        self:setPartnerInfo(self.data)
    end
end
--强化消耗是否满足  0 可以升级或升阶
--                  1--强化消耗碎片不满足  2--强化消耗金币 不足
--                  11--升阶消耗碎片不满足  12--升阶消耗金币 不足
function PartnerEquipmentEnhanceView:enhanceCostEnough(_level,_equipId)
    local equipId = _equipId or self.selectEquipmentId
    local equData = FuncPartner.getEquipmentById(equipId)
    equData = equData[tostring(_level)]
    local costVec = equData.lvCost or equData.qualityCost;
    local _type = 0
    if equData.showLv[1].key == equData.showLv[1].value then
        _type = 10 --现在是升品状态
    end
    if costVec == nil then
        return 3
    end
    for i,v in pairs(costVec) do
        local str = string.split(v,",")
        if tonumber(str[1]) == 1 then
            local num = ItemsModel:getItemNumById(str[2])
            if num < tonumber(str[3]) then 
                return 1+_type , itemId 
            end
        elseif  tonumber(str[1]) == 3 then -- 铜钱   
            if tonumber(str[2]) > UserModel:getCoin() then
                return 2+_type 
            end
        end
    end
    return 0
end
--铜钱变化刷新
function PartnerEquipmentEnhanceView:coinChangeRefresh()
    local equipData = self:getEquipmentData(self.selectEquipmentId) 
    local equLevel = equipData.level -- 装备等级
    local equData = FuncPartner.getEquipmentById(self.selectEquipmentId)
    equData = equData[tostring(equLevel)]
    local costVec = equData.lvCost or equData.qualityCost;
    if costVec then
        for i,v in pairs(costVec) do
            local str = string.split(v,",")
            if  tonumber(str[1]) == 3 then -- 铜钱   
                if tonumber(str[2]) > UserModel:getCoin() then
                    self.panel_1.mc_tong:showFrame(2)
                else
                    self.panel_1.mc_tong:showFrame(1)
                end
                self.panel_1.mc_tong.currentView.txt_1:setString(str[2])
            end
        end
    end
    self:refreshBtn()
end
function PartnerEquipmentEnhanceView:registerEvent()
    PartnerEquipmentEnhanceView.super.registerEvent();
    self.panel_1.btn_1:setTap(c_func(self.equipmentEnhanceTap,self,1))

    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.coinChangeRefresh, self);
end
return PartnerEquipmentEnhanceView
