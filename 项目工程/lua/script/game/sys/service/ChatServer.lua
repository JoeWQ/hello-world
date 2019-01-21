--//聊天系统协议分发
--//2016-5-9
--/author:xiaohuaxiong
local  ChatServer=class("ChatServer");
--//初始化,注册监听事件
function  ChatServer:init()
--//
      EventControler:addEventListener("notify_chat_world_3512",self.requestWorldMessage,self);
      EventControler:addEventListener("notify_chat_league_3524",self.requestLeagueMessage,self);
      EventControler:addEventListener("notify_chat_private_3516",self.requestPrivateMessage,self);
end
--//世界聊天中消息监听
function ChatServer:requestWorldMessage(param)
     ChatModel:updateWorldMessage(param.params.params.data);
end
--//联盟聊天中消息推送
function ChatServer:requestLeagueMessage(param)
     ChatModel:updateLeagueMessage(param.params.params.data);
end
--//私人聊天中消息推送
function ChatServer:requestPrivateMessage(param)
     ChatModel:updatePrivateMessage(param.params.params.data);
end
--//向世界聊天中发送消息
function ChatServer:sendWorldMessage(param,callback)
        Server:sendRequest(param,MethodCode.chat_send_message_world_3501,callback,nil,nil,true);
end
--//向联盟聊天中发送消息
function    ChatServer:sendLeagueMessage(param,callback)
        Server:sendRequest(param,MethodCode.chat_send_message_league_3503,callback,nil,nil,true);
end
--//向私聊页面中发送消息
function ChatServer:sendPrivateMessage(param,callback)
        Server:sendRequest(param,MethodCode.chat_send_message_private_3505,callback,nil,nil,true);
end
--//分享战报
function ChatServer:shareBattleMessage(param,callback)
        Server:sendRequest(param,MethodCode.chat_send_battle_info_3507,callback,nil,nil,true);
end
--//战报回放
function ChatServer:battleMessagePlay(param,callback)
        Server:sendRequest(param,MethodCode.chat_battle_info_play_3509,callback,nil,nil,true);
end
--//查询角色信息
function ChatServer:queryPlayerInfo(param,callback)
       Server:sendRequest(param,MethodCode.query_player_info_337,callback,nil,nil,true);
end
return  ChatServer;