--
-- Author: guanfeng
-- Date: 2016-1-06
--
--家园人物进出

local HomeServer = class("HomeServer")

function HomeServer:init()
	echo("HomeServer:init");
	EventControler:addEventListener(HomeEvent.GET_ONLINE_PLAYER_EVENT,
		self.checkOnlinePlayer, self);

	EventControler:addEventListener(HomeEvent.GET_ONLINE_PLAYER_EVENT_AGAIN,
		self.checkOnlinePlayerAgain, self);
end

function HomeServer:checkOnlinePlayer()
	-- echo("HomeServer:checkOnlinePlayer")
	local params = {
		rids = nil
	};
	Server:sendRequest(params, MethodCode.user_getOnlinePlayer_319,
		c_func(HomeServer.checkOnlinePlayerCallBack, self), false, false);
end

function HomeServer:checkOnlinePlayerCallBack(event)
	-- dump(event.result, "__checkOnlinePlayerCallBack__");

	--发事件
    EventControler:dispatchEvent(HomeEvent.GET_ONLINE_PLAYER_OK_EVENT, 
    	{onLines = event.result.data.onlines});
end

function HomeServer:checkOnlinePlayerAgain(data)
	-- dump(data.params.rids, "HomeServer:checkOnlinePlayerAgain")

	local params = {
		rids = data.params.rids
	};

	Server:sendRequest(params, MethodCode.user_getOnlinePlayer_319,
		c_func(HomeServer.checkOnlinePlayerAgainCallBack, self), false, false);
end

function HomeServer:checkOnlinePlayerAgainCallBack(event)
	-- dump(event, "__checkOnlinePlayerCallBack__");
	--发事件
    EventControler:dispatchEvent(HomeEvent.GET_ONLINE_PLAYER_EVENT_OK_AGAIN, 
    	{onLines = event.result.data.onlines});
end

-- 领取事件奖励
function HomeServer:getEventReward(eventId, callBack)
	echo("eventId", tostring(eventId));
	local params = {
		eventId = eventId,
	}
	Server:sendRequest(params, MethodCode.user_getEventReward_309, callBack)
end

--获得最屌玩家
function HomeServer:getDiaoestPlayer(callBack)
	echo(" getDiaoestPlayer ");
	local params = {

	}
	Server:sendRequest(params, MethodCode.home_getBest_3401, callBack)
end

function HomeServer:worship(typeworship,callBack)
	echo(" worship " , tostring(typeworship));
	local params = {
		type = typeworship,
	}
	Server:sendRequest(params, MethodCode.home_worship_3403, callBack)
end


HomeServer:init();

return HomeServer












