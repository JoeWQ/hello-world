-- Author: ZhangYanguang
-- Date: 2017-01-12
-- 主角升品界面

local CharQualityLevelUpView = class("CharQualityLevelUpView", UIBase);

function CharQualityLevelUpView:ctor(winName)
    CharQualityLevelUpView.super.ctor(self, winName);
end

function CharQualityLevelUpView:loadUIComplete()
	self:initData()
	self:initView()
	self:registerEvent()

	self:updateUI()
end 

function CharQualityLevelUpView:initData(playerData)
	local charId = UserModel:getCharId()
	self.charInitData = FuncChar.getHeroData(charId)
end

function CharQualityLevelUpView:initView(playerData)
	self:registClickClose("out");
end

function CharQualityLevelUpView:registerEvent()
	-- 关闭
	self.btn_close:setTap(c_func(self.startHide,self))
	-- 取消
	self.btn_1:setTap(c_func(self.startHide,self))
	-- 升品
	self.btn_2:setTap(c_func(self.doQualityLevelUp,self))

	EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end

function CharQualityLevelUpView:updateUI()
	local curQuality = UserModel:quality()
	local nextQuality = CharModel:getNextQuality()

	self:updateHeroMc(self.mc_1,self.txt_2,curQuality)
	self:updateHeroMc(self.mc_2,self.txt_3,nextQuality)

	-- 升下一品的消耗，是当前品的配置
	local nextQualityData = FuncChar.getCharQualityDataById(curQuality)

	local myLv = UserModel:level()
	local myCoin = UserModel:getFinanceByKey("coin")
	local needLv = nextQualityData.needLv
	local costCoin = nextQualityData.costCoin

	local mcNeedLv = self.panel_1.mc_1
	local mcCostCoin = self.panel_1.mc_2

	
	if tonumber(myLv) >= tonumber(needLv) then
		mcNeedLv:showFrame(1)
		self.isLevelEnough = true
	else
		-- 不足显示红色
		mcNeedLv:showFrame(2)
		self.isLevelEnough = false
	end

	-- 不足显示红色
	if tonumber(myCoin) >= tonumber(costCoin) then
		mcCostCoin:showFrame(1)
		self.isCoinEnough = true
	else
		mcCostCoin:showFrame(2)
		self.isCoinEnough = false
	end

	-- 等级达到X级
	mcNeedLv.currentView.txt_1:setString(GameConfig.getLanguageWithSwap("tid_char_1002",needLv))
	mcCostCoin.currentView.txt_1:setString(costCoin)
end

function CharQualityLevelUpView:updateHeroMc(mcView,txtName,quality)
	local qualityData = FuncChar.getCharQualityDataById(quality)

	-- 边框颜色
	local border = qualityData.border
	mcView:showFrame(tonumber(border))

	-- 主角icon
	local headIconPath = FuncRes.iconHead(self.charInitData.icon)
	local headImg = display.newSprite(headIconPath)
	mcView.currentView.ctn_1:addChild(headImg)

	-- 主角名称
	local plusName = ""
	if qualityData.stepName and qualityData.stepName ~= "" then
		plusName = "+" .. qualityData.stepName
	end
	txtName:setString(UserModel:name() .. plusName)
end

function CharQualityLevelUpView:doQualityLevelUp()
	local callBack = function(data)
		if data and data.result ~= nil then
			-- 升品成功
			echo("升品成功")

			self:startHide()
		else
			echo("升品失败")
		end
	end

	local nextQuality = CharModel:getNextQuality()
	if self.isLevelEnough then
		if self.isCoinEnough then
			CharServer:qualityLevelUp(callBack)
		else
			-- 跳到购买界面
			WindowControler:showWindow("CompBuyCoinMainView")
		end
	else
		local myQuality = UserModel:quality()
		if tonumber(nextQuality) > tonumber(myQuality) then
			-- 等级不足
			WindowControler:showTips(GameConfig.getLanguage("tid_char_1003"))
		else
			-- 已经升到最大品阶
			WindowControler:showTips(GameConfig.getLanguage("tid_char_1004"))
		end
		
	end
end

return CharQualityLevelUpView
