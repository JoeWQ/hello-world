-- //购买铜钱
-- //原来的页面被误删除了,重写..
-- //2016-4-22
--//xianpro\art\美术确定资源\特效\UI特效\主城
local CompBuyCoinMainView = class("CompBuyCoinMainView", UIBase);
function CompBuyCoinMainView:ctor(_winName)
    CompBuyCoinMainView.super.ctor(self, _winName);
    self.hasInit=false;
end
-- //
function CompBuyCoinMainView:loadUIComplete()
    self:registerEvent();
    self:buyCoin();
    self.scroll_record=self.panel_jieguo.scroll_1;
    self.scroll_record:setFillEaseTime(0.2);
    self.table_record={};
--//动作队列
    self.actionSequence={};
    self.panel_jieguo.panel_1:setVisible(false);
--//Tga标记,用于执行自删除操作
    self.sequenceTag=11;
    self.isVisibleChanged=false;
--//索引1位字体的描边颜色,[2]位字体的颜色
    self.explodeMapColor={  
                                             [2]={ [1]=cc.c4b(0x22,0x40,0x92,255), [2]=cc.c3b(0x23,0xcb,0xff ) , },
                                             [5]={[1]=cc.c4b(0x51,0x03,0x62,255),[2]=cc.c3b(0xf8,0x40,0xff ),},
                                             [10]={[1]=cc.c4b( 0x5f,0x2a,0x00,255),[2]=cc.c3b(0xff,0xdb,0x4c),},
        };
    self.panel_jieguo:setVisible(false);
end
function CompBuyCoinMainView:registerEvent()
    CompBuyCoinMainView.super.registerEvent(self);
    self:registClickClose("out");
    self.btn_close:setTap(c_func(self.clickButtonClose, self));
--FuncCommUI.showTipMessage(FuncDataResource.RES_TYPE.COIN, msg.totalCoin);
   EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE,self.onEventRefresh,self);--//仙玉发生了变化
end
function CompBuyCoinMainView:clickButtonClose()
    self:startHide();
end

function  CompBuyCoinMainView:onEventRefresh()
   self.hasInit=false;
   self:buyCoin();
end
--//购买铜钱唯一的入口
function CompBuyCoinMainView:buyCoin()
   if(self.hasInit)then
         return;
   end
   self.hasInit=true;
    self.panel_1.txt_1:setString(GameConfig.getLanguage("#tid2005"));
    -- //购买次数,最大购买次数
    self.buyTimes = CountModel:getCoinBuyTimes();
    self.maxBuyTimes = CountModel:getMaxCoinBuyTimes();
    self.txt_3:setVisible(false);
    self.txt_4:setVisible(false);
    local content = GameConfig.getLanguage("tid_buy_times_1002");
    -- //购买次数详情
    self.txt_1:setString(content:format(self.buyTimes, self.maxBuyTimes));
    -- //价格,数目
    self.diamondCost, self.coinNum = FuncCommon.getCoinPriceByTimes(self.buyTimes + 1);
    self.panel_2.txt_1:setString("" .. self.diamondCost);
    self.panel_2.txt_2:setString("" .. self.coinNum);
    if(self.diamondCost>UserModel:getGold())then--//金币不足
         self.panel_2.txt_1:setColor(cc.c3b(255,0,0));
    else
         self.panel_2.txt_1:setColor(cc.c3b(0x8E,0x5F,0x35));
    end
    -- //购买十次
    self.btn_buyten:setTap(c_func(self.clickButtonTenTimes , self));
    -- //购买一次
    self.btn_queding:setTap(c_func(self.clickButtonOneTime, self));
   
end
-- //购买一次
function CompBuyCoinMainView:clickButtonOneTime()
    self:buyCoinByRequest(1);
end
-- //十次
function CompBuyCoinMainView:clickButtonTenTimes()
    self:buyCoinByRequest(10);
end
-- //购买
function CompBuyCoinMainView:buyCoinByRequest(_times)
    -- //检测条件
    if (self.buyTimes >= self.maxBuyTimes) then
        -- //购买次数
        WindowControler:showTips(GameConfig.getLanguage("tid_buy_limit_1003"));
        return;
    end
    -- //至少能购买一次
	if not UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, self.diamondCost, true) then
		return
	end
    self:requestBuyCoin(_times);
end
-- //联网
function CompBuyCoinMainView:requestBuyCoin(_times)
    local   function    _onPanelVisible()
          self.panel_jieguo:setVisible(true);
          self.ctn_ss:removeChildByTag(1);
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
            -- //如果有暴击
            AudioModel:playSound(MusicConfig.s_com_buycopper);

            local msg = _param.result.data;
            local explode = 1;
            for _index = 1, #msg.hit do
                local  _record={};
                _record.explode=msg.hit[_index];
                _record.coin=msg.detailCoin[_index];
                _record.cost=self.totalTimes[_index];
                table.insert(self.actionSequence,_record);
            end
--//如果底层面板是隐藏的
            if(not self.isVisibleChanged and not self.panel_jieguo:isVisible())then
                  local   _ani=self:createUIArmature("UI_buycoin","UI_buycoin_menghei",nil,false,_onPanelVisible);
                  self.ctn_ss:addChild(_ani,1,1);
                  _ani:pos(-214,-103);
                  self.isVisibleChanged=true;
            end
--//调度动作队列
            self:scheduleExplodeRecord();
            -- //更新购买次数
 --           self.buyTimes = self.buyTimes + table.length( msg.detailCoin);
            local content = GameConfig.getLanguage("tid_buy_times_1002");
            self.txt_1:setString(content:format(self.buyTimes, self.maxBuyTimes));
            self.diamondCost, self.coinNum = FuncCommon.getCoinPriceByTimes(self.buyTimes + 1);
            self.panel_2.txt_1:setString("" .. self.diamondCost);
            self.panel_2.txt_2:setString("" .. self.coinNum);
        else
            echo("--------CompBuyCoinMainView:requestBuyCoin---------", _param.error.code, _param.error.message);
            WindowControler:showTips(GameConfig.getLanguage("tid_buy_coin_failed_1005"));
        end
    end
    local param = { };
    self.totalCost=self.diamondCost;
    local     _totalTimes={};
    -- //如果是购买十次,需要判定是否能够满额购买,或者如果不能,需要计算出最大购买次数
    if (_times > 1) then
        local _count = 0;
        local _goldCount = UserModel:getGold();
        local _buyTimes = self.buyTimes + 1;
        local _gold, _2 = FuncCommon.getCoinPriceByTimes(_buyTimes);
        local _costGold = _gold;
        _buyTimes = _buyTimes + 1;
        while (_costGold <= _goldCount and _count <= 10) do
            table.insert(_totalTimes,_costGold);
            _count = _count + 1;
            local _gold, _2 = FuncCommon.getCoinPriceByTimes(_buyTimes);
            _costGold = _costGold + _gold;
            _buyTimes = _buyTimes + 1;
        end
        if (_count > 10) then
            _count = 10;
        end
        if(_count+self.buyTimes>self.maxBuyTimes)then
                 _count=self.maxBuyTimes-self.buyTimes;
        end
        _times=_count;
        self.totalCost=_costGold;
    else
           _totalTimes[1]=self.diamondCost;
    end
    self.totalTimes=_totalTimes;
    param.times = _times;
    UserServer:buyCoin(param, _callback);
end
--//向队列中插入元素
function CompBuyCoinMainView:scheduleExplodeRecord()
--//如果正处于执行中,那么就直接返回
      if(self.isPerforming or #self.actionSequence<=0)then
            return;
      end
      self.isPerforming=true;
--//对第一个动作队列执行删除操作
      local    _record=self.actionSequence[1];
      table.remove(self.actionSequence,1);
      self:performExplodeAction(_record);
end
--//执行动作
function CompBuyCoinMainView:performExplodeAction(_record)
    local function genRecordFunc(_recordItem)
        local _viewItem = UIBaseDef:cloneOneView(self.panel_jieguo.panel_1);
        self:updateBuyCoinRecord(_viewItem, _recordItem);
        return _viewItem;
    end
    -- //暴击动画之后调用
    local function _afterExplodeAni()
        local scroll_param = {
            data = self.table_record,
            createFunc = genRecordFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = { x = 0, y = -40.75, width = 412.75, height = 40.75 },
        };
 --       self.panel_jieguo:setVisible(true);
        self.scroll_record:styleFill( { scroll_param });
        self.scroll_record:gotoTargetPos(#self.table_record, 1,0,0.2);
    end
--//自删除
   table.insert(self.table_record,_record);
   local     _removeTag=self.sequenceTag;
   local    function  _remove_self()
        self.ctn_ss:removeChildByTag(_removeTag);
        self.ctn_ss:removeChildByTag(_removeTag+1);
        self.ctn_ss:removeChildByTag(_removeTag+2);
   end
   local    function   _delayCallback()
        self.isPerforming=false;
        self:scheduleExplodeRecord();
   end
--//如果是普通金钱获取
   if(_record.explode<=1)then
         local    _flutter_label=cc.Label:createWithSystemFont("恭喜获得铜币 ".._record.coin,GameVars.systemFontName,24);
         _flutter_label:setAnchorPoint(cc.p(0,1));
         local    _ani=self:createUIArmature("UI_buycoin","UI_buycoin_piaodong",nil,false,_remove_self);
         FuncArmature.changeBoneDisplay(_ani, "layer1", _flutter_label);
         _flutter_label:setColor(cc.c3b(0xff,0xff,0xff))
         _flutter_label:enableOutline(cc.c4b(0x48,0x48,0x48,0x48),2);
         self.ctn_ss:addChild(_ani,3,_removeTag);
         self.ctn_ss:runAction( cc.Sequence:create(cc.DelayTime:create(0.2) ,cc.CallFunc:create(_delayCallback)  )     );
         _afterExplodeAni();
   else
          local map = {[2]=1,[5]=2,[10]=3 };
          local aniMap = { [2] = "UI_buycoin_baodianlan", [5] = "UI_buycoin_baodianzi", [10] =  "UI_buycoin_baodianjin"};
          local aniMap2={[2]="UI_buycoin_baodian",[5]="UI_buycoin_zisebaoji",[10]="UI_buycoin_jinse",};
         local    _flutter_label=cc.Label:createWithSystemFont("恭喜获得铜币 ".._record.coin,GameVars.systemFontName,24);
         _flutter_label:setAnchorPoint(cc.p(0,1)); 

         local    _ani=self:createUIArmature("UI_buycoin","UI_buycoin_piaodong",nil,false,_remove_self);
         FuncArmature.changeBoneDisplay(_ani, "layer1", _flutter_label);
         _flutter_label:setColor(self.explodeMapColor[_record.explode][2]);
         _flutter_label:enableOutline(self.explodeMapColor[_record.explode][1],2);
         self.ctn_ss:addChild(_ani,3,_removeTag);
         self.ctn_ss:runAction( cc.Sequence:create(cc.DelayTime:create(0.2) ,cc.CallFunc:create(_delayCallback)  )     );

          local ani = self:createUIArmature("UI_buycoin",aniMap[_record.explode], nil, false, GameVars.emptyFunc);
          ani:pos(-120,0);
          self.ctn_ss:addChild(ani, 1,_removeTag+1);

          ani = self:createUIArmature("UI_buycoin",aniMap2[_record.explode], nil, false, _remove_self);
          ani:pos(-200,-20);
          self.ctn_ss:addChild(ani, 2,_removeTag+2);
          _afterExplodeAni();
    end
    self.sequenceTag=self.sequenceTag+3;
end
--//Update Function
function CompBuyCoinMainView:updateBuyCoinRecord(_viewItem,_record)
    _viewItem.txt_sz:setString(_record.cost.."仙玉");
    _viewItem.txt_tq:setString("铜钱".._record.coin);
    local map = {[2]=1,[5]=2,[10]=3 };
    if(_record.explode>1)then
           _viewItem.mc_baojiji:showFrame(map[_record.explode]);
           _viewItem.mc_baoji:showFrame(map[_record.explode]);
--           _viewItem.txt_tq:setColor(self.explodeMapColor[_record.explode][2]);
--           _viewItem.txt_tq:enableOutline(self.explodeMapColor[_record.explode][1],2);
--           _viewItem.txt_sz:setColor(self.explodeMapColor[_record.explode][2]);
--           _viewItem.txt_sz:enableOutline(self.explodeMapColor[_record.explode][1],2);
    else
           _viewItem.mc_baoji:setVisible(false);
           _viewItem.mc_baojiji:setVisible(false);
    end
end
return CompBuyCoinMainView;
