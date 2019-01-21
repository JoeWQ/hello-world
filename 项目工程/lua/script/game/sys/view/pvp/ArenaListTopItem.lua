ArenaListBaseItem = require('game.sys.view.pvp.ArenaListBaseItem')
local ArenaListTopItem = class("ArenaListTopItem", ArenaListBaseItem)

function ArenaListTopItem:ctor(winName)
	ArenaListTopItem.super.ctor(self, winName)
end

function ArenaListTopItem:loadUIComplete()
	ArenaListTopItem.super.loadUIComplete(self)
end

return ArenaListTopItem

