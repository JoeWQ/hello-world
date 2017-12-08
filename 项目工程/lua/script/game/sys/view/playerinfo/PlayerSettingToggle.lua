local PlayerSettingToggle = class("PlayerSettingToggle", UIBase)

function PlayerSettingToggle:ctor(winName)
	PlayerSettingToggle.super.ctor(self, winName)
end

function PlayerSettingToggle:loadUIComplete()

end

function PlayerSettingToggle:setInfo(info)
	self.info = info
end

function PlayerSettingToggle:updateUI()
	self.txt_toggle_name:setString(self.info.keyStr)
	self.UI_slider:setInfo(self.info)
	self.UI_slider:updateUI()
end

return PlayerSettingToggle

