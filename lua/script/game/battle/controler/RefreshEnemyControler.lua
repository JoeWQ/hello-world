

RefreshEnemyControler = class("RefreshEnemyControler")

function RefreshEnemyControler:ctor(controler)
	self.controler = controler
end

--创建一个英雄 第几号位
function RefreshEnemyControler:createHeroes(objData, camp,posIndex,enterType)
	local hero 
	if camp == 2 then
		hero = ModelEnemy.new(self.controler,objData)
	else
		hero = ModelHero.new(self.controler,objData)
	end
	if objData.rid == self.controler.userRid then
		objData:setCharacter()
		self.controler.character = hero
	--如果敌方rid 是主角 不是boss
	elseif objData.rid == self.controler.enemyRid and objData:boss() ~= 1   then
		objData:setCharacter()
	end
	--记录初始坐标
	--计算坐标
	local  middlePos = self.controler.middlePos
	if camp == 1 and self.controler.gameMode ==Fight.gameMode_pve  then
		middlePos = GAMEHALFWIDTH 
	end

	local x,y = self:turnPosition(camp,posIndex,objData:figure(),middlePos)
	hero._initPos = {x=x,y=y,z=0}
	if not Fight.isDummy then
		local view = ViewSpine.new(hero.data.curSpbName,nil,nil,hero.data.curArmature) -- defArmature curArmature
		hero:initView(self.controler.layer.a122,view)

		
		-- enterType = Fight.enterType_stand
		-- hero:setCamp(camp,true)
		--如果是原地的
		local inAction = hero.data.sourceData.inAction 
		--只有pve 和gve 副本才会入场
		if camp == 1 or self.controler.gameMode ==Fight.gameMode_pvp  or self.controler.gameMode == Fight.gameMode_gve  then
			inAction = nil
		end
		
		--先判定是否有出场动作
		if inAction and enterType~= Fight.enterType_summon then
			--那么直接跳转到 入场动作
			hero:setPos(x,y,0)
			hero:setCamp(camp,true)
			-- hero:justFrame(Fight.actions.action_inAction)
			-- hero:stopFrame()
			--隐藏视图
			hero.myView:visible(false)
		else
			if enterType == Fight.enterType_stand then
				hero:setPos(x,y,0)
				hero:setCamp(camp,true)
			elseif enterType == Fight.enterType_runIn  then
				--那么 暂定跑进来的距离是500像素
				local moveDis = 500
				if camp == 2 then
					hero:setPos(x + moveDis ,y,0)
				else
					hero:setPos(x - moveDis ,y,0)
				end
				hero:setCamp(camp,true)
				if self.controler.gameMode ==Fight.gameMode_pvp  or self.controler.gameMode == Fight.gameMode_gve then
					local posParams = {x= x,y = y,speed = Fight.enterSpeed,call = {"standAction" }}
					hero:justFrame(Fight.actions.action_run )
					hero:moveToPoint(posParams)
				end
			elseif enterType == Fight.enterType_summon then
				hero:setPos(x,y,0)
				hero:setCamp(camp,true)
				if hero.data.sourceData.inAction then
					hero:justFrame(Fight.actions.action_inAction)
				end

			else
				echo("没有入场行为",enterType)
				hero:setPos(x,y,0)
				hero:setCamp(camp,true)
			end
		end
	else
		hero:setCamp(camp,true)
	end

	hero.data:setHeroModel(hero)

	self.controler:insertOneObject(hero)
	-- 会根据当前法宝切换成相应的视图
	if hero.myView then		
		local peopleType = hero.data:peopleType()
		-- 判断显示人物的信息
		if peopleType < Fight.people_type_summon then
			if peopleType == Fight.people_type_robot or peopleType == Fight.people_type_robot_user then
				hero._onlineState = Fight.state_show_yongli
				hero.data:dispatchEvent(BattleEvent.BATTLEEVENT_PLAYER_STATE,hero._onlineState)
			else
				hero._onlineState = Fight.state_show_zhengchang
				hero.data:dispatchEvent(BattleEvent.BATTLEEVENT_PLAYER_STATE,hero._onlineState)
			end
		end

		-- hero:setClickFunc()

	end
	hero:onInitComplete()
	
	return hero
end


function RefreshEnemyControler:turnPosition( camp,posIndex,figure,middlePos )
	figure = figure or 1
	
	local xIndex = math.ceil( posIndex /2 )
	local yIndex = posIndex %2 
	if yIndex == 0 then
		yIndex = 2
	end
	local way = camp == 1 and 1 or -1
	

	local xjiange = Fight.position_xdistance
	--离中线的距离
	local middleDistance = Fight.position_middleDistance
	local offsetPos = Fight.position_offset

	local xpos
	local ypos
	if yIndex == 1 then
		xpos = middlePos - (middleDistance + xjiange*(xIndex -1) ) * way
		ypos = Fight.initYpos_1
	else
		xpos = middlePos - ( middleDistance +offsetPos + xjiange*(xIndex -1) ) * way
		ypos = Fight.initYpos_2
	end

	--还得左下体形修正
	xpos = xpos + (math.ceil( figure/2 ) -1) * xjiange/2
	--如果体型大于1
	if figure > 1 then
		if yIndex ~= 1 then
			echoWarn("有大体型怪的时候 yIndex 必须是1,检查关卡配置")
		end
		ypos = Fight.initYpos_3
	end

	return xpos,ypos
end


--布局一方 enterType 入场方式
function RefreshEnemyControler:distributionOneCamp( datas,camp,wave ,enterType)
	for i,v in ipairs(datas) do
		local objHero = ObjectHero.new(v.hid,v)
		self:createHeroes(objHero,camp,v.posIndex,enterType)
	end
end

return RefreshEnemyControler