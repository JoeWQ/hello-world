--
-- Author: Cwb
-- Date: 2015-11-17 10:05:47
-- 法宝管理

ObjectTreasure = class("ObjectTreasure")

ObjectTreasure.__aura = nil
ObjectTreasure.skills = nil -- 技能
ObjectTreasure.onSkill = nil -- 登场
ObjectTreasure.__maxpower = 0 -- 最大威能
ObjectTreasure.__damagePower = 0 -- 被击消耗的威能 
ObjectTreasure.__char = nil -- 主角的编号

--不备份
ObjectTreasure.objHero = nil
ObjectTreasure.spineName = nil


ObjectTreasure.skill1 = nil       --普通攻击
ObjectTreasure.skill2 = nil       --小技能
ObjectTreasure.skill3 = nil       --大招
ObjectTreasure.skill4 = nil       --特殊技
ObjectTreasure.skill5 = nil       --天赋
ObjectTreasure.skill6 = nil       --小技能
ObjectTreasure.treaType = "base"  --法宝类型 默认是 base

ObjectTreasure.leftRound = 0        --剩余回合数
ObjectTreasure.leftInjury = 0       --剩余伤害抵消
ObjectTreasure.bearRatio = 0        --伤害抵消百分比

ObjectTreasure.treasureLabel = "a"          --法宝标签  a表示a类, b表示b类法宝
ObjectTreasure.isSuyanyan = false
ObjectTreasure.hasAttackSkill = true

function ObjectTreasure:ctor( hid,datas,char,sex,monster )
	self.hid = hid
    self.data = datas
    self.__char = char
    self.__damagePower = 0
    self.hasAttackSkill = true
    if not monster then
        self.__name = FuncTreasure.getName(self.hid)
        ObjectCommon.getPrototypeData( "treasure.Treasure",hid, self )
        -- 法宝属性
        local stateInfo = self:sta_state()
        --如果法宝境界为0了 name
        if tonumber(self.data.state) == 0 or not self.data.state then
            echoWarn("这个法宝"..hid.."_境界为0了，检查原因")
            self.data.state = 1
        end
       
        if datas.state > #stateInfo then
            echoWarn( string.format("法宝:%s,当前境界%d,超过最大境界%d,请检查错误",self.hid,self.data.state,#stateInfo) )
            datas.state = #stateInfo
        end
        local stateHid = tostring(stateInfo[datas.state])  --hid.."0"..datas.state
        ObjectCommon.getPrototypeData( "treasure.TreasureState",stateHid, self )
    else
        self.__char = "A1"
        ObjectCommon.getPrototypeData( "level.EnemyTreasure",hid,self )
        self.__name = GameConfig.getLanguage(self:sta_name()) 
    end 
    
    -- 法宝的动作
    local sourceId = self:sta_source()
    if IS_CHECK_CONFIG then
        if sourceId == nil then
            echoWarn("self.hid 对应的 sourceId为空")
        end
    end
    -- 1 或者2 表示素颜
    if sourceId == 1 or sourceId == 2 then
        self.isSuyanyan = true
    end

    self.sourceData = ObjectCommon.getPrototypeData( "treasure.Source",sourceId, obj )
    if IS_CHECK_CONFIG then
        --echo("检查特效文件是否存在，动作是否存在")
        local spine = self.sourceData["spine"]
        --echo("spine",spine)
        if not FuncArmature.getSpineArmatureFrameData(spine) then
            echoWarn("source表"..sourceId.."行中的Spine不存在")
        end
        for k,v in pairs(Fight.actions) do
            local action = self.sourceData[v]
            if not FuncArmature.getSpineArmatureFrameData(spine,action) then
                echoWarn("source表"..sourceId.."行中的"..v.."动作不存在")
            end
        end
    end
    -- 区分男女
    if sex == 1 or not sex then
        self.spineName = self.sourceData.spine
    else
        self.spineName = self.sourceData.spineFormale
    end
 
    self.__maxpower = 0

    -- 登场效果
    local inSkill = self:sta_inSkill()
    if inSkill then
        self.onSkill = ObjectSkill.new(inSkill, 1,self.__char,self:sta_dmgE())
        self.onSkill:setTreasure(self)
        self.onSkill.showTotalDamage = true
    end

    -- 目前只是一个光环的情况下
    local aura = self:sta_aura()
    if aura then
        self.__aura = aura
    end

    --存储7个技能 ,分别是普攻 小技能 和大招,特殊技,天赋1,天赋2,击杀技 

    for i=1,Fight.maxSkillNums do
        local skillId = self["sta_skill"..i](self)
        if skillId then
            local  skill 
            --如果是被动技
            if i == 8 then
                skill = ObjectSpecialSkill.new(skillId, datas,self.__char,self["sta_dmg"..i](self))
            else
                skill = ObjectSkill.new(skillId, datas,self.__char,self["sta_dmg"..i](self))
            end
            self["skill"..i] = skill
            skill:setTreasure(self)
            --记录skill 的序号
            skill.skillIndex = i
            if i == 3 then
                --大招显示总伤害
                skill.showTotalDamage = true
            end
        end
    end

    --如果没有可以攻击的技能 那么就不让他攻击
    if not self.skill1 and not self.skill2 and not self.skill3 then
        self.hasAttackSkill = false
    end

    self:initData()
end

--初始化法宝
function ObjectTreasure:initData(  )
    self.leftRound = self:sta_round()or 0

    --判断是否是常驻法宝 
    if not self.leftRound or  self.leftRound == 0 then
        self.leftRound = 9999
    end

    if self.leftRound < 0 then
        self.leftRound = 999
        self.treasureLabel  = Fight.treasureLabel_b
        echo("这是B类法宝",self.hid)
    else
        self.treasureLabel = Fight.treasureLabel_a
    end

    self.leftInjury = self.sta_injury()
    if not self.leftInjury then
        self.leftInjury = 0
    end
    self.bearRatio = self.sta_bearR() or 0
end

function ObjectTreasure:setHero( hero )
    self.heroModel = hero
    for i=1,Fight.maxSkillNums do
        if self["skill"..i] then
            self["skill"..i]:setHero(hero)
        end
    end
end


-- 光环buff
function ObjectTreasure:aura( )
    return self.__aura
end
-- 境界
function ObjectTreasure:state( )
    return numEncrypt:getNum(self.data.state)
end
-- 星级
function ObjectTreasure:star( )
    return self.data.star
end
-- 最大威能
function ObjectTreasure:maxpower( )
    return self.__maxpower
end
-- 承受的伤害量
function ObjectTreasure:addDamagePower(dmg)
    self.__damagePower = self.__damagePower + dmg
end
-- debug 信息
function ObjectTreasure:tostring()
    local show = numEncrypt:decodeObject( self.prototypeData )
    dump(show)
end


--销毁法宝数据
function ObjectTreasure:deleteMe( )
    self.heroModel = nil
    for i=1,5 do
        local skill = self["skill"..i]
        if skill then
            skill.heroModel = nil
        end
    end
end


return ObjectTreasure