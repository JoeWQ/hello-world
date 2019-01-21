local PlayerSettingSlider = class("PlayerSettingSlider", UIBase)

function PlayerSettingSlider:ctor(winName)
	PlayerSettingSlider.super.ctor(self, winName)
end

function PlayerSettingSlider:loadUIComplete()
	self.panel_slider.panel_off:visible(false)
	self.container_box = self:getContainerBox()
	self:registerEvent()
end

function PlayerSettingSlider:registerEvent()
	self.panel_slider:setTouchedFunc(c_func(self.toggleSwitch, self))
end

function PlayerSettingSlider:toggleSwitch()

   -- 系统设置 音效
    if AudioModel:isSoundOn() then
		AudioModel:playSound("s_com_click2")
	end
	
    
	if not self.info then return end
	local slider_block = self.panel_slider.panel_slider_block
	local box = self.container_box
	local state = self:getStorageState()
	local moveX = box.width/2
	local newState
	if state == FuncSetting.SWITCH_STATES.ON then
		moveX = 0-moveX
		newState = FuncSetting.SWITCH_STATES.OFF
	else
		newState = FuncSetting.SWITCH_STATES.ON
		moveX = moveX
	end
	if newState then
		LS:pub():set(self.info.sc, newState)
	end
	slider_block:runAction(act.moveby(0.1, moveX, 0))
	local event = self.info.event
	if event then
		EventControler:dispatchEvent(event, {state = newState})
	end
	self:setStateStr(newState)
end

function PlayerSettingSlider:setInfo(info)
	self.info = info
end

function PlayerSettingSlider:updateUI()
	self:initState()
end

function PlayerSettingSlider:setStateStr(state)
	if state == FuncSetting.SWITCH_STATES.ON then
		self.panel_slider.panel_on:visible(true)
		self.panel_slider.panel_off:visible(false)
	else
		self.panel_slider.panel_on:visible(false)
		self.panel_slider.panel_off:visible(true)
	end
end

function PlayerSettingSlider:initState()
	local state = self:getStorageState()
	local slider_block = self.panel_slider.panel_slider_block
	if state == FuncSetting.SWITCH_STATES.OFF then
		local box = slider_block:getContainerBox()
		local x,y = slider_block:getPosition()
		slider_block:pos(cc.p(box.width/2+2,y))
	end
	self:setStateStr(state)
end

function PlayerSettingSlider:getStorageState()
    local state = FuncSetting.SWITCH_STATES.ON
    if self.info.key == "show_palyer" then
        state = FuncSetting.SWITCH_STATES.OFF
    end
	state = LS:pub():get(self.info.sc, state)
	return state
end

return PlayerSettingSlider

