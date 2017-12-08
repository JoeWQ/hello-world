--[[
	guan
	持续修改中
]]

local TreasuresModel = class("TreasuresModel", BaseModel)

function TreasuresModel:init(data)
    TreasuresModel.super.init(self, data);

	--所有的法宝 包括已经被合成的和正常法宝
	self._treasures = {};

	--有的法宝
	self._ownTreasures = {};

	--已经被用于合成的法宝
	self._destroyTreasures = {};

	--法宝统计
	self._isNeedReStatistic = true;

	self.modelName = "treasure"

    self._datakeys = {
   
	}

	self:createKeyFunc();

	self:updateData(data);

	self:registerEvent();

end

function TreasuresModel:registerEvent()
    --金币增加
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, 
        self.coinChangeCallBack, self);

    --道具变化
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.itemChangeCallBack, self);


end

function TreasuresModel:redPointCheck()
	local curIsRedPonitShow = self:isRedPointShow();
	if self._preIsRedPointState == curIsRedPonitShow then 
		return;
	end 

	if curIsRedPonitShow == true then 
	    EventControler:dispatchEvent(TreasureEvent.OPERATION_STATE_CHANGE,
	        {isShow = true});	
	    self._preIsRedPointState = true;
	else 
	    EventControler:dispatchEvent(TreasureEvent.OPERATION_STATE_CHANGE,
	        {isShow = false});
	    self._preIsRedPointState = false;   
	end 
end

function TreasuresModel:coinChangeCallBack()
	self:redPointCheck();
    CombineControl:cailiaoChangeCallBack()
end

function TreasuresModel:itemChangeCallBack()
	self:redPointCheck(); 
    CombineControl:cailiaoChangeCallBack()
end

--更新数据
--没区分 已合成法宝 和 现有的法宝 --todo
function TreasuresModel:updateData(data)
	-- dump(data, "------TreasuresModel:updateData-------");
	-- 有没有被合成的
	local isCombinedExist = false;
	self._isNeedReStatistic = true;

	local newTreasure = {};
	
	for k, v in pairs(data) do
		if not self._treasures[k] then
			self._data[k] = v
			self._treasures[k] = Treasure.new()
			self._treasures[k]:init(v)
			self._treasures[k]:setId(tonumber(k));
			table.insert(newTreasure, tonumber(k));
		else
			self._treasures[k]:updateData(v)
			if v.status == 2 then 
				isCombinedExist = true;
			end 
		end
	end

	self:classifyTreasure();

	--发消息出去
	self:eventFireCheck(isCombinedExist, newTreasure);
end

--已经用于和成的法宝和正常法宝
function TreasuresModel:classifyTreasure()
	--清空
	self._ownTreasures = {};
	self._destroyTreasures = {};
	
	for k, t in pairs(self._treasures) do
		if t:status() == 1 then 
			self._ownTreasures[k] = t;
		else 
			self._destroyTreasures[k] = t;
		end 
	end
end

--删除数据
function TreasuresModel:deleteData( keyData ) 
	local deleteTidArray = {};

	for k, v in pairs(keyData) do
		self._treasures[k] = nil;
		table.insert(deleteTidArray, tonumber(k));
	end
	
	self:classifyTreasure();

	for k, v in pairs(deleteTidArray) do
		EventControler:dispatchEvent(TreasureEvent.TREASUREEVENT_MODEL_DELETE, 
			{tid = v});
	end

	EventControler:dispatchEvent(TreasureEvent.TREASUREEVENT_MODEL_CHANGE, {});
end

function TreasuresModel:eventFireCheck(isCombinedExist, tids)
	if isCombinedExist == true then 
		EventControler:dispatchEvent(TreasureEvent.TREASURE_COMBINE_EVENT, {});
	end 

    EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {});

    if table.length(tids) ~= 0 then 
		EventControler:dispatchEvent(TreasureEvent.TREASUREEVENT_MODEL_NEW, 
			{tids = tids});
	end 

	self:redPointCheck();

	EventControler:dispatchEvent(TreasureEvent.TREASUREEVENT_MODEL_CHANGE, {});

end

--总共有多少法宝, 不包含销毁的 
function TreasuresModel:getOwnTreasureCount()
	return table.length(self._ownTreasures);
end

--已经销毁的法宝数
function TreasuresModel:getDestroyTreasureCount()
	return table.length(self._destroyTreasures);
end

--所有法宝数量
function TreasuresModel:getAllTreasureCount()
	return table.length(self._treasures);
end

--quality int 有的法宝，按 quality 返回数量
function TreasuresModel:getOwnTreasureCountByQuality(quality)
	local num = 0;
	
	for k, t in pairs(self._ownTreasures) do
		if t:getQuality() == quality then 
			num = num + 1;
		end 
	end
	
	return num;
end

--quality int 销毁的法宝，按 quality 返回数量
function TreasuresModel:getDestroyTreasureCountByQuality(quality)
	local num = 0;
	
	for k, t in pairs(self._destroyTreasures) do
		if t:getQuality() == quality then 
			num = num + 1;
		end 
	end
	
	return num;
end

--获取已经销毁的法宝
function TreasuresModel:getDestroyedTreasureById(id)
	return self._destroyTreasures[tostring(id)]
end


function TreasuresModel:getTreasureById(id)
	return self._treasures[tostring(id)];
end

function TreasuresModel:getAllTreasure()
	return self._treasures;
end

--[[
	得到排序后的法宝
	
	self._treasuresAfterSort = {
		treasure,
		treasure,
		treasure,
		treasure,
	}

	isResort 是否需要从新排序, 默认需要重新排序
]]
function TreasuresModel:getAllTreasureWithoutKeyAfterSort()

	function sortTreasures(treasures)
		--排序规则 品质 > 阶级 > 星级 > 等级 > id
	    local sortFunc = function (t1, t2)
	        if t1:getQuality() > t2:getQuality() then 
	            return true;
	        elseif t1:getQuality() < t2:getQuality() then
	            return false;
	        else 
	            if t1:state() > t2:state() then 
	                return true;
	            elseif t1:state() < t2:state() then
	                return false;
	            else 
	                if t1:star() > t2:star() then 
	                    return true;
	                elseif t1:star() < t2:star() then 
	                    return false;
	                else 
	                    if t1:level() > t2:level() then 
	                        return true;
	                    elseif t1:level() < t2:level() then 
	                    	return false;
	                    else 
	                    	if t1:getId() > t2:getId() then 
	                    		return true;
	                    	else 
	                        	return false;
	                        end 
	                    end 
	                end 
	            end     
	        end 
	    end	

	    table.sort(treasures, sortFunc);
	end

	self._treasuresAfterSort = {};
	for k, v in pairs(self._ownTreasures) do
		table.insert(self._treasuresAfterSort, v);
	end

	sortTreasures(self._treasuresAfterSort);

    return self._treasuresAfterSort;
end

function TreasuresModel:setTreasureBeforeSort()
	self._preSortTreasure = {};
	for k, v in pairs(self._treasuresAfterSort) do
		table.insert(self._preSortTreasure, v);
	end
end

--[[
	得到下一个法宝，按照排序规则 
	--todo 加个参数，是否需要重排序
]]
function TreasuresModel:getNextTreasure(id)
	-- local total = self:getAllTreasureWithoutKeyAfterSort(false);
	local total = self._preSortTreasure or {};

	if table.length(total) == 1 then 
		return nil ;
	end 
	
	local pos = 0;
	for k, v in pairs(total) do
		if id == tonumber(v:getId()) then 
			pos = k;
		end 
	end

	if pos == 0 then 
		return nil;
	else 
		if pos == table.length(total) then 
			return total[1];
		else 
			return total[pos + 1];
		end 
	end 
end

--[[
	得到前一个法宝，按照排序规则
	--todo 加个参数，是否需要重排序
]]
function TreasuresModel:getPreTreasure(id)
	-- local total = self:getAllTreasureWithoutKeyAfterSort(false);
	local total = self._preSortTreasure or {};

	if table.length(total) == 1 then 
		return nil ;
	end 

	local pos = 0;
	for k, v in pairs(total) do
		if id == tonumber(v:getId()) then 
			pos = k;
		end 
	end

	if pos == 0 then 
		return nil;
	else 
		if pos == 1 then 
			return total[table.length(total)];
		else 
			return total[pos - 1];
		end 
	end 
end

function TreasuresModel:getBuffEffectNum(yinengId, level)
	local buffId = FuncTreasure.getValueByKeyFD(yinengId, level, "aura");
	local value = FuncTreasure.getValueByKeyBD(buffId, "value");
	return value;
end

function TreasuresModel:getSkillDes(yinengId, value)
	local transKey = FuncTreasure.getValueByKeyFD(yinengId, 1, "des1");
	local strValue = GameConfig.getLanguage(transKey, "zh_CN");

	return string.gsub(strValue, "#1", tostring(value));
end

--[[
	传入item id，得到这个 itemId 是用于强化那个法宝的
	没有用于强化的法宝返回 nil 否则 法宝 id
]]
-- function TreasuresModel:getItemServiceForTreasureId(itemId)
-- 	--没遍历所有表，有哪个法宝返回哪个法宝。需求太二了，肯定会改 zpc
-- 	if self._treasures == nil then 
-- 		return nil;
-- 	end 

-- 	for i, v in pairs(self._treasures) do
-- 		return tonumber(i);
-- 	end
-- 	return nil;
-- end

-- 获取pvp防守法宝阵型
function TreasuresModel:getPvpTreasureFormula()
	local treasureFormula = UserModel:getTreasureFormula()
	local pvpTreasureFormula =  treasureFormula[tostring(TreasuresModel.formulaType.TYPE_PVP_FORMULA)]
	if pvpTreasureFormula == nil then
		pvpTreasureFormula = {}
	end
	
	if #pvpTreasureFormula > 0 then
		pvpTreasureFormula = json.decode(pvpTreasureFormula)
	end

	return pvpTreasureFormula
end

-- 获取法宝总威能
function TreasuresModel:getTreasurePower(tid, level, star, state)
	local num = state;
	local initState = FuncTreasure.getValueByKeyTD(tid, "initState");

	if num < initState then 
		num = initState;
	end 

	local stateNum = FuncTreasure.getValueByKeyTD(tid, "state")[num];
	
	local statNum = star;
	local basePower = FuncTreasure.getValueByKeyTSD(stateNum, "baseP")[statNum];
	local increasePower = FuncTreasure.getValueByKeyTSD(stateNum, "strP")[statNum];

	local lv = level; 

	if level % 10 == 0 then 
		lv = 10;
	end 

	return basePower + increasePower * (lv - 1);
end

--根据法宝id,获取法宝品质
function TreasuresModel:getTreasureQualityById(tid)
    return FuncTreasure.getValueByKeyTD(tid, "quality") or 1;
end

-- 根据法宝id,获取法宝名称
function TreasuresModel:getTreasureName(tid)
	return FuncTreasure.getValueByKeyTD(tid, "name") or "";
end

-- 根据法宝id,获取法宝位置描述
function TreasuresModel:getTreasurePosDesc(tid)
	local pos = FuncTreasure.getValueByKeyTD(tid, "label1") or ""
	return pos
end

-- 克隆法宝id列表
function TreasuresModel:cloneTreasureIdList()
	self.cacheTreasureIdList = {};
	for k, v in pairs(self._ownTreasures) do
		self.cacheTreasureIdList[tostring(k)] = true
	end
end

-- 根据法宝id，判断缓存中是否已拥有该法宝
function TreasuresModel:hasTreasureInCache(tid)
	local find = false
	if self.cacheTreasureIdList ~= nil then
		find = self.cacheTreasureIdList[tid]
	end

	return find
end

--[[
更新缓存
]]
function TreasuresModel:addTreasureToCache(tid)
	if self.cacheTreasureIdList then
		self.cacheTreasureIdList[tostring(tid)] = true
	end
end


-- 法宝转碎片
function TreasuresModel:convertToPieces(tid)
	local pieceNum = FuncTreasure.getValueByKeyTD(tid,"sameCardDebris")
	return pieceNum
end

--法宝的所有异能, 包括未解锁的 参数是法宝id
--[[
	skills = {
		id = maxLevel,
		id = maxLevel,
	}
]]
function TreasuresModel:getAllSkillById(treasureId)
	local allSkills = FuncTreasure.getValueByKeyTD(treasureId, "featuresL");
	local skills = {};

	for i = 1, table.length(allSkills), 2 do
		local skillId = allSkills[i];
		if skillId ~= nil and skillId ~= "0" then 
			skills[tonumber(skillId)] = allSkills[i + 1];
		end 
	end

	return skills;
end

--法宝的所有异能, 包括未解锁的 参数是法宝id
--[[
	skills = {
		{id = , level = },
		{id = , level = },
		{id = , level = },
	}
]]
function TreasuresModel:getAllSkillByIdAfterSort(treasureId)
	local allSkills = FuncTreasure.getValueByKeyTD(treasureId, "featuresL");
	local skills = {};

	for i = 1, table.length(allSkills), 2 do
		local skillId = allSkills[i];
		if skillId ~= nil and skillId ~= "0" and allSkills[i + 1] ~= "0" then 
			table.insert(skills, {id = tonumber(skillId), 
				level = tonumber(allSkills[i + 1])});
		end 
	end

	return skills;
end

function TreasuresModel:getPower(treasureId, lvl, star, state)
	local stateNum = FuncTreasure.getValueByKeyTD(treasureId, "state")[state];
	
	local starNum = star;
	local basePower = FuncTreasure.getValueByKeyTSD(stateNum, "baseP")[starNum];
	local increasePower = FuncTreasure.getValueByKeyTSD(stateNum, "strP")[starNum];

	local level = lvl % 10; 

	if level == 0 and isMaxCurState(lvl, state) == true then 
		level = 10;
	end 

	return basePower + increasePower * level;
end


--[[
	所有有的法宝碎片
	return = {
		"201" = 3, -- str = num 
		"202" = 10, -- str = num
		……
	}
]]
function TreasuresModel:getAllTreasureFragmentsInBag()
--    if not self._ownFragments then
--        local treasureAllConfig = FuncTreasure.getTreasureAllConfig();
--	    -- dump(treasureAllConfig, "--treasureAllConfig---");
--	    local fragments = {};

--	    for k, v in pairs(treasureAllConfig) do
--		    if ItemsModel:getItemById(k) ~= nil then  
--                table.insert(fragments,{id = k,num = ItemsModel:getItemNumById(k)})
--		    end 
--	    end
--        self._ownFragments = fragments
--    end

    local treasureAllConfig = FuncTreasure.getTreasureAllConfig();
	    -- dump(treasureAllConfig, "--treasureAllConfig---");
	local fragments = {};

	for k, v in pairs(treasureAllConfig) do
		if ItemsModel:getItemById(k) ~= nil then  
                table.insert(fragments,{id = k,num = ItemsModel:getItemNumById(k)})
		end 
    end
    self._ownFragments = fragments
    
	return self._ownFragments;
end
--[[
 根据ID获取对应的法宝碎片数量
]]
function TreasuresModel:getTreasureFragmentsByID( id )
    local _fragments = self:getAllTreasureFragmentsInBag()
    for i = 1, #_fragments do
        if _fragments[i].id == tostring(id) then
           return _fragments[i] 
        end
    end 
    return {};
end

--[[
	所有法宝的威能之和
]]
function TreasuresModel:getTreasuresInBagTotalPower()
	local sum = 0;
	for k, v in pairs(self._ownTreasures) do
		sum = v:getPower() + sum;
	end
	return sum;
end

--[[
	拥有有的所有法宝id
	return = {
		"201" = treasure,  
		"202" = treasure, 
		……	

	}
]]
function TreasuresModel:getAllTreasureInBag()
	local treasures = {};

	for k, v in pairs(self._ownTreasures) do
		treasures[k] = v;
	end

	return treasures;
end

--[[
	condition = "2,3"
]]
function TreasuresModel:isCompleteLvlCondition(condition)
	local tables = string.split(condition, ",");
	local needNum = tonumber(tables[1]);
	local lvl = tonumber(tables[2]);

	local haveNum = 0;
	--以前有过也可以 所以是 self._treasures
	for k, v in pairs(self._treasures) do
		if v:level() >= lvl then 
			haveNum = haveNum + 1;
			if haveNum >= needNum then 
				return true, haveNum;
			end 
		end 
	end
	return false, haveNum; 
end

--[[
	condition = "2,3"
]]
function TreasuresModel:isCompleteStarCondition(condition)
	local tables = string.split(condition, ",");
	local needNum = tonumber(tables[1]);
	local star = tonumber(tables[2]);
	
	local haveNum = 0;
	--以前有过也可以 所以是 self._treasures
	for k, v in pairs(self._treasures) do
		if v:star() >= star then 
			haveNum = haveNum + 1;

			if haveNum >= needNum then 
				return true, haveNum;
			end 
		end 
	end
	return false, haveNum;
end

--[[
	是否显示红点主界面
]]
function TreasuresModel:isRedPointShow()
	for k, v in pairs(self._ownTreasures) do
		if (v:canEnhance() == true or 
			v:canRefine() == true or v:canUpStar() == true ) then 
			return true;
		end 
	end		
	return false;
end

function TreasuresModel:getStateId(id, state)
	local stateId = FuncTreasure.getValueByKeyTD(id, "state")[state];
	return stateId;
end

--[[
	根据技能的等级和id获得它加强的值
	1. dmg 2.power 3.shield 4.recover
]]
function TreasuresModel:skillIncreaseNums(treasureId, skillId, skillLvl, treasureState, treasureLvl, treasureStar)
	treasureState = treasureState or 1;
	treasureLvl = treasureLvl or 1;
	treasureStar = treasureStar or 1;

	local power = self:getPower(treasureId, treasureLvl, treasureStar, treasureState);
	-- local stateId = self:getStateId(treasureId, treasureState);
	-- local atkInitP = FuncTreasure.getValueByKeyTSD(stateId, "atkInitP");
	-- local costPR = FuncTreasure.getValueByKeyTSD(stateId, "costPR");
	-- local powerR = FuncTreasure.getValueByKeyTSD(stateId, "powerR");
	local value = FuncTreasure.getSkillValue(skillId, skillLvl);

	local attr = CharModel:getCharFightAttribute();
	-- dump(attr, "-----attr----");

	function calDmg()
		return math.floor((value / 100) * power * (1 + attr.def / 10000));
	end

	function calShield()
		return math.floor( (value / 100) * power);
	end

	function calNormalDmg()
		return math.floor((value / 100) * attr.atk);
	end

	function calRatio()
		return value;
	end

	local increaseTypes = FuncTreasure.getSkillIncreaseType(skillId, skillLvl);
	local ret = {};

	for k, increaseType in pairs(increaseTypes) do
		local num = 0;
		if increaseType == 1 then 
			num = calDmg();
		elseif increaseType == 2 then 
			num = calShield();
		elseif increaseType == 3 then
			num = calNormalDmg();
		elseif increaseType == 4 then
			num = calRatio();
		end 
		table.insert(ret, num);
	end

	-- dump(ret, "------ret-----");

	return ret;
end

--在法宝精炼界面中用，显示左边list
function TreasuresModel:getAllShowRefineTreasure()
	local ret = {};

	for k, treasure in pairs(self._treasuresAfterSort) do
	 	if treasure:isCurStageMaxLvl() == true and 
	 		treasure:isMaxPower() == false then
	 		table.insert(ret, treasure);
	 	end
	end 

	return ret;
end

--在法宝强化界面中用，显示左边list
function TreasuresModel:getAllShowEnhanceTreasure()
	local ret = {};

	for k, treasure in pairs(self._treasuresAfterSort) do

	 	if treasure:isMaxPower() == false and 
	 		treasure:isCurStageMaxLvl() == false then
	 		table.insert(ret, treasure);
	 	end

	end 
	return ret; 
end

----活动统计相关----
--所有统计都实时计算的，代码清晰点
function TreasuresModel:calStatisticMaxLevel()
	if self._isNeedReStatistic == false then 
		return self._statisticMaxLevel;
	end 

	self._isNeedReStatistic = false;
	self._statisticMaxLevel = 0;
	--统计的是所有的
	for k, treasure in pairs(self._treasures) do
		if treasure:level() > self._statisticMaxLevel then 
			self._statisticMaxLevel = treasure:level();
		end 
	end

	return self._statisticMaxLevel;
end 

return TreasuresModel



























