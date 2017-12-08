--精炼成功威能变化界面
--guan
--2016.3.3

--废弃

local TreasureReFineSkillUpView = class("TreasureReFineSkillUpView", UIBase);

local originPosMcPositinX = 0;

function TreasureReFineSkillUpView:ctor(winName, treasure, alls, opens, news, ups, upPowerStr)
    TreasureReFineSkillUpView.super.ctor(self, winName);
    self._treasure = treasure;
    self._alls = alls;
    self._news = news;
    self._ups = ups;
    self._opens = opens;
    self._upPowerStr = upPowerStr;
end

function TreasureReFineSkillUpView:loadUIComplete()
	self:registerEvent();
    self:initUI();

    self:delayCall(c_func(self.closeView, self), 2);
end 

function TreasureReFineSkillUpView:closeView()
    self:startHide();
    WindowControler:showWindow("TreasureReFineSuccessView", 
        self._treasure, self._news, self._ups, self._upPowerStr);
end

function TreasureReFineSkillUpView:registerEvent()
	TreasureReFineSkillUpView.super.registerEvent();
    --暂时 点下再下个界面
    self:setTouchedFunc(c_func(self.closeView, self));
    originPosMcPositinX = self.panel_fb1.mc_1:getPositionX();
end

function TreasureReFineSkillUpView:initUI()
    self:initTreasureInfo();
    self:setPower();
    self:initSkill();
end

function TreasureReFineSkillUpView:setPower()
    function setUI(nums)
        local len = table.length(nums);
        self.mc_shuzi:showFrame(len);
        -- dump(nums, "__nums__");
        for k, v in pairs(nums) do
            local mcs = self.mc_shuzi:getCurFrameView();
            mcs["mc_" .. tostring(k)]:showFrame(v + 1);
        end
    end

    local power = self._treasure:getPower();
    local powerValueTable = number.split(power);
    if isWithAnimation ~= true then 
        setUI(powerValueTable);
    else  

    end 
end

function TreasureReFineSkillUpView:initSkill()
    --是否是强化过的异能
    function isUpSkill(id)
        if table.isKeyIn(self._ups, id) or table.isKeyIn(self._news, id) then 
            return true;
        else 
            return false;
        end
    end

    local allSkills = self._alls;
    self.mc_st1:showFrame(table.length(allSkills));

    local i = 1;
    for _, value in pairs(allSkills) do
        local id = value.id;
        local maxLvl = value.level;

        local stonePanel = self.mc_st1:getCurFrameView()["panel_" .. tostring(i)];
        --icon
        local lvl = self._treasure:getSkillLvl(id);
        stonePanel.panel_1.ctn_1:removeAllChildren();
        local sprite = FuncTreasure.getSkillSprite(id, lvl);
        stonePanel.panel_1.ctn_1:addChild(sprite);
        sprite:size(stonePanel.panel_1.ctn_1.ctnWidth, 
            stonePanel.panel_1.ctn_1.ctnHeight); 

        if isUpSkill(tonumber(id)) == true then 
            self:createUIArmature("UI_xiangqing","UI_xiangqing_jihuo", stonePanel.ctn_2, true);
            AudioModel:playSound("s_treasure_shentongup");
        end 

        --名字
        stonePanel.panel_2.txt_1:setString(FuncTreasure.getSkillNameById(id, 1));

        if self._treasure:isSkillActive(id) == false then 
            --置灰
            FilterTools.setGrayFilter(sprite);
        else 
            FilterTools.clearFilter(sprite);
        end  
        local maxFrame = stonePanel.panel_2.mc_st1:getTotalFrameNum();

        stonePanel.panel_2.mc_st1:showFrame(maxLvl);

        local lvl = self._treasure:getSkillLvl(id);

        for j = 1, maxLvl do
            if lvl >= j then --绿豆
                --新开的
                if lvl == j and isUpSkill(id) == true then 
                    --播特效 
                    -- stonePanel.panel_2.mc_st1:getCurFrameView()["mc_" .. tostring(j)]:showFrame(3);
                    -- local ctn = stonePanel.panel_2.mc_st1:getCurFrameView()["ctn_" .. tostring(j)];
                    -- self:createUIArmature(nil,"ui_xiangqing_gouyu", ctn, false, function ()
                    --     stonePanel.panel_2.mc_st1:getCurFrameView()["mc_" .. tostring(j)]:showFrame(1);
                    -- end);

                    stonePanel.panel_2.mc_st1:getCurFrameView()["mc_" .. tostring(j)]:showFrame(1);
                else 
                    stonePanel.panel_2.mc_st1:getCurFrameView()["mc_" .. tostring(j)]:showFrame(1);
                end 
            elseif self._treasure:isShowEnhanceArrow(id) == true and (j == (lvl + 1)) then 
                stonePanel.panel_2.mc_st1:getCurFrameView()["mc_" .. tostring(j)]:showFrame(2);
            else 
                stonePanel.panel_2.mc_st1:getCurFrameView()["mc_" .. tostring(j)]:showFrame(3);
            end 
        end

        i = i + 1;
    end
end

function TreasureReFineSkillUpView:initTreasureInfo()
    self.panel_fb1.mc_dingwei:showFrame(2);
    self.panel_fb1.mc_dingwei.currentView.txt_1:setString(
        FuncTreasure.getLabel3(self._treasure:getId()));

    self.panel_fb1.txt_3:setString(self._treasure:level());
    
    --name 
    local nameStr = self._treasure:getName();
    self.panel_fb1.txt_1:setString(nameStr);
    
    --前后 图片 底框
    local id = self._treasure:getId();

    echo("----initTreasureInfo---");
    local nameLength = string.len(nameStr) / 3;

    echo("nameLength " .. tostring(nameLength));
    self.panel_fb1.mc_1:setPositionX(originPosMcPositinX - nameLength * 25);

    local posIndex = self._treasure:getPosIndex();
    self.panel_fb1.mc_1:showFrame(posIndex);


    local state = self._treasure:state();
    self.panel_fb1.mc_3:showFrame(state);

    -- todo 法宝图标
    local iconPath = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, id);
    local spriteTreasureIcon = display.newSprite(iconPath); 
    self.panel_fb1.ctn_1:removeAllChildren();
    
    spriteTreasureIcon:size(self.panel_fb1.ctn_1.ctnWidth, 
        self.panel_fb1.ctn_1.ctnHeight);
    self.panel_fb1.ctn_1:addChild(spriteTreasureIcon);

    --等级
    self.panel_fb1.txt_3:setString(GameConfig.getLanguageWithSwap(
        "treasure_lvl", self._treasure:level()));

    --星级
    local star = self._treasure:star();
    for i = 1, 5 do
        local mc = self.panel_fb1["mc_bigxing" .. tostring(i)];
        if star >= i then 
            mc:showFrame(2);
        else 
            mc:showFrame(1);
        end 
    end

    --什么品 
    local quality = FuncTreasure.getValueByKeyTD(id, "quality");
    if quality >= 6 then 
        quality = 5;
    end 
    self.panel_fb1.mc_2:showFrame(quality);
end

function TreasureReFineSkillUpView:updateUI()
	
end


return TreasureReFineSkillUpView;












