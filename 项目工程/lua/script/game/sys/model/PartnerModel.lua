--伙伴系统
--2016-12-6 14:29:19
--@Author:狄建彬
local PartnerModel = class("PartnerModel",BaseModel)

function PartnerModel:init( d,_skillPoint)
  PartnerModel.super.init(self,d)
  self._partners=d--伙伴集合
--伙伴技能点
   self._skillPoint =_skillPoint
--临时数据
--红点显示
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            { redPointType = HomeModel.REDPOINT.DOWNBTN.PARTNER, isShow = self:redPointShow() })
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            { redPointType = HomeModel.REDPOINT.DOWNBTN.EQUIPMENT, isShow = self:redPointShow() })
end
--注意,尽可能的少发送事件
function PartnerModel:updateData( d )
    --注意,伙伴的数目只会变大而不会变小
--    dump(d,"============= huo ban shua xin ============")
    local    _numChanged = false--table.length(self._partners) == table.length(d)
    --注意,一些细节可能会发生变化
    --这里需要使用 setmetable函数,因为后面会拿着个数据去创建组件
    local _changedPartner = {}
    for _key,_value in pairs(d) do
        if self._partners[_key] ~=nil then
               -- setmetatable(_value,getmetatable(self._partners[_key]));
            --技能是否发生了变化
            if _value.skills ~=nil then
                local _skill 
                for _otherKey,_otherValue in pairs(_value.skills)do
                    self._partners[_key].skills[_otherKey] = _otherValue
                    _skill ={ id = _otherKey,level = _otherValue }
                end
                EventControler:dispatchEvent(PartnerEvent.PARTNER_SKILL_CHANGED_EVENT,{id = tonumber(_key),skills = _skill})
            end
            --仙魂是否发生了变化
            if _value.souls ~=nil then
                local _soul
                for _otherKey,_otherValue in pairs(_value.souls)do--仙魂每次只可能会变化一个
                    if _otherValue.level ~=nil then--级别发生变化,此时经验也必定会发生变化
                        self._partners[_key].souls[_otherKey] = {id = tonumber(_otherKey),level =_otherValue.level ,exp = _otherValue.exp}
                    elseif _otherValue.exp ~=nil then--如果只有经验发生变化
                        self._partners[_key].souls[_otherKey].exp = _otherValue.exp
                    end
                    _soul = self._partners[_key].souls[_otherKey]
                end
                EventControler:dispatchEvent(PartnerEvent.PARTNER_SOUL_CHANGE_EVENT,{id=tonumber(_key),souls=_soul})
            end
            --星级发生了变化
            if _value.star ~=nil then
                self._partners[_key].star = _value.star
                EventControler:dispatchEvent(PartnerEvent.PARTNER_STAR_LEVELUP_EVENT,{id = tonumber(_key),star = _value.star})
            end
            --星级节点发生了变化
            if _value.starPoint ~=nil then
                self._partners[_key].starPoint = _value.starPoint
                EventControler:dispatchEvent(PartnerEvent.PARTNER_STAR_POINT_CHANGE_EVENT,{id = tonumber(_key), starPoint=_value.starPoint})
            end
            --等级发生变化
            if _value.level ~=nil then
                self._partners[_key].level = _value.level
                EventControler:dispatchEvent(PartnerEvent.PARTNER_LEVELUP_EVENT,{id =tonumber(_key),level = _value.level,exp = _value.exp})
                EventControler:dispatchEvent(PartnerEvent.PARTNER_TOP_REDPOINT_EVENT)
            end
            --经验发生变化
            if _value.exp ~=nil then
                self._partners[_key].exp =_value.exp 
                EventControler:dispatchEvent(PartnerEvent.PARTNER_EXP_CHANGE_EVENT,{id=tonumber(_key),exp = _value.exp})
            end
            --品质发生变化
            if _value.quality ~=nil then
                self._partners[_key].quality = _value.quality
                EventControler:dispatchEvent(PartnerEvent.PARTNER_QUALITY_CHANGE_EVENT,{id=tonumber(_key),quality =_value.quality})
            end
            --升品装备变化
            if _value.position ~=nil then
                self._partners[_key].position = _value.position
                EventControler:dispatchEvent(PartnerEvent.PARTNER_QUALITY_POSITION_CHANGE_EVENT,{id=tonumber(_key),position =_value.position})
                EventControler:dispatchEvent(PartnerEvent.PARTNER_TOP_REDPOINT_EVENT)
            end
            --装备升级变化
            if _value.equips ~= nil then
                for i,v in pairs(_value.equips) do
                    self._partners[_key].equips[i].level = v.level
                    EventControler:dispatchEvent(PartnerEvent.PARTNER_TOP_REDPOINT_EVENT)
                end
                
            end
            --最后将变化的信息写入到集合中
            local _somePartner=table.copy(self._partners[_key])
            _changedPartner[_key] = _somePartner
        else
                _numChanged = true
                self._partners[_key] = _value
                _changedPartner[_key] = _value
        end
    end
--伙伴的数目发生了变化,此时也默认伙伴的信息发生了变化
    if( _numChanged )then
         EventControler:dispatchEvent(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT,self._partners)
--否则,伙伴的信息一定发生了变化
    else
        EventControler:dispatchEvent(PartnerEvent.PARTNER_INFO_CHANGE_EVENT,_changedPartner)
    end
--红点显示
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            { redPointType = HomeModel.REDPOINT.DOWNBTN.PARTNER, isShow = self:redPointShow() })
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            { redPointType = HomeModel.REDPOINT.DOWNBTN.EQUIPMENT, isShow = self:redPointEqiupShow() })
end
--获取所有伙伴的集合
function PartnerModel:getAllPartner()
    return  self._partners
end
--获取单个伙伴数据by id
function PartnerModel:getPartnerDataById(_partnerId)
return self._partners[tostring(_partnerId)]

end
--获取伙伴数量
function PartnerModel:getPartnerNum()
    local num = 0;
    for i,v in pairs(self._partners) do
        num = num + 1
    end
    return num
end
--获取技能点
function PartnerModel:getSkillPoint()
    return self._skillPoint
end

--通过技能ID和伙伴ID判断 技能是否解锁
function PartnerModel:isUnlockSkillById(partnerId,skillId)
    local data = self:getPartnerDataById(tostring(partnerId))
    if data then
        for i,v in pairs(data.skills) do
            if i == skillId then
                return true ,v
            end
        end
    end
    return false , 0
end
--通过仙魂ID和伙伴ID判断 仙魂是否解锁
function PartnerModel:isUnlockSoulById(partnerId,soulId)
    local data = self:getPartnerDataById(tostring(partnerId))
    if data then
        for i,v in pairs(data.souls) do
            if i == soulId then
                return true ,v
            end
        end
    end
    return false , 0
end

--升品道具合成UI集
function PartnerModel:clearCombine()
    self.combineItems = nil
end
function PartnerModel:addCombineItemId(_id)
    if self.combineItems == nil then
        self.combineItems = {}
    end
    table.insert(self.combineItems,_id)
end
function PartnerModel:deleteCombineItemId(_id)
    if self.combineItems == nil then
        self.combineItems = {}
    end
    for i,v in pairs(self.combineItems) do
        if v == _id then
            table.remove(self.combineItems,i)
        end
    end
end
function PartnerModel:getCombineItemId()
    if self.combineItems == nil then
        self.combineItems = {}
    end
    return self.combineItems 
end
function PartnerModel:getCombineLastItemId()
    if self.combineItems == nil then
        self.combineItems = {}
    end
    return self.combineItems[#self.combineItems] 
end

--判断升品道具合成条件是否满足
-- 返回值 1道具或碎片不满足 2金币不满足 3满足
function PartnerModel:isCombineQualityItem(_item)
    local itemCombineCostVec = FuncPartner.getConbineResById(_item).cost
--    -- 判断是否时无消耗的道具
--    if itemCombineCostVec == nil then -- 如果为空 
--        return 1
--    end
    for i,v in pairs(itemCombineCostVec) do
        local costStr = string.split(v,",")
        if tonumber(costStr[1]) == 1 then
            if ItemsModel:getItemNumById(costStr[2]) < tonumber(costStr[3]) then
                return 1
            end
        elseif tonumber(costStr[1]) == 3 then
            local needNum ,hasNum,enough = UserModel:getResInfo( v )
            if enough == false then
                return 2
            end
        end
    end
    return 3
end
function PartnerModel:isCombineQualityOneItem(itemId,itemId2)
    local itemCombineCostVec = FuncPartner.getConbineResById(itemId2).cost
    for i,v in pairs(itemCombineCostVec) do
        local costStr = string.split(v,",")
        if tonumber(costStr[1]) == 1 then
            if tostring(costStr[2]) == tostring(itemId) then
                if ItemsModel:getItemNumById(costStr[2]) < tonumber(costStr[3]) then
                    return false
                else
                    return true
                end
            end
        end
    end
    return false
end
-- 升品道具状态
-- 返回值为 1 2 3 4 5 6
-- 1 已装备 2 可装备 3 可合成 4 置灰 5 不做处理显示用 6 已拥有但不能装备
function PartnerModel:getItemFrame(itemId,itemId2,partnerId)
    -- 首先判断是否是碎片
    local itemData = FuncItem.getItemData(itemId)
    if itemData.subType == 311 then
        local enough = self:isCombineQualityItem(itemId2)
        if enough ~= 3 then
            return 4
        end
    end

--    -- 判断是否是整道具 无消耗
--    if itemData.subType == 314 then
--        local enough = self:isCombineQualityItem(itemId)
--        if enough ~= 3 then
--            return 4
--        end
--    end

    -- 判断是否可合成
    local enough = self:isCombineQualityOneItem(itemId,itemId2)
    if enough then
        return 6
    end
    
    return 4

end
--判断升品装备是否已装备
function PartnerModel:upQualityEquiped(itemId,itemId2,partnerId)
    local isAdd = false
    local positions = {}
    local value = PartnerModel:getPartnerDataById(tostring(partnerId)).position ----- 此处应为伙伴对应的position
    while value ~= 0 do
		local num = value % 2;
		table.insert(positions, 1, num);
		value = math.floor(value / 2);
	end
    for i = 1 ,4 do
        if positions[i] == nil then
            table.insert(positions, 1, 0);
        end
    end
    local upQualityDataVec = FuncPartner.getPartnerQuality(partnerId)
    local partnerData = self:getPartnerDataById(tostring(partnerId))
    local upQualityCostVec = upQualityDataVec[tostring(partnerData.quality)].pellet;

    for i,v in pairs(positions) do
        if v == 1 and upQualityCostVec[i] == itemId then
            isAdd = true
            break
        end
    end
    return isAdd
end
-- 获取升品装备位置 传 0 1 2 3
function PartnerModel:getUpqualityPosition(_item,_partnerId)
    local upQualityDataVec = FuncPartner.getPartnerQuality(_partnerId)
    local partnerData = self:getPartnerDataById(tostring(_partnerId))
    for m,n in pairs(upQualityDataVec[tostring(partnerData.quality)].pellet) do
        if n == _item then
            local pos = m - 1   
            echo("+++++++++++++++++++ 次道具位置 = ".. pos)
            return pos
        end
    end
    return -1
end
-- 返回伙伴最大品级 
function PartnerModel:getPartnerMaxQuality(partnerId)
    local data = FuncPartner.getPartnerById(partnerId)
    return data.maxQuality
end
--返回品质的颜色
function PartnerModel:getQualityColor(partnerId,quality)
    local partnerData = FuncPartner.getPartnerQuality(partnerId);
    local data = partnerData[tostring(quality)]
    echo("++++++++++++++++ color = " .. data.color)
    return data.color
end

--获取加成描述文字 例如：6,10 攻击力+10
function PartnerModel:getDesStahe(des)
    local buteData = FuncChar.getAttributeData()
    local buteName = GameConfig.getLanguage(buteData[tostring(des.key)].name)
    local str = buteName.."+"..des.value
    return str
end
--获取加成描述文字 例如：6,10 攻击力+10
function PartnerModel:getDesStaheTable(des)
    if des == nil then
        return ""
    end
    local buteData = FuncChar.getAttributeData()
    local buteName = GameConfig.getLanguage(buteData[tostring(des.key)].name)
    local str = buteName..": +"..des.value
    return str
end
-- 升星消耗是否满足 返回false的时候 会返回不足的类型 1 碎片 2铜钱
function PartnerModel:isCanUpStar(_partnerId)
    -- 升星消耗
    local vec = FuncPartner.getStarsByPartnerId(_partnerId)
    local partnerData = self:getPartnerDataById(tostring(_partnerId))
    local costVec = vec[tostring(partnerData.star)].cost
    local cost = costVec[partnerData.starPoint + 1];
    local haveNum = ItemsModel:getItemNumById(_partnerId)
    if haveNum >= cost then
        if vec[tostring(partnerData.star)].coin > UserModel:getCoin() then
            return false ,2
        else
            return true ,0
        end
        
    else
        return false ,1
    end
end
----------- 显示红点逻辑 ---------------
--主城红点显示
function PartnerModel:redPointShow()
    for i,v in pairs(self._partners) do
        --升品
        if self:isShowQualityRedPoint(v.id) then
            return true
        end
        --升级
        if self:isShowUpgradeRedPoint(v.id) then
            return true
        end
        --升星
        if self:isShowStarRedPoint(v.id) then
            return true
        end
        --技能
        --绝技
    end
    return false
end
--主城装备红的显示
function PartnerModel:redPointEqiupShow()
    for i,v in pairs(self._partners) do
        if self:isShowEquipRedPoint(v.id) then
            return true
        end
    end
    return false
end
-- 升品红点显示 
function PartnerModel:isShowQualityRedPoint(_partnerId)
    local partnerData = self:getPartnerDataById(tostring(_partnerId))
    local upQualityDataVec = FuncPartner.getPartnerQuality(tostring(_partnerId))[tostring(partnerData.quality)]
    local isShow = true
    if partnerData.position ~= 15 then
        local positions = {}
        local value = partnerData.position
        while value ~= 0 do
		    local num = value % 2;
		    table.insert(positions, 1, num);
		    value = math.floor(value / 2);
	    end
        for i = 1 ,4 do
            if positions[i] == nil then
                table.insert(positions, 1, 0);
            end
        end
        -- 判断每一个是否 装备 可装备 
        -- 有一个可添加的 就显示红点
        local itemsV = upQualityDataVec.pellet
        for i,v in pairs(itemsV) do
            if ItemsModel:getItemNumById(v) > 0 and positions[i] == 0 then
                isShow = true
                break
            else
                isShow = false
            end
        end
    end
    local currentPartnerLevle = partnerData.level
    local maxQuality = FuncPartner.getPartnerById(_partnerId).maxQuality
    local needPartnerLevle = upQualityDataVec.partnerLv;
    if currentPartnerLevle < needPartnerLevle or maxQuality == partnerData.quality then
        isShow = false
    end

    --铜钱判断
    if UserModel:getCoin() < upQualityDataVec.coin then
        isShow = false
    end
    return isShow
end
-- 升星红点显示
function PartnerModel:isShowStarRedPoint(_partnerId)
    local partnerData = FuncPartner.getPartnerById(_partnerId);
    local maxStar = partnerData.maxStar
    local currentStar = self:getPartnerDataById(tostring(_partnerId)).star
    if maxStar == currentStar then -- 已经升到最大行
        return false
    else
        return self:isCanUpStar(_partnerId)
    end
end
-- 升级红点显示
function PartnerModel:isShowUpgradeRedPoint(_partnerId)
    local partnerData = self:getPartnerDataById(tostring(_partnerId))
    local partnerLevel = partnerData.level;
    if (UserModel:level() - partnerLevel) > 3 or (UserModel:level() - partnerLevel) <= 0 then
        return false
    elseif (UserModel:level() - partnerLevel) == 0 then
        return false
    else
        -- 判断材料 是否满足
        local expItem = FuncPartner.getPartnerById(_partnerId).expItem
        for i,v in pairs(expItem) do
            local currentExp = partnerData.exp;
            local levelData = FuncPartner.getConditionByLevel(partnerLevel)
            local maxExp = levelData[tostring(FuncPartner.getPartnerById(_partnerId).aptitude)].exp
            if ItemsModel:getItemNumById(v) > 0 then
                local _itemData = FuncItem.getItemData(v)
                if _itemData.subType == 308 then
                    return true
                else
                    local addExp = _itemData.useEffect * ItemsModel:getItemNumById(v)
                    if maxExp <= (addExp + currentExp) then
                        return true
                    end 
                end
                
            end
        end
        return false
    end
end
-- 装备红点显示
function PartnerModel:isShowEquipRedPoint(_partnerId)
    local partnerCfgData = FuncPartner.getPartnerById(_partnerId);
    for i,v in pairs(partnerCfgData.equipment) do
        if self:isShowEquipRedPointByEquipId(_partnerId,v) then
            return true ,i
        end
    end
    return false
end
function PartnerModel:isShowEquipRedPointByEquipId(_partnerId,equipId)
    local partnerData = self:getPartnerDataById(tostring(_partnerId))
    local level = partnerData.equips[equipId].level
    local equData = FuncPartner.getEquipmentById(equipId)
    local needLevel = equData[tostring(level)].needLv or 0 
    equData = equData[tostring(level)]
    if needLevel <= partnerData.level then --是否解锁
        if self:equipLevelMax(equipId,level) then
            return false
        end
        local costVec = equData.lvCost or equData.qualityCost;
        for i,v in pairs(costVec) do
            local str = string.split(v,",")
            if tonumber(str[1]) == 1 then
                local num = ItemsModel:getItemNumById(str[2]);
                if num < tonumber(str[3]) then
                    return false
                end
            elseif  tonumber(str[1]) == 3 then -- 铜钱   
                if tonumber(str[2]) > UserModel:getCoin() then
                    return false
                end
            end
        end
    else
        return false    
    end
    return true
end
--判断装备是否满级
function PartnerModel:equipLevelMax(_equipId,level)
    local equData = FuncPartner.getEquipmentById(_equipId)
    equData = equData[tostring(level)]
    if equData.lvCost == nil and equData.qualityCost == nil then
        return true
    else
        return false
    end
end
--是否有技能可以升级
function PartnerModel:isShowSkillRedPoint(_partnerId)
    local _user_coin = UserModel:getCoin()
    local _user_level = UserModel:level()
    local _partnerInfo = self._partners[tostring(_partnerId)]
    local _red_point = false
    local _skill_table = FuncPartner.getPartnerById(_partnerId)
    --首先统计星级约束
    local _star_condition = {}
    local _star_table = FuncPartner.getStarsByPartnerId(_partnerId)
    for _key,_value in pairs(_star_table)do
        if _value.skillId ~= nil then
            _star_condition[_value.skillId] = tonumber(_key)
        end
    end
    --遍历所有的伙伴技能
    for _key,_skillId in pairs(_skill_table.skill)do
        local _now_level = _partnerInfo.skills[_skillId] or 1
        --等级约束,星级约束
        if _now_level < _user_level and _star_condition[_skillId] <= _partnerInfo.star then
            local _partner_skill = FuncPartner.getSkillInfo(_skillId)
            local _skill_cost = FuncPartner.getSkillCostInfo(_partner_skill.quality)
            local _real_cost = _skill_cost[tostring(_now_level)].coin
            --铜钱约束
            if _real_cost <= _user_coin then
                _red_point = true
                break
            end
        end
    end
    return _red_point
end
--仙魂红点事件
function PartnerModel:isShowSoulredPoint(_partnerId)
    --统计几种道具可以产生的升级经验
    local _soul_item = {}
    for _key,_value in pairs(FuncPartner.SoulItemId)do
        local _item_item = FuncItem.getItemData(_key)
        _soul_item[_key] = ItemsModel:getItemNumById(_key) * _item_item.useEffect
    end
    --计算所能产生的
end
-------------------- 初始NPC ---------------------
function PartnerModel:initNpc(_partnerId)
    local t1 = os.clock()
    local partnerData = FuncPartner.getPartnerById(_partnerId);
    local bossConfig = partnerData.dynamic
    local arr = string.split(bossConfig, ",");
--    local sp = ViewSpine.new(arr[1], {}, arr[1]);
    local sp = FuncPartner.getHeroSpine(_partnerId)
    if arr[3] == "1" then 
        sp:setRotationSkewY(180);
    end 
    if arr[4] ~= nil then -- 缩放
        local scaleNum = tonumber(arr[4])
        if scaleNum > 0 then
            scaleNum = 0 - scaleNum    
        end
        sp:setScaleX(scaleNum)
        sp:setScaleY(-scaleNum)
    end
    if arr[5] ~= nil then -- x轴偏移
        sp:setPositionX(sp:getPositionX() + tonumber(arr[5]))
    end
    if arr[6] ~= nil then -- y轴偏移
        sp:setPositionY(sp:getPositionY() + tonumber(arr[6]))
    end
    
    sp:setShadowVisible(false)
    echo(os.clock() - t1,"-------- spin ddddd 消耗时间");
    return sp
end
--判断伙伴已存在
function PartnerModel:isHavedPatnner(_partnerId)
    for i,v in pairs(self._partners) do
        if tostring(v.id) == tostring(_partnerId) then
            return true
        end
    end
    return false
end
--伙伴合成需要碎片数量
function PartnerModel:getCombineNeedPartnerNum(_partnerId)
    return FuncPartner.getPartnerById(_partnerId).tity
end
--伙伴升星需要碎片数量
function PartnerModel:getUpStarNeedPartnerNum(_partnerId)
    local partnerData = self:getPartnerDataById(tostring(_partnerId))
    local costVec = FuncPartner.getStarsByPartnerId(_partnerId)
    local costFrag = 0
    for i,v in pairs(costVec) do
        if v.star == partnerData.star then
            local starStage = partnerData.starPoint+1;
            if starStage > 4 then
                costFrag = 0
            else
                costFrag = (v.cost)[starStage]
            end
            
            break
        end
    end
    return costFrag
end
--获得有几个大于level参数级别的伙伴
function PartnerModel:partnerNumGreaterThenParamLvl(level)
    local num = 0
    for i,v in pairs(self._partners) do
        if v.level > level then
            num = num + 1
        end
    end
    return num
end
--获得有几个大于quality参数品质的伙伴
function PartnerModel:partnerNumGreaterThenParamQuality(quality)
    local num = 0
    for i,v in pairs(self._partners) do
        if v.quality > quality then
            num = num + 1
        end
    end
    return num
end
--获得有几个大于star参数星级的伙伴
function PartnerModel:partnerNumGreaterThenParamStar(star)
    local num = 0
    for i,v in pairs(self._partners) do
        if v.star > star then
            num = num + 1
        end
    end
    return num
end
--计算所有伙伴战力总和
function PartnerModel:getAllPartnerAbility( )
    local _ability = 0
    if self._partners then
        for i,v in pairs(self._partners) do
            _ability = _ability + FuncPartner.getPartnerAvatar( v )
        end
    end
    echo("伙伴 总战力 ====== ".. _ability)
    return _ability
end
--检查伙伴是否存在
function PartnerModel:isPartnerExist(_partnerId)
    return self._partners[tostring(_partnerId)] ~= nil 
end
return PartnerModel