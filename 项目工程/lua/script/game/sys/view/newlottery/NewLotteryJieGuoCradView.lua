-- NewLotteryJieGuoCradView
--三皇抽奖系统
--2016-1-6 11:40
--@Author:wukai

local NewLotteryJieGuoCradView = class("NewLotteryJieGuoCradView", UIBase);

function NewLotteryJieGuoCradView:ctor(winName,reward)
    NewLotteryJieGuoCradView.super.ctor(self, winName)
    self.reward = reward
    -- dump(self.reward,"显示卡牌数据")
end	

function NewLotteryJieGuoCradView:loadUIComplete()
	local a_black = FuncRes.a_black(1136*4,640*4)
    self:addChild(a_black,-10)
    
    self:updataUI(self.reward[2])
    self:PartnerConversionFragment()
    self:registerEvent()
    self:addeffectcard()
end

function NewLotteryJieGuoCradView:registerEvent()
    -- NewLotteryJieGuoCradView.super.registerEvent()
    AudioModel:playSound(MusicConfig.s_scene_luck_large)

end
function NewLotteryJieGuoCradView:addeffectcard()
    -- self:registerEvent()
    -- self.ctn_2
    -- self.panel_1:visible(false)
    -- self:registerEvent()
    -- self:registerEvent()
    local lockAni = self:createUIArmature("UI_chouka_c","UI_chouka_c_wanzhengkapai", self.ctn_2, false,function ()
        self:registClickClose(1, c_func( function()
            self:press_btn_close()
        end , self))
    end)
    lockAni:getBoneDisplay("zi"):getBone("zi"):visible(false)--doByLastFrame( true, true ,function () end)
    lockAni:getBoneDisplay("layer12"):getBone("layer4"):visible(false)
    -- self.ctn_2:addChild(lockAni,3)
    self.panel_1:setPosition(-80,150);
    self.ctn_2:setPosition(self.ctn_2:getPositionX(), -35);
    self.txt_1:setPosition(self.txt_1:getPositionX(),self.txt_1:getPositionY() - 100);
    FuncArmature.changeBoneDisplay(lockAni, "node1", self.panel_1);


end

function NewLotteryJieGuoCradView:updataUI(_partnerId)
    -- _partnerId = 5001
    local partnerCfg = FuncPartner.getPartnerById(_partnerId)
    -----  npc ------
    local ctn = self.panel_1.ctn_ren
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
    local partnerData = FuncPartner.getPartnerById(tostring(_partnerId))
    local quality = 1
    local stat = 1;
    if self.haved then
        quality = partnerData.quality --品质
        stat = partnerData.star --星级
    end
    local name = GameConfig.getLanguage(partnerCfg.name) --姓名
    self.panel_1.panel_1.panel_name.txt_1:setString(name.."+"..quality)

    self.panel_1.mc_kuang:showFrame(quality)  --背景框
    self.panel_1.panel_1.mc_long:showFrame(quality)  --信息背景框

    self.panel_1.panel_1.mc_star:showFrame(stat)
    local _type = partnerCfg.type;--类型
    self.panel_1.panel_1.panel_name.mc_gfj:showFrame(_type)
    local skills = partnerCfg.skill--技能
    local skill1 = self:getSkillIcon(skills[1])
    self.panel_1.panel_1.panel_skill1.ctn_skill:addChild(skill1)
    local skill2 = self:getSkillIcon(skills[2])
    self.panel_1.panel_1.panel_skill2.ctn_skill:addChild(skill2)

end
function NewLotteryJieGuoCradView:getSkillIcon(skillId,_skillLevel)
    skillLevel = _skillLevel or 1
    local  _skillInfo = FuncPartner.getSkillInfo(skillId)
    --图标
    local  _iconPath = FuncRes.iconSkill(_skillInfo.icon)
    local  _iconSprite = cc.Sprite:create(_iconPath)
    _iconSprite:scale(0.4)
    return _iconSprite
end
--添加卡牌立绘 _type1 横向切割方式 _type2 竖向切割方式
-- 参数值 0 不切割 1左切（下） 2右切（上） 3都切
function NewLotteryJieGuoCradView:addCardNpc(ctn,npcSpine,_type1,_type2)
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
--伙伴转化成碎片
function NewLotteryJieGuoCradView:PartnerConversionFragment()
    local PartnerID = self.reward[2]
    -- local PartnerData = PartnerModel:getAllPartner()
    local PartnerData = FuncNewLottery.PartnerData --FuncNewLottery.CachePartnerdata()
        -- dump(self.reward)
        -- dump(PartnerData)
        -- echo("PartnerID==========",PartnerID)
    if PartnerData[tostring(PartnerID)] ~= nil then
        -- sameCardDebris
        self.txt_1:visible(true)
        local Partnerinfo = FuncPartner.getPartnerById(PartnerID)
        local CardDebrisnumber =  Partnerinfo.sameCardDebris --整卡碎片返还
        local itemsinfo = FuncItem.getItemData(PartnerID)
        self.txt_1:setString("已拥有该伙伴,转化为对应碎片x"..CardDebrisnumber)
    else
        self.txt_1:visible(false)
    end
end
function NewLotteryJieGuoCradView:press_btn_close()
    -- dump(self.reward)
    -- FuncNewLottery.PartnerData
    local PartnerID = self.reward[2]
    local PartnerData = FuncNewLottery.PartnerData--FuncPartner.getPartnerById(PartnerID)--PartnerModel:getAllPartner()
        -- dump(self.reward)
        -- dump(PartnerData)
        -- echo("==========PartnerID====",PartnerID)
    if PartnerData[tostring(PartnerID)] == nil then
	   WindowControler:showWindow("NewLotteryShowHeroUI",self.reward[2],true)
       FuncNewLottery.addCachePartnerdata(PartnerID)
    else
        EventControler:dispatchEvent(NewLotteryEvent.RESUME_REWARD_ITEMS)
    end
    -- FuncNewLottery.CachePartnerdata()
    self:startHide()
end

return NewLotteryJieGuoCradView

