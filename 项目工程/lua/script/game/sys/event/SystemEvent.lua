--其他系统相关事件 比如时间更新, 比如 apk更新通知等
local SystemEvent = {}

SystemEvent.SYSTEMEVENT_APPENTERBACKGROUND = "SYSTEMEVENT_APPENTERBACKGROUND"  		--失去游戏焦点  参数  {time ,usec }
SystemEvent.SYSTEMEVENT_APPENTERFOREGROUND = "SYSTEMEVENT_APPENTERFOREGROUND" 		--恢复游戏焦点  参数  {time ,usec ,dt} )




return SystemEvent