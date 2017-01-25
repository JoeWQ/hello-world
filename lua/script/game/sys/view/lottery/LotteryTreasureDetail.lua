local LotteryTreasureDetail = class("LotteryTreasureDetail", UIBase);

function LotteryTreasureDetail:ctor(winName,treasureId)
    LotteryTreasureDetail.super.ctor(self, winName);

    self.maxStar = 5
    self.treasureId = treasureId
end

function LotteryTreasureDetail:loadUIComplete()
	self:registerEvent();

    -- 标题
    FuncCommUI.setViewAlign(self.panel_1,UIAlignTypes.LeftTop) 
    FuncCommUI.setViewAlign(self.btn_close,UIAlignTypes.RightTop) 
    
    -- FuncCommUI.setViewAlign(self.panel_2,UIAlignTypes.MiddleTop) 
    -- FuncCommUI.setViewAlign(self.mc_1,UIAlignTypes.MiddleTop) 

    FuncCommUI.setViewAlign(self.panel_npc.ctn_1,UIAlignTypes.RightBottom) 
    FuncCommUI.setViewAlign(self.panel_npc.panel_1,UIAlignTypes.LeftBottom) 

    self:updateUI()
end 

function LotteryTreasureDetail:registerEvent()
	LotteryTreasureDetail.super.registerEvent();
    self.btn_close:setTap(c_func(self.press_btn_close, self));
end

function LotteryTreasureDetail:updateUI()
    local treasurePanel = self.panel_2
    local treasureId = self.treasureId
    local npcPanel = self.panel_npc

	local treasureName = FuncTreasure.getValueByKeyTD(treasureId,"name")
    treasureName = GameConfig.getLanguage(treasureName)

    -- 法宝名字
    treasurePanel.txt_1:setString(treasureName)

    -- 法宝Icon
    local treasureIcon = display.newSprite(FuncRes.iconTreasure(treasureId))
    treasureIcon:setScale(1.0)
    treasurePanel.ctn_1:addChild(treasureIcon)

    -- 位置
    local pos = TreasuresModel:getTreasurePosDesc(treasureId)
    treasurePanel.mc_1:showFrame(pos)

    local star = FuncTreasure.getValueByKeyTD(treasureId,"initStar")
    -- 星级
    treasurePanel.mc_xing:showFrame(star)

    local state = FuncTreasure.getValueByKeyTD(treasureId,"initState")
    -- 底座境界
    treasurePanel.mc_3:showFrame(state)

    local quality = FuncTreasure.getValueByKeyTD(treasureId,"quality")
    -- 品阶
    treasurePanel.mc_zizhi:showFrame(quality)

    -- 法宝描述
    local treasureDes = FuncTreasure.getValueByKeyTD(treasureId,"treasureDes")
    treasureDes = GameConfig.getLanguage(treasureDes)
    npcPanel.panel_1.txt_1:setString(treasureDes)

    -- zhangyg
    -- 法宝相关npc任务icon及name 未设计 暂时写死
    -- npcPanel.txt_2:setString("")
    local npcAnim = FuncRes.npcAnim()
    npcPanel.ctn_1:addChild(npcAnim)

    -- 附带神通
    local skills = TreasuresModel:getAllSkillByIdAfterSort(treasureId)
    local skillsNum = #skills
    self.mc_1:showFrame(skillsNum)

    for i=1,skillsNum do
        local skillId = skills[i].id
        local skillIconName = FuncTreasure.getValueByKeyFD(skillId, 1,"imgBg")
        local skillName = FuncTreasure.getValueByKeyFD(skillId, 1,"name")
        skillName = GameConfig.getLanguage(skillName)

        local skillPanel = self.mc_1.currentView["panel_"..i]
        skillPanel.txt_1:setString(skillName)
         --神通Icon
        local skillIcon = display.newSprite(FuncRes.iconSkill(skillIconName))
        skillIcon:setScale(1.0)
        skillPanel.ctn_1:addChild(skillIcon)

        local params = {
            skillId = skillId,
            level = 1,
            treasureId=treasureId,
        }
        FuncCommUI.regesitShowSkillTipView(skillPanel,params)
    end
end

-- 关闭
function LotteryTreasureDetail:press_btn_close()
    self:startHide()
end


return LotteryTreasureDetail;
