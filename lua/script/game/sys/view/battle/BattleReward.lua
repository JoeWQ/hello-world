



--[[
战斗奖励
]]
local BattleReward = class("BattleReward", UIBase);




BattleReward.winRwd= 
{
    [1]="10,101,100" ,
    [2]="10,101,101", 
    [3]="10,102,300", 
    [4]="10,104,100" ,
    [5]="10,105,100", 
    [6]="10,105,100",
    [7]="10,105,100",
    [8]="10,105,100",
    [9]="10,105,100",
    [10]="10,105,100",
}




--[[
@params params 表示的是奖励宝箱
]]
function BattleReward:ctor(winName,params)
    BattleReward.super.ctor(self, winName);
    echo("战斗结算的  数据")
    dump(params)
    echo("战斗结算的  数据")
    self.params = params

    --self.isLvUp = params.preLv < UserModel:level()

    echo("是否升级--------",isLvlUp,"============")
    if not LoginControler:isLogin() then
        self.isLvUp = false
    else
        self.isLvUp = params.preLv < UserModel:level()
    end
    
    if not LoginControler:isLogin() then
        self.rwd = self.winRwd
    else
        self.rwd = self.params.reward
    end
    


end

function BattleReward:loadUIComplete()
    self:registerEvent();

    --
    AudioModel:playMusic(MusicConfig.s_com_reward, false)

    WindowControler:createCoverLayer(nil, nil, GameVars.bgAlphaColor):addto(self, -2)
    -- 注册点击任意地方事件

    --3秒后才可以点击胜利界面关闭
    local tempFunc = function (  )
        self:registClickClose(nil, c_func(self.pressClose, self))
    end


    self.txt_2:visible(false)

    self:delayCall(tempFunc, 0.5)

    --FuncArmature.loadOneArmatureTexture("UI_tongyonghuode",nil,true)
    -- 使用 UI_zhandoujiesuan_chutubiao
    --FuncArmature.loadOneArmatureTexture("UI_zhandoujiesuan",nil,true)
    

    self:loadAni()


    self:loadItems()

end 





--[[
加载动画
]]
function BattleReward:loadAni(  )
    local callBack
    callBack = function()
        self.boxAni:pause(false) 
        self.boxAni:getBoneDisplay("xuhuan"):playWithIndex(0, true)   
    end
    

    --self.boxAni = FuncArmature.createArmature("UI_zhandoujiesuan_baoxiang",self.ctn_1,false,GameVars.emptyFunc)
    self.boxAni = self:createUIArmature("UI_zhandoujiesuan","UI_zhandoujiesuan_baoxiang",self.ctn_1,false,GameVars.emptyFunc)
    self.boxAni:removeFrameCallFunc()
    self.boxAni:registerFrameEventCallFunc(nil, false, callBack)

    self.bgAni = FuncCommUI.createSuccessArmature(10):addto(self.ctn_2):pos(480,-160)
    self.bgAni:getBone("di2"):visible(false)

    --
    -- self.txt_2:visible(true)
    -- self.txt_2:pos(-310,16)
    -- FuncArmature.changeBoneDisplay(self.bgAni:getBoneDisplay("di1"),"renyi",self.txt_2)
    
end



--[[
加载 奖励
]]
function BattleReward:loadItems(  )
    self.mc_1:showFrame(#self.rwd)
    -- echo("当前的奖励--------------------")
    -- dump(self.rwd)
    -- echo("当前的奖励--------------------")

    for k = 1, #self.rwd,1 do
        local itemStr = self.rwd[k]
        self.mc_1.currentView["panel_"..k].UI_1:visible(false)

        local createAniFunc = function(index,data)
            self.mc_1.currentView["panel_"..index].showAni = self:createUIArmature("UI_zhandoujiesuan","UI_zhandoujiesuan_chutubiao",self.mc_1.currentView["panel_"..index].ctn_1, false, GameVars.emptyFunc)    
            local itemNode = self.mc_1.currentView["panel_"..index].UI_1
            itemNode:visible(true):pos(0,0)
            -- echo("data--------------")
            -- dump(data)
            -- echo("data--------------")
            -- local dataArr = string.split(data, ",")
            -- dump(dataArr)
            -- local itemData = {}
            -- itemData.type = dataArr[1]
            -- itemData.itemId = dataArr[2]
            -- itemData.itemNum = dataArr[3]
            
            -- dump(itemData)
            local rwd = {}
            rwd.reward = data
            itemNode:setRewardItemData(rwd)

            FuncArmature.changeBoneDisplay(self.mc_1.currentView["panel_"..index].showAni,"node1",itemNode)
        end
        self.mc_1.currentView["panel_"..k]:delayCall(c_func(createAniFunc,k,itemStr),(20+(k-1)*3)/GAMEFRAMERATE)

    end
end




function BattleReward:setViewStyle()


end 
-- 退出战斗
function BattleReward:pressClose()
    if self.isUpgrade then
        
    end
    self:startHide()
end


function BattleReward:registerEvent()

end

function BattleReward:playWinEff()
    
end 
 
 

function BattleReward:updateUI()

end

function BattleReward:hideComplete()
    
    --echo("调用到了这里-=--------------------------------")
    if  self.isLvUp then
        --echo("展示升级界面--------------------")
        WindowControler:showBattleWindow("CharLevelUpView", UserModel:level(),true);
    else
        --echo("不升级------------")
        FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
    end
    BattleReward.super.hideComplete(self)
end


function BattleReward:deleteMe()
    BattleReward.super.deleteMe(self)
    self.controler = nil
end 

return BattleReward;
