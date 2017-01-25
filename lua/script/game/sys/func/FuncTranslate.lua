
FuncTranslate = FuncTranslate or {}

local translateData = nil
local PlotTranslate = nil
local errorTranslate = nil
local translateLuaData = nil
function FuncTranslate.init(  )
	translateData = require("Translate")
	translateLuaData = require("Translate_lua")
    PlotTranslate = require("PlotTranslate")
    errorTranslate = require("Translate_error")
end

-- 根据key获取对应的文字
function FuncTranslate._getLanguage(key,languageVersion)
	languageVersion = languageVersion or "zh_CN"
    if not key then
        echoError("传入了空language key")
    end
	local content = translateData[key] 
	if not content or next(content) == nil then
		content = translateLuaData[key]
	end
	local str = key
	if content ~= nil then
		str = content[languageVersion]
	else
		echoError("没有找到这个语言id配置:", key) 
	end

	return str
end
-- 获取剧情对话文字信息
function FuncTranslate.getPlotLanguage(key,languageVersion)
	local content = PlotTranslate[key] 
	if type(content) == 'table' then
		return content[languageVersion]
	end

	return nil
end

-- 置换字符串 并 换文字
--[[
	eg: 
]]
function FuncTranslate._getLanguageWithSwap(key, ...)
	local str = FuncTranslate._getLanguage(key)

	local args = {...}
	for i, v in ipairs(args) do
		str = string.gsub(str, "#" .. tostring(i), tostring(v))
	end

	return str
end

--获取errortranslate
function FuncTranslate._getErrorLanguage(key,... )
	local languageVersion = "zh_CN"
    if not key then
        echoError("传入了空language key")
    end
	local content = errorTranslate[key] 
	local str = key
	if content ~= nil then
		str = content[languageVersion]

		local args = {...}
		for i, v in ipairs(args) do
			str = string.gsub(str, "#" .. tostring(i), tostring(v))
		end
	else
		echoError("没有找到这个语言id配置:", key) 
	end
	return str
end
