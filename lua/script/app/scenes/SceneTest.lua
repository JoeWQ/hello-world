--
-- Author: xd
-- Date: 2015-11-26 15:03:42
-- 主场景  登入进去以后就是主场景

--等有flash了移除出去 todo
require("game.sys.view.tutorial.TutoralLayer")

SceneTest = class("SceneTest", SceneMain)
    
function SceneTest:ctor(...)
    self._testRoot = display.newNode():addto(self)
    SceneTest.super.ctor(self, ...)

    self:autoLoginConfig()
end

function SceneTest:autoLoginConfig()
    -- 自动登录开关
    self.autoLogin = DEBUG_ENTER_SCENE_TEST
    -- azyg207
    self.userId = "200002"
    self.password = "123456789"
end

function SceneTest:onEnter()
    SceneTest.super.onEnter(self)
end

-- 在登入之前需要初始化的东西放在这里
function SceneTest:initFirst()
    SceneTest.super.initFirst(self)
end

-- 注册事件
function SceneTest:registEvent()
    SceneTest.super.registEvent(self)

    -- 注册按钮事件
    self:registBtnsEvent()
end

-- 显示玩家基本信息
function SceneTest:showUserInfo()
    SceneTest.super.showUserInfo(self)
    
    -- 只有在调试的时候用
    if not self._userInfoLabel then
        self._userInfoLabel = TTFLabelExpand.new( { co = { text = "", color = 0xffffff, align = "center", valign = "left" }, w = 300, h = 50 }):addto(self._root):anchor(0, 1)
        :pos(100, GameVars.height - 10)
    end
    self._userInfoLabel:setString("name:" .. LoginControler:getUname() .. "_rid:" .. UserModel:rid())
end

-- 测试代码=================================================================
function SceneTest:enterLogin()
    --WindowControler:showWindow("TestLoginView")
    -- WindowControler:showWindow("EnterGameView")
    self:showLoading()
end

function SceneTest:testFilter(  )
    WindowControler:showWindow("DebugFilterView")
end


function SceneTest:enterCharView()
    if not self:checkLoginOk() then return end
    -- WindowControler:showWindow("CharAttributeView")
    WindowControler:showWindow("CharPulseView")
end


function SceneTest:treasureTest()
    if not self:checkLoginOk() then return end
    WindowControler:showWindow("TreasureEntrance");
end

-- 背包测试
function SceneTest:ItemTest()
    if not self:checkLoginOk() then return end
    -- WindowControler:showWindow("SelectRoleView");

    local name = "我"
    local filteredName, replNum = string.gsub(name, "%W", "") 
    echo("filteredName, replNum=",filteredName, replNum)

    -- FuncArmature.loadOneArmatureTexture("UI_xunxian", nil, true)

    -- if self.peopleAnim then
    --     echo("缓存动画....")
    --     self.peopleAnim:startPlay(false)
    --     return
    -- end

    -- local peopleAnim = FuncArmature.createArmature("UI_xunxian_yundakai",self._root, false, GameVars.emptyFunc)
    -- peopleAnim:pos(300,300)
    -- peopleAnim:startPlay(false)
    -- self.peopleAnim = peopleAnim

    -- local pveImg = FuncRes.iconPVE("world_img_yuhangzhen")
    -- print("pvImg====",pveImg)

    -- local scene = WindowControler:getScene()
    -- local childArr = scene:getChildren()
    -- local childArrLen = scene:getChildrenCount()

    -- for i=#childArr,2,-1 do
    --     -- childArr[i]:removeFromParent(true)
    --      echo("i===",i)
    --      dump(childArr[i])
    -- end

    -- local code = "203"
    -- WindowControler:showWindow("LoginUpdateExceptionView",nil,code)   
end

-- 竞技场
function SceneTest:aranaTest()
    if not self:checkLoginOk() then return end
    WindowControler:showWindow("ArenaMainView")
end

function SceneTest:homeBtn()
    WindowControler:showWindow("HomeMainView");
end

function SceneTest:guildTest()
    -- 判断境界够不够
    local needState = FuncDataSetting.getDataByEncStr(FuncDataSetting.getOriginalData("GuildState"));
    echo("needState:" .. tostring(needState));
    if needState <= UserModel:state() then
        -- todo 判断是否已经加入了公会
        if UserModel:guildId() == "" then
            WindowControler:showWindow("GuildBlankView");
        else
            echo("已经加入公会");
            -- 取公会数据数据
            -- WindowControler:showWindow("GuildHomeView");
            EventControler:dispatchEvent(GuildEvent.GUILD_GET_MEMBERS_EVENT,
            { });
        end
    else
        WindowControler:showTips( { text = "境界不足" })
    end
end

-- 邮件
function SceneTest:enterMail()
    -- body
    WindowControler:showWindow("MailView", QuestType.MainLine)
end

-- 商城
function SceneTest:enterShop()
    if not self:checkLoginOk() then return end
    WindowControler:showWindow("ShopView")
end

-- 排行榜
function SceneTest:enterRank()
    local callBack = function(data)
        echo("enterRank callBack...")
        if data.result then
            WindowControler:showWindow("RankMainView", data.result.data)
        else
            echo("enterRank 请求error")
        end
    end

    RankServer:getRankList(2, 1, 10, c_func(callBack))
end

-- 签到
function SceneTest:signView()
    WindowControler:showWindow("SignView");
end

-- 抽卡
function SceneTest:enterLottery()
    if not self:checkLoginOk() then return end
    WindowControler:showWindow("LotteryMainView");
end

function SceneTest:enterTrial()
    if TrailModel:isTrailOpen(TrailModel.TrailType.ATTACK, 1) == true then
        WindowControler:showWindow("TrialEntranceView");
    else
        WindowControler:showTips( { text = "等级不足" });
    end
end

-- 进入六届
function SceneTest:enterWorld()
    if not self:checkLoginOk() then return end
    WindowControler:showWindow("WorldHomeView");
    -- WindowControler:showWindow("WorldMainView");
    -- WindowControler:showWindow("WorldPVELevelListView");
end

function SceneTest:enterPVE()
    if not self:checkLoginOk() then return end
    WindowControler:showWindow("WorldPVEMainView");
end

-- 奇缘
function SceneTest:enterRomance()
    if not self:checkLoginOk() then return end
    WindowControler:showWindow("RomanceView");
end

--剧情对话
function SceneTest:plotDialog() 
    self.dialog = require("game.sys.controler.PlotDialogControl")
    self.dialog:init() 
    function _callback(ud)
        -- ud{ step,index }
        --print("click---" .. ud.index .. "step..."..ud.step)
    end 
    self.dialog:showPlotDialog(101, _callback);
end 

-- 任务
function SceneTest:questTest()

    local isOpen, needLvl = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST);
    if isOpen == true then 
        WindowControler:showWindow("QuestView");
    else 
        WindowControler:showTips("需要等级 " .. tostring(needLvl));
    end 
end

function SceneTest:combineInterface()
   CombineControl:showWindow();
end 

-- 战斗胜利
function SceneTest:fightResult()
       local _params ={result=1, addExp = 10, preExp = 30, preLv = 35, star =1, reward = {[1]="1,4011,301" ,[2]="1,4012,300", [3]="1,4013,300", [4]="2,300,301" ,[5]="3,4201,301", } }
 

        local uiWin = WindowsTools:createWindow("BattleWin",_params)
        uiWin:addto(self._root):zorder(100):pos(GameVars.UIbgOffsetX +100 ,GameVars.scaleHeight)
        uiWin.battleDatas = _params
        uiWin:startShow()
        uiWin:updateUI( _params)


--        local uiLose = WindowsTools:createWindow("BattleLose")
--        uiLose.battleDatas = _params
--        uiLose:addto(self):zorder(100):pos(100,GameVars.scaleHeight)
--        uiLose:startShow()
--        uiLose:updateUI( _params) 
end 



--战斗失败
function SceneTest:fightLose(  )
     local _params ={result=1, addExp = 10, preExp = 30, preLv = 35, star =1, reward = {[1]="1,4011,301" ,[2]="1,4012,300", [3]="1,4013,300", [4]="2,300,301" ,[5]="3,4201,301", } }
 

        local uiWin = WindowsTools:createWindow("BattleLose",_params)
        uiWin:addto(self._root):zorder(100):pos(GameVars.UIbgOffsetX+100 ,GameVars.scaleHeight)
        uiWin.battleDatas = _params
        uiWin:startShow()
        uiWin:updateUI( _params)
end



--[[
胜利宝箱
]]
function  SceneTest:winBox(  )
    local uiWin = WindowsTools:createWindow("BattleReward",_params)
    uiWin:addto(self._root):zorder(100):pos(GameVars.UIbgOffsetX+100 ,GameVars.scaleHeight)
    uiWin.battleDatas = _params
    uiWin:startShow()
    uiWin:updateUI( _params)
end





--[[
战斗 伤害对比
]]
function SceneTest:fightCompare(  )
    local uiWin = WindowsTools:createWindow("BattleAnalyze")
        uiWin:addto(self._root):zorder(100):pos(GameVars.UIbgOffsetX+100 ,GameVars.scaleHeight)
        uiWin:startShow()
        -- uiWin.battleDatas = _params
        -- uiWin:startShow()
        uiWin:updateUI( _params)
end



function SceneTest:debugConnData(t)
    WindowControler:showWindow("TestConnView")
end

function SceneTest:enterTest()

    package.loaded["app.scenes.Window_test"] = nil
    package.preload["app.scenes.Window_test"] = nil
    self._root:visible(false)
    local testView = require("app.scenes.Window_test").new():addto(self)

    echo(package.loaded["app.scenes.Window_test"],"__aaaa_______")
    echo(package.preload["app.scenes.Window_test"],"__bbbbbbbbb_______")

end





function SceneTest:openTuroral()
    WindowControler:showTips( { text = "进主界面看引导" })
    
    require("game.sys.view.tutorial.TutorialManager")

    self:tutorialTest();
end

function SceneTest:openToggerTuroral()
    IS_OPEN_TURORIAL = true;
    local unforcedTutorialManager = UnforcedTutorialManager.getInstance();
    if unforcedTutorialManager:isAllFinish() == false then 
        unforcedTutorialManager:startWork();
    end
end

function SceneTest:configTest()
    local testView = require("game.sys.view.test.ConfigTestView").new():addto(self._root)
end


function SceneTest:crtAni(  )
    local callBack
    callBack = function()
        self.testAni:pause(false)
    end
    FuncArmature.loadOneArmatureTexture("UI_tongyonghuode",nil,true)
    self.testAni = FuncArmature.createArmature("UI_tongyonghuode_biaoti",self._root,false,GameVars.emptyFunc)
    --self.testAni:getBoneDisplay("layer2"):playWithIndex(0, true)
    self.testAni:registerFrameEventCallFunc(45, false, callBack)
    self.testAni:pos(480,600)
    self.testAni:playWithIndex(0)
end






function SceneTest:showGamble()
    
end

function SceneTest:guanFengTest()

    local params = {
        colorize = "#0000cc",--nil就是不设置这个参数
        amount = 2.4, --单独测试ok

        contrast = 3, --单独测试ok ok

        brightness = 2,  --单独测试ok ok
        saturation = 3,   --单独测试ok

        hue = 300,  --单独测试ok
        -- threshold = 200, --单独测试ok
    }   

    local matrix = ColorMatrixFilterPlugin:genColorTransForm(params);

    ColorMatrixFilterPlugin:dumpMatrix(matrix);


    local sprite = display.newSprite("asset/test/test123.png");
    self._root:addChild(sprite);

    sprite:setPosition(200, 300);
    sprite:setScale(1);


    local sprite2 = display.newSprite("asset/test/test123.png");
    self._root:addChild(sprite2);

    sprite2:setPosition(600, 300);
    sprite2:setScale(1);

    FilterTools.setColorMatrix(sprite2, matrix);
    

    -- local sp = ViewSpine.new("eff_treasure413_xutianding", {}, "", "eff_treasure413_xutianding"):addto(
    --     self._root):pos(200, 300);

    -- sp:playLabel("attack", true);
    -- -- sp:playLabel("stand_1", true);

    -- sp.currentAni:setScale(1);
    -- sp:setPlaySpeed(1);

end

-- 战斗测试
function SceneTest:enterGame(t,battleLabel)
    GameLuaLoader:loadGameBattleInit()

    local attrInfo = {  
        {key=1,value = 200,mode = 1},
        {key=1,value = 3000,mode = 2},
        {key=1,value = 500,mode = 3},
        {key=1,value = 5000,mode = 4},
        {key=10,value = 5,mode = 1},
        
    }

    local info = FuncBattleBase.formatAttribute( attrInfo )

    FuncBattleBase.countFinalAttr( attrInfo,attrInfo     )
    UserModel:init({level =1})
    local battleInfo = { }
    battleInfo.battleUsers = { }
    local defaultHero = ObjectCommon:getServerData()
    for i = 1, #defaultHero do
        table.insert(battleInfo.battleUsers, defaultHero[i])
    end
    battleInfo.levelId = t
    battleInfo.randomSeed = 100
    --这是pve
    battleInfo.battleLabel =  battleLabel or GameVars.battleLabels.worldPve  --GameVars.battleLabels.worldPve
    BattleControler:startBattleInfo(battleInfo)
    --一下注释掉的是PVP测试
    --battleInfo.battleLabel = GameVars.battleLabels.pvp          --竞技场类型的
    --BattleControler:startPVP(battleInfo)

end



function SceneTest:enterTestRever( t,battleLabel )



    GameLuaLoader:loadGameBattleInit()
    Fight.cameraWay = Fight.cameraWay * (-1)
    UserModel:init({level =1})
    local battleInfo = { }
    battleInfo.battleUsers = { }
    local defaultHero = ObjectCommon:getServerData()
    for i = 1, #defaultHero do
        table.insert(battleInfo.battleUsers, defaultHero[i])
    end
    battleInfo.levelId = t
    battleInfo.randomSeed = 100
    --这是pve
    battleInfo.battleLabel =  battleLabel or GameVars.battleLabels.worldPve  --GameVars.battleLabels.worldPve
    BattleControler:startBattleInfo(battleInfo)
end




--[[
删除多余spine文件

local flaArr = {
        "TreaGiveOut","treasure0","eff_buff_bing","eff_buff_gongjili","eff_buff_jiafanghudun",
        "eff_buff_jiafangyuli","eff_buff_jianfang","eff_buff_xuanyun",
        }
    self._textureFlaArr = clone(flaArr)

    local spineArr = {
        "eff_treasure0"
        }

]]
function SceneTest:checkDelSpine(  )

    local ignoreSpineArr = 
    {
        eff_treasure0 = true
    }
    local ignoreFlaArr = 
    {
         TreaGiveOut = true,
         treasure0=true,
         eff_buff_bing=true,
         eff_buff_gongjili=true,
         eff_buff_jiafanghudun=true,
         eff_buff_jiafangyuli = true,
         eff_buff_jianfang = true,
         eff_buff_xuanyun=true
    }

    require("lfs")
    local path=lfs.currentdir()
    -- E:\heracles\svn\tempFiles\roundDemo\Resources
    local svnPath = path.."/../../../"
    echo(svnPath)
    local targetPath1 = svnPath.."Assets/anim/spine/sourceSvn/"
    local targetPath2 = svnPath.."/tempFiles/roundDemo/Resources/asset/anim/spine/"
    local flatargetpath1 = svnPath.."Assets/anim/armature/zipSvn/"
    local flatargetpath2 = svnPath.."tempFiles/roundDemo/Resources/asset/anim/armature/"
    
    local sourceCfg = require("treasure.Source")
    -- echo("sourceCfg---------")
    -- dump(sourceCfg)
    -- echo("sourceCfg---------")
    --当前使用的文件
    local existSpine ={}
    for k,v in pairs(sourceCfg) do
        if v.spine and v.spine ~= "0" then
            existSpine[v.spine] = true
        end
        --dump(v.effSpine)
        --echoError('aaa')
        if v.effSpine and v.effSpine ~="0" then
            for kk,vv in pairs(v.effSpine) do
                existSpine[vv] = true
            end
        end
        if v.spineFormale and v.spineFormale ~="0" then
            existSpine[v.spineFormale] = true
        end
    end
    --"C:\Users\playcrab\Desktop\sourceFile.txt"
    -- local f = assert( io.open("C:/Users/playcrab/Desktop/sourceFile.txt", 'a') )
    -- f:write("spine文件\n")
    -- for k,v in pairs(existSpine) do
    --     f:write(k.."\n")
    -- end
    -- f:close()
    --获取所有当前存在的文件
    local allFiles = {}
    for file in lfs.dir(targetPath2) do 
        if file ~= "." and file ~= ".." then
            local idx = file:match(".+()%.%w+$")  
            local fileWithOutExten = string.sub(file,1,idx-1)
            allFiles[fileWithOutExten] = true
        end
    end
    --当前要删除的文件数组
    local willDel = {}
    for k,v in pairs(allFiles) do
        -- echo(string.find(k, "ui_"),"--")
        -- echo(string.find(k,"art_"),"---")
        --art_
        if existSpine[k] ~= true and string.find(k, "UI_") ~= 1 and string.find(k,"art_") ~=1 and ignoreSpineArr[k] ~= true   then
            willDel[k] = true
        end
    end
    -- echo("要删除的文件数组")
    -- dump(willDel)
    -- echo("要删除的文件数组")

    --删除targetpath2中的数据
    echoWarn("不使用的资源文件")
    for file in lfs.dir(targetPath2) do 
        if file ~= "." and file ~= ".." then
            local idx = file:match(".+()%.%w+$")  
            local fileWithOutExten = string.sub(file,1,idx-1)
            
            if willDel[fileWithOutExten] == true then
                --echo("删除文件",targetPath2..file)
                echo(targetPath2..file)
                --os.remove(targetPath2..file)
            end
        end
    end
    echoWarn("不使用的资源文件")
    --删除 targetPath1中的目录
    -- for file in lfs.dir(targetPath1) do 
    --     if file ~= "." and file ~= ".." then
    --         local idx = file:match(".+()%.%w+$")  
    --         local fileWithOutExten = string.sub(file,1,idx-1)
    --         if willDel[fileWithOutExten] == true then
    --             echo("删除文件",targetPath2..file)
    --             os.remove(targetPath2..file)
    --         end
    --     end
    -- end

    local existFlas = {}
    for k,v in pairs(sourceCfg) do
        if v.fla and v.fla ~= "0" then
            for kk,vv in pairs(v.fla) do
                existFlas[vv] = true    
            end
        end
    end
    local allFlaFils = {}
    for file in lfs.dir(flatargetpath2) do 
        if file ~= "." and file ~= ".." then
            local idx = file:match(".+()%.%w+$")  
            local fileWithOutExten = string.sub(file,1,idx-1)
            allFlaFils[fileWithOutExten] = true
        end
    end

    local flaWillDel = {}
    for k,v in pairs(allFlaFils) do
        if existFlas[k] ~= true 
            and string.find(k, "UI_") ~= 1 
            and string.find(k,"common") ~=1 
            and string.find(k,"a3") ~=1 
            and string.find(k,"map_")~=1
            and ignoreFlaArr[k] ~= true
            --and string.find(k,"eff_treasure0")~=1  
        then
            flaWillDel[k] = true
        end
    end

    --删除flatargetpath1对应的文件
    -- for file in lfs.dir(flatargetpath1) do 
    --     if file ~= "." and file ~= ".." then
    --         local idx = file:match(".+()%.%w+$")  
    --         local fileWithOutExten = string.sub(file,1,idx-1)
    --         if flaWillDel[fileWithOutExten] == true then
    --             echo("删除fla文件",targetPath2..file)
    --             os.remove(targetPath2..file)
    --         end
    --     end
    -- end
    --echo("删除 ",flatargetpath2,"目录下的文件------")
    --删除flatargetpath2对应的文件
    for file in lfs.dir(flatargetpath2) do 
        if file ~= "." and file ~= ".." then
            local idx = file:match(".+()%.%w+$")  
            local fileWithOutExten = string.sub(file,1,idx-1)
            if flaWillDel[fileWithOutExten] == true then
                echo("删除fla文件",flatargetpath2..file)
                os.remove(flatargetpath2..file)
            end
        end
    end


end





function SceneTest:pt()
   -- TowerControl:showWindow()
   self._sp:gotoAndPlay(20);
end 

function SceneTest:registBtnsEvent()

    self:creatBtns("普通关卡", c_func(self.enterGame, self,"10101",GameVars.battleLabels.worldPve))

    self:creatBtns("普通关卡1", c_func(self.enterGame, self,"10101",GameVars.battleLabels.worldPve))
    self:creatBtns("普通关卡2", c_func(self.enterGame, self,"10102",GameVars.battleLabels.worldPve))
    self:creatBtns("普通关卡3", c_func(self.enterGame, self,"10103",GameVars.battleLabels.worldPve))
    self:creatBtns("普通关卡4", c_func(self.enterGame, self,"10104",GameVars.battleLabels.worldPve))
    self:creatBtns("普通关卡5", c_func(self.enterGame, self,"10105",GameVars.battleLabels.worldPve))


    self:creatBtns("战斗反向",c_func(self.enterTestRever,self,"10101",GameVars.battleLabels.worldPve))
    self:creatBtns("boss关卡", c_func(self.enterGame, self,"10102",GameVars.battleLabels.worldPve))
    self:creatBtns("竞技场关卡", c_func(self.enterGame,self,"103" ,GameVars.battleLabels.pvp))

    -- self:creatBtns("删除多余spine",c_func(self.checkDelSpine,self))

    self:creatBtns("滤镜测试", c_func(self.testFilter, self))
    
    self:creatBtns("登入入口", c_func(self.enterLogin, self))
    -- self:creatBtns("主角", c_func(self.enterCharView, self))
    -- self:creatBtns("法宝", c_func(self.treasureTest, self))
    -- self:creatBtns("背包", c_func(self.ItemTest, self))
    -- self:creatBtns("竞技场", c_func(self.aranaTest, self))
    self:creatBtns("主界面", c_func(self.homeBtn, self))
    -- 公会
    -- self:creatBtns("公会", c_func(self.guildTest, self))
    -- self:creatBtns("邮件", c_func(self.enterMail, self))
    -- 商城入口
    -- self:creatBtns("商场", c_func(self.enterShop, self))
    -- 排行榜入口
    -- self:creatBtns("排行榜", c_func(self.enterRank, self))
    -- 签到
    -- self:creatBtns("签到", c_func(self.signView, self))
    -- 抽卡
    -- self:creatBtns("抽卡", c_func(self.enterLottery, self))
    -- 试炼
    -- self:creatBtns("试炼", c_func(self.enterTrial, self))
    -- 六界
    -- self:creatBtns("六界", c_func(self.enterWorld, self))
    -- 寻仙
    -- self:creatBtns("寻仙", c_func(self.enterPVE, self))

    -- 奇缘
    -- self:creatBtns("奇缘", c_func(self.enterRomance, self))
    -- 剧情
    -- self:creatBtns("剧情", c_func(self.plotDialog, self))
    --任务
    -- self:creatBtns("任务", c_func(self.questTest, self))

    -- self:creatBtns("法宝合成", c_func(self.combineInterface, self))

     --创建测试入口
    self:creatBtns("战斗胜利", c_func(self.fightResult, self))
    self:creatBtns("战斗伤害",c_func(self.fightCompare,self))
    self:creatBtns("战斗失败",c_func(self.fightLose,self))
    self:creatBtns("胜利宝箱",c_func(self.winBox,self))

    -- 网络数据修改
    -- self:creatBtns("通信协议", c_func(self.debugConnData, self))
    -- 创建测试入口
    self:creatBtns("测试入口", c_func(self.enterTest, self))

    self:creatBtns("开启新手引导", c_func(self.openTuroral, self))
    self:creatBtns("开启触发试引导", c_func(self.openToggerTuroral, self))
    self:creatBtns("配置文件检查", c_func(self.configTest, self))
    self:creatBtns("动画测试",c_func(self.crtAni,self))
    

    -- self:creatBtns("天玑赌肆", c_func(self.showGamble, self))

    --关测试
    -- self:creatBtns("guan测试", c_func(self.guanFengTest, self))
    -- self:creatBtns("爬塔", c_func(self.pt, self))

    --大量加载释放测试
    -- self:creatBtns("cache大量加载", c_func(self.manyLoad, self))
    -- self:creatBtns("cache大量释放", c_func(self.manyRelease, self))

    if OPEN_TUTORAL == true then 
        require("game.sys.view.tutorial.TutorialManager")

        self:tutorialTest();
    end 
end

function SceneTest:tutorialTest()
    local tutorialManager = TutorialManager.getInstance();
    IS_OPEN_TURORIAL = true;
    if tutorialManager:isAllFinish() == false then 
        tutorialManager:startWork(self);
    end 
end


function SceneTest:checkLoginOk()
    if not LoginControler:isLogin() then
        WindowControler:showTips( { text = "请先登入游戏在执行此操作" })
        return false
    end
    return true
end

-- 测试
SceneTest.btnNums = 0

local hangNums = 5
local wid = 180
local hei = 80

-- 创建一个测试按钮只用传递一个显示文本和一个点击函数即可,目前是自动排列
function SceneTest:creatBtns(text, clickFunc)
    self.btnNums = self.btnNums + 1
    local xIndex = self.btnNums % hangNums
    xIndex = xIndex == 0 and hangNums or xIndex
    local yIndex = math.ceil(self.btnNums / hangNums)
    local xpos = GameVars.UIOffsetX +(xIndex - 1) * wid + 30

    local ypos = GameVars.height - GameVars.UIOffsetY -(yIndex - 1) * hei - 70
    -- local sp = display.newNode():addto(self._root):pos(xpos, ypos):anchor(0, 1)
    -- sp:size(137,64)

    local view = UIBaseDef:createPublicComponent( "UI_debug_public","panel_bt" ):addto(self._testRoot)
    view:pos(xpos,ypos)

    view.txt_1:setString(text)

    -- display.newRect(cc.rect(0, -50, 150, 50),
    -- { fillColor = cc.c4f(1, 1, 1, 0.8), borderColor = cc.c4f(0, 1, 0, 1), borderWidth = 1 }):addto(sp):anchor(0, 1):pos(10, 0)

    --local label = TTFLabelExpand.new( { co = { text = text, fontName = nil, color = 0, align = "center", valign = "center" }, w = 170, h = 50 }):addto(sp):anchor(0, 1)
    -- display.newTTFLabel({text = text, size = 20, color = cc.c3b(255,0,0)})
    --         :align(display.CENTER, sp:getContentSize().width/2, sp:getContentSize().height/2)
    --         :addTo(sp):pos(65,25)
    view:setTouchedFunc(clickFunc)
    -- table.insert(self._debug_btns, view)
    return view
end

return SceneTest
