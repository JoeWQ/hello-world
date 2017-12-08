--
-- User: zhangyanguang
-- Date: 2015/5/22
-- 公用UI设置

FuncCommUI = FuncCommUI or {}

UIAlignTypes= {
    Left = 1,              --左对齐
    LeftTop = 2,           --左上对齐
    MiddleTop = 3,         --居中顶对齐
    RightTop = 4,          --右上对齐

    Right = 5,             --右对齐
    RightBottom = 6,       --右底对齐
    MiddleBottom = 7;      --居中底对齐
    LeftBottom = 8,        --左底对齐
    Middle=9,--保持居中,一般只用在Scale9Sprite的缩放上
}




FuncCommUI.COLORS = {
	TEXT_RED = cc.c3b(255,39,0),
	TEXT_WHITE = cc.c3b(255,255,255),
}
--//居中缩放,用于页面的背景适配,只适配纵向
function FuncCommUI.setViewAlignByCenter(_view,_scaleX,_scaleY)
    local  x,y=_view:getPosition();
    local _size=_view:getContainerBox();
    local _anchorPoint=_view:getAnchorPoint();

--    local  _newx=x+_size.width/2;
 --   local  _newy=y+_size.height/2;
    _view:setAnchorPoint(cc.p(0.5,0.5));
    _view:setPosition(cc.p(x,y+_size.height*(_scaleY-1.0)/2));
    _view:setScaleY(_scaleY);
--//恢复成原来的锚点
end



--scale9缩放规则,alignType 对齐方式,withScaleX x方向缩放拉长系数,会在左右2边均匀加长
--withScaleX x方向缩放拉长系数,会在上下均匀加长 
--withScaleX 是一个比例值 
--如果传空或者0表示不缩放 传其他表示按照 withScaleX*( GameVars.width  - GAMEWIDTH )宽度缩放
--withScaleY也是同理  
--moveScale 表示移动的系数 默认是1 ,也就是说 1136机器 靠左对其 只移动 (1136-960)/2 * moveScale这个多像素
--[[
    示例 机型是 1136*768
    FuncCommUI.setScale9Align( scale9Sprite,UIAlignTypes.MiddleTop,1,0 )
    表示让 scale9Sprite 居中朝上对其,x方向 会让这个scale9左右各自加长 (1136-960) *withscaleX /2的宽度 
    scroll的适配同样如此
]]
function FuncCommUI.setScale9Align( view,alignType,withScaleX,withScaleY ,moveScale)
    local spSize = view:getContentSize()
    local offsetX =0
    local offsetY =0

    if withScaleX then
        spSize.width = spSize.width +  (GameVars.width  - GAMEWIDTH )*withScaleX
        offsetX = - (GameVars.width  - GAMEWIDTH )*withScaleX /2
    end

    if withScaleY then
        spSize.height = spSize.height +( GameVars.height  - GAMEHEIGHT  ) * withScaleY
        offsetY = ( GameVars.height  - GAMEHEIGHT  ) * withScaleY/2
    end
    moveScale = moveScale or 1
    view:setContentSize(spSize)
    view:offsetPos(offsetX * moveScale, offsetY *moveScale)
    FuncCommUI.setViewAlign(view,alignType)

end

function FuncCommUI.setScale9Scale(view,withScaleX,withScaleY)
    local spSize = view:getContentSize()
    local offsetX = 0
    local offsetY = 0
    withScaleX = withScaleX or 1
    withScaleY = withScaleY or 1

    if withScaleX then
        spSize.width = spSize.width *  withScaleX
    end

    if withScaleY then
        spSize.height = spSize.height * withScaleY
    end

    view:setContentSize(spSize)
end

--参数格式 和 setScale9Align 一样
function FuncCommUI.setScrollAlign( scroll,alignType,withScaleX,withScaleY ,moveScale)
    
    local offsetX =0
    local offsetY =0

    local rect = scroll:getViewRect()
    moveScale = moveScale or 1
    if withScaleX then
        offsetX =  - (GameVars.width  - GAMEWIDTH )*withScaleX /2
        rect.width = rect.width +  (GameVars.width  - GAMEWIDTH )*withScaleX
    end

    if withScaleY then
        offsetY = ( GameVars.height  - GAMEHEIGHT  ) * withScaleY/2
        rect.height = rect.height + ( GameVars.height  - GAMEHEIGHT  ) * withScaleY
    end
    rect.y = -rect.height 
    scroll:updateViewRect(rect)
    scroll:offsetPos(offsetX*moveScale, offsetY*moveScale)
    FuncCommUI.setViewAlign(scroll,alignType)
end


--设置view对其
--moveScale 表示移动的系数 默认是1 ,也就是说 1136机器 靠左对其 只移动 (1136-960)/2 * moveScale这个多像素
function FuncCommUI.setViewAlign(view,alignType,moveScaleX , moveScaleY)
    -- print("\n\n setViewAlign=============================== \n\n");
    if view == nil then
        return ;
    end
    moveScaleX = moveScaleX or 1
    moveScaleY = moveScaleY or 1
    local offsetX = 0
    local offsetY = 0
    if alignType == UIAlignTypes.Left then
        offsetX = - GameVars.UIOffsetX
    elseif alignType == UIAlignTypes.LeftTop then
        offsetX = - GameVars.UIOffsetX
        offsetY =   GameVars.UIOffsetY

    elseif alignType == UIAlignTypes.MiddleTop then
        offsetY =   GameVars.UIOffsetY

    elseif alignType == UIAlignTypes.RightTop then
        offsetX =   GameVars.UIOffsetX
        offsetY =   GameVars.UIOffsetY
    elseif alignType == UIAlignTypes.Right then
        offsetX =   GameVars.UIOffsetX
    elseif alignType == UIAlignTypes.RightBottom then
        offsetX =   GameVars.UIOffsetX
        offsetY = - GameVars.UIOffsetY
    elseif alignType == UIAlignTypes.MiddleBottom then
        offsetY = - GameVars.UIOffsetY

    elseif alignType == UIAlignTypes.LeftBottom then
        offsetX = - GameVars.UIOffsetX
        offsetY = - GameVars.UIOffsetY
    end
    view:offsetPos(offsetX*moveScaleX, offsetY*moveScaleY)
    -- print("后(x,y)",view:getPositionX(),view:getPositionY());
end



--朝中下对齐的场景 针对战斗场景
function FuncCommUI.setViewAlignByDown(view,alignType)
    -- print("\n\n setViewAlign=============================== \n\n");
    if view == nil then
        return;
    end
    -- print("前(x,y)",view:getPositionX(),view:getPositionY());
    if alignType == UIAlignTypes.Left then
        view:setPositionX(view:getPositionX() - GameVars.UIOffsetX);
    elseif alignType == UIAlignTypes.LeftTop then
        view:setPositionX(view:getPositionX() - GameVars.UIOffsetX);
        view:setPositionY(view:getPositionY() + GameVars.UIOffsetY*2);
    elseif alignType == UIAlignTypes.MiddleTop then
        view:setPositionY(view:getPositionY() + GameVars.UIOffsetY*2);

    elseif alignType == UIAlignTypes.RightTop then
        view:setPositionX(view:getPositionX()+GameVars.UIOffsetX);
        view:setPositionY(view:getPositionY() + GameVars.UIOffsetY*2);
    elseif alignType == UIAlignTypes.Right then
        view:setPositionX(view:getPositionX()+GameVars.UIOffsetX);
    elseif alignType == UIAlignTypes.RightBottom then
        view:setPositionX(view:getPositionX()+GameVars.UIOffsetX);
        view:setPositionY(view:getPositionY() );
    elseif alignType == UIAlignTypes.MiddleBottom then
        -- 空实现

    elseif alignType == UIAlignTypes.LeftBottom then
        view:setPositionX(view:getPositionX() - GameVars.UIOffsetX);
    end

    -- print("后(x,y)",view:getPositionX(),view:getPositionY());
end


--[[
    bar 可以是圆形bar  也可以是水平bar
    targetPercent 目标百分比
    frame 缓动帧数 默认20帧 

]]

function FuncCommUI.tweenProgressBar(bar,targetPercent,frame,callBack)
    bar:tweenToPercent(targetPercent,frame,callBack)
end

-- 滚动文本框中的数字
--[[
    frame 持续帧数
    bits,  精确到的位数  默认是 个位 也就是0 
    callBack 回调
]]
function FuncCommUI.tweenTxtNum(txt,beginNum,endNum,frame, bits, callBack)
    if endNum == beginNum then
        if callBack then
            callBack()
        end
        return
    end
    frame = frame or 10

    bits = bits or 0

    local perNum = ( (endNum - beginNum) / frame )
    local p = math.pow(10,bits)
    perNum = math.ceil( perNum/p ) * p

    if perNum ==0 then
        return
    end
    --先移除事件  因为有可能重复注册
    txt:unscheduleUpdate()
    local bNum = beginNum
    local count = 1;
    local listener = function (dt)
        count = count + 1
        bNum = bNum +  perNum
        txt:setString(tostring(bNum) )

        frame = frame -1
        if frame == 0 then
            txt:setString(tostring(endNum))
            txt:unscheduleUpdate()
            if callBack then
                callBack()
            end

        elseif  (endNum - bNum) / perNum < 1 then
            txt:setString(tostring(endNum))
            txt:unscheduleUpdate()
            if callBack then
                callBack()
            end

        end

    end
    txt:scheduleUpdateWithPriorityLua(listener, 0) 
end

-- 获得遮罩层
function FuncCommUI.getMaskCan(maskSprite, contentNode,...)
	local clipper = cc.ClippingNode:create()
    clipper:setCascadeOpacityEnabled(true)
    clipper:setOpacityModifyRGB(true)
	clipper:setStencil(maskSprite)
    clipper:setInverted(false)
    clipper:setAlphaThreshold(0.01)
    contentNode:parent(clipper)
    local args = {...}
    if args and #args >0 then
        for i,v in ipairs(args) do
            v:parent(clipper)
        end
    end

    return clipper
end

--GoldTopView 用法已废弃
---- 加入GoldTopView
--function FuncCommUI.addGoldTopView(level)
--    local viewNameTag = "GoldTopView"
--     -- 加载金币公共组件
--    local scene = display.getRunningScene()
--    local goldTopView = scene._root:getChildByName(viewNameTag)
--    if goldTopView ~= nil then
--        goldTopView:setVisible(true)
--    else
--        goldTopView = WindowControler:createWindowNode("GoldTopView")
--        goldTopView:setName(viewNameTag)
--        goldTopView:setPositionX(290)
--        scene._root:addChild(goldTopView)
--    end

--    if level ~= nil then
--        goldTopView:zorder(level)
--    else
--        goldTopView:zorder(100)
--    end
--end

---- 移除GoldTopView
--function FuncCommUI.removeGoldTopView()
--    local scene = display.getRunningScene()
--    scene._root:removeChildByName("GoldTopView", true)
--end

---- 隐藏GoldTopView
--function FuncCommUI.hideGoldTopView()
--    local scene = display.getRunningScene()
--    local goldTopView = scene._root:getChildByName("GoldTopView")
--    if goldTopView ~= nil then
--        goldTopView:setVisible(false)
--    end
--end

-- 加入LogsView
function FuncCommUI.addLogsView()

    local logsView = WindowControler:createWindowNode("LogsView")
    logsView:zorder(99999)
    logsView:setName("LogsView")

    local scene = display.getRunningScene()
    scene._topRoot:addChild(logsView)
end

function FuncCommUI.addGmEnterView()
    local GMEnterView = WindowControler:createWindowNode("GMEnterView")
    GMEnterView:zorder(99999)
    GMEnterView:setName("GMEnterView")

    GMEnterView:setPosition(50, 600);

    local scene = display.getRunningScene()
    scene._topRoot:addChild(GMEnterView)

end


-- 移除LogsView
function FuncCommUI.removeLogsView()
    local scene = display.getRunningScene()
    scene._root:removeChildByName("LogsView", true)
end

-- 加入pve匹配view
function FuncCommUI.addPVEMatchView()
    local matchView = WindowControler:createWindowNode("PVEEliteMatchView")
    matchView:zorder(99999)
    matchView:setName("PVEEliteMatchView")

    local scene = display.getRunningScene()
    scene._root:addChild(matchView)
end

-- 移除pve匹配view
function FuncCommUI.removePVEMatchView()
    local scene = display.getRunningScene()
    scene._root:removeChildByName("PVEEliteMatchView", true)
end


local _inputView

--开始输入     传入一个回调  callBack("haha",1) 2个参数 输入结果 和方式 1是确定 0是取消
function FuncCommUI.startInput(curstr, callBack,inputParams )
    if not _inputView then
        _inputView = WindowControler:createWindowNode("InputView")
        _inputView:visible(false)
        local scene = WindowControler:getCurrScene()
        _inputView:addto(scene._topRoot,WindowControler.ZORDER_INPUT)
    end
    _inputView:startInput(curstr,callBack,inputParams)

end

--全屏奖励界面5个以下
function FuncCommUI.startFullScreenRewardView(itemArray, callBack)
    WindowControler:showWindow("RewardSmallBgView", itemArray, callBack);
end 

--缓存的奖励数组
local cacheRewardArr = {}
--当前是否在运动中
local isMoving = false

MOVE_TIP_TYPE = {
    TYPE_RES_REWARD = 1,
    TYPE_FIGHT_ATTR = 2
}
FuncCommUI.offsetX=GameVars.cx
FuncCommUI.offsetY=GameVars.height - 340
FuncCommUI.TipHeight=60;--//弹出奖励UI的高度
FuncCommUI.FixedSpeedY=60;--//纵向飘动的速度
FuncCommUI.scheduleController=nil;--//回调函数控制器,需要手工进行销毁
FuncCommUI.TipSequence={} --//弹出提示队列
FuncCommUI.TimeInterval={[1]=0.24,[2]=0.04,[3]=0.24,[4]=0.8,[5]=0.25};
--//弹出记录的状态
local    RewardTipState={
     TipState_Born=0,--//刚产生
     TipState_FadeIn=1,--//透明度开始变化,淡入
     TipState_Delay1=2,--//第一次停留
     TipState_Move=3,--//开始移动
     TipState_Delay2=4,--//第二次停留
     TipState_FadeOut=5,--//开始淡出
 }
--弹出奖励UI队列
local  scheduler = require("framework.scheduler")
--弹出奖励道具数组   奖励格式 [ "1,101,1", "3,100",    ] 直接传递配置表的格式 或者服务器回来的格式 
--通用奖励格式
function FuncCommUI.startRewardView( rewardArr,rewardType )
    local tipType = rewardType or MOVE_TIP_TYPE.TYPE_RES_REWARD
    for i,v in ipairs(rewardArr) do
        local tipData = {}
        tipData.data = v
        tipData.tipType = tipType
        --将需要奖励的 道具 缓存起来
        table.insert(cacheRewardArr, tipData)
    end

--    if isMoving then
--        return 
--    end
    FuncCommUI.resumeMove()
    AudioModel:playSound(MusicConfig.s_com_reward);
    
    
end


--复原
function FuncCommUI.resumeMove()
--    isMoving =false
    while(#cacheRewardArr>0)do
        local tipData = cacheRewardArr[1].data
        local tipType = cacheRewardArr[1].tipType
--        FuncCommUI.startMoving(tipData,tipType)
        FuncCommUI.insertTipMessage(tipData,tipType);
        table.remove(cacheRewardArr,1)
    end

end

-- 根据tip类型，创建对应的view
function FuncCommUI.createMoveTipView(tipType)
    local tipView = nil
    if tipType == nil or tipType == MOVE_TIP_TYPE.TYPE_RES_REWARD then
        tipView = WindowsTools:createWindow("TipItemView")
    elseif tipType == MOVE_TIP_TYPE.TYPE_FIGHT_ATTR then
        tipView = WindowsTools:createWindow("TipFightAttrView")
    end

    return tipView
end
-- //获取基本类型时弹出式页面
function FuncCommUI.showTipMessage(_resType, _resCount)
    FuncCommUI.startRewardView({_resType ..",".._resCount} )
end
--//将给定的数据转换成弹出提示框,并初始化相关的数据结构
function FuncCommUI.insertTipMessage(tipData,tipType)
    local scene = WindowControler:getScene()

    local scale=scene:getScale()
    local ui = FuncCommUI.createMoveTipView(tipType)
    ui:pos(FuncCommUI.offsetX,FuncCommUI.offsetY):addto(scene,9999)
    ui:setRewardInfo(tipData)
--//初始隐藏
    ui:setCascadeColorEnabled(true);
    ui:setOpacity(0);
    ui.tipState=RewardTipState.TipState_FadeIn;
    ui.delayTime=0;--//提示框处于该状态已经持续的时间
    ui.originY=ui:getPositionY();
--//插入到调度队列中
    table.insert(FuncCommUI.TipSequence,ui)
--//开始调度
   if(not FuncCommUI.scheduleController)then
          FuncCommUI.scheduleController=scheduler.scheduleGlobal(FuncCommUI.startMoving,0);
   end
end
---//调度队列
function FuncCommUI.startMoving(_deltaTime)
--//队列为空,就停止调度器
    if(#FuncCommUI.TipSequence<=0)then
             scheduler.unscheduleGlobal(FuncCommUI.scheduleController);
             FuncCommUI.scheduleController=nil;
             return;
    end
--//从下一个UI开始,依次向下遍历,所有的UI位置由上一个决定
    local  last_ui=nil;
    local  select_index=0;--//从select_index开始依次向上遍历,高度增加
    local _index=1;
--    echo("delta time:",_deltaTime);
    while(_index<=#FuncCommUI.TipSequence) do
            local  ui=FuncCommUI.TipSequence[_index];
            if(last_ui~=nil and last_ui:getPositionY()-ui:getPositionY()<FuncCommUI.FixedSpeedY and ui.tipState==RewardTipState.TipState_FadeIn)then--//此时以下的UI是不能调度的
                   break;
            end
            if(ui.tipState==RewardTipState.TipState_FadeIn)then
                  ui.delayTime=ui.delayTime+_deltaTime;
                  rate=_deltaTime/FuncCommUI.TimeInterval[RewardTipState.TipState_FadeIn];
                  local  opacity=64+191*rate;
                  select_index=_index;
                  if( ui.delayTime>=FuncCommUI.TimeInterval[RewardTipState.TipState_FadeIn])then
                         ui:setOpacity(255);
                         ui.tipState=RewardTipState.TipState_Move;
                         ui.delayTime=ui.delayTime-FuncCommUI.TimeInterval[RewardTipState.TipState_FadeIn];
                         ui:setPositionY(ui:getPositionY()+FuncCommUI.FixedSpeedY*rate);
                  else
                         ui:setOpacity(opacity);
                         ui:setPositionY(ui:getPositionY()+FuncCommUI.FixedSpeedY*rate);
                 end
           elseif(ui.tipState==RewardTipState.TipState_Move)then
                 ui.delayTime=ui.delayTime+_deltaTime;
                 rate=_deltaTime/FuncCommUI.TimeInterval[RewardTipState.TipState_Move];
                 select_index=_index;
                if(ui.delayTime>=FuncCommUI.TimeInterval[RewardTipState.TipState_Move])then
                      ui.delayTime=ui.delayTime-FuncCommUI.TimeInterval[RewardTipState.TipState_Move];
                      ui.tipState=RewardTipState.TipState_Delay2;--//进入第二阶段延迟
                      ui:setPositionY(ui:getPositionY()+FuncCommUI.FixedSpeedY*rate);
                else
                      ui:setPositionY(ui:getPositionY()+FuncCommUI.FixedSpeedY*rate);
                end
          elseif(ui.tipState==RewardTipState.TipState_Delay2)then--//第二阶段延迟
                ui.delayTime=ui.delayTime+_deltaTime;
                if(ui.delayTime>=FuncCommUI.TimeInterval[RewardTipState.TipState_Delay2])then
                     ui.delayTime=ui.delayTime-FuncCommUI.TimeInterval[RewardTipState.TipState_Delay2];
                     ui.tipState=RewardTipState.TipState_FadeOut;
               end
         elseif(ui.tipState==RewardTipState.TipState_FadeOut)then
               ui.delayTime=ui.delayTime+_deltaTime;
               rate=ui.delayTime/FuncCommUI.TimeInterval[RewardTipState.TipState_FadeOut];
               if(ui.delayTime>=FuncCommUI.TimeInterval[RewardTipState.TipState_FadeOut])then--//如果超过了事件限制,删除掉这个UI
                     table.remove(FuncCommUI.TipSequence,1);
                     local  nextState=0;
                     local  nextTime=0
                     if(1<=#FuncCommUI.TipSequence)then
                              nextState=FuncCommUI.TipSequence[1].tipState;
                              nextTime=FuncCommUI.TipSequence[1].delayTime
                     end
                     ui:deleteMe();
                     ui=nil;
                     _index=_index-1;--//此种情况在整个函数运行期间至多出现一次
                     if(select_index>0)then
                             select_index=select_index-1;
                     end
               else
                     ui:setOpacity(255*(1.0-rate));
               end
          end
          _index=_index+1;
          last_ui=ui;
    end
--//自底向上遍历
   if(select_index>0)then
         local  from_index=select_index-1;
         local  lastPositionY=FuncCommUI.TipSequence[select_index]:getPositionY();
         for _index2=from_index, 1,-1 do
               local ui=FuncCommUI.TipSequence[_index2];
               local  nowPositionY=ui:getPositionY();
               if(nowPositionY-lastPositionY<FuncCommUI.TipHeight)then--//如果两个UI之间小于UI的高度,此时已经产生了挤压,需要调整距离
                       local offsetY=FuncCommUI.TipHeight-nowPositionY+lastPositionY;
                       ui:setPositionY(nowPositionY+offsetY);
               end
               lastPositionY=ui:getPositionY();
         end
   end
end

-- 展示星级tip view
-- 参数说明
--[[
    raidId:PVE raidID
--]]
function FuncCommUI.regesitShowStarTipView(followView,raidId)
    local currentUi= nil

    local overFunc = function (  )
    end

    local movedFunc = function (  )
    end

    local beginFunc = function (  )
        if followView.checkCanClick then
            if not followView:checkCanClick() then
                return  false
            end
        end

        local scene = WindowControler:getCurrScene()
        currentUi = WindowsTools:createWindow("WorldStarTipView",raidId):addto(scene,100):pos(GameVars.UIOffsetX,
            GameVars.height  - GameVars.UIOffsetY)
        currentUi:startShow(followView)
        currentUi:registClickClose(nil,nil,true,true)
        return true
    end

    followView:setTouchedFunc(beginFunc,nil,false,nil,nil)
end

-- 展示tip View
function FuncCommUI.regesitShowTipView(followView,tipViewName,params,playSound)
    local currentUi= nil
    local overFunc = function (  )
    end

    local movedFunc = function (  )
    end

    local beginFunc = function (  )
        if followView.checkCanClick then
            if not followView:checkCanClick() then
                return  false
            end

             if playSound and AudioModel:isSoundOn() then
                 AudioModel:playSound("s_com_click2")
            end
        end

        local scene = WindowControler:getCurrScene()
        currentUi = WindowsTools:createWindow(tipViewName,params):addto(scene,100):pos(GameVars.UIOffsetX,
            GameVars.height  - GameVars.UIOffsetY)
        currentUi:registClickClose(nil,nil,true,true)
        currentUi:startShow(followView)
        return true
    end

    followView:setTouchedFunc(beginFunc,nil,false,nil,nil)
end

-- params结构
--[[
    skillId = skillId
    level = level
--]]
function FuncCommUI.regesitShowSkillTipView(followView,params,playSound)
    -- FuncCommUI.regesitShowTipView(followView,"TipSkillView",params,playSound)
end

function FuncCommUI.regesitShowPowerTipView(followView, treasureId)
    FuncCommUI.regesitShowTipView(followView,"TreasurePowerTips",treasureId,playSound)
end

function FuncCommUI.regesitShowNpcInfoTipView(followView,npcId,playSound)
    FuncCommUI.regesitShowTipView(followView,"WorldNpcInfoTipView",npcId,playSound)
end

--通用资源tip详细信息显示框 注册资源显示信息
--followView  传递过来进行坐标参照的view,  
--如果followView 是scroll滚动条 里面的一个 子节点, 那么这个 followView 必须有一个checkCanClick方法
-- isSound 这个只用在邮件 试炼里 表示是图标的音效
-- hideTipNum 隐藏tips上的个数
function FuncCommUI.regesitShowResView( followView, resType,resNums,resId , reward ,isSound ,hideTipNum)
    local currentUi= nil
    local overFunc = function (  )
    end
    
    local movedFunc = function (  )

    end

    local beginFunc = function (  )
        if followView.checkCanClick then
            if not followView:checkCanClick() then
                return  false
            end
        end
        if isSound and AudioModel:isSoundOn() then
             AudioModel:playSound("s_com_click2")
        end
        local scene = WindowControler:getCurrScene()
        currentUi = WindowsTools:createWindow("TipItemView2"):addto(scene,100):pos(GameVars.UIOffsetX,GameVars.height  - GameVars.UIOffsetY)
        currentUi:setResInfo(resType,resNums,resId ,reward ,hideTipNum )
        currentUi:registClickClose(nil,nil,true,true)
        currentUi:startShow(followView)
        return true
    end

    followView:setTouchedFunc(beginFunc,nil,false,nil,nil)
end

-- 播放宝箱奖品item动画
function FuncCommUI.playRewardItemAnim(ctnNode,changeNode)
    local anim = FuncArmature.createArmature("UI_common_chutubiao",ctnNode, false, GameVars.emptyFunc)
    FuncArmature.changeBoneDisplay(anim , "node1", changeNode)
    anim:pos(0,0)
    anim:startPlay(false)

    return anim
end

-- 播放奖品item动画
function FuncCommUI.playLotteryRewardItemAnim(rewardItem,_time,callBack)
    rewardItem:setVisible(true)
    local time = _time or 0.4
    local scaleAction = rewardItem:getScaleAnimByPos(0,0,0)
    local scaleAction2 = rewardItem:getScaleAnimByPos(time,1.0,1.0)

    rewardItem:opacity(0)
    local alphaAction = act.fadein(time)
    local itemAnim = cc.Spawn:create(scaleAction2,alphaAction)

    rewardItem:stopAllActions()
    rewardItem:runAction(
        cc.Sequence:create(scaleAction,itemAnim)
    )

    if callBack then
        rewardItem:delayCall(c_func(callBack), time)
    end
end


-- 播放奖品item动画
function FuncCommUI.playRewardItemAnim_old(rewardItem,_time,callBack)
    rewardItem:setVisible(true)
    local time = _time or 0.4
    local scaleAction = rewardItem:getScaleAnimByPos(0,0,0)
    local scaleAction2 = rewardItem:getScaleAnimByPos(time,1.0,1.0)

    rewardItem:opacity(0)
    local alphaAction = act.fadein(time)
    local itemAnim = cc.Spawn:create(scaleAction2,alphaAction)

    rewardItem:stopAllActions()
    rewardItem:runAction(
        cc.Sequence:create(scaleAction,itemAnim)
    )

    if callBack then
        rewardItem:delayCall(c_func(callBack), time)
    end
end

-- 播放FadeIn动画
function FuncCommUI.playFadeInAnim(itemView,_time,callBack)
    itemView:setVisible(true)
    local time = _time or 0.4
    itemView:opacity(0)
    local alphaAction = act.fadein(time)

    itemView:stopAllActions()
    itemView:runAction(
        cc.Sequence:create(alphaAction)
    )

    if callBack then
        itemView:delayCall(c_func(callBack), time)
    end
end


-- 设置背景全屏
-- direction 1表示水平 2 垂直方向
function FuncCommUI.setBgFullScreen(bg,direction)
    -- 背景条拉伸及适配
    local bgRect = bg:getContainerBox()

    if direction == 1 then
        local scaleX = GameVars.width / bgRect.width
        bg:setScaleX(scaleX)
        bg:setPositionX(- GameVars.UIOffsetX)
        FuncCommUI.setViewAlign(bg,UIAlignTypes.MiddleTop) 
    elseif direction == 2 then
        local scaleY = GameVars.height / bgRect.height
        bg:setScaleY(scaleY)
        bg:setPositionY(GameVars.UIOffsetY)
        FuncCommUI.setViewAlign(bg,UIAlignTypes.Left) 
    end
end

-- 在view上添加全屏全黑背景
function FuncCommUI.addBlackBg(view,_opacity)
    local bg = FuncRes.a_black(GameVars.width,GameVars.height):anchor(0,1)
    bg:pos(- GameVars.UIOffsetX,GameVars.UIOffsetY)
    bg:opacity(_opacity or 200)
    view:addChild(bg,-10)
end


--创建粒子拖尾效果
--[[
    fromPos {x=100,y=100},初始位置
    endPos  结束位置
    time  缓动时间
    image  图片路径url test/test_img_xiaohong.png
    wid     粒子的显示尺寸
    color   颜色 cc.c3b
    endFunc     缓动结束函数
    endClear    缓动结束后是否自动删除
]]
function FuncCommUI.createMotionStreak(way, fromPos,toPos,time,image,wid, color, endFunc,endClear )

    local nd = display.newNode()

    local sp = display.newSprite(image):size(wid,wid)
    -- wid = sp:getContentSize().width
    local motionStreak = cc.MotionStreak:create(0.8,wid,wid,color,image)
    motionStreak:pos(fromPos):addto(nd)
    sp:pos(fromPos):addto(nd)
    local onComplete = function (  )
        if endClear then
            nd:delayCall(c_func(nd.clear,nd,true ),1)
        end
        if endFunc then
            endFunc()
        end
    end

    local bezier = {  
        cc.p(fromPos.x + 100*way, fromPos.y+100),  
        cc.p(fromPos.x + 150*way, fromPos.y),   
        cc.p(toPos.x, toPos.y),  
      }  
    -- 以持续时间和贝塞尔曲线的配置结构体为参数创建动作  
    local bzto = cc.BezierTo:create(time, bezier)     
    motionStreak:runAction(bzto)

    sp:setOpacity(0)
    transition.moveTo(sp,{x= toPos.x,y = toPos.y, time =time,onComplete=onComplete})
    --transition.moveTo(motionStreak,{x= toPos.x,y = toPos.y, time =time})
    return nd
end




--临时缓存的文本
local cacheTempLabel = nil

function FuncCommUI.initTempLabelCache()
    if not cacheTempLabel then
        cacheTempLabel = cc.Label:create()
        cacheTempLabel:retain()
    end
end

--获取某个字符串的宽度 --通常是用来判断是否是单行还是多行
function FuncCommUI.getStringWidth(str, fontSize,fontName )
	FuncCommUI.initTempLabelCache()
    cacheTempLabel:setSystemFontSize(fontSize)
    cacheTempLabel:setSystemFontName(fontName)
    cacheTempLabel:setString(str)
	cacheTempLabel:setDimensions(0, 0)
    return cacheTempLabel:getContentSize().width
end

--给定内容，字体、字体大小，和固定的宽度，计算文本的高度
function FuncCommUI.getStringHeightByFixedWidth(strContent, fontSize, fontName, fixedWidth)
	FuncCommUI.initTempLabelCache()
	--下面这句会导致ios下文字高度计算问题,注释掉就没问题了
	--local fontName = UIBaseDef:turnFontName(fontName)
	cacheTempLabel:setSystemFontName(fontName)
	cacheTempLabel:setSystemFontSize(fontSize)
	cacheTempLabel:setString(strContent)
	cacheTempLabel:setDimensions(fixedWidth, 0)
	local height = cacheTempLabel:getContentSize().height
	return height
end

--UI_common 中 UI_common_biaoti 动画
FuncCommUI.SUCCESS_TYPE = {
    ["REFINE"] = 1,  --法宝精炼成功
    ["GET"] = 2,  --恭喜获得
    ["OPEN"] = 3,  --恭喜开启
    ["SKILL"] = 4,  --开启新神通
    ["EXTRE"] = 5,  --额外获得
    ["ROMANCE"] = 6,  --新奇缘开启
    ["NEW_TREASURE_GET"] = 7,  --恭喜获得新法宝
    ["NEW_RECORD"] = 8, --历史最高
    ["FINAL"] = 9,  --法宝恭喜圆满
}

-- 播放获得动画
-- compUI:通用获得UI
-- SUCCESS_TYPE:从FuncCommUI.SUCCESS_TYPE中选择枚举值
-- whichBg:1 表示大背景 2 表示小背景
-- showAnyClose:是否显示点击任意关闭，默认不显示
-- align:动画适配，默认是UIAlignTypes.MiddleTop
function FuncCommUI.playSuccessArmature(compUI,SUCCESS_TYPE,whichBg,showAnyClose,align)
    local bgAnimName = nil
    
    local anim = FuncCommUI.createSuccessArmature(SUCCESS_TYPE)
    anim:addto(compUI.ctn_1)
    FuncCommUI.setViewAlign(anim,align or UIAlignTypes.Middle)

    local bgAnim = nil
    if whichBg == 1 then
        anim:pos(0,-50)
        anim:getBone("di2"):setVisible(false);
        local anyCloseAnim =  anim:getBoneDisplay("di1"):getBone("renyi")
        if not showAnyClose then
            anyCloseAnim:setVisible(false)
        end
    elseif whichBg == 2 then
        anim:getBone("di1"):setVisible(false);
        anim:getBone("di2"):setLocalZOrder(-1)

        --往下居中
        anim:setPositionY(anim:getPositionY() - 150);
        local anyCloseAnim =  anim:getBoneDisplay("di1"):getBone("renyi")
        if not showAnyClose then
            anyCloseAnim:setVisible(false)
        end
    end

    return anim;
end

--成功标题
function FuncCommUI.createSuccessArmature(SUCCESS_TYPE)
    --大标题
    FuncArmature.loadOneArmatureTexture("UI_tongyonghuode", nil, true)
    local tittleAni = FuncArmature.createArmature(
        "UI_tongyonghuode_biaoti", nil, false, GameVars.emptyFunc); 
    FuncCommUI.setSuccessArmature(tittleAni,SUCCESS_TYPE)

    return tittleAni;
end

function FuncCommUI.setSuccessArmature(anim, SUCCESS_TYPE)
    local tittleAni = anim
    tittleAni:doByLastFrame(false, false, function ( ... )
            tittleAni:pause(true);
        end);

    local subTittleAni = tittleAni:getBoneDisplay("ziheyun");
    subTittleAni:playWithIndex(0, false)

    tittleAni:getBoneDisplay("saoguang"):getBoneDisplay("layer3_copy"):gotoAndPause(SUCCESS_TYPE);

    local zi = subTittleAni:getBoneDisplay("zi");
    zi:gotoAndPause(SUCCESS_TYPE);
    local zimh = subTittleAni:getBoneDisplay("zimh");
    zimh:gotoAndPause(SUCCESS_TYPE);
    local zimh1 = subTittleAni:getBoneDisplay("zimh1");
    zimh1:gotoAndPause(SUCCESS_TYPE);
    local zimh_copy = subTittleAni:getBoneDisplay("zimh_copy");
    zimh_copy:gotoAndPause(SUCCESS_TYPE);
    local zi2 = subTittleAni:getBoneDisplay("zi2");
    zi2:gotoAndPause(SUCCESS_TYPE);
    local zi_copy = subTittleAni:getBoneDisplay("zi_copy");
    zi_copy:gotoAndPause(SUCCESS_TYPE);

    local yun1 = subTittleAni:getBoneDisplay("yun1");
    yun1:gotoAndPause(SUCCESS_TYPE);

    local yun1_copy = subTittleAni:getBoneDisplay("yun1_copy");
    yun1_copy:gotoAndPause(SUCCESS_TYPE);

    tittleAni:getBoneDisplay("di1"):playWithIndex(0, false)
    tittleAni:getBoneDisplay("di2"):playWithIndex(0, false)
end

--战力变化动画
function FuncCommUI.showPowerChangeArmature(prePower, curPower)
    local ui = WindowsTools:createWindow("PowerRolling", prePower, curPower);
    ui:setScale(0.8);

    FuncArmature.loadOneArmatureTexture("UI_zhanlibianhua", nil, true)

    local RollingNumAni = FuncArmature.createArmature("UI_zhanlibianhua", 
        nil, false, nil);

    FuncArmature.changeBoneDisplay(RollingNumAni, "gunshuzib", ui);

    RollingNumAni:setPosition(GameVars.width / 2 - 20, GameVars.height / 4 * 3);

    --加到场景中
    WindowControler:getScene()._topRoot:addChild(RollingNumAni, 
        WindowControler.ZORDER_PowerRolling);

    RollingNumAni:registerFrameEventCallFunc(7, 1, function ( ... )
        ui:startRolling();   
    end);
end

--[[
带洞的view，只有洞可以响应点击
pos = {x =, y =},点击位置
size = {width =, height = ,},长宽
adjust = {horizontalLayout =, verticalLayout =,},适配策略
touchEndCallBack 点成功的回调
isInBattle 是否在战斗中
               
               size.width
             ------------
            |            |
            |      *(pos)|
            |            |size.height
             ------------

--todo 新手引导改用这个 
]]

ENUM_LAYOUT_POLICY = {
    ["CENTER"] = 0,
    ["LEFT"] = 2,
    ["RIGHT"] = 1,
    ["UP"] = 2,
    ["DOWN"] = 1,
};

local g_listener = nil;

function FuncCommUI.getListenerInHole()
    return g_listener;
end

function FuncCommUI.setATopViewWithAHole(pos, size, layout, touchEndCallBack, isInBattle)
    FuncArmature.loadOneArmatureTexture("UI_qiangzhitishi", nil, true)

    local function createRectTempNode()
        local node = cc.LayerColor:create(
            cc.c4b(0, 255, 0, 200), 10, 10);
        return node;
    end

    local function createGrayLayer()
        local color = cc.c4b(0, 0, 0, 120);

        local graylayer = display.newColorLayer(color):pos(0, 0)
        graylayer:setContentSize(cc.size(GameVars.width, GameVars.height))
        graylayer:setTouchEnabled(false)

        local clipNode = cc.ClippingNode:create();
        local stencilNode = createRectTempNode();

        clipNode:setStencil(stencilNode);

        clipNode:addChild(graylayer);
        clipNode:setInverted(true);
        clipNode:setPosition(0, 0)

        return clipNode, stencilNode;
    end


    --得到坐标差
    local function getDifXandY()
        local diffWidth = GameVars.width - CONFIG_SCREEN_WIDTH;
        local difHeight = GameVars.height - CONFIG_SCREEN_HEIGHT;
        return diffWidth, difHeight;
    end

    --从960*640到当前机器的坐标
    local function adjustToCurPos(pos, horizontalLayout, verticalLayout)
        local difX, difY = getDifXandY();

        if horizontalLayout == ENUM_LAYOUT_POLICY.LEFT and verticalLayout == ENUM_LAYOUT_POLICY.CENTER then
            --左中 done 
            return {x = pos.x, y = pos.y + difY / 2};
        elseif horizontalLayout == ENUM_LAYOUT_POLICY.LEFT and verticalLayout == ENUM_LAYOUT_POLICY.UP then
            --左上 done
            return {x = pos.x, y = pos.y + difY};
        elseif horizontalLayout == ENUM_LAYOUT_POLICY.LEFT and verticalLayout == ENUM_LAYOUT_POLICY.DOWN then 
            --左下 done
            return { x = pos.x, y = pos.y};
        elseif horizontalLayout == ENUM_LAYOUT_POLICY.CENTER and verticalLayout == ENUM_LAYOUT_POLICY.UP then
            --上对齐 done
            return { x = pos.x + difX / 2, y = pos.y + difY};
        elseif horizontalLayout == ENUM_LAYOUT_POLICY.CENTER and verticalLayout == ENUM_LAYOUT_POLICY.DOWN then
            --下对齐 done
            return {x = pos.x + difX / 2, y = pos.y};
        elseif horizontalLayout == ENUM_LAYOUT_POLICY.RIGHT and verticalLayout == ENUM_LAYOUT_POLICY.CENTER then
            --右对齐 done
            return {x = pos.x + difX, y = pos.y + difY / 2};
        elseif horizontalLayout == ENUM_LAYOUT_POLICY.RIGHT and verticalLayout == ENUM_LAYOUT_POLICY.UP then
            --右上对齐 done
            return {x = pos.x + difX, y = pos.y + difY};
        elseif horizontalLayout == ENUM_LAYOUT_POLICY.RIGHT and verticalLayout == ENUM_LAYOUT_POLICY.DOWN then
            --右下 done
            echo(horizontalLayout, horizontalLayout);
            return {x = pos.x + difX, y = pos.y};
        else 
            --CENTER CENTER
            return {x = pos.x + difX / 2, y = pos.y + difY / 2};
        end 
    end

    local function convertToGL(pos)
        local glView = cc.Director:getInstance():getOpenGLView();

        local designResolutionSize = glView:getDesignResolutionSize();

        pos = cc.Director:getInstance():convertToGL(
            {x = pos.x, y = pos.y}); 

        if designResolutionSize.width > GameVars.maxScreenWidth then 
            pos.x = pos.x - (designResolutionSize.width - GameVars.maxScreenWidth) / 2;
        elseif designResolutionSize.height > GameVars.maxScreenHeight then 
            pos.y = pos.y - (designResolutionSize.height - GameVars.maxScreenHeight) / 2;
        end 

        return pos;
    end

    local function isInClickArea(touchX, touchY, pos, size, layout)
        local clickPosGL = convertToGL(
            {x = touchX, y = touchY});  

        local width, height = size.width, size.height;

        local targetPos = adjustToCurPos(pos, 
            layout.horizontalLayout, layout.verticalLayout); 

        local rect = cc.rect(targetPos.x - width / 2, 
            targetPos.y - height / 2, width, height);

        return cc.rectContainsPoint(rect, cc.p(clickPosGL.x, clickPosGL.y));
    end

    local function initClick(topView, touchEndCallBack)
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
        local listener = cc.EventListenerTouchOneByOne:create();

        listener:setSwallowTouches(true);

        local function onTouchBegan(touch, event)
            local uiPos = touch:getLocationInView()
            if isInClickArea(uiPos.x, uiPos.y, pos, size, layout) == true then
                echo("--onTouchBegan in--");
                listener:setSwallowTouches(false);
            else
                echo("--onTouchBegan out--");

                listener:setSwallowTouches(true);
            end 
            return true
        end

        local function onTouchEnded(touch, event)  
            local uiPos = touch:getLocationInView();
            if isInClickArea(uiPos.x, uiPos.y, pos, size, layout) == true then
                --todo 干掉自己
                echo("--onTouchEnded in--");
                if touchEndCallBack ~= nil then 
                    touchEndCallBack();
                end 
                listener:setEnabled(false);
                topView:removeFromParent();
                g_listener = nil;
            else 
                echo("--onTouchEnded out--");
            end 
        end

        listener:registerScriptHandler(onTouchEnded,
            cc.Handler.EVENT_TOUCH_ENDED);
        listener:registerScriptHandler(onTouchBegan, 
            cc.Handler.EVENT_TOUCH_BEGAN);

        eventDispatcher:addEventListenerWithSceneGraphPriority(
            listener, topView);
        return listener;
    end
 
    --------------------我是分割线--------------------

    local function createTopView(touchEndCallBack)
        local topView = display.newNode();

        local graylayer, stencilNode = createGrayLayer();
        topView:addChild(graylayer, -1);
        g_listener = initClick(topView, touchEndCallBack);

        return topView, stencilNode;
    end

    local function setClickUI(topView, stencilNode, pos, size, layout)
        stencilNode:setVisible(true);

        local width, height = size.width, size.height;
        stencilNode:setContentSize(cc.size(width, height));

        local targetPos = adjustToCurPos(pos, 
            layout.horizontalLayout, layout.verticalLayout); 

        local spriteArrow = FuncArmature.createArmature("UI_main_img_shou_sz", nil, true);
        topView:addChild(spriteArrow, 200);
        spriteArrow:setPosition(targetPos.x, targetPos.y); 

        stencilNode:setPosition(targetPos.x - width / 2, targetPos.y - height / 2);    
    end


    local isInBattle = isInBattle or false;

    local topView, stencilNode = createTopView(touchEndCallBack);
    -- echo("---11111111111111");
    setClickUI(topView, stencilNode, pos, size, layout);
    -- echo("---22222222222");
    WindowControler:getScene()._topRoot:addChild(topView);
end

--[[
    所有scroll可否滚动
]]
function FuncCommUI.setCanScroll(isCanScroll)
    if HomeMapLayer ~= nil then 
        HomeMapLayer.setCanScroll(isCanScroll);
    end 

    if ScrollViewExpand ~= nil then 
        ScrollViewExpand.setEnableScroll(isCanScroll);
    end 
end
