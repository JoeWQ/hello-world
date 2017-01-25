
--[[
autor:gaoshuang
时间：2016.12.12
站前选人
]]



FuncTeamFormation= FuncTeamFormation or {}



--阵容对应的阵容id
FuncTeamFormation.formation = 
{
	pve = 1,			--寻仙问清
	pvp_attack = 2,		--竞技场攻击阵容
	pvp_defend = 7,		--竞技场防守阵型
	trailPve1 = 3,		--试炼1
	trailPve2 = 4,		--试炼2
	trailPve3 = 5,		--试炼3
	towerPve  = 6,		--爬塔
}










--source对应的配置表
local formationCfg
local sourceCfg
local partnerCfg



function FuncTeamFormation.init()
		
end


function FuncTeamFormation.chkRequire(  )
	if formationCfg == nil then
		formationCfg = require("format.Format")
	end	
	if sourceCfg == nil then
		sourceCfg = require("treasure.Source")
	end
	if partnerCfg == nil then
		partnerCfg = require("partner.Partner")
	end
end


--[[
根据玩家id获取spineName
]]
function FuncTeamFormation.getSpineNameByHeroId( heroId )
	--echo("heroId",heroId,"========")
	FuncTeamFormation.chkRequire()
	local sourceId
	if tostring(heroId) == "1" then
		sourceId = "1"
	else
		sourceId = partnerCfg[tostring(heroId)].sourceld
	end
	return FuncTeamFormation.getSpineName( sourceId )
end



--[[
获取SpineName
]]
function FuncTeamFormation.getSpineName( sourceId )
	--echo("sourceId",sourceId,"====================")
	FuncTeamFormation.chkRequire(  )
	local spine =  sourceCfg[tostring(sourceId)]["spine"]
	if spine == nil then
	 	spine= sourceCfg[tostring(sourceId)]["spineFormale"]
	 end 
	 return spine
end


--[[
检查某个站位是否开启
]]
function FuncTeamFormation.checkPosIsOpen( pIdx )
	local val = FuncDataSetting.getDataVector("FormatPositionOpen")
	if val["p"..pIdx] <= UserModel:level() then
		return true,val["p"..pIdx]
	end
	return false,val["p"..pIdx]
end





--[[
检测是否显示怒气条和生命条
]]
function FuncTeamFormation.isShowNuQi( systemId )
	FuncTeamFormation.chkRequire(  )
	local row = formationCfg[tostring(systemId)]
	return row.display == 1
end




--[[
获取属性对应的攻击  防御  描述
]]
function FuncTeamFormation.getPropTxt( ty )
	if ty == 1 then
		return "攻击"
	elseif  ty == 2 then
		return "防御"
	elseif ty == 3  then
		return "辅助"
	end
	return "租的"
end


--[[
获取台子的属性
]]
function FuncTeamFormation.getPropByTaiZi( index )
	--return math.floor((index-1)/2)+1
	if index>=1 and index<=2 then
		return 2
	elseif index>=3 and index<=4 then
		return 1
	elseif index>=5 and index<=6 then
		return 3
	end
	return 1
end
