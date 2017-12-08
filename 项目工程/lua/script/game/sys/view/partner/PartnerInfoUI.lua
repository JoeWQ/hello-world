local PartnerInfoUI = class("PartnerInfoUI", UIBase)

function PartnerInfoUI:ctor(winName,id)
	PartnerInfoUI.super.ctor(self, winName)
    self.partnerId = id
    self.haved = PartnerModel:isHavedPatnner(id)
end
function PartnerInfoUI:loadUIComplete()
	self:setAlignment()
	self:registerEvent()
    self:updataUI(self.partnerId);
    self:refreshSwitchBtn()  
end


function PartnerInfoUI:setAlignment()
end

function PartnerInfoUI:registerEvent()
    PartnerInfoUI.super.registerEvent(); 
    self.panel_2.btn_1:setTap(c_func(self.switchPartner,self,1))
    self.panel_2.btn_2:setTap(c_func(self.switchPartner,self,2))
    self.btn_1:setTap(c_func(function()
        self:startHide()
    end,self))
end

function PartnerInfoUI:switchPartner(_type)
    local id = self:getSwitchPartnerId(_type);
    if id then 
        echo("--------------- 此时伙伴ID = "..id) 
        self.partnerId = id
        self:updataUI(id)
    end  
    self:refreshSwitchBtn()   
end
--刷新切换按钮
function PartnerInfoUI:refreshSwitchBtn()
    -- 左
    local id = self:getSwitchPartnerId(1);
    if id then
        self.panel_2.btn_1:visible(true)
    else
        self.panel_2.btn_1:visible(false)
    end
    -- 右
    local id = self:getSwitchPartnerId(2);
    if id then
        self.panel_2.btn_2:visible(true)
    else
        self.panel_2.btn_2:visible(false)
    end
end
function PartnerInfoUI:getSwitchPartnerId(_type)
    local partnerIndexDatas = {}
    local num = 0
    if self.haved then
        for i,v in pairs(PartnerModel:getAllPartner()) do
            table.insert(partnerIndexDatas,v)
            num = num + 1
        end
    else
        local partnerDataCfg = FuncPartner.getAllPartner()
        for i,v in pairs(partnerDataCfg) do
            if PartnerModel:getPartnerDataById(tostring(v.id)) == nil then
                table.insert(partnerIndexDatas,v)
                num = num + 1
            end
        end
    end
   
    local currentIndex = 0
    for i,v in pairs(partnerIndexDatas) do
        if tostring(v.id) == tostring(self.partnerId) then
            currentIndex = i
        end
    end
    if _type == 1 then
        if (currentIndex - 1) > 0 then
            return partnerIndexDatas[currentIndex - 1].id
        end
    elseif _type == 2 then
        if (currentIndex + 1) <= num then
            return partnerIndexDatas[currentIndex + 1].id
        end
    end

    return nil
end
function PartnerInfoUI:updataUI(_partnerId)
    -- 伙伴卡牌信息
    self.panel_2.UI_comp_card:updataUI(_partnerId)
    ----- 伙伴信息 ------
    self:initPartnerInfo()
end

function PartnerInfoUI:initPartnerInfo()
    self.panel_2.panel_1:visible(false)
    self.panel_2.panel_2:visible(false)
    self.panel_2.panel_3:visible(false)
    self.panel_2.panel_4:visible(false)
    local createFunc = function ( itemData )
		local view = UIBaseDef:cloneOneView(self.panel_2["panel_"..itemData])
		self:updateItem(view, itemData)
		return view
    end
    local updateFunc = function (_item,_view)
        self:updateItem(_view,_item)
    end
	local _scrollParams = {
			
            {
				data = {1},
				createFunc= createFunc,
                updateFunc = updateFunc,
				perFrame = 1,
				offsetX =0,
				offsetY =0,
				itemRect = {x=0,y= -212,width=368,height = 212},
				widthGap = 0,
                heightGap = 0,
                perNums = 1,
			},
            {
				data = {2},
				createFunc= createFunc,
                updateFunc = updateFunc,
				perFrame = 1,
				offsetX =0,
				offsetY =0,
				itemRect = {x=0,y= -75,width=368,height = 75},
				widthGap = 0,
                heightGap = 0,
                perNums = 1,
			},
            {
				data = {3},
				createFunc= createFunc,
                updateFunc = updateFunc,
				perFrame = 1,
				offsetX =0,
				offsetY =0,
				itemRect = {x=0,y= -384,width=368,height = 384},
				widthGap = 0,
                heightGap = 0,
                perNums = 1,
			},
            {
				data = {4},
				createFunc= createFunc,
                updateFunc = updateFunc,
				perFrame = 1,
				offsetX =0,
				offsetY =0,
				itemRect = {x=0,y= -158,width=368,height = 158},
				widthGap = 0,
                heightGap = 0,
                perNums = 1,
			}
		}
    self.panel_2.scroll_1:refreshCellView( 1 )
    self.panel_2.scroll_1:styleFill(_scrollParams);
	self.panel_2.scroll_1:hideDragBar()
end
function PartnerInfoUI:updateItem(view, itemData)
    local partnerData = FuncPartner.getPartnerById(self.partnerId);
    if itemData == 1 then --属性
        self:initProperty(view)
    elseif itemData == 2 then --定位
        view.txt_1:setString(GameConfig.getLanguage(partnerData.charaCteristic))
    elseif itemData == 3 then --技能
        local skills = partnerData.skill
        for i,v in pairs(skills) do
            local isUnlock , skillLevel =  PartnerModel:isUnlockSkillById(self.partnerId,v)
            self:initSkill(view["panel_"..(i+1)],v,skillLevel,isUnlock)
        end
    elseif itemData == 4 then --描述
        view.rich_1:setString(GameConfig.getLanguage(partnerData.describe))
    end
    
end
function PartnerInfoUI:getSkillIcon(skillId,_skillLevel)
    skillLevel = _skillLevel or 1
    local  _skillInfo = FuncPartner.getSkillInfo(skillId)
    --图标
    local  _iconPath = FuncRes.iconSkill(_skillInfo.icon)
    local  _iconSprite = cc.Sprite:create(_iconPath)
    _iconSprite:scale(0.4)
    return _iconSprite
end
function PartnerInfoUI:initSkill(view,skillId,skillLevel,isUnlock)
    if skillLevel == 0 then
        skillLevel = 1
    end
    local  _skillInfo = FuncPartner.getSkillInfo(skillId)
    local  _iconPath = FuncRes.iconSkill(_skillInfo.icon)
    local  _iconSprite = cc.Sprite:create(_iconPath)
    _iconSprite:scale(0.7)
    view.ctn_1:addChild(_iconSprite)
    --技能名称
    view.txt_1:setString(GameConfig.getLanguage(_skillInfo.name))
    
    -- 判断是否解锁
    if isUnlock then
        --技能等级
        view .txt_3:setString("等级:"..skillLevel.."级")
    else
        --解锁条件
        view.txt_3:setString("未解锁")
    end
end
function PartnerInfoUI:initProperty(view)
    -- 属性vec

    local t1 = os.clock()

    local propertyVec1 = {};
    local propertyVec2 = {};



    local partnerData = PartnerModel:getPartnerDataById(tostring(self.partnerId))
    
    local function initPropertyF(propertyData)
        for i,v in pairs(propertyData) do
            if self:isInitProperty(v.key) then
                table.insert(propertyVec1,v)
            else
                table.insert(propertyVec2,v)
            end
        end
    end;

        --初始属性
    if self.haved then
        local data = FuncPartner.getPartnerAttr(partnerData)
        data = FuncBattleBase.formatAttribute( data )
        initPropertyF(data)
        self:showProperty(view,1,partnerData,propertyVec1)
    else
        local partnerInitData = FuncPartner.getPartnerById(self.partnerId);
        local data1 = FuncBattleBase.countFinalAttr( partnerInitData.initAttr )
        data1 = FuncBattleBase.formatAttribute( data1 )
        initPropertyF(data1)
    end
    
    local currentStage = 1 -- 当前显示详情状态
    self:showProperty(view,1,partnerData,propertyVec1)
    view.btn_1:setTap(c_func(function ()
        if currentStage == 1 then
            currentStage = 2
            view.btn_1:getUpPanel().mc_1:showFrame(2)
            self:showProperty(view,2,partnerData,propertyVec2)
        elseif currentStage == 2 then
            currentStage = 1
            view.btn_1:getUpPanel().mc_1:showFrame(1)
            self:showProperty(view,1,partnerData,propertyVec1)
        end
    end,self))
    

--    --初始属性
--    local partnerInitData = FuncPartner.getPartnerById(self.partnerId);
--    initPropertyF(partnerInitData.initAttr)
--    local data1 = FuncBattleBase.countFinalAttr( partnerInitData.initAttr )
--    dump(data1,"基础属性")

--    if self.haved then
--        --升星属性 
--        local starData = FuncPartner.getStarsByPartnerId(self.partnerId)
--        local starCinfig = starData[tostring(partnerData.star)]
--        -- 星级加成 算出来
--        local starJC = starCinfig.attr
--        for i,v in pairs(starJC) do
--            v.value = v.value * partnerData.level
--        end
--        -- 小阶段加成 累加
--        local starPointJCTb = {};
--        local starLevel = partnerData.star - 1
--        while starLevel > 0 do
--            local cinfig = starData[tostring(starLevel)]
--            local data = FuncBattleBase.formatAttribute( cinfig.stage )
--            for i,v in pairs(data) do
--                table.insert(starPointJCTb,v)
--            end
--            starLevel = starLevel - 1
--        end
--        local starPointJC = starCinfig.stage
--        for i,v in pairs(starPointJC) do
--            if partnerData.starPoint >= i then
--                table.insert(starPointJCTb,v)
--            end
--        end
--        local data2 = FuncBattleBase.countFinalAttr( starPointJCTb,starJC )
--        dump(data2,"升星属性")

--        --升品属性
--        local qualityData = FuncPartner.getPartnerQuality(self.partnerId)
--        local qualityJC = {}
--        local _quality = partnerData.quality
--        while _quality > 0 do
--            local qualityProerty = qualityData[tostring(_quality)]
--            for i,v in pairs(qualityProerty.attr) do
--                table.insert(qualityJC,v)
--            end
--            _quality = _quality - 1
--        end
--        --道具加成
--        local positions = {}
--        local value = partnerData.position or 0
--        while value ~= 0 do
--            local num = value % 2;
--            table.insert(positions, 1, num);
--            value = math.floor(value / 2);
--        end
--        local function zhuangbei(index)
--            if positions[index] and positions[index] == 1 then
--                return true 
--            end
--            return false
--        end;
--        local items = qualityData[tostring(partnerData.quality)].pellet
--        for i,v in pairs(items) do
--            if zhuangbei(i) then
--                local data = FuncPartner.getConbineResById(v).attr
--                for m,n in pairs(data) do
--                    table.insert(qualityJC,n)
--                end
--            end
--        end
--        local data3 = FuncBattleBase.countFinalAttr( qualityJC )
--        dump(data3,"品质属性")
----        initPropertyF(qualityProerty.num)

--        --技能属性
--        local skillJC = {}
--        for i,v in pairs(partnerData.skills) do
--            local  _skillInfo = FuncPartner.getSkillInfo(i)
--            if skillInfo.initAttr then
--                for i,v in pairs(_skillInfo.initAttr) do
--                    table.insert(skillJC,v)
--                end
--            end
--            if _skillInfo.attr then
--                for i,v in pairs(_skillInfo.attr) do
--                    v.value = v.value * partnerData.level
--                    table.insert(skillJC,v)
--                end
--            end
--        end
--        local data4 = FuncBattleBase.countFinalAttr( skillJC )
--        dump(data4,"技能属性")
----        --仙魂属性
----        for i,v in pairs(partnerConfigData.xianhun) do
----            local isUnlock , soulData =  PartnerModel:isUnlockSoulById(self.partnerId,v)
----            if isUnlock then
----                local  soulInfo = FuncPartner.getSoulInfo(v)
----                soulInfo = soulInfo[tostring(soulData.level)]
----                initPropertyF(soulInfo.num)
----            end
----        end
--    end




    echo(os.clock() - t1,"-------- 初始 属性 消耗时间");
end
function PartnerInfoUI:showProperty(view,_type,partnerData,data)
    for i = 2,9 do
        view["panel_"..i]:visible(false)
    end
    local partnerConfigData = FuncPartner.getPartnerById(self.partnerId);
    local buteData = FuncChar.getAttributeData()
--    local buteName = GameConfig.getLanguage(buteData[strVec[1]].name)
    if tonumber(_type) == 1 then -- 显示基础属性 等级 品质等
        -- 添加 等级
        view.panel_2:visible(true)
        view.panel_2.txt_1:setString("等级：")
        if self.haved then
            view.panel_2.txt_2:setString(partnerData.level)
        else
            view.panel_2.txt_2:setString(1)
        end
        -- 添加 品质
        view.panel_3:visible(true)
        view.panel_3.txt_1:setString("资质：")
        view.panel_3.txt_2:setString(partnerConfigData.aptitude)
        -- 添加基础属性
        local index = 0
        for i,v in pairs(data) do
            index = index + 1
            if index < 10 then
                view["panel_"..(index+3)]:visible(true)
                view["panel_"..(index+3)].txt_1:setString(FuncBattleBase.getAttributeName( v.key )..":")
                view["panel_"..(index+3)].txt_2:setString(v.value)
            else
                echoWarn("没有显示的属性 : "..FuncBattleBase.getAttributeName( v.key ))
            end
        end
    else
         -- 添加属性
        local index = 1
        for i,v in pairs(data) do
            index = index + 1
            if index < 10 then
                view["panel_"..(index)]:visible(true)
                view["panel_"..(index)].txt_1:setString(FuncBattleBase.getAttributeName( v.key )..":")
                view["panel_"..(index)].txt_2:setString(v.value)
            else
                echoWarn("没有显示的属性 : "..FuncBattleBase.getAttributeName( v.key ))
            end
        end
    end

    if self.haved then
        view.mc_power:showFrame(1)
        local partnerData = PartnerModel:getPartnerDataById(tostring(self.partnerId));
        local _ability = FuncPartner.getPartnerAvatar(partnerData)
        view.mc_power.currentView.panel_1.UI_comp_rollingNumber:setPower(_ability)
    else
        view.mc_power:showFrame(2)
        local needFrag = partnerConfigData.tity;
        local haveFrag = ItemsModel:getItemNumById(self.partnerId)
        view.mc_power.currentView.panel_progress.txt_1:setString(haveFrag .. "/"..needFrag)
        view.mc_power.currentView.panel_progress.mc_progress:showFrame(1)
        view.mc_power.currentView.panel_progress.mc_progress.currentView.progress_1:setPercent(haveFrag/needFrag*100)
    end
end
-- 是否会放到初始属性里 -- 这里 先这样写死
function PartnerInfoUI:isInitProperty(_type) 
    if tonumber(_type) == 2 then
        return true
    elseif tonumber(_type) == 10 then
        return true
    elseif tonumber(_type) == 11 then
        return true
    elseif tonumber(_type) == 12 then
        return true
    else
        return false
    end
end
--
function clippingPartnerCard(args)
--    local clipNode = cc.ClippingNode:create()
--    local stencilNode = cc.LayerColor:create(cc.c4b(0, 255, 0, 200), 500, 340);
--    clipNode:setStencil(stencilNode)
--    clipNode:addChild(npcSpine)
--    clipNode:setInverted(false)
--    clipNode:anchor(0.5,0.5)
--    ctnnpc:addChild(clipNode)
end

return PartnerInfoUI
