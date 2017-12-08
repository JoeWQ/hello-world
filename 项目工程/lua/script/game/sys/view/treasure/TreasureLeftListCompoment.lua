--guan
--2016.6.27
--todo 强化 升星 精炼后的刷新
local TreasureLeftListCompoment = class("TreasureLeftListCompoment", UIBase);

function TreasureLeftListCompoment:ctor(winName, treasure,combine)
    TreasureLeftListCompoment.super.ctor(self, winName);
    self._treasure = treasure;
    self._combine = combine
    if not combine then
        self._treasureId = treasure:getId();
    else
        self._treasureId = treasure.id
    end
    
end

function TreasureLeftListCompoment:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function TreasureLeftListCompoment:registerEvent()
	TreasureLeftListCompoment.super.registerEvent();

    --升星成功
    EventControler:addEventListener(TreasureEvent.PLUS_STAR_SUCCESS_EVENT,
        self.plueStarSuccess, self);

    --强化成功
    EventControler:addEventListener(TreasureEvent.ENHANCE_SUCCESS_EVENT,
        self.enhanceSuccess, self);

    --精炼成功
    EventControler:addEventListener(TreasureEvent.REFINE_SUCCESS_EVENT,
        self.refineSuccess, self);

    --金币增加
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, 
        self.coinChangeCallBack, self);

    --道具变化
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.itemChangeCallBack, self);

    --有新的了
    EventControler:addEventListener(TreasureEvent.TREASUREEVENT_MODEL_NEW, 
        self.newTreasureCallBack, self);
end

function TreasureLeftListCompoment:newTreasureCallBack( ... )
    -- echo("----TreasureLeftListCompoment:newTreasureCallBack---");

    if self._combine then
        self._treasures = CombineControl:checkCombineState();
    else
        self._treasures = TreasuresModel:getAllTreasureWithoutKeyAfterSort();
    end

    self._scrollParams[1].data = self._treasures;

    self.scroll_list:styleFill(self._scrollParams);
end

function TreasureLeftListCompoment:itemChangeCallBack( ... )
    self.scroll_list:refreshCellView(1);

end

function TreasureLeftListCompoment:coinChangeCallBack( ... )
    self.scroll_list:refreshCellView(1);
end

function TreasureLeftListCompoment:refineSuccess()
    echo("--TreasureLeftListCompoment:refineSuccess--");
    --跟新当前选择的法宝cell
    self.scroll_list:refreshCellView(1);
end

function TreasureLeftListCompoment:enhanceSuccess()
    echo("--TreasureLeftListCompoment:enhanceSuccess--");
    --跟新当前选择的法宝cell
    self.scroll_list:refreshCellView(1);
end

function TreasureLeftListCompoment:plueStarSuccess()
    echo("--TreasureLeftListCompoment:plueStarSuccess--");
    --跟新当前选择的法宝cell
    self.scroll_list:refreshCellView(1);
end

function TreasureLeftListCompoment:initUI()
    --得到所有法宝的数据
    if self._combine then
        self._treasures = CombineControl:checkCombineState();
    else
        self._treasures = TreasuresModel:getAllTreasureWithoutKeyAfterSort();
    end
    
    --list
    self.scroll_list = self.panel_liebiao.scroll_list;
    local listCell = self.panel_item;
    listCell:setVisible(false);

    local createRankItemFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(listCell);
        if not self._combine then
            self:updateItem(view, itemData)
        else
            self:updateCombineItem(view, itemData.id)
        end
        
        return view;
    end

    local reuseUpdateCellFunc = function (itemData, view)
        if not self._combine then
            self:updateItem(view, itemData)
        else
            self:updateCombineItem(view, itemData.id)
        end
        return view;  
    end

    self._scrollParams = {
        {
            data = self._treasures,
            createFunc = createRankItemFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = -10,
            itemRect = {x = 0, y = -145, width = 145, height = 145},
            perFrame = 6,
            updateCellFunc = reuseUpdateCellFunc,
        }
    }

    self.scroll_list:styleFill(self._scrollParams);
    self.scroll_list:setScrollSpeed(4)

    local index = nil
    local selectedTreasureId 
    if self._combine then
        selectedTreasureId = tonum(self._treasure.id)
    else
        selectedTreasureId = tonum(self._treasure._data.id)
    end
    for i,v in pairs(self._treasures) do
        local vid
        if self._combine then
            vid = tonum(v.id)
        else
            vid = tonum(v._data.id)
        end


        if vid == selectedTreasureId then
            index = i
            break
        end

    end

    if index then
       self.scroll_list:gotoTargetPos(index, 1)
    end
    
end

function TreasureLeftListCompoment:updateCombineItem(view, treasureId)
    view.panel_1.UI_1.mc_biaoqian:setVisible(false);

    
    --最后一个隐藏下面框
    local lastId = self._treasures[#self._treasures];
    
    if lastId == treasureId then 
        view.panel_pic:setVisible(false);
    else 
        view.panel_pic:setVisible(true);
    end 

    local selectbg = view.scale9_1;
    selectbg:setVisible(false);

    if tonum(treasureId) == tonum(self._treasureId) then 
        self._selectCell = view;
        selectbg:setVisible(true);
    end 

    --什么品
    local quality = FuncTreasure.getValueByKeyTD(treasureId, "quality");
    if quality >= 6 then 
        quality = 5;
    end 
    view.panel_1.UI_1.mc_zizhi:showFrame(quality);

    --法宝图标
    local iconPath = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, treasureId);
    local spriteTreasureIcon = display.newSprite(iconPath); 
    view.panel_1.UI_1.ctn_icon:removeAllChildren();

    spriteTreasureIcon:size(view.panel_1.UI_1.ctn_icon.ctnWidth, 
        view.panel_1.UI_1.ctn_icon.ctnHeight);

    view.panel_1.UI_1.ctn_icon:addChild(spriteTreasureIcon);

    --底盘
    view.panel_1.UI_1.mc_di:showFrame(1);

    --星级
    local star = FuncTreasure.getValueByKeyTD(treasureId, "initStar");
    view.mc_1:showFrame(star);
    --等级
    view.txt_1:setString(1);

    --点击事件
    view:setTouchedFunc(c_func(self.changeSelectCombineCell, self, treasureId, view));

    --红点
    self:cellCombineRedPointInit(view, treasureId);
end
function TreasureLeftListCompoment:cellCombineRedPointInit(view, treasureId)
    --法宝碎片数量
    local num = ItemsModel:getItemNumById(treasureId);
    local _itemInfo = CombineControl:getTeasureItemData(treasureId, num);

    if _itemInfo.isSatisfy == true then 
        view.panel_red:setVisible(true);
    else 
        view.panel_red:setVisible(false);
    end 

end

function TreasureLeftListCompoment:updateItem(view, treasure)
    -- echo("--TreasureLeftListCompoment:updateItem--");
    view.panel_1.UI_1.mc_biaoqian:setVisible(false);

    local last = self._treasures[#self._treasures];
    if last == treasure then 
        view.panel_pic:setVisible(false);
    else 
        view.panel_pic:setVisible(true);
    end 

    local selectbg = view.scale9_1;
    selectbg:setVisible(false);

    local treasureId = treasure:getId();

    if treasureId == self._treasureId then 
        self._selectCell = view;
        selectbg:setVisible(true);
    end 

    --什么品
    local quality = FuncTreasure.getValueByKeyTD(treasureId, "quality");
    if quality >= 6 then 
        quality = 5;
    end 
    view.panel_1.UI_1.mc_zizhi:showFrame(quality);

    --法宝图标
    local iconPath = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, treasureId);
    local spriteTreasureIcon = display.newSprite(iconPath); 
    view.panel_1.UI_1.ctn_icon:removeAllChildren();

    spriteTreasureIcon:size(view.panel_1.UI_1.ctn_icon.ctnWidth, 
        view.panel_1.UI_1.ctn_icon.ctnHeight);

    view.panel_1.UI_1.ctn_icon:addChild(spriteTreasureIcon);
    --底盘
    view.panel_1.UI_1.mc_di:showFrame(treasure:state());
    --星级
    local star = treasure:star();
    view.mc_1:showFrame(star);
    --等级
    view.txt_1:setString(tostring(treasure:level()));
    --点击事件
    view:setTouchedFunc(c_func(self.changeSelectCell, self, treasure, view));
    --红点
    self:cellRedPointInit(treasure, view);
end

function TreasureLeftListCompoment:cellRedPointInit(treasure, view)
    if treasure:canUpStar() == true then 
        view.panel_red:setVisible(true);
    elseif treasure:getStrongType() == Treasure.StrongType.Refine then 
        if treasure:canRefine() == true then 
            view.panel_red:setVisible(true);
        else 
            view.panel_red:setVisible(false);
        end
    elseif treasure:getStrongType() == Treasure.StrongType.Strength then 
        if treasure:canEnhance() == true then 
            view.panel_red:setVisible(true);
        else 
            view.panel_red:setVisible(false);
        end 
    elseif treasure:getStrongType() == Treasure.StrongType.Max then 
        view.panel_red:setVisible(false);
    else 
        echo("---------warning: cellRedPointInit getStrongType wrong type---------",
            tostring(treasure:getId()));
    end 
end

function TreasureLeftListCompoment:changeSelectCombineCell(treasureId, view)

    if self.scroll_list:isMoving() == false then 
        AudioModel:playSound("s_com_click1")
        if self._selectCell then
            self._selectCell.scale9_1:setVisible(false);
        end
        self._selectCell = view;
        self._selectCell.scale9_1:setVisible(true);

        self._treasureId = treasureId;

        local all = CombineControl:checkCombineState();
        local itemData = nil;

        for k, v in pairs(all) do
            -- echo(v.id, self._treasureId, "---");
            if tonumber(v.id) == tonumber(self._treasureId) then 
                itemData = v;
            end 
        end
        --发送切换法宝合成选项的消息
        EventControler:dispatchEvent(CombineEvent.CHANGE_SELECT, 
                {itemData = itemData,id = self._treasureId}); 
        
    end 

end

function TreasureLeftListCompoment:changeSelectCell(treasure, view)
    if self.scroll_list:isMoving() == false then 

        local currentView = WindowControler:getCurrentWindowView()
        local cname = currentView.__cname

        if treasure:isMaxPower() == true and cname ~= "TreasureDetailView" then 
            WindowControler:showTips( { text = "此法宝已圆满" })
        else 
            AudioModel:playSound("s_com_click1")
            self._selectCell.scale9_1:setVisible(false);
            self._selectCell = view;
            self._selectCell.scale9_1:setVisible(true);

            self._treasure = treasure;
            self._treasureId = treasure:getId();

            --发个切换法宝事件
            EventControler:dispatchEvent(TreasureEvent.CHANGE_SELECT, 
                {treasure = self._treasure}); 
            -- self.scroll_list:refreshCellView(1);
        end
    end 
end

return TreasureLeftListCompoment;














