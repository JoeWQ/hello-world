local BattleWin = class("BattleWin", UIBase);
local uiUrl = "uipng/"
BattleWin.tempResult = 
{
    result=1, 
    addExp = 10, 
    preExp = 30, 
    preLv = 35, 
    lv = 36,
    star =1, 
    reward = {
        [1]="1,4011,301" ,
        [2]="1,4012,300", 
        [3]="1,4013,300", 
        [4]="2,300,301" ,
        [5]="3,4201,301", 
    },
    heros = {
            [5001]  = {
                hid = 5001,
                addExp = 200,
                preExp = 30,
                preLv = 3,
                lv = 4,
            },
            [5002]  = {
                hid = "5002",
                addExp = 200,
                preExp = 30,
                preLv = 3,
                lv = 4
            },
            [5003]  = {
                hid = "5003",
                addExp = 200,
                preExp = 30,
                preLv = 3,
                lv = 4
            },
            [5004]  = {
                hid = "5004",
                addExp = 200,
                preExp = 30,
                preLv = 3,
                lv = 4
            },
            [5005]  = {
                hid = "5005",
                addExp = 200,
                preExp = 30,
                preLv = 3,
                lv = 4
            }
        }, 
}

function BattleWin:ctor(winName,params)
    BattleWin.super.ctor(self, winName);

    -- echo("胜利界面-------------------")
    -- dump(params)
    -- echo("胜利界面-------------------")

    self.isUpgrade = false
    --战斗结果的数据
    self.battleDatas = params
    
    self.result = self.battleDatas


    -- echo("结算的战斗数据")
    -- dump(self.result)
    -- echo("结算的战斗数据")

    if self.result.battleLabels == GameVars.battleLabels.pvp then
        self.isPVP = true
    else
        self.isWin = self.result.result == 1
 
        if not LoginControler:isLogin() then
            self.isLvUp = false
        else
            self.isLvUp = params.preLv < UserModel:level()
        end
    end
    

end

function BattleWin:loadUIComplete()
    self:registerEvent()
    if not self.isPVP then
        AudioModel:playMusic(MusicConfig.s_battle_win, false)
    else
        AudioModel:playMusic(MusicConfig.s_battle_pvp_win, false)    
    end

    WindowControler:createCoverLayer(nil, nil, GameVars.bgAlphaColor):addto(self, -2)
    -- 注册点击任意地方事件
    --0.5秒后才可以点击胜利界面关闭
    local tempFunc = function (  )
        self:registClickClose(nil, c_func(self.pressClose, self))
    end
    self:delayCall(tempFunc, 0.5)

    self.txt_1:visible(false)

    self.isUpgrade = false


    --self.txt_2:setString("点击任意处继续...")

    --FuncArmature.loadOneArmatureTexture("UI_zhandoujiesuan",nil,true)

    self:uiAdjust()
    self.mc_huobannum:visible(false)
    if not self.isPVP then
        self:loadAni()
        if LoginControler:isLogin() then
            self:updateHeros()
        end
    else
        self:loadPVP()
    end

end 


-- 退出战斗
function BattleWin:pressClose()
    if self.isUpgrade then
        
    end
    self:startHide()

    if LoginControler:isLogin() and (not self.isPVP) then
        WindowControler:showBattleWindow("BattleReward",self.battleDatas)
    end

     if self.isPVP then
        FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
    end
end


function BattleWin:registerEvent()

end

--[[
界面适配
]]
function BattleWin:uiAdjust()
    if not self.isPVP then
        self.mc_zhuangtai:showFrame(1)
        self.bg = self.mc_zhuangtai.currentView
        self.txt_2:visible(true)
        self.txt_1:visible(false)
        self.bg:visible(false)
        FuncCommUI.setScale9Align( self.bg,UIAlignTypes.MiddleTop )

        --FuncCommUI.setViewAlignByCenter(self.mc_zhuangtai.currentView,GameVars.width/GAMEWIDTH ,1.0);

        self.mc_zhuangtai.currentView.panel_1:setScaleX(GameVars.width/GAMEWIDTH)
        FuncCommUI.setViewAlign( self.mc_zhuangtai.currentView.panel_1,UIAlignTypes.LeftTop )
        self.mc_zhuangtai.currentView.panel_1:setAnchorPoint(cc.p(0,1))
        self.mc_zhuangtai.currentView.panel_1:pos(-GameVars.width/2,100)
    else
        self.mc_zhuangtai:showFrame(2)

        self.bg = self.mc_zhuangtai.currentView
        self.txt_2:visible(true)
        self.txt_2:setString("点击任意处关闭...")
        FuncCommUI.setScale9Align( self.bg,UIAlignTypes.MiddleTop )


        self.mc_zhuangtai.currentView.panel_2222:setScaleX(GameVars.width/GAMEWIDTH)
        FuncCommUI.setViewAlign( self.mc_zhuangtai.currentView.panel_2222,UIAlignTypes.LeftTop )
        -- self.mc_zhuangtai.currentView.panel_2222:setAnchorPoint(cc.p(0,1))
        -- self.mc_zhuangtai.currentView.panel_2222:pos(-GameVars.width/2,100)
    end
end
--[[
竞技场界面的加载
]]
function BattleWin:loadPVP()
    if self.result.historyRank< self.result.userRank then
        self.mc_zhuangtai.currentView.mc_zhuangtai:showFrame(2)
        self.mc_zhuangtai.currentView.mc_zhuangtai.currentView.txt_1:setString(self.result.userRank)
        self.mc_zhuangtai.currentView.mc_zhuangtai.currentView.txt_3:setString(self.result.userRank-self.result.historyRank)
    else
        self.mc_zhuangtai.currentView.mc_zhuangtai:showFrame(1)
        self.mc_zhuangtai.currentView.mc_zhuangtai.currentView.txt_1:setString(self.result.userRank)
    end 

    FuncCommUI.setViewAlign( self.mc_zhuangtai.currentView.btn_1,UIAlignTypes.RightTop )
    FuncCommUI.setViewAlign( self.mc_zhuangtai.currentView.btn_2,UIAlignTypes.RightTop )

    self.mc_zhuangtai.currentView.btn_1:setTap(c_func(self.doRankClick,self))
    self.mc_zhuangtai.currentView.btn_2:setTap(c_func(self.doReplayClick,self))
end


--[[
打开排名列表
]]
function BattleWin:doRankClick(  )
    echo("打开排名列表")
end

--[[
重新播放
]]
function BattleWin:doReplayClick()
    echo("执行重新播放")
end



--[[
加载界面动画
]]
function BattleWin:loadAni(  )
    local callBack
    callBack = function (  )
        if self.winAni then
            self.winAni:pause(false)
            self.winAni:getBoneDisplay("zhuanguang"):getBoneDisplay("layer18"):playWithIndex(0, true)
            self.winAni:getBoneDisplay("fazhen"):getBoneDisplay("layer6"):playWithIndex(0, true)
            --self.winAni:getBoneDisplay("fazhen"):getBoneDisplay("fazhen"):playWithIndex(0, true)
        end
    end
    --UI_zhandoujiesuan
    self.winAni = self:createUIArmature("UI_zhandoujiesuan","UI_zhandoujiesuan_zhandoushengli",self.ctn_big,false,GameVars.emptyFunc):pos(0,0)
    FuncArmature.changeBoneDisplay(self.winAni:getBoneDisplay("beijing"),"layer12",self.mc_zhuangtai.currentView.panel_1)
    --self.winAni = FuncArmature.createArmature("UI_zhandoujiesuan_zhandoushengli",self.ctn_big,false,GameVars.emptyFunc):pos(0,0)
    self.winAni:registerFrameEventCallFunc(nil, false, callBack)
    self.winAni:playWithIndex(0, false)

    --获得的星星数
    local star = self.result.star
    star = FuncCommon:getBattleStar(star)
    for k = 1,3,1 do
        self.winAni:getBone("xingxing"..k):visible(k<=star)
    end

    -- local indexLbl
    -- if star == 1 then
    --     indexLbl = 
    -- elseif star == 2 then
    -- elseif star== 3 then
    -- end
        --todo
        --todo
    --过关条件
    self.winAni:getBoneDisplay("chuzi"):playWithIndex(star-1,true)

    --立绘
    local avator = 101    --UserModel:avatar()
    local level = 1     --UserModel:level()
    local tHid = 1
    --battle_img_win 这个不用立绘了  使用  battle_img_win  替换
    --local charView =  FuncRes.getArtSpineAni("art_LiXiaoYaoLiHui")
    --charView:gotoAndStop(1)
    local charView
    local imgName = "battle_img_win.png"
    -- if CONFIG_USEDISPERSED  then
    --         charView = display.newSprite()
    --     else
    --         charView = display.newSprite("#" ..imgName)
    -- end
    charView = display.newSprite("icon/char/battle_img_win.png")
    charView:setPosition(cc.p(0,-26))
    local lihuiAni = self.winAni:getBoneDisplay("jueselihui")--:getBoneDisplay("layer8")
    FuncArmature.changeBoneDisplay(lihuiAni,"layer8",charView)

    --等级
    local lvNode = UIBaseDef:cloneOneView(self.txt_1)
    lvNode:visible(true)
    lvNode:pos(0,23)
    lvNode:setString(self.result.lv)
    --echo(self.tempResult.addExp,"===============")
    local lvAni = self.winAni:getBoneDisplay("dengjijingyan"):getBoneDisplay("layer9")
    FuncArmature.changeBoneDisplay(lvAni,"node1",lvNode)  

    --经验
    local expNode = UIBaseDef:cloneOneView(self.txt_1)
    expNode:visible(true)
    expNode:pos(0,23)
    expNode:setString(self.result.addExp)
    -- local expNode = display.newSprite(FuncRes.icon( "buff/battle_img_bianshen.png" ))
    -- echo(self.tempResult.lv,"===============")
    local expAni = self.winAni:getBoneDisplay("dengjijingyan"):getBoneDisplay("jingyan")
    FuncArmature.changeBoneDisplay(expAni,"layer2",expNode)  



end



function BattleWin:updateHeros(  )
    --每个英雄增加了多少经验
    local allHeros = table.values(self.result.damages.camp1)
    local heros = {}
    for k,v in pairs(allHeros) do
        if not v.isMainHero then
            local hid = v.hid
            local index = TeamFormationModel:getPartnerRealPIdx( hid,self.result.battleLabels )
            v.order = index
            table.insert(heros, v)
        end
    end
    if #heros == 0 then
        self.mc_huobannum:visible(false)
        return    
    end
    self.mc_huobannum:visible(true)
    table.sort( heros, function(a,b) return a.order<b.order  end )
    --这里应该对heros进行一次排序
    self.mc_huobannum:showFrame(#heros)

    for k=1,#heros,1 do
        local panel = self.mc_huobannum.currentView["panel_"..k]
        panel.panel_1:visible(false)
    end

    --动画结束
    local callBack2
    callBack2 = function ( panel,data )
        --品质
        panel.panel_1.mc_1:showFrame(data.quality)
        panel.panel_1:visible(true)
        --星级
        panel.panel_1.mc_2:showFrame(data.star)
        --等级
        panel.panel_1.txt_1:setString(data.lv)
        --经验
        panel.panel_1.txt_2:setString("EXP+"..data.addExp)
        --头像
        local icon = data.icon
        panel.ctn_1:addChild(display.newSprite( FuncRes.iconHero(icon ..".png")):size(78,78) )

        local lastExp = math.round((data.exp-data.addExp)/data.maxExp*100)
        if lastExp<=0 then lastExp = 0 end
        
        panel.panel_1.progress_1:setPercent(lastExp)
        panel.panel_1.progress_1:tweenToPercent(math.round(data.exp/data.maxExp*100))

        if data.lv> data.preLv then
            --升级了
           panel.ctn_2.lvUpAni= self:createUIArmature("UI_zhandoujiesuan", "UI_zhandoujiesuan_zhujueshengji", panel.ctn_2, false, nil)
           panel.ctn_2.lvUpAni:playWithIndex(0,false)
        end

    end



    --icon显示
    local callBack
    callBack = function ( panel,data )
        --UI_zhandoujiesuan
        panel.chuxianAni = self:createUIArmature("UI_zhandoujiesuan","UI_zhandoujiesuan_chuxian",panel.ctn_1,false,GameVars.emptyFunc):pos(0,0)
        --panel.chuxianAni = FuncArmature.createArmature("UI_zhandoujiesuan_chuxian",panel.ctn_1,false,GameVars.emptyFunc):pos(0,0)
        panel.chuxianAni:scale(1.2)
        panel.chuxianAni:playWithIndex(0)
    end


    for k = 1,#heros do
        local panel = self.mc_huobannum.currentView["panel_"..k]
        
        panel:delayCall( c_func(callBack,panel,heros[k] ), (45+(k-1)*3)/GAMEFRAMERATE )
        panel:delayCall( c_func(callBack2,panel,heros[k] ), (47+(k-1)*3)/GAMEFRAMERATE )
        
    end
end





function BattleWin:hideComplete()
    BattleWin.super.hideComplete(self)
    if not LoginControler:isLogin() then
        --WindowControler:showBattleWindow("BattleReward",self.battleDatas)
        FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
    end

   
    
end


function BattleWin:deleteMe()
    BattleWin.super.deleteMe(self)
    self.controler = nil
end 

return BattleWin;
