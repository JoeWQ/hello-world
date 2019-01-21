local YongAnNewBonusView = class("YongAnNewBonusView", UIBase)
function YongAnNewBonusView:ctor(winName, bonusId)
	YongAnNewBonusView.super.ctor(self, winName)
	self.bonusId = bonusId
end

function YongAnNewBonusView:loadUIComplete()
	self:registerEvent()
	self:updateUI()
end

function YongAnNewBonusView:updateUI()
	local preBonusAddTimes = FuncYongAnGamble.getPreBonusIdAddCount(self.bonusId)
	local achieved, currentNum, needNum, gambleTimes, needQuality = YongAnGambleModel:checkBonusAchieved(self.bonusId)
	local desc = ""
	if needQuality > 0 then
		local qualityName = FuncTreasure.getQualityName(needQuality)
		desc = GameConfig.getLanguageWithSwap("tid_gamble_1005", qualityName, needNum)
	else
		desc = GameConfig.getLanguageWithSwap("tid_gamble_1006", needNum)
	end
	self.rich_goal:setString(desc)
	self.rich_add_count:setString(GameConfig.getLanguageWithSwap("tid_gamble_1007", gambleTimes - preBonusAddTimes))
end

function YongAnNewBonusView:registerEvent()
	self.UI_tanban.mc_1.currentView.btn_1:setTap(c_func(self.close, self))
	self.UI_tanban.btn_close:setTap(c_func(self.close, self))
	self:registClickClose("out", c_func(self.close, self))
end

function YongAnNewBonusView:close()
	local bonusId = YongAnGambleModel:getNextBonusId()
	local achieved = YongAnGambleModel:checkBonusAchieved(bonusId)
	if achieved then
		YongAnGambleServer:getAchievement(bonusId,c_func(self.onNewBonusIdUpdateOk, self))
	end
	self:startHide()
end

function YongAnNewBonusView:onNewBonusIdUpdateOk()
	EventControler:dispatchEvent(YongAnGambleEvent.GET_NEW_BONUS_OK)
	local currentBonusId = YongAnGambleModel:getCurrentBonusId()
	WindowControler:showWindow("YongAnNewBonusView", currentBonusId)
end

return YongAnNewBonusView
