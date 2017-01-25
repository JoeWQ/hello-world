--
-- Author: guan
-- Date: 2016-1-26
--

local SignServer = class("SignServer")

--签到当天
function SignServer:mark(callBack)
	echo("mark");
	local params = {

	}
	Server:sendRequest(params, MethodCode.sign_mark_1901, callBack )
end

--累计签到
function SignServer:totalMark(callBack, targetDay)
	echo("totalMark:" .. tostring(targetDay));
	local params = {
		days = tonumber(targetDay),
	}
	Server:sendRequest(params,MethodCode.sign_markTotal_1903, callBack);
end

return SignServer