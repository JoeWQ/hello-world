local SmeltTitleView = class("SmeltTitleView", UIBase)
function SmeltTitleView:ctor(winName)
	SmeltTitleView.super.ctor(self, winName)
end

function SmeltTitleView:loadUIComplete()
	self.UI_item:visible(false)
	self:setViewAlign()
	self:registerEvent()
	self:setHistorySoul()
	self:initTitles()
end

function SmeltTitleView:setViewAlign()
	FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.UI_res, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
end

function SmeltTitleView:setHistorySoul()
	self.txt_history_soul:setString(UserExtModel:totalSoul())
end

function SmeltTitleView:registerEvent()
	self.btn_back:setTap(c_func(self.close, self))
	EventControler:addEventListener(SmeltEvent.SMELTEVENT_BUY_TITLE_OK, self.onBuyTitleOk, self)
end

function SmeltTitleView:onBuyTitleOk(event)
	local params = event.params
	local itemView = params.view
	if itemView then
		local tempFunc = function (view ,x,y )
			self.scroll_titles:easeMoveto(x,y,0.2)
			view:visible(false)
			self:initTitles()
		end
		local x,y = itemView:getPosition()
		transition.moveTo(itemView, {x=x-800,y = y,time = 0.2,onComplete = c_func(tempFunc, itemView, x,y )})
	else
		self:initTitles()
	end
end

function SmeltTitleView:initTitles()
	local smelts = UserModel:smelts()
	local sortById = function(a, b)
		local hasA = smelts[a.id]
		local hasB = smelts[b.id]
		local aid = tonumber(a.id)
		local bid = tonumber(b.id)
		if hasA then aid = aid + 100 end
		if hasB then bid = bid + 100 end
		return aid < bid
	end
	local rewards = table.deepCopy(FuncSmelt.getSmeltRewardsData())
	local keys = table.sortedKeys(rewards, sortById)
	local createFunc = function(id)
		local ui_item = WindowsTools:createWindow("SmeltTitleItemView", id);
		ui_item:updateUI()
		return ui_item
	end
	local params = {
		{
			data = keys, 
			createFunc = createFunc,
			perNums = 1,
			perFrame = 1,
			offsetX = 60,
			offsetY = 0,
			widthGap = 0,
			heightGap = 10,
			itemRect = {x=0, y=-156, width=760, height=156},
		}
	}
	self.scroll_titles:styleFill(params)
	self.scroll_titles:cancleCacheView()
end

function SmeltTitleView:close()
	self:startHide()
end
return SmeltTitleView
