-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
  
local TowerNewBenCengJiangLiView = class("TowerNewBenCengJiangLiView", UIBase)

function TowerNewBenCengJiangLiView:ctor(winName,_data)
    TowerNewBenCengJiangLiView.super.ctor(self, winName)
    self.data = _data
end 
function TowerNewBenCengJiangLiView:loadUIComplete()
    self:registerEvent()
    self:setViewAlign()
    self:updataUI()
end
function TowerNewBenCengJiangLiView:registerEvent()
    TowerNewBenCengJiangLiView.super.registerEvent()
    self.btn_close:setTap(c_func(self.onBtnBackTap, self));
    self.btn_1:setTap(c_func(self.tiaoZhanTap, self));
    self:registClickClose("out");
end
function TowerNewBenCengJiangLiView:setViewAlign()

end
function TowerNewBenCengJiangLiView:updataUI()
    self.txt_1:setString("第"..self.data.id.."层")
    self.txt_2:setString(self.data.recommend)
    local rewardYLArr = self.data.reward
    for i = 1,3 do
        local reward = rewardYLArr[i]
        local itemView = self["UI_"..i];
        if reward then
            local num,hasNum,isEnough,resType,itemId = UserModel:getResInfo(reward)
			itemView:visible(true)
			itemView:setResItemData( {reward = reward})
			itemView:setResItemClickEnable(true)
            --注册点击事件 弹框
            local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(reward)
            FuncCommUI.regesitShowResView(itemView, resType, needNum, resId,reward,true,true)
        else
            itemView:setVisible(false)
        end
    end
end

function TowerNewBenCengJiangLiView:tiaoZhanTap()
    WindowControler:showTips("功能还未开启")
    --TowerServer:exploreWithOption({floor = TowerNewModel:currentFloor()}, c_func(self.enterMainStageCallBack, self))
end



-- 开始PVE战斗
function TowerNewBenCengJiangLiView:enterMainStageCallBack(event)
    echo("PVEChapterView:startBattleCallBack")
    if event.result ~= nil then
        -- dump(event.result.data)
        self.battleId = event.result.data.battleId

        local battleInfo = {}
        battleInfo.battleUsers = event.result.data.battleUsers;
        battleInfo.randomSeed = event.result.data.randomSeed;
        battleInfo.inBattleDrop = nil;
        battleInfo.battleLabel = GameVars.battleLabels.towerPve ;
        -- dump(battleInfo,"爬塔战斗信息")
        local maxFloor = tonumber(FuncTower.getMaxTowerFloor())
        local currentFloor = tonumber(TowerNewModel:currentFloor())
        if currentFloor >  maxFloor then
            currentFloor = maxFloor
        end
        local battleLevelId = FuncTower.getTowerDataByKey(currentFloor,"params1_1")
        -- 设置关卡ID
        TowerServer:setBattleID(self.battleId)
        BattleControler:setLevelId(battleLevelId[1])
        -- 关闭界面
        self:startHide()
        
        -- 开始战斗
        BattleControler:startPVE(battleInfo)
    end
end
function TowerNewBenCengJiangLiView:onBtnBackTap()
    self:startHide()
end
return TowerNewBenCengJiangLiView 
-- endregion 
