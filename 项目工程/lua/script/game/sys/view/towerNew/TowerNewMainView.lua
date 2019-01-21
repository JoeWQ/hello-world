-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
  


local TowerNewMainView = class("TowerNewMainView", UIBase)

function TowerNewMainView:ctor(winName, conl)
    TowerNewMainView.super.ctor(self, winName)
end
 
function TowerNewMainView:loadUIComplete()
    self.mc_mainbtn:showFrame(2)
--    self.mc_mainbtn.currentView.txt_1:setString("可扫荡到"..TowerNewModel:maxFloor() .. "层")
    self.mc_mainbtn.currentView.txt_1:setVisible(false)
    self:registerEvent() 
    self:setViewAlign()
    self:initData()
	self:initTowerScrollContent()
    self:updataCurrentProgress()
    self:setPlayerIcon()
    self:updateResetBtn()
    self:btnRedPoint()

end

function TowerNewMainView:updateResetBtn()
	local btnReset = self.btn_reset
    local redReset = btnReset:getUpPanel().panel_red
    local redSaodang = self.mc_mainbtn.currentView.panel_hongdian
    redSaodang:setVisible(false)
    redReset:setVisible(false)
    

    local alreadyResetCount = CountModel:getTowerResetCount()
    local resetMaxCount = TowerNewModel:getTowerResetMaxCount()
    if alreadyResetCount > 0 then
        if resetMaxCount <= alreadyResetCount then
            -- 全部用完
            btnReset:getUpPanel().mc_1:setVisible(false)
        else
            -- 可以花费仙玉重置
            btnReset:getUpPanel().mc_1:setVisible(true)
            btnReset:getUpPanel().mc_1:showFrame(2)
            btnReset:getUpPanel().mc_1.currentView.txt_2:setString("需要"..TowerNewModel:getTowerResetCost())
        end
    end
    local leftResetCount = TowerNewModel:getTowerResetLeftCount()
	btnReset:getUpPanel().txt_1:setString("次数".. leftResetCount .. "/" .. resetMaxCount)
	local sweepStatus = TowerNewModel:resetStatus() 
	if sweepStatus == 1 or sweepStatus == 0 then -- 未重置
        -- 未重置状态下 扫荡永远是置灰状态
        FilterTools.setGrayFilter(self.mc_mainbtn) 
        if leftResetCount > 0 and TowerNewModel:currentFloor() > 1 then  -- 剩余次数 > 0 
            if TowerNewModel:isFirstDayPlay() and sweepStatus == 1 then -- 第一天 
                FilterTools.clearFilter(btnReset) 
            elseif TowerNewModel:isFirstDayPlay() and sweepStatus == 0 then
                FilterTools.setGrayFilter(btnReset)
            else
                FilterTools.clearFilter(btnReset) 
            end
            
        else -- 剩余次数为 0 
            FilterTools.setGrayFilter(btnReset)
        end
          
	elseif sweepStatus == 2 then --已重置
        local leftResetCount = TowerNewModel:getTowerResetLeftCount()
        -- 无重置次数置灰
        if leftResetCount <= 0 then
            FilterTools.setGrayFilter(self.btn_reset)
            FilterTools.setGrayFilter(redReset)
        end
         
        FilterTools.clearFilter(self.mc_mainbtn)
	end

end
function TowerNewMainView:initData()
    self.allFloorData = FuncTower.getTowerAllFloorData()
    self.npcEffct = nil
end 

function TowerNewMainView:initTowerScrollContent()
        self.itemDatas = { }
    
        for k, v in pairs(self.allFloorData) do
            table.insert(self.itemDatas, v)
        end
        table.insert(self.itemDatas,{id = "0"})
        table.insert(self.itemDatas,{id = "10000"})
        function sortFunc(a, b)
		    return tonumber(a.id) > tonumber(b.id);
	    end
	    table.sort(self.itemDatas, sortFunc);
        local createFunc = function(_itemdata)
            local _itemView = UIBaseDef:cloneOneView(self.panel_2.mc_1) 
            self:updataFloor(_itemdata,_itemView)
            return _itemView
        end

        local reuseUpdateCellFunc = function(_itemdata, _itemView)
            self:updataFloor(_itemdata,_itemView)
            return _itemView
        end

        local createFuncTop = function(_itemdata)
            local _itemView = UIBaseDef:cloneOneView(self.panel_2.mc_2) 
            _itemView:showFrame(4)
            return _itemView
        end
        local createFuncBottom = function(_itemdata)
            local _itemView = UIBaseDef:cloneOneView(self.panel_2.mc_mc_3) 
            _itemView:showFrame(1)
            return _itemView
        end

        self.scroll_1:setCanScroll(false);
        local params = {
            {
                data = self.itemDatas,
                createFunc = createFunc,
                offsetX = -1,
                offsetY = 70,
                widthGap = 0,
                heightGap = 0,
                itemRect = { x = 0, y = - 260, width = 514, height = 260 },
                perFrame = 1,
                updateCellFunc = reuseUpdateCellFunc,
            },
        }
        self.scroll_1:styleFill(params)
        self.scroll_1:hideDragBar()
        self:initFloor()
        self.panel_2:setVisible(false)

end
--
function TowerNewMainView:initFloor()
    local tzjg = Cache:get("PaTaTiaozhanjieguo",0) -- 挑战结果 0 失败或初始化 1 胜利 
    echo("挑战结果 = " .. tzjg)
    local currentFloor = tonumber(TowerNewModel:currentFloor())  -- 当前所在层数 
    echo("当前所在层数 = " .. currentFloor)
    local maxFloor = FuncTower.getMaxTowerFloor()
    if tzjg == 1 then 
        
        local lastFloor = currentFloor - 1
        local floorIdex = maxFloor - lastFloor + 2 
        self.scroll_1:gotoTargetPos(floorIdex ,1,1)
        self:delayCall(function()
            -- 关门
            local view, data = self:getDataAndView(currentFloor - 1)
            self:updataFloor(data,view,1)
            self:delayCall(function()
                local floorIdex = maxFloor - currentFloor + 2
                self.scroll_1:gotoTargetPos(floorIdex ,1,1,0.5)
                self:delayCall(function()
                    -- 解锁
                    local view, data = self:getDataAndView(currentFloor)
                    if view and data then
                        self:updataFloor(data,view,2)
                    end
                    Cache:set("PaTaTiaozhanjieguo",0)
                end,0.5)
            end,0.5)
        end,1.3) 
    else
        
        local floorIdex = maxFloor - currentFloor + 2
        self.scroll_1:gotoTargetPos(floorIdex ,1,1)
    end
end
function TowerNewMainView:getDataAndView(floorNum)
    local data
    for i,v in pairs(self.itemDatas) do
        if tonumber(v.id)  ==  floorNum then
           data = v
           break
        end
    end
    local view = self.scroll_1:getViewByData(data)
    return view , data
end
-- 更新每个楼层的信息
function TowerNewMainView:updataFloor(_itemdata,_itemView,finish) -- 1 关门 2 解锁
    local _type = finish or 0
    local tzjg = Cache:get("PaTaTiaozhanjieguo",0)
    if tonumber(_itemdata.id) == 0  then --bottom
        _itemView:showFrame(5)
        return
    elseif tonumber(_itemdata.id) == 10000  then --top 
        _itemView:showFrame(4)
        return  
    end
	local floorNum = tonumber(_itemdata.id) 
    local currentMaxFloor = tonumber(TowerNewModel:currentFloor()) -- 挑战到的最高层
    local lastFloor = TowerNewModel:getLastFloor()
    if floorNum == 1 and self.floorOne == nil and self.floorOneView == nil then
        self.floorOne = _itemdata
        self.floorOneView = _itemView
    end
    if floorNum == currentMaxFloor or _type > 0 then --  本层是准备要挑战的
        if finish == 1 then -- 关门
            echo("播放  效果 ============关门")
            self:kaimenZhuangTai(_itemView,_itemdata,false)
            -- 关门 特效
            local itemInfo = _itemView.currentView.panel_2
            local aniCtn = itemInfo.ctn_npc
            itemInfo.panel_men:setVisible(false)
            self:closeMenAni(aniCtn)
        elseif finish == 2 then -- 解锁 
            echo("播放  效果 ============解锁")
            self:kaimenZhuangTai(_itemView,_itemdata,true)
            local itemInfo = _itemView.currentView.panel_2
            local aniCtn = itemInfo.ctn_npc
            -- 解锁特效、
            itemInfo.panel_men:setVisible(false)
            self:unLockAni(aniCtn,itemInfo.panel_men)
        elseif  floorNum == currentMaxFloor and tzjg > 0 then
            -- 未解锁状态
             _itemView:showFrame(1)
            local itemInfo = _itemView.currentView
            itemInfo.txt_1:setString("第".._itemdata.id.."层")

            -- 添加锁的特效
            local aniCtn = itemInfo.ctn_suo
            self:lockingAni(aniCtn)
        else
            echo("播放  效果 ============正常")
            self:kaimenZhuangTai(_itemView,_itemdata,true)
        end
        
    elseif floorNum > currentMaxFloor then -- 本层是不可挑战的
        _itemView:showFrame(1)
        local itemInfo = _itemView.currentView
        itemInfo.txt_1:setString("第".._itemdata.id.."层")

--        -- 添加锁的特效
        local aniCtn = itemInfo.ctn_suo
        self:lockingAni(aniCtn)
        
    else    
        -- 本层是已挑战的 
        if tzjg and tzjg == 1 and floorNum == (currentMaxFloor-1) then
            echo("本层是已挑战的 门是开着的")
            self:kaimenZhuangTai(_itemView,_itemdata,true)
        else
            _itemView:showFrame(3)
            local itemInfo = _itemView.currentView.panel_1
            itemInfo.txt_1:setString("第".._itemdata.id.."层")
        end
        
    end

end
-- 开门状态
function TowerNewMainView:kaimenZhuangTai(_itemView,_itemdata,isShow)
    _itemView:showFrame(2)
    local itemInfo = _itemView.currentView.panel_2
    itemInfo.txt_1:setString("第".._itemdata.id.."层")
    self:addNpc(itemInfo.ctn_1,_itemdata.id)
    local currentFloor = tonumber(TowerNewModel:currentFloor()) -- 挑战到的最高层
    if currentFloor == tonumber(_itemdata.id) then
        itemInfo:setTouchedFunc(c_func(self.npcTap, self,_itemdata))
    end
    

    -- npc 特效
    if isShow == true then
        local aniCtn = itemInfo.ctn_npc
        self:npcAni(aniCtn,itemInfo.ctn_1) 
    end
    
end
-- 关门特效
function TowerNewMainView:closeMenAni(ctn)
    echo("关门特效")
    if ctn:getChildByTag(10003) then
        return
    end
    local lockAni = self:createUIArmature("UI_suoyaota","UI_suoyaota_guanmen", nil, false, GameVars.emptyFunc)
--            unlockAni:doByLastFrame(true,true,GameVars.emptyFunc)
    lockAni:setPositionY(lockAni:getPositionY() + 53)
    lockAni:setPositionX(lockAni:getPositionX() - 6.5)
    ctn:addChild(lockAni)
    lockAni:setTag(10003)
end
-- 锁 特效
function TowerNewMainView:lockingAni(aniCtn)
    echo("锁 特效")
    if aniCtn:getChildByTag(10002) then
        return
    end
    local lockAni = self:createUIArmature("UI_suoyaota","UI_suoyaota_chixu", nil, true, GameVars.emptyFunc)
    lockAni:setPositionX(lockAni:getPositionX() - 3)
    lockAni:setPositionY(lockAni:getPositionY() + 8)
    aniCtn:addChild(lockAni)
    lockAni:setTag(10002)
end
-- 解锁特效
function TowerNewMainView:unLockAni(ctn,men)
    echo("解锁特效")
    if ctn:getChildByTag(10001) then
        return
    end
    local unlockAni = self:createUIArmature("UI_suoyaota","UI_suoyaota_kaiqi", nil, false, GameVars.emptyFunc)
    local tempFunc = function ()
        men:setVisible(true)
    end
    unlockAni:doByLastFrame(true,true,tempFunc)
    unlockAni:setPositionX(unlockAni:getPositionX() - 8)
    unlockAni:setPositionY(unlockAni:getPositionY() + 50.5)
    ctn:addChild(unlockAni)
    unlockAni:setTag(10001)
end

-- npc 特效
function TowerNewMainView:npcAni(npcCtn,node)

    local npcAni = self:createUIArmature("UI_suoyaota","UI_suoyaota_npc", nil, true, GameVars.emptyFunc)
    node:setPositionX(13)
    node:setPositionY(-37)
   
    FuncArmature.changeBoneDisplay(npcAni, "node1", node );
    
    npcCtn:addChild(npcAni)
end
-- addNpc 
function TowerNewMainView:addNpc(npcCtn,id)
      local npcId = FuncTower.getTowerDataByKey(id ,"towerNpcResId")
--      npcId = "30001_wuhoubianshen"

      local npcSpine = FuncRes.getArtSpineAni(npcId)
	  npcSpine:gotoAndStop(1)
	  npcCtn:removeAllChildren()
--      npcSpine:setScale(0.6)
      npcSpine:setPositionY(npcSpine:getPositionY() - 55)
      npcCtn:addChild(npcSpine)
--    ctnPeople:removeAllChildren()
--	local rName = FuncTower.getTowerDataByKey(id, "towerNpcResId")
--	local tNpc = ViewSpine.new(rName, nil, "skin1")
--	tNpc:setScale(0.4)
--	tNpc:addto(ctnPeople)
--    tNpc:setPositionY(tNpc:getPositionY() - 20)
--	tNpc:playLabel("1_stand")
end
-- 进度条
function TowerNewMainView:updataCurrentProgress(event)
    local progressBar = self.panel_1.panel_1.progress_1
    progressBar:setDirection(2)
    local maxFloor = FuncTower.getMaxTowerFloor()
    local currentFloor = tonumber(TowerNewModel:currentFloor())  -- 挑战到的最高层
    
    if event then
       local _floor = event.params.floor
       currentFloor = _floor
    end
    if currentFloor > maxFloor  then
       currentFloor = maxFloor
    end
    
    progressBar:setPercent(currentFloor/maxFloor*100)
    local progressLable = self.panel_1.panel_2
    local progressPosY = self.panel_1.panel_1:getPositionY()
    local progressHeight = 433
    local posY = math.ceil(progressPosY - progressHeight + progressHeight * (currentFloor/maxFloor) + 27.5);
    progressLable:setPositionY(posY)
    self.panel_1.panel_2.txt_1:setString(currentFloor.."层")

    if currentFloor <= 3 then
        self.scroll_1:refreshCellView( 1 )
        self.scroll_1:refreshCellView( 2 )
        self.scroll_1:refreshCellView( 3 )
    end
end
function TowerNewMainView:setPlayerIcon()
	local avatarId = UserModel:avatar()..''
	local icon = FuncRes.iconAvatarHead(avatarId)
	local iconSprite = display.newSprite(icon)
	local avatarCtn = self.panel_1.panel_2.panel_2.ctn_1
	local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", avatarCtn, false, GameVars.emptyFunc)
	iconAnim:setScale(0.45)
	FuncArmature.changeBoneDisplay(iconAnim, "node", iconSprite)
end

-- 宝箱红点
function TowerNewMainView:baoxiangRedPoint()
    local  state_box = TowerNewModel:_checkCanOpenBox();
    self.btn_box:getUpPanel().panel_red:setVisible(state_box)
end

-- 成就 宝箱 红点提示
function TowerNewMainView:btnRedPoint()
    -- 成就
    local state_3 = TowerNewModel:getAchievementState()
    self.btn_3:getUpPanel().panel_red:setVisible(state_3)    
    -- 宝箱
    local  state_box = TowerNewModel:_checkCanOpenBox();
    self.btn_box:getUpPanel().panel_red:setVisible(state_box)
    -- 重置
    -- 扫荡
end

function TowerNewMainView:npcTap(data)
    if self.scroll_1:isMoving() then
        return
    end
    if data.attriRandom then
        WindowControler:showWindow("TowerNewXuanZeBangShouView", table.deepCopy(data))
    else
        WindowControler:showWindow("TowerNewBenCengJiangLiView",data)
    end
	
end

-- 适配 
function TowerNewMainView:setViewAlign()
    FuncCommUI.setViewAlign(self.panel_icon, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.UI_tower_box_key, UIAlignTypes.RightTop)
    
    FuncCommUI.setScrollAlign(self.scroll_1, UIAlignTypes.Middle, 0,1)

    self.btn_1:getUpPanel().panel_red:setVisible(false)
    self.btn_2:getUpPanel().panel_red:setVisible(false)
    self.btn_3:getUpPanel().panel_red:setVisible(false)
end 

function TowerNewMainView:registerEvent()
	--返回按钮
	self.btn_back:setTap(c_func(self.onBackBtnTap, self))
	-- 镇妖宝箱
    self.btn_box:setTap(c_func(self.onTreasuresBtnTap, self))
	-- 成就
	self.btn_3:setTap(c_func(self.onAchievementBtnTap, self))
    -- 重置
	self.btn_reset:setTap(c_func(self.onResetBtnTap, self))
    -- 奖励预览
    self.btn_2:setTap(c_func(function ()
         WindowControler:showWindow("TowerNewSaoDangHeJLYLView",1)
    end, self))
    -- 排行榜
    self.btn_1:setTap(c_func(self.onPaihangbangBtnTap, self))
    -- 扫荡
    self.mc_mainbtn.currentView.btn_2:setTap(c_func(self.onSaoDangBtnTap, self))

    EventControler:addEventListener(TowerEvent.TOWERR_FLOOR_UPDATE, self.updataCurrentProgress, self);
    EventControler:addEventListener(TowerEvent.TOWERR_RED_POINT_UPDATA, self.btnRedPoint, self);
    EventControler:addEventListener("CHONGZHITISHI", self.onResetBtnTapTip, self);
end 

-- 镇妖宝箱
function TowerNewMainView:onTreasuresBtnTap()
	WindowControler:showWindow("TowerNewMainTreasureView", self)
--        local itemDatas = { }

--        for k, v in pairs(self.allFloorData) do
--            table.insert(itemDatas, v)
--        end

--        function sortFunc(a, b)
--		    return tonumber(a.id) < tonumber(b.id);
--	    end
--	    table.sort(itemDatas, sortFunc);
--        local view = WindowControler:showWindow("TowerNewXuanZeBangShouView", table.deepCopy(itemDatas[5]))
end

--重置
function TowerNewMainView:onResetBtnTapCallback(event)
    dump(event,"重置回调")
    self:updateResetBtn()
    self:updataCurrentProgress()
    local maxFloor = FuncTower.getMaxTowerFloor()
    local currentFloor = tonumber(TowerNewModel:currentFloor())
    if currentFloor <= 3 then
        if self.floorOne ~= nil and self.floorOneView ~= nil then
            self:updataFloor(self.floorOne,self.floorOneView)
        end
    end
    self.scroll_1:gotoTargetPos(maxFloor - currentFloor + 2 ,1,1,self.timeFloor)
    EventControler:dispatchEvent("CHALLENGE_TOWER_CAN_RESET_RED_POINT")
end
-- 重置
function TowerNewMainView:onResetBtnTap()
    if TowerNewModel:isFirstDayPlay() then
        --第一天玩，resetState nil 不可重置 1 可重置
        if TowerNewModel:resetStatus() == 0 then
            return
        end
    end
    if TowerNewModel:currentFloor() < 1 then
        WindowControler:showTips("大于第一层才可重置") 
        return
    end
    local sweepStatus = TowerNewModel:resetStatus() or 1
    if sweepStatus == 1 or sweepStatus == 0 then
        local leftCount = TowerNewModel:getTowerResetLeftCount()
	    if leftCount <= 0 then 
		    WindowControler:showTips(GameConfig.getLanguage("tid_tower_1006"))
		    return
	    end
        -- 可以重置
        local oneFloorMoveTime = 0.5
        if TowerNewModel:currentFloor() > 50 then
            oneFloorMoveTime = 0.015
        elseif TowerNewModel:currentFloor() > 20 then
            oneFloorMoveTime = 0.07
        elseif TowerNewModel:currentFloor() > 10 then
            oneFloorMoveTime = 0.25
        end
        self.timeFloor = oneFloorMoveTime * tonumber(TowerNewModel:currentFloor())
        echo("每层时间 == " ..oneFloorMoveTime .. " 总时间 == " .. self.timeFloor .. " 层数 == " ..TowerNewModel:currentFloor())

        WindowControler:showWindow("TowerNewBuyTip", self)

--        TowerServer:requestResetFightCount({} , c_func(self.onResetBtnTapCallback, self))
    else
        WindowControler:showTips( { text = "已经重置，请扫荡" })
        return 
    end
--	WindowControler:showWindow("TowerTreasureReset", self)
end

function TowerNewMainView:onResetBtnTapTip()
     TowerServer:requestResetFightCount({} , c_func(self.onResetBtnTapCallback, self))
end
-- 成就
function TowerNewMainView:onAchievementBtnTap()
--    local data = EnemyInfo.new("101021")
--    local a = data.attr.armature
--    local b = data.attr.name
--    dump(data,"調試看")
--    echo("+++++"..b .. "------------".. a)
	WindowControler:showWindow("TowerNewAchievementView", self)
end
-- 排行榜
function TowerNewMainView:onPaihangbangBtnTapCallback(event)
    local data = event.result.data.towerRank.rank
    WindowControler:showWindow("TowerNewPaihangbangView", data)
end
function TowerNewMainView:onPaihangbangBtnTap()
    TowerServer:requestPaihangbang({} , c_func(self.onPaihangbangBtnTapCallback, self))
end
-- 扫荡
function TowerNewMainView:onSaoDangBtnTapCallback(event)
    local reward = event.result.data.reward
    dump(reward,"扫荡奖励")
    EventControler:dispatchEvent(TowerEvent.TOWER_RECEIVE_SWEEP_REWARD_OK)
    WindowControler:showWindow("TowerNewSaoDangHeJLYLView",0,reward,self.lastCurrentFloor)
        
    self:updateResetBtn()
    self:updataCurrentProgress()
    local maxFloor = FuncTower.getMaxTowerFloor()
    local currentFloor = tonumber(TowerNewModel:currentFloor())
    self.scroll_1:gotoTargetPos(maxFloor - currentFloor + 2 ,1,1)
end
function TowerNewMainView:onSaoDangBtnTap()
--    local a = {}
--    for i = 1, 20 do
--        table.insert(a,{"1,4046,1"})   
--    end
--    WindowControler:showWindow("TowerNewSaoDangHeJLYLView",0,a)
    
    -- 判断是否可扫荡
    if TowerNewModel:resetStatus() == 2 then
        self.lastCurrentFloor = TowerNewModel:currentFloor()
        TowerServer:requestAutoFight({} , c_func(self.onSaoDangBtnTapCallback, self))
    else
        WindowControler:showTips( { text = "扫荡条件不足" })
    end
end
function TowerNewMainView:onBackBtnTap()
	self:close()
end

function TowerNewMainView:close()
	self:startHide()
end

return TowerNewMainView  
