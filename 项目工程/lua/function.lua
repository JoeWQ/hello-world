function c_func(f,...)
	local _args = {...}
	if not f then
		error("´«µÝÁË¿Õº¯Êý")
		dump(_args,"____args")
	end

	local maxNums = 0
	for k,v in pairs(_args) do
		maxNums = math.max(k,maxNums)
	end

	for i=1,maxNums do
		if not _args[i] then
			_args[i] = false
		end
	end

	return function(...)
		local _tmp = table.copy(_args)
		table.array_merge(_tmp,{...})
		return f(unpack(_tmp))
	end
end

