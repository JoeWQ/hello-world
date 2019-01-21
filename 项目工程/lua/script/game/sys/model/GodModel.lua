--
--
--

local GodModel = class("GodModel", BaseModel);

function GodModel:init(data)
    -- dump(data,"神明init")
    GodModel.super.init(self, data)
    self.godsInfo = data or {}
    -- dump(self._data,"神明self.____data = ")
end

function GodModel:updateData(data)
    dump(data,"神明update")
    GodModel.super.updateData(self, data)
    dump(self._data,"神明self.___data = ")
    self.godsInfo = self._data
    dump(self.godsInfo,"神明self.data = ")
end

--通过data 判断神明是否可以解锁
function  GodModel:godCanUnlockById(data)
    local condition = data.condition;
    if UserModel:checkCondition( condition ) == nil then
        return true
    end
    return false
end
--通过data 判断神明是否被激活
function  GodModel:godUnlockById(data)
    local id = data.id;
    local god = self.godsInfo[id]
    if god then
        return true
    end
    return false
end
--通过data 判断神明是否上阵
function  GodModel:godForMulaById(data)
    return GodFormulaModel:godFormulaById(data.id)
end

-- 战斗力
function GodModel:getZhandouli(data)
   local level = self:getGodLevelById(data.id)
   local configGodExp = FuncGod.getGodExp();
   local configGodExpById = configGodExp[data.id]
   local zhandouli = 0
   if configGodExpById == nil then
       return 0
   end
   for i,v in pairs(configGodExpById) do
        if v.level <= level then
            zhandouli = zhandouli + v.power
        end
   end

   local configGodChar = FuncGod.getGodChar();
   local configGodCharById = configGodChar[data.id]
   if configGodCharById == nil then
        return zhandouli
   end
   for i,v in pairs(configGodCharById) do
        if v.level <= level then
            zhandouli = zhandouli + v.hp + v.att + v.dod + v.def + v.crit
        end
   end

   --饰品战斗力
   local configGodGroove = FuncGod.getGodGroove()
   local grooveArr = self:getGrooveArrByGodId(data.id)
   for i,v in pairs(grooveArr) do
       if self:isGrooveActivate(data.id,v) == true then
            local grooveData = configGodGroove[v]
            zhandouli = zhandouli + grooveData.power + grooveData.hp + grooveData.att + grooveData.dod + grooveData.def + grooveData.crit
       end
   end
   
   
   return zhandouli

end

--每十级增加的额外战力
function GodModel:getExtraByGodData(data)
   local configGodChar = FuncGod.getGodChar();
   local configGodCharById = configGodChar[data.id]
   local extraArr = {}
   local level = GodModel:getGodLevelById(data.id)
   if configGodCharById == nil then
        return nil
   end
   for i,v in pairs(configGodCharById) do
        if v.level <= level then
            local str = ""
            local ty = "0"
            local tyValue = 0
            if v.hp > 0 then
                ty = "1"
                local extraValue = extraArr[ty]
                if extraValue then
                    tyValue = extraValue.tyValue
                end
                tyValue = v.hp + tyValue
                str = "气血增加"
            elseif v.att > 0 then
                ty = "2"
                local extraValue = extraArr[ty]
                if extraValue then
                    tyValue = extraValue.tyValue
                end
                tyValue = v.att + tyValue
                str = "普通攻击增加"
            elseif v.dod > 0 then
                ty = "3"
                local extraValue = extraArr[ty]
                if extraValue then
                    tyValue = extraValue.tyValue
                end
                tyValue = v.dod + tyValue
                str = "闪避增加"
            elseif v.def > 0 then
                ty = "4"
                local extraValue = extraArr[ty]
                if extraValue then
                    tyValue = extraValue.tyValue
                end
                tyValue = v.def + tyValue
                str = "暴击增加"
            elseif v.crit > 0 then
                ty = "5"
                local extraValue = extraArr[ty]
                if extraValue then
                    tyValue = extraValue.tyValue
                end
                tyValue = v.crit + tyValue
                str = "灵力增加"
            end
            if tonumber(ty) > 0 then
                extraArr[ty] = {ty = ty ,tyValue = tyValue,str = str}  
            end

        end
   end
   dump(extraArr , "额外奖励战力")
   return extraArr
end

--获取神明等级 by godId
function GodModel:getGodLevelById(godId)
    local god = self.godsInfo[godId]
    if god then
        return god.level
    end
    return 0
end

--获取神明下一级  经验值 power by godId
function GodModel:getConfigGodExpAndPowerById(godId)
   local configGodExp = FuncGod.getGodExp();
   local configGodExpById = configGodExp[godId];
   local currentLevel = self:getGodLevelById(godId)
   if configGodExpById then
   local maxLevel = table.length(configGodExpById)
   echo("获取神明下一级  经验 aaa == " .. maxLevel)
   local level = currentLevel + 1
       for i,v in pairs(configGodExpById) do
           if v.level == level then
                return v.exp , v.power
           end
       end
   end
   return 0,0
end
function GodModel:getGodExpById(godId)
   local god = self.godsInfo[godId]
   if god then
       return god.exp
   end
   return 0
end

-- 强化上限 1铜钱 2仙玉
function GodModel:getStrongeUp(_type)
    local num = FuncDataSetting.getDataByConstantName("GodUpLevelNum")
    return num
end
-- 已经强化的次数 1铜钱 2仙玉
function GodModel:getStrongedUp(_type)
    if _type == 1 then
        return CountModel:getGodUpgradeCoinCount()
    elseif _type == 2 then
        return CountModel:getGodUpgradeGlodCount()
    end
end
-- 剩余强化次数
function GodModel:getRemainderCount(_type)
     return GodModel:getStrongeUp(_type) - GodModel:getStrongedUp(_type)
end

-- 获取强化消耗 1铜钱 2仙玉
function  GodModel:getCost(_type)
    if _type == 1 then
        local costInfo = FuncGod.getGodLevelUpCoinValueByKey( UserModel:level(),"consume")
        local costArr = string.split(costInfo[1],",")
        return costArr[2]
    elseif _type == 2 then
        local glodNum =  GodModel:getStrongedUp(_type) + 1
        if glodNum > GodModel:getStrongeUp(_type) then
            glodNum = GodModel:getStrongeUp(_type)
        end
        local costInfo = FuncGod.getGodLevelUpGoldValueByKey(glodNum,"consume")
        local costArr = string.split(costInfo[1],",")
        return costArr[2]
    end
end
-- 饰品是否 激活
function GodModel:isGrooveActivate(godId,grooveId)
    local god = self.godsInfo[godId] 
    if god then
        if god.grooveId then
            if  tonumber(god.grooveId) >= tonumber(grooveId) then
                return true
            end
        end
    end
    return false
end
-- 饰品激活条件是否满足 1可以激活 2消耗不足 3顺序激活 4已经激活
function GodModel:isGrooveCanActivate(godId,grooveId,costArr)
    local god = self.godsInfo[godId] 
    if god.grooveId == nil then
        local rt = true
        for i,v in pairs(costArr) do
            local a,b,c= UserModel:getResInfo( v )
            if c == false then
                rt = false
                break
            end
        end
        if rt == true then
            -- 添加 判断是否时第一个饰品
            local grooveArr = GodModel:getGrooveArrByGodId(godId)
            if grooveArr[1] == grooveId then
                return 1
            end
            return 3
        else
            return 2
        end 
    elseif tonumber(god.grooveId)+1 > tonumber(grooveId) then
        return 4
    elseif tonumber(god.grooveId)+1 == tonumber(grooveId) then
        local rt = UserModel:checkCondition(costArr)
        if rt == nil then
            return 1
        else
            return 2
        end   
    elseif tonumber(god.grooveId)+1 < tonumber(grooveId) then
        return 3   
    end
    return 0
end

-- 饰品属性
function GodModel:getGrooveShuXing(grooveId)
    local configGodGroove = FuncGod.getGodGroove()
    local data = configGodGroove[grooveId]
    local strArr = {}
    if data.power > 0 then
        local str = "威力：" .. data.power 
        table.insert(strArr,str)
    end
    if data.hp > 0 then
        local str = "气血：" .. data.hp 
        table.insert(strArr,str)
    end
    if data.att > 0 then
        local str = "普攻：" .. data.att 
        table.insert(strArr,str)
    end
    if data.dod > 0 then
        local str = "闪避：" .. data.dod 
        table.insert(strArr,str)
    end
    if data.crit > 0 then
        local str = "暴击：" .. data.crit 
        table.insert(strArr,str)
    end
    if data.def > 0 then
        local str = "灵力：" .. data.def 
        table.insert(strArr,str)
    end
    return strArr
end

-- 饰品数组 排好序
function GodModel:getGrooveArrByGodId(godId)
    local godData = FuncGod.getGodData()
    local grooveArr = godData[godId]["groove"]
    function sortFunc(a, b)
		return tonumber(a) < tonumber(b);
	end
	table.sort(grooveArr, sortFunc);
    return grooveArr
end

return GodModel;





















