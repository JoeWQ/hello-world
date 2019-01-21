--三皇抽奖系统
--2016-12-27 10:40
--@Author:wukai

local EllipseType = import("script.game.sys.view.newlottery.EllipseType")
local NewLotteryMainView = class("NewLotteryMainView", UIBase);
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
function NewLotteryMainView:ctor(winName,cardID)
    NewLotteryMainView.super.ctor(self, winName)
    self.freestring = "本次免费"
    self.firstcostRMB = false
    self.Countdownsch = nil
    if cardID ~= nil then
        self.showCardID = tonumber(cardID)
    else
        self.showCardID = nil
    end
    -- FuncNewLottery.getlotteryShoprefreshitems()
    ShopServer:getShopInfo()  -- 请求商店信息
end
NewLotteryMainView.freeselectlotter = 1 --默认是一次
NewLotteryMainView.RMBselectlotter = 1 --默认是一次
function NewLotteryMainView:loadUIComplete()
    FuncCommUI.setViewAlign(self.btn_back,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.mc_UI,UIAlignTypes.RightTop) --panel_UI
    FuncCommUI.setViewAlign(self.panel_icon,UIAlignTypes.LeftTop)
    FuncCommUI.setScale9Align(self.scale9_resdi,UIAlignTypes.MiddleTop,1,0)
    FuncCommUI.setViewAlign(self.mc_1,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.mc_2,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.btn_jiangchi,UIAlignTypes.RightTop)


    self.btn_back:setTap(c_func(self.press_btn_close,self))
    self.mc_1.currentView.btn_1:setTap(c_func(self.TouchFreeButton,self))
    self.mc_2.currentView.btn_1:setTap(c_func(self.TouchRNBButton,self))

    self.btn_jiangchi:setTap(c_func(self.replaceButton,self))
    
    -- self.windowCfg.bg


    self.freeioncetems = self.mc_zao1:getViewByFrame(1).mc_cost:getViewByFrame(1).txt_1 --免费抽次数对象
    self.ordinarycard = self.mc_zao2:getViewByFrame(1).mc_cost:getViewByFrame(2).txt_1  --普通造物符对象
    self.senioroncestring = self.mc_zao1:getViewByFrame(2).mc_cost2:getViewByFrame(1).txt_1  --rmb一次对象
    self.seniortencard =   self.mc_zao2:getViewByFrame(2).mc_cost2:getViewByFrame(2).txt_1--高级造物符对象

    self.selectbuttonindex = 1
    self.CDtime = 0
    self:addellipse()
    self:Defaultshowselect()
    self:selectfreeAndRMBOnTouch()
    self:addEventListeners()
    if self.showCardID ~= nil then
        self:selectDefaultshowselect(self.showCardID)
    end
    FuncNewLottery.CachePartnerdata()
    self:addcardButton()
    self:addBeiJinJSound()
end
function NewLotteryMainView:addBeiJinJSound()
    audio.preloadSound(MusicConfig.s_scene_Luck_turn)
    if audio.isMusicPlaying() then
        AudioModel:stopMusic()
    end
    AudioModel:playMusic(MusicConfig.s_scene_luck,true)
    
end
function NewLotteryMainView:addcardButton()
    self.mc_UI:getViewByFrame(2).panel_1.btn_xianyujiahao:setTap(function ()
        WindowControler:showTips("获取途径暂未开启")
    end)
    self.mc_UI:getViewByFrame(1).panel_1.btn_xianyujiahao:setTap(function ()
        WindowControler:showTips("获取途径暂未开启")
    end)

end
--显示造物卡的数量--低级
function NewLotteryMainView:DiJicardexchangeShowUI()
    local view = self.mc_UI:getViewByFrame(2).panel_1.txt_xianyu
    local numer =  NewLotteryModel:getordinaryDrawcard()
    view:setString(numer)

end
--显示造物卡的数量--高级
function NewLotteryMainView:GaoJicardexchangeShowUI()
    local view = self.mc_UI:getViewByFrame(1).panel_1.txt_xianyu
    local numer =  NewLotteryModel:getseniorDrawcard()
    view:setString(numer)

end


function NewLotteryMainView:addellipse()
    self.panel_fangda.mc_wupin1:visible(false)
    local object = {}
    for i=1,6 do
        local view = UIBaseDef:cloneOneView(self.panel_fangda.mc_wupin1)
        object[i] = view
    end
    local config ={
        EllipselengthA = 270,
        EllipseshortB = 60,
        DirectionRotation = 1,
        ObjectNumber = 6
    }
    self.ellipsenode = EllipseType.new(object,config,self.windowCfg.bg)
    self.ellipsenode:setPosition(cc.p(300,0))
    self.panel_fangda:addChild(self.ellipsenode)
    -- self.panel_fangda:setLocalZOrder()
    -- self.ellipsenode:getcallback(self:createUIArmature("UI_chouka_a","UI_chouka_a_wenhao", nil, true, GameVars.emptyFunc))
    self.ellipsenode:getMianviewself(self)

end



function NewLotteryMainView:selectfreeAndRMBOnTouch()
    self.mc_zao1:setTouchEnabled(true)
    self.mc_zao1:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
            local result = self:touchSelectone(event)
            return result or false
        end)
    self.mc_zao2:setTouchEnabled(true)
    self.mc_zao2:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
            local result = self:touchSelecttwo(event)
            return result or false
        end)
end
function NewLotteryMainView:touchSelectone(event)
    if event.name == "began" then
        self.movex =  event.x
        self.movey =  event.y
        return true
    elseif event.name == "moved" then



    elseif  event.name == "ended" then
        if math.abs(event.x - self.movex) < 15 and math.abs(event.y - self.movey) < 15 then
            if  self.selectbuttonindex == 1 then
                self.mc_zao1:getViewByFrame(1).panel_1:visible(true)
                self.mc_zao2:getViewByFrame(1).panel_1:visible(false)
                NewLotteryMainView.freeselectlotter = 1
                FuncNewLottery.setlotteryFreeType(NewLotteryMainView.freeselectlotter)
                self.mc_zao1:getViewByFrame(1).panel_lan:visible(true)
                self.mc_zao2:getViewByFrame(1).panel_lan:visible(false)
            else
                self.mc_zao1:getViewByFrame(2).panel_1:visible(true)
                self.mc_zao2:getViewByFrame(2).panel_1:visible(false)
                NewLotteryMainView.RMBselectlotter = 1
                FuncNewLottery.setlotteryRMBType(NewLotteryMainView.RMBselectlotter)
                self.mc_zao1:getViewByFrame(2).panel_zi:visible(true)
                self.mc_zao2:getViewByFrame(2).panel_zi:visible(false)
            end
        end
    end

end

function NewLotteryMainView:addEventListeners()
    EventControler:addEventListener(NewLotteryEvent.START_LOTTERY,self.bgandellipseaction,self)
    -- EventControler:addEventListener(NewLotteryEvent.REFRESH_FREE_UI,self.RefreshAllui,self)
    -- EventControler:addEventListener(NewLotteryEvent.REFRESH_RMBPAY_UI,self.RefreshAllui,self)
    EventControler:addEventListener(NewLotteryEvent.BLACK_LOTTERY_MAIN,self.addEillpseEffect,self)
    EventControler:addEventListener(CountEvent.COUNTEVENT_MODEL_UPDATE,self.dailyrefreshAllui,self)
    EventControler:addEventListener(NewLotteryEvent.GET_AUDIO_BLACK_MAIN,self.addBeiJinJSound,self)

    

end
function NewLotteryMainView:dailyrefreshAllui()
    -- echo("======================时间和数据及时刷新==================")
    local selecttype =  FuncNewLottery.getlotterytype()
    if tonumber(selecttype) == 1 then
        local data = NewLotteryModel:getfreeawardpool()
        self.ellipsenode:updata(data)
    else
        local data = NewLotteryModel:getRMBawardpool()
        self.ellipsenode:updata(data)
    end
    self:initfreeData()
    self:initRMBData()
    self:DiJicardexchangeShowUI()
    self:GaoJicardexchangeShowUI()
    self:refreshawardStringshow()
    -- EventControler:dispatchEvent(NewLotteryEvent.REFRESH_LOTTERY_SHOP_UI)
end

--刷新所有界面
function NewLotteryMainView:RefreshAllui()
    -- WindowControler:showTips("替换特效添加")
    local index,quality = NewLotteryModel:getihuangIndex()
    local ctn_1 = self.ellipsenode.newObjectTable[tonumber(index)]
    local effecttype = nil 
    if quality == 1 then
        effecttype = "UI_chouka_b_bai"
    elseif quality == 2 then
        effecttype = "UI_chouka_b_lv"
    elseif quality == 3 then
        effecttype = "UI_chouka_b_lan"
    elseif quality == 4 then
        effecttype = "UI_chouka_b_zi"
    elseif quality == 5 then
        effecttype = "UI_chouka_b_jin"
    end

    local lockAnione = self:createUIArmature("UI_chouka_b","UI_chouka_b_xianshichuxian", ctn_1.currentView.ctn_1, false,function ()
    end)
    lockAnione:registerFrameEventCallFunc(15,1,function ()
        self:bdactionBlack2()
        self:dailyrefreshAllui()
    end)
    lockAnione:doByLastFrame( true, true ,function () end)
    -- self:delayCall(function()
    --    self:bdactionBlack2()
    --     self:dailyrefreshAllui()
    -- end,1.5)
    

end
-- function NewLotteryMainView:addXuanzhuangEffect()
--    -- self.panel_fangda
--    local lockAnione = self:createUIArmature("UI_chouka_a","UI_chouka_a_xuzhuanfeng", self.panel_fangda, true,function ()end)
--    -- lockAnione:doByLastFrame( true, true ,function () end)
--    lockAnione:setPosition(cc.p(340,-110))
--    lockAnione:runAction(act.scaleto(1,1.2,1.2))


-- end
function NewLotteryMainView:bgandellipseaction()

    self.ellipsenode:setPosition(cc.p(300,10))
    -- self:addXuanzhuangEffect()

    local movex = -120
    local movey = -200
    self.mc_1:runAction(act.moveby(1,movex,0))
    self.mc_2:runAction(act.moveby(1,movex,0))
    self.btn_jiangchi:runAction(act.moveby(0.5,-movex,0))
    self.mc_zao1:runAction(act.moveby(1,0,movey))
    self.mc_zao2:runAction(act.moveby(1,0,movey))

    self.btn_back:runAction(act.moveby(1,0,-movey))
    self.mc_UI:runAction(act.moveby(1,0,-movey))--panel_UI
    self.panel_icon:runAction(act.moveby(1,0,-movey))
    self.scale9_resdi:runAction(act.moveby(1,0,-movey))
    self.panel_3:runAction(act.moveby(1,0,movey))
    self.mc_small:runAction(act.moveby(1,0,movey))


    -- self.__bgView:anchor(0.5,0.5)
    self.yuyanlaiX = self.__bgView:getPositionX()
    self.yuyanlaiY = self.__bgView:getPositionY()

    local pso = {
        x = self.yuyanlaiX,
        y = self.yuyanlaiY,
    } 

    local scale = 1.2
    local time = 1
    
    local box = self.__bgView:getContainerBox()
    local xpos = (box.width * scale - box.width)/2
    local ypos = (box.height * scale - box.height)/2
    local scaleAnim = act.spawn(
            act.scaleto(time,scale,scale),
            act.moveto(time,pso.x - xpos,pso.y + ypos)
        )
    self.__bgView:runAction(scaleAnim)
    self.ellipsenode:runAction(act.scaleto(time,scale,scale))


end

function NewLotteryMainView:addEillpseEffect()
    -- WindowControler:showTips("播放替换特效")
    self:RefreshAllui()
    -- EventControler:dispatchEvent(NewLotteryEvent.ADD_EILLPSE_EFFECT)
    -- self:delayCall(c_func(self.bdactionBlack2, self),1.5)

end
function NewLotteryMainView:bdactionBlack2()
    
    
    -- WindowControler:showTips("替换特效添加")

    self.ellipsenode:setPosition(cc.p(300,0))
    local movex = 120
    local movey = 200
    self.mc_1:runAction(act.moveby(1,movex,0))
    self.mc_2:runAction(act.moveby(1,movex,0))
    self.btn_jiangchi:runAction(act.moveby(1,-movex,0))
    self.mc_zao1:runAction(act.moveby(1,0,movey))
    self.mc_zao2:runAction(act.moveby(1,0,movey))

    self.btn_back:runAction(act.moveby(1,0,-movey))
    self.mc_UI:runAction(act.moveby(1,0,-movey))--panel_UI
    self.panel_icon:runAction(act.moveby(1,0,-movey))
    self.scale9_resdi:runAction(act.moveby(1,0,-movey))
    self.panel_3:runAction(act.moveby(1,0,movey))
    self.mc_small:runAction(act.moveby(1,0,movey))

    self.scaleyingzi = 1
    self.ellipsenode.moveInAnticlockwise = true
    self.ellipsenode:openAction()
    local scale = 1
    local time = 1   
    local pso = {
        x = self.yuyanlaiX, 
        y = self.yuyanlaiY,
    } 
    local box = self.__bgView:getContainerBox()
    local xpos = (box.width * scale - box.width)/2
    local ypos = (box.height * scale - box.height)/2
    local scaleAnim = act.spawn(
            act.scaleto(time,scale,scale),
            act.moveto(time,pso.x + xpos,pso.y - ypos)
        )
    self.__bgView:runAction(scaleAnim)
    self.ellipsenode:runAction(act.scaleto(time,scale,scale))
    self:delayCall(function ()
        self.ellipsenode:setsprinttouchu(true)
    end,1.0)
    
    -- self:RefreshAllui()

end
-- function NewLotteryMainView:OpactionAndScale2()
--     if self.bgscale <= 1.05  then
--         self:unscheduleUpdate()
--         self.__bgView:anchor(0,1)
--         self.__bgView:setPosition(cc.p(self.yuyanlaiX,self.yuyanlaiY))
--         self.ellipsenode:setsprinttouchu(true)
--         -- self.ellipsenode:setPosition(cc.p(-55,110))
--     end
--     self.bgscale = self.bgscale - self.fangdayizi 
--     if self.__bgView ~= nil then
--         self.__bgView:setScale(self.bgscale)
--     end
--     self.ellipsenode:setScale(self.bgscale)
-- end


function NewLotteryMainView:touchSelecttwo(event)
    if event.name == "began" then
        self.movex =  event.x
        self.movey =  event.y
        return true
    elseif event.name == "moved" then


    elseif  event.name == "ended" then
        if math.abs(event.x - self.movex) < 15 and math.abs(event.y - self.movey) < 15 then
            if  self.selectbuttonindex == 1 then
                self.mc_zao1:getViewByFrame(1).panel_1:visible(false)
                self.mc_zao2:getViewByFrame(1).panel_1:visible(true)
                NewLotteryMainView.freeselectlotter = 5
                FuncNewLottery.setlotteryFreeType(NewLotteryMainView.freeselectlotter)
                self.mc_zao1:getViewByFrame(1).panel_lan:visible(false)
                self.mc_zao2:getViewByFrame(1).panel_lan:visible(true)
            else
                self.mc_zao1:getViewByFrame(2).panel_1:visible(false)
                self.mc_zao2:getViewByFrame(2).panel_1:visible(true)
                NewLotteryMainView.RMBselectlotter = 10
                FuncNewLottery.setlotteryRMBType(NewLotteryMainView.RMBselectlotter)
                self.mc_zao1:getViewByFrame(2).panel_zi:visible(false)
                self.mc_zao2:getViewByFrame(2).panel_zi:visible(true)
            end
        end
    end
end

function NewLotteryMainView:refreshawardStringshow(_def)
    -- local sumnumber = 10 --总数量
    local sumnumber = 9
    local Lotteryitems = NewLotteryModel:RMBcounts() 
    local parmes = NewLotteryModel:getnextTreasureFlag()
    -- echo("======parmes===========",parmes)
    if parmes ~= nil then
        if parmes == 0 then
            parmes = 1
        elseif parmes == 1 then
            parmes = 2
        elseif parmes == 2 then
            parmes = 1
        end
    else
        parmes = 1
    end


    local lotteryType = FuncNewLottery.getlotteryRMBType()
    -- echo("=======Lotteryitems==========",Lotteryitems)
    local level = FuncNewLottery.getawardLevelopenfree()
    if UserModel:level() >= level then
        if tonumber(lotteryType) ~= 10 then

            self.panel_3.txt_2:setString(sumnumber-math.fmod(Lotteryitems,10))
        else --十抽的时候
            self.panel_3.txt_2:setString(sumnumber-math.fmod(Lotteryitems,10))

        end

        self.panel_3.txt_1:visible(true)
        self.panel_3.mc_1:showFrame(parmes)
        if sumnumber-math.fmod(Lotteryitems,10) == 0 then
            if Lotteryitems ~= 0 then 
                self.panel_3.txt_2:setString("本")
                self.panel_3.txt_1:visible(false)
            end
        elseif sumnumber-math.fmod(Lotteryitems,10) == sumnumber then
            self.panel_3.txt_2:setString(sumnumber)
            self.panel_3.txt_1:visible(true)
        end
    else
        -- echo("=========self.Lotteryitems========",Lotteryitems)
        self.panel_3.mc_1:showFrame(parmes)
        self.panel_3.txt_1:visible(true)
        self.panel_3.txt_2:setString(sumnumber-math.fmod(Lotteryitems,10))
        if sumnumber-math.fmod(Lotteryitems,10) == 0 then
            if Lotteryitems ~= 0 then
                self.panel_3.txt_2:setString("本")
                self.panel_3.txt_1:visible(false)
            end
        elseif sumnumber-math.fmod(Lotteryitems,10) == sumnumber then
            self.panel_3.txt_2:setString(sumnumber)
            self.panel_3.txt_1:visible(true)
        end
    end
end
function NewLotteryMainView:selectDefaultshowselect(showCardID)
    -- echo("===showCardID=======",showCardID)

    local itemsdata = FuncItem.getItemData(showCardID)
    if itemsdata == nil then
        echo("不存在该道具的ID====",showCardID)
    end
    local  showCardIDs = tonumber(itemsdata.subType)
    if showCardIDs == 312 then --低级道具
        self:TouchFreeButton()
    elseif showCardIDs == 313 then  --高级道具
        self:TouchRNBButton()
    end
end
function NewLotteryMainView:Defaultshowselect()
    -- FuncNewLottery.setTouchawardtype(1)

    FuncNewLottery.setlotterytype(1)
    FuncNewLottery.setlotteryFreeType( NewLotteryMainView.freeselectlotter )
    self.mc_1:showFrame(2)
    self.btn_jiangchi:visible(false)
    self.panel_3:visible(false)
    self.mc_UI:showFrame(2)  --:visible(false)
    self:showfreeselectUI()
    if self.selectbuttonindex == 1 then
        self.mc_zao1:getViewByFrame(1).mc_1:showFrame(1)
        self.mc_zao2:getViewByFrame(1).mc_1:showFrame(2)
        self.mc_zao1:getViewByFrame(1).panel_lan:visible(true)
        self.mc_zao2:getViewByFrame(1).panel_lan:visible(false)
        self.mc_small:showFrame(1)
    end
    local level = FuncNewLottery.getawardLevelopenfree()
    if UserModel:level() >= level then
        self.panel_3.mc_1:showFrame(2)
    else
        self.panel_3.mc_1:showFrame(1)
    end
    local data = NewLotteryModel:getfreeawardpool()
    self.ellipsenode:updata(data)


    local cdtime = NewLotteryModel:getCDtime()
    if  cdtime ~= 0 then
        self.cdtime = cdtime
        self:setcdtime()
    end
    self:initfreeData()
    self:initRMBData()
    self:DiJicardexchangeShowUI()
    self:GaoJicardexchangeShowUI()
    self:refreshawardStringshow()
end



--初始化免费数据
---[[
function NewLotteryMainView:initfreeData()
    
    self.serverdatafreeonce = NewLotteryModel:getLotterynumber() --服务器抽奖次数
    local Differ = FuncNewLottery.getFreecardnumber() - self.serverdatafreeonce
    -- --显示免费一次造物符
    if Differ ~= 0 then
        self.mc_zao1:getViewByFrame(1).mc_cost:showFrame(1)
        self.freeioncetems:setString(self.freestring..Differ.."/"..FuncNewLottery.getFreecardnumber())
    else
        self.mc_zao1:getViewByFrame(1).mc_cost:showFrame(2)
        local freeioncetemsstring = self.mc_zao1:getViewByFrame(1).mc_cost:getViewByFrame(2).txt_1
        local number = NewLotteryModel:getordinaryDrawcard()
        -- if number >= FuncNewLottery.Ordninaryfreecardnumber() then
        --         --还原颜色
        --     freeioncetemsstring:setColor(self:HEXtoC3b("0xffec93"))
        -- else
        --     freeioncetemsstring:setColor(cc.c3b(255,0, 0))
        -- end
        freeioncetemsstring:setString(number.."/"..FuncNewLottery.Ordninaryfreecardnumber())

    end
    --显示免费五次造物符
    local onefreenumber = 5 * FuncNewLottery.Ordninaryfreecardnumber()
    self.mc_zao2:getViewByFrame(1).mc_cost:showFrame(2)

    local number = NewLotteryModel:getordinaryDrawcard()
    -- if number >=  5 * FuncNewLottery.Ordninaryfreecardnumber() then
    --             --还原颜色
    --     self.ordinarycard:setColor(self:HEXtoC3b("0xffec93"))
    -- else
    --     self.ordinarycard:setColor(cc.c3b(255,0, 0))
    -- end
    self.ordinarycard:setString(number.."/"..onefreenumber)


    self:RefreshfreecradUI()
     
end
-- ]]
--初始化元宝数据
function NewLotteryMainView:initRMBData()
    --显示元宝十次高级造物符
    local tenRMBnumber = FuncNewLottery.consumeTenRMB()
    self.seniortencard:setString(tenRMBnumber)
    local seniorDrawcard = NewLotteryModel:getseniorDrawcard()
    local RMBonce = NewLotteryModel:getRMBoneLottery() --花费元宝抽
    local RMBfirstlottery =  NewLotteryModel:getRMBPayLottery()
    -- echo("====seniorDrawcard========RMBonce==========RMBfirstlottery=============",seniorDrawcard,RMBonce,RMBfirstlottery)
    if RMBonce ~= 0 then
        if seniorDrawcard > 0 then
            self.mc_zao1:getViewByFrame(2).mc_cost2:showFrame(3)
            
            self.mc_zao1:getViewByFrame(2).mc_cost2:getViewByFrame(3).txt_1:setString(seniorDrawcard.."/1")
        else
            -- self.mc_zao1:getViewByFrame(2).mc_cost2:showFrame(2)
            if  RMBfirstlottery == 0 then
                self.mc_zao1:getViewByFrame(2).mc_cost2:showFrame(4)
                self.mc_zao1:getViewByFrame(2).mc_cost2:getViewByFrame(4).txt_2:setString(FuncNewLottery.consumeOnceRMB()/2)  --消耗一半元宝
            else
                self.mc_zao1:getViewByFrame(2).mc_cost2:showFrame(2)
                self.mc_zao1:getViewByFrame(2).mc_cost2:getViewByFrame(2).txt_1:setString(FuncNewLottery.consumeOnceRMB())
            end
        end

    elseif RMBonce == 0 then
        self.mc_zao1:getViewByFrame(2).mc_cost2:showFrame(1)
    end

    if seniorDrawcard >= 10 then
        self.mc_zao2:getViewByFrame(2).mc_cost2:showFrame(3)
        self.mc_zao2:getViewByFrame(2).mc_cost2:getViewByFrame(3).txt_1:setString(seniorDrawcard.."/10")
    else
        self.mc_zao2:getViewByFrame(2).mc_cost2:showFrame(2)
        self.mc_zao2:getViewByFrame(2).mc_cost2:getViewByFrame(3).txt_1:setString(FuncNewLottery.consumeTenRMB())  
    end
end

function NewLotteryMainView:RefreshfreecradUI()
    
    local freeitems  = NewLotteryModel:getLotterynumber()
    local ordinarycrad = NewLotteryModel:getordinaryDrawcard()
    local cdtime = NewLotteryModel:getCDtime()
    -- echo("====freeitems========ordinarycrad==========cdtime=============",freeitems,ordinarycrad,cdtime)
    if freeitems ~= 0 then
        if ordinarycrad ~= 0 then
            ---不显示倒计时，显示普通造物符
            if cdtime == 0 then
                -- 显示免费次数
                self.serverdatafreeonce = NewLotteryModel:getLotterynumber() --服务器抽奖次数
                local Differ = FuncNewLottery.getFreecardnumber() - self.serverdatafreeonce
                --显示免费一次造物符
                if Differ ~= 0 then
                    self.mc_zao1:getViewByFrame(1).mc_cost:showFrame(1)
                    self.freeioncetems:setString(self.freestring..Differ.."/"..FuncNewLottery.getFreecardnumber())
                else
                    self.mc_zao1:getViewByFrame(1).mc_cost:showFrame(2)
                    local freeioncetemsstring = self.mc_zao1:getViewByFrame(1).mc_cost:getViewByFrame(2).txt_1
                    local number = NewLotteryModel:getordinaryDrawcard()
                    -- if number >= FuncNewLottery.Ordninaryfreecardnumber() then
                    --         --还原颜色
                    --     freeioncetemsstring:setColor(self:HEXtoC3b("0xffec93"))
                    -- else
                    --     freeioncetemsstring:setColor(cc.c3b(255,0, 0))
                    -- end
                    freeioncetemsstring:setString(number.."/"..FuncNewLottery.Ordninaryfreecardnumber())
                end

            else
                local Differ = FuncNewLottery.getFreecardnumber() - NewLotteryModel:getLotterynumber()
                --显示免费一次造物符
                local freeioncetemsstring = self.mc_zao1:getViewByFrame(1).mc_cost:getViewByFrame(2).txt_1
                local number = NewLotteryModel:getordinaryDrawcard()
                -- if number >= FuncNewLottery.Ordninaryfreecardnumber() then
                --         --还原颜色
                --     freeioncetemsstring:setColor(self:HEXtoC3b("0xffec93"))
                -- else
                --     freeioncetemsstring:setColor(cc.c3b(255,0, 0))
                -- end
                    freeioncetemsstring:setString(number.."/"..FuncNewLottery.Ordninaryfreecardnumber())
                    self.cdtime = NewLotteryModel:getCDtime()
                    self:setcdtime()
                    self.mc_zao1:getViewByFrame(1).mc_cost:showFrame(2)
                -- freeioncetemsstring:setString(FuncNewLottery.Ordninaryfreecardnumber())
            end
        else
            --显示时间
            if  cdtime ~= 0 then
                self.cdtime = NewLotteryModel:getCDtime()
                self:setcdtime()
            else
                local freeioncetemsstring = self.mc_zao1:getViewByFrame(1).mc_cost:getViewByFrame(2).txt_1
                local number = NewLotteryModel:getordinaryDrawcard()
                -- echo("============11111========",number)
                -- if number >= FuncNewLottery.Ordninaryfreecardnumber() then
                --         --还原颜色
                --     freeioncetemsstring:setColor(self:HEXtoC3b("0xffec93"))
                -- else
                --     freeioncetemsstring:setColor(cc.c3b(255,0, 0))
                -- end
                freeioncetemsstring:setString(number.."/"..FuncNewLottery.Ordninaryfreecardnumber())
            end
        end
    else
        if  cdtime ~= 0 then
            self.cdtime = NewLotteryModel:getCDtime()
            self:setcdtime()
        end
    end
end
function NewLotteryMainView:HEXtoC3b(hex)
    local flag = string.lower(string.sub(hex,1,2))
    local len = string.len(hex)
    if len~=8 then
        print("hex is invalid")
        return nil 
    end
    if flag ~= "0x" then
        print("not is a hex")
        return nil
    end
    local rStr =  string.format("%d","0x"..string.sub(hex,3,4))
    local gStr =  string.format("%d","0x"..string.sub(hex,5,6))
    local bStr =  string.format("%d","0x"..string.sub(hex,7,8))
    -- print(rStr,gStr,bStr)
    -- local ten = string.format("%d",hex)
    ten = cc.c3b(rStr,gStr,bStr)
    return ten
end
function NewLotteryMainView:setcdtime()
    if self.cdtime ~= 0 then
        local onetime =  math.floor(self.cdtime/3600)
        if string.len(onetime) == 1 then
            onetime = "0"..onetime
        end
        local onebranch = math.floor((self.cdtime - onetime*3600)/60)
        if string.len(onebranch) == 1 then
            onebranch = "0"..onebranch
        end
        local onesecond =  math.fmod(self.cdtime - onetime*3600, 60)
        if string.len(onesecond) == 1 then
            onesecond = "0"..onesecond
        end
        self.Atimes = onetime
        self.Abranchs = onebranch
        self.Aseconds = onesecond
    else
        self.Atimes = "00"
        self.Abranchs = "00"
        self.Aseconds = "00"
    end
    self.mc_zao1:getViewByFrame(1).mc_cost:showFrame(1)
    self.freeioncetems:setString(self.Abranchs..":"..self.Aseconds)
    if self.Countdownsch == nil then
        self.Countdownsch = scheduler.scheduleGlobal(c_func(self.showCountdown,self), 1)
    end
end
function NewLotteryMainView:showCountdown()
    ---一次的时间
        self.Aseconds = self.Aseconds - 1
        if self.Aseconds == -1  then
            if self.Abranchs ~= -1 then
                self.Abranchs = self.Abranchs - 1
                self.Aseconds = 59
                if self.Abranchs == -1 then
                    if self.Atimes ~= -1 then 
                        self.Atimes = self.Atimes - 1
                        self.Abranchs = 59 
                        if self.Atimes == -1 then
                            self.Atimes = 0
                            self.Abranchs = 0
                            self.Aseconds = 0
                            if self.Countdownsch ~= nil then
                                scheduler.unscheduleGlobal(self.Countdownsch)
                                self.Countdownsch = nil
                                self:initfreeData()
                                self:initRMBData()
                                self:DiJicardexchangeShowUI()
                                self:GaoJicardexchangeShowUI()
                                return 
                            end
                        end
                    end
                end
            end
        end
        self.Atimes = self.Atimes..""
        self.Abranchs  = self.Abranchs..""
        self.Aseconds = self.Aseconds..""

        if string.len(self.Atimes) == 1 then
            self.Atimes = "0"..self.Atimes
        end
        if string.len(self.Abranchs) == 1 then
            self.Abranchs = "0"..self.Abranchs 
        end
        if string.len(self.Aseconds) == 1 then
            self.Aseconds = "0"..self.Aseconds
        end
        -- self.mc_zao1:getViewByFrame(1).mc_cost:showFrame(1)
        self.freeioncetems:setString(self.Abranchs..":"..self.Aseconds)


end
function NewLotteryMainView:showfreeselectUI()
    self.mc_zao1:showFrame(1)
    self.mc_zao2:showFrame(1)
    self.mc_zao1:getViewByFrame(1).mc_1:showFrame(1)
    self.mc_zao2:getViewByFrame(1).mc_1:showFrame(2)
    if NewLotteryMainView.freeselectlotter == 1 then
        --显示打钩造物一次
        self.mc_zao1:getViewByFrame(1).panel_1:visible(true)
        self.mc_zao2:getViewByFrame(1).panel_1:visible(false)
        FuncNewLottery.setlotteryFreeType( NewLotteryMainView.freeselectlotter )
        self.mc_zao1:getViewByFrame(1).panel_lan:visible(true)
        self.mc_zao2:getViewByFrame(1).panel_lan:visible(false)
        -- self.mc_zao1:getViewByFrame(2).panel_zi:visible(false)
        -- self.mc_zao2:getViewByFrame(2).panel_zi:visible(true)

    else
        FuncNewLottery.setlotteryFreeType( NewLotteryMainView.freeselectlotter )
        --显示打钩造物五次
        self.mc_zao1:getViewByFrame(1).panel_1:visible(false)
        self.mc_zao2:getViewByFrame(1).panel_1:visible(true)
        -- self.mc_zao1:getViewByFrame(1).panel_zi:visible(false)
        -- self.mc_zao2:getViewByFrame(1).panel_zi:visible(true)
         self.mc_zao1:getViewByFrame(1).panel_lan:visible(false)
        self.mc_zao2:getViewByFrame(1).panel_lan:visible(true)
    end
end

function NewLotteryMainView:showRMBcradUI()
    self.mc_zao1:showFrame(2)
    self.mc_zao2:showFrame(2)
    self.mc_zao1:getViewByFrame(2).mc_1:showFrame(1)
    self.mc_zao2:getViewByFrame(2).mc_1:showFrame(3)
    if NewLotteryMainView.RMBselectlotter == 1 then
        FuncNewLottery.setlotteryRMBType( NewLotteryMainView.RMBselectlotter )
        --显示RMB打钩造物一次
        self.mc_zao1:getViewByFrame(2).panel_1:visible(true)
        self.mc_zao2:getViewByFrame(2).panel_1:visible(false)
        self.mc_zao1:getViewByFrame(2).panel_zi:visible(true)
        self.mc_zao2:getViewByFrame(2).panel_zi:visible(false)
    else
        FuncNewLottery.setlotteryRMBType( NewLotteryMainView.RMBselectlotter )
        --显示RMB打钩造物十次
        self.mc_zao1:getViewByFrame(2).panel_1:visible(false)
        self.mc_zao2:getViewByFrame(2).panel_1:visible(true)
        self.mc_zao1:getViewByFrame(2).panel_zi:visible(false)
        self.mc_zao2:getViewByFrame(2).panel_zi:visible(true)
    end
end


--点击普通造物
function NewLotteryMainView:TouchFreeButton()
    ---不是当前叶签（免费造物）
    local x = CountModel:getCountByType()
    if self.selectbuttonindex ~= 1 then
        self.selectbuttonindex = 1
        self.mc_1:showFrame(2)
        self:selectshowUI(self.selectbuttonindex)
        -- self:RefreshfreecradUI()
        self:showfreeselectUI()
        self.mc_small:showFrame(1)
        local data = NewLotteryModel:getfreeawardpool()
        self.ellipsenode:updata(data)
        -- FuncNewLottery.setTouchawardtype(1)
        FuncNewLottery.setlotterytype(1)
        self.btn_jiangchi:visible(false)
        self.panel_3:visible(false)
        self.mc_UI:showFrame(2)
        -- self.panel_UI:visible(false)
    end
end
--点击三星（消耗元宝）造物
function NewLotteryMainView:TouchRNBButton()
    if self.selectbuttonindex ~= 2 then
        self.selectbuttonindex = 2
        self.mc_2:showFrame(2)
        self:selectshowUI(self.selectbuttonindex)
        self:showRMBcradUI()
        self.mc_small:showFrame(2)
        local data = NewLotteryModel:getRMBawardpool()
        self.ellipsenode:updata(data)
        -- FuncNewLottery.setTouchawardtype(2)
        FuncNewLottery.setlotterytype(2)
        self.btn_jiangchi:visible(true)
        self.panel_3:visible(true)
        self.mc_UI:showFrame(1)
        -- self.panel_UI:visible(true)
    end
end
--选着显示界面
function NewLotteryMainView:selectshowUI(index)
    if index == 1 then
        self.mc_2:showFrame(1)
    elseif index == 2 then
        self.mc_1:showFrame(1)
    end
end

---刷新显示Ui界面
function NewLotteryMainView:RefreshUIdata()
end

function NewLotteryMainView:lotteryResult()
    -- NewLotteryModel:getLotterynumber()
end

---奖池替换按钮
function NewLotteryMainView:replaceButton()
   echo("奖池替换界面")
   WindowControler:showWindow("NewLotteryShopView")

end

--免费抽一次选择
function NewLotteryMainView:freeselectOnce()
    NewLotteryMainView.freeselectlotter = 1
end
--免费抽五次选择
function NewLotteryMainView:freeselectFirve()
    NewLotteryMainView.freeselectlotter = 5
end
--元宝抽一次选择
function NewLotteryMainView:RMBselectOnce()
    NewLotteryMainView.RMBselectlotter = 1
end
--元宝抽十次选择
function NewLotteryMainView:RMBselectTen()
    NewLotteryMainView.RMBselectlotter = 10
end

--发送抽奖协议
function NewLotteryMainView:sendserverdata()
   
end


function NewLotteryMainView:press_btn_close()
    -- self.Countdownsch
    if self.Countdownsch ~= nil then
        scheduler.unscheduleGlobal(self.Countdownsch)
        self.Countdownsch = nil
    end
    if audio.isMusicPlaying() then
        -- echo("11111111111111111111111111111")
        AudioModel:stopMusic()
    end
    self:startHide()
end
return NewLotteryMainView
