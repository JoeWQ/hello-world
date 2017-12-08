local TeamFormationView = class("TeamFormationView", UIBase);



-- TeamFormationView.formationPos =
-- {
--     [1] = {x=753.20,y=199.85},
--     [2] = {x=753.20,y=339.70 },
--     [3] = {x=537.75,y=199.85},
--     [4] = {x=537.75,y=339.70},
--     [5] = {x=322.30,y=199.85},
--     [6] = {x=322.30,y=339.70},
-- }



function TeamFormationView:ctor(winName,battleData,systemId,params)
    TeamFormationView.super.ctor(self, winName);
    --战斗需要的参数  比如打开战斗加载界面
    self.battleData = battleData
    --加载参数
    --self.loadParams = loadParams
    self.params = params
    echo("参数ctor Params-----------")
    dump(self.params)
    echo("参数ctor Params-----------")
    self.systemId = systemId
   
    
    

    --创建临时的阵容，所有都在这里操作
    TeamFormationModel:createTempFormation(  self.systemId )
end

function TeamFormationView:loadUIComplete()
    --FuncArmature.loadOneArmatureTexture("UI_format",nil,true)
	self:registerEvent()
    self:uiAdjust()
    self.ctn_bgbg:visible(false)
    self.panel_12:visible(false)
    --self.tempFormation = {}
    if not TeamFormationModel:checkInited( self.systemId ) then
        self:doFormationClick()
    else
        self:initView()        --todo
    end

end 

function TeamFormationView:registerEvent()
	TeamFormationView.super.registerEvent();

    self.btn_back:setTap(c_func(self.doBackClick,self))
    self.btn_yijian:setTap(c_func(self.doFormationByOneKey,self))

    for i=1,5 do
        self.panel_1["mc_"..i]:setTouchedFunc(c_func(self.doBarItemClick,self,i))
    end

    if self.systemId == FuncTeamFormation.formation.pvp_attack then
        self.mc_zhandou:showFrame(1)

        self.mc_zhandou.currentView:setTouchedFunc(c_func(self.doBattleClick,self))
    else
        self.mc_zhandou:showFrame(2)
        self.mc_zhandou.currentView:setTouchedFunc(c_func(self.doOKClick,self))
   end

end

--[[
点击barItem
]]
function TeamFormationView:doBarItemClick( tag )
    --echo("tag",tag,"=======")
    if tag == self.tag then
        return
    end
    self:initBarItem(tag)
    --初始化数据
    self:initData()
    --初始化左侧列表 加载列表
    self:initScrollPartener()
end




--[[
UI多分辨率适配
]]
function TeamFormationView:uiAdjust(  )
    FuncCommUI.setViewAlign(self.panel_1, UIAlignTypes.LeftTop,0.7)
    FuncCommUI.setViewAlign(self.scroll_1, UIAlignTypes.LeftTop,0.7)
    --scale9_1
    FuncCommUI.setViewAlign(self.scale9_1, UIAlignTypes.LeftTop,0.7)
    FuncCommUI.setViewAlign(self.panel_power, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
    FuncCommUI.setScale9Align(self.scale9_tou,UIAlignTypes.MiddleTop, 1, 0)
    
    if self.systemId == FuncTeamFormation.formation.pvp_defend then
        self.mc_title:showFrame(2)
    else
        self.mc_title:showFrame(1)
    end
    FuncCommUI.setViewAlign(self.mc_title.currentView, UIAlignTypes.LeftTop)
end


function TeamFormationView:updateUI()
	
end

--[[

]]
function TeamFormationView:initView(  )
    --self.panel_change:visible(false)
    self.panel_goods:visible(false)
    --先初始化左侧
    self:initBarItem( 1 )
    --根据左侧初始化数据
    self:initData()
    --初始化阵容
    self:initFormation()
    --初始化左侧列表
    self:initScrollPartener()
    --初始化法宝
    self:initTreasure()
end

--[[
左侧的bar选择
todo dev 这里应该还有条件判断   某些条件下一些tag是不可见的
tag == 1 所有   
tag == 2 攻击   
tag == 3 防御  
tag == 4 辅助   
tag == 5 租
]]
function TeamFormationView:initBarItem( tag )
    self.tag = tag
    for k = 1,5 do
        if k == tag then
            self.panel_1["mc_"..k]:showFrame(2)
        else
            self.panel_1["mc_"..k]:showFrame(1)    
        end
    end
end







--[[
根据tag初始化数据
]]
function TeamFormationView:initData(  )

    self.npcsData = TeamFormationModel:getNPCsByTy( self.tag-1 )
end



function TeamFormationView:initScrollPartener( ... )
    local heroData = self.npcsData

    --self.heroData = data

    local createCellFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_goods);
        self:updateItem(view, itemData)
        return view
    end
    local updateCellFunc = function ( data,view )
        self:updateItem(view, data)
    end

    self.scrollParams = {
        {
            data = heroData,
            createFunc = createCellFunc,
            perNums = 2,
            offsetX = 14,
            offsetY = 10,
            widthGap = 0,
            updateCellFunc = updateCellFunc,
            heightGap = 10,
            itemRect = {x = 0, y = -100, width = 100, height =100},
            perFrame = 2,
        }
        
    }
    self.scroll_1:styleFill(self.scrollParams)
    --self.scroll_1:styleFill(self.scrollParams);


end





--[[
初始化上阵法宝
]]
function TeamFormationView:initTreasure(  )
    --treas是一个table数组
    for k= 1,2 do
        self.panel_fb10["mc_fbzt"..k]:setTouchedFunc(c_func(self.doTreaClick,self,k))
        self.panel_fb10["panel_jiantou"..k]:visible(false)
    end
    self:updateFormationTreas()

    self.ctn_bgbg:visible(false)
    self.panel_12:visible(false)
end

--[[
初始化法宝
]]
function TeamFormationView:updateFormationTreas(  )
    for k= 1,2 do
        local curTrea = TeamFormationModel:getCurTreaByIdx(k)

        --echo("curTrea",curTrea,"==================")
        if  curTrea ~= nil and tostring(curTrea) ~= "0" then
            local treaData = TeamFormationModel:getTreaById( curTrea )
            local mc = self.panel_fb10["mc_fbzt"..k]
            mc:showFrame(1)
            --local data = TreasuresModel:getTreasureById(curTrea)
            local icon = FuncRes.iconTreasure( curTrea )

            mc.currentView.panel_fbzt2.panel_tuijian:visible(false)
            --对号
            mc.currentView.panel_fbzt2.panel_duihao:visible(false)
            --100 文字
            mc.currentView.panel_fbzt2.txt_1:setString(treaData.level)

            mc.currentView.panel_fbzt2.mc_1:showFrame(treaData.star)

            --
            local tsp = display.newSprite(icon):size(80,70)
            mc.currentView.panel_fbzt2.ctn_goodsicon:removeAllChildren()
            tsp:addto(mc.currentView.panel_fbzt2.ctn_goodsicon)

        else
            self.panel_fb10["mc_fbzt"..k]:showFrame(2)
        end
    end
end



--[[
点击打开法宝界面
]]
function TeamFormationView:doTreaClick( index )
    --echo("index----",index)
    self.panel_fb10["panel_jiantou"..index]:visible(true)
    --打开法宝选择界面
    --echo("打开法宝选择界面-----------")

    self.pIdx = index
    --TeamChooseTreasureView
    --WindowControler:showWindow("TeamChooseTreasureView",c_func(self.onTreasSelectClose,self),self.systemId,index)
    --self.pIdx,view.data.id
    local posx = 128.5 --+235-480
    local posy = -345.5 ---182+320
    if index == 2 then
        posx = 128.5+(111-1.65)--+235-480
    end
    self.panel_fb10["panel_jiantou"..index]:parent(self.panel_12):pos(posx+(32.5-1.65),posy+41.35)
    self.panel_fb10["mc_fbzt"..index]:parent(self.panel_12):pos(posx,posy)
    self:showChooseTreaView()

end

--[[
关闭法宝界面
]]
function TeamFormationView:closeChooseTreaView(  )
    --echo("关闭法宝窗口------------")
    self.pIdx = nil

    self.ctn_bgbg:setVisible(false)
    self.panel_12:visible(false)

    --重新把相应的法宝放到对应的节点中
    self.panel_fb10["panel_jiantou"..1]:parent(self.panel_fb10):pos(32.5,0)
    self.panel_fb10["mc_fbzt"..1]:parent(self.panel_fb10):pos(1.65,-41.35)

    self.panel_fb10["panel_jiantou"..2]:parent(self.panel_fb10):pos(140.5,0)
    self.panel_fb10["mc_fbzt"..2]:parent(self.panel_fb10):pos(111,-41.35)

    --重新初始化相应的法宝
    self:initTreasure()
end


-- ============================================================================ --
--                  打开的panel 里边显示法宝的所有信息
-- ============================================================================ --

--[[
打开法宝界面  法宝界面的list初始化
]]
function TeamFormationView:showChooseTreaView(  )
    if self.ctn_bgbg.coverLayer == nil then
     local coverLayer = WindowControler:createCoverLayer(nil, nil, cc.c4b(0,0,0,120)):addto(self.ctn_bgbg, 0)
        coverLayer:pos(-GameVars.width/2,GameVars.height/2)
         -- 注册点击任意地方事件
         --0.5秒后才可以点击胜利界面关闭
        coverLayer:setTouchedFunc(c_func(self.closeChooseTreaView, self),cc.rect(0,0,GameVars.width,GameVars.height),true)

        self.ctn_bgbg.coverLayer  = coverLayer
    end
    -- local tempFunc = function (  )
    --     self:registClickClose(nil, c_func(self.closeChooseTreaView, self))
    -- end
    -- self:delayCall(tempFunc, 0.3)

    self.treaShow = true

    self.ctn_bgbg:setVisible(true)
    self.panel_12:visible(true)
    -- self.panel_12:scale(0)
    -- self.panel_12:runAction(cc.ScaleTo:create(5/GAMEFRAMERATE,1 ))


    self:initTreaList()

end



function TeamFormationView:initTreaList()
    local treaData = TeamFormationModel:getAllTreas(  )
    
    self.panel_12.panel_1:visible(false)

    local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_12.panel_1);
        --初始化法宝
        self:updateTreaItem(view,itemData)

        --view:setTouchedFunc(c_func(self.doChooseTreas,self,view,itemData))
        return view
    end


    local updateCellFunc = function ( data,view )
        self:updateTreaItem(view, data)
    end


    local params =  {
        {
            data = treaData,
            createFunc = createCellFunc,
            updateCellFunc = updateCellFunc,
            perNums = 4,
            offsetX = 20,
            offsetY = 34,
            widthGap = 6,
            heightGap = 10,
            itemRect = {x = 0, y = -110, width = 100, height =110},
            perFrame = 5
        }
        
    }
    self.panel_12.scroll_1:styleFill(params)


end



--[[
更新某一项法宝数据
]]
function TeamFormationView:updateTreaItem( view,itemData )

    -- echo("itemDataitemDataitemDataitemDataitemData")
    -- dump(itemData)
    -- echo("itemDataitemDataitemDataitemDataitemData")
    if not self.itemArr then
        self.itemArr = {}
    end
    --判断是否推荐
    local tuijian = false
    view.panel_tuijian:visible(tuijian)

    --级别
    view.txt_1:setString(itemData.level)

    --是否上阵
    local shangzhen = TeamFormationModel:chkTreaInFormation(itemData.id )
    view.panel_duihao:visible(shangzhen)

    view.mc_1:showFrame(itemData.star)
    view.ctn_goodsicon:removeAllChildren()
    view.ctn_goodsicon:addChild( display.newSprite(FuncRes.iconTreasure(itemData.id) ):size(80,80) )
    view.data = itemData
    if shangzhen then
        table.insert(self.itemArr, view)
    end


    view.ctn_goodsicon:setTouchedFunc(c_func(self.doTreaItemClick,self,view))

end
--[[
点击法宝item
]]
function TeamFormationView:doTreaItemClick(view)
    --echo("点击某个item",view.data.id,"============")
    local isHas = TeamFormationModel:chkTreaInFormation( view.data.id )
    if not isHas then
        TeamFormationModel:updateTrea( self.pIdx,view.data.id )
        table.insert(self.itemArr, view)
        self:updateItemByChoose()
        --self:initSelectItem()
        --self:initTreasure()
        
    else
        --法宝原来所在的位置
        local srcIdx = TeamFormationModel:getTreaPIdx( view.data.id )
        
        if tostring(srcIdx) ~= tostring(self.pIdx) then
            local otherIdx = self.pIdx
            if otherIdx == 1 then otherIdx = 2 else otherIdx = 1 end 
            local srcTreaId = TeamFormationModel:getCurTreaByIdx(self.pIdx ) 
            --echo("srcId",srcId,"otherIdx",otherIdx,"self.pIdx",self.pIdx,"=-===============")
            TeamFormationModel:updateTrea( self.pIdx,view.data.id )
            TeamFormationModel:updateTrea( otherIdx,srcTreaId )
            self:updateItemByChoose()
        end

    end
    --self:startHide()
    self:closeChooseTreaView()
end



function TeamFormationView:updateItemByChoose(  )
    local arr = self.itemArr
    self.itemArr = {}
    for k,v in pairs(arr) do
        self:updateTreaItem( v,v.data )
    end
end






--[[
选择法宝界面关闭
]]
function TeamFormationView:onTreasSelectClose(  )
    for i=1,2 do
        self["panel_jiantou"..i]:visible(false)
    end
    self:updateFormationTreas()
end


-- ============================================================================ --
--                  以上打开的panel 里边显示法宝的所有信息
-- ============================================================================ --




--[[
更新每个数据
如果使用 updateViewCell可以复用cell 这样的话，
@@@@@ 需要做的事情就是   清空addChild的东西，并且   重新注册事件
]]
function TeamFormationView:updateItem( view,itemData )
    -- echo("更新数据updateItem====================")
    -- dump(itemData)
    -- echo("更新数据updateItem====================")
    --等级
    view.txt_1:setString(itemData.level)
    view.mc_no:visible(false)           --存在以上阵等等
    view.panel_tiao:visible(false)
    --view.panel_duihao:visible(true)
    local star = itemData.star
    --echo("sta")
    view.mc_2:showFrame(star)
    local isInFormation = TeamFormationModel:chkIsInFormation(itemData.id )
    --echo(itemData.id,"===============",isInFormation,"====================")




    --echo("是否上阵-----",itemData.id,isInFormation,"=============")
    view.panel_duihao:visible( isInFormation)
    --品质
    local quality = itemData.quality
    --echo("quality",quality,"================")
    view.mc_1:showFrame(quality)
    local icon = itemData.icon
    --这里应该判断是否是主角
    if tostring(itemData.id) == "1" then icon = "head30005" end
    view.mc_1.currentView.ctn_1:removeAllChildren()
    view.mc_1.currentView.ctn_1:addChild(display.newSprite( FuncRes.iconHero(icon ..".png") ):size(78,78))
    

    view.data = itemData


    -- view:setTouchedFunc(
    --      c_func(self.doItemClick,self,view),
    --      nil, 
    --      true, 
    --      c_func(self.doItemBegan, self,view), 
    --      c_func(self.doItemMove, self,view),
    --      false,
    --      c_func(self.doItemEnded, self,view) 
    --     )
 view:setTouchedFunc(
         c_func(self.doItemClick,self,view)
         -- nil, 
         -- true, 
         -- c_func(self.doItemBegan, self,view), 
         -- c_func(self.doItemMove, self,view),
         -- false,
         -- c_func(self.doItemEnded, self,view) 
        )
end








function TeamFormationView:initFormation(  )

    
    local showNuQi = FuncTeamFormation.isShowNuQi( self.systemId )


    -- for k,v in pairs(data) do
    --     local formation = v.formation
    --     self["mc_tai"..formation].formation = v
    -- end
    
    self:clearCtnNode()
    for k = 1,6 do 
        local isOpen,lv = FuncTeamFormation.checkPosIsOpen( k )
        local mc = self["mc_tai"..k]
        --绑定是否开启属性
        mc.isOpen = isOpen

        if isOpen then
            mc:showFrame(1)
            mc.currentView.panel_1.panel_1:visible(false)
            local ctn = mc.currentView.panel_1.ctn_player
            ctn:removeAllChildren()
            local nd = display.newNode()
            local viewSize  = cc.size(80,140)
            nd:setContentSize(viewSize)
            nd:anchor(0,0)
            --注册点全部放到脚下
            nd:pos(-viewSize.width* 0.5,-viewSize.height * 0.1-50)
            nd:addto(ctn):zorder(1)
            ctn.nd = nd
            --判断血条和怒气是否显示  todo dev
            mc.currentView.panel_1.ctn_player.nd:setTouchedFunc(
            c_func(self.doViewClick,self,mc,k), 
            nil, 
            true, 
            c_func(self.doViewBegan, self,mc,k), 
            c_func(self.doViewMove, self,mc,k),
            false,
            c_func(self.doViewEnded, self,mc,k) 
            )


            local prop = FuncTeamFormation.getPropByTaiZi( k )
            mc.currentView.panel_1.mc_1:visible(true)
            --echo("prop",prop,"hero",hero,"-------")
            mc.currentView.panel_1.mc_1:showFrame(prop)
            mc.currentView.panel_1.mc_1.currentView["txt_"..prop]:setString(FuncTeamFormation.getPropTxt(prop))

            mc.currentView.panel_1.panel_keyidong:visible(false)
            if mc.currentView.panel_1.ctn_chuxiantexiao.showHeroAni then
                mc.currentView.panel_1.ctn_chuxiantexiao.showHeroAni:removeFrameCallFunc()
                mc.currentView.panel_1.ctn_chuxiantexiao.showHeroAni:clear()
                mc.currentView.panel_1.ctn_chuxiantexiao.showHeroAni = nil
            end
            if mc.currentView.panel_1.ctn_chuxiantexiao then
                mc.currentView.panel_1.ctn_chuxiantexiao:stopAllActions()
            end


            --这个hero只是一个heroId  如果是1的话，就是主角
            local hero = TeamFormationModel:getHeroByIdx(k )
            local isShowAni = false
            if mc.heroId == nil or mc.heroId == "0" then
                isShowAni = true
            end
            
            if hero == nil or hero == 0 or hero == "0" then
                --没有人
                --血条不可见
                mc.currentView.panel_1.panel_tiao:visible(false)
                --属性文字
                --mc.currentView.panel_1.mc_1:visible(false)
                mc.currentView.panel_1.ctn_kongdonghua:visible(true)
                if  mc.currentView.panel_1.ctn_kongdonghua.emptyAni == nil then
                    --createUIArmature(flaName, armatureName ,ctn, iscycle ,callBack )
                    mc.currentView.panel_1.ctn_kongdonghua.emptyAni = self:createUIArmature("UI_format","UI_format_tishishangzhena",mc.currentView.panel_1.ctn_kongdonghua,true)
                    --mc.currentView.panel_1.ctn_kongdonghua.emptyAni = FuncArmature.createArmature("UI_format_tishishangzhena",mc.currentView.panel_1.ctn_kongdonghua,true)
                    mc.currentView.panel_1.ctn_kongdonghua.emptyAni:pos(2,-16)
                end
                mc.currentView.panel_1.ctn_kongdonghua.emptyAni:startPlay(true)

                ctn.view = nil
                mc.heroId = hero
            else
                --有人
                mc.currentView.panel_1.ctn_kongdonghua:visible(false)
                mc.currentView.panel_1.panel_tiao:visible(showNuQi)
                --mc.currentView.panel_1.mc_1:visible(showNuQi)
                --设置可点击节点
                
                local loadHeroSpine = function (  )

                    local spine = FuncTeamFormation.getSpineNameByHeroId( hero )
                    local view = ViewSpine.new(spine,{},spine):addto(ctn):pos(0,-50):zorder(-1)
                    view:setScaleX(-1)
                    mc.heroId = hero
                    ctn.view = view
                    --播放站立动作   这个需要写一个npc站立方法
                    view:playLabel("stand",true)
                    --这个prop需要从npc中读取
                    --local prop = TeamFormationModel:getPropByPartnerId( k )
                    
                end




                local callBack
                callBack = function (  )
                    mc.currentView.panel_1.ctn_chuxiantexiao.showHeroAni:removeFrameCallFunc()
                    mc.currentView.panel_1.ctn_chuxiantexiao.showHeroAni:clear()
                    mc.currentView.panel_1.ctn_chuxiantexiao.showHeroAni = nil
                    --loadHeroSpine()
                end
                
                if  isShowAni then
                    --self:createUIArmature("UI_format"
                    mc.currentView.panel_1.ctn_chuxiantexiao.showHeroAni = self:createUIArmature("UI_format","UI_format_xuanshanzhen",mc.currentView.panel_1.ctn_chuxiantexiao,false,GameVars.emptyFunc)
                    --mc.currentView.panel_1.ctn_chuxiantexiao.showHeroAni = FuncArmature.createArmature("UI_format_xuanshanzhen",mc.currentView.panel_1.ctn_chuxiantexiao,false,GameVars.emptyFunc)
                    mc.currentView.panel_1.ctn_chuxiantexiao.showHeroAni:registerFrameEventCallFunc(nil,nil,callBack)
                    --echo("执行到演示了===================")
                    mc.currentView.panel_1.ctn_chuxiantexiao:stopAllActions()
                    mc.currentView.panel_1.ctn_chuxiantexiao:delayCall(function (  )
                        loadHeroSpine()
                    end,18/GAMEFRAMERATE )
                    -- mc.currentView.panel_1.ctn_chuxiantexiao:runAction(cc.Sequence:create(
                    --         cc.DelayTime:create(20*GAMEFRAMERATE ),
                    --         cc.CallFunc:create(function (  )
                    --             echo("加载Spine--------------------")
                    --             loadHeroSpine()
                    --         end)
                    --     ))
                    mc.currentView.panel_1.ctn_chuxiantexiao.showHeroAni:playWithIndex(0)
                else
                    loadHeroSpine()
                end

                
                



            end
        else
            mc:showFrame(2)
            mc.currentView.txt_1:setString(lv.."级开启")
        end
    end

end




--[[
执行上阵操作
]]
function TeamFormationView:doFormationClick( isNotCloseSelf )
    --初始化阵容
    local params = {}
    params.id = tostring(self.systemId) 
    params.formation = {}
    
    if not TeamFormationModel:checkInited( self.systemId ) then
        
        params.formation.treasureFormation = {}
        params.formation.partnerFormation = {}
        --初始化要上阵的法宝
        params.formation.treasureFormation.p1= TeamFormationModel:getInitUseTrea(  )
        params.formation.treasureFormation.p2 = 0
        --主角上阵
        params.formation.partnerFormation.p1 = 1
        params.formation.partnerFormation.p2 = 0
        params.formation.partnerFormation.p3 = 0
        params.formation.partnerFormation.p4 = 0
        params.formation.partnerFormation.p5 = 0
        params.formation.partnerFormation.p6 = 0

        TeamFormationServer:doFormation( params,c_func(self.doFormationCallBack,self,true) )
    else
        --更新阵容
        local params = {}
        params.id = tostring(self.systemId)
        params.formation = TeamFormationModel:getTempFormation(  )
        TeamFormationServer:doFormation( params,c_func(self.doFormationCallBack,self,isCloseSelf) )
    end
end

--[[
执行上阵回调
]]
function TeamFormationView:doFormationCallBack(params,isInit,isNotCloseSelf)
    -- echo("执行上阵的网络回调")
    -- dump(params)
    -- echo(isInit,"=========")
    -- echo("执行上阵的网络回调")
    if isInit then
        TeamFormationModel:createTempFormation(  self.systemId )
        self:initView(  )
    else
        WindowControler:showTips( { text = "阵容保存成功" })
        if not isNotCloseSelf then
            self:startHide()
        end
    end 
end





--===============================数据接上要优化========================================--




--[[
点击左侧列表
]]
function TeamFormationView:doItemClick(view)
   -- echo("当前的view.data")
   -- dump(view.data)
   -- echo("当前的view.data")

   if self.scroll_1:isMoving() then
        return
   end

   local hid = view.data.id
   local chkUpdate = true
   if TeamFormationModel:chkIsInFormation(hid ) then
        if tostring(hid)  == "1" then
            WindowControler:showTips( { text = "主角不能下阵" })
            return
        end
        --已经上阵
        local pIdx = TeamFormationModel:getPartnerPIdx( hid )

        --echo("已经上阵-------",pIdx,"=============")
        TeamFormationModel:updatePartner( pIdx,"0" )
        --下阵音效
        AudioModel:playSound(MusicConfig.s_formation_out)
    else
        --没有上阵
        local pIdx = TeamFormationModel:getAutoPIdx( view.data.type )
        if pIdx == -1 then
            chkUpdate = false
            WindowControler:showTips( {text = "出战伙伴已满，不可上阵"} )
        else
            --todo
            TeamFormationModel:updatePartner( pIdx,hid )
            --上阵音效
            AudioModel:playSound(MusicConfig.s_formation_come)
        end
   end
   if chkUpdate then
        self:updateItem(view, view.data)
        self:initFormation()
   end
end

--[[
点击view
@params view 
@params pIdx
]]
function TeamFormationView:doViewClick( view,pIdx )
    --echo(view.heroId,"=-==========================")
    if view.heroId ~= nil and view.heroId ~= "0" then
        if tostring( view.heroId ) == "1" then
            WindowControler:showTips( { text = "主角不能下阵" })
            return
        end
        --下阵音效
        AudioModel:playSound(MusicConfig.s_formation_out)
        --echo("播放了-------------")
        TeamFormationModel:updatePartner( pIdx,"0" )
        --self:updateItem(view, view.data)
        --self.scroll_1:refreshCellView(1)
        self.scroll_1:refreshCellView(1)
        self:initFormation()
    end
end







--[[
显示红色台子
]]
function TeamFormationView:doShowRedTaiZi( pIdx,isShow )
    for k = 1,6 do
        local mc = self["mc_tai"..k]
        if  mc.isOpen then
            mc.currentView.panel_1.panel_keyidong:visible(isShow)


            if  isShow  then
                if mc.currentView.panel_1.ctn_kongdonghua then
                    mc.currentView.panel_1.ctn_kongdonghua:visible(not isShow)    
                end
            end
        end
        
        
        
    end
end







---  ===============================================================  --
--                  began move end 事件  处理
---  ===============================================================  --
--[[
点击spine
]]
function TeamFormationView:doViewBegan( mcView,pIdx,event)
    -- body
    -- echo("doViewBegan")
    -- echo("event.x,event.y",event.x,event.y,"began------------------")

    
    if tostring(mcView.heroId) =="0" or  (not mcView.isOpen) then
        return
    end
    self.startMcView = mcView
    self.startPos = {x = event.x,y = event.y}
    local xx ,yy = mcView.currentView.panel_1.ctn_player.view:getPosition()
    --self.viewSrcPos = {x = xx,y = yy}

    --计算当前的世界为之
    local globelPos = mcView.currentView.panel_1.ctn_player.view:convertToWorldSpace(cc.p(xx,yy))
    --echo("globelPos.x,globelPos.y",globelPos.x,globelPos.y,"==============")


    -- self.ctn_node:removeAllChildren()
    -- self.ctn_node.view = nil
    -- self.ctn_node.heroId = nil
    self:clearCtnNode()

    mcView.currentView.panel_1.ctn_player.view:opacity(120)
    mcView.currentView.panel_1.ctn_player.view:parent(self.ctn_node):pos(0,50)
    self.ctn_node.view = mcView.currentView.panel_1.ctn_player.view
    mcView.currentView.panel_1.ctn_player.view = nil
    self.ctn_node.heroId = mcView.heroId
    --设置临时节点的位置
    local cntParent = self.ctn_node:parent()
    local locaNode = cntParent:convertToNodeSpace(globelPos)
    --self.ctn_node:pos(GameVars.UIOffsetX+globelPos.x, GameVars.height - GameVars.UIOffsetY-globelPos.y)
    self.ctn_node:pos(locaNode.x,locaNode.y)

    xx,yy = self.ctn_node:getPosition()
    self.viewSrcPos = {x = xx,y = yy}

    local currentFrame =self.ctn_node.view:getCurrentFrame()
    self.ctn_node.view:gotoAndStop(currentFrame)

    --self:doShowRedTaiZi( pIdx,true )

end


--[[
移动
]]
function TeamFormationView:doViewMove( mcView,pIdx,event)
    -- echo("doViewMove")
    -- -- body
    -- echo("event.x,event.y",event.x,event.y,"moved---------------------")

    if self.startMcView and self.startPos and self.viewSrcPos then
        self:doShowRedTaiZi( pIdx,true )
        local offsetX = event.x - self.startPos.x
        local offsetY = event.y - self.startPos.y

        --local lastPosx,lastPosy = self.ctn_node:getPosition()

        self.ctn_node:pos(self.viewSrcPos.x + offsetX,self.viewSrcPos.y+ offsetY)

        if self.moveIng == nil then
            self.moveIng = {}
        end
        

        local targetIdx = self:chkEnterMc(event.x, event.y)
        --echo("targetIdxtargetIdxtargetIdx",targetIdx,"===============")
        if targetIdx>=1 and targetIdx<=6  then

            if self.moveIng.targetMC and self.moveIng.srcMC and self.moveIng.lastIdx ~= targetIdx then
                --移动到目标内了。且 第一次进入目标内 则把原来的一动撤销回来
                --echo("执行撤销还原---------")
                self:moveToMc(self.moveIng.srcMC,self.moveIng.targetMC)
            end
            --设置新的移动
            if self.moveIng.lastIdx ~= targetIdx and targetIdx ~= pIdx then
                self.moveIng.targetMC = self.startMcView
                self.moveIng.targetIdx = targetIdx
                self.moveIng.srcMC = self["mc_tai"..targetIdx]
                self.moveIng.srcIdx = pIdx
                --echo("设置新一动")
                self:moveToMc(self.moveIng.targetMC,self.moveIng.srcMC)
                self.moveIng.lastIdx = targetIdx
            end
        else
            self.moveIng.lastIdx = targetIdx
        end

    end
end

--[[
松开
]]
function TeamFormationView:doViewEnded( mcView,pIdx,event )
    echo("doViewEnded")
    self:doShowRedTaiZi( pIdx,false )
    if self.startMcView and self.startPos and self.viewSrcPos then
        local x,y = event.x,event.y
        local targetMc
        local targetIdx = 0
        for k=1,6,1 do
            if self["mc_tai"..k].isOpen then
                --已经开启的情况
                local nd = self["mc_tai"..k].currentView.panel_1.ctn_player.nd
                local localPos = nd:convertToNodeSpace(cc.p(x,y))
                if cc.rectContainsPoint(cc.rect(0,0,80,140),localPos) then
                    targetMc = self["mc_tai"..k]
                    targetIdx = k
                    break
                end
            end
        end
        --if targetMc then
            if self.moveIng and self.moveIng.targetMC and self.moveIng.srcMC  then
                --移动到目标内了。且 第一次进入目标内 则把原来的一动撤销回来
                --echo("执行撤销还原---------222222222")
                self:moveToMc(self.moveIng.srcMC,self.moveIng.targetMC)
            end
        --end

        if not targetMc then
            targetMc = self.startMcView
        end
        if targetMc ~= self.startMcView then
            --拖动成功音效
            AudioModel:playSound(MusicConfig.s_formation_move)
        end
        if targetMc  then
            local tempView = self.ctn_node.view
            local tempHeroId = self.ctn_node.heroId
            --local srcView = self.startMcView.currentView.panel_1.ctn_player.view
            local targetView = targetMc.currentView.panel_1.ctn_player.view
            if targetView then
                targetView:parent(self.startMcView.currentView.panel_1.ctn_player):pos(0,-50)
                targetView:zorder(-1)
            end
            self.startMcView.currentView.panel_1.ctn_player.view = targetView
            self.startMcView.heroId = targetMc.heroId
            --显示属性文字
            --local prop = TeamFormationModel:getPropByPartnerId( self.startMcView.heroId )
            local prop = FuncTeamFormation.getPropByTaiZi( pIdx )
            if prop>=1 and prop<=3 and self.startMcView.heroId ~= nil and tostring(self.startMcView.heroId) ~= "0" then
                self.startMcView.currentView.panel_1.mc_1:visible(true)
                self.startMcView.currentView.panel_1.mc_1:showFrame(prop)
                self.startMcView.currentView.panel_1.mc_1.currentView["txt_"..prop]:setString(FuncTeamFormation.getPropTxt(prop))
            else
                self.startMcView.currentView.panel_1.mc_1:visible(false)
            end

            tempView:parent(targetMc.currentView.panel_1.ctn_player):pos(0,-50)
            tempView:zorder(-1)
            targetMc.currentView.panel_1.ctn_player.view = tempView
            --显示属性文字
            targetMc.heroId = tempHeroId
            --prop = TeamFormationModel:getPropByPartnerId( targetMc.heroId )
            prop = FuncTeamFormation.getPropByTaiZi( targetIdx )
            if prop>=1 and prop<=3 and targetMc.heroId ~= nil and tostring(targetMc.heroId) ~= "0" then
                targetMc.currentView.panel_1.mc_1:visible(true)
                targetMc.currentView.panel_1.mc_1:showFrame(prop)
                targetMc.currentView.panel_1.mc_1.currentView["txt_"..prop]:setString(FuncTeamFormation.getPropTxt(prop))
            else
                targetMc.currentView.panel_1.mc_1:visible(false)
            end



            local srcView = self.startMcView.currentView.panel_1.ctn_player.view
            if srcView then
                local currentFrame =srcView:getCurrentFrame()
                srcView:gotoAndPlay(currentFrame)
            end
            --srcView:playLabel("stand",true)
            
            targetView = targetMc.currentView.panel_1.ctn_player.view
            if targetView then
                local  currentFrame =targetView:getCurrentFrame()
                targetView:gotoAndPlay(currentFrame)
            end

            --更新原 位置
            TeamFormationModel:updatePartner(pIdx,self.startMcView.heroId)
            --更新目标位置
            if targetIdx ~= 0 then
                TeamFormationModel:updatePartner(targetIdx,targetMc.heroId)
            end



            


            if srcView then
                srcView:opacity(255)
            end
            if targetView then
                targetView:opacity(255)
            end
            --暂时这么写，需要优化
            self:delayCall(c_func(self.initFormation,self),0.02)
            --self:initFormation()
            self:clearCtnNode()
            self.startMcView = nil
            self.startPos = nil
            self.viewSrcPos = nil
            self.moveIng = nil
        end
    end
end

--[[
清空之间节点node
]]
function TeamFormationView:clearCtnNode(  )
    self.ctn_node:removeAllChildren()
    self.ctn_node.view = nil
    self.ctn_node.heroId = nil
end




---  ===============================================================  --
--                  began move end 事件  处理
---  ===============================================================  --




--[[
获取当前手指一动到的mc 返回 pIndex 1-6
]]
function TeamFormationView:chkEnterMc( globelPosX,globelPosY )
    local targetIdx = -1
    for k=1,6,1 do
        if self["mc_tai"..k].isOpen then
            --已经开启的情况
            local nd = self["mc_tai"..k].currentView.panel_1.ctn_player.nd
            local localPos = nd:convertToNodeSpace(cc.p(globelPosX,globelPosY))
            if cc.rectContainsPoint(cc.rect(0,0,80,140),localPos) then
                targetIdx = k
                break
            end
        end
    end
    return targetIdx
end



--[[
这里只更换view别的都不更换这样在end事件中，直接更换更改和结束就可以了
]]
function TeamFormationView:moveToMc( targetMc,srcMc )
    --srcMc.currentView.panel_1.ctn_player.view and
    if  srcMc.currentView.panel_1.ctn_player.view then
        local tempView = targetMc.currentView.panel_1.ctn_player.view
        srcMc.currentView.panel_1.ctn_player.view:parent(targetMc.currentView.panel_1.ctn_player):pos(0,-50)
        targetMc.currentView.panel_1.ctn_player.view = srcMc.currentView.panel_1.ctn_player.view
        if tempView and self.ctn_node.view ~= tempView then
            tempView:parent(srcMc.currentView.panel_1.ctn_player):pos(0,-50)
            srcMc.currentView.panel_1.ctn_player.view = tempView
        else
            srcMc.currentView.panel_1.ctn_player.view = nil
        end
    end
end





--===================================数据接上要优化==============================================--

--[[
关闭
]]
function TeamFormationView:doBackClick(  )
    --self:doFormationClick()
    self:startHide()
end




--[[
一键上阵
]]
function TeamFormationView:doFormationByOneKey(  )
    TeamFormationModel:allOnFormation(  )
    --刷新对应的cell
    self.scroll_1:refreshCellView(1)
    self:updateFormationTreas()
    self:initFormation()
    --一键布阵音效
    AudioModel:playSound(MusicConfig.s_formation_yijian)
    WindowControler:showTips( {text="一键布阵成功"} )
    
end


--[[
完成
点击保存保存阵型
]]
function TeamFormationView:doOKClick(  )
    self:doFormationClick()
end




--[[
点击开始战斗
]]
function TeamFormationView:doBattleClick(  )
    echo("点击开始战斗")

    --self:doFormationClick(true)
    TeamFormationModel:saveLocalData()
    
    --WindowControler:showBattleWindow("ArenaBattleLoading", self.loadParams)
    --BattleControler:startBattleInfo(self.battleData)
    -- if self.callBack then
    --     self.callBack()
    -- end
    --self:startHide()
    --dump(self.params)
    FuncPvp.onChallengePlayerEvent(self.params,c_func(self.doBattle,self,self.params))

end



function TeamFormationView:doBattle(params,_event )
    -- echo("战斗回调=======================")
    -- dump(params)
    -- echo("=============================")
    -- dump(_event.result.data)
    -- echo("战斗回调=======================")
    local _battleInfo  = _event.result.data
    _battleInfo.battleLabel = GameVars.battleLabels.pvp 

    if not FuncPvp.processChallengeErrorEvent(_event) then
        self:startHide()
        WindowControler:showBattleWindow("ArenaBattleLoading", params)
        BattleControler:startBattleInfo(_battleInfo)
    end

end




return TeamFormationView;
