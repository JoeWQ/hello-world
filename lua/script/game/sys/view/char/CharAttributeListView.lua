-- Author: ZhangYanguang
-- Date: 2017-01-11
-- 主角属性列表界面

local CharAttributeListView = class("CharAttributeListView", UIBase);

function CharAttributeListView:ctor(winName)
    CharAttributeListView.super.ctor(self, winName);

end

function CharAttributeListView:loadUIComplete()
	self:initData()
	self:initView()
	self:registerEvent()

	self:updateUI()
end 

function CharAttributeListView:registerEvent()
	self.btn_close:setTap(c_func(self.startHide,self))
end

function CharAttributeListView:initData(playerData)
	-- 属性分组配置
	local attrGroupInfo = {
		{
			2,		--气血
			10,		--攻击
			11,		--物理防御
			12		--法术防御
		},

		{
			13,		--暴击率
			15,		--暴击强度
			16,		--格挡率
			18,     --格挡强度
			14,		--抗暴率
			17		--破击率
		},

		{
			19,		--伤害率
			20,		--免伤率
			-- 21,		--控制率
			-- 22,     --免控率
			-- 25,		--治疗效率
			-- 26		--被治疗
		},
	}


	self.attrGroupListData = CharModel:getCharGroupFightAttribute(attrGroupInfo)
end

function CharAttributeListView:initView()
	self.scrollAttrList = self.scroll_1
	self.panelAttrItemView = self.panel_1

	self:registClickClose("out");
	
	self:initScrollCfg()
end

-- 初始化滚动条配置
function CharAttributeListView:initScrollCfg()
	self.panelAttrItemView:setVisible(false)
	local createAttrItemView = function(itemData)
		local itemView = UIBaseDef:cloneOneView(self.panelAttrItemView)
		self:setAttrItemView(itemView,itemData)

		return itemView
	end

	self.oneGroupAttrItemView = {
		data = {},
        createFunc = createAttrItemView,
        itemRect = {x=0,y=0,width = 208,height = 40},
        perNums= 1,
        offsetX = 94,
        offsetY = 0,
        widthGap = 0,
        heightGap = -13,
        perFrame = 50,
        test = 1,
	}
end

-- 动态构造滚动列表配置
function CharAttributeListView:buildItemScrollParams()
	local listParams = {}

	for i=1,#self.attrGroupListData do
		local groupParams = table.deepCopy(self.oneGroupAttrItemView)
		groupParams.data = self.attrGroupListData[i]
		if i == 1 then
			groupParams.offsetY = 20
		end
		listParams[#listParams+1] = groupParams
	end

	return listParams
end

-- 设置战斗属性值
function CharAttributeListView:setAttrItemView(itemView,itemData)
	local attrId = itemData.key
	local attrValue = itemData.value
	attrValue = FuncBattleBase.getFormatFightAttrValue(attrId,attrValue)

	local attrName = FuncBattleBase.getAttributeName(attrId)

	itemView.txt_1:setString(attrName .. ":")
	itemView.txt_2:setString(attrValue)
end

function CharAttributeListView:updateUI()
	local listParams = self:buildItemScrollParams()

	-- dump(listParams)
	self.scrollAttrList:styleFill(listParams)
end


return CharAttributeListView
