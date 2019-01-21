local ArenaRefreshCdView = class("ArenaRefreshCdView", UIBase)

function ArenaRefreshCdView:ctor(winName)
	ArenaRefreshCdView.super.ctor(self, winName)
end

function ArenaRefreshCdView:loadUIComplete()
	self.panel_refresh_cd.btn_2:setTap(c_func(self.onClearCdPopBtnTap, self))
	--self:updateUI()
	self:scheduleUpdateWithPriorityLua(c_func(self.updateTime, self) ,0)
end

function ArenaRefreshCdView:updateTime()
	local left = FuncPvp.getPvpCdLeftTime()

	local minute = math.floor(left / 60)
	local sec = left - minute*60
	local timeStr = string.format("%02d:%02d", minute, sec)
--	local str = GameConfig.getLanguageWithSwap("tid_pvp_1040", timeStr)
	self.panel_refresh_cd.txt_time:setString(timeStr)
end

function ArenaRefreshCdView:onClearCdPopBtnTap()
	WindowControler:showWindow("ArenaClearChallengeCdPop")
end

return ArenaRefreshCdView

