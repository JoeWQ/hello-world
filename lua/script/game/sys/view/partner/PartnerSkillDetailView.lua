--伙伴系统,技能详情
--2017年1月6日15:40:55
--@Author:xiaohuaxiong
local PartnerSkillDetailView = class("PartnerSkillDetailView",UIBase)

function PartnerSkillDetailView:ctor(_win_name,_skill_info,_worldPoint)
    PartnerSkillDetailView.super.ctor(self,_win_name)
    self._skillInfo = _skill_info
    --self.panel_1需要调整对齐的位置,这个只是一个推荐位置,具体的实现取决于面板本身所在的位置
    self._worldAlignPoint = _worldPoint
end

function PartnerSkillDetailView:loadUIComplete()
    self:registerEvent()
    self:alignDetailView()
    self:updateDetailView()
end

function PartnerSkillDetailView:registerEvent()
    PartnerSkillDetailView.super.registerEvent(self)
    self:registClickClose("out")
end

function PartnerSkillDetailView:updateDetailView()
    local _skill_item = FuncPartner.getSkillInfo(self._skillInfo.id)
    local _view = self.panel_1
    --icon
    local _iconPath = FuncRes.iconSkill(_skill_item.icon)
    local _iconSprite = cc.Sprite:create(_iconPath)
    _view.ctn_1:removeAllChildren()
    _view.ctn_1:addChild(_iconSprite)
    --name
    _view.txt_1:setString(GameConfig.getLanguage(_skill_item.name))
    --type
    _view.txt_2:setString(GameConfig.getLanguage(_skill_item.dis))
--    --level
    _view.txt_3:setString(GameConfig.getLanguage("partner_skill_level_1016"):format(self._skillInfo.level))
--    --describe
    _view.txt_4:setString(GameConfig.getLanguage(_skill_item.describe))
--    --关于该技能对角色的属性的提升
    local _final_content
    if _skill_item.kind == 2 then--固定属性
        local _attrMap = {}
        for _key,_value in pairs(_skill_item.lvAttr)do
            local _attr_item = {
                key = _value.key,
                value = _value.value * self._skillInfo.level + _skill_item.initAttr[_key].value, --lv * _value.value + _base
                mode = _value.mode,
            }
            table.insert( _attrMap,_attr_item)
        end
        local _result = FuncBattleBase.countFinalAttr(_attrMap)
        local _resultAttr = FuncBattleBase.formatAttribute(_result)
        _final_content = GameConfig.getLanguageWithSwap(_skill_item.describe2,_resultAttr[1].name,_resultAttr[1].value)
    elseif _skill_item.kind == 1 then
        local _attrMap = {}
        for _key,_value in pairs(_skill_item.growType) do
            local a=0
            local b=0
            if _value == 1 then
                a = _skill_item.growDmg[1] * self._skillInfo.level + _skill_item.growDmg[2]
                b = _skill_item.growDmg[3] * self._skillInfo.level + _skill_item.growDmg[4]
                if a>0  then
                    table.insert(_attrMap,math.floor(a/10000))
                end
                if b>0 then
                    table.insert(_attrMap, math.floor(b/10000))
                end
            elseif _value == 2 then
                a = _skill_item.growTreat[1] * self._skillInfo.level + _skill_item.growTreat[2]
                b = _skill_item.growTreat[3] * self._skillInfo.level + _skill_item.growTreat[4]
                if a>0  then
                    table.insert(_attrMap, math.floor(a/10000))
                end
                if b>0 then
                    table.insert(_attrMap, math.floor(b/10000) )
                end
            elseif _value ==3 then
                for _index=1,#_skill_item.growOther , 2 do
                    a = _skill_item.growOther[_index] * self._skillInfo.level + _skill_item.growOther[_index+1] 
                    if a>0 then
                        table.insert(_attrMap,a)
                    end
                end
            end
        end
        _final_content = GameConfig.getLanguageWithSwap(_skill_item.describe2,unpack(_attrMap))
    end
    _view.txt_5:setString(_final_content)
end

function PartnerSkillDetailView:alignDetailView()
    local _rect = self.panel_1:getContainerBox()
    --判断是否在调整后出现越过边界行为
    --优先限计算面板向下延伸
    local x = self._worldAlignPoint.x
    local y = self._worldAlignPoint.y
    if x + _rect.width > GameVars.width then--X镜像反射
        x = x - _rect.width
    end
    if y - _rect.height <0  then--Y镜像反射
        y = y + _rect.height
    end
    --转换到蒙版中的
    self.panel_1:setPosition(cc.p(x - GameVars.UIOffsetX,  y - GameVars.height))
end

return PartnerSkillDetailView