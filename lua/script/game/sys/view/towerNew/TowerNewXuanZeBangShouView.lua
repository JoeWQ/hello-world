-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
  
local TowerNewXuanZeBangShouView = class("TowerNewXuanZeBangShouView", UIBase)

function TowerNewXuanZeBangShouView:ctor(winName,_data)
    TowerNewXuanZeBangShouView.super.ctor(self, winName)
    self.data = _data
end 

function TowerNewXuanZeBangShouView:loadUIComplete()
    self:registerEvent()
    self:setViewAlign()
    self:updataUI()
end
function TowerNewXuanZeBangShouView:registerEvent()
    TowerNewXuanZeBangShouView.super.registerEvent()
--    self.btn_close:setTap(c_func(self.onBtnBackTap, self));
    
end
function TowerNewXuanZeBangShouView:setViewAlign()

end
function TowerNewXuanZeBangShouView:updataUI()
    self.txt_1:setString("第"..self.data.id.."层")
    
    local selectedArr = TowerNewModel:randomArr(3,self.data.attriRandom) ;
    for i = 1,3 do
        local info = selectedArr[i]
        dump(info,"已选属性")
        local itemView = self["btn_xz"..i]:getUpPanel().mc_1;
        if tonumber(info["type"]) == 1 then --属性加成
            itemView:showFrame(1)
            FuncChar.getAttrNameByKeyName(info["value1"])
            local index = 1;
            if info["value1"] == "6" then
                index = 1;
            elseif info["value1"] == "4" then
                index = 2;
            else
                index = 3;
            end
            itemView.currentView.mc_1:showFrame(index)
            itemView.currentView.txt_2:setString(info["value2"] .. "%")
        elseif tonumber(info["type"]) == 2 then --添加英雄   
            itemView:showFrame(2)

            local data = EnemyInfo.new(info["value1"])
            local npcId = data.attr.armature
            local name = data.attr.name

            local npcCtn = itemView.currentView.ctn_1
            local npcSpine = FuncRes.getArtSpineAni(npcId)
	        npcSpine:gotoAndStop(1)
	        npcCtn:removeAllChildren()
            npcSpine:setScale(0.3)
--            npcSpine:setPositionY(npcSpine:getPositionY() - 55)
            npcCtn:addChild(npcSpine)

            local txt = itemView.currentView.txt_1
            txt:setString("求助"..name)
        end
        self["btn_xz"..i]:setTap(c_func(self.tiaoZhanTap, self,info))
    end
end

function TowerNewXuanZeBangShouView:tiaoZhanTap(value)
    dump(value,"选中属性")
    self.selectBuff = nil
    if self.selectBuff == 1 then
        self.selectBuff = value
    end
    TowerNewModel:setSelectedShuxing(value)
    TowerServer:exploreWithOption({floor = TowerNewModel:currentFloor()}, c_func(self.enterMainStageCallBack, self))
end



-- 开始PVE战斗
function TowerNewXuanZeBangShouView:enterMainStageCallBack(event)
    echo("PVEChapterView:startBattleCallBack")
    if event.result ~= nil then
        -- dump(event.result.data)
        self.battleId = event.result.data.battleId

        local battleInfo = {}
        battleInfo.battleUsers = event.result.data.battleUsers;
        battleInfo.randomSeed = event.result.data.randomSeed;
        battleInfo.inBattleDrop = nil;
        battleInfo.battleLabel = GameVars.battleLabels.towerPve ;
        battleInfo.buffInfo = self.selectBuff
        -- dump(battleInfo,"爬塔战斗信息")
        
        local battleLevelId = FuncTower.getTowerDataByKey(tostring(TowerNewModel:maxFloor() + 1),"params1_1")
        -- 设置关卡ID
        TowerServer:setBattleID(self.battleId)
        BattleControler:setLevelId(battleLevelId[1])
        -- 关闭界面
        self:startHide()
        
        -- 开始战斗
        BattleControler:startPVE(battleInfo)
    end
end
function TowerNewXuanZeBangShouView:onBtnBackTap()
    self:startHide()
end
return TowerNewXuanZeBangShouView 
-- endregion 
