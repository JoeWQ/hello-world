

--
-- Author: cuiweibo
-- Date: 2016-05-11 18:00:00
-- 战斗 PVE 控制器


GameControlerPVE = class("GameControlerPVE",import(".GameControler"))

-- 初始化函数
function GameControlerPVE:ctor( ... )
	GameControlerPVE.super.ctor(self,...)
end

-- npc 对话判断
function GameControlerPVE:checkNpcDialog()
	local dlg = 0
	for i=1,#self.campArr_1 do
		local hero = self.campArr_1[i]
		-- F 类话语
		if hero.data.curTreasure:sta_isSuyan() == 1 then
			local per = hero.data:energy()/hero.data:maxenergy()
			if per < 0.25 and per > 0 then
				dlg = dlg < 1 and 1 or dlg
			end
		end

		-- E 类话语
		local hpPer = hero.data:hp()/hero.data:maxhp()
		if hpPer < 0.25 and hpPer > 0 then
			dlg = dlg < 2 and 2 or dlg
		end

		-- D 类说话
		if #self.campArr_2 > 0 then
			local dx1 = self.middlePos - self.campArr_1[1].pos.x
			local dx2 = self.campArr_2[1].pos.x - self.middlePos
			if dx1 > dx2 then
				dlg = dlg < 3 and 3 or dlg
			end
		end

		-- C类话语
		if #self.campArr_2 > 5 then
			dlg = dlg < 4 and 4 or dlg
		end			
	end
	-- AB类话语
	local ab = self:checkDialogAB()	
	dlg = dlg < ab and ab or dlg

	return dlg
end

-- A B 对话判断
function GameControlerPVE:checkDialogAB()
	local noDefA = true
	local noA = true
	for i=1,#self.campArr_1 do
		local hero = self.campArr_1[i]
		local curTreasure = hero.data.curTreasure
		--echo("---------------ddfffsdfsdf",hero.data.hid,curTreasure:sta_isSuyan(),curTreasure:sta_label2())
		if curTreasure:sta_isSuyan() ~= 1 then
			noA =  false
			if curTreasure:sta_label2() == 2 then
				--echo("3333333333333333333333___________",)
				noDefA = false
			end
		end
	end

	local dlg = 0
	if noA then
		dlg = 5
	end
	if noDefA then
		dlg = 6
	end
	--echo("----ddddddaaaaaaaaaaaaaaaaaa",noA,noDefA,dlg)
	return dlg
end

function GameControlerPVE:checkNpcTalk(dlg)
	
	local npcArr = {}
	for i=1,#self.campArr_1 do
		if self.campArr_1[i].data:peopleType() == Fight.people_type_npc then
			table.insert(npcArr, self.campArr_1[i] )
		end
	end
	local num = #npcArr
	if num <= 0 then
		return
	end
	local rand = math.random(num)
	local hero = npcArr[rand]

	local str = FuncBattleBase.getBattleTalkByIdx(hero,nil,dlg)
	hero.data:dispatchEvent(BattleEvent.BATTLEEVENT_TOPTALK,str)
end

-- 敌人说话
function GameControlerPVE:checkEnemyTalk()
	local num = #self.campArr_2
	if num <= 0 then
		return
	end
	local rand = math.random(num)
	local hero = self.campArr_2[rand]
	local idx = 1
	local per = hero.data:hp()/hero.data:maxhp()
	if per > 25 then
		idx = 2
	end
	
	local str = FuncBattleBase.getBattleTalkByIdx(hero,nil,idx)
	hero.data:dispatchEvent(BattleEvent.BATTLEEVENT_TOPTALK,str)
end

 
-- 检测对话
function GameControlerPVE:checkBubbleDialogue()
	if self.gameLeftTime%300 ~= 0 then
		return
	end
	--NPC说话
	local dlg = self:checkNpcDialog()
	if dlg ~= 0 then
		self:checkNpcTalk(10-dlg)
	end
	--敌人说
	self:checkEnemyTalk()
end


-- 获取战后的血量和能量
function GameControlerPVE:getRemainInfo( ... )
	if #self.campArr_1 == 0 then
		return {}
	end

	local remainInfo = {}
	local campArr = self.campArr_1
	for i=1,#campArr do
		local hero = campArr[i]
		if hero.data:peopleType() < Fight.people_type_summon then
			local rid = hero.data.rid
			if not remainInfo[rid] then
				remainInfo[rid] = {}
				remainInfo[rid].hp = hero.data:hp()
				remainInfo[rid].energy = hero.data:energy()
			end
		end
	end
	return remainInfo
end



return GameControlerPVE