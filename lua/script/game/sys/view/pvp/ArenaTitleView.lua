--
-- Author: ZhangYanguang
-- Date: 2015-12-18
-- 竞技场称号界面

local ArenaTitleView = class("ArenaTitleView", UIBase)

function ArenaTitleView:ctor(winName)
    ArenaTitleView.super.ctor(self, winName)
end

function ArenaTitleView:loadUIComplete()
	self:registerEvent()
	self:initData()

	self:initScrollCfg()
	self:adjustScrollBg()
	self:setViewAlign()
	self:updateUI()
end 

function ArenaTitleView:registerEvent()
	ArenaTitleView.super.registerEvent()
    self.btn_close:setTap(c_func(self.close, self))
end

function ArenaTitleView:setViewAlign()
	FuncCommUI.setViewAlign(self.btn_close, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_1, UIAlignTypes.LeftTop)
	local scale = GameVars.height*1.0/GameVars.maxResHeight
	FuncCommUI.setScrollAlign(self.scroll_list, UIAlignTypes.Middle, 0,1)

end

function ArenaTitleView:adjustScrollBg()
	local rect = self.scale9_1:getContainerBox()
	local heightDelta = GameVars.height - GameVars.maxResHeight
	local height = rect.height + heightDelta
	self.scale9_1:runAction(act.moveby(0,0, heightDelta/2))
	self.scale9_1:setContentSize(cc.size(rect.width, height))
end

function ArenaTitleView:initData()
	self.titleRules = {1}
	self.titleList = FuncPvp.getTitleIdList()
end

-- 初始化滚动配置
function ArenaTitleView:initScrollCfg()
	self.panel_head:setVisible(false)
	self.panel_seperator:setVisible(false)
	self.panel_title_preview:setVisible(false)

    local createTitleRuleFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_head)
        self:initHeadView(view, itemData)
        return view
    end

    local createSeperatorFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_seperator)
        return view
    end

    local createTitleFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_title_preview)
        self:initTitleView(view,itemData)
        return view
    end

	self.scrollParams = {
		{
			data = self.titleRules,
            createFunc = createTitleRuleFunc,
            perNums = 1,
            offsetX = 48,
            offsetY = 6,
            itemRect = {x=0,y=-208,width=775,height=208},
            heightGap = 0,
            perFrame = 1,
		},
		{
			data = {1},
            createFunc = createSeperatorFunc,
            perNums = 1,
            offsetX = 177,
            offsetY = 20,
            itemRect = {x=0,y=-40,width=490,height=40},
            heightGap = 20,
            perFrame = 1,
		},
		{
			data = self.titleList,
            createFunc = createTitleFunc,
            perNums = 1,
            offsetX = 17,
            offsetY = 10,
            itemRect = {x=0,y=-189,width=834,height=189},
            heightGap = 0,
            perFrame = 2,
		},
	}
end

-- 更新title说明
function ArenaTitleView:initHeadView(itemView,data)
	itemView.txt_title:setString(GameConfig.getLanguage("tid_pvp_1032"))
	itemView.txt_1:setString(GameConfig.getLanguage("tid_pvp_1033"))
	itemView.txt_2:setString(GameConfig.getLanguage("tid_pvp_1034"))

	local totalAddMana = 0
	local ability = UserModel:getAbility()
	for i,tid in ipairs(self.titleList) do
		local titleAchieved = FuncPvp.hasAchieveTitle(ability, tid)
		if titleAchieved then
			--TODO 设置属性加成
			local attrInfo = FuncPvp.getAttrEffectByTitleId(tid)
			totalAddMana = attrInfo.mana
			itemView['txt_'..(i+2)]:setString(attrInfo.effectStr)
		else
			itemView['txt_'..(i+2)]:visible(false)
		end
	end
	itemView.txt_11:setString(string.format(" + %s", totalAddMana))
end

function ArenaTitleView:initTitleView(itemView, titleId)
	---- 称号名称
	itemView.mc_1:showFrame(tonumber(titleId))
	local ability = UserModel:getAbility()
	local titleAchieved = FuncPvp.hasAchieveTitle(ability, titleId)
	if titleAchieved then
		itemView.mc_getmark:showFrame(1)
	else
		itemView.mc_getmark:showFrame(2)
	end

	local condition = FuncPvp.getTitleCondition(titleId)
	local attrInfo = FuncPvp.getAttrEffectByTitleId(titleId)

	local panel_info = itemView.panel_info
	panel_info.txt_1:setString(GameConfig.getLanguage("tid_pvp_1033"))
	panel_info.txt_2:setString(GameConfig.getLanguage("tid_pvp_1034"))
	panel_info.txt_3:setString(GameConfig.getLanguageWithSwap("tid_pvp_1035", condition))

	panel_info.txt_4:setString(attrInfo.effectStr)
	panel_info.txt_5:setString(string.format(" + %s", attrInfo.mana))

	if not titleAchieved then
		FilterTools.setGrayFilter(itemView.panel_info)
		FilterTools.setGrayFilter(itemView.scale9_1)
	end
end

function ArenaTitleView:updateUI()
	-- 创建滚动条
    self.scroll_list:styleFill(self.scrollParams)
end

function ArenaTitleView:close()
    self:startHide()
end

return ArenaTitleView
