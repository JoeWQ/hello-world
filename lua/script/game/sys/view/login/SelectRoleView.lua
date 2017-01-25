local SelectRoleView = class("SelectRoleView", UIBase)

function SelectRoleView:ctor(winName)
	SelectRoleView.super.ctor(self, winName)
end

function SelectRoleView:loadUIComplete()
	self:initData()
	self:initView()
	self:registerEvent()
	self:updateUI()
end

function SelectRoleView:registerEvent()
	self.btn_1:setTap(c_func(self.onConfirmTap, self))
	self.mcMale:setTouchedFunc(c_func(self.onSelectMale,self))
	self.mcFemale:setTouchedFunc(c_func(self.onSelectFemale,self))
end

function SelectRoleView:initView()
	FuncCommUI.setViewAlign(self.panel_name, UIAlignTypes.LeftTop)

	self.mc_2:showFrame(1)
	self.mc_3:showFrame(2)

	-- 男mc
	self.mcMale = self.mc_2.currentView.mc_1
	-- 女mc
	self.mcFemale = self.mc_3.currentView.mc_1
end

function SelectRoleView:initData()
	self.roleType = {
		ROLE_MALE = 1,
		ROLE_FEMALE = 2,
	}


	self.hidList = {
		"101",			--男
		"104"			--女
	}

	self.roleIcon = {
		"head101_cheng.png",
		"head401_cheng.png"
	}

	self.curSelectRole = self.roleType.ROLE_MALE
	local randomIndex =  RandomControl.getOneRandomInt(10,1)
	if randomIndex % 2 == 0 then
		self.curSelectRole = self.roleType.ROLE_FEMALE
	end

	self.heroAnimCache = {}
end

-- 更新角色状态
function SelectRoleView:updateRoleHead(roleType,isSelect)
	local mcRole = nil
	local iconName = self.roleIcon[roleType]
	
	local headIcon = display.newSprite(FuncRes.iconHead(iconName))
	local headIconScale = 1.0
	-- 男
	if roleType == self.roleType.ROLE_MALE then
		mcRole = self.mcMale
		if isSelect then
			mcRole:showFrame(2)
		else
			mcRole:showFrame(1)
			headIconScale = 0.8
		end

		headIcon:pos(-10,4)
	else
		mcRole = self.mcFemale
		if isSelect then
			mcRole:showFrame(2)
		else
			mcRole:showFrame(1)
			headIconScale = 0.8
		end

		headIcon:pos(0,-8)
	end
	
	local btnRole = mcRole.currentView.btn_1
	local ctnHead = btnRole:getUpPanel().ctn_1
	ctnHead:addChild(headIcon)
	ctnHead:setScale(headIconScale)
end

function SelectRoleView:updateUI()
	if self.curSelectRole == self.roleType.ROLE_MALE then
		self:updateRoleHead(self.roleType.ROLE_MALE,true)
		self:updateRoleHead(self.roleType.ROLE_FEMALE,false)
	else
		self:updateRoleHead(self.roleType.ROLE_MALE,false)
		self:updateRoleHead(self.roleType.ROLE_FEMALE,true)
	end

	self:updateTextTip()
	self:updateRoleAnim()
end

-- 更新文字描述
function SelectRoleView:updateTextTip()
	self.mc_1:showFrame(self.curSelectRole)
end

-- 更新角色动画
function SelectRoleView:updateRoleAnim()
	self:resetHeroSpineAnim()
	
	local ctnHero = self.ctn_hero
	local roleAnim = self:createRoleAnim(self.curSelectRole,ctnHero)
	roleAnim:setVisible(true)
end

function SelectRoleView:resetHeroSpineAnim()
	for k,v in pairs(self.heroAnimCache) do
		if v then
			v:setVisible(false)
		end
	end
end

-- 创建角色动画
function SelectRoleView:createRoleAnim(curSelectRole,ctnNode)
	local hid = self.hidList[curSelectRole]
	self.hid = hid
	
	local heroSpineAnim = self.heroAnimCache[hid]
	local treasureSourceData = FuncChar.getDefaultTreasureSourceData(hid)
	if not heroSpineAnim then
		local spine = FuncChar.getSpineAni(hid)
		spine:setSkin("zi_se")
		spine:setScale(1.7)
		spine:pos(0,40)
		-- spine:playLabel(treasureSourceData["stand"])

		spine:addto(ctnNode)

		-- 缓存动画
		heroSpineAnim = spine
		self.heroAnimCache[hid] = heroSpineAnim
	end

	heroSpineAnim:playLabel(treasureSourceData["stand"])

	return heroSpineAnim
end

-- 选择男性
function SelectRoleView:onSelectMale()
	if self.curSelectRole == self.roleType.ROLE_MALE then
		return
	end

	self.curSelectRole = self.roleType.ROLE_MALE
	self:updateUI()
end

-- 选择女性
function SelectRoleView:onSelectFemale()
	if self.curSelectRole == self.roleType.ROLE_FEMALE then
		return
	end

	self.curSelectRole = self.roleType.ROLE_FEMALE
	self:updateUI()
end

-- 选角色确定
function SelectRoleView:onConfirmTap()
	UserServer:setHero(self.hid, c_func(self.onHeroSetOk, self))
end

function SelectRoleView:onHeroSetOk()
	self:startHide()
	LoginControler:showEnterGameResLoading()
end

return SelectRoleView
