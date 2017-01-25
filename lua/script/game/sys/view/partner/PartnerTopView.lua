--伙伴系统功能按钮管理
--2016-12-6 17:14:13
--Author:xiaohuaxiong
local PartnerTopView = class("PartnerTopView",UIBase)

function PartnerTopView:ctor(_winName)
    PartnerTopView.super.ctor(self,_winName)
--当前被选中的按钮
    self._currentSelect=0;
--关于PartnerView的引用
    self._partnerView=nil
end

function PartnerTopView:setPartnerView( _class)
    self._partnerView = _class
end

function PartnerTopView:loadUIComplete()
    self:registerEvent();
end

function PartnerTopView:registerEvent()
    PartnerTopView.super.registerEvent(self)
--将按钮的名字集合起来,注意按钮与事件之间的对应关系
   self._mcFunc={}
--升品
   self._mcFunc[1]=self.mc_1
   self._mcFunc[2]=self.mc_2
   self._mcFunc[3]=self.mc_3
   self._mcFunc[4]=self.mc_4
   self._mcFunc[5]=self.mc_5
--按钮注册事件
   self._funcSet ={
        self.clickButtonQualityLevelup,--升品
        self.clickButtonLevelup,--升级
        self.clickButtonStarLevelup,--升星
        self.clickButtonSkill,--技能
        self.clickButtonSuperSkill,--绝技
   }
--函数表驱动
   for _index=1, #self._mcFunc do
        self._mcFunc[_index].currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,_index))
   end
--默认选择第一个
--   self:setCurrentSelect(1)
end
--设置当前被选中的按钮
function PartnerTopView:setCurrentSelect( _select)
    assert(_select>0 and _select<=#self._mcFunc)
    if(_select ~= self._currentSelect)then
            if(self._currentSelect >0)then
                    self._mcFunc[self._currentSelect]:showFrame(1)  
            end
            self._mcFunc[_select]:showFrame(2)
            self._currentSelect = _select
--调用新的事件函数
            self._funcSet[_select](self);
            self._partnerView:changeUIInTopView(_select)
    end
end
--获取当前被选中的按钮的索引
function PartnerTopView:getCurrentSelectButtonIndex()
     return self._currentSelect
end
-------------------------按钮事件集合---------------
--升品
function PartnerTopView:clickButtonQualityLevelup()

end
--升级
function PartnerTopView:clickButtonLevelup()

end
--升星
function PartnerTopView:clickButtonStarLevelup()

end
--技能
function PartnerTopView:clickButtonSkill()

end
--绝技
function PartnerTopView:clickButtonSuperSkill()

end

-------------------红点提示刷新--------------------
function PartnerTopView:refreshRedPoint(_partnerId)
    local isQualityShow = PartnerModel:isShowQualityRedPoint(_partnerId)
    self._mcFunc[1].currentView.panel_red:visible(isQualityShow)

    local isUpgradeShow = PartnerModel:isShowUpgradeRedPoint(_partnerId)
    self._mcFunc[2].currentView.panel_red:visible(isUpgradeShow)

    local isStarShow = PartnerModel:isShowStarRedPoint(_partnerId)
    if isStarShow == false then
        echo("--------------- isStarShow  xxxxxxxxxxxxxxxxxxx")
    else
        echo("--------------- isStarShow  yyyyyyyyyyyyyyyyyyyyyy")
    end
    
    self._mcFunc[3].currentView.panel_red:visible(isStarShow)
end
return PartnerTopView