local TipSkillView = class("TipSkillView", InfoTipsBase);

function TipSkillView:ctor(winName,data)
    TipSkillView.super.ctor(self, winName);

    self.skillId = data.skillId
    self.level = data.level or 1
    self.treasure = data.treasure;
    self.treasureId = data.treasureId;
end

function TipSkillView:loadUIComplete()
	self:registerEvent();

    self:updateUI()
end 

function TipSkillView:registerEvent()
	TipSkillView.super.registerEvent();
end

function TipSkillView:updateUI()
	local skillName = FuncTreasure.getValueByKeyFD(self.skillId, self.level,"name")
    skillName = GameConfig.getLanguage(skillName)

    local skillLv = FuncTreasure.getValueByKeyFD(self.skillId, self.level, "level")

    local skillDes = FuncTreasure.getValueByKeyFD(self.skillId, self.level, "des1");

    if FuncTreasure.getValueByKeyFD(self.skillId, self.level, "type") ~= nil then 

        local numIncreaseTable = nil;
        if self.treasure == nil then 
            numIncreaseTable = TreasuresModel:skillIncreaseNums(self.treasureId, self.skillId, self.level);
        else  
            numIncreaseTable = TreasuresModel:skillIncreaseNums(self.treasure:getId(), 
                self.skillId, self.level, self.treasure:state(), self.treasure:level(), self.treasure:star());
        end 

        -- dump(numIncreaseTable, "---numIncreaseTable--");
        if table.length(numIncreaseTable) == 1 then 
            skillDes = GameConfig.getLanguageWithSwap(skillDes, numIncreaseTable[1]);
        else 
            skillDes = GameConfig.getLanguageWithSwap(skillDes, numIncreaseTable[1], numIncreaseTable[2]);
        end 

    else 
        skillDes = GameConfig.getLanguage(skillDes);
    end 


    local skillLvUpDes = FuncTreasure.getValueByKeyFD(self.skillId, self.level,"des2")
    skillLvUpDes = GameConfig.getLanguage(skillLvUpDes)

    skillName = skillName;

    self.txt_1:setString(skillName);
    local strLabelWidth = FuncCommUI.getStringWidth(skillName, 24, "gameFont1")
    echo("--width--", strLabelWidth);

    self.rich_2:setString(skillDes)
    -- self.txt_3:setString(skillLvUpCond)
    self.txt_4:setString(skillLvUpDes);

    self.panel_skills:setPositionX(self.txt_1:getPositionX() + strLabelWidth)
    for i = skillLv, 4 do
        self.panel_skills["panel_st" .. tostring(i + 1)]:setVisible(false);
    end

end

return TipSkillView;

