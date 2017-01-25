
local viewsPackage = "game.sys.view"

--窗口配置   目前手配, 会比较容易管理,主要负责管理ui 的显示层级,父子关系,显示样式等

--[[
    ui(string) 是否这个窗口 有 flash对应的UI配置,默认为空,  
    level(int) 显示层级 越高 越在上面,  比如 tip 层级最高 ,tip会盖住一般的window, 默认为2
    package(string) , ui对应的包路径,默认为空
    cache(bool):  是否缓存这个ui  ,有些窗口关闭以后 是需要缓存起来的,有些是需要立即销毁的,以后的扩展可能还会配置 clearTextrues 
    addTex(Array):  打开这个窗口需要加载的材质,默认为空,
    clearTex(Array): 关闭这个窗口后需要清除的材质, 默认为空, 当cache为true的时候 不执行clearTextures
    style 显示的过程  默认值 1(fadein) 2缩放 , 0
    pos 显示的初始位置 默认值 pos={x=0,y=GameVars.height}
    bgAlpha             --背景透明度
    bg          --背景图片 默认为空

]]

-- 1= scene  2= 1j window --------------5  6= tip
--每一个键名一定会有一个对应的view和他对应,这个名字一定要保证一致

local LocalZorder = {
    SystemOpenView_10 = 10,
}

local windowsCfgs = {
    
    --基础UIBase
    UIBase = {ui = "*",style  = 0},
    -- 测试界面
    
    --通用Tip弹窗
    Tips = {ui="UI_comp_tcdan",  level = 999, package ="component", style = 2,pos = {x=0,y=GameVars.height}},

    --通用输出
    InputView = {ui="UI_inputModel",level = 999,package = "component"},

    --网络调试接口界面
    TestConnView = {ui = "UI_debug_interface" ,package = "test"   },
    --进入gm界面的入口
    GMEnterView = {ui = "UI_debug_GM" ,package = "test"   },
    
    DebugFilterView= {ui="UI_debug_filter",package ="test",bgAlpha=0},
    DebugColorView= {ui="UI_debug_color",package ="test",bgAlpha=0},
    TestDebug_public= {ui="UI_debug_public",package ="test",bgAlpha=0},


    --日志
    LogsView = {ui = "UI_debug_log", package = "test", style = 0, level = 999999},
	GlobalServerSwitchView = {ui = "UI_debug_switchserver", package = "test", style = 0, level = 999999},
    LogsItem = {ui = "UI_debug_textItem", package = "test", style = 0, level = 1},

    -- 公共界面
    --gridView Test
    GridViewTestView = {ui="UI_GridViewTest", package = "GridViewTest"},
    GridItem = {ui="UI_itemTest", package = "GridViewTest"},
    --公共messageBox
    MessageBoxView = {ui = "UI_comp_tanchuang", package = "component", style = 0, level = 100},
    --公共背景拉缩框
    DynamicBgView = {ui = "UI_comp_bg", package = "component"},
    DynamicBgView2 = {ui = "UI_comp_bg2", package = "component"},
    TipItemView = {ui = "UI_comp_tipsItem", package = "component"},
    TipItemView2 = {ui = "UI_comp_tipsItem2", package = "component"},
    -- 战斗属性滚动tip
    TipFightAttrView = {ui = "UI_comp_tipsItem3", package = "component"},
       --剧情对话
    PlotDialogView = {ui = "UI_comp_plot", package = "plot", level = 999999},

    -- 神通tips界面
    TipSkillView = {ui = "UI_comp_skill_tips", package = "component"},

    -- 获得奖品界面
    RewardBgView = {ui = "UI_comp_huodegoods", package = "component"},

    --5个以下获得奖品弹窗
    RewardSmallBgView = {ui = "UI_comp_comphuode", package = "component"},

    -- 资源itemView公用UI
    CompResItemView = {ui = "UI_comp_goodsItem_mc", package = "component", style = 2, level = 2},

    -- 玩家明细
    -- PlayerDetailView = {ui = "UI_comp_playerDetail", package = "component", style = 2, level = 100},
    -- 仙盟明细
    -- GuildDetailView = {ui = "UI_comp_guildDetail", package = "component", style = 2, level = 100},
    -- 获取途径
    GetWayListView = {ui = "UI_comp_tongyong_tujing", package = "component", style = 2, level = 100},
    -- 获取途径窗口item
    GetWayListItemView = {ui = "UI_comp_getWayCell", package = "component", style = 0, level = 100},


	--UI_comp_shopItem
	CompShopItemView = {ui = "UI_comp_shopItem", package = "component", style=0, level=0},
    -- 法宝view
    CompTreasureView = {ui = "UI_comp_fb", package = "component", style = 0, level = 0},
    -- 恭喜获得
    CompRewardGetView = {ui = "UI_comp_tc", package = "component", style = 0, level = 0},
    -- 通用小弹窗
    CompPopSmallView = {ui = "UI_comp_tc2", package = "component", style=0, level=0},
    -- 通用小弹窗3
    CompPopSmallView3 = {ui = "UI_comp_tc3", package = "component", style=0, level=0},
    -- 购买体力: 已废弃
    --CompBuySpView = {ui = "@@@UI_comp_maitili", package = "component", style = 0, level = 0},
--
    CompBuyCoinMainView ={ui="UI_comp_buymoney",package="component",style=2,level=2, bgAlpha=180},
    CompBuySpMainView={ui="UI_comp_buytili",package="component",style=2,level=2, bgAlpha=180},
    -- 顶部资源条体力
    CompResTopSpView = {ui = "UI_comp_res_tili", package = "component", style = 0, level = 0},
    -- 顶部资源条银币
    CompResTopCoinView = {ui = "UI_comp_res_tongqian", package = "component", style = 0, level = 0},
    -- 顶部资源条元宝
    CompResTopGoldView = {ui = "UI_comp_res_yuanbao", package = "component", style = 0, level = 0},
    -- 顶部资源条赤铜
    CompResTopCopperView = {ui = "UI_comp_res_chitong", package = "component", style = 0, level = 0},
    -- 顶部资源条宝物精华
    CompResTopJinghunView = {ui = "UI_comp_res_jinghun", package = "component", style=0, level=0},
    -- 顶部资源魂牌
    CompResTopHunpaiView = {ui = "UI_comp_res_hunpai", package = "component", style=0, level=0},
    -- 顶部资源真气
    CompResTopZhenQiView = {ui = "UI_comp_res_zhenqi", package = "component", style=0, level=0},
	--购买天赋资源条UI
	CompResTopTalentView={ui="UI_comp_res_tianfu",package="component",style=2,level=2},
	--竞技场货币资源条
	CompResTopArenaCoinView = {ui = "UI_comp_res_xianyu", package = "component", style=2,level=0},
	--侠义值
	CompResTopXiayiView = {ui="UI_comp_res_xiayi", package="component", style=2, level=0},
    -- vip限制，引导去充值
    CompVipToChargeView = {ui = "UI_comp_vip_charge_tip", package = "component", style = 2, level = 3},
    -- 主角系统天赋点
    CompResTalentBeanView = {ui = "UI_comp_res_tianfudian", package = "component", style = 2, level = 3},

    -- 通用商品详情
    CompGoodItemView = {ui = "UI_comp_xiangqing", package = "component", style = 2,},

    -- 通用伙伴卡片UI
    CompPartnerCardView = {ui = "UI_comp_card", package = "component"},

    -- 充值跳转
    CompGotoRechargeView = {ui = "UI_comp_chongzhi", package="component", style =2,},

	-- loading
	CompLoading = {ui = "UI_comp_res_loading", package = "component", style = 0, },

    --断网弹窗
    CompServerOverTimeTipView = {ui = "UI_comp_duanwang", package="component", style =2};
    
    --邀请战斗
    BattleInvitationView = {ui = "UI_comp_tuisong",  package = "component", style = 1, level = 1},

    PowerComponent = {ui = "UI_comp_powerNum",  package = "component"},

    --威力滚动
    PowerRolling = {ui = "UI_comp_rollingNumber",  package = "component" },

    -- 更新版本界面
    VerView = {ui="UI_VersionUpdates",  package ="ver"},


    -- 主角升级
    CharLevelUpView = {ui="UI_char_levelUp",package = "char",
        pos = {x=0,y=GameVars.height}, level = 100, addTex = {"UI_char_common"}},
    -- 主角主界面
    CharMainView = {ui = "UI_char_main", package = "char", style = 0, level = 2, full = true,bg = "char_bg_zhujue.png"},
    -- 主角属性信息
    CharAttributeInfoView = {ui = "UI_char_1", package = "char", style = 0, level = 2, full = true},
    -- 主角升品
    CharQualityLevelUpView = {ui = "UI_char_1_shengpin", package = "char", style = 0, level = 2, full = true},
    -- 主角属性列表
    CharAttributeListView = {ui = "UI_char_1_shuxing", package = "char", style = 0, level = 2, full = true},
    -- 主角属性法宝详情
    CharTreasureTipView = {ui = "UI_char_tips", package = "char", style = 0, level = 2, full = true},
    -- 主角天赋
    CharTalentView = {ui = "UI_char_2", package = "char", style = 0, level = 2, full = true},

    --战斗系统
    --战斗界面
    BattleView = {ui="UI_battle",package ="battle",bgAlpha =0, pos = {x=10,y=GameVars.height},addTex = {"UI_battle_common","UI_battle_public"}}, -- UI_battle  UI_zhandouzhong
    BattleMap = {ui="UI_map_1", package ="battle",},
    
    BattleTreasureView = {ui= "UI_battle_treasure",package = "battle" },
    --PVE战斗血条
    BattlePVEHpView = {ui="UI_battle_pve_hp",package="battle"},
    --PVP战斗血条
    BattlePVPHpView = {ui="UI_battle_pvp_hp",package="battle"},

    --暂停界面
    BattlePause ={ui = "UI_battle_pause",package = "battle",style =2 }, 

    --战斗胜利界面
    BattleWin ={ui = "UI_battle_win",package = "battle"}, 
    --战斗失败界面
    BattleLose ={ui = "UI_battle_lose",package = "battle"}, 
    

    BattleWin3 = {ui = "UI_battle_win3", package = 'battle', style = 2},  

    --新 战斗结果  有胜利失败
    BattleResult = {ui = "UI_battle_jiesuan",package = "battle"},
    --新  战斗  伤害数据对比
    BattleAnalyze = {ui = "UI_battle_shuju",package = "battle"},
    --新 战斗  宝箱奖励
    BattleReward = {ui = "UI_battle_jiangli",package = "battle"},

    -- 战斗loading界面
    BattleLoadingView = {ui="UI_battle_loading",  package ="component", style = 2, level = 100},

    --站前阵容
    TeamFormationView = {ui = "UI_team_formation",package = "team",style = 2,bg = "team_bg_changjing.png"},
    TeamChooseTreasureView = {ui = "UI_team_choosetreasure",package="team",style = 2},

    --公共ui组件 不单独显示整个ui
    BattlePublic = {ui ="UI_battle_public",package="battle"},

    --网络请求
    ConnRepeateView = {ui ="UI_conn_reconnect",package ="conn" ,style =0,level = 20,bgAlpha =0  },
    ServerLoading = {ui ="UI_conn_loading",package ="conn",style = 0 },


    --登入相关
    ---- 调试用登录界面
	---- 正式版用登录界面
	EnterGameView = {ui = "UI_login_entergame", package='login', bg="bg_denglu.png", style=2},
	LoginView = {ui = "UI_login_login", package='login', style=2, level=3},
	LoginSelectView = {ui = "UI_login_select_way", package = "login", style=2,},
	LoginBindingAccount = {ui = "UI_login_up", package = "login", style = 2},
	--热更之后资源、lua加载界面 --用CompLoading
	--热更进度界面
	LoginLoadingView = {ui = "UI_login_loading", package = "login",bg="bg_denglu.png", style = 0,addTex = { "UI_login_common"}},
	--游戏中服务器维护、关服、或者帐号禁用还包括进游戏前的热更提示，都弹这个窗口
	LoginExceptionView = {ui = "UI_login_exception", package = "login", style=0},
	--游戏更新异常
	LoginUpdateExceptionView = {ui = "UI_login_update_exception", package = "login", style = 2},
	ServerListView = {ui = "UI_login_xuanfu", package="login", bg="global_bg_tongyong",style=2},
    SelectRoleView = {ui = "UI_login_select_role", package="login", bg="bg_xuanjue.png", style=2},
    
	-- Activity
	ActivityMainView = {ui = "UI_activity", package = "activity", style=2, addTex={"UI_activity_common"}},
	ActivityMainNavView = {ui = "UI_activity_mainnav", package = "activity", style=1},
	ActivityItemReceive = {ui = "UI_activity_lingqu", package = "activity", style=2},
    ActivityItemExchange = {ui = "UI_activity_duihuan", package = "activity", style=2},
	ActivityFirstRechargeView = {ui = "UI_activity_1", package = "activity", style=2},

    --法宝
    TreasureEntrance = {ui = "UI_treasure",  
        package = "treasure", style = 0, level = 2, addTex = {"UI_treasure_common"}},
    TreasureItem = {ui = "UI_treasure_tiao", package = "treasure", style = 0, level = 2},
    TreasureDetailView = {ui = "UI_treasure_xiangqing", bg = "treasure_bg.png", 
        package = "treasure", style = 0, level = 2},
    TreasurePlusStarView = {ui = "UI_treasure_shengxing2", package = "treasure", style = 2, level = 2},
    TreasureMaxView = {ui = "UI_treasure_manji", package = "treasure", style = 0, level = 2},
    TreasureEnhanceView = {ui = "UI_treasure_qianghua", bg = "treasure_bg.png", 
        package = "treasure", style = 0, level = 2},

    TreasureReFineView = {ui = "UI_treasure_jinglian", bg = "treasure_bg.png", 
        package = "treasure", style = 0, level = 2},

    TreasureReFineSkillUpView = {ui = "UI_treasure_jinglianUp", bg = "treasure_bg.png", 
        package = "treasure", style = 0, level = 2},
    
    TreasureReFineSuccessView = {ui = "UI_treasure_chenggong", 
        package = "treasure", style = 0, level = 2},

    TreasureInfoView = {ui = "UI_treasure_shuxing", package = "treasure", style = 0, level = 2,},
    TreasureSkillDetailView = {ui = "UI_treasure_shuoming", package = "treasure", style = 0, level = 2},
    TreasurePowerTips = {ui = "UI_comp_tipsItem4", package = "treasure"},
    TreasureLeftListCompoment = {ui = "UI_treasure_leftList", package = "treasure"},
    TreasureSkillPanelCompoment = {ui = "UI_treasure_component", package = "treasure"},



     --法宝合成
    CombineView  = {ui = "UI_combine", package = 'combine', style = 2},   
    CombineItemView  = {ui = "UI_combine_tiao", package = 'combine', style = 2}, 
    CombineItemTip  = {ui = "UI_combine_jilian", package = 'combine', bg = "treasure_bg.png"}, 
    --强化
    CombineItemIntensify  = {ui = "UI_combine_quqianghua", package = 'combine'}, 
    --确认提示
    CombineItemConfTip  = {ui = "UI_combine_queren", package = 'combine', style = 2}, 


    --星缘
    StarlightView = {ui = "UI_starlight", package = 'starlight', style = 2, level = 2,addTex ={"UI_starlight_common"}}, 
    StarlightTipView = {ui = "UI_starlight_jihuo", package = 'starlight', style = 2, level = 2}, 
    StarlightViewItem = {ui = "UI_starlight_Item", package = 'starlight', style = 2, level = 2}, 
    --大法宝入口,单独flash，里面就一个UI_merge UI界面
    TreasureView = {ui = "UI_merge", package = 'treasure', bg = "treasure_bg.png",
        level = 2, addTex = {"UI_starlight_common","UI_combine_common"}}, 
		
	--挑战
    ChallengeView = {ui = "UI_chal",package ="challenge",bg = "chal_bg_tiaozhan.png"},
	



    -- 背包列表
    ItemListView = {ui = "UI_bag", package = "item", style = 2, level = 2,bg="global_bg_tongyong.png"},
    -- 开宝箱奖品列表界面
    ItemBoxRewardView = {ui = "UI_bag_dakai", package = "item", style = 2, level = 2},

    -- 竞技场
    ArenaMainView = {ui = "UI_pvp", package = "pvp", style = 2, bg="arena_bg.png", level = 2,addTex= {"UI_pvp_common"}},
    -- 称号列表
    ArenaTitleView = {ui = "UI_pvp_chenghao", package = "pvp", style = 2, level = 2},
    -- 规则说明列表
    ArenaRulesView = {ui = "UI_pvp_shuoming", package = "pvp", style = 2, bg="arena_bg.png" ,level = 2},
    -- 战斗回放列表
    ArenaBattlePlayBackView = {ui = "UI_pvp_huifang", package = "pvp",bg="arena_bg.png", style = 2, level = 2},
    -- 战斗回放结果
    ArenaBattleReplayResult = {ui = "UI_pvp_replay_result", package = "pvp", style=2, },

    -- 竞技场天梯分割item 
    ArenaListCommonItem = {ui = "UI_pvp_rank_item_common", package = "pvp", style=2, },
    ArenaListTopItem = {ui = "UI_pvp_rank_item_top", package = "pvp", style=2},

	--竞技场主界面，显示挑战次数界面
    ArenaAddPvpCountView = {ui = "UI_pvp_add_count", package = "pvp", style=2},

    -- 清除挑战cd对话框
    ArenaClearChallengeCdPop = {ui = "UI_pvp_clearcd", package = "pvp", style=2},
    ArenaRefreshCdView = {ui = "UI_pvp_refresh_cd", package = "pvp", style=2},
    ArenaPlayerView = {ui = "UI_pvp_player", package = "pvp", style= 2 },
    -- 竞技场购买挑战次数
    ArenaBuyCountView = {ui = "UI_pvp_buycount", package = "pvp", style=2},

    -- 称号获得
    ArenaTitleAchieveView = {ui="UI_pvp_titlehuode", package = "pvp", style = 2, },

    ArenaBattleLoading = {ui="UI_pvp_loading", package = "pvp", bg="arena_bg.png", style = 2},

    ArenaPlayerTalkView = {ui = "UI_pvp_player_talk", package = "pvp", style=2},
    --角色展示
    ArenaDetailView = {ui = "UI_pvp_information" ,package = "pvp",style = 2,},
  --  ArenaDefenceView = {ui="UI_pvp_fang",package ="pvp",style=2,},
    --排名兑换
    ArenaRankExchangeView = {ui="UI_pvp_paimingduihuan",package ="pvp",bg = "arena_bg.png"},
    --积分奖励
    ArenaScoreRewardView = {ui="UI_pvp_jiangli",package="pvp",bg = "arena_bg.png"},
    --挑战5次
    ArenaChallenge5View = {ui = "UI_pvp_jieguo",package ="pvp",style =2,},
    --家园 -- 主界面
    HomeMainView = {ui = "UI_mainview", package = "home", style = 0, level = 0, addTex={ "UI_mainview_common"}},   
    HomeMainCompoment = {ui = "UI_mainview_downBtnsCompoment", package = "home"},   
    HomeMainUpBtnCompoment = {ui = "UI_mainview_upBtnsCompoment", package = "home"},   
    HonorView = {ui = "UI_honor", package = 'home', style = 2, level = 2,  bg = "arena_bg"}, 
    SysWillOpenView = {ui = "UI_mainview_newsystips", package = 'home', style = 2, level = 2}, 
    TrotHoseLampView={ui="UI_mainview_5",package="home",style=0,level=0 },--//跑马灯
    --玩家信息和设置
    PlayerInfoView = {ui = "UI_info", package = "playerinfo", style=2,bg = "global_bg_tongyong" },
    PlayerSettingToggle = {ui = "UI_info_setting_toggle", package = "playerinfo", style=0},
    PlayerSettingSlider = {ui = "UI_info_setting_slider", package = "playerinfo", style=0},
    PlayerRenameView = {ui = "UI_info_rename", package = "playerinfo", style=2, level = 2},
    GameFeedBackView = {ui = "UI_info_fankui", package = "playerinfo", style=2},
    GameGonggaoView = {ui = "UI_info_gonggao", package = "playerinfo", style=1, addTex = {"UI_info_common"}},
    CdkeyExchangeView = {ui = "UI_info_cdkey", package = "playerinfo", style=2},
	CdkeyExchangeResult = {ui = "UI_info_cdkey_reward", package="playerinfo", style=2},

	--天玑赌肆
	YongAnGambleView = {ui = "UI_gamble", package = "gamble", style = 2,bg="gamble_bg_beijing"},
	YongAnGambleHelpView = {ui= "UI_gamble_help", package = "gamble", style = 2},
	YongAnGambleDice = {ui = "UI_gamble_dice", package = "gamble", style=1},
	YongAnNewBonusView = {ui = "UI_gamble_newbonus", package = "gamble", level=10, style=2},

	--熔炼
	SmeltMainView = {ui = "UI_smelt", package = "smelt", style=2, addTex = {"UI_smelt_common"}},
	SmeltMainItemView = {ui = "UI_smelt_main_select_item", package = "smelt", style=1},
	SmeltSelectMainView = {ui = "UI_smelt_select_main", package = "smelt", style=2},
	SmeltSelectedView = {ui = "UI_smelt_selected", package = "smelt", style=1},
	SmeltSelectContentItem = {ui = "UI_smelt_select_content_item", package = "smelt", style=1},
	SmeltTitleView = {ui = "UI_smelt_reward", package = "smelt", style=2},
	SmeltTitleItemView = {ui = "UI_smelt_reward_item", package = "smelt", style=1},

    --充值
    RechargeMainView = {ui = "UI_recharge",package = "recharge",style = 2},
    RechargeMainItemView = {ui = "UI_recharge_item",package = "recharge",style = 2},

    --公会
    --选择创建或者
    --GuildBlankView = {ui = "UI_@@guild_xianmeng", package = "guild", style = 0, level = 0},
    --GuildCreateView = {ui = "UI_@@guild_chuangjian", package = "guild", style = 0, level = 0},
    --GuildJoinView = {ui = "UI_@@guild_jiaru", package = "guild", style = 0, level = 0},
    --GuildIconItem = {ui = "UI_@@guild_kuangItem", package = "guild", style = 0, level = 0},
    --GuildInviteView = {ui = "UI_@@guild_chenggong", package = "guild", style = 0, level = 3},
    --GuildListItem = {ui = "UI_@@guild_addItem", package = "guild", style = 0, level = 0},
    --GuildHomeView = {ui = "UI_@@guild_gonghuizhu", package = "guild", style = 0, level = 0},
    --GuildManageView = {ui = "UI_@@guild_xinxi", package = "guild", style = 0, level = 0},
    --GuildMemberItem = {ui = "UI_@@guild_chengyuanliebiao", package = "guild", style = 0, level = 0},
    --GuildApplyListView = {ui = "UI_@@guild_liebiaoshenqing", package = "guild", style = 0, level = 0},
    --GuildApplyListItem = {ui = "UI_@@guild_shenqingItem", package = "guild", style = 0, level = 0},
    --GuildMemberDetailView = {ui = "UI_@@guild_chakan", package = "guild", style = 0, level = 0},
    --GuildInviteItem = {ui = "UI_@@guild_yqtiaoItem", package = "guild", style = 0, level = 0},
    --GuildChangeIconView = {ui = "UI_@@guild_biaozhixiugai", package = "guild", style = 0, level = 0},
    --GuildEditDeclarationView = {ui = "UI_@@guild_gonggaoxiugai", package = "guild", style = 0, level = 0},

    --邮件
    MailView = {ui = "UI_mail",package ="mail",style = 2,bg="global_bg_tongyong.png"},
    MailGoodItemView = {ui = "UI_mail_goodsItem",package ="mail"},

    --商城 
    ShopView = { ui = "UI_shop",package = "shop" ,style = 2 , bg="global_bg_tongyong",addTex = {"UI_shop_common"} },
    ShopNavBtnsView = {ui = "UI_shop_navbtns", package = "shop", style=2},
    ShopNavBtn = {ui = "UI_shop_nav_btn", package = "shop", style=2},
    --商店开启的时候也得打开 通用界面
    ShopKaiqi = {ui = "UI_shop_kaiqi",package = "shop", addTex = {"UI_shop_common"} ,level = 3, style=2},
    ShopJiefeng = {ui = "UI_shop_jiefeng",package = "shop",level =3 , bgAlpha=0, style=2},  
    --刷新界面
    ShopRefreshView = {ui = "UI_shop_shuaxin",package ="shop",level =3, style=2 },
    ShopOpenConfirm = {ui = "UI_shop_open_confirm", package="shop", level=3, style=2},
    --灵宝殿刷新次数用完
    ShopSmeltNoRefreshView = {ui = "UI_shop_smelt_no_refresh", package = "shop", level=3, style=2},

    --奇缘
    
	

    -- 排行榜
    -- RankMainView = {ui = "UI_@@rank", package = "rank", style = 0, level = 1},

    --签到
    SignView = {ui = "UI_sign", package = "sign", style = 0, bg="global_bg_tongyong", level = 0, },
    -- 抽卡
    LotteryMainView = {ui = "UI_lottery", package = "lottery", style = 2, level = 2 ,bg="lottery_bg_beijing",},
    LotteryPreviewReward = {ui = "UI_lottery_yulan", package = "lottery", style = 2, level = 2,bg ="global_bg_tongyong" },
    LotteryShowReward = {ui = "UI_lottery_jieguo", package = "lottery", style = 2, level = 2},
    LotteryShowTreasure = {ui = "UI_lottery_jiangli", package = "lottery", style = 2, level = 10,},
    -- 抽卡系统法宝详情
    LotteryTreasureDetail = {ui = "UI_lottery_xiangqing", package = "lottery", style = 2, level = 10},

    --试炼
    TrialEntranceView = {ui = "UI_trial_homepage", package = "trial", 
        bg = "trial_bg_shilian", style = 0, level = 2,},
    -- TrialDifficultySelectView = {ui = "UI_@@trial_difficulty",        bg = "trial_bg_xinxiyemian.png", package = "trial", style = 0, level = 2},
    TrialSweepView = {ui = "UI_trial_saodang", package = "trial", style = 2, level = 2},
    TrialDetailView = {ui = "UI_trial_info", package = "trial", 
        bg = "trial_bg_shilian", style = 0, level = 2,},

    TrailSweepInfoView = {ui = "UI_trial_sdguize", package = "trial", style = 2, level = 2},
    TrailRecommendTreasureView = {ui = "UI_trial_tuijian", package = "trial", style = 2, level = 2},
    TrailRegulationView = {ui = "UI_trial_guize", package = "trial", style = 0, level = 2},
    -- TrailLoadingView = {ui = "UI_@@trail_loading", package = "trial", style = 0, level = 2},

    -- 副本相关界面
    WorldPVEMainView = {ui = "UI_world_main_new", package = "world", style = 0, level = 2, full = true, bg = "world_bg_beijing.png"},
    -- 寻仙PVE关卡界面
    WorldPVELevelView = {ui = "UI_world_1", package = "world", style = 2, level = 3,hideBg=true},
    -- 获得额外奖励界面
    WorldExtraRewardView = {ui = "UI_world_tan_2", package = "world", style = 0, level = 3},
    -- 评级奖励界面
    WorldStarRewardView = {ui = "UI_world_6", package = "world", style = 2, level = 3},
    -- 星级tool tip界面
    WorldStarTipView = {ui = "UI_world_3", package = "world", style = 2, level = 3},
    -- NpcInfo tool tip界面
    WorldNpcInfoTipView = {ui = "UI_world_2", package = "world", style = 2, level = 3},
    -- 扫荡结果界面
    WorldSweepListView = {ui = "UI_world_4", package = "world", style = 2, level = 3},
    
    --任务
    QuestView = {ui = "UI_task", package = "quest", style = 2, level = 2, bg = "global_bg_tongyong.png",},
--好友
    FriendMainView={ui="UI_friend",package="friend",style=2,level=2,bg="global_bg_tongyong"},
    FriendModifyNameView={ui="UI_friend_1",package="friend",style=2,level=2},
   

    --爬塔 new
    TowerNewMainView = {ui = "UI_tower", package = 'towerNew', style = 2,addTex = {"UI_tower_common"},bg = "tower_bg_syt"},
    TowerNewAchievementView = {ui = "UI_tower_chengjiu", package = 'towerNew', style = 2,bg = "tower_bg_syt"}, 
    TowerNewAchievementItemView = {ui = "UI_tower_chengjiujiangli", package = 'towerNew',addTex = {"UI_tower_common"}, style = 2}, 
    TowerNewMainTreasureView = {ui = "UI_tower_baoxiang", package = 'towerNew', style = 2,bg = 'tower_bg_syt'},
    TowerNewSaoDangHeJLYLView = {ui = "UI_tower_SaoDang", package = 'towerNew', style = 2}, 
    TowerNewBenCengJiangLiView = {ui = "UI_tower_BenCengJiangLi", package = 'towerNew', style = 2}, 
    TowerNewPaihangbangView = {ui = "UI_tower_PaiHangBang", package = 'towerNew', style = 2}, 
    TowerNewXuanZeBangShouView = {ui = "UI_tower_XuanZeBangShou", package = 'towerNew', style = 2}, 
    TowerNewBoxKeys = {ui = "UI_tower_box_key", package = "towerNew", style=2},
    TowerNewBuyTip =  {ui = "UI_tower_elite_buy", package = "towerNew", style=2},
    TowerNewBoxRewardView  =  {ui = "UI_tower_gongxihuode", package = "towerNew", style=2},
    --宝箱可获得奖励展示
    TowerNewTreasureShowAward = {ui = "UI_tower_jiliyulan", package = 'towerNew', style = 2}, 
    TowerNewTreasureShowAwardItemView = {ui = "UI_tower_jiangliyulankuang", package = 'towerNew', style = 2}, 
    
        
    --新手引导
    NpcContentWidget = {ui = "UI_novice", package = 'tutorial', style = 2}, 
    BubbleWidget = {ui = "UI_trigger", package = 'tutorial', style = 2}, 

    --聊天
    ChatMainView = {ui = "UI_talk", package = 'chat', style = 0, level = 0},-- ,bgAlpha  = 0},  
    CompPlayerDetailView={ui="UI_comp_palyerxq",package="component",style=2,level=2},
    --欢乐签到
    HappySignView = {ui="UI_activity_happy_sign",package="happySign",bg = "global_bg_tongyong",style=2,level=2},

    -- 新奇缘
    EliteView = {ui="UI_elite",package="elite",bg = "global_bg_tongyong",style=2,level=2},
    EliteDetailsView = {ui="UI_elite_xiangqing",package="elite",bg = "global_bg_tongyong",style=2,level=2},
    EliteTipsView = {ui="UI_elite_buy",package="elite",style=2,level=2,bgAlpha = 50},
    EliteYJDHRewardView = {ui="UI_elite_jiangli",package="elite",style=2,level=2,bgAlpha = 50},
    EliteHelp = {ui="UI_elite_help",package="elite",style=2,level=2,bg = "global_bg_tongyong"},

    --vip
    VipMainView = {ui="UI_Vip_main", package = "vip"},
    VipPageComponentView = {ui="UI_Vip_Compenent", package = "vip",},

    -- 御灵
    GodView = {ui="UI_god", package = "god", bg="god_bg_yuling"},
    GodDetailView = {ui="UI_god_2", package = "god", bg="god_bg_yuling"},

    --守护紫萱
     DefenderMainView = {ui="UI_defender", package = "defender", bg="defender_bg_changjing",addTex = {"UI_defender"}},
    DefenderHelpView = {ui="UI_defender_help", package = "defender", bg="defender_bg_changjing",addTex = {"UI_defender"}},
--伙伴系统 
    PartnerView = {ui="UI_partner_main",package ="partner",style=2,bg="global_bg_tongyong.png"},--伙伴系统主界面
    PartnerBtnView = {ui="UI_partner_list" , package ="partner",}, --伙伴系统左侧伙伴列表管理
    PartnerTopView = {ui="UI_partner_func" , package="partner",}, --伙伴系统功能按钮管理
    PartnerSkillView ={ui="UI_partner_skill",package="partner",}, --技能
    PartnerSoulView = {ui="UI_partner_soul",package="partner",},--仙魂
    PartnerSoulUpView = {ui="UI_partner_soul_levelup" , package="partner",}, --仙魂升级
    PartnerSoulItemView ={ui="UI_partner_soul_item",package="partner",},
    PartnerCombineView = {ui="UI_partner_display",package="partner",}, --伙伴碎片合成
    PartnerSkillPointView = {ui = "UI_partner_open_confirm",package="partner"},
    PartnerNobodyView = {ui="UI_partner_nobody",package="partner"},
    PartnerSkillDetailView = {ui="UI_partner_tips",package="partner",bgAlpha=0},
    PartnerNewPartnerView = {ui="UI_partner_new_partner",package="partner",},
 --   PartnerAttackDefenceView = {ui="UI_partner_attack_defence",package="partner",},
--升品
    PartnerUpQualityView = { ui="UI_partner_quality_levelup",package="partner" ,},
     --伙伴升级
   PartnerUpgradeView = {ui="UI_partner_levelup", package = "partner",},
   --伙伴升星
   PartnerUpStarView = {ui="UI_partner_star_levelup", package = "partner",},
   --伙伴类型标签
   PartnerTypeLabelView = {ui="UI_partner_attack_defence", package = "partner",},
   --伙伴万能碎片
   PartnerWanNengSuiPianView = {ui="UI_partner_frag", package = "partner",},
--伙伴合成
    PartnerCombineItemView = {ui="UI_partner_chengxu" ,package="partner",},
    --伙伴升品道具合成UI
    PartnerUpQualityItemCombineView = {ui="UI_partner_combine" ,package="partner",},
    --伙伴详情
    PartnerInfoUI = {ui="UI_partner_info" ,package="partner",},
    --伙伴装备
    PartnerEquipView = {ui="UI_partner_main2" ,package="partner",bg="global_bg_tongyong.png",},
    PartnerEquipTopView = {ui="UI_partner_func2" , package="partner",},
    --伙伴装备强化
    PartnerEquipmentEnhanceView = {ui="UI_partner_zbqh" ,package="partner",},
    PartnerEquipmentShenzhuangView = {ui="UI_partner_sz" ,package="partner",},
    --三皇抽卡
    NewLotteryMainView = {ui="UI_lottery_new", package = "newlottery", bg="lottery_bg_sanhuangtai"},
    NewLotteryShopView = {ui="UI_lottery_1", package = "newlottery", bg="lottery_bg_sanhuangtai"},
    NewLotteryreplaceView = {ui="UI_lottery_2", package = "newlottery"},
    NewLotteryJieGuoView = {ui="UI_lottery_jieguo", package = "newlottery"},
    NewLotteryJieGuoCradView = {ui="UI_lottery_jieguo2", package = "newlottery"},
    NewLotteryShowHeroUI = {ui="UI_lottery_jieguo3", package = "newlottery"},
    NewLotteryNavBtn = {ui = "UI_lottery_nav_btn", package = "newlottery", style=2},
    NewLotteryNavBtn2 = {ui = "UI_lottery_nav_btn2", package = "newlottery", style=2},
    CompSanhuangcoinview = {ui = "UI_lottery_res_sanhuang", package = "newlottery", style=0, level = 0},
    NewLotteryRewardShowUI = {ui = "UI_lottery_newyulan", package = "newlottery", style=0, level = 0}
}

WindowsTools= {
  
}

function WindowsTools:getWindowsCfgs()
    return windowsCfgs;
end 


function WindowsTools:getWindowNameByUIName(uiName )
    for k,v in pairs(windowsCfgs) do
        if v.ui ==uiName then
            return k
        end
    end
    error("not find cfgs by uiName:"..tostring(uiName))
    return nil
end


--根据UIname获取windowName
function WindowsTools:getClassByUIName( uiName )
    local url = viewsPackage
    for k,v in pairs(windowsCfgs) do
        if v.ui == uiName then
            --如果是没有包路径
            if v.package =="" or not v.package then
                url = url.."."..k
            else
                url = url..".".. v.package.."."..k
            end

            break
        end
    end

    if url == viewsPackage then
        error("not file uinameCfgs:"..tostring(uiName))
        return
    end

    -- echo(uiName,"_______________uiName",url)
    local windowClass = require(url)
    return windowClass
end

--根据WindowName 获取 class
function WindowsTools:getClassByWindowName(windowName )
    local url = viewsPackage
    local cfg = windowsCfgs[windowName]
    if cfg.package =="" or not cfg.package then
        url = url..".".. windowName
    else
        url = url.."." ..cfg.package.."." .. windowName
    end
end

--获取uiname
function WindowsTools:getUiName(viewName )
    local cfg = windowsCfgs[viewName]
    if not viewName then
        error("not fint viewName cfgs:"..tostring(viewName))
    end
    return cfg.ui
end

-- 获得ui配置信息
function WindowsTools:getUiCfg(viewName )
    local cfg = windowsCfgs[viewName]
    if not cfg then
        cfg = {}
        echoError("没有对应窗口的ui配置"..viewName)
    end
    -- 设置默认值
    cfg.level = cfg.level and cfg.level or 2
    cfg.cache = cfg.cache and cfg.cache or false
    cfg.style = cfg.style and cfg.style or 0
    cfg.pos   = cfg.pos and cfg.pos or {x=0,y=GameVars.height}

    return cfg
end

--创建Window 
function WindowsTools:createWindow(windowName,...)
    if not windowsCfgs[windowName] then 
        return nil
    end
    
    local uiName = self:getUiName(windowName)
    local classModel = self:getClassByWindowName(windowName)
    return UIBaseDef:createUIByName(uiName,classModel,...)
end



function WindowsTools.showFloatBar(text, x, y, handler)
    local scene = display.getRunningScene()
    local barX = x or GameVars.cx-- + 80
    local barY = y or GameVars.cy-- - 150

    local layer = display.newColorLayer(cc.c4b(0,0,0,150)):addTo(scene):zorder(6)

    layer:setTouchEnabled(true)
    layer:setTouchSwallowEnabled(true)
    layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "ended" then
            if not scene.updateNewer then
                if handler then handler() end
                layer:removeSelf()
            end
        end     
        return true
    end)    

    local textF = display.newTTFLabel({text = text, size = 24, color = cc.c3b(255,0,0)})
            :addTo(layer)
            :pos(barX,barY)

    textF:runAction( 
        transition.sequence({
        act.delaytime(0.5), 
        act.spawn(act.moveby(1, cc.p(0, 150)), act.fadeto(1, 1)), 
        act.callfunc(function() 
            layer:removeSelf() 
            if handler then handler() end 
            end)
        }))
end

