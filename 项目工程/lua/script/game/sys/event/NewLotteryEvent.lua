--三皇抽奖系统
--2016-1-4 20:20
--@Author:wukai

--//三皇抽奖事件
local   NewLotteryEvent=NewLotteryEvent or {};

NewLotteryEvent.REFRESH_FREE_UI = "REFRESH_FREE_UI"  --刷新免费抽奖界面
NewLotteryEvent.REFRESH_RMBPAY_UI = "REFRESH_RMBPAY_UI" --刷新元宝抽奖界面
NewLotteryEvent.START_LOTTERY = "START_LOTTERY" --开始抽奖
NewLotteryEvent.RESUME_REWARD_ITEMS = "RESUME_REWARD_ITEMS" --繼續顯示獎勵
NewLotteryEvent.BLACK_LOTTERY_MAIN = "BLACK_LOTTERY_MAIN" --返回到
NewLotteryEvent.DELETE_LITTERY_LAYER = "DELETE_LITTERY_LAYER" ---删除商店层
NewLotteryEvent.REFRESH_MAIN_UI = "REFRESH_MAIN_UI" ---替换特效监听界面
NewLotteryEvent.ADD_EILLPSE_EFFECT = "ADD_EILLPSE_EFFECT" -- 添加抽奖后的替换特效
NewLotteryEvent.REFRESH_LOTTERY_SHOP_UI = "REFRESH_LOTTERY_SHOP_UI"
NewLotteryEvent.GET_AUDIO_BLACK_MAIN = "GET_AUDIO_BLACK_MAIN"  --获得界面音乐返回


return  NewLotteryEvent;