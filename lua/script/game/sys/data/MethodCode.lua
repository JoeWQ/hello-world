--
-- Author: xd
-- Date: 2015-11-24 20:55:40
--
--
local MethodCode = {}

MethodCode.sys_heartBeat = "heartBeat" 			--请求心跳
MethodCode.sys_init = "init" 					--系统初始化


--测试通信协议请求json串接口
MethodCode.test_getJsonDesc_100105 = 100105 	
MethodCode.test_getJsonDesc2_100103 = 100103 	

--用户相关模块
MethodCode.user_loginout_203 = 203 				--用户登出
MethodCode.user_login_205 = 205 				--用户登入
MethodCode.user_register_207 = 207 				--注册用户
MethodCode.user_selectZone_209 = 209 			--用户选区
MethodCode.user_serverList_211 = 211 			--服务器列表
MethodCode.user_guest_login_217 = 217			--试玩登录
MethodCode.user_bind_account_219 = 219			--账号绑定

MethodCode.user_getUserInfo_301 = 301 			--拉取用户信息

MethodCode.user_buySp_305 = 305 				--购买体力
MethodCode.base_dataUpdate_308 = 308			--底层数据更新
MethodCode.user_getEventReward_309 = 309		--领取事件奖励
MethodCode.user_getMp_311 = 311					--领取法力
MethodCode.user_clearCD_313 = 313				--清空cd
MethodCode.user_state_315 = 315					--连接
MethodCode.user_set_avatar_323 = 323			--设置主角形象
MethodCode.user_set_role_name_325 = 325			--设置角色名字
MethodCode.user_check_role_name_327 = 327		--检查主角名字
MethodCode.user_change_role_name_329 = 329		--修改主角名字

--家园系统
MethodCode.user_getOnlinePlayer_319 = 319       --获取在线玩家
--购买铜钱/金币
MethodCode.user_buyCoin_311 = 331     --购买金币

MethodCode.get_recharge_reward_341=341    --领取首冲奖励

--法宝系统
MethodCode.treasure_upgradeLevel_401 =401 		--法宝强化
MethodCode.treasure_upgradeStar_403 =403 		--法宝升星
MethodCode.treasure_upgradeState_405 =405 		--法宝进阶   
MethodCode.treasure_setFormula_407 =407 		--设置法宝阵型
MethodCode.treasure_combine_409 =409 		    --法宝合成

--战斗模块
MethodCode.battle_joinRoom_701 = 701 			--加入房间
MethodCode.battle_start_705 = 705 				--战斗开始
MethodCode.battle_receiveFragment_711 = 711 	--接收时间片
MethodCode.battle_releaseMagic_713 = 713 		--释放法宝
MethodCode.battle_reveiveBattleResult_717 = 717 		--战斗结果验证
MethodCode.battle_changeAutoBattleFlag_721 = 721 		--切换自动/手动战斗状态
MethodCode.battle_receiveCheatCase_725 = 725 			--客户端上报发现作弊
MethodCode.battle_quitRoom_729 = 729 					--退出房间
MethodCode.battle_loadBattleResOver_733 = 733 			--加载战斗资源完成
MethodCode.battle_pullTimeLine_737 = 737 		--获取时间片
MethodCode.battle_repet_loadover_745 = 745 				--加载完毕
MethodCode.battle_getInfo_749 = 749 		
MethodCode.battle_user_quit_battle_753 = 753 	-- 玩家退出战斗


-- 背包模块
MethodCode.item_customItem_801 = 801 			--使用道具
MethodCode.item_buyKey_803 = 803 				--购买钥匙


--匹配模块
MethodCode.match_battleStart_901 = 901 			--战斗开始匹配
MethodCode.match_joinIntive_903 = 903 			--战斗加入邀请


-- PVP模块
MethodCode.pvp_buyPVP_1101 = 1101             -- 购买pvp挑战次数
MethodCode.pvp_refreshPVP_1103 = 1103         -- 刷新pvp数据
MethodCode.pvp_startChallenge_1105 = 1105     -- pvp开始战斗
MethodCode.pvp_reportBattleResult_1107 = 1107 -- pvp上报战斗结果
MethodCode.pvp_pullBattleRecord_1109 = 1109   -- pvp拉取战斗记录
MethodCode.pvp_flushShop_1111 = 1111          -- 刷新pvp商店
MethodCode.pvp_shopBuyItem_1113 = 1113        -- pvp购买商店物品
MethodCode.pvp_recordTitle_1117 = 1117		  -- 记录已经获得的最大称号
MethodCode.pvp_player_detail_1119 = 1119   --查看角色详情
MethodCode.pvp_challenge_player_1121 = 1121 --竞技场挑战对手
MethodCode.pvp_challenge5_times_1123 = 1123 --挑战5次
MethodCode.pvp_get_pvp_report_1125 = 1125           --获取竞技场战报详情
MethodCode.pvp_rank_exchange_1127 = 1127            --竞技场排名兑换 
MethodCode.pvp_score_reward_1129 = 1129                 --竞技场积分奖励

MethodCode.pve_upLoadStage_1201 = 1201 			--上传PVE章节完成状态
MethodCode.pve_enterMainStage_1201 = 1201 		--PVE进入副本
MethodCode.pve_reportBattleResult_1203 = 1203 	--PVE汇报战斗结果
MethodCode.pve_enterEliteStage_1205 = 1205 		--GVE进入
MethodCode.pve_openStarBox_1209 = 1209 			--PVE打开星宝箱
MethodCode.pve_openExtraBox_1211 = 1211 		--打开额外宝箱
MethodCode.pve_sweep_1213 = 1213				--PVE扫荡接口

--公会
MethodCode.guild_create_1301 = 1301        --公会创建
MethodCode.guild_find_1303 = 1303          --查询公会
MethodCode.guild_list_1305 = 1305 		   --公会列表
MethodCode.guild_members_1307 = 1307 	   --公会成员
MethodCode.guild_apply_1309 = 1309 		   --加入公会
MethodCode.guild_apply_list_1311 = 1311    --公会申请列表
MethodCode.guild_apply_judge_1313 = 1313    --入会审批
MethodCode.guild_modify_info_1315 = 1315   --修改公会信息
MethodCode.guild_modify_member_right_1317 = 1317   --修改权限
MethodCode.guild_kick_member_1319 = 1319   --踢人
MethodCode.guild_quit_1321 = 1321   --退出公会
MethodCode.guild_cancel_apply_1323 = 1323  --取消申请
MethodCode.guild_invite_1325 = 1325  --公会邀请



--邮件
MethodCode.mail_requestMail_1501 = 1501 		--取邮件
MethodCode.mail_getAttachment_1503 = 1503 		--领取附件



--商店
MethodCode.shop_getInfo_1601 = 1601 			--获取商店信息
MethodCode.shop_refresh_1603 = 1603 			--刷新商店
MethodCode.shop_unlockShop_1605 = 1605 			--解锁商店
MethodCode.shop_buyGoods_1607 = 1607 			--购买道具
MethodCode.norandshop_buygoods_3903 = 3903		--购买商品
MethodCode.norandshop_refresh_3901 = 3901		--购买商品

--商店
MethodCode.romance_giveGift_2401    = 2401			--赠送礼物
MethodCode.romance_interact_2405    = 2405			--进行一次互动
MethodCode.romance_story_2403		= 2403			--节点事件
MethodCode.romance_buyinteract_2407 = 2407			--购买互动次数
--排行榜
MethodCode.rank_getRankList_1701 = 1701 		--获取各类排行榜排名信息
MethodCode.rank_getPlayerInfo_1703 = 1703 		--获取排行榜玩家数据
MethodCode.rank_getGuildInfo_1705 = 1705 		--获取公会数据


--试炼
MethodCode.trial_start_battle_1801 = 1801
MethodCode.trial_end_battle_1803 = 1803
MethodCode.trial_normal_battle_1805 = 1805
MethodCode.trial_sweep_battle_1807 = 1807

-- 新问情
MethodCode.elite_challenge_mark_2403 = 2403      -- 挑战
MethodCode.elite_exchange_mark_2405 = 2405       -- 兑换
MethodCode.elite_buy_2407 = 2407                 -- 购买

--签到
MethodCode.sign_mark_1901 = 1901 		    --签到
MethodCode.sign_markTotal_1903 = 1903		--总签到	   

--欢乐签到
MethodCode.happysign_mark_4001 = 4001 	

--抽卡
MethodCode.lottery_token_2101 = 2101 		--令牌抽
MethodCode.lottery_gold_one_2103 = 2103		--钻石单抽
MethodCode.lottery_gold_ten_2105 = 2105		--钻石十连抽



--熔炼
MethodCode.smelt_smelt_items_2301 = 2301		--熔炼物品
MethodCode.smelt_exchange_items_2303 = 2303	--兑换商品
MethodCode.smelt_flush_shop_info_2305 = 2305 --刷新灵宝殿
MethodCode.smelt_shop_buy_item_2307 = 2307	--灵宝殿购买商品

--任务
MethodCode.quest_getDailyQuest_reward_2503 = 2503
MethodCode.quest_getMainLineQuest_reward_2501 = 2501

--爬塔
MethodCode.tower_start_fight_2601 = 2601         --开始探索
MethodCode.tower_reset_fight_count_2603 = 2603   --重置战斗次数
MethodCode.tower_open_teasuer_box_2609 = 2609    --开启宝箱
MethodCode.tower_start_auto_fight_2605 = 2605    --扫荡
MethodCode.tower_fight_over_2611 = 2611    --爬塔结束
--MethodCode.tower_auto_fight_immediately_finish_2611 = --立即完成
MethodCode.tower_auto_fight_finish_2607 =  2607--结束扫荡，领取奖励
MethodCode.tower_achievement_reward_2613 =  2613--成就奖励
MethodCode.tower_request_paihangbang_2615 =  2615--排行榜

MethodCode.tower_fight_Over_result_2611 = 2611 --爬塔战斗结果小场

--cdkey兑换
MethodCode.cdkey_exchange_2701 = 2701 --cdkey兑换

--好友系统
MethodCode.friend_user_motto2901=2901           --修改玩家的签名
MethodCode.friend_page_list2903=2903               --获取好友列表中的好友信息
MethodCode.friend_apply_list2905=2905              --获取好友申请列表
MethodCode.friend_recommend_list2907=2907   --获取推荐好友列表
MethodCode.friend_search_list2909=2909            --获取搜索好友列表
MethodCode.friend_apply_request2911=2911         --请求向对方申请好友请求
MethodCode.friend_approve_request2913=2913    --同意对方好友申请请求
MethodCode.friend_reject_request2915=2915        --拒绝对方申请好友请求
MethodCode.friend_remove_request2917=2917     --删除好友
MethodCode.friend_send_sp2919 =2919                 --向好友赠送体力
MethodCode.friend_achieve_sp2921=2921             --获取好友赠送的体力

--获取公告
MethodCode.get_notice_3101 = 3101 --获取公告

-- 主角
MethodCode.char_qualitry_levelup_349 = 349				--主角升品

MethodCode.yongan_gamble_get_achievement_3201 = 3201 --天玑赌肆领取成就
MethodCode.yongan_gamble_roll_the_dice_3203 = 3203 --天玑赌肆掷骰子
MethodCode.yongan_gamble_change_role_fate_3205 = 3205 --改投
MethodCode.yongan_gamble_end_role_3207 = 3207 --见好就收

--新手引导
MethodCode.tutor_finish_groupId_333 = 333


--荣耀事件
MethodCode.home_getBest_3401 = 3401
MethodCode.home_worship_3403 = 3403

MethodCode.starlight_activate_3301 = 3301

--聊天系统
MethodCode.chat_send_message_world_3501=3501 --向世界聊天中发送信息
MethodCode.chat_send_message_league_3503=3503--向联盟聊天中发送信息
MethodCode.chat_send_message_private_3505=3505--向私聊页面中发送信息
MethodCode.chat_send_battle_info_3507=3507--分享战报
MethodCode.chat_battle_info_play_3509=3509--战报回放
MethodCode.query_player_info_337=337--//查询角色信息

--活动
MethodCode.act_finish_task_3601 = 3601 --完成活动任务、领奖励、或者兑换奖励

--充值
MethodCode.recharge_temp_2203 = 2203    --临时充值接口
MethodCode.recharge_2205 = 2205    --临时充值接口

--购买礼包
MethodCode.vip_buy_gift_343 = 343    --购买vip礼包


-- 神明
MethodCode.god_activite_4101 = 4101 --神明激活
MethodCode.god_setFormula_4103 = 4103 --神明上阵
MethodCode.god_activiteGroove_4105 = 4105 --饰品激活
MethodCode.god_upgradeLevel_4107 = 4107 --神明强化

--伙伴
MethodCode.partner_combine_4201 = 4201 --伙伴合成
MethodCode.partner_equipment_levelup_4203 = 4203 --伙伴装备升级
MethodCode.partner_star_leveup_4205 = 4205 --伙伴升星
MethodCode.partner_quality_levelup_4207 =4207 --伙伴升品
MethodCode.partner_skill_levelup_4209 = 4209 --伙伴技能升级
MethodCode.partner_soul_levelup_4211 = 4211 --伙伴仙魂升级
MethodCode.partner_fragment_exchange_4217 = 4217 --伙伴碎片兑换
MethodCode.partner_quality_item_combine_4219 = 4219--伙伴升品道具合成
MethodCode.partner_quality_item_equip_4213 = 4213--伙伴升品道具装备
MethodCode.partner_skill_point_buy_4215 = 4215--伙伴技能点购买
MethodCode.partner_equipment_upgrade_4221 = 4221--伙伴装备升级

--上阵  执行上阵操作
MethodCode.formation_doformation_347 = 347




--新抽奖
MethodCode.lottery_replace_2105 = 2105   ---奖池替换
MethodCode.lottery_freeDrawcard_2101 = 2101 --免费抽奖
MethodCode.lottery_consumeDrawcard_2103 = 2103 --元宝抽

return MethodCode







