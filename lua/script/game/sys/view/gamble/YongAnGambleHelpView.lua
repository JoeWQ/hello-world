local YongAnGambleHelpView = class("YongAnGambleHelpView", UIBase)
function YongAnGambleHelpView:ctor(winName)
	YongAnGambleHelpView.super.ctor(self, winName)
end

function YongAnGambleHelpView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self.panel_txt1:visible(false)
	self.panel_txt2:visible(false)
	self.panel_txt3:visible(false)

	self:initScrollContent()
end

function YongAnGambleHelpView:initScrollContent()
	local createPanel1 = function()
		local view = UIBaseDef:cloneOneView(self.panel_txt1)
		return view
	end
	local createPanel2 = function()
		local view = UIBaseDef:cloneOneView(self.panel_txt2)
		return view
	end

	local createPanel3 = function()
		local view = UIBaseDef:cloneOneView(self.panel_txt3)
		return view
	end
	local params = {
		{
			data = {1},
			createFunc = createPanel1,
			perNums =1,
			--perFrame=1, --不要分帧
			offsetX = 0,
			offsetY = 20,
			widthGap = 0,
			heightGap = 0,
			itemRect = {x=0,y=-93.6, width = 884.35, height=93.6},
		},
		{
			data = {1},
			createFunc = createPanel2,
			perNums =1,
			--perFrame=1, --不要分帧
			offsetX = 0,
			offsetY = 10,
			widthGap = 0,
			heightGap = 0,
			itemRect = {x=0,y=-131.6, width = 884.35, height=131.6},
		},
		{
			data = {1},
			createFunc = createPanel3,
			perNums =1,
			--perFrame=1, --不要分帧
			offsetX = 0,
			offsetY = 10,
			widthGap = 0,
			heightGap = 0,
			itemRect = {x=0,y=-169.45, width = 884.35, height=169.45},
		},
	}

	self.scroll_content:styleFill(params)
end

function YongAnGambleHelpView:setViewAlign()
	FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
end

function YongAnGambleHelpView:registerEvent()
	self.btn_back:setTap(c_func(self.close, self))
end

function YongAnGambleHelpView:close()
	self:startHide()
end
return YongAnGambleHelpView
