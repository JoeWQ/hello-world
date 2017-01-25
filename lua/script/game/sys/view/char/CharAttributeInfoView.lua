-- Author: ZhangYanguang
-- Date: 2017-01-10
-- 主角属性信息界面

local CharAttributeInfoView = class("CharAttributeInfoView", UIBase);

-- charId：如果是查看其它玩家的属性界面
function CharAttributeInfoView:ctor(winName,playerData)
    CharAttributeInfoView.super.ctor(self, winName);

    self:initData(playerData)
end

function CharAttributeInfoView:loadUIComplete()
	self:initView()
	self:registerEvent()

	self:updateUI()
end 

function CharAttributeInfoView:registerEvent()
	self.panelAttr.btn_ck:setTap(c_func(self.showAttributeListView,self))
	self.panelAttr.panel_mc:setTouchedFunc(c_func(self.showQualityLevelUpView, self))

	EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.onCharDataUpdate, self)
end

-- 初始化数据
function CharAttributeInfoView:initData(playerData)
	-- 默认显示自己的主角信息
	self.isMyChar = true
	self.charInfoData = nil

	-- 显示其它玩家的信息
	if playerData then
		self.isMyChar = false
		self.charInfoData = playerData
	else
		-- 显示自己的信息
		self.charInfoData = self:getMyCharInfo()
	end

	self.charInitData = FuncChar.getHeroData(self.charInfoData.charId)
end

function CharAttributeInfoView:onCharDataUpdate()
	if self.isMyChar then
		-- 显示自己的信息
		self.charInfoData = self:getMyCharInfo()
		self:updateUI()
	end
end

-- 获取自己的主角数据
function CharAttributeInfoView:getMyCharInfo()
	local charInfoData = {
			nickName = UserModel:name(),
			quality = UserModel:quality(),
			-- todo
			star = 1,
			level = UserModel:level(),
			exp = UserModel:exp(),
			charId = UserModel:getCharId(),
			treasures = {"304","313","302"}
		}
	return charInfoData
end

function CharAttributeInfoView:initView()
	-- UI适配
    FuncCommUI.setViewAlign(self.panel_icon,UIAlignTypes.LeftTop) 
	FuncCommUI.setViewAlign(self.panel_res,UIAlignTypes.MiddleTop)
	FuncCommUI.setScale9Align(self.scale9_resdi,UIAlignTypes.MiddleTop, 1, 0)

	self.panelAttr = self.panel_2
	self.panelChar = self.panel_1


	-- 更新动画
	self:showHeroInfo()
	-- 播放吊坠动画
	self:playRopeAnim()
	-- 更新法宝信息
	self:initTreasureInfo()
end

function CharAttributeInfoView:updateUI()
	local panelAttr = self.panelAttr
	local charInfoData = self.charInfoData
	local panelHead = self.panelAttr.panel_mc

	-- todo
	-- 战斗力
	local charAbility = 0
	if self.isMyChar then
		charAbility = UserModel:getAbility()
	end

	self.panelChar.panel_power.UI_comp_powerNum:setPower(charAbility)

	local qualityData = FuncChar.getCharQualityDataById(charInfoData.quality)
	
	-- 边框颜色
	local border = qualityData.border
	panelHead.mc_1:showFrame(tonumber(border))

	-- 主角icon
	local headIconPath = FuncRes.iconHead(self.charInitData.icon)
	local headImg = display.newSprite(headIconPath)
	panelHead.mc_1.currentView.ctn_1:addChild(headImg)

	-- 是否可升品
	panelHead.txt_1:setVisible(false)
	if self.isMyChar then
		if CharModel:checkQualityLevelUp(UserModel:quality()) then
			-- 可升品文本
			panelHead.txt_1:setVisible(true)
		end
	end

	-- 角色名称
	local plusName = ""
	if qualityData.stepName and qualityData.stepName ~= "" then
		plusName = "+" .. qualityData.stepName
	end

	local heroName = charInfoData.nickName .. plusName
	panelAttr.panel_jsname.txt_1:setString(heroName)

	local scale = string.lenword(heroName) / 9
	if scale < 0.45 then
		scale = 0.45
	end
	-- 名字文本框背景图片缩放
	FuncCommUI.setScale9Scale(panelAttr.panel_jsname.scale9_1,scale)

	-- 星级
	local mcStar = panelAttr.mc_star
	mcStar:showFrame(mcStar.totalFrames)
	for i=1,mcStar.totalFrames do
		local curStar = mcStar.currentView["mc_" .. i]
		curStar:showFrame(1)
		if i > charInfoData.star then
			curStar:showFrame(2)
		end
	end

	-- 等级
	panelAttr.panel_progress.txt_1:setString(GameConfig.getLanguageWithSwap("tid_char_1001",charInfoData.level))

	-- 升级进度条
	local panelProgress = panelAttr.panel_progress.panel_blue
	-- 当前经验值
	local curExp = charInfoData.exp
	-- 下个等级经验
	local nextLevelExp = FuncChar.getCharMaxExpAtLevel(FuncChar.getCharNextLv(charInfoData.level))

	panelProgress.txt_1:setString(curExp .. "/" .. nextLevelExp)
	panelProgress.progress_1:setPercent(curExp / nextLevelExp * 100)


	-- 更新战斗属性
	self:updateAttrInfo()
end

-- 更新战斗属性
function CharAttributeInfoView:updateAttrInfo()
	local attrIdArr = {
		2,  --气血
		10, --攻击
		11, --物防
		12, --法防
	}

	for i=1,#attrIdArr do
		local txtAttr = self.panelAttr["txt_" .. i]
		local attrValue = self:getAttrValue(attrIdArr[i])
		if txtAttr then
			txtAttr:setString(attrValue)
		end
	end
end

function CharAttributeInfoView:playRopeAnim()
	local ctnAnim = self.panelAttr.ctn_guazhui

	local animName = "eff_zhujue_diaozhui"
    local ropeAnim = ViewSpine.new(animName, {}, nil,animName);
    ropeAnim:pos(-10,50)
    ropeAnim:playLabel(animName)
    ctnAnim:addChild(ropeAnim)
end

-- 展示主角信息
function CharAttributeInfoView:showHeroInfo()
	local charId = self.charInfoData.charId
	local ctnHero = self.panelChar.ctn_1
	local ctnBg = self.panelChar.ctn_2
	local charInitData = FuncChar.getHeroData(charId)

	-- 主角背景遮罩
	local bgMaskData = charInitData.bgMask
	local bgMaskSprite = display.newSprite(FuncRes.iconOther(bgMaskData[1]))
	bgMaskSprite:pos(bgMaskData[2],bgMaskData[3])

	-- 主角立绘高亮背景
	local artBgData = self. charInitData.artBg
	self.bgSprite = display.newSprite(FuncRes.iconOther(artBgData[1]))
	self.bgSprite:pos(artBgData[2],artBgData[3])

	self.newBgSprite = FuncCommUI.getMaskCan(bgMaskSprite,self.bgSprite)
	ctnBg:addChild(self.newBgSprite)

	-- ctnBg:addChild(self.bgSprite)

	-- 立绘动画遮罩
	local artMaskData = charInitData.artMask
	local artMaskSprite = display.newSprite(FuncRes.iconOther(artMaskData[1]))
	artMaskSprite:pos(artMaskData[2],artMaskData[3])

	local artName = charInitData.art[1]
	local artScale = charInitData.art[2]
	local artPosX = charInitData.art[3]
	local artPosY = charInitData.art[4]

	-- 主角立绘动画
	local heroAnim = FuncRes.getArtSpineAni(artName)
	heroAnim:pos(artPosX,-180+artPosY)
	heroAnim:setScale(artScale)
	
	local newHeroAnim = FuncCommUI.getMaskCan(artMaskSprite,heroAnim)
	ctnHero:addChild(newHeroAnim)

	-- ctnHero:addChild(artMaskSprite)

	-- ctnHero:setVisible(false)

	-- 设置立绘背景触摸事件
	self:setHeroBgTouchFunc()
end

function CharAttributeInfoView:setHeroBgTouchFunc()
	local bgSprite = self.bgSprite

	local maxMove = 15
	-- 设置bg最大移动坐标
	local bgMaxPosX = bgSprite:getPositionX() + maxMove
	local bgMaxPosY = bgSprite:getPositionY() + maxMove

	local bgMinPosX = bgSprite:getPositionX() - maxMove
	local bgMinPosY = bgSprite:getPositionY() - maxMove


	local lastX = nil
	local lastY = nil

	local endX = nil
	local endY = nil

	local moveX = 0
	local moveY = 0

	local span = 1
	local scale = 3

	local moveHeroBg = function(moveX,moveY)
		local x,y = bgSprite:getPosition()
		local absMoveX = math.abs(moveX) / scale
		local absMoveY = math.abs(moveY) / scale

		if absMoveX >= span then
			if moveX > 0 then
				x = bgSprite:getPositionX() - absMoveX
			else
				x = bgSprite:getPositionX() + absMoveX
			end
		end

		if absMoveY >= span then
			if moveX > 0 then
				y = bgSprite:getPositionY() - absMoveY
			else
				y = bgSprite:getPositionY() + absMoveY
			end
		end

		if x > bgMaxPosX then
			x = bgMaxPosX
		elseif x < bgMinPosX then
			x = bgMinPosX
		end

		if y > bgMaxPosY then
			y = bgMaxPosY
		elseif y < bgMinPosY then
			y = bgMinPosY
		end

		bgSprite:setPosition(x, y)
	end

	local onTouchHeroBg = function(event)
		if event.name == "began" then
			lastX = event.x
			lastY = event.y
		elseif event.name == "moved" then
			if not lastX or not lastY then
				return
			end

			endX = event.x
			endY = event.y

			moveX = endX - lastX
			moveY = endY - lastY

			moveHeroBg(moveX,moveY)
		elseif event.name == "ended" then
			endX = event.x
			endY = event.y

			moveX = endX - lastX
			moveY = endY - lastY

			moveHeroBg(moveX,moveY)
		end
	end

	local onTouchFunc = c_func(onTouchHeroBg)
	self.newBgSprite:setTouchedFunc(onTouchFunc, nil,true,onTouchFunc,onTouchFunc,false,onTouchFunc)
end

function CharAttributeInfoView:initTreasureInfo()
	-- 更新三个法宝信息
	for i=1,3 do
		local panelTreasure = self.panelAttr["panel_" .. i]

		local treasureId = self.charInfoData.treasures[i]
		-- 法宝icon
		local treasureIcon = display.newSprite(FuncRes.iconTreasure(treasureId))
		treasureIcon:setScale(0.5)
		panelTreasure.ctn_1:addChild(treasureIcon)

		FuncCommUI.regesitShowTipView(panelTreasure,"CharTreasureTipView",treasureId,true)
	end
end

function CharAttributeInfoView:getAttrValue(attrId)
	local charAttrData = FuncChar.getCharFightAttribute(self.charInfoData.charId,self.charInfoData.quality)
	local attrValue = 0
	for i=1,#charAttrData do
		if attrId == charAttrData[i].key then
			attrValue = charAttrData[i].value
		end
	end

	attrValue = FuncBattleBase.getFormatFightAttrValue(attrId,attrValue)

	return attrValue
end

-- 展示升品界面
function CharAttributeInfoView:showQualityLevelUpView()
	if not self.isMyChar then
		return
	end

	if tonumber(UserModel:quality()) == tonumber(CharModel:getCharMaxQuality()) then
		WindowControler:showTips(GameConfig.getLanguage("tid_char_1005"))
	else
		WindowControler:showWindow("CharQualityLevelUpView")
	end
end

function CharAttributeInfoView:showAttributeListView()
	WindowControler:showWindow("CharAttributeListView")	
end

return CharAttributeInfoView;
