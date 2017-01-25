-- //角色详情
-- //2016-5-11
-- //@author:xiaohuaxiong
local CompPlayerDetailView = class("CompPlayerDetailView", UIBase);
-- //tyope,type:1表示从世界聊天页面中进入
-- //_type:2表示从好友系统中进入
--//_type:3 表示从其他页面进入
-- //_callback回调函数
-- //传递给回调函数的参数
function CompPlayerDetailView:ctor(_winName, _params, _super_class, _type)
    CompPlayerDetailView.super.ctor(self, _winName);
    self.params = _params;
    self.super_class = _super_class;
    self.ui_type = _type;
    self.vCallback=nil;--//回调函数
end
--
function CompPlayerDetailView:loadUIComplete()
    self:registerEvent();
    -- //
    if (self.ui_type == 1) then
        self:setChatPlayerDetail(self.params);
        self:setChatSuperClass(self.super_class);
    elseif (self.ui_type == 2) then
        self:setFriendClass(self.super_class);
        self:setFriendRemoveDetail(self.params);
    elseif(self.ui_type==3)then
        self:setChatPlayerDetail(self.params);
    end
end
-- //注册监听
function CompPlayerDetailView:registerEvent()
    CompPlayerDetailView.super.registerEvent(self);
    self:registClickClose("out");
    self.UI_1.btn_close:setTap(c_func(self.clickButtonClose, self));
end
-- //设置上层调用,聊天页面中,调用私聊页面
function CompPlayerDetailView:setChatSuperClass(_super_class)
    self.chatClass = _super_class;
end
--//申请加好友后的回调函数
function CompPlayerDetailView:setAfterApplyCallback(_callback,_class)
    self.vCallback=_callback;
    self.vClass=_class;
end
function CompPlayerDetailView:clickButtonClose()
    self:startHide();
end
-- //设置任务角色详情,世界聊天中调用
function CompPlayerDetailView:setChatPlayerDetail(_player)
    -- //标题
    self.UI_1.txt_1:setString(GameConfig.getLanguage("chat_player_detail_1009"));
    -- //图标
    local _node = self.ctn_1;
    local _icon = FuncChar.icon(tostring(_player.avatar));
    local _sprite = display.newSprite(_icon);
    local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", _node, false, GameVars.emptyFunc)
    iconAnim:setScale(1.3)
    FuncArmature.changeBoneDisplay(iconAnim, "node", _sprite)
    -- //玩家名字
    local _name
    if (_player.name == nil or _player.name == "") then
        _name=GameConfig.getLanguage("tid_common_2006");
    else
        _name=_player.name;
    end      
    self.txt_1:setString(_name);
    local  x=self.txt_1:getPositionX();
    local  width=FuncCommUI.getStringWidth(_name,24,GameVars.fontName);
    self.mc_1:setPositionX(x+width+20);

    self.mc_1:showFrame(_player.vip + 1);
    -- //vip
    self.txt_5:setString("" .. _player.ability.total); 
--//安卓下修正坐标位置
    if(device.platform=="android")then
             local   x=self.txt_2:getPositionX();
             self.txt_2:setPositionX(x-12);
             self.txt_5:setPositionX(self.txt_5:getPositionX()+4);

             self.txt_1:setPositionX(self.txt_1:getPositionX()+2);
             self.mc_1:setPositionX(self.mc_1:getPositionX()+2);
    end
    -- //战力
    self.txt_6:setString("" .. _player.level);
    -- //等级
    self.txt_7:setString(_player.guildName or GameConfig.getLanguage("chat_own_no_league_1013"));
    -- //联盟
    -- //切换按钮
    self.UI_1.mc_1:showFrame(5);
    self.UI_1.mc_1.currentView.btn_3:setVisible(false);
    self.UI_1.mc_1.currentView.btn_4:setVisible(false);
    -- //注册监听事件
    if (_player.friend) then
        -- //如果已经是好友
        self.UI_1.mc_1.currentView.btn_2:setTap(c_func(self.clickButtonRemoveFriend, self));
        self.UI_1.mc_1.currentView.btn_2:setBtnStr(GameConfig.getLanguage("tid_friend_remove_button_title_1043"));
    else
        self.UI_1.mc_1.currentView.btn_2:setTap(c_func(self.clickButtonAddFriend, self));
        -- //加为好友
    end
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.clickButtonPrivateChat, self));
--//签名
   self.txt_8:setString(_player.userExt.sign or GameConfig.getLanguage("tid_friend_sign_max_word_1037"));
    self.player = _player;
end
-- //加为好友,
function CompPlayerDetailView:clickButtonAddFriend()
--//是否好友数目已经满了
    local  _max_friend_count=FuncDataSetting.getDataByConstantName("FriendLimit");
    local  _friend_count=FriendModel:getFriendCount();
    if(_friend_count>=_max_friend_count)then
         WindowControler:showTips(GameConfig.getLanguage("tid_friend_self_friend_count_reach_limit_1046"));
         return;
    end
    local function callback(param)
        if (param.result ~= nil) then
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_1015"));
            if(self.vCallback)then
                  self.vCallback(self.vClass);--//调用回调函数
            end
            self:startHide();
        elseif (param.error.message == "friend_exists") then 
            WindowControler:showTips("tid_friend_already_exist_1036");
        elseif (param.error.message == "friend_count_limit") then
            -- //好友已经达到上限
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_friend_count_limit_1030"));
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_failed_1016"));
        end
    end
    local _param = { };
    _param.rids = { };
    _param.rids[1] = self.player._id;
    FriendServer:applyFriend(_param, callback);
end
-- //删除好友
function CompPlayerDetailView:clickButtonRemoveFriend()
    local function callback(param)
        if (param.result ~= nil) then
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_remove_friend_ok_1042"));
            self:startHide();
            EventControler:dispatchEvent(FriendEvent.FRIEND_REMOVE_SOME_PLAYER,self.player._id);
        elseif (param.error.message == "friend_not_exists") then
            -- //好友不存在
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_not_exist_1021"));
            -- //不会有另一个错误
        end
    end
    local _param = { }
    _param.frid = self.player._id;
    FriendServer:removeFriend(_param, callback);
end
-- //私聊
function CompPlayerDetailView:clickButtonPrivateChat()
    -- //关闭自身,同时调用私聊页面
    local chatClass = self.chatClass;
    -- //将于对象玩家的聊天信息加入到缓存中
    local player = self.player;
    player.rid = player._id;
    local  _ui_type=self.ui_type;
    self:startHide();
    ChatModel:insertOnePrivateObject(player);
--//如果是从聊天页面进入的
    if(_ui_type==2)then
            chatClass:freshPrivateChat();
    elseif(_ui_type==3)then
            local   _open,_level=FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.CHAT);
            local   _user_level=UserModel:level();
            if(_user_level<_level)then
                     WindowControler:showTips(GameConfig.getLanguage("chat_common_level_not_reach_1014"):format(_level));
                     return;
            end
--//检测对方的等级
            if(player.level<_level)then--//对方未满足等级要求限制
                    WindowControler:showTips(GameConfig.getLanguage("chat_extra_other_dont_reach_level_limit_1002"));
                      return;
             end
            WindowControler:showWindow("ChatMainView",3);
    end
end
-- //设置聊天系统的引用
function CompPlayerDetailView:setFriendClass(_class)
    self.friendClass = _class;
end
-- //好友系统页面调用,删除好友
function CompPlayerDetailView:setFriendRemoveDetail(_player)
    -- //标题
    self.UI_1.txt_1:setString(GameConfig.getLanguage("chat_player_detail_1009"));
    -- //图标
    local _node = self.ctn_1;
    local _icon = FuncChar.icon(tostring(_player.avatar));
    local _sprite = display.newSprite(_icon);
    local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", _node, false, GameVars.emptyFunc)
    iconAnim:setScale(1.3)
    FuncArmature.changeBoneDisplay(iconAnim, "node", _sprite)
    -- //玩家名字
    local _name
    if (_player.name == nil or _player.name == "") then
        _name=GameConfig.getLanguage("tid_common_2006");
    else
        _name=_player.name;
    end      
    self.txt_1:setString(_name);
    local  x=self.txt_1:getPositionX();
    local  width=FuncCommUI.getStringWidth(_name,24,GameVars.fontName);
    self.mc_1:setPositionX(x+width+20);

    self.mc_1:showFrame(_player.vip + 1);
    -- //vip
    self.txt_5:setString("" .. _player.ability.total);
    if(device.platform=="android")then
             local   x=self.txt_2:getPositionX();
             self.txt_2:setPositionX(x-12);
             self.txt_5:setPositionX(self.txt_5:getPositionX()+4);

             self.txt_1:setPositionX(self.txt_1:getPositionX()+2);
             self.mc_1:setPositionX(self.mc_1:getPositionX()+2);
    end
    -- //战力
    self.txt_6:setString("" .. _player.level);
    -- //等级
    self.txt_7:setString(_player.guildName or GameConfig.getLanguage("chat_own_no_league_1013"));
    -- //联盟
    -- //按钮显示
    self.UI_1.mc_1:showFrame(4);
    if (_player.friend) then
        -- //如果已经是好友
        self.UI_1.mc_1.currentView.btn_2:setTap(c_func(self.clickButtonRemoveFriend2, self));
        self.UI_1.mc_1.currentView.btn_2:setBtnStr(GameConfig.getLanguage("tid_friend_remove_button_title_1043"));
    else
        self.UI_1.mc_1.currentView.btn_2:setTap(c_func(self.clickButtonAddFriend, self));
        -- //加为好友
    end
    -- //聊天
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.clickButtonJmpChat, self));
    self.txt_8:setString(_player.userExt.sign or GameConfig.getLanguage("tid_friend_sign_max_word_1037"));
    self.player = _player;
end
-- //从好友系统跳转到聊天
function CompPlayerDetailView:clickButtonJmpChat()
    -- //检查等级
     local   _open,_level=FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.CHAT);
     local   _user_level=UserModel:level();
     if(_user_level<_level)then
            WindowControler:showTips(GameConfig.getLanguage("chat_common_level_not_reach_1014"):format(_level));
             self:startHide();
             return;
     end
    local player = self.player;
    --//检测对方的等级
    if(player.level<_level)then--//对方未满足等级要求限制
             WindowControler:showTips(GameConfig.getLanguage("chat_extra_other_dont_reach_level_limit_1002"));
             self:startHide();
             return;
     end
    local _friend_class = self.friendClass;
    player.rid = player._id;
    self:startHide();
    ChatModel:insertOnePrivateObject(player);
    -- //关闭好友页面,同时打开聊天页面
    _friend_class:clickButtonBack();
    local _chat_ui = WindowControler:showTopWindow("ChatMainView", 3);
    -- //切换到私聊
end
-- //从好友系统中删除好友
function CompPlayerDetailView:clickButtonRemoveFriend2()
    local function callback(param)
        if (param.result ~= nil) then
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_remove_friend_ok_1042"));
            local _friend_class = self.friendClass;
            EventControler:dispatchEvent(FriendEvent.FRIEND_REMOVE_SOME_PLAYER,self.player._id);
            self:startHide();
            -- //调用好友系统中的刷新函数
            _friend_class:freshFriendListUICommon();
        elseif (param.error.message == "friend_not_exists") then
            -- //好友不存在
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_not_exist_1021"));
            -- //不会有另一个错误
        end
    end
    local _param = { }
    _param.frid = self.player._id;
    FriendServer:removeFriend(_param, callback);
end
return CompPlayerDetailView;