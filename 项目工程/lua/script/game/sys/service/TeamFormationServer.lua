


--[[
阵前站位
基本的网络交互
]]


local TeamFormationServer = class("TeamFormationServer")

function TeamFormationServer:init()

end


--[[
执行上阵操作
]]
function TeamFormationServer:doFormation( params,callBack )
    Server:sendRequest(params, MethodCode.formation_doformation_347, callBack )
end



return TeamFormationServer