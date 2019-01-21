local ArenaPlayerTalkView = class("ArenaPlayerTalkView", UIBase)

function ArenaPlayerTalkView:ctor(winName)
	ArenaPlayerTalkView.super.ctor(self, winName)
end

function ArenaPlayerTalkView:loadUIComplete()
	local txt_content = self.panel_talk.txt_content
	local x,y = txt_content:getPosition()
	self.box_width = self:getContainerBox().width
	self.txt_content_px = x
	self.txt_content_py = y
end

function ArenaPlayerTalkView:setTalkContent(contentStr)
--	self.panel_talk.scale9_1:setScaleX(1)
	self.panel_talk.txt_content:setString(contentStr)
	local txt_content = self.panel_talk.txt_content
	local cn2Len = string.len4cn2(contentStr)
	local tx = self.txt_content_px
	local ty = self.txt_content_py
	--复位
	txt_content:pos(cc.p(tx, ty))
	--少于5个汉字，适配下
	if cn2Len/2<=5 then
		local width = FuncCommUI.getStringWidth(contentStr, txt_content:getFontSize(), txt_content:getFont())
		local scale = (width+30)/self.box_width
		if scale < 0.5 then
			scale = 0.5
		end
		--self.panel_talk.scale9_1:setScaleX(scale)
        local _offsetX = tx-self.box_width/2*scale-15*scale
        _offsetX = _offsetX <5 and 5 or _offsetX
		txt_content:pos(cc.p(_offsetX, ty))
	else
		txt_content:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
	end
end

return ArenaPlayerTalkView

