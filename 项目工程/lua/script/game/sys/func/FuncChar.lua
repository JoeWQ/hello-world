FuncChar= FuncChar or {}


local heroData = nil
local attributeData = nil
local charLevelData = nil
local charLevelUpData = nil
local charQualityData = nil

FuncChar.SEX_TYPE = {
	NAN = "a",
	NV = "b"
}

-- 每个灵穴节点数量
FuncChar.pulseNodeNumPerLv = 4
FuncChar.fightAttrCritR = "critR"

function FuncChar.init(  ) 
    heroData = require("char.CharInitAttr")
    attributeData = require("battle.AttributeConvert")
    charLevelData = require("char.CharLevel")
    charLevelUpData = require("char.CharLevelUp")
    charQualityData = require("char.CharQuality")
end

function FuncChar.getCharQualityData()
    return charQualityData
end

function FuncChar.getCharQualityDataById(id)
    local qualityData = nil
    if id == nil or id == "" then
        return id
    end

    qualityData = charQualityData[tostring(id)]
    return qualityData
end

-- 废弃，暂不使用 Zhangyanguang 2017.01.17
--[[
获取主角战斗力
主角战力=【初始+等级*《星级索引出的等级成长》】+法宝战力+主角品质战力+主角技能战力+天赋战力  
charId:主角hid
quality:主角品阶

function FuncChar.getCharAbility(charId,level,quality)
    local charAbility = 0
    -- 初始战力
    local initAbility = tonumber(FuncChar.getCharInitAbility(charId))
    -- 品阶战力
    local qualityAbility = tonumber(FuncChar.getCharQualityAbility(quality))
    -- todo
    local starRatio = 0
    -- 星级战力
    local starAbility = level * starRatio
    -- 天赋战力
    local talentAbility = 0
    -- 技能战力
    local skillAbility = 0
    -- 法宝战力
    local treasureAbility = 0

    charAbility = initAbility + starAbility + treasureAbility + qualityAbility + skillAbility + talentAbility
    return charAbility
end

--]]

-- 根据等级获取主角初始战力
function FuncChar.getCharInitAbility(charId)
    local heroData = FuncChar.getHeroData(charId)
    local initAbility = heroData.initAbility
    return initAbility
end

-- 根据主角品级增加的战斗力
function FuncChar.getCharQualityAbility(quality)
    local qualityData = FuncChar.getCharQualityDataById(tostring(quality))
    return qualityData.abilityTotal
end

--[[
获取角色战斗属性
charId:角色ID
charQuality:角色的品级
]]
function FuncChar.getCharFightAttribute(charId,charQuality)
    -- 角色初始战斗属性加成
    local charInitAttrData = heroData[tostring(charId)].initAttr

    -- 品阶战斗属性加成
    local qualityAttrData = FuncChar.getCharQualityAttribute(charQuality)

    -- 主角战斗属性
    local charFinalAttr = FuncBattleBase.countFinalAttr(charInitAttrData,qualityAttrData)

    return charFinalAttr
end

--[[
获取角色品阶战斗属性加成
charQuality:角色的品级
]]
-- 获取角色品阶战斗属性加成
function FuncChar.getCharQualityAttribute(charQuality)
    -- 品阶属性加成
    local qualityAttrData = {}
    
    if charQuality ~= nil then
        local qualityData = charQualityData[tostring(charQuality)]
        if qualityData then
            qualityAttrData = qualityData.attr
        end
    end
    
    return qualityAttrData
end

-- 格式化战斗属性，加入属性名称及排序及删除不显示的属性
function FuncChar.formatFightAttribute(attrInfo)
    local attrDatas = {}
    for k,v in pairs(attrInfo) do
        local attrName = FuncChar.getAttrNameByKeyName(k)
        local attrId = FuncChar.getAttrIdByKey(k)
        local attrOrderId = FuncChar.getAttributeOrderById(attrId)

        local info = {}
        info.name = attrName
        info.attrId = attrId
        info.value = FuncChar.getFormatFightAttrValue(info.attrId,v)
        info.attrOrderId = attrOrderId

        -- 小于0的属性不显示
        if info.attrOrderId > 0 then
            attrDatas[#attrDatas+1] = info 
        end
    end

    table.sort(attrDatas , function(a,b) 
        if a.attrOrderId < b.attrOrderId then
            return true
        end
    end)

    return attrDatas
end

-- 获取格式化的战斗属性值
function FuncChar.getFormatFightAttrValue(attrId,attrValue)
    local newAttrValue = attrValue
    local attrData = FuncChar.getAttributeById(attrId)
    local attrKey = attrData.keyName

    if tostring(attrKey) == FuncChar.fightAttrCritR then
        newAttrValue = newAttrValue .. "%"
    end

    return newAttrValue
end

-- 获取战斗属性名称
function FuncChar.getAttrNameById(id)
    local attrData = FuncChar.getAttributeById(id)
    local attrName = GameConfig.getLanguage(attrData.name)
    return attrName
end

-- 获取战斗属性名称
function FuncChar.getAttrNameByKeyName(attrKey)
    local attrName = nil
    local attributeData = FuncChar.getAttributeData()

    for k, v in pairs(attributeData) do
        if tostring(v.keyName) == tostring(attrKey) then
            attrName = GameConfig.getLanguage(v.name)
            break
        end
    end

    return attrName 
end

-- 根据属性Key获取属性id值
function FuncChar.getAttrIdByKey(attrKey)
    local attrId = nil
    local attributeData = FuncChar.getAttributeData()

    for k, v in pairs(attributeData) do
        if tostring(v.keyName) == tostring(attrKey) then
            attrId = k
            break
        end
    end

    return attrId 
end

-- 获取下一个等级
function FuncChar.getCharNextLv(lv)
    local nextLv = tonumber(lv) + 1
    if nextLv >= tonumber(FuncChar.getCharMaxLv()) then
        nextLv = tonumber(FuncChar.getCharMaxLv())
    end

    return nextLv
end

-- 主角最大等级
function FuncChar.getCharMaxLv()
    if FuncChar.charMaxLv then
        return FuncChar.charMaxLv
    else
        FuncChar.charMaxLv = 1

        for k,_ in pairs(charLevelData) do
            if tonumber(k) > FuncChar.charMaxLv then
                FuncChar.charMaxLv = tonumber(k)
            end
        end

        return FuncChar.charMaxLv
    end
end

-- 根据lv获取升级数据
function FuncChar.getCharLevelDataByLv( lv )
    local data = charLevelData[tostring(lv)]
    if data ~= nil then
        return data
    else
        echoError("FuncChar.getCharLevelDataByLv lv=" .. lv .. " not found")
    end
end

function FuncChar.getCharMaxExpAtLevel(lv)
	local data = FuncChar.getCharLevelDataByLv(lv)
	if not data then return 0 end
	return data.charExp
end

-- 根据lv及key获取升级数据
function FuncChar.getCharLevelValueByLv(lv,key)
    local data = FuncChar.getCharLevelDataByLv(lv)
    if data ~= nil then
        return data[key]
    end
end

function FuncChar.getCharLevelConfig()
    return charLevelUpData;
end

function FuncChar.getCharLevelNextSysLevel(lv)
    local data = charLevelUpData[tostring(lv)]
    -- dump(data, "--data--");
    if data ~= nil then
        return data["nextSys"];
    else
        return nil;
    end
end

function FuncChar.getCharLevelUpValueByLv(lv, key)
    local data = charLevelUpData[tostring(lv)]
    if data ~= nil then
        return data[key]
    else
        echoError("FuncChar.getCharLevelUpValueByLv lv=" .. lv .. " not found")
    end
end

function FuncChar.getCharLevelUpValueByLvWithOutError(lv, key)
    local data = charLevelUpData[tostring(lv)]
    echo("data " .. tostring(data));
    if data ~= nil then
        return data[key]
    else
        return nil;
    end
end

function FuncChar.getSysNameByGid(gid)
    for _, v in pairs(charLevelUpData) do
        if tonumber(v.guideId) == tonumber(gid) then 
            return v.sysNameKey;
        end 
    end
    return nil;
end

-- 获取英雄静态数据
function FuncChar.getHeroData( hid )
    local data = heroData[tostring(hid)]
    if data ~= nil then
        return data
    else
        echo("FuncChar.getHeroData hid " .. hid .. " not found")
        return nil
    end
end

--获取英雄的icon图片名
function FuncChar.getHeroAvatar(hid)
	local data = heroData[hid]
	return data.icon
end

function FuncChar.getHeroSex(hid)
	local data = heroData[hid]
    if not data then
        echoWarn("这个hid的数据不存在",hid)
    end
	return data and data.sex or 1
end

function FuncChar.getAllHerosData()
	return table.deepCopy(heroData)
end

--获取英雄的 动画名字
function FuncChar.armature( hid )
    local data = FuncChar.getHeroData(hid)
    return  data.armature
end


--获取英雄icon
function FuncChar.icon( hid )
    local icon = heroData[hid].icon
	return FuncRes.iconHero(icon)
end


--获取对应星级需要的魂石
function FuncChar.getNeedSoul( star )
    return GameVars.starNeedSoul[star]
end

function FuncChar.getAttributeById(id)
    local info = attributeData[tostring(id)]
    return info
end

-- 根据属性Id获取order
function FuncChar.getAttributeOrderById(id)
    local info = attributeData[tostring(id)]
    return info.order
end

-- 根据属性key获取order
function FuncChar.getAttributeOrderByKey(attrKey)
    for k,v in pairs(attributeData) do
        if v.keyName == attrKey then
            return v.order
        end
    end
end

function FuncChar.getAttributeData()
    return attributeData
end

-- 判断AttributeConvert中是否有该key值 
function FuncChar.hasAttributeKey(keyName)
    for k,v in pairs(attributeData) do
        if v.keyName == tostring(keyName) then
            return true
        end
    end

    return false
end

function FuncChar.getCharProp(lv,isDecode )
    local data = confg[lv]
    return data
end

--根据avatar 和 等级获取主角的资源名字
function FuncChar.getSpineAniName( avatar, level)
    level= level or 1
    local armature = FuncChar.armature(avatar)
    local spbName = armature.."_bai"
    if level <= 29 then
        -- armature = armature.."_bai"
    -- elseif level <= 59 then
    --     armature = armature.."_lan"
    -- elseif level <= 99 then
    --     armature = armature.."_zi"
    else
        -- armature = armature.."_cheng"
    end
    return  armature,armature
end

--根据avatar 获取spine动画
--[[
    播放动画示例
    local spine = FuncChar.getSpineAni( 1,20)
    spine:playLabel(spine.actionArr.stand)
]]
function FuncChar.getSpineAni( avatar, level)
    avatar = tostring(avatar)
    return FuncChar.getCharOnTreasure( avatar,level, tostring(tonumber(avatar)-100) , true)
end

--[[
    任意玩家穿法宝的形象
]]
function FuncChar.getCharSkinSpine(avatar, level, tid, isWhole)
    if tid == nil or tid == "" then 
        return FuncChar.getSpineAni(avatar, level);
    else 
        return FuncChar.getCharOnTreasure(avatar, level, tid, isWhole);
    end 
end

function FuncChar.getTreaSource( treaHid )
    -- body
    local stateCfg = FuncTreasure.getValueByKeyTD(treaHid,"state")
    local stateHid = stateCfg[1]

    local sourceHid = FuncTreasure.getValueByKeyTSD(stateHid,"source")
    local sourceCfg = FuncTreasure.getSourceDataById(sourceHid)

    return stateHid,sourceCfg
end


-- 获取穿着某个法宝的主角的角色
-- 参数说明：avatar 角色默认的信息， level 等级， treaHid 穿戴的法宝id 
-- 返回一个ViewSpine对象,这个spine对象有一个属性叫 actionArr,对应source表的动作名称
-- isWhole 是否是加载全部动作 isWhole默认是false(只加载run*和stand*动作)
--[[
    local spine = FuncChar.getCharOnTreasure( 1,20, 101 )
    spine:playLabel(spine.actionArr.stand)
]]
function FuncChar.getCharOnTreasure( avatar,level, treaHid, isWhole)
    if isWhole == nil then 
        isWhole = false;
    end 

    local charView = nil

    local stateHid,sourceCfg = FuncChar.getTreaSource(treaHid)
    local sex = FuncChar.getHeroSex(avatar)
    local spineName = nil
    local spbName = nil

    if not sourceCfg then
        treaHid = "1"
        avatar = 1
        stateHid,sourceCfg = FuncChar.getTreaSource("1")
        sex = FuncChar.getHeroSex(avatar)
    end

    if sex == "a" then
        if sourceCfg.spine and sourceCfg.spine ~= "0" then
            spineName = sourceCfg.spine
        end
    else
        if sourceCfg.spine and sourceCfg.spine ~= "0" then
            spineName = sourceCfg.spineFormale
        end
    end

    if spineName then
        spbName = spineName  
    else
        spbName, spineName = FuncChar.getSpineAniName( avatar, level)
    end

    if treaHid == nil or isWhole == true then 
        charView = ViewSpine.new(spbName,{}, nil, spineName)
    else 
        --spbName 后加 Extract 
        spbName = spbName .. "Extract";
        -- echo("-----charView------", spbName);
        charView = ViewSpine.new(spbName, {}, nil, spineName);
    end 

   --charView.viewData =  FrameDatas.getViewData(true, spineName ) 
    local label1 = FuncTreasure.getValueByKeyTD(treaHid,"label1")
    -- 技能部分
    local skillHid = FuncTreasure.getValueByKeyTSD(stateHid,"skill")
    -- local skillData = FuncBattleBase.getSkillCfg(skillHid)
    -- charView.skillEff = skillData.aniArr
    

    -- 悬挂法宝
    if  isWhole and sourceCfg.fla then
        -- for i,v in ipairs(sourceCfg.fla) do
        --     FuncArmature.loadOneArmatureTexture(v ,nil ,true)
        -- end
        
    end


    -- 看看用哪一套动
    --local actionArr = {}
    
    charView.label1 = label1
    if label1 == 3 or sourceCfg.useSuyan == 1 then
        local initTrea = tostring(heroData[avatar].initTrea)
        local initStateHid,initSrcCfg = FuncChar.getTreaSource(initTrea)

        charView.actionArr = initSrcCfg
    else
                
    end
    charView.actionArr = sourceCfg
    charView:playLabel(charView.actionArr.stand, true);

    charView.playAction = false

    -- 为随机动作设定的动作索引
    return charView
end

-- 删除对应的角色spine动画资源
function FuncChar.deleteCharOnTreasure( charView )
    local fla = charView.fla
    charView:clear()
    
end

-- 下一个动作
-- 参数说明：charView=展示动作的主角， callback=动作播放完毕的回调函数，params=回调函数可以带回的参数
-- callback， params 参数可以不传
function  FuncChar.playNextAction( charView,callback,params )
    -- 随机动作用。目前不需要随机动作
    -- local actionArrNum = #charView.actionArr
    --local random = RandomControl.getOneRandomInt(actionArrNum+1,1,charView.actionIdx)
    --charView.actionIdx = random

    if charView.playAction then
        return
    end

    local playSkillEff = function( charView )
        if not charView.skillEff then
            return
        end

    end

    local playActionEnd =function ( charView )
        charView.playAction = false
        if callback then
            if params then
                callback(unpack(params))
            else
                callback()
            end
        end
    end

    charView.playAction  = true
    if charView.label1 == 1 then
        local actionArr = { 
            {label = charView.actionArr.atkNear },
            {label = charView.actionArr.stand,loop = true, startCall = c_func(playActionEnd, charView)} ,
           }
        charView:playActionArr( actionArr )

        -- 特效部分
        playSkillEff(charView)

    elseif charView.label1 == 2 then
        local actionArr = { 
            {label = charView.actionArr.atkFar },
            {label = charView.actionArr.stand,loop = true, startCall = c_func(playActionEnd, charView)} ,
           }
        charView:playActionArr( actionArr )

        -- 特效部分
        playSkillEff(charView)

    elseif charView.label1 == 3 then
        local singTime = charView.singTime
        local actionArr = { 
            {label = charView.actionArr.giveOutBS },
            {label = charView.actionArr.giveOutBM,loop = true, startCall = c_func(playSkillEff, charView),lastFrame = singTime } ,
            {label = charView.actionArr.giveOutBE} ,
            {label = charView.actionArr.stand,loop = true, startCall = c_func(playActionEnd, charView)} ,
           }
        charView:playActionArr( actionArr )

    end
end

--[[
    得到主角祭出middle的label
]]
function FuncChar.getCharGiveOutMiddleLabel( avatar ) 
    return "giveOutBMiddle_1";  
end

--[[
    得到主角祭出start的label
]]
function FuncChar.getCharGiveOutStartLabel( avatar ) 
    return "giveOutBStart_1";  
end

--[[
    得到主角跑步的label
]]
function FuncChar.getCharRunLabel( avatar ) 
    return "run_1";  
end

--[[
    得到主角站立待机的label
]]
function FuncChar.getCharStandLabel( avatar ) 
    return "stand_1";  
end

--[[
    得到主角走路的
]]
function FuncChar.getCharWalkLabel( avatar )
    return "walk_1";
end

--半身立绘
function FuncChar.getHeroArtSpine(hid)
	local data = heroData[hid]
	return data.actSpine
end

--根据默认法宝获取主角默认动作
function FuncChar.getDefaultTreasureSourceData(hid)
	local defaultTreasureId = tostring(tonumber(hid) - 100)
	local state = FuncTreasure.getValueByKeyTD(defaultTreasureId, "state")
	local sourceId = FuncTreasure.getValueByKeyTSD(state[1], "source")
	local sourceData = FuncTreasure.getSourceDataById(sourceId)
	return sourceData
end

--选角色界面的文字
function FuncChar.getHeroSelectTalk(hid)
	local data = heroData[hid]
	return GameConfig.getLanguage(data.talk)
end
