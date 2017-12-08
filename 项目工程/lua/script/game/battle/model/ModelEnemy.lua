--
-- Author: XD
-- Date: 2014-07-10 12:03:53
--主要处理 一些敌人的一些特殊行为
--
local Fight = Fight
local FuncDataSetting  = FuncDataSetting
ModelEnemy = class("ModelEnemy", ModelHero)

--重写回合开始前做的事
function ModelEnemy:doRoundFirst(  )
	ModelEnemy.super.doRoundFirst(self)
	--判断回合数是否到了
	self:checkHeadBuffRound()
end

--判断头顶buff的回合
function ModelEnemy:checkHeadBuffRound(  )
	--如果没有beKillInfo
	local beKillInfo = self.data:beKill() 
	if not beKillInfo then
		return
	end
	--判断回合
	local round = self.logical.roundCount
	round = math.ceil(round/2)
	if round >= tonumber(beKillInfo[3]) then
		--那么情况data的kill 信息 同时自身加buff
		--如果是做攻击包
		echo("__自己把头顶特效吃了")
		self:doBeKillEnemyBuff(beKillInfo,self)
		--然后把beKill信息置空
		self.data.datas.beKill = nil
	end

end