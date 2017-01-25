local PartnerUpgradeView = class("PartnerUpgradeView", UIBase)

local upgradeItemId = {
    UPGRADEITEM1 = "9001",
    UPGRADEITEM2 = "9002",
    UPGRADEITEM3 = "9003",
    UPGRADEITEM4 = "9004",
    UPGRADEITEM5 = "9005",
}

function PartnerUpgradeView:ctor(winName)
	PartnerUpgradeView.super.ctor(self, winName)
end
function PartnerUpgradeView:updataUI(data)
	self.data = data
    self.partnerId = data.id
    self.level = data.level
    local partnerData = FuncPartner.getPartnerById(self.partnerId);

    -----  npc ------
    local ctn = self.panel_6.panel_1.ctn_1;
    ctn:removeAllChildren();
    local sp = PartnerModel:initNpc(self.partnerId)
    ctn:addChild(sp);

    local node = display.newLayer();
    node:setContentSize(cc.size(270,315))
    self.panel_6.panel_1:addChild(node,10000)
    node:setPositionY(-315)
    node:setTouchedFunc(c_func(self.openPartnerInfoUI,self))

    -- 战斗描述
    self.panel_6.panel_1.txt_bing:setString(GameConfig.getLanguage(partnerData.charaCteristic))
    -- name
    self.panel_6.panel_1.txt_1:setString(GameConfig.getLanguage(partnerData.name).."+"..data.quality)
    -- 星级
    self.panel_6.panel_1.mc_star:showFrame(data.star)
    -- 品质
    local color = PartnerModel:getQualityColor(data.id,data.quality)
    self.panel_6.panel_1.mc_2:showFrame(color)
    --type
    self.panel_6.panel_1.mc_gfj:showFrame(partnerData.type)
    --显示战力
    local _ability = FuncPartner.getPartnerAvatar(self.data)
    self.panel_6.panel_1.UI_number:setPower(_ability)
    ----------- 升级消耗 ------------
    
    self:initUpgradeCostList()

end

function PartnerUpgradeView:initUpgradeCostList()
    local costItem = self.panel_6.panel_3.UI_1
    costItem:setVisible(false)
    local viewX = costItem:getPositionX()
    local viewY = costItem:getPositionY()
    local viewWith = 100;
    local viewHeight = 100;
    local interval = 3
    self.num = 0
    self.itemNum = {}
    self.panel_6.panel_3.ctn_2:removeAllChildren()
    for i = 1,5 do
        local data = { };
        data.itemId = upgradeItemId["UPGRADEITEM"..i];
        data.exp = FuncItem.getItemData(data.itemId).useEffect;
        data.subType = FuncItem.getItemData(data.itemId).subType;
        data.itemNum = ItemsModel:getItemNumById(data.itemId) or 0;
        local view = UIBaseDef:cloneOneView(costItem);
        data.view = view
        view:setResItemData(data);
        if data.itemNum > 0 then
            FilterTools.clearFilter(view);
            view:showResItemNum(true)
        else
            FilterTools.setGrayFilter(view);
            view:showResItemNum(false)
        end
        if data.subType == 308 then
            view:setName("经验提升1级")
        else
            view:setName("经验+"..data.exp)
        end
        
        self.panel_6.panel_3.ctn_2:addChild(view)
        local x = (i-1) % 4
        local y =  math.modf(i / 5)

        view:setPositionX((viewWith+interval) * x + viewX)
        view:setPositionY(-(viewHeight+interval) * (y) + viewY)

        local  funcs = {};
        self.itemNum[data.itemId] = ItemsModel:getItemNumById(data.itemId)
        local changanTap = function ()
            if self.itemNum[data.itemId] > 0 then
                if self:isCanUpgrade() then 
                    self.itemNum[data.itemId] = self.itemNum[data.itemId]-1
                    self.expType = "changan"
                    self.num = self.num + 1
                    data.itemNum = self.itemNum[data.itemId] or 0
                    self:updataLevel(data)
                else
                    WindowControler:showTips("请提升主角等级")
                end
            else
                WindowControler:showWindow("GetWayListView", data.itemId);
            end
            
        end
        local duananTap = function ()
            if self.expType == "changan" then
                self.expType = ""
                echo("长按 次数 === ".. self.num)
                PartnerServer:levelupRequest({partnerId = self.partnerId,itemId = data.itemId,num = self.num }, c_func(self.upgradeCallBack,self))
                self.num = 0
                self.selectView = view
                self.selectItemId = data.itemId
            else
                if ItemsModel:getItemNumById(data.itemId) > 0 then
                    if self:isCanUpgrade() then
                        self.expType = "duanan"
                        self.num = self.num + 1
                        data.itemNum = ItemsModel:getItemNumById(data.itemId) - self.num  or 0;
                        self:updataLevel(data)
                        local params = {}
                        params.partnerId = self.partnerId
                        params.itemId = data.itemId
                        params.num = self.num
                        PartnerServer:levelupRequest({partnerId = self.partnerId,itemId = data.itemId,num = self.num }, c_func(self.upgradeCallBack,self))
                        self.num = 0
                        self.selectView = view
                        self.selectItemId = data.itemId
                    else
                        WindowControler:showTips("请升级主角等级")
                    end
                else
                    WindowControler:showWindow("GetWayListView", data.itemId);
                end
            end
        end
        funcs.endFunc = duananTap
        funcs.repeatFunc = changanTap
        view:setLongTouchFunc(funcs,nil,false,0.35,0)
    end
    self.currentExp = self.data.exp
    self.progressbarFrame = 2
    self.panel_6.panel_2.panel_2.mc_progress:showFrame(self.progressbarFrame)
    self:updataLevel({})
end

-- 是否满足升级条件，伙伴等级小于人物等级
function PartnerUpgradeView:isCanUpgrade()
    if self.level >= UserModel:level() then
        return false
    else
        return true
    end
end

function PartnerUpgradeView:upgradeCallBack(event)
    if event.error == nil then
        echo("-------------------------------------shengjichenggong")
        if ItemsModel:getItemNumById(self.selectItemId) > 0 then
            FilterTools.clearFilter(self.selectView);
            self.selectView:showResItemNum(true)
        else
            FilterTools.setGrayFilter(self.selectView);
            self.selectView:showResItemNum(false)
        end

        --刷新战力
        local _ability = FuncPartner.getPartnerAvatar(self.data)
        self.panel_6.panel_1.UI_number:setPower(_ability)

        self.itemNum[self.selectItemId] = ItemsModel:getItemNumById(self.selectItemId)
    end
end

function PartnerUpgradeView:updataLevel(data)
    --升级需要的经验值
    --资质
    local progressBar = self.panel_6.panel_2.panel_2.mc_progress.currentView.progress_1
    local maxExp;
    local zizhi = FuncPartner.getPartnerById(self.partnerId).aptitude;
    local levelData = FuncPartner.getConditionByLevel(self.level)
    maxExp = levelData[tostring(zizhi)].exp
    if maxExp == nil then
        -- 此时已满级
        progressBar:setPercent(100)
        -- 进度条显示
        self.panel_6.panel_2.panel_2.txt_1:setString("满级")
        -- 等级显示
        local currentLevel = self.level
        self.panel_6.panel_2.txt_1:setString(currentLevel.."级")
        return 
    end
    local exp = 0;
    if data.subType == 308 then -- 308代表升一级的道具
        exp = maxExp
    else
        exp = data.exp or 0
    end
    if exp == 0 then
        -- 此时已满级
        progressBar:setPercent(self.currentExp/maxExp*100)
        -- 进度条显示
        self.panel_6.panel_2.panel_2.txt_1:setString(self.currentExp .. "/" .. maxExp)
        -- 等级显示
        local currentLevel = self.level
        self.panel_6.panel_2.txt_1:setString(currentLevel.."级")
    else
        local speed = exp / 5.00
        local lastExp = self.currentExp

        self.currentExp = self.currentExp + exp
        local upgrade = false 
        if self.currentExp >= maxExp then
            self.currentExp = self.currentExp - maxExp 
            self.level = self.level + 1
            upgrade = true 
        end
        function progressCallBack()
            maxExp = FuncPartner.getConditionByLevel(self.level)[tostring(zizhi)].exp
            if maxExp == nil then
                -- 此时已满级
                progressBar:setPercent(100)
                -- 进度条显示
                self.panel_6.panel_2.panel_2.txt_1:setString("满级")
                -- 等级显示
                local currentLevel = self.level
                self.panel_6.panel_2.txt_1:setString(currentLevel.."级")
                return 
            end
            -- 进度条显示
            self.panel_6.panel_2.panel_2.txt_1:setString(self.currentExp .. "/" .. maxExp)
            -- 等级显示
            local currentLevel = self.level
            self.panel_6.panel_2.txt_1:setString(currentLevel.."级")
            --刷新道具数量
            if data.view and data.itemId then
                data.view:setResItemNum(data.itemNum)
            end
            local isUpgrade = false;
            if self.currentExp >= maxExp then
                local levelData = FuncPartner.getConditionByLevel(self.level)
                maxExp = levelData[tostring(zizhi)].exp
                self.currentExp = self.currentExp - maxExp
                self.level = self.level + 1
                isUpgrade = true
            end
            progressBar:setPercent(0)
            if isUpgrade then
                local _time = maxExp / speed ;
                progressBar:tweenToPercent(100,_time+1,function ()self:delayCall(progressCallBack,1/30)end)
            else
                local _time = self.currentExp / speed;
                progressBar:tweenToPercent(self.currentExp/maxExp*100,_time)
            end
        end
        if upgrade then
            local _time = (maxExp - lastExp) / speed;
            progressBar:tweenToPercent(100,_time,function ()self:delayCall(progressCallBack,1/30)end)
        else
            progressBar:tweenToPercent(self.currentExp/maxExp*100,8)
            -- 进度条显示
            self.panel_6.panel_2.panel_2.txt_1:setString(self.currentExp .. "/" .. maxExp)
            -- 等级显示
            local currentLevel = self.level
            self.panel_6.panel_2.txt_1:setString(currentLevel.."级")

            --刷新道具数量
            if data.view and data.itemId then
                data.view:setResItemNum(data.itemNum)
            end
        end
    end

    
end
function PartnerUpgradeView:loadUIComplete()
	self:setAlignment()
	self:registerEvent()
end
function PartnerUpgradeView:setAlignment()

end
function PartnerUpgradeView:openPartnerInfoUI()
    WindowControler:showWindow("PartnerInfoUI",self.data.id)
end

function PartnerUpgradeView:updateUIWithPartner(_partnerInfo)
    --只有在必要的时候才会刷新
--    local  _hasChanged=false
--    if(not self._partnerInfo or self._partnerInfo.id ~= _partnerInfo.id)then--如果原来没有目标伙伴
--        self._partnerInfo = _partnerInfo;
--        _hasChanged=true
--    else --否则开始计算两者之间的差异
--        hasChanged=true
--        self._partnerInfo = _partnerInfo
--    end
--    --如果没有发生任何的变化,则直接返回
--    if not _hasChanged then
--        return
--    end

    --更新UI信息
    self:updataUI(_partnerInfo)
end
function PartnerUpgradeView:registerEvent() 
    PartnerUpgradeView.super.registerEvent();
    
end



return PartnerUpgradeView
