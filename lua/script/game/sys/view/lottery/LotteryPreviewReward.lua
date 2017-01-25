local LotteryPreviewReward = class("LotteryPreviewReward", UIBase);

function LotteryPreviewReward:ctor(winName,data)
    LotteryPreviewReward.super.ctor(self, winName);
    self:initData(data)
end

function LotteryPreviewReward:loadUIComplete()
    self:registerEvent();

    FuncCommUI.setViewAlign(self.panel_3,UIAlignTypes.LeftTop) 
    FuncCommUI.setViewAlign(self.btn_close,UIAlignTypes.RightTop) 
    --FuncCommUI.setViewAlign(self.txt_1,UIAlignTypes.MiddleTop) 
    FuncCommUI.setScale9Align(self.scale9_heidai,UIAlignTypes.MiddleTop,1)
    -- FuncCommUI.setScrollAlign(self.scroll_list,UIAlignTypes.Middle,1,1)

    self:initScrollCfg()
    self:updateUI()
end 

function LotteryPreviewReward:registerEvent()
    LotteryPreviewReward.super.registerEvent();
    self.btn_close:setTap(c_func(self.press_btn_close, self));
end

-- 初始化预览数据
function LotteryPreviewReward:initData(data)
    -- echo("初始化预览数据")
    -- dump(data)
    -- echo("初始化预览数据")
    self.lotteryType = data.lotteryType

    -- 令牌抽
    if self.lotteryType == LotteryModel.lotteryType.TYPE_TOKEN then
        self.treasureList = LotteryModel:getTokenLotteryRewardListByType(UserModel.RES_TYPE.TREASURE)
        self.treasurePieceList = LotteryModel:getTokenLotteryRewardListByType(UserModel.RES_TYPE.ITEM)
    -- 钻石抽
    elseif self.lotteryType == LotteryModel.lotteryType.TYPE_GOLD then
        self.treasureList = LotteryModel:getGoldLotteryRewardListByType(UserModel.RES_TYPE.TREASURE)
        self.treasurePieceList = LotteryModel:getGoldLotteryRewardListByType(UserModel.RES_TYPE.ITEM)
    end

    self.maxStar = 5
end

-- 滚动配置
function LotteryPreviewReward:initScrollCfg()
    self.panel_1:setVisible(false)
    self.panel_2:setVisible(false)
    self.panel_fenge:setVisible(false)
    --创建法宝
    local createTreasureItemFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_1)
        self:updateTreasureItem(view,itemData)
        return view
    end

    -- -- 创建法宝背景
    -- local createTreasureBgFunc = function(groupIndex,width,height)
    --     local bgView = UIBaseDef:cloneOneView(self.panel_di)
    --     bgView:pos(0,0)
    --     bgView.scale9_1:setContentSize(cc.size(width,height))

    --     return bgView
    -- end

    --创建法宝碎片
    self.panel_2:setVisible(false)
    local createTreasurePieceItemFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_2)
        self:updateTreasurePieceItem(view,itemData)
        return view
    end
    --创建分割线
    local createSplitLineFunc = function(  itemData )
        local splitLine = UIBaseDef:cloneOneView(self.panel_fenge)
        return splitLine
    end
    -- -- 创建法宝背景
    -- local createTreasurePieceBgFunc = function(groupIndex,width,height)
    --     local bgView = UIBaseDef:cloneOneView(self.panel_di)
    --     bgView:pos(0,-15)
    --     bgView.scale9_1:setContentSize(cc.size(width,height - 15))

    --     return bgView
    -- end


    self.scrollParams = {
        {
            data = self.treasureList,
            createFunc = createTreasureItemFunc,
            --createBgFunc = createTreasureBgFunc,
            perNums = 4,
            offsetX = 30,
            offsetY = 20,
            itemRect = {x=0,y=-200,width=200,height=200},
            widthGap = 10,
            heightGap = 6,
            perFrame = 3,
        },
        {
            data={"0"},
            createFunc=createSplitLineFunc,
            perNums = 1,
            offsetX = 454/2,
            offsetY = 10,
            itemRect = {x=0,y=-39,width=382,height=39},
            widthGap = 10,
            heightGap = 10,
            perFrame = 3,
        },
        {
            data = self.treasurePieceList,
            createFunc = createTreasurePieceItemFunc,
            perNums = 4,
            offsetX = 10,
            offsetY = 20,
            itemRect = {x=0,y=-140,width=200,height=140},
            widthGap = 10,
            heightGap = 6,
            perFrame = 3,
        },

    }
end

function LotteryPreviewReward:updateUI()
    self.scroll_list:enableMarginBluring()
	self.scroll_list:styleFill(self.scrollParams)
end

function LotteryPreviewReward:showTreasureDetail(treasureId)
    if self.scroll_list:isMoving() then
        return
    end
    AudioModel:playSound("s_com_click1")
    --TreasureInfoView
    WindowControler:showWindow("TreasureInfoView",treasureId)
    --WindowControler:showWindow("LotteryTreasureDetail",treasureId)
end

-- 更新法宝
function LotteryPreviewReward:updateTreasureItem(itemView,data)
    local treasureId = data.id
    local treasureName = FuncTreasure.getValueByKeyTD(treasureId,"name")
    treasureName = GameConfig.getLanguage(treasureName)

    -- 法宝Icon
    local treasureIcon = display.newSprite(FuncRes.iconTreasure(treasureId))
    treasureIcon:setScale(1)
    itemView.ctn_1:addChild(treasureIcon)

    -- 法宝名字
    itemView.txt_1:setString(treasureName)
    -- 位置
    local pos = TreasuresModel:getTreasurePosDesc(treasureId)
    itemView.mc_1:showFrame(pos)

    -- 星级
    itemView.mc_xing:showFrame(data.star)

    -- 底座境界
    itemView.mc_3:showFrame(data.state)
    -- 资质
    itemView.mc_zizhi:showFrame(data.quality)

    -- 设置点击事件
    itemView.ctn_1:setTouchedFunc(c_func(self.showTreasureDetail,self,treasureId))
end

-- 更新法宝碎片
function LotteryPreviewReward:updateTreasurePieceItem(itemView,data)
    local treasureId = data.id
    local treasureName = FuncTreasure.getValueByKeyTD(treasureId,"name")
    treasureName = GameConfig.getLanguage(treasureName)

    -- 法宝碎片Icon
    local treasureIcon = display.newSprite(FuncRes.iconTreasure(treasureId))
    treasureIcon:setScale(0.46)
    itemView.ctn_neirong:addChild(treasureIcon)

    -- 法宝名字
    itemView.txt_1:setString(treasureName)

    -- 资质
    itemView.mc_2:showFrame(data.quality)

     -- 设置点击事件
    itemView.ctn_neirong:setTouchedFunc(c_func(self.showTreasureDetail,self,treasureId))
end

-- 关闭
function LotteryPreviewReward:press_btn_close()
    self:startHide()
end


return LotteryPreviewReward;
