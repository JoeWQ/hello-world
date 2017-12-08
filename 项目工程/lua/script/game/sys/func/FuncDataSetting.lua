
FuncDataSetting = FuncDataSetting or {}

local dataSetting = nil


function FuncDataSetting.init( 	 )
	dataSetting = require("DataSetting")
end

-- 通过 hid 获得设置数据
function FuncDataSetting.getDataByHid(hid)
    return dataSetting[hid]
end

-- 通过 ConstantName 获得设置数据
function FuncDataSetting.getDataByConstantName(constantName)
	local value = dataSetting[constantName].num
	if (not value) or value ==""  then
		return numEncrypt:getNum0()
	end
    return numEncrypt:getNum(value)
end


-- 通过 ConstantName 获得原始数据 也就是未解密的
function FuncDataSetting.getOriginalData(constantName)
    return dataSetting[constantName].num
end

-- 通过 加密串 获得设置数据 --除了战斗系统以外 其他系统应该直接调用  FuncDataSetting.getDataByConstantName
function FuncDataSetting.getDataByEncStr(encStr)
	local value = encStr
	if (not value) or value ==""  then
		return numEncrypt:getNum0()
	end
    return numEncrypt:getNum(value)
end


function FuncDataSetting.filterStr(str)
	if str and string.len(str) > 1 and string.getChar(str,string.len(str)) == ";" then
		str = string.sub(str,1,string.len(str) - 1)
	end

	return str
end

function FuncDataSetting.getPVELimitDropOrder(itemId)
	local limitDropStr = dataSetting["PVELimitDrop"].str
	limitDropStr = FuncDataSetting.filterStr(limitDropStr)

	local limitDropArr = {}
	if limitDropStr then
		limitDropArr = string.split(limitDropStr,";")
	end

	if #limitDropArr > 0 then
		for i=1,#limitDropArr do
			if tostring(itemId) == limitDropArr[i] then
				return i
			end
		end
	end

	return #limitDropArr + 1
end

function FuncDataSetting.getPVESweepTargetItemSubType()
	local itemsStr = dataSetting["PVESweepTargetItems"].str
	itemsStr = FuncDataSetting.filterStr(itemsStr)

	local itemsArr = {}
	if itemsStr then
		itemsArr = string.split(itemsStr,";")
	end

	return itemsArr
end

function FuncDataSetting.getDataVector( constantName )

	local data = dataSetting[constantName]
	data = data.vec
	local result = {}
	for k,v in pairs( data ) do
		result[v.k] = numEncrypt:getNum(v.v)
	end

	return result
end
