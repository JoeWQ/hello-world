local MailGoodItemView = class("MailGoodItemView", ItemBase);

--[[
    self.ctn_1,
    self.mc_kuang,
    self.txt_goodsshuliang,
]]

function MailGoodItemView:ctor(winName)
    MailGoodItemView.super.ctor(self, winName);
end

function MailGoodItemView:loadUIComplete()
	self:registerEvent();
end 

function MailGoodItemView:registerEvent()
	MailGoodItemView.super.registerEvent();

end

--设置资源str
function MailGoodItemView:setItemData( resStr )
	local needNum,hasNum,isEnough ,resType,itemId = UserModel:getResInfo( resStr )

	--判断是道具 还是其他资源  除了道具  其他资源走相同的
	local quality = FuncDataResource.getQualityById( resType,itemId )
	local iconPath = FuncRes.iconRes(resType,itemId)
	local icon = display.newSprite(iconPath)

	self.txt_goodsshuliang:setString(needNum)
	self.mc_kuang:showFrame(quality)
	self.ctn_1:removeAllChildren()
	icon:addto(self.ctn_1):anchor(0.5,0.5)
end


function MailGoodItemView:updateUI()
	
end


return MailGoodItemView;
