--
-- Author: xd
-- Date: 2016-11-14 16:46:54
--筛选过滤器
--
ObjectFilterAi = class("ObjectFilterAi", super)

--初始化 筛选器
function ObjectFilterAi:ctor(id)
	self.hid = id
	ObjectCommon.getPrototypeData( "battle.FilterAi",id ,self)
	self.trigCount = self:sta_trigCount() or 1
	--如果配置0 表示无限次触发
	if self.trigCount == 0 then
		self.trigCount = 9999
	end
	--阵营是全阵营
	self.camp = self:sta_camp() or 0
	--性别是全性别
	self.sex = self:sta_sex() or 0
	--职业是全职业
	self.profession = self:sta_pro() or 0
	--判断是级回合
	self.roundCount = self:sta_round() or  0
	--任意情况
	self.chance = self:sta_chance() or 0
	self.area = self:sta_area() or 0
	--人数比较
	self.numCompare = self:sta_numsC()
	if self.numCompare then
		self.numCompare = self.numCompare[1]
	end

	self.attrCompares = self:sta_attrC()

	self.xChooseArr = self:sta_x() or {0}
    if self.xChooseArr[1] == 0 then
    	self.xChooseArr = {1,2,3}
    end
    self.yChooseType = self:sta_y() or 0

end

--开始筛选
function ObjectFilterAi:startChoose(attacker,defender, targetArr ,skill )
	
	--如果技能配置了动作 但是自身是被控制了,那么就不应该触发
	if skill and skill:sta_action() and not self.heroModel.data:checkCanAttack(true) then
		return false,nil
	end

	local toArr = {}
	local campArr= {}
	--筛选结果数组
	local resultArr = {}
	if self.trigCount == 0 then
		return false, resultArr
	end
	local result = true
	

	--当有人死亡时 那么筛选数组就优先判定为死亡对象了
	if self.chance == Fight.chance_onDied  then
		--必须为同一阵营
		if self.heroModel.camp ~= defender.camp  then
			return
		end
		if defender.reliveState ~= 0 then
			campArr  = {}
			return false,campArr
		else
			campArr =  {defender}
		end
	else
		if targetArr then
			campArr = table.copy(targetArr)
			
		else
			--阵营筛选
			--如果是全阵营的
			if self.camp == 0 then
				campArr = array.merge(attacker.campArr ,attacker.toArr)
			else
				if self.camp ==1  then
					campArr = table.copy(attacker.campArr) 
				else
					campArr = table.copy(attacker.toArr)
				end
			end

			--没有指定范围
			if self.area == 0 then
				
				--如果是指定我为范围
			elseif self.area == 1 then
				campArr = {self.heroModel}
			--如果指定进攻者
			elseif self.area == 2 then
				campArr =attacker and {attacker} or {}
			end
			
		end

		--区域筛选
		if self.area == 1 then
			campArr = {self.heroModel}
		--如果是指定进攻着
		elseif self.area == 2 then
			campArr = attacker and {attacker} or {}
		--如果是非自己
		elseif self.area == 3 then
			table.removebyvalue(campArr, self.heroModel)
		--如果是排除进攻过的人
		elseif self.area == 4 then
			local length = #campArr
			for i=length,1,-1 do
				local hero = campArr[i]
				--如果已经攻击过
				if hero.hasAttacked then
					table.remove(campArr,i)
				end
			end
			
		end
	end

	--对技能状态进行筛选
	campArr = self:checkSkillState(campArr)


	--对人数进行 初步筛选
	campArr = self:chooseOneCampArr(campArr,attacker)
	
	--遍历满足属性比较的数组
	for i,v in ipairs(campArr) do
		if self:compareAttr(v,defender) then
			table.insert(resultArr, v)
		end
	end
	
	--如果有人数比较的
	if self.numCompare then
		--如果是和敌方比较人数 那么重新比较人数
		if self.numCompare.num == 0 then
			campArr = self:chooseOneCampArr(self.heroModel.campArr,self.heroModel)
			toArr = self:chooseOneCampArr(self.heroModel.toArr,self.heroModel)
			result = self:checkCompare( #campArr,#toArr,self.numCompare.compare )
			resultArr = self:cutChooseNums(self:sta_chooseNum(),campArr)
		else
			result = self:checkCompare( #campArr,self.numCompare.num,self.numCompare.compare )
			resultArr = self:cutChooseNums(self:sta_chooseNum(),campArr)
		end
	else
		--截取人数
		resultArr = self:cutChooseNums(self:sta_chooseNum(),resultArr)
	end


	--对结果进行排序



	if #resultArr == 0 then
		return false ,resultArr
	end

	--如果技能是带召唤的,那么还附带特殊判定条件
	if skill and skill.hasSummonInfo then
		if not self:checkSkillSummon(skill) then
			return false, resultArr
		end
	end

	--如果满足结果判定了 那么减少一次筛选次数 直到不能筛选了
	if result then
		self.trigCount = self.trigCount - 1
	end

	--那么直接返回true
	return result, resultArr

end

--技能条件筛选
function ObjectFilterAi:checkSkillState( campArr )
	local skillState = self:sta_skillState()
	local length = #campArr
	if skillState == 0 or not skillState then
		return campArr
	--如果是伤害技
	elseif skillState == 1 then
		for i=length,1,-1 do
			local hero = campArr[i]
			local skill = hero:getNextSkill()
			--如果不是攻击技能
			if not skill.isAttackSkill then
				table.remove(campArr,i)
			end
		end
	--如果是辅助技能
	elseif skillState == 2 then
		for i=length,1,-1 do
			local hero = campArr[i]
			local skill = hero:getNextSkill()
			--移除掉伤害技
			if  skill.isAttackSkill then
				table.remove(campArr,i)
			end
		end
	end
	return campArr

end


--判断技能召唤条件是否满足
function ObjectFilterAi:checkSkillSummon( skill )
	local atkInfos = skill.attackInfos
	local logical = skill.heroModel.logical

	--必须是boss才触发召唤
	if self.heroModel.data:boss() ~= 1 then
		return false
	end

	for i,v in ipairs(atkInfos) do
		local atkData = v[3]
		local summonInfo = atkData:sta_summon()
		--判断指定位置上是否有人,如果没有人 直接判定为true
		if summonInfo then
			if not logical:findHeroModel(skill.heroModel.camp,summonInfo.pos) then
				return true
			end
		end
	end
	return false
end



--截取人数
function ObjectFilterAi:cutChooseNums(chooseNum,campArr  )
	chooseNum = chooseNum or 12 
	if chooseNum == -1 then
		chooseNum = 12
	end

	--在来排序
	local sortKey = self:sta_attrS()
	if sortKey then
		self:sortProp(campArr)
	end

	self:sortSkillState(campArr)

	local resultArr = {}
	for i=1,chooseNum do
		if campArr[i] then
			table.insert(resultArr,campArr[i])
		end
	end
	

	return resultArr
end

--选取对应的人数
function ObjectFilterAi:chooseOneCampArr( campArr,attacker )
	local resultArr = {}

	for i,v in ipairs(campArr) do
		--判断性别 坐标
		if self:checkSex(self.sex, v) and self:checkPos(self.xChooseArr, self.yChooseType, attacker, v)  
			and self:checkProfession(self.profession,v) 
		then
			table.insert(resultArr, v)
		end
	end
	--返回resultArr
	return resultArr

end

--判断职业
function ObjectFilterAi:checkProfession( profession,hero )
	--暂时判定正确
	if profession == 0 then
		return true
	end
	return profession == hero.data:profession()
end


--判断位置是否正确
function ObjectFilterAi:checkPos(xArr,yType,attacker, hero )
	if hero.data.gridPos.x < xArr[1] or hero.data.gridPos.x > xArr[#xArr] then
		return false
	end
	if hero.data:isBigger() then
		return true
	end
	if yType == 1 or yType == 2 then
		
		if hero.data.gridPos.y ~= yType then
			return false
		end
		return true
	elseif yType == 0 then
		return true
	else
		if hero.data.gridPos.y ~= attacker.data.gridPos.y then
			return false
		end
		return true
	end
	return true

end


--判断性别
function ObjectFilterAi:checkSex( sex,hero )
	if sex ==0 then
		return true
	end
	return hero.data:sex() == sex
end

--对筛选结果排序
function ObjectFilterAi:soreResultArr( resultArr )
	-- skillSort 先是技能筛选排序


end


--技能排序
function ObjectFilterAi:sortSkillState( resultArr )
	local skillSort = self:sta_skillSort()
	if skillSort == 0 or not skillSort then
		return resultArr
	end
	local sortFunc = function ( hero1,hero2 )
		local skill1 = hero1:getNextSkill()
		local skill2 = hero2:getNextSkill()
		--如果是优先选择aoe的
		if skillSort == 1 then
			local aoe1 = skill1:getAtkNums()
			local aoe2 = skill2:getAtkNums()
			local random = BattleRandomControl.getOneRandom()
			--如果2个都是aoe
			if aoe1 >= 2 and aoe2 >= 2 then
				return hero1.data.posIndex > hero2.data.posIndex
			else
				return aoe1 > aoe2
			end
		else
			return hero1.data.posIndex > hero2.data.posIndex
		end
	end

	table.sort(resultArr,sortFunc)

end


--排列属性
function ObjectFilterAi:sortProp( campArr )
	local sortKey = self:sta_attrS()
	local sortFunc = function ( hero1,hero2 )
		for i,v in ipairs(sortKey) do
			local key = v.key
			local value2
			local value1
			--判断是按绝对值还是百分比
			if v.valueT == 1 then
				value1 = hero1.data:getAttrByKey(key)
				value2 = hero2.data:getAttrByKey(key)
			else
				value1 = hero1.data:getAttrPercent(key)
				value2 = hero2.data:getAttrPercent(key)
			end
			--1增序  2减序
			if v.type == 1 then
				if value1 < value2 then
					return true
				elseif value1 > value2 then
					return false
				end
			else
				if value1 > value2 then
					return true
				elseif value1 < value2 then
					return false
				end
			end
		end
		return hero1.data.posIndex > hero2.data.posIndex
	end
	table.sort(campArr,sortFunc)
end


--比较属性
function ObjectFilterAi:compareAttr( attacker,defender )
	--如果是有属性比较的
	local result
	if self.attrCompares then
		for i,v in ipairs(self.attrCompares) do
			--如果是和防守方比较
			--比较属性 
			local value1 = attacker.data:getAttrByKey(v.key)
			local value2 = v.value
			if v.value == 0 then
				--如果没有防守方  那么返回空
				if not defender then
					return false
				end
				value2 = defender.data:getAttrByKey(v.key)
				--必须所有的 比较条件都满足才行
				result = self:checkCompare(value1,value2,v.compare)
				if not result then
					return false
				end
			else
				--如果是按比例比较
				if v.valueT == Fight.valueChangeType_ratio  then
					local value1 = attacker.data:getAttrPercent(v.key)* 100
					result = self:checkCompare(value1,value2,v.compare)
					-- echo(value1,value2,v.compare,"___比例比较属性",attacker.data.posIndex,attacker.camp)
					if not result then
						return false
					end
				--按固定数值比较
				elseif v.valueT == Fight.valueChangeType_num  then
					result = self:checkCompare(value1,value2,v.compare)
					if not result then
						return false
					end
				end
			end
		end
	end
	return true
end


--判断是否触发
function ObjectFilterAi:checkCanTrigger( roundCount,chance )
	local turnRound = math.ceil(roundCount/2)

	if self.trigCount == 0 then
		return false
	end

	--如果回合数不符合
	-- echo(self.roundCount,roundCount, self.chance, chance)
	if self.roundCount ~= 0 and self.roundCount > turnRound then
		return false
	end

	if self.chance ~= 0 and self.chance ~= chance  then
		return false
	end
	--回合数 和 chance 都满足了 就可以进行下一步筛选了
	return true

end

--判断比较 true 返回成  false 返回比较失败
--1大于,2大于等于,3等于,4小于等于,5小于)
function ObjectFilterAi:checkCompare( value1,value2,compareType )
	if compareType == 1 then
		return  value1 > value2
	elseif compareType == 2 then
		return  value1 >= value2
	elseif compareType == 3 then
		return  value1 == value2
	elseif compareType == 4 then
		return  value1 <= value2
	elseif compareType == 5 then
		return  value1 < value2
	else
		echoError("错误的比较模式:",compareType,"filterhid",self.hid)
		return false
	end

end


