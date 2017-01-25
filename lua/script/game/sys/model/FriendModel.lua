-- //@好友系统的数据
-- //&2016-4-23
-- //@author:xiaohuaxiong
local FriendModel = class("FriendModel");
-- //不属于玩家角色本身的属性
function FriendModel:init(_data)
    -- //好友列表
    self.friendList = { };
    -- //当前是好友列表中的多少页(好友界面需要分页显示好友)
    self.friendNowPage = 1;
    -- //好友的数目
    self.friendCount = 0;
    -- //向自己申请好友的玩家列表
    self.friendApplyList = { };
    -- //当前处于申请好友页面的第几页
    self.applyFriendNowPage = 1;
    -- //系统推荐的好友列表
    self.recommendFriendList = { };
    -- //自己搜索的好友列表
    self.researchFriendList = { };
    -- //玩家自己的签名
    self.motto = _data.sign;
    if (self.motto == nil) then
        self.motto = "";
    end
    -- //好友申请数目
    self.friendApplyCount = 0;
    -- //好友赠送的体力数目
    self.friendSendSpCount = 0;
end
function FriendModel:isFriendApply()
    -- //是否有好友申请
    return self.friendApplyCount > 0;
end
function FriendModel:isFriendSendSp()
    -- //是否满足领取好友赠送的体力的条件
    local _maxSpNum = FuncDataSetting.getDataByConstantName("ReceiveTimes");
    -- //体力领取的上限
    local _achieveCount = CountModel:getCountByType(FuncCount.COUNT_TYPE.COUNT_TYPE_ACHIEVE_SP_COUNT);
    local _other_flag = UserExtModel:sp() + FuncDataSetting.getDataByConstantName("FriendGift") <= FuncDataSetting.getDataByConstantName("HomeCharBuySPMax");
    local _send_flag = _achieveCount < _maxSpNum and self.friendSendSpCount > 0 and _other_flag
    return _send_flag;
end
-- //检查主页面是否需要显示红点
function FriendModel:checkHomeRedPointEvent(showRed, eventType)
    --        local    showRed=false;
    -- //如果满足需要刷新的条件,发送消息
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, {
        redPointType = HomeModel.REDPOINT.LEFTMARGIN.FRIEND,
        isShow = self:isFriendApply() or self:isFriendSendSp(),
        eventType = eventType-- //需要在标记红点事件上做细分时使用
    }
    );
end
-- //更新好友赠送体力数据,注意这里面传送的数据
function FriendModel:updateFriendSendSp(_data)
    self.friendCount = _data.count;
    self.friendSendSpCount = _data.spCount;
    self:checkHomeRedPointEvent(_data.spCount > 0, FriendEvent.FRIEND_SEND_SP_UPDATE);
    -- //分发好友赠送体力事件
    EventControler:dispatchEvent(FriendEvent.FRIEND_SEND_SP_UPDATE);
end
-- //好友申请数据更新
function FriendModel:updateFriendApply(_data)
    -- //判断是否有好友申请
    self.friendApplyCount = _data.count;
    self:checkHomeRedPointEvent(_data.count > 0, FriendEvent.FRIEND_APPLY_REQUEST);
    EventControler:dispatchEvent(FriendEvent.FRIEND_APPLY_REQUEST);
end
function FriendModel:getFriendList()
    return self.friendList;
end
-- //
function FriendModel:setFriendList(_list)
    self.friendList = _list;
end
-- //当前是第几页
function FriendModel:getNowFriendPage()
    return self.friendNowPage;
end
-- //设置当前第几页
function FriendModel:setNowFriendPage(_nowPage)
    self.friendNowPage = _nowPage;
end
-- //每页显示的数目
function FriendModel:getCountPerPage()
    return 10;
end
-- //好友数目
function FriendModel:getFriendCount()
    return self.friendCount;
end
-- //
function FriendModel:setFriendCount(_count)
    self.friendCount = _count;
end
-- //获取向自己申请加好友的申请列表
function FriendModel:getFriendApplyList()
    return self.friendFriendList;
end
-- //
-- //获取玩家的签名
function FriendModel:getUserMotto()
    if (self.motto == "") then
        return GameConfig.getLanguage("tid_friend_sign_max_word_1037");
    end
    return self.motto;
end
-- //设置玩家的签名
function FriendModel:setUserMotto(_motto)
    self.motto = _motto;
end
-- //设置推荐好友列表
---------------------------------
-- //监听事件,是否好友数目发生了变化
function FriendModel:checkFriendNum(_friendMap)

end
-- //好友赠送的体力发生了变化
function FriendModel:checkFriendSp()

end
return FriendModel;
