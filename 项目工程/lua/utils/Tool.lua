 --
-- User: ZhangYanGuang
-- Date: 15-5-14
-- 全局工具方法
--

local function swapGem(str)
	--预留扩展，该方法中修改str
    return str
end

function getPlotLanguage(id)
    --先从csv配置从读取
    local result = FuncTranslate.getPlotLanguage(id, 'zh_CN') --GameConfig:getRaw("translate", id, 'zh_CN');
 
    if result == nil then
        echo("没有找到这个语言id配置:",id) 
        return id 
    end
    if type(result)=='string' then
        result=swapGem(result);
    elseif type(result)=='table' then
        for i,v in pairs(result) do
            if type(result[i])=='string' then
                result[i]=swapGem(result[i]);
            end
        end
    end
    return result;
end
 
--三元运算符
function _yuan3(a, b, c)
    if a == nil then return c end
    return(a and { b } or { c })[1]
end 

Tool = Tool or {}

-- 二进制位表示战斗结果的星级及完成了哪个条件
Tool.battleStarCfg = {
    -- 一星
    [1] = {1,{0,0,1}},
    [2] = {1,{0,1,0}},
    [4] = {1,{1,0,0}},

    -- 二星
    [3] = {2,{0,1,1}},
    [5] = {2,{1,0,1}},
    [6] = {2,{1,1,0}},

    -- 三星
    [7] = {3,{1,1,1}},
} 

-- 将战斗结果值，转为星级数据
-- battleResult:战斗结果值，3位二进制表示星级及完成了哪个条件，取值范围 1-7
-- 返回值：星级star,完成的条件数组
function Tool:getBattleStar(battleResult)
    local star = 0
    local condArr = {}

    local battleRt = tonumber(battleResult)
    if battleRt >= 1 and battleRt <= 7 then
        local starData = Tool.battleStarCfg[battleRt]
        star = starData[1]
        -- 反转数组元素，使condArr中的条件顺序修改为从易到难
        condArr = table.reverse(starData[2])
    end

    return star,condArr
end

function Tool:getDeviceId()
	local device_id = LS:pub():get(StorageCode.device_id, "")
	if not device_id or device_id == "" then
		--TODO 获取设备id
		if false then
			--首先通过公司技术支持的方法获取deviceid
            
		else
			device_id = self:getFakeDeviceId()
		end
	end
	return device_id
end

--先用时间戳和随机串来模拟设备id
function Tool:getFakeDeviceId()
	local device_id_max_len = 30
	local strs = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","_","1","2","3","4","5","6","7","8","9","0"}
	math.randomseed(os.time()) 
    
    local randomIn = math.random()
    table.shuffle(strs, math.random(1,os.time()))
	local deviceid = os.time().."_"..string.sub(table.concat(strs), 1, device_id_max_len)
	return deviceid
end

--判断是否是敏感词 ,replaceStr 把敏感词替换成指定的词
function Tool:checkIsBadWords(str,replaceStr)
    local time = os.clock()
    replaceStr = replaceStr or "*"
    local banWords = require("game.sys.data.BanWords")

    --判断是否是敏感词
    for i,v in ipairs(banWords) do
        --暂时用简单方法去排查
        if string.find(str, v) then
			str = string.gsub(str, string.format("(.*)%s(.*)", v), string.format("%%1%s%%2", replaceStr))
            return true,str
        end
    end
    return false,str
end

-- 坐标转换为gl坐标
function Tool:convertToGL(pos)
    local glView = cc.Director:getInstance():getOpenGLView();

    local designResolutionSize = glView:getDesignResolutionSize();

    pos = cc.Director:getInstance():convertToGL(
        {x = pos.x, y = pos.y}); 

    if designResolutionSize.width > GameVars.maxScreenWidth then 
        pos.x = pos.x - (designResolutionSize.width - GameVars.maxScreenWidth) / 2;
    elseif designResolutionSize.height > GameVars.maxScreenHeight then 
        pos.y = pos.y - (designResolutionSize.height - GameVars.maxScreenHeight) / 2;
    end 

    return pos;
end
