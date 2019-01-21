local PlayerRenameView = class("PlayerRenameView", UIBase)
local GEN_RANDOM_NAME_MAX_TRY = 10

function PlayerRenameView:ctor(winName)
	PlayerRenameView.super.ctor(self, winName)
	self.gen_random_name_try_count = 0
end

function PlayerRenameView:loadUIComplete()
	self:registerEvent()
	self:setRenameCost()
	if not UserModel:isNameInited() then
		self.btn_close:visible(false)
		self.mc_cost:visible(false)
		self.txt_1:setString(GameConfig.getLanguage("tid_info_1001"))
	end
end

function PlayerRenameView:setRenameCost()
	if UserModel:isNameInited() then
		self.rename_is_free = 0
		self.mc_cost:showFrame(1)
		local cost = UserExtModel:getRenameCost()
		self.mc_cost.currentView.txt_cost:setString(cost)
		if cost > UserModel:getGold() then
			self.mc_cost.currentView.txt_cost:setColor(FuncCommUI.COLORS.TEXT_RED)
		end
	else
		self.rename_is_free = 1
		self.mc_cost:showFrame(2)
	end
end

function PlayerRenameView:registerEvent()
	if UserModel:isNameInited() then
		self:registClickClose("out")
		self.btn_close:setTap(c_func(self.close, self))
	end
	self.btn_confirm:setTap(c_func(self.onRenameConfirm, self))
	self.btn_random_name:setTap(c_func(self.onRandomNameTap, self))
end

function PlayerRenameView:onRandomNameTap()
	local name = self:doGenOneRandomName()
	UserServer:checkRoleName(name, c_func(self.onCheckRoleNameOk, self))
end

function PlayerRenameView:doGenOneRandomName()
	local avatarId = UserModel:avatar()..''
	local sex = FuncChar.getHeroSex(avatarId)
	local name = FuncAccountUtil.getRandomRoleName(sex)
	self.random_name = name
	return name
end

function PlayerRenameView:onCheckRoleNameOk(serverData)
	if serverData.error then
		if self.gen_random_name_try_count < GEN_RANDOM_NAME_MAX_TRY then
			local anotherRandomName = self:doGenOneRandomName()
			UserServer:checkRoleName(anotherRandomName, c_func(self.onCheckRoleNameOk, self))
		else
			self:doInitRandomName(self.random_name)
		end
	else
		self:doInitRandomName(self.random_name)
	end
	self.gen_random_name_try_count = self.gen_random_name_try_count + 1
end

function PlayerRenameView:doInitRandomName(name)
	self.input_name:setText(name)
end

function PlayerRenameView:onRenameConfirm()
	self.gen_random_name_try_count = 0
	local name = self.input_name:getText()
	local ok, tip = FuncAccountUtil.checkRoleName(name)
	if not ok then
		WindowControler:showTips(tip)
		return
	end

	if UserModel:isNameInited() then
		local cost = UserExtModel:getRenameCost()
        if UserModel:tryCost(UserModel.RES_TYPE.DIAMOND, tonumber(cost), true) == true then
             UserServer:changeRoleName(name, self.rename_is_free, c_func(self.onChangeRoleName, self))
        end
	else

		UserServer:setRoleName(name, c_func(self.onSetRoleName, self))
	end
end

function PlayerRenameView:onChangeRoleName(serverData)
	if serverData.error then
		self:_checkRenameError(serverData.error)
	else
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1019"))
		EventControler:dispatchEvent(UserEvent.USEREVENT_NAME_CHANGE_OK)
		self:close()
	end
end

function PlayerRenameView:_checkRenameError(errorInfo)
	local code = errorInfo.code
	--这三个错误一般客户端都检查了
	--特殊字符
	if code == 10046 then
	end
	--长度不符
	if code == 10047 then
	end
	--敏感词
	if code == 10048 then
		WindowControler:showTips(GameConfig.getLanguage("tid_setting_1005"))
	--重名判断
	elseif code == 32502 then
		WindowControler:showTips(GameConfig.getLanguage("tid_info_nameuse"))
	end
end

function PlayerRenameView:onSetRoleName(serverData)
	if serverData.error then
		self:_checkRenameError(serverData.error)
	else
		WindowControler:showTips(GameConfig.getLanguage("tid_info_1002"))
		EventControler:dispatchEvent(UserEvent.USEREVENT_SET_NAME_OK)
		self:close()
	end
end

function PlayerRenameView:close()
	self:startHide()
end

return PlayerRenameView

