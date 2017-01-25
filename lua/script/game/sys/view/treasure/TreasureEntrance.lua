-- guan 
-- 2016.02.24
-- 2016.6.10 换
require("game.sys.view.treasure.TreasureUICommon");

local TreasureEntrance = class("TreasureEntrance", UIBase);

function TreasureEntrance:ctor(winName, scrollRect)
    TreasureEntrance.super.ctor(self, winName);
    self._scrollRect = scrollRect
end

function TreasureEntrance:loadUIComplete()
    --新和成的法宝
    self._newTreasureIds = {};
    --取排序后的 treasure 
    self:initTreasure();
    self:resolutionAdaptation();

	self:registerEvent();
    self:initUI();
end 

--分辨率适配
function TreasureEntrance:resolutionAdaptation()
    --居左
    FuncCommUI.setViewAlign(self.txt_1, UIAlignTypes.Right);
    FuncCommUI.setViewAlign(self.txt_2, UIAlignTypes.Right);
    FuncCommUI.setViewAlign(self.scroll_list, UIAlignTypes.Left);
    FuncCommUI.setViewAlign(self.ctn_aciton, UIAlignTypes.Left);   
    self:adaptationScrollList();
end

function TreasureEntrance:adaptationScrollList()

    self.scroll_list:updateViewRect(self._scrollRect); 

end

function TreasureEntrance:registerEvent()
    TreasureEntrance.super.registerEvent();

    --精炼成功
    EventControler:addEventListener(TreasureEvent.REFINE_SUCCESS_EVENT,
        self.refineSuccess, self);

    --强化成功
    EventControler:addEventListener(TreasureEvent.ENHANCE_SUCCESS_EVENT,
        self.enhanceSuccess, self);

    --升星成功
    EventControler:addEventListener(TreasureEvent.PLUS_STAR_SUCCESS_EVENT,
        self.upStarSuccess, self);

    --法宝合成，需要重新刷新界面 
    EventControler:addEventListener(TreasureEvent.TREASURE_COMBINE_EVENT,
        self.combineCallBack, self);

    --又被删除的法宝
    EventControler:addEventListener(TreasureEvent.TREASUREEVENT_MODEL_DELETE,
        self.deleteCallBack, self);

    --金币增加
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, 
        self.coinChangeCallBack, self);

    --道具变化
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.itemChangeCallBack, self);

    --有新的了
    EventControler:addEventListener(TreasureEvent.TREASUREEVENT_MODEL_NEW, 
        self.newTreasureCallBack, self);

    EventControler:addEventListener(TreasureEvent.CANCEL_EFFECT_LIUGUANG, 
        self.refreshListview, self);
end
function TreasureEntrance:refreshListview()
    self:refreshListData()
end

function TreasureEntrance:refreshListData()
    if #self._newTreasureIds ~= nil then 
            for k,v in pairs(self._newTreasureIds) do
                if self._newTreasureIds[tonumber(k)] == true then
                    self._newTreasureIds[tonumber(k)] =false
                    local data = TreasuresModel:getTreasureById(tonumber(k))
                    for _k, _v in pairs(self._treasures) do
                        if _v == data then
                            local cellView = self.scroll_list:getViewByData(_v);
                            self:updateItem(cellView, data)
                        end
                    end
                end
            end
        end
end
function TreasureEntrance:coinChangeCallBack(event)
    local changeNum = event.params.coinChange;
    -- echo("----changeNum---", changeNum);
    if changeNum > 0 then 
        self.scroll_list:refreshCellView(1);

        self:allTreasureCellRedPointCheck();
        self:resortList();
    end 
end

function TreasureEntrance:itemChangeCallBack()

    self.scroll_list:refreshCellView(1);

    self:allTreasureCellRedPointCheck();
    self:resortList();
end

function TreasureEntrance:newTreasureCallBack()
    echo("--newTreasureCallBack newTreasureCallBack newTreasureCallBack--");

    self.scroll_list:refreshCellView(1);

    self:allTreasureCellRedPointCheck();
    self:resortList();
end

function TreasureEntrance:initTreasure()
    self._treasures = TreasuresModel:getAllTreasureWithoutKeyAfterSort(true);
end

function TreasureEntrance:initUI()

    self:initList();
    self.UI_tiao:setVisible(false);
end


function TreasureEntrance:initList(treasures)
    local createRankItemFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.UI_tiao);
        self:updateItem(view, itemData)
        return view;
    end

    local reuseUpdateCellFunc = function (itemData, view)
        self:updateItem(view, itemData)
        return view;  
    end

    self.scroll_list:setCanScroll(true);
    self._scrollParams = {
        {
            data = self._treasures,
            createFunc = createRankItemFunc,
            perNums = 3,
            offsetX = 0,
            offsetY = 3,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -203.5, width = 260.05, height = 203.5},
            perFrame = 1,
            updateCellFunc = reuseUpdateCellFunc,
        }
    }

    self.scroll_list:styleFill(self._scrollParams);
    self.scroll_list:setBarBgWay(1);
    self.scroll_list:enableMarginBluring();
end

function TreasureEntrance:resortList()
    self._treasures = TreasuresModel:getAllTreasureWithoutKeyAfterSort(true);
    self:initList();
end

function TreasureEntrance:makeTreasure( ... )
    CombineControl:showWindow();
end

function TreasureEntrance:updateItem(view, treasure)
    local treasureId = treasure:getId();
    local btnView = view;
    view = view.btn_1:getUpPanel().panel_1;

    --名称
    local name = treasure:getName();
    view.txt_1:setString(name);
    --前中后
    local posIndex = treasure:getPosIndex();
    view.mc_1:showFrame(posIndex)

    --隐藏
    view.UI_fb1.mc_biaoqian:setVisible(false);

    view.ctn_glow:removeAllChildren();

    if self._newTreasureIds[treasureId] == true then 
        self:createUIArmature("UI_Combine","UI_Combine_liuguang", 
            view.ctn_glow, true);
        view.panel_xin:setVisible(true);
    else 
        view.panel_xin:setVisible(false);
    end 

    --什么品
    local quality = FuncTreasure.getValueByKeyTD(treasureId, "quality");
    if quality >= 6 then 
        quality = 5;
    end 
    view.UI_fb1.mc_zizhi:showFrame(quality);

    --法宝图标
    local iconPath = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, treasureId);
    local spriteTreasureIcon = display.newSprite(iconPath); 
    view.UI_fb1.ctn_icon:removeAllChildren();

    spriteTreasureIcon:size(view.UI_fb1.ctn_icon.ctnWidth, 
        view.UI_fb1.ctn_icon.ctnHeight);

    view.UI_fb1.ctn_icon:addChild(spriteTreasureIcon);

    --底盘
    view.UI_fb1.mc_di:showFrame(treasure:state());

    --星级
    local star = treasure:star();
    view.mc_xing:showFrame(star);
    --等级
    view.txt_2:setString(tostring(treasure:level()) .. "级");

    self:cellRedPointInit(view, treasure);

    btnView.btn_1:setTap(c_func(self.gotoStrongView, self, treasure, btnView));

end

function TreasureEntrance:gotoStrongView(treasure, view)
    echo("--gotoStrongView--");
    if self.scroll_list:isMoving() == false then 

        --点新的法宝了
        if self._newTreasureIds[treasure:getId()] == true then 
            self._newTreasureIds[treasure:getId()] = nil;
            self:updateItem(view, treasure);
        end 

        TreasuresModel:setTreasureBeforeSort();
        WindowControler:showWindow("TreasureDetailView", treasure);
    end 
end

--强化成功
function TreasureEntrance:enhanceSuccess(data)
    echo("enhanceSuccess");
    
    -- local treasure =  data.params.treasure;
    -- --更新单个treasure
    -- local cellView = self.scroll_list:getViewByData(treasure);
    -- if(cellView~=nil)then
    --     self:updateItem(cellView, treasure, true);
    -- end

    self.scroll_list:refreshCellView(1);

    self:allTreasureCellRedPointCheck();
    self:resortList();
end

--精炼成功
function TreasureEntrance:refineSuccess(data)
    echo("refineSuccess");
    self.scroll_list:refreshCellView(1);
    self:allTreasureCellRedPointCheck();
    self:resortList();
    
end

--升星成功
function TreasureEntrance:upStarSuccess(data)
    echo("------------TreasureEntrance:upStarSuccess------");

    self.scroll_list:refreshCellView(1); 
    self:allTreasureCellRedPointCheck();
    self:resortList();  
end


--合成法宝
function TreasureEntrance:combineCallBack(event)
    echo("---combineCallBack");
    self:resortList();
    -- 新合成的法宝需要特效
    if event.params.item then
        local data = TreasuresModel:getTreasureById(event.params.item.id);
        for k, v in pairs(self._treasures) do
            if v == data then
                self.scroll_list:gotoTargetPos(k,1,1);
                local cellView = self.scroll_list:getViewByData(v);
                self._newTreasureIds[tonumber(event.params.item.id)] = true;
                self:updateItem(cellView, data)
                return
            end
        end
    end
end

--不太好……
function TreasureEntrance:cellRedPointInit( view, treasure)
    --红点
    view.panel_red:setVisible(false);
    if treasure:canUpStar() == true then 
        view.panel_red:setVisible(true);
    elseif treasure:isMaxPower() == true then 
        view.panel_red:setVisible(false);
    elseif treasure:isCurStageMaxLvl() == true then 
        --可否精炼
        if treasure:canRefine() == true then 
            view.panel_red:setVisible(true);
        else 
            view.panel_red:setVisible(false);
        end 
    else
        --可否强化
        if treasure:canEnhance() == true then 
            view.panel_red:setVisible(true);
        else 
            view.panel_red:setVisible(false);
        end 
    end 
end

function TreasureEntrance:allTreasureCellRedPointCheck()
    for k, v in pairs(self._treasures) do
        local cellView = self.scroll_list:getViewByData(v);
        if(cellView~=nil)then
        cellView = cellView.btn_1:getUpPanel().panel_1;
        self:cellRedPointInit(cellView, v);
        end
    end
end

function TreasureEntrance:deleteCallBack()
    echo("----deleteCallBack---");
    self.scroll_list:refreshCellView(1); 
    self:allTreasureCellRedPointCheck();
    self:resortList();  
end

return TreasureEntrance;







