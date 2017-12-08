local CompResItemView = class("CompResItemView", ItemBase);

function CompResItemView:ctor(winName)
    CompResItemView.super.ctor(self, winName);
    
    self:initData()
end

function CompResItemView:loadUIComplete()
    self:registerEvent();
end 

function CompResItemView:registerEvent()
    CompResItemView.super.registerEvent();
end

function CompResItemView:initData()
    self.itemSubTypes = {
        ITEM_SUBTYPE_201 = 201,         --法宝碎片
        ITEM_SUBTYPE_202 = 202,         --伙伴碎片
    }
end

-- 更新itemUI
function CompResItemView:updateItemUI()
    -- 初始化数据
    local itemId = self.itemId
    local itemNum = self.itemNum
    
    local itemName = nil
    local itemIcon = nil

    local quality = nil
    local qualityMc = self.panelInfo.mc_kuang
    -- 道具类型资源
    if itemId ~= nil then
        local itemType = self.itemType

        -- 如果是碎片
        if itemType ~= nil and tonumber(itemType) == ItemsModel.itemType.ITEM_TYPE_PIECE then
            -- 资质
            quality = FuncItem.getItemQuality(itemId)

            -- 如果是法宝碎片
            if self.itemSubType == self.itemSubTypes.ITEM_SUBTYPE_201 then
                itemIcon = display.newSprite(FuncRes.iconTreasure(itemId)):anchor(0.5,0.5)
                itemIcon:setScale(0.44)

            -- 如果是伙伴碎片
            elseif self.itemSubType == self.itemSubTypes.ITEM_SUBTYPE_202 then
                local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
                headMaskSprite:anchor(0.5,0.5)
                headMaskSprite:pos(-1,0)
                headMaskSprite:setScale(0.95)

                tempItemIcon = display.newSprite(FuncRes.iconHero(FuncItem.getItemData(itemId).icon)):anchor(0.5,0.5)
                tempItemIcon:setScale(0.8)

                -- 通过遮罩实现头像裁剪
                itemIcon = FuncCommUI.getMaskCan(headMaskSprite,tempItemIcon)
            end
        else
            itemIcon = display.newSprite(FuncRes.iconItem(itemId)):anchor(0.5,0.5)
            itemIcon:setScale(1.0)

            -- 道具边框颜色
            quality = FuncItem.getItemQuality(itemId)
        end

        itemName = FuncItem.getItemName(itemId)

    -- 非道具类型资源
    else
        local rewardType = self.rewardType
        itemNum = self.rewardNum
        
        -- 完整法宝
        if tostring(rewardType) == FuncDataResource.RES_TYPE.TREASURE then
            local treasureId = self.rewardId
            itemIcon = display.newSprite(FuncRes.iconTreasure(treasureId))
            itemIcon:setScale(0.5)

            local treasureName = FuncTreasure.getValueByKeyTD(treasureId,"name")
            treasureName = GameConfig.getLanguage(treasureName)

            -- 法宝名字
            itemName = treasureName

            -- 法宝资质
            quality = FuncTreasure.getValueByKeyTD(treasureId,"quality")

        -- 完整伙伴
        elseif tostring(rewardType) == FuncDataResource.RES_TYPE.PARTNER then
            local partnerId = self.rewardId
            -- 伙伴资质
            local partnerInfo = FuncPartner.getPartnerById(partnerId)

            itemIcon = display.newSprite(FuncRes.iconHero(partnerInfo.icon)):anchor(0.5,0.5)
            itemIcon:setScale(0.8)
            
            quality = tonumber(partnerInfo.initQuality)

        -- 其他类资源
        else
            itemIcon = display.newSprite(FuncRes.iconRes(rewardType)):anchor(0.5,0.5)
            itemName = FuncDataResource.getResNameById(tonumber(rewardType))

            quality = FuncDataResource.getQualityById(rewardType)
        end
    end 

    if not quality  then
        echoError("rewardType:",rewardType,"没有quality")
    else
        if qualityMc then
            qualityMc:showFrame(quality)
        end
    end
    self.qualityMc = qualityMc

    -- 道具icon
    local iconCtn = self.panelInfo.ctn_1
    iconCtn:removeAllChildren()
    iconCtn:addChild(itemIcon)

    
    -- 道具数量
    local txtNum = self.panelInfo.txt_goodsshuliang
    if tonumber(itemNum) > 9999 then
        itemNum = 9999
    end
    txtNum:setString(itemNum)

    -- 道具小红点
    local redPanel = self.panelInfo.panel_red
    -- 默认不显示小红点
    if redPanel then
        redPanel:setVisible(false)
    end

    -- 道具名称
    --itemName = GameConfig.getLanguage(itemName)

    -- 不带数量的名称
    self.itemNameWithNotNum = itemName
    -- 带数量的名称
    self.itemNameWithNum = GameConfig.getLanguageWithSwap("tid_common_1018",itemName,itemNum)

    -- 默认使用带数量的名称
    local nameTxt = self.panelInfo.mc_zi.currentView.txt_1
    nameTxt:setString(self.itemNameWithNum)
end
     
--设置道具数据
-- data 为用户已获取道具的动态数据
function CompResItemView:setItemData(data)
    CompResItemView.super.setItemData(self,data)
   
    self.itemId = data.itemId
    self.itemNum = data.itemNum or 0

    local itemData = FuncItem.getItemData(self.itemId )
    self.itemType = itemData.type
    self.itemSubType = itemData.subType or 0
     -- 根据viewType初始化UI
    self:initUI()
    self:updateItemUI()
end

function CompResItemView:setClickBtnCallback(cfunc)
    self.mc_1.currentView.btn_1:setTap(cfunc)
end

-- 设置奖品数据
function CompResItemView:setRewardItemData(data)
    CompResItemView.super.setItemData(self,data)

    self.rewardStr = data.reward
    local data = string.split(self.rewardStr,",")
    local rewardType = data[1]
    local rewardId = nil
    local rewardNum = 0

    -- 如果奖品是道具
    if tostring(rewardType) == UserModel.RES_TYPE.ITEM then
        rewardId = data[2]
        rewardNum = data[3]

       local data = {
            itemId = rewardId,
            itemNum = rewardNum,
       }
       self:setItemData(data)

    -- 奖品为非道具资源
    else
        self.itemType = nil
        -- 如果奖品是法宝
        if tostring(rewardType) == UserModel.RES_TYPE.TREASURE 
            or tostring(rewardType) == UserModel.RES_TYPE.PARTNER then
            rewardId = data[2]
            rewardNum = 1

            self.rewardId = rewardId
            self.rewardType = rewardType
        else
            rewardNum = data[2]
        end
        
        -- 非道具类型资源，将道具id设置为nil
        self.itemId = nil

        self.rewardType = rewardType
        self.rewardNum = rewardNum

        -- 根据viewType初始化UI
        self:initUI()
        self:updateItemUI()
    end
end

function CompResItemView:initUI()
    -- 如果是碎片
    -- echo("===self.rewardType====self.itemType=====",self.rewardType,self.itemType)
    if self.itemType ~= nil and tonumber(self.itemType) == tonumber(ItemsModel.itemType.ITEM_TYPE_PIECE) then
        -- 伙伴碎片
        if self.itemSubType and self.itemSubType == self.itemSubTypes.ITEM_SUBTYPE_202 then
            self.mc_1:showFrame(3)
        else
             -- 法宝碎片
            self.mc_1:showFrame(2)
        end
    elseif self.rewardType ~= nil and tostring(self.rewardType) == FuncDataResource.RES_TYPE.TREASURE then
        self.mc_1:showFrame(2)
    else
        self.mc_1:showFrame(1)
    end

    self.mc_1.currentView.btn_1:setTouchSwallowEnabled(true)

    -- 初始化panelInfo
    self.panelInfo = self.mc_1.currentView.btn_1:getUpPanel().panel_1
    -- 设置点击区域，解决透明区域过大，导致点击左边item，后边item响应的bug
    self.mc_1.currentView.btn_1:setRect(cc.rect(0,-90,90,90))

    -- 默认功能
    -- 使用第二帧字体
    self.panelInfo.mc_zi:showFrame(2)
    
    -- 隐藏名字
    self:showResItemName(false)
    -- 显示数量
    self:showResItemNum(true)
    -- 不可以点击
    self:setResItemClickEnable(false)
end

-- 对外接口------------------------------------------------------------------------------------------------
--[[
    -- 道具数据格式
    data数据格式：{
        itemId="",          --道具ID
        itemNum="",         --道具数量
    }

    -- 奖品数据格式
    data数据格式：{
        reward="3,10",      --奖品是金币
    }
    或
    data数据格式：{
        reward="1,101,1",   --奖品是道具
    }
--]]
function CompResItemView:setResItemData(data)
    CompResItemView.super.setItemData(self,data)
    
    -- 如果是奖品
    if data.reward ~= nil then
        self:setRewardItemData(data)
    else
    -- 如果是道具
        self:setItemData(data)
    end
end

-- 设置itemView是否可以点击
function CompResItemView:setResItemClickEnable(visible)
    if visible then
        self.mc_1.currentView.btn_1:enabled(true)
    else
        self.mc_1.currentView.btn_1:disabled(true)
    end
end

-- 是否显示道具名称
-- whichFrame传1or2, 默认是2 第一帧黄色 第二帧褐色
function CompResItemView:showResItemName(visible, hideNum, whichFrame)
    local mcZi = self.panelInfo.mc_zi
    mcZi:setVisible(visible)

    if visible then
        if whichFrame == 1 then 
            self.panelInfo.mc_zi:showFrame(1);
        end 
        
        local nameTxt = mcZi.currentView.txt_1
        if hideNum then
            nameTxt:setString(self.itemNameWithNotNum)
        else
            nameTxt:setString(self.itemNameWithNum)
        end
    end
end

-- 重新命名道具名称
function CompResItemView:setName(name)
    local mcZi = self.panelInfo.mc_zi
    mcZi:setVisible(true)
    self.panelInfo.mc_zi:showFrame(2);
    local nameTxt = mcZi.currentView.txt_1
    nameTxt:setString(name)
end

-- 是否显示道具数量
function CompResItemView:showResItemNum(visible)
    self.panelInfo.txt_goodsshuliang:setVisible(visible)
end

-- 是否显示道具小红点
function CompResItemView:showResItemRedPoint(visible)
    local redPanel = self.panelInfo.panel_red

    -- 第二帧碎片没有小红点，所以需要判断是否为nil
    if redPanel then
        redPanel:setVisible(visible)
    end
end

-- 修改资源数量
function CompResItemView:setResItemNum(num)
	local txtNum = self.panelInfo.txt_goodsshuliang
    if num > 9999 then
        num = 9999
    end
	txtNum:setString(num)
end

-- 修改资质比例
function CompResItemView:setQualityScale(scale)
    if self.qualityMc and scale then
        self.qualityMc:setScale(scale)
    end
end

--隐藏背景框
function CompResItemView:hideBgCase(  )
    if self.panelInfo.mc_kuang then
        self.panelInfo.mc_kuang:visible(false)
    else
        if self.panelInfo.panel_bg   then
            self.panelInfo.panel_bg:visible(false)
        end
    end
end

-- 返回动画特效ctn
function CompResItemView:getAnimationCtn()
    return self.panelInfo.ctn_2
end

-- 获取资源icon的ctn
function CompResItemView:getResItemIconCtn()
    return self.panelInfo.ctn_1
end

--隐藏法宝碎片或法宝右上角的quality
function CompResItemView:hideTreasureOrPieceQuality(hide)
	local visible = _yuan3(hide, false, true)
	self.mc_1:getViewByFrame(2).btn_1:getUpPanel().panel_1.mc_2:visible(visible)
end



return CompResItemView;
