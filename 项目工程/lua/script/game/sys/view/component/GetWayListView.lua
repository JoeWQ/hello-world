--[[
    --
    -- Author: ZhangYanguang
    -- Date: 2016-04-12
    -- 道具或资源获取途径公共弹出框组件
    参数：resId 资源ID
]]

local GetWayListView = class("GetWayListView", UIBase);

-- isHCSP 是否是合成碎片
function GetWayListView:ctor(winName,resId,isHCSP,isTreasuer)
    GetWayListView.super.ctor(self, winName);

    self.resId = tostring(resId)
    self.hcsp = isHCSP
    -- 资源是否是道具
    self.isItemRes = false
    self.isTreasure = isTreasuer
end

function GetWayListView:loadUIComplete()
	self:registerEvent();

    self:initData()
    self:initScrollCfg()

    self:updateUI()
    self:registClickClose("out")
end 

function GetWayListView:initData()
    local itemData = FuncItem.getItemData(self.resId)
    if itemData ~= nil then
        self.isItemRes = true
        -- 是道具
        self.itemData = FuncItem.getItemData(self.resId)
        self.getWayListData = self.itemData.accessWay
        if self.getWayListData == nil then
            self.getWayListData = {}
        end
        
        -- 获取途径id降序排
        ItemsModel:sortGetWayListData(self.getWayListData)
    else
        -- 非道具资源
        local   _baseResource=FuncDataResource.getDataByID(self.resId);
        self.getWayListData = _baseResource.accessWay--FuncDataResource.getDataAccessWay(self.resId)
        if(_baseResource.listName ~=nil and _baseResource.listName~="")then
               self.txt_1:setString(GameConfig.getLanguage( _baseResource.listName));
        end
    end
end 

function GetWayListView:initScrollCfg()
    -- 创建途径item
    local createGetWayItemFunc = function ( itemData )
        local view = WindowsTools:createWindow("GetWayListItemView")
        view:setGetWayItemData(itemData,self.scroll_list,self)
        return view
    end

    self.__getWaylistParams = {
        {
            data = self.getWayListData,
            createFunc = createGetWayItemFunc,
            itemRect = {x=0,y=-78,width = 385,height = 78},
            perNums= 1,
            offsetX = 27,
            offsetY = 10,
            widthGap = -12,
            heightGap = -6,
            perFrame = 4
        },
    }
end

function GetWayListView:registerEvent()
	GetWayListView.super.registerEvent();
    self.btn_close:setTap(c_func(self.press_btn_close, self));
end

function GetWayListView:updateUI()
   if(#self.__getWaylistParams>0 and self.__getWaylistParams[1].data ~=nil)then
    self.scroll_list:styleFill(self.__getWaylistParams)
    -- echo("GetWayList self.resId=",self.resId)
    end
    local resDesc = ""
    local resName = ""
    local resNum = 0
    local params = {}

    -- 如果是道具
    if self.isItemRes then
        local itemData = self.itemData
        resDesc = GameConfig.getLanguage(itemData.des)

        if self.hcsp or self.isTreasure then
            local _treasureData = FuncTreasure.getTreasureAllConfig()
            local resNameId = _treasureData[tostring(itemData.id)].name
            resName = GameConfig.getLanguage(resNameId)
        else
            resName = GameConfig.getLanguage(itemData.name)
        end
        

        

        resNum = ItemsModel:getItemNumById(self.resId)
        params = {
            itemId = self.resId,
            resNum = resNum,
        }

    -- 非道具资源
    else
        params.reward = self.resId .. ",0"
        resName = FuncDataResource.getResNameById(self.resId)
        resDesc = FuncDataResource.getResDescrib(self.resId)

        local _,hasNum = UserModel:getResInfo(params.reward)
        resNum = hasNum
    end
    self.UI_goods:setResItemData(params)
    self.UI_goods:showResItemNum(false)

    -- 获取途径
    self.txt_1:setString(GameConfig.getLanguage("#tid32107"))

    -- 资源名字
    self.txt_2:setString(resName)
    local resInfoDesc = GameConfig.getLanguageWithSwap("tid_common_2012",resNum)

    -- 数量描述
    self.rich_3:setString(resInfoDesc)
    -- 用途描述
    self.txt_4:setString(resDesc)

    -- 合成中法宝获取途径
    if self.isTreasure then
        self:combineTxt()
    end
end

function GetWayListView:press_btn_close()
    self:startHide()
end

function GetWayListView:combineTxt()
    self.rich_3:setString(GameConfig.getLanguage("tid_common_2016"));
    self.txt_4:setVisible(false);
end

return GetWayListView;
