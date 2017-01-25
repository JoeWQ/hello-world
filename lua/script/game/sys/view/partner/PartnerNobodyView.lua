--伙伴系统,无任何伙伴碎片的时候UI表现
--2017-1-3 14:53:28
--@Author:xiaohuaxiong
local PartnerNobodyView = class("PartnerNobodyView",UIBase)

function PartnerNobodyView:ctor(_name)
    PartnerNobodyView.super.ctor(self,_name)
end

function PartnerNobodyView:loadUIComplete()
    self:registerEvent()
end

function PartnerNobodyView:registerEvent( )
    PartnerNobodyView.super.registerEvent(self)
end

return PartnerNobodyView