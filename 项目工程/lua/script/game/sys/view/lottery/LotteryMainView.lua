local LotteryMainView = class("LotteryMainView", UIBase);

function LotteryMainView:ctor(winName)
    LotteryMainView.super.ctor(self, winName);
end

function LotteryMainView:loadUIComplete()
	self:registerEvent();
    self:initData()
    self:initView()
	self:startLotteryCd()
    self:updateUI()
    -- normal --aniplaying 
    self.curUIState = "Normal"
end 

function LotteryMainView:registerEvent()
	LotteryMainView.super.registerEvent();

    --  预览 操作
    self.panel_1.btn_1:setTap(c_func(self.pressTokenPreview,self))
    --返回按钮
     self.btn_back:setTap(c_func(self.press_btn_back, self));
     --预览  操作
     self.panel_2.btn_1:setTap(c_func(self.pressGoldPreview,self))

    -- 开启cd
    EventControler:addEventListener(LotteryEvent.LOTTERYEVENT_START_CD, self.startLotteryCd, self)
    -- 奖品界面关闭消息
    EventControler:addEventListener(LotteryEvent.LOTTERYEVENT_CLOSE_REWARD_VIEW, self.resetLotteryPanel, self)

    -- 再次抽卡成功
    EventControler:addEventListener(LotteryEvent.LOTTERYEVENT_DO_LOTTERY_AGAIN_SUCCESS, self.doLotteryAgainSuccess, self)


    local rootView = WindowControler:getCurrScene()._root
    local sp = display.newNode():addto(rootView,994):pos(0,0):anchor(0,0)
    sp:size(GameVars.width,GameVars.height)
    sp:setTouchedFunc(c_func(self.speedAniClick,self),cc.rect(0,0,GameVars.width*2,GameVars.height*2))
end


--[[
动画屏蔽层被点击
]]
function LotteryMainView:speedAniClick(  )
    if self.curUIState == "Normal" then
       return
    end
    if self.curUIState == "Aniplaying" then
        self:showRewardView(self.lotteryCallBackParams,true)
    end
end


--[[
初始化数据
]]
function LotteryMainView:initData()
    -- 累计10次出法宝
    self.maxTimes = LotteryModel.maxTimes
    -- 令牌抽卡是否在cd中
    self.isCdTokenLottery = true
    -- 钻石抽卡是否在cd中
    self.isCdGoldLottery = true

    -- 令牌抽是否免费
    self.isTokenFree = false
    -- 钻石单抽是否免费
    self.isGoldOneFree = false
    -- 是否是第一次钻石十连抽
    self.isFirstGoldTen = false

    -- 是否是第一次令牌抽
    if tonumber(LotteryModel:getTokenLotteryFreeTimes()) == 0 then
        self.isTokenFree = true
    else
        if LotteryModel:isTokenLotteryInCd() then
            self.isTokenFree = false
        end
    end

    -- 是否是第一次钻石单抽
    if tonumber(LotteryModel:getGoldLotteryOneTimes()) == 0 then
        self.isGoldOneFree = true
    else
        if LotteryModel:isGoldLotteryInCd() then
            self.isTokenFree = false
        end
    end

    -- 是否是第一次钻石十连抽
    if tonumber(LotteryModel:getGoldLotteryTenTimes()) == 0 then
        self.isFirstGoldTen = true
    end
end 

--[[
设置布局
]]
function LotteryMainView:initView()

    FuncCommUI.setViewAlign(self.panel_title,UIAlignTypes.LeftTop) 
    FuncCommUI.setViewAlign(self.btn_back,UIAlignTypes.RightTop) 
    FuncCommUI.setViewAlign(self.panel_res,UIAlignTypes.RightTop)
    FuncCommUI.setScale9Align( self.scale9_heidai,UIAlignTypes.MiddleTop,1 ) 

    self:initAnim()
    self:initList()
    self:initFenKaiAni()
end

--[[
初始化分开动画
]]
function LotteryMainView:initFenKaiAni(  )
    local moveAni = self:createUIArmature("UI_lottery", "UI_lottery_kapaiyizou", self.ctn_1, false, GameVars.emptyFunc)
    self.moveAni = moveAni
    self.moveAni:gotoAndPause(1)
    self.panel_1:pos(-206,330)
    self.panel_2:pos(-226,330)
    FuncArmature.changeBoneDisplay(moveAni,"a_copy",self.panel_2)
    FuncArmature.changeBoneDisplay(moveAni,"a",self.panel_1)
end



function LotteryMainView:initList(  )
    self.panel_1.panel_ct:visible(false)
    self.panel_2.panel_zzb:visible(false)
    --self.panel_1.scroll_1
    function createLeftCellFunc()
        --local view = UIBaseDef:cloneOneView(self.panel_1.panel_ct);
        local view = self.panel_1.panel_ct
        view:pos(-6,-70)
        --这里也是要更新view的
        self:updateLeftView(view)
        self.leftView = view

        -- local testFunc = function()
        --     echo("点击到了,点击到了")
        -- end

        --self.leftView:setTouchedFunc(c_func(self.doLeftViewClick,self))
        local sp = display.newNode():addto(self.panel_1.ctn_neirong):pos(0,-398):anchor(0,0)
        sp:size(330,398)
        sp:zorder(-10)
        -- display.newRect(cc.rect(0, 0,330, 398),
        --     {fillColor = cc.c4f(1,1,1,0.8), borderColor = cc.c4f(0,1,0,1), borderWidth = 1}):addto(sp)
        sp:setTouchedFunc(c_func(self.doLeftViewClick,self),cc.rect(0,0,330,398))
        return view;
    end

    local leftAni = self:createUIArmature("UI_lottery", "UI_lottery_xiayidong",self.panel_1.ctn_neirong,false,GameVars.emptyFunc)
    --self.panel_1.ctn_neirong:setTouchedFunc(c_func(self.doLeftViewClick,self))
    self.leftAni = leftAni
    FuncArmature.changeBoneDisplay(leftAni,"layer3",createLeftCellFunc())
    leftAni:pos(330/2,-390/2-4)
    --停到第一帧
    leftAni:gotoAndPause(17)
    self.leftView.leftState = "2"              --1:表示最上面  2 表示最下面  3 表示中间态不能响应事件



    local posx,poxy = self.panel_2.ctn_neirong22:getPosition()
    local  pos =self.panel_2.ctn_neirong22:getParent():convertToWorldSpace({x = posx,y = posy })
    local w,h = self.panel_2.ctn_neirong22:getContentSize().width,self.panel_1.ctn_neirong:getContentSize().height
    function createRightFunc(  )
        --local view  = UIBaseDef:cloneOneView(self.panel_2.panel_zzb)
        local view  = self.panel_2.panel_zzb
        view:pos(46,-70)
        self:updateRightView(view)
        self.rightView = view

        local sp = display.newNode():addto(self.panel_2.ctn_neirong22):pos(0,-398):anchor(0,0)
        sp:size(330,398)
        sp:zorder(-10)
        sp:setTouchedFunc(c_func(self.doRightViewClick,self),cc.rect(0,0,330,398))

        return view
    end
    local rightAni = self:createUIArmature("UI_lottery", "UI_lottery_xiayidong",self.panel_2.ctn_neirong22,false,GameVars.emptyFunc)
    
    FuncArmature.changeBoneDisplay(rightAni,"layer3",createRightFunc())
    self.rightAni = rightAni
    rightAni:pos(330/2,-390/2-4)
    rightAni:gotoAndPause(17)
    self.rightView.rightState = "2"


end
--[[
更新左侧面板
这里要增加事件的相应区域
]]
function LotteryMainView:updateLeftView( view )
    --cc.rect(,,330,400)
    --local posx,posy = self.panel_1.ctn_neirong:getPosition()
    --echo("posx,posy",posx,posy,"========")
    --local  pos =self.panel_1.ctn_neirong:getParent():convertToWorldSpace({x = posx,y = posy })
    --local w,h = 330,400
    --echo("posx,posy",pos.x,pos.y,w,h,"----------")
    view.panel_chou1.btn_1:setTap(c_func(self.pressTokenOne, self))
    view.panel_chou1.btn_4:setTap(c_func(self.pressTokenFive, self))

    --这里要加载动画

    local cnt = view.panel_fb.ctn_1
    local ani = self:createUIArmature("UI_lottery","UI_lottery_dijichouguang",cnt,true,GameVars.emptyFunc)
    ani:getBone("layer3"):visible(false)

    local ctn2 = view.panel_chou1.ctn_1
    local aniBtn= self:createUIArmature("UI_common","UI_common_zhonganniu", ctn2, true)
    aniBtn:setScale(0.85)
end
--[[
更新右侧面板
]]
function LotteryMainView:updateRightView( view )

    

    view.panel_chou2.btn_1:setTap(c_func(self.pressGoldOne, self))
    view.panel_chou2.btn_3:setTap(c_func(self.pressGoldTen, self))

    local cnt = view.panel_zhubao_2.ctn_1
    view.panel_zhubao_2.mc_1:setVisible(false)

    local ani = self:createUIArmature("UI_lottery","UI_lottery_gaojichouka",cnt,true,GameVars.emptyFunc)
    ani:visibleBone("layer3",false)
    local nodeDisplay = ani:getBoneDisplay("node")
    self.nodeDisplay = nodeDisplay
    nodeDisplay:gotoAndPause(1)

    local node2Display = ani:getBoneDisplay("node2")
    node2Display:gotoAndPause(1)
    self.node2Display = node2Display

    --右侧面板上的外框动画
    local waikuangAni=self:createUIArmature("UI_lottery","UI_lottery_waikuang",self.panel_2.ctn_2,true,GameVars.emptyFunc)
    waikuangAni:pos(204,-512/2-21)


    local cntBtn = view.panel_chou2.ctn_1
    local aniBtn = self:createUIArmature("UI_common","UI_common_zhonganniu", cntBtn, true)
    aniBtn:setScale(0.85)
end






--[[
点击事件
]]
function LotteryMainView:doLeftViewClick(  )
    echo("左侧面板点击事件")
    --状态1 表示在上面   没有露出按钮  2 表示露出按钮了  3 表示中间态
    if self.leftView.leftState == "1" then
        --self.leftAni:gotoAndPause(1)
        self.leftAni:playWithIndex(0,false)
        self.leftView.leftState = "3"
        self.leftView:delayCall(function() self.leftView.leftState = "2" end,0.4)
    elseif self.leftView.leftState =="2" then
        self.leftAni:playWithIndex(1,false)
        self.leftView.leftState = "3"
        self.leftView:delayCall(function() self.leftView.leftState = "1" end,0.4)
    else
        echo("中间态不用处理")
    end
    -- self.leftAni:gotoAndPause(1)
    -- self.leftAni:playWithIndex(0,false)
end

function LotteryMainView:doRightViewClick(  )
    echo("右侧面板点击事件")
    --self.rightView:setTouchEnabled(false)
    --self:doViewClick(self.panel_2.scroll_1)
    --echo("self.rightView.rightState",self.rightView.rightState,"----------")
    if  self.rightView.rightState == "1" then
        self.rightAni:playWithIndex(0,false)
        self.rightView.rightState = "3"
        self.rightView:delayCall(function() self.rightView.rightState="2"  end,0.4)
    elseif self.rightView.rightState == "2" then
        self.rightAni:playWithIndex(1,false)
        self.rightView.rightState = "3"
        self.rightView:delayCall(function() self.rightView.rightState="1" end,0.4)    
    end
end

-- function LotteryMainView:doViewClick( scroll )
--     self._scrollTouch=nil
--     local curState  = scroll.curState
--     local toState = curState
--     if curState == "1" then
--         toState = "2"
--     else
--         toState = "1"
--     end
--     local offset = 0
--     if toState == "1" then
--         offset = 0
--     else
--         offset = 149
--     end
--     --scroll:easeMoveto(0, offset, nil)
--     scroll.scrollNode:runAction(cc.MoveTo:create(0.4,cc.p(0,offset)))
--     --self:delayCall(function() end)
--     scroll.curState = toState
-- end


--[[
左侧的滑动条的事件
]]
-- function LotteryMainView:leftScroll( event )
--     self:chgScrollState(self.panel_1.scroll_1, event,"left")
-- end
-- function LotteryMainView:rightScroll( event )
--     self:chgScrollState(self.panel_2.scroll_1, event,"rgiht")
-- end

--[[
内部scrollNode的坐标为0,149
]]
-- function LotteryMainView:chgScrollState( scroll,event,tag)
--     --dump(event)
--     --if event.name=="clicked" then
--     local view
--     if tag=="left" then
--         view = self.leftView
--     else
--         view = self.rightView
--     end
            
--         if event.name == "ended" then
--             echo("松开事件--ended")
--             --dump(event)
--             local y = event.y
--             local offset = 0
--             local toState = scroll.curState
--             --echo("curState",scroll.curState)
--             --dump(self._scrollTouch)
--             if self._scrollTouch and self._scrollTouch.y then
--                 offset = y - self._scrollTouch.y
--             else
--                 return
--             end
--             if math.abs(offset)>20 then
--                 if offset>0 then
--                     toState = "2"
--                 else
--                     toState ="1"
--                 end
--             end
--             --echo("toState",toState)
--             local moveOffsetY = 1
--             if toState == "2" then
--                 moveOffsetY = 149
--             else
--                 moveOffsetY =0
--             end
--             scroll.curState = toState
--             --scroll:easeMoveto(0, moveOffsetY, nil)
--             scroll.scrollNode:runAction(cc.MoveTo:create(0.4,cc.p(0,moveOffsetY)))
--             self:delayCall(function() view:setTouchEnabled(true) end,0.4)
--             self._scrollTouch =nil
--         elseif event.name == "began" then
--            echo("开始移动")
--            self._scrollTouch ={}
--            self._scrollTouch.x = event.x
--            self._scrollTouch.y = event.y
--            local x,y = scroll.scrollNode:getPosition()
--            echo(x,y,"内部位置-----")
--         elseif event.name == "scrollEnd" then
--             echo("scrollEnd-----")
--             -- local toState = scroll.curState
--             -- local moveOffsetY = 1
--             -- if toState == "2" then
--             --     moveOffsetY = 5000
--             -- else
--             --     moveOffsetY = -5000
--             -- end
--             -- scroll:easeMoveto(0, moveOffsetY, nil)
--             self._scrollTouch =nil
--         else
            
--         end
-- end

function LotteryMainView:initAnim()
    local offsetY = -65
    local offsetY2 = -40
    --加载抽卡特效
    -- FuncArmature.loadOneArmatureTexture("UI_lottery", nil, true)
    -- 场景动画
    local lotteryAnim = self:createUIArmature("UI_lottery", "UI_lottery_changtai",self.ctn_1, true, GameVars.emptyFunc)
    lotteryAnim:pos(0,80)
    lotteryAnim:startPlay(true)
end


-- 播放卷轴打开、关闭动画
function LotteryMainView:playScrollAnim(closeAnim,openAnim,ropeAnim,callBack)
    -- ropeAnim:playLabel("shou_qi")
    -- 收起来动画
    closeAnim:getAnimation():playWithIndex(1,0,0)

    local closeCallBack = function(event)

        closeAnim:setVisible(false)

        openAnim:setVisible(true)
        openAnim:getAnimation():playWithIndex(0,0,0)

        local openCallBack = function(event)
            -- ropeAnim:playLabel("chang_tai")

            if callBack ~= nil then
                callBack()
            end
        end

        local delayTime = 15 / GAMEFRAMERATE
        openAnim:delayCall(c_func(openCallBack),delayTime)
    end

    local delayTime = 10 / GAMEFRAMERATE
    closeAnim:delayCall(c_func(closeCallBack),delayTime)
end

-- 开启cd
function LotteryMainView:startLotteryCd()
    echo("LotteryMainView:startLotteryCd")
    echo("self.checkCd",self.checkCd,"self=",self)
    self:checkCd()
end

-- 检查cd
function LotteryMainView:checkCd()
    local leftTokenCdSecond = TimeControler:getCdLeftime("CD_ID_LOTTERY_TOKEN_FREE")
    local leftGoldCdSecond = TimeControler:getCdLeftime("CD_ID_LOTTERY_GOLD_FREE")

    -- echo("checkCd= ",leftTokenCdSecond,leftGoldCdSecond)
    self:updateCdTime()
    if tonumber(leftTokenCdSecond) > 0 or tonumber(leftGoldCdSecond) > 0 then
        self:schedule(self.updateCdTime, 1 )
    end
end
    
-- 更新cd时间
function LotteryMainView:updateCdTime()
    
    local leftTokenCdSecond = TimeControler:getCdLeftime("CD_ID_LOTTERY_TOKEN_FREE")
    local leftGoldCdSecond = TimeControler:getCdLeftime("CD_ID_LOTTERY_GOLD_FREE")

    -- echo("updateCdTime....",leftTokenCdSecond,leftGoldCdSecond)

    if tonumber(leftTokenCdSecond) <= 0 then
        -- cd结束 令牌抽免费
        self.isTokenFree = true 

        -- 显示免费
        --self.tokenMainPanel.mc_2:showFrame(1)
        self.leftView.panel_fb.panel_1.mc_1:showFrame(1)
        --echo("_____xiaohuangdiankejian")
         --小黄点可见
        self.leftView.panel_fb.panel_1.panel_1:setVisible(true)
         
        --消耗显示免费
        self.leftView.panel_chou1.mc_1:showFrame(2)
       
        -- 显示小红点
        --self.tokenMainPanel.panel_red:setVisible(true)
        self.leftView.panel_chou1.panel_red:setVisible(true)

        local ctn = self.leftView.panel_chou1.ctn_1
        ctn:setVisible(true)
        
        


    else
        self.isTokenFree = false

        leftTokenCdSecond = fmtSecToHHMMSS(leftTokenCdSecond)
        --self.tokenMainPanel.mc_2:showFrame(2)
        self.leftView.panel_fb.panel_1.mc_1:showFrame(2)
        --小黄点
        --echo("黄点不可见-------------")
        self.leftView.panel_fb.panel_1.panel_1:setVisible(false)
         --self.panel_1.panel_ct.panel_fb.panel_1.panel_1:visible(false)
        -- 设置倒计时
        self.leftView.panel_fb.panel_1.mc_1.currentView.txt_1:setString(leftTokenCdSecond)

        -- 设置倒计时
        --self.tokenMainPanel.mc_2.currentView.txt_1:setString(leftTokenCdSecond)
        
        --显示消耗
        self.leftView.panel_chou1.mc_1:showFrame(1)
        --显示小红点
        self.leftView.panel_chou1.panel_red:setVisible(false)
        local ctn = self.leftView.panel_chou1.ctn_1
        ctn:setVisible(false)


       
    end

   if tonumber(leftGoldCdSecond) <= 0 then
        -- cd结束 令牌抽免费
        self.isGoldFree = true 

        -- 显示免费
        self.rightView.panel_zhubao_2.panel_1.mc_1:showFrame(1)
        --小黄点
        self.rightView.panel_zhubao_2.panel_1.panel_1:setVisible(true)
        

        --显示消耗
        self.rightView.panel_chou2.mc_1:showFrame(2)
        --显示红点
        self.rightView.panel_chou2.panel_red:setVisible(true)

        local cntBtn = self.rightView.panel_chou2.ctn_1
        cntBtn:setVisible(true)
        --多少次后必出卡 todo dev
        --self.rightView.panel_chou2.mc_3:

        --self.goldMainPanel.mc_2:showFrame(1)
        -- 显示小红点
        --self.goldMainPanel.panel_red:setVisible(true)
        -- 隐藏actionPanel中的倒计时
        --self.goldActionPanel.txt_1:setVisible(false)

        -- actionPanel相关设置
        -- 隐藏actionPanel中的倒计时
        --self.goldActionPanel.txt_1:setVisible(false)
        -- 显示免费
        --self.goldActionPanel.mc_1:showFrame(2)
        --self.goldActionPanel.panel_red:setVisible(true)
        --小黄点
        
    else
        self.isGoldFree = false

        leftGoldCdSecond = fmtSecToHHMMSS(leftGoldCdSecond)
        self.rightView.panel_zhubao_2.panel_1.mc_1:showFrame(2)
        self.rightView.panel_zhubao_2.panel_1.panel_1:setVisible(false)
        --self.goldMainPanel.mc_2:showFrame(2)
        -- 设置倒计时
        --self.goldMainPanel.mc_2.currentView.txt_1:setString(leftGoldCdSecond)
        self.rightView.panel_zhubao_2.panel_1.mc_1.currentView.txt_1:setString(leftGoldCdSecond)


        --显示消耗
        self.rightView.panel_chou2.mc_1:showFrame(1)
        self.rightView.panel_chou2.panel_red:setVisible(false)
        
        local cntBtn = self.rightView.panel_chou2.ctn_1
        cntBtn:setVisible(false)

        --self.goldActionPanel.txt_1:setVisible(true)
        --local tokenTimeStr = GameConfig.getLanguageWithSwap("tid_lottery_1003",leftGoldCdSecond)
        --self.goldActionPanel.txt_1:setString(tokenTimeStr)

        -- 隐藏小红点
        --self.goldMainPanel.panel_red:setVisible(false)

        -- actionPanel相关设置
        -- self.goldActionPanel.txt_1:setVisible(true)
        -- local tokenTimeStr = GameConfig.getLanguageWithSwap("tid_lottery_1003",leftGoldCdSecond)
        -- self.goldActionPanel.txt_1:setString(tokenTimeStr)

        -- self.goldActionPanel.mc_1:showFrame(1)
        -- self.goldActionPanel.mc_1.currentView.txt_1:setString(LotteryModel:getGoldLotteryOneCost())
        -- self.goldActionPanel.panel_red:setVisible(false)
        
    end
end
    
-- 隐藏抽卡panel
function LotteryMainView:hideLotteryPanel()
    -- local moveX = self.panelMoveX
    -- for i=1,#self.movePanelObjArray do
    --     local arr = self.movePanelObjArray[i]
    --     local viewArr = arr.view
    --     local propArr = arr.propArr

    --     for k=1,#viewArr do
    --         local view = viewArr[k]
    --         local prop = {}
    --         prop.x = view:getPositionX()
    --         prop.opacity = view:getOpacity()

    --         table.insert(propArr, prop)
    --         self:doDisappearAnim(view,moveX,i)
    --     end
    -- end
end

-- 重置抽卡panel
function LotteryMainView:resetLotteryPanel()
    self:setUIClickEnable(true)
    if self.moveAni then
        self.moveAni:gotoAndPause(1)
    end
    
end

-- 左侧道具列表动画特效
function LotteryMainView:doDisappearAnim(target,width,way)
    local targetWidth = width

    local panelLeft = target

    local x,y = panelLeft:getPosition()
    -- if self.panelLeftViewX == nil then
    --     self.panelLeftViewX = x
    -- end

    -- 出现动画（移动+渐现)
    -- panelLeft:pos(self.panelLeftViewX - targetWidth,y)
    local targetPosX = 0
    if way == 1 then
        targetPosX = x - targetWidth
    else
        targetPosX = x + targetWidth
    end
    
    -- panelLeft:opacity(0)
    local moveAction = act.moveto(0.6,targetPosX,y)
    local alphaAction = act.fadeout(0.6)
    local disappearAnim = cc.Spawn:create(moveAction,alphaAction) 
    -- local disappearAnim = cc.Spawn:create(moveAction) 

    panelLeft:stopAllActions()
    panelLeft:runAction(
        cc.Sequence:create(disappearAnim)
    )
end
--[[
self.leftView
self.rightView
更新内容
]]
function LotteryMainView:updateUI()
    -- token cost
    -- 5连抽消耗
     --self.tokenActionPanel.txt_2:setString(LotteryModel:getTokenLotteryFiveCost())
     self.leftView.panel_chou1.txt_2:setString(LotteryModel:getTokenLotteryFiveCost())

    -- -- 是否做过十连抽，提醒不同
    if self.nodeDisplay and self.node2Display then
        --echo(self.isFirstGoldTen,"==============")
        if self.isFirstGoldTen then

            self.nodeDisplay:gotoAndPause(1)
            self.node2Display:gotoAndPause(1)
         else
            --echo("调到第二帧======")
            self.nodeDisplay:gotoAndPause(2)
            self.node2Display:gotoAndPause(2)
        end
    else
        --echo("self.nodeDisplay  or self.node2Display is null"  )
    end
    

     -- 10连抽倒计次数
     local leftTimes = LotteryModel.maxTimes - LotteryModel:oneTimes() % LotteryModel.maxTimes
     leftTimes = leftTimes - 1
     if leftTimes == 0 then
         --self.goldActionPanel.mc_3:showFrame(2)
         self.rightView.panel_chou2.mc_3:showFrame(2)
     else
         self.rightView.panel_chou2.mc_3:showFrame(1)
         local timesMc = self.rightView.panel_chou2.mc_3.currentView.mc_1
         timesMc:showFrame(10-leftTimes)
     end
     -- gold cost
     -- 钻石十连抽消耗
     self.rightView.panel_chou2.txt_2:setString(LotteryModel:getGoldLotteryTenCost())
end

function LotteryMainView:playAnimCompleteCallBack()
    self:resumeUIClick()
end

-- 令牌抽
-- function LotteryMainView:pressTokenLottery()
--     echo("令牌点击返回按钮事件----")
--     -- self:disabledUIClick()
--     -- -- mainPanel收起来,actionPanel打开
--     -- self:playScrollAnim(self.anim_token_main,self.anim_token_action,self.anim_token_rope,c_func(self.playAnimCompleteCallBack,self))
-- end

-- 令牌抽返回
-- function LotteryMainView:pressTokenBack()
--     self:disabledUIClick()
--     -- actionPanel收起来,mainPanel打开
--     self:playScrollAnim(self.anim_token_action,self.anim_token_main,self.anim_token_rope,c_func(self.playAnimCompleteCallBack,self))
-- end

-- 钻石抽
-- function LotteryMainView:pressGoldLottery()
--     self:disabledUIClick()
--     self:playScrollAnim(self.anim_gold_main,self.anim_gold_action,self.anim_gold_rope,c_func(self.playAnimCompleteCallBack,self))
-- end

-- 钻石抽返回
-- function LotteryMainView:pressGoldBack()
--     self:playScrollAnim(self.anim_gold_action,self.anim_gold_main,self.anim_gold_rope)
-- end

-- 抽卡结束回调
function LotteryMainView:lotteryCallBack(data)
    if data.result then
        echo("lottery reward is :")
        -- dump(data.result)
        if self.lotteryType == LotteryModel.lotteryType.TYPE_TOKEN then
            -- 如果是免费抽的
            if self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_TOKEN_FREE then
                -- 服务端不会推送该值，客户端自动加1更新
                LotteryModel:addTokenLotteryTimes()
				self:checkCd()
            end
        elseif self.lotteryType == LotteryModel.lotteryType.TYPE_GOLD then
            -- 如果是免费抽的
            if self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_GOLD_FREE then
				self:checkCd()
            -- 如果是不免费单抽
            elseif self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_GOLD_ONE then
                -- 服务端不会推送该值，客户端自动加1更新
                LotteryModel:addGoldLotteryTimes()
            end
        end

        -- 打开奖品结果界面
        local params = {
            reward = data.result.data.reward,
            lotteryActionType = self.lotteryActionType,
            lotteryType = self.lotteryType
        }

        -- 更新必送完整法宝倒计次数等
        self:updateUI()
        -- 展示抽卡结果
        self:showRewardView(params)
        -- 发送小红点状态
        LotteryModel:sendRedStatusMsg()
    end
end

-- 再次抽卡成功
function LotteryMainView:doLotteryAgainSuccess(event)
    -- 更新必送完整法宝倒计次数等
    self:updateUI()

    self:showRewardView(event.params.data)
end

-- 展示抽卡结果，先播放抽卡动画再打开抽卡结果界面
function LotteryMainView:showRewardView(params,isDirect)
    -- echo("铸宝网络回调的方法------")
    -- dump(params)
    -- echo("铸宝网络回调的方法------")
    self:setUIClickEnable(false)
    local callBack = function(event)
        if self.curUIState == "Aniplaying" then
            --echo("打开奖品结果界面-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=")
            --dump(params)
           WindowControler:showWindow("LotteryShowReward",params)
           self.curUIState = "Normal"
       else
           --echo("不用打开界面，已经打开========")
        end
        self.lotteryCallBackParams = nil
    end
    if isDirect then
       --echo("直接调用XXXXXXXX")
       callBack() 
   else
        --echo("播放动画回调================")
        self:playLotteryAnim(callBack)
        self.lotteryCallBackParams = params
        self.curUIState = "Aniplaying"
    end

    
end




-- 播放抽卡特效，之后展示抽卡结果界面
function LotteryMainView:playLotteryAnim(callBack)
    --将两个面板移动开
    if self.moveAni then
        self.moveAni:playWithIndex(0)
    end

    local doLotteryAnim 
    local clearAni = function (  )
        --echo("播放完成了")
        doLotteryAnim:clear()
        --if callBack then
         --   callBack()
        --end
    end


    doLotteryAnim = self:createUIArmature("UI_lottery_chouka", "UI_lottery_chouka",self.ctn_1,false,clearAni)
    --doLotteryAnim:pos(-10,0)
    local bgSp  = display.newSprite(FuncRes.iconBg("lottery_bg_beijing.png"))
    --echo(bgSp:getContentSize().width,bgSp:getContentSize().height,"------------------")
    FuncArmature.changeBoneDisplay(doLotteryAnim,"layer2a",bgSp)
    --FuncArmature.setArmaturePlaySpeed(doLotteryAnim,0.1)
    doLotteryAnim:pos(-5,80)

    self:delayCall(
        function() 
            --echo("时间到------")
            if callBack then callBack() end 
        end,44/GAMEFRAMERATE )
end

-- 令牌单抽或免费抽
function LotteryMainView:pressTokenOne()
    if self.leftView.leftState ~="1" then
        return
    end
    echo("令牌抽1个")
    self.lotteryType = LotteryModel.lotteryType.TYPE_TOKEN
    local times = 1

    if not LotteryModel:isTokenLotteryInCd() then
        self.isTokenFree = true
    else
        self.isTokenFree = false
    end

    -- 是否是免费抽
    if self.isTokenFree then
        self.lotteryActionType = LotteryModel.lotteryActionType.TYPE_TOKEN_FREE
        LotteryServer:doTokenLottery(times,c_func(self.lotteryCallBack,self), true)
        --self:setUIClickEnable(false)
    else
        self.lotteryActionType = LotteryModel.lotteryActionType.TYPE_TOKEN_ONE
        if LotteryModel:isTokenEnough(times) then
            LotteryServer:doTokenLottery(times,c_func(self.lotteryCallBack,self))
            --self:setUIClickEnable(false)
        else
            WindowControler:showTips("令牌不足")
            return
        end
    end

    self:hideLotteryPanel()
end

-- 令牌5连抽
function LotteryMainView:pressTokenFive()
    if self.leftView.leftState ~="1" then
        return
    end
    echo("令牌抽5个")

    self.lotteryType = LotteryModel.lotteryType.TYPE_TOKEN
    self.lotteryActionType = LotteryModel.lotteryActionType.TYPE_TOKEN_FIVE
    local times = 5

    if LotteryModel:isTokenEnough(times) then
        LotteryServer:doTokenLottery(times,c_func(self.lotteryCallBack,self))
        --self:setUIClickEnable(false)
    else
        WindowControler:showTips("令牌不足")
        return
    end

    self:hideLotteryPanel()
end

-- 钻石单抽或免费抽
function LotteryMainView:pressGoldOne()
    --echo("------pressGoldOne()",self.rightView.rightState)
    if self.rightView.rightState ~= "1" then
        return
    end
    echo("钻石抽1个")
    self.lotteryType = LotteryModel.lotteryType.TYPE_GOLD
    local times = 1
    local isFree = true

    if not LotteryModel:isGoldLotteryInCd() then
        self.isGoldFree = true
    else
        self.isGoldFree = false
    end

    -- 是否是免费抽
    if self.isGoldFree then
        self.lotteryActionType = LotteryModel.lotteryActionType.TYPE_GOLD_FREE
        LotteryServer:doGoldOneLottery(c_func(self.lotteryCallBack,self),isFree)
        --self:setUIClickEnable(false)
    else
        -- 钻石抽一次
        self.lotteryActionType = LotteryModel.lotteryActionType.TYPE_GOLD_ONE
        if LotteryModel:isGoldEnough(times) then
            LotteryServer:doGoldOneLottery(c_func(self.lotteryCallBack,self))
            --self:setUIClickEnable(false)
        else
            --WindowControler:showTips(GameConfig.getLanguage("tid_buy_jump_gold_1004"));
            WindowControler:showWindow("RechargeMainView")
            return
        end
    end

    self:hideLotteryPanel()
end

-- 钻石十连抽
function LotteryMainView:pressGoldTen()
    if self.rightView.rightState ~= "1" then
        return
    end
    echo("钻石抽10个")
    
    self.lotteryType = LotteryModel.lotteryType.TYPE_GOLD
    self.lotteryActionType = LotteryModel.lotteryActionType.TYPE_GOLD_TEN
    local times = 10

    if LotteryModel:isGoldEnough(times) then
        LotteryServer:doGoldTenLottery(c_func(self.lotteryCallBack,self))
        --self:setUIClickEnable(false)
    else
        --WindowControler:showTips(GameConfig.getLanguage("tid_buy_jump_gold_1004"));
        WindowControler:showWindow("RechargeMainView")
        return
    end

    self:hideLotteryPanel()
end


--[[
设置UI上的按钮是否能够点击
]]
function LotteryMainView:setUIClickEnable( val )
    if val then
        self:resumeUIClick()
    else
        self:disabledUIClick()
    end

end

-- 令牌预览
function LotteryMainView:pressTokenPreview()
    local params = {
        lotteryType = LotteryModel.lotteryType.TYPE_TOKEN
    }
    WindowControler:showWindow("LotteryPreviewReward",params)
end

-- 钻石预览
function LotteryMainView:pressGoldPreview()
    local params = {
        lotteryType = LotteryModel.lotteryType.TYPE_GOLD
    }
    WindowControler:showWindow("LotteryPreviewReward",params)
end


function LotteryMainView:press_btn_back()
    -- 关闭抽卡时 给法宝详情UI发消息 
    -- 不好 需要改 这个消息应该放到碎片增加的时候发放
    EventControler:dispatchEvent(TreasureEvent.FABAO_SUIPIAN);  
    self:startHide()
end

-- function LotteryMainView:startHide()
--     LotteryMainView.super.startHide(self)
--     echo("关闭 LotteryMainView")
-- end

return LotteryMainView;
