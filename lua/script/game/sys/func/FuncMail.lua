--
-- Author: xd
-- Date: 2016-01-14 14:42:07
--


--邮件配置文件相关

local mailData = nil

FuncMail = FuncMail or {}

function FuncMail.init(  )
	mailData = require("mail.Mail")
end

--获取邮件信息
function FuncMail.getMailCfg( id )
	local cfgs = mailData[tostring(id)]
	if not cfgs  then
		echoError("没有这个id数据:",tostring(id))
		return mailData[tostring(1)]
	end
	return cfgs
end

--获取邮件标题
function FuncMail.getMailTitle( id,replaceInfo )
	local info = FuncMail.getMailCfg( id )
	local str = info.title;
	replaceInfo = replaceInfo or {}
	--获取占位符
	return GameConfig.getLanguageWithSwap(str,unpack(replaceInfo))

end

--获取邮件内容
function FuncMail.getMailContent( id,replaceInfo )
	local info = FuncMail.getMailCfg( id )
	local str = info.content;
	replaceInfo = replaceInfo or {}
	--获取占位符
	return GameConfig.getLanguageWithSwap(str,unpack(replaceInfo))
end


--获取邮件发件人
function FuncMail.getMailSec( id,replaceInfo )
	local info = FuncMail.getMailCfg( id )
	local str = info.sec;
	replaceInfo = replaceInfo or {}
	--获取占位符
	return GameConfig.getLanguageWithSwap(str,unpack(replaceInfo))
end






