ArenaListBaseItem = require('game.sys.view.pvp.ArenaListBaseItem')
local ArenaListCommonItem = class("ArenaListCommonItem", ArenaListBaseItem)

function ArenaListCommonItem:ctor(winName)
	ArenaListCommonItem.super.ctor(self, winName)
end

function ArenaListCommonItem:loadUIComplete()
	ArenaListCommonItem.super.loadUIComplete(self)
	self.cloudAnim = self:createUIArmature("UI_arena","UI_arena_di", self.ctn_middle_cloud, false, GameVars.emptyFunc)
	self.cloudAnim:startPlay(true)
end


return ArenaListCommonItem

