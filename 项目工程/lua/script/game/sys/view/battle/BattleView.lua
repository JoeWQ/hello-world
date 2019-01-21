local BattleView = class("BattleView", UIBase);

--[[
]]

BattleView.maxStarLevel = 3

BattleView.baoxiangNums = 0


--激活对象 特效
BattleView.ani_attackSign = nil


function BattleView:ctor(winName)
    BattleView.super.ctor(self, winName);
    self._canClick = true
    self.updateCount = 0
    self.quickGameWinButtonState = false --Temp 限制点击次数
    --左方的总血量  和右方的总血量 
    self._totalHp1 = 0
    self._totalHp2 = 0

    self:setNodeEventEnabled(true)

end

--UI加载完成
function BattleView:loadUIComplete()
    self:registerEvent();
    self._currentStarLevel = self.maxStarLevel
    --ui对其
    FuncCommUI.setViewAlign(self.panel_1,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.panel_xue2,UIAlignTypes.MiddleTop)
    FuncCommUI.setViewAlign(self.txt_san,UIAlignTypes.MiddleTop)
    FuncCommUI.setViewAlign(self.panel_3,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.btn_1,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.txt_1,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.btn_2,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.mc_2,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.mc_1,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.btn_4,UIAlignTypes.LeftTop)

    if IS_SHOWBATTLESKIP and BattleControler.__gameMode ~= Fight.gameMode_pvp then
        local  creatBtns = function (text,clickFunc  )
            local view = UIBaseDef:createPublicComponent( "UI_debug_public","panel_bt" )
            view.txt_1:setString(text)
            view:setTouchedFunc(clickFunc)
            view:addto(self)
            return view
        end
        if true then
            creatBtns("三星7", c_func(self.quickGameWin, self,7)):pos(250,-10+GameVars.UIOffsetY *2)  
            creatBtns("二星5", c_func(self.quickGameWin, self,5)):pos(420,-10+GameVars.UIOffsetY *2)  
            creatBtns("一星1", c_func(self.quickGameWin, self,1)):pos(590,-10+GameVars.UIOffsetY *2)  
            creatBtns("失败", c_func(self.quickGameWin, self,0)):pos(250,-10+GameVars.UIOffsetY *2 - 60)  
        end
    end

    if IS_SHOWBATTLESKIP and BattleControler.__gameMode == Fight.gameMode_pvp then
        local  creatBtns = function (text,clickFunc  )
            local view = UIBaseDef:createPublicComponent( "UI_debug_public","panel_bt" )
            view.txt_1:setString(text)
            view:setTouchedFunc(clickFunc)
            view:addto(self)
            return view
        end
        if true then
            creatBtns("PVP胜利", c_func(self.quickPVPGame, self,-1)):pos(250,-10+GameVars.UIOffsetY *2)
            creatBtns("PVP失败", c_func(self.quickPVPGame, self,-2)):pos(420,-10+GameVars.UIOffsetY *2)        
        end
    end


    FuncArmature.loadOneArmatureTexture("UI_zhandoulianji",nil,true)
    FuncArmature.loadOneArmatureTexture("UI_zhandou",nil,true)


     self.ani_attackSign = FuncArmature.createArmature("UI_zhandou_zhishichuxian", self._root, true)
    -- --隐藏这个动画
     self.ani_attackSign:visible(false)
     self.ani_attackSign:pause(false)
     self._root:visible(false)
     self.panel_zhandou:visible(false)

    --暂停按钮的控制  弹起状态
    self.mc_1:showFrame(1)
    self.mc_1.currentView.btn_1:setTap(c_func(self.doPauseBattle,self))


    --隐藏连击伤害
    --self.panel_l:visible(false)
    self.panel_l:setOpacity(0)

    

    
    self.panel_zdzd:visible(false)


    -- self.slider_ma:setMinMax(0,100)
    -- self.slider_ma:setPercent(50)
    -- self.slider_ma:onSliderChange(c_func(self.onPlayChanged,self))

    self.panel_zhan:visible(false)
    self.panel_tou:visible(false)  
    self.mc_newnumber:visible(false)  

    self.panel_daoju:visible(false)
    self.panel_daoju2:visible(false)

    self.panel_treaDemo:visible(false)

    --测试按钮  点击  宝箱切换场景
    local tempFunc = function (  )
        self.controler.map:setNextMapId()
    end
    self.btn_4:setTap(tempFunc)

end 

--[[
暂停按钮
]]
function BattleView:onPauseClick(  )
    --echo("暂停")
    if self.controler then
        self.controler:playOrPause(false)
        self.controler:testFramePlay(3)
    end
end


--[[
逐帧播放
]]
function BattleView:onFrameClick(  )
    --echo("逐帧")
    if self.controler then
        --echo("当前播放的帧数:",self.controler.updateCount)
        self.controler:testFramePlay(2)
    end
end

--[[
播放
]]
function BattleView:onPlayClick(  )
    --echo("播放")
    if self.controler then
       self.controler:playOrPause(true)
       self.controler:testFramePlay(3)
   end
end



--[[
测试 DEMO中控制速度
]]
function BattleView:onPlayChanged( per )
    
    local per = tonumber(string.format('%.1f', per))
    --echo("当前百分比:",per)
    local speed = (per-50)/50 +1 --*(100)
    speed = tonumber(string.format('%.1f', speed))
    if self.controler then
        self.controler:changeGameSpeed(speed)
    end
end



--[[
界面退出
]]
function BattleView:onEnter(  )
    self:scheduleUpdateWithPriorityLua(c_func(self.onUpdateAutoFrame, self), 0) 
end

--[[
界面进入
]]
function BattleView:onExit(  )
    self:unscheduleUpdate()
end
--[[
刷新倒计时时间
]]
function BattleView:onUpdateAutoFrame(  )
    --echo("刷新方法-----")

    if self.controler and self.controler.gameMode == Fight.gameMode_pvp then
        --echo("ssss更新=-===============================")
        self.panel_djs.txt_leftAutoFrame:visible(false)
        --self.panel_djs.djsAni:visible(false)
        self:unscheduleUpdate()
        return
    end

    if self.controler and self.controler.logical then
        if self.controler.logical.autoFight then
            self.panel_zdzd:visible(true)
            if self.panel_djs and self.panel_djs.djsAni then
                self.panel_djs.djsAni:visible(false)
            end
            self.panel_djs.txt_leftAutoFrame:visible(false)
            return
        end
        local leftFrame = self.controler.logical.leftAutoFrame
        if not self.panel_djs.djsAni then
            self.panel_djs.djsAni = FuncArmature.createArmature("UI_zhandou_daojishi",self.panel_djs,false,GameVars.emptyFunc):pos(50,-20)
            self.panel_djs.djsAni:gotoAndPause(0)
            self.panel_djs.djsAni:visible(false)
        end
        if leftFrame == -1 then
            --echo("-1,不显示")
            self.panel_djs.txt_leftAutoFrame:visible(false)
            self.panel_djs.djsAni:gotoAndPause(0)
            self.panel_djs.djsAni:visible(false)

            self.panel_djs.txt_leftAutoFrame:visible(true)
            self.panel_djs.txt_leftAutoFrame:setString("∞")
            return
        end
        FuncArmature.setArmaturePlaySpeed( self.panel_djs.djsAni ,self.controler.updateScale)
        if self.controler._gamePause then
            self.panel_djs.djsAni:pause()
            return
        else
            self.panel_djs.djsAni:play()
        end
        local minSec = math.ceil( leftFrame/GAMEFRAMERATE )
        if not self.lastMinSec then self.lastMinSec = minSec-1 end
        if minSec==self.lastMinSec then
            return
        end
        if minSec >5 then
            self.panel_djs.txt_leftAutoFrame:visible(true)
            self.panel_djs.txt_leftAutoFrame:setString(minSec)
            self.panel_djs.djsAni:gotoAndPause(0)
            self.panel_djs.djsAni:visible(false)
        else
            self.panel_djs.txt_leftAutoFrame:visible(false)
            if minSec == 5 then
                self.panel_djs.djsAni:gotoAndPlay(0)
            end
            self.panel_djs.djsAni:visible(true)
            FuncArmature.setArmaturePlaySpeed( self.panel_djs.djsAni ,self.controler.updateScale)
        end
        self.lastMinSec = minSec
    end

    
end



--战斗暂停
function BattleView:doPauseBattle(  )
    




    if not self._canClick then
        return
    end

    if self.controler.__gameStep == Fight.gameStep.result then
        return
    end
    --发送暂停事件 
    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_GAMEPAUSE )
    WindowControler:showBattleWindow("BattlePause",self.controler)

    --self.mc_1:showFrame(2)
    --self.mc_1.currentView.btn_1:setTap(c_func(self.doResumeBattle,self))
    echo("战斗暂停")

    -- if self.panel_djs.djsAni then
    --     self.panel_djs.djsAni:pause(false)
    -- end

end




--回复战斗
function BattleView:doResumeBattle(  )
    self.mc_1:showFrame(1)
    --echo("回复战斗----")
    -- if self.panel_djs.djsAni then
    --     echo("战斗动画回复=--------")
    --     self.panel_djs.djsAni:play(false)
    -- end
end

--[[
快速跳过PVP
-1:表示竞技场胜利
-2:表示竞技场失败
]]
function BattleView:quickPVPGame(star)
    if not self.quickGameWinButtonState then
        --BattleControler:showReward( {})
        -- -1 表示竞技场胜利
        self.controler:quickVictory(star)
        self.quickGameWinButtonState = true
    end
end







--快速跳过战斗
function BattleView:quickGameWin( star)
    if not self.quickGameWinButtonState then --Temp 只允许点击一次即可
        self.controler:quickVictory(star)
        self.quickGameWinButtonState = true
    end 
end

function BattleView:registerEvent()
    --暂停按钮的操作  mc_1  这个状态是点击  按下  弹起状态
    --self.panel_1.btn_1:setTap(c_func(self.press_btn_1, self));
    --注册游戏结束事件
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_REWARD,self.onGameOver,self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH,self.onHpChanged,self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDEND,self.onRoundEnd,self)
end


----------------------------------------新手引导------------------------
function BattleView:showTutorial( treaType )
    
    
    if not self.hero:canChangeTreasure(treaView.treasure,true) then
        return
    end

    -- 只会出现一次
    self.controler.levelInfo._tutorial = nil

    local x,y = treaView:getPosition()
    pos = {x=x,y=y}
    local battleRoot = WindowControler:getCurrScene()._battleRoot
    local pos = treaView:convertLocalToNodeLocalPos(battleRoot)

    local size = {width=120,height=150}
    pos.x = pos.x + size.width/2
    pos.y = pos.y - size.height/2
    local layout = {horizontalLayout=ENUM_LAYOUT_POLICY.LEFT,verticalLayout=ENUM_LAYOUT_POLICY.DOWN}
    FuncCommUI.setATopViewWithAHole(pos,size,layout,function( ... ) self.controler:scenePlayOrPause(false) end,true)

end


----------------------------------------按钮点击事件--------------------
-- 点击暂停按钮
function BattleView:press_btn_1()

    --如果不能点击 比如 是开场动画的时候
    if not self._canClick then
        return
    end

    if self.controler.__gameStep == Fight.gameStep.result then
        return
    end
    --发送暂停事件 
    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_GAMEPAUSE )
    WindowControler:showBattleWindow("BattlePause",self.controler)

end

-------------update刷新函数--------------------------------------------
function BattleView:updateFrame(  )
    self.updateCount = self.updateCount +1
    self:updateTimeAndStar()
end


--刷新计时 和星级
function BattleView:updateTimeAndStar(  )

    if self.updateCount % GAMEFRAMERATE ~= 0 then
        return
    end
    if self.controler.gameLeftTime > 0 then
        local second = math.round(self.controler.gameLeftTime/GAMEFRAMERATE)
        local star = self.maxStarLevel
        --如果有星级评价
        local str = fmtSecToMMSS(second)
        self.panel_1.txt_2:setString(str)

    end
end





--------------------------侦听事件---------------------------
--[[
回合结束
]]
function BattleView:onRoundEnd( event )
    --echo("回合结束")
    if self.comAni then
        self.comAniIndex = 3
        self.comAni:gotoAndPlay(0)
        self.comAni:playWithIndex(3,false)
        --倒计时播放完成  播放消失
        -- self.comAni:getBoneDisplay("note1"):gotoAndPause(comCnt)
        -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer3"):gotoAndPause(first+1)
        -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer4"):gotoAndPause(second+1)
        -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer5"):gotoAndPause(third+1)
    end
end


--侦听战斗结束事件
function BattleView:onGameOver( event )
    local result = event.params.result
    -- echo("战斗结果数据=====================")
    -- dump(event.params)
    -- echo("战斗结果数据=====================")


    --隐藏root
    self._root:visible(false)
    --停止当前背景音乐
     AudioModel:stopMusic()

     --如果是pvp战斗界面
    if event.params.battleLabels == GameVars.battleLabels.pvp then
        if tonumber(result) == 2 then
            WindowControler:showBattleWindow("BattleLose",event.params,GameVars.battleLabels)
        else
            WindowControler:showBattleWindow("BattleWin",event.params,GameVars.battleLabels)
        end
    end

    --创建失败界面
    if tonumber(result) == 2  then
        --WindowControler:showBattleWindow("BattleLose",event.params)
        --让游戏置灰
        FilterTools.setGrayFilter(self.controler.layer.a2)
        --AudioModel:playSound("s_battle_lose")
        WindowControler:showBattleWindow("BattleLose",event.params,GameVars.battleLabels)
    else

        -- local uiWin 
        -- --如果是 towerPve
        -- if BattleControler:getBattleLabel() == GameVars.battleLabels.towerPve   then
        --     uiWin =  WindowControler:showBattleWindow("BattleWin3",event.params)  --WindowsTools:createWindow("BattleWin3")
        -- else
        --     uiWin = WindowControler:showBattleWindow("BattleWin",event.params)  --WindowsTools:createWindow("BattleWin")
        -- end
        WindowControler:showBattleWindow("BattleWin",event.params,GameVars.battleLabels)
        -- AudioModel:playSound("s_battle_win")
    end

    

    

end


--@测试代码
function BattleView:creatBtns( text,clickFunc )

    local xpos = 30

    local ypos = -110
    local sp = display.newNode():addto(self):pos(xpos,ypos):anchor(0,0)
    sp:size(80,40)
    display.newRect(cc.rect(0, 0,80, 40),
        {fillColor = cc.c4f(1,1,1,0.8), borderColor = cc.c4f(0,1,0,1), borderWidth = 1}):addto(sp)

    display.newTTFLabel({text = text, size = 20, color = cc.c3b(255,0,0)})
            :align(display.CENTER, sp:getContentSize().width/2, sp:getContentSize().height/2)
            :addTo(sp):pos(40,20)
    sp:setTouchedFunc(clickFunc,cc.rect(0,0,84,44))
end

--能否点击
function BattleView:setClickAble( value )
    self._canClick = value
end


--点击自动战斗按钮
function BattleView:pressAutoBtn(  )
    if self.controler.logical.autoFight then
        echo("设置非自动战斗")
        self.controler.logical:setAutoFight(false)
        
        --self.mc_zd:showFrame(1)
    else
        echo("自动战斗----")
        self.controler.logical:setAutoFight(true)
        --self.btn_2:setOpacity(100)
        --self.mc_zd:showFrame(2)
    end

    --判断是否需要自动攻击
    self.controler.logical:doAutoFightAi(1)

end

----------------------外部调用------------------------------------------
--设置游戏控制器
function BattleView:setControler(controler )
    self.controler = controler
    --self.UI_treasure:initControler(self,controler)

    if not TutorialManager.getInstance():isAllFinish() then
       self.panel_1.btn_1:visible(false)
    end

    if self.controler.levelInfo._tutorial then
        self.panel_1.btn_1:visible(false)
    end
        
    --判断是否是自动战斗  自动战斗
    if self.controler.logical.autoFight then
        --self.btn_2:
        --self.mc_zd:showFrame(2)
        self.btn_2:setOpacity(100)
    else
        --那么显示第二帧
        --self.mc_zd:showFrame(1)
        self.btn_2:setOpacity(255)
    end
    --self.mc_zd:setTouchedFunc(c_func(self.pressAutoBtn,self), nil, true)
    self.btn_2:setTap(c_func(self.pressAutoBtn,self),nil,true)
    self.colorLayer:visible(false)

    --根据战斗类型，显示战斗血条种类
    self.panel_zhandou:visible(false)          --未知种类的战斗血条   不可见
    self.UI_pvp_hp:visible(false)
    self.UI_pve_hp:visible(false)
    if self.controler.gameMode == Fight.gameMode_pvp then
        self.ui_hp_view = self.UI_pvp_hp
    elseif self.controler.gameMode == Fight.gameMode_pve then
        self.ui_hp_view = self.UI_pve_hp
    else
    end
    if self.ui_hp_view then
        self.ui_hp_view:visible(true)
    end
    self.ui_hp_view:initControler(self,controler)
    self:chkElementVisibe()
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_COMBCHANGE,self.onComChanged,self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundStart, self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_NEXTWAVE,self.onNextWave,self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CHANGEAUTOFIGHT,self.autoChanged,self )
    self.mc_2:setTouchedFunc(c_func(self.speedClick,self))
    self:onNextWave()

    
end



--[[
    pve pvp 暂停，自动战斗显示隐藏

]]
function BattleView:chkElementVisibe(  )
    if self.controler.gameMode == Fight.gameMode_pvp then
        self.btn_4:visible(false)
        self.btn_2:visible(false)
        self.panel_zdzd:visible(false)
        self.txt_san:visible(false)
    elseif self.controler.gameMode ==  Fight.gameMode_pve then
        self.btn_4:visible(true)
        self.btn_2:visible(true)
        self.panel_zdzd:visible(false)
        self.txt_san:visible(true)
    end
end



--[[
倍率发生改变
]]
function BattleView:speedClick(  )
    local speed = self.controler.updateScale
    local frame = speed
    if speed == 1 then
        speed = 1.5
        frame = 2
    else
        speed = 1
        frame = 1
    end
    self.controler:changeGameSpeed(speed)
    self.mc_2:showFrame(frame)

    --倒计时动画
    -- if self.panel_djs.djsAni then
    --     FuncArmature.setArmaturePlaySpeed( self.panel_djs.djsAni ,self.controler.updateScale)
    -- end
end

--[[
是否是自动战斗
]]
function BattleView:autoChanged(  )
    echo("是否是自动战斗")
    local isAuto = self.controler.logical.autoFight
    local opacityVal = 255
    if isAuto then
        opacityVal = 100
    end
    self.btn_2:setOpacity(opacityVal)

    --是否是自动战斗
    self.panel_zdzd:visible(isAuto)
    --self.panel_djs:visible(not isAuto)
end


--[[
连击数发生改变
]]
function BattleView:onComChanged( e )
    --echo("连击数发生改变")
    local comCnt = e.params
    if comCnt<=1 then
        return
    end
    if self.controler.logical.currentCamp ~= 1 then
        return
    end
    local allFrame = 2*GAMEFRAMERATE-10  --倒计时特效药持续的帧数
    local gameSpeed = self.controler.updateScale

    local ratio = self.controler.logical:getCombDamageRatio(comCnt)
    local first = math.floor(ratio*100/100)                         --第一个数字
    local second = math.floor((ratio*100-first*100)/10)             --第二个数字    
    local third = math.floor((ratio*100-first*100-second*10))       --第三个数字



    --动画播放的回调
    local callback
    callback = function ( )
    --echo("播放完成---",self.comAniIndex,"---------------",first,second,third)
        self.comAni:removeFrameCallFunc()
        if self.comAniIndex ==0 then
            -- self.comAniIndex = 1
            self.comAniIndex = 2
            -- --echo("回调播放11111111")
            -- self.comAni:playWithIndex(1,false)
            -- self.comAni:gotoAndPlay(0)
            -- --FuncArmature.setArmaturePlaySpeed(self.comAni,10/allFrame*gameSpeed)
            -- --出现播放完成  接着播放倒计时
            -- self.comAni:getBoneDisplay("note1"):gotoAndPause(comCnt)
            -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer3"):gotoAndPause(first+1)
            -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer4"):gotoAndPause(second+1)
            -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer5"):gotoAndPause(third+1)
            
            --self.comAni:registerFrameEventCallFunc(nil,1,callback)
        elseif self.comAniIndex == 1 then
            --echo("回调播放333333")
            -- self.comAniIndex = 3
            -- self.comAni:gotoAndPlay(0)
            -- self.comAni:playWithIndex(3,false)
            -- --倒计时播放完成  播放消失
            -- self.comAni:getBoneDisplay("note1"):gotoAndPause(comCnt)
            -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer3"):gotoAndPause(first+1)
            -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer4"):gotoAndPause(second+1)
            -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer5"):gotoAndPause(third+1)
            
            --self.comAni:registerFrameEventCallFunc(nil,1,callback)
        elseif self.comAniIndex == 2 then
            -- self.comAniIndex = 1
            -- self.comAni:gotoAndPlay(0)
            -- self.comAni:playWithIndex(1,false)
            -- --FuncArmature.setArmaturePlaySpeed(self.comAni,10/allFrame*gameSpeed)
            -- --跳字播放完成  播放倒计时
            -- self.comAni:getBoneDisplay("note1"):gotoAndPause(comCnt)
            -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer3"):gotoAndPause(first+1)
            -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer4"):gotoAndPause(second+1)
            -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer5"):gotoAndPause(third+1)
            
            -- self.comAni:registerFrameEventCallFunc(nil,1,callback)
        elseif self.comAniIndex == 3 then
            --消失播放完成
            --echo("清除数字")
            -- self.comAniIndex = 0
            -- self.lastComCnt = nil
            -- self.lastFirst = nil
            -- self.lastSecond = nil
            -- self.lastThird = nil
        end
    end
    if not self.comAni then
        self.comAni = FuncArmature.createArmature("UI_zhandoulianji_chuxian",self.ctn_lianjidonghua,false,callback)
        FuncCommUI.setViewAlign(self.comAni,UIAlignTypes.RightTop)
        --FuncArmature.setArmaturePlaySpeed( self.comAni ,0.5)
        --self.comAni:pos(display.width-240,-120)
        self.comAniIndex = 0
    end
    self.comAni:removeFrameCallFunc()
    
    if self.comAniIndex ==0  then
        self.comAniIndex = 0
        --echo("播放000000")
        self.comAni:playWithIndex(0,false)

        --FuncArmature.setArmaturePlaySpeed(self.comAni,1*gameSpeed)
        --当前动画在出现阶段
        self.comAni:getBoneDisplay("note1"):gotoAndPause(comCnt)            --连击次数
        self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer3"):gotoAndPause(first+1)  --原来的数字   在d标签中是 新数字
        self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer4"):gotoAndPause(second+1)
        self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer5"):gotoAndPause(third+1)
        
    elseif self.comAniIndex == 2 then
        --当前在跳字阶段  或者倒计时  到应该播放  跳字动画
        --echo("播放22222")
        self.comAniIndex = 2
        self.comAni:playWithIndex(2,false)
        self.comAni:gotoAndPlay(0)
        --FuncArmature.setArmaturePlaySpeed(self.comAni,10/allFrame*gameSpeed)
        local lstNum = comCnt
        if self.lastComCnt ~= nil then lstNum = self.lastComCnt end
        self.comAni:getBoneDisplay("note1"):gotoAndPause(comCnt)
        self.comAni:getBoneDisplay("lianji2"):gotoAndPause(lstNum)
        lstNum = first
        if self.lastFirst ~= nil then lstNum= self.lastFirst end
        self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer3"):gotoAndPause(lstNum+1)
        lstNum = second
        if self.lastSecond ~= nil then lstNum = self.lastSecond end
        self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer4"):gotoAndPause(lstNum+1)
        lstNum = third
        if self.lastThird then lstNum = self.lastThird end
        self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer5"):gotoAndPause(lstNum+1)
        
        self.comAni:getBoneDisplay("light2"):getBoneDisplay("layer3"):gotoAndPause(first+1)
        self.comAni:getBoneDisplay("light2"):getBoneDisplay("layer4"):gotoAndPause(second+1)
        self.comAni:getBoneDisplay("light2"):getBoneDisplay("layer5"):gotoAndPause(third+1)
    end
    --注册回调
    self.comAni:registerFrameEventCallFunc(nil,1,callback)
    self.lastComCnt = comCnt
    self.lastFirst = first
    self.lastSecond= second
    self.lastThird = third
end







--[[
回合发生改变
]]
function BattleView:onRoundStart(  )
    local curRound = self.controler.logical.roundCount
    curRound = math.ceil(curRound/2)
    self.txt_1:setString(curRound.."/20")

    self.comAniIndex =0

    --self:autoChanged()  --更新自动战斗的状态
    
end

function BattleView:onNextWave( params )
    -- echo("战斗进入下一波")
    -- dump(params)
    -- echo("战斗进入下一波")
    --self.__currentWave == self.levelInfo.maxWaves
    local curWave = self.controler.__currentWave
    local maxWaves = self.controler.levelInfo.maxWaves
    self.txt_san:setString(curWave.."/"..maxWaves)

end



--初始化完毕
function BattleView:initGameComplete(  )
    self._totalHp1 = self:countTotalHp(1)
    self._totalHp2 = self:countTotalHp(2)
    self:onHpChanged(true)
   -- self.UI_treasure:initView()
    self:showCharHead()
    self._root:visible(true)
    if self.ui_hp_view then
        self.ui_hp_view:initView()
    end
end

--显示主角和敌人头像
function BattleView:showCharHead(  )
    --显示主角头像和boss头像
    -- for k,v in pairs(self.controler.campArr_1) do
    --     if v:checkIsMainHero() then
    --         local head = v.data:head()
    --         local ctn = self.panel_xue2.panel_1.panel_2.ctn_1
    --         local sp = display.newSprite(FuncRes.iconHead(head)):addto(ctn):scale(0.8)
    --     end
    -- end

    -- for k,v in pairs(self.controler.campArr_2) do
    --     if v:checkIsMainHero() then
    --         local head = v.data:head()
    --         local ctn = self.panel_xue2.panel_3.panel_1.ctn_1
    --         local sp = display.newSprite(FuncRes.iconHead(head)):addto(ctn):scale(0.8)
    --     end
    -- end

end



--掉落道具
function BattleView:createDrop( itemArr,x,y,ctn )
    local perDis = Fight.drop_distance --每个距离位置
    local leftPos = -(#itemArr-1)/2 *perDis + x
    local  createBaoxiang = function ( x,y,tox ,ctn)
        local ani = FuncArmature.createArmature("UI_battle_diaoluobaoxiang", ctn, true)
        ani:pos(x,y )
        ani:moveTo(0.5,tox,y)
        ani:runEndToNextLabel(0,1,true)
        ani:setTouchedFunc(c_func(self.easeChest,self,ani ))
        --默认3秒后自动飞到目标点
        ani:delayCall(c_func(self.easeChest,self, chestView), 3 )
    end

    for i=1,#itemArr do
        self:delayCall(c_func(createBaoxiang,x,y + RandomControl.getOneRandomInt(15, -15) ,leftPos + perDis*(i-1),ctn ), (i-1)*0.1+ 0.001 )
    end
end


--让一个宝箱缓动运动到ui目标点
function BattleView:easeChest(chestView )
    if chestView._isMoving then
        return
    end
    chestView._isMoving = true
    local turnPos = chestView:convertLocalToNodeLocalPos(self.panel_1.ctn_3)
    --强制添加到 宝箱容器
    chestView:parent(self.panel_1.ctn_3):pos(turnPos.x,turnPos.y)
    --播放第三个动作  也就是飞过去的动作
    chestView:playWithIndex(2, false)

    --获取帧数
    local frame = chestView:getAnimation():getRawDuration()
    local angle = math.atan2(-turnPos.y,-turnPos.x)

    -- chestView:getBoneDisplay("bone1"):getBoneDisplay("layer6"):setRotation(angle*180/math.pi)
    --到达目标点
    local onOverEnd = function ( chest  )
        chest:clear()
        --宝箱播放动画
        self.ani_baoxiang:startPlay(false)
        self.baoxiangNums = self.baoxiangNums +1
        --更新宝箱数量
        self.panel_1.txt_1:setString(self.baoxiangNums)
        --播放到达特效

    end

    --做一个缓动
    transition.moveTo(chestView,
        {x = 0, y = 0, time = (frame-3)/GAMEFRAMERATE ,
        -- easing = "exponentialIn",
        onComplete = c_func(onOverEnd, chestView)
        }) 
end


--获取中心坐标
function BattleView:getCtnCenterPos()
    return GAMEHALFWIDTH,-GAMEHALFHEIGHT 
end

--显示或者隐藏蒙板
function BattleView:showOrHideMengban(value  )
    if not self._mengban then
        self._mengban = display.newColorLayer(cc.c4b(0,0,0,200)):addto(self)
        self._mengban:setContentSize(cc.size(GameVars.width,GameVars.height))
        self._mengban:anchor(0,1)
        FuncCommUI.setViewAlign(self._mengban,UIAlignTypes.LeftTop)
    end
    if value then
        self._mengban:visible(true)
    else
        self._mengban:visible(false)
    end
end

--显示或者隐藏血条警告
function BattleView:showOrHideXueWarn( value )
    if not self.ani_xueWarn then
        self.ani_xueWarn = FuncArmature.createArmature("UI_battle_warn", self, true)
        local centerx,centery = self:getCtnCenterPos()

        self.ani_xueWarn:pos(centerx,centery)
        local sx = GameVars.width / GAMEWIDTH 
        local sy = GameVars.height / GAMEHEIGHT 
        self.ani_xueWarn:setScaleX(sx)
        self.ani_xueWarn:setScaleY(sy)
        local globalPos = self.ani_xueWarn:convertLocalToNodeLocalPos(WindowControler:getCurrScene())
    end

    self.ani_xueWarn:visible(value)

end


--计算阵营的总血量
function BattleView:countTotalHp( camp )
    local campArr = camp ==1  and self.controler.campArr_1 or self.controler.campArr_2
    local hp =0
    for k,v in pairs(campArr) do
        hp = hp +  v.data:hp()
    end
    return hp
end


--某个阵营的血量发生变化
function BattleView:onHpChanged( isInit  )
    -- local hp1 = self:countTotalHp(1)
    -- local percent1 = math.round(hp1/self._totalHp1 * 100)
    
    

    -- local hp2 = self:countTotalHp(2)
    -- local percent2 = math.round(hp2/self._totalHp2 * 100)
    
    -- if  isInit ~= true then
    --     self.panel_xue2.panel_1.panel_1.progress_1:tweenToPercent(percent1,10)
    --     self.panel_xue2.panel_3.panel_2.progress_1:tweenToPercent(percent2,10)
    -- else
    --     self.panel_xue2.panel_1.panel_1.progress_1:setPercent(percent1)
    --     self.panel_xue2.panel_3.panel_2.progress_1:setPercent(percent2)
    -- end

end

--给某个英雄中标记
-- flag == true   播循环阶段  falg==false  播出现阶段
function BattleView:setAttackSign( hero,flag)

    --echo("------英雄选中发生变化------",flag, (not hero),"=========================" )
    local callback
    callback = function (  )
        if self.ani_attackSign then
            --echo("回调播放完成-------")
            self.ani_attackSign:removeFrameCallFunc()
            if not flag then
                self.ani_attackSign:playWithIndex(1,true)
            else
                -- self.ani_attackSign:visible(false)
                -- self.ani_attackSign:pause(false)
                -- self.ani_attackSign:parent(self._root)
                self.ani_attackSign:playWithIndex(1,true)
            end
        end
    end

    --如果hero 为空表示 当前没有标记
    if not hero  then
        --echo("nil不可见------")
        self.ani_attackSign:removeFrameCallFunc()
        self.ani_attackSign:visible(false)
        self.ani_attackSign:parent(self._root)
        self.ani_attackSign:pause(false)
    else
        --echo("BattleView:setAttackSign",hero.data.rid,self.ani_attackSign.ridSign,"------")
        --显示到 这个人的头顶上去

        self.ani_attackSign:visible(true)
        local viewHeight = hero.data.viewSize[2]
        self.ani_attackSign:parent(hero.healthBar._lightNode):pos(0, -viewHeight/2)
        if flag then

            --拿到healthbar 对应的容器坐标 进行转化 
            --echo("重新播放")
            --self.ani_attackSign:parent(hero.healthBar):pos(0, -viewHeight/2)
            self.ani_attackSign.ridSign = hero.data.rid
            self.ani_attackSign:removeFrameCallFunc()
            self.ani_attackSign:playWithIndex(0,false)
            self.ani_attackSign:registerFrameEventCallFunc(nil,1,callback)
        else
            --echo("没有重新播放")
            --if flag then
            self.ani_attackSign:removeFrameCallFunc()
            self.ani_attackSign:playWithIndex(1,true)
        end
    end
end



function BattleView:deleteMe(  )
    self.controler = nil
    BattleView.super.deleteMe(self)
    --清除自身的侦听 
    FightEvent:clearOneObjEvent(self)
end

return BattleView;
