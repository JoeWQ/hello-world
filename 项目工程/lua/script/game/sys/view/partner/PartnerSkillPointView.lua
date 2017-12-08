--伙伴技能点购买
--2016-12-29 14:30:41
--@Author:xiaohuaxiong
local PartnerSkillPointView = class("PartnerSkillPointView",UIBase)

function PartnerSkillPointView:ctor(_winName)
    PartnerSkillPointView.super.ctor(self,_winName)
end

function PartnerSkillPointView:loadUIComplete()
    self:registerEvent()
        --每次的花费
    local _partner_cost_array = FuncDataSetting.getDataByHid("PartnerConsumeSkill").str
    local _partner_cost = string.split(_partner_cost_array,";")
    --当前的购买次数
    local _now_times = CountModel:getPartnerSkillPointTime()+1
    self._nowCost = _now_times>4 and tonumber(_partner_cost[4]) or tonumber(_partner_cost[_now_times])
    self.txt_2:setString(tostring(self._nowCost))
    --颜色
    local _user_diamond = UserModel:getGold()
    if self._nowCost > _user_diamond then
        self.txt_2:setColor(FuncCommUI.COLORS.TEXT_RED)
    end
    local _user_vip = UserModel:vip();
    local _max_skill_point = FuncCommon.getVipPropByKey(_user_vip,"partnerSkillMax")
    self.txt_3:setString(GameConfig.getLanguage("partner_skill_point_buy_1018"):format(_max_skill_point))
    self.UI_1.txt_1:setString(GameConfig.getLanguage("partner_skill_point_title_1013"))
end

function PartnerSkillPointView:registerEvent()
    PartnerSkillPointView.super.registerEvent(self)
    self:registClickClose("out");
    self.UI_1.btn_close:setTap(c_func(self.clickButtonClose,self))
    self.UI_1.mc_1:showFrame(2)
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.clickButtonBuy,self))
    self.UI_1.mc_1.currentView.btn_2:setTap(c_func(self.clickButtonClose,self))
end

function PartnerSkillPointView:clickButtonBuy()
    --检测仙玉
    local _user_diamond = UserModel:getGold()
    if self._nowCost > _user_diamond then
        UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND,self._nowCost,true)
        return
    end
    PartnerServer:skillPointBuyrequest(c_func(self.onSkillPointBuyEvent,self))
end

function PartnerSkillPointView:onSkillPointBuyEvent(_event)
    --弹出购买成功提示
    if _event.result ~= nil then
        WindowControler:showTips(GameConfig.getLanguage("partner_skill_point_buy_success_1011"))
        self:startHide()
    elseif _event.error.message == "partner_buy_skill_max" then --伙伴技能角色还没有耗尽,档这个弹出框在有种长时间悬浮的时候就有可能出现
        WindowControler:showTips(GameConfig.getLanguage("partner_skill_point_not_zero_1014"))
    end
end

function PartnerSkillPointView:clickButtonClose()
    self:startHide()
end

return PartnerSkillPointView