local LotteryShowTreasure = class("LotteryShowTreasure", UIBase);

function LotteryShowTreasure:ctor(winName,treasureId)
    LotteryShowTreasure.super.ctor(self, winName);
    echo("treasureId",treasureId,"=-=========")
    self.treasureId = treasureId

    local quality =  FuncTreasure.getValueByKeyTD(treasureId,"quality")
    -- echo("当前的法宝")
    -- echo(quality,"========================= 传入的品质")
    -- echo("当前的法宝")
    self.quality = quality
end

function LotteryShowTreasure:loadUIComplete()
    self:registerEvent();
    
    self:initView()
    self:updateUI()
    self:hideAllView()
    self:initAnim()
end 

function LotteryShowTreasure:registerEvent()
    LotteryShowTreasure.super.registerEvent();
end

function LotteryShowTreasure:initView()

    local img = "lottery_bg_fabao"
    if self.quality<=2 then
          img="lottery_bg_lan"
    end
    --echo("img is : ",img,"========使用的背景类型")
    --根据法宝的品质修改背景
     display.addImageAsync(FuncRes.iconBg(img), function ( ... )
            --echo("加载图片--90909-09-9-090-0-")
            display.newSprite(FuncRes.iconBg(img), GameVars.UIbgOffsetX, GameVars.UIbgOffsetY):anchor(0,1)
                     :addto(self,-2);
        end)
    -- FuncCommUI.addBlackBg(self._root)
    FuncCommUI.setViewAlign(self.panel_1,UIAlignTypes.Left)
    FuncCommUI.setViewAlign(self.panel_4,UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.txt_1,UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.panel_title,UIAlignTypes.MiddleTop)
    
    -- 法宝信息部分
    self.treasurePanel = self.panel_3
    -- 神通部分
    self.skillPanel = self.panel_4
    -- 定位部分
    self.locationPanel = self.panel_1

    -- 法宝描述及确定按钮
    self.confirmBtn = self.btn_1

    -- 是否拥有该法宝
    self.hasTreasure = false

    -- 如果抽到了不存在的法宝
    if TreasuresModel:hasTreasureInCache(self.treasureId) then
        self.hasTreasure = true

        local playGetTreasureSound = function()
             AudioModel:playSound("s_lottery_getTreasure")
        end
        self:delayCall(c_func(playGetTreasureSound), 0.5)
    end

    -- zhangyg test
    -- self.hasTreasure = false
end

function LotteryShowTreasure:hideAllView()
    self.treasurePanel:setVisible(false)
    self.skillPanel:setVisible(false)
    self.locationPanel:setVisible(false)

    self.panel_title:setVisible(false)
end

function LotteryShowTreasure:initAnim()
    --加载抽卡特效
    -- FuncArmature.loadOneArmatureTexture("UI_lottery", nil, true)
    -- FuncArmature.loadOneArmatureTexture("UI_lottery_chouka", nil, true)

    local treasureAnim = self:createUIArmature("UI_lottery_chouka","UI_lottery_chouka_wancheng",self.ctn_donghua, false, GameVars.emptyFunc)
    treasureAnim:pos(0,50)
    treasureAnim:startPlay(true)

    -- 法宝icon换装
    -- local iconCtn = UIBaseDef:cloneOneView(self.treasurePanel.ctn_1)
    self.treasurePanel.ctn_1:setVisible(false)
    local treasureIcon = display.newSprite(FuncRes.iconTreasure(self.treasureId))
    treasureIcon:pos(0,-60)
    treasureIcon:setScale(1.7)
    FuncArmature.changeBoneDisplay(treasureAnim,"node1",treasureIcon)

    -- 法宝icon换装
    local iconBoneAnim = treasureAnim:getBoneDisplay("node4")
    iconBoneAnim:pos(0,0)
    local treasureIcon2 = display.newSprite(FuncRes.iconTreasure(self.treasureId))
    treasureIcon2:pos(0,0)
    treasureIcon2:setScale(0.75)
    FuncArmature.changeBoneDisplay(iconBoneAnim,"layer6",treasureIcon2)

    -- 法宝资质换装
    self.treasurePanel.mc_zizhi:pos(-30,20)
    FuncArmature.changeBoneDisplay(treasureAnim,"node2",self.treasurePanel.mc_zizhi)

    -- 法宝名字换装
    self.treasurePanel.panel_title:setAnchorPoint(cc.p(0,0))
    self.treasurePanel.panel_title:pos(52,2)
    FuncArmature.changeBoneDisplay(treasureAnim,"node3",self.treasurePanel.panel_title)

    -- 停止播放恭喜获得
    local titleTipAnim = treasureAnim:getBoneDisplay("zi")
    local titleTipAnim2 = treasureAnim:getBoneDisplay("layer12")

    local stopTreasureAnim = function()
        -- FuncArmature.playOrPauseArmature(treasureAnim,false)
        treasureAnim:getAnimation():pause()
        titleTipAnim:pause()
        titleTipAnim2:pause()
            
        local delay = 0
        if self.hasTreasure then
            delay = 0
        else
            delay = 0.8
        end
        self:delayCall(c_func(self.playClickCloseAnim,self), delay)
    end

    local getNewTreasure = function()
        -- 第一次获取该法宝，播放法宝说明动画
       self:doTreasureTipAnim()
       self:playCharUseTreasureAnim()
       self:showStarAnim(false)
    end

    treasureAnim:registerFrameEventCallFunc(30,1,c_func(self.playPosDesAnim,self))
    treasureAnim:registerFrameEventCallFunc(30,1,c_func(self.playStarAnim,self))
    
    if self.hasTreasure then
        treasureAnim:registerFrameEventCallFunc(65,1,c_func(stopTreasureAnim,self))
        --测试按钮
        --treasureAnim:registerFrameEventCallFunc(75,1,c_func(getNewTreasure,self))
    else
        treasureAnim:registerFrameEventCallFunc(75,1,c_func(self.hideLocationMc,self))
        treasureAnim:registerFrameEventCallFunc(75,1,c_func(getNewTreasure,self))
        treasureAnim:registerFrameEventCallFunc(treasureAnim.totalFrame,1,c_func(stopTreasureAnim,self))
    end
end

-- 播放恭喜获得标题动画
function LotteryShowTreasure:playTitleAnim()
    self.panel_title:setVisible(true)
    self.panel_title:opacity(0)
    local alphaAction = act.fadein(0.6)
    self.panel_title:stopAllActions()
    self.panel_title:runAction(
        cc.Sequence:create(alphaAction)
    )
end

-- 播放法宝位置动画
function LotteryShowTreasure:playPosDesAnim()
    local treasurePanel = self.treasurePanel
    treasurePanel:setVisible(true)
    treasurePanel.mc_1:opacity(0)
    local alphaAction = act.fadein(0.2)

    treasurePanel.mc_1:stopAllActions()
    treasurePanel.mc_1:runAction(
        cc.Sequence:create(alphaAction)
    )
end

-- 是否显示星级
function LotteryShowTreasure:showStarAnim(visible)
    local mcStar = self.treasurePanel.panel_dizuo.mc_xing
    mcStar:setVisible(visible)
end

-- 播放恭喜获得标题动画
function LotteryShowTreasure:playStarAnim()
    local star = self.star

    local mcStar = self.treasurePanel.panel_dizuo.mc_xing
    local x,y = mcStar:getPosition()
    mcStar:pos(x+15,y+30)

    local showStar = function(panelStar,panelCtn)
        panelStar:setVisible(true)

        local starAnim = self:createUIArmature("UI_lottery_chouka","UI_lottery_chouka_xingxing",panelCtn, false,GameVars.emptyFunc )
        starAnim:pos(0,3)
        starAnim:startPlay(false)
    end

    local showStar2 = function(panelCtn)
        local starAnim = self:createUIArmature("UI_lottery_chouka","UI_lottery_chouka_xingxing2",panelCtn, false,GameVars.emptyFunc )
        starAnim:pos(1,3)
        starAnim:startPlay(true)
    end

    for i=1,star do
        local delay = i*3 / GAMEFRAMERATE
        local panelStar = mcStar.currentView["panel_xing" .. i]
        panelStar:setVisible(false)
        local panelCtn = mcStar.currentView["ctn_star" .. i]

        self:delayCall(c_func(showStar,panelStar,panelCtn), delay)

        local delay2 = (star+1)*3 / GAMEFRAMERATE
        self:delayCall(c_func(showStar2,panelCtn), delay2)
    end
end

-- 播放主角使用法宝动画
function LotteryShowTreasure:playCharUseTreasureAnim()
    echo("播放主角使用法宝动画")
    local treasureId = self.treasureId
    --local treasureId = "322"

    if not self.charView then
        self.charView = UserModel:getCharOnTreasure(treasureId, true)
        self.charView:setScale(1.7)
        self.charView:pos(0,-140)
        self.ctn_donghua:addChild(self.charView)

        FuncChar.playNextAction(self.charView,c_func(self.playCharUseTreasureAnim,self))
    else
        local playAgain = function()
            FuncChar.playNextAction(self.charView,c_func(self.playCharUseTreasureAnim,self))
        end
        
        self:delayCall(c_func(playAgain), 1)
    end
end

-- 播放点击任意关闭动画
function LotteryShowTreasure:playClickCloseAnim()
    echo("playClickCloseAnimplayClickCloseAnim")
    
    local tipTxt = self.txt_1
    tipTxt:setVisible(true)
    tipTxt:opacity(0)

    local delay = 0.2
    local alphaAction = act.fadein(delay)
    local appearAnim = cc.Spawn:create(alphaAction) 
    tipTxt:stopAllActions()
    tipTxt:runAction(
        cc.Sequence:create(appearAnim)
    )

    local clickClose = function()
        self:registClickClose()
    end

    self:delayCall(c_func(clickClose), delay)
end

-- 法宝说明动画，第一次获取该法宝时播放
function LotteryShowTreasure:doTreasureTipAnim()
    --echo("出现法宝左右内容---")
    local skillPanel = self.skillPanel          --skillPanel就是左侧的panel_1
    local locationPanel = self.locationPanel    --locationPanel就是右侧的panel_4
    local moveDis = 300

    local frame = 1
    if self.quality<=2 then
        frame = 2
    end
    --echo(frame,"quality","============================展示那个frame")
    -- 神通动作
    local doSkillPanelAnim = function()
        skillPanel.mc_1:showFrame(frame)
        local skillPanelX,skillPanelY = skillPanel:getPosition()
        skillPanel:pos(skillPanelX + moveDis,skillPanelY)
        skillPanel:opacity(0)
        skillPanel:setVisible(true)
        
        local alphaAction = act.fadein(0.6)
        local moveAction = act.moveto(0.6,skillPanelX,skillPanelY)

        local appearAnim = cc.Spawn:create(alphaAction,moveAction) 

        skillPanel:stopAllActions()
        skillPanel:runAction(
            cc.Sequence:create(appearAnim)
        )
    end

    -- 定位动作
    local doLocationPanelAnim = function()
        locationPanel.mc_1:showFrame(frame)
        local posPanelX,posPanelY = locationPanel:getPosition()
        locationPanel:pos(posPanelX - moveDis,posPanelY)
        locationPanel:opacity(0)
        locationPanel:setVisible(true)
        
        
        local alphaAction = act.fadein(0.6)
        local moveAction = act.moveto(0.6,posPanelX,posPanelY)

        local appearAnim = cc.Spawn:create(alphaAction,moveAction) 

        locationPanel:stopAllActions()
        locationPanel:runAction(
            cc.Sequence:create(appearAnim)
        )
    end

    self:delayCall(c_func(doSkillPanelAnim), 0)
    self:delayCall(c_func(doLocationPanelAnim), 0)
end

-- 根据法宝名字长度修改位置坐标
function LotteryShowTreasure:setPosDesXByNameLength(view,treasureName)
    local length = string.len(treasureName)
    local x,y = view:getPosition()
    local maxLength = 15
    local offsetX = (maxLength - length) / 3 * 20

    --view:pos(x+offsetX+5+30,y + 46)
    view:pos(x+offsetX-14,y + 46)
end

-- 隐藏位置
function LotteryShowTreasure:hideLocationMc()
    local locationMc = self.treasurePanel.mc_1
    locationMc:setVisible(false)
end

function LotteryShowTreasure:updateUI()
    -- zhangyg 隐藏恭喜获得
    self.panel_title:setVisible(false)
    -- 隐藏点击任意位置关闭
    self.txt_1:setVisible(false)

    -- 法宝相关信息
    local treasurePanel = self.treasurePanel

    local treasureId = self.treasureId
    local treasureName = FuncTreasure.getValueByKeyTD(treasureId,"name")
    treasureName = GameConfig.getLanguage(treasureName)
    -- 法宝名称
    treasurePanel.panel_title.txt_1:setString(treasureName)

    -- 位置
    local pos = TreasuresModel:getTreasurePosDesc(treasureId)
    treasurePanel.mc_1:showFrame(pos)
    self:setPosDesXByNameLength(treasurePanel.mc_1,treasureName)

    -- 法宝资质
    local quality = FuncTreasure.getValueByKeyTD(treasureId,"quality")
    treasurePanel.mc_zizhi:showFrame(quality)

    -- 法宝Icon
    local treasureIcon = display.newSprite(FuncRes.iconTreasure(treasureId))
    treasureIcon:setScale(1)
    treasurePanel.ctn_1:addChild(treasureIcon)

    -- 法宝星级
    local maxStar = 5
    local star = FuncTreasure.getValueByKeyTD(treasureId,"initStar")
    self.star = star

    if star <=0 then
        star = 1
        echoError(treasureId," star=",star)
    elseif star >= maxStar then
        star = maxStar
        echoError(treasureId," star=",star)
    end
    -- 星级
    treasurePanel.panel_dizuo.mc_xing:showFrame(star)
    for i=1,star do
        treasurePanel.panel_dizuo.mc_xing.currentView["panel_xing"..i]:setVisible(false)
    end

    -- 定位相关
    local locationDes = FuncTreasure.getValueByKeyTD(treasureId,"location")
    locationDes = GameConfig.getLanguage(locationDes)
    local locationPanel =  self.locationPanel
    locationPanel.txt_1:setString(locationDes)

    -- 神通相关信息
    local skillPanel = self.skillPanel
    -- 附带神通
    local skills = TreasuresModel:getAllSkillByIdAfterSort(treasureId)
    local skillsNum = #skills
    if skills == nil or skills[1] == nil then
        echoError("treasureId=",treasureId," 没有配置神通")
    end
    
    local skillId = skills[1].id
    local skillIconName = FuncTreasure.getValueByKeyFD(skillId, 1,"imgBg")
    local skillName = FuncTreasure.getValueByKeyFD(skillId, 1,"name")
    skillName = GameConfig.getLanguage(skillName)

    local skillDes = FuncTreasure.getValueByKeyFD(skillId, 1,"des1")
    skillDes = GameConfig.getLanguage(skillDes)

    -- 神通名称
    skillPanel.txt_1:setString(skillName)

    -- 神通icon
    local skillIcon = display.newSprite(FuncRes.iconSkill(skillIconName))
    skillPanel.panel_1.ctn_1:removeAllChildren()
    skillPanel.panel_1.ctn_1:addChild(skillIcon)
end

function LotteryShowTreasure:startHide()
    LotteryShowTreasure.super.startHide(self)

    -- 释放资源
    if self.charView then
        FuncChar.deleteCharOnTreasure(self.charView)
    end
    EventControler:dispatchEvent(LotteryEvent.LOTTERYEVENT_CLOSE_TREASURE_VIEW)
end

return LotteryShowTreasure;
