local BattleLoadingView = class("BattleLoadingView", UIBase);
local scheduler = require("framework.scheduler")
function BattleLoadingView:ctor(winName,loadingId)
    BattleLoadingView.super.ctor(self, winName);

    self:setNodeEventEnabled(true)
    -- 获取loadingId
    self.loadingId = loadingId
    --self.loadingId = 3006
    --echo("初始化进来的LoadingId数据------------")
    if self.loadingId == nil or self.loadingId == "" then
        echoError("self.loadingId is ",self.loadingId)
        return
    else
        echo("self.loadingId is ",self.loadingId)
    end

    self.DEBUG = false
end


--[[
界面进入
]]
function BattleLoadingView:onEnter(  )
    echo("界面进入")
end

--[[
界面退出
]]
function BattleLoadingView:onExit(  )
    echo("界面退出")
    if self.secondTickScheduler then
            scheduler.unscheduleGlobal(self.secondTickScheduler) 
            self.secondTickScheduler = nil
    end
    if self.thirdTickScheduler then
        scheduler.unscheduleGlobal(self.thirdTickScheduler) 
        self.thirdTickScheduler = nil
    end

end


function BattleLoadingView:loadUIComplete()
    --UI适配
    -- local panel1Mc5View = 1 self.panel_1.mc_5.getViewByFrame(1)
    -- local panel1Mc5View.txt_1: = 1


	self:registerEvent();
    self:initData()
    self:initView()

    -- --加载抽卡特效
    FuncArmature.loadOneArmatureTexture("UI_battle", nil, true)
    self.lightAnim = FuncArmature.createArmature("UI_battle_xuetiao_zhedang", self.panel_jindu.ctn_dongxiao, false, GameVars.emptyFunc)
    self.lightAnim:startPlay(true)
    self.lightAnim:zorder(100)
    self.lightAnim:pos(22,-24)

    -- if self.isMutilMatchMode then
    self:simulateMutilMatch()
    -- else
    --     self:simulateSingleMatch()
    -- end

     self:updateRandomTips()

    echo("\n\n---------BattleLoadingView loadUIComplete self.loadingId=",self.loadingId)
end 

function BattleLoadingView:registerEvent()
	BattleLoadingView.super.registerEvent();

    -- 战斗匹配的所有用户(我方人员+敌方人员)   这是战斗中发送的 battleInfo信息中 没有战斗
    EventControler:addEventListener(LoadEvent.LOADEVENT_USERENTER,self.matchUsers,self)

    -- 加载完毕一个用户的资源 
    EventControler:addEventListener(LoadEvent.LOADEVENT_USERCOMPLETE,self.loadOneUserComplete,self)

    -- loading 全部加载完毕
    EventControler:addEventListener(LoadEvent.LOADEVENT_BATTLELOADCOMP,self.loadAllUsersComplete,self)

    -- 匹配超时
    EventControler:addEventListener(LoadEvent.LOADEVENT_MATCH_TIME_OUT,self.onMatchTimeOut,self)
end

function BattleLoadingView:initData()
    self.userLoadStatus = {
        STATUS_PREPARE = 1,         --准备中
        STATUS_LOAD_COMPLETE = 2,   --待战斗
    }

    -- 定义常量
    self.maxTipsNum = 99 --tid901-tid999
    self.tipMinTid = 900  --tip tid 最小值为900

    self.curPercent = 10
    self.maxPercent = 100
    -- 匹配是否已经完成
    self.isMatchComplete = false
    -- 是否在模拟加速中
    self.isSpeedUp = false

    -- 初始化loading数据 
    self.loadingData = FuncLoading.getLoadingData(self.loadingId)
    -- echo("loadingData的数据")
    -- dump(self.loadingData)
    -- echo("loadingData的数据")

    -- 是否是匹配模式
    -- self.isMutilMatchMode = true
    -- local single = self.loadingData.single
    -- if tonumber(single) == 1 then
    --     self.isMutilMatchMode = false
    -- end

    -- -- 模拟数据
    -- self.gameData = {
    --     camp1 = 
    --     {
    --         {rid="1",sec="sec_1",name="张三",lv=10},
    --         {rid="2",sec="sec_2",name="test1",lv=11},
    --         {rid="dev_503",sec="sec_3",name="Me",lv=9},
    --         {rid="4",sec="sec_4",name="test3",lv=11},
    --     },

    --     waveData = 
    --     {
    --         {rid="5",sec="sec_1",name="张三",lv=10},
    --         {rid="6",sec="sec_1",name="张三",lv=10},
    --         {rid="7",sec="sec_1",name="张三",lv=10},
    --         {rid="8",sec="sec_1",name="张三",lv=10},
    --     },
    -- }
end

function BattleLoadingView:initView()
    --进度条
    self.progress = self.panel_jindu.progress_jindu
    self.progress:setDirection(ProgressBar.l_r)
    self.progress:setPercent(0)
    --进度条上的文字
    self.percentTxt = self.panel_jindu.txt_1
    self.percentTxt:setString("0%")

    -- 道友panel
    -- self.friendPanel = self.panel_lianjie
    -- self.infoPanel = self.panel_xinxi

    -- 初始化道友panel
    -- local maxFriendsNum = 5
    -- for i=1,maxFriendsNum do
    --     self.friendPanel["panel_"..i]:setVisible(false)
    -- end

    -- if self.isMutilMatchMode then
    --     self.friendPanel:setVisible(true)
    --     self.infoPanel:setVisible(true)
    -- else
    --     self.friendPanel:setVisible(false)
    --     self.infoPanel:setVisible(false)
    -- end

    -- 添加全屏背景
    local bg = display.newSprite(FuncRes.iconBg(self.loadingData.img_bg)):anchor(0,1)
    local rect = bg:getContainerBox()
    local scaleX = GameVars.width / rect.width
    local scaleY = GameVars.height / rect.height
    bg:setScaleX(scaleX)
    bg:setScaleY(scaleY)
    bg:pos(- GameVars.UIOffsetX,GameVars.UIOffsetY)
    self:addChild(bg,0)

    --添加玩法图标
    -- echo("self.loadingData=====================")
    -- dump(self.loadingData)
    -- echo("self.loadingData=====================")
    local playIcon = display.newSprite(FuncRes.iconSys(self.loadingData.icon))
    self.panel_xinxi.ctn_head:addChild(playIcon)
    --标题
    self.panel_xinxi.txt_name:setString(GameConfig.getLanguage(self.loadingData.translateName))
    --描述
    self.panel_xinxi.txt_miaoshu:setString(GameConfig.getLanguage(self.loadingData.des1))
    self:showFirstForReady()
    self:showSecondForLoading()
    self:showThirdForLoading()

end

--[[
加载自己素颜
]]
function BattleLoadingView:showFirstForReady()
    self.panel_1.mc_5:showFrame(1)
    local curView = self.panel_1.mc_5.currentView
    local serverName = LoginControler:getServerNameById(LoginControler:getServerId())
    curView.txt_1:setAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    serverName = GameConfig.getLanguageWithSwap("#tid_gvp_zone_name", serverName)
    curView.txt_1:setString(serverName)  --"【"..serverName.."】"
    local name = UserModel:name()
    curView.txt_name1:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
    curView.txt_name1:setString(name)

    local level = UserModel:level()
    curView.txt_level1:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
    local lvStr = GameConfig.getLanguageWithSwap("#tid_gvp_userlv",level) --level.."级"
    curView.txt_level1:setString(lvStr)
    local nameWidth = FuncCommUI.getStringWidth(name, curView.txt_name1:getFontSize(), curView.txt_name1:getFont())
    --local nameWidth,nameHeight = curView.txt_name1:getContentSize().width
    --echo("少侠的字体宽度---",nameWidth,"===============")
    local namex,namey = curView.txt_name1:getPosition()
    curView.txt_name1:pos(namex,namey)
    local serPosx,serPosy = curView.txt_1:getPosition()
    --echo("serPosx,serPosy","---",serPosx,serPosy,"============")
    curView.txt_1:pos(serPosx+(165-nameWidth)/2-20,serPosy)
    local lvPosx,lvPosy = curView.txt_level1:getPosition()
    --echo("lvPosy,lvPosy","----",lvPosx,lvPosy,"================")
    curView.txt_level1:pos(lvPosx-(165-nameWidth)/2+20,lvPosy)
    self.panel_1.mc_4:showFrame(1)
    local roleView = self.panel_1.mc_4.currentView
    --echo("加载个人的素颜法宝,回调加载个人的本命法宝")
    --加载素颜法宝的容器
    --roleView.ctn_1
    --local suyan = FuncChar.getSpineAni(UserModel:avatar(),UserModel:level())
    -- local suyan = NatalModel:getCharOnNatal(6)
    -- suyan:setScale(1.75)
    -- roleView.ctn_1:addChild(suyan)

    -- local treasureId
    -- if  self.firstUser and self.firstUser.treasureNatal and self.firstUser.treasureNatal.hid then
    --     treasureId = self.firstUser.treasureNatal.hid
    -- end
    -- local spine
    -- if treasureId then
    --     echo("有本命法宝加载")
    --     --LoginControler:writeDumpToFile("有本命法宝加载----------------")
    --     spine = FuncChar.getCharOnTreasure(tostring(self.firstUser.avatar),self.firstUser.lv,treasureId)
    -- else
    --     echo("没有本命法宝加载=-=---------")
    --     --LoginControler:writeDumpToFile("没有本命法宝加载=-=---------")
    --     spine = FuncChar.getSpineAni(tostring(UserModel:avatar()),UserModel:level(),treasureId)
    -- end
    -- 6:山神  7：火神  8：雪妖
    --这种方法很2  todo dev
    local sys = "6"
    if toint(self.loadingData.id )> 20100 then
        sys = "4"
    elseif toint(self.loadingData.id) >= 3001 and  toint(self.loadingData.id)<=3005 then
        sys= "6"
    elseif toint(self.loadingData.id) >= 3006 and  toint(self.loadingData.id)<=3010 then
        sys = "7"
    elseif toint(self.loadingData.id) >= 3011 and  toint(self.loadingData.id)<=3015 then
        sys = "8"
    elseif toint(self.loadingData.id) >= 3016 and  toint(self.loadingData.id)<=3020 then
        sys = "6"
    elseif toint(self.loadingData.id) >= 3021 and  toint(self.loadingData.id)<=3025 then
        sys = "7"
    elseif toint(self.loadingData.id) >= 3026 and  toint(self.loadingData.id)<=3030 then
        sys = "8"
    end
    local spine = NatalModel:getCharOnNatal(sys)
    spine:setScale(1.75)
    --suyan:pos(150/2,-200)
    roleView.ctn_1:addChild(spine)






    --战力
    local power = UserModel:getAbility()
    local powerValueTable = number.split(power)
    local len = table.length(powerValueTable);
    if len > 6 then 
        echo("-----------warning: power is over 999999!!!----------");
        return;
    end 
    self.panel_1.mc_6:showFrame(len);
    for k, v in pairs(powerValueTable) do
        local mcs = self.panel_1.mc_6:getCurFrameView()
        mcs["mc_zi" .. tostring(k)]:showFrame(v + 1);
    end
    --状态准备中
    self.panel_1.mc_1:showFrame(1)

    --底座
    self.panel_1.mc_2:showFrame(self.loadingData.taizi)
    --衬底
    self.panel_1.mc_3:showFrame(self.loadingData.chendi)

end

--[[
第一个人就是自己
]]
function BattleLoadingView:showFirstCompelte(  )
    --echo("自己准备好了XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
    self.panel_1.mc_1:showFrame(2)
    -- local roleView = self.panel_1.mc_4.currentView
    -- --echo("加载本命法宝")
    -- roleView.ctn_1:removeAllChildren()

    -- local treasureId
    -- --dump(self.firstUser.treasureNatal)
    -- if  self.firstUser and self.firstUser.treasureNatal and self.firstUser.treasureNatal.hid then
    --     treasureId = self.firstUser.treasureNatal.hid
    -- end
    -- local spine
    -- if treasureId then
    --     --echo("有本命法宝加载")
    --     --LoginControler:writeDumpToFile("有本命法宝加载----------------")
    --     spine = FuncChar.getCharOnTreasure(tostring(self.firstUser.avatar),self.firstUser.lv,treasureId)
    -- else
    --     --echo("没有本命法宝加载=-=---------")
    --     --LoginControler:writeDumpToFile("没有本命法宝加载=-=---------")
    --     spine = FuncChar.getSpineAni(tostring(UserModel:avatar()),UserModel:level(),treasureId)
    -- end

    -- --local suyan = NatalModel:getCharOnNatal(6)
    -- spine:setScale(1.75)
    -- --suyan:pos(150/2,-200)
    -- roleView.ctn_1:addChild(spine)
end

--[[
加载第二个人的剪影
]]
function BattleLoadingView:showSecondForLoading()
    --头顶的标题
    self.panel_2.mc_5:setVisible(false)
    --剪影
    self.panel_2.mc_4:showFrame(2)
    --战力
    --self.panel_2.mc_6:setVisible(false)

    --状态
    self.secondLeftTime = 9
    self.panel_2.mc_1:showFrame(3)
    local updateTime = function (  )
        --不听得更新时间
        --echo("更新匹配剩余时间")
        if self.secondLeftTime <= 0 then
            self.secondLeftTime = 0
            if self.secondTickScheduler then
               scheduler.unscheduleGlobal(self.secondTickScheduler) 
               self.secondTickScheduler = nil
            end
        end

        local str = "匹配中("..self.secondLeftTime..")..."
        self.panel_2.mc_1.currentView.txt_1:setString(str)
        self.secondLeftTime = self.secondLeftTime-1
    end
    self.secondTickScheduler = scheduler.scheduleGlobal(c_func(updateTime,self), 1)
    --底座
    self.panel_2.mc_2:showFrame(self.loadingData.taizi)
    --衬底
    self.panel_2.mc_3:showFrame(self.loadingData.chendi)
end

--[[
第二个人
]]
function BattleLoadingView:showSecondForReady(  )
    if self.secondTickScheduler then
            scheduler.unscheduleGlobal(self.secondTickScheduler) 
            self.secondTickScheduler = nil
    end
    
    self.panel_2.mc_5:setVisible(true)
    self.panel_2.mc_5:showFrame(2)
    local curView = self.panel_2.mc_5.currentView
    --这个是假的  如果战斗信息传过来了。就用，否则就默认和玩家在同一个区
    local serverName = LoginControler:getServerNameById(self.secondUser.sec)
    curView.txt_1:setAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    serverName = GameConfig.getLanguageWithSwap("#tid_gvp_zone_name", serverName)
    curView.txt_1:setString(serverName)

    local name = self.secondUser.name 
    --echo("[][][][][][][][]",name)
    if name == nil or name == "" then
        name= GameConfig.getLanguage("tid_common_2006")
    end
    --echo("第二个人的名字--------",name,"===================================")
    curView.txt_name1:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
    curView.txt_name1:setString(name)
    local level =self.secondUser.lv
    curView.txt_level1:setString(lvStr)
    curView.txt_level1:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
    local lvStr = GameConfig.getLanguageWithSwap("#tid_gvp_userlv",level)
    curView.txt_level1:setString(lvStr)

    local nameWidth = FuncCommUI.getStringWidth(name, curView.txt_name1:getFontSize(), curView.txt_name1:getFont())
    local namex,namey = curView.txt_name1:getPosition()
    curView.txt_name1:pos(namex,namey)
    local serPosx,serPosy = curView.txt_1:getPosition()
    --echo("serPosx,serPosy","---",serPosx,serPosy,"============")
    curView.txt_1:pos(serPosx+(165-nameWidth)/2-20,serPosy)
    local lvPosx,lvPosy = curView.txt_level1:getPosition()
    --echo("lvPosy,lvPosy","----",lvPosx,lvPosy,"================")
    curView.txt_level1:pos(lvPosx-(165-nameWidth)/2+20,lvPosy)



    self.panel_2.mc_4:showFrame(1)
    local roleView = self.panel_2.mc_4.currentView
    echo("加载个人的素颜法宝,回调加载个人的本命法宝")
    --加载素颜法宝的容器
    --roleView.ctn_1
    --local suyan = FuncChar.getCharOnTreasure(tostring(self.secondUser.avatar),self.secondUser.level,tonumber(self.secondUser.avatar)-100)--NatalModel:getCharOnNatal("0")
    -- local suyan = FuncChar.getSpineAni(tostring(self.secondUser.avatar),self.secondUser.lv)
    -- suyan:setScale(1.75)
    local treasureId
    if self.secondUser.treasureNatal and self.secondUser.treasureNatal and self.secondUser.treasureNatal.hid then
        treasureId = self.secondUser.treasureNatal.hid
    end
    local spine
    if treasureId then
        spine = FuncChar.getCharOnTreasure(tostring(self.secondUser.avatar),self.secondUser.lv,treasureId)
    else
        spine = FuncChar.getSpineAni(tostring(self.secondUser.avatar),self.secondUser.lv,treasureId)
    end
    spine:setScale(1.75)
    --spine:pos(150/2,-200)
    roleView.ctn_1:addChild(spine)


    --suyan:pos(150/2,-200)
    --roleView.ctn_1:addChild(suyan)
    --战力
    local power = self.secondUser.ability    --UserModel:getAbility()            --self.secondUser.ability 
    local powerValueTable = number.split(power)     --战力
    local len = table.length(powerValueTable);
    if len > 6 then 
        echo("-----------warning: power is over 999999!!!----------");
        return;
    end 
    self.panel_2.mc_6:showFrame(len);
    for k, v in pairs(powerValueTable) do
        local mcs = self.panel_2.mc_6:getCurFrameView()
        mcs["mc_zi" .. tostring(k)]:showFrame(v + 1);
    end
    --状态准备中
    self.panel_2.mc_1:showFrame(1)

    --底座
    self.panel_2.mc_2:showFrame(self.loadingData.taizi)
    --衬底
    self.panel_2.mc_3:showFrame(self.loadingData.chendi)
end

--[[
显示第二个人资源加载完成
]]
function BattleLoadingView:showSecondComplete(  )
    echo("第二个人准备好了--------------------------")
    self.panel_2.mc_1:showFrame(2)
    self.panel_2.mc_4:showFrame(1)
    local roleView = self.panel_2.mc_4.currentView
    --echo("加载本命法宝 secondUser")
    --roleView.ctn_1:removeAllChildren()
    --加载素颜法宝的容器
    --roleView.ctn_1
    --local suyan = FuncChar.getCharOnTreasure(tostring(self.secondUser.avatar),self.secondUser.level,tonumber(self.secondUser.avatar)-100)--NatalModel:getCharOnNatal("0")
    -- local treasureId
    -- if self.secondUser.treasureNatal and self.secondUser.treasureNatal and self.secondUser.treasureNatal.hid then
    --     treasureId = self.secondUser.treasureNatal.hid
    -- end
    -- local spine
    -- if treasureId then
    --     spine = FuncChar.getCharOnTreasure(tostring(self.secondUser.avatar),self.secondUser.lv,treasureId)
    -- else
    --     spine = FuncChar.getSpineAni(tostring(self.secondUser.avatar),self.secondUser.lv,treasureId)
    -- end
    -- spine:setScale(1.75)
    -- --spine:pos(150/2,-200)
    -- roleView.ctn_1:addChild(spine)
end


--[[
加载第三个人的剪影
]]
function BattleLoadingView:showThirdForLoading()
    --头顶的标题
    self.panel_3.mc_5:setVisible(false)
    --剪影
    self.panel_3.mc_4:showFrame(2)
    --战力
    --self.panel_2.mc_6:setVisible(false)

    self.thirdLeftTime = 9
    --状态
    self.panel_3.mc_1:showFrame(3)
    local updateTime = function (  )
        --不听得更新时间
        --echo("更新匹配剩余时间")
        if self.thirdLeftTime<=0 then
            self.thirdLeftTime = 0
            if self.thirdTickScheduler then
               scheduler.unscheduleGlobal(self.thirdTickScheduler) 
               self.thirdTickScheduler = nil
            end
        end
        local str = "匹配中("..self.thirdLeftTime..")..."
        self.panel_3.mc_1.currentView.txt_1:setString(str)
        self.thirdLeftTime = self.thirdLeftTime-1
    end
    self.thirdTickScheduler=scheduler.scheduleGlobal(c_func(updateTime,self), 1)
    --底座
    self.panel_3.mc_2:showFrame(self.loadingData.taizi)
    --衬底
    self.panel_3.mc_3:showFrame(self.loadingData.chendi)
end


--[[
显示第三个人
]]
function BattleLoadingView:showThirdForReady(  )
    if self.thirdTickScheduler then
        scheduler.unscheduleGlobal(self.thirdTickScheduler) 
        self.thirdTickScheduler = nil
    end
    self.panel_3.mc_5:setVisible(true)
    self.panel_3.mc_5:showFrame(2)
    local curView = self.panel_3.mc_5.currentView
    --这个是假的  如果战斗信息传过来了。就用，否则就默认和玩家在同一个区
    local serverName = LoginControler:getServerNameById(self.thirdUser.sec)
    curView.txt_1:setAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    serverName = GameConfig.getLanguageWithSwap("#tid_gvp_zone_name", serverName)
    curView.txt_1:setString(serverName)
    name = self.thirdUser.name
   if name == nil or name == "" then
        name= GameConfig.getLanguage("tid_common_2006")
    end
    curView.txt_name1:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
    curView.txt_name1:setString(name)

    local level = self.thirdUser.lv
    curView.txt_level1:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
    local lvStr = GameConfig.getLanguageWithSwap("#tid_gvp_userlv",level)
    curView.txt_level1:setString(lvStr)
    --curView.txt_level1:setString(level.."级")

    local nameWidth = FuncCommUI.getStringWidth(name, curView.txt_name1:getFontSize(), curView.txt_name1:getFont())
    local namex,namey = curView.txt_name1:getPosition()
    curView.txt_name1:pos(namex,namey)
    local serPosx,serPosy = curView.txt_1:getPosition()
    --echo("serPosx,serPosy","---",serPosx,serPosy,"============")
    curView.txt_1:pos(serPosx+(165-nameWidth)/2-20,serPosy)
    local lvPosx,lvPosy = curView.txt_level1:getPosition()
    --echo("lvPosy,lvPosy","----",lvPosx,lvPosy,"================")
    curView.txt_level1:pos(lvPosx-(165-nameWidth)/2+20,lvPosy)



    self.panel_3.mc_4:showFrame(1)
    local roleView = self.panel_3.mc_4.currentView
    echo("加载个人的素颜法宝,回调加载个人的本命法宝")
    --加载素颜法宝的容器
    --roleView.ctn_1
    --local suyan =  FuncChar.getCharOnTreasure(tostring(self.thirdUser.avatar),self.thirdUser.level,tonumber(self.thirdUser.avatar)-100)  --NatalModel:getCharOnNatal("0")
    -- local suyan = FuncChar.getSpineAni(tostring(self.thirdUser.avatar),self.thirdUser.lv)
    -- suyan:setScale(1.75)
    -- --suyan:pos(150/2,-200)
    -- roleView.ctn_1:addChild(suyan)


    local treasureId
    if self.thirdUser.treasureNatal and self.thirdUser.treasureNatal and self.thirdUser.treasureNatal.hid then
        treasureId= self.thirdUser.treasureNatal.hid
    end
    local spine
    if treasureId then
        spine = FuncChar.getCharOnTreasure(tostring(self.thirdUser.avatar),self.thirdUser.lv,treasureId)
    else
        spine = FuncChar.getSpineAni(tostring(self.thirdUser.avatar),self.thirdUser.lv)
    end
    spine:setScale(1.75)
    --spine:pos(150/2,-200)
    roleView.ctn_1:addChild(spine)



    --战力
    local power = self.thirdUser.ability          --self.secondUser.ability 
    local powerValueTable = number.split(power)     --战力
    local len = table.length(powerValueTable);
    if len > 6 then 
        echo("-----------warning: power is over 999999!!!----------");
        return;
    end 
    self.panel_3.mc_6:showFrame(len);
    for k, v in pairs(powerValueTable) do
        local mcs = self.panel_3.mc_6:getCurFrameView()
        mcs["mc_zi" .. tostring(k)]:showFrame(v + 1);
    end
    --状态准备中
    self.panel_3.mc_1:showFrame(1)

    --底座
    self.panel_3.mc_2:showFrame(self.loadingData.taizi)
    --衬底
    self.panel_3.mc_3:showFrame(self.loadingData.chendi)
end


--[[
显示第三个人资源加载完成
]]
function BattleLoadingView:showThirdComplete(  )
    self.panel_3.mc_1:showFrame(2)
    --local roleView = self.panel_3.mc_4.currentView
    echo("加载本命法宝--")
    --roleView.ctn_1:removeAllChildren()

    -- local treasureId
    -- if self.thirdUser.treasureNatal and self.thirdUser.treasureNatal and self.thirdUser.treasureNatal.hid then
    --     treasureId= self.thirdUser.treasureNatal.hid
    -- end
    -- local spine
    -- if treasureId then
    --     spine = FuncChar.getCharOnTreasure(tostring(self.thirdUser.avatar),self.thirdUser.lv,treasureId)
    -- else
    --     spine = FuncChar.getSpineAni(tostring(self.thirdUser.avatar),self.thirdUser.lv)
    -- end
    -- spine:setScale(1.75)
    -- --spine:pos(150/2,-200)
    -- roleView.ctn_1:addChild(spine)
end



-- 多人模式模拟匹配
function BattleLoadingView:simulateMutilMatch()
    -- 假定匹配耗时10秒
    self.matchCostTime = RandomControl.getOneRandomInt(10,5)
    -- 匹配占50%进度
    self.matchPercent = RandomControl.getOneRandomInt(55,45)

    local intervalSec = 0.1
    self:delayCall(c_func(self.simulateMatchPercent,self,intervalSec), intervalSec)
end

-- 单人模式模拟匹配
function BattleLoadingView:simulateSingleMatch()
    -- 假定匹配耗时10秒
    self.matchCostTime = RandomControl.getOneRandomInt(3,1)
    -- 匹配占50%进度
    self.matchPercent = RandomControl.getOneRandomInt(80,60)

    local intervalSec = 0.1
    self:delayCall(c_func(self.simulateMatchPercent,self,intervalSec), intervalSec)
end

-- 模拟匹配进度条
function BattleLoadingView:simulateMatchPercent(intervalSec)
    -- if self.matchTime == nil then
    --     self.matchTime = 0
    -- else
    --     self.matchTime = self.matchTime + intervalSec 
    -- end

    local addPercent = (intervalSec / self.matchCostTime) * self.matchPercent
    self.curPercent = math.round(self.curPercent + addPercent)
    -- echo("##### self.curPercent ====",self.curPercent,addPercent,self.matchCostTime)

    -- 模拟
    if self.DEBUG then
        -- zhangyg模拟中断
        if self.curPercent == (self.matchPercent - 1) then
            EventControler:dispatchEvent(LoadEvent.LOADEVENT_USERENTER,self.gameData)
        end

        -- zhangyg模拟结束
        if self.curPercent == self.matchPercent then
            self.isMatchComplete = true
        else
            self:delayCall(c_func(self.simulateMatchPercent,self,intervalSec), intervalSec)
        end
    else
        if self.curPercent >= self.matchPercent then
            self.isMatchComplete = true
        else
            self:delayCall(c_func(self.simulateMatchPercent,self,intervalSec), intervalSec)
        end
    end
    
    self:updateUI()    
end

function BattleLoadingView:updateUI()
    if self.curPercent > 100 then
        --echo("self.curPercent==",self.curPercent)
        self.curPercent = 100
    end

    -- echo("updateUI self.curPercent===",self.curPercent)

    self.progress:setPercent(self.curPercent)
    self.percentTxt:setString(self.curPercent .. "%")

    self.lightAnim:pos((self.curPercent / 100 * 498+16),-24)
    if self.curPercent > 99 then
        self.lightAnim:setVisible(false)
    end

    -- if self.isMutilMatchMode then
    --     self:updateTitleInfo()
    --     self:updateFriendsStatus()
    -- end
end

-- 更新标题信息
function BattleLoadingView:updateTitleInfo()
    -- local totlFrame = self.infoPanel.mc_mingzi1:getTotalFrameNum()
    -- local typeLabelFrame = self.loadingData.typeLabel

    -- -- 系统名称
    -- if typeLabelFrame == nil or typeLabelFrame == 0 or typeLabelFrame == "" then
    --     self.infoPanel.mc_mingzi1:showFrame(1)
    -- elseif typeLabelFrame >= totlFrame then
    --     self.infoPanel.mc_mingzi1:showFrame(totlFrame)
    -- else
    --     self.infoPanel.mc_mingzi1:showFrame(typeLabelFrame)
    -- end

    -- -- 名称
    -- self.infoPanel.txt_mingcheng:setString(GameConfig.getLanguage(self.loadingData.type2Label))
    -- -- 描述
    -- self.infoPanel.txt_miaoshu:setString(GameConfig.getLanguage(self.loadingData.des1))

    -- -- boss icon
    -- local bossIcon = display.newSprite(FuncRes.iconHead(self.loadingData.icon))
    -- bossIcon:setScale(0.8)
    -- self.infoPanel.ctn_head:addChild(bossIcon)
end

-- 更新道友状态
function BattleLoadingView:updateFriendsStatus()
    -- if not self.isMutilMatchMode then
    --     return 
    -- end

    -- if self.myCampUsers == nil or #self.myCampUsers <=0 then
    --     return
    -- end

    -- local friendsNum = #self.myCampUsers
    -- for i=1,friendsNum do
    --     -- self:updateOneFriendInfo(i)
    --     local curFriendPanel = self.friendPanel["panel_"..i]
    --     local friendData = self.myCampUsers[i]
    --     -- 状态
    --     --curFriendPanel.mc_1:showFrame(friendData.status)
    -- end
end

-- 更新一个道友的信息
function BattleLoadingView:updateOneFriendInfo(index)
    -- 标题栏
    -- self.panel_lianjie.txt_xxzy:setString(GameConfig.getLanguage(self.loadingData.title))
    -- local curFriendPanel = self.friendPanel["panel_"..index]
    -- curFriendPanel:setVisible(true)

    -- local friendData = self.myCampUsers[index]
    -- -- 区服号
    -- curFriendPanel.txt_1:setString(LoginControler:getServerNameById( friendData.sec ))
    -- -- 名字
    -- curFriendPanel.txt_name1:setString(friendData.name)
    -- -- 等级
    -- curFriendPanel.txt_level1:setString(  GameConfig.getLanguageWithSwap("tid_common_2015",friendData.lv) )
    -- 状态
    --curFriendPanel.mc_1:showFrame(friendData.status)
end

-- 更新tips
function BattleLoadingView:updateRandomTips()
    -- echo("\n\nupdateRandomTips-----------------")

    local setTips = function(event)
        local tipIndex = RandomControl.getOneRandomInt(self.maxTipsNum+1,1)
        if tipIndex < 1 then
            tipIndex = 1
        elseif tipIndex > self.maxTipsNum then
            tipIndex = self.maxTipsNum
        end
        
        local tid = GameConfig.getLanguageWithSwap("tid_common_1004",(self.tipMinTid+tipIndex))
        local tipStr = GameConfig.getLanguage(tid)
        self.txt_tips:setString(tipStr)
    end

    setTips()

    self:schedule(c_func(setTips,self), 5)
end

-- 收到匹配玩家消息，获取需要加载的所有用户的信息
function BattleLoadingView:matchUsers(data)
    echo("BattleLoadingView:matchUsers")
    echo("\n\nmatchUsers-匹配到全部玩家")
    echo("匹配到全部玩家-------")
    --LogsControler:writeDumpToFile(data.params,8,8)
    --这里应该判定就是3个  在匹配界面不用区分是不是npc
    if #data.params.camp1 >3 then return end
    local allUsers ={}
    local myData
    for k,v in pairs(data.params.camp1) do
        if tostring(v.avatar) ~= tostring(UserModel:avatar()) then
            table.insert(allUsers,v)
            echo("插入allUsers")
        else
            myData = v
            echo("赋值给myData")
        end
    end
    --这里做一个模拟  就是3个  以后会干掉
    local cnt = #allUsers
    for i=1,2-cnt,1 do
        table.insert(allUsers,myData)
    end
    self.firstUser = myData
    --后两个人的信息也加载出来
    self.secondUser = allUsers[1]
    --LogsControler:writeDumpToFile(self.secondUser,4,4)
    self.thirdUser = allUsers[2]
    if self.thirdUser == nil then
        self.thirdUser = self.secondUser
    end
    --LogsControler:writeDumpToFile("=------------------------------------")
    --LogsControler:writeDumpToFile(self.thirdUser,5,5)
    --显示第二个人匹配到
    self:showSecondForReady()
    --显示第三个人匹配到
    self:showThirdForReady()

    --dump(data.params)
    --LogsControler:writeDumpToFile(data.params,8,8)

    -- self.myCampUsers = self:copyMyCampUsers(data.params.camp1)
    -- self.enemyCmapUser = data.params.waveData

    -- -- 多人匹配模式
    self.isMatchComplete = true
    if self.curPercent < self.matchPercent then
         self:tweenToMatchPercent()
    end
    -- -- self.curPercent = self.matchPercent
    -- -- echoError ("## self.matchPercent=",self.matchPercent)


    -- if self.isMutilMatchMode then
    --     -- 战斗总人物数量
     self.totalUserNum = 3
    -- else
    --     self.totalUserNum = 1
    -- end
    
    -- 已加载完成人物数量
    self.loadUserResNum = 1

    -- if self.isMutilMatchMode then
    --     self:simulateShowFriendInfo(1)
    -- end

    --if DEBUG then
         -- 测试
         -- self:testLoadRes()
     --    self:delayCall(c_func(self.testLoadRes,self), 5)
    --end
end

-- 模拟间隔显示匹配到的玩家
function BattleLoadingView:simulateShowFriendInfo(index)
    if index > #self.myCampUsers then
        return
    end

    self:updateOneFriendInfo(index)

    self:delayCall(c_func(self.simulateShowFriendInfo,self,index+1), 0.5)
end


-- 收到一个用户资源加载完毕的消息
function BattleLoadingView:loadOneUserComplete(data)
    echo("一个玩家加载完成------- 相当于自己的加载完成了 data")
    --echo("\n\nloadOneUserComplete-加载完一个玩家=",data.params,",self.loadUserResNum=",self.loadUserResNum)
    echo("\n\nloadOneUserComplete-加载完一个玩家=",data.params)
    --LogsControler:writeDumpToFile(data.params,8,8)

    --自己加载完成
    if data.params.rid == UserModel:rid() then
        self:showFirstCompelte()
        --return
    end
    --第二个人加载完成
    if data.params.rid == self.secondUser.rid then
        self:showSecondComplete()
        --return
    end

    --第三个人加载完成
    if data.params.rid == self.thirdUser.rid then
        self:showThirdComplete()
        --return
    end


    -- 收到了用户资源加载完成的消息，立即停止模拟加速
    if  self.isSpeedUp  then
         self.isSpeedUp = false
         self.curPercent = self.matchPercent
         -- echoError ("self.curPercent = self.matchPercent===",self.matchPercent)
    end

    local leftPercent = self.maxPercent
    leftPercent = self.maxPercent - self.matchPercent

    self.loadUserResNum = self.loadUserResNum + 1
    
    local rid = data.params
    local addPercent = math.round(1 / self.totalUserNum * leftPercent)
    self.curPercent =  self.curPercent + addPercent

    -- echo("addPercent==",addPercent,self.curPercent,self.curPercent)

    if self.loadUserResNum == self.totalUserNum then
         self.curPercent = self.maxPercent
    end

    -- -- 设置我方人员状态
    -- self:setMyCampUserStatus(rid,self.userLoadStatus.STATUS_LOAD_COMPLETE)

    --self:updateUI()
    --如果已经达到最大直接更新 否则 加速进度条到一定位置
    if self.curPercent == self.maxPercent then
        self:updateUI()
    else
        self:tweenToMatchPercent()
    end
    
end

--[[
收到全部加载完毕的消息
全部加载完成进入战斗
]]
function BattleLoadingView:loadAllUsersComplete(data)
    --echo("所有匹配到的玩家加载完成------")
    LogsControler:writeDumpToFile(data.params,8,8)
    if data.params ~= nil then
        local result = data.params.result
        if result ~= nil and tonumber(result) == 1 then
            --echo("全部加载完成，关闭loading")
            self.curPercent = self.maxPercent
            self:updateUI()
            self:delayCall(c_func(self.closeLoadingView,self),2/GAMEFRAMERATE)
            --self:closeLoadingView()
        else
            WindowControler:showTips("loading加载异常")
        end
    else
        echoError("全部加载完成,没有收到参数")
        self:closeLoadingView()
    end    
end

function BattleLoadingView:closeLoadingView()
    self:delayCall(c_func(self.startHide,self),0.2)
end

-- 测试方法模拟进度
function BattleLoadingView:testLoadRes()
    local index = 0
    for i=1,self.totalUserNum do
        index = i
        local delayTime = i*0.5

        local rid = ""
        if i > #self.myCampUsers then
            index = self.totalUserNum - #self.myCampUsers

            rid = self.enemyCmapUser[index].rid
        else
            rid = self.myCampUsers[index].rid
        end

        local callBack = function()
            EventControler:dispatchEvent(LoadEvent.LOADEVENT_USERCOMPLETE,rid)
        end

        self:delayCall(c_func(callBack,self), delayTime)
    end
end

-- 加速缓动到匹配进度
function BattleLoadingView:tweenToMatchPercent()
    if self.curPercent < self.matchPercent then
        self.isSpeedUp = true
        local dif = self.matchPercent - self.curPercent
        dif = math.round(dif)

        local addPercent = function()
            if not self.isSpeedUp then
                return
            end
            
            if self.curPercent >= self.matchPercent then
                self.isSpeedUp = false
                return
            else
                self.curPercent =  self.curPercent + 1
            end

            self:updateUI()
        end

        for i=1,dif do
            local interval = i * 0.05
            self:delayCall(c_func(addPercent,self), interval)
        end
    end
end

-- 拷贝我方数据
function BattleLoadingView:copyMyCampUsers(campUsers)
    local usersTab = {}
    local myRid = UserModel:rid()
    if self.DEBUG then
        myRid = "dev_503"
    end

    for i=1,#campUsers do
        local curUser = campUsers[i]
        local copyUser = {}
        copyUser.rid = curUser.rid
        copyUser.sec = curUser.sec
        copyUser.name = curUser.name
        copyUser.lv = curUser.lv
        -- 初始化状态
        copyUser.status = self.userLoadStatus.STATUS_PREPARE

        table.insert(usersTab, copyUser)
    end

    table.sort( usersTab, function(a,b) 
        if tostring(a.rid) == tostring(myRid) then
            return true
        elseif a.lv > b.lv then
            return true
        end
    end )


    return usersTab
end

-- 修改道友状态
function BattleLoadingView:setMyCampUserStatus(rid,status)
    for i=1,#self.myCampUsers do
        local user = self.myCampUsers[i]
        if tostring(rid) == tostring(user.rid) then
            user.status = status
        end
    end
end

-- 匹配超时
function BattleLoadingView:onMatchTimeOut()
    echo("匹配超时---------------")
    WindowControler:showTips("匹配超时")
    self:startHide()
    
    local scene = WindowControler:getCurrScene()    
    scene:showRoot()
    --清空GameControler  不需要清空
    --BattleControler:onExitBattle(  )
end



function BattleLoadingView:finishLoading(frame,actionCFunc)
    echo("多人匹配模式-------关闭 断线重连关闭界面")
    self.progress:stopTween()
    self.progress:tweenToPercent(100,frame,actionCFunc)
end



return BattleLoadingView;
