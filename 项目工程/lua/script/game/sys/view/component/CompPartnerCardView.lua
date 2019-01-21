local CompPartnerCardView = class("CompPartnerCardView", UIBase);

function CompPartnerCardView:ctor(winName)
    CompPartnerCardView.super.ctor(self, winName);
end

function CompPartnerCardView:loadUIComplete()
	
end 

function CompPartnerCardView:registerEvent()
	CompPartnerCardView.super.registerEvent();

end



function CompPartnerCardView:updataUI(_partnerId)
    local partnerCfg = FuncPartner.getPartnerById(_partnerId)
    -----  npc ------
    local ctn = self.panel_1.ctn_ren;
    ctn:removeAllChildren();
    local npcConfig = partnerCfg.order
    local arr = string.split(npcConfig, ",");
    local npcSpine = FuncRes.getArtSpineAni(arr[1])
	npcSpine:gotoAndStop(1)
    npcSpine:setOpacityModifyRGB(true)
    if arr[3] ~= nil then 
        npcSpine:setPositionX(npcSpine:getPositionX() + tonumber(arr[2]))    
    end 
    if arr[4] ~= nil then -- 缩放
        npcSpine:setPositionY(npcSpine:getPositionY() + tonumber(arr[3]))
    end
    local zuo = tonumber(arr[5])
    local shang = tonumber(arr[6])
    local you = tonumber(arr[7])
    local xia = tonumber(arr[8])
    local type1 = 0
    local type2 = 0
    if (zuo + you ) == 2 then --左右都切
        type1 = 3
    elseif zuo == 1 then
        type1 = 1
    elseif you == 1 then 
        type1 = 2
    else
        type1 = 0
    end
    if (shang + xia ) == 2 then --上下都切
        type2 = 3
    elseif xia == 1 then
        type2 = 1
    elseif shang == 1 then 
        type2 = 2
    else
        type2 = 0
    end
    echo("伙伴卡片切割 左右 == "..type1.."  上下 === ".. type2)
    self:addCardNpc(ctn,npcSpine,type1,type2)
    ----- 卡牌上信息 ------
    local partnerData = PartnerModel:getPartnerDataById(tostring(_partnerId))
    local quality = 1
    local stat = 1;
    if partnerData then
        quality = partnerData.quality --品质
        stat = partnerData.star --星级
    end
    local name = GameConfig.getLanguage(partnerCfg.name) --姓名
    self.panel_1.panel_1.panel_name.txt_1:setString(name.."+"..quality)
    self.panel_1.panel_1.mc_star:showFrame(stat)
    local _type = partnerCfg.type;--类型
    self.panel_1.panel_1.panel_name.mc_gfj:showFrame(_type)
    local skills = partnerCfg.skill--技能
    local skill1 = self:getSkillIcon(skills[1])
    self.panel_1.panel_1.panel_skill1.ctn_skill:addChild(skill1)
    local skill2 = self:getSkillIcon(skills[2])
    self.panel_1.panel_1.panel_skill2.ctn_skill:addChild(skill2)

end
--添加卡牌立绘 _type1 横向切割方式 _type2 竖向切割方式
-- 参数值 0 不切割 1左切（下） 2右切（上） 3都切
function CompPartnerCardView:addCardNpc(ctn,npcSpine,_type1,_type2)
    local nodeWight = 500
    local nodeHeight = 500
    local nodePosX = 0
    local nodePosY = 0
    local npcPosX = 0
    local npcPosY = 0
    local cardWight = 221;
    local cardHeight = 295;
    local clipNode = cc.ClippingNode:create()

    -- 左右切
    if _type1 == 0 then
        nodePosX = clipNode:getPositionX() - nodeWight/2
        npcPosX = npcSpine:getPositionX() + nodeWight/2
    elseif _type1 == 1 then
        nodePosX = clipNode:getPositionX() - cardWight/2
        npcPosX = npcSpine:getPositionX() + cardWight/2
    elseif _type1 == 2 then
        nodePosX = clipNode:getPositionX() - (nodeWight - cardWight/2)  
        npcPosX = npcSpine:getPositionX() + (nodeWight - cardWight/2) 
    elseif _type1 == 3 then
        nodeWight = 221
        nodePosX = clipNode:getPositionX() - nodeWight/2
        npcPosX = npcSpine:getPositionX() + nodeWight/2
    end
    --上下切
    if _type2 == 0 then
    elseif _type2 == 1 then
        nodePosY = clipNode:getPositionY() 
        npcPosY = npcSpine:getPositionY() 
    elseif _type2 == 2 then
        nodePosY = clipNode:getPositionY() - (nodeHeight - cardHeight) 
        npcPosY = npcSpine:getPositionY() + (nodeHeight - cardHeight)
    elseif _type2 == 3 then 
        nodeHeight = 295
        nodePosY = clipNode:getPositionY() 
        npcPosY = npcSpine:getPositionY() 
    end
    
    local stencilNode = cc.LayerColor:create(cc.c4b(0, 255, 0, 200), nodeWight, nodeHeight);
    clipNode:setStencil(stencilNode)
    clipNode:addChild(npcSpine)
    npcSpine:setPositionX(npcPosX)
    npcSpine:setPositionY(npcPosY)
    clipNode:setPositionX(nodePosX)
    clipNode:setPositionY(nodePosY)
    clipNode:setInverted(false);
    ctn:addChild(clipNode)
end
function CompPartnerCardView:getSkillIcon(skillId,_skillLevel)
    skillLevel = _skillLevel or 1
    local  _skillInfo = FuncPartner.getSkillInfo(skillId)
    --图标
    local  _iconPath = FuncRes.iconSkill(_skillInfo.icon)
    local  _iconSprite = cc.Sprite:create(_iconPath)
    _iconSprite:scale(0.4)
    return _iconSprite
end

return CompPartnerCardView;
