local WebHttpServer = class("WebHttpServer")

WebHttpServer.POST_TYPE = {
	POST = "POST",
	GET = "GET"
}

function WebHttpServer:ctor()
	self.curConn = nil
	self.connCache = {}
	self.serverErrorTip = nil
end


function WebHttpServer:sendRequest(params, url, postType, headers, callBack)

	local connInfo = {params = params,url = url,postType = postType,headers = headers ,callBack = callBack }
	if self.curConn then
		echo("__当前请求正在发送中")
		table.insert(self.connCache, connInfo )
		return
	end

	self.curConn = connInfo

	local url = url
	--get:拼接url
	if postType == WebHttpServer.POST_TYPE.GET then
		url = self:turnGetUrl(url, params)
	end
	local request= network.createHTTPRequest(c_func(self.onHttpCallBack,self, callBack), url, postType)
	
	--post
	if postType == WebHttpServer.POST_TYPE.POST then
		for k,v in pairs(params) do
			request:addPOSTValue(k,v)
		end
	end

	headers = headers or {}
	for _, header in pairs(headers) do
		request:addRequestHeader(header)
	end

	request:start()
end

function WebHttpServer:reSendRequest()
	if self.curConn then
		local connInfo = self.curConn
		self.curConn = nil
		self:sendRequest(connInfo.params, connInfo.url, connInfo.postType, connInfo.headers, connInfo.callBack)
	end
end

-- 临时方案，设置服务器异常提醒
function WebHttpServer:setServerErrorTip(serverErrorTip)
	self.serverErrorTip = serverErrorTip
end

function WebHttpServer:onHttpCallBack(callBack, message)
	local req = message.request
	--如果连接失败
	if message.name =="failed" then

		if self.curConn ~= nil then
			--那么设置重连函数
			local tipView = WindowControler:showTopWindow("CompServerOverTimeTipView")
			if self.serverErrorTip then
				tipView:setTipContent(self.serverErrorTip)
			end
			tipView:setCallFunc(c_func(self.reSendRequest,self))
		end

		echo("WebHttpServer http请求失败,请检查网络---")
		return
	end

	if message.name ~="completed" then
		--说明请求失败--
		return
	end

	local state = req:getState()
	local statusCode = req:getResponseStatusCode()

	if state==5 then --超时
		echo("WebHttpServer:http请求超时---")
		if self.curConn ~= nil then
			--那么设置重连函数
			WindowControler:showTopWindow("CompServerOverTimeTipView"):setCallFunc(c_func(self.reSendRequest,self))
		end
		return
	end

	local responseData = req:getResponseData()
	
	if statusCode~=200 then --非200，说明出错了
		echoWarn("WebHttpServer:http请求错误,statusCode",statusCode)
		-- return
	end

	if DEBUG_CONNLOGS ==2 then
		echo("WebHttpServer: responceInfo:", responseData)
	end
	
	local resData = {}
	resData.code = statusCode
	resData.data = json.decode(responseData)
	self.curConn = nil
	callBack(resData)

	if #self.connCache > 0 and not self.curConn then
		local connInfo = self.connCache[1]
		table.remove(self.connCache,1)
		echo("继续发送请求")
		self:sendRequest(connInfo.params, connInfo.url, connInfo.postType, connInfo.headers, connInfo.callBack)
	end

end

function WebHttpServer:turnGetUrl(url, params)
	if not params or not next(params) then
		return url
	end
	local ret = {}
	for k,v in pairs(params) do
		table.insert(ret, string.format("%s=%s", k,v))
	end
	local url = string.format("%s?%s", url, table.concat(ret, "&"))
	return url
end

return WebHttpServer.new()
