
Fight= Fight and Fight or {}

Fight.gameStep={
    load = 1,
    wait = 2,
    prepare =3,
    surprised = 4,
    move = 5,
    meet = 6,
    battle = 7,
    result = 8,
}

Fight.cameraWay = -1


Fight.result_none = 0       --还没出结果
Fight.result_win = 1        --胜利 
Fight.result_lose = 2       --失败
--视图相关参数
--x轴的缩放系数
Fight.screenScaleX = 1 --GameVars.width/GAMEWIDTH 

-- 打击点的位置
Fight.hit_position = 1/2

--初始化动画播放速度
Fight.armaturePlayerSpeed = ARMATURERATE/60 
Fight.armatureUpdateScale = 1/ ARMATURERATE  

--帧率时间
Fight.frame_time = Fight.armatureUpdateScale

Fight.moveMinSpeed = 20
Fight.moveFrame = 20
Fight.attackKeepDistance = 100  --攻击保持距离

Fight.enterSpeed = 20       --入场速度

Fight.initYpos_1 = 340      --第一条线的位置
Fight.initYpos_2 = 500      --第二条线的位置
Fight.initYpos_3 = 420          -- 中间线
Fight.initYpos1Scale = 0.9  --在最里面的人的scale 是0.8

--计算视图的斜率
Fight.initScaleSlope = (Fight.initYpos_2 - Fight.initYpos_1 ) /(1-Fight.initYpos1Scale)
Fight.wholeScale = 1.3    --整体的缩放 
Fight.moveType_g = 2 -- 重力加速度


Fight.attackSignFrame = 15  --第一次集火等待时间

Fight.radian_angle = 180/math.pi    -- 角度计算


Fight.position_xdistance = 125  --站位  x的间隔
Fight.position_middleDistance = 150     --第一个人离中线距离
--当屏幕宽度小于1024的时候  这个offset变成50 尽量让出边的距离少些
Fight.position_offset = 60

--排队离中线的位置
Fight.position_queneDistance = 180
Fight.zorder_front = 200    --最上层的zorder 偏移
Fight.zorder_blackScreen = 800  --黑屏图层
Fight.zorder_blackChar = 1200       --黑屏时人物的zorder


--状态
Fight.state_show_yuyin = 1 -- 语音
Fight.state_show_zhengchang = 2 --正常
Fight.state_show_jingyin = 3 --静音
Fight.state_show_zidong = 4 -- 自动
Fight.state_show_lixian = 5 -- 离线(暂离)
Fight.state_show_yongli = 6 --永离

Fight.diedType_disappear = 0    --直接死亡
Fight.diedType_alpha = 1        --透明度闪现下降死亡 
Fight.diedType_alphades = 2     --透明度下降死亡

--自动战斗帧数 回合前是 20秒 回合中是10秒
Fight.autoFightFrame1 = 50* GAMEFRAMERATE 
Fight.autoFightFrame2 = 50* GAMEFRAMERATE 
Fight.combHandleFrame = 2 * GAMEFRAMERATE   --连击操作时间

--出场方式
Fight.enterType_stand = 0   --原地出现
Fight.enterType_runIn = 1  --跑进来
Fight.enterType_summon = 2  --召唤
--最大40回合
Fight.maxRound = 40


Fight.killEnemyFrame= 30        --杀敌后的延时帧

--===========================================================================================
--                     game 
--===========================================================================================

--攻击能量恢复
Fight.atkEnergyResume = 200
Fight.waveEnergyResume = 100

--拿人头 奖励怒气
Fight.killEnergyResume = 200

--最多技能数量是 8 个 1-3
Fight.maxSkillNums = 8

Fight.skillIndex_normal = 1
Fight.skillIndex_small = 2
Fight.skillIndex_max = 3

-- 战斗模式
Fight.gameMode_pve = 1
Fight.gameMode_gve = 2
Fight.gameMode_pvp = 3
Fight.gameMode_gvg = 4

-- 类型
Fight.modelType_heroes = 1 -- 英雄
Fight.modelType_missle = 2 -- 子弹
Fight.modelType_effect =3  -- 特效
Fight.modelType_shade = 4 -- 影子
Fight.modelType_piece = 5 -- 残片
Fight.modelType_treasure = 6 -- 法宝
Fight.modelType_drop = 7 -- 掉落


-- 战斗人的类型
Fight.people_type_common = 1    -- 玩家
Fight.people_type_robot = 2     -- 机器人(策划配置数据) 智能AI
Fight.people_type_system = 3    -- 被邀请的玩家
Fight.people_type_rescue = 4    -- 行侠仗义玩家
Fight.people_type_watcher = 5   -- 观看玩家
Fight.people_type_robot_user = 6 -- 未在线玩家数据     智能AI

Fight.people_type_summon = 10   -- 召唤物
Fight.people_type_monster = 11  -- 小怪
Fight.people_type_boss = 12     -- boss
Fight.people_type_npc = 13      -- npc


-- AI 模式
Fight.fightState_handle = 1 -- 手动
Fight.fightState_auto   = 2 -- 自动
Fight.fightState_zanli  = 3 -- 暂离
Fight.fightState_smart  = 4 -- 智能AI
Fight.fightState_boss   = 5 -- boss AI




Fight.levelWin_killAll =  1     -- 全部击杀
Fight.levelWin_timeLimit = 2    -- 达到规定时间
Fight.levelWin_killSpec = 3     -- 杀死特定的怪物

--时机:1表示我方回合前,2表示我攻击前,3表示我攻击后,4表示我方回合后,5表示敌方回合前,
--6表示我受击时,  7表示敌方回合后,8代表属性变化时判定,  9表示按照角色选择枚举死亡时判定
--0表示立刻
Fight.chance_justNow = 0
Fight.chance_roundStart = 1
Fight.chance_atkStart = 2
Fight.chance_atkend = 3
Fight.chance_roundEnd = 4
Fight.chance_toStart = 5
Fight.chance_defStart = 6
Fight.chance_toEnd = 7
Fight.chance_propChange = 8
Fight.chance_onDied = 9

--===========================================================================================
--                     treasure
--===========================================================================================
--默认的基础法宝
Fight.treasureKind_base = 1 
--攻击类的法宝
Fight.treasureKind_attack = 2
--防御类的法宝 
Fight.treasureKind_defence = 3 


Fight.treasureLabel_a = "a"
Fight.treasureLabel_b = "b"

--===========================================================================================
--                     action
--===========================================================================================

--记录人物运动状态
Fight.state_stand= "stand"
Fight.state_move= "move"
Fight.state_jump= "jump"

--动作标签
-- Fight.actions.action_stand = "stand"
-- Fight.actions.action_run = "run"
-- Fight.actions.action_race2 = "race2"    --小技能运动
-- Fight.actions.action_race3 = "race3"    --大招运动
-- Fight.actions.action_attack1= "attack1"
-- Fight.actions.action_attack2= "attack2"
-- Fight.actions.action_attack3= "attack3"
-- Fight.actions.action_blow1= "blow1"
-- Fight.actions.action_blow2= "blow2"
-- Fight.actions.action_blow3= "blow3"
-- Fight.actions.action_win= "win"
-- Fight.actions.action_die= "die"
-- Fight.actions.action_hit= "hit"
-- Fight.actions.action_walk= "walk"
-- Fight.actions.action_giveOutA = "giveOutA"   --祭出A法宝   
-- Fight.actions.action_treaOver = "treaOver" --法宝崩溃

-- Fight.actions.action_treaOn2 = "treaOn2" --小技能出场
-- Fight.actions.action_treaOn3 = "treaOn3" --大招技能出场
-- Fight.actions.action_block = "block"        --格挡


Fight.actions = {
    action_stand = "stand",
    action_stand2 = "stand2",   --防守状态的站立

    action_readyStart = "readyStart", --攻击准备开始
    action_readyLoop = "readyLoop", --攻击准备循环

    action_standSkillStart = "standSkillStart",     --大招待机
    action_standSkillLoop = "standSkillLoop",     --大招待机循环


    action_run = "run",
    action_race2 = "race2",
    action_race3 = "race3" ,
    action_attack1= "attack1",
    action_attack2= "attack2",
    action_attack3= "attack3",
    action_blow1= "blow1",
    action_blow2= "blow2",
    action_blow3= "blow3",
    action_win= "win",
    action_die= "die",
    action_hit= "hit",
    action_walk= "walk",
    action_treaOver = "treaOver",
    action_treaOn = "treaOn",       --法宝上身
    action_treaOn2 = "treaOn2",        --小技能上身
    action_treaOn3 = "treaOn3",         --大招上身
    action_giveOutBS = "giveOutBS",     --祭出B开始
    action_giveOutBM = "giveOutBM",     --祭出B循环
    action_giveOutBE = "giveOutBE",     --祭出B结束

    action_inAction = "inAction",     --登场



    action_original = "original" ,      --素颜法宝恢复
    action_block = "block",             --格挡
    action_relive = "relive",           --复活

    action_powerup = "powerup" ,        --击杀播放powerup
}

--===========================================================================================
--                     treasure 
--===========================================================================================

Fight.treasureKind_base = 1 --默认法宝
Fight.treasureKind_attack = 2 --A攻击法宝
Fight.treasureKind_defense = 3 --防御类法宝

--===========================================================================================
--                     skill 
--===========================================================================================

Fight.skill_type_attack = 1 -- 直接攻击
Fight.skill_type_missle = 2 -- 释放子弹
Fight.skill_type_summon = 3 -- 释放召唤物

Fight.skill_appear_normal = 1       --出现在x方向能 打到的第一个目标面前
Fight.skill_appear_ymiddle = 2       --出现在x方向能 打到的第一个目标面前,y方向是中间
Fight.skill_appear_myFirst = 3       --出现在我方x方向能能选到的第一个人面签
Fight.skill_appear_toMiddle = 4     --出现在相对敌方屏幕中心
Fight.skill_appear_myMiddle = 5     --出现在相对我方屏幕中心
Fight.skill_appear_myplace = 6     --原地施法


--===========================================================================================
--                     missle 
--===========================================================================================

-- 移动方式
Fight.missle_moveType_budong = 1 -- 不动
Fight.missle_moveType_zhixian = 2 -- 直线运动
Fight.missle_moveType_paowuxian = 3 -- 抛物线
Fight.missle_moveType_xie = 4 -- 斜着运动打击
Fight.missle_moveType_yanchang = 5 -- 子弹延长打击
Fight.missle_moveType_frame = 6 -- 按固定帧直线运动到目标点

-- 出现方式
Fight.missle_appearType_shoot = 1 -- 以发射者来计算坐标
Fight.missle_appearType_jin = 2 -- 最近的一个
Fight.missle_appearType_chooseMid = 3 --创建在 选中敌人的最中间
Fight.missle_appearType_middleX = 5 -- X轴的中间
Fight.missle_appearType_specEnemy = 6 -- 特定敌人身边


-- 扩散方式
Fight.diffusion_youce = 1  -- 向右边扩散
Fight.diffusion_zuoce = 2  -- 向左边扩散
Fight.diffusion_liangce = 3 -- 向两边扩散

--===========================================================================================
--                     attack 
--===========================================================================================

Fight.valueChangeType_num = 1    --数值改变方式  1是按照数值修改, 2是按照比例修改
Fight.valueChangeType_ratio = 2  -- 按比例修改

-- value类型 定义一些属性 目前战斗过程中主要会改变的属性就是 生命和能量 所以在这里单独定义下
Fight.value_health = "hp"           --生命
Fight.value_maxhp = "maxhp"            --最大生命
Fight.value_inenergy = "inenergy"       --初始怒气
Fight.value_energy = "energy"           --能量 
Fight.value_maxenergy = "maxenergy"           --最大能量 

Fight.value_engergyget = "engergyget"       --单次攻击获得怒气
Fight.value_engergyR = "engergyR"           --过图获得怒气
Fight.value_engergychageR = "engergychageR"     --血转怒气转换效率
Fight.value_engergyeco = "engergyeco"           --怒气节省
Fight.value_atk = "atk"                         --攻击

Fight.value_phydef = "phydef"                   --物防
Fight.value_magdef = "magdef"                   --法防
Fight.value_crit = "crit"                       --暴击
Fight.value_resist = "resist"         --抗暴
Fight.value_critR = "critR"         --暴击强度

Fight.value_block = "block"       --格挡率
Fight.value_wreck = "wreck"         --破击率
Fight.value_blockR = "blockR"       --格挡强度
Fight.value_injury = "injury"       --伤害率
Fight.value_avoid = "avoid"         --免伤率

Fight.value_limitR = "limitR"       --控制率
Fight.value_guard = "guard"         --免控率
Fight.value_suckR = "suckR"         --吸血
Fight.value_thorns = "thorns"       --反伤
Fight.value_cureR = "cureR"         --治疗率

Fight.value_curegetR = "curegetR"   --反治疗


--连击伤害系数
Fight.combDmgRatio = {
    -- 1, 1.1, 1.2, 1.3, 1.4, 1.6
    1, 1, 1, 1, 1, 1
}


Fight.useWay_selfCamp = 1
Fight.useWay_enemyCamp = 2


--战斗伤害相关   3种打击结果 
Fight.damageResult_none = -1           --没有结果
Fight.damageResult_normal = 1         --普通命中 
Fight.damageResult_shanbi =  2        --闪避
Fight.damageResult_baoji =  3         --暴击
Fight.damageResult_gedang =  4         --格挡
Fight.damageResult_baojigedang =  5         --同时暴击和格挡

--挨打类型
Fight.hitType_shanghai = 1  -- 伤害
Fight.hitType_baoji = 2 --暴击
Fight.hitType_gedang = 3 --格挡
Fight.hitType_shanbi = 4 -- 闪避
Fight.hitType_mianyi = 5 -- 免疫
Fight.hitType_xingyun = 6 -- 幸运
Fight.hitType_zhiliao = 7 -- 治疗
Fight.hitType_jiafali = 8 -- 加法力
Fight.hitType_jianfali = 9 --减法力
Fight.hitType_weinengbaoji = 10 -- 减威能暴击
Fight.hitType_weinengputong = 11 -- 减威能普通
Fight.hitType_jiaweineng = 12  --  加威能
Fight.hitType_skillShanghai = 13  --  技能伤害

Fight.hitType_miss = 20     -- 闪避

--===========================================================================================
--                     bufff 
--===========================================================================================
--buff  所有的非二级属性buff 全部从50以上开始 
Fight.buffType_HOT = 1 -- HOT
Fight.buffType_DOT = 2 --DOT
Fight.buffType_xuanyun = 3 -- 眩晕
Fight.buffType_bati = 4 -- 霸体
Fight.buffType_wudi = 5 -- 无敌
Fight.buffType_gongji = 6 -- 攻击
Fight.buffType_fangyu = 7 -- 防御
Fight.buffType_chenmo = 8 -- 沉默
Fight.buffType_nuqihuifu = 9 -- 怒气回复速度
Fight.buffType_mianshang = 10 -- 免伤伤害
Fight.buffType_shanghai = 11 -- 增加伤害
Fight.buffType_baoji = 12 --暴击
Fight.buffType_mianbao = 13 -- 免暴
Fight.buffType_shanbi = 14 -- 闪避
Fight.buffType_mingzhong = 15 -- 命中
Fight.buffType_baobei = 16 -- 暴倍
Fight.buffType_xixue = 17 --吸血
Fight.buffType_fantan = 18 --反弹
Fight.buffType_nuqi = 19        --怒气
Fight.buffType_zhiliao = 20     --治疗效果
Fight.buffType_beizhiliao = 21   --被治疗效果

Fight.buffType_gedang = 22  --格挡
Fight.buffType_gedangqiangdu = 23 --格挡强度
Fight.buffType_poji = 24       --破击
Fight.buffType_bingdong = 25 -- 冰冻
Fight.buffType_kongzhi = 26         --控制率
Fight.buffType_miankong = 27        --免控

Fight.buffType_mabi =  28       --麻痹

Fight.buffType_relive = 30  --复活



--buff 映射的人物属性表 
Fight.buffMapAttrType  = {
    [Fight.buffType_gongji] = "atk",            -- 攻击
    [Fight.buffType_fangyu] = "def",            -- 防御
    [Fight.buffType_nuqihuifu] = "manaR",       -- 法力回复 
    [Fight.buffType_mianshang] = "avoid",       --免伤率
    [Fight.buffType_shanghai] = "injury",        -- 伤害率
    
    [Fight.buffType_baoji] = "crit",            -- 暴击
    [Fight.buffType_mianbao] = "resist",        -- 抗暴
    [Fight.buffType_shanbi] = "dodge",          --闪避
    [Fight.buffType_mingzhong] = "hit",         -- 命中
    [Fight.buffType_baobei] = "critR",          -- 暴倍

    [Fight.buffType_xixue] = "vampire",         -- 吸血
    [Fight.buffType_fantan] = "reflect",        -- 反弹
}

--buff对应飘字帧数表
Fight.buffMapFlowWordHao = {
    [Fight.buffType_baoji ] = 1 ,           --暴击率
    [Fight.buffType_baobei] = 2 ,           --暴击伤害    
    [Fight.buffType_beizhiliao] = 3,          --被治疗效果
    [Fight.buffType_fangyu] = 4,          --防御
    [Fight.buffType_gedang] = 5,          --格挡效果
    [Fight.buffType_gedangqiangdu] = 6,          --格挡强度
    [Fight.buffType_HOT] = 7 ,              --hot
    [Fight.buffType_mianbao] = 8 ,              --抗暴
    [Fight.buffType_kongzhi] = 9 ,          --控制率
    [Fight.buffType_miankong] = 10 ,          --免控
    [Fight.buffType_mianshang] = 11 ,          --免伤
    [Fight.buffType_nuqi] = 12 ,          --怒气变化
    [Fight.buffType_poji] = 14 ,          --破击
    [Fight.buffType_shanghai] = 15 ,          --伤害率
    [Fight.buffType_gongji] = 16 ,          --攻击力
    [Fight.buffType_zhiliao] = 17 ,          --治疗
}
--坏buff对应的帧数
Fight.buffMapFlowWordHuai = {
    [Fight.buffType_baoji ] = 1 ,           --暴击率
    [Fight.buffType_baobei] = 2 ,           --暴击伤害    
    [Fight.buffType_beizhiliao] = 3,          --被治疗效果
    [Fight.buffType_fangyu] = 4,          --防御
    [Fight.buffType_gedang] = 5,          --格挡效果
    [Fight.buffType_gedangqiangdu] = 6,          --格挡强度
    [Fight.buffType_HOT] = 7 ,              --hot
    [Fight.buffType_mianbao] = 8 ,              --抗暴
    [Fight.buffType_kongzhi] = 9 ,          --控制率
    [Fight.buffType_miankong] = 10 ,          --免控
    [Fight.buffType_mianshang] = 11 ,          --免伤
    [Fight.buffType_nuqi] = 13 ,          --怒气变化
    [Fight.buffType_poji] = 14 ,          --破击
    [Fight.buffType_shanghai] = 15 ,          --伤害率
    [Fight.buffType_gongji] = 16 ,          --攻击力
    [Fight.buffType_zhiliao] = 17 ,          --治疗
    [Fight.buffType_xuanyun] = 18 ,           --晕眩
    [Fight.buffType_bingdong] = 19 ,           --冰冻
    [Fight.buffType_chenmo] = 23 ,           --沉默
    [Fight.buffType_mabi] = 26 ,            --麻痹
    [Fight.buffType_DOT ] = 27 ,            --灼烧
}


--人物属性对应的buff属性表,
Fight.attrMapBuffType = {
}

for k,v in pairs(Fight.buffMapAttrType) do
    Fight.attrMapBuffType[v] = k
end

-- buff的类型
Fight.buffKind_hao = 1 -- 正面buff
Fight.buffKind_huai = 2 -- 负面buff
Fight.buffKind_aura = 3  -- 光环
Fight.buffKind_aurahuai = 4  -- 光环

-- 叠加的相同ID的情况替换
Fight.buffMulty_all = 0 --0是并存
Fight.buffMulty_replace = 1 --1是覆盖
Fight.buffMulty_max = 2 --2是存留剩余回合数比较大的


Fight.buffRunType_now =  1 --立刻作用
Fight.buffRunType_round =  2 --回合前作用


Fight.filterStyle_fire = 1  --灼烧滤镜效果
Fight.filterStyle_ice = 2  --冰冻滤镜效果

--===========================================================================================
--                     net
--===========================================================================================
--如果被晕眩了 那么应该休息 什么都不能做
Fight.operationType_sleep = 0
Fight.operationType_giveSkill = 1
Fight.operationType_giveTreasure = 2


--===========================================================================================
--                      调试相关
--===========================================================================================

Fight.conditions_nomal = 1
Fight.conditions_repeat = 2
Fight.conditions_insert = 3



Fight.dum_frame_num = 9000


Fight.camp_1 = 1 -- 阵容1
Fight.camp_2 = 2 -- 阵容2


Fight.drop_distance = 50 -- 掉落距离


Fight.low_fps = false -- true false

-- 是否进行数据统计
Fight.game_statistic = false -- 表示数据统计包含进入战斗人员信息和操作信息
if device.platform == "ios" or device.platform == "android" then
    Fight.game_statistic = false
end
Fight.use_operate_info = false -- 表示根据文件复盘战斗情况
Fight.statistic_file = "battle_2016_11_18_14_35_23" -- 记录战斗操作信息的文件

 
--测试clone帧
Fight.debugCloneFrame = false
-- 单个数据备份调试
Fight.debugeBackupOne = false
Fight.backups_count = 670

--是否是 模拟播放  比如 纯粹计算战斗ai的时候 那么就设置为 true
Fight.isDummy = false -- false true
Fight.dummyUpdata = 1/30

Fight.only_one_enemy_hid = "10001"
Fight.enemy_low_hp = false      --敌人低血量
Fight.all_high_hp = false       --高血量
Fight.default_level_id = "103"
Fight.allways_lose = false

Fight.no_dialog = false
Fight.test_jitui_hid = "29300071"  --29300071  10026

Fight.debugFullEnergy = false        --无限能量


function Fight:getElementString( t )
    return self.elementStrObj[t]
end
BattleDebug = function ( ... )
    if Fight.debugCloneFrame and not Fight.debugeBackupOne then
        return
    end

    if DEBUG  and DEBUG > 0 then
        local params = {...}
        local str = " "
        for k,v in pairs(params) do
            str = str.."  "..v
        end
        -- print("[echo:]",str)
        if LogsControler then
            LogsControler:addLog(LogsControler.logType.LOG_TYPE_NORMAL,...)
        end        
    end
end



return Fight



