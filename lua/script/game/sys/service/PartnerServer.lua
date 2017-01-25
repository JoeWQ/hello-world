-- 伙伴系统
-- 2016-12-6 15:38:32
-- Author:狄建彬
-- 注意,在以下的函数中,如果只需要传入一个参数的,可以直接传入相关参数
-- 如果需要传入多个参数的,需要在外部自己填写相关的数据结构,然后吧参数传入
local PartnerServer = class("PartnerServer")

function PartnerServer:init()

end
-- 获取所有的伙伴
-- function PartnerServer:getAllPartners( )

-- end
-- 伙伴合成
function PartnerServer:partnerCombineRequest(_partnerId, _funcCall)
    Server:sendRequest( { partnerId = _partnerId }, MethodCode.partner_combine_4201, _funcCall, nil, ni, true);
end
-- 伙伴升级
function PartnerServer:levelupRequest(_param, _funcCall)
    Server:sendRequest(_param, MethodCode.partner_equipment_levelup_4203, _funcCall, nil, nil, true)
end
-- 伙伴升星
function PartnerServer:starLevelupRequest(_partnerId, _funcCall)
    Server:sendRequest( { partnerId = _partnerId }, MethodCode.partner_star_leveup_4205, _funcCall, nil, nil, true)
end
-- 伙伴升品
function PartnerServer:qualityLevelupRequest(_partnerId, _callFunc)
    Server:sendRequest( { partnerId = _partnerId }, MethodCode.partner_quality_levelup_4207, _callFunc, nil, nil, true)
end
-- 伙伴技能升级
function PartnerServer:skillLevelupRequest(_param, _callFunc)
    Server:sendRequest(_param, MethodCode.partner_skill_levelup_4209, _callFunc, nil, nil, true)
end
-- 仙魂升级
function PartnerServer:soulLevelupRequest(_param, _callFunc)
    Server:sendRequest(_param, MethodCode.partner_soul_levelup_4211, _callFunc, nil, nil, true)
end
-- 碎片兑换
function PartnerServer:fragExchangeRequest(_param, _callFunc)
    dump(_param,"—————碎片兑换-----")
    Server:sendRequest(_param, MethodCode.partner_fragment_exchange_4217, _callFunc, nil, nil, true)
end
-- 升品道具合成
function PartnerServer:qualityItemLevelupRequest(_itemId, _callFunc)
    Server:sendRequest( { itemId = _itemId }, MethodCode.partner_quality_item_combine_4219, _callFunc, nil, nil, true)
end
-- 升品道具装备
function PartnerServer:qualityItemEquipRequest(_param, _callFunc)
    Server:sendRequest( _param, MethodCode.partner_quality_item_equip_4213, _callFunc, nil, nil, true)
end
-- 技能点购买
function PartnerServer:skillPointBuyrequest(_callFunc)
    Server:sendRequest( { }, MethodCode.partner_skill_point_buy_4215, _callFunc, nil, nil, true)
end
-- 伙伴装备升级 
function PartnerServer:equipUpgradeRequest(_param, _callFunc)
    Server:sendRequest( _param, MethodCode.partner_equipment_upgrade_4221, _callFunc, nil, nil, true)
end

return PartnerServer;