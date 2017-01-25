--guan
--2016.5.6
local HonorView = class("HonorView", UIBase);

function HonorView:ctor(winName, worship)
    HonorView.super.ctor(self, winName);
    self._worship = worship;

    self._totalFrame = 0;
    -- dump(self._worship, "----self._worship---");
end

function HonorView:loadUIComplete()
	self:registerEvent();
    self:adjust();
    self:initUI();
end 

function HonorView:adjust()
    FuncCommUI.setViewAlign(self.panel_honor, UIAlignTypes.LeftTop);

    FuncCommUI.setViewAlign(self.UI_yuanbao, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.ctn_lizi3, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.UI_tili, UIAlignTypes.RightTop);
    FuncCommUI.setScale9Align(self.scale9_heidai, UIAlignTypes.MiddleTop, 1, nil);

    FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop);
end

function HonorView:registerEvent()
	HonorView.super.registerEvent();
    self.btn_mobai:setTap(c_func(self.press_btn_mobai, self));
    self.btn_gaojimobai:setTap(c_func(self.press_btn_gaojimobai, self));
    self.btn_back:setTap(c_func(self.press_btn_back, self));

    self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)

end

function HonorView:initUI()
    self.panel_liujiediyi.txt_playername:setString(
        self._worship.name);

    local npc = FuncChar.getCharSkinSpine(
        tostring(self._worship.avatar), self._worship.level, self._worship.treasureNatal);

    npc:playLabel(npc.actionArr.stand);

    self.panel_liujiediyi.ctn_npcNode:addChild(npc);

    --普通奖励 
    local normalNum = FuncWorshipevent.getGainSp(1);
    self.panel_green.txt_2:setString(normalNum);  

    --高级奖励
    local specialNum = FuncWorshipevent.getGainSp(2);
    local needNum = string.split(FuncWorshipevent.getCost(2), ",")[2];

    local haveNum = UserModel:getGold();

    --有足够的元宝
    if tonumber(haveNum) >= tonumber(needNum) then 
        self.panel_yuanbao.mc_2:showFrame(1);
    else 
        self.panel_yuanbao.mc_2:showFrame(2);
    end 
    
    self.panel_yuanbao.mc_2.currentView.txt_2:setString(specialNum);

    local count = CountModel:getHonorCountTime();

    if count == 0 then 
        self.panel_heidai.mc_1:showFrame(1);
    else 
        self.panel_heidai.mc_1:showFrame(2);
    end 

    --气泡 
    self._talkView = WindowsTools:createWindow("ArenaPlayerTalkView");
    self.panel_liujiediyi.ctn_talk:addChild(self._talkView);

    self._talkView:setOpacity(0);
end

function HonorView:updateFrame()
    --[[
        持续7s, 0.5s渐隐出现，0.5s渐隐消失，5s闭嘴
    ]]
    local showFrame = 5 * 30;
    local fadeInFrame = 0.5 * 30;
    local fadeOutFrame = 0.5 * 30;
    local shutUpFrame = 5 * 30;

    if self._totalFrame % 
        (showFrame + fadeInFrame + fadeOutFrame + shutUpFrame) == 0 then
            local fadeInAction = cc.FadeIn:create(0.5);
            local delayAction = cc.DelayTime:create(7);
            local fadeOutAction = cc.FadeOut:create(0.5);
            local sequenceAction = cc.Sequence:create(
                fadeInAction, delayAction, fadeOutAction);
            self._talkView:runAction(sequenceAction);

            local randomInt = RandomControl.getOneRandomInt(6, 1);
            local str = GameConfig.getLanguage(string.format("#tid218%d", randomInt));
            self._talkView:setTalkContent(str);
    end 

    self._totalFrame = self._totalFrame + 1;
end

function HonorView:press_btn_mobai()
    self._isNormalClick = true;
    local count = CountModel:getHonorCountTime();
    echo("----count----", count);

    if count == 1 then 
        local str = GameConfig.getLanguage("worship_already_done");
        WindowControler:showTips({ text = str });
    else 
        --是否超过最大值
        local maxSpNum = FuncDataSetting.getDataByConstantName("HomeCharBuySPMax");
        local sp = UserExtModel:sp();

        if (sp + FuncWorshipevent.getGainSp(2)) > maxSpNum then 
            local str = GameConfig.getLanguageWithSwap("worship_sp_reach_max", 
                maxSpNum);
            WindowControler:showTips({ text = str});
            return
        end
        self.UI_tili:stopChangeEffect();
        HomeServer:worship(1, c_func(self.worshipCallback, self));
        self._isGood = false;

    end 
end

function HonorView:press_btn_gaojimobai()
    self._isNormalClick = false;

    local count = CountModel:getHonorCountTime();
    if count >= 1 then 
        local str = GameConfig.getLanguage("worship_already_done");
        WindowControler:showTips({ text = str });
    else 
        --是否超过最大值
        local maxSpNum = FuncDataSetting.getDataByConstantName("HomeCharBuySPMax");
        local sp = UserExtModel:sp();

        if (sp + FuncWorshipevent.getGainSp(2)) > maxSpNum then 
            local str = GameConfig.getLanguageWithSwap("worship_sp_reach_max", 
                maxSpNum);
            WindowControler:showTips({ text = str});
            return
        end 

        local cost = FuncWorshipevent.getCost(2)
        local costArray = string.split(cost, ",");

        -- echo("----cost---", cost);
        -- dump(costArray, "----costArray---");

        if UserModel:tryCost(costArray[1], tonumber(costArray[2]), true) == true then 
            self.UI_tili:stopChangeEffect();
            HomeServer:worship(2, c_func(self.worshipCallback, self));
        end 

    end 
end

function HonorView:playSoulParticles(beginCtn, teixaoCtn)
    --todo 待替换
    local effectPlist = FuncRes.getParticlePath() .. 'mobailizi.plist'
    local particleNode = cc.ParticleSystemQuad:create(effectPlist);
    particleNode:setTotalParticles(200);
    particleNode:setVisible(false);

    beginCtn:addChild(particleNode)
    particleNode:pos(cc.p(0,0))
   
    local deleteParticle = function()
        beginCtn:removeAllChildren()
    end

    local showSoulNumAddEffect = function()
        self.UI_tili:forceUpdate();
    end

    local xDiff = self.ctn_lizi3:getPositionX() - beginCtn:getPositionX();
    local yDiff = self.ctn_lizi3:getPositionY() - beginCtn:getPositionY();

    local acts = {
        act.callfunc(function ( ... )
            particleNode:setVisible(false);
        end),
        act.delaytime(0.5),
        act.callfunc(function ( ... )
            particleNode:setVisible(true);
        end),
        act.moveby(1, xDiff, yDiff),
        act.callfunc(showSoulNumAddEffect),
        act.delaytime(1.0 / GAMEFRAMERATE * 15),
        act.moveby(1.0 / GAMEFRAMERATE, 500, 500),
        act.delaytime(1),
        act.callfunc(deleteParticle),
    };

    self:createUIArmature("UI_mobai","UI_mobai_xiaohao", teixaoCtn, false);

    particleNode:runAction(act.sequence(unpack(acts)));

end

function HonorView:worshipCallback( event )
    if event.error == nil then 
        if self._isNormalClick == true then 
            self:playSoulParticles(self.ctn_lizi1, self.ctn_texiao1);
        else 
            self:playSoulParticles(self.ctn_lizi2, self.ctn_texiao2);
        end 

        local gainSp = nil;
        if self._isGood == true then 
            gainSp = FuncWorshipevent.getGainSp(2);
        else 
            gainSp = FuncWorshipevent.getGainSp(1);
        end 

        -- FuncCommUI.startRewardView({string.format("5,%d", gainSp)});

        local count = CountModel:getHonorCountTime();

        if count == 0 then 
            self.panel_heidai.mc_1:showFrame(1);
        else 
            self.panel_heidai.mc_1:showFrame(2);
        end
    end 
end

function HonorView:press_btn_back()
    self:startHide();
end

return HonorView;
















