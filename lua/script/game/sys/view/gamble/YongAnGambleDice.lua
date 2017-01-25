local YongAnGambleDice = class("YongAnGambleDice", UIBase)
function YongAnGambleDice:ctor(winName)
	YongAnGambleDice.super.ctor(self, winName)
end

function YongAnGambleDice:loadUIComplete()
	self:registerEvent()
end

function YongAnGambleDice:registerEvent()
end

function YongAnGambleDice:close()
	self:startHide()
end

function YongAnGambleDice:showPoint(point)
	if point > 6 then point = 6 end
	self.mc_dice:showFrame(point)
end

return YongAnGambleDice
