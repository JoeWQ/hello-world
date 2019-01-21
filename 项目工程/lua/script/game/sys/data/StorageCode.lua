--
-- Author: xd
-- Date: 2015-11-26 16:50:11
--本地存储的一些key

--用户模块
local StorageCode ={}
StorageCode.username = "username" 					--用户名
StorageCode.userpassword = "userpassword" 			--用户密码
StorageCode.debugInputData = "debugInputData" 		--调试输出的数据 json串

StorageCode.romance_interact_sweep_open_mark = "romance_interact_sweep_open_mark"
StorageCode.romance_interact_first_open_mark = "romance_interact_first_open_mark"

StorageCode.login_last_server_id = "login_last_server_id"
StorageCode.login_last_server_index = "login_last_server_index"
StorageCode.login_last_server_name = "login_last_server_name"

StorageCode.device_id = "device_id" --记录设备id
StorageCode.login_type = "login_type" --记录是游客登录(guest),还是账号登录(account)
StorageCode.last_login_type = "last_login_type" --用于新游客第一次登录之后判断是否提示账号升级

--设置
StorageCode.setting_music_st = "setting_music_st"
StorageCode.setting_sound_st = "setting_sound_st"
StorageCode.setting_show_player_st = "setting_show_player_st"
StorageCode.setting_battle_music_st = "setting_battle_music_st"
StorageCode.setting_battle_sound_st = "setting_battle_sound_st"

--新手引导发送给数据中心的最后一步
StorageCode.tutorial_last_send_to_center = "tutorial_last_send_to_center"
--没有完成的非强制引导
StorageCode.tutorial_showing_triggerGroup = "tutorial_showing_triggerGroup"

-- 释放法宝引导
StorageCode.tutorial_use_treasure = "tutorial_use_treasure"

--[[
所有的阵型信息保存在本地
]]
StorageCode.all_team_formation = "all_team_formation__"

return StorageCode


