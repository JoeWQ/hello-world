-- //好友系统中所有的协议封装
-- @2016-4-23
-- @xiaohuaxiong
local FriendServer = class("FriendServer");
-- //添加监听事件
function FriendServer:init()
    -- //监听好友申请,好友赠送体力事件
    EventControler:addEventListener("notify_friend_send_sp_2926", self.requestFriendSp, self);
    -- //其他玩家申请加好友事件
    EventControler:addEventListener("notify_friend_apply_request_2924", self.requestFriendApply, self);
end
-- 好友赠送体力事件
function FriendServer:requestFriendSp()
    local function callback(param)
        if (param.result ~= nil) then
            param.result.data.spCount=param.result.data.spCount or 0;
            FriendModel:updateFriendSendSp(param.result.data);
        else
            echo("---listen friend send sp event failed-----");
        end
    end
    local param = { };
    param.page = 1;
    self:getFriendListByPage(param, callback);
end
-- //好友申请变化
function FriendServer:requestFriendApply()
    local function callback(param)
        if (param.result ~= nil) then
            FriendModel:updateFriendApply(param.result.data);
        end
    end
    local param = { };
    param.page = 1;
    -- //获取好友申请表
    self:getFriendApplyList(param, callback);
end
-- //获取好友列表
function FriendServer:getFriendListByPage(_param, _callback)
    Server:sendRequest(_param, MethodCode.friend_page_list2903, _callback, nil, nil, true);
end
-- //获取好友申请列表
function FriendServer:getFriendApplyList(_param, _callback)
    Server:sendRequest(_param, MethodCode.friend_apply_list2905, _callback, nil, nil, true);
end
-- //获取推荐好友列表
function FriendServer:getFriendRecommendList(_param, _callback)
    Server:sendRequest(_param, MethodCode.friend_recommend_list2907, _callback, nil, nil, true);
end
-- //获取搜索的好友列表
function FriendServer:getFriendSearchList(_param, _callback)
    Server:sendRequest(_param, MethodCode.friend_search_list2909, _callback, nil, nil, true);
end
-- //向对方申请好友
function FriendServer:applyFriend(_param, _callback)
    Server:sendRequest(_param, MethodCode.friend_apply_request2911, _callback, nil, nil, true);
end
-- //同意对方加好友的请求
function FriendServer:approveFriend(_param, _callback)
    Server:sendRequest(_param, MethodCode.friend_approve_request2913, _callback, nil, nil, true);
end
-- //拒绝对方好友请求
function FriendServer:rejectFriend(_param, _callback)
    Server:sendRequest(_param, MethodCode.friend_reject_request2915, _callback, nil, nil, true);
end
-- //删除好友
function FriendServer:removeFriend(_param, _callback)
    Server:sendRequest(_param, MethodCode.friend_remove_request2917, _callback, nil, nil, true);
end
-- //向好友赠送体力
function FriendServer:sendFriendSp(_param, _callback)
    Server:sendRequest(_param, MethodCode.friend_send_sp2919, _callback, nil, nil, true);
end
-- //获取好友赠送的体力
function FriendServer:achieveFriendSp(_param, _callback)
    Server:sendRequest(_param, MethodCode.friend_achieve_sp2921, _callback, nil, nil, true);
end
-- //修改玩家的签名
function FriendServer:modifyUserMotto(_param, _callback)
    Server:sendRequest(_param, MethodCode.friend_user_motto2901, _callback, nil, nil, true);
end
return FriendServer;