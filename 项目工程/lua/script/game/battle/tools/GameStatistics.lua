

GameStatistics = {}

GameStatistics.operationInfo =  nil

-- 初始化
function GameStatistics:init(fileName)
	if fileName then
		self._strTime = fileName
	else
		self:getTime()
		self:getLogsFullPath()
		self._strTime = self._fulPath..self._strTime
	end
end

-- 获取log信息的路径
function GameStatistics:getLogsFullPath()
	local logsfile = "logs/battlelogs"
	if device.platform =="mac" then
		logsfile = "../../../logs/battlelogs"
	end

	if not cc.FileUtils:getInstance():isDirectoryExist(logsfile) then
		cc.FileUtils:getInstance():createDirectory(logsfile)
	end

	self._fulPath = logsfile.."/"
	return  self._fulPath 
end


-- 获取当前时间
function GameStatistics:getTime(rid)
	local time = os.time()
	local year = os.date("%Y",time)
	local month = os.date("%m",time)
	local day = os.date("%d",time)
	local hour = os.date("%H",time)
	local minute = os.date("%M",time)
	local second = os.date("%S",time)

	self._strTime = string.format("battle_%d_%d_%d_%02d_%02d_%02d.txt",year,month,day,hour,minute,second)
	if rid then
		self._strTime = self._strTime.." "..rid
	end
	
	return self._strTime
end


-- 读取战斗信息
function GameStatistics:getLogsBattleInfo( fileName )
	if not self._fulPath then
		self:getLogsFullPath()
	end
	local name = self:getLogsFullPath()..fileName..".txt"
	if not cc.FileUtils:getInstance():isFileExist(name) then
		echo("______读取的操作文件不存在")
		return
	end

	local str =  FS.readFileContent(name)
	local obj = json.decode(str)
	for k,v in pairs(obj) do
		echo(k,v,"____aaadhsajdsh")
	end
	return obj
end

function GameStatistics:saveBattleInfo(battleInfo)
	
	if device.platform == "windows" or device.platform =="mac" then
		local fileName = self:getTime()
		local targetFileName = self:getLogsFullPath()..fileName
		local targetFile, errorMsg = io.open(targetFileName, "a")
		local targetStr = json.encode(battleInfo)
		if not targetStr or targetStr == "" then
			echoWarn("____错误的battleInfo")
		end
		targetFile:write(targetStr)
		targetFile:close()
	end
	
end


return GameStatistics