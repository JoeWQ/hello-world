


EnemyInfo = class("EnemyInfo")

EnemyInfo.attr = nil

function EnemyInfo:ctor( hid )
	ObjectCommon.getPrototypeData( "level.EnemyInfo",hid,self )

	self.hid = hid
	self:getAttrCfg()
end


function EnemyInfo:getAttrCfg()
	self.attr = {}
	self.attr.hid = self.hid
	self.attr.rid = self.hid
	self.attr.lv 	= self:sta_lv()
	self.attr.energy = self:sta_energy() 
	if Fight.debugFullEnergy then
		self.attr.energy = 1000
	end
	self.attr.maxenergy = self:sta_maxenergy()
	self.attr.manaR = self:sta_manaR()
	self.attr.hp 	= self:sta_hp()
	self.attr.maxhp = self:sta_maxhp()
	--@测试
	if Fight.all_high_hp then
		self.attr.hp = 10000000
		self.attr.maxhp = 10000000
	end
	-- self.attr.hp = 50000
	-- 	self.attr.maxhp = 50000
	if Fight.enemy_low_hp then
		self.attr.hp = 1
		self.attr.maxhp = 1
	end

	self.attr.atk 	= self:sta_atk()
	self.attr.def = self:sta_def()
	self.attr.crit = self:sta_crit()
	self.attr.resist = self:sta_resist()
	self.attr.wreck = self:sta_wreck()
	self.attr.block = self:sta_block()
	self.attr.blockq = self:sta_blockq()
	

	self.attr.hit = 1--self:sta_hit()
	-- self.attr.dodge = self:sta_dodge()
	self.attr.critR = self:sta_critR()
	self.attr.injury = self:sta_injury() or 0 	--伤害率
	self.attr.avoid = self:sta_avoid()  or 0		--免伤率

	self.attr.dropCount = self:sta_dropCount() or 0
	self.attr.name	= GameConfig.getLanguage(self:sta_name())

	self.attr.moveSpd = self:sta_moveSpd()
	
	self.attr.treat = 100 		--治疗效果 
	self.attr.betreat = 100 		--被治疗效果 

	self.attr.boss = self:sta_boss() or 0
	self.attr.head = self:sta_head() or ""
	self.attr.icon = self:sta_icon() or ""
	self.attr.headBG = self:sta_headBG() or ""

	self.attr.artImg = self:sta_artImg() or ""
	-- self.attr.artTxt = self:sta_artTxt() or ""
	-- self.attr.artTrea = self:sta_artTrea() or ""
	-- self.attr.artTreaTxt = self:sta_artTreaTxt() or ""
	self.attr.sex = self:sta_sex() 						--性别
	self.attr.profession = self:sta_profession() 		--职业
	self.attr.viewSize = self:sta_viewSize() or {50,140}
	self.attr.viewScale = self:sta_viewScale() or 100
	self.attr.beusedScale = self:sta_beusedScale() or 100
	
	self.attr.vampire = 0 		--吸血 不单配 默认为0
    self.attr.reflect = 0 		--反弹 		默认为0

    --小技能的触发参数 初始值,每回合增加值,释放要求值
    self.attr.sskp = self.sta_sskp()

	--hpAi[vector;hp[int];t[int];id[string];p1[int];p2[int]]
	self.attr.hpAi = self:sta_hpAi() 
										or 
										{
										 -- 	{hp=85,t=1,id="1001",p1=1,p2=0},	
											-- {hp=84,t=2,id="30014",p1=1,p2=0},	
											-- {hp=83,t=1,id="1002",p1=1,p2=0},	
											-- {hp=50,t=1,id="1002",p1=1,p2=0},
											-- {hp=30,t=1,id="1003",p1=1,p2=0},
											-- {hp=10,t=1,id="1004",p1=1,p2=0},	
										} 

	self.attr.ability = self:sta_ability() 		--战力
	
	self.attr.beKill = self:sta_beKill()  		-- 被杀后做什么事

	self.attr.immunity = self:sta_immunity() or 0

	self.attr.figure = self:sta_figure() or 1 		--体积 默认是1
	if IS_CHECK_CONFIG then
		if not ( self.attr.figure == 1 or self.attr.figure ==2 or self.attr.figure == 4 or self.attr.figure ==6) then
			echoError(self.attr.hid.."EnemyInfo中的figure体型配置不正确,必须为 1 2 4 6")
		end
	end

	if self.attr.boss == 0 then
		self.attr.peopleType = Fight.people_type_monster -- 怪物的AiMode
	elseif self.attr.boss == 2 then
		self.attr.peopleType = Fight.people_type_npc
	else
		self.attr.peopleType = Fight.people_type_boss
	end

   

	self.attr.treasures = {}
	local baseTrea = self:sta_baseTrea()
	-- 近战
	if baseTrea then
		local trs = {}
		trs.hid = baseTrea
		trs.treaType = "base"
		table.insert(self.attr.treasures,trs)
	end

	for i=1, 2 do
		local treaCfg = self["sta_trea"..i](self)
		if treaCfg then
			local trs = {}
			trs.hid = treaCfg
			trs.treaType = "normal"
			table.insert(self.attr.treasures,trs)
		end
	end
end

return EnemyInfo


