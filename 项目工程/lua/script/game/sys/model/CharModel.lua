-- Author: ZhangYanguang
-- Date: 2016-04-14
-- 主角系统数据类

local CharModel = class("CharModel",BaseModel)

function CharModel:init(d)
	self.modelName = "char"
	self:sendRedStatusMsg()
end

-- 发送小红点状态消息
function CharModel:sendRedStatusMsg() 
	-- todo by zhangyanguang
	-- local isShowRedPoint = CharModel:showRedPoint() or NatalModel:isNatalRedPoint() or TalentModel:isTalentRedPoint()
    local isShowRedPoint = true
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,{ redPointType = HomeModel.REDPOINT.DOWNBTN.CHAR, isShow = isShowRedPoint })
end

-- 初始化全局变量
function CharModel:initData()
	-- 缓存最大品阶
	self.maxCharQuality = nil
end

--更新数据
function CharModel:updateData(data)
	CharModel.super.updateData(self,data);
end

--删除数据
function CharModel:deleteData(data) 
	
end

-- 主角系统战斗属性
function CharModel:getCharFormatFightAttribute()
	local charAttrInfo = self:getCharFightAttribute()
    local attrDatas = FuncChar.formatFightAttribute(charAttrInfo)
    return attrDatas
end

-- 主角系统战斗属性
function CharModel:getCharFightAttribute()
	local charAttrData = FuncBattleBase.getUserDetailData(UserModel:getUserData())
	local attributeData = FuncChar.getAttributeData()

	local attrData = {}
	for k,v in pairs(charAttrData) do
		if FuncChar.hasAttributeKey(k) then
			attrData[k] = v.num
		end
	end

	return attrData
end

-- 获取主角分组战斗属性（战斗属性列表展示)
-- groupInfo:战斗属性分组配置
function CharModel:getCharGroupFightAttribute(groupInfo)
	local quality = UserModel:quality()
	local charId = UserModel:getCharId()
	local charAttrData = FuncChar.getCharFightAttribute(charId,quality)

	local charFightAttrData = {}

	local findAttrValue = function(attrId,charAttrData)
		for i=1,#charAttrData do
			if attrId == charAttrData[i].key then
				return charAttrData[i].value
			end
		end

		return 0
	end

	local sortAttrs = function(groupAttrData)
		table.sort(groupAttrData,function(a,b)
			local aOrder = FuncBattleBase.getAttributeOrder(a.key)
			local bOrder = FuncBattleBase.getAttributeOrder(b.key)
			return aOrder < bOrder
		end)

		return groupAttrData
	end

	for i=1,#groupInfo do
		local groupAttrData = {}

		local curGroup = groupInfo[i]
		for j=1,#curGroup do
			local attrId = curGroup[j]
			local attr = {
				key = curGroup[j],
				value = findAttrValue(attrId,charAttrData),
				order = FuncChar.getAttributeOrderById(attrId)
			}

			groupAttrData[#groupAttrData+1] = attr
		end
		
		charFightAttrData[#charFightAttrData+1] = sortAttrs(groupAttrData)
	end

	return charFightAttrData
end

-- 是否展示主角小红点
function CharModel:showRedPoint()
	-- todo
	return true
end

--得到主角头像
function CharModel:getCharIconSp()
	return self:getCharIconByHid( tostring(UserModel:avatar()) );
end

--通过hid获得icon
function CharModel:getCharIconByHid(hid)
	local iconConfig = FuncChar.getHeroAvatar(tostring(hid));
	local path = FuncRes.iconHero( iconConfig );
	return display.newSprite(path);
end

-- 判断是否可以升品
function CharModel:checkQualityLevelUp(qualityId)
	local canLevelUp = false
	local myQuality = UserModel:quality()

	local qualityData = FuncChar.getCharQualityDataById(qualityId)
	local myLevel = UserModel:level()
	-- local myCoin = UserModel:getFinanceByKey("coin")

	if tonumber(qualityId) < tonumber(CharModel:getCharMaxQuality()) then
		-- 可升品，不判断金钱
		if tonumber(myLevel) >= tonumber(qualityData.needLv) then
		-- if myLevel >= tonumber(qualityData.needLv) and myCoin >= tonumber(qualityData.costCoin) then
			canLevelUp = true
		end
	end

	return canLevelUp
end

-- 获取最大品阶
function CharModel:getCharMaxQuality()
	if not self.maxCharQuality then
		local allQualityData = FuncChar.getCharQualityData()
		local maxQuality = 0
		for k,_ in pairs(allQualityData) do
			if tonumber(k) > tonumber(maxQuality) then
				maxQuality = k
			end
		end

		self.maxCharQuality = maxQuality
	end
	
	return self.maxCharQuality 
end

-- 获取下一个品阶
function CharModel:getNextQuality()
	local myQuality = UserModel:quality()

	local nextQuality = myQuality + 1
	local maxQuality = self:getCharMaxQuality()
	if tonumber(nextQuality) >= tonumber(maxQuality) then
		nextQuality = maxQuality
	end

	return nextQuality
end

return CharModel

