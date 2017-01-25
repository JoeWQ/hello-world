--
-- Author: zq
-- Date: 2016-8-16
--

local HappySignServer = class("HappySignServer")

--签到
function HappySignServer:mark(dayId,callBack)
	echo("mark");
	Server:sendRequest({ day = dayId }, MethodCode.happysign_mark_4001, callBack );
end



return HappySignServer