local LotteryShowReward = class("LotteryShowReward", UIBase);

function LotteryShowReward:ctor(winName,data)
    LotteryShowReward.super.ctor(self, winName);
    self.reward = data.reward
    self.lotteryActionType = data.lotteryActionType
    self.lotteryType = data.lotteryType
end

function LotteryShowReward:loadUIComplete()
	self:registerEvent();
    self:initView()
-- 转碎片提醒 默认隐藏
    self.txt_1:setVisible(false)
    
    --隐藏item列表
    self.mc_item:visible(false)


    self.btn_1:setVisible(false)
    self.mc_2:setVisible(false)
    self.mc_xiaohao:setVisible(false)

    self:setOpacity(0)
    self:runAction(cc.Sequence:create(
            cc.FadeIn:create(8/GAMEFRAMERATE),
            cc.CallFunc:create(c_func(self.fadeInCallBack,self))
        ))
    
end 

function LotteryShowReward:fadeInCallBack(  )
    
    self:updateUI()
end

function LotteryShowReward:registerEvent()
	LotteryShowReward.super.registerEvent();
    self.btn_1:setTap(c_func(self.pressClose, self));

    EventControler:addEventListener(LotteryEvent.LOTTERYEVENT_CLOSE_TREASURE_VIEW, self.continueShowReward, self)
end

function LotteryShowReward:initView()

    -- display.addImageAsync(FuncRes.iconBg(windowCfg.bg), function ( ... )
    --        display.newSprite(FuncRes.iconBg(windowCfg.bg), GameVars.UIbgOffsetX, GameVars.UIbgOffsetY):anchor(0,1)
    --                 :addto(uiView,-2);
    --    end);


    FuncCommUI.addBlackBg(self._root)
    --FuncCommUI.setViewAlign(self.mc_1,UIAlignTypes.MiddleTop)

    --加载特效
    -- FuncArmature.loadOneArmatureTexture("UI_common", nil, true)
    -- FuncArmature.loadOneArmatureTexture("UI_lottery", nil, true)
    --FuncArmature.loadOneArmatureTexture
end

function LotteryShowReward:updateUI()
    -- 转碎片提醒 默认隐藏
    self.txt_1:setVisible(false)
    
    --隐藏item列表
    self.mc_item:visible(false)

    --这里要做隐藏操作的,暂时不隐藏
    self:hideItemBeforAnim()
end


function LotteryShowReward:hideItemBeforAnim( )
    --self:hideAllReward()
    self.btn_1:setVisible(false)
    self.mc_2:setVisible(false)
    self.mc_xiaohao:setVisible(false)
    
    FuncCommUI.playSuccessArmature(self.UI_di,FuncCommUI.SUCCESS_TYPE.GET,1)
    self:delayCall(c_func(self.showItemAfterAnim,self),0.2)
end


function LotteryShowReward:showItemAfterAnim(  )
     self:updateStatus()
     self:updateCost()
    -- self:updateRewardList()

    local rewardMc = self.mc_zhanshi
    local rewardNum = #self.reward

    -- 单抽
    if rewardNum == 1 then
        rewardMc:showFrame(1)
    -- 5连抽
    elseif rewardNum == 5 then
        rewardMc:showFrame(2)
    -- 10连抽
    elseif rewardNum == 10 then
        rewardMc:showFrame(3)
    end

    for i=1,rewardNum,1 do
        local ctn = rewardMc.currentView["ctn_"..i]
        --rewardMc.currentView["mc_kuang"..i].currentView["panel_kuang1"]["txt_1"]:setVisible(false)
        --rewardMc.currentView["mc_kuang"..i].currentView["panel_kuang1"][""]
        --local ctn =rewardMc.currentView["mc_kuang"..i].currentView["panel_kuang1"]["ctn_neirong"]
        --UI_lottery_baoshi
        self:createUIArmature("UI_lottery","UI_lottery_baoshi",ctn,true,nil)
    end

    --self:delayCall(c_func(self.updateRewardList,self),0.1)
    self:updateRewardList()
end

--[[
更新列表
]]
function LotteryShowReward:crtItem( rewardInfo,isToPieces )
    local view = UIBaseDef:cloneOneView(self.mc_item)
    --下面要更新view的数据
    local resType = rewardInfo.resType
    local treasureId = rewardInfo.treasureId
    local resNum = rewardInfo.resNum

    local treasureName = FuncTreasure.getValueByKeyTD(treasureId,"name")
    treasureName = GameConfig.getLanguage(treasureName)

    -- 法宝碎片资质
    local quality = FuncTreasure.getValueByKeyTD(treasureId,"quality")
    -- 法宝星级(整法宝显示)
    local star = FuncTreasure.getValueByKeyTD(treasureId,"initStar")

    -- 设置法宝或碎片icon
    local treasureIcon = display.newSprite(FuncRes.iconTreasure(treasureId))



    if tostring(resType) == UserModel.RES_TYPE.TREASURE and not isToPieces then
        echo("法宝------")
        view:showFrame(2)
        local curRewadItem = view.currentView.panel_kuang1
        treasureIcon:setScale(0.61)
        -- 设置法宝星级
        curRewadItem.mc_1:showFrame(star)
        curRewadItem.ctn_neirong:removeAllChildren()
        curRewadItem.ctn_neirong:addChild(treasureIcon)
        treasureIcon:pos(5,0)
        curRewadItem.mc_2:showFrame(quality)
        curRewadItem.txt_1:setString(treasureName)
        curRewadItem.txt_1:setVisible(true)
    else
        echo("碎片-----")
        view:showFrame(1)
        local curRewadItem = view.currentView.panel_kuang1

        treasureIcon:setScale(0.47)
        -- 设置icon
        curRewadItem.ctn_neirong:removeAllChildren()
        treasureIcon:pos(5,0)
        curRewadItem.ctn_neirong:addChild(treasureIcon)
        --treasureIcon:setVisible(false)
        curRewadItem.mc_2:showFrame(quality)
        treasureName = GameConfig.getLanguageWithSwap("tid_lottery_1001",treasureName,resNum)

        curRewadItem.txt_1:setString(treasureName)
        curRewadItem.txt_1:setVisible(true)
    end
    view:pos(0,0)
    return view
end



function LotteryShowReward:hideAllReward()
    local rewardMc = self.mc_zhanshi
    for i=1,10 do
        local mcPanel = rewardMc.currentView["mc_kuang"..i]
        if mcPanel ~= nil then
            mcPanel:setVisible(false)
        end
    end
end

-- 更新奖品列表
function LotteryShowReward:updateRewardList()
    local rewardMc = self.mc_zhanshi
    local rewardNum = #self.reward
    self.delayFrame = 3
    self.rewardIndex = 0
    --self:hideAllReward()
    local delayTime = self.delayFrame / GAMEFRAMERATE
    self:delayCall(c_func(self.showNextReward,self,false), delayTime)
end

function LotteryShowReward:showNextReward(hasShowTreasure)
    if self.rewardIndex >= #self.reward then
        echo("全部展示完毕,要做检测展示出来的东西是不是法宝--进行崩裂")
        self.treausreIndex = 0
        self:chkIsTreasure()
        return
    end

    self.rewardIndex = self.rewardIndex + 1
    local rewardStr = self.reward[self.rewardIndex]
    local rewardArr = string.split(rewardStr,",")

    -- 资源类型
    local resType = rewardArr[1]
    -- 法宝id
    local treasureId = rewardArr[2]
    -- 资源数量
    local resNum = rewardArr[3]

    local rewardInfo = {
        resType = resType,
        treasureId = treasureId,
        resNum = resNum,
        index = self.rewardIndex
    }

    if tostring(rewardInfo.resType) == UserModel.RES_TYPE.TREASURE then
        --如果是法宝就不需要延时一会会有继续的操作
       self:showOneReward(rewardInfo)
       AudioModel:playSound("s_lottery_reward2")
    else
        self:showOneReward(rewardInfo)
        AudioModel:playSound("s_lottery_reward1")
        local delayTime = self.delayFrame / GAMEFRAMERATE
        echo("showNextReward 函数内部-------调用延时操作-----")
        self:delayCall(c_func(self.showNextReward,self,false), delayTime)
    end

    
    
    

end
--[[
检测是不是法宝
]]
function LotteryShowReward:chkIsTreasure()

    local delayTime = 0
    if self.cacheTreasureViewList and #self.cacheTreasureViewList>0 then
        --todo
        delayTime = 30
        for k,v in pairs(self.cacheTreasureViewList) do

            local rewardInfo = v.reward
            local ctnView = v.view
            local oldItemView = v.oldItemView
            local treasureId = rewardInfo.treasureId
            if TreasuresModel:hasTreasureInCache(treasureId) then
                echo("已经有了---------")
                local resNum = TreasuresModel:convertToPieces(treasureId) 
                rewardInfo.resNum = resNum
                --self:setActionBtn(false)
                self:doTxtTipAnim()

                ctnView:removeAllChildren()

                local ani = self:createUIArmature("UI_lottery","UI_lottery_xiaoshi",ctnView,false,GameVars.emptyFunc)
                local oldItem = self:crtItem(rewardInfo)
                oldItem:pos(44,-44)
                local newItem = self:crtItem(rewardInfo,true)
                newItem:pos(44,-44)
                FuncArmature.changeBoneDisplay(ani,"node2",oldItem)
                FuncArmature.changeBoneDisplay(ani,"node3",newItem)
                --FuncArmature.setArmaturePlaySpeed(ani,0.1)
            else
                 TreasuresModel:addTreasureToCache(treasureId)
            end
        end
     end
     self:delayCall(function()
        self.btn_1:setVisible(true)
        self.mc_2:setVisible(true)
        self.mc_xiaohao:setVisible(true)
     end,delayTime/GAMEFRAMERATE)
end


--[[
显示爆破动画

local mcPanel = rewardMc.currentView["mc_kuang"..i]
        if mcPanel ~= nil then
            mcPanel:setVisible(false)
        end


]]
-- function LotteryShowReward:showOneItemAni(rewardInfo)
--     local index = self.rewardIndex
--     local rewardMc = self.mc_zhanshi
--     local curRewadMc = rewardMc.currentView["mc_kuang"..index]
--     -- if curRewadMc ~= nil then
--     --     curRewadMc:setVisible(true)
--     -- end
--     -- local cnt = curRewadMc.currentView["panel_kuang1"]["ctn_neirong"]
--     -- cnt:removeAllChildren()
--     -- self:createUIArmature("UI_lottery","UI_lottery_zhakai",curRewadMc.currentView["panel_kuang1"]["ctn_neirong"],false,c_func(self.rewardBloomCallBack,self,rewardInfo))
--     self:rewardBloomCallBack(rewardInfo)
-- end

--[[
一个奖励爆破完成
]]
-- function LotteryShowReward:rewardBloomCallBack(rewardInfo)
--     echo("爆炸完成")
--     -- 如果是法宝
    

-- end

-- 继续展示奖品
function LotteryShowReward:continueShowReward()
    if self.rewardIndex == nil then
        return
    end

    -- 是否已展示完毕法宝
    if self.rewardIndex <= 0 then
        echoError("LotteryShowReward:continueShowReward self.rewardIndex is ",self.rewardIndex)
    end

    --self:afterShowTreasure(self.rewardIndex)

    -- self.rewardIndex = self.rewardIndex - 1
    echo("LotteryShowReward:continueShowReward----------")
    local delayTime = self.delayFrame / GAMEFRAMERATE
    self:delayCall(c_func(self.showNextReward,self), delayTime)
end

-- 展示一个奖品
function LotteryShowReward:showOneReward(rewardInfo,isToPieces)
  

    local resType = rewardInfo.resType
    -- 法宝id
    local treasureId = rewardInfo.treasureId
    -- 资源数量
    local resNum = rewardInfo.resNum
    local index = rewardInfo.index
    local curView = self.mc_zhanshi.currentView["ctn_"..index]
    curView:removeAllChildren()


    local itemAnim = self:createUIArmature("UI_lottery","UI_lottery_zhakai",curView,false,GameVars.emptyFunc)
    --itemAnim:getBone("node"):setVisible(false)
    local item  = self:crtItem(rewardInfo)
    FuncArmature.changeBoneDisplay(itemAnim,"node",item)
    itemAnim:pos(0,0)
    --itemAnim:startPlay(false)

    -- self:delayCall(function()
    --     treasureIcon:setVisible(true)
    --     curRewadItem.txt_1:setVisible(true)
    -- end,4/GAMEFRAMERATE)
    self:delayCall(function (  )
        --echo("treasureId:",treasureId,"=====")
        if tostring(resType) == UserModel.RES_TYPE.TREASURE  then
            self:cacheTreasureView(rewardInfo,curView,item)
            WindowControler:showWindow("LotteryShowTreasure",treasureId)
        end
    end,15/GAMEFRAMERATE)

    -- 如果是法宝转碎片
    -- if isToPieces then
    --     local pieceAnim = self:createUIArmature("UI_lottery","UI_lottery_xiaoshi",curRewadItem.ctn_1, false, GameVars.emptyFunc)
    --     pieceAnim:pos(0,0)
    --     pieceAnim:setScale(2)
    --     pieceAnim:startPlay(false)

    --     pieceAnim:registerFrameEventCallFunc(pieceAnim.totalFrame, 1, c_func(self.addRedShadeAnim,self,curRewadItem.ctn_2))
    -- end

    -- 法宝底盘特效，如果是法宝，并且不是转碎片
    -- local treasureItemAnim = nil
    -- if tostring(resType) == UserModel.RES_TYPE.TREASURE and not isToPieces then
    --     -- echo("cache treasureId====",treasureId,"index=",index)
    --     -- item 法宝底层光特效
    --     local treasureItemAnim = self:addRedShadeAnim(curRewadItem.ctn_2)
    --     if TreasuresModel:hasTreasureInCache(treasureId) then
    --         self:cacheTreasureView(rewardInfo,treasureItemAnim)
    --     end
    -- else
    --     if tonumber(quality) == 4 or tonumber(quality) == 5 then
    --     -- if tonumber(quality) >=1  then
    --         self:addYellowShadeAnim(curRewadItem.ctn_2)
    --     end
    -- end

    -- local callBack = function()
    --     -- 如果是法宝
    --     if tostring(resType) == UserModel.RES_TYPE.TREASURE then
    --         self:beforeShowTreasure()
    --         WindowControler:showWindow("LotteryShowTreasure",treasureId)
    --     end
    -- end

    -- if not isToPieces then
    --     -- 如果是最后一个奖品，显示操作按钮
    --     if rewardInfo.index == #self.reward then
    --         -- self:setActionBtn(true)
    --         -- 如果最后一个不是法宝，开始做转碎片逻辑
    --         -- 如果最后一个是法宝，在afterShowTreasure中做转碎片逻辑
    --         if tostring(resType) ~= UserModel.RES_TYPE.TREASURE then
    --             self:delayDoTreasureToPieces()
    --         end
    --     end

    --     FuncCommUI.playLotteryRewardItemAnim(curRewadMc,0.4,callBack)
    -- end
end

-- 关闭整法宝界面后
function LotteryShowReward:afterShowTreasure(itemIndex)
     self.mc_zhanshi:setVisible(true)
     if itemIndex == #self.reward then
        -- self:setActionBtn(true)
        self:delayDoTreasureToPieces()
     end
end
--清楚所有动画和内容
function LotteryShowReward:resetRewardItemMc(rewardItemMc)
    for i=1,2 do
        rewardItemMc:showFrame(i)
        rewardItemMc.currentView.panel_kuang1.ctn_1:removeAllChildren()
        rewardItemMc.currentView.panel_kuang1.ctn_2:removeAllChildren()
        rewardItemMc.currentView.panel_kuang1.ctn_neirong:removeAllChildren()
    end
end

-- function LotteryShowReward:addYellowShadeAnim(ctn)
--     ctn:removeAllChildren()
--     local treasurePieceItemAnim = self:createUIArmature("UI_lottery","UI_lottery_huangse",ctn, false, GameVars.emptyFunc)
--     treasurePieceItemAnim:pos(0,0)
--     treasurePieceItemAnim:setScale(1.5)
--     treasurePieceItemAnim:startPlay(true)

--     return treasureItemAnim
-- end

-- function LotteryShowReward:addRedShadeAnim(ctn)
--     ctn:removeAllChildren()
--     local treasureItemAnim = self:createUIArmature("UI_lottery","UI_lottery_hongse",ctn, false, GameVars.emptyFunc)
--     treasureItemAnim:pos(0,0)
--     treasureItemAnim:setScale(2)
--     treasureItemAnim:startPlay(true)

--     return treasureItemAnim
-- end

-- 缓存法宝view
function LotteryShowReward:cacheTreasureView(rewardInfo,treasureView,oldItemView)
    if self.cacheTreasureViewList == nil then
        self.cacheTreasureViewList = {}
    end

    local treasureInfo = {}
    treasureInfo.reward = rewardInfo
    treasureInfo.view = treasureView
    treasureInfo.oldItemView = oldItemView

    table.insert(self.cacheTreasureViewList, treasureInfo)
end

function LotteryShowReward:delayDoTreasureToPieces()
    local toPiecesCallBack = function()
        self:setActionBtn(true)
    end
    -- 加入转碎片逻辑
    self:delayCall(c_func(self.doTreasureToPieces,self,toPiecesCallBack), 0.2)
end

-- 执行法宝转碎片逻辑
function LotteryShowReward:doTreasureToPieces(callBackFunc)
    if self.cacheTreasureViewList == nil or #self.cacheTreasureViewList == 0 then 
        if callBackFunc then
            callBackFunc()
        end                
        return
    end

    for i=1,#self.cacheTreasureViewList do
        local treasureInfo = self.cacheTreasureViewList[i]
        local rewardInfo = treasureInfo.reward
        local anim = treasureInfo.anim

        local treasureId = rewardInfo.treasureId

        if TreasuresModel:hasTreasureInCache(treasureId) then
            local resNum = TreasuresModel:convertToPieces(treasureId) 
            rewardInfo.resNum = resNum

            self:setActionBtn(false)
            self:doTxtTipAnim()
            -- 隐藏原特效
            anim:setVisible(false)
                       
            self:showOneReward(rewardInfo,true)
        end
    end

    local callBack = function(data) 
        self.cacheTreasureViewList = nil
        if callBackFunc then
            callBackFunc()
        end
    end

    self:delayCall(c_func(callBack), 2.5)
end

function LotteryShowReward:setActionBtn(visible)
    self.btn_1:setVisible(visible)
    self.mc_2:setVisible(visible)
    self.mc_xiaohao:setVisible(visible)
end

-- 转碎片文本动画
function LotteryShowReward:doTxtTipAnim()
    self.txt_1:setVisible(true)
    self.txt_1:opacity(0)
    local alphaAction = act.fadein(0.5)
    self.txt_1:stopAllActions()
    self.txt_1:runAction(
        alphaAction
    )
end

-- 打开整法宝界面前
function LotteryShowReward:beforeShowTreasure()
     self.mc_zhanshi:setVisible(false)

     self.btn_1:setVisible(false)
     self.mc_2:setVisible(false)

     self.mc_xiaohao:setVisible(false)
     self.txt_1:setVisible(false)
end

-- 更新消耗的显示
function LotteryShowReward:updateCost()
    -- 令牌消耗
    if self.lotteryType == LotteryModel.lotteryType.TYPE_TOKEN then
        local cost = 1
        self.mc_xiaohao:showFrame(1)

        local userToken = UserModel:getToken()
        if self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_TOKEN_FREE  
            or self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_TOKEN_ONE then
            self.mc_xiaohao.currentView.txt_1:setString(userToken.."/"..cost)
        elseif self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_TOKEN_FIVE  then
            cost = 5
            self.mc_xiaohao.currentView.txt_1:setString(userToken.."/"..cost)
        end
    else
        self.mc_xiaohao:showFrame(2)
        if self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_GOLD_FREE  
            or self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_GOLD_ONE then
            cost = LotteryModel:getGoldLotteryOneCost()
        elseif self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_GOLD_TEN  then
            cost = LotteryModel:getGoldLotteryTenCost()
        end

        self.mc_xiaohao.currentView.txt_1:setString(cost)
    end
end

-- 更新再来N次按钮的状态
function LotteryShowReward:updateStatus()
    local againMc = self.mc_2
    -- 从免费过来的
    if self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_TOKEN_FREE         --免费铜牌抽卡
        or self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_TOKEN_ONE      --铜牌抽卡
        or self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_GOLD_FREE      --钻石免费抽卡
        or self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_GOLD_ONE then   --钻石抽卡
        againMc:showFrame(1)
    elseif self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_TOKEN_FIVE then  --铜牌抽卡5次
        againMc:showFrame(2)
    elseif self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_GOLD_TEN then     --钻石抽卡十次
        againMc:showFrame(3)
    end

    againMc.currentView.btn_1:setTap(c_func(self.doLotteryAgain, self))

    local tipMc = self.mc_1
    if self.lotteryType == LotteryModel.lotteryType.TYPE_TOKEN then
        tipMc:showFrame(1)
    else
        tipMc:showFrame(2)
    end
end

-- 抽卡结束回调
function LotteryShowReward:lotteryCallBack(data)
    if data.result then
        -- local callBack = function()
        --     self.reward = data.result.data.reward
        --     self:updateUI()
        -- end

        self:startHide()

        local params = {
            reward = data.result.data.reward,
            lotteryActionType = self.lotteryActionType,
            lotteryType = self.lotteryType
        }

        EventControler:dispatchEvent(LotteryEvent.LOTTERYEVENT_DO_LOTTERY_AGAIN_SUCCESS,{data = params})
    end
end

function LotteryShowReward:doLotteryAgain()
    -- local callBack = function()
    --     self:doLotteryAgainAction()
    -- end
    -- self:doTreasureToPieces(callBack)

    self:doLotteryAgainAction()
end

-- 再次抽奖
function LotteryShowReward:doLotteryAgainAction()
    -- 从免费过来的
    if self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_TOKEN_FREE then
        local times = 1
        if LotteryModel:isTokenEnough(times) then
            LotteryServer:doTokenLottery(times,c_func(self.lotteryCallBack,self))
        else
            WindowControler:showTips("令牌不足")
            return
        end
    -- 如果此时刚好免费的cd结束了呢？
    elseif self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_TOKEN_ONE then
        local times = 1
        if LotteryModel:isTokenEnough(times) then
            LotteryServer:doTokenLottery(times,c_func(self.lotteryCallBack,self))
        else
            WindowControler:showTips("令牌不足")
            return
        end
    elseif self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_TOKEN_FIVE then
        local times = 5
        if LotteryModel:isTokenEnough(times) then
            LotteryServer:doTokenLottery(times,c_func(self.lotteryCallBack,self))
        else
            WindowControler:showTips("令牌不足")
            return
        end

    -- 免费过来的
    elseif self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_GOLD_FREE then
        local times = 1
        if LotteryModel:isGoldEnough(times) then
            -- 钻石单抽
            LotteryServer:doGoldOneLottery(c_func(self.lotteryCallBack,self))
        else
            --WindowControler:showTips(GameConfig.getLanguage("tid_buy_jump_gold_1004"));
            WindowControler:showWindow("RechargeMainView")
            return
        end
    elseif self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_GOLD_ONE then
        local times = 1
        if LotteryModel:isGoldEnough(times) then
            -- 钻石单抽
            LotteryServer:doGoldOneLottery(c_func(self.lotteryCallBack,self))
        else
            --WindowControler:showTips(GameConfig.getLanguage("tid_buy_jump_gold_1004"));
            WindowControler:showWindow("RechargeMainView")
            return
        end
    elseif self.lotteryActionType == LotteryModel.lotteryActionType.TYPE_GOLD_TEN then
        local times = 10
        if LotteryModel:isGoldEnough(times) then
            -- 钻石十连抽
            LotteryServer:doGoldTenLottery(c_func(self.lotteryCallBack,self))
        else
            --WindowControler:showTips(GameConfig.getLanguage("tid_buy_jump_gold_1004"));
            WindowControler:showWindow("RechargeMainView")
            return
        end
    end
end

function LotteryShowReward:pressClose()
    -- local callBack = function()
    --     self:closeTreasureView()
    -- end
    -- self:doTreasureToPieces(callBack)

    self:closeTreasureView()
end

function LotteryShowReward:closeTreasureView()
    self:startHide()
    EventControler:dispatchEvent(LotteryEvent.LOTTERYEVENT_CLOSE_REWARD_VIEW)
end

return LotteryShowReward;
