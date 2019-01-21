-- Author: ZhangYanguang
-- Date: 2017-01-13
-- 主角天赋界面

local CharTalentView = class("CharTalentView", UIBase);

function CharTalentView:ctor(winName)
    CharTalentView.super.ctor(self, winName);

end

function CharTalentView:loadUIComplete()
	self:initData()
	self:initView()
	self:registerEvent()

	self:updateUI()
end 

function CharTalentView:registerEvent()
	self.btn_1:setTap(c_func(self.showAttributeListView,self))
	self.btn_2:setTap(c_func(self.resetTalent,self))

	self.btn_left:setTap(c_func(self.goLastTalentPage,self))
	self.btn_right:setTap(c_func(self.goNextTalentPage,self))
end

function CharTalentView:initData(playerData)
	self.whicPage = 1
end

function CharTalentView:initView(playerData)
	-- UI适配
    FuncCommUI.setViewAlign(self.panel_icon,UIAlignTypes.LeftTop) 
	FuncCommUI.setViewAlign(self.panel_res,UIAlignTypes.MiddleTop)
	FuncCommUI.setScale9Align(self.scale9_resdi,UIAlignTypes.MiddleTop, 1, 0)
end

function CharTalentView:updateUI()
	local mcTalentPage = self.mc_1
	mcTalentPage:showFrame(self.whicPage)

	local panelName = mcTalentPage.currentView.panel_hun
	local  txtTalentCoin = mcTalentPage.currentView.txt_2
	txtTalentCoin:setString("88")

	panelName.txt_1:setString("白虎之关")
end

function CharTalentView:showAttributeListView()
	WindowControler:showTips("属性加成列表")
end

function CharTalentView:resetTalent()
	WindowControler:showTips("重置天赋")
end

function CharTalentView:goLastTalentPage()
	WindowControler:showTips("上一个天赋页")
end

function CharTalentView:goNextTalentPage()
	WindowControler:showTips("下一个天赋页")
end


return CharTalentView