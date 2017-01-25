local BattleLose = class("BattleLose", UIBase);

--[[
    self.panel_1,
    self.panel_2,
    self.panel_3.panel_1,
    self.panel_3.panel_2,
    self.panel_3.panel_3,
    self.panel_3.panel_4,
    self.panel_3.txt_1,
    self.panel_bg,
    self.panel_bg.scale9_bg,
    self.txt_1,
]]

function BattleLose:ctor(winName,params)
    BattleLose.super.ctor(self, winName);
    self.isUpgrade = false

    self.battleDatas = params
    
    self.result = self.battleDatas    

    --self.isLvUp = true
    if not LoginControler:isLogin() then
        self.isLvUp = false
    elseif self.result.battleLabels == GameVars.battleLabels.pvp then
        --todo
    else
        self.isLvUp = params.preLv < UserModel:level()
    end
    --self.battleDatas = params




end


function BattleLose:loadUIComplete()



    if self.result.battleLabels == GameVars.battleLabels.pvp then
        --echo("战斗失败-------PVp")
        AudioModel:playMusic(MusicConfig.s_battle_pvp_lose, false)
    else
        --echo("战斗失败 ==-==== 普通----")
        AudioModel:playMusic(MusicConfig.s_battle_lose, false)
    end
    WindowControler:createCoverLayer(nil, nil, GameVars.bgAlphaColor):addto(self, -2)
    -- 注册点击任意地方事件
    self:registClickClose(nil, c_func(self.pressClose, self))
    self.isUpgrade = false
    self:registerEvent();
    self:uiAdjust()

    self.txt_2:setString("点击任意处继续...")

    local particalNode = FuncArmature.getParticleNode( "xiaxue" )
    
    self.ctn_1:addChild(particalNode)



end 

--[[
界面适配
]]
function BattleLose:uiAdjust()
    FuncCommUI.setViewAlign( self.btn_3,UIAlignTypes.RightTop )
    FuncCommUI.setViewAlign( self.btn_4,UIAlignTypes.RightTop )


    self.btn_3:visible(false)
    self.btn_3:enabled(false)
    self.btn_4:visible(false)
    self.btn_4:enabled(false)

    --FuncCommUI.setViewAlignByCenterX(self.panel_lose1,GameVars.width/GAMEWIDTH)
    --FuncCommUI.setScale9Align( self.panel_lose1,UIAlignTypes.Middle)
    --FuncCommUI.setViewAlignByCenter(self.panel_lose1,GameVars.width/GAMEWIDTH ,1.0);
    self.panel_lose1:setScaleX(GameVars.width/GAMEWIDTH)
    --FuncCommUI.setViewAlign( self.panel_lose1,UIAlignTypes.LeftTop )


    FuncCommUI.setViewAlign(  self.panel_lose1,UIAlignTypes.Left )
    -- self.panel_lose1:setAnchorPoint(cc.p(0.5,0.5))
    -- self.panel_lose1:pos(0,-40)

end




function BattleLose:registerEvent() 
    BattleLose.super.registerEvent()
    self.btn_3:setTap(function (  )
        echo("查看排行榜")
    end)
    self.btn_4:setTap(function (  )
        echo("重新战斗")
    end)
    self.mc_1:zorder(0)
    self.mc_1:showFrame(1)
    self.mc_1.currentView:setTouchedFunc(function()
        echo("去变强------------")
    end,nil,true)
end


-- 退出战斗
function BattleLose:pressClose()
    if self.isUpgrade then
        
    end
    self:startHide()

end



function BattleLose:hideComplete()
    
    --FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
    if not self.isLvUp then
        FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
    else
        WindowControler:showBattleWindow("CharLevelUpView", UserModel:level(),true);
    end
    BattleLose.super.hideComplete(self)
end


return BattleLose;
