local GodDetailView = class("GodDetailView", UIBase)

function GodDetailView:ctor(winName,data)
	GodDetailView.super.ctor(self, winName)
    self.data = data
end

function GodDetailView:loadUIComplete()
	self:setAlignment()
	self:registerEvent()
    self:initGogList()
    self:updateGodDetail()
    self.scroll_1:gotoTargetPos(self.data.fla ,1,1)
end


function GodDetailView:setAlignment()
	--设置对齐方式
	FuncCommUI.setViewAlign(self.panel_6, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_icon, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.btn_help, UIAlignTypes.LeftTop)
    FuncCommUI.setScale9Align(self.scale9_1,UIAlignTypes.MiddleTop, 1, 0)
end
function GodDetailView:registerEvent()
    GodDetailView.super.registerEvent();
    self.btn_back:setTap(c_func(self.onBtnBackTap, self));
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE,self.updataShengji,self)
    EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE,self.updataShengji,self)
    
end
-- 左侧列表
function GodDetailView:initGogList()
    local configData = FuncGod.getConfigGodData();
    local createFunc = function ( itemData )
		local view = UIBaseDef:cloneOneView(self.panel_2)
		self:updateListItem(view, itemData)
		return view
    end
    local reuseUpdateCellFunc = function (itemData, view)
        self:updateListItem(view, itemData,true)
        return view;  
    end
    
	local _scrollParams = {
			{
				data = configData,
				createFunc= createFunc,
				perFrame = 1,
				offsetX =0,
				offsetY =0,
				itemRect = {x=0,y= -112,width=112,height = 112},
				heightGap = 0,
                perNums = 1,
                updateFunc = reuseUpdateCellFunc,

			}
		}
    self.scroll_1:styleFill(_scrollParams);
	self.scroll_1:hideDragBar()
    self.panel_2:setVisible(false)
end
function GodDetailView:updateListItem(view, itemData)
    view.mc_1:showFrame(tonumber(itemData.fla))
    if itemData.fla == self.data.fla then
        view.panel_1:setVisible(true)
    else
        view.panel_1:setVisible(false)
    end
    local lock = GodModel:godUnlockById(itemData)
    if lock == true then
        view.txt_1:setVisible(true)
        view.txt_1:setString(GodModel:getGodLevelById(itemData.id))
        FilterTools.clearFilter(view) 
    else
        view.txt_1:setVisible(false)
        FilterTools.setGrayFilter(view) 
    end
    view.mc_1:setTouchedFunc(c_func(function()
        -- 列表头像点击事件
        if self.scroll_1:isMoving() then
            return
        end
        if self.data == itemData then
            return
        end
        
        if lock == false then
            local strLock = GameConfig.getLanguage(itemData.openTranslate)
            WindowControler:showTips(strLock)
            return
        end
        local  lastView = self.scroll_1:getViewByData(self.data);
        lastView.panel_1:setVisible(false)
        view.panel_1:setVisible(true)
        self.data = itemData;
        self:updateGodDetail();
    end,self))
end
-- 右侧详细信息
function GodDetailView:updateGodDetail()
    -- 御灵index
    local framIndex = self.data.fla
    -- 名称
    self.panel_3.mc_1:showFrame(framIndex)
    -- 等级
    local currentLevel = GodModel:getGodLevelById(self.data.id)
    self.panel_3.txt_1:setString(currentLevel)
    -- 主动攻击增加攻击力
    for i = 1 ,5 do
        if self:getChildByTag(2000+i) then
            self:removeChildByTag(2000+i)
        end
    end
    local arr = GodModel:getExtraByGodData(self.data)
    local index = 0
    self.panel_4:setVisible(false)
    if arr then
        for i,v in pairs(arr) do
            local panel = UIBaseDef:cloneOneView(self.panel_4)
            panel:setPositionY(self.panel_4:getPositionY() + 42 * index)
            panel.txt_1:setString(v.str)
            panel.txt_2:setString(v.tyValue)
            self:addChild(panel)
            index = index + 1
            panel:setTag(2000+index)
            
        end
    end

    -- 升级详细信息
    self:updataShengji();

    -- 饰品
    self:updataShipin();

end
function GodDetailView:updataShengji()
    self.mc_2:showFrame(1)
    local upLevelInfo = self.mc_2.currentView.panel_1
    local configExp ,configPower = GodModel:getConfigGodExpAndPowerById(self.data.id)
    local currentExp = GodModel:getGodExpById(self.data.id)
    -- 加威力
    upLevelInfo.txt_2:setString("威力+" .. configPower )
    -- 经验条
    if configExp == 0 then
        upLevelInfo.panel_exp.txt_9999:setString( "--/--")
        upLevelInfo.panel_exp.progress_exp:setPercent(100)
    else
        upLevelInfo.panel_exp.txt_9999:setString(currentExp .. "/" .. configExp)
        upLevelInfo.panel_exp.progress_exp:setPercent(currentExp/configExp*100)
    end
    
    local numMax = GodModel:getStrongeUp()
    --仙玉强化
    local xyNum = GodModel:getStrongedUp(2)
    local xyCost = GodModel:getCost(2)
    upLevelInfo.txt_4:setString(xyCost)
    if UserModel:getGold() >= tonumber(xyCost) then
        upLevelInfo.txt_4:setColor(cc.c3b(132,68,14))
    else    
        upLevelInfo.txt_4:setColor(cc.c3b(255,0,0))
    end
    upLevelInfo.panel_1:setVisible(true)
    upLevelInfo.btn_1:setTap(c_func(self.qianghuaTap,self,2,xyCost))
    upLevelInfo.btn_1:getUpPanel().txt_2:setString((numMax-xyNum) .. "/" .. numMax)
    if GodModel:getStrongedUp(2) > 0 then
        upLevelInfo.panel_1:setVisible(false)
    else
        upLevelInfo.panel_1:setVisible(true)
    end
    if numMax-xyNum > 0 then
        FilterTools.clearFilter(upLevelInfo.btn_1)
    else   
        FilterTools.setGrayFilter(upLevelInfo.btn_1) 
    end
    --铜钱强化
    local tqNum = GodModel:getStrongedUp(1)
    local tqCost = GodModel:getCost(1)
    upLevelInfo.txt_5:setString(tqCost)
    if UserModel:getCoin() >= tonumber(tqCost) then
        upLevelInfo.txt_5:setColor(cc.c3b(132,68,14))
    else    
        upLevelInfo.txt_5:setColor(cc.c3b(255,0,0))
    end
    upLevelInfo.btn_2:setTap(c_func(self.qianghuaTap,self,1,tqCost))
    upLevelInfo.btn_2:getUpPanel().txt_2:setString((numMax-tqNum) .. "/" .. numMax)
    if numMax-tqNum > 0 then
        FilterTools.clearFilter(upLevelInfo.btn_2)
    else   
        FilterTools.setGrayFilter(upLevelInfo.btn_2) 
    end
    -- 战斗力
    self.mc_1:showFrame(1)
    local zdl = GodModel:getZhandouli(self.data)
    local powerValueTable = number.split(zdl);
    self:setPowerNum(self.mc_1.currentView.panel_1, powerValueTable);

end
function GodDetailView:updataShipin()
    local grooveArr = GodModel:getGrooveArrByGodId(self.data.id)
    local configGodGroove = FuncGod.getGodGroove()
    for i,v in pairs(grooveArr) do
        local data = configGodGroove[v]
        dump(data,"测试 看数据")
        self["panel_f"..i].ctn_1:removeAllChildren();
        local grooveUnlock = GodModel:isGrooveActivate(self.data.id,v)
        -- 封
        if grooveUnlock then
            self["panel_f"..i].panel_1:setVisible(false)
        else
            self["panel_f"..i].panel_1:setVisible(true)
        end
        
        local sprName = FuncRes.uipng(data.icon)
        local spr = display.newSprite(sprName);
        self["panel_f"..i].ctn_1:addChild(spr);
        self["panel_f"..i].panel_2:setVisible(false);
        self["panel_f"..i]:setTouchedFunc(c_func(function()
            self:updataShipinXQ(data,v)
            for i = 1,4 do
               self["panel_f"..i].panel_2:setVisible(false);
            end
            self["panel_f"..i].panel_2:setVisible(true);
        end,self))
    end
end
function GodDetailView:updataShipinXQ(data,grooveId)
    self.mc_2:showFrame(2)
    local panelInfo = self.mc_2.currentView.panel_1
    local grooveUnlock = GodModel:isGrooveActivate(self.data.id,grooveId)
    local costArr = data.cost
    dump(costArr,"测试数据消耗饰品")
    for i,v in pairs(costArr) do
        panelInfo["UI_" .. i]:setResItemData({reward = v})
        panelInfo["UI_" .. i]:showResItemName(false)
        panelInfo["UI_" .. i]:setVisible(true)
        if grooveUnlock then
            local a,b= UserModel:getResInfo( v )
            panelInfo["UI_" .. i]:setResItemNum(b)
        end
        panelInfo["UI_" .. i]:setTouchedFunc(c_func(function ()
            local strArr = string.split(v,",")
            echo("id ========" .. strArr[1] )
            local getWayId = strArr[1]
            if tonumber(strArr[1]) == 1 then
                getWayId = strArr[2]
            end
            WindowControler:showWindow("GetWayListView", getWayId);
        end,self))
        
    end

    local jhxgArr = GodModel:getGrooveShuXing(grooveId)
    panelInfo.txt_3:setVisible(false)
    for i = 1,7 do
        if panelInfo:getChildByTag(10000+i) then
             panelInfo:removeChildByTag(10000+i)
        end
    end
    for i,v in pairs(jhxgArr) do
        local txt = UIBaseDef:cloneOneView(panelInfo.txt_3)
        txt:setPositionY(panelInfo.txt_3:getPositionY() - (i-1) * 40)
        txt:setPositionX(panelInfo.txt_3:getPositionX())
        txt:setString(v)
        panelInfo:addChild(txt)
        if grooveUnlock then
            txt:setColor(cc.c3b(0,255,0))
        else
            txt:setColor(cc.c3b(132,68,14))
        end
        txt:setTag(10000+i)
    end
    

    panelInfo.btn_1:setTap(c_func(function ()
         self.mc_2:showFrame(1)
    end,self))

    
    if grooveUnlock then
        panelInfo.mc_1:showFrame(2)
    else
        panelInfo.mc_1:showFrame(1)
        local rt = GodModel:isGrooveCanActivate(self.data.id,grooveId,costArr)
        if rt == 1 then
            FilterTools.clearFilter(panelInfo.mc_1.currentView.btn_2)
            panelInfo.mc_1.currentView.btn_2:setTap(c_func(self.grooveActivteServer,self,grooveId,costArr))
        else
            echo("条件不足 == " .. rt)
            FilterTools.setGrayFilter(panelInfo.mc_1.currentView.btn_2)
            panelInfo.mc_1.currentView.btn_2:setTap(c_func(function ()
                WindowControler:showTips("条件不足")
            end,self))
        end
        
    end
end
-- 饰品激活
function GodDetailView:grooveActivteServer(grooveId,costArr)
    GodServer:godGrooveActivate(tonumber(grooveId),c_func(self.grooveActivteServerCallBack,self))
end
function GodDetailView:grooveActivteServerCallBack(event)
    if not event.result then
		return
	end
    -- 
    local panelInfo = self.mc_2.currentView.panel_1
    panelInfo.mc_1:showFrame(2)
    self:updateGodDetail()
end
function GodDetailView:setPowerNum(panel_power,nums)
    local len = table.length(nums);
    panel_power.mc_shuzi:showFrame(len);

    for k, v in pairs(nums) do
        local mcs = panel_power.mc_shuzi:getCurFrameView();
        mcs["mc_" .. tostring(k)]:showFrame(v + 1);
    end
end
--强化
function GodDetailView:qianghuaTapCallBack(event)
    dump(event,"强化回调")
    if not event.result then
		return
	end
    self:updateGodDetail()
end
function GodDetailView:qianghuaTap(_type,cost)
    if _type == 2 then -- 仙玉强化
        echo("仙玉强化")
        if UserModel:tryCost(UserModel.RES_TYPE.DIAMOND, tonumber(cost), true) == true then
            GodServer:godUpgrade(self.data.id,1,c_func(self.qianghuaTapCallBack,self))
        end
        
    elseif _type == 1 then -- 铜钱强化
        echo("铜钱强化")
        if UserModel:tryCost(UserModel.RES_TYPE.COIN, tonumber(cost), true) == true then
            GodServer:godUpgrade(self.data.id,0,c_func(self.qianghuaTapCallBack,self))
        end
        
    end
end

--返回 
function GodDetailView:onBtnBackTap()
	self:startHide()
end

return GodDetailView
