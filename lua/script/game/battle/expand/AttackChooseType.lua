
local Fight = Fight
AttackChooseType = {}


function AttackChooseType:atkChooseByType(attacker, atkData,attTarget, myCampArr, toCampArr,skill  )
	
	local campArr 
	local xArr = atkData.xChooseArr
	local yType = atkData.yChooseType

	local useWay = atkData:sta_useWay()
	local firstHero 
	if useWay == 1 then
		campArr = myCampArr
		--x方向偏移
		firstHero = self:findFirstHero(campArr,attacker,atkData.xChooseArr,atkData.yChooseType)
	else
		campArr = toCampArr
	end

	local resultArr
	local  startXIndex ,startYIndex
	if not skill then
		startXIndex = 1
		startYIndex = 1
	else
		startXIndex = skill.startXIndex
		startYIndex = skill.startYIndex
	end
	--如果是作用在我方的
	if useWay == 1 then
		if not firstHero then
			return 
		end
		startXIndex = firstHero.data.gridPos.x
		resultArr = self:findHeroesBySkillPos( startIndex,startYIndex,xArr,yType,firstHero, campArr,attacker )
	else
		if attacker.logical.attackSign and attacker.logical.attackSign.camp ~= attacker.camp then
			firstHero = attacker.logical.attackSign
		end
		resultArr = self:findHeroesBySkillPos( startXIndex,startYIndex,xArr,yType,nil, campArr,attacker )

		
	end


	local filterId = atkData:sta_filterId()
	if filterId then
		local filteObj = ObjectFilterAi.new(filterId)
		filteObj.heroModel = attacker
		local tempValue 
		tempValue,resultArr = filteObj:startChoose(attacker, nil, resultArr, nil)
	end



	return resultArr
end

--找对位的第一个英雄
function AttackChooseType:findFirstYposHero( attacker,heroArr )
	local hero1 = heroArr[1]
	local hero2 = heroArr[2]
	if not hero2 then
		return hero1
	end

	--如果是大体型的 直接返回第一个
	if attacker.data:isBigger() then
		return hero1
	end
	if hero2.data.gridPos.x ~= hero1.data.gridPos.x then
		return hero1
	end
	if hero2.data.gridPos.y == attacker.data.gridPos.y then
		return hero2
	end
	return hero1


end


--根据各种条件筛选符合条件的人
function AttackChooseType:secondChooseHeroes( targetArr,chooseTypeArr,atkNums )
	targetArr = targetArr or {}
	--给hero 临时定义排序属性 __tempValue
	local sortByProp = function (hero1,hero2  )
		for i,v in ipairs(chooseTypeArr) do

			local key = v.k
			local value = v.v
			local chooseType = v.t
			--如果是按照属性选择 目前只有属性选择
			if chooseType == "1" then
				--如果是 越大 越靠前
				if value == 1 then
					if hero1.data[key](hero1.data) > hero2.data[key](hero2.data) then
						return true
					elseif hero1.data[key](hero1.data) < hero2.data[key](hero2.data) then
						return false
					end
				else
					if hero1.data[key](hero1.data) > hero2.data[key](hero2.data) then
						return false
					elseif hero1.data[key](hero1.data) < hero2.data[key](hero2.data) then
						return true
					end
				end
			end
		end
		return false
	end
	--如果有特殊排序方式
	if #targetArr >= 2 and chooseTypeArr then
		--如果是走随机的,单独先随机这个数组
		if #chooseTypeArr > 0 and chooseTypeArr[1].t =="0" then
			targetArr = BattleRandomControl.randomOneGroupArr(arr, index)
		else
			table.sort(targetArr,sortByProp)
		end
	end
	if not atkNums or atkNums == -1 then
		return targetArr
	end
	--在按照攻击数量
	local resultArr = {}
	for i=1,atkNums do
		if targetArr[i] then
			table.insert(resultArr, targetArr[i])
		end
	end
	return  resultArr

end


--


--找第一个能打的人
function AttackChooseType:findFirstHero( campArr, attacker,xArr,yType )

	local hero1 = campArr[1]
	local hero2 = campArr[2]


	local targetHero,targetHero2
	if yType == 3 then
		--只要找到了对应y上面的人 就不换行
		--如果只有一个人
		local yIndex = attacker.data.gridPos.y
		if #xArr == 1 then
			targetHero = self:findHeroByIndex(xArr[1], yIndex, campArr)

			if not targetHero then
				targetHero = self:findHeroByIndex(xArr[1], yIndex == 1 and 2 or 1, campArr)
			end
			if targetHero then
				return targetHero
			end
		--如果是有选择2个x方向的
		elseif #xArr == 2 then
			targetHero = self:findHeroByIndex(xArr[1], yIndex, campArr)
			targetHero2 = self:findHeroByIndex(xArr[2], yIndex, campArr)
			--找对应位置的人  如
			if targetHero  then
				return targetHero
			end
			if targetHero2  then
				return targetHero2
			end
			yIndex = yIndex ==1 and 2 or 1
			argetHero = self:findHeroByIndex(xArr[1], yIndex, campArr)
			targetHero2 = self:findHeroByIndex(xArr[2], yIndex, campArr)

			if targetHero  then
				return targetHero
			end
			if targetHero2  then
				return targetHero2
			end
		end
	else 
		for i,v in ipairs(xArr) do
			targetHero = self:findHeroByIndex(v, 1, campArr)
			if targetHero then
				return targetHero
			end
			targetHero = self:findHeroByIndex(v, 2, campArr)
			if targetHero then
				return targetHero
			end
		end
	end


	if not hero2 then
		return hero1
	end
	--如果 网格x坐标不相等 肯定是选择 最靠前的人
	if hero1.data.gridPos.x ~= hero2.data.gridPos.x then
		return hero1
	end

	--在来判断 网格坐标 优先选择 y坐标相等的人
	if hero1.data.gridPos.y == attacker.data.gridPos.y then
		return hero1
	else
		return hero2
	end

end

--根据技能的起始位置获取hero
function AttackChooseType:findHeroesBySkillPos( startXIndex,startYIndex,xArr,yType,targetHero, campArr,attacker )
	local resultArr = {}
	startXIndex = startXIndex or 1
	startYIndex = startYIndex or targetHero.data.gridPos.y
	local firstXIndex = xArr[1] + startXIndex -1
	local endXIndex = xArr[#xArr] + startXIndex -1
	--这里需要判断
	for i,v in ipairs(campArr) do
		--这里需要判断yType
		--如果是指定打上下排的
		local gridPos = v.data.gridPos
		--必须在x选择范围之类
		if gridPos.x >= firstXIndex and gridPos.x <= endXIndex then
			--如果是
			if yType == 1 or yType ==2 then
				if gridPos.y == yType  then
					table.insert(resultArr, v)
				end
			elseif yType == 0 then
				table.insert(resultArr, v)
			--如果是打对应Index
			elseif yType ==3 then
				if gridPos.y ==startYIndex or v.data:isBigger() then
					table.insert(resultArr, v)
				end
			end
		end
	end
	-- echo(#resultArr,"__打到的人的数量",startXIndex,firstXIndex,endXIndex)
	return  resultArr
end


--根据xChooseArr 和 当前锁定的人  返回 能选择到的人
function AttackChooseType:findFirstBySign( xArr,yType, targetHero, campArr,attacker)
	--有个前提就是 xArr里面的数必须是连续的 不允许分散开 否则就会出问题
	--如果是找对应 x方向的
	local hero1 = campArr[1]
	local hero2 = campArr[2]

	--找到xIndex
	local xIndex = targetHero.data.gridPos.x
	local yIndex = targetHero.data.gridPos.y

	local firstHero 
	--如果是打对应y列的 而且目标是大体形怪
	if yType == 3 and targetHero.data:isBigger() then
		yIndex = attacker.data.gridPos.y
	end

	--如果目标xIndex 在我的x范围内
	if xIndex >= xArr[1] and xIndex <= xArr[#xArr] then
		for i,v in ipairs(xArr) do
			firstHero = self:findHeroByIndex(v, yIndex, campArr)
			if firstHero then
				return firstHero
			end
		end
	--如果靠左了 那么直接返回追击目标
	elseif xIndex < xArr[1] then
		firstHero = targetHero
		return firstHero
	else
		--如果靠右  那么需要做偏移
		local xOff = xIndex - xArr[#xArr]
		for i,v in ipairs(xArr) do
			firstHero = self:findHeroByIndex(v + xOff, yIndex, campArr)
			if firstHero then
				return firstHero
			end
		end
	end
	dump(xArr,"xArr_yType"..yType)
	echoError("不应该走到这里来",targetHero.data.posIndex)

	return firstHero
end

--找指定位置的人 根据gridPos
function AttackChooseType:findHeroByIndex( xIndex,yIndex,campArr )
	for i,v in ipairs(campArr) do
		if v.data:isBigger() then
			if v.data.gridPos.x == xIndex then
				return v
			end
		else
			--必须 x 和y 相等
			if v.data.gridPos.x == xIndex and v.data.gridPos.y == yIndex then
				return v
			end
		end
	end
	return nil
end

--根据posIndex 找到指定的人
function AttackChooseType:findHeroByPosIndex( posIndex,campArr )
	for i,v in ipairs(campArr) do
		if v.data.posIndex == posIndex then
			return v
		end
	end
	return nil
end


--获取技能攻击点
function AttackChooseType:getSkillAttackPos( controler,model, skill )
	local chooseType = skill:sta_appear()

	local keepDistance = Fight.attackKeepDistance
	local xpos ,ypos
	local toCampArr = model.toArr
	local firstHero
	if controler.logical.attackSign then
		firstHero = self:findFirstBySign(skill.xChooseArr,skill.yChooseType, controler.logical.attackSign, toCampArr,model)
	else
		firstHero = self:findFirstHero(toCampArr,model,skill.xChooseArr,skill.yChooseType)
	end

	if not firstHero then
		dump(skill.xChooseArr,"__skil.hid"..skill.hid)
		for k,v in pairs(toCampArr) do
			echo(v.data.posIndex,"___剩余阵容位置---,index")
		end
		echoWarn("没有找到fristHero,skill.yChooseType",skill.yChooseType,controler.logical.attackSign and controler.logical.attackSign.data.posIndex or "no AtkSign")
	end
		

	skill.firstHeroPosIndex = firstHero.data.posIndex
	--找到第一个攻击点的位置偏移
	skill.startXIndex = firstHero.data.gridPos.x - skill.xChooseArr[1] + 1
	skill.startYIndex = firstHero.data.gridPos.y
	-- echo(skill.startXIndex,"_______技能的起始xIndex")
	--如果是跑第一个攻击目标人面前
	if chooseType == Fight.skill_appear_normal then
		xpos, ypos = firstHero._initPos.x - model.way * keepDistance,firstHero._initPos.y
		--如果大体型的
		if firstHero.data:isBigger() then
			ypos = Fight.initYpos_3
		end
	--如果是站在y轴中间
	elseif chooseType == Fight.skill_appear_ymiddle then
		xpos, ypos = firstHero._initPos.x - model.way * keepDistance
		ypos = Fight.initYpos_3

	elseif chooseType == Fight.skill_appear_myFirst then

		local chooseArr = AttackChooseType:atkChooseByType(model, skill.attackInfos[1][3],nil, model.campArr, model.toArr,skill  )

		  --self:findFirstHero(model.campArr,model,skill.xChooseArr,skill.yChooseType)
		if chooseArr[1] then
			firstHero =chooseArr[1]
			xpos, ypos = firstHero._initPos.x + firstHero.way * keepDistance,firstHero._initPos.y
			-- echo("____",xpos,firstHero.pos.x, firstHero.data.posIndex,firstHero.camp)
		else
			--如果没人
			xpos, ypos = model.pos.x,model.pos.y
			return xpos,ypos
			-- echoError("没有选择到人,技能id:%s",skill.hid)
		end
		
		--如果大体型的
		if firstHero.data:isBigger() then
			ypos = Fight.initYpos_3
		end

	--如果是屏幕中心
	elseif chooseType == Fight.skill_appear_toMiddle then
		-- 在屏幕正中间
		xpos = controler.logical:getAttackMiddlePos(model.toCamp)
		ypos = Fight.initYpos_3
	--如果是我方屏幕中心
	elseif chooseType == Fight.skill_appear_myMiddle then
		-- 在屏幕正中间
		xpos = controler.logical:getAttackMiddlePos(model.camp)
		ypos = Fight.initYpos_3
	elseif chooseType == Fight.skill_appear_myplace then
		-- 原地施法
		xpos = model.pos.x
		ypos = model.pos.y
	else
		echoWarn("错误的技能选择模式:",chooseType,"skillid:",skill.hid)
	end

	local offsetPos = skill:sta_pos()
	if offsetPos then
		xpos = xpos +offsetPos[1] * model.way
		ypos = offsetPos[2] + ypos
	end

	return xpos,ypos
end


--根据攻击区域 选择能攻击到的人, 目前暂时从最左边一个人数起
function AttackChooseType:getCanAttackEnemy(atkData,campArr,chooseType  )
	
	local length = #campArr
	if #campArr ==0 then
		return {}
	end
	local area = atkData:sta_area()
	if not area then
		echoError("没有配置攻击区域,hid:",atkData.hid)
		return {}
	end
	local dis = numEncrypt:getNum(area[2]) -numEncrypt:getNum(area[1])
	local start = 0
	local resultArr ={}
	if dis < 0 then
		echoError("攻击区域配范围小于0了,",atkData.hid)
		return {}
	end

	local first = campArr[1]
	table.insert(resultArr, first)
	for i=2,length do
		local enemy = campArr[i]
		if math.abs(enemy.pos.x - first.pos.x ) < dis then
			table.insert(resultArr,enemy)
		else
			break
		end
	end
	return resultArr
end


--获取一个技能能打到的人
function AttackChooseType:getSkillCanAtkEnemy( hero,skill )
	local attackInfos = skill.attackInfos
	local heroArr = {}
	if #hero.toArr == 0 then
		return heroArr
	end

	AttackChooseType:getSkillAttackPos(hero.controler,hero,skill)
	for i,v in ipairs(attackInfos) do
		if v[1] == Fight.skill_type_attack then
			--显示技能展示区域是不能做攻击标记的
			local chooseArr = AttackChooseType:atkChooseByType(hero, v[3],nil, hero.campArr, hero.toArr,skill  )
			if chooseArr then
				for ii,vv in ipairs(chooseArr) do
					if not table.indexof(heroArr, vv) then
						table.insert(heroArr, vv)
					end
				end
			end
		end
	end
	return  heroArr
end

--确定一个技能标记谁
function AttackChooseType:getSkillAttackSign( hero,skill)
	local lockType = skill:sta_lock()
	--如果已经有集火目标了  那么不需要
	if hero.logical.attackSign then
		return nil
	end
	--如果是没有攻击性行为的
	if lockType == 0 then
		return nil
	end
	local toArr = hero.toArr
	local targetHero = self:findHeroByIndex(lockType,hero.data.gridPos.y,toArr)
	if not targetHero then
		targetHero = self:findFirstYposHero(hero, toArr)
	end
	--那么通知英雄设置标记
	-- hero.logical:setAttackSign(targetHero)
	return targetHero

end


--返回技能能打到的第一个目标,以及是否是中后排,true表示是中后排 第三个值是返回 技能打到的所有人
function AttackChooseType:getSkillFirstAtkEnemy( hero,skill )

	local firstHero = self:getSkillAttackSign(hero, skill)
	if not firstHero then
		return nil  ,false
	end
	local toArr = hero.toArr
	local isHoupai = false
	if firstHero.data.gridPos.x ~= toArr[1].data.gridPos.x then
		if firstHero.camp ~= hero.camp then
			isHoupai = true
		end
	end

	return firstHero  ,isHoupai
end

--判断一个人能否达到另外一个人  以及是否是集火目标 ,
-- 返回 true true 表示 能打到 而且 这个人是集火目标 
function AttackChooseType:checkSkillCanAtkEnemy( attacker,skill,defender )
	local firstHero,isHoupai = self:getSkillFirstAtkEnemy(attacker,skill)
	local heroArr = self:getSkillCanAtkEnemy(attacker, skill)
	local  canAtk = table.indexof(heroArr, defender) and true or false
	local isSign = firstHero == defender
	-- echo(canAtk,isSign,"___________aaaaa,canAtc",firstHero.data.posIndex, defender.data.posIndex,attacker.data.posIndex,#heroArr)
	return  canAtk,isSign
end


return AttackChooseType




