local PartnerTypeLabelView = class("PartnerTypeLabelView", UIBase)

function PartnerTypeLabelView:ctor(winName)
	PartnerTypeLabelView.super.ctor(self, winName)
end

function PartnerTypeLabelView:loadUIComplete()
	self:setAlignment()
	self:registerEvent()
end


function PartnerTypeLabelView:setAlignment()
	--设置对齐方式
end

function PartnerTypeLabelView:updateUIWithPartner(_partnerInfo)
end

function PartnerTypeLabelView:registerEvent()
    PartnerTypeLabelView.super.registerEvent();
    
end

function PartnerTypeLabelView:showFrame(num)
    self.mc_1:showFrame(num)
end

return PartnerTypeLabelView
