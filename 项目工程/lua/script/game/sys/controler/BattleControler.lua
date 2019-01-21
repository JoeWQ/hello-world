--
-- Author: xd
-- Date: 2016-01-09 11:28:10

local BattleControler = BattleControler or {}
BattleControler.__poolType = nil
BattleControler.__levelHid = nil
BattleControler.__gameMode = nil
BattleControler.gameControler = nil
BattleControler.levelInfo = nil
BattleControler.__gameResult = nil

--[[
    battleInfo  
    {
        levelId 战斗关卡id  战斗回放需要配这个参数
        battleUsers = { {玩家A信息.,team =1},{玩家B信息..,team =2},..  }, -- team 是必须有的字段,可以为1或者2,可以都为 1
        randomSeed = 100,
        inBattleDrop = {"1,1302,10","1,1303,10"} -- 掉落的物品
        battleLabel = "worldGve", 战斗标签.用来接受消息时候的 参数 必须有,没有就报错

        --额外添加 的buff,比如爬塔,需要把这这些buff 在站前添加进去,目前只有爬塔系统有这个属性
        buffInfo = {buffid1,buffid2,...}
        
        --加法宝额外威能信息,是一个table,num表示按数值增加多少,per表示按百分比增加多少 ,目前是爬塔有这个需求
        powerInfo = {num =120,per = 50}
    
        --阵型
        fromation = {
            parte:    
        }


        --如果是战斗回放或者复盘的 需要的信息
        
        operation, 操作信息 格式 
        {
            frame:{
                操作信息是  战斗状态 释放法宝  掉线离线 3选1
                rid: {treasureHid:101(string,法宝id),fightState:1(int,战斗状态),online:(int在线状态)}
            }
        }
        replayGame  2表示是回放,空或者0表示非回放
        
    }
]]

--直接根据数据开启游戏
function BattleControler:startBattleInfo( battleInfo )
    local label = battleInfo.battleLabel
    if label ==GameVars.battleLabels.towerPve or  label ==GameVars.battleLabels.worldPve or 
        label ==GameVars.battleLabels.trailPve or label ==GameVars.battleLabels.trailPve2 or
        label ==GameVars.battleLabels.trailPve3 then
       
        self:startPVE(battleInfo)
    elseif label ==GameVars.battleLabels.worldGve1 or label ==GameVars.battleLabels.worldGve2 or 
        label ==GameVars.battleLabels.trailGve1 or label ==GameVars.battleLabels.trailGve2 or 
        label ==GameVars.battleLabels.trailGve3 or label ==GameVars.battleLabels.kindGve

        then
        --组队gve
        self:startGVE(battleInfo)

    --传统竞技场
    elseif label ==GameVars.battleLabels.pvp  then
        self:startPVP(battleInfo)
    else
        echoWarn("wrong battleLabel:",label)
    end

end


function BattleControler:startPVP(battleInfo)
    --dump(battleInfo)
    self.__gameMode = Fight.gameMode_pvp
    self:setCampData(Fight.gameMode_pvp,battleInfo )
end


--副本关卡
function BattleControler:startPVE(battleInfo)
    --dump(battleInfo)
    self.__gameMode = Fight.gameMode_pve
    self:setCampData(Fight.gameMode_pve,battleInfo )
end



-- GVE(匹配进入的接口)
function BattleControler:startGVE(battleInfo)
     -- poolType,只有匹配时候才会用到,单人战斗不会用到
    self.__poolType = battleInfo.poolType
    --LogsControler:writeDumpToFile("BattleControler:startGVE()开始战斗 battleInfo")
    --LogsControler:writeDumpToFile(battleInfo)
    -- 多人匹配不会首先设置levelId,通过poolType获取levelId
    self.__levelHid = FuncMatch.getBattleLevelId( self.__poolType ) 
  
    self.__gameMode = Fight.gameMode_gve
    self:setCampData(Fight.gameMode_gve,battleInfo )
end


-- 回放
function BattleControler:replayLastGame(battleInfo,skilClearView)
    --dump(battleInfo)
    -- 目前先用PVP做例子
    --如果有controler
    if self.gameControler then
        self.gameControler:deleteMe()
        self.gameControler = nil
    end
    battleInfo.replayGame = 2
    self.__gameMode = battleInfo.gameMode
    self:setCampData(Fight.gameMode_pvp,battleInfo, skilClearView)
end

-- 重放
function BattleControler:replayCurGame(  )
    if self.gameControler then
        self.gameControler:gameReplay()
    end
end

--[[
hid level表中的关卡表示
sigleFlag 1 单人，sigleFlag 2 多人
]]
function BattleControler:setLevelId(hid,sigleFlag)
    self.__levelHid = hid
    --local loadId = FuncLoading.getLoadingId(hid)
    --如果是loading界面 那么不加载loading
    if Fight and Fight.isDummy then
        return
    end
    self:setLoadingId(hid,1)
end


--[[
loadId  levelId
sigleFlag == 1表示单人
sigleFlag == 2表示多人
]]
function BattleControler:setLoadingId(loadId,sigleFlag)
    -- if self._gameMode == Fight.gameMode_pvp then
    --     return
    -- end
    BattleLoadingControler:showBattleLoadingView(loadingId,sigleFlag)
end


function BattleControler:getLevelId()
    return self.__levelHid
end


function BattleControler:reConnectBattle(battleId,poolType)
    echo("___________________重连进入战斗_",battleId,poolType)

    self.__poolType = poolType

    GameLuaLoader:loadGameBattleInit()
    BattleServer:quitBattle(battleId)
end


-- 获得poolType
function BattleControler:getPoolType()
    return self.__poolType
end

function BattleControler:getPoolSystem()
    if self.__poolType then 
        return FuncMatch.getPoolSystem(self.__poolType)
    end
    return nil
end



-- 掉落排序
local function funDropOrder( item1,item2 )
    if item1[5] < item1[5] then
        return true
    end
    return false
end

-- 整理掉落信息
function BattleControler:checkBattleDrop(drop)
    local dropArr = {}
    for i=1,#drop do
        local tmpTb = {}
        tmpTb = string.split(drop[i],",")
        tmpTb[3] = tonumber(tmpTb[3])
        tmpTb[4] = 0
        tmpTb[5] = FuncItem.getItemPropByKey(tmpTb[2],"drop")
        if tmpTb[1] == "1" then
            table.insert(dropArr,tmpTb)
        else
            echo("______传来的掉落物品是非物品")
            dump(tmpTb)
        end
    end
    -- 排序
    table.sort(dropArr,funDropOrder)
    return dropArr
end



--[[
   battleInfo = {
        campArr_1 = { {{
                    rid="a", hid = "10001",armature = "taiyihongluan",lv = 1, energy=0,maxenergy=5,manaR=1,hp =100,maxhp =100,atk =20,def = 1,crit = 1,resist = 1,hit=10,dodge=0,critR=0,
                    treasure =  {
                                    {hid="101",state = 1,star = 1,strengthen = 2},
                                }, 
                },}          }
        campArr_2,
        randomseed,
    }
]]

-- 计算英雄的属性,并复制默认属性
function BattleControler:setDefaultAttr(mode,hero,battleLabel)
    --dump(hero)
    local avatar = tonumber(hero.avatar) or 101
    hero.hid   = tostring(avatar)
    hero.treasures[tostring(avatar-100)] = {
                    level       = 1,
                    star        = 1,
                    state       = 1,
                    status      = 1,
                    treaType = "base", -- 出场时带的法宝
                }
    
    battleLabel = battleLabel or self.battleLabel

    local tmp = FuncBattleBase.createBattleData( hero, hero.treasures, battleLabel)


    if Fight.all_high_hp then

        tmp.hp = 1000000
        tmp.maxhp = 1000000
    end

    return tmp
end


--- 解析掉落信息 1为类型,2掉落物品id 3 数目 4位0  5读取drop属性进行排序
--local encDefault = numEncrypt:encodeObject( defaultData )
function BattleControler:checkTeam(mode,battleInfo)
    -- 战斗数据
    local gameData = {
        camp1 = {},
        camp2 = {},
        waveData = {},        
        gameMode = mode,
        randomSeed = battleInfo.randomSeed,
        levelId = battleInfo.levelId,
    }


    -- 首先解析服务器传过来的数据
    -- for i,v in pairs(battleInfo.battleUsers) do        
    --     local tmp = self:setDefaultAttr(mode,v,battleInfo.battleLabel)
    --     if tmp.camp == 1 then
    --         table.insert(gameData.camp1, tmp)
    --     else
    --         table.insert(gameData.camp2, tmp)
    --     end
    -- end

    -- 战斗前加的buff
    -- if battleInfo.buffInfo then
    --     gameData.buffInfo = battleInfo.buffInfo
    -- end

    -- 关卡
    local levelObj = ObjectLevel.new( self.__levelHid,gameData )
    levelObj.randomSeed = battleInfo.randomSeed
    --计算掉落
    if battleInfo.inBattleDrop then 
        levelObj.dropArr = self:checkBattleDrop(battleInfo.inBattleDrop)
    end

     -- 因为levelObj 加密不了,所有直接赋值过去
    self.gameControler:initGameData(levelObj)

    --这里是pvp  在ObjectLevel对象中已经设置了相应的值
    if mode == Fight.gameMode_pve or mode == Fight.gameMode_gve then -- 单人推本
        -- 战斗中主角
        levelObj.userRid = UserModel:rid()
    end

    --dump(gameData.camp1)

    return gameData
end



--[[
]]
function BattleControler:setCampData(mode, battleInfo, skipClearView )

    if not battleInfo.charRid  then
        battleInfo.charRid = UserModel:rid()
    end
    local randomInzi = 100 --os.time()%10000
    
    local battleLabels = battleInfo.battleLabel
    --echo("战斗类型-----------",battleLabels,"===========================")
    --假定战斗模式 为  pve 
    --battleLabels = GameVars.battleLabels.worldPve
    

    BattleRandomControl.setOneRandomYinzi(randomInzi,10)
    -- echo(randomInzi)
    local info,op = nil,nil
    if Fight.use_operate_info then
        battleInfo= GameStatistics:getLogsBattleInfo( Fight.statistic_file )
        if battleInfo.levelId then
            self.__levelHid = battleInfo.levelId
        end
    end

    -- 战报统计
    if Fight.game_statistic and not Fight.use_operate_info then
        GameStatistics:init()
        
        -- 直接将levelId 存入
        if not battleInfo.levelId then
            battleInfo.levelId = self.__levelHid
        end

        GameStatistics:saveBattleInfo(battleInfo)
    end

    if not Fight.isDummy then
        --进入战斗之前移除没有使用的texture
        WindowControler:clearUnusedTexture()
    end

    --进入战斗
    self:onEnterBattle()
   
   --这个暂时注释掉  使用pve来模拟pvp
    -- if mode ==Fight.gameMode_pvp then
    --     self.__levelHid = "103"
    -- end

    --@测试
    if not self.__levelHid then        
        if battleInfo.levelId then
            self:setLevelId(battleInfo.levelId)
        else
            self.__levelHid = Fight.default_level_id 
            echo("___________没有设置levelId,默认为",mode,self.__levelHid)
        end
    end
    --判断是否有操作
    if battleInfo.operation then
        self.gameControler.logical.operationMap = battleInfo.operation
    end

    --如果是回放的
    if battleInfo.replayGame then
        echo("___-回放战斗----------是")
        self.gameControler.replayGame = 2
    end
    battleInfo.randomSeed = 100

    echo("__________________到底是哪一个关卡",self.__levelHid,battleInfo.randomSeed)
    if not battleInfo.battleLabel then
        echoError("这个战斗没有传入battleLabel:",mode)
        battleInfo.battleLabel = GameVars.battleLabels.worldPve
        -- return
    end
    
    self:checkTeam(mode,battleInfo)

    self.battleLabel = battleInfo.battleLabel

    if not battleInfo.fromation then
        if LoginControler:isLogin() then
            --battleInfo.formation = TeamFormationModel:getCurFormation(battleLabels)
            -- echo("站前保存的阵容数据--------")
            -- dump(TeamFormationModel:getCurFormation(battleLabels))
            -- echo("站前保存的阵容数据--------")
            local formation = TeamFormationModel:getCurFormation(battleLabels)
            battleInfo.formation = {}
            for k,v in pairs(formation) do
                battleInfo.formation[k] = {}
                if tostring(v) ~= "0" then 
                     if tostring(v) == "1" then
                        --主角  非主角
                        battleInfo.formation[k] = {hid = v,lv =UserModel:level(),exp = UserModel:exp() }
                     else
                        --非主角
                        local partnerData = PartnerModel:getPartnerDataById(v)
                        battleInfo.formation[k] = {hid = v,lv =partnerData.level,exp=partnerData.exp }
                     end
                else
                    battleInfo.formation[k] = v
                end
               
            end
        else
            battleInfo.formation = {}
        end
        
    end

    -- echo("当前的战斗信息================")
    -- dump(battleInfo)
    -- echo("当前的战斗信息================")

    self._battleInfo = battleInfo

    local onClearCompelet = function (  )
        self.gameControler:checkLoadTexture()
    end
    
    if not Fight.isDummy then
        if not skipClearView  then
            WindowControler:onEnterBattle(onClearCompelet)
        else
            onClearCompelet()
        end
        
    else
        onClearCompelet()
    end

    return self.gameControler
end


-- 创建gameControler 通过战斗类型
function BattleControler:createGameControler(root)
    if self.__gameMode == Fight.gameMode_pve then
        self.gameControler =  GameControlerPVE.new(root)
    elseif self.__gameMode == Fight.gameMode_gve then
        self.gameControler =  GameControlerGVE.new(root)
    elseif self.__gameMode == Fight.gameMode_pvp then
        self.gameControler =  GameControlerPVP.new(root)
    end
    --初始化统计
    StatisticsControler:init(self.gameControler)
end

--进入游戏
function BattleControler:onEnterBattle(  )


    if  DEBUG_SERVICES  then
        self:createGameControler(nil)
    else

        EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_ONBATTLEENTER)
        local scene = WindowControler:getCurrScene()
        local battleRoot = scene:getBattleRoot()
        scene:showBattleRoot()
        
        
        self:createGameControler(battleRoot)      

        --显示root    
        
         AudioModel:playMusic(MusicConfig.m_scene_battle, true)
    end
    
end

--游戏退出 
function BattleControler:onExitBattle(  )
    echo("___________战斗退出, onExitBattle")
    local poolType = self.gameControler.__poolType
    -- 告诉分系统奖励界面关闭
    -- EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,self.gameControler.__poolType)
    if not Fight.isDummy then

        --存储战报
        if not self._battleInfo.replayGame then
            self._battleInfo.replayGame = true
            self._battleInfo.operation = self.gameControler.logical.operationMap
            echo("保存战斗信息")
            GameStatistics:saveBattleInfo(self._battleInfo)

        end


        WindowControler:clearUnusedTexture(  )


        local onLoadingEndFunc = function (  )
             
             if not Fight.isDummy then
                --ui复原完成
                 WindowControler:onResumeComplete()
             end

             if self.gameControler then
                self.gameControler:deleteMe()
                self.gameControler = nil
             end

            local scene = WindowControler:getCurrScene()  
            EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,poolType)
            scene:showRoot()
            -- WindowControler:showWindow("HomeMainView")
            --播放主界面音乐
            -- AudioModel:playMusic(MusicConfig.m_scene_main, true)
        end

        --显示主界面
        local processActions = WindowControler:onExitBattle()
        -- onLoadingEndFunc()
        if #processActions ==0 then
            onLoadingEndFunc()
        else
            WindowControler:showTopWindow("CompLoading", {percent=10,frame =10}, processActions, onLoadingEndFunc)
        end        
    end
    
    self.__levelHid = nil
    self.__gameMode = nil

    self.__gameResult = nil
    
    self.__poolType = nil
end


-- 判断是否在战斗中
function BattleControler:isInBattle()
    if self.gameControler then
        return true
    else
        return false
    end
end

--获取当前的战斗标签
function BattleControler:getBattleLabel(  )
    return self.battleLabel
end

--获取战斗结果
function BattleControler:getBattleDatas(  )
    local battleInfo = {
        --结束帧数
        result = self.gameControler._gameResult,
        operation = self.gameControler.logical.operationMap,
        battleStar = self.gameControler._battleStar,
        battleLabel = self.battleLabel,
        levelId = self.__levelHid,
        userInfo = {}
    }

    local userInfo = battleInfo.userInfo
    local attr = {"hp","manaR", "atk","energy","def","crit","resist","hit","critR","dodge"}

    for i,v in ipairs(self.gameControler.campArr_1) do
        if v.data:peopleType() < Fight.people_type_summon then
            userInfo[v.data.rid]  ={}
           for ii,vv in ipairs(attr) do
                --动态获取属性
                userInfo[v.data.rid][vv] = v.data[vv](v.data)
            end 
        end
    end
    
    --玩家信息
    --dump(battleInfo,"___userInfo")

    return battleInfo
end

-- 可能会提前收到战斗结束的消息
function BattleControler:recvGameResult( params )
    self.__gameResult = true
end

function BattleControler:setIsUpgrade( value )
    self._isUpGrade = value
end

function BattleControler:isMulBattle(  )
    if self.battleLabel ==GameVars.battleLabels.towerPve or 
        self.battleLabel ==GameVars.battleLabels.trailPve or 
        self.battleLabel ==GameVars.battleLabels.worldPve 
     then
        return false
    end
    return true
end


--[[
    --此接口是 通知游戏打开战斗结束界面 
    战斗结束界面关闭以后 会发送一个 游戏关闭的 消息
    BattleEvent.BATTLEEVENT_BATTLE_CLOSE,不会附带参数 因为结果 分系统自己知道
    参数说明
    {
        inBattleDrop = {"1,101,1","3,100" } --战斗奖励数据   奖励掉落数据
        reward = {"1,101,1","3,100" }, 通用奖励格式 数组  如果为空  表示没奖励 
        result = 1,  战斗结果  1表示胜利 2表示失败
        star = 1,       星级 pvp  pve需要这个值
        addExp = 10,      加了多少经验 默认为0 消耗体力的副本需要传这个值
        preExp = 30,    --升级之前的经验值
        preLv  = 10,     --升级之前的等级
        
        heroAddExp = 30,

        

        damages=
        {
            camp1 = 
            {
                [1]={
                    hid = "5001",
                    damage = 100,
                    name = "张三",
                    star = 1,
                    lv = 10,
                    preLv = 9,
                    addExp = 100,
                    preExp = 1000,
                    quality = 1,
                    maxExp = 10000,
                    isMainHero = true     --可空  空 表示 不是主角
                },
                ...
            },
            camp2 = {
                 [2] = {
                    hid = "5001",
                    damage = 100,
                    icon = "lixiaoyao"     --这个可不要，可以从配置表中读取
                    star = 1,
                    lv = 10,
                    addExp = 100,
                    preExp = 1000,
                    maxExp = 10000,
                    quality = 1,
                    isMainHero = true,

                },
                ...
            }
        },        
        }
        
    }
]]

function BattleControler:showReward( battleResultData)
    -- echo("_____battleResultData_______")
    -- dump(battleResultData)
    -- echo("_____battleResultData_______")
    

    -- echo("self._battleInfo==================================")
    -- dump(self._battleInfo)
    -- echo("self._battleInfo==================================")

    -- local times = WorldModel:getDropTimes()
    -- echo("翻倍次数------",times)
    -- local open,actTaskId = WorldModel:isOpenDropActivity()
    -- echo("活动是否开启，",open,"活动id",actTaskId,"===========")
    
    -- echoError("------------------------------")

    if self._battleInfo.replayGame == 2 then
        FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
        return
    end


    if self.__gameMode == Fight.gameMode_pvp then
        --echo("是否------------------------------")
        local pvpResult = {}
        pvpResult.result = battleResultData.result
        pvpResult.battleLabels =self._battleInfo.battleLabel
        pvpResult.historyRank =  PVPModel:getHistoryTopRank()
        pvpResult.userRank = self._battleInfo.userRank or 0
        EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_BATTLE_REWARD, pvpResult )
        return
    end


    local addExp = battleResultData.heroAddExp
    battleResultData.gameMode = self.__gameMode
    battleResultData.addExp = battleResultData.addExp or 0
    battleResultData.preExp = battleResultData.preExp or 0
    battleResultData.preLv  = battleResultData.preLv  or UserModel:level()
    battleResultData.star   = battleResultData.star   or -1
    battleResultData.lv = UserModel:level()
    battleResultData.battleLabels = self.battleLabel

    
    --self._battleInfo
    --如果是pve   并且已经登录的情况下
    if self.battleLabel == GameVars.battleLabels.worldPve and LoginControler:isLogin() then
        battleResultData.damages = {}
        battleResultData.damages.camp1 = {}
        --遍历infomation  拿对应伙伴的当前经验去构造数据

        -- echo("战斗BattleInfo=============")
        -- dump(self._battleInfo)
        -- echo("战斗BattleInfo=============")


        local formation = self._battleInfo.formation
        for k,v in pairs(formation) do
            local hid = v.hid
            if tostring(v) ~= "0" then
                local npcData = {}
                npcData.hid = hid
                npcData.damage = 100
                if tostring(hid) == "1" then
                    npcData.name = UserModel:name()
                    npcData.star =  1
                    npcData.lv = UserModel:level()
                    npcData.preLv = v.lv
                    npcData.quality = UserModel:quality()
                    npcData.maxExp = 100
                    npcData.isMainHero = true
                    npcData.addExp = addExp
                    npcData.preExp = v.exp
                else
                    local data = PartnerModel:getPartnerDataById(hid)
                    local npcCfg = FuncPartner.getPartnerById(hid)
                    local maxExp = FuncPartner.getMaxExp( hid,data.level )

                    npcData.name = GameConfig.getLanguage(npcCfg.name)
                    npcData.star = data.star
                    npcData.lv = data.level
                    npcData.preLv = v.lv
                    npcData.quality = data.quality
                    npcData.maxExp = maxExp
                    npcData.icon = npcCfg.icon
                    npcData.isMainHero = false
                    npcData.addExp = addExp
                    npcData.exp = data.exp
                    npcData.preExp = v.exp
                end
                table.insert(battleResultData.damages.camp1 , npcData)

            end
        end
        battleResultData.damages.camp2 = {}

        --这里使用假数据
        battleResultData.damages.camp2 = battleResultData.damages.camp1

    end



    EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_BATTLE_REWARD, battleResultData )

    
    
end





return BattleControler