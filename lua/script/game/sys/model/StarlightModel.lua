--
-- Author: zpc
-- Date: 2016-01-15 14:38:41
--

-- 星缘

local StarlightModel = class("StarlightModel", BaseModel)

function StarlightModel:init(data)

    StarlightModel.super.init(self, data)
    self.starlights=data or {};
    self._datakeys = {

    }
    self.starLightData = {}
    local _tdata = FuncTreasure.getStarlightData()
    for i, v in pairs(_tdata) do
        table.insert(self.starLightData, v)
    end
    function _compe(a, b)
        return tonumber(a.Order) < tonumber(b.Order)
    end

    table.sort(self.starLightData, _compe)

end
--//获取角色startLights属性
function StarlightModel:getStarlights()
   return  self.starlights;
end
function StarlightModel:updateData(data)
    StarlightModel.super.updateData(self, data)
    -- 通知刷新
    echo("_____________________aa")
    for key,value in pairs(data) do
           self.starlights[key]=value;
    end
    EventControler:dispatchEvent(StarlightEvent.STARLIGHT_EVENT_UPDATE, data)
end
 
function StarlightModel:starLightData()
    return self.starLightData 
end
 
return StarlightModel
