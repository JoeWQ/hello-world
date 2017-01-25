--
-- Author: ZhangYanguang
-- Date: 2016-12-20
--
-- PVE NPC tool tip界面

local WorldNpcInfoTipView = class("WorldNpcInfoTipView", UIBase);

function WorldNpcInfoTipView:ctor(winName,npcId)
    WorldNpcInfoTipView.super.ctor(self, winName);

    self.npcId = npcId
end

function WorldNpcInfoTipView:loadUIComplete()
	self:registerEvent();
    self:registClickClose("out")

    self:initView()
    self:updateUI()
end 

function WorldNpcInfoTipView:registerEvent()

end

function WorldNpcInfoTipView:initView()
	local mcNpcInfo = self.mc_2or4

	self.npcInfo = FuncChapter.getNpcInfo(self.npcId)
	local buffIconArr = self.npcInfo.buffIcon
	-- buff数量
	local buffNum = #buffIconArr
	-- buff数量只能是2或4
	if buffNum == 2 then
		mcNpcInfo:showFrame(2)
	elseif buffNum == 4 then
		mcNpcInfo:showFrame(1)
	else
		echoWarn("buffIconArr config error ")
	end

	-- 基类需要四个箭头
	self.panel_left = mcNpcInfo.currentView.panel_1.panel_left
	self.panel_right = mcNpcInfo.currentView.panel_1.panel_right
	self.panel_up = mcNpcInfo.currentView.panel_1.panel_up
	self.panel_down = mcNpcInfo.currentView.panel_1.panel_down

	self.panel_left:setVisible(false)
	self.panel_up:setVisible(false)
	self.panel_down:setVisible(false)
end

function WorldNpcInfoTipView:updateUI()
	local mcNpcInfo = self.mc_2or4

	local npcInfo = self.npcInfo

	-- npcInfo 
	local panelNpcInfo = mcNpcInfo.currentView.panel_1

	-- 头像
	local panelHead = panelNpcInfo.panel_1
	local headImgPath = FuncRes.iconHead(npcInfo.head)
	local headImg = display.newSprite(headImgPath)

	-- 边框颜色，升品决定
	panelHead.mc_1:showFrame(npcInfo.color)
	local ctnHead = panelHead.mc_1.currentView.ctn_1
	headImg:setScale(0.9)
	ctnHead:addChild(headImg)

	-- 星级
	panelHead.mc_dou:showFrame(npcInfo.star)

	-- 名字
	local txtName = panelNpcInfo.txt_1
	txtName:setString(GameConfig.getLanguage(npcInfo.name))

	-- 等级
	local txtLevel = panelNpcInfo.txt_2
	txtLevel:setString("Lv" .. npcInfo.level)

	-- 类型（攻防辅)
	local mcType = panelNpcInfo.mc_gfj
	if npcInfo.type == 5 then
		mcType:showFrame(4)
	else
		mcType:showFrame(npcInfo.type)
	end

	-- 描述
	local txtDesc = panelNpcInfo.txt_3
	txtDesc:setString(GameConfig.getLanguage("#tid11500"))

	-- buff列表
	local panelBuff = panelNpcInfo.panel_2
	local buffDescArr = npcInfo.buffDesc
	local buffIconArr = npcInfo.buffIcon

	for i=1,#buffDescArr do
		local ctnBuff = panelBuff["ctn_" .. i]
		local txtBuffDesc = panelBuff["txt_" .. i]

		-- 创建buff icon
		local buffImgPath = FuncRes.iconBuff(buffIconArr[i])
		local buffImg = display.newSprite(buffImgPath)
		ctnBuff:addChild(buffImg)

		-- 设置buff描述
		txtBuffDesc:setString(GameConfig.getLanguage(buffDescArr[i]))
	end
end

return WorldNpcInfoTipView;
