local PlayerInfoView = class("PlayerInfoView", UIBase)
local INFO_LABEL_TYPE = {
	INFO = 1,
	SETTING = 2,
}

function PlayerInfoView:ctor(winName)
	PlayerInfoView.super.ctor(self, winName)
end

function PlayerInfoView:loadUIComplete()
	self:setViewAlign()
	self:registerEvent()
	self:selectLabel(INFO_LABEL_TYPE.INFO)
end

function PlayerInfoView:setViewAlign()
	FuncCommUI.setViewAlign(self.btn_close, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_res, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
    FuncCommUI.setScale9Align(self.scale9_134,UIAlignTypes.MiddleTop, 1, 0)
    FuncCommUI.setViewAlign(self.panel_h, UIAlignTypes.LeftTop)
    
    
end

function PlayerInfoView:showLabel(label)
	self.mc_content:showFrame(label)
end

function PlayerInfoView:selectLabel(label)
	if label == INFO_LABEL_TYPE.INFO then
		self.panel_h.mc_info:showFrame(2)
		self.panel_h.mc_setting:showFrame(1)
		self.mc_content:showFrame(1)
		self:updateInfoView()
	else
		self.panel_h.mc_info:showFrame(1)
		self.panel_h.mc_setting:showFrame(2)
		self.mc_content:showFrame(2)
		self:updateSettingView()
	end
	self:showLabel(label)
end

function PlayerInfoView:updateInfoView()
	if self.info_view_inited then return end
	local contentView = self.mc_content.currentView.panel_1
	--icon
	self:setPlayerIcon()
	--如果是 版署包
	if APP_PLAT  ==10001 then
		contentView.panel_vip:visible(false)
		contentView.mc_vip:visible(false)
	end
	
	--vip
	contentView.mc_vip:showFrame(UserModel:vip()+1)
	--name
	contentView.txt_name:setString(UserModel:name())
	--account_id
	contentView.txt_account_id:setString(UserModel:uidMark())
	--TODO xianmeng
	contentView.txt_xianmeng_name:setString("暂无仙盟")
	--level
	contentView.txt_level:setString("等级：" .. tostring( UserModel:level() ) )    
	--exp
	local currentExp = UserModel:exp()
	local maxExp = FuncChar.getCharMaxExpAtLevel(UserModel:level())
	local str = string.format("%d/%d",currentExp, maxExp)
	contentView.panel_progress.txt_exp:setString(str)
	local percent = currentExp*1.0/maxExp*100
	contentView.panel_progress.progress_exp:setPercent(percent)
	--rename button
	contentView.btn_rename:setTap(c_func(self.onRenameTap, self))
	--server_name
	local sname = LoginControler:getServerName()
	local smark = LoginControler:getServerMark()
	contentView.txt_server_name:setString(string.format("【%s服】%s", smark, sname))
	--buttons
	self:setInfoBottomButtons()
	self.info_view_inited = true
end

function PlayerInfoView:onUserModelUpdate()
	local contentView = self.mc_content.currentView.panel_1
	contentView.txt_name:setString(UserModel:name())
end


function PlayerInfoView:onRenameTap()
	WindowControler:showWindow("PlayerRenameView")
end

function PlayerInfoView:setInfoBottomButtons()
	local contentView = self.mc_content.currentView.panel_1
	local isCdkeyOpen = FuncSetting.isCdkeyOpen()
	if isCdkeyOpen then
		contentView.mc_buttons:showFrame(1)
	else
		contentView.mc_buttons:showFrame(2)
	end
	local buttonViews = contentView.mc_buttons.currentView
	if buttonViews.btn_cdkey then
		buttonViews.btn_cdkey:setTap(c_func(self.onCdkeyBtnTap, self))
	end
	buttonViews.btn_feedback:setTap(c_func(self.onFeedbackBtnTap, self))
	buttonViews.btn_notice:setTap(c_func(self.onNoticBtnTap, self))
	buttonViews.btn_gologin:setTap(c_func(self.onGologinBtnTap, self))
end

function PlayerInfoView:onCdkeyBtnTap()
	WindowControler:showWindow("CdkeyExchangeView")
end

function PlayerInfoView:onNoticBtnTap()
	LoginControler:fetchGonggao()
end

function PlayerInfoView:onFeedbackBtnTap()
	WindowControler:showWindow("GameFeedBackView")
end

function PlayerInfoView:onGologinBtnTap()
	self:startHide()
	WindowControler:goBackToEnterGameView()
end

function PlayerInfoView:setPlayerIcon()
	local contentView = self.mc_content.currentView.panel_1
	local avatarId = UserModel:avatar()..''
	local icon = FuncRes.iconAvatarHead(avatarId)
	local iconSprite = display.newSprite(icon)
	local avatarCtn = contentView.ctn_icon
	local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", avatarCtn, false, GameVars.emptyFunc)
	iconAnim:setScale(1.2)
	FuncArmature.changeBoneDisplay(iconAnim, "node", iconSprite)
end

function PlayerInfoView:updateSettingView()
	if self.setting_view_inited then return end
	local contentView = self.mc_content.currentView.panel_1
	contentView.UI_toggle_common:visible(false)

	local musicInfo = FuncSetting.SETTTING_SWITCHS.MUSIC
	contentView.UI_music_toggle:setInfo(musicInfo)
	contentView.UI_music_toggle:updateUI()

	local soundInfo = FuncSetting.SETTTING_SWITCHS.SOUND
	contentView.UI_sound_toggle:setInfo(soundInfo)
	contentView.UI_sound_toggle:updateUI()

    local showPlayerInfo = FuncSetting.SETTTING_SWITCHS.SHOWPLAYER
    contentView.UI_yincang:setInfo(showPlayerInfo)
	contentView.UI_yincang:updateUI()

    contentView.btn_1k:setTap(c_func(function()
        echo("隐藏协议")
    end,self))
    contentView.btn_2k:setTap(c_func(function()
        echo("用户协议")
    end,self))

	local notikeys = FuncSetting.getNotificationKeys()
	local createFunc = function(switch_key)
		local info = FuncSetting.SETTTING_SWITCHS[switch_key]
		local view = UIBaseDef:cloneOneView(contentView.UI_toggle_common)
		view:setInfo(info)
		view:updateUI()
		return view
	end
	local params = {
		{
			data = notikeys,
			createFunc = createFunc,
			perNums = 2,
			offsetX = -10,
			offsetY = 22,
			widthGap = 30,
			heightGap = 20,
			itemRect = {x=0,y= -40,width = 300,height = 40},
			perFrame=1
		}
	}
	contentView.scroll_notifications:styleFill(params)
	self.setting_view_inited = true
end


function PlayerInfoView:registerEvent()
	self.btn_close:setTap(c_func(self.close, self))
	self.panel_h.mc_info:setTouchedFunc(c_func(self.selectLabel, self, INFO_LABEL_TYPE.INFO))
	self.panel_h.mc_setting:setTouchedFunc(c_func(self.selectLabel, self, INFO_LABEL_TYPE.SETTING))
	EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.onUserModelUpdate, self)
end

function PlayerInfoView:close()
	self:startHide()
end

return PlayerInfoView

