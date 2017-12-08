--
-- Author: XD
-- Date: 2014-07-24 10:44:47
--
ObjectSkill = class("ObjectSkill")

--实例属性
ObjectSkill.__lv = 1
ObjectSkill.action = "attack"
ObjectSkill.attackInfos = nil
ObjectSkill.cameraInfos = nil -- 摄像头信息

ObjectSkill.__treasure = nil -- 当前技能属于哪个法宝， 不需要备份

ObjectSkill.__alertEff = nil --境界区域特效
ObjectSkill.__skillEffArr = nil
ObjectSkill.__summonInfo = nil


--起始的xindex,后面的攻击包都需要根据这个来向后推移 1 2 3 对应左中右
ObjectSkill.startXIndex = 1
--起始的yIndex 1 是上 2 是下 
ObjectSkill.startYIndex = 0
ObjectSkill.yChooseType = 0
ObjectSkill.xChooseArr = nil
ObjectSkill.skillIndex = 0
--[[
--技能的数值参数  是一个数组
skillParams:

]]
ObjectSkill.missleInfos = nil

ObjectSkill.damageR = 1     --技能伤害系数
ObjectSkill.damageN = 0     --技能伤害常量
ObjectSkill.treaR = 1       --治疗百分比
ObjectSkill.treaN = 0       --治疗系数

ObjectSkill.firstHeroPosIndex = 1   --技能找到的第一个英雄 坐标

ObjectSkill.filterAi = nil         --特殊技能筛选器


ObjectSkill.hasSummonInfo = nil        --是否有召唤信息

ObjectSkill.showTotalDamage = false     --是否显示总伤害

ObjectSkill.isAttackSkill = false       --是否是攻击性技能

function ObjectSkill:ctor( hid,lv, charIdx,skillParams )
    self.hid = hid    
    self.__lv = lv

    ObjectCommon.getPrototypeData( "battle.Skill",hid,self )

    self.attackInfos = {}
    self.missleInfos = {}
    self.skillParams = skillParams

    self.hasSummonInfo = false
    self.isAttackSkill = false
    local atkInfos = self["sta_atkInfo"..charIdx](self)
    if atkInfos then
        for i,v in ipairs(atkInfos) do
            table.insert(self.attackInfos,{Fight.skill_type_attack,v.fm,v.at})
        end
    end
    
    local misInfos = self["sta_mslInfo"..charIdx](self)
    if misInfos then
        for i,v in ipairs(misInfos) do   
            table.insert(self.missleInfos,{Fight.skill_type_missle,v.fm,v.mi,v.nu or 1})
        end
    end
    if #self.skillParams < 4 then
        echoError("技能id:%s的技能参数数量不对",hid)
    end
    --伤害系数
    self.damageR = self.skillParams[1]

    --伤害常量
    self.damageN = self.skillParams[2]
    --治疗系数
    self.treaR = self.skillParams[3]
    --治疗常量
    self.treaN = self.skillParams[4]

    self:update(datas)

    self:initSkill()

    if self:sta_filterId() then
        self.filterAi = ObjectFilterAi.new(self:sta_filterId() )
    end


end

--初始化技能属性
function ObjectSkill:initSkill(  )
end

--更行技能
function ObjectSkill:update( datas )

    for i,v in pairs(self.attackInfos) do
        v[3] = ObjectAttack.getAtkObjByHid(v[3])
    end

    for i,v in pairs(self.missleInfos) do
        v[3] = ObjectMissle.new(v[3])
    end

    --这里需要遍历所有的攻击包  来判断下
    self.xChooseArr = {}
    self.yChooseType = 0
    self.isAttackSkill = false

    for i,v in ipairs(self.attackInfos) do
        if v[1] == Fight.skill_type_attack  then
            local atkData = v[3]
            local xArr =atkData.xChooseArr
            if atkData:sta_dmg() then
                --找到所有的攻击包 合并他的选择范围
                for ii,vv in ipairs(xArr) do
                    if not table.indexof(self.xChooseArr, vv) then
                        table.insert(self.xChooseArr, vv)
                    end
                end
                if self.yChooseType == 0 then
                    self.yChooseType = atkData.yChooseType
                end
                self.isAttackSkill = true
            end
            --如果是有召唤的
            if atkData:sta_summon() then
                self.hasSummonInfo =true
            end

        end
    end


    --在把xchooseArr排序
    table.sort(self.xChooseArr)
    --那么固定插入一个 表示这是只会作用在己方身上的
    if #self.xChooseArr == 0 then
        table.insert(self.xChooseArr, 1)
    end
    --倒着遍历attackInfos 找到最后一个攻击包
    local info
    --判断是不是最后一个攻击包
    for i=#self.attackInfos,1,-1 do
        info = self.attackInfos[i]
        if info[1] == Fight.skill_type_attack then
            local atkData = info[3]
            --必须是作用在敌方的 而且是伤害性的攻击包
            if atkData:sta_dmg() then
                atkData.isFinal = true
                break
            end
        end
    end
    --判断是不是第一个攻击包
    for i=1,#self.attackInfos do
        info = self.attackInfos[i]
        if info[1] == Fight.skill_type_attack then
            local atkData = info[3]
            --必须是作用在敌方的 而且是伤害性的攻击包
            if atkData:sta_dmg() then
                atkData.isFirst = true
                break
            end
        end
    end
    --初始化攻击包伤害系数
    self:initAtkDmgRatio()

    --把攻击包按时间顺序排序
    local sortFunc = function ( info1,info2 )
        return info1[2] <= info2[2]
    end


end

--计算攻击包伤害系数
function ObjectSkill:initAtkDmgRatio(  )
    local index = 1
    local percentInfoArr = {

    }

    for k,v in pairs(self.attackInfos) do
        local atkData = v[3]
        if not percentInfoArr[index] then
            percentInfoArr[index] = {0,0 }
        end
        local infoArr = percentInfoArr[index]
        if atkData:sta_dmg() then
            infoArr[1] = infoArr[1] + atkData:sta_dmg()
        end
        --如果是治疗的
        if atkData:sta_addHp() then
            infoArr[2] = infoArr[2] + atkData:sta_addHp()
        end
        atkData.__tempValueIndex = index
        --如果是最后一个攻击包
        if atkData.isFinal then
            index = index +1
        end
    end

    for i,v in ipairs(self.attackInfos) do
        local atkData = v[3]
        local info = percentInfoArr[atkData.__tempValueIndex]
        if atkData:sta_dmg() then
            atkData.dmgRatio = math.round(atkData.sta_dmg() / info[1] * 1000) / 1000
        --如果是治疗百分比的
        elseif atkData:sta_addHp() then
            atkData.dmgRatio = math.round(atkData.sta_addHp() / info[2] * 1000) / 1000
        end
    end
end


function ObjectSkill:setTreasure(treasure)
    self.__treasure = treasure
end

--获取攻击数据
function ObjectSkill:getAttackDatas(index )
    return self.attackInfos
end

--判断是否是打子弹的技能体
function ObjectSkill:isMissleSkill(  )
    for i,v in ipairs(self.attackInfos) do
        if v[1] == Fight.skill_type_missle then
            return true
        end
    end
    return false
end

--判断这个攻击包是否是最后一下 只有是最后一下的时候 才判定从数组移除英雄
function ObjectSkill:checkAtkDataIsEnd( atkData )
    return atkData.isFinal
end


--设置hero
function ObjectSkill:setHero( hero )
    self.heroModel = hero
    --给筛选器赋值hero
    if self.filterAi then
        self.filterAi.heroModel  = hero
    end
end

--判断特殊技能触发
function ObjectSkill:checkChanceTrigger(params )
    --先判定下是否做筛选功能
    self:doFilterFunc(params.chance)
    if not self.filterAi then
        return 
    end
    
    -- if self.hid == "100302" then
    --     echo("____火神特殊技判定111111111111111112",params.chance)
    -- end

    --如果是攻击前 那么判定是不是我在攻击
    if params.chance == Fight.chance_atkStart then
        if self.heroModel ~= params.attacker  then
            return
        end
    --防守前判断是否是我在防守
    elseif params.chance == Fight.chance_defStart then
        if self.heroModel ~= params.defender  then
            return
        end
    end
    local round = self.heroModel.logical.roundCount
    --如果满足触发条件了
    if self.filterAi:checkCanTrigger(round,params.chance) then
        echo("____开始判定特殊技能:",self.hid,params.chance,self.filterAi.chance,params.camp)
        local result,chooseArr = self.filterAi:startChoose(params.attacker or self.heroModel,params.defender or self.heroModel,nil,self)
        --如果成功了
        if result then
            echo("特殊技判定成功,hid:",self.hid)
            self.willDoFilterInfo = {choose=chooseArr}
            self:doFilterFunc(Fight.chance_justNow)
        end
    end
end

--判断是否做filterFunc 
function ObjectSkill:doFilterFunc( chance )

    if not self.willDoFilterInfo then
        return
    end


    
    
    local doFilterInfo = self:sta_doFilter()
    if not doFilterInfo then
        return 
    end

    local hasDo =false
    
    for i,v in ipairs(doFilterInfo) do
        
        --首先判断chance是否相同
        if v.cs == chance then
            echo("___触发特殊技----",self.filterAi.hid,self.hid,chance)
            --如果自己是做攻击包的 
            if v.t == 1 then
                local atkData = ObjectAttack.new(v.p1)
                self.heroModel:checkAttack(atkData, self)
            --如果自己做buff
            elseif v.t == 2 then
                self.heroModel:checkCreateBuff(v.p1, self.heroModel)
            --如果是给选中的人做buff
            elseif v.t == 3 then
                if #self.willDoFilterInfo.choose > 0 then
                    for ii,vv in ipairs(self.willDoFilterInfo.choose) do
                        echo("___给选中的人加buff-camp:%01d,pos:%01d,buffid:%s",vv.camp, vv.data.posIndex,v.p1 or "")
                        --那么直接创建buff
                        vv:checkCreateBuff(v.p1,self.heroModel,self)
                    end
                end
            --如果是做召唤功能
            elseif v.t == 4 then
                if self.hasSummonInfo then
                    self:doSummonFunc()
                    self.willDoFilterInfo = nil
                    return 
                end
            end
            hasDo = true
            
        end
        
    end
    if hasDo then
        --对应hero 创建转换特效
        if not Fight.isDummy then
            -- ModelEffectBasic:createCommonHeadEff( ModelEffectBasic.effMapType.teshuji,self.heroModel )
            self.heroModel:insterEffWord( {2,22, Fight.buffKind_hao  })
        end
        self.willDoFilterInfo = nil
    end
end

--做召唤行为
function ObjectSkill:doSummonFunc(  )
    --让英雄做召唤行为
    self.heroModel:setSummonAction(self)
end

--立即做攻击包行为,主要是天赋技和击杀技会做
function ObjectSkill:doAtkDataFunc(  )
    for i,v in ipairs(self.attackInfos) do
        local atkData = v[3]
        self.heroModel:checkAttack(atkData,self)
    end
end

--判断一个技能是否是aoe
function ObjectSkill:getAtkNums(  )
    if not self.isAttackSkill then
        return 0
    end
    local xNums = #self.xChooseArr
    local yNums 
    if self.yChooseType == 0 then
        yNums = 2
    else
        yNums = 1
    end
    return xNums * yNums


end


return  ObjectSkill
