--三皇抽奖系统
--2016-12-27 10:40
--@Author:wukai


local NewLotteryServer = { }

function NewLotteryServer:ctor()


end 
--开始免费抽奖协议 一次（次数）
--开始免费抽奖协议 五次（次数）
--(参数0 免费，1造物卷，5造物卷)
function NewLotteryServer:freeDrawcard(type,_cllback)
	local Params = {type = type} 
	Server:sendRequest( Params, MethodCode.lottery_freeDrawcard_2101, _cllback,false,false,true)
end
--开始消耗元宝抽奖协议 0,1,10（次数）
function NewLotteryServer:consumeDrawcard(type,isGold,_cllback)
	local Params = {
		type = type,
		isGold = isGold,
	}
	Server:sendRequest( Params, MethodCode.lottery_consumeDrawcard_2103, _cllback,false,false,true)
end


-- --显示替换奖池界面数据
-- function NewLotteryServer:getawardpooldata(_cllback)
-- 	local Params = {}
-- 	-- Server:sendRequest( Params, MethodCode.lottery_replace_2105, _cllback)
-- end

--刷新按钮协议
function NewLotteryServer:Refreshbutton(shopType,_cllback)
	ShopServer:refreshShop( shopType ,_cllback )
end

---奖池替换协议(商店类型，商店第几个物品，替换那个位置的物品)
function NewLotteryServer:requestpoolCombineData( shopType ,shopIndex,replaceLotteryIndex,_cllback )
 	local Params = {
 		shopType = tostring(shopType),
 		shopIndex = tostring(shopIndex),
 		replaceLotteryIndex = tostring(replaceLotteryIndex),
	}

	Server:sendRequest( Params, MethodCode.lottery_replace_2105, _cllback,false,false,true)
end 

return NewLotteryServer

