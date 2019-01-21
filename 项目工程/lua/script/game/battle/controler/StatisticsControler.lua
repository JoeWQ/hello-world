--
-- Author: xd
-- Date: 2016-06-20 11:27:10
--
StatisticsControler = {}

--记录每回合每个技能造成的伤害
StatisticsControler.roundSkillDamage = nil

--每回合造成的总伤害
StatisticsControler.totalDamage = nil 


--[[
	--数据格式
	{
		roundCount = {
			rid = {
				treat = 0 --治疗量
				skillId = 1001
				damage = 0 --伤害量
			}
		} 
	}

]]

function StatisticsControler:init(controler )
	self.controler = controler

	self.totalDamage = {}
end


--统计伤害
function StatisticsControler:statisticsdamage(attacker,defender, skill , damage)
	--
	local rid = attacker.data.rid
	local round = self.controler.logical.roundCount
	if not self.totalDamage[round] then
		self.totalDamage[round]  = {}
	end
	if not self.totalDamage[round][rid] then
		self.totalDamage[round][rid] = {treat = 0,damage =0,skillId = skill.hid}
	end
	local info = self.totalDamage[round][rid]
	info.damage = info.damage + damage

end

--统计治疗
function StatisticsControler:statisticsTreat(attacker,defender, skill , treat  )
	local rid = attacker.data.rid
	local round = self.controler.logical.roundCount
	if not self.totalDamage[round] then
		self.totalDamage[round]  = {}
	end
	if not self.totalDamage[round][rid] then
		self.totalDamage[round][rid] = {treat = 0,damage =0,skillId = skill.hid }
	end
	local info = self.totalDamage[round][rid]
	info.treat = info.treat + treat
end

--获取当前回合的总伤害
function StatisticsControler:getRoundTotalDamage(  )
	local round = self.controler.logical.roundCount 
	local roundInfo = self.totalDamage[round]
	if not roundInfo then
		return 0
	end
	local damage = 0
	for k,v in pairs(roundInfo) do
		damage = damage + v.damage
	end

	return damage

end


--获取当前回合某个人的伤害
function StatisticsControler:getRidDamage( rid )
	local round = self.controler.logical.roundCount 
	local roundInfo = self.totalDamage[round]
	if not roundInfo then
		return 0
	end
	local rInfo = roundInfo[rid]
	if not rInfo then
		return 0
	end
	return rInfo.damage
end

--获取某个人的整场战斗的总伤害
function StatisticsControler:getRidTotalDamage( rid )
	local damage = 0
	for k,v in pairs(self.totalDamage) do
		if v[rid] then
			damage = damage + v[rid].damage
		end
	end
	return damage
end



function StatisticsControler:deleteMe(  )
	self.controler = nil
end