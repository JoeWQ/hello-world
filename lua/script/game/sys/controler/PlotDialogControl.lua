local PlotDialogControl = { }
----------------------------------------------------
PlotDialogControl.addSelfAmoutt = 0
-- _addSelf = { }
-- _addSelf.amount = 0
-- meta1 = {
--     __index = function(t, k)
--         if k == "amount" then
--             _addSelf.amount = _addSelf.amount + 1
--             return _addSelf.amount
--         else
--             return _addSelf[k]
--         end
--     end,
--     __newindex = function(t, k, v)
--         _addSelf[k] = v
--     end
-- }
-- setmetatable(PlotDialogControl.addSelf, meta1) 




---------------------------------------------------- 
local scheduler = require("framework.scheduler") 

function PlotDialogControl:init()
    -- self.plotCfg= require("plot.Plot.lua")
 
    self.curStep = 1
    -- 当前执行到的步数
    PlotDialogControl.addSelfAmoutt = 0
    -- 加载纹理材质
    -- FuncArmature.loadOneArmatureTexture("UI_battle", nil, true)
    self.pdata = { }
    self.allData = { }
    self.preAniVer = { }
    self.plotDialogState = 0
    self.optionBtCallback = nil
    -- 标记当前一个正在播放的动画的状态，如果为false 则可以点击跳过
    self.isShowOption = false
    self.optionLocalData = {} --plot表中的剧情文字
    self.optionExtData = {} --其他配表中的剧情文字
    self.optionState = false
    self.playAniState = false
    self.localTextSource = true
    local x,y = WindowControler:getDocLayer():getPosition()
    self.originPosition=cc.p(x,y);
end  
 
-- 震动播放顺序
local PLOT_DIALOG_STATE = {
    A = 1,
    -- A=出场动画播放之前
    B = 2,
    -- B=出场动画播放时
    C = 3,
    -- C=说话之前震动
    D = 4,
    -- D=说话之后震动
    E = 5,
    -- E= 选项按钮
}
 
-- 优先级,震动，动画
function PlotDialogControl:showPlotDialog(id, _callback)
    self:init()
    self.handle = scheduler.scheduleGlobal(handler(self, self.updateFrame), 0.05)
    echo("  handle -----------------------------",id)
    self.optionBtCallback = _callback
    FuncPlot.setPlotID(id)
    echo("-------Plot id:--------- ",id);
    self.view = WindowControler:showTutoralWindow("PlotDialogView", self, { bgAlpha = 0 });
    self.view.colorLayer:setPlotLayerSize(GameVars.width+100,GameVars.height+100);
    self.plotDialogState = -1
    self:onTouchEvent()
    self:sortPlotData()
   
end 

function  PlotDialogControl:setSkipButtonVisbale( state )
   self.view.btn_1:setVisible(state)
end   

-- 点击屏幕回调 注意点击按钮是否和该事件重叠
function PlotDialogControl:onTouchEvent(step)

    --    if step ~= nil then
    --        PlotDialogControl.addSelf.amount = step
    --    end
    if self.optionState or self.playAniState then
        -- 显示选框， 并且
        return
    end
    if self.plotDialogState == PLOT_DIALOG_STATE.A then
        -- 入场前
        return
    elseif self.plotDialogState == PLOT_DIALOG_STATE.C then
        return
    elseif self.plotDialogState == PLOT_DIALOG_STATE.D then

        if self.pdata.afterAni ~= nil then
            local _dtime = cc.DelayTime:create(0.5)
            local _act = cc.CallFunc:create(
            function()
                self:plotInfoCompleteAni()
            end
            )
            local _action = cc.Sequence:create(_dtime,
            _act)
            self.view:runAction(_action)
            self.playAniState = true
        else
            -- 没有结束动画 标记对话完成
            self:aniCompleteCallBack()
        end
        
        return
    else
        -- 选项点击

    end

    -- self.curStep = PlotDialogControl.addSelf.amount
    if step ~= nil and type(step) ~= "table" then
        self.curStep = step
    end
    echo("self.curStep -->" .. self.curStep)
    self.pdata = FuncPlot.getStepPlotData(self.curStep)
    if self:table_is_empty(self.pdata) then
        echoError("plot data is null")
        return
    end
    self.preAniVer = FuncPlot.getPreAniData(self.curStep)
    self.plotDialogState = PLOT_DIALOG_STATE.A
    -- 对话前的动画序列
    self.aniIndex = #self.preAniVer or 0
    self.curAniIdx = 1
    self.lastAniIdx = 0
    -- 判断是否有进场动画 以及 震动
    local _shake = self.pdata.shake
    local _time = 0
    if _shake[PLOT_DIALOG_STATE.A] == 1 then
        -- 出场动画前播放震动
        self:shake(10, 10, "x")
        _time = 0
    elseif _shake[PLOT_DIALOG_STATE.B] == 1 then
        -- 出场动画和震动同时播放
        self:shake(10, 10, "x")
        _time = 0
    end

    --    local _dtime = cc.DelayTime:create(_time)
    --    local _act = cc.CallFunc:create(
    --    function()
    if self.pdata.enterT == 1 then
        -- 判断是否有进场动画
        self.playAniState = true

        self.view:removeCurAni()
        local _data = { enterAni = self.pdata.enterAni, img = self.pdata.img, dir = self.pdata.pos[2], pos = self.pdata.pos }
        self.view:playPlotAni(_data)
    else
        if self.aniIndex ~= 0 then
            -- 无进场动画但是有对话前动画序列
            self:playAniView(self.preAniVer[self.curAniIdx])
            self.plotDialogState = PLOT_DIALOG_STATE.C

        else
            -- 无对话前动画
            self.view:removeCurAni()
            if _shake[PLOT_DIALOG_STATE.C] == 1 then
                self:shake(10, 10, "x")
            end
            self:updatePlogInfo(self.pdata)
            self.plotDialogState = PLOT_DIALOG_STATE.D
        end

    end
    self.view:setBackGroupImg(self.pdata.board)
    --    end )
    --    local _action = cc.Sequence:create(_dtime,
    --    _act)
    --    self.view:runAction(_action)

end 

function PlotDialogControl:plotInfoCompleteAni()
    self.preAniVer = self.pdata.afterAni or { }
    self.aniIndex = #self.preAniVer or 0
    self.curAniIdx = 1
    self:aniCompleteCallBack()
end  
function PlotDialogControl:aniCompleteCallBack()

    if self.plotDialogState == PLOT_DIALOG_STATE.A then
        -- 进场
        self.plotDialogState = PLOT_DIALOG_STATE.C
        if self.aniIndex ~= 0 then
            -- 检查进场动画序列
            local _enterAni = self.pdata.preAni[self.curAniIdx]
            self:playAniView(_enterAni)
        else
             self.plotDialogState = PLOT_DIALOG_STATE.D
            self:updatePlogInfo(self.pdata)
        end
    elseif self.plotDialogState == PLOT_DIALOG_STATE.C then
        -- 对话前
        if self.curAniIdx <= self.aniIndex then
            local _enterAni = self.pdata.preAni[self.curAniIdx]
            local _time = _yuan3(_enterAni == 0, 5, 1)
            if _enterAni == 0 then
                local _dtime = cc.DelayTime:create(_time)
                local _act = cc.CallFunc:create(
                function()
                    self.curAniIdx = self.curAniIdx + 1
                    _enterAni = self.pdata.preAni[self.curAniIdx]
                    self:playAniView(_enterAni)
                end
                )
                local _action = cc.Sequence:create(_dtime,
                _act)
                self.view:runAction(_action)
            else
                self:playAniView(_enterAni)
            end
        else
            self.view:removeCurAni()
            if self.pdata.shake[PLOT_DIALOG_STATE.C] == 1 then
                self:shake(10, 10, "x")
            end
            if self.isShowOption then
                -- 进入新动画检测 是否需要显示对话选项
                self:updatePlogInfo(self.pdata,false)
                self:showOptionView()
                self:setOptionState(false)
            else
                self:updatePlogInfo(self.pdata)
            end
            self.plotDialogState = PLOT_DIALOG_STATE.D
        end
    elseif self.plotDialogState == PLOT_DIALOG_STATE.D then
        -- 退场动画

        if self.pdata.shake[PLOT_DIALOG_STATE.D] == 1 then
            self:shake(10, 10, "x")
        end
        if self.curAniIdx <= self.aniIndex  then
            self:playAniView(self.preAniVer[self.curAniIdx])
        else
            --  a process complete
            self.view:plotDialogComplete(self.pdata)

            if self.pdata.nextId == nil then
                -- close Window
                self:destoryDialog()
                return
            end
            self.curStep = self.pdata.nextId[1]
            self.playAniState = false
            -- 进入新流程 检查是否入场动画..震动...
            -- 此处检查是否有选项
            if self.pdata.glaType == 1 then
                self:setOptionState(true, true)
            else
                self.plotDialogState = PLOT_DIALOG_STATE.E
                self:setOptionState(false)
                self:onTouchEvent()
            end
            --  self.curAniIdx = 1
        end
    else
        -- 选项
        return
    end

end
 
function PlotDialogControl:setOptionState(isShow, isNextStep)
  --  self.plotDialogState = -1
    self.isShowOption = isShow
    if not isShow then return end

    for i = 1, #self.pdata.nextId do
        table.insert(self.optionLocalData, self.pdata.nextId[i])
    end

    -- 对话流程结束 重置标记
    if isNextStep then
        self.plotDialogState = PLOT_DIALOG_STATE.E
        self:onTouchEvent()
    end
end 


function PlotDialogControl:playAniView(_enterAni, dir)

    if _enterAni ~= nil then
        self.playAniState = true
        local _data = { enterAni = _enterAni, img = self.pdata.img, dir = self.pdata.pos[2], pos = self.pdata.pos,ani=self.preAniVer[self.curAniIdx-1] }
        if(_enterAni~=0)then
             self.view:removeCurAni()
             self.view:playPlotAni(_data)
        else
             self.view:playDelayAni(_data);
        end
        self.curAniIdx = self.curAniIdx + 1
    end
end 
-- skip the game Plot
function PlotDialogControl:skipPlot()
   AudioModel:playSound("s_com_click2")
    local _allData = FuncPlot.getPlotData()
    local _close = true
    self.press_skip_button=true
    for i, v in pairs(self.allData) do
        local _step = tonumber(v.order)
        if v.glaType == 1 and _step >= self.curStep then
            self.pdata = FuncPlot.getStepPlotData(_step)
            if self.pdata.nextId == nil then
                -- close window
                WindowControler:getDocLayer():setPosition(self.originPosition);
                _close = true
                return
            end
            _close = false

            self:setOptionState(true, false)
            self.curStep = self.pdata.nextId[1]
            self.pdata = FuncPlot.getStepPlotData(self.curStep)
            self.view:cleanLastAni()
            self:updatePlogInfo(self.pdata,false)
            self:showOptionView()
            --  self.view:plotDialogComplete(self.pdata)
            echo("curStep--->" .. self.curStep)
            break
        end
    end
    if _close then
        self:destoryDialog()
    end
--//还原场景的坐标点
    WindowControler:getDocLayer():setPosition(self.originPosition);
end
function PlotDialogControl:showOptionView()
    self.view:setSkipBtnVisable(false)
    if self.localTextSource then
        self.view:showLocalOption(self.optionLocalData)
    else
       if self.optionExtData ~= nil then 
        self.view:showExtOption(self.optionExtData)
       end 
    end
    self.optionState = true

end 

function PlotDialogControl:sortPlotData()
    local _allData = FuncPlot.getPlotData()
    local _i = 1
    for _, key in pairs(_allData) do
        table.insert(self.allData, FuncPlot.getStepPlotData(_i))
        _i = _i + 1
    end
end 
function PlotDialogControl:updatePlogInfo( data, isShowText)
     
     local _textVisable = _yuan3(isShowText == nil ,true,false)
    self.view:updateUI(self.pdata,_textVisable)
    self.playAniState = false
end 

function PlotDialogControl:updateFrame(dt)
 
    self:sceneShake()

    if self.plotDialogState == PLOT_DIALOG_STATE.C then

    elseif self.plotDialogState == PLOT_DIALOG_STATE.D then

    end
end 

function PlotDialogControl:destoryDialog()
 
    if self.handle ~= nil then
        scheduler.unscheduleGlobal(self.handle)
    end

    self.optionBtCallback( { step = - 1, index = - 1 })
    self.view:startHide()
    self:clear()

    -- self.view = nil
    -- PlotDialogControl = nil
end 
   
-- 震屏
function PlotDialogControl:shake(frame, range, shakeType)

    range = range and range or 2
    frame = frame and frame or 6
    shakeType = shakeType and shakeType or "xy"
    self.shakeInfo = {
        frame = frame,
        shakeType = shakeType
    }
    if shakeType == "x" then
        self.shakeInfo.range = { range, 0 }
    elseif shakeType == "y" then
        self.shakeInfo.range = { 0, range }
    else
        self.shakeInfo.range = { range, range }
    end
    local shakeLayer = WindowControler:getDocLayer()

    if self.oldPos then
        shakeLayer:pos(self.oldPos[1], self.oldPos[1])
    else
        self.oldPos = { shakeLayer:getPosition() }
    end
end


function PlotDialogControl:sceneShake()
    if not self.shakeInfo then
        return
    end
    local shakeLayer = WindowControler:getDocLayer()
    self.shakeInfo.frame = self.shakeInfo.frame - 1

    local oldXpos = self.oldPos[1] or 0
    local oldYpos = self.oldPos[2] or 0
    local pianyi =(self.shakeInfo.frame % 2 * 2 - 1)

    shakeLayer:pos(oldXpos + pianyi * self.shakeInfo.range[1], oldYpos + pianyi * self.shakeInfo.range[2])

    if self.shakeInfo.frame == 0 then
        self.shakeInfo = nil
        shakeLayer:pos(oldXpos, oldYpos)
        self.oldPos = nil
    end
    if(self.press_skip_button)then
            self.press_skip_button=nil;
            shakeLayer:setPosition(self.originPosition);
    end
end
function PlotDialogControl:optionCallback(idx)
    -- 玩家点击后跳转至对应的
    local _step = self.optionLocalData[idx]
    if self.optionBtCallback ~= nil then 
        self.optionBtCallback( { step = _step, index = idx })
    end
    self.optionState = false
    self.playAniState = false
    self.plotDialogState = PLOT_DIALOG_STATE.D
    self:setOptionState(false)
    self.optionLocalData = { }
    self.view:setSkipBtnVisable(true)
    self:onTouchEvent(_step)

end 
--选项事件类型，剧情ID
function PlotDialogControl:setTextSource( id ,data)
 --Temp
   if id ~= 0  then 
    self.localTextSource = false
    for i = 1,#data do
     local _info = FuncTower.getTowerOptionText(data[i])
     table.insert(self.optionExtData,_info)
    end 
 
   end 

end 

   
function PlotDialogControl:table_is_empty(t)
    return _G.next(t) == nil
end

function PlotDialogControl:clear()
    -- self.view  = nil

end 

return PlotDialogControl 
