
FuncTreasure = FuncTreasure or {}

local treasureData = nil
local treasureStateData = nil
local treasureUpgradeLevelData = nil
local FeatureData = nil

local FeatureBuffData = nil
local sourceData = nil

local TREASURE_QUALITY_NAMES = {
	[1] = "人品",
	[2] = "地品",
	[3] = "天品",
	[4] = "通天品",
	[5] = "玄天品"
}

function FuncTreasure.getName(id)
	local tid = FuncTreasure.getValueByKeyTD(id, "name");
	return GameConfig.getLanguage(tid);
end

function FuncTreasure.init(  )
	treasureData = require("treasure.Treasure");
	treasureStateData = require("treasure.TreasureState");
	treasureUpgradeLevelData = require("treasure.TreasureUpgradeLevel");
	FeatureData = require("treasure.Feature");
	sourceData = require("treasure.Source");
    combineData = require("treasure.Combine")
 	FeatureBuffData = require("battle.Buff");
    starlightData = require("treasure.Starlight");
end

function FuncTreasure.getSourceDataById(id)
	local data = sourceData[tostring(id)]
	if data ~= nil then
		return data
	else
		echo("FuncTreasure.getSourceDataById id not dound " .. id)
	end
end

function FuncTreasure.getQualityName(quality)
	quality = tonumber(quality)
	name = TREASURE_QUALITY_NAMES[quality] or ""
	return name
end

function FuncTreasure.getValueByKeyTD(id, key)
	local t = treasureData[tostring(id)];
	if id == nil or t == nil then
		echoError("FuncTreasure.getValueByKeyTD id not found " .. id .. "_"..key)
		return nil
	end

	local ret = t[tostring(key)];
	if ret == nil then 
		echo("FuncTreasure.getValueByKeyTD key not found " .. key)
		return nil
	end 

	return ret;
end
function FuncTreasure.getStarlightData()
	return starlightData;
end

function FuncTreasure.getTreasureAllConfig()
	return treasureData;
end

function FuncTreasure.getTreasureById(_id)
    local _treasure = treasureData[tostring(_id)]
    if not _treasure then
        echo("Warning!!! jianjianjian,error,",_id)
    end
    return _treasure
end
function FuncTreasure.getValueByKeyTSD(id, key)
	local t = treasureStateData[tostring(id)]

	if t == nil then 
		echo("FuncTreasure.getValueByKeyTSD id not found " .. id);
		return nil
	end 

	local value = t[tostring(key)]

	if value == nil then 
		echo("FuncTreasure.getValueByKeyTSD key not found " .. key);
		return nil
	end 

	return value;
end

function FuncTreasure.getValueByKeyTULD(id1, id2, key)
	local t1 = treasureUpgradeLevelData[tostring(id1)];
	if t1 == nil then 
		echo("FuncTreasure.getValueByKeyTULD id1 not found " .. id1);
		return nil;
	end 

	local t2 = t1[tostring(id2)];
	if t2 == nil then 
		echo("FuncTreasure.getValueByKeyTULD id2 not found " .. id2);
		return nil;
	end 

	local value = t2[tostring(key)]

	if value == nil then 
		echo("FuncTreasure.getValueByKeyTULD key not found " .. key);
		return nil;
	end 

	return value;
end

function FuncTreasure.getValueByKeyFD(id1, id2, key)
	local t1 = FeatureData[tostring(id1)];
	if t1 == nil then 
		echo("FuncTreasure.getValueByKeyFD id1 not found " .. id1);
		return nil;
	end 

	local t2 = t1[tostring(id2)];
	if t2 == nil then 
		echo("FuncTreasure.getValueByKeyFD id2 not found " .. id2);
		return nil;
	end 

	local value = t2[tostring(key)]

	if value == nil then 
		echo("FuncTreasure.getValueByKeyFD key not found " .. key);
		return nil;
	end 
	
	return value;
end

function FuncTreasure.getValueByKeyBD(id, key)

	local t = FeatureBuffData[tostring(id)];

	if t == nil then 
		echo("FuncTreasure.getValueByKeyBD id not found " .. id);
		return nil
	end 

	local value = t[tostring(key)]

	if value == nil then 
		echo("FuncTreasure.getValueByKeyBD key not found " .. key);
		return nil
	end 

	return value;
end

function FuncTreasure.getIconPathById(id)
	return FuncTreasure.getValueByKeyTD(id, "icon")
end

--得到异能的图标，参数是异能id，lvl默认为1
function FuncTreasure.getSkillSprite(id, lvl)
	lvl = lvl or 1;
	local skillPicName = FuncTreasure.getValueByKeyFD(id, lvl, "imgBg");
	local imageName = FuncRes.iconSkill(skillPicName);
    local sprite = display.newSprite(imageName);
    return sprite;
end

function FuncTreasure.getSkillNameById(id, lvl)
	lvl = lvl or 1;
    local name = FuncTreasure.getValueByKeyFD(id, 
    	lvl, "name")
    return GameConfig.getLanguage(name);
end

function FuncTreasure.getSkillDes(id, lvl)
	lvl = lvl or 1;
	local des = FuncTreasure.getValueByKeyFD(id, 
    	lvl, "des1");
	return GameConfig.getLanguage(des);
end

function FuncTreasure.getSkillIncreaseType(id, lvl)
	lvl = lvl or 1;
	return FuncTreasure.getValueByKeyFD(id, lvl, "type");
end

function FuncTreasure.getSkillValue(id, lvl)
	lvl = lvl or 1;
	return FuncTreasure.getValueByKeyFD(id, lvl, "value");
end

--[[
	获得法宝颜色
	id 法宝id
	state 法宝境界

	返回 1 2 3 4 5
]]
function FuncTreasure.getTreasureColor(id, state)
	local stateId = FuncTreasure.getValueByKeyTD(id, "state")[state];
	local colour = FuncTreasure.getValueByKeyTSD(stateId, "colour");
	return colour;
end


function FuncTreasure.getCombineData()
  return  combineData
end



function FuncTreasure.getCombineData( id , key ) 
    
   local _id =  _yuan3(type(id) == "number",tostring(id),id)
   local _key =  _yuan3(type(key) == "number",tostring(key),key)

   return combineData[_id][_key] or  -1
end 

function FuncTreasure.isCanCombine( id )
   local _state =  treasureData[tostring(id)]["combine"] or 0  
  return  _yuan3(_state == 1,true,false)
end 

--强化等级
function FuncTreasure.getTreasureMaxLvl(id)
	return FuncTreasure.getValueByKeyTD(id, "lvLimit")
end

--精炼最大等级
function FuncTreasure.getTreasureRefineMaxLvl(id)
    local ver = FuncTreasure.getValueByKeyTD(id, "state")
    return #ver or 0
end

--当前法宝资源的路径
function FuncTreasure.getTreasureIconPath(id)
    local _resName = FuncTreasure.getValueByKeyTD(id, "icon") or ""
     
    return  "/icon/treasure/".._resName..".png"
end

function FuncTreasure.getTreasureDes(id)
    local translateId = FuncTreasure.getValueByKeyTD(
        id, "treasureDes");
    local str = GameConfig.getLanguage(translateId)
    return str;
end

--得到label转换后的字符串
function FuncTreasure.getLabel3(id)
	local translateId = FuncTreasure.getValueByKeyTD(
        id, "label3");
	local str = GameConfig.getLanguage(translateId);
	return str;
end

function FuncTreasure.getUseDes(id)
	local translateId = FuncTreasure.getValueByKeyTD(
        id, "uesDes");
	local str = GameConfig.getLanguage(translateId);
	return str;
end

function FuncTreasure.getLabel4(id)
	local translateId = FuncTreasure.getValueByKeyTD(
        id, "label4");
	local str = GameConfig.getLanguage(translateId);
	return str;
end












