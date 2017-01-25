--guan
--2016.1.12

--[[
	这里的数据没有走自动更新逻辑, 所有数据必须进一次公会才能取到
]]

local GuildModel = class("GuildModel");

GuildModel.MEMBER_RIGHT = {
	LEADER = 1,  --会长
	SUPER_MASTER = 2,  --太上长老
	MASTER = 3,   --长老
	PEOPLE = 4,   --群众
}

function GuildModel:ctor()

end

function GuildModel:init()
	echo("________GuildModel:ctor_______");

	--[[

	self._baseGuildInfo =	{
		    /* 公会ID */
			optional string _id = 1;
		    /* 创建时间 */
		    optional int32 ctime = 2;
		    /* 名称 */
		    optional string name = 3;
		    /* 等级 */
		    optional int32 level = 4;
		    /* 经验 */
		    optional int32 exp = 5;
		    /* 图标 */
		    optional int32 icon = 6;
		    /* 需要审核 */
		    optional int32 needApply = 7;
		    /* 会长ID */
		    optional string leaderId = 8;
		    /* 宣言 */
		    optional string desc = 9;
		    /* 成员数 */
		    optional int32 members = 10;

		    notice 公告
		}

	]]
	self._baseGuildInfo = {};

	--只有改这些key是合法的
	self._baseInfoKey = {
		["_id"] = true,
		["level"] = true,
		["exp"] = true,
		["icon"] = true,
		["needApply"] = true,
		["desc"] = true,
		["notice"] = true,
	};

	--[[
	self._membersInfo =
	{
		_id = {
		    /* 成员ID */
		    optional string _id = 1;
		    /* 权限 */
		    optional int32 right = 2;
		    /* 名称 */
		    optional string name = 3;
		    /* 等级 */
		    optional int32 level = 4;
		    /* 境界 */
		    optional int32 state = 5;
		    /* vip */
		    optional int32 vip = 6;
		    /* 头像 */
		    optional int32 avatar = 7;
		    /* 战力 */
		    optional int32 ability = 8;
		    /* 离线时间 */
		    optional int32 logoutTime = 9;
		    /* 累积贡献 */
		    optional int32 guildCoin = 10;
		} , ……
	}
	]]
	self._membersInfo = {};
	--接受事件 todo
end

--是否已经加入公会
function GuildModel:isInGuild()
	return UserModel:guildExt().id ~= nil;
end

--已经申请了的公会
--[[
	{
		"dev_6" = 13123,
		"dev_6" = 13123,
	}
]]
function GuildModel:applyingGuild()
	return UserModel:guildExt().applys;
end

--公会基础信息
function GuildModel:setGuildBaseInfo(baseInfo)
	self._baseGuildInfo = baseInfo;
end

function GuildModel:updateBaseInfo(key, value)
	if self._baseInfoKey[key] ~= true then 
		echo("warning:updateBaseInfo key not exist.");
		return;
	else 
		self._baseGuildInfo[key] = value;
	end 
end

function GuildModel:getGuildBaseInfo()
	return self._baseGuildInfo;
end

--公会成员信息
function GuildModel:setGuildMembersInfo(members)
	for k, v in pairs(members) do
		self._membersInfo[v._id] = v;
	end
end

function GuildModel:getGuildMembersInfo()
	return self._membersInfo;
end

function GuildModel:addMembersInfo(member)
	if member ~= nil then 
		self._membersInfo[member._id] = member;
	else
		echo("warning:addMembersInfo member is nil.");
	end 
end

function GuildModel:delMembersInfo(id)
	self._membersInfo[id] = nil;
end

function GuildModel:getMemberInfo(id)
	return self._membersInfo[id];
end

--我自己的公会信息
function GuildModel:getMyMembersInfo()
	local myId = UserModel:_id();
	return self._membersInfo[myId];
end

--自己是什么职位
function GuildModel:getMyRight()
	return self:getMyMembersInfo().right;
end

function GuildModel:isAppliedTheGuild(searchId)
	local ids = self:applyingGuild() or {};
	for id, time in pairs(ids) do
		if searchId == id then 
			return true 
		end 
	end
	return false;
end

function GuildModel:getMaxMemberNum()
	local level = self._baseGuildInfo.level;
	return FuncGuild.getGroudLvData(level, "nop");
end

GuildModel:init();

return GuildModel;








