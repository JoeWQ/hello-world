-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local ChatMainView = class("ChatMainView", UIBase)
--可以用来扩展表情
local numerToFrameMap = {
    ["@:/101"] = "@101",
    ["@:/102"] = "@101",
    ["@:/103"] = "@101",
    ["@:/104"] = "@101",
    ["@:/105"] = "@101",
    ["@:/106"] = "@101",
    ["@:/107"] = "@101",
    ["@:/108"] = "@101",
    ["@:/109"] = "@101",
    ["@:/110"] = "@101", 
}
local  ChatType={
       ChatType_World=1,
       ChatType_League=2,
       ChatType_Private=3,
};
--//_type,1:世界聊天,2:仙盟聊天,3:私聊
function ChatMainView:ctor(winName, _type)
    ChatMainView.super.ctor(self, winName)
--//当前选中的聊天按钮,默认为世界聊天
    self.chatType=ChatType.ChatType_World;
    self.chatWorldContent=nil;--//世界聊天内容
--//联盟聊天
    self.chatLeagueContent=nil;
    self.currentPrivateSelect=1;--//私聊对象的索引
--//聊天内容
    self.reserveMessage="";
--//聊天对象,在私聊系统中使用,如果不为nil,表明发送聊天时的对象是别人
    self.targetObject=nil;
--//
    self.ui_type=_type;
end
function ChatMainView:openChat()
        self:setVisible(true)
end

function ChatMainView:loadUIComplete()
    FuncCommUI.setViewAlign(self._root,UIAlignTypes.LeftBottom);
    self:registerEvent()

    if(self.ui_type==1)then
           self.delayEntryFirst=true;
           self:setWorldChat();
    elseif(self.ui_type==2)then

    elseif(self.ui_type==3)then
 --//做一些前置工作,防止页面闪烁,但是这些代码不能设置在freshPrivateChat函数中
          self.btn_1:setVisible(false);
          self.panel_2:setVisible(false);
          self.panel_1:setVisible(false);
          self.panel_3:setVisible(false);
          self.panel_4:setVisible(false);
          self:freshPrivateChat();
    end
end

function ChatMainView:showComplete( )
  ChatMainView.super.showComplete(self);
  --//加入弹出动画
    local  _rect=self._root:getContainerBox();
    local  _otherx,_othery=self._root:getPosition();

    self._root:setPosition(cc.p(_otherx - _rect.width,_othery));
--    self:setPosition(cc.p(-_rect.width+_otherx,0));
    local  _mAction=cc.MoveTo:create(0.2,cc.p(_otherx,_othery));
    self._root:runAction(_mAction);
end

function ChatMainView:registerEvent()
      self.mc_1.currentView.btn_1:setTap(c_func(self.clickButtonWorld,self));
      self.mc_2.currentView.btn_1:setTap(c_func(self.clickButtonLeague,self));
      self.mc_3.currentView.btn_1:setTap(c_func(self.clickButtonPrivate,self));
      self.btn_close:setTap(c_func(self.closeChat,self));
 --//加入弹出动画
      local function _closeCallback()
            self:startHide();
      end
      local  function _callback()
           local  _root=self._root;
           local  _rect=_root:getContainerBox();
           local  _mAction=cc.MoveBy:create(0.2,cc.p(-_rect.width,0));
           local  _mSeq=cc.Sequence:create(_mAction,cc.CallFunc:create(_closeCallback));
           _root:runAction(_mSeq);
      end
      self:registClickClose("out",_callback);
--//注册监听事件
      EventControler:addEventListener(ChatEvent.WORLD_CHAT_CONTENT_UPDATE,self.notifyWorldChat,self);
      EventControler:addEventListener(ChatEvent.PRIVATE_CHAT_CONTENT_UPDATE,self.notifyPrivateChat,self);
end 
--//监听事件
function ChatMainView:notifyWorldChat()
         if(self.chatType==ChatType.ChatType_World)then
                  self:setWorldChat();
         else--//否则,产生红点事件
                  
         end
end
function ChatMainView:notifyPrivateChat()
       if(self.chatType==ChatType.ChatType_Private)then
               self:setPrivateChat();
        else--//产生红点事件
               self.mc_3.currentView.panel_red:setVisible(true);
        end
end
--//世界聊天
function ChatMainView:clickButtonWorld()
        self:setWorldChat();
end
--//联盟聊天
function ChatMainView:clickButtonLeague()
     WindowControler:showTips(GameConfig.getLanguage("chat_function_not_open_1015"));
end
--//私聊
function ChatMainView:clickButtonPrivate()
--//设置私聊对象
       ChatModel:setPrivateTargetPlayer(nil);
       self:freshPrivateChat();
end
--//发送聊天信息
function  ChatMainView:clickButtonSendWorldMessage()
--//如果仍处于冷却中
      if(self.flagButtonGray)then
             WindowControler:showTips(GameConfig.getLanguage("chat_cool_down_1007"));
             return;
      end
--//发言次数判断
      local   _ramind_chat_count=ChatModel:getFreeOfChatCount();
      if(_ramind_chat_count<=0)then
             WindowControler:showTips(GameConfig.getLanguage("chat_times_not_engough_1003"));
             return;
      end
      local  bad;
       local       _text=self.mc_4.currentView.input_1:getText();
       bad,_text=Tool:checkIsBadWords(_text);
       self.mc_4.currentView.input_1:setText("");
       local  _size=string.len(_text);
       local  _other_size=string.len4cn2(_text);
 --      local  _other_size=string.len(_other_text);
       if(_other_size<=0)then--//字数过少
                WindowControler:showTips(GameConfig.getLanguage("chat_words_too_little_1002"));
                return;
       end
--//字数过多
      if(_other_size>100)then
               WindowControler:showTips(GameConfig.getLanguage("chat_words_too_long_1003"));
               return;
      end
--//等级限制
      if(ChatModel:getFreeOfChatCount()<=0)then
               WindowControler:showTips(GameConfig.getLanguage("chat_times_not_engough_1003"));
               return;
      end
      self:sendWorldChat(_text);
end
--//填写玩家自己发送的聊天信息
function   PerfectPlayerChatInfo(_content)
      local   item={};
      item.content=_content;
      item.rid=UserModel:rid();
      item.name=UserModel:name();
      item.level=UserModel:level();
      item.vip=UserModel:vip();
      item.avatar=UserModel:avatar();
      item.time=os.date("%X");
      return item;
end
--//发送聊天信息
function  ChatMainView:sendWorldChat(_text)
      local    function  _delayCall()
               FilterTools.clearFilter(self.mc_4.currentView.btn_1);
               self.flagButtonGray=nil;
      end
      local function callback(_param)
               if(_param.result~=nil)then--//发言成功后需要置灰冷却发送信息按钮
                          FilterTools.setGrayFilter(self.mc_4.currentView.btn_1);
                          self.flagButtonGray=true;
                          self:delayCall(_delayCall,3);
               elseif(_param.error.message=="ban_word")then--//敏感词
                       WindowControler:showTips(GameConfig.getLanguage("tid_friend_ban_word_1004"));
               elseif(_param.error.message=="string_illegal")then
                        WindowControler:showTips(GameConfig.getLanguage("chat_illegal_word_1005"));
              elseif(_param.error.message=="chat_times_max")then--//次数上限
                        WindowControler:showTips(GameConfig.getLanguage("chat_times_not_engough_1003"));
              elseif(_param.error.message=="chat_in_cd")then
                        WindowControler:showTips(GameConfig.getLanguage("chat_cool_down_1006"));
             elseif(_param.error.message=="ban_chat")then--//被禁言
                        WindowControler:showTips(GameConfig.getLanguage("chat_extra_forbid_chat_1001"));
              else
                            echo("--ChatMainView:sendWorldChat-",_param.error.message);
               end
      end
      self.lastWorldChatContent=_text;
      local  param={};
      param.content=_text;
      ChatServer:sendWorldMessage(param,callback);
end
--//设置世界聊天界面
function ChatMainView:setWorldChat()
         self.reserveMessage=self.mc_4.currentView.input_1:getText();
--//隐藏不相关的组件
          self.btn_1:setVisible(false);
          self.panel_1:setVisible(false);
          self.panel_2:setVisible(false);
          self.panel_3:setVisible(false);
          self.panel_4:setVisible(false);
--//高亮度显示当前页签
          if(self.chatType~=ChatType.ChatType_World)then
                     self["mc_"..self.chatType]:showFrame(1);
          end
         self.mc_3.currentView.panel_red:setVisible(false);
          self.chatType=ChatType.ChatType_World;
          self.mc_1:showFrame(2);
          self.mc_scroll:showFrame(1);
          local      _scroll_list=self.mc_scroll.currentView.scroll_1;
--//发送聊天内容的组件设置,剩余免费次数
         self.mc_4:showFrame(1);
         if(UserModel:level()<50)then--//如果等级小于50,就会有限制
              self.mc_4:showFrame(1);
              self.mc_4.currentView.txt_1:setVisible(true);
              self.mc_4.currentView.txt_1:setString(GameConfig.getLanguage("chat_world_chat_times_remind_1001"):format(ChatModel:getFreeOfChatCount()));
         else--//否则没有限制
              self.mc_4:showFrame(2);
 --             self.mc_4.currentView.txt_1:setVisible(false);
         end
         self.mc_4.currentView.input_1:setText(self.reserveMessage);
         self.mc_4.currentView.rich_text:setVisible(false);
         self.mc_4.currentView.btn_1:setTap(c_func(self.clickButtonSendWorldMessage,self))
--//获取所有的世界聊天内容,必要时需要删除某些聊天内容
         local     _chatWorldContent=table.copy(ChatModel:getWorldMessage());
         local     _reserve={};--//舍弃掉的数据
         if(self.chatWorldContent~=nil)then
                   for _index=0,#self.chatWorldContent do
                               if(not table.indexof(_chatWorldContent,self.chatWorldContent[_index]))then
                                          _reserve[#_reserve+1]=self.chatWorldContent[_index];
                               end
                   end
         end
         self.chatWorldContent=_chatWorldContent;
         local    function   genWorldChatCell(_item)
                   local  _cell=UIBaseDef:cloneOneView(self.panel_1);
                   self:updateWorldChatCell(_cell,_item);
                   return  _cell;
         end
         local    param={
                   data=self.chatWorldContent,
                   createFunc=genWorldChatCell,
                   perNums=1,
                   offsetX=3.85,
                   offsetY=15,
                   widthGap=0,
                   itemRect={x=3.85,y=-102,width=718,height=102},
                   perFrame=5,
          }
          _scroll_list:styleFill({param});
          _scroll_list:gotoTargetPos(#self.chatWorldContent,1);
--//删除掉缓存里面的cell
        for _index=1,#_reserve do
                   _scroll_list:clearOneView(_reserve[_index]);
        end
end
--//辅助函数,格式化时间
function  FormatChatTime(_time)
       local    _format;
       _format=os.date("%X",_time)--//string.format("%02d:%02d",math.floor(_time/3600),math.floor(_time%3600/60));
       return  _format;
end
--//设置聊天组件的内容,需要对聊天的内容做语法分析
function     FormatRichText(_rich,_content)
       local    _index=1;
       local    _origin=1;
       local    _size=1;
       local   _words={};
       local   _string_length=string.len(_content);
       while( _index~=nil and _origin<=_string_length)do
                _index,_size=string.find(_content,"@:/1[0-9][0-9]",_origin);
                if(_index~=nil )then
                           if(_index~=_origin)then
                                  local  _subString=string.sub(_content,_origin,_index-1);
                                  table.insert(_words,_subString);
                            end
                            local    _subString2=string.sub(_content,_index,_size);
                            table.insert(_words,_subString2);
                            _origin=_size+1;
                else
                            local   _subString3=string.sub(_content,_origin,string.len(_content));
                            table.insert(_words,_subString3);
                end
      end
       _index=1;
       local     _chatContent="";
       while(_index<=#_words)do
                local    _word=_words[_index];
                local    _mapImage=numerToFrameMap[_word];
                if(_mapImage~=nil)then
                         local re9 = _rich:getRichElementImage(8, cc.c3b(255,  0,   0), 255, "icon/bar/bar.png")
                         _rich:pushBackElement(re9);
                         _index=_index+1;
                else
                        _chatContent=_word;
                        _index=_index+1;
                        while(_index<=#_words and numerToFrameMap[_words[_index]]==nil)do
                                 _word=_words[_index];
                                 _chatContent=_chatContent.._word;
                                 _index=_index+1;
                        end
                         local   re8=_rich:getRichElementText(1,cc.c3b(0x85,0x4f,0x21),255,_chatContent,GameVars.systemFontName,20);
                         _rich:pushBackElement(re8);
                end
       end
end
--//更新聊天组件内容
function ChatMainView:updateWorldChatCell(_cell,_item)
--//任务图标
    local _icon = FuncChar.icon(tostring(_item.avatar));
    local      _panel=_cell.btn_1:getUpPanel();
    local _node = _panel.panel_1.ctn_1;
    local _sprite = display.newSprite(_icon):size(_node.ctnWidth, _node.ctnHeight);
    _node:addChild(_sprite);
        _panel.panel_1.txt_1:setString("".._item.level);--人物等级
--//玩家名字
    if(_item.rid==UserModel:rid())then
             _cell.mc_1:showFrame(2);
    end
    if(_item.name==nil or _item.name=="")then
           _item.name=GameConfig.getLanguage("tid_common_2006");
    end
   _cell.mc_1.currentView.txt_1:setString(_item.name);
--//玩家地位,先隐藏掉,并把VIP挪动到mc_2位置上
   _cell.mc_2:setVisible(false);

   local  x,y=_cell.mc_3:getPosition();
   local  namex,namey=_cell.mc_1:getPosition();
--   local  _size=_cell.mc_1.currentView.txt_1:getContentSize();
--   local  _rect=_cell.mc_1.currentView.txt_1:getWidth();
   local   _label=_cell.mc_1.currentView.txt_1;
   local   _width=22*string.len4cn2(_item.name);
   _cell.mc_3:setPosition(cc.p(namex+_width/2+10,y));
--//玩家VIP
    if(_item.vip>0)then
            _cell.mc_3:showFrame(_item.vip+1);
    else
            _cell.mc_3:showFrame(1);
    end
--//时间
    _cell.txt_2:setString(FormatChatTime(_item.time));
--//聊天内容
    _cell.rich_1:initRichText();
    FormatRichText(_cell.rich_1,_item.content);
--//注册监听
    if(_item.rid ~=UserModel:rid())then
            _cell.btn_1:setTap(c_func(self.clickCellButtonQueryPlayerInfo,self,_item));
    else
           _cell.btn_1:setTap(c_func(self.clickCellButtonQuerySelf,self,_item));
    end
end
--//查询自己
function ChatMainView:clickCellButtonQuerySelf(_item)
      WindowControler:showTips(GameConfig.getLanguage("chat_can_not_view_self_1012"));
end
--//查询任意一个角色信息
function ChatMainView:clickCellButtonQueryPlayerInfo(_item)
    local function _callback(param)
            if(param.result~=nil)then
                 local   _playerUI=WindowControler:showTopWindow("CompPlayerDetailView",param.result.data.data[1],self,1);--//从世界聊天进入
            end
    end
    local  _param={};
    _param.rids={};
    _param.rids[1]=_item.rid;
    ChatServer:queryPlayerInfo(_param,_callback);
end
--//分享战斗情况
function ChatMainView:updateBattleInfoCell(_item,_item)

end
function ChatMainView:closeChat()
      ChatModel:clearPrivateQueue();
      local function _closeCallback()
            self:startHide();
      end
      local  _rect=self._root:getContainerBox();
       local  _mAction=cc.MoveBy:create(0.2,cc.p(-_rect.width,0));
       local  _mSeq=cc.Sequence:create(_mAction,cc.CallFunc:create(_closeCallback));
       self._root:runAction(_mSeq);
end 
--//私人聊天
function ChatMainView:setPrivateChat()
--//保留世界聊天的信息
     self.reserveMessage=self.mc_4.currentView.input_1:getText();
--//隐藏不相关的组件
      self.panel_1:setVisible(false);
      self.panel_2:setVisible(false);
      self.panel_3:setVisible(false);
      self.panel_4:setVisible(false);
      self.btn_1:setVisible(false);
      self.mc_4:showFrame(2);
      self.mc_4.currentView.rich_text:setVisible(false);
      self.mc_scroll:showFrame(2);
      self.mc_4.currentView.input_1:setText(self.reserveMessage);

      local    _name_scroll_list=self.mc_scroll.currentView.scroll_1;--//左侧显示玩家的名字
--//显示名字的列表
      local     _privateMessage=ChatModel:getPrivateMessage();
      self.privateMessage=_privateMessage;
--//设置私聊对象,注意使用该对象的时候只能使用他的rid数据,否则可能会出现引用错误
      self.targetPlayer=ChatModel:getPrivateTargetPlayer();
--//生成左侧玩家的名字列表
      local  function genPrivateObject(_item)
              local  _cell=UIBaseDef:cloneOneView(self.panel_3);
              self:updatePrivateObject(_cell,_item);
              return _cell;
      end
      local param={
             data=_privateMessage,
             createFunc=genPrivateObject,
             perNums=1,
             offsetX=-1.5,
             offsetY=0,
             widthGap=0,
             itemRect={x=-1.5,y=-102,width=257.35,height=102},
             perFrame=1,
       };
       _name_scroll_list:styleFill({param});
--//聊天内容选择
     local   _chat_index=1;
     if(self.targetPlayer~=nil)then
             for _index=1,#_privateMessage do
                     if(self.targetPlayer.rid==_privateMessage[_index].rid)then
                               _chat_index=_index;
                               break;
                     end
             end
     end
      if(#_privateMessage>0)then
                     self:setPrivateChatDetail(_privateMessage[_chat_index].chatContent);
      else
                     self:setPrivateChatDetail({});
      end
--//注册事件监听
      self.mc_4.currentView.btn_1:setTap(c_func(self.clickButtonSendPrivateMessage,self));
--//私聊对象高亮度显示
      if(self.targetPlayer~=nil)then
               for  _index=1,#_privateMessage do
                      local   _target=_privateMessage[_index];
                      local   _cell=_name_scroll_list:getViewByData(_target);
                      if(_cell~=nil)then
                                     _cell.scale9_2:setVisible(_target.rid==self.targetPlayer.rid);
                       end
               end
      end
--//通知主页面红点消失
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, {
        redPointType = HomeModel.REDPOINT.LEFTMARGIN.CHAT,
        isShow = false }   );
end
--//发送私人聊天事件
function ChatMainView:clickButtonSendPrivateMessage()
      local    _text=self.mc_4.currentView.input_1:getText();
      local  bad;
      bad,_text=Tool:checkIsBadWords(_text);
      local    _size=string.len(_text);
      self.mc_4.currentView.input_1:setText("");
--//检查是否选中了某一个聊天对象
      if(self.targetPlayer==nil)then
               WindowControler:showTips(GameConfig.getLanguage("chat_need_select_player_1010"));
               return;
      end
--//字数显示
      if(_size<=0)then
                WindowControler:showTips(GameConfig.getLanguage("chat_words_too_little_1002"));
                return;
      end
      if(_size>100)then
                WindowControler:showTips(GameConfig.getLanguage("chat_words_too_long_1003"));
                return;
      end
--      ChatModel:setPrivateTargetPlayer(self.targetPlayer);
--//发送聊天协议
      self:requestPrivateMessage(_text,self.targetPlayer.rid);
end
--//聊天协议
function ChatMainView:requestPrivateMessage(_text,_rid)
      local function callback(param)
             if(param.result~=nil)then--//没有其他操作
             
             elseif(param.error.message=="string_illegal")then
                     WindowControler:showTips(GameConfig.getLanguage("chat_illegal_word_1005"));
            elseif(param.error.message=="ban_word")then--//敏感词
                       WindowControler:showTips(GameConfig.getLanguage("tid_friend_ban_word_1004"));
            elseif(param.error.message=="user_not_online")then--//对象已经离线
                       local     rid=self.targetPlayer.rid;
                       for   _index=1,#self.privateMessage do
                                if(self.privateMessage[_index].rid==rid)then
                                        local    _cell=self.mc_scroll.currentView.scroll_1:getViewByData(self.privateMessage[_index]);
                                        if(_cell~=nil)then
                                                  _cell.mc_2:showFrame(2);
                                        end
                                        break;
                                end
                       end
                       WindowControler:showTips(GameConfig.getLanguage("chat_chat_target_offline_1011"));
           elseif(_param.error.message=="ban_chat")then--//被禁言
                        WindowControler:showTips(GameConfig.getLanguage("chat_extra_forbid_chat_1001"));
            else
                     echo("---ChatMainView:requestPrivateMessage--",param.error.message);
             end
      end
      local  _param={};
      _param.target=_rid;
      _param.content=_text;
      ChatServer:sendPrivateMessage(_param,callback);
end
function ChatMainView:updatePrivateObject(_cell,_item)
 --//玩家头像
        local     _node=_cell.panel_1.ctn_1;
        local _icon = FuncChar.icon(tostring(_item.avatar));
        local _sprite = display.newSprite(_icon):size(_node.ctnWidth, _node.ctnHeight);
        _node:addChild(_sprite);
--//名字
      if(_item.name==nil or _item.name=="")then
           _cell.mc_1.currentView.txt_1:setString(GameConfig.getLanguage("tid_common_2006"));
       else
            _cell.mc_1.currentView.txt_1:setString(_item.name);
       end
       if(not _item.online)then
           _cell.mc_2:showFrame(2);
       end
--//等级
      _cell.panel_1.txt_1:setString("".._item.level);
--//高亮度显示
      _cell.scale9_2:setVisible(_item.rid==self.targetPlayer.rid);
--//注册监听事件
      _cell:setTouchedFunc(c_func(self.clickCellButtonChangeTarget,self,_item));
--//注册玩家详情点击事件
      _cell.panel_1:setTouchedFunc(c_func(self.clickCellButtonQueryPlayerInfo,self,_item));
end
--//点击私聊对象
function  ChatMainView:clickCellButtonChangeTarget(_item)
--//对所有的聊天对象进行遍历,如果选中不是原来的
      if(self.targetPlayer.rid~=_item.rid)then
               for  _index=1,#self.privateMessage do
                    local   _target=self.privateMessage[_index];
                    local   _cell=self.mc_scroll.currentView.scroll_1:getViewByData(_target);
                    if(_cell~=nil)then
                         _cell.scale9_2:setVisible(_item.rid==_target.rid);
                    end
             end
             self.targetPlayer=_item;
             ChatModel:setPrivateTargetPlayer(_item);
             self:setPrivateChatDetail(_item.chatContent);
      end
end
--//右侧刷新页面
function ChatMainView:setPrivateChatDetail(_message)
--//右侧的聊天内容
      local function genObjectMessage(_item)
            local _cell=UIBaseDef:cloneOneView(self.panel_4);
            self:updateObjectMessage(_cell,_item);
            return _cell;
      end
      local  param2={
           data=_message,
           createFunc=genObjectMessage,
           perNums=1,
           offsetX=1.45,
           offsetY=0,
           widthGap=0,
           itemRect={x=0,y=-118.85,width=450,height=118.85},
           perFrame=1,
      };
      local    _detail_scroll_list=self.mc_scroll.currentView.scroll_2;--//右侧显示与该玩家的对话
      _detail_scroll_list:styleFill({param2});
      _detail_scroll_list:gotoTargetPos(#_message,1);
end
function ChatMainView:updateObjectMessage(_cell,_item)
     local   _scroll_list=self.mc_scroll.currentView.scroll_2;
--//玩家图标
        local     _node=_cell.panel_1.ctn_1;
        local _icon = FuncChar.icon(tostring(_item.avatar));
        local _sprite = display.newSprite(_icon):size(_node.ctnWidth, _node.ctnHeight);
        _node:addChild(_sprite);
--//名字
      local  _rid=UserModel:rid();
      if(_item.rid==_rid)then--//自身
              _cell.mc_1:showFrame(2);
     end
     if(_item.name=="")then
        _cell.mc_1.currentView.txt_1:setString(GameConfig.getLanguage("tid_common_2006"));
     else
      _cell.mc_1.currentView.txt_1:setString(_item.name);
      end
--//VIP
      if(_item.vip>0)then
               _cell.mc_3:showFrame(_item.vip+1);
      end
--//level
     _cell.panel_1.txt_1:setString("".._item.level);
--//时间
      _cell.txt_2:setString(FormatChatTime(_item.time));
--//格式化对话内容
     _cell.rich_1:initRichText();
     FormatRichText(_cell.rich_1,_item.content);
end
--//刷新私聊页面
function ChatMainView:freshPrivateChat()
      if(self.chatType~=ChatType.ChatType_Private)then
              self["mc_"..self.chatType]:showFrame(1);
      end
      self.mc_3:showFrame(2);
      self.chatType=ChatType.ChatType_Private;
       local  function callback(param)
             if(param.result~=nil)then
--//刷新缓存中的数据
                    ChatModel:updatePrivateOnlineState(param.result.data.data);
                    self:setPrivateChat();
             end
       end
       local  rids=ChatModel:getAllPrivateRid();
       if(#rids>0)then--//如果有私聊对象,则需要联网一次获取所有任务的在线状态,否则直接切换
                local   param={};
                param.rids=rids;
                ChatServer:queryPlayerInfo(param,callback);
       else
                self:setPrivateChat();
       end
end
return ChatMainView  
-- endregion
