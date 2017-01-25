--
-- Author: gs
-- Date: 2016-10-12 14:51:47
--
local BattlePVPHpView = class("BattlePVPHpView", UIBase)


function BattlePVPHpView:loadUIComplete(  )







    --FuncCommUI.setViewAlign(self.scale9_bg,UIAlignTypes.LeftBottom)

    --FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundStart, self)

end


function BattlePVPHpView:initView(  )
end




function BattlePVPHpView:initControler( view,controler )
	--echoError("===================================")
    self._battleView = view
    self.controler = controler
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundChanged, self)
    self.panel_1.panel_1.progress_1:setPercent(100)
    self.panel_3.panel_2.progress_1:setPercent(100)
    -- self:initMyHpBar()
    -- self:initEnemyHpBar()
    -- self:onMyHpChanged()
    -- self:onEnemyHpChanged()
end


function BattlePVPHpView:onRoundChanged(  )
	self:initMyHpBar()
    self:initEnemyHpBar()
    self:onMyHpChanged()
    self:onEnemyHpChanged()
end


--[[
我方血量发生变化
]]
function BattlePVPHpView:onMyHpChanged(  )
	--math.round( view.hero.data:hp()/ view.hero.data:maxhp() *100 )
	local allHp = 0
	local curHp = 0
	local myCamp = self.controler.campArr_1
	for k,v in pairs(myCamp) do
		allHp = allHp + v.data:maxhp()
		curHp = curHp + v.data:hp()
	end
	if self.allMyHp ~= nil then allHp = self.allMyHp else self.allMyHp = allHp end
	local percent = math.round(curHp/allHp*100)
	--self.panel_1.panel_1.progress_1:tweenToPercent(percent)
	self.panel_3.panel_2.progress_1:tweenToPercent(percent)
end


--[[
敌方血量发生变化
]]
function BattlePVPHpView:onEnemyHpChanged(  )
	local allHp = 0
	local curHp = 0
	local enemyCamp = self.controler.campArr_2
	for k,v in pairs(enemyCamp) do
		allHp = allHp + v.data:maxhp()
		curHp = curHp + v.data:hp()
	end
	if self.allEnemyHp ~= nil then allHp = self.allEnemyHp else self.allEnemyHp = allHp end
	local percent = math.round(curHp/allHp*100)
	--self.panel_3.panel_2.progress_1:tweenToPercent(percent)
	self.panel_1.panel_1.progress_1:tweenToPercent(percent)
end


--[[
初始化我方血条
]]
function BattlePVPHpView:initMyHpBar(  )
	if self.iconInitedMyCamp  then 
		return 
	end
	--local allHp = 0
	local myCamp = self.controler.campArr_1
	local icon
	--local myMainHero
	for k,v  in pairs(myCamp) do
		--echo("----------------==================")
		if v:checkIsMainHero() then
			icon = FuncRes.iconHead(v.data:head()) 
		end
		v.data:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH,self.onMyHpChanged,self)
	end

	if icon == nil and #myCamp>0 then
		icon = FuncRes.iconHead(myCamp[1].data:head())
	end

	if icon then
		local iconSp = display.newSprite(icon):pos(0,0)
		iconSp:setScale(-0.5,0.5)
		--self.panel_1.panel_2.ctn_1:addChild(iconSp)
		self.panel_3.panel_1.ctn_1:addChild(iconSp)
	end
	self.iconInitedMyCamp  = true
end

--[[
初始化地方血条
]]
function BattlePVPHpView:initEnemyHpBar(  )
	if self.iconInitedEnemyCamp then
		return 
	end
	local enemyCamp = self.controler.campArr_2
	local icon 
	for k,v in pairs(enemyCamp) do
		--echo("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=")
		if v:checkIsMainHero() then
			icon = FuncRes.iconHead(v.data:head())
		end
		v.data:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH,self.onEnemyHpChanged,self)
	end
	if icon == nil and #enemyCamp>0 then
		icon = FuncRes.iconHead(enemyCamp[1].data:head())
	end
	if icon then
		local iconSp = display.newSprite(icon):pos(0,0)
		--iconSp:setScaleX(-1)
		iconSp:setScale(0.5,0.5)
		self.panel_1.panel_2.ctn_1:addChild(iconSp)
		--self.panel_3.panel_1.ctn_1:addChild(iconSp)
	end
	self.iconInitedEnemyCamp = true
end





return BattlePVPHpView