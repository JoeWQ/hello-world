--伙伴系统功能按钮管理
--2017-01-3 18:14:13
--Author:xiaohuaxiong
local PartnerEquipTopView = class("PartnerEquipTopView",UIBase)

function PartnerEquipTopView:ctor(_winName)
    PartnerEquipTopView.super.ctor(self,_winName)
--当前被选中的按钮
    self._currentSelect=0;
--关于PartnerView的引用
    self._partnerView=nil
end

function PartnerEquipTopView:setPartnerView( _class)
    self._partnerView = _class
end

function PartnerEquipTopView:loadUIComplete()
    self:registerEvent();
end

function PartnerEquipTopView:registerEvent()
    PartnerEquipTopView.super.registerEvent(self)
--将按钮的名字集合起来,注意按钮与事件之间的对应关系
   self._mcFunc={}
--
   self._mcFunc[1]=self.mc_1
   self._mcFunc[2]=self.mc_2

--按钮注册事件
   self._funcSet ={
        self.clickButtonQianghua,--强化
        self.clickButtonShenzhuang,--神装
   }
--函数表驱动
   for _index=1, #self._mcFunc do
        self._mcFunc[_index].currentView.btn_1:setTap(c_func(self.setCurrentSelect,self,_index))
   end
--默认选择第一个
--   self:setCurrentSelect(1)
end
--设置当前被选中的按钮
function PartnerEquipTopView:setCurrentSelect( _select)
    assert(_select>0 and _select<=#self._mcFunc)
    if (_select == 2) then
        WindowControler:showTips("此功能暂时不做")
        return 
    end
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
function PartnerEquipTopView:getCurrentSelectButtonIndex()
     return self._currentSelect
end

-------------------------按钮事件集合---------------
function PartnerEquipTopView:clickButtonQianghua()

end
function PartnerEquipTopView:clickButtonShenzhuang()

end

-------------------红点提示刷新--------------------
function PartnerEquipTopView:refreshRedPoint(_partnerId)
    local isEquipShow = PartnerModel:isShowEquipRedPoint(_partnerId)
    self._mcFunc[1].currentView.panel_red:visible(isEquipShow)
end

return PartnerEquipTopView