local LogsControler = LogsControler or {}

--一行支持的文本数最大值 ,一个中文算2个字节
local messageLength = 62
local _tempClientLogFileName = nil

-- 日志类型
LogsControler.logType = {
    LOG_TYPE_NORMAL = 1,
    LOG_TYPE_WARN = 2,
    LOG_TYPE_ERROR = 3,
    }

-- 每类日志最大行数
LogsControler.maxLineMap = {
    [LogsControler.logType.LOG_TYPE_NORMAL] = 1000,
    [LogsControler.logType.LOG_TYPE_WARN] = 500,
    [LogsControler.logType.LOG_TYPE_ERROR] = 500,
    }

--logs内容数组
LogsControler._logsInfo = { 
    [LogsControler.logType.LOG_TYPE_NORMAL] = {},
    [LogsControler.logType.LOG_TYPE_WARN] =  {},
    [LogsControler.logType.LOG_TYPE_ERROR] = {}    
}

--根据日志类型添加日志信息
-- logType:日志类型
-- log内容为不定参数链接后的字符串
function LogsControler:addLog(logType, ...)
    if logType < self.logType.LOG_TYPE_NORMAL or logType > self.logType.LOG_TYPE_ERROR then
        return
    end

    local args = {...}
    local logMsg = ""
    for k,v in pairs(args) do
        logMsg = logMsg .. " " .. tostring(v)
    end

    if logType == self.logType.LOG_TYPE_NORMAL then
        self:addNormal(logMsg)
    elseif logType == self.logType.LOG_TYPE_WARN then
        self:addWarn(logMsg)
    elseif logType == self.logType.LOG_TYPE_ERROR then
        self:addError(logMsg)
    end
end
--[[
gs添加  暂时使用，不提交  注意保存
]]
function LogsControler:writeDumpToFile( value, desciption, nesting )
    -- if type(nesting) ~= "number" then nesting = 3 end

    -- local lookupTable = {}
    -- local result = {}

    -- local function _v(v)
    --     if type(v) == "string" then
    --         v = "\"" .. v .. "\""
    --     end
    --     return tostring(v)
    -- end

    -- local traceback = string.split(debug.traceback("", 2), "\n")
    -- --print("dump from: " .. string.trim(traceback[3]))

    -- local function _dump(value, desciption, indent, nest, keylen)
    --     desciption = desciption or "<var>"
    --     spc = ""
    --     if type(keylen) == "number" then
    --         spc = string.rep(" ", keylen - string.len(_v(desciption)))
    --     end
    --     if type(value) ~= "table" then
    --         result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
    --     elseif lookupTable[value] then
    --         result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
    --     else
    --         lookupTable[value] = true
    --         if false and nest > nesting then
    --             result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
    --         else
    --             result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
    --             local indent2 = indent.."    "
    --             local keys = {}
    --             local keylen = 0
    --             local values = {}
    --             for k, v in pairs(value) do
    --                 keys[#keys + 1] = k
    --                 local vk = _v(k)
    --                 local vkl = string.len(vk)
    --                 if vkl > keylen then keylen = vkl end
    --                 values[k] = v
    --             end
    --             table.sort(keys, function(a, b)
    --                 if type(a) == "number" and type(b) == "number" then
    --                     return a < b
    --                 else
    --                     return tostring(a) < tostring(b)
    --                 end
    --             end)
    --             for i, k in ipairs(keys) do
    --                 _dump(values[k], k, indent2, nest + 1, keylen)
    --             end
    --             result[#result +1] = string.format("%s}", indent)
    --         end
    --     end
    -- end
    -- _dump(value, desciption, "- ", 1)
    -- echo("将log写入日志-----------")
    -- for i, line in ipairs(result) do
    --     self:addNormal(line)
    -- end
end

--添加普通log日志
function LogsControler:addNormal(str )
	self:joinOneMessage(str,self.logType.LOG_TYPE_NORMAL)
end

--添加警告log日志
function LogsControler:addWarn( str )
    self:joinOneMessage(str,self.logType.LOG_TYPE_WARN)
end

--添加错误log日志
function LogsControler:addError( str )
	self:joinOneMessage(str,self.logType.LOG_TYPE_ERROR)
end

--根据类型，清空log
function LogsControler:clearLogByType( logType )
    if logType < self.logType.LOG_TYPE_NORMAL or logType > self.logType.LOG_TYPE_ERROR then
        return logsArr
    end

    self._logsInfo[logType] = {}
    EventControler:dispatchEvent(LogEvent.LOGEVENT_LOG_CHANGE,{logType=logType});
end

-- 获取log数据
function LogsControler:getLogs( logType )
    local logsArr = {}
    if logType < self.logType.LOG_TYPE_NORMAL or logType > self.logType.LOG_TYPE_ERROR then
        return logsArr
    end
    
    logsArr = self._logsInfo[logType]

    if #logsArr <= 0 then
        return {"没有找到该类型日志"}
    end

    return logsArr
end

--加入一组信息
function LogsControler:joinOneMessage(str,logType )
    if logType < self.logType.LOG_TYPE_NORMAL or logType > self.logType.LOG_TYPE_ERROR then
        return
    end

    local originLogArr = self._logsInfo[logType]
    local newLogArr = self:turnOneStr(str)
    local maxLine = self.maxLineMap[logType]
    
    if (#newLogArr + #originLogArr) > maxLine then
        local deleteLinesNum = #newLogArr + #originLogArr - maxLine
        -- 倒序删除log
        for i = #originLogArr,(#originLogArr - deleteLinesNum + 1),-1 do
            table.remove(originLogArr,i)
        end
    end
    
    -- 插入log
    for i=#newLogArr,1,-1 do
        table.insert(originLogArr, 1 , newLogArr[i])
    end

    if DEBUG_LOGVIEW then
        EventControler:dispatchEvent(LogEvent.LOGEVENT_LOG_CHANGE,{logType=logType});
    end
    
	self:saveLocalLog(str)
end

function LogsControler:genLocalLogFileName()
	local time = os.time()
	local year = os.date("%Y",time)
	local month = os.date("%m",time)
	local day = os.date("%d",time)
	local hour = os.date("%H",time)
	local minute = os.date("%M",time)
	local second = os.date("%S",time)
	return string.format("%d_%d_%d_%02d_%02d_%02d",year,month,day,hour,minute,second)
end

--本地存储log
function LogsControler:saveLocalLog(str)
	if str == "" or str == nil then return end
	local logfile = self:getClientLogFile()
	if device.platform == "windows" or device.platform =="mac" then
		local targetFile = io.open(logfile,"a")

        if targetFile == nil then
            return
        end

        targetFile:write(str.."\n")
        targetFile:close()
	end
end

function LogsControler:getClientLogFile()
	local logPath = "logs/serverlogs"
	if device.platform == "mac" then
		logPath = "../../../../../svn/Resources/logs/clientlogs"
	end
	if not cc.FileUtils:getInstance():isDirectoryExist(logPath) then 
		cc.FileUtils:getInstance():createDirectory(logPath)
	end
	if not _tempClientLogFileName then
		_tempClientLogFileName = self:genLocalLogFileName()
	end
	local logFile = logPath..'/'.._tempClientLogFileName..'.txt'
	return logFile
end

--将一个字符串转化成数组
function LogsControler:turnOneStr( str )
	str = string.gsub(str, "\\n", "\n")
	local arr = string.split(str, "\n")
	local result ={}

	for i,v in ipairs(arr) do
		local tempArr =  string.splitCharsStr(v,messageLength) --self:splitOneStr(v)
		-- echo(v,string.len(v),"string.len(v)")
		for k,s in ipairs(tempArr) do
			table.insert(result, s)
		end
	end

	return  result
end

--中文匹配符
local chiReq = "[\128-\255][\128-\255][\128-\255]"
function LogsControler:splitOneStr( input, lineChars )
    lineChars = lineChars or messageLength
	local pos,arr = 1, {}
	local len = string.len(input)
	local resultArr = {}
	if len ==0 then
		return resultArr
	end
    -- 先把这个字符串按照字符拆分 中文字符也算一个字符拆分 同时记录长度
    for st,sp in function() return string.find(input, chiReq, pos) end do
    	if st >1 and pos < st then

    		for i=pos,st-1 do
    			table.insert(arr, { string.sub(input, i, i)  ,1 } )
    		end
    	end
        table.insert(arr, {string.sub(input, st, sp) ,2 } )
        pos = sp + 1
    end

    if pos <= len then
    	for i=pos,len do
			table.insert(arr, {string.sub(input, i, i) ,1 })
		end
    end


    local utfLength =0

    local tempStr = ""

    local arrleng = #arr

    for i,v in ipairs(arr) do
    	local str = v[1]
    	local len =v[2]
    	--如果大于一行的长度了
    	--echo(i,str,len, arrleng,"___aa",tempStr,utfLength)
    	if utfLength + len > lineChars then
    		table.insert(resultArr, tempStr)
    		tempStr = str
    		utfLength = len
    	else
    		
    		utfLength = utfLength + len
    		tempStr = tempStr ..str
    	end

    	if i == arrleng then
			table.insert(resultArr, tempStr)
		end
    end

    return resultArr
end

return LogsControler
