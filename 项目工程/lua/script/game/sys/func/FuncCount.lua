FuncCount = FuncCount or {}

local data = nil;

-- 计数类型
FuncCount.COUNT_TYPE = {
	COUNT_TYPE_BUY_SP = "1",                  -- 购买体力
	COUNT_TYPE_BUY_MP = "2",                  -- 购买法力
	COUNT_TYPE_BUY_PVP = "3",                 -- 购买PVP
	COUNT_TYPE_PVPCHALLENGE = "4",            -- PVP挑战次数
	COUNT_TYPE_LEADER_KICK = "5" ,            -- 会长踢人次数
	COUNT_TYPE_JUNIOR_SHOP_FLUSH_TIMES = "6", -- 最低档商店刷新刷次
	COUNT_TYPE_MEDIUM_SHOP_FLUSH_TIMES = "7", -- 中档档商店刷新刷次
	COUNT_TYPE_SENIOR_SHOP_FLUSH_TIMES = "8", -- 高档档商店刷新刷次
	COUNT_TYPE_SIGN_RECEIVE_RETIO = "9",      -- 已领取签到奖励基础奖励倍数(普通人1 vip领取2)
	COUNT_TYPE_SIGN_DAYS = "10",              -- 签到天数
	COUNT_TYPE_TRIAL_TYPE_TIMES_1 = "11",     -- 试炼类型1进入次数
	COUNT_TYPE_TRIAL_TYPE_TIMES_2 = "12",     -- 试炼类型2进入次数
	COUNT_TYPE_TRIAL_TYPE_TIMES_3 = "13",     -- 试炼类型3进入次数
	COUNT_TYPE_SMELT_REFRESH_TIMES_SOUL = "16", --熔炼商店使用宝物精华刷新的次数
	COUNT_TYPE_TOWER_RESET = "17",
	COUNT_TYPE_PVP_SHOP_REFRESH_TIMES = "18", -- 竞技场商店刷新次数
    COUNT_TYPE_ACHIEVE_SP_COUNT="19",--玩家领取的好友赠送的体力的数目
    COUNT_TYPE_USER_BUY_COIN_TIMES="21",--//玩家购买铜钱的次数
    COUNT_TYPE_GAMBLE_COUNT = "22",		--天玑赌肆每日投掷骰子次数
    COUNT_TYPE_GAMBLE_CHANGE_FATE_COUNT = "23", --每日改投次数
    COUNT_TYPE_HONOR_COUNT = "24", --膜拜次数
    COUNT_TYPE_WORLD_CHAT_COUNT="25",--每日世界聊天最大免费次数
    COUNT_TYPE_CHAR_SHOP_REFRESH_TIMES = "26", --侠义值商店刷新次数
    COUNT_TYPE_FREE_RECHARGE_TIMES = "27", --每日领取仙玉次数数
    COUNT_TYPE_GODUPGRADE_COIN_TIMES = "28", --神明铜钱强化次数
    COUNT_TYPE_GODUPGRADE_GLOD_TIMES = "29", --神明仙玉强化次数
    -- COUNT_TYPE_DEFENDER_COUNT = "100",  		 --守护紫萱的挑战次数
    COUNT_TYPE_PARTNER_SKILL_POINT_TIMES = "32",--伙伴技能点购买次数
    COUNT_TYPE_NEWLOTTERY_FREE_TIMES = "33",    ---免费抽卡次数
    COUNT_TYPE_NEWLOTTERY_GOLD_FREE_TIMES = "34",    ---元宝免费抽卡次数
    COUNT_TYPE_NEWLOTTERY_GOLD_FAY_TIMES = "35",    ---元宝付费抽卡次数
    COUNT_TYPE_NEWLOTTERY_MANY_REFRESH_TIMES = "36",    ---铜钱刷新次数 --toDo

}


function FuncCount.init()
    data = require("common/Count");
end

function FuncCount.getHour(id)
    local t = data[tostring(id)];
    if t == nil then 
        echo("FuncCount.getHour id nil " .. tostring(id));
    else 
        local value = t["h"];
        if value == nil then 
            echo("FuncCount.getHour id h is nil " .. tostring(id));
        else 
            return value;
        end 
    end 
end

function FuncCount.getMinute(id)
	local default = 0
	local t = data[tostring(id)]
	if not t then
		return default
	else
		local value = t['m']
		return tonumber(value) or 0
	end
end



