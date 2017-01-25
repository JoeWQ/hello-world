local BaseInspect = require("game.sys.config_inspect.BaseInspect")
local SmeltInspect = class("SmeltInspect", BaseInspect)

function SmeltInspect:ctor()
	SmeltInspect.super.ctor(self)
	self.configs = {
		"items.Item",
		"treasure.Treasure",
	}
end

function SmeltInspect:getConfigItems()
	return self.configs
end

function SmeltInspect:run_check_smelt_items()
	for id, info in pairs(self.config_Item) do
		
		if info.type == 3 and info.isSmelt then
			self:log(string.format("item: %s 是可以熔炼的", id))
		end
	end
end

return SmeltInspect
