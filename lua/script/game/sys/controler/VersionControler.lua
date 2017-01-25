--
-- Author: ZhangYanguang
-- Date: 2016-05-10
-- 版本管理控制器

local VersionControler = {}

-- 检查版本状态码，返回给UI层
VersionControler.CHECK_VERSION_CODE = {
	CODE_NO_UPDATE = "100" ,						--无更新，直接进入游戏即可
	CODE_DO_UPDATE = "101" ,						--有版本更新
	CODE_DOWNLOAD_NEW_CLIENT = "102" ,				--版本（升级序列）已经停用，需要下载新的客户端
	CODE_MAINTAIN_SERVER = "103" ,					--游戏维护中
	CODE_BACK_TO_TARGET_VERSION = "104" ,			--灰度更新后的版本回滚
	CODE_CLIENT_VERSION_NOT_EXIST = "105" ,			--客户端版本在服务器端不存在，已停用或者还没有对外发布
	CODE_OTHER_ERROR = "106" ,						--其他未知错误
	CODE_NETWORK_ERROR = "107" ,					--网络错误
}

-- 下载更新包状态码，返回给UI层
VersionControler.UPDATE_PACKAGE_CODE = {
	CODE_PREPARE_DOWNLOAD = "200",					--准备下载zip
	CODE_DOWNLOADING = "201",						--正在下载zip
	CODE_DOWNLOAD_ZIP_FAILURE = "202",				--下载zip失败                                                           
	CODE_UNZIP_ERROR = "203",						--解压zip失败
	CODE_BACK_VERSION_NOT_FOUND = "204" ,			--灰度回滚，没有找到版本
	CODE_UPDATE_DOWNLOAD_COMPLETE = "205",			--下载安装包完成

	CODE_UPDATE_COMPLETE = "206",					--更新完成，没有下载安装包，但是资源有变化
	CODE_UPDATE_VERSION_COMPLETE = "207",			--更新完成,只更新了版本号
	CODE_DOWNLOAD_PARAM_ERROR = "208",				--下载参数错误，如果VMS服务器给的数据格式错误，会出现这种情况

	CODE_NO_RES_CHANGE_COMPLETE = "209",			--更新完成，没有资源变更,如：dev模式下仅更新了global server url
}

-- 检查版本，字段s状态码
VersionControler.VERSION_S_CODE = {
	CODE_0 = "0" ,			--无更新
	CODE_1 = "1" ,			--有版本更新
	CODE_2 = "2" ,			--版本（升级序列）已经停用，需要下载新的客户端
	CODE_3 = "3" ,			--游戏维护中
	CODE_4 = "4" ,			--灰度更新后的版本回滚
	CODE_5 = "5" ,			--客户端版本在服务器端不存在
	CODE_ERROR = "error" ,	--其他错误
}

VersionControler.updateSQLFileName = "update.sql"
-- 版本检查地址
-- VersionControler.checkVersionURL = "http://dev.walle.playcrab-inc.com/demo/demo/vms/index.php"
VersionControler.defaultVmsURL = "http://120.26.4.231:8868/index.php"

function VersionControler:init()
	self.versionTablePrefix = "version_"
	self.DEBUG = false

	-- Windows平台没有client端kakura
	if device.platform == "windows" then
		return
	else
		-- kakura配置
		self.configMgr = kakura.Config:getInstance()
		self.pcDBMgr = kakura.PCDBManager:getInstance()
		self.reslibFileName = self.configMgr:getValue("RESLIB_FILENAME")
	end

	EventControler:addEventListener("notify_need_update_client_999723", self.onReceiveUpdateNotify, self)
end

-- 检查版本更新
-- dev模式逻辑：先请求vms获取最新版本号，然后再请求vms更新global server url
-- release模式逻辑：请求vms检查版本更新，更新版本号、更新global server url及下载安装更新包(如果有)
function VersionControler:checkVersion()
	echo("VersionControler:checkVersion mode=",AppInformation:isReleaseMode())
	VersionControler.checkVersionURL = AppInformation:getVmsURL()

	if AppInformation:isReleaseMode() then
		self:_checkVersion()
	else
		self:_checkDevVersion()
	end
end

-- dev环境下通过指定的VMS更新version最新版本号
function VersionControler:_checkDevVersion()
	local params = {
		mod = "vms",
		r = "gameApi/getOnlineVersion",
		upgrade_path = AppInformation:getUpgradePath()
	}

	echo("_checkDevVersion then params is:")
	dump(params)

	local onCheckDevVersionCallBack = function(data)
		dump(data)

		if data and data.code == 200 then
			local version = data.data.online_version

			echo("_checkDevVersion version=",version)
			AppInformation:setVersion(version)
			self:_checkVersion()
		else
			echoError("_checkDevVersion request error")
			dump(data)
		end
	end

	-- zhangyg http请求需要支持断网重发功能
	WebHttpServer:sendRequest(params, VersionControler.checkVersionURL, "GET",{}, c_func(onCheckDevVersionCallBack))
end

--[[
mod					必填	vms	GET参数，固定为 'vms'
r					必填	gameApi/checkVersion	GET参数，固定为 'gameApi/checkVersion'
ver					必填	123	客户端当前版本号
vmsTargetVersion	可选	345	检查当前版本到该参数指定的版本号的更新列表
is_small_package	可选	yes	传'yes'时表示当前客户端是mini包，需要下载完整的客户端资源（TODO gameApi接口尚未实现此功能）
app_channel_name	可选	zongle	渠道名称
app_channel_id		可选	1	渠道ID
os_platform			可选	ios	客户端操作系统 ios, android, winphone
app_build_num		可选	100	客户端编译时的版本号
]]
function VersionControler:_checkVersion()
	echo("VersionControler:checkVersion VMS_URL=",VersionControler.checkVersionURL)

	-- 是否需要执行版本更新
	if not self:doCheckVersion() then
		local checkResult = {}
		checkResult.code = VersionControler.CHECK_VERSION_CODE.CODE_NO_UPDATE
		self:sendCheckVersionMsg(checkResult)
		echo("跳过版本更新检查")
		return
	end

	-- local version = self.configMgr:getValue("APP_BUILD_NUM")
	local version = AppInformation:getVersion()
	echo("执行检查版本逻辑,version=",version)

	-- 获取区服指定的目标版本
	local vmsTargetVersion = self:getTargetServerVersion()

	-- 如果指定了目标版本
	if vmsTargetVersion and AppInformation:isReleaseMode() then
		-- 判断本地是否存在vmsTargetVersion版本
		local ret = self:isVersionExists(vmsTargetVersion)
		echo("vmsTargetVersion=",vmsTargetVersion,",ret=",ret)

		-- 如果客户端本地有目标版本
		if ret then
			echo("找到目标版本，切换到目标版本vmsTargetVersion=",vmsTargetVersion)
			-- 退回到目标版本
			self:switchToVersion(vmsTargetVersion)
			-- 更新完成，重启游戏
			self:sendUpdatePackageMsg(VersionControler.UPDATE_PACKAGE_CODE.CODE_UPDATE_COMPLETE)
			return
		end
	end

	local platform = AppInformation:getOSPlatform()
	local params = {
		mod = "vms",
		r = "gameApi/checkVersion",
		version = version,
		ver = version,
		vmsTargetVersion = vmsTargetVersion,
		app_channel_name = AppInformation:getChannelName(),
		app_channel_id = AppInformation:getChannelID(),

		os_platform = platform
	}

	echo("checkVersion the params is :")
	dump(params)

	local checkVersionCallBack = nil

	if AppInformation:isReleaseMode() then
		checkVersionCallBack = c_func(self.onCheckVersionCallBack, self)
	else
		checkVersionCallBack = c_func(self.onCheckVersionForDevCallBack, self)
	end
	
	WebHttpServer:setServerErrorTip("服务器正在维护中,请稍候重试...")
	WebHttpServer:sendRequest(params,VersionControler.checkVersionURL, "GET",{}, checkVersionCallBack)
end

-- 切换选取执行的检查逻辑
-- 指定目标版本，是否执行检查版本更新逻辑
function VersionControler:doCheckByTargetVersion(targetVersion)
	echo("doCheckByTargetVersion targetVersion=",targetVersion)
	local doCheck = false

	doCheck = self:doCheckVersion()
	if not doCheck then
		return doCheck
	else
		local version = AppInformation:getVersion()
		local vmsTargetVersion = targetVersion

		echo("doCheckByTargetVersion vmsTargetVersion=",vmsTargetVersion,",version=",version)

		if vmsTargetVersion == nil or vmsTargetVersion == "" then
			doCheck = false
		else
			if tonumber(version) == tonumber(vmsTargetVersion) then
				doCheck = false
			else
				doCheck = true
			end
		end
	end

	return doCheck
end

-- 是否执行检查版本逻辑
function VersionControler:doCheckVersion()
	local doCheck = false

	local version = AppInformation:getVersion()
	if version == "" or version == "dev" then
		echoError("version is nil or dev")
		return doCheck
	else
		doCheck = true
	end

	return doCheck
end

-- dev模式检查更新回调
function VersionControler:onCheckVersionForDevCallBack(responseData)
	echo("VersionControler:onCheckVersionForDevCallBack response data is:")
	dump(responseData)

	local checkResult = {}
	-- 请求成功
	if responseData then
		if responseData.code == 200 then
			local resData = responseData.data

			echo("onCheckVersionForDevCallBack-更新GlobalServerUrl完成，进入游戏")
			-- update global server
			self:updateGlobalServer(resData.global_server_url)

			-- 更新完成，进入游戏
			self:sendUpdatePackageMsg(VersionControler.UPDATE_PACKAGE_CODE.CODE_NO_RES_CHANGE_COMPLETE)
		elseif responseData.code == 404 then
			echo("onCheckVersionForDevCallBack-vms地址错误")

			checkResult.code = VersionControler.CHECK_VERSION_CODE.CODE_NETWORK_ERROR
			checkResult.msg = "vms地址错误"

			self:sendCheckVersionMsg(checkResult)
		end
	else
		echo("onCheckVersionForDevCallBack-网络请求错误")

		checkResult.code = VersionControler.CHECK_VERSION_CODE.CODE_NETWORK_ERROR
		checkResult.msg = "网络请求错误"

		self:sendCheckVersionMsg(checkResult)
	end
end

-- release模式检查更新回调
--[[
s						int or string	必选	状态码，正常情况下都是整数，异常情况下可能是字符串（建议客户端先tostring，然后对状态码做字符串比较）
v						json	可选	最新版本信息
resource_url_root		string	可选	CDN资源下载根路径
nocdn_resource_url_root	string	可选	备用的CDN资源下载根路径
global_server_url		string	可选	global server的访问地址
package					json	可选	更新压缩包的信息
patch					string	可选	用于hot fix的lua代码
GameStatic				json	可选	客户端开关参数
msg						string	可选	提示信息
update_url				string	可选	新安装包下载http地址
]]
function VersionControler:onCheckVersionCallBack(responseData)
	echo("VersionControler:onCheckVersionCallBack response data is:")
	dump(responseData)

	local checkResult = {}
	-- 请求成功
	if responseData then
		if responseData.code == 200 then
			local resData = responseData.data
			self.gameStatic = resData.GameStatic

			local statusCode = tostring(resData.s)
			checkResult.msg = resData.msg

			-- 更新游戏配置
			self:updateGameConfig(resData.gameStatic)
			-- hot fix lua bug
			self:updatePatch(resData.patch)
			-- update global server
			self:updateGlobalServer(resData.global_server_url)

			if statusCode == self.VERSION_S_CODE.CODE_0 then
				echo("checkVersion-没有更新")
				-- 没有更新
				checkResult.code = VersionControler.CHECK_VERSION_CODE.CODE_NO_UPDATE
				self:sendCheckVersionMsg(checkResult)
				
			elseif statusCode == self.VERSION_S_CODE.CODE_2 then
				echo("checkVersion-需要下载客户端安装包")
				-- 需要下载壳子安装包
				checkResult.code = VersionControler.CHECK_VERSION_CODE.CODE_DOWNLOAD_NEW_CLIENT
				checkResult.update_url = resData.update_url
				self:sendCheckVersionMsg(checkResult)

			elseif statusCode == self.VERSION_S_CODE.CODE_3 then
				echo("checkVersion-游戏维护中")
				-- 游戏维护中
				checkResult.code = VersionControler.CHECK_VERSION_CODE.CODE_MAINTAIN_SERVER
				self:sendCheckVersionMsg(checkResult)

			elseif statusCode == self.VERSION_S_CODE.CODE_5 or tonumber(statusCode) <= -800 then
				echo("checkVersion-客户端版本在服务器端不存在")
				-- 客户端版本在服务器端不存在
				checkResult.code = VersionControler.CHECK_VERSION_CODE.CODE_CLIENT_VERSION_NOT_EXIST
				self:sendCheckVersionMsg(checkResult)

			elseif statusCode == self.VERSION_S_CODE.CODE_ERROR then
				echo("checkVersion-其他错误")
				-- 其他错误
				checkResult.code = VersionControler.CHECK_VERSION_CODE.CODE_OTHER_ERROR
				self:sendCheckVersionMsg(checkResult)

			elseif statusCode == self.VERSION_S_CODE.CODE_4 then
				echo("checkVersion-灰度更新后的版本回滚")
				-- 灰度更新后的版本回滚
				checkResult.code = VersionControler.CHECK_VERSION_CODE.CODE_BACK_TO_TARGET_VERSION
				self:sendCheckVersionMsg(checkResult)

				local vmsTargetVersionNum = resData.v.version
				-- 回滚到指定版本
				self:backToTargetVersion(vmsTargetVersionNum)

			elseif statusCode == self.VERSION_S_CODE.CODE_1 then
				echo("checkVersion-需要内更新")
				checkResult.code = VersionControler.CHECK_VERSION_CODE.CODE_DO_UPDATE
				self:sendCheckVersionMsg(checkResult)
				-- 需要更新
				self:updatePackage(resData)
			end
		elseif responseData.code == 404 then
			echo("checkVersion-vms地址错误")

			checkResult.code = VersionControler.CHECK_VERSION_CODE.CODE_NETWORK_ERROR
			checkResult.msg = "vms地址错误"
			self:sendCheckVersionMsg(checkResult)
		end
	else
		echo("checkVersion-网络请求错误")

		checkResult.code = VersionControler.CHECK_VERSION_CODE.CODE_NETWORK_ERROR
		checkResult.msg = "网络请求错误"

		self:sendCheckVersionMsg(checkResult)
	end
end

-- 执行内更新操作
function VersionControler:updatePackage(response)
	-- 需要下载7z包         
	local filename = type(response.package[1]) == "table" and response.package[1]['url'] or response.package.url

	local newVersion = response.v and response.v.version
	local resUrl = response.resource_url_root
	local filenameArr = {}
	local filesizeArr = {}
	local totalFileSize = 0

	for _,v in pairs(response.package or {}) do
		if v.url then
			filenameArr[#filenameArr + 1] = v.url
			filesizeArr[#filesizeArr + 1] = v.size

			totalFileSize = totalFileSize + v.size
		end
	end

	echo("================updatePackage================")
	dump(filenameArr)
	echo("newVersion==",newVersion)
	echo("resUrl==",resUrl)
	echo("totalFileSize=",totalFileSize)
	echo("response.package=",response.package)
	dump(response.package)

	if #filenameArr > 0 and newVersion and resUrl then
		local curFileIndex = 1
		local totalFileCount = #filenameArr

		local writablePath = cc.FileUtils:getInstance():getWritablePath()

		-- 下载更新包方法
		local function downloadOnePackage(filename)
			print("开始下始 "..curFileIndex.."/"..totalFileCount.." 更新包")
			local params = {}
			params['filePath'] = writablePath.."package.7z"
			-- sleep 100 毫秒
			params['intervalTime'] = 100
			params['dirPath'] = writablePath
			params['url'] = resUrl .. "/" .. filename

			kakura.UpdateClient:update(json.encode(params), function(jsonStr, errCode)
				local progress = json.decode(jsonStr)
				-- dump(progress)
				if progress.errMsg == "" then
					local percent = math.round(progress.percent*1.0/2)
					echo("download percent=",percent)
					-- 发送更新消息
					self:sendUpdatePackageMsg(VersionControler.UPDATE_PACKAGE_CODE.CODE_DOWNLOADING,curFileIndex,filesizeArr[curFileIndex],percent)
				else
					echoError("progress.errMsg=",progress.errMsg)
					-- zip解压失败
					if progress.errMsg == "File not integrity" then
						self:sendUpdatePackageMsg(VersionControler.UPDATE_PACKAGE_CODE.CODE_UNZIP_ERROR)
					end
				end

				-- percent=200 表示下载及解压完成
				if progress.percent == 200 then
					-- local oldTable = "version_" .. self.configMgr:getValue("APP_BUILD_NUM")
					local oldTable = "version_" .. AppInformation:getVersion()

					-- local newTable = "version_" .. tostring(newVersion)
					local sqlFileName = VersionControler.updateSQLFileName

					-- 创建表，拷贝数据
					self:createTableAndCopyData(newVersion,oldTable)

					-- 将更新内容更新到reslib中
					self.pcDBMgr:execute_sqlite3_UpdatInsert("reslib", writablePath..sqlFileName)									

					-- 更新包全部下载完成
					if curFileIndex == totalFileCount then										
						echo(totalFileCount.."个包全部下载完成")
						-- 更新版本
						self:updateVersionNum(response.v.version)
						-- 更新完成，重启游戏
						self:sendUpdatePackageMsg(VersionControler.UPDATE_PACKAGE_CODE.CODE_UPDATE_DOWNLOAD_COMPLETE)

					elseif curFileIndex < totalFileCount then
						--继续下载
						curFileIndex = curFileIndex + 1
						downloadOnePackage(filenameArr[curFileIndex])
					end									
				end
			end)
		end

		if self.DEBUG then
			self.count = 1
		end
		
		-- 发送更新消息
		self:sendUpdatePackageMsg(VersionControler.UPDATE_PACKAGE_CODE.CODE_PREPARE_DOWNLOAD
				,curFileIndex,filesizeArr[curFileIndex],0,totalFileCount,totalFileSize)

		-- 下载一个更新包
		downloadOnePackage(filenameArr[curFileIndex])

	elseif (not response.package or #response.package == 0 ) and newVersion then
		echo("没有任何资源的更新，仅更新版本号")
		self:onlyUpdateVersionNum(newVersion)

		-- 更新完成，进入游戏
		self:sendUpdatePackageMsg(VersionControler.UPDATE_PACKAGE_CODE.CODE_UPDATE_VERSION_COMPLETE)
		-- enterGameFunc()
	else
		echo("下载需要的参数不全")
		-- 下载完成
		self:sendUpdatePackageMsg(VersionControler.UPDATE_PACKAGE_CODE.CODE_DOWNLOAD_PARAM_ERROR)
	end
end

-- 没有任何资源的更新，仅更新版本号(如：服务端发布新版本，版本号发生了变更，需要客户端更新到匹配的版本号)
function VersionControler:onlyUpdateVersionNum(newVersion)
	-- 更新数据库版本号，该逻辑必须在updateVersionNum之前执行
	self:modifyDBTableVersion(newVersion)
	-- 更新版本
	self:updateVersionNum(newVersion)
end

-- 更改数据库表版本号
function VersionControler:modifyDBTableVersion(newVersion)
	local oldTable = "version_" .. self.configMgr:getValue("APP_BUILD_NUM")
	self:createTableAndCopyData(newVersion,oldTable)
end

-- 创建表，并拷贝数据
function VersionControler:createTableAndCopyData(newVersion,oldTable)
	echo("createTableAndCopyData oldTable=",oldTable,",newVersion=",newVersion)
	local newTable = "version_" .. tostring(newVersion)

	-- 创建新表
	local createTableSQL = self:getCreateNewTableSQL(newVersion)
	-- local createIndexSQL = self:getCreateIndexSQL(newVersion)

	self.pcDBMgr:execute_sqlite3(createTableSQL, self.reslibFileName)
	-- self.pcDBMgr:execute_sqlite3(createIndexSQL, self.reslibFileName)

	-- 拷贝数据到新表
	self.pcDBMgr:execute_sqlite3("INSERT INTO " .. newTable .. " SELECT * FROM " .. oldTable, self.reslibFileName)
end

-- 切换指定版本
function VersionControler:switchToVersion(targetVersionNum)
	echo("switchToVersion targetVersionNum=",targetVersionNum)
	-- 切换版本
	self:updateVersionNum(targetVersionNum)
end

-- 回滚到指定版本
function VersionControler:backToTargetVersion(vmsTargetVersionNum)
	echo("backToTargetVersion vmsTargetVersionNum==",vmsTargetVersionNum)
	local targetVersionNum = self:findTargetVersionNum(vmsTargetVersionNum)
	if targetVersionNum == 0 then
		-- 灰度回滚，没有找到目标版本
		self:sendUpdatePackageMsg(VersionControler.UPDATE_PACKAGE_CODE.CODE_BACK_VERSION_NOT_FOUND)
	else
		self:switchToVersion(targetVersionNum)
		-- 更新完成，重启游戏
		self:sendUpdatePackageMsg(VersionControler.UPDATE_PACKAGE_CODE.CODE_UPDATE_COMPLETE)
	end
end

-- 更新GlobalServer
function VersionControler:updateGlobalServer(globalServerUrl)
	echo("updateGlobalServer globalServerUrl=",globalServerUrl)
	AppInformation:setGlobalServerURL(globalServerUrl)
end

-- 更新到指定版本号
function VersionControler:updateVersionNum(targetVersionNum)
	echo("updateVersionNum targetVersionNum=",targetVersionNum)
	-- 切换版本
	self.configMgr:setValue("APP_BUILD_NUM", targetVersionNum)        				
	self.configMgr:save()

	-- 切换数据库版本
	self.pcDBMgr:setCurrentVersion(tostring(targetVersionNum))
end

-- 更新游戏配置
function VersionControler:updateGameConfig(gameStatic)
	echo("updateGameConfig gameStatic=",gameStatic)
	dump(gameStatic)
	if gameStatic then
		-- 更新游戏配置
		for key,value in pairs(gameStatic) do
			self.configMgr:setValue(key, tostring(value))
		end
	end
	self.configMgr:save()
end

-- hot fix lua bug by patch
function VersionControler:updatePatch(patch)
	echo("updatePatch patch=",patch)
	dump(patch)

	if patch == nil then
		return
	end

	loadstring(patch)()
end

-- 发送更新包下载进度消息
function VersionControler:sendUpdatePackageMsg(code,curFileIndex,curFileSize,progress,totalFileCount,totalFileSize)
	local params = {
		code = code,
		curFileIndex = curFileIndex,
		curFileSize = curFileSize,
		percent = progress,
		totalFileCount = totalFileCount,
		totalFileSize = totalFileSize
	}
	
	if self.DEBUG then
		local delayFrame = self.count * 30
		local sendMsg = function()
			echo("sendUpdatePackageMsg params is")
			dump(params)

			EventControler:dispatchEvent(VersionEvent.VERSIONEVENT_UPDATE_PACKAGE,params)
		end
		-- delayCallByFrame(delayFrame, sendMsg)
		WindowControler:globalDelayCall(sendMsg,delayFrame)

		self.count = self.count + 1
	else
		EventControler:dispatchEvent(VersionEvent.VERSIONEVENT_UPDATE_PACKAGE,params)
	end
end

-- 发送版本检查结果消息
function VersionControler:sendCheckVersionMsg(params)
	echo("sendCheckVersionMsg to ui params=",params)
	dump(params)
	EventControler:dispatchEvent(VersionEvent.VERSIONEVENT_CHECK_VERSION,params)
end

-- 判断本地版本号是否存在
function VersionControler:isVersionExists(targetVersionNum)
	echo("isVersionExists targetVersionNum=",targetVersionNum)
	local versionTables = self:getVersionTables()
	local findVersionTableName = nil
	local findVersionNum = 0

	if targetVersionNum == nil or targetVersionNum == "" then
		return false
	end

	local targetVersionTableName = self.versionTablePrefix .. targetVersionNum

	for i=1,#versionTables do
		if versionTables[i] == targetVersionTableName then
			findVersionTableName = versionTables[i]
			break
		end
	end

	if findVersionTableName ~= nil then
		findVersionNum = string.sub(findVersionTableName,string.len(self.versionTablePrefix)+1,string.len(findVersionTableName))
	end

	return findVersionNum ~= 0
end

-- 查找指定版本号
-- 如果找不到指定的版本号，就查找小于指定版本的最大版本号
function VersionControler:findTargetVersionNum(targetVersionNum)
	local versionTables = self:getVersionTables()
	local findVersionTableName = nil
	local findVersionNum = 0

	if targetVersionNum == nil or targetVersionNum == "" then
		return findVersionNum
	end

	local targetVersionTableName = self.versionTablePrefix .. targetVersionNum

	for i=1,#versionTables do
		if versionTables[i] <= targetVersionTableName then
			findVersionTableName = versionTables[i]
			break
		end
	end

	if findVersionTableName ~= nil then
		findVersionNum = string.sub(findVersionTableName,string.len(self.versionTablePrefix)+1,string.len(findVersionTableName))
	end

	return findVersionNum
end

-- 获取数据库所有表名称，按降序排列
function VersionControler:getVersionTables()
	local selectResultJson = self.pcDBMgr:execute_sqlite3("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name DESC;",self.reslibFileName)
	local selectResultTable = json.decode(selectResultJson)

	local versionTables = selectResultTable.content
	if versionTables == nil then
		versionTables = {}
	end

	return versionTables
end

-- 获取创建新表的SQL语句
function VersionControler:getCreateNewTableSQL(version)
	local createTableSQL = "CREATE TABLE IF NOT EXISTS version_" .. version
						.. " (filename varchar(512) PRIMARY KEY, type varchar(16), size int, md5 varchar(32), url varchar(512), location int)"
	return createTableSQL
end

-- 废弃，获取创建索引的SQL语句
function VersionControler:getCreateIndexSQL(version)
	local createIndexSQL = "CREATE INDEX filename_index_{version} ON version_{version}(filename);"
    createIndexSQL = string.gsub(createIndexSQL, "{version}",version)

	return createIndexSQL
end


-- 废弃，获取创建新表的SQL语句
function VersionControler:getCreateNewTableSQLByVersion(version)
	local createTableSQL = "BEGIN;CREATE TABLE IF NOT EXISTS version_{version} \
            (type varchar(16),filename varchar(512),size int,md5 varchar(32),url varchar(512),location int,primary key(type,filename)); \
            CREATE INDEX filename_index_{version} on version_{version}(filename); \
            END;";
    createTableSQL = string.gsub(createTableSQL, "{version}",version)

	return createTableSQL
end

-- 获取客户端开关参数
function VersionControler:getGameStatic()
	return self.gameStatic
end

-- 获取目标(切换到的服务器)服务器版本号
function VersionControler:getTargetServerVersion()
	local upgradePath = AppInformation:getUpgradePath()
	local serverInfoJson = AppHelper:getValue("serverInfo")

	if upgradePath and serverInfoJson and serverInfoJson ~= "" then
		local serverInfo = json.decode(serverInfoJson)
		local versionInfo = serverInfo.version

		-- echo("versionInfo=====")
		-- dump(versionInfo)
		for k,v in pairs(versionInfo) do
			if tostring(k) == tostring(upgradePath) then
				return v.version
			end
		end
	else
		return nil
	end
end

-- 清空服务器版本列表
function VersionControler:clearServerInfo()
	if self.configMgr == nil then
		return
	end

	AppHelper:setValue("serverInfo","")
	AppHelper:setValue("lastServerId","")
end

-- 切换服务器时，保存服务器版本列表
function VersionControler:saveServerInfo(serverInfo)
	if self.configMgr == nil or serverInfo == nil then
		return
	end

	local serverInfoJson = json.encode(serverInfo)
	AppHelper:setValue("serverInfo",serverInfoJson)

	local serverId = ""
	if serverInfo and serverInfo._id then
		serverId = serverInfo._id
	end
	AppHelper:setValue("lastServerId",serverId)
end

function VersionControler:getServerId()
	local serverId = AppHelper:getValue("lastServerId")
	if serverId == "" then
		return nil
	end

	return serverId
end

-- 游戏中监听到需要更新客户端的消息
function VersionControler:onReceiveUpdateNotify(event)
	local notifyUpdateClientCode = NotifyEvent.notifyUpdateClientCode
	WindowControler:showWindow("LoginUpdateExceptionView", nil ,notifyUpdateClientCode)
end

-- test，测试方法下载7z更新包测试方法
function VersionControler:downloadTest()
	local writablePath = cc.FileUtils:getInstance():getWritablePath()
	local resUrl = "http://120.26.4.231:8869"
	local filename = "update.7z"

	local params = {}
	params['filePath'] = writablePath..filename
	params['intervalTime'] = 100
	params['dirPath'] = writablePath
	params['url'] = resUrl .. "/" .. filename

	kakura.UpdateClient:update(json.encode(params), function(jsonStr, errCode)
		local progress = json.decode(jsonStr)

		if progressFunc then															
			progressFunc(curFileIndex, totalFileCount, progress)
		end
		
		-- echo("progress.percent====",progress.percent)
		if progress.percent == 200 then
			echo("下载完成。")						
		end
	end)
end

-- 初始化VmsURL
VersionControler:init()

return VersionControler
