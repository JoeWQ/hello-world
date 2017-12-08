--
-- Author: gaoshuang
-- Date: 2016-12-12
-- 站前 站人





--[[
站前站人数据
]]
local TeamFormationModel = class("TeamFormationModel",BaseModel)



TeamFormationModel.system = {

	pve = 1,			--寻仙问清
	pvp_attack = 2,		--竞技场攻击阵容
	pvp_defend = 7,		--竞技场防守阵型
	trailPve1 = 3,		--试炼1
	trailPve2 = 4,		--试炼2
	trailPve3 = 5,		--试炼3
	towerPve  = 6,		--爬塔
}


function TeamFormationModel:init( d )

	TeamFormationModel.super.init(self,d)

	-- echo("阵型信息初始化")
	-- dump(d)
	-- echo("阵型信息初始化")
	--teams 以 key :: 系统id value 阵型 p1 p2 ...的形式显示
	-- key 配置表 formation 配置表中对应
	if self.formations == nil then
		self.formations = {}
	end
	for k,v in pairs(d) do
		self.formations[k] = v
	end
	-- echo("没有合并数据前----------")
	-- dump(self.formations)
	-- echo("没有合并数据前----------")

	self:mergeLocalData()
	self:chkFmtValid()

	-- echo("合并后的数据=-================")
	-- dump(self.formations)
	-- echo("合并后的数据=-================")
end



--[[
合并本地数据
]]
function TeamFormationModel:mergeLocalData()
	local jsonStr = LS:prv():get(StorageCode.all_team_formation,"")
	local fmtData = {}
	local sys = TeamFormationModel.system 				--FuncTeamFormation.formation
	if jsonStr == "" then
		for k,v in pairs(sys) do
			--pve 阵容的数据 不保存  因为要提示
			if k~= "pve" and k ~= "pvp_defend" then
				local fmt = self:initDefaultFmt(v)
				-- local netFmt = self.formation[tostring(v)]
				-- if not netFmt then
				-- 	self.formation[tostring(v)] = fmt
				-- end
				fmtData[tostring(v)] = fmt
			end
		end
	else
		--本地数据
		fmtData = json.decode(jsonStr)
		-- echo("本地存储的数据----------------")
		-- dump(fmtData)
		-- echo("本地存储的数据----------------")
	end

	--dump(fmtData)


	--数据合并
	for k,v in pairs(fmtData) do
		--判断网络中有没有该数据
		if not self.formations[tostring(k)] then
				self.formations[tostring(k)] = {}
		end
			--同步id
			if self.formations[tostring(k)].id == nil then
				self.formations[tostring(k)].id = v.id
			end
			--同步partner
			if self.formations[tostring(k)].partnerFormation == nil then
				self.formations[tostring(k)].partnerFormation = {}
			end
			for kk,vv in pairs(v.partnerFormation ) do
				if self.formations[tostring(k)].partnerFormation[kk] == nil or
			 			tostring(self.formations[tostring(k)].partnerFormation[kk]) == "0" then
				 	self.formations[tostring(k)].partnerFormation[kk] = vv
				end
			end
			--同步法宝 阵位
			if self.formations[tostring(k)].treasureFormation == nil then
				self.formations[tostring(k)].treasureFormation = {}
			end 
			for kk,vv in pairs(v.treasureFormation) do
				if self.formations[tostring(k)].treasureFormation[kk] == nil or
					tostring(self.formations[tostring(k)].treasureFormation[kk]) == "0" then
						self.formations[tostring(k)].treasureFormation[kk] = vv	
				end
			end
	end
end

--[[
检查阵容的合法性
@因为阵容中的Partner or Treasure 有可能会被分解
]]
function TeamFormationModel:chkFmtValid(  )
	--dump(self.formations)
	for k,v in pairs(self.formations) do
		for kk,vv in pairs(v.partnerFormation) do
			--检查vv 的partner是否存在	
			if (not PartnerModel:isPartnerExist(vv)) and tostring(vv) ~= "1" then
				self.formations[k].partnerFormation[kk] = "0"
			end
		end

		for kk,vv in pairs(v.treasureFormation) do
			--检查vv 的法宝是否存在
			if TreasuresModel:getTreasureById(vv) == nil then
				self.formations[k].treasureFormation[kk] = "0"
			end
		end
	end
end


--[[
将数据保存到本地
保存本地数据
将数据保存到本地
]]
function TeamFormationModel:saveLocalData(  )
	local sysId = self.tempFormation.id
	self.formations[tostring(sysId)] = self.tempFormation
	local jsonStr = json.encode(self.formations)
	LS:prv():set(StorageCode.all_team_formation,jsonStr)
end


--[[
更新阵型信息
@params dict 阵型信息的更新状态
]]
function TeamFormationModel:updateData(dict)
	-- echo("aaaaaaaaaaaaaaaaa")
	-- dump(dict)
	-- echo("aaaaaaaaaaaaaaaaa")
	if self.formations == nil then
		self.formations = {}
	end
	for k,v in pairs(dict) do
		if self.formations[k] == nil then self.formations[k] = {}  end
		if v.partnerFormation then
			if self.formations[k].partnerFormation == nil then self.formations[k].partnerFormation={} end
			for kk,vv in pairs(v.partnerFormation) do
				self.formations[k].partnerFormation[kk] = vv
			end
		end
		if v.treasureFormation then
			if self.formations[k].treasureFormation == nil then self.formations[k].treasureFormation={} end
			for kk,vv in pairs(v.treasureFormation) do
				self.formations[k].treasureFormation[kk] = vv
			end
			
		end
	end
    --判断是否竞技场的阵容发生了变化
    if dict[GameVars.battleLabels.pvp] ~= nil then
        EventControler:dispatchEvent(PvpEvent.PVP_FORMATION_CHANGED_EVENT,dict[GameVars.battleLabels.pvp])
    end


end

--获取竞技场系统的攻击性阵容
function TeamFormationModel:getPVPFormation()
    local _pvp_formation = self:getFormation(GameVars.battleLabels.pvp)
    _pvp_formation.treasureFormation = _pvp_formation.treasureFormation or {}
    _pvp_formation.partnerFormation = _pvp_formation.partnerFormation or {}

    return _pvp_formation
end
--获取竞技场的防御阵容
function TeamFormationModel:getPVPDefenceFormation()
    local _pvp_defence = self:getFormation(TeamFormationModel.system.pvp_defend) or {}
    _pvp_defence.treasureFormation = _pvp_defence.treasureFormation or {}
    _pvp_defence.partnerFormation = _pvp_defence.partnerFormation or {}

    return _pvp_defence
end
--[[
根据系统id来判断是否需要初始化
]]
function TeamFormationModel:checkInited( systemId )
	if self.formations == nil  then
		return false
	end
	if self.formations[tostring(systemId)] == nil  then
		return false
	end
	return true
end

--[[
执行初始化阵容
]]
function TeamFormationModel:toInitializeFormation( systemId,callBack )

	local params = {}
    params.id = tostring(systemId) 
    params.formation = {}
    
    params.formation.treasureFormation = {}
    params.formation.partnerFormation = {}
    --初始化要上阵的法宝
    params.formation.treasureFormation.p1= TeamFormationModel:getInitUseTrea(  )
    params.formation.treasureFormation.p2 = 0
    --主角上阵
    params.formation.partnerFormation.p1 = 1
    params.formation.partnerFormation.p2 = 0
    params.formation.partnerFormation.p3 = 0
    params.formation.partnerFormation.p4 = 0
    params.formation.partnerFormation.p5 = 0
    params.formation.partnerFormation.p6 = 0

    TeamFormationServer:doFormation( params,callBack )
end



function TeamFormationModel:initDefaultFmt( systemId )
	local fmt = {}
    fmt.id = tostring(systemId) 
    
    fmt.treasureFormation = {}
    fmt.partnerFormation = {}
    --初始化要上阵的法宝
    fmt.treasureFormation.p1= TeamFormationModel:getInitUseTrea(  )
    fmt.treasureFormation.p2 = 0
    --主角上阵
    fmt.partnerFormation.p1 = 1
    fmt.partnerFormation.p2 = 0
    fmt.partnerFormation.p3 = 0
    fmt.partnerFormation.p4 = 0
    fmt.partnerFormation.p5 = 0
    fmt.partnerFormation.p6 = 0

    return fmt
end


--[[
获取用户当前是攻防辅特性
]]
function TeamFormationModel:getPropByPartnerId( pId )
	pId = tostring(pId)
	if pId == "1" then
		return 1
	else
		local allNpcs = self:getNPCsByTy(0)
		for k,v in pairs(allNpcs) do
			if tostring(v.id)  == tostring(pId) then
				return v.type
			end
		end
		return 0
	end
end



--[[
获取当前阵型数据
这个暂时没有使用
]]
function TeamFormationModel:getCurFormation( systemId )
	return self.formations[tostring(systemId)]["partnerFormation"]
end



--[[
根据攻 防  辅  获取对应的npcs
@params ty == 1 攻 ty==2 防 ty==3 辅


返回的数据可能不全   先这么搞  等有新需求的时候再改  todo modify--

]]
function TeamFormationModel:getNPCsByTy( ty )
	--echo("ty",ty,"=============================")

	local partners = PartnerModel:getAllPartner()
	-- echo("获取当前所有的npcs----")
	-- dump(partners)
	-- echo("获取当前所有的npcs----")
	local npcs = {}
	for k,v in pairs(partners) do
		local npcCfg = FuncPartner.getPartnerById(v.id)
		if ty == 0 or npcCfg.type == ty then 
			--如果传入的 ty ==0 或者指定的npc类型
			local temp = {}
			temp.id = v.id
			temp.level = v.level
			temp.exp = v.exp
			temp.position = v.position 
			temp.quality = v.quality 
			temp.skills = v.skills 
			temp.star = v.star
			temp.starPoint = v.starPoint
			temp.type = npcCfg.type 
			temp.icon = npcCfg.icon 
			temp.sourceId = npcCfg.sourceld
			temp.dynamic = npcCfg.dynamic
			temp.order = 0
			table.insert(npcs,temp)
		end
	end
	local player = {}
	player.id = 1
	player.level = UserModel:level()
	--暂定  todo dev
	player.type = 1
	player.exp = UserModel:exp()
	player.star = 1      --默认玩家的星级 1
	player.order = 1
	player.quality = UserModel:quality()

	--player.sourceld
	if ty == 0 or player.type == ty then
		table.insert(npcs, player)
	end
	--dump(npcs)

	--这里应该有一个排序，上阵的，然后是品质，等等  这里进行一次排序，玩家自己放在最前面
	table.sort(npcs,function ( a,b )
		local rst = false
		if a.order>b.order then
			rst = true
		elseif a.order == b.order then
			if a.level>b.level then
				rst = true
			elseif a.level==b.level then
				if a.star>b.star then
					rst = true
				elseif a.star==b.star then
					if toint(a.id)<toint(b.id) then
						rst = true
					elseif toint(a.id)==toint(b.id) then
						rst = false
					else
						rst = false
					end
				else
					rst = false
				end
			else
				rst = false
			end
		else
			rst = false
		end	

		-- elseif a.level>b.level then
		-- 	rst = true
		-- elseif a.star>b.star then
		-- 	rst = true
		-- elseif toint(a.id)<toint(b.id) then
		-- 	rst = true
		-- else
		-- 	rst = false
		-- end
		return rst
	end)

	return npcs
end













--[[
获取玩家的第一个法宝
@ 当玩家首次进入该系统的时候 没有法宝，那么选择一个法宝让其上阵。自动执行的
]]
function TeamFormationModel:getInitUseTrea(  )
	local allTreas = TreasuresModel:getAllTreasure()
	--默认法宝405  这里暂时这么写    等待优化
	local treaId = 0
	if allTreas then
		for k,v in pairs(allTreas) do
			treaId = k 
			break
		end
	end
	return toint( treaId)
end








--[[
获取所有的法宝
]]
function TeamFormationModel:getAllTreas(  )
	local treas = {}
	local allTreas = TreasuresModel:getAllTreasure()
	for k,v in pairs(allTreas) do
		local item = {}
		item.id = k
		item.level = v._data.level
		item.star = v._data.star
		item.state = v._data.state
		table.insert(treas,item)
	end
	return treas
end




function TeamFormationModel:getTreaById( treaId )
	local treas = self:getAllTreas()
	for k,v in pairs(treas) do
		 if tostring(v.id) == tostring(treaId) then
		 	return v
		 end
	end
	return nil
end






--=================================================================================--
-- 						创建临时阵型           用于在关闭的时候向服务器提交阵容
--=================================================================================--
function TeamFormationModel:createTempFormation( systemId )
	-- echo("systemId",systemId,"================")
	-- dump(self.formations)
	self.tempFormation = {}
	self.tempFormation.id = systemId
	self.tempFormation.treasureFormation = {}
	self.tempFormation.partnerFormation = {}
	local srcFormation = self.formations[tostring(systemId)]
	if srcFormation ~= nil then
		for k,v in pairs(srcFormation.treasureFormation) do
			self.tempFormation.treasureFormation[k] = v
		end
		for k,v in pairs(srcFormation.partnerFormation) do
			self.tempFormation.partnerFormation[k] = v	
		end
	end
end




--[[
一键上阵
]]
function TeamFormationModel:allOnFormation(  )
	local allNpcs = self:getNPCsByTy( 0 )
	--获取前5个
	-- local fiveNpc = {}
	-- for k,v in pairs(allNpcs) do
	-- 	if v.
	-- end
	for k = 1,6,1 do
		local heroId = "0"
		if allNpcs[k] ~= nil then
			heroId = allNpcs[k].id
		end
		local isOpen,lv = FuncTeamFormation.checkPosIsOpen( k )
		if not isOpen then heroId = "0" end
		self.tempFormation.partnerFormation["p"..k] = heroId
	end

	local allTreas = self:getAllTreas()
	for k = 1,2 do
		local treaId = "0"
		if allTreas[k] ~= nil then
			treaId = allTreas[k].id
		end
		self.tempFormation.treasureFormation["p"..k] = treaId
	end

end





--[[
临时阵容
]]
function TeamFormationModel:getTempFormation(  )
	return self.tempFormation
end

--[[
获取阵容信息
]]
function TeamFormationModel:getFormation( systemId )
	return self.formations[tostring(systemId)]
end


--[[
获取当前上阵的法宝
]]
function TeamFormationModel:getCurTreaByIdx(pIdx )
	-- if self.formations[tostring(systemId)] and self.formations[tostring(systemId)]["treasureFormation"] then
	-- 	return self.formations[tostring(systemId)]["treasureFormation"]
	-- end

	return self.tempFormation.treasureFormation["p"..pIdx]
end



--[[
根据位置  获取当前位置的 heroId
]]
function TeamFormationModel:getHeroByIdx(pIdx )
	--echo(systemId,pIdex,"========================")
	-- if self.formations == nil then
	-- 	self.formations = {}
	-- end
	--dump(self.formations[tostring(systemId)]["partnerFormation"])
	-- if self.formations[tostring(systemId)] and self.formations[tostring(systemId)]["partnerFormation"] then
	-- 	return self.formations[tostring(systemId)]["partnerFormation"]["p"..pIdx]
	-- end
	-- return 0

	return self.tempFormation.partnerFormation["p"..pIdx]
end




--[[
判断hero是否上阵了
@params :systemId 使用的系统id
@params：hid hero的id 
]]
function TeamFormationModel:chkIsInFormation(hid )
	-- echo("当前的阵容数据")
	-- dump(self.tempFormation.partnerFormation)
	-- echo("当前的阵容数据")
	local fmt = self.tempFormation.partnerFormation
	for k,v in pairs(fmt) do
		if tostring(v) == tostring(hid) then
			return true
		end
	end
	return false
end


--[[
判断法宝是否上阵
]]
function TeamFormationModel:chkTreaInFormation(treaId )
	local trea = self.tempFormation.treasureFormation
	for k,v in pairs(trea) do
		if tostring(v) == tostring(treaId) then
			return true
		end
	end
	return false
end



--[[
更新临时阵容
]]
function TeamFormationModel:updatePartner( pIdx,heroId )
	--dump(self.tempFormation)
	self.tempFormation.partnerFormation["p"..pIdx] = tostring( heroId )

	-- echo("更新NPC后的信息")
	-- dump(self.tempFormation)
	-- echo("更新NPC后的信息")
end

--[[
获取自动上阵应该所在的位置
]]
function TeamFormationModel:getAutoPIdx( ty )
	--local x = math.ceil (ty)
	local pIdx = -1
	if self.tempFormation.partnerFormation["p"..ty*2-1] == "0" and FuncTeamFormation.checkPosIsOpen( ty*2-1 ) then
		return  ty*2-1
	end
	if self.tempFormation.partnerFormation["p"..ty*2] == "0" and FuncTeamFormation.checkPosIsOpen( ty*2 ) then
		 return ty*2
	end
	for k,v in pairs(self.tempFormation.partnerFormation) do
		local idx =  toint( string.sub(k,2) )
		if tostring(v) == "0" and FuncTeamFormation.checkPosIsOpen( idx ) then
			--pIdx = idx
			return idx
		end
	end
	-- if pIdx ~= -1 then
	-- 	--检查位置是否开启
	--echo(FuncTeamFormation.checkPosIsOpen( pIdx ),"=================",pIdx)
	-- 	 if not FuncTeamFormation.checkPosIsOpen( pIdx ) then
	-- 	 	pIdx = -1
	-- 	 end
	-- end
	return pIdx
end



--[[
获取heroid做在的阵容
]]
function TeamFormationModel:getPartnerPIdx( heroId )
	for k,v in pairs(self.tempFormation.partnerFormation) do
 		if tostring(v) == tostring(heroId) then
 			--echo("vvvvvv",v,"heroId",heroId,"=-=-")
 			local pIdx = k
 			--echo("pIdx",pIdx,"string.sub(pIdx,2,1)",string.sub(pIdx,2),toint( string.sub(pIdx,2,1) ))
 			return toint( string.sub(pIdx,2) )
 		end
 	end

end



--[[
获取heroid做在的阵容
]]
function TeamFormationModel:getPartnerRealPIdx( heroId,systemId )
	for k,v in pairs(self.formations[tostring(systemId)].partnerFormation) do
 		if tostring(v) == tostring(heroId) then
 			--echo("vvvvvv",v,"heroId",heroId,"=-=-")
 			local pIdx = k
 			--echo("pIdx",pIdx,"string.sub(pIdx,2,1)",string.sub(pIdx,2),toint( string.sub(pIdx,2,1) ))
 			return toint( string.sub(pIdx,2) )
 		end
 	end

end






--[[
更新法宝信息
]]
function TeamFormationModel:updateTrea( pIdx,treaId )
	self.tempFormation.treasureFormation["p"..pIdx] = tostring(treaId)
end


--[[
获取法宝所在的位置
]]
function TeamFormationModel:getTreaPIdx( treaId )
	for k,v in pairs(self.tempFormation.treasureFormation) do
 		if tostring(v) == tostring(treaId) then
 			local pIdx = k
 			return toint( string.sub(pIdx,2) )
 		end
 	end
end





return TeamFormationModel
