local GetWayListItemView = class("GetWayListItemView", UIBase);

function GetWayListItemView:ctor(winName)
    GetWayListItemView.super.ctor(self, winName);
end

function GetWayListItemView:loadUIComplete()
    self.mc_1:showFrame(1)

    self.btn = self.mc_1.currentView.btn_1
	self.panelInfo = self.btn.spUp.panel_1

    self:registerEvent();
end 

function GetWayListItemView:registerEvent()
	GetWayListItemView.super.registerEvent();

    self.btn:setTap(c_func(self.pressGetWayItem, self));
    -- self.mc_1:setTouchedFunc(c_func(self.pressGetWayItem, self))

    --接受事件
    -- EventControler:addEventListener(UIEvent.UIEVENT_STARTHIDE, 
    --     self.onUIStartHide,self)
end

--设置道具数据
function GetWayListItemView:setGetWayItemData(getWayId,listView, getWayView)
	self.listView = listView
	self.getWayId = getWayId
    self._getWayView = getWayView;

    if getWayId == nil or getWayId == "" then
        self.mc_1:showFrame(2)
        return
    end

	local getWayData = FuncCommon.getGetWayDataById(getWayId)
    self.getWayData = getWayData

    -- 描述
    self:setGetWayDes()

    -- 依赖的功能索引
    local funcIndex = self.getWayData.index
    local getWayOpenConditon = self.getWayData.condition

    self.isOpen = FuncCommon.isSystemOpen(funcIndex,getWayOpenConditon)

    if not self.isOpen then
        FilterTools.setGrayFilter(self.btn);
    end
end

function GetWayListItemView:setGetWayDes()
    local desStr = GameConfig.getLanguage(self.getWayData.name) or ""
    local getWayType = self.getWayData.type

    local desDetail = ""
    local des = self.getWayData.des
    if des then
        desDetail = GameConfig.getLanguage(des) or ""
    end

    self.panelInfo.txt_1:setString("【" .. desStr .. "】")
    self.panelInfo.txt_2:setString(desDetail)
end

function GetWayListItemView:pressGetWayItem()
	echo("点击获取途径，跳转到对应系统 getWayId=",self.getWayId)
    if self.getWayId == nil or self.getWayId == "" then 
        return
    end

    if self.listView ~= nil and self.listView:isMoving() then
        return
    end

    if not self.isOpen then
        WindowControler:showTips(GameConfig.getLanguage("tid_common_2002"))
        return
    end

    local linkStr = self.getWayData.link
    local linkPara = self.getWayData.linkPara

    if linkStr ~= nil then
        -- local linkArr = string.split(linkPara, ",");
        local linkArr = linkPara

        local viewClassName = WindowsTools:getWindowNameByUIName(linkStr)

        if linkArr ~= nil then
            WindowControler:showWindow(viewClassName, linkArr,"GETWAY")
--            WindowControler:showWindow(viewClassName, unpack(linkArr))
        else
            WindowControler:showWindow(viewClassName)
        end
        
        if self._getWayView ~= nil then
            -- self._getWayView:setVisible(false);
            -- self._jumpToViewName = viewClassName;
            self._getWayView:startHide();
        end 
    end
end

-- function GetWayListItemView:onUIStartHide(e)
--     local targetUI = e.params.ui;
--     if targetUI.windowName == self._jumpToViewName then 
--         self._getWayView:setVisible(true);
--     end 
-- end

function GetWayListItemView:updateUI()
	
end

return GetWayListItemView;
