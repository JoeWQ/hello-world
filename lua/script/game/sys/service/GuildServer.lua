--
-- Author: guanfeng
-- Date: 2016-1-07
--

local GuildServer = class("GuildServer")

function GuildServer:init()
	echo("GuildServer:init");
	--创建公会
	EventControler:addEventListener(GuildEvent.CREATE_GUILD_EVENT,
		self.createGuild, self);
	--查询公会
	EventControler:addEventListener(GuildEvent.FIND_GUILD_EVENT,
		self.findGuild, self);
	--公会列表
	EventControler:addEventListener(GuildEvent.LIST_GUILD_EVENT,
		self.listGuild, self);

	--加入公会
	EventControler:addEventListener(GuildEvent.GUILD_APPLY_EVENT,
		self.joinGuild, self);

	--公会信息
	EventControler:addEventListener(GuildEvent.GUILD_GET_MEMBERS_EVENT,
		self.getMembers, self);

	--得到公会申请列表
	EventControler:addEventListener(GuildEvent.GUILD_GET_APPLY_LIST_EVENT,
		self.getApplyList, self);

	--修改公会配置
	EventControler:addEventListener(GuildEvent.GUILD_MODITY_CONFIG_EVENT,
		self.modifyConfig, self);	

	--取消申请
	EventControler:addEventListener(GuildEvent.GUILD_CANCEL_APPLY_EVENT,
		self.cancelApply, self);	

	--入会审批
	EventControler:addEventListener(GuildEvent.GUILD_APPLY_JUDGE_EVENT,
		self.judgeApply, self);

	--踢人
	EventControler:addEventListener(GuildEvent.GUILD_KICK_GUILD_EVENT,
		self.kickMember, self);

	--修改会员权限
	EventControler:addEventListener(GuildEvent.GUILD_MODIFY_MEMBER_RIGHT_EVENT,
		self.modifyMEmberRight, self);

	--退出公会
	EventControler:addEventListener(GuildEvent.GUILD_QUIT_EVENT,
		self.quitGuild, self);

	--邀请玩家
	EventControler:addEventListener(GuildEvent.GUILD_invite_EVENT,
		self.inviteMember, self);
end

--创建公会
function GuildServer:createGuild(data)
	local p = data.params.param;
	dump(p, "__createGuild__");
	local params = {
		name = p.name,
		icon = p.icon
	};
	Server:sendRequest(params, MethodCode.guild_create_1301,
		c_func(GuildServer.createGuildOK, self));
end

function GuildServer:createGuildOK(event)
	echo("createOk");
	-- dump(event, "__checkOnlinePlayerCallBack__");
	--发事件
	local inviters = event.result.data.data;
	if event.error == nil then 
	    EventControler:dispatchEvent(GuildEvent.CREATE_GUILD_OK_EVENT, 
	    	{inviters = inviters});
	end 
end

--查询公会
function GuildServer:findGuild(data)
	local guildId = data.params.guildId;
	dump(p, "__findGuild__");
	local params = {
		id = guildId
	};
	Server:sendRequest(params, MethodCode.guild_find_1303,
		c_func(GuildServer.findGuildOk, self));	
end

function GuildServer:findGuildOk(event)
	dump(event, "__findGuildOk__");
	if event.error == nil then 
		echo("find no error");
	    EventControler:dispatchEvent(GuildEvent.FIND_GUILD_OK_EVENT, 
	    	{guildEntity = event.result.data.guild});	
	elseif event.error.code == 130301 then
		echo("find error");
		--event.error.code == 130301 后端把没有找到那个id的公会当成错误 呵呵
		--自己返回空
	    EventControler:dispatchEvent(GuildEvent.FIND_GUILD_OK_EVENT, 
	    	{guildEntity = {}});			
	end 
end

--公会列表
function GuildServer:listGuild(data)
	local isAll = data.params.isAll;
	local page = data.params.page;
	echo("__listGuild__isAll:" .. tostring(isAll));
	echo("__listGuild__page:" .. tostring(page));

	local params = {
		page = page,
		all = isAll
	};
	Server:sendRequest(params, MethodCode.guild_list_1305,
		c_func(GuildServer.listGuildOk, self));	
end

function GuildServer:listGuildOk(event)
	dump(event, "__listGuildOk__");
	local guilds = event.result.data.guild -- todo

	if event.error == nil then 
	    EventControler:dispatchEvent(GuildEvent.LIST_GUILD_OK_EVENT, 
	    	{guilds = guilds});
	end 
end

--加入公会
function GuildServer:joinGuild(data)
	local guildId = data.params.guildId;
	local index = data.params.index;
	local needApply = data.params.isNeedApply;

	echo("joinGuild: " ..guildId);
	echo("index: " .. tostring(index));
	local params = {
		id = guildId
	};
	Server:sendRequest(params, MethodCode.guild_apply_1309,
		c_func(GuildServer.joinGuildOK, self, index, needApply));	
end

function GuildServer:joinGuildOK(index, needApply, event)
	echo("joinGuildOK:" .. tostring(index));
	if event.error == nil then 
	    EventControler:dispatchEvent(GuildEvent.GUILD_APPLY_OK_EVENT, 
	    	{index = index, isNeedApply = needApply});
	end
end

--公会所有成员
function GuildServer:getMembers(data)
	local params = {};
	Server:sendRequest(params, MethodCode.guild_members_1307,
		c_func(GuildServer.getMembersOk, self));	
end

function GuildServer:getMembersOk(event)
	local guild = event.result.data.guild;
	local members = event.result.data.members;

	echo("得到公会成员");
	dump(guild, "我的公会");
	dump(members, "公会成员");

	if event.error == nil then 
	    EventControler:dispatchEvent(GuildEvent.GUILD_GET_MEMBERS_OK_EVENT, 
	    	{guild = guild, members = members});
	end
end

--得到申请列表
function GuildServer:getApplyList(data)
	local guild = data.params.guildId;
	echo("guild: " .. tostring(guild));
	local params = {
		id = guildId
	};
	Server:sendRequest(params, MethodCode.guild_apply_list_1311,
		c_func(GuildServer.getApplyListOk, self));
end

function GuildServer:getApplyListOk(event)
	dump(event, "_getApplyListOk_");
	local guildApplyList = event.result.data.data;

	if event.error == nil then 
	    EventControler:dispatchEvent(GuildEvent.GUILD_GET_APPLY_LIST_OK_EVENT, 
	    	{guildApplyList = guildApplyList});
	end
end

--更改配置
function GuildServer:modifyConfig(data)
	local configs = data.params.configs;

	dump(configs, "__config__");

	local params = {
		icon = configs.icon,
		needApply = configs.needApply,
		desc = configs.desc,
		notice = configs.notice
	};

	Server:sendRequest(params, MethodCode.guild_modify_info_1315,
		c_func(GuildServer.modifyConfigOk, self, configs));
end

function GuildServer:modifyConfigOk(configs, event)
	echo("__modifyConfigOk__");

	if event.error == nil then 
	    EventControler:dispatchEvent(GuildEvent.GUILD_MODITY_CONFIG_OK_EVENT, 
	    	{configs = configs});
	end
end

--取消申请
function GuildServer:cancelApply(data)
	local guildId = data.params.guildId;
	local index = data.params.index;

	local params = {
		id = guildId
	};

	Server:sendRequest(params, MethodCode.guild_cancel_apply_1323,
		c_func(GuildServer.cancelApplyOk, self, index));
end

function GuildServer:cancelApplyOk(index, event)
	echo("cancelApplyOk");
	
	if event.error == nil then 
	    EventControler:dispatchEvent(GuildEvent.GUILD_CANCEL_APPLY_OK_EVENT, 
	    	{index = index});
	end 
end

--入会申请
function GuildServer:judgeApply(data)
	local userId = data.params.userId;
	local index = data.params.index;
	local isAdpot = data.params.isAdpot;

	local params = {
		id = userId,
		type = isAdpot
	};

	Server:sendRequest(params, MethodCode.guild_apply_judge_1313,
		c_func(GuildServer.judgeApplyOk, self, index, isAdpot));
end

function GuildServer:judgeApplyOk(index, isAdpot, event)
	dump(event, "judgeApplyOk");
	
	if event.error == nil then 
		local newMember = event.result.data.data;
	    EventControler:dispatchEvent(GuildEvent.GUILD_APPLY_JUDGE_OK_EVENT, 
	    	{index = index, isAdpot = isAdpot, newMember = newMember});
	end
end

--踢人
function GuildServer:kickMember(data)
	local userId = data.params.id;
	echo("GuildServer:kickMember:" .. tostring(userId));

	local params = {
		id = userId
	};

	Server:sendRequest(params, MethodCode.guild_kick_member_1319,
		c_func(GuildServer.kickMemberOk, self, userId));

end

function GuildServer:kickMemberOk(userId, event)
	echo("kickMemberOk");
	if event.error == nil then 
	    EventControler:dispatchEvent(GuildEvent.GUILD_KICK_GUILD_OK_EVENT, 
	    	{userId = userId});
	end
end

--修改会员权限
function GuildServer:modifyMEmberRight(data)
	local id = data.params.id;
	local right = data.params.right;

	local params = {
		id = id,
		right = right
	};

	Server:sendRequest(params, MethodCode.guild_modify_member_right_1317,
		c_func(GuildServer.modifyMEmberRightOk, self, id, right));
end

function GuildServer:modifyMEmberRightOk(userId, right, event)
	echo("modifyMEmberRightOk");

	if event.error == nil then 
	    EventControler:dispatchEvent(GuildEvent.GUILD_MODIFY_MEMBER_RIGHT_OK_EVENT, 
	    	{userId = userId, right = right});
	end
end

--退出公会
function GuildServer:quitGuild(data)
	local id = data.params.id;

	local params = {
		id = id
	};	

	Server:sendRequest(params, MethodCode.guild_quit_1321,
		c_func(GuildServer.quitGuildOk, self));
end

function GuildServer:quitGuildOk(event)
	echo("quitGuildOk");
	if event.error == nil then 
	    EventControler:dispatchEvent(GuildEvent.GUILD_QUIT_OK_EVENT, 
	    	{});
	end	
end

--邀请玩家
function GuildServer:inviteMember(data)
	local id = data.params.id;

	local params = {
		id = id
	};	

	Server:sendRequest(params, MethodCode.guild_invite_1325,
		c_func(GuildServer.inviteMemberOk, self));	
end

function GuildServer:inviteMemberOk(event)
	echo("inviteMemberOk");
	if event.error == nil then 
	    EventControler:dispatchEvent(GuildEvent.GUILD_invite_OK_EVENT, 
	    	{});
	end		
end

GuildServer:init();

return GuildServer











