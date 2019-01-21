local PartnerEquipmentShenzhuangView = class("PartnerEquipmentShenzhuangView", UIBase)

function PartnerEquipmentShenzhuangView:ctor(winName)
	PartnerEquipmentShenzhuangView.super.ctor(self, winName)
end

function PartnerEquipmentShenzhuangView:loadUIComplete()
	self:setAlignment()
	self:registerEvent()

end


function PartnerEquipmentShenzhuangView:setAlignment()
end

function PartnerEquipmentShenzhuangView:updateUIWithPartner(_partnerInfo)
    --只有在必要的时候才会刷新
    local  _hasChanged=false
    if(not self._partnerInfo or self._partnerInfo.id ~= _partnerInfo.id)then--如果原来没有目标伙伴
        self._partnerInfo = _partnerInfo;
        _hasChanged=true
    else 
        _hasChanged=true
        self._partnerInfo = _partnerInfo
    end
    --如果没有发生任何的变化,则直接返回
    if not _hasChanged then
        return
    end

    --更新UI信息
--    self.data = _partnerInfo
--    self:setPartnerInfo(_partnerInfo)
   
end
--伙伴信息
function PartnerEquipmentShenzhuangView:setPartnerInfo( _partnerInfo)
    self.partnerId = _partnerInfo.id
    local partnerData = FuncPartner.getPartnerById(_partnerInfo.id);
    -- name--品质
    self.panel_1.panel_1.txt_1:setString(GameConfig.getLanguage(partnerData.name).."+".._partnerInfo.quality)
    self.panel_1.panel_1.mc_2:showFrame(_partnerInfo.quality)
    --tpye -- 
    self.panel_1.panel_1.mc_g:showFrame(partnerData.type)
    --战力
    local _ability = FuncPartner.getPartnerAvatar(_partnerInfo)
--    self.panel_1.UI_number:setPower(_ability)
    -- npc
    local ctn = self.panel_1.panel_1.ctn_1
    ctn:removeAllChildren();
    local sp = PartnerModel:initNpc(self.partnerId)
    ctn:addChild(sp);
    
    --初始化装备
    self:initEquipment(partnerData.equipment)

    self:refreshEquipmentInfo("10001")
end
function PartnerEquipmentShenzhuangView:initEquipment(_equipmentData)
    for i,v in pairs(_equipmentData) do
        local equData = FuncPartner.getEquipmentById(v)
        local equPanel = self.panel_1.panel_1["panel_"..i]
        equPanel.mc_1:showFrame(1)
        local ctn = equPanel.mc_1.currentView.ctn_1
        echo("equData.Icon === "..equData.Icon)
        local sprPath = FuncRes.iconItemWithImage("img_Icon1015.png")
        local spr = cc.Sprite:create(sprPath)
        ctn:removeAllChildren()
        ctn:addChild(spr)
        --选择事件
        equPanel:setTap(c_func(self.refreshEquipmentInfo),self,v)
    end
    
end
--刷新装备详情
function PartnerEquipmentShenzhuangView:refreshEquipmentInfo(EquipmentId)
    local equPanel = self.panel_1.panel_2
    local equData = FuncPartner.getEquipmentById(EquipmentId)
    --装备名称
    equPanel.txt_1:setString(GameConfig.getLanguage(equData.name))
    equPanel.mc_1:showFrame(1)
    local ctn = equPanel.mc_1.currentView.ctn_1
    local sprPath = FuncRes.iconItemWithImage("img_Icon1015.png")
    local spr = cc.Sprite:create(sprPath)
    ctn:removeAllChildren()
    ctn:addChild(spr)
end
--按钮显示刷新
function PartnerEquipmentShenzhuangView:refreshBtn()
    -- 一键满级
    if true then
        FilterTools.clearFilter(self.panel_1.btn_1)
    else
        FilterTools.setGrayFilter(self.panel_1.btn_1)
    end
    -- 强化
--    FilterTools.clearFilter(view);
--    FilterTools.setGrayFilter(view);
end
function PartnerEquipmentShenzhuangView:registerEvent()
    PartnerEquipmentShenzhuangView.super.registerEvent();
--    EventControler:addEventListener(PartnerEvent.PARTNER_FRAGMENT_CHANGE_EVENT,self.refreshFragNum,self)
--    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.refreshBtnDisplay, self);
end


return PartnerEquipmentShenzhuangView
