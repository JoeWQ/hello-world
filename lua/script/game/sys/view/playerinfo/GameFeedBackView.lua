local GameFeedBackView = class("GameFeedBackView", UIBase)
local INPUT_DEFAULT_HEIGHT = 150
function GameFeedBackView:ctor(winName)
	GameFeedBackView.super.ctor(self, winName)
end

function GameFeedBackView:loadUIComplete()
	--self.input_content:visible(false)
	self.txt_content:visible(false)
	self.input_content:setAlignment("left", "up")
	self.txt_width = 484
	self.txt_font_size = 22
	self.txt_font_name = GameVars.systemFontName
	self.content = ""
	self:registerEvent()
	self:setTextNum(0)
	self.scroll_content:cancleCacheView()

	local alpha_child = FuncRes.a_alpha(485, 150)
	alpha_child:anchor(0,1)
	alpha_child:addTo(self.panel_click.ctn_1)
	self.panel_click:setTouchedFunc(c_func(self.onInputTap, self))
	self.input_content:setTouchEnabled(false)

	self:updateScrollContent()
end

function GameFeedBackView:onInputTap()
	if self.scroll_content:isMoving() then
		return
	end
	FuncCommUI.startInput(self.content, c_func(self.onInputFinished, self), self.input_content.__uiCfgs.co)
end

function GameFeedBackView:onInputFinished(txt, t)
	if t ~= 1 then
		--取消
		return
	end
	self.content = txt
	if self.content ~= "" then
		self.input_content:visible(false)
	else
		self.input_content:visible(true)
	end

	-- local len = string.len4cn2(self.content)
	 self.content = string.subcn(self.content,1,150)
	local len = self:getStrlength(self.content)
	self:setTextNum(len)
	local height = FuncCommUI.getStringHeightByFixedWidth(self.content, self.txt_font_size, self.txt_font_name, self.txt_width)
	self:updateScrollContent(height)
end

function GameFeedBackView:setTextNum(num)
    self.inputNum = num
	self.txt_content_num:setString(string.format("%d/150", num))
end
function GameFeedBackView:getStrlength( str )

	local lenInByte = #str
	local widthsize = 0
	local num = 0
	for i=1,lenInByte do
	    local curByte = string.byte(str, i)
	    local byteCount = 0;
	    if curByte>0 and curByte<=127 then
	        byteCount = 1
	    elseif curByte>=192 and curByte<223 then
	        byteCount = 2
	    elseif curByte>=224 and curByte<239 then
	        byteCount = 3
	    elseif curByte>=240 and curByte<=247 then
	        byteCount = 4
	    end 
	    if byteCount ~= 0 then
	    	num = num + 1
	    	-- widthsize = widthsize + byteCount
		end
	end
	return num
end

function GameFeedBackView:updateScrollContent(textHeight)
	local createFunc = function()
		local view = UIBaseDef:cloneOneView(self.txt_content)
		if textHeight then
			view:setString(self.content)
		end
		return view
	end
	local item_height = textHeight or INPUT_DEFAULT_HEIGHT
	if item_height < INPUT_DEFAULT_HEIGHT then
		item_height = INPUT_DEFAULT_HEIGHT
	end
	local params = { 
		{
			data = {{}},
			createFunc = createFunc,
			perNums =1,
			--perFrame=1, --不要分帧
			offsetX = 0,
			offsetY = 15,
			widthGap = 0,
			heightGap = 0,
			itemRect = {x=0,y=-item_height, width=self.txt_width, height=item_height},
		}
	}
	self.scroll_content:styleFill(params)
	
end

function GameFeedBackView:registerEvent()
	self:registClickClose("out")
	self.btn_close:setTap(c_func(self.close, self))
	self.btn_confirm:setTap(c_func(self.onConfirmBtnClick, self))
end

function GameFeedBackView:close()
	self:startHide()
end

function GameFeedBackView:onConfirmBtnClick()
	local content = self.content
	if nil == content or "" == content then
		WindowControler:showTips(GameConfig.getLanguage("tid_setting_1004"))
		return
	end
    if self.inputNum > 150 then
		WindowControler:showTips(GameConfig.getLanguage("tid_setting_1006"))
		return
	end
	local params = self:getFeedBackParams()
	local url = FuncSetting.FEEDBACK_URL
	local dateStr = os.date("%Y-%m-%d %X")
	local token = crypto.md5(string.format("PlayCrab%s%s", FuncSetting.FEEDBACK_PRIKEY, dateStr))
	local signature = string.format("PLAYCRAB %s:%s", FuncSetting.FEEDBACK_PUBKEY, token)
	
	--httpheader
	local headers = {
		string.format("Authorization: %s", signature),
		string.format("Date: %s", dateStr),
	}

	dump(params, "---params send to questionServer---");

	WebHttpServer:sendRequest(params, url, 
		WebHttpServer.POST_TYPE.POST, headers, c_func(self.onFeedBackOk, self))
end

function GameFeedBackView:onFeedBackOk(serverData)
	self:startHide()

	if serverData.data and serverData.data.code == "200" then
		WindowControler:showTips(GameConfig.getLanguage("tid_setting_1003"))
	end
end

function GameFeedBackView:getFeedBackParams()
	local params = {
		uid = UserModel:uidMark(),
		pid = "暂传uid " .. UserModel:uid(), 
		rid = UserModel:rid(),
		version = AppInformation:getVersion(), --必填
		package_version = "1.0.1", --必填
		game = "xianpro", --必填
		platform = "dev", --必填
		area_service = LoginControler:getServerName(), --必填
		vip = UserModel:vip(),
		role = UserModel:rid(), --必填
		title = "仙",
		content = self.content
	}
	return params
end

return GameFeedBackView



