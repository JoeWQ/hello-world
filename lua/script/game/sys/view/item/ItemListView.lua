local ItemListView = class("ItemListView", UIBase);

function ItemListView:ctor(winName)
    ItemListView.super.ctor(self, winName);
end

function ItemListView:loadUIComplete()
    self:initData()
	self:registerEvent();

    self:initUI()

    self:initScrollCfg()
    self:updateUI(self.selectTagType.TAG_TYPE_ALL)
end 

function ItemListView:registerEvent()
	ItemListView.super.registerEvent();
    self.btn_back:setTap(c_func(self.press_btn_back, self));

    -- 监听item选择事件
    EventControler:addEventListener(ItemEvent.ITEMEVENT_CLICK_ITEM_VIEW,self.onClickItemView,self);

    local tagPanel = self.panel_left.panel_1.panel_bgyeqian
    self.tagPanel = tagPanel

    tagPanel.mc_yeqian1.currentView:setTouchedFunc(c_func(ItemListView.pressItemTag, self, self.selectTagType.TAG_TYPE_ALL));
    tagPanel.mc_yeqian2.currentView:setTouchedFunc(c_func(ItemListView.pressItemTag, self, self.selectTagType.TAG_TYPE_BOX));
    tagPanel.mc_yeqian3.currentView:setTouchedFunc(c_func(ItemListView.pressItemTag, self, self.selectTagType.TAG_TYPE_MATERIAL));
    tagPanel.mc_yeqian4.currentView:setTouchedFunc(c_func(ItemListView.pressItemTag, self, self.selectTagType.TAG_TYPE_PIECE));

    -- 道具更新消息
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.updateItems, self)
    -- 合成等成功返回消息
    EventControler:addEventListener(TreasureEvent.TREASURE_COMBINE_EVENT, self.onActionSuccess, self)
end

-- 初始化数据
function ItemListView:initData()
    self.selectAnimCache = {}

    -- 页签类别
    self.selectTagType = {
        TAG_TYPE_ALL = 1,       --全部
        TAG_TYPE_BOX = 2,       --宝箱
        TAG_TYPE_MATERIAL = 3,  --材料
        TAG_TYPE_PIECE = 4,     --碎片
    }

    self.itemType = ItemsModel.itemType

    -- 全部item展示类别顺序
    self.itemOrderList = {
        self.itemType.ITEM_TYPE_BOX,
        self.itemType.ITEM_TYPE_MATERIAL,
        self.itemType.ITEM_TYPE_PIECE,
    }

    -- 获取道具所有子类别
	self.itemSubType = ItemsModel:getAllItemSubTypes()
    -- 当前选择的itemId
    self.curSelectItemId = nil
    -- 页签总数量
    self.tagNum = 4
    -- 是否是初始化
    self.isInit = true
    -- 是否正在开宝箱
    self.isOpeningBox = false
end

-- 初始化滚动配置
function ItemListView:initScrollCfg()
    -- 创建道具item
    local createItemFunc = function ( itemData )
        local view = WindowsTools:createWindow("CompResItemView")
        self:setItemViewData(view,itemData)
        return view
    end

    -- 道具item的更新方法
    local updateItemFunc = function(itemData,itemView)
        self:setItemViewData(itemView,itemData)
        return itemView
    end

    -- -------------------------------------------------------
    -- 创建碎片item
    local createPieceItemFunc = function(itemData)
        local view = WindowsTools:createWindow("CompResItemView")
        self:setItemViewData(view,itemData)
        -- view:setQualityScale(0.8)
        return view
    end

    -- 道具item的更新方法
    local updatePieceItemFunc = function(itemData,itemView)
        self:setItemViewData(itemView,itemData)
        return itemView
    end
    -- -------------------------------------------------------

    -- 创建道具分割线itemLine
    self.itemLineView:setVisible(false)
    local createItemLineFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.itemLineView)
        return view
    end

    -- 创建途径滚动区上部分
    local mcGoods = self.mc_goodxq
    mcGoods:showFrame(2)
    local panelGoods = mcGoods.currentView.panel_xq1
    local createScrollFunc = function ( itemData )
        local mcGundong =  panelGoods.mc_gundong

        -- 是否隐藏合成按钮
        if self:needHideActionBtn() then
            mcGundong:showFrame(2)
        else
            mcGundong:showFrame(1)
        end

        -- todo
        -- local panelScroll = mcGundong.currentView.panel_gundong
        local panelScroll = mcGundong.currentView.panel_title
        panelScroll:setVisible(false)

        local view = UIBaseDef:cloneOneView(panelScroll)
        self:setScrollDetail(view,itemData)
        return view
    end

    -- 创建途径item
    local panelGoods = mcGoods.currentView.panel_xq1
    
    local createGetWayItemFunc = function (itemData)
        local mcGundong =  panelGoods.mc_gundong
        -- 是否隐藏合成按钮
        if self:needHideActionBtn() then
            mcGundong:showFrame(2)
        else
            mcGundong:showFrame(1)
        end

        -- 隐藏模板获取途径itemView
        local panelGetWay = panelGoods.mc_gundong.currentView.panel_tujing
        panelGetWay:setVisible(false)

        local view = UIBaseDef:cloneOneView(panelGetWay)
        local scrollList = mcGundong.currentView.scroll_list

        view.UI_1:setGetWayItemData(itemData,scrollList)

        return view
    end

    -- itemList 滚动配置，根据道具类型，动态生成
    self.__listParams = {

    }

    -- itemView参数配置
    self.itemViewParams = {
        data = nil,
        itemRect = {x=0,y=-98,width = 98,height = 98},
        createFunc = createItemFunc,
        perNums= 4,
        offsetX = 28,
        offsetY = 13,
        widthGap = 7,
        heightGap = 8,
        perFrame = 1,
        updateCellFunc = updateItemFunc,
        cellWithGroup = 1
    }

    -- 碎片间距不同，单独配置
    -- itemPieceView参数配置
    self.itemPieceViewParams = {
        data = nil,
        itemRect = {x=0,y=-98,width = 98,height = 98},
        createFunc = createPieceItemFunc,
        perNums= 4,
        offsetX = 20,
        offsetY = 8,
        widthGap = 11,
        heightGap = 8,
        perFrame = 1,
        updateCellFunc = updatePieceItemFunc,
        cellWithGroup = 1
    }

    -- item分割线参数配置
    self.itemLineParams = {
        data = {""},
        createFunc = createItemLineFunc,
        itemRect = {x=0,y=-11,width = 384,height = 11},
        perNums= 1,
        offsetX = 26,
        offsetY = 8,
        widthGap = 7,
        heightGap = 0,
        perFrame = 1,
        updateCellFunc = GameVars.emptyFunc,
        cellWithGroup = 2
    }

    self.__getWaylistParams = {
        {
            data = self.getWayListData,
            createFunc = createGetWayItemFunc,
            itemRect = {x=8,y=-40,width = 308,height = 62},
            perNums= 1,
            offsetX = 17,
            offsetY = 0,
            widthGap = 0,
            heightGap = -8,
            perFrame = 4
        },
    }
end

-- 初始化UI
function ItemListView:initUI()
    -- FuncArmature.loadOneArmatureTexture("UI_common", nil, true)
    local scaleX = GameVars.width / GAMEWIDTH
    local scaleY = GameVars.height / GAMEHEIGHT

    --分辨率适配
    --关闭按钮右上
    FuncCommUI.setViewAlign(self.btn_back,UIAlignTypes.RightTop) 
    FuncCommUI.setViewAlign(self.panel_title,UIAlignTypes.LeftTop) 
    FuncCommUI.setViewAlign(self.panel_res,UIAlignTypes.RightTop)
    FuncCommUI.setScale9Align(self.scale9_resdi,UIAlignTypes.MiddleTop, 1, 0)
    -- 页签适配
    FuncCommUI.setViewAlign(self.panel_left.panel_1,UIAlignTypes.LeftTop,0.7) 
    FuncCommUI.setViewAlign(self.panel_zhui,UIAlignTypes.LeftTop,0.7) 

    self.panel_left.mc_beibaonei:showFrame(1)
    -- 道具列表滚动区
    self.scrollItemList = self.panel_left.mc_beibaonei.currentView.panel_goodskuang1.scroll_list
    -- 分割线
    self.itemLineView = self.panel_left.mc_beibaonei.currentView.panel_goodskuang1.panel_1
    -- 默认隐藏道具详情
    self.mc_goodxq:setVisible(false)
    self.scrollItemList:enableMarginBluring();
end

-- 切换背包页签
function ItemListView:pressItemTag(tagType)
    if self.curTagType == tagType then
        return
    end

    self:updateUI(tagType)
end

-- 更新所有UI
function ItemListView:updateUI(tagType)
    --修改当前tagType
    self.curTagType = tagType
    self:showItemsByTagType(tagType)
    self:updateTagStatus(tagType)
end

-- 更新道具明细
function ItemListView:onClickItemView(event)
    local itemId = event.params.itemId
    self.curSelectItemId = itemId

    self:updateItemDetail()
end

-- 更新右侧道具明细
function ItemListView:updateItemDetail()
    if self.curSelectItemId == nil then
        return 
    end
    
    local itemId = self.curSelectItemId
    local item = ItemsModel:getItemById(itemId)
    local itemData = FuncItem.getItemData(itemId)
    local itemDesc = GameConfig.getLanguage(itemData.des)
    local itemNum = item:num()

    local mcGoods = self.mc_goodxq
    mcGoods:setVisible(true)
    local panelGoods = nil

    -- 如果选择的是宝箱
    if ItemsModel:isBox(itemId) then
        mcGoods:showFrame(1)
        panelGoods = mcGoods.currentView.panel_xq1

        self:setBoxBtnAction(panelGoods,itemId,itemNum)
    else
        mcGoods:showFrame(2)
        panelGoods = mcGoods.currentView.panel_xq1

        -- 获取途径滚动条条初始化
        local getWayListData = itemData.accessWay
        
        -- 更新获取途径滚动条
        self:updateGetWayListView(panelGoods,getWayListData,itemData)

        local mcGundong =  panelGoods.mc_gundong
        -- 是否隐藏合成按钮
        if self:needHideActionBtn() then
            mcGundong:showFrame(2)
        else
            mcGundong:showFrame(1)
            self:updateBtnAction(mcGundong,itemData)
        end
    end

    -- 道具名字
    local txtItemName = self:getItemNameTxt(panelGoods,itemId)
    txtItemName:setString(GameConfig.getLanguage(itemData.name))

    -- 道具数量
    panelGoods.txt_shuzhi1:setString(GameConfig.getLanguageWithSwap("tid_common_1002",itemNum))

    -- 道具描述
    if panelGoods.txt_djmiaoshu ~= nil then
        panelGoods.txt_djmiaoshu:setString(itemDesc)
    end

    -- 更新Item图标框
    local  data = {
        itemId=itemId,
        itemNum=itemNum,
    }
    -- panelGoods.UI_goods:setItemData(item,ITEM_VIEW_TYPE.TYPE_ITEM_LIST_DETAIL_VIEW,self)
    panelGoods.UI_goods:setResItemData(data)
    panelGoods.UI_goods:showResItemNum(false)
end

-- 设置按钮响应行为
function ItemListView:updateBtnAction(mcGundong,itemData)
    local itemId = itemData.id
    local itemSubType = itemData.subType

    local itemDesc = GameConfig.getLanguage(itemData.des)

    -- 设置动作按钮显示状态
    self:updateItemActionBtnStatus(mcGundong.currentView.mc_qitabtn,itemId,itemSubType)
    mcGundong.currentView.mc_qitabtn.currentView:setTouchedFunc(c_func(ItemListView.doItemAction, self, itemId,itemSubType));
end

-- 获取道具名字文本框
function ItemListView:getItemNameTxt(panelGoods,itemId)
    local itemData = FuncItem.getItemData(itemId)
    local itemType = itemData.type

    -- 道具名字
    local mcItemName = panelGoods.mc_daojuming

    if itemType == self.itemType.ITEM_TYPE_PIECE then
        -- 碎片固定为第7帧
        mcItemName:showFrame(7)
    else
        mcItemName:showFrame(itemData.quality or 1)
    end

    local txtItemName = mcItemName.currentView.txt_daojuming
    return txtItemName
end

-- 设置开宝箱按钮
function ItemListView:setBoxBtnAction(panelGoods,itemId,itemNum)
    local boxActionMc = panelGoods.mc_1
    self:setBoxBtnRedPointStatus(boxActionMc,itemNum)

    -- 开十个按钮
    local btnOpenTen = nil
    -- 打开按钮
    local btnOpen = nil

    local openTenFunc = function()
        self:openBoxes(itemId,ItemsModel.boxType.TYPE_BOX_NUM_TEN,itemNum)
    end

    local openFunc = function()
        self:openBoxes(itemId,ItemsModel.boxType.TYPE_BOX_NUM_ONE,itemNum)
    end

    if tonumber(itemNum) > 1 then
        boxActionMc:showFrame(1)
        btnOpenTen = boxActionMc.currentView.btn_kaishigebtn
        btnOpen = boxActionMc.currentView.btn_dakaibtn

        btnOpenTen:setTap(c_func(openTenFunc, self));

        local showBoxNum = ItemsModel.boxType.TYPE_BOX_NUM_TEN 
        if itemNum < ItemsModel.boxType.TYPE_BOX_NUM_TEN then
            showBoxNum = itemNum
        end

        local btnTxt = GameConfig.getLanguageWithSwap("tid_bag_1003",showBoxNum)
        btnOpenTen:setBtnStr(btnTxt,"txt_ten")
    else
        boxActionMc:showFrame(2)
        btnOpen = boxActionMc.currentView.btn_dakaibtn
    end

    btnOpen:setTap(c_func(openFunc, self));
end

-- 设置打开按钮红点状态
function ItemListView:setBoxBtnRedPointStatus(boxActionMc,itemNum)
    local btnOpen = boxActionMc.currentView.btn_dakaibtn
    local btnOpenTen = boxActionMc.currentView.btn_kaishigebtn

    -- 宝箱数量大于等于10个，打开10个按钮显示红点
    if tonumber(itemNum) >= 10 then
        btnOpen:setBtnChildVisible("panel_red", false)
        if btnOpenTen then
            btnOpenTen:setBtnChildVisible("panel_red", true)
        end
    else
        btnOpen:setBtnChildVisible("panel_red", true)
        if btnOpenTen then
            btnOpenTen:setBtnChildVisible("panel_red", false)
        end
    end
end

-- 更新明细的滚动条
function ItemListView:updateGetWayListView(panelGoods,getWayListData,itemData)
    if getWayListData == nil then
        -- 如果没有获取途径，设置默认第一个为空
        getWayListData = {""}
    end

    -- 更新获取途径列表
    -- 获取途径id降序排
    ItemsModel:sortGetWayListData(getWayListData)
    self.__getWaylistParams[1].data = getWayListData

    local mcGundong =  panelGoods.mc_gundong
    -- 是否隐藏操作按钮
    if self:needHideActionBtn() then
        mcGundong:showFrame(2)
    else
        mcGundong:showFrame(1)
    end

    local getWayScrollList = mcGundong.currentView.scroll_list
    getWayScrollList:cancleCacheView()
    getWayScrollList:styleFill(self.__getWaylistParams)
    getWayScrollList:gotoTargetPos(1,1,0,false)

    self.getWayScrollList = getWayScrollList
end

-- 是否隐藏操作按钮
function ItemListView:needHideActionBtn()
    -- 当前碎片对应的法宝已经拥有
    local treasure = TreasuresModel:getTreasureById(self.curSelectItemId)
    
    local result = false
    -- 拥有该法宝，无法合成
    if treasure ~= nil then
        result = true
    else
        local itemData = FuncItem.getItemData(self.curSelectItemId)
        local hideBtn = FuncItem.getItemActionValue(itemData.subType,"hideBtn")

        if hideBtn and tonumber(hideBtn) == 1 then
            result = true
        else
            result = false
        end
    end

    return result
end

-- 道具修炼、强化、进阶
function ItemListView:doItemAction(itemId,itemSubType)
    local mcGoods = self.mc_goodxq
    local panelGoods = mcGoods.currentView.panel_xq1
    local getWayScrollList = panelGoods.scroll_list
    if getWayScrollList ~= nil then
        if getWayScrollList:isMoving() then
            return
        end
    end
    
    self:doItemJumpAction(itemId,itemSubType)
end

-- todo
-- 重构后根据配表进行跳转
function ItemListView:doItemJumpAction(itemId,itemSubType)
    itemSubType = tonumber(itemSubType)

    -- todo 全部合并到ItemAction表中
    -- 特殊处理
    -- 合成
    if itemSubType == self.itemSubType.ITEM_SUBTYPE_201 then
        local combineView = WindowControler:showWindow("CombineItemTip",self,{bgAlpha=0})
        combineView:setCombineData(CombineControl:getTeasureItemData(self.curSelectItemId))
    
    -- 伙伴碎片
    elseif itemSubType == self.itemSubType.ITEM_SUBTYPE_202 then
        if PartnerModel:isHavedPatnner(itemId) then
            -- 跳到升星界面
            -- todo 如果有伙伴显示使用，否则显示合成
            WindowControler:showWindow("PartnerView",FuncPartner.PartnerIndex.PARTNER_UPSTAR)
        else
            -- 跳到合成界面
            WindowControler:showWindow("PartnerView",FuncPartner.PartnerIndex.PARTNER_COMBINE)
        end
    else
        -- 从ItemAction表中获取跳转配置
        local actionData = FuncItem.getItemActionData(itemSubType)

        if actionData ~= nil then
            local linkViewName = actionData.link
            if linkViewName then
                local linkArr = actionData.linkPara or {}
                linkArr[#linkArr+1] = itemId

                local viewClassName = WindowsTools:getWindowNameByUIName(linkViewName)
                WindowControler:showWindow(viewClassName, unpack(linkArr))
            end
        end
    end
end

-- 根据item 子类型更新点击按钮状态
function ItemListView:updateItemActionBtnStatus(btnAction,itemId,itemSubType)
    if self:needHideActionBtn() then
        btnAction:setVisible(false)
    else
        btnAction:setVisible(true)

        -- 默认
        btnAction:showFrame(1)

        -- 特殊处理
        if itemSubType == self.itemSubType.ITEM_SUBTYPE_202 then
            -- 使用
            if PartnerModel:isHavedPatnner(itemId) then 
                btnAction:showFrame(4)
            else
                -- 合成
                btnAction:showFrame(1)
            end
        else
            local itemData = FuncItem.getItemData(itemId)
            local btnFrame = FuncItem.getItemActionValue(itemData.subType,"btnFrame")
            if btnFrame then
                btnAction:showFrame(tonumber(btnFrame))
            end
        end
    end 
end

-- 打开宝箱
function ItemListView:openBoxes(itemId,itemNum,leftBoxNum)
    -- 如果正在开宝箱中
    if self.isOpeningBox then
        return
    end

    local customItemCallBack = function(event)
        self.isOpeningBox = false
        if event.result ~= nil then
            local rewardArr = event.result.data.reward
            local data = {}
            data.reward = rewardArr
            data.itemId = itemId
            data.itemNum = itemNum
            WindowControler:showWindow("ItemBoxRewardView",data);
        end
    end

    local canUse = ItemsModel:checkItemUseCondition(itemId,itemNum)
    if canUse then
        self.isOpeningBox = true
        ItemServer:customItems(itemId, itemNum,c_func(customItemCallBack))
    else    
        -- 不足10个宝箱，有几个开几个
        if itemNum == ItemsModel.boxType.TYPE_BOX_NUM_TEN and leftBoxNum > 0 then
            self.isOpeningBox = true
            ItemServer:customItems(itemId, leftBoxNum,c_func(customItemCallBack))
        else
            WindowControler:showTips("宝箱数量不足")
        end
    end
end

-- 处理强化、合成、精炼等操作成功后消息
function ItemListView:onActionSuccess()
    local data = {}
    data.params = {}
    data.params[self.curSelectItemId] = true

    self:updateItems(data)
end

-- 更新道具
function ItemListView:updateItems(data)
    if data.params == nil then
        return
    end

    local refreshList = false
    for k,v in pairs(data.params) do
        local itemId = k

        local item = ItemsModel:getItemById(itemId)
        if item == nil then
            -- item被删除了，需要刷新列表
            refreshList = true
        else
            local targetItemData = self:findItemDataFromListData(itemId)
            if targetItemData == nil then
                refreshList = true
            else
                self:updateOneItemView(itemId)
            end
        end
    end

    -- 需要刷新列表
    if refreshList then
        -- 刷新滚动列表
        -- self:showItemsByTagType(self.curTagType)
        self:updateUI(self.curTagType)
    end

    -- -- 更新tag状态
    self:updateTagStatus(self.curTagType)
end

function ItemListView:updateOneItemView(itemId)
    -- 找到变化的item的tab引用
    local targetItemData = self:findItemDataFromListData(itemId)
    local item = ItemsModel:getItemById(itemId)

    local itemNum = ItemsModel:getFormatItemNum(itemId)
    if targetItemData then
        local targetView =  self.scrollItemList:getViewByData(targetItemData)
        if targetView == nil then
            echo("targetView is nil itemId====",itemId)
            return
        end

        targetView:setResItemNum(itemNum)

        if tonumber(itemId) == tonumber(self.curSelectItemId) then
            -- 更新itemDetail
            self:updateItemDetail()
        end 
    end
end

-- 更具itemId，从列表数据中查找itemData
function ItemListView:findItemDataFromListData(itemId)
    local itemType = self:getItemTypeByTagType(self.curTagType) 

    local targetItemData = nil
    if itemType == self.itemType.ITEM_TYPE_ALL then
        -- for i=1,#self.itemDatas do
        for k,v in pairs(self.itemDatas) do
            local data = v
            for n=1,#data do
                if tostring(data[n]:id()) == tostring(itemId) then
                    targetItemData = data[n]
                    return targetItemData
                end
            end
        end
    else
        for i=1,#self.itemDatas do
            if tostring(self.itemDatas[i]:id()) == tostring(itemId) then
                targetItemData = self.itemDatas[i]
                return targetItemData
            end
        end
    end

    return targetItemData
end

-- 更新页签状态
function ItemListView:updateTagStatus(tagType)
    if ItemsModel:isBagEmpty() then
        self:hideAllTag()
        return
    else
        if self:getItemNumByTagType(self.curTagType) == 0 then
            -- 显示当前类别无道具
            self.panel_left.mc_beibaonei:showFrame(tagType)

            -- 道具明细显示空
            -- self.mc_goodxq:showFrame(3)
            -- 2016-04-18 修改为隐藏明细
            self.mc_goodxq:setVisible(false)

            -- ZhangYanguang 2016-07-20 出现动画已弃用，所以消失动画也需要注释掉
            -- 逐渐消失
            -- local act = cc.Sequence:create(act.fadeout(0.15),nil)
            -- self.mc_goodxq:runAction(act)

            -- self:doItemDetailDisappearAnim()
        end
    end

    local tagNum = self.tagNum
    local tagPanel = self.tagPanel
    tagPanel:setVisible(true)

    for i=1,tagNum do
        tagPanel["mc_yeqian" .. i]:setVisible(true)
        if i == tagType then
            tagPanel["mc_yeqian" .. i]:showFrame(2)
        else
            tagPanel["mc_yeqian" .. i]:showFrame(1)
        end
    end

    -- 是否有未使用的宝箱
    if ItemsModel:hasCanUseBox() then
        tagPanel.panel_yeqianred1:setVisible(true)
        tagPanel.panel_yeqianred2:setVisible(true)
    else
        tagPanel.panel_yeqianred1:setVisible(false)
        tagPanel.panel_yeqianred2:setVisible(false)
    end
end

function ItemListView:showItemsByTagType(tagType)
    self.itemDatas = self:getItemDataByTagType(tagType)

    -- 设置滚动数据
    self.__listParams = self:buildItemScrollParams()
    -- self:buildItemScrollParams()

    -- ZhangYanguang 2016-07-13 屏蔽动画
    -- 是否是初始化
    --[[
    if self.isInit then
        self.isInit = false
        self:doItemLeftAppearAnim()
    end
    --]]

    -- 有相应的道具，显示道具列表
    if self:getItemNumByTagType(self.curTagType) > 0 then
        self.panel_left.mc_beibaonei:showFrame(1)
        self.scrollItemList:styleFill(self.__listParams)

        -- 切换类别，滚动条条重置并且默认选中第一个item
        self.scrollItemList:gotoTargetPos(1,1,2,false)
        -- self.curSelectItemId = self:getFirstItemId()
        local curSelectItemId = self:getFirstItemId()

        -- 默认选中第一个
        local targetItemData = self:findItemDataFromListData(curSelectItemId)
        local targetView =  self.scrollItemList:getViewByData(targetItemData)
        self:clickOneItemView(targetView, curSelectItemId)

        -- ZhangYanguang 2016-07-13 屏蔽动画
        -- self:doItemDetailAppearAnim()
    else
        self.panel_left.mc_beibaonei:showFrame(2)

        self:resetData()
    end
end

-- 该类型背包数据为空的时候，重置数据
function ItemListView:resetData()
    self.curSelectItemId = nil
end

-- 动态生成item滚动区配置参数
function ItemListView:buildItemScrollParams()
    local itemType = self:getItemTypeByTagType(self.curTagType) 

    local scrollParams = {}

    if itemType == self.itemType.ITEM_TYPE_ALL then
        local isFirstPart = true

        -- for i=1,#self.itemDatas do
        for i=1,#self.itemOrderList do
            local curItemType = self.itemOrderList[i]
            local data = self.itemDatas[curItemType]

            if #data > 0 then
                if isFirstPart then
                    isFirstPart = false
                else
                    -- 分割线
                    local copyLineParams = table.deepCopy(self.itemLineParams)
                    scrollParams[#scrollParams+1] = copyLineParams
                end

                -- 道具数据
                local copyItemParams = nil
                if curItemType == self.itemType.ITEM_TYPE_PIECE then
                    copyItemParams = table.deepCopy(self.itemPieceViewParams)
                else
                    copyItemParams = table.deepCopy(self.itemViewParams)
                end

                copyItemParams.data = data
                scrollParams[#scrollParams+1] = copyItemParams
            end
        end
    else
        local copyItemParams = nil
        if itemType == self.itemType.ITEM_TYPE_PIECE then
            copyItemParams = table.deepCopy(self.itemPieceViewParams)
        else
            copyItemParams = table.deepCopy(self.itemViewParams)
        end

        copyItemParams.data = self.itemDatas
        scrollParams[#scrollParams+1] = copyItemParams
    end

    return scrollParams
end

-- 获取第一个道具
function ItemListView:getFirstItemId()
    local itemType = self:getItemTypeByTagType(self.curTagType) 

    local firstItemId = nil
    if itemType == self.itemType.ITEM_TYPE_ALL then
        -- for i=1,#self.itemDatas do
        for i=1,#self.itemOrderList do
            local curItemType = self.itemOrderList[i]
            local data = self.itemDatas[curItemType]
            if #data > 0 then
                firstItemId = data[1]:id()
                break
            end
        end
    else
        firstItemId = self.itemDatas[1]:id()
    end

    return firstItemId
end

-- 获取当前类型道具总数量
function ItemListView:getItemNumByTagType(tagType)
    local itemNum = 0
    local itemType = self:getItemTypeByTagType(tagType) 
    if itemType == self.itemType.ITEM_TYPE_ALL then
        -- for i=1,#self.itemDatas do
        for i=1,#self.itemOrderList do
            local curItemType = self.itemOrderList[i]
            local data = self.itemDatas[curItemType]
            itemNum = itemNum + #data
        end
    else
        itemNum = #self.itemDatas
    end

    return itemNum
end

-- 左侧道具列表动画特效
function ItemListView:doItemLeftAppearAnim()
    local itemLeftWidth = 600

    local panelLeft = self.panel_left

    local x,y = panelLeft:getPosition()
    if self.panelLeftViewX == nil then
        self.panelLeftViewX = x
    end

    -- 出现动画（移动+渐现)
    panelLeft:pos(self.panelLeftViewX - itemLeftWidth,y)
    panelLeft:opacity(0)
    local moveAction = act.moveto(0.3,self.panelLeftViewX,y)
    local alphaAction = act.fadein(0.6)
    local appearAnim = cc.Spawn:create(moveAction,alphaAction) 

    panelLeft:stopAllActions()
    panelLeft:runAction(
        cc.Sequence:create(appearAnim)
    )
end

-- 道具明细出现动画特效
function ItemListView:doItemDetailAppearAnim()
    local detailWidth = 354

    local mcGoods = self.mc_goodxq
    
    local x,y = mcGoods:getPosition()
    if self.detailViewX == nil then
        self.detailViewX = x
    end

    -- 出现动画（移动+渐现)
    mcGoods:pos(self.detailViewX + detailWidth,y)
    mcGoods:opacity(0)

    local moveAction = act.moveto(0.3,self.detailViewX,y)
    local alphaAction = act.fadein(0.6)
    local appearAnim = cc.Spawn:create(moveAction,alphaAction)

    mcGoods:stopAllActions()
    mcGoods:runAction(
        cc.Sequence:create(appearAnim)
    )
end

-- 根据tag类型获取道具数据
function ItemListView:getItemTypeByTagType(tagType)
    local itemType = 0
    if tagType == self.selectTagType.TAG_TYPE_ALL then
        itemType = self.itemType.ITEM_TYPE_ALL
    elseif tagType == self.selectTagType.TAG_TYPE_BOX then
         itemType = self.itemType.ITEM_TYPE_BOX
    elseif tagType == self.selectTagType.TAG_TYPE_PIECE then
        itemType = self.itemType.ITEM_TYPE_PIECE
    elseif tagType == self.selectTagType.TAG_TYPE_MATERIAL then
        itemType = self.itemType.ITEM_TYPE_MATERIAL
    end

    return itemType
end

-- 根据tag类型获取道具数据
function ItemListView:getItemDataByTagType(tagType)
    local itemDatas = {};
    local itemType = self:getItemTypeByTagType(tagType) 

    if itemType == self.itemType.ITEM_TYPE_ALL then
        for i=1,#self.itemOrderList do
            local curItemType = self.itemOrderList[i]
            local curData = ItemsModel:getItemsByType(curItemType)
            itemDatas[curItemType] = curData
        end
    else
        itemDatas = ItemsModel:getItemsByType(itemType)
    end

    return itemDatas
end

-- 隐藏所有页签
function ItemListView:hideAllTag()
    local tagNum = self.tagNum
    local tagPanel = self.tagPanel

    tagPanel:setVisible(false)
    local mcGoods = self.mc_goodxq

    -- 隐藏明细
    mcGoods:setVisible(false)
    -- 显示空空如也
    self.panel_left.mc_beibaonei:showFrame(5)
end

function ItemListView:press_btn_back()
    self:startHide()
end

-- ItemView相关方法----------------------------------------------------------------
function ItemListView:setItemViewData(itemView,itemData)
    local itemId = itemData:id()
    local itemNum = ItemsModel:getFormatItemNum(itemId)

    local data = {
        itemId = itemId,
        itemNum = itemNum,
    }

    itemView:setResItemData(data)
    itemView:setResItemClickEnable(true)

    -- 如果是宝箱类型，显示小红点
    if ItemsModel:isBox(itemId) then
        itemView:showResItemRedPoint(true)
    end

    -- 展示一个itemview
    itemView.showItemView = function(itemView,event)
        local itemId = itemView:getItemData().itemId
        local selectItemId = event.params.itemId

        if tonumber(itemId) == tonumber(selectItemId) then
            self:showSelectAnim(itemView,true)
        else
            self:showSelectAnim(itemView,false)
        end
    end

    EventControler:addEventListener(ItemEvent.ITEMEVENT_SHOW_ITEM_VIEW,itemView.showItemView,itemView);
	itemView:setClickBtnCallback(c_func(self.clickOneItemView,self,itemView,itemId))
end

-- 点击itemView
function ItemListView:clickOneItemView(itemView,itemId)
    echo("clickOneItemView itemId=",itemId)
    if itemView:checkCanClick() then
        if itemId == self.curSelectItemId then
            return
        end

        self.curSelectItemId = itemId

        EventControler:dispatchEvent(ItemEvent.ITEMEVENT_CLICK_ITEM_VIEW,{itemId=itemId});
        EventControler:dispatchEvent(ItemEvent.ITEMEVENT_SHOW_ITEM_VIEW,{itemId=itemId});

        self:playSelectAnim(itemView)
    end
end

-- 是否显示选中动画
function ItemListView:showSelectAnim(itemView,visible)
   if visible then
       self:playSelectAnim(itemView)
   else
       local animCtn = itemView:getAnimationCtn()
       animCtn:setVisible(false)
   end 
end

-- 播放选择动画
function ItemListView:playSelectAnim(itemView)
    local selectAnim = self:getSelectAnim()
    local animCtn = itemView:getAnimationCtn()
    animCtn:setVisible(true)
    selectAnim:parent(animCtn)
end

-- 获取选中特效
function ItemListView:getSelectAnim()
    local itemId = self.curSelectItemId

    local itemData = FuncItem.getItemData(itemId)
    local itemType = itemData.type
    local subType = itemData.subType

    local animName = "UI_common_fang"
    if itemType == self.itemType.ITEM_TYPE_PIECE then
        -- 如果是法宝碎片
        if subType == ItemsModel.itemSubTypes.ITEM_SUBTYPE_201 then
            animName = "UI_common_yuan"
        end
    end

    local anim = self.selectAnimCache[animName]
    if anim == nil then
        anim = self:createUIArmature("UI_common", animName, self._root, false, GameVars.emptyFunc)
        anim:pos(0,-1)
        anim:startPlay(true)
        self.selectAnimCache[animName] = anim
    end

    return anim
end

return ItemListView;
