--
-- Author: XD
-- Date: 2014-07-24 10:44:47
--
local Fight = Fight
--触发事件的名称数组  比如 生命值改变的时候 需要触发生命改变侦听 通知ui 去更新生命值
local eventNameArr = {  hp = BattleEvent.BATTLEEVENT_CHANGEHEALTH,
                        energy =BattleEvent.BATTLEEVENT_CHANGEENEGRY,
                        power = BattleEvent.BATTLEEVENT_CHANGEPOWER,
                        state = BattleEvent.BATTLEEVENT_PLAYER_STATE,
                        }


--  每个数据对象 都有一个属性值 对应静态属性
ObjectHero = class("ObjectHero")


--对应的静态数据库对象  是非修改的 每个数据对象的 静态数据格式对应 对影静态数据获取格式
--static  静态属性 会从数据库直接取过来  而且这个数值是不能更改的
-- ObjectHero.prototypeData= {
-- }

--实例属性
--一定要让这里的数值属性 和 传递过来的属性保持一致  这样是为了 保证 修改某个属性值的时候 方便拿到初始值          
        
--[[
    --记录自身的buff信息
    {
        --buff类型
        type = Fight.bufftType_resumeHealth,
        kind = 1
        value = 100,
        time  = 100,
        eff = nil
    }  

]]
ObjectHero.treasures = nil      -- 对象带的技能对象数组

ObjectHero.posIndex = 0            --位置  


ObjectHero.gridPos = nil       --记录自己在第几个x 几个y 的格子


--[[
    --结构
    {
        buffType1:{ buff1,buff2 },
        buffType2:{ buff1,buff2 },
        buffType3:{ buff1,buff2 },
        ...
    }

]]

ObjectHero.buffInfo = nil       -- buff信息

--[[
    结构
    {
        buffType1:{ani1,ani2,...},是一个特效数组

    }
]]

-- ObjectHero.__hp = 0
-- ObjectHero.__energy = 0


ObjectHero.rid = "bzd" -- 必须默认一个值，不能用nil 因为怪物的时候不会赋值rid
ObjectHero._curTreasureHid = 0
ObjectHero.curTreasureIndex = 0     --当前法宝序号 默认是0 表示默认法宝 1表示第一个位置 2表示第二个位置
ObjectHero.defArmature = nil
ObjectHero.defSpbName = nil
ObjectHero.curArmature = nil    --当前spine动画名称
ObjectHero.curSpbName = nil     --当前的spine 配置文件名称  这2个是独立的

-- 不需要备份的数据
ObjectHero.__heroModel = nil
ObjectHero.speed = 0   -- 配表数据不需要备份,创建时就会有
ObjectHero.curTreasure = nil  -- 当前所带法宝
ObjectHero.isCharacter = nil
ObjectHero.sourceData = nil -- 人物的动作
ObjectHero.__actionExArr = nil
ObjectHero.attackDis = nil
ObjectHero.attackSep = nil

--重复播放的动作
ObjectHero._repeatActionArr =nil 

--小技能概率参数
ObjectHero.skillRatioParams  = nil



function ObjectHero:ctor(hid, datas)
    --绑定侦听
    EventEx.extend(self)
    self.buffInfo = {}
    self.sourceData = {}
    self.__repeatActionArr ={}
    --目前暂时先采用固定配置 等策划需求跟上   然后需要根据datas的属性确定最终的实例属性
    self.hid = hid
    self.rid = datas.rid
    --站位
    self.posIndex = datas.posIndex
    --
    local xIndex = math.ceil( self.posIndex /2 )
    local yIndex = self.posIndex %2 
    if yIndex == 0 then
        yIndex = 2
    end

    self.isCharacter = false 
    self.speed = datas.moveSpd

    local initTrea = nil
    if datas.peopleType < Fight.people_type_summon then
        ObjectCommon.getPrototypeData("char.Char",hid,self)
        self.defSpbName,self.defArmature = FuncChar.getSpineAniName(tonumber(self.hid),datas.lv)
        self.viewSize = self:sta_viewSize() or {50,140}
        initTrea = self:sta_initTrea()
    else
        self.defArmature = datas.armature
        self.defSpbName = datas.armature
        self.viewSize = datas.viewSize
    end

    self.gridPos = {x=xIndex ,y =yIndex}
    self:updateDatas(datas,true)

    -- echo("sel.hpAi------------------")
    -- dump(self:hpAi)
    -- echo("sel.hpAi------------------")
    self.hpAiObj = ObjectHpAi.new(self:hpAi() ,self  )

    --小技能参数管理
    local sskp = self.datas.sskp 
    --如果配置了小技能 那么小技能才能触发
    if sskp then
        self.skillRatioParams = {start = sskp[1],current = sskp[1],step = sskp[2], need=sskp[3]   }
    else
        self.skillRatioParams = nil
    end
    

end


--是否是默认法宝
function ObjectHero:isDefaultTreasure(  )
    return self.curTreasure == self.treasures[1]
end


--是否是大体型角色
function ObjectHero:isBigger(  )
    return self:figure() > 1
end

function ObjectHero:setCharacter()
    self.isCharacter = true
end 

--初始化各种二级属性
function ObjectHero:initSecondProp(  )
    local attr = self.datas
    for k,v in pairs(attr) do
        if k ~= "rid" and k ~= "hid" then
            self["__"..k] = v
            --同时存储下初始值,
            self["__init"..k] = v

            --必须动态设置 没有设定的属性方法,避免覆盖
            if not ObjectHero[k] then
                ObjectHero[k] = function ( _self )
                    --直接返回这个属性
                    return _self["__"..k]
                end
            end
        end
    end
end

--更新数据 --是否是初始化
function ObjectHero:updateDatas( datas ,init )
    self.datas = clone(datas)
    --初始化二级属性
    self:initSecondProp()
    self.treasures = {}

    local treasurArr = self.datas.treasures

    local char = nil
    local ismonster = true
    local sex = 1
    if self:peopleType() < Fight.people_type_summon then        
        sex = self:sex()
        char = "A"
        if sex == 2 then
            char = "B"
        end
        char = char..self:sta_charIdx()
        ismonster = false
    end

    -- 法宝
    for i=1,#treasurArr do
        local num = #self.treasures + 1
        local treasueObj = ObjectTreasure.new(treasurArr[i].hid,treasurArr[i],char,sex,ismonster)
        self.treasures[num] = treasueObj
        treasueObj.treaType = treasurArr[i].treaType
        if treasurArr[i].treaType == "base" then
            self:useTreasure(treasueObj)
        end
    end 
end

--插入一个法宝 返回法宝的treasureIndex
function ObjectHero:insterTreasure( treasureHid )
    local  sex = 1
    local treasueObj = ObjectTreasure.new(treasureHid,{},nil,sex,true)
    for i=1,4 do
        if not self.treasures[i] then
            self.treasures[i] = treasueObj
            treasueObj:setHero(self.__heroModel)
            return i -1
        end
    end
end


-- 使用法宝的数据
function ObjectHero:useTreasure(treasure,treasureIndex)
    -- 首先清除光环这个法宝自带的光环
    local isChangeTreasure = false
    if self.curTreasure and treasure ~= self.curTreasure then
        self:cancleAure()
        isChangeTreasure = true
    end
    self.curTreasureIndex = treasureIndex
    treasure:initData()
    self.curTreasure = treasure
    self._curTreasureHid = self.curTreasure.hid

    -- 动作
    self:getAllAction()

    self:initAure()

end

--初始化一个法宝的光环 或者说是天赋
function ObjectHero:initAure(  )
    local skill5 =self.curTreasure.skill5
    if skill5 then
        skill5:doAtkDataFunc()
    end
    local skill6 =self.curTreasure.skill6
    if skill6 then
        skill6:doAtkDataFunc()
    end
end

--取消这个英雄附带的光环
function ObjectHero:cancleAure(  )
    local allModelArr = self.__heroModel.controler.allModelArr
    local length = #allModelArr
    for i=length,1,-1 do
        local hero = allModelArr[i]
        if hero.data and hero.data.clearAuraByTargeHero then
            --让每个英雄都取消掉作用在他身上的光环
            hero.data:clearAuraByTargeHero(self.__heroModel)
        end
    end
end


--当换法宝的时候 需要遍历所有人取消掉所有的光环
function ObjectHero:clearAuraByTargeHero(heroModel  )
    for k,v in pairs(self.buffInfo) do
        local length = #v
        local hasClear = false
        for i=length,1,-1 do
            local buffObj = v[i]
            --必须是同一个作用着 而且 time < 0  而且
            if buffObj.hero == heroModel and buffObj.time < 0 and buffObj:sta_followClear() == 1 then
                self:clearOneBuffObj(buffObj)
                --移除这个buff
                table.remove(v,buffObj)
                hasClear = true
            end
        end
        if hasClear then
            self:useLastBuffAni(k)
        end
    end
end


-- 获得法宝的所有动作
function ObjectHero:getAllAction()
    local treasure = self.curTreasure


    -- 动作序列
    self.curArmature = treasure.spineName
    self.curSpbName = self.curArmature
    if self.curArmature == "0" then
        self.curArmature = self.defArmature
        self.curSpbName = self.defSpbName
    end

    if not self.curSpbName then
        echoError("__没有找到spine文件ingz",treasure.hid,treasure.spineName)
    end

    --直接拿法宝的动作
    self.sourceData = self.curTreasure.sourceData

    -- 动作特效跟sourceId 绑定
    local sourceId = self.curTreasure:sta_source()
    self.__actionExArr = ObjectCommon:getSourceEx(sourceId)

    --记录能重复播放的动作
    --
    local repeatArr = {"stand","walk","run","giveOutBM","rushMiddle","win","repelledMiddle"}
    for i,v in ipairs(repeatArr) do
        local act = self.sourceData[v]
        if act then
            if type(act) == "string" then
                self.__repeatActionArr[ act  ] = true
            else
                for kk,vv in pairs(act) do
                    self.__repeatActionArr[ vv ] = true 
                end
            end
        end
    end

end

function ObjectHero:getActionEx( action )
    if not self.__actionExArr then
        return nil
    end
    return self.__actionExArr[action]
end

function ObjectHero:hang( ... )
    return 0
end



function ObjectHero:setHeroModel( hero )
    self.__heroModel = hero
    for i,v in pairs(self.treasures) do
        v:setHero(hero)
    end
end

--改变某个属性
--[[
    name  属性名称
    value 改变值
    changeType 类型 1 是按数值变化 2是按照比例变化
    min 最小值 限制
    max 最大值 限制
]]
function ObjectHero:changeValue( name,value,changeType ,min,max )
    local keyName = "__".. name
    local old = self[keyName]

    changeType = changeType or 1

    local changeNum
    --按数值改变
    if changeType ==Fight.valueChangeType_num then
        old = old + value
        changeNum = value
    else
        local initValue = self["__init"..name]
        
        if initValue then
            changeNum = initValue * value
            old =old + initValue * value
        else
            echoWarn("key:",name,"按比例修改属性但是没有获取到初始属性值")
        end
    end

    max = max or self["__max"..name]
    min = min or 0
    if min then
        if old < min then
            old = min
        end
    end

    if max then
        if old > max then
            old = max
        end
    end
    self[keyName] = old

    --发送一个对应属性改变的侦听  比如 攻击改变 或者防御 生命改变之后 是需要发送侦听的
    local eventName = eventNameArr[name]
    if eventName and self.__heroModel then
       self:dispatchEvent(eventName,changeNum)
    end
    return changeNum
end


-----------------------------------------------------------------------------------------
-----------------------------buff相关------------------------------------------------------------
-----------------------------------------------------------------------------------------

----------------------------------------------------------------------
---------------------设置buff-----------------------------------------
-- buffObj
function ObjectHero:setBuff(buffObj )
    local buffType = buffObj:sta_type()
    if not self.buffInfo[buffType] then
        self.buffInfo[buffType] = {}
    end
    local arr = self.buffInfo[buffType]


    --判断是否加属性
    local attrProp = Fight.buffMapAttrType[buffType]
    --如果是属性buff --那么直接修改属性 不用在每次获取属性的时候 修改属性了
    if attrProp then
        if buffObj.changeType == Fight.valueChangeType_num  then
            self:changeValue(attrProp, buffObj.value, buffObj.changeType)
        else
            --按比例的话需要除以100
            self:changeValue(attrProp, buffObj.value/100, buffObj.changeType)
        end
        
    end

    --如果是马上执行的
    if buffObj.runType == Fight.buffRunType_now then
        -- 打上就又效果
        self:doBuffFunc(buffObj)
    end
    
    --如果次数为0 表示是一次性行为
    if buffObj.time == 0 then
        self:clearOneBuffObj(buffObj)
        return
    end
    if self:hp() <= 0 and buffType ~= Fight.buffType_relive  then
        self:clearOneBuffObj(buffObj)
        return
    end
    local length = #arr
    -- 判断是否可以叠加
    if length > 0 then

        --相同id的buff直接移除
        for i=length,1,-1 do
            local tempObj = arr[i]
            --同一个hid的buff 直接后面覆盖前面的
            if tempObj.hid == buffObj.hid then
                self:clearOneBuffObj(tempObj)
                table.remove(arr,i)
            end
        end

        --判断叠加方式
        local replace  = buffObj.replace
        --如果是并行的
        if replace == Fight.buffMulty_all then
            self:sureInsertBuff( arr, buffObj )
        --如果是直接替换的
        elseif replace == Fight.buffMulty_replace  then
            --移除所有的老buff
            for i,v in ipairs(arr) do
                self:clearOneBuffObj(v)
            end
            --清空数组
            table.clear(arr)
            self:sureInsertBuff( arr, buffObj )
        --如果是比较剩余最大次数的
        elseif replace == Fight.buffMulty_max then
            local maxTime = 0
            local length = #arr
            local hasReplace
            for i=length,1,-1 do
                local obj = arr[i]
                --如果有 永久的同类型buff 那么不执行
                if obj.time == -1 then
                    break
                end
                --如果新来的buff 次数大于老buff
                if obj.time < buffObj.time or buffObj.time == -1 then
                    self:clearOneBuffObj(obj)
                    table.remove(arr,i)
                    self:sureInsertBuff( arr, buffObj )
                    return
                end
            end

            --如果没有替换成功 那么 直接清掉这个buff
            self:clearOneBuffObj(buffObj)
        end
    else
        self:sureInsertBuff( arr, buffObj )
    end
end

--做buff 飘字特效
function ObjectHero:doBuffFlowEff(buffObj )
    if buffObj:sta_flowWord() ~= 1 then
        return
    end    
    --判断是用哪种动画
    local kind = buffObj.kind
    local buffType = buffObj.type
    if kind == Fight.buffKind_aura or kind == Fight.buffKind_aurahuai   then
        echoWarn("光环不应该有,hid:",buffObj.hid)
        return
    end
    local frame 
    if kind == Fight.buffKind_hao  then
        frame = Fight.buffMapFlowWordHao[buffType]
    else
        frame = Fight.buffMapFlowWordHuai[buffType]
    end
    if not frame then
        echoWarn("____这个buff 配置了飘字动画但是没有对应的帧数,",buffObj.hid,buffType)
        return
    end
    self.__heroModel:insterEffWord( {2, frame,kind})


end



--确认插入一个buff
function ObjectHero:sureInsertBuff( buffArr, buffObj )
    table.insert(buffArr, buffObj)
    --使用这个buff的最近一个动画
    self:useLastBuffAni(buffObj.type)
    --如果是带滤镜样式的  那么 就配一个滤镜样式
    if buffObj:sta_style() then
        self.__heroModel:changeFilterStyleNums(buffObj:sta_style(),1)
    end
end

----------------------------------------------------------------------
---------------------清除buff-----------------------------------------
--清除一类buff  clearAura是否清除光环 默认是false
function ObjectHero:clearGroupBuff(buffType )
    local arr = self.buffInfo[buffType]
    if not arr or #arr ==0 then
        return
    end

    for i=#arr,1,-1 do
        local buffObj = arr[i]
        --清除buff效果
        self:clearOneBuffObj(buffObj)
        table.remove(arr,i)   
    end
     
end


--清除某一个buffid
function ObjectHero:clearOneBuffByHid( buffHid )
    for k,v in pairs(self.buffInfo) do
        local arr = v
        for i=#arr,1,-1 do
            local buffObj = arr[i]
            if buffObj.hid == buffHid then
                self:clearOneBuffObj(buffObj)
                table.remove(arr,i)
            end
        end
    end
end


--清除所有buff
function ObjectHero:clearAllBuff(  )
    for buffType,arr in pairs(self.buffInfo) do
        self:clearGroupBuff(buffType)
    end
    self.buffInfo = {}
end

--清除控制性的buff 
function ObjectHero:clearHandleBuff(  )
    --清除坏的光环
    self:clearBuffByKind(Fight.buffKind_huai )
end

--执行驱散
function ObjectHero:clearBuffByKind( ty )
    for k,v in pairs(self.buffInfo) do
        if #v > 0 then
            for i=#v,1,-1 do
                local info = v[i]
                if info.kind == ty then
                    --清除这个buff的作用
                    self:clearOneBuffObj(info)
                    table.remove(v,i)
                end
            end
        end
    end
end

--清除一个buffobj的效果
function ObjectHero:clearOneBuffObj( buffObj )
    self.__heroModel:oneBuffClear(buffObj.type,buffObj)
    local buffType = buffObj:sta_type()
    --先清除作用属性 比如加攻击的 就得把攻击还原
    local attrProp = Fight.buffMapAttrType[buffType]
    --那么这个数值是反方向的
    if attrProp then

        if buffObj.changeType == Fight.valueChangeType_num  then
            self:changeValue(attrProp, -buffObj.value, buffObj.changeType)
        else
            --按比例的话需要除以100
            self:changeValue(attrProp, -buffObj.value/100, buffObj.changeType)
        end
    end

    --减少一次滤镜样式
    if buffObj:sta_style() then
        self.__heroModel:changeFilterStyleNums(buffObj:sta_style(),-1)
    end
    -- echo("清除某个buff",buffObj.hid)
    buffObj:clearBuff()
end

----------------------------------------------------------------------
---------------------buff作用-----------------------------------------

--这里分化一些model的功能出来 是为了减轻 AutoFight的压力 主要分担的是 数据交互 以及buff这一块 因为涉及到数值


--判断能否释放大招或者法宝 普通攻击除外 --- 沉默的时候 
function ObjectHero:checkCanGiveSkill(  )
    local buffInfo = self.buffInfo
    if self:checkHasOneBuff(Fight.buffType_chenmo)  then
        return  false
    end

    --如果是不能攻击的
    if not self:checkCanAttack() then
        return false
    end

    if self:energy() < self:maxenergy() then
        return false
    end

    return true
end

--判断本回合能否行动
function ObjectHero:checkCanAttack( isSpecielSkill  )
    if self:hp() <= 0 then
        return
    end

    if not isSpecielSkill then
        --如果法宝是没有攻击技能的
        if not self.curTreasure.hasAttackSkill then
            return 
        end
    end
    
    if self:checkHasOneBuff(Fight.buffType_bingdong) or  
        self:checkHasOneBuff(Fight.buffType_xuanyun) 
        then
        return false
    end
    return true
end


--执行buff的函数
function ObjectHero:doBuffFunc( buffObj )
    local buffType = buffObj.type
    local  value = buffObj.value
    local changeType = buffObj.changeType or Fight.valueChangeType_num 
    if changeType == Fight.valueChangeType_ratio  then
        value = value /10000
    end
    --如果是降低生命
    if buffType == Fight.buffType_DOT then
        local  changeNums = self:changeValue(Fight.value_health,-value,changeType,0)
        self.__heroModel:createNumEff(Fight.hitType_shanghai ,changeNums)
        self.__heroModel:checkHealth(value)
    -- 生命恢复 
    elseif buffType == Fight.buffType_HOT then 
        local  changeNums = self:changeValue(Fight.value_health,value,changeType,0)
        self.__heroModel:createNumEff(Fight.hitType_zhiliao ,changeNums)
        self.__heroModel:checkHealth(value)

    --如果是复活
    elseif buffType == Fight.buffType_relive  then
        local expandParams = buffObj.expandParams
        local  changeNums = self:changeValue(Fight.value_health,expandParams[2],expandParams[1],0)
        self.__heroModel:createNumEff(Fight.hitType_zhiliao ,changeNums)
        --改变怒气
        if expandParams[4] > 0 then
            changeNums = self:changeValue(Fight.value_health,expandParams[4],expandParams[3],0)
            self.__heroModel:createNumEff(Fight.hitType_jiaweineng  ,changeNums)
        end
        --做复活做的事情
        self.__heroModel:doReliveAction()
    --如果是怒气
    elseif buffType == Fight.buffType_nuqi  then
        changeNums = self:changeValue(Fight.value_energy ,value,changeType,0)
        self.__heroModel:createNumEff(Fight.hitType_jiaweineng  ,changeNums)
    end
    --判断是否有作用动画
    local useAniArr = buffObj:sta_useAniArr()
    if useAniArr then
        self.__heroModel:createEffGroup(useAniArr, false,true)
    end
    self:doBuffFlowEff(buffObj)
end

----------------------------------------------------------------------
---------------------获得信息-----------------------------------------
--判断是否中了特定的BUFF
function ObjectHero:checkHasOneBuff( buffType,hid )   
    local arr = self.buffInfo[buffType]
    if not arr or #arr == 0 then      return false    end
    if not hid then return true   end
    for i,v in ipairs(arr) do
        if hid == v.hid then
            return true
        end
    end
    return false
end

-- 判断是否含有某种类型的buff
function ObjectHero:checkHasOneBuffType( buffType )   
    local arr = self.buffInfo[buffType]
    if not arr then   return false   end
    if #arr ==0 then  return false   end
    return true
end

--获取一个buff的作用值
function ObjectHero:getOneBuffValue( buffType )
    if not buffType then
        return 0
    end
    local buffArr = self.buffInfo[buffType]
    local value = 0
    if not buffArr or (#buffArr ==0) then
        return value
    end
    for i,v in ipairs(buffArr) do
        value  = value  + v.value
    end
    return value
end

-----------------------------------------------------------------------------------------
--------------------------刷新buff-------------------------------------------------------
--刷新函数目前主要是更新buff 回合前执行的buff
function ObjectHero:updateRoundFirst(  )
    local info 

    --回合前只负责执行buff
    for k,v in pairs(self.buffInfo) do
        --更新buff
        if #v > 0 then
            for i=#v,1,-1 do
                info = v[i]
                if info.runType == Fight.buffRunType_round  then
                    self:doBuffFunc(info)
                    if info.type == Fight.buffType_relive  then
                        self:clearOneBuffObj(info)
                        table.remove(v,i)
                    end
                end   
            end
        end 
    end
end

--回合后执行做的事情  主要是更新buff次数
function ObjectHero:updateRoundEnd(  )
    local info 
    --检查坏buff次数
    self:checkReduceBuff(Fight.buffKind_huai)
end

--地方回合结束后我方做什么事情 需要减少正面buff的次数
function ObjectHero:updateToRoundEnd(  )
    --检查好buff次数
    self:checkReduceBuff(Fight.buffKind_hao)
end

--检查某种kind buff的次数 -1
function ObjectHero:checkReduceBuff( kind )
    for k,v in pairs(self.buffInfo) do
        --更新buff
        if #v > 0 then
            for i=#v,1,-1 do
                info = v[i]
                if info.time > 0 and info.kind == kind  then
                    info.time = info.time - 1 
                    if info.time ==0 then
                        --移除这个数组
                        table.remove(v,i)
                        --清除这个效果
                        self:clearOneBuffObj(info)
                        self:useLastBuffAni(k)
                    end
                end
            end
        end 
    end
end


--使用某种buff的最后一个特效
function ObjectHero:useLastBuffAni( buffType,isDelay )
    local buffArr = self.buffInfo[buffType]
    local buffObj
    local lastIndex 
    local needDelay
    if self.__heroModel.hasKillEnemy and not isDelay then
        needDelay = true
    end
    if buffArr and  #buffArr >= 1  then
        for i =#buffArr, 1,-1 do
            buffObj = buffArr[i]
            local aniArr = buffObj.aniArr
            if aniArr then
                if not lastIndex then
                    lastIndex = i
                    for ii,vv in ipairs(aniArr) do
                        if needDelay then
                            vv.myView:visible(false)
                            vv.myView:stop()
                        else
                            vv.myView:visible(true)
                            vv.myView:play()
                        end
                        
                    end
                else
                    for ii,vv in ipairs(aniArr) do
                        vv.myView:visible(false)
                        vv.myView:stop()
                    end
                end
            end
        end
    end
    --主角在刚击杀人的时候 上的buff需要延时显示
    if needDelay then
        self.__heroModel:pushOneCallFunc(Fight.killEnemyFrame+8, self.useLastBuffAni,{self,buffType})
    end
end

--隐藏某种buff的动画
function ObjectHero:hideOneBuffAni( buffType )
    local buffArr = self.buffInfo[buffType]
    local buffObj
    if buffArr and  #buffArr >= 1  then
        for i =#buffArr, 1,-1 do
            buffObj = buffArr[i]
            local aniArr = buffObj.aniArr
            if aniArr then
                for ii,vv in ipairs(aniArr) do
                    vv.myView:visible(false)
                    vv.myView:stop()
                end
            end
        end
    end
end


--获取身上的buff数量
function ObjectHero:getBuffNums(  )
    local nums = 0
    for k,v in pairs(self.buffInfo) do
        nums = nums + #v
    end
    return nums
end

--获取属性 根据key
function ObjectHero:getAttrByKey( key )
    if not self[key] then
        echoError ("没有这个属性:",key)
    end
    return self[key](self)
end

--获取某个属性的比例
function ObjectHero:getAttrPercent( key )
    local value1 = self:getAttrByKey(key)
    local value2 = self:getAttrByKey("max"..key)
    return value1/value2 
end


--事件-----------

function ObjectHero:checkChanceTrigger( event )
    for i=1,5 do
        local skill = self.curTreasure["skill"..i]
        if skill then
            -- echo(skill.heroModel,self.__heroModel.camp, self.rid,skill.hid,"_______判定事件")
            skill:checkChanceTrigger(event)
        end
    end
end

function ObjectHero:beKill(  )
    return self.datas.beKill 
end



function ObjectHero:hasMaxSkill(  )
    if self.curTreasure.skill3 then
        return true
    end
    return false
end

--当释放小技能的时候
function ObjectHero:onGiveSmallSkill(  )
    --让当前值为0
    if self.skillRatioParams then
        self.skillRatioParams.current = 0
    end
    
end

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--清除
function ObjectHero:clear(  )
    self:clearAllBuff()
    self:clearAllEvent()
    self.__heroModel = nil
    --移除注册的
    FightEvent:clearOneObjEvent(self)
end

function ObjectHero:tostring(  )
    local attr =  "Heroes--id:"..self.hid..",maxHp:"..self.maxhp..",hp:"..self:hp()..",atk:"..self:atk()..",def:"..self:def()..",crit:"..self:crit()..",hit:"..self:hit()
    echo(attr)
end

return  ObjectHero
