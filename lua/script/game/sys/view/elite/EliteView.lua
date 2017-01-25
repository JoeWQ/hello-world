local EliteView = class("EliteView", UIBase)

function EliteView:ctor(winName)
	EliteView.super.ctor(self, winName)
end

function EliteView:loadUIComplete()
	--隐藏要复制的对象
    self.mc_1:setVisible(false)
	self:initDefaultViewType()
	self.scroll_list = self.scroll_1
	self:setAlignment()


--	self:adjustScrollList()
	self:setNPCList()
	self:registerEvent()
end

function EliteView:initDefaultViewType()
	self.item_view = self.mc_1
end

function EliteView:setAlignment()
	--设置对齐方式
	FuncCommUI.setViewAlign(self.btn_1, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_1, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.btn_2, UIAlignTypes.LeftTop)
    FuncCommUI.setScale9Align(self.scale9_1,UIAlignTypes.MiddleTop, 1, 0)
end

function EliteView:setNPCList()
    echo("++++++++++++++++shuxin")
	local eliteList = EliteModel:getAllVaildEliteList()
	
	local createFunc = function(record)
		local view = UIBaseDef:cloneOneView(self.item_view)
		self:updateItemUI(view,record)
		return view
	end

	local updateCellFunc = function ( date,view )
        self:updateItemUI(view,date)
	end


	local scroll_param = self:getNpcScrollParam()
	scroll_param.data = eliteList
	scroll_param.updateCellFunc = updateCellFunc
	scroll_param.createFunc = createFunc
	local params = {scroll_param}

	self.scroll_list:styleFill(params)
    local unitNum = EliteModel:getMaxUnlockUnit()
    if unitNum > 2 then
        self.scroll_list:pageEaseMoveTo(unitNum-1,1,0);
    end

end
function EliteView:addTongguanEffect(event)
    local params = event.params
    local view = self.scroll_list:getViewByData(params.data)
    view:showFrame(1)
    local ctn = view.currentView.btn_1:getUpPanel().panel_1.ctn_2
    local anim = self:createUIArmature("UI_common","UI_common_shouqing", ctn, false, GameVars.emptyFunc)
    local panel_pass = view.currentView.btn_1:getUpPanel().panel_1.panel_pass
	FuncArmature.changeBoneDisplay(anim, "layer1",panel_pass )
    panel_pass:pos(0,0)
    panel_pass:setPositionY(panel_pass:getPositionY()+48)
    panel_pass:setPositionX(panel_pass:getPositionX()-52)
end
function EliteView:addUnlockEffect(view,itemData)
        echo("+++++++++++++++++++++EliteView:addUnlockEffect")
        local unLockAni = self:createUIArmature("UI_qiyuan","UI_qiyuan_jiefeng1", nil, true, GameVars.emptyFunc)
        unLockAni:doByLastFrame(true,true,GameVars.emptyFunc)
        view:addChild(unLockAni)
        unLockAni:setPositionX(unLockAni:getPositionX() + 155)
        unLockAni:setPositionY(unLockAni:getPositionY() - 250)
        self:delayCall(function ()
            local _key = UserModel:_id() .. "ELITE_UNLOCK_UNIT"
            LS:pub():set(_key, itemData[1].ascription) 
            self:updateUnlockItemUI(view,itemData)
            view.currentView.btn_1:setTap(c_func(self.onPressNpc, self, itemData))
        end, 0.4)
end
function EliteView:updateUnlockItemUI(view,itemData)
        local data = itemData[1]
        view:showFrame(1)
        local uiInfo = view.currentView.btn_1:getUpPanel().panel_1
        -- 第几章
        uiInfo.mc_1:showFrame(data.ascription) 
        -- 章节名称
        uiInfo.txt_1:setString(GameConfig.getLanguage(data.bigNameTranslate))
        -- 章节详情
        uiInfo.txt_2:setString(GameConfig.getLanguage(data.bigTranslateA))
        uiInfo.txt_3:setString(GameConfig.getLanguage(data.bigTranslateB))
        --奖励列表
        for i = 1,3 do
            local rewardView = uiInfo["UI_"..i]
            local itemData = data.threeRewardA[i]
            rewardView:setResItemData({reward = itemData})
		    rewardView:showResItemName(false)
            rewardView:showResItemNum(false)
        end
        -----npc
        ----
        self:updateItemNpc(uiInfo,itemData[1].npcImg);
end
function EliteView:updatelockItemUI(view,itemData)
        local data = itemData[1]
        view:showFrame(2)
        -- 章节
        local txt2 = view.currentView.btn_1:getUpPanel().panel_1.txt_2
        local strZJ = WorldModel:getChapterNum(data.ascription)
        txt2:setString("第"..strZJ.."章")
        -- 介绍
        local txt3 = view.currentView.btn_1:getUpPanel().panel_1.txt_3
        txt3:setString(GameConfig.getLanguage(data.bigNameTranslate))
end
function EliteView:updateItemUI(view,itemData)
    -- 判断章节是否解锁
    local data = itemData[1]
    local isOpen = EliteModel:isOpenEliteUnitById(data.condition,data,true)
    if isOpen == false then
         self:updatelockItemUI(view,itemData)
    else
        view:showFrame(1)
        local panel_pass = view.currentView.btn_1:getUpPanel().panel_1.panel_pass
        if EliteModel:isTGEliteUnitById(itemData) then --  通关
            panel_pass:setVisible(true)
        else
            panel_pass:setVisible(false)
        end
        if EliteModel:isPlayUnlockUnitEffect() then -- bofang
            -- 判断是否是 播放特效UI
            if EliteModel:getMaxUnlockUnit() == data.ascription then
                self:updatelockItemUI(view,itemData)
                self:delayCall(function ()
                    self:addUnlockEffect(view,itemData)
                end, 0.9)
            else
                self:updateUnlockItemUI(view,itemData);
            end
        else
            self:updateUnlockItemUI(view,itemData);
        end
        
    end

    view.currentView.btn_1:setTap(c_func(self.onPressNpc, self, itemData))
end
-- addNPC
function EliteView:updateItemNpc(view ,npcId)
	    local npcSpine = FuncRes.getArtSpineAni(npcId)
	    npcSpine:gotoAndStop(1)

	    local ctnnpc = view.ctn_1
	    ctnnpc:removeAllChildren()

	    -- local ghostNode = pc.PCNode2Sprite:getInstance():spriteCreate(npcSpine)
	    -- ghostNode:pos(0,0)
	    -- ghostNode:setCascadeOpacityEnabled(true)
	    -- ghostNode:anchor(0,0)
     --    ghostNode:setOpacity(255*0.6)
	  --  ctnnpc:addChild(npcSpine)

        -- 裁切节点

        local clipNode = cc.ClippingNode:create()
        local stencilNode = cc.LayerColor:create(cc.c4b(0, 255, 0, 200), 300, 340);
        clipNode:setStencil(stencilNode)
        clipNode:addChild(npcSpine)
        local  a = clipNode:getPositionX();
        npcSpine:setOpacity(255*0.6)
        npcSpine:setPositionX(npcSpine:getPositionX() + 200)
        clipNode:setPositionX(clipNode:getPositionX() - 100)
        clipNode:setPositionY(clipNode:getPositionY() - 130)
        clipNode:setInverted(false);
        clipNode:anchor(0.5,0.5)
        ctnnpc:addChild(clipNode)

end

function EliteView:adjustScrollList()
	local viewRect = self.scroll_list:getViewRect()
	viewRect.width = viewRect.width + (GameVars.width - GameVars.maxResWidth)
	viewRect.heigt = viewRect.height + (GameVars.height - GameVars.maxResHeight)
	self.scroll_list:updateViewRect(viewRect)
end

function EliteView:getNpcScrollParam()
	
	local data = {}
	data = {
			perNums = 1,
			offsetX = 0,
			offsetY = 0,
			widthGap = 0,
			heightGap = 0 ,
			itemRect = {x=0,y= -507,width = 350,height = 507},
			perFrame=1
	}

	return data
end

function EliteView:registerEvent()
	EliteView.super.registerEvent()
    self.btn_1:setTap(c_func(self.onBtnBackTap, self));
    self.btn_2:setTap(c_func(self.onBtnGuizeTap, self));

    EventControler:addEventListener(EliteEvent.ELITE_UNIT_SHUAXIN,self.setNPCList,self)
    EventControler:addEventListener(EliteEvent.ELITE_UNIT_TONGGUAN,self.addTongguanEffect,self)
	
end

function EliteView:onPressNpc(record)
    if self.scroll_list:isMoving() then
        return
    end
--    self:addTongguanEffect(dataItem)
    -- 判断章节是否解锁
    if EliteModel:isOpenEliteUnitById(record[1].condition,record[1],true) then
    -- 进入 章节详细关卡
        WindowControler:showWindow("EliteDetailsView",record)
    else
    -- 章节还未解锁提示
        WindowControler:showTips("通关"..GameConfig.getLanguage(record[1].bigNameTranslate).."后解锁")

    end

end

-- 规则
function EliteView:onBtnGuizeTap()
	WindowControler:showWindow("EliteHelp")
end

--返回 
function EliteView:onBtnBackTap()
	self:startHide()
end

return EliteView
