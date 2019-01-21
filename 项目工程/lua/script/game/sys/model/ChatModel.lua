-- //聊天系统数据
-- //2016-5-9
-- //author:xiaohuaxiong
local ChatModel = class("ChatModel", BaseModel);

function ChatModel:init()
    -- //世界聊天中的数据
    self.worldMessage = { };
    -- //联盟聊天中的数据
    self.leagueMessage = { };
    -- //私聊中的数据
    self.privateMessage = { };
    self.fastPrivateMap = { };
    -- //快速查找私聊对象
    -- //世界聊天中已经聊天的次数
    self.worldChatCount = 0;
    -- //聊天系统的最大记录数目,超过了这个数目,以后显示的消息将会把最初的顶掉
    self.maxChatRecordCount = 50;
    -- //如果有战报,则在原来的基础上减掉1
    -- //私聊的聊天对象
    self.privateTargetPlayer = nil;
    -- //私聊的消息是有否且没有被获取
    self.isPrivateMessageAchieve = true;
end
-- //设置聊天对象,党一个消息是自己发出的的时候,需要确认聊天对象的身份
function ChatModel:setPrivateTargetPlayer(_player)
    self.privateTargetPlayer = _player;
end
-- //获取私聊对象
function ChatModel:getPrivateTargetPlayer()
    -- //如果没有私聊对象,默认选择对话队列中第一个
    if (self.privateTargetPlayer == nil) then
        self.privateTargetPlayer = self.privateMessage[1];
    end
    return self.privateTargetPlayer;
end
-- //获取免费聊天次数(世界聊天中)
function ChatModel:getFreeOfChatCount()
    local _sendCount = CountModel:getCountByType(25);
    -- 获取最大免费世界聊天次数
    local _level = UserModel:level();
    local _count = 8000000;
    if (_level <= 29) then
        _count = 10;
    elseif (_level < 50) then
        _count = 20;
    end
    return _count - _sendCount;
end
-- //获取世界聊天数据
function ChatModel:getWorldMessage()
    return self.worldMessage;
end
-- //获取联盟的聊天数据
function ChatModel:getLeagueMessage()
    return self.leagueMessage;
end
-- //是否可以显示私聊信息提示
function ChatModel:isChatFlag()
    return not self.isPrivateMessageAchieve;
end
-- //获取私聊数据
function ChatModel:getPrivateMessage()
    self.isPrivateMessageAchieve = true;
    -- //标志获取了所有的私聊数据
    return self.privateMessage;
end
-- //更新世界聊天数据
function ChatModel:updateWorldMessage(_item)
    if (#self.worldMessage < self.maxChatRecordCount) then
        table.insert(self.worldMessage, _item);
    else
        table.remove(self.worldMessage, 1);
        table.insert(self.worldMessage, _item);
    end
    EventControler:dispatchEvent(ChatEvent.WORLD_CHAT_CONTENT_UPDATE);
    -- //分发世界聊天内容更新事件
end
-- //更新联盟聊天数据
function ChatModel:updateLeagueMessage(_item)
    if (#self.leagueMessage < self.maxChatRecordCount) then
        table.insert(self.leagueMessage, _item);
    else
        table.remove(self.leagueMessage, 1);
        table.insert(self.leagueMessage, _item);
    end
    -- //分发消息

end
-- //返回所有私聊对象的rid
function ChatModel:getAllPrivateRid()
    local rids = { };
    for key, value in pairs(self.fastPrivateMap) do
        table.insert(rids, key);
    end
    return rids;
end
-- //更新私聊中的数据
function ChatModel:updatePrivateMessage(_item)
    -- //确认发送消息的人物身份
    local _self_rid = UserModel:rid();
    local _rid = nil;
    if (_item.rid ~= _self_rid) then
        -- //如果发送消息的人不是自己
        _rid = _item.rid;
    else
        _rid = self.privateTargetPlayer.rid;
        -- //否则,取出目标对象
    end
    local object = self.fastPrivateMap[_rid];
    if (object ~= nil) then
        -- //插入相关人物的对话队列,并更换聊天的顺序
        table.insert(object.chatContent, _item);
        local _index = table.indexof(self.privateMessage, object);
        -- //一定可以找到,如果找不到则属于程序错误
        if (_index > 1) then
            table.remove(self.privateMessage, _index);
            table.insert(self.privateMessage, 1, object);
        end
    else
        object = { };
        self.fastPrivateMap[_item.rid] = object;
        object.online = true;
        -- //在线状态
        object.name = _item.name;
        -- //名字
        object.rid = _item.rid;
        -- //rid
        object.level = _item.level;
        -- //等级
        object.avatar = _item.avatar;
        -- //头像
        object.guildName = _item.guildName or "";
        -- //联盟
        object.chatContent = { };
        object.chatContent[1] = _item;
        table.insert(self.privateMessage, 1, object);
        -- //直接排在队列的首位
    end
    -- //分发私聊事件
    self.isPrivateMessageAchieve = false;
    EventControler:dispatchEvent(ChatEvent.PRIVATE_CHAT_CONTENT_UPDATE);
    -- //发起红点事件
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, {
        redPointType = HomeModel.REDPOINT.LEFTMARGIN.CHAT,
        isShow = not self.isPrivateMessageAchieve,
    } );
end
-- //更新聊天对象的在线状态
function ChatModel:updatePrivateOnlineState(players)
    for _index = 1, #players do
        local player = players[_index];
        local object = self.fastPrivateMap[player._id];
        object.online = player.userExt.logoutTime == 0;
    end
end
-- //向私聊数据队列中接入一个待聊天的对象
function ChatModel:insertOnePrivateObject(_player)
    -- //先查找是否有这个对象
    local player = self.fastPrivateMap[_player.rid];
    self.privateTargetPlayer = _player;
    if (player ~= nil) then
        local index = table.indexof(self.privateMessage, player);
        if (index > 1) then
            table.remove(self.privateMessage, index);
            table.insert(self.privateMessage, player);
        end
    else
        player = { };
        player.online = true;
        player.name = _player.name;
        player.level = _player.level;
        player.avatar = _player.avatar;
        player.rid = _player.rid;
        player.guildName = _player.guildName or "";
        player.chatContent = { };
        self.fastPrivateMap[_player.rid] = player;
        table.insert(self.privateMessage, 1, player);
    end
end
-- //清理私聊对象队列,清理目标为发起了聊天但是却没有真正聊天的对象,程序应该在退出私聊页面时调用一次
function ChatModel:clearPrivateQueue()
    for _index = #self.privateMessage, 1, -1 do
        local player = self.privateMessage[_index];
        if (#player.chatContent <= 0) then
            self.fastPrivateMap[player.rid] = nil;
            -- //在快速查找表中删除该玩家
            table.remove(self.privateMessage, _index);
            -- //从对话队列中删除该玩家
        end
    end
    self.privateTargetPlayer = nil;
    -- //清除聊天对象
end
return ChatModel;