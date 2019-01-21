--//伙伴系统,所有的配置表
--//2016-12-5 11:22:00 
--//@Author:狄建彬

FuncPartner = FuncPartner or {}

FuncPartner.PartnerIndex = {
    PARTNER_QUALILITY = 1, -- 伙伴升品
    PARTNER_UPGRADE = 2,-- 伙伴升级
    PARTNER_UPSTAR = 3,-- 伙伴升星
    PARTNER_SKILL = 4,-- 伙伴技能
    PARTNER_JUEJI = 5,-- 伙伴绝技
    PARTNER_COMBINE = 6,-- 伙伴合成
}
--伙伴系统UI类型
FuncPartner.PartnerUIType={
     Main = 1,--主页面
     Strength = 2,--强化
     Levelup = 3,--升级
     Skill = 4, -- 技能
     Soul = 5,--仙魂
     Star = 6,--星品
}
--品质与颜色之间的映射
FuncPartner.QualityToColor={
    [1]="白色",
    [2]="绿色",
    [3]="绿色+1",
    [4]="蓝色",
    [5]="蓝色+1",
    [6]="蓝色+2",
    [7]="蓝色+3",
    [8]="紫色",
    [9]="紫色+1",
    [10]="紫色+2",
    [11]="紫色+3",
    [12]="橙色",
    [13]="橙色+1",
    [14]="橙色+2",
    [15]="橙色+3",
    [16]="红色",
    [17]="红色+1",
    [18]="红色+2",
    [19]="红色+3",
}
--伙伴属性 键
FuncPartner.ATTR_KEY = {
    ATTR_KEY_LIFE = 1,--生命
    ATTR_KEY_ATTACK = 10,--攻击
    ATTR_KEY_DEFENCE_PHY = 11,--物理防御
    ATTR_KEY_DEFENCE_MAGIC =12,--法术防御
    ATTR_KEY_CRIT = 13,--暴击
    ATTR_KEY_RESIST =14,--抗暴击
    ATTR_KEY_CRIT_S =15,--暴击强度
    ATTR_KEY_BLOCK = 16,--格挡率
    ATTR_KEY_WRECK =17,--破击率
    ATTR_KEY_WRECK_S = 18,--格挡强度
    ATTR_KEY_INJURY = 19,--伤害率
    ATTR_KEY_AVOID = 20,--免伤率
    ATTR_KEY_LIMIT = 21,--控制率
    ATTR_KEY_GUARD =22,--免控率
    ATTR_KEY_SUCK_S= 23,--吸血率
    ATTR_KEY_THORNS = 24,--反伤率
}

--仙魂升级所需要的道具以及相关的子类型
FuncPartner.SoulItemId = {"9501","9502","9503","9504"}
--万能碎片id
FuncPartner.FullFuncItemId = "4049"
FuncPartner.SoulItemSubType = 309
--表config/partner/equipment.csv
local _equipment_table
--config/partner/equipmentPlus
local _equipment_plus_table
--config/partner/partner
local _partner_table
--config/partner/partnerCombine
local _partner_combine_table
--config/partner/partnerExp
local _partner_exp_table
--config/partner/partnerSkill
local _partner_skill_table
--config/partner/partnerSoul
local _partner_soul_table
--config/partner/partnerStar
local _partner_star_table
--config/partner/partnerStarQuality
local _partner_star_quality
--config/partner/PartnerSkillUpCost
local _partner_skill_cost 
function FuncPartner.init()
   _equipment_table = require("partner.PartnerEquipment")
   _equipment_plus_table = require("partner.PartnerEquipmentSet")
   _partner_table = require("partner.Partner")
   _partner_combine_table = require("partner.PartnerCombine")
   _partner_exp_table = require("partner.PartnerExp")
   _partner_skill_table = require("partner.PartnerSkill")
   _partner_soul_table = require("partner.PartnerSoul")
   _partner_star_table = require("partner.PartnerStar")
   _partner_star_quality = require("partner.PartnerQuality")
   _partner_skill_cost = require("partner.PartnerSkillUpCost")
end

--获取伙伴装备
function FuncPartner.getEquipmentById( id)
  local   _data = _equipment_table[tostring(id)]
  if( not _data )then
    echo("Warning!!,id",_id," get null equipment")
  end
  return _data
end

--用给定的装Id获取装备升级时的资源消耗情况信息
function FuncPartner.getEquipmentLevelupInfo(_id)
  local _data = _equipment_plus_table[tostring(_id)]
  if( not _data)then
    echo("Warning!!, id",_id,"could not be found in table partner.equipmentPlus")
  end
  return _data;
end

--获取所有的伙伴信息
function FuncPartner.getAllPartner()
 return _partner_table
end

--给定伙伴的Id,返回伙伴的相关信息
function FuncPartner.getPartnerById(_id)
    local _info = _partner_table[tostring(_id)];
    if( not _info )then
        echo("Warning!!, could not find infomation by id",_id," in table partner.partner")
    end
    return _info;
end

--给定装备的Id,返回合成该装备需要的各种资源
function FuncPartner.getConbineResById(_equipment_id)
    local   _res_info=_partner_combine_table[tostring(_equipment_id)]
    if not _res_info then 
        echo("Warning,Equipment id ",_equipment_id," is illeagal")
    end
    return _res_info
end

--伙伴升级需要的条件
function FuncPartner.getConditionByLevel(_level)
        local       _condition = _partner_exp_table[tostring(_level)]
        if(not _condition)then
                echo("Warning, level ",_level," is illegal")
        end
        return _condition
end

--[[
根据partnerId lv 获取升级需要的经验
]]
function FuncPartner.getMaxExp( partnerId,lv )
    local condition = FuncPartner.getConditionByLevel(lv)
    local aptitude = _partner_table[tostring(partnerId)].aptitude
    return condition[tostring(aptitude)].exp
end



--获取所有的伙伴技能
function FuncPartner.getAllPartnerSkills()
    return _partner_skill_table
end

--返回有关某一技能的详情
function FuncPartner.getSkillInfo(_skill_id)
    local _skill_info = _partner_skill_table[tostring(_skill_id)]
    if(not _skill_info)then
        echo("Warning!!!,get skill infomation failed,skill id is ",_skill_id)
    end
    return _skill_info
end
--返回某一个技能的资源消耗情况
function FuncPartner.getSkillCostInfo(_skill_quality)--输入技能的资质id
    local _skill_cost = _partner_skill_cost[tostring(_skill_quality)]
    if not _skill_cost then
        echo("Warning!!!,get Skill Cost infomation failed,input skill quality is :",_skill_quality)
    end
    return _skill_cost
end
--获取所有的仙魂
function FuncPartner.getAllPartnerSouls()
    return _partner_soul_table
end

--返回有关某一技能的详情
function FuncPartner.getSoulInfo(_soul_id)
    local _soul_info = _partner_soul_table[tostring(_soul_id)]
    if(not _soul_info)then
        echo("Warning!!!,get skoul infomation failed,skill id is ",_soul_info)
    end
    return _soul_info
end

--_partner_id:伙伴的Id,注意,返回的是一个结构体的数组
function FuncPartner.getStarsByPartnerId(_partner_id)
   local _partner_stars=_partner_star_table[tostring(_partner_id)];
   if( not _partner_stars)then
        echo("Warning!!, Partner id ",_partner_id," is illegal")
   end
   return _partner_stars
end

--partner_id:伙伴的Id
--返回伙伴的品质信息
function FuncPartner.getPartnerQuality(_partnerId)
    local _qualityInfo = _partner_star_quality[tostring(_partnerId)]
    if(not _qualityInfo)then
        echo("Warning!!,Partner Quality is null,partner id is ",partner_id)
    end
    return _qualityInfo
end

--计算伙伴的战力
function FuncPartner.getPartnerAvatar( _partnerInfo)
    local _ability = 0
    --基础数据
    local _base_data = FuncPartner.getPartnerById(_partnerInfo.id)
    _ability = _ability + _base_data.initAbility
    --品质带来的基础数据累加
    local _quality = _partnerInfo.quality
    local _quality_table = FuncPartner.getPartnerQuality(_partnerInfo.id)
    for _index=1,_quality do
        local _quality_item = _quality_table[tostring(_index)]
        _ability = _ability + _quality_item.addAbility 
        local _position = _index < _quality and 0xF or _partnerInfo.position
        --品质的装备位带来的属性加成
        if _position ~=nil and _position >0 then
            for _index=1,4 do
                --获取第_index的二进制位
                local bit = number.bitat(_position,_index-1)
                if bit > 0 then
                    local _combine_item = FuncPartner.getConbineResById(_quality_item.pellet[_index])
                    _ability = _ability + _combine_item.ability
                end
            end 
        end
    end
    --星级加成
    local _star = _partnerInfo.star
    local _star_table = FuncPartner.getStarsByPartnerId(_partnerInfo.id)
    local _star_item = _star_table[tostring(_star)]
    _ability = _ability + _star_item.lvAbility * _partnerInfo.level
    --星级节点的加成
    for _index=1,_partnerInfo.starPoint do
        _ability = _ability + _star_item.addAbility[_index] 
    end
    --技能加成
    local _partner_skill_levels =0
    for _key1,_skillValue in pairs(_partnerInfo.skills)do
        local _skill_item = FuncPartner.getSkillInfo(_key1)
        _ability = _ability + _skill_item.lvAbility * _skillValue --乘以技能的等级
    end
    --仙魂加成
    for _key1,_value1 in pairs(_partnerInfo.souls) do
        local _soul_table = FuncPartner.getSoulInfo(_key1)
        local _soul_item = _soul_table[tostring(_value1.level)]
        _ability = _ability + _soul_item.ability
    end
    --计算总战力加成
    return _ability
end
--获取给定伙伴的所有属性加成
function FuncPartner.getPartnerAttr(_partnerInfo)
    local dataMap = {}
    --基本属性
    local _base_data = FuncPartner.getPartnerById(_partnerInfo.id)
    for _key,_value in pairs(_base_data.initAttr) do
        local _data = {
            key = _value.key,
            value = _value.value,
            mode = _value.mode,
        }
        table.insert(dataMap,{_data})
    end
    --品质带来的基础属性累加
    local _quality = _partnerInfo.quality
    local _quality_table = FuncPartner.getPartnerQuality(_partnerInfo.id)
    for _index=1,_quality do
        local _quality_item = _quality_table[tostring(_index)]
        if _quality_item.addAttr then
            for _key,_value in pairs(_quality_item.addAttr)do
                local _data = {
                    key = _value.key,
                    value = _value.value,
                    mode = _value.mode,
                }
                table.insert(dataMap,{_data})
            end
        end
        
        --槽位
        local _position = _index < _quality and 0xF or _partnerInfo.position 
        --品质的装备位带来的属性加成
        if _position > 0 then
            for _index2 = 1, 4 do
                -- 获取第_index的二进制位
                local bit = number.bitat(_position, _index2 - 1)
                if bit > 0 then
                    local _combine_item = FuncPartner.getConbineResById(_quality_item.pellet[_index2])
                    for _key, _value in pairs(_combine_item.attr) do
                        local _data = {
                            key = _value.key,
                            value = _value.value,
                            mode = _value.mode,
                        }
                        table.insert(dataMap, { _data })
                    end
                end
            end
        end
    end
    --星级加成
    local _star = _partnerInfo.star
    local _star_table = FuncPartner.getStarsByPartnerId(_partnerInfo.id)
    local _star_item = _star_table[tostring(_star)]
    for _key,_value in pairs(_star_item.subAttr)do
        local _data = {
            key = _value.key,
            value = _value.value * _partnerInfo.level,
            mode = _value.mode,
        }
        table.insert(dataMap,{_data})
    end
    --星级节点的加成
    for _index=1,_partnerInfo.starPoint do
        local _attr_star_point = _star_item.addAttr[_index]
        local _data = {
            key = _attr_star_point.key,
            value = _attr_star_point.value,
            mode = _attr_star_point.mode,
        }
        table.insert(dataMap,{_data})
    end
    --技能加成
    for _key1,_skillValue in pairs(_partnerInfo.skills)do
        local _skill_item = FuncPartner.getSkillInfo(_key1)
        if _skill_item.kind ==2 then --只有类型为2的表格数据才会被累加
            for _key2,_value2 in pairs(_skill_item.lvAttr)do
                local _value3 = _skill_item.initAttr[_key2]
                local _data = {
                    key =_value2.key,
                    value =_value3.value + _value2.value * _skillValue,
                    mode = _value2.mode,
                }
                table.insert(dataMap,{_data})
            end
        end
    end
    --仙魂加成
    for _key1,_value1 in pairs(_partnerInfo.souls) do
        local _soul_table = FuncPartner.getSoulInfo(_key1)
        local _soul_item = _soul_table[tostring(_value1.level)]
        for _key2,_value2 in pairs(_soul_item.attr)do
            local _data = {
                key = _value2.key,
                value = _value2.value,
                mode = _value2.mode,
            }
            table.insert(dataMap,{_data})
        end
    end
    --伙伴装备加成
    if _partnerInfo.equips then
        for _key1,_value1 in pairs(_partnerInfo.equips) do
            local equCfgData = FuncPartner.getEquipmentById(_value1.id)
            equCfgData = equCfgData[tostring(_value1.level)]
            local da = equCfgData.subAttr or equCfgData.subAttrPlus; -- 表中标注是 替换关系
            for _key2,_value2 in pairs(da)do 
                local _data = {
                    key = _value2.key,
                    value = _value2.value,
                    mode = _value2.mode,
                }
                table.insert(dataMap,{_data})
            end
        end
    end
    
    return FuncBattleBase.countFinalAttr(unpack( dataMap) )
end
--获取sourceid
function FuncPartner.getSourceId( _partnerId )
  local partnerData  = FuncPartner.getPartnerById(_partnerId)
  if not partnerData.sourceld  then
    echoWarn("这个英雄没有配sourceId:",_partnerId)
  end
  return partnerData.sourceld 
end

--获取英雄的spine , iswhole是否是整个spine 默认是精简版的spine
function FuncPartner.getHeroSpine(_partnerId,iswhole )
    local sourceId =  FuncPartner.getSourceId( _partnerId )
    local sourceCfg = FuncTreasure.getSourceDataById(sourceId)
    local spineName = sourceCfg.spine 
    local spbName = spineName
    if not iswhole then
        spbName = spbName .. "Extract";
    end
    local charView = ViewSpine.new(spbName, {}, nil, spineName);
    charView.actionArr = sourceCfg
    charView:playLabel(charView.actionArr.stand, true);
    return charView
end
