
local LS = {
	__db_prv = false,
	__db_pub = false,
}

--[[
-- 账户私有存储(分区分uid)
-- LS:prv():get("key",def)
-- LS:prv():set("key",value)
 ]]
function LS:prv()
	if not self.__db_prv then
		--assert(uzone~=0 and uid~=0,"@LS:prv(). uzone or uid is 0.")
		-- 标识是"kvprv_z分区_uid"
		local tagname = string.format("pre_%s_%s", LoginControler:getServerId(), UserModel:uid())
		self.__db_prv = storage.new(tagname)
	end
	return self.__db_prv
end

--[[
-- 本机器所有账号通用存储
-- LS:pub():get("key",def)
-- LS:pub():set("key",value)
 ]]
function LS:pub()
	if not self.__db_pub then
		-- 标识是"kvpub"
		local tagname = "pub"
		self.__db_pub = storage.new(tagname)
	end
	return self.__db_pub
end

--[[
--本机版本控制版本成功数据存储
 ]]
function LS:ver()
	if not self.__ver then
		local tagname="ver"
		self.__ver = storage.new(tagname)
	end
	return self.__ver
end

function LS:restore()
	self.__db_prv = nil
end

--todo加存table相关方法

return LS
