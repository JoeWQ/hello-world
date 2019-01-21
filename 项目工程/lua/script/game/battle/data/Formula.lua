-------------------------------------
-- Desc:战斗相关计算公式
-------------------------------------
	
Formula = Formula or {}

--等级对应的 一些基础属性  
local levelBattleBaseCfg = require("battle.BattleBase")

--获取基础属性值
local function getBaseValue(key,level )
    level = level <=0 and 1 or level
    local data = levelBattleBaseCfg[tostring(level)]
    if not data  then
        warn("数据没有找到,key:",key,"_level:",level)
    end

    local value = numEncrypt:getNum(data[key])
    if not value then
        echo("数据_lv有 key没有 ,key:",key,"_level:",level)
    end
    return value
end

--获取标暴
local function getbcrit(level )
    return getBaseValue("bcrit",level)
end

--获取标暴基准暴击
local function getbjcrit(level )
    return getBaseValue("bjcrit",level)
end


--获取标闪
local function getbdod(level )
    return getBaseValue("bdod",level)
end

--获取标闪基准闪避
local function getbjdod(level )
    return getBaseValue("bjdod",level)
end

--获取威能系数
local function getpowerRate(level )
    return getBaseValue("powerRate",level)
end

-- 加密字符串，一些常量值===================================================



--[[
	
--]]           
function Formula:skillDamage(atker,defer,skill,atkData,damageResult,comb)
	-- 攻击
	local atk = atker.data:atk()
	-- 改成灵力
    local def = defer.data:def()
    

    local injury = atker.data:injury() --伤害率
    local avoid = defer.data:avoid() 	--免伤率

    local dmgRatio = atkData.dmgRatio

    local damage = (atk-def ) *(1+injury/100 -avoid/100 ) * dmgRatio
    if damage <= 0 then
    	damage = 1
    end

    --判断技能伤害率
    damage = damage * skill.damageR / 100 + skill.damageN
    damage = self:getCombDamageRatio(comb) * damage
    --计算暴击强度 
    local critR = atker.data:critR()
    local blockq = atker.data:blockq()
    --如果暴击了
    if damageResult == Fight.damageResult_baoji  then
        
        damage = damage * ( critR/10000)
    --如果被格挡了
    elseif damageResult == Fight.damageResult_gedang  then
        damage = damage  * (blockq / 10000)
    --暴击加格挡
    elseif  damageResult == Fight.damageResult_baojigedang  then
        damage = damage  * critR/10000 * (blockq/10000)
    end

    if damage > 10000 then
        echo("伤害%s,atk:%02f,def:%f,injury:%d,avoid:%d,dmgRatio:%02f,skill.damageR:%d,skill.damageN:%d,critR:%d",damage,atk,def,injury,avoid,dmgRatio , skill.damageR,skill.damageN,critR)
    end

    -- if atker.data.hid == "30004" or atker.data.hid =="40026" then
    --     echo("伤害%s,atk:%02f,def:%f,injury:%02f,avoid:%f,dmgRatio:%02f,skill.damageR:%d,skill.damageN:%d",damage,atk,def,injury,avoid,dmgRatio , skill.damageR,skill.damageN)
    -- end
    
	return  math.floor(damage)
end

--[[

	功能:加血
]]
function Formula:skillTreat(atker,defer,skill,atkData,damageResult,comb  )
	-- 攻击
	local atk = atker.data:atk()
	-- 改成灵力
    local def = defer.data:def()

    local injury = atker.data:injury() --伤害率
    local avoid = atker.data:avoid() 	--免伤率

    --攻击包的伤害系数 是动态算出来的
    local dmgRatio = atkData.dmgRatio

    local damage = atk  *(1+injury/100 -avoid/100 ) * dmgRatio
    if damage <= 0 then
    	damage = 1
    end
    --判断技能伤害率
    damage = damage * skill.treaR / 100 + skill.treaN
    damage = self:getCombDamageRatio(comb) * damage
	return  math.floor(damage)
end


--[[
	功能：被击，计算闪避/暴击
--]]
function Formula:countDamageResult(atker,defer,skill)
	
    -- 计算最终结果，是闪避还是暴击了 0-1
    local canDoit = skill:sta_canCrit()
    local baojiResult = false
    if canDoit == 1 then
    	local random = BattleRandomControl.getOneRandom()
        local crit = atker.data:crit()
        local resist = defer.data:resist()
        -- echo("crit:",crit,"resist",resist)
        local ratio = crit/10000 - resist/10000
        ratio = ratio < 0 and 0 or ratio
        ratio = ratio > 1 and 1 or ratio
	    if random < ratio then
	        baojiResult = true
	    end

    end

    --判断格挡
    local  gedangResult 
    local randomGedang = BattleRandomControl.getOneRandom()

    --破击
    local wreck = atker.data:wreck()
    local block = defer.data:block()
    local blockRatio = block/10000- wreck/10000
    blockRatio = blockRatio < 0 and 0 or blockRatio
    blockRatio = blockRatio >1 and 1 or blockRatio

    if randomGedang < blockRatio then
        gedangResult = true 
    end
    -- echo(gedangResult,"poji,",wreck,"block",block)
    if baojiResult  then
        if not gedangResult then
            return Fight.damageResult_baoji 
        else
            return Fight.damageResult_baojigedang 
        end
    else
        if not gedangResult then
            return Fight.damageResult_normal 
        else
            return Fight.damageResult_gedang  
        end
    end
    return Fight.damageResult_normal
end



function Formula:getCombDamageRatio( comb )
	local ratioArr = Fight.combDmgRatio
    if comb == 0 then
        comb = 1
    elseif comb > #ratioArr then
        echoError("错误的comb:",comb)
        comb = #ratioArr
    end
    return  ratioArr[comb]
end


return Formula