--
-- Author: xd
-- Date: 2015-11-26 15:16:44
--
require("game.sys.view.tutorial.TutorialManager")

local Window_test = class("Window_test", function (  )
    return display.newNode()
end)


 local sharedTextureCache = cc.Director:getInstance():getTextureCache()

function Window_test:ctor()
    self._root = display.newNode():addto(self)
    local layer = WindowControler:createCoverLayer(0,GameVars.height ,cc.c4b(99,99,99,255)):addto(self,-1)

    -- echo("------------------aaaa",type(cc.GLNode),"____",cc.GLNode.create)
    
    -- echo(Btn_base,"____btnBase")

    --local sp1 = display.newSprite("ui/BtnOrange_Normal.png"):anchor(0,0):pos(100,100)
    --local btn = BtnExpand.new(sp1):addto(self,999):setTap(handler(self, self.testBtnExpand))


    --local color = numberToColor(10066227)
    --echo(color.r,color.g,color.b,"___________")


    --初始化所有的model
    --FuncServerData.initModel( serviceData )


    local t1 = os.clock()

    --self.windowControler =  WindowControler.new():initFirst(self, {level=1})

    -- ui 测试
    --local ui = WindowsTools:createWindow("Window_test"):addto(self):pos(100,GameVars.height)

    -- WindowControler 测试
    --local ui = WindowControler:showWindow("Window_test")

    -- ListView 测试
    --self:ListViewTest()

    -- 输入测试
    -- self:inputTest()

    self:creatBtns("返回主场景",c_func(self.backSceneMain,self))

    self:creatBtns("进入战斗",c_func(self.enterGame,self))
    local img = FuncRes.uipng("arena_img_cd.png")
    local sp = display.newSprite(img):addto(self):pos(100,160)

    self:creatBtns("动画测试",c_func(self.testArmature,self))
    self:creatBtns("二进制性能",c_func(self.testDecodePerformance,self))
    self:creatBtns("富文本测试",c_func(self.fuwenbenTest,self))


    self:creatBtns("动画测试2",c_func(self.animTest,self))

    self:creatBtns("GridView测试", c_func(self.GridViewTest2, self));
    
    self:creatBtns("动画倒播", c_func(self.testReverseAnim, self));

    self:creatBtns("spine测试", c_func(self.spineTest, self));
    self:creatBtns("spine 预加载", c_func(self.preLoad, self));
    self:creatBtns("spine 释放", c_func(self.deleteSpine, self));
    self:creatBtns("公式测试", c_func(self.gongshiTest, self));

    self:creatBtns("文本打印机", c_func(self.testTxtPrinter, self));
    -- self:creatBtns("我的测试", c_func(self.CwbTest, self));
    self:creatBtns("Node2Sprite", c_func(self.Node2SpriteTest, self));
    self:creatBtns("日志测试", c_func(self.logTest, self))

    self:creatBtns("diaozhen", c_func(self.diaozhen, self))
    self:creatBtns("开启线程加载资源", c_func(self.openThread, self))
    self:creatBtns("关闭线程加载资源", c_func(self.closeThread, self))

    self:creatBtns("spine局部换装", c_func(self.spineChangeSlotTexture, self))

    self:creatBtns("spine局部皮肤复原", c_func(self.spineSlotReset, self));

    self:creatBtns("spine换装", c_func(self.spineSlotResetSkin, self));

    self:creatBtns("图片加载及释放速度测试", c_func(self.picLoadAndRelease, self));

    self:creatBtns("加载spine和释放spine速度测试", c_func(self.spineLoadAndRelease, self));
    self:creatBtns("action Test", c_func(self.actionTest, self));

    self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self) ,0)

end

local j = 0;

local skinId = 0;

function Window_test:actionTest()
    local sprite = display.newSprite("asset/test/grossini.png");
    local fadeAction = cc.FadeTo:create(2, 0);
    sprite:runAction(fadeAction);
    sprite:setPosition(cc.p(400, 400));
    self._root:addChild(sprite);

    local node = display.newSprite("asset/test/grossinis_sister.png");
    node:runAction(fadeAction);
    node:setPosition(cc.p(600, 400));
    self._root:addChild(node);
end

function Window_test:spineLoadAndRelease()
    local t1 = os.clock();
    pc.PCSkeletonDataCache:getInstance():SkeletonDataPreLoad(FuncRes.spine("char_2"))
    local t2 = os.clock();
    echo("加载spine: " .. tostring(t2 - t1));

    t1 = os.clock();
    pc.PCSkeletonDataCache:getInstance():clearAllCache();
    t2 = os.clock();
    echo("释放spine: " .. tostring(t2 - t1));
end

function Window_test:picLoadAndRelease()
    local key = "test/pic256256.png";
    --加载图速度 1024 * 1024;
    local t1 = os.clock();
    local sharedTextureCache = cc.Director:getInstance():getTextureCache();
    sharedTextureCache:addImage(key);
    local t2 = os.clock();

    echo("加载耗时：" .. tostring(t2 - t1));

    t1 = os.clock();
    sharedTextureCache:removeTextureForKey(key);
    t2 = os.clock();
    echo("释放耗时：" .. tostring(t2 - t1));

end

function Window_test:spineSlotResetSkin( ... )
    if skinId == 0 then 
        self._sp:setSkin("zi_se");
        skinId = 1;
    else 
        self._sp:setSkin("test");
        skinId = 0;
    end 
end

function Window_test:spineSlotReset()
    self._sp:resetSlotTexture("jian2");
    self._sp:resetSlotTexture("xiuzi");
end

function Window_test:preLoad( ... )
    -- pc.PCSkeletonDataCache:getInstance():SkeletonDataPreLoad(
    --     FuncRes.spine("bigPic", "bigPic"));

    -- pc.PCSkeletonDataCache:getInstance():SkeletonDataPreLoad(
    --     FuncRes.spine("bigPic", "bigPicTwo"));

    pc.PCSkeletonDataCache:getInstance():SkeletonDataPreLoad(FuncRes.spine("eff_treasure0"))
end

function Window_test:deleteSpine( ... )
    -- local jsonPath = FuncRes.spine("bigPic");
    pc.PCSkeletonDataCache:getInstance():clearCacheByFileName(FuncRes.spine("bigPic", "bigPic"));
    pc.PCSkeletonDataCache:getInstance():clearCacheByFileName(FuncRes.spine("bigPic", "bigPicTwo"));

end

local num = 1;

function Window_test:spineTest()
    self._isPlayBack = false

    -- for i = 1, 10 do
        local sp = ViewSpine.new("treasure_a3_cheng", {}, "", "treasure_a3_cheng"):addto(
            self._root):pos(num * 20, 300);

        -- local sp = ViewSpine.new("treasure_a3_cheng_small", {}, "", "treasure_a3_cheng"):addto(
        --     self._root):pos(i * 20, 300);

        sp:playLabel("attack", true);
        -- sp:playLabel("stand_1", true);

        sp.currentAni:setScale(1);
        sp:setPlaySpeed(1);

        num = num + 1;

        echo(sp:isBoneExist("bone108d"));

        dump(sp:getBonePos("bone108"));

        -- FuncArmature.createArmature("UI_common_juesexiaoshi", self, 
        --     true):pos(i * 20, 200);
    -- end
end

function Window_test:spineChangeSlotTexture()
    self._sp:changeSlotTexuture("weapon_y1_1", "asset/test/jian2.png");
end

function Window_test:openThread()
    self._openUpdate = true;
    echo("open");
end

function Window_test:closeThread()
    self._openUpdate = false;

    echo("close");

end

function Window_test:diaozhen()

    local char = "treasure _a3";
    local sp = ViewSpine.new(char,{},
        char):addto(self._root):pos(200, 200);
    sp:playLabel("stand_1")
    -- sp:setSkin("zi_se");
    sp.currentAni:setScale(2)
    sp:setPlaySpeed(1);

end

local index =0
local anitest
function Window_test:updateFrame( dt )
    FilterTools.updateFrame()
    --加载释放几个资源

    if self._openUpdate == true then
        -- echo("hh ");
        for i = 2, 2 do
            local name = "anim/spine/char_" .. tostring(i);
            --已经加载好了，就释放
            if pc.PCSpineAsyncFacade:getInstance():isResLoad(name) and 
                pc.PCSpineAsyncFacade:getInstance():isResInReleasing(name) == false then
                echo("释放资源：" .. tostring(i));
                pc.PCSpineAsyncFacade:getInstance():resRelease(name);
            end 

            --没有加载，就加载
            if pc.PCSpineAsyncFacade:getInstance():isResLoad(name) == false and
                pc.PCSpineAsyncFacade:getInstance():isResInLoading(name) == false then 
                echo("加载资源：" .. tostring(i));

                pc.PCSkeletonDataCache:getInstance():setIsUseBinaryConfig(true); 
                pc.PCSpineAsyncFacade:getInstance():resLoad(name);
            end 
        end

    end

end

function Window_test:logTest()
    WindowControler:showWindow("LogsView")
end

function Window_test:Node2SpriteTest()
    -- --带子节点的node测试
    local node = display.newSprite("asset/test/grossinis_sister.png");
    node:setPosition(600, 400)
    local node2 = display.newSprite("asset/test/grossini.png");
    node2:setAnchorPoint(cc.p(0.5, 0.5))
    node:addChild(node2);
    self._root:addChild(node, 100);

    local offsetX = node2:getBoundingBox().width / 2
    local offsetY = node2:getBoundingBox().height / 2

    local width = node:getBoundingBox().width + offsetX;
    local height = node:getBoundingBox().height + offsetY;

    -- local nodeSprite = pc.PCNode2Sprite:getInstance():spriteCreate(
    --     node, width, height, -offsetX, -offsetY);

    local nodeSprite = pc.PCNode2Sprite:getInstance():spriteCreate(
        node);

    nodeSprite:pos(800, 400)
    self._root:addChild(nodeSprite, 100);

    --spine
    local sp = ViewSpine.new("char_1",{},"char_1"):addto(self._root):pos(0, 0)
    local spineBox = sp:getSkeletonAnimationNode():getBoundingBox();

    sp:playLabel("walk");
    dump(spineBox);

    self._sps = sp;
    -- local spineSprite = pc.PCNode2Sprite:getInstance():spriteCreate(
    --     sp:getSkeletonAnimationNode(), spineBox.width, spineBox.height, -spineBox.width / 2, 0);
    local spineSprite = pc.PCNode2Sprite:getInstance():spriteCreate(
        sp:getSkeletonAnimationNode());
    echo(spineSprite);
    self._root:addChild(spineSprite, 100);
    spineSprite:setAnchorPoint(cc.p(0, 0))
    spineSprite:pos(200, 0)


    --dragonBone 木有资源了
    --zhantaizhaoying有bug todo
    -- FuncArmature.loadOneArmatureTexture("zhantaizhaoying", nil, true);
    -- local ani = FuncArmature.createArmature("zhantaizhaoying_standby1", self, true)

    -- FuncArmature.loadOneArmatureTexture("bingdilian", nil, true);
    -- local ani = FuncArmature.createArmature("bingdilian_standby1", self, true)

    -- ani:setScale(0.8)
    -- ani:pos(300,100)

    -- local aniSprite = pc.PCNode2Sprite:getInstance():spriteCreate(ani);
    -- self._root:addChild(aniSprite, 100);
    -- aniSprite:setPosition(500, 200);
end

function Window_test:testTxtPrinter(  )
    WindowControler:showWindow("MyTestView");
end


function Window_test:backSceneMain(  )
    self:clear()
end

function Window_test:CwbTest()

end

function Window_test:CwbTest2()
    self._ssp:setRotationSkewY(180);
end

function Window_test:CwbTest3()
    self._ssp:setRotationSkewY(0);
end

function Window_test:testOnLoadComp()
    local test = nil
    -- 创建图片，确认图片的名字
    -- local test = display.newSprite("#jingmuhanlingbuyunyuanjian-yun9.png")   
    -- test:addTo(self)
    -- test:setPosition(cc.p(480,320))

    -- 创建特效
    --test = ViewArmature.new("RW_guangzhaopiliea")

    -- buff 特效测试
    --test = ViewArmature.new("renwutexiaob_fbjichu_g")
    test = ViewArmature.new("renwutexiaob_fbjichu_g")

    test:addTo(self)
    test:setPosition(cc.p(480,320))
end

function Window_test:gongshiTest()
    self._sp:playLabel("attack1");
end


function Window_test:GridViewTest2()
    local ui = WindowControler:showWindow("GridViewTestView")
end



function Window_test:animTest()
    -- FuncArmature.loadOneArmatureTexture("dazhao",c_func(self.onLoadComp, self), false)
    -- local texture, plist, xml = FuncRes.armature("effect_1"); --changzhuodaoren.bobj
    local texture, plist, xml = FuncRes.armature("changzhuodaoren");

    -- local texture, plist, xml = FuncRes.armature("mingyuetongzi");

    pc.ArmatureDataManager:getInstance():addArmatureFileInfo(xml)
    display.addSpriteFrames(plist, texture)

    -- armature = FuncArmature.createArmature("effect_1_file", nil, true);
    -- armature = FuncArmature.createArmature("changzhuodaoren_win", nil, true);

    armature = FuncArmature.createArmature("changzhuodaoren_skill1", nil, true);
    armature:setPosition(200, 200)

    self._root:addChild(armature);
end 



--新手引导检查
function Window_test:TutorialCheck()
    if OPEN_TUTORAL == true then 
        local tm = TutorialManager.getInstance();
        if tm:isAllFinish() == true then
            tm:dispose();
        else 
            tm:setRootNode(self._root);
            tm:prepareToTutor();
            --发送现在是主界面消息
            EventControler:dispatchEvent(TutorialEvent.TUTORIALEVENT_VIEW_CHANGE, 
                {viewName = "Window_test"});
        end 
    end 
end


function Window_test:doLogin()
    local params = {
        api = ServiceData.USER_LOGIN,
        uid = "1001",
        zid ="1",
    }
    local callBack = function(data)
        echo("doLogin callBack=================");
    end
    -- Conn.sendRequest(params);
    Server:getInstance():sendRequest(params,callBack);
end




function Window_test:onExit()
    --self.windowControler:onExitEx()
end

--测试
Window_test.btnNums = 0

local hangNums = 5
local wid = 150
local hei = 70
--创建一个测试按钮只用传递一个显示文本和一个点击函数即可,目前是自动排列
function Window_test:creatBtns( text,clickFunc )
    self.btnNums = self.btnNums + 1
    local xIndex =  self.btnNums %hangNums 
    xIndex = xIndex == 0 and hangNums or xIndex
    local yIndex = math.ceil( self.btnNums/hangNums )
    local xpos = GameVars.UIOffsetX +  (xIndex-1) * wid  + 30

    local ypos = GameVars.height - GameVars.UIOffsetY-(yIndex-1) * hei - 70
    local sp = display.newNode():addto(self._root):pos(xpos,ypos):anchor(0,0)
    sp:size(130,50)
    display.newRect(cc.rect(0, 0,130, 50),
        {fillColor = cc.c4f(1,1,1,0.8), borderColor = cc.c4f(0,1,0,1), borderWidth = 1}):addto(sp)

    display.newTTFLabel({text = text, size = 20, color = cc.c3b(255,0,0)})
            :align(display.CENTER, sp:getContentSize().width/2, sp:getContentSize().height/2)
            :addTo(sp):pos(65,25)
    sp:setTouchedFunc(clickFunc,cc.rect(0,0,127,64))
end


function Window_test:onExit()
end


--===================================================================
-- 富文本测试
function Window_test:fuwenbenTest()
    
    local _richText =  RichTextExpand.new():pos(200,400)
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setContentSize(cc.size(200, 100))
    local re1 = _richText:getRichElementText(1, cc.c3b(255, 255, 255), 255, "哈哈This color is white  ", GameVars.fontName, 20)
    local re2 = _richText:getRichElementText(2, cc.c3b(255, 255,   0), 255, "哈哈This color is white  ", GameVars.fontName, 20)
    local re3 = _richText:getRichElementText(3, cc.c3b(0,   0, 255), 255, "This one is blue. ", GameVars.fontName, 20)
    local re4 = _richText:getRichElementText(4, cc.c3b(0, 255,   0), 255, "And green. ", GameVars.fontName, 20)
    local re5 = _richText:getRichElementText(5, cc.c3b(255,  0,   0), 255, "Last one is red ", GameVars.fontName, 10)
    local re6 = _richText:getRichElementLinkLineNode(6, cc.c3b(255,  0,   0), 255, "哈哈This one", GameVars.fontName, 20)
    local re7 = _richText:getRichElementText(7, cc.c3b(255,  0,   0), 255, "Last one is red ", GameVars.fontName, 20)


    local func = function (  )
    end
    -- FuncArmature.loadOneArmatureTexture("test",nil,true)
    -- self._aniEff = FuncArmature.createArmature("zhandouzhong_kongzhixunhuan", nil, true,func)
    -- local re8 = _richText:getRichElementCustomNode(8, cc.c3b(255,  0,   0), 255, self._aniEff)

    local re9 = _richText:getRichElementImage(8, cc.c3b(255,  0,   0), 255, "ui/image_16.png")


    _richText:pushBackElement(re1)

    _richText:pushBackElement(re9)

    _richText:addNewLine()
    --_richText:pushBackElement(re2)
    _richText:insertElement(re2,0)

    -- _richText:pushBackElement(re8)
    
    _richText:pushBackElement(re3)
    _richText:addNewLine()
    _richText:pushBackElement(re4)
    _richText:pushBackElement(re5)
    
    _richText:pushBackElement(re6)
    _richText:addNewLine()
    _richText:pushBackElement(re7)

    
    
    self:addChild(_richText)

    self:delayCall(handler(self, self.delayCallHandler))
end

function Window_test:delayCallHandler( event )
    if self._aniEff then
        FuncArmature.clearOneArmatureTexture( "test" )
    end
    
    if tolua.isnull(self._aniEff) then
        echo("1111")
    else
        echo("2222")
    end
end



--===================================================================
function Window_test:ssssss( ... )
    echo("_______________________",self.__sssss:getPosition())
end
-- 战斗测试
function Window_test:enterGame(  )
    --WindowControler:chgScene("SceneGame")
    local img = FuncRes.uipng("arena_img_cd.png")
    local sp = display.newSprite(img):addto(self):pos(100,160)
    self.__sssss = sp
    local bezier = {  
        cc.p(100, 200),  
        cc.p(100, 200),  
        cc.p(220, 160),  
      }  
    -- 以持续时间和贝塞尔曲线的配置结构体为参数创建动作  
    local bzto = cc.BezierTo:create(0.3, bezier)
    local bzby = cc.BezierBy:create(0.3, bezier)
    local act_call = act.callfunc(  c_func(self.ssssss,self)  )
    local seq = cc.Sequence:create({bzto,act_call}) 
    sp:runAction(seq)
    
end

-- 测试动画倒播
function Window_test:testReverseAnim()
    FuncArmature.loadOneArmatureTexture("changzhuodaoren",c_func(self.onLoadReverseAnim, self),true)
end

function Window_test:onLoadReverseAnim()
    local ani = FuncArmature.createArmature("changzhuodaoren_ubullet", self ,true)
    ani:setScale(0.8)
    ani:pos(300,100)

    local callBack = function()
        ani:getAnimation():setWay(-1)
    end
    delayCallByFrame(15,callBack)
end

--===================================================================
-- 解析性能测试
function Window_test:testDecodePerformance()
    local resTab = {
        "bingdilian",
        -- "changzhuodaoren",
        -- "jiuyanshimo",
        -- "muhuayi",
        -- "taiyihongluan",
        -- "weishuixianjiqinbuyao",
        -- "xuanjijianzi",
        -- "zhantaizhaoying"
    } 
    local t1= os.clock();
    for i=1,#resTab do
        print(resTab[i])
        FuncArmature.loadOneArmatureTexture(resTab[i],c_func(self.onLoadCompPerformance, self),true)
    end
    local t2 = os.clock()
    print("time=",t2-t1)
end

function Window_test:onLoadCompPerformance(value )
    local ani = FuncArmature.createArmature("bingdilian_skill2", self ,true)
    ani:setScale(0.8)
    ani:pos(300,100)
end

--测试动画
function Window_test:testArmature(  )


-- FuncArmature.loadOneArmatureTexture("UI_treasure_shengxing2")


    -- local moveAction = cc.MoveTo:create(1, cc.p(100, 100));
    -- ani:runAction(moveAction);
    FuncArmature.createArmature("UI_common_juesexiaoshi", self, 
            false, GameVars.emptyFunc):pos(400, 200);

    -- local ani2 = FuncArmature.createArmature(
    --     "UI_unblock", self, true):pos(400, 200);  
    -- ani2:runAction(moveAction:clone());

end

function Window_test:onLoadComp(value )
    local flashOrSpine = self.flashOrSpine          -- 1是flash  2 是spine
    local checkMesh = self.checkMesh                --是否是mesh动画
    local isChangeBone = self.isChangeBone          --是否插入换装
    local boneNums = 18
    local nums = self.testNums

    -- echo(sp.SkeletonAnimation,"____sp.SkeletonAnimation")

    -- local tt = os.clock()
    -- for i=1,nums * boneNums do
    --     local testSp = display.newSprite("#_bitmap-torso.png", 0, 0):addto(self)
    -- end

    -- echo(os.clock() - tt,"__创建spirte时间")

    if not checkMesh then
        if flashOrSpine ==2 then
            local t1 = os.clock()

            for i=1,nums do
                local spNode = pc.PCSkeletonAnimation:createWithFile("asset/anim/spine/spineboy.json","asset/anim/spine/spineboy.atlas",1) --sp.SkeletonAnimation:create("asset/anim/spine/spineboy.json","asset/anim/spine/spineboy.atlas",1)
               
                if isChangeBone then
                    local testSp = display.newSprite("#_bitmap-torso.png", 0, 0)
                    spNode:addSubNode(testSp,"neck")
                end
                
                spNode:setAnimation(0,"walk",true)
                spNode:addto(self._root):pos(i*1+100,300)
            end

            if isChangeBone then
                echo(os.clock() - t1,"_____spine耗时__换1层装,数量:"..nums .."个")
            else
                echo(os.clock() - t1,"_____spine耗时,创建对象:"..nums.."个")
            end
        end
        
        if flashOrSpine == 1 then
            local index = 0

            local perFrame = nums/4

            local t2=0
            tempFunc = function (  )
                
                if index == 0 then
                    t2 = os.clock()
                end

                for i=1,perFrame do
                    local spNode  = pc.Armature:create("spineBoy_walk"):addto(self._root):pos((i+index)*3+200,400)  -- FuncArmature.createArmature("bingdilian_standby1",self._root,  true  ) :pos(100,100)  --sp.SkeletonAnimation:create("asset/anim/spine/dragon/dragon.json","asset/anim/spine/dragon/dragon.atlas",0.3)
                    spNode:getAnimation():playWithIndex(0,0,1)

                    if isChangeBone then
                        local testSp = display.newSprite("#_bitmap-torso.png", 0, 0)
                        FuncArmature.changeBoneDisplay(spNode,"head" , testSp, 0)
                    end
                    
                end
                index = index + perFrame
                if index >= nums then

                    if isChangeBone then
                        echo(os.clock() - t2,"_____flash动画耗时__换1层装,"..nums.."个")
                    else
                        echo(os.clock() - t2,"_____flash动画耗时,创建对象:"..nums.."个")
                    end

                    return
                end
                
                 delayCall(tempFunc2, 0.0001)
            end

            tempFunc2 = function (  )
                tempFunc()
            end

            delayCall(tempFunc, 1)
        end
    elseif checkMesh  then 
        local t1 = os.clock()
        for i=1,nums do
            local spNode = pc.PCSkeletonAnimation:createWithFile("asset/spine/spineboy500Mesh/export/spineboy.json","asset/spine/spineboy500Mesh/export/spineboy.atlas",0.5) --sp.SkeletonAnimation:create("asset/anim/spine/spineboy.json","asset/anim/spine/spineboy.atlas",1)
           
            if isChangeBone then
                local testSp = display.newSprite("#_bitmap-torso.png", 0, 0)
                spNode:addSubNode(testSp,"neck")
            end
            
            spNode:setAnimation(0,"walk",true)
            spNode:addto(self._root):pos(i*1+100,300)
        end

        if isChangeBone then
            echo(os.clock() - t1,"_____ spine mesh 顶点数 500  耗时__换1层装,"..nums.."个")
        else
            echo(os.clock() - t1,"_____spine  mesh 顶点数 500  耗时,创建对象:"..nums.."个")
        end
    end
end





--===================================================================
-- 输入测试
function Window_test:inputTest( ... )

    local listener = function( textfield, eventType )
        echo(eventType,"_________")
    end
    
    local params = {
        -- text ="输入测试",
        -- valign = "center",
        image="ui/panel_3.png",
        UIInputType =1,
        size = cc.size(200,50),
        listener = listener,
        x=100,
        y =100,
    }

    local editText = cc.ui.UIInput.new(params):addto(self)
    editText:setFontColor(cc.c3b(255,0))
    editText:setAnchorPoint(cc.p(0,1))

    local params = {
        text ="输入测试",
        align ="center",
        valign = "center",

        UIInputType =2,
        size = cc.size(200,50),
        listener = listener,
        x=300,
        y =100,

    }

    local editText = cc.ui.UIInput.new(params):addto(self)
    editText:setAnchorPoint(cc.p(0,0))
    editText:setColor(cc.c3b(255,0,0))
    --editText:setAnchorPoint(cc.p(0,1))
end




return Window_test
