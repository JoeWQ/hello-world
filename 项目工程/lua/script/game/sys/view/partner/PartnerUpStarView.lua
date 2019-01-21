local PartnerUpStarView = class("PartnerUpStarView", UIBase)

function PartnerUpStarView:ctor(winName)
	PartnerUpStarView.super.ctor(self, winName)
end

function PartnerUpStarView:loadUIComplete()
	self:setAlignment()
	self:registerEvent()
end


function PartnerUpStarView:setAlignment()
end

function PartnerUpStarView:updateUIWithPartner(_partnerInfo)
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
    self.data = _partnerInfo
    self:setPartnerInfo(_partnerInfo)
   
end
--伙伴信息
function PartnerUpStarView:setPartnerInfo( _partnerInfo)
    self.partnerId = _partnerInfo.id
    self.starLevel = _partnerInfo.star
    self.starStage = _partnerInfo.starPoint
    self.quality = _partnerInfo.quality
    local partnerData = FuncPartner.getPartnerById(self.partnerId);
    -- name--品质
    self.panel_1.txt_1:setString(GameConfig.getLanguage(partnerData.name).."+"..self.quality)
    --tpye -- 
    self.panel_1.UI_dashen:showFrame(partnerData.type)
    --战力
    local _ability = FuncPartner.getPartnerAvatar(_partnerInfo)
    self.panel_1.UI_number:setPower(_ability)
    --当前星级
    local maxStar = partnerData.maxStar
    self.panel_1.mc_star:showFrame(maxStar)
    for i = 1,maxStar do
        if self.starLevel >= i then
            self.panel_1.mc_star.currentView["mc_"..i]:showFrame(1)
        else
            self.panel_1.mc_star.currentView["mc_"..i]:showFrame(2)
        end
    end
    
    --升星阶段
    local _frame = self.starLevel % 4 + 1; -- 最多有四针
    self.panel_1.mc_1:showFrame(_frame)
    if maxStar == self.starLevel then -- 当前已满级
        self.panel_1.mc_2:showFrame(3)
        FilterTools.clearFilter(self.panel_1.mc_2);
    else
        if self.starStage == 3 then  --此时为升星
            self.panel_1.mc_2:showFrame(2)
        else
            self.panel_1.mc_2:showFrame(1)
        end
        self.panel_1.mc_2.currentView.btn_2:setTap(c_func(self.upStarTap, self)) --对应按钮响应事件
    end
    
    
    self:updataStarStage()
    -- 更新消耗
    self:refreshFragNum()
end

function PartnerUpStarView:refreshBtnDisplay()
    --提升
    local needPartner,needCoin = self:getNeedPartnerNum()
    echo("----refreshBtnDisplay------- xuyao 铜钱数 == ".. needCoin)
    if UserModel:getCoin() >= needCoin then
        self.panel_1.mc_wenben:showFrame(1)
        self.panel_1.mc_wenben.currentView.mc_red5000:showFrame(1)
    else
        self.panel_1.mc_wenben:showFrame(1)
        self.panel_1.mc_wenben.currentView.mc_red5000:showFrame(2)
    end
    self.panel_1.mc_wenben.currentView.mc_red5000.currentView.txt_1:setString(needCoin)
    local havePartner = ItemsModel:getItemNumById(self.partnerId) or 0
    local maxStar = FuncPartner.getPartnerById(self.partnerId).maxStar
    if maxStar > self.starLevel then -- 当前已满级
        self.panel_1.mc_wenben:visible(true)
        if needPartner > havePartner then -- 碎片是否满足
            self.panel_1.mc_2.currentView.panel_red:visible(false)
            FilterTools.setGrayFilter(self.panel_1.mc_2);
        else
            --铜钱是否满足
            if UserModel:getCoin() >= needCoin then
                self.panel_1.mc_2.currentView.panel_red:visible(true)
                FilterTools.clearFilter( self.panel_1.mc_2 );
            else
                self.panel_1.mc_2.currentView.panel_red:visible(false)
                FilterTools.setGrayFilter(self.panel_1.mc_2);
            end
            
        end
        FilterTools.clearFilter(self.panel_1.btn_1);
    else
        FilterTools.setGrayFilter(self.panel_1.btn_1);
        self.panel_1.mc_wenben:visible(false)
    end
end


function PartnerUpStarView:getNeedPartnerNum()
    local costVec = FuncPartner.getStarsByPartnerId(self.partnerId)
    local costFrag = 0
    local costCoin = 0
    for i,v in pairs(costVec) do
        if v.star == self.starLevel then
            local starStage = self.starStage+1;
            if starStage > 4 then
                starStage = 4
            end
            local maxStar = FuncPartner.getPartnerById(self.partnerId).maxStar
            if self.starLevel < maxStar then
                costFrag = (v.cost)[starStage] or 0
                costCoin = v.coin or 0
            end
            break
        end
    end
    return costFrag,costCoin
end

function PartnerUpStarView:registerEvent()
    PartnerUpStarView.super.registerEvent();
    self.panel_1.btn_1:setTap(c_func(self.wannengsuipian, self))
    EventControler:addEventListener(PartnerEvent.PARTNER_FRAGMENT_CHANGE_EVENT,self.refreshFragNum,self)
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.refreshBtnDisplay, self);
end
-- 刷新碎片数量进度条 和 按钮状态
function PartnerUpStarView:refreshFragNum()
    local maxStar = FuncPartner.getPartnerById(self.partnerId).maxStar
    if maxStar > self.starLevel then -- 当前已满级
        self.panel_1.panel_sp:visible(true)
        local needPartner = self:getNeedPartnerNum()
        local havePartner = ItemsModel:getItemNumById(self.partnerId) 
        self.panel_1.panel_sp.panel_progress.txt_1:setString(havePartner .."/"..needPartner)
        self.panel_1.panel_sp.panel_progress.mc_progress:showFrame(1)
        self.panel_1.panel_sp.panel_progress.mc_progress.currentView.progress_1:setPercent(havePartner/needPartner*100)
    else
        self.panel_1.panel_sp:visible(false)
    end

    self:refreshBtnDisplay()
end
function PartnerUpStarView:wannengsuipian()
    -- 判断是否满级
    local maxStar = FuncPartner.getPartnerById(self.partnerId).maxStar
    if maxStar == self.starLevel then -- 当前已满级
        WindowControler:showTips("伙伴星级已满") -- 策划说暂时不弹 -- 策划又要添加
    else
        WindowControler:showWindow("PartnerWanNengSuiPianView",self.partnerId,self:getNeedPartnerNum())
    end
    
end
function PartnerUpStarView:upStarTap()
    echo("shengxingTap ---------------")
    local partnerData = FuncPartner.getPartnerById(self.partnerId);
    if self.data.star == partnerData.maxStar then
        WindowControler:showTips("已到最大星级")
    else
        local isCan ,_type = PartnerModel:isCanUpStar(self.partnerId);
        if isCan then
            PartnerServer:starLevelupRequest(tonumber(self.partnerId), c_func(self.upStarCallBack,self))
        elseif _type == 1 then 
            WindowControler:showTips("碎片数量不足，可通过万能碎片兑换")
        elseif _type == 2 then    
            WindowControler:showTips("铜钱不足，点击铜钱加号查看铜钱来源")
        end
    end
end

function PartnerUpStarView:upStarCallBack(event)
    echo("shengxingTap ---------- callback-----")

    if event.error == nil then 
        --升星或提升 成功 刷新UI
        local _originPartner = PartnerModel:getAllPartner();
        for i,v in pairs(_originPartner) do
            if v.id == self.partnerId then
                self:updateUIWithPartner(v)
                break
            end
        end
        EventControler:dispatchEvent(PartnerEvent.PARTNER_TOP_REDPOINT_EVENT) 
    end
end


function  PartnerUpStarView:updataStarStage()
    -- 升星到下一星需要的资源数量   
    --当前进行到第几个阶段
    local vec = FuncPartner.getStarsByPartnerId(self.partnerId)
    local stageVec
    for i,v in pairs(vec) do
        if v.star == self.starLevel then
            stageVec = v.addAttr
            break
        end
    end
    echo("+++++++++++++ 当前星级 "..self.starLevel .. "  当前状态 "..self.starStage  )
    --已经升星
    local partnerData = FuncPartner.getPartnerById(self.partnerId);
    local maxStar = partnerData.maxStar
    for i = 1,4 do  
        if maxStar > self.starLevel then -- 还未达到满级
            if i > self.starStage then -- 未达到的状态
                self.panel_1.mc_1.currentView["panel_yuan"..i].mc_yuan1:showFrame(3)
                self.panel_1.mc_1.currentView["panel_"..i].mc_1:showFrame(2)
            else -- 已达到的状态
                self.panel_1.mc_1.currentView["panel_yuan"..i].mc_yuan1:showFrame(2)
                self.panel_1.mc_1.currentView["panel_"..i].mc_1:showFrame(1)
            end
        else -- 升到最高星
            self.panel_1.mc_1.currentView["panel_yuan"..i].mc_yuan1:showFrame(2)
            self.panel_1.mc_1.currentView["panel_"..i].mc_1:showFrame(1)
        end
        local stage = stageVec[i];
        local txt = self.panel_1.mc_1.currentView["panel_"..i].mc_1.currentView.txt_1
        txt:setString(PartnerModel:getDesStahe(stage))
    end
    -- 将要升星
    if maxStar > self.starLevel then
        self.panel_1.mc_1.currentView["panel_yuan"..(self.starStage+1)].mc_yuan1:showFrame(1)
    end
    -- 线的显示
    for i = 1,3 do
        if i < self.starStage then
            --此时显示第一帧
            self.panel_1.mc_1.currentView["mc_lan"..i]:showFrame(1)
        else
            self.panel_1.mc_1.currentView["mc_lan"..i]:showFrame(2)
        end
    end
    
end

return PartnerUpStarView
