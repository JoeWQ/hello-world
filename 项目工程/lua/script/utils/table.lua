table.length = function (t)
	local count = 0;
	for k,v in pairs(t) do
		count = count + 1;
	end
	return count;
end

table.isValueIn = function (t, value)
	for k, v in pairs(t) do
		if v == value then 
			return true;
		end 
	end
	return false;
end

table.isKeyIn = function (t, key)
	for k, v in pairs(t) do
		if k == key then 
			return true;
		end 
	end
	return false;
end

table.sortedKeys = function(t,cmp)
	local ret = {}
	if cmp == nil then
		for k in pairs(t) do
			table.insert(ret,k)
		end
	else
		local reverse_map = {}
		local values = {}
		for k,v in pairs(t) do
			reverse_map[v] = k
			table.insert(values,v)
		end
		table.sort(values,cmp)
		for i,v in ipairs(values) do
			table.insert(ret,reverse_map[v])
		end
	end
	return ret
end

table.shuffle = function(t, randomseed)
	if not randomseed then randomseed = os.time() end
	math.randomseed(randomseed)
    local rand = math.random 
    assert( t, "shuffleTable() expected a table, got nil" )
    local iterations = #t
    local j
    
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

--得到没有key的table数组
table.getNewTableWithOutKey = function (t)
	local ret = {};
	for k, v in pairs(t) do
		table.insert(ret, v);
	end

	return ret;
end

--table copy 当copy数组的时候 ,数组里面一定不能有 nil元素否则 #table的时候 会获取到错误值
table.copy = function(t)
	local u = { }
	for k, v in pairs(t) do u[k] = v end
	return setmetatable(u, getmetatable(t))
end



table.deepCopy = function(t)
	local function _deepCopy(from ,to)
		for k, v in pairs(from)   do
			if type(v) ~= "table" then
				to[k] = v
			else
				to[k] = {}
				_deepCopy(v,to[k])
			end
		end
		return setmetatable(from, getmetatable(to))
	end
	local u = {}
	_deepCopy(t,u)
	return u
end


--深度合并  把t2里的属性 赋值给  t1
table.deepMerge= function ( t1,t2 )
	if not t2 then
		return 
	end
	if not t1 then
		t1 = {}
	end

	for k,v in pairs(t2) do
		if(type(v) =="table") then 
			if not t1[k] then
				t1[k] = {}
			end
			table.deepMerge(t1[k],v)
		else
			t1[k] = v
		end
	end
	return t1
end


--深度删除  
--deltitle 删除标识符 当 keyData的 某个key的值为1的时候 表示删除这个值
table.deepDelKey = function (t,keyData ,deltitle  )
	if not deltitle then
		deltitle = 1
	end
	if not keyData then
		return
	end

	for k,v in pairs(keyData) do
 
		if k ~= "_id" then 
			if v == 1 then
				t[k] =nil
			elseif type(v)=="table" then
				if t[k] ~= nil then 
					table.deepDelKey(t[k],v,deltitle)
				end 
			else
				echo("错误的删除码,key: "..k.."_value: "..v)
			end
		end


		
	end

end

table.clear = function (t)
	for k,v in pairs(t) do
		t[k] = nil
	end
end

--测试 深度删除
-- local t1 = {
-- 	 a= 1,
-- 	 aa ={1,2,3},
-- 	 b={c=2,d=5,e = {f="a",g =2  }  },
-- 	 hh = {mm =2},
-- 	 h ={i =1,j="2"}


-- }

-- local t2 = {
-- 	 a= 1,
-- 	 b={c=1,d=2,e = {f="a",g =2  }  },
-- 	 h ={i =1}


-- }

-- table.deepDelKey(t1,t2)
-- dump(t1,"____t1")




table.find = function(t,f)
	for k,v in pairs(t) do
		if v==f then
			return k
		end
	end
	return false
end

table.isEmpty = function(t)
	for k,v in pairs(t) do
		return false
	end
	return true
end


--获取一个数组的反向序列
table.reverse = function ( t )
	local arr = {}
	for i=#t ,1,-1 do
		table.insert(arr, t[i])
	end
	return arr
end


--[[
-- 多个参数倒序排序
-- Usage:
	local arr = {}
	for i=1,100 do
		table.insert(arr,{a=math.random(1,10),b=math.random(1,10),c=math.random(1,10)})
	end
	table.sortDesc(arr,"a","b","c")

-- ]]
table.sortDesc = function(t,...)
	local args = {...}
	local function _sortfunc(a,b,idx)
		if args[idx+1] then
			if a[args[idx]]==b[args[idx]] then return _sortfunc(a,b,idx+1) end
		end
		if not a[args[idx]] then return false end
		if not b[args[idx]] then return true end
		return a[args[idx]]>b[args[idx]]
	end
	table.sort(t,function(a,b)
		return _sortfunc(a,b,1)
	end)
end
table.sortAsc = function(t,...)
	local args = {...}
	local function _sortfunc(a,b,idx)
		if args[idx+1] then
			if a[args[idx]]==b[args[idx]] then return _sortfunc(a,b,idx+1) end
		end
		if not a[args[idx]] then return true end
		if not b[args[idx]] then return false end
		return a[args[idx]]<b[args[idx]]
	end
	table.sort(t,function(a,b)
		return _sortfunc(a,b,1)
	end)
end
table.join = function(t,sep)
	sep = sep or "," --默认逗号
	return table.concat(t,sep)
end
table.join2d = function(t,sep1,sep2)
	sep1 = sep1 or ";"
	sep2 = sep2 or ","
	local tmp_t = {}
	for k,v in pairs(t) do
		local str = v[1]..sep2..v[2]
		table.insert(tmp_t,str)
	end
	return table.join(tmp_t,sep1)
end
--[[
-- 连接两个数组
-- Usage:
	local arr = {1,2,3}
	table.array_merge(arr, {4,5})
	echo(arr) -- {1,2,3,4,5}
 ]]
table.array_merge = function(dest, src)
	local len = #dest
	for i, v in ipairs(src) do
		dest[len+i] = v
	end
end




--获取一个对象的属性
function table.getValue(obj,params )
	if not params then
		return obj
	end
	if type(params) =="table" then
		local temp = obj
		for i,v in ipairs(params) do
			temp = temp[v]
		end
		return temp
	else
		return obj[params]
	end

end



array = array or {}


--截取指定位置的数组
function array.slice(arr,startIndex,endIndex )
	if not startIndex then		startIndex = 1	end
	if not endIndex then	endIndex=  #arr	end
	startIndex = startIndex < 1 and 1 or startIndex
	endIndex= endIndex > #arr and #arr or endIndex
	local resultArr = {}
	for i=startIndex,endIndex do
		resultArr[i] = arr[i]
	end
	return resultArr
end

-- 数组最小值 如果params 是{b,c},会按照参数顺序 a.b.c ,获取值
function array.min(arr ,params )
	local min ,index
	index =1
	local targetValue
	for i,v in ipairs(arr) do
		if not min then
			min = table.getValue(v,params)
			oldMin = min
			index = i
		else
			targetValue = table.getValue(v,params)
			if targetValue < min then
				index = i
				min = targetValue
			end
		end
	end
	return min,index
end



function array.max( arr,params )
	local max 
	local index=1
	local targetValue
	for i,v in ipairs(arr) do
		if not max then
			max = table.getValue(v,params)
			index = i
		else
			targetValue = table.getValue(v,params)
			if targetValue> max then
				max = targetValue
				index =i
			end
		end
		
	end
	return max,index
end




-- 合并数组 并创建新数组
function array.merge( ... )
	local args = {...}
	local resultArr = {}
	local v
	for i=1,#args do
		v = args[i]
		if  v then
			for j,k in ipairs(v) do
				if table.indexof(resultArr,k) == false then
					table.insert(resultArr, k)
				end
			end
		else
			echoError("传入了空数组..",i)
		end
	end

	return resultArr
end

--把后面的数组合并到第一个数组
function array.merge2(resultArr,... )
	local args = {...}
	local v
	for i=1,#args do
		v = args[i]
		if  v then
			for j,k in ipairs(v) do
				if table.indexof(resultArr,k) == false then
					table.insert(resultArr, k)
				end
			end
		else
			echoError("传入了空数组..",i)
		end
	end

	return resultArr
end


--剔除数组
function array.excluding(sourceArr,excludeArr )
	local resultArr
	if not excludeArr then
		return sourceArr
	end
	resultArr = {}
	for i,v in ipairs(sourceArr) do
		if table.indexof(excludeArr, v) == false then
			table.insert(resultArr, v)
		end
	end
	return resultArr
end



--减序排列
function table.descSort( a,b )	return b < a end

