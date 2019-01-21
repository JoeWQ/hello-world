--
-- Author: XD
-- Date: 2014-07-24 10:44:47
--
ObjectCommon = class("ObjectCommon")


--一些通用的配置  比如 特效 影子  血条 残片 子弹 等的配置

ObjectCommon.prototypeData = {
    id = "600001"
   
}


--实例属性
ObjectCommon.level = 10

--[[
    datas = {
        level = 10, 目前只需要有级别的概念  到后面会扩展
    }
]]
local globalCfg = require("GlobalCfg")
local sourceEx = require("treasure.SourceEx")


--获取静态数据
function ObjectCommon.getPrototypeData( fullFile,id, obj )
    local allData = require(fullFile)
    if not allData then
        echoError("这个模块不存在配置数据,"..tostring(file),id)
    end

    --echo("_____________config",fullFile)
    local fileName = string.split(fullFile,".")
    local len = #fileName
    local encKey = globalCfg[fileName[len]].encKey
    local decKey = globalCfg[fileName[len]].decKey

    local strId = tostring(id)
    local data = allData[strId]
    if not data then
        echoWarn("这个模块不存在这个id数据,id="..tostring(id).."    模块="..fullFile)
    end
    if obj then
        ObjectCommon.mapFunction(data,encKey,decKey,obj)
    end
     -- allData.encKeyMap  allData.decKeyMap

    return data
end


-- 直接字段映射函数。其中 encryptKey 为加密的字段的key表
function ObjectCommon.mapFunction(staticData,encKey,decKey,obj)
    if not obj then -- 还有好多需要改，目前这样是保证程序能运行起来
        return 
    end

    for k,v in pairs(encKey) do
        obj["sta_"..v] = function(_self)
            return numEncrypt:getNum(staticData[v] )
        end
    end

    for k,v in pairs(decKey) do
        obj["sta_"..v] = function(_self)
            return staticData[v]
        end
    end
end


function ObjectCommon:getSourceEx(hid)
    return sourceEx[hid]
end



-- 上阵英雄的属性
function ObjectCommon:getHeroCfg()
    local herodata = require("testConfig.Hero")
    return herodata
end

--获取关卡怪物数据
function ObjectCommon:getLevelEnemys()
    return require("testConfig.Enemy")
end

function ObjectCommon:getServerData()
    local herodata = require("testConfig.ServerData")
    if LoginControler:isLogin() then 
        herodata[1]._id = UserModel:rid()
    end
    return herodata
end


return  ObjectCommon
