--
-- Author: xd
-- Date: 2015-11-28 14:38:15
--主要是用来一些通知事件  格式  methodcode = 事件name 收到通知的时候 会发送一个消息出去  
local NotifyEvent = {
	[340] = "notify_trot_lamp_340",						--//系统公告消息推送

	[704] = "notify_battle_userJoinRoom_704", 			--战斗 玩家加入房间
	[708] = "notify_battle_start_708",					--战斗开始 
	[710] = "notify_battle_pushTimeLine_710",			--战斗 服务器拉取时间片
	[716] = "notify_battle_useTreasure_716" , 			--战斗 广播 使用法宝
	[724] = "notify_battle_useAutoFight_724" , 			--战斗 自动战斗
	[720] = "notify_battle_gameResult_720",				--战斗广播结果
	[732] = "notify_battle_userQuitRoom_732",			--战斗 玩家退出房间
	[736] = "notify_battle_loadBattleResOver_736",		--战斗 加载战斗资源完成，开始战斗
	[740] = "notify_battle_userDrop_740",				--战斗 玩家掉线(暂离)
	[744] = "notify_battle_addOnePlayer_744",			--战斗 加入新玩家
	[748] = "notify_battle_addToBattle_748",			--战斗 玩家中途加入
	[756] = "notify_battle_user_quit_battle_756",		--战斗 玩家离开,不玩了
	[760] = "notify_battle_someOne_hasReady_760",		--战斗 玩家中途加入

	[906] = "notify_match_intive_906",					--邀请加入系统匹配
	[908] = "notify_match_timeout_908",					--匹配超时失败
	
	[1116] = "notify_pvp_new_fight_resport_1116",		--竞技场有新的战报

	[1208] = "notify_world_gve_match_battle_end_1208",	--六界GVE战斗结束
	[1506] = "notify_mail_receive_1506",				--收到邮件

	[1810] = "notify_trial_match_battle_end_1810",      --试炼战斗结束

    [2924] = "notify_friend_apply_request_2924",		--收到其他玩家申请加好友的请求
    [2926] ="notify_friend_send_sp_2926",           	--收到好友赠送的体力

    [3512] = "notify_chat_world_3512",					--//聊天系统,世界聊天消息推送
    [3514] = "notify_chat_league_3524",					--//聊天系统,仙盟聊天消息推送
    [3516] = "notify_chat_private_3516",					--//私聊消息推送

    [999723] = "notify_need_update_client_999723",		--//有新版本发布消息推送
}


NotifyEvent.notifyUpdateClientCode = 999723



return NotifyEvent
