-- 
local ResTopBase = require("game.sys.view.component.CompResTopBase")
local NewLotteryNavBtn = class("NewLotteryNavBtn", ResTopBase)
function NewLotteryNavBtn:ctor(winName)
	NewLotteryNavBtn.super.ctor(self, winName)
end

function NewLotteryNavBtn:loadUIComplete()
	
end



return NewLotteryNavBtn
