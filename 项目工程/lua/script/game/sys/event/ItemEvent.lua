--道具系统相关事件
local ItemEvent = {}

-- 背包变更
ItemEvent.ITEMEVENT_ITEM_CHANGE = "ITEMEVENT_ITEM_CHANGE"

-- 展示道具详情
ItemEvent.ITEMEVENT_SHOW_ITEM_VIEW = "ITEMEVENT_SHOW_ITEM_VIEW"

-- 点击了一个itemview
ItemEvent.ITEMEVENT_CLICK_ITEM_VIEW = "ITEMEVENT_CLICK_ITEM_VIEW"

-- 打开宝箱，展示结果界面
ItemEvent.ITEMEVENT_OPEN_BOXES_RESULT = "ITEMEVENT_OPEN_BOXES_RESULT"
-- 宝箱钥匙不足跳转到购买界面
ItemEvent.ITEMEVENT_BUY_KEYS = "ITEMEVENT_BUY_KEYS"

return ItemEvent