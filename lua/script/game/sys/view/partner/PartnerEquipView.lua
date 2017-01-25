--伙伴装备系统主页面
--2017年1月3日18:00:52
--Author:xiaohuaxiong
local PartnerEquipView = class("PartnerEquipView",UIBase)

function PartnerEquipView:ctor(_winName,_CurrentSelect,_selectPartnerId)
    PartnerEquipView.super.ctor(self,_winName);
    self._CurrentSelect = 1 --tonumber(_CurrentSelect) or 1
    self.selectPartnerId = _selectPartnerId 
end

function PartnerEquipView:loadUIComplete()
    --统计MC功能与实际的帧数,以及实际的UI模块的名字
    self._mcFrames={
        [1] = { frame= 1, name ="UI_1", },--强化
        [2] ={ frame= 2, name ="UI_1",} , --神装
    }
    --注意所有的UI都必须实现 updateUIWithPartner( _partner ) 接口,其中_partner为伙伴的详细信息
    self:registerEvent()
    FuncCommUI.setViewAlign(self.panel_res,UIAlignTypes.MiddleTop);--上方的资源条
    FuncCommUI.setViewAlign(self.btn_back,UIAlignTypes.RightTop)--右上角返回按钮
    FuncCommUI.setScale9Align(self.scale9_resdi,UIAlignTypes.MiddleTop, 1, 0)--上方的Scale9底板
    FuncCommUI.setViewAlign(self.UI_latiao,UIAlignTypes.Left)--左侧伙伴列表
    FuncCommUI.setViewAlign(self.panel_icon,UIAlignTypes.LeftTop)--左上角标题
    --设置组件之间的相互引用
    self.UI_1:setPartnerView(self)
    self.UI_latiao:setUIType("EQUIP_SYS")
    self.UI_latiao:setPartnerView(self)
    self.UI_latiao:setCurrentPartner(self.selectPartnerId)
    self.UI_latiao:updateView()
    --设置第一个选择的UI
    if self._CurrentSelect == FuncPartner.PartnerIndex.PARTNER_COMBINE then
        self.UI_1:setCurrentSelect(1)--默认选择第一个UI/升品
        self:delayCall(function ()
            WindowControler:showWindow("PartnerCombineView")
        end,0.06)
    else    
        self.UI_1:setCurrentSelect(self._CurrentSelect)
    end
end

function PartnerEquipView:registerEvent()
    PartnerEquipView.super.registerEvent(self)
    self.btn_back:setTap(c_func(self.close,self))
    --铜钱变化监听
    
    --顶部红点变化监听
    EventControler:addEventListener(PartnerEvent.PARTNER_TOP_REDPOINT_EVENT,self.refreshTopRedPoint,self)
end
--切换UI,注意这个函数主要是作为一个回调函数使用
--_uiIndex:功能的索引值(索引的顺序就是按钮从左到右的顺序),至于如何寻址,取决于模块的内部接口,
--注意这里虽然传入了伙伴的信息,但是具体的刷新与否,取决于UI自己的实现
function PartnerEquipView:changeUIWith( _uiIndex,_partnerInfo)
    local   _mcFrame = self._mcFrames[_uiIndex]
    self.mc_n:showFrame(_mcFrame.frame)
    local   _uiModule = self.mc_n.currentView[_mcFrame.name]
    _uiModule:updateUIWithPartner(_partnerInfo)
    self._partnerInfo = _partnerInfo
    self:refreshTopRedPoint()
end
--对上一个函数的封装,这个函数会在PartnerBtnView中被调用
function PartnerEquipView:changeUIInTopView( _topUIIndex)
    local  _partnerInfo = self.UI_latiao:getCurrentPartner()
    self:changeUIWith(_topUIIndex,_partnerInfo)
end
--在PartnerbtnView中被调用
function PartnerEquipView:changeUIInBtnView( _partnerInfo)
    local  _topViewIndex=self.UI_1:getCurrentSelectButtonIndex()
    self:changeUIWith(_topViewIndex,_partnerInfo)
end
function PartnerEquipView:close()
    self:startHide()
end
-- 刷新顶部红点提示
function PartnerEquipView:refreshTopRedPoint()
    self.UI_1:refreshRedPoint(self._partnerInfo.id)
end

return PartnerEquipView