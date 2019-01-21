-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
 
local CombineItemTip = class("CombineItemTip", ItemBase)

function CombineItemTip:ctor(winName)
    CombineItemTip.super.ctor(self, winName)
    self.itemID = 0
    self.arcAni = nil
    self.lightning = nil
    self.chooseId = -1

    self.conbimeState = false
   
end

function CombineItemTip:loadUIComplete()
    self:registerEvent()
    FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.btn_2, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.btn_1, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.panel_red, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.panel_res, UIAlignTypes.MiddleTop)
    FuncCommUI.setViewAlign(self.panel_shiban, UIAlignTypes.MiddleTop)
    FuncCommUI.setViewAlign(self.ctn_leftList, UIAlignTypes.LeftTop)

    self:adjustZFBCLPos()
end

--调整 整法宝材料位置
function CombineItemTip:adjustZFBCLPos()
    local adjustX = 15
    local adjustY = -20
    self.mc_1:showFrame(2)
    self.mc_1.currentView["panel_3"].mc_tiaojian:showFrame(2)
    local ui = self.mc_1.currentView["panel_3"].mc_tiaojian.currentView.UI_1
    ui:setPosition(ui:getPositionX()+adjustX,ui:getPositionY()+adjustY)

    self.mc_1:showFrame(3)
    self.mc_1.currentView["panel_3"].mc_tiaojian:showFrame(2)
    local ui1 = self.mc_1.currentView["panel_3"].mc_tiaojian.currentView.UI_1
    ui1:setPosition(ui1:getPositionX()+adjustX,ui1:getPositionY()+adjustY)

    self.mc_1.currentView["panel_4"].mc_tiaojian:showFrame(2)
    local ui2 = self.mc_1.currentView["panel_4"].mc_tiaojian.currentView.UI_1
    ui2:setPosition(ui2:getPositionX()+adjustX,ui2:getPositionY()+adjustY)
end
   
function CombineItemTip:registerEvent()
    CombineItemTip.super.registerEvent(self)
    self.btn_back:setTap(c_func( function()
         -- AudioModel:playSound("s_com_click1")
        self:startHide()
        
    end , self));

    self.btn_2:setTap(c_func( function()
--        self:openDetail()
        WindowControler:showWindow("TreasureInfoView",self._treasureId);
    end , self));

    self.btn_1:setTap(c_func( function()
        if self.itemData.isSatisfy then
            if not self.conbimeState then
                if TreasuresModel:getTreasureById(self.itemData.id) then
                    WindowControler:showTips("法宝已经存在")
                else
                    self:combineCallback()
                end
                
            end  
        else
            -- 铜币不足
            if not self.itemData.coinSatisfy then
                local _ui=WindowControler:showWindow("CompBuyCoinMainView")
	             _ui:buyCoin()
            elseif not self.itemData.debrisSatisfy then --残片判断
                WindowControler:showTips(string.format(GameConfig.getLanguage("combine_suipian_buzu"),GameConfig.getLanguage(self.itemData.name)))
            else
                self:zhengfabaoTips() -- 整法宝
--                WindowControler:showTips(GameConfig.getLanguage("combine_tips"))
            end
        end
    end , self));

    EventControler:addEventListener(UIEvent.UIEVENT_HIDECOMP, self.updateTrreuUpdate, self)
    EventControler:addEventListener(CombineEvent.CHANGE_SELECT, self.setCombineDataEvent, self)

     --金币增加
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, 
        self.coinChangeCallBack, self);

    --道具变化
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.itemChangeCallBack, self);
--    EventControler:addEventListener(CombineEvent.CHANGE_SELECT, self.setCombineDataEvent, self)
-- 有新的法宝
    EventControler:addEventListener(TreasureEvent.TREASUREEVENT_MODEL_NEW, 
        self.newTreasureCallBack, self);

end

function CombineItemTip:zhengfabaoTips()
     local needTreasures = self.itemData.needGoodsIcon
     if #needTreasures then
        for i,v in pairs(needTreasures)  do
            if not v._own then -- 未拥有
                local treaSureName = GameConfig.getLanguage(FuncTreasure.getValueByKeyTD(v._id ,"name"))  
                WindowControler:showTips(string.format(GameConfig.getLanguage("combine_zhengfaobao_weiyongyou"),treaSureName))
            end
        end
        for i,v in pairs(needTreasures) do
            if v._own then -- 拥有
                if not self.itemData.needGoodssatisfy[i] then --未圆满
                    local treaSureName = GameConfig.getLanguage(FuncTreasure.getValueByKeyTD(v._id ,"name"))  
                    WindowControler:showTips(string.format(GameConfig.getLanguage("combine_zhengfaobao_weiyuanman"),treaSureName))
                end
                
            end
        end
     end

     
end
function CombineItemTip:newTreasureCallBack(event)
    local _tids = event.params.tids;
    if self.itemData then
        if self.itemData.id == _tids then
            self:startHide()
        else
            self.itemData = CombineControl:getTeasureItemData(self.itemData.id)
            self:updateUI()
        end
    end
end
function CombineItemTip:coinChangeCallBack(event)
    local changeNum = event.params.coinChange;
    if changeNum > 0 then 
        self.itemData = CombineControl:getTeasureItemData(self.itemData.id)
        self:updateUI()
    end 
end
function CombineItemTip:itemChangeCallBack()
     if CombineControl:isHasThisTreasureById(self.itemData.id) then
        -- 返回合成UI
        self:startHide()   
     end
     self.itemData = CombineControl:getTeasureItemData(self.itemData.id)
     self:updateUI()     
end

function CombineItemTip:updateTrreuUpdate(event)
    local _p = event.params
    if _p.ui.windowName == "TreasureDetailView" then
        local os = _p.data.treasureLvl

        if _p.data ~= nil and self.chooseId ~= -1 then
           --返回时刷新单个Item
--             EventControler:dispatchEvent(CombineEvent.TREASURE_COMBINE_UPDATE_SIGN_DATA, { })         
            local _myTreasuresVer = TreasuresModel:getAllTreasure()
            local _mid = self.itemData.needGoodsIcon[self.chooseId]._id
            local refineLv = FuncTreasure.getTreasureRefineMaxLvl(_mid)
            local _state = _myTreasuresVer[tostring(_mid)]:state()
            if _state == refineLv then
                self.itemData.needGoodssatisfy[self.chooseId] = true 
                local _a = true
                --整法宝是否满足            
                for i = 1, #self.itemData.needGoodssatisfy do
                    if not self.itemData.needGoodssatisfy[i] then
                        _a = false
                    end 
                end  
                self.itemData.isSatisfy = _yuan3(self.itemData.coinSatisfy and _a and self.itemData.debrisSatisfy ,true ,false )
                
            end
            self.itemData.needGoodsIcon[self.chooseId]._quality = _state
            self:updateUI()
        end
    end

end 

function CombineItemTip:showCombineTip(_mId)
    self.itemData = CombineControl:getTeasureItemData(_mId)
    self:updateUI()
end 

function CombineItemTip:addCaiLiaoBgAnim(panelName)
     self:createUIArmature("UI_Combine","UI_Combine_xuanzhuan", nil, true):addto(self.mc_1.currentView[panelName].ctn_3):setPosition(self.mc_1.currentView[panelName].ctn_3:getPositionX()-144,self.mc_1.currentView[panelName].ctn_3:getPositionY()+144)
end 

--_type 1 碎片 2 铜钱 3 法宝 ，
--index 法宝回调方法的index ， _quality 法宝的品阶 ，_state 法宝是否圆满
function CombineItemTip:showCaiLiao(panelName,_type,_sprite,index,_quality,_state)
     self.mc_1.currentView[panelName].mc_tiaojian:showFrame(_yuan3(_type==3,2,1))
     local ui = self.mc_1.currentView[panelName].mc_tiaojian.currentView.UI_1
     
     local panelInfo
     if _type == 3 then
        panelInfo = ui
     else
        ui.mc_1:showFrame(_type)
        panelInfo = ui.mc_1.currentView.btn_1:getUpPanel().panel_1      
     end

    if _type == 1 then
        panelInfo.panel_red:setVisible(false)
    end
     
     if panelName == "panel_2" then
         ui.mc_1.currentView.btn_1:setTap(c_func(function ()
             local _ui=WindowControler:showWindow("CompBuyCoinMainView")
	         _ui:buyCoin()
         end, self))
         
     end

     if panelName == "panel_1" then
         ui.mc_1.currentView.btn_1:setTap(c_func(self.treasureMaterialCallBack, self))
         --panelInfo.ctn_1:setTouchedFunc(c_func(self.treasureMaterialCallBack, self), nil, true, function() end)
     end

     if index then
        local _function = function ()
            self:treasureMaterialCallBack(index)
        end 

        panelInfo:setTouchedFunc(c_func(_function, self))
     end

     if _type ~= 3 then
         self.mc_1.currentView[panelName].mc_di:showFrame(1)
         panelInfo.txt_goodsshuliang:setVisible(false)
         panelInfo.ctn_1:removeAllChildren()
         panelInfo.mc_zi:setVisible(false)
         _sprite:addto(panelInfo.ctn_1):size(
            panelInfo.ctn_1.ctnWidth, 
            panelInfo.ctn_1.ctnHeight)
     else
        self.mc_1.currentView[panelName].mc_di:showFrame(2)
        --panelInfo:setPosition(panelInfo:getPositionX()+5,panelInfo:getPositionY()-10)
        panelInfo:setScale(0.8)
        panelInfo.mc_biaoqian:setVisible(false)
        if type(_state) == "number" then
            panelInfo.mc_di:showFrame(_state)
        end
        panelInfo.mc_zizhi:showFrame(_quality)
        --self.mc_1.currentView[panelName].panel_di:setVisible(false)
        panelInfo.ctn_icon:removeAllChildren()
         _sprite:addto(panelInfo.ctn_icon):size(
                panelInfo.ctn_icon.ctnWidth, 
                panelInfo.ctn_icon.ctnHeight)
     end

     
end

function CombineItemTip:updateUI()
    self.ctn_3:removeAllChildren();
    self.ctn_2:removeAllChildren();
    self.panel_3.ctn_1:removeAllChildren();

    --   是否可以合成
    if self.itemData.isSatisfy then
        FilterTools.clearFilter( self.btn_1 )
    else
        FilterTools.setGrayFilter(self.btn_1);
    end
    
   
    ---------------------------------------------------------------------------
    local _sprite = display.newSprite(self.itemData.mainIcon):size(self.panel_3["ctn_1"].ctnWidth, self.panel_3["ctn_1"].ctnHeight)
    _sprite:parent(self.panel_3["ctn_1"])
    -- 物品名称
    self.panel_3["txt_1"]:setString(GameConfig.getLanguage(self.itemData.name))
    self.panel_3["txt_1"]:setVisible(false)
    self.panel_shiban["txt_1"]:setString(GameConfig.getLanguage(self.itemData.name))
    -- 法宝位置icon
    if self.itemData.pos ~= 0 then 
        self.panel_3["mc_2"]:showFrame(self.itemData.pos)
        self.panel_3["mc_2"]:setVisible(false)
        self.panel_shiban["mc_1"]:showFrame(self.itemData.pos)
    else 
        self.panel_3["mc_2"]:setVisible(false)
        self.panel_shiban["mc_1"]:setVisible(false)
    end 
    -- 法宝星级
    self.panel_3["mc_3"]:showFrame(self.itemData.star)
    -- 小红点
    self.panel_red:setVisible(self.itemData.isSatisfy)
    -- 资质
    self.panel_3.mc_1:showFrame(self.itemData.quality)


    local _len = #self.itemData.needGoodssatisfy
    self.mc_1:showFrame(_len + 1)

    --需要的金币数  panel_2
    self:showCaiLiao("panel_2",1,display.newSprite(FuncRes.iconRes(3)))
    if self.itemData.coinSatisfy then 
        self.mc_1.currentView["panel_2"].mc_1:showFrame(1);
    else 
        self.mc_1.currentView["panel_2"].mc_1:showFrame(4);
    end 
    self.mc_1.currentView["panel_2"].mc_1.currentView["rich_1"]:setString(FuncTreasure.getCombineData(self.itemData.id, "coin"))
    -- 需要的碎片数量  panel_1
    local _resName = FuncRes.iconTreasure(self.itemData.id)
    local _panelName = "panel_1"  

    self:showCaiLiao(_panelName,2,display.newSprite(_resName))
    local _frame = _yuan3(self.itemData.debrisSatisfy , 3, 4)
    self.mc_1.currentView[_panelName].mc_1:showFrame(_frame)
   
    self.mc_1.currentView[_panelName].mc_1.currentView["rich_1"]:setString(self.itemData.goodsNum)

    self.mc_1.currentView[_panelName].ctn_3:removeAllChildren();


    -- 整法宝 panel_3  panel_4
    local _ngs = self.itemData.needGoodssatisfy
    local _nicon = self.itemData.needGoodsIcon
    local _eventCallBack = { }
    self.zhengfabaoState = {}  --整法宝圆满为true 否则为 false
    for i = 1, _len do
        local _sprite = display.newSprite(_nicon[i]._iconName)
        _sprite:setScale(0.5)
        local _fbPanelName = "panel_" ..( 2 + i)
        local _cuview = self.mc_1.currentView["panel_" ..( 2 + i)]
        _cuview.ctn_3:removeAllChildren();

        if not _nicon[i]._own then
            -- 没有该法宝置灰
            FilterTools.setGrayFilter(_sprite);
        end
        -- 是否圆满
        local _state
        if _nicon[i]._own then
             local treasures = TreasuresModel:getAllTreasureInBag()
             for k,v in pairs(treasures) do
                if v._id == _nicon[i]._id then
                  _state = v._data.state
                  break
                end
             end

            if not _ngs[i] then
                table.insert(self.zhengfabaoState,false)
                _cuview.mc_1:showFrame(2)
            else
                table.insert(self.zhengfabaoState,true)
                _cuview.mc_1:showFrame(3)
            end
        else
            table.insert(self.zhengfabaoState,false)
            _cuview.mc_1:showFrame(4)
        end
        local _quality = TreasuresModel:getTreasureQualityById(_nicon[i]._id)
        self:showCaiLiao(_fbPanelName,3,_sprite,i,_quality,_state)
    end
    --初始化特效
    self:initEffect()
end 

-- 合成特效  初始化时的 特效
function CombineItemTip:initEffect()
    -- FuncArmature.loadOneArmatureTexture("UI_Combine", nil, true)
 --碎片
    if self.itemData.debrisSatisfy then
        local ctnCailiao_1 = self.mc_1.currentView["panel_1"].ctn_s
        ctnCailiao_1:removeAllChildren()
        self.arcAniCailiao_1 = self:createUIArmature("UI_Combine","UI_Combine_xuanzhong", nil, true, GameVars.emptyFunc):addto(ctnCailiao_1)
--        self.arcAniCailiao_1:setPositionY(self.arcAniCailiao_1:getPositionY()+300)
    end
    
--金币
    local costCoin = "3,"..FuncTreasure.getCombineData(self.itemData.id, "coin")
    local tableCost = {}
    table.insert(tableCost,costCoin)
    if UserModel:isResEnough(tableCost) == true then
        local ctnCailiao_2 = self.mc_1.currentView["panel_2"].ctn_s
        ctnCailiao_2:removeAllChildren()
        self.arcAniCailiao_2 = self:createUIArmature("UI_Combine","UI_Combine_xuanzhong", nil, true, GameVars.emptyFunc):addto(ctnCailiao_2)
    end
   
--法宝
    local _len = #self.itemData.needGoodssatisfy
    --法宝材料
    self.arcAniFBCL = {}
    for i = 1, _len do
        if self.zhengfabaoState[i] then
            local ctnCailiao = self.mc_1.currentView["panel_" ..( 2 + i)].ctn_s
            ctnCailiao:removeAllChildren()
            local arcAniCailiao = self:createUIArmature("UI_Combine","UI_Combine_xuanzhong", nil, true, GameVars.emptyFunc):addto(ctnCailiao)
            table.insert(self.arcAniFBCL,arcAniCailiao)
        end  
        
    end       

--法宝光罩
    self.arcAniGuangZhao = self:createUIArmature("UI_Combine","UI_Combine_baozhao", nil, true,  GameVars.emptyFunc):addto(self.panel_3["ctn_1"])
    self.arcAniGuangZhao:pause()
--法宝扫光
    self.arcAniSaoGuang = self:createUIArmature("UI_Combine","UI_Combine_saoguang", nil, true,GameVars.emptyFunc):addto(self.panel_3["ctn_1"])
    
--法宝正常状态下 法阵
    self:playEffectFazhen()
end

function CombineItemTip:playEffectFazhen()
    if self.itemData.isSatisfy then
        self.arcAniFaZhen = self:createUIArmature("UI_Combine","UI_Combine_fazhenxunhua", nil, true, GameVars.emptyFunc):addto(self.ctn_2)
    else
        self.arcAniFaZhen = self:createUIArmature("UI_Combine","UI_Combine_huxi", nil, true, GameVars.emptyFunc):addto(self.ctn_2)
    end
end

function CombineItemTip:playEffectFinish()
    self:startHide()    
    WindowControler:showWindow("LotteryShowTreasure", self.itemData.id)
    
--    self.arcAniCombCailiao_1:removeFromParent()
--    self.arcAniCombCailiao_2:removeFromParent()
--    self.arcAniGuangZhao:removeFromParent()
--    self.arcAniSaoGuang:removeFromParent()
--    local _len = #self.itemData.needGoodssatisfy
--    if _len == 1 then
--        self.arcAniCombCailiao_3:removeFromParent()
--    end
--    if _len == 2 then
--        self.arcAniCombCailiao_3:removeFromParent()
--        self.arcAniCombCailiao_4:removeFromParent()
--    end

end

--材料换装
function CombineItemTip:cailiaoPlayEffect(panelName,effectName,changeName)
     local ctnCailiao_1 = self.mc_1.currentView[panelName].ctn_2
     local arcAniCombCailiao = self:createUIArmature("UI_Combine",effectName, nil, false, GameVars.emptyFunc):addto(ctnCailiao_1)
     arcAniCombCailiao:doByLastFrame(false,true);
     local xiaohao = arcAniCombCailiao:getBoneDisplay(changeName);
     self.mc_1.currentView[panelName].mc_tiaojian:setPosition(-43, 0);
     FuncArmature.changeBoneDisplay(xiaohao, "layer2", self.mc_1.currentView[panelName].mc_tiaojian);

     return arcAniCombCailiao
end

-- 播放合成特效  
-- 为什么要在 播特效时候 self.combine 后端请求合成
function CombineItemTip:playCombineEffect()
    self.conbimeState = true
    AudioModel:playSound("s_treasure_combining")
    
--碎片
     self.arcAniCombCailiao_1 = self:cailiaoPlayEffect("panel_1","UI_Combine_xiaohao1","xiaohao1")
--金币
     self.arcAniCombCailiao_2 = self:cailiaoPlayEffect("panel_2","UI_Combine_xiaohao4","xiaohao4")
--法宝
    local _len = #self.itemData.needGoodssatisfy
    --法宝材料
    self.arcAniCombCailiao_3 = nil
    self.arcAniCombCailiao_4 = nil
    if _len == 1 then
        self.arcAniCombCailiao_3 = self:cailiaoPlayEffect("panel_3","UI_Combine_xiaohao5","xiaohao4")
    end
    if _len == 2 then
        self.arcAniCombCailiao_3 = self:cailiaoPlayEffect("panel_3","UI_Combine_xiaohao2","xiaohao2")
        self.arcAniCombCailiao_4 = self:cailiaoPlayEffect("panel_4","UI_Combine_xiaohao3","xiaohao3")

    end
--播放光罩动画
    self.arcAniGuangZhao:startPlay(false)
    self.arcAniGuangZhao:doByLastFrame(false,true,function ()
        self:playEffectFinish()
    end);

--去掉扫光特效
    self.arcAniSaoGuang:removeFromParent()
--法阵特效
    self.arcAniGuangZhao:registerFrameEventCallFunc(20, 1, function ( ... )
            echo("---arcAniGuangZhao 20----");
           self.arcAniFaZhenFG = self:createUIArmature("UI_Combine","UI_Combine_shanguang", nil, false, GameVars.emptyFunc):addto(self.ctn_2)             
    end) 

end 


function CombineItemTip:treasureMaterialCallBack(idx)
    AudioModel:playSound("s_com_click1")


    if type(idx) == "number" then
        if self.itemData.needGoodsIcon[idx]._own then
            WindowControler:showWindow("CombineItemIntensify", self, { bgAlpha = 0 }):initData(self.itemData, idx)
            self.chooseId = idx
        else
            WindowControler:showWindow("GetWayListView", self.itemData.needGoodsIcon[idx]._id,false,true);
        end
    else
        WindowControler:showWindow("GetWayListView", self.itemData.id,true,true);
    end

end 
function CombineItemTip:setCombineDataEvent(event)
    self.itemData = event.params.itemData;
    -- dump(data, "---data-----");
    self._treasureId = event.params.id;
    self:updateUI()
end 

function CombineItemTip:setCombineData(itemData)
    self.itemData = itemData;
    -- dump(data, "---data-----");
    self._treasureId = itemData.id;
    self:updateUI()

    self:initLeftListUI();
end 


function CombineItemTip:openDetail()
    WindowControler:showWindow("LotteryTreasureDetail",
        self.itemData.id)

end 
function CombineItemTip:combineSucceed()
    EventControler:dispatchEvent(CombineEvent.TREASURE_COMBINE_UPDATE_LIST, { })
    EventControler:dispatchEvent(TreasureEvent.TREASURE_COMBINE_EVENT, { item = self.itemData })
    --服务器 合成成功之后 播放合成特效
    self:playCombineEffect()

    EventControler:dispatchEvent(TreasureEvent.CHANGE_TREASURE, { })
    
end 

 
 
function CombineItemTip:combineCallback()

    -- 需要的整法宝
    local _treasures = self.itemData.needGoodsIcon
    -- 满足条件 检查当前法宝星级
    local _restInfo = { }
    --    if self.itemData.isSatisfy then
    local _myTreasuresVer = TreasuresModel:getAllTreasure()

    -- 判断星级
    for i = 1, #_treasures do
        local _nId = _treasures[i]._id
        -- 初始星级
        local _initStar = FuncTreasure.getValueByKeyTD(_nId, "initStar")
        local _curStar = _myTreasuresVer[tostring(_nId)]:star()
        if _curStar > _initStar then
            local _name = FuncTreasure.getValueByKeyTD(_nId, "name")
            local _numVer = FuncTreasure.getValueByKeyTD(_nId, "upStar")
            -- 返还个数
            local _num = _yuan3((_curStar - 1) == _initStar, _numVer[_initStar], _numVer[_initStar] + _numVer[_curStar - 1])
            table.insert(_restInfo, { name = GameConfig.getLanguage(_name), num = _num })
            -- 物品ID,个数
        end
    end
    --    end
    if _G.next(_restInfo) ~= nil then
        local _v = WindowControler:showWindow("CombineItemConfTip", self);
        _v:initData(_restInfo)
    else
        self:combine()
    end

end 

function CombineItemTip:combine()
    self:disabledUIClick()
    CombineServer:requestCombineData(self.itemData.id, c_func(self.combineSucceed, self))
end 


--[[
    初始化左边的list
]]
function CombineItemTip:initLeftListUI()

    local leftList = WindowsTools:createWindow(
            "TreasureLeftListCompoment", self.itemData,true);

    leftList._root:retain();

    self.ctn_leftList:addChild(leftList);
    
end

function CombineItemTip:setSelcetBgVisible(isbVisible)
    if self._selectCell ~= nil then 
        self._selectCell.scale9_1:setVisible(isbVisible);
    end 
end

function CombineItemTip:updateItem(view, treasureId)
    view.panel_1.UI_1.mc_biaoqian:setVisible(false);
    
    --最后一个隐藏下面框
    local lastId = self._treasureIds[#self._treasureIds];
    
    if lastId == treasureId then 
        view.panel_pic:setVisible(false);
    else 
        view.panel_pic:setVisible(true);
    end 

    local selectbg = view.scale9_1;
    selectbg:setVisible(false);

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
    view.panel_1.UI_1.mc_di:showFrame(1);

    --星级
    local star = FuncTreasure.getValueByKeyTD(treasureId, "initStar");
    view.mc_1:showFrame(star);
    --等级
    view.txt_1:setString(1);

    --点击事件
    view:setTouchedFunc(c_func(self.changeSelectCell, self, treasureId, view));

    --红点
    self:cellRedPointInit(view, treasureId);
end

function CombineItemTip:cellRedPointInit(view, treasureId)
    --法宝碎片数量
    local num = ItemsModel:getItemNumById(treasureId);
    local _itemInfo = CombineControl:getTeasureItemData(treasureId, num);

    if _itemInfo.isSatisfy == true then 
        view.panel_red:setVisible(true);
    else 
        view.panel_red:setVisible(false);
    end 

end

--function CombineItemTip:changeSelectCell(treasureId, view)

--    if self.scroll_list:isMoving() == false then 
--        AudioModel:playSound("s_com_click1")

--        self._selectCell.scale9_1:setVisible(false);
--        self._selectCell = view;
--        self._selectCell.scale9_1:setVisible(true);

--        self._treasureId = treasureId;

--        local all = CombineControl:checkCombineState();
--        local itemData = nil;

--        for k, v in pairs(all) do
--            -- echo(v.id, self._treasureId, "---");
--            if tonumber(v.id) == tonumber(self._treasureId) then 
--                itemData = v;
--            end 
--        end

--        self:setCombineData(itemData)
--    end 

--end

function CombineItemTip:deleteMe()
    CombineItemTip.super.deleteMe(self)
    self.controler = nil
end


return CombineItemTip
-- endregion

