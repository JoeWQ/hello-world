--
-- Author: xd
-- Date: 2015-11-10 17:07:21
--

--通知管理
local NotifyControler = NotifyControler or  {}

--接收到一个通知
function NotifyControler:receivenNotify( notify)
	local  eventName = NotifyEvent[notify.method]
	local result = notify.result
	
	--echo("获取一条通知-----:",notify.method,eventName)
	--dump(notify)
	
	--如果对应了 通知名称  那么 发送这个通知出去 
	if eventName then
		EventControler:dispatchEvent(eventName,notify)
	end

	--如果有pushId  那么必须给一个反馈

end

return NotifyControler


