local TeamChooseTreasureView = class("TeamChooseTreasureView", UIBase);







--[[
@params winName:窗口名字
@params 当前使用的法宝
@params onCloseCallBack
@params pIdx 1 == 左侧法宝 2 == 右侧法宝
]]
function TeamChooseTreasureView:ctor(winName,onCloseBack,sytemId,pIdx)
    TeamChooseTreasureView.super.ctor(self, winName);
    self.onCloseCallBack = onCloseBack
    self.systemId = sytemId

    self.pIdx = pIdx
end

function TeamChooseTreasureView:loadUIComplete()
	self:registerEvent()
    self:uiAdjust()

    self:initView()
end 

function TeamChooseTreasureView:registerEvent()
	TeamChooseTreasureView.super.registerEvent();
    self:registClickClose("out")

    --self.btn_back:setTap(c_func(self.doBackClick,self))
end



--[[
UI多分辨率适配
]]
function TeamChooseTreasureView:uiAdjust(  )
    --FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop);
end


--[[
初始化 view
]]
function TeamChooseTreasureView:initView(  )
    -- body
    self.panel_1:visible(false)

    self:initSelectItem()

    self:initData()

    self:initTreaList()


    --增加一个node用于下面的点击事件  关闭node
    local touchNode = display.newNode()
    local conentSize = self.scale9_1:getContentSize()
    local px,py = self.scale9_1:getPosition()

    touchNode:setContentSize(cc.size(conentSize.width,GameVars.maxResHeight))
    touchNode:anchor(0,0)
    touchNode:addto(self.scale9_1:getParent()):pos(px,py-conentSize.height-GameVars.maxResHeight)
    :setTouchedFunc( c_func(self.startHide,self) )



end



function TeamChooseTreasureView:initSelectItem(  )
    for i = 1,2 do
        self["mc_fbzt"..i]:visible(false)
        self["panel_jiantou"..i]:visible(false)
    end
    local treaId = TeamFormationModel:getCurTreaByIdx(self.pIdx )
    local mc
    if self.pIdx == 1 then
        --左侧法宝
        self.mc_fbzt1:visible(true)
        self.panel_jiantou1:visible(true)
        mc = self.mc_fbzt1
    else
        --右侧法宝
        self.mc_fbzt2:visible(true)
        self.panel_jiantou2:visible(true)
         mc = self.mc_fbzt2
    end
    if tostring(treaId) == "0" then 
        mc:showFrame(2)
    else
        local treaData = TeamFormationModel:getTreaById( treaId )
        mc:showFrame(1)


        local view = mc.currentView.panel_fbzt2
        view.ctn_goodsicon:removeAllChildren()
    
        --判断是否推荐
        local tuijian = false
        view.panel_tuijian:visible(tuijian)

        --级别
        view.txt_1:setString(treaData.level)

        --是否上阵
        local shangzhen = TeamFormationModel:chkTreaInFormation(treaData.id )
        shangzhen = false
        view.panel_duihao:visible(shangzhen)

        view.mc_1:showFrame(treaData.star)
        view.ctn_goodsicon:addChild( display.newSprite(FuncRes.iconTreasure(treaData.id) ):size(80,80) )




    end
end




--[[
初始化法宝数据
]]
function TeamChooseTreasureView:initData(  )
    -- body
    --echo("初始化法宝数据")

    self.treaData = TeamFormationModel:getAllTreas(  )

    -- echo("所有的法宝数据")
    -- dump(self.treaData)
    -- echo("所有的法宝数据")
end


--[[
初始化法宝列表
]]
function TeamChooseTreasureView:initTreaList(  )
    echo("初始化法宝列表")
    local treaData = self.treaData

    
    local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_1);
        --初始化法宝
        self:updateItem(view,itemData)

        --view:setTouchedFunc(c_func(self.doChooseTreas,self,view,itemData))
        return view
    end


    local updateCellFunc = function ( data,view )
        self:updateItem(view, data)
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
    self.scroll_1:styleFill(params)

end


--[[
更新某一项法宝数据
]]
function TeamChooseTreasureView:updateItem( view,itemData )

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
    view.ctn_goodsicon:addChild( display.newSprite(FuncRes.iconTreasure(itemData.id) ):size(80,80) )
    view.data = itemData
    if shangzhen then
        table.insert(self.itemArr, view)
    end


    view.ctn_goodsicon:setTouchedFunc(c_func(self.doItemClick,self,view))

end


function TeamChooseTreasureView:updateItemByChoose(  )
    local arr = self.itemArr
    self.itemArr = {}
    for k,v in pairs(arr) do
        self:updateItem( v,v.data )
    end
end



function TeamChooseTreasureView:doItemClick(view)
    --echo("点击某个item",view.data.id,"============")
    local isHas = TeamFormationModel:chkTreaInFormation( view.data.id )
    if not isHas then
        TeamFormationModel:updateTrea( self.pIdx,view.data.id )
        table.insert(self.itemArr, view)
        self:updateItemByChoose()
        self:initSelectItem()
        
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
    self:startHide()
end


--[[
关闭
]]
function TeamChooseTreasureView:startHide(  )
    --echo("开始关闭-------")
    if self.onCloseCallBack then
        self.onCloseCallBack(self)
    end
    TeamChooseTreasureView.super.startHide(self)
end

--[[
选择某个法宝
@params:view     某一个view
@params:itemData 某一项数据
]]
-- function TeamChooseTreasureView:doChooseTreas(view,itemData )
    
-- end



return TeamChooseTreasureView;
