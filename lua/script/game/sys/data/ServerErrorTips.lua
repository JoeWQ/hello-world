local ServerErrorTips = {
	--begin 公共错误
	["10000"] ={ tip = nil, code_num="unknown_notok_error",},                                      -- NotOk message 未定义
	["10001"] ={ tip = nil, code_num="param_error",},                                              -- 参数错误
	["10002"] ={ tip = nil, code_num="op_error",},                                                 -- op错误
	["10003"] ={ tip = nil, code_num="cid_error",},                                                -- game_sso:错误
	["10004"] ={ tip = nil, code_num="uid_error",},                                                -- uid错误
	["10005"] ={ tip = 1, code_num="name_or_passwd_error",},                                     -- 用户名密码错误
	["10006"] ={ tip = nil, code_num="ban_login",},                                                -- 账号封停
	["10007"] ={ tip = nil, code_num="ban_chat",},                                                 -- 账号禁言
	["10008"] ={ tip = nil, code_num="to_error",},                                                 -- 送达Id错误
	["10009"] ={ tip = nil, code_num="relogin_error",},                                            -- 多点登陆
	["10010"] ={ tip = nil, code_num="dao_not_exists",},                                           -- 模板id不存在
	["10011"] ={ tip = nil, code_num="dao_param_error",},                                          -- 模板数据错误
	["10012"] ={ tip = nil, code_num="stage_locked",},                                             -- 主线没有开启
	["10013"] ={ tip = nil, code_num="user_level_not_enough",},                                    -- 玩家等级不足
	["10014"] ={ tip = nil, code_num="item_not_enough",},                                          -- 物品数量不足
	["10015"] ={ tip = nil, code_num="user_coin_not_enough",},                                     -- 金币不足
	["10016"] ={ tip = nil, code_num="user_mp_not_enough",},                                       -- 法力不足
	["10017"] ={ tip = nil, code_num="user_sp_not_enough",},                                       -- 行动力不足
	["10018"] ={ tip = nil, code_num="come_from_error",},                                          -- 物品获得-消耗来源错误
	["10019"] ={ tip = nil, code_num="user_gold_not_enough",},                                     -- 钻石不足
	["10020"] ={ tip = nil, code_num="user_in_cd",},                                               -- 用户冷却CD中
	["10021"] ={ tip = nil, code_num="user_no_cd",},                                               -- 用户无冷却CD
	["10022"] ={ tip = nil, code_num="cd_id_can_not_clear",},                                      -- 此类型CD无法清除
	["10023"] ={ tip = nil, code_num="numeric_error",},                                            -- 数据表错误
	["10024"] ={ tip = nil, code_num="module_check_error",},                                       -- 没有达到激活条件
	["10025"] ={ tip = nil, code_num="user_not_exists",},                                          -- 玩家不存在
	["10026"] ={ tip = nil, code_num="no_user_to_join_battle",},                                   -- 没有足够的玩家加入队伍
	["10027"] ={ tip = nil, code_num="user_not_idle",},                                            -- 用户未空闲(在匹配或战斗)
	["10028"] ={ tip = nil, code_num="sec_not_exists",},                                           -- 大区不存在
	["10029"] ={ tip = nil, code_num="user_viplevel_not_enough",},                                 -- 用户vip等级不足
	["10030"] ={ tip = nil, code_num="state_locked",},                                             -- 境界没有开启
	["10031"] ={ tip = nil, code_num="elite_locked",},                                             -- 精英没有开启
	["10032"] ={ tip = nil, code_num="user_token_not_enough",},                                    -- 令牌不足
	["10033"] ={ tip = nil, code_num="session_error",},                                            -- session错误
	["10034"] ={ tip = nil, code_num="user_copper_not_enough",},                                   -- 铜牌不足
	["10035"] ={ tip = nil, code_num="user_soul_not_enough",},                                     -- 宝物精华不足
	["10036"] ={ tip = nil, code_num="function_error",},                                           -- 方法无法使用
	["10037"] ={ tip = nil, code_num="server_error",},                                             -- server错误
	["10038"] ={ tip = nil, code_num="cid_expire",},                                               -- cid过期
	["10039"] ={ tip = nil, code_num="user_not_online",},                                          -- 用户不在线(断线没有调用连接接口)
	["10040"] ={ tip = nil, code_num="user_online_expire",},                                       -- 用户在线状态已过期
	["10041"] ={ tip = nil, code_num="config_error",},                                             -- config配置错误
	["10042"] ={ tip = nil, code_num="pvpcoin_not_enough",},                                       -- pvp货币不足
	["10043"] ={ tip = nil, code_num="connection_url_miss",},                                      -- 连接URL不存在
	["10044"] ={ tip = nil, code_num="num_can_not_zero",},                                         -- 数量不能为0
	["10045"] ={ tip = nil, code_num="platform_error",},                                           -- 平台错误
	["10046"] ={ tip = nil, code_num="string_illegal",},                                           -- 含有特殊字符
	["10047"] ={ tip = nil, code_num="string_length_limit",},                                      -- 字符长度不符
	["10048"] ={ tip = nil, code_num="ban_word",},                                                 -- 敏感词
	--end 公共error
	
	--begin GM error
	["15001"] ={ tip = nil, code_num="authenticate_error",},                                       -- 签名验证错误
	["15002"] ={ tip = nil, code_num="sec_id_has_use",},                                           -- 服务器Id已占用
	--end GM error

	--begin 账户系统
	["20101"] ={ tip = 1, code_num="create_user_passport_already_exist",},                       -- 账户被占用
	["21301"] ={ tip = nil, code_num="mostsdk_login_error",},                                      -- mostsdk登录失败
	--end 账户系统

	--begin 用户系统
	["30501"] ={ tip = nil, code_num="buy_sp_times_max",},                                         -- 达到今日购买上限
	["30502"] ={ tip = nil, code_num="buy_sp_limit",},                                             -- 达到今日购买上限
	["30701"] ={ tip = nil, code_num="event_not_exists",},                                         -- 事件不存在
	["30702"] ={ tip = nil, code_num="event_bonus_not_exists",},                                   -- 事件奖励不存在
	["30901"] ={ tip = nil, code_num="get_mp_times_max",},                                         -- 达到今日了领取上限
	["30902"] ={ tip = nil, code_num="get_mp_vip_limit",},                                         -- 领取法力vip限制
	["30903"] ={ tip = nil, code_num="get_mp_treasure_not_enough",},                               -- 可进行灵力事件的法宝不足5个
	["32301"] ={ tip = nil, code_num="user_avatar_has_set",},                                      -- 形象已设置
	["32501"] ={ tip = nil, code_num="user_name_has_set",},                                        -- 用户名已设置
	["32502"] ={ tip = 1, code_num="user_name_has_use",},                                        -- 用户名已被占用
	--end 用户系统
	
	--begin 法宝error
	["40101"] ={ tip = nil, code_num="user_treasure_not_found",},                                  -- 法宝不存在
	["40102"] ={ tip = nil, code_num="user_treasure_status_wrong",},                               -- 法宝已被分解
	["40103"] ={ tip = nil, code_num="treasure_state_not_enough",},                                -- 法宝境界不足
	["40301"] ={ tip = nil, code_num="treasure_star_max",},                                        -- 法宝已满星
	["40501"] ={ tip = nil, code_num="treasure_state_max",},                                       -- 法宝已达到最高境界
	["40502"] ={ tip = nil, code_num="treasure_level_not_enough",},                                -- 法宝等级不足以进阶
	["40503"] ={ tip = nil, code_num="user_state_not_enough",},                                    -- 主角境界不足
	["40901"] ={ tip = nil, code_num="treasure_combine_user_already_own_treasure",},               -- 法宝合成：法宝已存在
	["40902"] ={ tip = nil, code_num="treasure_combine_state_not_enough",},                        -- 法宝合成：法宝未圆满
	--end 法宝error
	["50101"] ={ tip = nil, code_num="holy_exists",},                                              -- 神器已存在
	["50102"] ={ tip = nil, code_num="holy_not_exists",},                                          -- 神器不存在
	["50301"] ={ tip = nil, code_num="holy_status_error",},                                        -- 神器状态错误
	["50302"] ={ tip = nil, code_num="holy_num_not_enough",},                                      -- 神器格数不足
	["50303"] ={ tip = nil, code_num="holy_space_not_enough",},                                    -- 神器空间不足
	["60101"] ={ tip = nil, code_num="state_not_exists",},                                         -- 境界不存在
	["60102"] ={ tip = nil, code_num="point_not_exists",},                                         -- 节点不存在
	["60103"] ={ tip = nil, code_num="point_level_max",},                                          -- 节点已达满级
	["60104"] ={ tip = nil, code_num="att_cost_not_exists",},                                      -- 节点消耗模板不存在
	["60105"] ={ tip = nil, code_num="father_point_not_exists",},                                  -- 父节点未激活
	["60301"] ={ tip = nil, code_num="adv_not_exists",},                                           -- 精纯不存在
	["60302"] ={ tip = nil, code_num="adv_exists",},                                               -- 精纯已经存在
	["70101"] ={ tip = nil, code_num="room_in_campaign",},                                         -- 房间在战斗中，无法进房
	["72901"] ={ tip = nil, code_num="user_not_in_this_room",},
	["72902"] ={ tip = nil, code_num="room_not_found",},
	["70501"] ={ tip = nil, code_num="user_lack_in_room",},
	["73301"] ={ tip = nil, code_num="battle_not_found",},
	["71101"] ={ tip = nil, code_num="user_not_in_this_battle",},                                  -- 用户不在战斗中
	["71102"] ={ tip = nil, code_num="battle_has_finished",},                                      -- 战斗已结束
	["71701"] ={ tip = nil, code_num="poolSystemId_error",},                                       -- poolSystem错误
	["80101"] ={ tip = nil, code_num="item_cannot_be_used",},                                      -- 该道具不能被使用
	["80102"] ={ tip = nil, code_num="user_item_not_found",},                                      -- 没找到该道具
	["80301"] ={ tip = nil, code_num="item_cannot_buy",},                                          -- 道具不能被购买
	["90101"] ={ tip = nil, code_num="match_condition_not_reach",},                                -- 匹配系统未达成条件


	--竞技场                                                                                       -- pvp 竞技场
	["110101"] ={ tip = nil, code_num="buy_pvp_times_max",},                                       -- pvp购买次数达到上限
	["110501"] ={ tip = 1, code_num="opponent_rank_have_changed",},                              -- pvp挑战：对手名次发生变化
	["110502"] ={ tip = 1, code_num="opponent_in_challenge",},                                   -- pvp挑战：对手正在被挑战
	["110503"] ={ tip = 1, code_num="pvp_challenge_times_not_enough",},                          -- pvp挑战：挑战次数不足
	["110504"] ={ tip = 1, code_num="user_rank_cannot_challenge_top3",},                         -- pvp挑战：用户处于10名以后无法挑战前3名
	["110505"] ={ tip = nil, code_num="user_not_in_opponents",},                                   -- pvp挑战：打的人不在对手列表中
	["110506"] ={ tip = 1, code_num="user_pvprank_changed",},                                    -- pvp挑战：用户名称发生变化
	["110507"] ={ tip = 1, code_num="user_cannot_challenge_lower_rank",}, -- pvp挑战：用户不能挑战排名低于自己的对手
	["110701"] ={ tip = nil, code_num="pvp_battleId_error",},                                      -- pvp上报挑战结果:battleId错误
	["110702"] ={ tip = nil, code_num="pvp_battle_has_finished",},                                 -- pvp上报挑战结果:该战斗已结算完成
	["110703"] ={ tip = nil, code_num="user_not_in_pvp_battle",},                                  -- pvp上报挑战结果:用户不在这场战斗中
	["110704"] ={ tip = nil, code_num="pvp_challenge_swap_busy",},                                 -- pvp上报挑战结果:未能成功交换排名
	["111301"] ={ tip = 1, code_num="pvp_shop_goods_cannot_buy",},                               -- pvp商店：商品已售罄s

	["120101"] ={ tip = nil, code_num="stage_complete",},                                          -- 副本已经通关
	["120102"] ={ tip = nil, code_num="stage_type_error",},                                        -- 副本类型错误
	["120103"] ={ tip = nil, code_num="chapter_complete",},                                        -- 章节已经通关
	["120301"] ={ tip = nil, code_num="stage_not_exists",},                                        -- 副本未创建
	["120901"] ={ tip = nil, code_num="chapter_reward_received",},                                 -- 奖励已经领取
	["120902"] ={ tip = nil, code_num="chapter_star_not_enough",},                                 -- 未完成奖励条件
	["130101"] ={ tip = nil, code_num="guild_exists",},                                            -- 公会已经存在
	["130102"] ={ tip = nil, code_num="guild_name_illegal",},                                      -- 公会名称非法
	["130103"] ={ tip = nil, code_num="guild_name_empty",},                                        -- 公会名称为空
	["130104"] ={ tip = nil, code_num="guild_name_used",},                                         -- 公会名称已用
	["130105"] ={ tip = nil, code_num="guild_state_not_enough",},                                  -- 主角境界不足
	["130301"] ={ tip = nil, code_num="guild_not_exists",},                                        -- 公会不存在
	["130901"] ={ tip = nil, code_num="guild_quit_cd",},                                           -- 退会cd中
	["130902"] ={ tip = nil, code_num="guild_member_full",},                                       -- 公会成员已满
	["130903"] ={ tip = nil, code_num="guild_apply_full",},                                        -- 公会申请已满
	["130904"] ={ tip = nil, code_num="user_guild_apply_full",},                                   -- 玩家申请已满
	["131101"] ={ tip = nil, code_num="guild_user_not_exists",},                                   -- 玩家不在公会中
	["131102"] ={ tip = nil, code_num="user_right_not_enough",},                                   -- 没有操作权限
	["131301"] ={ tip = nil, code_num="guild_user_exists",},                                       -- 玩家已有公会
	["131302"] ={ tip = nil, code_num="guild_apply_not_exists",},                                  -- 玩家申请不存在
	["131701"] ={ tip = nil, code_num="guild_right_error",},                                       -- 权限错误
	["131702"] ={ tip = nil, code_num="guild_longtime_not_login",},                                -- 长时间未登陆
	["131703"] ={ tip = nil, code_num="guild_too_much_master",},                                   -- 长老太多了
	["131901"] ={ tip = nil, code_num="guild_leader_kick_limit",},                                 -- 超过今日踢人次数
	["150101"] ={ tip = nil, code_num="mail_reward_error",},                                       -- 邮件奖励配置错误
	["150301"] ={ tip = nil, code_num="mail_not_exists",},                                         -- 邮件不存在
	["150302"] ={ tip = nil, code_num="mail_has_expire",},                                         -- 邮件已过期
	["150303"] ={ tip = nil, code_num="mail_has_read",},                                           -- 邮件已读取
	["160501"] ={ tip = nil, code_num="shop_has_already_open",},                                   -- 商店已经永久解封
	["160502"] ={ tip = nil, code_num="shop_in_temp_open_status",},                                -- 商店处于临时开启状态
	["160701"] ={ tip = nil, code_num="goods_buytimes_max",},                                      -- 商品已售罄
	["170101"] ={ tip = nil, code_num="rank_type_error",},                                         -- 排行榜类型错误
	["180101"] ={ tip = nil, code_num="trial_locked",},                                            -- 试炼未开启
	["180102"] ={ tip = nil, code_num="trial_type_error",},                                        -- 试炼类型错误
	["180103"] ={ tip = nil, code_num="trial_times_max",},                                         -- 超过试炼每日次数
	["180104"] ={ tip = nil, code_num="trial_battle_not_exists",},                                 -- 试炼挑战不存在
	["180105"] ={ tip = nil, code_num="trial_is_activate",},                                       -- 试炼已激活
	["180501"] ={ tip = nil, code_num="trial_not_activate",},                                      -- 试炼未激活
	["180502"] ={ tip = nil, code_num="trial_must_sweep",},                                        -- 试炼必须扫荡
	["180701"] ={ tip = nil, code_num="trial_can_not_sweep",},                                     -- 试炼不能扫荡
	["190101"] ={ tip = nil, code_num="sign_has_mark",},                                           -- 已经签到
	["190201"] ={ tip = nil, code_num="sign_days_not_reach",},                                     -- 累计签到次数不足
	["190202"] ={ tip = nil, code_num="sign_total_reward_has_receive",},                           -- 累计奖励已经领取
	["202701"] ={ tip = nil, code_num="method_doc_not_write",},                                    -- 注释没有添加
	["210101"] ={ tip = nil, code_num="lottery_loot_empty",},                                      -- 掉落错误
	["220101"] ={ tip = nil, code_num="mostsdk_data_error",},
	["220102"] ={ tip = nil, code_num="mostsdk_unknown_callback_ip",},
	["220103"] ={ tip = nil, code_num="mostsdk_param_error",},
	["220104"] ={ tip = nil, code_num="mostsdk_appid_error",},
	["220105"] ={ tip = nil, code_num="mostsdk_sign_error",},
	["220106"] ={ tip = nil, code_num="mostsdk_repeat_lock_order",},
	["220107"] ={ tip = nil, code_num="mostsdk_repeat_order",},
	["220109"] ={ tip = nil, code_num="mostsdk_cash_error",},
	["220110"] ={ tip = nil, code_num="mostsdk_role_id_error",},
	["220111"] ={ tip = nil, code_num="order_callback_param_error",},
	["220112"] ={ tip = nil, code_num="order_callback_sign_error",},
	["220113"] ={ tip = nil, code_num="order_callback_role_id_error",},
	["230101"] ={ tip = nil, code_num="smelt_count_error",},                                       -- 熔炼物品超过最大值
	["230102"] ={ tip = nil, code_num="item_can_not_smelt",},                                      -- 物品无法熔炼
	["230103"] ={ tip = nil, code_num="smelt_item_count_error",},                                  -- 熔炼物品数量错误
	["230301"] ={ tip = nil, code_num="smelt_has_exchange",},                                      -- 物品已经兑换
	["230302"] ={ tip = nil, code_num="total_soul_not_enough",},                                   -- 总宝物精华不足
	["230501"] ={ tip = nil, code_num="smelt_shop_empty",},                                        -- 商品错误
	["230502"] ={ tip = nil, code_num="smelt_shop_flush_times_max",},                              -- 刷新次数达到上限
	["230701"] ={ tip = nil, code_num="smelt_shop_goods_not_exists",},                             -- 商品不存在
	["230701"] ={ tip = nil, code_num="smelt_shop_goods_sold",},                                   -- 商品已出售

	                                                                                               -- 奇缘
	["240101"] ={ tip = nil, code_num="romance_not_exists",},                                      -- 奇缘npc没有激活
	["240102"] ={ tip = nil, code_num="romance_level_max",},                                       -- 奇缘npc好感度达到最大值
	["240103"] ={ tip = nil, code_num="item_is_not_gift",},                                        -- 物品不能赠送
	["240104"] ={ tip = nil, code_num="romance_exp_max",},                                         -- 奇缘npc好感度溢出
	["240301"] ={ tip = nil, code_num="romance_node_finished",},                                   -- 奇缘npc节点事件已完成
	["240302"] ={ tip = nil, code_num="romance_choose_error",},                                    -- 奇缘节点事件id错误
	["240501"] ={ tip = nil, code_num="romance_interact_not_exists",},                             -- 奇缘互动没有激活
	["240502"] ={ tip = nil, code_num="romance_interact_limit",},                                  -- 奇缘互动达到每日上限
	["240503"] ={ tip = nil, code_num="romance_can_not_sweep",},                                   -- 奇缘互动不能扫荡
	["240701"] ={ tip = nil, code_num="romance_interact_can_not_buy",},                            -- 奇缘互动不能购买

	["250101"] ={ tip = nil, code_num="mainline_quest_id_error",},                                 -- 主线任务：id不在应领取奖励id数组中
	["250102"] ={ tip = nil, code_num="mainline_quest_not_complete",},                             -- 主线任务：没有完成
	["250301"] ={ tip = nil, code_num="everyday_quest_not_complete",},                             -- 每日任务没有完成
	["250303"] ={ tip = nil, code_num="everyday_quest_reward_received",},                          -- 每日任务奖励已经领取
	["250305"] ={ tip = nil, code_num="everyday_quest_month_card_invalid",},                       -- 每日任务：月卡非法（过期或者不存在）
	["250307"] ={ tip = nil, code_num="everyday_quest_sp_receive_expire",},                        -- 每日任务：不在领取体力时间段
	["250208"] ={ tip = nil, code_num="everyday_request_condition_check_error",},                  -- 每日任务：领取条件未达到
	["260901"] ={ tip = nil, code_num="tower_chest_dao_error",},                                   -- 宝箱数据表错误
	["261301"] ={ tip = nil, code_num="tower_achievement_reward_received",},                       -- 爬塔成就奖励已领取
	["261302"] ={ tip = nil, code_num="tower_floor_not_enough",},                                  -- 爬塔成就奖励，条件未达到
	["270101"] ={ tip = 1, code_num="cdkey_validate_error",},                                    -- 兑换码错误
	["270102"] ={ tip = 1, code_num="cdkey_items_error",},                                       -- 兑换码配置错误
	["270103"] ={ tip = 1, code_num="cdkey_active_error",},                                      -- 兑换码激活错误
}
return ServerErrorTips
