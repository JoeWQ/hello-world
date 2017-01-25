local EliteDetailsView = class("EliteDetailsView", UIBase)

function EliteDetailsView:ctor(winName,data,_type)
	EliteDetailsView.super.ctor(self, winName)
    if _type == "GETWAY" then
        self.getWayData = data
        self.data = EliteModel:getGetWayData(data)
        dump(self.data,"获取途径")
    else
        self.data = data
    end
    self.isGetWay = _type
    self.selectItemData = nil
    self.exchangeType = 0 
    self.btnTyp = nil; -- 0 兑换 1 挑战
    self.lastView = nil;
end

function EliteDetailsView:loadUIComplete()
    --FuncArmature.loadOneArmatureTexture("UI_qiyuan", nil, true)
	--隐藏要复制的对象
    self.btn_item:getUpPanel().panel_jiang:setVisible(false)
	self:initDefaultViewType()
	self.scroll_my_list = self.scroll_1
	self:setAlignment()


--	self:adjustScrollList()
	self:setScrollList()
	self:registerEvent()
-----npc
    self:addNpc()    
end
-- addNPC
function EliteDetailsView:addNpc()
    
--    self.data[1].npcImg
	    local npcSpine = FuncRes.getArtSpineAni(self.data[1].npcImg)
	    npcSpine:gotoAndStop(1)

	    local ctnnpc = self.ctn_1
	    ctnnpc:removeAllChildren()
        ctnnpc:setPositionY(ctnnpc:getPositionY() -188)
        npcSpine:setOpacity(255*0.2)
--	    local ghostNode = pc.PCNode2Sprite:getInstance():spriteCreate(npcSpine)
--	    ghostNode:pos(0,0)
--	    ghostNode:setCascadeOpacityEnabled(true)
--	    ghostNode:anchor(0,0)
--        ghostNode:setOpacity(255*0.2)
--	    ctnnpc:addChild(ghostNode)

         -- 裁切节点
        local clipNode = cc.ClippingNode:create()
        local stencilNode = cc.LayerColor:create(cc.c4b(0, 255, 0, 200), 500, 340);
        clipNode:setStencil(stencilNode)
        clipNode:addChild(npcSpine)
        local  a = clipNode:getPositionX();
        npcSpine:setPositionX(npcSpine:getPositionX() + 150)
--        clipNode:setPositionY(clipNode:getPositionY() - 150)
        clipNode:setInverted(false);
        clipNode:anchor(0.5,0.5)
        ctnnpc:addChild(clipNode)
end


function EliteDetailsView:initDefaultViewType()
	self.item_view = self.btn_item
end

function EliteDetailsView:setAlignment()
	--设置对齐方式
	FuncCommUI.setViewAlign(self.btn_1, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_1, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.btn_2, UIAlignTypes.LeftTop)
    FuncCommUI.setScale9Align(self.scale9_1,UIAlignTypes.MiddleTop, 1, 0)
end

function EliteDetailsView:setScrollList()
	
	local createFunc = function(record)
		local view = UIBaseDef:cloneOneView(self.item_view)
		self:updateItemUI(view,record)
		return view
	end

	local updateCellFunc = function ( date,view )
        self:updateItemUI(view,date)
	end

    local onCreateCompFunc = function ( )
        if self.btnTyp == 1 then  -- 挑战 
            self:initXiaoguanPos()
        elseif self.btnTyp == 0 then
            self:updateItemDetailsUI(self.selectItemData)
            self.scroll_my_list:gotoTargetPos(EliteModel:getIndexByDataInUnits(self.data,self.selectItemData),1,1);  
        else
            if self.isGetWay == "GETWAY" then
                self:initGetWayXiaoguanPos()
            else
                self:initXiaoguanPos()
            end
            
        end 
	end

	local scroll_param = self:getNpcScrollParam()
	scroll_param.data = self.data
	scroll_param.updateCellFunc = updateCellFunc
	scroll_param.createFunc = createFunc
	local params = {scroll_param}



    self.scroll_my_list:setScrollPage(1, 30, 1,{scale = 0.5,wave = 0.6},c_func(self.scrollMoveEndCallBack, self))
    self.scroll_my_list:styleFill(params)
    self.scroll_my_list:hideDragBar()
    self.scroll_my_list:onScroll(c_func(self.onMyListScroll, self))
    self.scroll_my_list.onCreateCompFunc = onCreateCompFunc

    if self.btnTyp == 0 then  --兑换 不跳转
        self:updateItemDetailsUI(self.selectItemData)
        self.scroll_my_list:gotoTargetPos(EliteModel:getIndexByDataInUnits(self.data,self.selectItemData),1,1);
    else
        local data,index = EliteModel:initXiaoguanByData(self.data,self.isGetWay,self.getWayData)
        self.selectItemData = data
        self:updateItemDetailsUI(self.selectItemData)
    end
end

function EliteDetailsView:onMyListScroll(event)

	if event.name == self.scroll_my_list.EVENT_SCROLLEND then 
		local group, index = self.scroll_my_list:getGroupPos(1)
        self:scrollMoveEndCallBack(index,group)
	end
end
function EliteDetailsView:initGetWayXiaoguanPos(time)
        local _time = time or 0.2
        local data = self.data[tonumber(self.getWayData[2])]

        self.selectItemData = data
        self.selectItemIndex = tonumber(self.getWayData[2])
        self.scroll_my_list:pageEaseMoveTo(tonumber(self.getWayData[2]),1,_time);    
        self:updateItemDetailsUI(self.selectItemData)
end
function EliteDetailsView:initXiaoguanPos(time)
        echo("!!!!!!!!!!!!!!!!!!!!!!!!initXiaoguanPos")
        local _time = time or 0.2
        local data,index = EliteModel:initXiaoguanByData(self.data)
        if Cache:get("QiYuanDuiHuanBtnType",nil) == 1 then
            if EliteModel:isTGEliteUnitById(self.data) then
               Cache:set("QiYuanDuiHuanBtnType",nil)
               -- 发 播放通关动画的消息
               EventControler:dispatchEvent(EliteEvent.ELITE_UNIT_TONGGUAN,{data = self.data})
--               EventControler:dispatchEvent(EliteEvent.ELITE_UNIT_SHUAXIN)
               -- 关闭本UI
               self:startHide()
            else
                echo("!!!!!!!!!!!!!!!!!!!!!!!!QiYuanDuiHuanBtnType")
                index = index - 1
                data = self.data[index]
            end
            
            
        end
        self.selectItemData = data
        self.selectItemIndex = index
        self.scroll_my_list:pageEaseMoveTo(index,1,_time);    
        self:updateItemDetailsUI(self.selectItemData)
end

-- 添加 解锁特效
function EliteDetailsView:addUnlockEffect(view)
    if view:getChildByTag(1111) then
        view:removeChildByTag(1111)
    end
    if self.lastView then
       if self.lastView:getChildByTag(1111) then
           self.lastView:removeChildByTag(1111)
       end
    end
    local unLockAni = self:createUIArmature("UI_qiyuan","UI_qiyuan_jiefeng2", nil, false, GameVars.emptyFunc)
    unLockAni:doByLastFrame(false,false,GameVars.emptyFunc)
    unLockAni:setPositionY(unLockAni:getPositionY()-20)
    view:addChild(unLockAni)
    self.lastView = view
    unLockAni:setTag(1111)
end

-- 添加选中特效
function EliteDetailsView:addSelectedEffect(view)
    if view:getChildByTag(1111) then
        view:removeChildByTag(1111)
    end
    if self.lastView then
       if self.lastView:getChildByTag(1111) then
           self.lastView:removeChildByTag(1111)
       end
    end
    local selectAni = self:createUIArmature("UI_qiyuan","UI_qiyuan_xuanzhong", nil, false, GameVars.emptyFunc)
    selectAni:doByLastFrame(false,false,GameVars.emptyFunc)
    view:addChild(selectAni)
    self.lastView = view
    selectAni:setTag(1111)
    
end

-- 滑动停止的回调
function EliteDetailsView:scrollMoveEndCallBack(itemIndex,groupIndex)
    echo("+++++++++++++++++++++++itemIndex"..itemIndex);
    local record = self.data[itemIndex]
    if record then
        if EliteModel:isOpenXiaoGuanByCondition(record.condition,record) then
            echo("scrollMoveEndCallBack &&&&&&&&&&&&&&&&=="..itemIndex)
            echo("scrollMoveEndCallBack &&&&&&&&&&&&&&&&=="..record.id)
            self:updateItemDetailsUI(record)
--            self.selectItemData = record
        else
            echo("需通关前置关卡 &&&&&&&&&&&&&&&&=="..itemIndex)
            self:delayCall(c_func(self.initXiaoguanPos,self,0.3), 0.1)
            WindowControler:showTips("需通关前置关卡")
        end

        if  EliteModel:isOpenXiaoGuanByCondition(record.condition,record) then
            local view = self.scroll_my_list:getViewByData(record)
            if self.lastView ~= view then
                if view then
                    if Cache:get("QiYuanDuiHuanBtnType",nil) == 1 then
                        echo("+++++++++++++++++++++++addSelectedEffect"..itemIndex);
                        self:addSelectedEffect(view)
                        -- 移动到挑战
                        Cache:set("QiYuanDuiHuanBtnType",nil)
                        local tempFunc = function (  )
                            local data,index = EliteModel:initXiaoguanByData(self.data)
                            echo("添加 解锁特效的index"..index)
                            local _view = self.scroll_my_list:getViewByData(data)
                            self.willAddUnlock = 1
                            self.scroll_my_list:pageEaseMoveTo(index,1,0.2);    
                            self:delayCall(function()
                                self.willAddUnlock = nil
                                self:addUnlockEffect(_view)
                                self:delayCall(function()
                                    self:updateItemUI(_view,data)
                                end,0.7) --item 刷新时间 间隔
                            end,0.3)   
                        end
                        self:delayCall(tempFunc,0.5)
                    else
                        if self.willAddUnlock == 1 then
                           return
                        end
                        self:addSelectedEffect(view)
                    end 
                end
            end
        end
    end
    
end

function EliteDetailsView:updateItemUI(view,record)
    -- 判断是否解锁
    local viewInfo = view:getUpPanel().panel_jiang
    if EliteModel:isOpenXiaoGuanByCondition(record.condition,record) then
        local zhdata,index = EliteModel:initXiaoguanByData(self.data)
        if Cache:get("QiYuanDuiHuanBtnType",nil) == 1 and zhdata == record then
             FilterTools.setGrayFilter(view);
             viewInfo.mc_1:showFrame(4)
             return
        end
         FilterTools.clearFilter( view );
        -- 小关卡 已解锁
        local str = record.exhibitionA[1]
        local strArr = string.split(str,",")      
        if strArr[1] == UserModel.RES_TYPE.ITEM then --道具
            viewInfo.mc_1:showFrame(2)
            viewInfo.mc_1.currentView.mc_1:showFrame(1)
            viewInfo.mc_1.currentView.mc_1.currentView.ctn_1:addChild(display.newSprite(FuncRes.iconRes(strArr[1], strArr[2]))) 
        elseif strArr[1] == UserModel.RES_TYPE.TREASURE  then
            viewInfo.mc_1:showFrame(1)
            viewInfo.mc_1.currentView.ctn_1:addChild(display.newSprite(FuncRes.iconRes(strArr[1], strArr[2])))
        else                                 --人物头像
            viewInfo.mc_1:showFrame(3)
        end

        view:setTap(c_func(self.onPressNpc, self, record))
    else
         FilterTools.setGrayFilter(view);
        viewInfo.mc_1:showFrame(4)
    end
end

function EliteDetailsView:updateItemDetailsUI(record)
    self.selectItemData = record
    self.selectItemIndex = EliteModel:getIndexInArrByData(self.data,record) or 1

    self.mc_1:showFrame(record.ascription)
    self.txt_1:setString(GameConfig.getLanguage(record.smallNameTranslate))
    self.txt_2:setString(GameConfig.getLanguage(record.desTranslate))
     -- 判断是否挑战 hasChangeFinish
     self.UI_1:setVisible(false)
     if not EliteModel:hasChangeFinish(record) then
         self.mc_6:showFrame(1)
         self.mc_3:showFrame(1)
         self.mc_2:showFrame(1)
         self.mc_2.currentView.btn_1:setTap(c_func(function ()
            self:tiaozhanTap(record)
         end, self))
         --奖励列表
         for i = 1,4 do
            local ui_item = self["UI_"..(i+1)]
            local ui_data = record.rewardA[i]
            if ui_data then
                echo("奖励类型 ========== ".. ui_data)
                ui_item:setResItemData({reward = ui_data})
                ui_item:showResItemName(false)
--                ui_item:updateItemUI()
                ui_item:setVisible(true)
              --注册点击事件 弹框
                local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(ui_data)
                FuncCommUI.regesitShowResView(ui_item, resType, needNum, resId,ui_data,true,true)
            else    
                ui_item:setVisible(false)
            end
            
         end
         
         
     else -- 兑换
         self.mc_6:showFrame(2)
         self.mc_3:showFrame(2)
         -- 剩余兑换次数
         local leftNum = EliteModel:getExchangeNumsById(record.id)
         self.mc_2:showFrame(2)
         -- 兑换次数为 0 时
         self:isShowDuihuanBtn(leftNum)
         

         self.mc_2.currentView.txt_1:setString(tostring(record.consume2))
         self.mc_2.currentView.btn_duihuan:setTap(c_func(function ()
              self:exchangeTap(record,0)
         end, self))
         local str = leftNum .. "/" .. EliteModel:getExchangeAllNums()
         self.mc_3.currentView.txt_4:setString(str)
         

         -- 奖励展示
         for i = 1,4 do
            local ui_item = self["UI_"..(i+1)]
            local ui_data = record.exhibitionB[i]
            if ui_data then
                echo("兑换类型 ========== ".. ui_data)
                ui_item:setResItemData({reward = ui_data})
                ui_item:showResItemName(false)
--                ui_item:updateItemUI()
                ui_item:setVisible(true)
              --注册点击事件 弹框
                local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(ui_data)
                FuncCommUI.regesitShowResView(ui_item, resType, needNum, resId,ui_data,true,true)
            else    
                ui_item:setVisible(false)
            end
         end


         if EliteModel:isYJDH() then
             -- 消耗sp
             local costSp = EliteModel:getxiaohaotiliNumById(record,1)
             self:isShowDuihuanBtnBySP(costSp)
             self.mc_2.currentView.txt_2:setString(tostring(EliteModel:getxiaohaotiliNumById(record,1)))
             self.mc_2.currentView.btn_yijian:setTap(c_func(function ()
                self:exchangeTap(record,1)
             end, self))
         else
             -- 隐藏一键兑换
             self.mc_2.currentView.btn_yijian:setVisible(false)
             self.mc_2.currentView.panel_2:setVisible(false)
             self.mc_2.currentView.txt_2:setVisible(false)
         end
         
     end
end
-- 钱不足置灰
function EliteDetailsView:isShowDuihuanBtnBySP(isShow)
         if isShow>0 then
             FilterTools.clearFilter( self.mc_2.currentView.btn_yijian );
             self.mc_2.currentView.txt_2:setVisible(true)
             self.mc_2.currentView.panel_2:setVisible(true)
             FilterTools.clearFilter( self.mc_2.currentView.btn_duihuan );
             self.mc_2.currentView.txt_1:setVisible(true)
             self.mc_2.currentView.panel_1:setVisible(true)
         else
            FilterTools.setGrayFilter( self.mc_2.currentView.btn_yijian );
            self.mc_2.currentView.txt_2:setVisible(false)
            self.mc_2.currentView.panel_2:setVisible(false)
            FilterTools.setGrayFilter( self.mc_2.currentView.btn_duihuan );
            self.mc_2.currentView.txt_1:setVisible(false)
            self.mc_2.currentView.panel_1:setVisible(false)

         end
         
end
-- 兑换按钮置灰
function EliteDetailsView:isShowDuihuanBtn(isShow)
          if isShow>0 then
             FilterTools.clearFilter( self.mc_2.currentView.btn_duihuan );
             FilterTools.clearFilter( self.mc_2.currentView.btn_yijian );
             self.mc_2.currentView.txt_1:setVisible(true)
             self.mc_2.currentView.panel_1:setVisible(true)
             self.mc_2.currentView.txt_2:setVisible(true)
             self.mc_2.currentView.panel_2:setVisible(true)
         else
            FilterTools.setGrayFilter(self.mc_2.currentView.btn_duihuan);
            FilterTools.setGrayFilter( self.mc_2.currentView.btn_yijian );
            self.mc_2.currentView.txt_1:setVisible(false)
            self.mc_2.currentView.panel_1:setVisible(false)
            self.mc_2.currentView.txt_2:setVisible(false)
            self.mc_2.currentView.panel_2:setVisible(false)
         end
end
--
function EliteDetailsView:tiaozhanTap(data)
    WindowControler:showTips("功能还未开启")
    
--    local hasSp = UserExtModel:sp()
--    local costSp = data.consume1
--    if hasSp>= costSp then -- 判断体力
--            self.btnTyp = 1
--            EliteServer:challenge(data.id,c_func(self.changeWenqingCallBack,self))
--    else
--            WindowControler:showWindow("CompBuySpMainView");
--    end
end

--兑换tap
function EliteDetailsView:exchangeTap(record,_all)
    --添加判断体力的条件
    if EliteModel:getExchangeNumsById(record.id) > 0  then
        if EliteModel:isTiliSatisfy(record,_all) then -- 判断体力
            self.btnTyp = 0
            EliteServer:exchange(record.id,_all,c_func(self.exchangeCallBack,self))
            self.exchangeType = _all
        else
            WindowControler:showWindow("CompBuySpMainView");
        end
    else
        if EliteModel:isVipManji() then -- 判断是否 vip满级
            WindowControler:showTips("兑换次数不足")
        else
            WindowControler:showWindow("EliteTipsView");
        end
        
    end
end
--兑换callback 
function EliteDetailsView:exchangeCallBack(event)
    --如果请求失败 
	if not event.result then
		return
	end
    local reward = event.result.data.reward;
    dump(reward)
    
    local rewardArr = {}
    for i,v in pairs(reward)  do
       table.insert(rewardArr,v)
    end
    EliteModel:duihuanHuidian(self.selectItemData.id, self.exchangeType)

    if self.exchangeType == 1 then --一键兑换奖励
        WindowControler:showWindow("EliteYJDHRewardView",rewardArr);
    else
        FuncCommUI.startFullScreenRewardView(reward[1], nil);
    end
    --WindowControler:showWindow("EliteYJDHRewardView",rewardArr);
    self:setScrollList()
    
end

--挑战问情
-- 开始GVE战斗
function EliteDetailsView:changeWenqingCallBack(event)
    if event.result ~= nil then
        echo("world gve 进入成功 levelId=",self.level)
        -- 缓存用户数据
        UserModel:cacheUserData()

        -- 设置关卡ID
        BattleControler:setLevelId(self.selectItemData.level,2);

    else
        echo("world gve 进入失败")
    end
end


function EliteDetailsView:adjustScrollList()
	local viewRect = self.scroll_my_list:getViewRect()
	viewRect.width = viewRect.width + (GameVars.width - GameVars.maxResWidth)
	viewRect.heigt = viewRect.height + (GameVars.height - GameVars.maxResHeight)
	self.scroll_my_list:updateViewRect(viewRect)
end

function EliteDetailsView:getNpcScrollParam()
	local data = {
			perNums = 1,
			offsetX = 0,
			offsetY = 0,
			widthGap = 0,
			heightGap = 0 ,
			itemRect = {x=-106,y= -125,width = 219,height = 233},
			perFrame=1
	}

	return data
end

function EliteDetailsView:registerEvent()
	EliteDetailsView.super.registerEvent()
    self.btn_1:setTap(c_func(self.onBtnBackTap, self));
    self.btn_2:setTap(c_func(self.onBtnGuizeTap, self));
    EventControler:addEventListener(EliteEvent.ELITE_CHALLENGE_SUCCEED,self.setScrollList,self)
	EventControler:addEventListener(UserEvent.USEREVENT_VIP_CHANGE,self.tiaojianChange, self)  
    -- 
    EventControler:addEventListener(UserExtEvent.USEREXTEVENT_MODEL_UPDATE, self.tiaojianChange, self);
end
function EliteDetailsView:tiaojianChange()
	-- vip升级  
    self:updateItemDetailsUI(self.selectItemData)
end


function EliteDetailsView:onPressNpc(record)
    if self.scroll_my_list:isMoving() then
        return
    end
--    self:updateItemDetailsUI(record)
end

-- 规则
function EliteDetailsView:onBtnGuizeTap()
	WindowControler:showWindow("EliteHelp")
end

--返回 
function EliteDetailsView:onBtnBackTap()
	self:startHide()
end

return EliteDetailsView
