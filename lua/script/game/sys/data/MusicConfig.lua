--
-- User: ZhangYanGuang
-- Date: 15-5-14
-- 音效配置
--
MusicConfig = {
	--test
	test = 'test',
	s_com_click1 ="s_com_click1",                       -- 点击按钮1          -- 通用 : 点击关闭/返回按钮
	s_com_click2 ="s_com_click2",                       -- 点击按钮2          -- 通用 : 点击非关闭/返回/标签按钮
	s_com_lvl_up ="s_com_lvl_up",                     -- 人物升级           -- 通用 : 玩家角色升级时
	s_com_tip ="s_com_tip",                             -- 弹出TIPS           -- 通用 : 显示tips
	s_com_moveTip ="s_com_moveTip",                     -- 显示移动浮窗       -- 通用 : 显示移动浮窗
	s_com_fixTip ="s_com_fixTip",                       -- 显示固定浮窗       -- 通用 : 显示固定浮窗
	s_com_appearBtn ="s_com_appearBtn",                 -- 浮现新的按钮       -- 通用 : 浮现新的按钮
	s_com_cover ="s_com_cover",                         -- 盖章               -- 通用 : 需要以盖章形式在界面内出现新的图片时
	s_com_numChange ="s_com_numChange",                 -- 数字变化           -- 通用 : 数字发生滚动时
	s_com_unlock = "s_com_unlock",						-- 解锁时
	s_com_reward = "s_com_reward",                      --领取奖励
	s_com_buycopper = "s_com_buycopper",                 --购买铜钱

	s_lottery_reward1 ="s_lottery_reward1",             -- 弹出抽卡奖励1      -- 抽卡 : 抽卡抽出低中价值物品
	s_lottery_reward2 ="s_lottery_reward2",             -- 弹出抽卡奖励2      -- 抽卡 : 抽卡抽出高价值物品
	s_lottery_getTreasure ="s_lottery_getTreasure",     -- 获得完整法宝       -- 抽卡 : 获得新的完整法宝时

	s_treasure_qianghua ="s_treasure_qianghua",         -- 强化法宝时         -- 法宝养成 : 强化法宝时
	s_treasure_qianghuaOK ="s_treasure_qianghuaOK",     -- 强化法宝成功       -- 法宝养成 : 强化法宝成功时
	s_treasure_jinglian ="s_treasure_jinglian",         -- 精炼法宝时         -- 法宝养成 : 精炼法宝时
	s_treasure_jinglianOK ="s_treasure_jinglianOK",     -- 精炼法宝成功       -- 法宝养成 : 精炼法宝成功时
	s_treasure_shengxing ="s_treasure_shengxing",       -- 升星法宝时         -- 法宝养成 : 升星法宝时
	s_treasure_shengxingOK ="s_treasure_shengxingOK",   -- 升星法宝成功       -- 法宝养成 : 升星法宝成功时
	s_treasure_combining ="s_treasure_combining",       -- 合成法宝时         -- 法宝养成 : 用碎片和完整法宝合成法宝的过程中
	s_treasure_combineOK ="s_treasure_combineOK",       -- 合成法宝成功       -- 法宝养成 : 合成法宝完成时
	s_treasure_shentongup ="s_treasure_shentongup",     -- 法宝神通等级提升   -- 法宝养成 : 法宝神通等级提升时
	s_treasure_ronglian ="s_treasure_ronglian",         -- 熔炼完成时         -- 法宝养成 : 熔炼完成，法宝碎片转化为灵气时

	s_trial_jiefeng ="s_trial_jiefeng",                 -- 封印燃烧           -- 试炼 : 试炼玩法解封

	s_romance_haogan1 ="s_romance_haogan1",             -- 好感提升1          -- 奇缘 : 事件中好感度小幅提升时，高还原仙3音效
	s_romance_haogan2 ="s_romance_haogan2",             -- 好感提升2          -- 奇缘 : 事件中好感度大幅提升时，高还原仙3音效
	s_romance_event1 ="s_romance_event1",               -- 特殊事件触发时     -- 奇缘 : 奇缘互动中触发特殊事件时
	s_romance_event2 ="s_romance_event2",               -- 节点事件开始时     -- 奇缘 : 节点事件开始时
	s_romance_levelup ="s_romance_levelup",             -- 好感度升级         -- 奇缘 : 好感度等级提升时

	s_world_open ="s_world_open",                       -- 问情宝鉴开启       -- 世界 : 六界界面中，问情图标上出现新的NPC头像时

	s_plot_dihan ="s_plot_dihan",                       -- 滴汗               -- 剧情对话 : 剧情对话中立绘挂滴汗表情时
	s_plot_fennu ="s_plot_fennu",                       -- 愤怒               -- 剧情对话 : 剧情对话中立绘挂愤怒表情时
	s_plot_gantan ="s_plot_gantan",                     -- 感叹号             -- 剧情对话 : 剧情对话中立绘挂感叹号表情时
	s_plot_gaoxing ="s_plot_gaoxing",                   -- 高兴               -- 剧情对话 : 剧情对话中立绘挂高兴表情时
	s_plot_yiwen ="s_plot_yiwen",                       -- 疑问               -- 剧情对话 : 剧情对话中立绘挂疑问表情时
	s_plot_shangxin ="s_plot_shangxin",                 -- 伤心               -- 剧情对话 : 剧情对话中立绘挂伤心表情时
	s_plot_yunxun ="s_plot_yunxun",                     -- 晕眩               -- 剧情对话 : 剧情对话中立绘挂晕眩表情时
	s_plot_move ="s_plot_move",                         -- 人物走动           -- 剧情对话 : 人物立绘移动时

	s_scene_1 ="s_scene_1",                             -- 风沙声             -- 场景 :
	s_scene_2 ="s_scene_2",                             -- 火焰燃烧声         -- 场景 :
	s_scene_3 ="s_scene_3",                             -- 鬼气森森声         -- 场景 :
	s_scene_4 ="s_scene_4",                             -- 寒风凛冽声         -- 场景 :
	s_scene_5 ="s_scene_5",                             -- 鸟语花香声         -- 场景 :
	s_scene_6 ="s_scene_6",                             -- 水流声             -- 场景 :

	s_battle_enter_1 ="s_battle_enter_1",               -- 空间撕裂           -- 战斗 : 战斗中角色出场特效同步
	s_battle_enter_2 ="s_battle_enter_2",               -- 梦境波纹           -- 战斗 : 战斗中角色出场特效同步
	s_battle_enter_3 ="s_battle_enter_3",               -- 御剑进场           -- 战斗 : 战斗中角色出场特效同步
	s_battle_enter_4 ="s_battle_enter_4",               -- 烟雾散开           -- 战斗 : 战斗中角色出场特效同步
	s_battle_enter_5 ="s_battle_enter_5",               -- 召唤出现           -- 战斗 : 战斗中角色出场特效同步
	s_battle_win ="s_battle_win",                       -- 战斗胜利           -- 战斗 : 战斗胜利时
	s_battle_pvp_win = "s_battle_pvp_win",				-- 战斗胜利           -- 战斗 : pvp战斗胜利时
	s_battle_pvp_lose = "s_battle_pvp_lose",			-- 战斗失败 		  -- 战斗 ：pvp战斗失败时
	s_battle_lose ="s_battle_lose",                     -- 战斗失败           -- 战斗 : 战斗失败时
	s_battle_falitisheng ="s_battle_falitisheng",       -- 法力增长           -- 战斗 : 法力值提升时
	s_battle_xueyu ="s_battle_xueyu",                   -- 血玉触发           -- 战斗 : 触发血玉效果时
	s_battle_clickTreasure ="s_battle_clickTreasure",   -- 点击使用法宝       -- 战斗 : 点击可使用的法宝UI
	s_battle_shunyi ="s_battle_shunyi",                 -- 瞬移               -- 战斗 : 向前/向后瞬移时体现速度感
	s_battle_bengkui ="s_battle_bengkui",               -- 法宝崩溃           -- 战斗 : 法宝崩溃时
	s_battle_xiaoni ="s_battle_xiaoni",                 -- 法宝消弭           -- 战斗 : 法宝消弭是
	s_battle_jichu ="s_battle_jichu",                   -- 祭出法宝           -- 战斗 : 法宝被祭出时
	s_battle_behited ="s_battle_behited",               -- 防御类法宝受击     -- 战斗 : 防御类法宝被攻击
	s_battle_gain ="s_battle_gain",                     -- 状态上升           -- 战斗 : 威能上升、被施加了增益状态
	s_battle_health ="s_battle_health",                 -- 血量回复           -- 战斗 : 血量上升
	s_battle_switch ="s_battle_switch",                 -- 切换场景           -- 战斗 :
	s_battle_dao ="s_battle_dao",                       -- 刀剑类近战攻击     -- 战斗 :
	s_battle_jian ="s_battle_jian",                     -- 剑系法术释放       -- 战斗 :
	s_battle_bing ="s_battle_bing",                     -- 冰系法术释放       -- 战斗 :
	s_battle_lei ="s_battle_lei",                       -- 雷系法术释放       -- 战斗 :
	s_battle_san ="s_battle_san",                       -- 伞类法术释放       -- 战斗 :
	s_battle_fu ="s_battle_fu",                         -- 符系法术释放       -- 战斗 :
	s_battle_huo ="s_battle_huo",                       -- 火系法术释放       -- 战斗 :
	s_battle_shui ="s_battle_shui",                     -- 水墨类法术释放     -- 战斗 :
	s_battle_gong ="s_battle_gong",                     -- 弓箭类法术释放     -- 战斗 :
	s_battle_huan ="s_battle_huan",                     -- 环类投掷技能释放   -- 战斗 :
	s_battle_qin ="s_battle_qin",                       -- 琴类法术释放       -- 战斗 :
	s_battle_liaqiping ="s_battle_liaqiping",           -- 两气瓶法宝技能释放 -- 战斗 :
	s_battle_tianyaofan ="s_battle_tianyaofan",         -- 天妖幡法宝技能释放 -- 战斗 :
	s_battle_xutianding ="s_battle_xutianding",         -- 虚天鼎法宝技能释放 -- 战斗 :
	s_battle_zhangtianyin ="s_battle_zhangtianyin",     -- 掌天印法宝技能释放 -- 战斗 :
	s_battle_jianmz ="s_battle_jianmz",                 -- 剑系法术命中       -- 战斗 :
	s_battle_bingmz ="s_battle_bingmz",                 -- 冰系法术命中       -- 战斗 :
	s_battle_leimz ="s_battle_leimz",                   -- 雷系法术命中       -- 战斗 :
	s_battle_sanmz ="s_battle_sanmz",                   -- 伞类法术命中       -- 战斗 :
	s_battle_fumz ="s_battle_fumz",                     -- 符系法术命中       -- 战斗 :
	s_battle_huomz ="s_battle_huomz",                   -- 火系法术命中       -- 战斗 :
	s_battle_shuimz ="s_battle_shuimz",                 -- 水墨类法术命中     -- 战斗 :
	s_battle_gongmz ="s_battle_gongmz",                 -- 弓箭类法术命中     -- 战斗 :
	s_battle_huanmz ="s_battle_huanmz",                 -- 环类投掷技能命中   -- 战斗 :
	s_battle_qinmz ="s_battle_qinmz",                   -- 琴类法术命中       -- 战斗 :
	s_battle_liaqipingmz ="s_battle_liaqipingmz",       -- 两气瓶法宝技能命中 -- 战斗 :
	s_battle_tianyaofanmz ="s_battle_tianyaofanmz",     -- 天妖幡法宝技能命中 -- 战斗 :
	s_battle_xutiandingmz ="s_battle_xutiandingmz",     -- 虚天鼎法宝技能命中 -- 战斗 :
	s_battle_zhangtianyinmz ="s_battle_zhangtianyinmz", -- 掌天印法宝技能命中 -- 战斗 :

	s_formation_come = "s_formation_come",				--阵容界面打开
	s_formation_move = "s_formation_move",
	s_formation_out = "s_formation_out",
	s_formation_yijian = "s_formation_yijian",			--布阵界面一键布阵

	--音乐 m is short for music
	m_scene_start = "m_scene_start",	--登入场景
	m_scene_main = "m_scene_main",		--主场景
	m_scene_battle = "m_scene_battle",	--战斗场景
	m_scene_pve = "m_scene_pve",		--PVE场景背景音乐

	s_scene_luck  = "s_scene_luck",    				--三皇抽卡主界面 			-- 抽卡 : 背景音乐
	s_scene_Luck_turn = "s_scene_Luck_turn",		--三皇抽卡旋转开始			-- 抽卡 : 旋转开始音乐
	s_scene_luck_get = "s_scene_luck_get",    		--三皇抽卡获得界面 			-- 抽卡 : 获得音乐
	s_scene_luck_icon  = "s_scene_luck_icon",		--三皇抽卡获得界面			-- 抽卡 ：显示图标items的音乐
	s_scene_luck_large = "s_scene_luck_large",      --三皇抽卡获得卡牌界面		-- 抽卡 ：显示获得卡牌界面时的音乐
	s_scene_luck_single = "s_scene_luck_single"     --三皇抽卡旋转获得特效界面	-- 抽卡 ：显示获得束光音乐
}

return MusicConfig
