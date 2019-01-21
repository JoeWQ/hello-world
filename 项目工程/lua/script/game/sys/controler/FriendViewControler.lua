
local FriendViewControler = class("FriendViewControler");

function FriendViewControler:ctor()

end

function FriendViewControler:showView()
--//检查等级限制
    local   _open,_level=FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FRIEND);
    local  _user_level=UserModel:level();
    if(_user_level<_level)then
             WindowControler:showTips(GameConfig.getLanguage("chat_common_level_not_reach_1014"):format(_level));
             return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
            local _friendUI = WindowControler:showWindow("FriendMainView",_param.result.data,1);
        else
            echo("---get friend list error--", _param.error.code, _param.error.message);
        end
    end
--//打开申请页面
    local function _callback2(_param)
        if(_param.result~=nil)then
            local _friendUI=WindowControler:showWindow("FriendMainView",_param.result.data,3);
        else
            echo("-------get friend apply error----------");
        end
    end
    if(FriendModel:isFriendSendSp())then
          local param = { };
          param.page = 1;
          FriendServer:getFriendListByPage(param, _callback);
    elseif(FriendModel:isFriendApply())then
          local   _param2={};
          _param2.page=1;
          FriendServer:getFriendApplyList(_param2,_callback2);
    else
          local param3 = { };
          param3.page = 1;
          FriendServer:getFriendListByPage(param3, _callback);
    end
end

function FriendViewControler:forceShowFriendList()
    local   _open,_level=FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FRIEND);
    local  _user_level=UserModel:level();
    if(_user_level<_level)then
             WindowControler:showTips(GameConfig.getLanguage("chat_common_level_not_reach_1014"):format(_level));
             return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
            local _friendUI = WindowControler:showWindow("FriendMainView",_param.result.data,1);
        else
            echo("---get friend list error--", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.page = 1;
    FriendServer:getFriendListByPage(param, _callback);
end

--//打开好友详情页面,传入玩家的role id
function FriendViewControler:showPlayer(_playerId)
    local function _callback(param)
            if(param.result~=nil)then
--//必须满足等级要求
                 local   _fdetail=param.result.data.data[1];
                 local   _playerUI=WindowControler:showTopWindow("CompPlayerDetailView",_fdetail,nil,3);
            end
    end
    local  _param={};
    _param.rids={};
    _param.rids[1]=_playerId;
    ChatServer:queryPlayerInfo(_param,_callback);
end
--//
return FriendViewControler;











