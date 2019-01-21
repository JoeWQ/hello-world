local PartnerWanNengSuiPianView = class("PartnerWanNengSuiPianView", UIBase)

function PartnerWanNengSuiPianView:ctor(winName,partnerId,needCount)
	PartnerWanNengSuiPianView.super.ctor(self, winName)
    self.partnerId = partnerId
    self.needCount = needCount
end

function PartnerWanNengSuiPianView:loadUIComplete()
	self:setAlignment()
	self:registerEvent()
    self:initUI()
end


function PartnerWanNengSuiPianView:setAlignment()
	--设置对齐方式
end

function PartnerWanNengSuiPianView:initUI()
    -- 万能碎片
    self.wnFragId = "4049"
    local wnFragNum = ItemsModel:getItemNumById("4049") or 10
    --    self.panel_1:setString("拥有"..wnFragNum)
    self.UI_1:setResItemData({ itemId = self.wnFragId, itemNum = wnFragNum })
    self.UI_1:showResItemNum(false)
    self.txt_2:setString("拥有"..wnFragNum.."个")
    
    -- 伙伴碎片
    local partnerFragNum = ItemsModel:getItemNumById(self.partnerId) 
    local partnerFragNeedNum = self.needCount
    self.UI_2:setResItemData({ itemId = self.partnerId, itemNum = partnerFragNum })
    self.UI_2:showResItemNum(false)
    self.txt_3:setString(partnerFragNum .. "/".. partnerFragNeedNum)

    --按钮显示
    self:btnRefresh()
end

function PartnerWanNengSuiPianView:registerEvent()
    PartnerWanNengSuiPianView.super.registerEvent();
    self:registClickClose("out");
    self.panel_1.btn_1:setTap(c_func(function ()
        self:startHide()
    end, self))
    self.panel_1.btn_2:setTap(c_func(self.exchange, self,1))
    self.panel_1.btn_3:setTap(c_func(self.exchange, self,10))
    
end
function PartnerWanNengSuiPianView:exchange(count)
    local _param = {}
    _param.partnerId = self.partnerId
    if ItemsModel:getItemNumById("4049") > 0 then
        if ItemsModel:getItemNumById("4049") < 10 and count == 10 then
            count = ItemsModel:getItemNumById("4049")
        end
        _param.num = count
        PartnerServer:fragExchangeRequest(_param, c_func(self.exchangeCallBack,self))
    else
        WindowControler:showTips("万能碎片不足")    
    end
    
end
function PartnerWanNengSuiPianView:exchangeCallBack(event)
    if event.error == nil then
        -- 刷新碎片数量
        self:refreshPartnerNum()
        self:btnRefresh()
        EventControler:dispatchEvent(PartnerEvent.PARTNER_FRAGMENT_CHANGE_EVENT)
        EventControler:dispatchEvent(PartnerEvent.PARTNER_TOP_REDPOINT_EVENT)
    end
end

function PartnerWanNengSuiPianView:refreshPartnerNum()
    -- 万能碎片
    self.wnFragId = "4049"
    local wnFragNum = ItemsModel:getItemNumById("4049") 
    self.txt_2:setString("拥有"..wnFragNum.."个")
    
    -- 伙伴碎片
    local partnerFragNum = ItemsModel:getItemNumById(self.partnerId);
    self.txt_3:setString(partnerFragNum .. "/".. self.needCount)
end
function PartnerWanNengSuiPianView:btnRefresh()
    local wnFragNum = ItemsModel:getItemNumById("4049") 
    if wnFragNum > 0 then
        FilterTools.clearFilter(self.panel_1.btn_2)
        FilterTools.clearFilter(self.panel_1.btn_3)
    else
        FilterTools.setGrayFilter(self.panel_1.btn_2)
        FilterTools.setGrayFilter(self.panel_1.btn_3)
    end
end

return PartnerWanNengSuiPianView
