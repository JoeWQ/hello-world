local PartnerUpQualityView = class("PartnerUpQualityView", UIBase)

function PartnerUpQualityView:ctor(winName)
	PartnerUpQualityView.super.ctor(self, winName)
end
function PartnerUpQualityView:updataUI(data)
	self.data = data
    local partnerData = FuncPartner.getPartnerById(self.data.id);
    -----  npc ------
    local ctn = self.panel_1.panel_1.ctn_1;
    ctn:removeAllChildren();
    local sp = PartnerModel:initNpc(self.data.id)
    ctn:addChild(sp);

    local node = display.newLayer();
    node:setContentSize(cc.size(270,315))
    self.panel_1.panel_1:addChild(node,10000)
    node:setPositionY(-315)
    node:setTouchedFunc(c_func(self.openPartnerInfoUI,self))

    ----------- 伙伴信息 ------------
    --姓名
    self.panel_1.panel_1.txt_1:setString(GameConfig.getLanguage(partnerData.name).."+"..data.quality)
    --type
    self.panel_1.panel_1.mc_gfj:showFrame(partnerData.type)
    --描述
    self.panel_1.panel_1.txt_bing:setString(GameConfig.getLanguage(partnerData.charaCteristic))
    --星级
    self.panel_1.panel_1.mc_star:showFrame(data.star)
    --品质
    local color = PartnerModel:getQualityColor(data.id,data.quality)
    self.panel_1.panel_1.mc_2:showFrame(color)
    --显示战力
    local _ability = FuncPartner.getPartnerAvatar(self.data)
    self.panel_1.panel_1.UI_number:setPower(_ability)

    ----------- 升品消耗 ------------
    self:initUpQualityCostList()
    -- 升品增加战力
    local upQualityDataVec = FuncPartner.getPartnerQuality(self.data.id)
    local upQualityData;
    for i,v in pairs(upQualityDataVec) do
        if v.quality == self.data.quality then
            upQualityData = v;
            break
        end
    end
    self.panel_1.panel_j.txt_1:setString(GameConfig.getLanguage(partnerData.name).."+"..data.quality)
    self.panel_1.panel_j.mc_cai:showFrame(color)
    if PartnerModel:getPartnerMaxQuality(data.id) > data.quality then
        self.panel_1.panel_3.txt_1:setString(GameConfig.getLanguage(partnerData.name).."+"..(data.quality+1))
        local color = PartnerModel:getQualityColor(data.id,data.quality+1)
        self.panel_1.panel_3.mc_cai:showFrame(color)
    else
        self.panel_1.panel_3.txt_1:setString(GameConfig.getLanguage(partnerData.name).."+"..(data.quality))
        self.panel_1.panel_3.mc_cai:showFrame(color)
    end
    self:zhihuiItemAndBtn()
end
function PartnerUpQualityView:refreshPower()
    local _ability = FuncPartner.getPartnerAvatar(self.data)
    self.panel_1.panel_1.UI_number:setPower(_ability)
end
function PartnerUpQualityView:initUpQualityCostList()
    local upQualityDataVec = FuncPartner.getPartnerQuality(self.data.id)
    local upQualityData = upQualityDataVec[tostring(self.data.quality)]
    local upQualityCostVec = upQualityData.pellet;
    dump(upQualityCostVec,"升品消耗")
    for i = 1,4 do
        local frame = self:getItemFrame(i,upQualityCostVec[i])
        local item = self.panel_1["UI_"..i]
        item:setResource({itemId = upQualityCostVec[i] ,frame = frame,partnerId = self.data.id ,isShowNum = false })
        -- 加成显示
        local data = FuncPartner.getConbineResById(upQualityCostVec[i])
        if frame == 1 then
            self.panel_1["mc_"..i]:showFrame(2)
        else
            self.panel_1["mc_"..i]:showFrame(1)
        end
        self.panel_1["mc_"..i].currentView.txt_1:setString(PartnerModel:getDesStahe(data.attr[1]))
    end
   self:coinCostAndBtnRefresh()
end
-- 升品合成按钮和铜钱消耗刷新
function PartnerUpQualityView:coinCostAndBtnRefresh()
    -- 铜钱消耗
    self:coinCostOrCondition()
    -- 升品按钮
    if FuncPartner.getPartnerById(self.data.id).maxQuality == self.data.quality and self.data.position == 15 then -- 已升满
        self.panel_1.mc_sp:showFrame(2)
        self.panel_1.mc_wenben:visible(false)
        FilterTools.clearFilter(self.panel_1.mc_sp);
    else    
        self.panel_1.mc_wenben:visible(true)
        self.panel_1.mc_sp:showFrame(1)
        if self:canUpQuality() then
            self.panel_1.mc_sp.currentView.btn_1:getUpPanel().panel_red:visible(true)
            FilterTools.clearFilter(self.panel_1.mc_sp);
        else    
            self.panel_1.mc_sp.currentView.btn_1:getUpPanel().panel_red:visible(false)
            FilterTools.setGrayFilter(self.panel_1.mc_sp);
        end
        self.panel_1.mc_sp.currentView.btn_1:setTap(c_func(self.combineTap,self))
    end
end
--金币消耗或显示不满足条件
function PartnerUpQualityView:coinCostOrCondition()
    local upQualityDataVec = FuncPartner.getPartnerQuality(self.data.id)
    local upQualityData = upQualityDataVec[tostring(self.data.quality)]
    local isEnough,needLevel = self:enoughLevel()
    if isEnough == false then
        self.panel_1.mc_wenben:showFrame(2)
        self.panel_1.mc_wenben.currentView.txt_1:setString("需要"..needLevel.."级可提升")
    else
        if upQualityData.coin > UserModel:getCoin() then
            self.panel_1.mc_wenben:showFrame(1)
            self.panel_1.mc_wenben.currentView.mc_red5000:showFrame(2)
            self.panel_1.mc_wenben.currentView.mc_red5000.currentView.txt_1:setString(upQualityData.coin)
        else
            self.panel_1.mc_wenben:showFrame(1)
            self.panel_1.mc_wenben.currentView.mc_red5000:showFrame(1)
            self.panel_1.mc_wenben.currentView.mc_red5000.currentView.txt_1:setString(upQualityData.coin)
        end
    end    
end

function PartnerUpQualityView:getItemFrame(index,itemId)
    local positions = {}
    local partData = PartnerModel:getPartnerDataById(tostring(self.data.id))
    local value = partData.position or 0
    while value ~= 0 do
		local num = value % 2;
		table.insert(positions, 1, num);
		value = math.floor(value / 2);
	end
    for i = 1 ,4 do
        if positions[i] == nil then
            table.insert(positions, 1, 0);
        end
    end
    -- 判断是否已装备
    if positions[index] and positions[index] == 1 then
        return 1 
    end
    -- 判断是否可装备
    if ItemsModel:getItemNumById(itemId) > 0 then
        return 2
    end
    -- 判断此道具    
    -- 判断是否可合成
    local enough = PartnerModel:isCombineQualityItem(itemId)
    if enough == 3 then
        return 3
    end
    return 4

end
--置灰升品消耗和升品按钮
function PartnerUpQualityView:zhihuiItemAndBtn()
--    if PartnerModel:getPartnerMaxQuality(self.data.id) == self.data.quality then
--        for i = 1,4 do
--            FilterTools.setGrayFilter(self.panel_1["UI_"..i]);
--            FilterTools.setGrayFilter(self.panel_1["mc_"..i]);  
--            FilterTools.setGrayFilter(self.panel_1.btn_1);
--        end
--    end
end
-- 是否可升品  1表示 装备位没有装满 2表示 伙伴等级不满足 3表示 已升到最高品 4表示 铜钱不足
function PartnerUpQualityView:canUpQuality()
    if self.data.position == 15 then
        -- 判断升级是否满足等级
        local ennoughLevel,needLevel = self:enoughLevel()
        if ennoughLevel then
            local maxQuality = FuncPartner.getPartnerById(self.data.id).maxQuality
            if maxQuality > self.data.quality then
                local upQualityDataVec = FuncPartner.getPartnerQuality(self.data.id)
                local upQualityData = upQualityDataVec[tostring(self.data.quality)]
                if upQualityData.coin > UserModel:getCoin() then
                    return false,4,upQualityData.coin
                else
                    return true
                end
            else
                return false,3,self.data.quality
            end
        else    
            return false,2,needLevel
        end

        
        return false
    else
        return false,1,self.data.position
    end
end
--升品条件 是否满足升品等级
function PartnerUpQualityView:enoughLevel()
    local currentPartnerLevle = self.data.level
    local upQualityDataVec = FuncPartner.getPartnerQuality(tostring(self.data.id))[tostring(self.data.quality)]
    local needPartnerLevle = upQualityDataVec.partnerLv;
    if needPartnerLevle > currentPartnerLevle then
        return false,needPartnerLevle,currentPartnerLevle
    else
        return true,needPartnerLevle,currentPartnerLevle
    end
end

function PartnerUpQualityView:openPartnerInfoUI()
    WindowControler:showWindow("PartnerInfoUI",self.data.id)
end

function PartnerUpQualityView:loadUIComplete()
	self:setAlignment()
	self:registerEvent()
end


function PartnerUpQualityView:setAlignment()
	--设置对齐方式
--	FuncCommUI.setViewAlign(self.panel_6, UIAlignTypes.RightTop)
--	FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
--	FuncCommUI.setViewAlign(self.panel_icon, UIAlignTypes.LeftTop)
--  FuncCommUI.setViewAlign(self.btn_help, UIAlignTypes.LeftTop)
--  FuncCommUI.setScale9Align(self.scale9_1,UIAlignTypes.MiddleTop, 1, 0)
end

function PartnerUpQualityView:updateUIWithPartner(_partnerInfo)
    --只有在必要的时候才会刷新
    local  _hasChanged=false
    if(not self._partnerInfo or self._partnerInfo.id ~= _partnerInfo.id)then
        --如果原来没有目标伙伴
        self._partnerInfo = _partnerInfo;
        _hasChanged=true
    else 
        --否则开始计算两者之间的差异
        self._partnerInfo = _partnerInfo
        _hasChanged=true
    end
    --如果没有发生任何的变化,则直接返回
    if not _hasChanged then
        return
    end

    --更新UI信息
    self:updataUI(_partnerInfo);
end
function PartnerUpQualityView:registerEvent()
    PartnerUpQualityView.super.registerEvent();

    EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_POSITION_CHANGE_EVENT,self.refreshPower,self)
    EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_ITEM_COMBINE_EVENT,self.initUpQualityCostList,self)
    EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_ITEM_COMBINE_EVENT,self.refreshPower,self)
     --金币增加
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.coinCostAndBtnRefresh, self);
end
--升品按钮注册事件
function PartnerUpQualityView:combineTap()
    local isCan,_type,_value = self:canUpQuality()
    if isCan then
        if PartnerModel:getPartnerMaxQuality(self.data.id) > self.data.quality then
            PartnerServer:qualityLevelupRequest(self.data.id, c_func(self.combineTapCallBack,self))
        else
            WindowControler:showTips("已经升到最高品阶")
        end
    else
        if _type == 3 then
            WindowControler:showTips("已经升到最高品阶")
        elseif _type == 1 then 
            WindowControler:showTips(GameConfig.getLanguage("#tid1561"))
        elseif _type == 2 then 
            WindowControler:showTips(_value .. "级以上的伙伴才能升级")
        elseif _type == 4 then 
            WindowControler:showTips(GameConfig.getLanguage("#tid1557"))
        end
    end
end
--升品回调
function PartnerUpQualityView:combineTapCallBack(event)
    --更新UI信息
    if event.error == nil then
        self:updataUI(self.data);
        -- 刷新红点提示
        EventControler:dispatchEvent(PartnerEvent.PARTNER_TOP_REDPOINT_EVENT)
    end
end

return PartnerUpQualityView
