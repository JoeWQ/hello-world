--
-- Author: ZhangYanguang
-- Date: 2016-06-12
-- 战斗loading控制器


local BattleLoadingControler = BattleLoadingControler or {}

BattleLoadingControler.battleLoadingType = {
	LOADING_TYPE_PVE = 1,
	LOADING_TYPE_GVE = 2,
}

function BattleLoadingControler:init()
	-- loading 全部加载完毕
    EventControler:addEventListener(LoadEvent.LOADEVENT_BATTLELOADCOMP,self.loadAllUsersComplete,self)
end

function BattleLoadingControler:showBattleLoadingView(loadingId,sigleFlag)
	self.loadingId = loadingId
	self.loadingType = self.battleLoadingType.LOADING_TYPE_PVE
    
    echo("loadingId",loadingId,"sigleFlag",sigleFlag,"====加载界面")
    --默认为单人
    if sigleFlag ~=2 then
        sigleFlag =1
    end
    self.sigleFlag= sigleFlag
    if sigleFlag == 1 then
        echo("展示单人战斗loadingView--------------")
        self:showPVEBattleLoadingView()
    else
        echo("展示多人战斗LoadingView--------------")
        self:showGVEBattleLoadingView()
    end

	-- if self.loadingId ~= nil and self.loadingId ~= "" then
 --        -- 初始化loading数据 
 --    	self.loadingData = FuncLoading.getLoadingData(self.loadingId)

 --    	local single = self.loadingData.single
	--     if tonumber(single) == 1 then
	--         self.loadingType = self.battleLoadingType.LOADING_TYPE_PVE
	--     else
	--     	self.loadingType = self.battleLoadingType.LOADING_TYPE_GVE
	--     end
 --    end

    -- if self.loadingType == self.battleLoadingType.LOADING_TYPE_PVE then
    -- 	self:showPVEBattleLoadingView()
    -- elseif self.loadingType == self.battleLoadingType.LOADING_TYPE_GVE then
    -- 	self:showGVEBattleLoadingView()
    -- end
end

-- GVE多人匹配战斗loading
function BattleLoadingControler:showGVEBattleLoadingView()
	local scene = WindowControler:getCurrScene()
    scene:showBattleRoot()
    self.loadingView = WindowControler:showBattleWindow("BattleLoadingView",self.loadingId)
end

-- PVE单机战斗loading
function BattleLoadingControler:showPVEBattleLoadingView()
	local scene = WindowControler:getCurrScene()
    scene:showBattleRoot()

    local initPercent = RandomControl.getOneRandomInt(10,25)
    local initTweenPercentInfo = {percent = initPercent,frame=20}

    local leftPercent = 100 - initPercent - 10
    local actionFuncs = {percent=leftPercent, frame = 20, action = nil}

    local processActions = {actionFuncs}

    self.loadingView =  WindowControler:showBattleWindow("CompLoading",initTweenPercentInfo, processActions)
end

-- loading全部加载完成
function BattleLoadingControler:loadAllUsersComplete(data)
    -- if BattleControler.__gameMode == Fight.gameMode_pvp then
    --     return
    -- end

    if self.loadingView == nil or tolua.isnull(self.loadingView) then
        --echo("收到事件  但是    不处理--------")
        return 
    end


    --echo("BattleLoadingControler:loadAllUsersComplete-------------------------")
    --dump(data.params)
	if data.params ~= nil then
        local result = data.params.result
        if result ~= nil and tonumber(result) == 1 then
        	-- 单机loading
            --if self.sigleFlag==1 self.loadingType == self.battleLoadingType.LOADING_TYPE_PVE then
            echo("self.sigleFlag == ",self.sigleFlag)
            if self.sigleFlag==1  then
				local loadingCompleteCallBack = function()
					self.loadingView:startHide()
                    self.loadingType = nil
                    self.loadingView = nil
				end

				delayFrame = 0.2 * GAMEFRAMERATE
				self.loadingView:finishLoading(delayFrame,c_func(loadingCompleteCallBack))
			end
        else
            WindowControler:showTips("loading加载异常")
        end
    else
        echoError("全部加载完成,没有收到参数")
        -- self:closeLoadingView()
        self.loadingView:startHide()
        self.loadingType = nil
        self.loadingView = nil
    end    
    
end

BattleLoadingControler:init()

return BattleLoadingControler