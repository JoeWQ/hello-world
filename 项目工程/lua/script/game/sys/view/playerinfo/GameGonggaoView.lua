local GameGonggaoView = class("GameGonggaoView", UIBase)

function GameGonggaoView:ctor(winName, data)
	GameGonggaoView.super.ctor(self, winName)
	self.gonggaoData = data
end

function GameGonggaoView:loadUIComplete()
	self.txt_item:visible(false)
	self:registerEvent()
	self:setGonggaoContent()
end

function GameGonggaoView:setGonggaoContent()
	local width = 600
	local fontName = GameVars.systemFontName --"gameFont1"
	local fontSize = 24

	local params = {}
	local gonggao = self:getGonggaoContents()
	for index, oneGonggao in ipairs(gonggao) do
		local strContent = oneGonggao[1].content
		local height = FuncCommUI.getStringHeightByFixedWidth(strContent, fontSize, fontName, width)
		local createFunc = function(gonggaoInfo)
			local view = UIBaseDef:cloneOneView(self.txt_item)
			view.baseLabel:setDimensions(width, height)
			view:setString(gonggaoInfo.content)
			return view
		end
		local oneParam = {
			data = oneGonggao,
			createFunc = createFunc,
			perNums =1,
			--perFrame=1, --不要分帧
			offsetX = 13,
			offsetY = 0,
			widthGap = 0,
			heightGap = 0,
			itemRect = {x=0,y= -height, width = width,height = height},
		}
		table.insert(params, oneParam)
	end
	self.scroll_content:styleFill(params)
end

function GameGonggaoView:getGonggaoContents()
	local defaultStr = GameConfig.getLanguage("tid_setting_1002")
	local str = self.gonggaoData.NoticeContent or defaultStr
	local gonggao = { {{content = str}}, }
	return gonggao
end

function GameGonggaoView:registerEvent()
	self:registClickClose("out")
	self.btn_close:setTap(c_func(self.onCloseTap, self))
	self.btn_confirm:setTap(c_func(self.onConfirmTap, self))
end

function GameGonggaoView:onCloseTap()
	self:close()
end

function GameGonggaoView:onConfirmTap()
	self:close()
end

function GameGonggaoView:close()
	self:startHide()
end

return GameGonggaoView

