

local arg = {...}
local path = arg[1]
if path then
    package.path = package.path..";"..path.."config/?.lua" ..";" ..path.."asset/?.lua" ..";" ..path .."script/?.lua"
end
  
require("config")

DEBUG_SERVICES = true

   
echo = function (...)
    -- print(...)
end

echoWarn = function ( ... )
    --print("warn:",... )
end

echoError = function (... )
    --print("error:", ...)
end

require("framework.debug")
require("framework.functions")
--require("framework.init")
require("utils.init")



--手动指定一些require
require("game.sys.GameVars")

local packageName = "game.sys.func."
--加载func
local debugServerGroup = {
    "FuncDataResource",
    "FuncDataSetting",
    "FuncRes",
    "FuncChar",
    "FuncBattleBase",
    "FuncPvp",
    "FuncTreasure",
    "GameConfig",
    "FuncTranslate",
    "FuncArmature",
    "FuncMatch",

}
for i,v in ipairs(debugServerGroup) do
    local loadPath = packageName..v
    if not package.loaded[loadPath] then
        require(loadPath)
        local t = _G[v]
        if t and t.init then
            t.init()
        end
    end
end


--加载事件
BattleEvent = require("game.sys.event.BattleEvent")
LoadEvent = require("game.sys.event.LoadEvent")
SystemEvent = require("game.sys.event.SystemEvent")



UserModel = require("game.sys.model.UserModel")
require("game.sys.controler.EventControler")

--加载controler
packageName = "game.sys.controler."
require(packageName .. "EventControler")
BattleControler = require(packageName.."BattleControler")
LoginControler = require(packageName.."LoginControler")


require("game.battle.init")


local json 
local function safeLoad(  )
    json = require("cjson")
end

if not pcall(safeLoad) then
    --说明没有json
    json = nil
end




local projectPath = ""

--[[
    luaFunc 目前保持默认值 pvp.run 不启作用

    data数据格式 
    {
        levelId 战斗关卡id  必须有 由客户端传递
        --battleUsers 战斗用户数据，服务器传递的必须有
        battleUsers = { {玩家A信息.,team =1},{玩家B信息..,team =2},..  }, 
        randomSeed = 100, --随机种子 必须有

        inBattleDrop = {"1,1302,10","1,1303,10"} -- 掉落的物品 可有可无
        
        
        --额外添加 的buff,比如爬塔,需要把这这些buff 在站前添加进去,目前只有爬塔系统有这个属性,复盘时也得附带这个属性
        buffInfo = {buffid1,buffid2,...}

        --如果是战斗回放或者复盘的 需要的信息
        
        battleLabel = "worldGve",  string， 战斗标签.用来接受消息时候的 参数 必须有,没有就报错，一般这个数据是由客户端提交给服务器的，参考battleLabel说明

        operate, 操作信息 ，由客户端提交服务器 
        格式  
        {
            frame:{
                操作信息是  战斗状态 释放法宝  掉线离线 3选1
                rid: {treasureHid:101(string,法宝id),fightState:1(int,战斗状态),online:(int在线状态)}
            }
        }
        
    }

    --额外说明 战斗标签说明
    battleLabels = {
        towerPve = "towerPve",      --爬塔pve
        worldPve = "worldPve",      --传统pve 六界刷关卡寻仙
        worldGve1 = "worldGve1",            --传统gve 六界刷关卡寻仙1
        worldGve2 = "worldGve2",            --传统gve 六界刷关卡寻仙2
        pvp = "pvp",        --传统竞技场
        trailPve = "trailPve" ,     --试炼pve
        trailGve1 = "trailGve1" ,   --山神试炼gve
        trailGve2 = "trailGve2" ,   --火神试炼gve
        trailGve3 = "trailGve3" ,   --雷神试炼gve
        kindGve = "kindGve",        --行侠仗义 

    }


]]

--参数示例是一个json串
--[[
    data
    {"battleLabel":"worldPve","battleUsers":[{"userExt":{"pulseNode":"142"},"userBattleType":1,"avatar":101,"treasures":{"107":{"state":1,"id":107,"star":1,"status":1,"level":1},"205":{"state":1,"id":205,"star":2,"status":1,"level":1},"105":{"state":1,"id":105,"star":1,"status":1,"level":1},"207":{"state":1,"id":207,"star":2,"status":1,"level":1},"101":{"state":1,"id":101,"star":1,"status":1,"level":1},"201":{"state":1,"id":201,"star":2,"status":1,"level":1},"103":{"state":1,"id":103,"star":1,"status":1,"level":2},"203":{"state":1,"id":203,"star":2,"status":1,"level":1},"322":{"state":1,"id":322,"star":3,"status":1,"level":1},"106":{"state":1,"id":106,"star":1,"status":1,"level":1},"206":{"state":1,"id":206,"star":2,"status":1,"level":1},"104":{"state":1,"id":104,"star":1,"status":1,"level":1},"209":{"state":1,"id":209,"star":2,"status":1,"level":1},"210":{"state":1,"id":210,"star":2,"status":1,"level":1},"202":{"state":1,"id":202,"star":2,"status":1,"level":1},"102":{"state":1,"id":102,"star":1,"status":1,"level":10}},"state":1,"starLights":{},"name":"","sec":"dev","team":1,"level":51,"_id":"dev_1405","states":{"1":{"advId":0,"status":0,"id":1}}}],"randomSeed":400714644,"levelId":"10405","inBattleDrop":["1,1001,5","1,2001,9","1,3001,50"],"charRid":"dev_1405"}

]]





--[[
    返回结果  理论上和客户端正常战斗返回的结果一样 只多了 costTime和 errorInfo2个属性
    {
        
        result = 1                --战斗结果    1胜利 2失败 int
        battleStar = 1          --战斗星级   部分系统需要   int
        usedTreasures = {"101","102",...} --使用过的法宝 --针对爬塔系统 可有可无 {treasureHid1,...}
        frame = self.updateCount        --记录结束帧数 必须有
        battleLabel = BattleControler._battleLabel  --战斗标签 必须有
        levelId = "1001"                            --战斗关卡id 必须有
        userInfo  = {userRid:{hp:1,atk:2,... },...  } --玩家信息 战斗结束后 剩余玩家的 血量 防御 攻击力 等参数,用来做服务器校验
        operation = {},                 --操作信息
        --错误信息  
        --错误码 
        101 战斗数据没有传递battleLabel
        102 战斗数据没有配置levelId
        103 战斗数据没有配置 battleUsers
        104 战斗数据没有配置 随机种子 randomSeed
        errorInfo = {
            {code:101，message:"battle data not config battleLabel"}，...

        }
        costTime =  0.2 ，跑战斗逻辑耗时多少秒，保留3位小数
    }

]]

--[[

    
    战斗结果 客户端上报的 参数格式 
    resultInfo = {
        result = 1                --战斗结果    1胜利 2失败 int
        battleStar = 1          --战斗星级   部分系统需要   int
        usedTreasures = {"101","102",...} --使用过的法宝 --针对爬塔系统 可有可无 {treasureHid1,...}
        frame = self.updateCount        --记录结束帧数 必须有
        battleLabel = BattleControler._battleLabel  --战斗标签 必须有
        levelId = "1001"                            --战斗关卡id 必须有
        userInfo  = {userRid:{hp:1,atk:2,... },...  } --玩家信息 战斗结束后 剩余玩家的 血量 防御 攻击力 等参数,用来做服务器校验
        operation = {},         --操作信息

    }

    这里的数据是 服务器用来复盘或者校验的唯一参考数据入口,
    任何一场战斗都需要有这样的战斗结果数据格式 传递给服务器 然后让服务器校验
]]



function run( luaFunc,data )

    if json and data then
       data = json.decode(data)
    end
    
    Fight.dum_frame_num = 1000000
    Fight.isDummy = true
    Fight.game_statistic=false

    local battleInfo = { }
    if not data then

    else
        if type(data) == "table" then
            battleInfo = data
        end
    end

    local errorInfo = {}
    local errorStr  = ""

    if not battleInfo.battleLabel then
        errorStr = errorStr .."   not config battleLabel \n "
        battleInfo.battleLabel = "worldPve"
        table.insert(errorInfo, {code = 101,message = "battle data not config battleLabel"})
    end

    if not battleInfo.levelId then
        errorStr = errorStr .."not config levelId \n  "
        table.insert(errorInfo, {code = 102,message = "not config levelId"})
    end

    if not battleInfo.battleUsers then
        errorStr = errorStr .."not config battleUsers\n  "
        table.insert(errorInfo, {code = 103,message = "battle data not config battleUsers"})
        battleInfo.battleUsers = { }
        local defaultHero = ObjectCommon:getServerData()
        for i = 1, #defaultHero do
            table.insert(battleInfo.battleUsers, defaultHero[i])
        end
    end

    if not battleInfo.randomSeed then
        errorStr = errorStr .."not config randomSeed\n  "
        table.insert(errorInfo, {code = 104,message = "battle data not config randomSeed"})
        battleInfo.randomSeed = 100
    end

    
    
    -- local encInfo = numEncrypt:encodeObject( battleInfo )
    -- BattleControler:startPVP(encInfo)

    local t1 = os.clock()
    BattleControler:startBattleInfo(battleInfo)
    local battleResultData = BattleControler:getBattleDatas()
    local costTime = os.clock() - t1
    battleResultData.costTime = costTime
    battleResultData.errorInfo = errorInfo
    print("costTime:",costTime)
    print("gameResult:",battleResultData.result)
    print("overFrame:",battleResultData.frame)
    print("errorStr:",errorStr)
    -- dump(battleResultData,"battleResultData")
    if json then
        return json.encode( battleResultData )
    end
    return battleResultData 
    
end

if not json then
    run()
end

