--[[
	guan
]]

local Treasure = class("Treasure", BaseModel);

Treasure.StrongType = {
	Strength = 1,
	Refine = 2,
	Max = 3,
}

function isMaxCurState(lvl, state)
	if (lvl % 10 == 0 and (state * 10 <= lvl)) then 
		return true;
	else 
		return false;
	end 
end

function Treasure:init( d )
	Treasure.super.init(self,d)

	-- 法宝阵型
	TreasuresModel.formulaType = {
		TYPE_PVP_FORMULA = 1, --PVP防守法宝阵型
	}

	--注册函数  keyData
	self._datakeys = {
		level = numEncrypt:ns1() , 		--法宝等级
		state = numEncrypt:ns1(),		--法宝境界
		star = numEncrypt:ns1() , 		--法宝星级
		status = numEncrypt:ns1(),		--法宝状态:1,正常状态；2，已被用于合成其他法宝
		lastUseTime = numEncrypt:ns1(),
	}

	self:createKeyFunc()
end

--更新数据
function Treasure:updateData(data)
	Treasure.super.updateData(self, data)

	EventControler:dispatchEvent(TreasureEvent.TREASUREEVENT_MODEL_UPDATE, 
		{tid = self._id});
end

function Treasure:setId(id)
	self._id = id;
end

function Treasure:getId()
	return self._id;
end

function Treasure:getQuality()
	return FuncTreasure.getValueByKeyTD(self._id, "quality");
end

--[[
	得到法宝的威能数
]]
function Treasure:getPower()
	local num = self:state();
	local initState = FuncTreasure.getValueByKeyTD(self._id, "initState");

	if num < initState then 
		num = initState;
	end 

	local stateNum = FuncTreasure.getValueByKeyTD(self._id, "state")[num];
	
	local statNum = self:star();
	local basePower = FuncTreasure.getValueByKeyTSD(stateNum, "baseP")[statNum];
	local increasePower = FuncTreasure.getValueByKeyTSD(stateNum, "strP")[statNum];

	local level = self:level(); 

	level = self:level() % 10;

	if level == 0 and self:isCurStageMaxLvl() == true then 
		level = 10;
	end 

	return basePower + increasePower * level;
end

--[[
	当前阶段每等级加的威能数
]]
function Treasure:powerAddEachLevel()
	local num = self:state();
	local initState = FuncTreasure.getValueByKeyTD(self._id, "initState");

	if num < initState then 
		num = initState;
	end 
	
	local statNum = self:star();
	local stateNum = FuncTreasure.getValueByKeyTD(self._id, "state")[num];
	local increasePower = FuncTreasure.getValueByKeyTSD(stateNum, "strP")[statNum];
	return increasePower;
end

--[[
	前后
]]
function Treasure:getPosIndex()
	local id = self:getId();
	return FuncTreasure.getValueByKeyTD(id, "label1");
end

function Treasure:getName()
	local id = self:getId();
	local tid = FuncTreasure.getValueByKeyTD(id, "name");
	return GameConfig.getLanguage(tid, "zh_CN");
end

--法宝的所有异能, 包括未解锁的
--[[
	skills = {
		id = maxLevel,
		id = maxLevel,
	}
]]
function Treasure:getAllSkill()
	local id = self:getId();
	local allSkills = FuncTreasure.getValueByKeyTD(id, "featuresL");
	local skills = {};

	for i = 1, table.length(allSkills), 2 do
		local skillId = allSkills[i];
		if skillId ~= nil and skillId ~= "0" and allSkills[i + 1] ~= "0" then 
			skills[tonumber(skillId)] = tonumber(allSkills[i + 1]);
		end 
	end

	return skills;
end

--[[
	法宝的神通等级
]]
function Treasure:getSkillLvl(id)
	local skills = self:getAddOnSkill();
	return skills[id] or 0;
end

function Treasure:isMaxStar()
	return self:star() == 5 and true or false;
end

--[[
	需要的星星数
]]
function Treasure:getUpStarNeedFragment()
	local id = self:getId();
	if self:isMaxStar() == false then 
		local nums = FuncTreasure.getValueByKeyTD(id, "upStar");
		return nums[self:star()];
	else 
		return 0;
	end 
end

function Treasure:isCoinEnoughToUpStar( )
	local need = self:getUpStarCoinCost();
	local have = UserModel:getCoin();

	if need < have then
		return true;
	else 
		return false;
	end 
end

function Treasure:canUpStar()
	local needFragment = self:getUpStarNeedFragment();
    local haveFragment = ItemsModel:getItemNumById(self:getId());
    if (haveFragment >= needFragment) and self:star() < 5 and 
    	self:isCoinEnoughToUpStar() == true then 

    	return true;
    else 
    	return false;
    end 
end
--[[
	所有已经学到的技能
	ret = {
		id = level,
		id = level,
		id = level,
	}
	--异能
	targetState 传目标阶段， 不传就是当前阶段
]]
function Treasure:getAddOnSkill(targetState)
	local id = self:getId();
	local targetState = targetState or self:state();
	local stateId = FuncTreasure.getValueByKeyTD(id, "state")[targetState];

	local addOnSkills = FuncTreasure.getValueByKeyTSD(stateId, "feature");
	local retable = {};
	
	local i = 1;
	for k, v in pairs(addOnSkills) do
		if addOnSkills[i] == nil or tonumber(addOnSkills[i]) == 0 then
			--跳过
		else 
			if tonumber(addOnSkills[i + 1]) ~= 0 then 
				local addOnId = tonumber(addOnSkills[i]);
				retable[addOnId] = tonumber(addOnSkills[i + 1]) or 1;
			end
		end 
		i = i + 2;
	end
	return retable;
end

--是否学到了 id 技能
function Treasure:isSkillActive(id)
	local openSkills = self:getAddOnSkill();
	return (openSkills[id] ~= nil and openSkills[id] ~= 0) and true or false;
end

--是否显示向上箭头
function Treasure:isShowEnhanceArrow(id)
	--没有满级
	if self:isMaxState() == false and self:isCurStageMaxLvl() == true then
		local upLvlTable, newActivateTable = self:skillDiffNextState();
		if upLvlTable[id] ~= nil or newActivateTable[id] ~= nil then 
			return true;
		else 
			return false;
		end 
	else  
		return false;
	end
end


--[[
	进阶到下一阶段 异能 变化

	upLvlTable = {
		1002 = 1, --生了几级
		1002 = 2
	},
	newActivateTable = {
		101 = 1, --初始登记
		101 = 1,
	}
]]
function Treasure:skillDiffNextState()
	if self:isMaxState() == false then 
		local curTable = self:getAddOnSkill();
		local nextTable = self:getAddOnSkill(self:state() + 1);

		local upLvlTable = {};
		local newActivateTable = {};

		for id, level in pairs(nextTable) do
			if curTable[id] == nil or tonumber(curTable[id]) == 0 then 
				newActivateTable[id] = level;
			else 
				if curTable[id] < level then 
					upLvlTable[id] = level - curTable[id];
				end 
			end 
		end
		return upLvlTable, newActivateTable;
	else 
		echo("----------skillDiffNextState max state-----------" 
			.. tostring(self:getId()))
		return false;
	end 

end

--当前等级是否是当前阶段的最大等级
function Treasure:isCurStageMaxLvl()
	return isMaxCurState(self:level(), self:state());
end

--此法宝能达到的最大阶级
function Treasure:getMaxState()
	local maxLvl = FuncTreasure.getValueByKeyTD(self:getId(), "lvLimit");
	return math.floor(maxLvl / 10) + 1;
end

--当前是否是最大阶级
function Treasure:isMaxState()
	local max = self:getMaxState();
	return max <= self:state();
end

------------------精炼相关-----------------------
--是否可以精炼
function Treasure:canRefine()
	if (self:isCurStageMaxLvl() == true) and (self:isMaxPower() == false)
		and (self:isResEnoughToRefine() == true) and self:isEnoughPlayerLvlToRefine() then
		return true;
	else 
		return false;
	end 
end

function Treasure:isResEnoughToRefine()
	local stateId = self:getStateId();
	local needRes = FuncTreasure.getValueByKeyTSD(stateId, "evoM");
	return UserModel:isResEnough(needRes) == true and true or false;
end


function Treasure:isEnoughPlayerLvlToRefine()
	local needLvl = self:refineNeedCharLvl();
	return needLvl <= UserModel:level() and true or false;
end

--需要主角等级
function Treasure:refineNeedCharLvl()
	local stateId = self:getStateId();
	local needLvl = FuncTreasure.getValueByKeyTSD(stateId, "needLv");
	return needLvl;
end

------------------强化相关的方法--------------------
--是否可以一键强化
function Treasure:canQuicklyEnhance()
	local playerLvl = UserModel:level();
	if playerLvl >= 30 and (playerLvl - self:level()) >= 10 then 
		echo("canQuicklyEnhance True")
		return true;
	else 
		echo("canQuicklyEnhance false")

		return false;
	end 
end

--是否可以强化
function Treasure:canEnhance()
	if self:isMaxLvl() == false and self:isResEnoughToEnhance()
		  and self:isCurStageMaxLvl() == false then
		return true;
	else 
		return false;
	end 
end

function Treasure:isMaxLvl()
	local maxLvl = FuncTreasure.getValueByKeyTD(self:getId(), "lvLimit");
	return self:level() >= maxLvl and true or false;
end

--是否强化到满级了
function Treasure:isMaxPower()
	local maxLvl = FuncTreasure.getValueByKeyTD(self:getId(), "lvLimit");

	if self:isCurStageMaxLvl() == false and self:level() >= maxLvl then 
		return true;
	else 
		return false;
	end 
end


function Treasure:isResEnoughToEnhance()
	local id = self:getId();
	local needRes = FuncTreasure.getValueByKeyTULD(id, self:level(), "cost");
	return UserModel:isResEnough(needRes) == true and true or false;
end

--------------------------------------------

function Treasure:getStateId()
	local id = self:getId();
	local stateId = FuncTreasure.getValueByKeyTD(id, "state")[self:state()];
	return stateId;
end

function Treasure:getNeedUpStarFragmentNum()
	return FuncTreasure.getValueByKeyTD(self:getId(), "upStar")[self:star()];
end

function Treasure:getUpStarCoinCost()
	local id = self:getId();

    local star = self:star();
    local coinNeed = FuncTreasure.getValueByKeyTD(id, "starCost")[star];
    return coinNeed;
end

--[[
	这个法宝是要怎么增强，强化 精炼，或是满级了
]]
function Treasure:getStrongType()
	if self:isMaxPower() == true then 
		return Treasure.StrongType.Max;
	elseif self:isCurStageMaxLvl() == true then
		return Treasure.StrongType.Refine;
	else 
		return Treasure.StrongType.Strength;
	end 
end

--[[
获取treasure对应的icon
]]
function Treasure:getIcon( treaId )
	local icon = FuncTreasure.getValueByKeyTD(treaId, "icon")
	return icon
end



return Treasure;





