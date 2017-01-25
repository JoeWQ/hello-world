local TowerNewBoxKeys = class("TowerNewBoxKeys", UIBase)
function TowerNewBoxKeys:ctor(winName)
	TowerNewBoxKeys.super.ctor(self, winName)
end

function TowerNewBoxKeys:loadUIComplete()
	self:registerEvent()
	self:setKeyNum()
end

function TowerNewBoxKeys:setKeyNum()
	local keyTypes = FuncTower.KEY_TYPES
	for i,keyType in pairs(keyTypes) do
		local keyId = FuncTower.KEYS[keyType]
		local num = ItemsModel:getItemNumById(keyId)
		echo(num, 'TowerNewBoxKeys :setKeyNum')
		local panel = self["panel_" .. i]
		panel.txt_1:setString(num)
	end
end

function TowerNewBoxKeys:registerEvent()
	EventControler:addEventListener(TowerEvent.TOWER_OPEN_BOX_OK, self.onOpenBox, self)
	EventControler:addEventListener(TowerEvent.TOWER_RECEIVE_SWEEP_REWARD_OK, self.onReceiveSweepReward, self)
end

function TowerNewBoxKeys:onReceiveSweepReward()
	self:setKeyNum()
end

function TowerNewBoxKeys:onOpenBox()
	self:setKeyNum()
end

function TowerNewBoxKeys:close()
	self:startHide()
end
return TowerNewBoxKeys
