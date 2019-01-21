-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成


local StarlightTipView = class("StarlightTipView", UIBase)


function StarlightTipView:ctor(winName, _sire)
    StarlightTipView.super.ctor(self, winName)
    self.sire = _sire
    self.itemDataCache = { }
    self.showIdx = 5
    -- 默认最显示5个
    self.index = -1
    self.length = 0

end
function StarlightTipView:initData(data)
    self.chooseId = -1
    self.data = data
    if not data.activate then
        self.mc_4.currentView.btn_1:setTap(c_func( function()
            if data.canActivate then
                self:requestActivate()
            else
                WindowControler:showTips("您未满足激活条件")
            end
        end , self));
    end
    self:updateUI()
end 

function StarlightTipView:requestActivate()
    local function _callback(_param)
       if(_param.result~=nil)then 
            self.mc_4:showFrame(2)
             self.data.activate=true;--//手动进行刷新
             self.panel_red:setVisible(false);
             self.mc_3:showFrame(1);
             local  _starlight=UserModel:starLights();
            if self.data.Num ~= nil then 
               self.mc_3.currentView.txt_2:setString(" +"..self.data.Num)
            else
              self.mc_3.currentView.txt_2:setString(self.data.Percent.."%")
            end 
            self.mc_3.currentView.txt_1:setString(GameConfig.getLanguage(self.data.Desc))
            
       else
             WindowControler:showTips("激活失败");
       end
    end 
    local  _param={};
    _param.starLightId=self.data.Id;
    Server:sendRequest(_param, MethodCode.starlight_activate_3301, _callback,nil,nil,true)
end 

function StarlightTipView:loadUIComplete()
    self:registerEvent()
    --  判断状态激活
    FuncCommUI.setViewAlign(self.panel_1, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.btn_close, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.panel_2, UIAlignTypes.MiddleTop)
    FuncCommUI.setViewAlign(self.mc_4, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.panel_red,UIAlignTypes.RightBottom);
    local  _map={"5"};

    _map[2]="2";
end

function StarlightTipView:registerEvent()

    self.btn_close:setTap(c_func( function()
        EventControler:dispatchEvent(TreasureEvent.STARLIGHT_UPDATE_ITEM,{data=self.data});
        self:startHide()
    end , self));

  EventControler:addEventListener(UIEvent.UIEVENT_HIDECOMP, self.updateTrreuUpdate, self)

end
--强化返回后刷新
function StarlightTipView:updateTrreuUpdate(event)
    local _p = event.params
    if _p.ui.windowName == "TreasureDetailView" or _p.ui.windowName=="LotteryMainView" then
 --       local os = _p.data.treasureLvl

 --       if _p.data ~= nil and self.chooseId ~= -1 then
              EventControler:dispatchEvent(StarlightEvent.STARLIGHT_EVENT_UPDATE) 
             self:updateUI()
--        end
    end

end 
--//格式化属性加成的显示
function StarlightTipView:formatAttribPosition()
    local _text2
    if self.data.Num ~= nil then 
         _text2="+"..self.data.Num;
    else
        _text2="+"..self.data.Percent.."%";
    end 
    local  _text1=GameConfig.getLanguage(self.data.Desc);
--//计算坐标
    local  _label2=self.mc_3.currentView.txt_2;
    local  _label1=self.mc_3.currentView.txt_1;

    local   x,y=_label1:getPosition();
    local  _total_width=FuncCommUI.getStringWidth(_text1.._text2,26,"systemFont");
--//分别根据各个字符串的长度取权值分量
    local   _width1=FuncCommUI.getStringWidth(_text1,26,"systemFont");
    local   _width2=FuncCommUI.getStringWidth(_text2,26,"systemFont");

    _label1:setPosition(cc.p(x+_total_width/2-_width2,y));
    _label2:setPosition(cc.p(x+_total_width/2-_width2,y));
    _label1:setString(_text1);
    _label2:setString(_text2);
end
function StarlightTipView:updateUI()
    local _len = #self.data.Require/2-1;
    local data = self.data
    if tonumber(UserModel:level()) < data.UnlockLevel then
        self.panel_1:setVisible(true)
    end

    self.mc_2:showFrame(data.Bg)
    self.mc_1:showFrame(_len )
    local _eventCallBack = { }
    local _myTreasuresVer = TreasuresModel:getAllTreasure()

    
    local  _starLight=StarlightModel:getStarlights();
    data.activate=_starLight[data.Id]~=nil;--//是否已经激活
    local      _canActive=true;
    for i = 1, #data.Require,2 do
 --       local _rId = string.split(data.Require[i], ",")
        local   _index=(i+1)/2;
        local  _rId1=data.Require[i];
        local  _rId2=data.Require[i+1];
        local _resName = FuncRes.iconTreasure(_rId1)
        local    _node=self.mc_1.currentView["panel_" .. _index].ctn_1
        _node:removeAllChildren();
        local _sprite = display.newSprite(_resName):size(_node.ctnWidth, _node.ctnHeight)
        _sprite:addto(_node)
  --      local _rId = string.split(data.Require[i], ",")
--        local maxLvl = FuncTreasure.getValueByKeyTD(_rId[1], "lvLimit");
        _eventCallBack[_index] = function()
            self:treasureMaterialCallBack(_index)
        end
--//是否需要重新计算激活条件
       _canActive=_canActive and (_myTreasuresVer[_rId1] ~= nil and _myTreasuresVer[_rId1]:level() >= tonumber(_rId2));

         local _text = ""
        if _myTreasuresVer[_rId1] ~= nil then
             _text = string.format("%s/%s级", _myTreasuresVer[_rId1]:level(), _rId2) 
             FilterTools.clearFilter(_sprite);
        else
            if(data.activate)then
                _text = string.format("%s/%s级", _rId2, _rId2)
                FilterTools.clearFilter(_sprite);
            else
               _text = string.format("%s/%s级", 0, _rId2)
               FilterTools.setGrayFilter(_sprite);
            end
        end
        self.mc_1.currentView["panel_" .. _index].txt_1:setString(_text)
        self.mc_1.currentView["panel_" .. _index].ctn_1:setTouchedFunc(_eventCallBack[_index], nil, true, function() end)
    end
--//激活与否需要重新计算
    data.canActivate=_canActive;
    local _frame = _yuan3(data.activate, 2, 1)
    self.mc_4:showFrame(_frame)
    if _frame  == 1 and not data.canActivate then 
        FilterTools.setGrayFilter(self.mc_4.currentView.btn_1)
    else
        FilterTools.clearFilter(self.mc_4.currentView.btn_1);
    end  

    self.panel_red:setVisible(not data.activate and data.canActivate);

    if(not data.activate)then
            self.mc_3:showFrame(2);
    else
            self.mc_3:showFrame(1);
    end
    local _text2
    if self.data.Num ~= nil then 
         _text2="+"..self.data.Num;
    else
        _text2="+"..self.data.Percent.."%";
    end 
    local  _text1=GameConfig.getLanguage(self.data.Desc);
--//计算坐标
    local  _label2=self.mc_3.currentView.txt_2;
    local  _label1=self.mc_3.currentView.txt_1;
    _label1:setString(_text1);
    _label2:setString(_text2);
end 
function StarlightTipView:treasureMaterialCallBack(idx)
     self.chooseId = idx
    local _myTreasuresVer = TreasuresModel:getAllTreasure()
--    local _rId = string.split(self.data.Require[idx], ",")
    local     _index=(idx-1)*2+1;
    local   _rid1=self.data.Require[_index];
    if _myTreasuresVer[_rid1] ~= nil then
        -- 是否拥有该法宝
        WindowControler:showWindow("TreasureDetailView", _myTreasuresVer[_rid1]);
    elseif(self.data.activate)then
        WindowControler:showTips(GameConfig.getLanguage("treasure_swallowed"));
    else
        WindowControler:showWindow("GetWayListView", _rid1);
    end
end 

function StarlightTipView:deleteMe()
    StarlightTipView.super.deleteMe(self)
    self.controler = nil
end

return StarlightTipView  
-- endregion
