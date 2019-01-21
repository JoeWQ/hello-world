--zq

local ChallengeModel = class("ChallengeModel");

ChallengeModel.KEYS = {
    TOWER = "tower",
    TRIAL = "trial",
    PVP = "Pvp",
    DEFENDER = "defender",
}

function ChallengeModel:ctor()

end

function ChallengeModel:init()
    UserModel:cacheUserData();

    EventControler:addEventListener("TIAOZHANHONGDIANSHUAXIN", self.dispatchTZHDEvent, self)  
end

function ChallengeModel:isSystemOpen(typeID)
    local value = FuncChallenge.getOpenLevelByitemId(typeID)
    return UserModel:checkCondition( value )
end

function ChallengeModel:getOpenLevel(typeID)
    local value = FuncChallenge.getOpenLevelByitemId(typeID)
    return value[1].v
end

function ChallengeModel:getDayTimesBySystemId(typeID)
    if typeID == ChallengeModel.KEYS.TOWER then
        return TowerNewModel:getTowerResetLeftCount()
    elseif typeID == ChallengeModel.KEYS.PVP then 
        return FuncPvp.getPvpChallengeLeftCount()
    elseif typeID == ChallengeModel.KEYS.TRIAL then 
        local num = 0
        for i = 1,3 do
            num = num + TrailModel:getTotalCount() - CountModel:getTrialCountTime(i);
        end
        return num
    elseif typeID == ChallengeModel.KEYS.DEFENDER then
        return DefenderModel:getDefenderResetLeftCount()  ---TODO
    end
    
end

function ChallengeModel:getIconsBySystemId(typeID)
    local itemIds = FuncChallenge.getIconByitemId(typeID)
--    local icons = {};
--    for i ,v in pairs(itemIds) do
--        local data = FuncItem.getItemData(v)
--        local _iconData = {
--            _resName,
--            _iconType,
--            _quality,
--        }
--        if data["type"] == 2 then --daoju 
--            _iconData._resName = FuncRes.iconTreasure(data["id"])
--            _iconData._iconType = 2
--            _iconData._quality = data["quality"]
--        else
--            _iconData._iconType = 1
--            _iconData._resName = FuncRes.iconItemWithImage(data["icon"])
--            _iconData._quality = data["quality"]
--        end
--            table.insert(icons,_iconData)
--    end
    return itemIds
end


--ÅÐ¶ÏÊÇ·ñÏÔÊ¾Ö÷³ÇÐ¡ºìµã
function ChallengeModel:checkShowRed(  )
    local num = 0
    num = num + self:getDayTimesBySystemId(ChallengeModel.KEYS.TOWER)
    num = num + self:getDayTimesBySystemId(ChallengeModel.KEYS.TRIAL)
    num = num + self:getDayTimesBySystemId(ChallengeModel.KEYS.PVP)
    if num > 0 then
       return true
    end
    return false
end

function ChallengeModel:dispatchTZHDEvent(  )
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
        {redPointType = HomeModel.REDPOINT.DOWNBTN.PVP, isShow = self:checkShowRed()});
end


return ChallengeModel;





















