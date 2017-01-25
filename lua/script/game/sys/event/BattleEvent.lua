
--英雄系统相关事件
local BattleEvent = {}
--游戏暂停 
BattleEvent.BATTLEEVENT_GAMEPAUSE= "BATTLEEVENT_GAMEPAUSE"
BattleEvent.BATTLEEVENT_SUREQUIT= "BATTLEEVENT_SUREQUIT"
BattleEvent.BATTLEEVENT_REPLAY = "BATTLEEVENT_REPLAY"


--生命值发生改变 参数 float 该变量
BattleEvent.BATTLEEVENT_CHANGEHEALTH = "BATTLEEVENT_CHANGEHEALTH"

-- 改变能量  参数 float  该变量
BattleEvent.BATTLEEVENT_CHANGEENEGRY = "BATTLEEVENT_CHANGEENEGRY"

--威能改变   参数 float  该变量
BattleEvent.BATTLEEVENT_CHANGEPOWER = "BATTLEEVENT_CHANGEPOWER"

--主角最大能量改变
BattleEvent.BATTLEEVENT_MAXENERGYCHANGE = "BATTLEEVENT_MAXENERGYCHANGE"

-- 玩家状态
BattleEvent.BATTLEEVENT_PLAYER_STATE = "BATTLEEVENT_PLAYER_STATE"

--击杀一个英雄,   参数 {kill = enemy(击杀谁), energy = 100(奖励能量)  } 
BattleEvent.BATTLEEVENT_KILLENEMY = "BATTLEEVENT_KILLENEMY"

--英雄初始化完毕之后  ,这个时候需要通知ui 显示更新
BattleEvent.BATTLEEVENT_HEROINITCOMPLETE = "BATTLEEVENT_HEROINITCOMPLETE"

-- 显示名字
BattleEvent.BATTLEEVENT_SHOWNAME = "BATTLEEVENT_SHOWNAME"
 
--显示血条 true 是显示 false是取消显示 params = {camp = 1,visible = false}
BattleEvent.BATTLEEVENT_SHOWHEALTHBAR = "BATTLEEVENT_SHOWHEALTHBAR"

-- 玩家离开事件
BattleEvent.BATTLEEVENT_USER_LEAVE = "BATTLEEVENT_USER_LEAVE"


--战斗领取奖励
BattleEvent.BATTLEEVENT_BATTLE_REWARD = "BATTLEEVENT_BATTLE_REWARD"

--[[
    战斗结果 客户端上报的 参数格式 
    parames.resultInfo = {
        result = 1                --战斗结果    1胜利 2失败 int
        battleStar = 1          --战斗星级   部分系统需要   int
        usedTreasures = {"101","102",...} --使用过的法宝 --针对爬塔系统 可有可无 {treasureHid1,...}
        frame = self.updateCount        --记录结束帧数 必须有
        battleLabel = BattleControler._battleLabel  --战斗标签 必须有
        levelId = "1001"                            --战斗关卡id 必须有
        userInfo  = {userRid:{hp:1,atk:2,... },...  } --玩家信息 战斗结束后 剩余玩家的 血量 防御 攻击力 等参数,用来做服务器校验
		operation = {},                 --操作信息
    }

    这里的数据是 服务器用来复盘或者校验的唯一参考数据入口,
    任何一场战斗都需要有这样的战斗结果数据格式 传递给服务器 然后让服务器校验
    e.params.resultInfo
]]
-- 与其他系统相关消息, 直接返回战斗结果信息 单人战斗结果接受
BattleEvent.BATTLEEVENT_BATTLE_RESULT = "BATTLEEVENT_BATTLE_RESULT"

-- 竞技场第一次逻辑跑结果
BattleEvent.BATTLEEVENT_JJC_LOGIC_PRO = "BATTLEEVENT_JJC_LOGIC_PRO"

-- 重播,战斗回放战报信息结束
BattleEvent.BATTLEEVENT_REPLAY_GAME = "BATTLEEVENT_REPLAY_GAME"

--进入战斗 打开loading界面的时候
BattleEvent.BATTLEEVENT_ONBATTLEENTER= "BATTLEEVENT_ONBATTLEENTER"

--战斗窗口关闭---------  参数 直接返回 BATTLEEVENT_BATTLE_REWARD所带的参数
BattleEvent.BATTLEEVENT_BATTLE_CLOSE = "BATTLEEVENT_BATTLE_CLOSE"

--关闭奖励窗口
BattleEvent.BATTLEEVENT_CLOSE_REWARD = "BATTLEEVENT_CLOSE_REWARD"

--npc头顶对话事件
BattleEvent.BATTLEEVENT_TOPTALK = "BATTLEEVENT_TOPTALK"


--一回合开始 
BattleEvent.BATTLEEVENT_ROUNDSTART = "BATTLEEVENT_ROUNDSTART"
BattleEvent.BATTLEEVENT_ROUNDEND = "BATTLEEVENT_ROUNDEND"   --回合结束

--连击数变化 参数 params = {  count:1,damage: 1 } ,count 是当前连击数,damage是伤害系数 默认是1
BattleEvent.BATTLEEVENT_COMBCHANGE = "BATTLEEVENT_COMBCHANGE"


--当玩家开始攻击了 需要通知ui界面显示 是否可以点击英雄头像了,params = {posIndex = 1,camp = 1},传递的是英雄的posIndex和阵营
BattleEvent.BATTLEEVENT_ONEHEROATTACK = "BATTLEEVENT_ONEHEROATTACK"


--剩余自动战斗时间  以帧为单位 需要自己转化成秒
BattleEvent.BATTLEEVENT_LEFTAUTOTIME = "BATTLEEVENT_LEFTAUTOTIME"

--改变自动战斗状态 需要同步ui显示
BattleEvent.BATTLEEVENT_CHANGEAUTOFIGHT = "BATTLEEVENT_CHANGEAUTOFIGHT"

--法宝变化
BattleEvent.BATTLEEVENT_CHANGETREASURE = "BATTLEEVENT_CHANGETREASURE"

--战斗进入下一波
BattleEvent.BATTLEEVENT_NEXTWAVE = "BATTLEEVENT_NEXTWAVE"


return BattleEvent







