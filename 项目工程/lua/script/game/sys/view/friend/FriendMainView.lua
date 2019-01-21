-- //好友系统
-- &2016-4-23
-- @author:xiaohuaxiong
local FriendMainView = class("FriendMainView", UIBase);
local ITEM_MOVE_DISTANCE=133;
--//_type,1:好友列表,2:添加好友,3:好友申请
function FriendMainView:ctor(_winName,_params,_type)
    FriendMainView.super.ctor(self, _winName);
    -- //有关好友的页面信息
    self.friendMap = nil;
    -- //当前被选中的按钮,避免页面的不必要的加载产生的不流畅情况
    self.selectButton = 1;
    -- //好友列表页面的索引,这个值会在setFriendList函数中自动调整,作为初始值,应该设置成1
    self.nowFriendPage = 1;
    self.nowFriendSelectedIndex=0;--//当前被选中的好友
    -- //当前申请好友页面中所处于的页面索引
    self.nowFriendApplyPage = 1;
    self.nowFriendApplySelectedIndex=0;--//当前好友申请页面中被选中的好友申请索引
    -- //好友列表缓存,考虑到好友列表的特殊性,比如好友的登录时间一直在变化,好有可能随时有赠送体力,并且好友列表需要联网分页,所以需要使用特殊的形式来缓存
    self.friendListCache = { };
    -- //键是好友的id,值是有关好友的信息
    -- //好友申请列表缓存
    self.friendApplyListCache = { };
    -- //推荐好友列表
    self.friendRecommendListCache = { };
    self.params=_params;
    self.ui_type=_type;
--//第N次进入
   self.firstEntry={[1]=0,[2]=0,[3]=0};
end
-- after  load  ui finished
function FriendMainView:loadUIComplete()
    self:registerEvent();
    self:setBaseResource();
    -- //组件对齐
    FuncCommUI.setViewAlign(self.panel_back, UIAlignTypes.RightTop);
    -- //返回
    FuncCommUI.setViewAlign(self.panel_name, UIAlignTypes.LeftTop);
    -- //标题
    FuncCommUI.setViewAlign(self.panel_ziyuan, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.panel_yeqian,UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.scale9_ding,UIAlignTypes.LeftTop);
    self.scale9_ding:setContentSize(cc.size(GameVars.width,self.scale9_ding:getContentSize().height));
--    FuncCommUI.setViewAlign(self.panel_yeqian.panel_sheng,UIAlignTypes.Left);
 --   FuncCommUI.setViewAlignByCenter(self.panel_yeqian.panel_1,1.0,GameVars.height/GAMEHEIGHT);
    -- //-- //添加好友红点隐藏
    self.panel_yeqian.mc_2.currentView.panel_hongdian:setVisible(false);
    self.panel_yeqian.mc_1.currentView.panel_hongdian:setVisible(false);
    self.panel_yeqian.mc_3.currentView.panel_hongdian:setVisible(false);
     
    self.friendMap={};
    self.friendMap.count=FriendModel:getFriendCount();
--//调用函数
   if(self.ui_type==1)then
           FriendModel:setFriendList(self.params.friendList);
           FriendModel:setFriendCount(self.params.count);
           self:setFriendMap(self.params);
   elseif(self.ui_type==3)then
            FriendModel:updateFriendApply(self.params);
            self:setFriendApplyMap(self.params);
   end
   self.scroll_list:enableMarginBluring();
   self.scroll_list2:enableMarginBluring();
   self.scroll_list3:enableMarginBluring();
end
-- //注册按钮事件
function FriendMainView:registerEvent()
    FriendMainView.super.registerEvent(self);
    self.panel_yeqian.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.clickButtonFriendList, self),nil,true);
    self.panel_yeqian.mc_2.currentView.btn_1:setTouchedFunc(c_func(self.clickButtonAddFriend, self),nil,true);
    self.panel_yeqian.mc_3.currentView.btn_1:setTouchedFunc(c_func(self.clickButtonApplyFriend, self),nil,true);
    self.panel_back.btn_back:setTap(c_func(self.clickButtonBack, self));
--//通知事件
    EventControler:addEventListener(FriendEvent.FRIEND_APPLY_REQUEST,self.notifyFriendApply,self);
    EventControler:addEventListener(FriendEvent.FRIEND_SEND_SP_UPDATE,self.notifyFriendSendSp,self);
    EventControler:addEventListener(FriendEvent.FRIEND_REMOVE_SOME_PLAYER,self.removeSomePlayer,self);
end
--//删除一个好友之后需要做的后期处理
function FriendMainView:removeSomePlayer(_param)
    local    _id=_param.params;
    if(self.friendListCache[_id]~=nil)then
         self.friendListCache[_id]=nil;
    end
end
function FriendMainView:clickButtonBack()
    self:startHide();
end
-- //背景板适配 
function FriendMainView:setBaseResource()
   local  _scale=GameVars.width/GAMEWIDTH;
 --  FuncCommUI.setScale9SpriteAlign(self.scale9_bg,UIAlignTypes.Middle,GameVars.width/GAMEWIDTH,GameVars.height/GAMEHEIGHT);
--   FuncCommUI.setScale9Align(self.scale9_bg,UIAlignTypes.Middle,1,1);
--   FuncCommUI.setScale9Align(self.panel_yeqian.panel_1,UIAlignTypes.Middle,1.0,1.0);
end
-- //好友赠送体力通知事件
function FriendMainView:notifyFriendSendSp()
    if (self.selectButton ~= 1) then
        self.panel_yeqian.mc_1.currentView.panel_hongdian:setVisible(FriendModel:isFriendSendSp());
    else
        self.panel_yeqian.mc_1:getViewByFrame(1).panel_hongdian:setVisible(FriendModel:isFriendSendSp());
    end
end
-- //好友申请通知事件
function FriendMainView:notifyFriendApply()
    -- //如果当前不是好友申请页面
    if (self.selectButton ~= 3) then
        self.panel_yeqian.mc_3.currentView.panel_hongdian:setVisible(FriendModel:isFriendApply());
    else
        self.panel_yeqian.mc_3:getViewByFrame(1).panel_hongdian:setVisible(FriendModel:isFriendApply());
    end
end
-- //管理好友的所有申请请求
function FriendMainView:setFriendApplyMap(_friendApplyMap)
    self.friendApplyMap = _friendApplyMap;
    for _index = 1, #_friendApplyMap.applyList do
        -- //对数据进行处理
        -- //查找缓存
        local _new_item = _friendApplyMap.applyList[_index];
        local _old_item = self.friendApplyListCache[_new_item._id];
        if (_old_item ~= nil) then
            for key, value in pairs(_new_item) do
                _old_item[key] = value;
            end
            _new_item = _old_item;
        end
        self.friendApplyListCache[_new_item._id] = _new_item;
        _friendApplyMap.applyList[_index] = _new_item;
        _friendApplyMap.applyList[_index].index = _index;
    end
    -- //最大分页
    --           self.nowFriendApplyPage=0;
    --           if(#_friendApplyMap>0)then
    --                   self.nowFriendApplyPage=1;
    --           end
    if(#_friendApplyMap.applyList>0)then
         self.mc_10:showFrame(1);
    else
         self.mc_10:showFrame(4);
    end
    self:setFriendApplyList();
end
-- //设置好友申请页面列表
function FriendMainView:setFriendApplyList()
    if (self.selectButton ~= 3) then
        self.panel_yeqian["mc_" .. self.selectButton]:showFrame(1);
    end
    -- //好友列表页面是否显示红点
    self.panel_yeqian.mc_1.currentView.panel_hongdian:setVisible(FriendModel:isFriendSendSp());
    if(self.panel_yeqian.mc_3.currentView.panel_hongdian~=nil)then
           self.panel_yeqian.mc_3.currentView.panel_hongdian:setVisible(false);
    end
    self.firstEntry[3]=self.firstEntry[3]+1;
    self.selectButton = 3;
    self.panel_yeqian.mc_3:showFrame(2);
    -- //隐藏不相关的面板,同时显示相关的组件
    self.panel_1:setVisible(false);
    self.panel_3:setVisible(false);
    self.scroll_list:setVisible(false);
    self.scroll_list2:setVisible(false);
    self.scroll_list3:setVisible(true);
    local panel = self.panel_2;
    panel:setVisible(true);
    self.panel_fanye:setVisible(true);
    -- //好友数目
    panel.txt_2:setString(FriendModel:getFriendCount().."/"..FuncDataSetting.getDataByConstantName("FriendLimit"));
    panel.txt_4:setString("" .. self.friendApplyMap.count)
    -- //好友申请的数目;
    -- //页签显示
    local _maxCountPerPage = FriendModel:getCountPerPage();
    local _maxPage = math.floor(self.friendApplyMap.count / _maxCountPerPage);
    if (self.friendApplyMap.count % _maxCountPerPage > 0) then
        _maxPage = _maxPage + 1;
    end
    self.totalFriendApplyPage = _maxPage;
    if (self.nowFriendApplyPage < 0) then
        -- //修正当前页面显示,防止好友动态更新引起的bug
        self.nowFriendApplyPage = 0;
    elseif (self.nowFriendApplyPage > _maxPage) then
        self.nowFriendApplyPage = _maxPage;
    end
    self.panel_fanye:setVisible(_maxPage>1);
    self.panel_fanye.panel_3.txt_1:setString("" .. self.nowFriendApplyPage .. "/" .. _maxPage);
--    self.panel_fanye.btn_3:enabled(self.nowFriendApplyPage > 1);
 --   self.panel_fanye.btn_4:enabled(self.nowFriendApplyPage < _maxPage);
    self.panel_fanye.btn_3:setTap(c_func(self.clickButtonPrevPage, self));
    -- //向左翻页
    self.panel_fanye.btn_4:setTap(c_func(self.clickButtonNextPage, self));
    -- //单元格
    local _cells={}
    local function genCellItem(_item)
        local _cell = UIBaseDef:cloneOneView(panel.panel_1);
        self:setFriendApplyCellItem(_cell, _item);
--        if(self.firstEntry[3]<=1)then
--            table.insert(_cells,_cell);
--            _cell:setVisible(false);
--            _cell:runAction(act.moveby(0, 0, -ITEM_MOVE_DISTANCE*#_cells));
--            if(#_cells>=#self.friendApplyMap.applyList)then
--                self:doActionForItem(_cells);
--            end
--        end
        return _cell;
    end
    local _scrollParam = {
        data = self.friendApplyMap.applyList;
        createFunc = genCellItem,
        perNums = 1,
        offsetX = 4,
        offsetY = 3,
        widthGap = 0,
        heightGap=2,
        itemRect = { x = 0, y = - 133, width = 758, height = 133 },
        perFrame = 1,
    };
    panel.panel_1:setVisible(false);
    self.scroll_list3:setFillEaseTime(0.3);
    self.scroll_list3:setItemAppearType(1, true);
    self.scroll_list3:styleFill( { _scrollParam });
    if(self.lastFriendApplyPage ~= self.nowFriendApplyPage)then
 --         self.scroll_list3:gotoTargetPos(self.nowFriendApplySelectedIndex, 1);
          self.scroll_list3:gotoTargetPos(1, 1);
          self.lastFriendApplyPage=self.nowFriendApplyPage;
    end
    -- //如果没有好友申请
    if (self.friendApplyMap.count <= 0) then
        FilterTools.setGrayFilter(panel.btn_1);
        FilterTools.setGrayFilter(panel.btn_2);
    else
        FilterTools.clearFilter(panel.btn_1);
        FilterTools.clearFilter(panel.btn_2);
    end
    panel.btn_1:setVisible(self.friendApplyMap.count > 0);
    -- //全部拒绝
    panel.btn_2:setVisible(self.friendApplyMap.count > 0);
    -- //全部同意
    -- //注册回调函数
    panel.btn_1:setTap(c_func(self.clickButtonRejectAllAppply, self));
    panel.btn_2:setTap(c_func(self.clickButtonApproveAllApply, self));
end
-- //格式化登录情况详情
function formatLoginInfo(loginTime)
    -- //登录情况
    local _loginInfo = "";
    loginTime=os.time()-loginTime;
    if (loginTime > 30 * 24 * 3600) then
        -- 大于30天
        _loginInfo = GameConfig.getLanguage("tid_friend_long_ago_1009");
    elseif (loginTime > 24 * 3600) then
        _loginInfo = GameConfig.getLanguage("tid_friend_some_day_ago_1010"):format(math.floor(loginTime /(24 * 2600)));
    elseif (loginTime > 3600) then
        _loginInfo = GameConfig.getLanguage("tid_friend_some_hour_ago_1011"):format(math.floor(loginTime / 3600));
    elseif (loginTime > 60) then
        _loginInfo = GameConfig.getLanguage("tid_friend_some_minute_ago_1012"):format(math.floor(loginTime / 60));
    else
        _loginInfo = GameConfig.getLanguage("tid_friend_just_right_1013");
    end
    return GameConfig.getLanguage("tid_friend_login_state_1014") .. _loginInfo;
end
-- //更新好友申请单元格页面
function FriendMainView:setFriendApplyCellItem(_cell, _item)
    -- //好友图标
    local _icon = FuncChar.icon(tostring(_item.avatar));
    local _node = _cell.panel_1.ctn_1;
    _node:removeAllChildren();
    local _sprite = display.newSprite(_icon);
	local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", _node, false, GameVars.emptyFunc)
	iconAnim:setScale(1.3)
	FuncArmature.changeBoneDisplay(iconAnim, "node", _sprite)

    local _name=_item.name;-- //名字
    if(_name==nil or _name=="")then
            _name=GameConfig.getLanguage("tid_common_2006");      
    end
    _cell.txt_1:setString(_name);
    SetVIPPosition(_cell.txt_1,_cell.mc_1,_name);
    _cell.txt_3:setString("" .. _item.level);
    -- //等级
    _cell.txt_5:setString("" .. _item.ability.total);
    -- //战力
    if (_item.vip > 0) then
        -- VIP
        _cell.mc_1:showFrame(_item.vip);
    else
        _cell.mc_1:setVisible(false);
    end
    -- //登录情况
    _cell.txt_6:setString(formatLoginInfo(_item.userExt.loginTime));
    -- //注册按钮回调
    _cell.btn_1:setTap(c_func(self.clickCellButtonRejectApply, self, _item));
    -- //拒绝好友申请
    _cell.btn_2:setTap(c_func(self.clickCellButtonApproveApply, self, _item));
    -- //同意好友申请
--//注册查看玩家详情
   _cell.panel_1:setTouchedFunc(c_func(self.clickCellButtonQueryPlayer,self,_item),nil,true,c_func(self.onCellBeganEvent,self,_item),c_func(self.onCellMovedEvent,self,_item));
end
-- //公共函数,在需要重新联网的情况下调用
-- //刷新当前页,调用时一定要确保,当前页一定有好友,否则会出现bug
function FriendMainView:freshFriendApplyCommon()
    local function _callback(_param)
        if (_param.result ~= nil) then
            FriendModel:updateFriendApply(_param.result.data);
            self:setFriendApplyMap(_param.result.data);
        else
            echo("----FriendMainView:freshFriendApplyCommon--", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.page = self.nowFriendApplyPage;
    FriendServer:getFriendApplyList(param, _callback);
end
-- //同意或者拒绝好友申请时,如果处于最后一页,并且好友申请的数目大于1的情况下,需要手工刷新页面
function FriendMainView:onFriendApplyChanged(_item, _cell)
    local function _delayAfterRemove(...)
 --       _cell:setVisible(false);
        -- //重新编排顺序,为了简化操作,从最初的开始
        for _index = 1, #self.friendApplyMap.applyList do
            self.friendApplyMap.applyList[_index].index = _index;
        end
        self:setFriendApplyList();
    end
    self:delayCall(_delayAfterRemove, 0.1);
end
-- //拒绝好友申请,当前好友组件移除掉,同时判定是否应该重新联网刷新页面
function FriendMainView:clickCellButtonRejectApply(_item)
    local function _callback(_param)
        if (_param.result ~= nil) then
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_reject_apply_1029"));
            -- //弹出提示,已经拒绝好友
            -- //播放组件被移除动画
 --           local _moveAction = cc.MoveBy:create(0.3, cc.p(-500, 0));
--            local _cell = self.scroll_list3:getViewByData(_item);
            -- self.friendApplyChild[_item.index];
 --           _cell:runAction(_moveAction);
            -- //移除相关数据与组件
            self.scroll_list3:clearOneView(_item);
            table.remove(self.friendApplyMap.applyList, _item.index);
            self.friendApplyMap.count = self.friendApplyMap.count - 1;
            self.nowFriendApplySelectedIndex=_item.index;
            if (self.nowFriendApplyPage >= self.totalFriendApplyPage) then
                -- //如果是最后一页
                if (self.friendApplyMap.count > 0) then
                    -- //如果最后一页的数组现在不为0,则不需要联网刷新
                    FriendModel:updateFriendApply(self.friendApplyMap);
                    -- //分发好友申请通知
                    self:onFriendApplyChanged(_item, _cell);
                else
                    -- //否则现在需要联网
                    self.nowFriendApplyPage = self.nowFriendApplyPage - 1;
                    if (self.nowFriendApplyPage <= 0) then
                        self.nowFriendApplyPage = 1;
                    end
                    self:freshFriendApplyCommon();
                end
            else
                self:freshFriendApplyCommon();
            end
        else
           if (_param.error.message == "friend_exists" or _param.error.message=="friend_apply_not_exists") then
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_already_exist_1036"));
           else
            -- //如果拒绝了好友申请,逻辑上是不会出现错误码的
                 echo("---FriendMainView:clickCellButtonRejectApply-----", _param.error.code, _param.error.message);
            end 
        end
    end
    local param = { };
    param.frid = _item._id;
    param.isAll = 0;
    FriendServer:rejectFriend(param, _callback);
end
-- //全部拒绝好友申请
function FriendMainView:clickButtonRejectAllAppply()
    -- //首先判断是否有好友申请
    if (self.friendApplyMap.count <= 0) then
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_friend_apply_1031"));
        return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_reject_apply_1029"));
            self.friendApplyMap.applyList = { };
            self.friendApplyMap.count = 0;
            FriendModel:updateFriendApply(self.friendApplyMap);
            self:setFriendApplyList();
        else
            echo("--FriendMainView:clickButtonRejectAllAppply--", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.isAll = 1;
    FriendServer:rejectFriend(param, _callback);
end
-- //同意好友申请
function FriendMainView:clickCellButtonApproveApply(_item)
--//是否好友数目已经满了
    local  _max_friend_count=FuncDataSetting.getDataByConstantName("FriendLimit");
    local  _friend_count=FriendModel:getFriendCount();
    if(_friend_count>=_max_friend_count)then
         WindowControler:showTips(GameConfig.getLanguage("tid_friend_self_friend_count_reach_limit_1046"));
         return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
           if(_param.result.data.count<=0)then--//没能添加一个好友
               WindowControler:showTips(GameConfig.getLanguage("tid_friend_friend_count_limit_1030"));
               return;
           end
            -- //添加好友
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_approve_apply_1031"));
 --           local _cell = self.scroll_list3:getViewByData(_item);
            -- self.friendApplyChild[_item.index];
            -- //移除相关的数据
            table.remove(self.friendApplyMap.applyList, _item.index);
            self.friendApplyMap.count = self.friendApplyMap.count - 1;
            self.friendMap.count = self.friendMap.count + 1;
--//刷新UI按钮
            -- //好友的数目+1
            FriendModel:setFriendCount(self.friendMap.count);
            -- //同时刷新缓存
--            local _moveAction = cc.MoveBy:create(0.3, cc.p(-500, 0));
--            _cell:runAction(_moveAction);
            self.scroll_list3:clearOneView(_item);
            self.nowFriendApplySelectedIndex=_item.index;
            if (self.nowFriendApplyPage >= self.totalFriendApplyPage) then
                -- //如果当前是最后一页
                if (self.friendApplyMap.count > 0) then
                    -- //并且该页中还有组件
                    FriendModel:updateFriendApply(self.friendApplyMap);
                    self:onFriendApplyChanged(_item, _cell);
                else
                    self.nowFriendApplyPage = self.nowFriendApplyPage - 1;
                    if (self.nowFriendApplyPage <= 0) then
                        self.nowFriendApplyPage = 1;
                    end
                    self:freshFriendApplyCommon();
                end
            else
                self:freshFriendApplyCommon();
            end
        else
            if (_param.error.message == "friend_count_limit") then
                -- //好友已经达到上限
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_friend_count_limit_1030"));
             elseif (_param.error.message == "friend_exists" or _param.error.message=="friend_apply_not_exists") then
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_already_exist_1036"));
            end
        end
    end
    local param = { };
    param.frid = _item._id;
    param.isAll = 0;
    FriendServer:approveFriend(param, _callback);
end
-- //全部同意好友申请
function FriendMainView:clickButtonApproveAllApply()
    if (self.friendApplyMap.count <= 0) then
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_friend_apply_1031"));
        return;
    end
--//是否好友数目已经满了
    local  _max_friend_count=FuncDataSetting.getDataByConstantName("FriendLimit");
    local  _friend_count=FriendModel:getFriendCount();
    if(_friend_count>=_max_friend_count)then
         WindowControler:showTips(GameConfig.getLanguage("tid_friend_self_friend_count_reach_limit_1046"));
         return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
            self.friendMap.count = self.friendMap.count + _param.result.data.count;
            -- //好友的数目增加
            FriendModel:setFriendCount(self.friendMap.count);
            -- //刷新缓存
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_approve_all_apply_1032"):format(_param.result.data.count));
            self.nowFriendApplyPage = 1;
            self:freshFriendApplyCommon();
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_can_not_add_friend_1033"));
            echo("--clickButtonApproveAllApply--", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.isAll = 1;
    FriendServer:approveFriend(param, _callback);
end
-- //设置好友数据,必须是从其他页面进入该页面才能调用
function FriendMainView:setFriendMap(_friendMap)
    -- //当前页面是好友列表页面
    self.friendMap = _friendMap;
    for _index = 1, #_friendMap.friendList do
        local _new_item = _friendMap.friendList[_index];
        -- //从缓存中查找
        local _old_item = self.friendListCache[_new_item._id];
        if (_old_item ~= nil) then
            for key, value in pairs(_new_item) do
                _old_item[key] = value;
            end
            -- //特殊的键需要处理
            _old_item.hasSend = _new_item.hasSend;
            _old_item.noSend = _new_item.noSend;
            _old_item.hasGetSp = _new_item.hasGetSp;
            _old_item.hasSp = _new_item.hasSp;
            _old_item.noSp = _new_item.noSp;
            _new_item = _old_item;
            local    _cell=self.scroll_list:getViewByData(_old_item);
            if(_cell~=nil)then
                   self:setFriendListCell(_cell,_old_item);
            end
        end
        self.friendListCache[_new_item._id] = _new_item;
        _friendMap.friendList[_index] = _new_item;
        _friendMap.friendList[_index].index = _index
    end
    -- //设置当前好友页面为第一页
    --        local        _nowPage=0;
    --         if(_friendMap.count>0)then
    ----                   _nowPage=1;
    --                   for  _index=1,#_friendMap.friendList do--//加上私有的数据
    --                             _friendMap.friendList[_index].index=_index;
    --                   end
    --         end
    --         self.nowFriendPage=_nowPage;
    FriendModel:setNowFriendPage(self.nowFriendPage);
    if(#_friendMap.friendList>0)then
           self.mc_10:showFrame(1);
    else
           self.mc_10:showFrame(2);
    end
    -- //设置完数据后会调用第一个页面
    self:setFriendList();
end
-- //好友列表中的按钮事件
function FriendMainView:clickButtonFriendList()
    self.panel_yeqian.mc_1:showFrame(2);
    self.nowFriendPage = 1;
    self:freshFriendListUICommon();
end
-- //添加好友
function FriendMainView:clickButtonAddFriend()
    self.panel_yeqian.mc_2:showFrame(2);
    -- //for test,after that,resume
    if (self.selectButton ~= 2) then
        self.panel_yeqian["mc_" .. self.selectButton]:showFrame(1);
    end
    self.selectButton = 2;
    self:freshFriendAddingUICommon();
end
-- //申请好友
function FriendMainView:clickButtonApplyFriend()
    self.panel_yeqian.mc_3:showFrame(2);
    if (self.selectButton ~= 3) then
        self.panel_yeqian["mc_" .. self.selectButton]:showFrame(1);
    end
    -- //好友列表页面是否显示红点
    self.selectButton = 3;
    self.nowFriendApplyPage = 1;
    self.nowFriendApplySelectedIndex=1;
    self:freshFriendApplyCommon();
end
-- //添加好友页面
function FriendMainView:setFriendAddingMap(_addedMap)
    self.friendAddingMap = _addedMap;
    local function table_sort(a,b)
          return a.userExt.loginTime>b.userExt.loginTime
    end
    table.sort(_addedMap,table_sort);
    for _index = 1, #_addedMap do
        _addedMap[_index].index = _index;
    end
    -- //如果没有一个推荐好友
    if (#_addedMap <= 0) then
           self.mc_10:showFrame(3);
           self.panel_3.btn_1:setVisible(false);
           self.panel_3.btn_2:setVisible(false);
           if(self.researchFriendFlag)then
                  WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_research_1041"));
            else
                 WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_recommend_1039"));
            end
    else
           self.mc_10:showFrame(1);
           self.panel_3.btn_1:setVisible(true);
           self.panel_3.btn_2:setVisible(true);
    end
    self.researchFriendFlag=nil;
    self:setFriendAddingList();
end
function FriendMainView:setFriendAddingList()
    -- //恢复以前的页签高亮度显示
    if (self.selectButton ~= 2) then
        self.panel_yeqian["mc_" .. self.selectButton]:showFrame(1);
    end
    self.firstEntry[2]=self.firstEntry[2]+1;
    self.selectButton = 2;
    self.panel_yeqian.mc_2:showFrame(2);
    self.panel_1:setVisible(false);
    self.panel_2:setVisible(false);
    self.panel_3:setVisible(true);
    self.scroll_list:setVisible(false);
    self.scroll_list2:setVisible(true);
    self.scroll_list3:setVisible(false);
--//恢复红点,如果条件满足
    self.panel_yeqian.mc_3.currentView.panel_hongdian:setVisible(FriendModel:isFriendApply());
    self.panel_yeqian.mc_1.currentView.panel_hongdian:setVisible(FriendModel:isFriendSendSp());
    -- //目标面板
    local panel = self.panel_3;
    -- //无用的组件都隐藏
    panel.panel_2:setVisible(false);
    -- //好友数目
    panel.txt_2:setString(FriendModel:getFriendCount().."/"..FuncDataSetting.getDataByConstantName("FriendLimit"));
    panel.btn_3:setTap(c_func(self.clickButtonResearchFriend, self));    -- //搜索好友按钮
    panel.panel_1.input_1:setAlignment("center", "center")
    if (#self.friendAddingMap <= 0) then
        FilterTools.setGrayFilter(panel.btn_2);
    else
        FilterTools.clearFilter(panel.btn_2);
    end
    panel.btn_1:setTap(c_func(self.clickButtonChangeOtherFriend, self));
    -- //换一批推荐好友
    panel.btn_2:setTap(c_func(self.clickButtonApplyAllFriend, self));
    if(#self.friendAddingMap>0)then
         panel.btn_2:enabled(true);
         FilterTools.clearFilter(panel.btn_2);
    else
         panel.btn_2:enabled(false);
         FilterTools.setGrayFilter(panel.btn_2);
    end
    -- //全部申请
    -- //单元格数据  
      local _cells={};
    local function genCellItem(_item)
        local _cell = UIBaseDef:cloneOneView(panel.panel_2);
        self:setFriendAddingCellItem(_cell, _item);
--        if(self.firstEntry[2]<=1)then
--             table.insert(_cells,_cell);
--             _cell:setVisible(false);
--             _cell:runAction(act.moveby(0, 0, -ITEM_MOVE_DISTANCE*#_cells));
--             if(#_cells>=#self.friendAddingMap)then
--                   self:doActionForItem(_cells);
--             end
--        end
        return _cell;
    end

    local _scrollParam = {
        data = self.friendAddingMap,
        createFunc = genCellItem,
        perNums = 1,
        offsetX = 4,
        offsetY = 3,
        widthGap = 0,
        heightGap=2,
        itemRect = { x = 0, y = - 133, width = 758, height = 133 },
        perFrame = 1,
    };
    self.scroll_list2:cancleCacheView();
--//添加事件
    self.scroll_list2:setFillEaseTime(0.3);
    self.scroll_list2:setItemAppearType(1, true);
    self.scroll_list2:styleFill( { _scrollParam });
 --   self.scroll_list2:gotoTargetPos(1, 1);
    self.panel_fanye:setVisible(false);
    -- //玩家自己的uidMark
    panel.txt_4:setString(UserModel:uidMark());
end
--//检查是否包含特殊字符
local function CheckContainSpecialChar(_tex)
    local _special="`~!@#$%^&*().   ,./'\"\\|{}[]-_+="
    local _size=string.len(_tex)
    for _index=1,_size do
           local _char=string.sub(_tex,_index,_index)
           local _start=string.find(_special,_char)
           if(_start~=nil)then
                return true;
           end
    end
    return false
end
-- //搜索好友
function FriendMainView:clickButtonResearchFriend()
    --      self.panel_3.panel_1.panel_1.txt_1:setString("----pppp-----");
    local _txt = self.panel_3.panel_1.input_1:getText();
    if(CheckContainSpecialChar(_txt))then
         WindowControler:showTips(GameConfig.getLanguage("friend_extra_can_not_blank"))
         return ;
    end
    if (string.len(_txt) <= 0) then
        -- //搜索内容不能为空
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_research_can_not_empty_1028"));
        return;
    end
    local _userName = UserModel:name();
    local _uidMask=tostring(UserModel:uidMark())
    if (_txt == _userName or _txt==_uidMask) then
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_can_not_research_self_1035"));
        return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
            self.researchFriendFlag=true;
            self:setFriendAddingMap(_param.result.data.searchList);
        elseif(_param.error.message=="string_length_limit")then
           WindowControler:showTips(GameConfig.getLanguage("tid_login_1017"));
        else
            echo("-----FriendMainView:clickButtonResearchFriend-----", _param.error.code, _param.error.message);
            WindowControler:showTips(GameConfig.getLanguage("friend_extra_can_not_blank"));
            -- //实际上是不会产生错误的,这里只是为了测试,但是还是产生了
        end
    end
    local param = { };
--//如果是纯数字
--    local   _number=tonumber(_txt);
--    if(_number~=nil and tostring(_number)==_txt)then
--            _txt=ServiceData.Sec.."_".._txt;
--    end
    param.name = _txt;
    FriendServer:getFriendSearchList(param, _callback);
end
-- //换一批好友推荐
function FriendMainView:clickButtonChangeOtherFriend()
    --     if(#self.friendAddingMap<=0)then
    --           WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_friend_recommend_1038"));
    --           return;
    --     end
--//检测是否处于冷却中
    if(self.coldChangeOther)then
          WindowControler:showTips(GameConfig.getLanguage("friend_extra_fresh_cold_down"));
          return;
    end
    local     function    _delayAfterColdDown()
          FilterTools.clearFilter(self.panel_3.btn_1);
          self.coldChangeOther=nil;
    end
--//冷却
    self.coldChangeOther=true;
    FilterTools.setGrayFilter(self.panel_3.btn_1);
    self.panel_3.btn_1:runAction( cc.Sequence:create(cc.DelayTime:create(3.0),cc.CallFunc:create(_delayAfterColdDown)));
    self:freshFriendAddingUICommon();
end
-- //全部申请
function FriendMainView:clickButtonApplyAllFriend()
    -- //如果没有推荐好友
    if (#self.friendAddingMap <= 0) then
        -- //策划说一定会有推荐好友
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_friend_recommend_1038"));
        return;
    end
--//是否好友数目已经满了
    local  _max_friend_count=FuncDataSetting.getDataByConstantName("FriendLimit");
    local  _friend_count=FriendModel:getFriendCount();
    if(_friend_count>=_max_friend_count)then
         WindowControler:showTips(GameConfig.getLanguage("tid_friend_self_friend_count_reach_limit_1046"));
         return;
    end
    local function _callback(_param)
        -- //
        if (_param.result ~= nil) then
            -- //手工刷新所有的好友页面
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_1015"));
            for _index = 1, #self.friendAddingMap do
                -- //将列表中的好友全部置成已经申请状态
                if(not self.friendAddingMap[_index].applyed)then
                    local _cell = self.scroll_list2:getViewByData(self.friendAddingMap[_index]);
                    if(_cell~=nil)then
                            local  sprite=UIBaseDef:cloneOneView(_cell.panel_yishenqing):getChildren()[1];
                            _cell.btn_1:setVisible(false);
                            PlayStampAnimation(self,sprite,_cell.ctn_donghua1,_cell.ctn_donghua1,_cell.panel_yishenqing);
                     end
                end
            end
--//相关按钮灰化
--            self.panel_3.btn_2:enabled(false);
            FilterTools.setGrayFilter(self.panel_3.btn_2);
            self.panel_3.btn_2:setTap(c_func(self.clickButtonAlreadyApplyAll,self))
        else
            echo("---FriendMainView:clickButtonApplyAllFriend---", _param.error.code, _param.error.message);
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_failed_1016"));
            -- //实际不会发生,for test
        end
    end
    local param = { };
    param.rids = { };
    for _index = 1, #self.friendAddingMap do
        param.rids[_index] = self.friendAddingMap[_index]._id;
    end
    FriendServer:applyFriend(param, _callback);
end
-- //设置添加好友的单元格的内容
function FriendMainView:setFriendAddingCellItem(_cell, _item)
    -- //英雄图标
    local _icon = FuncChar.icon(tostring(_item.avatar));
    local _node = _cell.panel_1.ctn_1;
    local _sprite = display.newSprite(_icon);
	local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", _node, false, GameVars.emptyFunc)
	iconAnim:setScale(1.3)
   -- _sprite:size(72,72)
	FuncArmature.changeBoneDisplay(iconAnim, "node", _sprite)

    local _name=_item.name-- //玩家名字
    if(_item.name==nil or _item.name=="")then
        _name=GameConfig.getLanguage("tid_common_2006");
    end 
    _cell.txt_1:setString(_name);
    SetVIPPosition(_cell.txt_1,_cell.mc_1,_name);
    _cell.txt_3:setString("" .. _item.level);
    -- //等级
    _cell.txt_5:setString("" .. _item.ability.total);
    -- //战力
    -- //VIP
    if (_item.vip > 0) then
        _cell.mc_1:showFrame(_item.vip>15 and 15 or _item.vip);
    else
        _cell.mc_1:setVisible(false);
    end
    -- //登录情况
    _cell.txt_6:setString(formatLoginInfo(_item.userExt.loginTime));
    -- //申请按钮
    _cell.btn_1:setTap(c_func(self.clickCellButtonApplyFriend, self, _item));
--//查看玩家信息
    _cell.panel_1:setTouchedFunc(c_func(self.clickCellButtonQueryPlayer,self,_item),nil,true,c_func(self.onCellBeganEvent,self,_item),c_func(self.onCellMovedEvent,self,_item));
    _cell.panel_yishenqing:setVisible(false);
end
function   FriendMainView:onCellBeganEvent(_item,_event)
      echo("-----------maomao---------------");
      local    _other_item=_item;
      local    _other_point=self:convertToNodeSpace(cc.p(_event.x,_event.y))
      _other_item.offsetX=_other_point.x;
      _other_item.offsetY=_other_point.y;
      _other_item.ignore_event=false;
end

function  FriendMainView:onCellMovedEvent(_item,_event)
   
     local    _other_point=self:convertToNodeSpace(cc.p(_event.x,_event.y))
     local    _deltax = _other_point.x - (_item.offsetX or _other_point.x);
     local    _deltay = _other_point.y - (_item.offsetY or _other_point.y);

     local    _other_item = _item;
     _other_item.ignore_event = _other_item.ignore_event or _deltax * _deltax + _deltay * _deltay >25 ;
end
--//检查是否应该灰化掉一键申请按钮
function FriendMainView:checkGrayOneKeyApply()
    local count=0;
    for _index=1,#self.friendAddingMap do
          if(self.friendAddingMap[_index].applyed)then
                  count=count+1;
          end
    end
    if(count>0 and count==#self.friendAddingMap)then
  --        self.panel_3.btn_2:enabled(false);
          FilterTools.setGrayFilter(self.panel_3.btn_2);
          self.panel_3.btn_2:setTap(c_func(self.clickButtonAlreadyApplyAll,self))
    end
end
-- //申请加好友,单元格中的事件
function FriendMainView:clickCellButtonApplyFriend(_item)
--//是否好友数目已经满了
    local  _max_friend_count=FuncDataSetting.getDataByConstantName("FriendLimit");
    local  _friend_count=FriendModel:getFriendCount();
    if(_friend_count>=_max_friend_count)then
         WindowControler:showTips(GameConfig.getLanguage("tid_friend_self_friend_count_reach_limit_1046"));
         return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
          local  _otherItem=_item;
           _otherItem.applyed=true;
            local _cell = self.scroll_list2:getViewByData(self.friendAddingMap[_item.index]);
            local  sprite=UIBaseDef:cloneOneView(_cell.panel_yishenqing):getChildren()[1];
            _cell.btn_1:setVisible(false);
            PlayStampAnimation(self,sprite,_cell.ctn_donghua1,_cell.ctn_donghua1,_cell.panel_yishenqing);
            self:checkGrayOneKeyApply();
--//刷新按钮
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_1015"));
        else
            if (_param.error.message == "friend_can_not_be_myself") then
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_can_not_add_self_1034"));
            elseif (_param.error.message == "friend_exists" or _param.error.message=="friend_apply_not_exists") then
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_already_exist_1036"));
            elseif(_param.error.message=="friend_count_limit")then--//对方好友已满
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_friend_count_limit_1030"));
            else
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_failed_1016"));
            end
        end
    end
    local param = { };
    param.rids = { };
    param.rids[1] = self.friendAddingMap[_item.index]._id
    FriendServer:applyFriend(param, _callback);
end

function  GenAction(count)
	local frameTime = 1.0/GAMEFRAMERATE

	local offset = count-1
	local _act = act.sequence(
		act.delaytime((count-1)*2*frameTime),
		act.easebackout(act.moveby(frameTime*6, 0, ITEM_MOVE_DISTANCE*count-5-offset)),
		act.moveby(frameTime*3, 0, 10+offset*2),
		act.moveby(frameTime*2, 0, -5-offset)
	)
    return _act;
end
--//为所有的单元格执行动作
function FriendMainView:doActionForItem(_cells)
   for _index=1,#_cells do
        local cell=_cells[_index];
--        cell:runAction(act.moveby(0, 0, -ITEM_MOVE_DISTANCE*_index));
         cell:setVisible(true);
         cell:runAction(GenAction(_index));
   end
end
-- //显示好友列表页面
function FriendMainView:setFriendList()
    self.panel_1:setVisible(true);
    self.panel_2:setVisible(false);
    self.panel_3:setVisible(false);
    self.scroll_list:setVisible(true);
    self.scroll_list2:setVisible(false);
    self.scroll_list3:setVisible(false);
--//是否已经进入了这个函数
   self.firstEntry[1]=self.firstEntry[1]+1;
    local   panel=self.panel_1;
    -- //恢复以前的设置
    if (self.selectButton ~= 1) then
        self.panel_yeqian["mc_" .. self.selectButton]:showFrame(1);
    end
    self.panel_yeqian.mc_3.currentView.panel_hongdian:setVisible(FriendModel:isFriendApply());
    if(self.panel_yeqian.mc_1.currentView.panel_hongdian~=nil)then
             self.panel_yeqian.mc_1.currentView.panel_hongdian:setVisible(false);
    end
    -- //好友申请页签是否应该显示红点
    self.selectButton = 1;
    self.panel_yeqian.mc_1:showFrame(2);
    --         local      _map=self.friendMap;
    -- //边缘组件的设置
    panel.txt_2:setString(self.friendMap.count.."/"..FuncDataSetting.getDataByConstantName("FriendLimit"));
    -- //好友数目
    local title = FriendModel:getUserMotto();
    panel.panel_1.txt_1:setString(FriendModel:getUserMotto());
    -- //设置签名--//策划没有将组件设置好
    panel.btn_1:setTap(c_func(self.clickButtonModifyMotto, self));
    -- //刷新按钮隐藏
    panel.btn_4:setVisible(false);
    -- //如果没有好友,一键领取和一键赠送体力 按钮灰化掉
    if (self.friendMap.count <= 0) then
--        FilterTools.setGrayFilter(self.panel_1.btn_2);
--        FilterTools.setGrayFilter(self.panel_1.btn_3);
           self.panel_1.btn_2:setVisible(false)
           self.panel_1.btn_3:setVisible(false)
    else
--        FilterTools.clearFilter(self.panel_1.btn_2);
--        FilterTools.clearFilter(self.panel_1.btn_3);
        self.panel_1.btn_2:setVisible(true)
        self.panel_1.btn_3:setVisible(true)
    end
--//判断当前 一键获取,一键赠送按钮是否可用
  local sendSpTimes=0;
  local needCount=0;
   for _index=1,#self.friendMap.friendList do
           local  item=self.friendMap.friendList[_index];
           if(item.hasSend)then
                 sendSpTimes=sendSpTimes+1;
           end
           if(item.hasSp)then
                 needCount=needCount+1;
           end
           local   _other_item=item;
           _other_item.vSendSp=item.hasSend
           _other_item.vAchieveSp=item.hasGetSp
   end
   if(sendSpTimes>=#self.friendMap.friendList)then
 --         self.panel_1.btn_3:enabled(false);
          FilterTools.setGrayFilter(self.panel_1.btn_3);
          self.panel_1.btn_3:setTap(c_func(self.clickButtonAlreadySendAll))
   else
--          self.panel_1.btn_3:enabled(true);
          FilterTools.clearFilter(self.panel_1.btn_3);
          self.panel_1.btn_3:setTap(c_func(self.clickButtonOneKeySendSp, self));    -- //一键赠送
   end
   if(needCount<=0)then
--         self.panel_1.btn_2:enabled(false);
         FilterTools.setGrayFilter(self.panel_1.btn_2);
--         self.panel_1.btn_2:setTap(c_func(self.clickButtonAlreadyAchieveAll))
   else
--         self.panel_1.btn_2:enabled(true);
         FilterTools.clearFilter(self.panel_1.btn_2);
 --        self.panel_1.btn_2:setTap(c_func(self.clickButtonOneKeyAchieveSp, self));    -- //一键领取
   end
   self.panel_1.btn_2:setTap(c_func(self.clickButtonOneKeyAchieveSp, self));    -- //一键领取
    -- //翻页选项,并且判断当前是否应该禁止 分页按钮的功能
    local _pagePerCount = FriendModel:getCountPerPage();
    -- //获取每一页显示多少
    local _totalPages = math.floor(self.friendMap.count / _pagePerCount);
    if (self.friendMap.count % _pagePerCount > 0) then
        _totalPages = _totalPages + 1;
    end
    -- //修正当前页数,防止好友的数目动态变化引起的BUG
    if (self.nowFriendPage > _totalPages) then
        self.nowFriendPage = _totalPages;
    elseif (self.nowFriendPage < 0) then
        self.nowFriendPage = 0;
    end
    self.totalFriendPages = _totalPages;
    self.panel_fanye:setVisible(_totalPages>1);
    self.panel_fanye.panel_3.txt_1:setString("" .. self.nowFriendPage .. "/" .. _totalPages);
 --   self.panel_fanye.btn_3:enabled(self.nowFriendPage > 1);
    -- //向前翻页
--    self.panel_fanye.btn_4:enabled(self.nowFriendPage < _totalPages);
    self.panel_fanye.btn_3:setTap(c_func(self.clickButtonPrevPage, self));
    -- //向左翻页
    self.panel_fanye.btn_4:setTap(c_func(self.clickButtonNextPage, self));
    -- //目标样板隐藏
    self.panel_1.panel_2:setVisible(false);
    -- //容器,装载所有的组件单元
    local _cells={};
    local function genFriendItem(_item)
        local _cell = UIBaseDef:cloneOneView(self.panel_1.panel_2);
        self:setFriendListCell(_cell, _item);
--        if(self.firstEntry[1]<=1)then
--            table.insert(_cells,_cell);
--            _cell:setVisible(false);
--            _cell:runAction(act.moveby(0, 0, -ITEM_MOVE_DISTANCE*#_cells));
--            if(#_cells>=#self.friendMap.friendList)then
--                   self:doActionForItem(_cells);
--            end
--        end
        return _cell;
    end 
    local _scrollParam = {
        data = self.friendMap.friendList,
        createFunc = genFriendItem,
        perNums = 1,
        offsetX = 4, 
        offsetY = 3,
        widthGap = 0,
        heightGap=2,
        itemRect = { x = 0, y = - 133, width = 758, height = 133 },
        perFrame = 1,
    };
    self.scroll_list:setFillEaseTime(0.3);
    self.scroll_list:setItemAppearType(1, true);
    self.scroll_list:styleFill( { _scrollParam });
    if(self.lastFriendListPage ~= self.nowFriendPage)then
           self.scroll_list:gotoTargetPos(1, 1);
           self.lastFriendListPage=self.nowFriendPage;
    end
end
--//设置VIP组件的位置
function SetVIPPosition(_label,_vip,_text)
--//字符串的长度
   local  _width=FuncCommUI.getStringWidth(_text,26,"systemFont");
   local  x,y=_label:getPosition();
   local  otherx,othery=_vip:getPosition();
   _vip:setPosition(cc.p(x+_width+20,othery));
end
-- //设置好友列表信息
function FriendMainView:setFriendListCell(_cell, _item)
    -- //好友头像
    local _icon = FuncChar.icon(tostring(_item.avatar));
    local _node = _cell.panel_1.ctn_1;
    _node:removeAllChildren();
    local _sprite = display.newSprite(_icon);
	local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", _node, false, GameVars.emptyFunc)
	iconAnim:setScale(1.3)
	FuncArmature.changeBoneDisplay(iconAnim, "node", _sprite)

    local  _name=_item.name-- //玩家名字
    if(_name==nil or _name=="")then
        _name=GameConfig.getLanguage("tid_common_2006");
    end
    _cell.txt_1:setString(_name);
    SetVIPPosition(_cell.txt_1,_cell.mc_1,_name);
    _cell.txt_3:setString("" .. _item.level);    -- //玩家等级
    _cell.txt_5:setString("" .. _item.ability.total);    -- //战斗力
    if (_item.vip > 0) then    -- //VIP等级
        _cell.mc_1:showFrame(_item.vip);
    else
        _cell.mc_1:setVisible(false);
    end
    -- //登录情况
    _cell.txt_6:setString(formatLoginInfo(_item.userExt.loginTime));
    -- //是否已经领取体力,是否已经赠送立体--//设置领取体力,赠送体力按钮回调
    if (_item.hasSend) then
        -- //如果已经赠送
        _cell.panel_yizengsong:setVisible(true);
        _cell.btn_1:setVisible(false);
    else
       _cell.panel_yizengsong:setVisible(false);
       _cell.btn_1:setVisible(true);
        _cell.btn_1:setTap(c_func(self.clickCellButtonSendSp, self, _item));
    end
    if (_item.hasGetSp) then
        -- //如果已经领取体力
        _cell.panel_yilingqu:setVisible(true);
        _cell.btn_2:setVisible(false);
    elseif (_item.noSp) then
        -- //没有体力
        _cell.panel_yilingqu:setVisible(false);
 --       _cell.btn_2:enabled(false);
        FilterTools.setGrayFilter(_cell.btn_2);
        _cell.btn_2:setVisible(true);
        _cell.btn_2:setTap(c_func(self.clickCellButtonAchieveFail,self,_item))
    else
       _cell.panel_yilingqu:setVisible(false)
       _cell.btn_2:enabled(true);
       _cell.btn_2:setVisible(true);
       FilterTools.clearFilter(_cell.btn_2)
        _cell.btn_2:setTap(c_func(self.clickCellButtonAchieveSp, self, _item));
    end
--//为好友的管理注册事件监听
    _cell.panel_1:setTouchedFunc(c_func(self.clickCellButtonQueryPlayer,self,_item),nil,true,c_func(self.onCellBeganEvent,self,_item),c_func(self.onCellMovedEvent,self,_item));
end
--//体力赠送
function  FriendMainView:clickCellButtonAchieveFail(_item)
    WindowControler:showTips(GameConfig.getLanguage("friend_extra_no_sp_achieve"))
end
--//已经赠送了所有的
function  FriendMainView:clickButtonAlreadySendAll()
    WindowControler:showTips(GameConfig.getLanguage("friend_extra_one_key_send_fail"))
end
--//已经领取了所有的人的
function FriendMainView:clickButtonAlreadyAchieveAll()
    WindowControler:showTips(GameConfig.getLanguage("friend_extra_one_key_achieve_fail"))
end
--//已经申请了所有的
function FriendMainView:clickButtonAlreadyApplyAll()
    WindowControler:showTips(GameConfig.getLanguage("friend_extra_one_key_apply"));
end
--//拒绝了所有的
function FriendMainView:clickButtonAlreadyRejectAll()
     WindowControler:showTips(GameConfig.getLanguage("friend_extra_one_key_reject"))
end
--//发送好友详情查询
function FriendMainView:clickCellButtonQueryPlayer(_item)
--   local  _a=self.scroll_list:isMoving()
--   local   _b=self.scroll_list2:isMoving()
--   local   _c=self.scroll_list3:isMoving()
--   if(_a or _b or _c)then
--          return;
--   end
    if(_item.ignore_event) then
           return;
    end
    local    function    _afterApplyCall()
          local  _view=self.scroll_list2:getViewByData(_item);--//好友添加
          if(_view ~=nil )then
          local    _other_item=_item
               _other_item.applyed=true;
               local _cell = self.scroll_list2:getViewByData(self.friendAddingMap[_item.index]);
               local  sprite=UIBaseDef:cloneOneView(_cell.panel_yishenqing):getChildren()[1];
               _cell.btn_1:setVisible(false);
               PlayStampAnimation(self,sprite,_cell.ctn_donghua1,_cell.ctn_donghua1,_cell.panel_yishenqing);
               self:checkGrayOneKeyApply();
          end
    end
    local     function   callback(param)
              if(param.result~=nil)then
                   local   _player_ui=WindowControler:showTopWindow("CompPlayerDetailView",param.result.data.data[1],self,2);--//从好友系统中进入
                   _player_ui:setAfterApplyCallback(_afterApplyCall,self);
              end
    end
    local   param={};
    param.rids={};
    param.rids[1]=_item._id;
    ChatServer:queryPlayerInfo(param,callback);
end
-- //设置玩家的签名(其他页面调用)
function FriendMainView:setUserMotto()
    local _motto = FriendModel:getUserMotto();
    self.panel_1.panel_1.txt_1:setString(_motto);
    -- //设置签名--//策划没有将组件设置好
end
-- //重新获取好友列表页面
function FriendMainView:freshFriendListUICommon()
    local function _callback(_param)
        if (_param.result ~= nil) then
            FriendModel:setFriendList(_param.result.data.friendList);
            FriendModel:setFriendCount(_param.result.data.count);
            self:setFriendMap(_param.result.data);
            FriendModel:updateFriendSendSp(_param.result.data);
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_enough_friends_1017"));
            echo("-----FriendMainView:clickButtonPrevPage-------", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.page = self.nowFriendPage;
    FriendServer:getFriendListByPage(param, _callback);
end
-- //重新刷新好友申请页面
function FriendMainView:freshFriendAddingUICommon()
    local function _callback(_param)
        if (_param.result ~= nil) then
            local _recommendFriend = _param.result.data.introduceList;
            self:setFriendAddingMap(_recommendFriend);
        else
            echo("----FriendMainView:freshFriendAddingUICommon---", _param.error.code, _param.error.message);
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_friend_failed_1018"));
        end
    end
    local param = { };
    FriendServer:getFriendRecommendList(param, _callback);
end
--//panel,将要替换的成组件
--//ctn动画被添加到的组件
--//oneView动画播放完毕之后,将要被隐藏的组件
--//otherView动画播放完毕之后将要被现实的组件
--//此函数不是通用的
function    PlayStampAnimation(_self,sprite,ctn,oneView,otherView)
  local function   afterStampPlay()
       oneView:setVisible(false);
--       oneView:removeChildByTag(0x80);
       otherView:setVisible(true);
  end
  sprite:retain();
  sprite:removeFromParent(true);
  sprite:setPosition(cc.p(0,0));
  sprite:setAnchorPoint(cc.p(0.5,0.5));
   local anim = _self:createUIArmature("UI_common","UI_common_shouqing", nil, false, afterStampPlay);
   FuncArmature.changeBoneDisplay(anim, "layer1", sprite)
   anim:pos(0,0);
   ctn:addChild(anim,1,0x80);
   sprite:release();
end
function FriendMainView:clickCellButtonSendSp(_item)
    -- //如果赠送成功了,需要刷新相关的组件
    local function _callback(_param)
        if (_param.result ~= nil) then

            local _cell = self.scroll_list:getViewByData(_item)
            local sprite=UIBaseDef:cloneOneView(_cell.panel_yizengsong):getChildren()[1];
            _cell.btn_1:setVisible(false);
            PlayStampAnimation(self,sprite,_cell.ctn_donghua1,_cell.ctn_donghua1,_cell.panel_yizengsong);
            local  _other_item=_item
            _other_item.vSendSp=true;
            self:checkGrayOneKeySend();
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_sp_success_1020"));
        else
            echo("-----FriendMainView:clickButtonSendSp-------", _param.error.code, _param.error.message);
            local _tipMessage = GameConfig.getLanguage("tid_friend_send_sp_failed_1019");
            -- 赠送体力失败
            if (_param.error.message == "friend_not_exists") then
                _tipMessage = GameConfig.getLanguage("tid_friend_not_exist_1021");
                -- //好友不存在
            elseif (_param.error.message == "friend_sp_times_max") then
                -- //对方体力已经达到上限
                _tipMessage = GameConfig.getLanguage("tid_friend_sp_reach_limit_1022");
            end
            WindowControler:showTips(_tipMessage);
        end
    end
    local param = { };
    param.frid = _item._id;
    param.isAll = 0;
    -- //非一键赠送
    FriendServer:sendFriendSp(param, _callback);
end
--//检查是否要灰化掉一件赠送,一键获取体力按钮
function FriendMainView:checkGrayOneKeySend()
     local  count=0;
     for _index=1,#self.friendMap.friendList do
             local item=self.friendMap.friendList[_index];
             if(item.vSendSp)then
                    count=count+1;
             end
    end        
    if(count>=#self.friendMap.friendList)then
 --     self.panel_1.btn_3:enabled(false);
     FilterTools.setGrayFilter(self.panel_1.btn_3);
     self.panel_1.btn_3:setTap(c_func(self.clickButtonAlreadySendAll,self))
     end
end
function FriendMainView:checkGrayOnKeyAchieve()
     local  count=0;
     local  needCount=0;
     for _index=1,#self.friendMap.friendList do
             local item=self.friendMap.friendList[_index];
             if(not item.vAchieveSp and item.hasSp)then
                    count=count+1;
             end
    end     
    if(count<=0)then
--         self.panel_1.btn_2:enabled(false);
         FilterTools.setGrayFilter(self.panel_1.btn_2);
         self.panel_1.btn_2:setTap(c_func(self.clickButtonAlreadyAchieveAll,self))
    end
end
-- //获取好友赠送的体力
function FriendMainView:clickCellButtonAchieveSp(_item)
    -- //如果获取失败
    local function _callback(_param)
        if (_param.result ~= nil) then
           if(_param.result.data.sp>0)then

                local _cell = self.scroll_list:getViewByData(_item);
                local sprite=UIBaseDef:cloneOneView(_cell.panel_yilingqu):getChildren()[1];
                _cell.btn_2:setVisible(false);
                PlayStampAnimation(self,sprite,_cell.ctn_donghua2,_cell.ctn_donghua2,_cell.panel_yilingqu);
                local   _other_item=_item;
                _other_item.vAchieveSp=true;
                self:checkGrayOnKeyAchieve();
                local _achieveInfo = GameConfig.getLanguage("tid_friend_sp_detail_1023");
            -- //获取了多少体力,还剩余多少体力
                local  _oneSp=FuncDataSetting.getDataByConstantName("FriendGift");
                local _maxSpNum = FuncDataSetting.getDataByConstantName("ReceiveTimes")*_oneSp;
            -- //体力上限
                self.friendMap.spCount = self.friendMap.spCount - 1;
                FriendModel:updateFriendSendSp(self.friendMap);
                local   _achieveCount=CountModel:getCountByType(FuncCount.COUNT_TYPE.COUNT_TYPE_ACHIEVE_SP_COUNT)*_oneSp;
                WindowControler:showTips(_achieveInfo:format(_param.result.data.sp, _maxSpNum - _achieveCount));
           else--//分情况
                local _maxSpNum = FuncDataSetting.getDataByConstantName("HomeCharBuySPMax");
                local  _oneSp=FuncDataSetting.getDataByConstantName("FriendGift");
                if(UserExtModel:sp()+_oneSp>_maxSpNum)then--//体力超上限
                    WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_sp_reach_limit_1044"):format(_maxSpNum));
                else
                    WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_sp_to_limit_1047"));
                end
           end
        else
            echo("-----FriendMainView:clickButtonSendSp-------", _param.error.code, _param.error.message);
            local _tipMessage = GameConfig.getLanguage("tid_friend_achieve_sp_failed_1024");
            -- //领取体力失败
            if (_param.error.message == "friend_sp_times_max") then
                _tipMessage = GameConfig.getLanguage("tid_friend_self_sp_reach_limit_1025");
                -- //自己已经达到体力上限
            elseif (_param.error.message == "friend_sp_not_exists") then--//好友已经被删除了
                -- //无法领取体力
                _tipMessage = GameConfig.getLanguage("tid_friend_need_add_friend_first_1045");--GameConfig.getLanguage("tid_friend_can_not_achieve_sp_1026");
                self:freshFriendListUICommon();--//刷新页面
            elseif(_param.error.message=="friend_not_exists")then--//如果不是好友
                _tipMessage=GameConfig.getLanguage("tid_friend_need_add_friend_first_1045");
                self:freshFriendListUICommon();--//刷新页面
            end
            WindowControler:showTips(_tipMessage);
        end
    end
    local param = { };
    param.frid = _item._id;
    param.isAll = 0;
    -- //非一键领取体力
    FriendServer:achieveFriendSp(param, _callback);
end
-- //修改签名
function FriendMainView:clickButtonModifyMotto()
    echo("-------FriendMainView:clickButtonModifyMotto------");
    local _mottoUI = WindowControler:showWindow("FriendModifyNameView",self);
end
-- //一键领取体力,与上面的领取单个体力不同,一键之后还需要刷新页面
function FriendMainView:clickButtonOneKeyAchieveSp()
    if (self.friendMap.count <= 0) then
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_friend_1027"));
        -- //列表中没有好友，快去添加好友吧
        return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
            if (_param.result.data.sp > 0) then
                 for _index = 1, #self.friendMap.friendList do
                     local   item=self.friendMap.friendList[_index];
                     if(not item.vAchieveSp and item.hasSp)then
                           local _cell = self.scroll_list:getViewByData(self.friendMap.friendList[_index]);
                            local sprite=UIBaseDef:cloneOneView(_cell.panel_yilingqu):getChildren()[1];
                            _cell.btn_2:setVisible(false);
                            PlayStampAnimation(self,sprite,_cell.ctn_donghua2,_cell.ctn_donghua2,_cell.panel_yilingqu);
                            local  _other_item=item
                            _other_item.vAchieveSp=true;
                      end
                end
                self:checkGrayOnKeyAchieve();
                local _achieveInfo = GameConfig.getLanguage("tid_friend_sp_detail_1023");
                -- //获取了多少体力,还剩余多少体力
            -- //获取了多少体力,还剩余多少体力
               local  _oneSp=FuncDataSetting.getDataByConstantName("FriendGift");
               local _maxSpNum = FuncDataSetting.getDataByConstantName("ReceiveTimes")*_oneSp;
            -- //体力上限
               FriendModel:updateFriendSendSp(self.friendMap);
               local   _achieveCount=CountModel:getCountByType(FuncCount.COUNT_TYPE.COUNT_TYPE_ACHIEVE_SP_COUNT)*_oneSp;
               WindowControler:showTips(_achieveInfo:format(_param.result.data.sp, _maxSpNum - _achieveCount));
               self.friendMap.spCount = self.friendMap.spCount - _param.result.data.sp /_oneSp;
                FriendModel:updateFriendSendSp(self.friendMap);

            else
--                WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_sp_achieve_1040"));
                  local needCount=0;
                  for _index=1,#self.friendMap.friendList do
                          local  item=self.friendMap.friendList[_index];
                          if(item.hasSp)then
                                 needCount=needCount+1;
                          end
                end
                if(needCount<=0)then
                       WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_sp_achieve_1040"));
                       return  ;
                end
                local _maxSpNum = FuncDataSetting.getDataByConstantName("HomeCharBuySPMax");
                local  _oneSp=FuncDataSetting.getDataByConstantName("FriendGift");
                if(UserExtModel:sp()+_oneSp>_maxSpNum)then--//体力超上限
                    WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_sp_reach_limit_1044"):format(_maxSpNum));
                else
                    WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_sp_to_limit_1047"));
                end
            end
        else
            echo("---FriendMainView:clickButtonOneKeyAchieveSp-----", _param.error.code, _param.error.message);
            local _tipMessage = GameConfig.getLanguage("tid_friend_achieve_sp_failed_1024");
            if (_param.error.message == "friend_sp_times_max") then
                -- //已经达到体力上限
                _tipMessage = GameConfig.getLanguage("tid_friend_self_sp_reach_limit_1025");
            elseif (_param.error.message == "friend_sp_not_exists") then
                _tipMessage = GameConfig.getLanguage("tid_friend_can_not_achieve_sp_1026");
            end
            WindowControler:showTips(_tipMessage);
        end
    end
    local param = { };
    --          param.frid="";
    param.isAll = 1;
    FriendServer:achieveFriendSp(param, _callback);
end
-- //一键赠送体力
function FriendMainView:clickButtonOneKeySendSp()
    echo("-------------FriendMainView:clickButtonOneKeySendSp---------------");
    if (self.friendMap.count <= 0) then
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_friend_1027"));
        -- //列表中没有好友，快去添加好友吧
        return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_sp_success_1020"));
            -- //                              self:freshFriendListUICommon();
            for _index = 1, #self.friendMap.friendList do
               local item=self.friendMap.friendList[_index];
               if(not item.vSendSp)then
                    local _cell = self.scroll_list:getViewByData(self.friendMap.friendList[_index]);
                    local sprite=UIBaseDef:cloneOneView(_cell.panel_yizengsong):getChildren()[1];
                    _cell.btn_1:setVisible(false);
                    PlayStampAnimation(self,sprite,_cell.ctn_donghua1,_cell.ctn_donghua1,_cell.panel_yizengsong);
                    local  _other_item=item
                    _other_item.vSendSp=true;
                end
            end
            self:checkGrayOneKeySend();
        else
            echo("-----FriendMainView:clickButtonSendSp-------", _param.error.code, _param.error.message);
            local _tipMessage = GameConfig.getLanguage("tid_friend_send_sp_success_1020");
            -- 赠送体力失败
            if (_param.error.message == "friend_not_exists") then
                _tipMessage = GameConfig.getLanguage("tid_friend_not_exist_1021");
                -- //好友不存在
            elseif (_param.error.message == "friend_sp_times_max") then
                -- //对方体力已经达到上限
                _tipMessage = GameConfig.getLanguage("tid_friend_sp_reach_limit_1022");
            end
            WindowControler:showTips(_tipMessage);
        end
    end
    local param = { };
    --         param.frid="";
    param.isAll = 1;
    FriendServer:sendFriendSp(param, _callback);
end
-- //分页,下一页
function FriendMainView:clickButtonNextPage()
    -- //如果是好友列表页面
    if (self.selectButton == 1) then
        -- //好友列表页面
        local function _callback(_param)
            if (_param.result ~= nil) then
                self.nowFriendPage = self.nowFriendPage + 1;
                FriendModel:setFriendList(_param.result.data.friendList);
                FriendModel:setFriendCount(_param.result.data.count);
                self:setFriendMap(_param.result.data);
            else
                echo("-------FriendMainView:clickButtonNextPage-----", result.error.code, result.error.message);
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_enough_friends_1017"));
            end
        end
        if (self.nowFriendPage < self.totalFriendPages) then
            local param = { page = self.nowFriendPage + 1 };
            FriendServer:getFriendListByPage(param, _callback);
        end
    elseif (self.selectButton == 3) then
        -- //管理好友申请的页面
        local function _callback(_param)
            if (_param.result ~= nil) then
                self.nowFriendApplyPage = self.nowFriendApplyPage + 1;
                self:setFriendApplyMap(_param.result.data);
            else
                echo("---get friend apply list by page error----", _param.error.code, _param.error.message);
            end
        end
        if (self.nowFriendApplyPage < self.totalFriendApplyPage) then
            local param = { };
            param.page = self.nowFriendApplyPage + 1;
            FriendServer:getFriendApplyList(param, _callback);
        end
    end
end
-- //分页,上一页
function FriendMainView:clickButtonPrevPage()
    if (self.selectButton == 1) then
        -- //好友列表
        local function _callback1(_param)
            if (_param.result ~= nil) then
                self.nowFriendPage = self.nowFriendPage - 1;
                FriendModel:setFriendList(_param.result.data.friendList);
                FriendModel:setFriendCount(_param.result.data.count);
                self:setFriendMap(_param.result.data);
            else
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_enough_friends_1017"));
                echo("-----FriendMainView:clickButtonPrevPage-------", _param.error.code, _param.error.message);
            end
        end
        if (self.nowFriendPage > 1) then
            local param1 = { };
            param1.page = self.nowFriendPage - 1;
            FriendServer:getFriendListByPage(param1, _callback1);
        end
    elseif (self.selectButton == 3) then
        local function _callback2(_param)
            if (_param.result ~= nil) then
                self.nowFriendApplyPage = self.nowFriendApplyPage - 1;
                self:setFriendApplyMap(_param.result.data);
            else
                echo("---get friend apply list by page error----", _param.error.code, _param.error.message);
            end
        end
        if (self.nowFriendApplyPage > 1) then
            local param2 = { };
            param2.page = self.nowFriendApplyPage - 1;
            FriendServer:getFriendApplyList(param2, _callback2);
        end
    end
end
return FriendMainView;