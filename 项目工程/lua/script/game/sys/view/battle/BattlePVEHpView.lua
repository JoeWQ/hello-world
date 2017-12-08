--
-- Author: gs
-- Date: 2016-10-12 14:51:47
--
local BattlePVEHpView = class("BattlePVEHpView", UIBase)


function BattlePVEHpView:loadUIComplete(  )


    --FuncCommUI.setViewAlign(self.scale9_bg,UIAlignTypes.LeftBottom)

    --FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundStart, self)

end


function BattlePVEHpView:initView(  )
    if self.controler then
        --先不加载bossIcon
        --self:loadBossIcon()
    end
    
    
    self:visible(false)
    --self:initHpProgress()

end

--玩家的回合发生变化
function BattlePVEHpView:onRoundChanged()
    --echo("新回合开始----检查血条等信息")
    self:checkBoss()

    if self.mainHero then
        self:visible(true)
        self.mc_1:visible(false)
        self.mc_2:visible(false)
        self:loadBossIcon()
        self:initHpProgress()
        self:initSkillIcon()
        self.mainHero.data:addEventListener(BattleEvent.BATTLEEVENT_CHANGEENEGRY, c_func( self.onHpChanged ,self), self)
        self:onHpChanged(  )
    end


end







function BattlePVEHpView:initControler( view,controler )
	self._battleView = view
	self.controler = controler
    --回合开始  回合发生改变
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundChanged, self)
end


--[[
获取boss
]]
function BattlePVEHpView:checkBoss(  )
    --echo("检查谁是boss-------")
    local mainHero
    local  camp2 = self.controler.campArr_2
    for k,v in pairs(camp2) do
        --echo(v.data:boss(),"=========================== 检查boss---")
       if v.data:boss() == 1 then
            mainHero = v
            break
       end
    end
    -- if mainHero == nil then
    --     echo("没有找到boss=-=-=======")
    -- end
    self.mainHero = mainHero
end

--加载boss头像
function BattlePVEHpView:loadBossIcon(  )
    -- body
    if self.mainHero then
        local icon = FuncRes.iconHead(self.mainHero.data:head())  --FuncRes.iconHero(hid)
        local iconSp = display.newSprite(icon):pos(-20,-30)
        self.panel_2.ctn_1:addChild(iconSp)
        
    end
end

--[[
初始化血条信息
血条1作为背景  
血条2当前这管血的血量
当只有最后一管血的时候，1不显示
]]
function  BattlePVEHpView:initHpProgress(  )

    if self.panel_1.progress_1 then
        --设置进度条方向为从右到左
        self.panel_1.progress_1:setDirection(ProgressBar.r_l)
        self.panel_1.progress_1:setPercent(100)
        --self.panel_1.progress_1:setBarColor(cc.c3b(0,255,0))
    end
    if self.panel_1.progress_2 then
        self.panel_1.progress_2:setDirection(ProgressBar.r_l)
        self.panel_1.progress_2:setPercent(100)
    end
    if self.panel_1.progress_3 then
        self.panel_1.progress_3:setDirection(ProgressBar.r_l)
        self.panel_1.progress_3:setPercent(100)
    end
    --获取总共有多少管血
    -- local hpnum = 1
    -- if hpnum<=1 then
    --     self.panel_1.progress_1:visible(false)
    --     self.panel_1.progress_2:visible(true)
    --     elf.panel_1.progress_3:visible(false)
    --     self.mc_1:visible(false)
    --     self.mc_2:visible(false)
    -- else

    -- end
    self:onHpChanged()
    self:visible(true)

end

-- BattlePVEHpView.skillIcon =
-- {
--     ["1004"] = "battle_img_bianshen",
--     ["1003"] = "battle_img_fangyu",
--     ["1002"] = "battle_img_gongji",
--     ["1001"] = "battle_img_nuqi"
-- }

BattlePVEHpView.progressBg =
{
    ["1"] = "battle_progress_hong1.png",
    ["2"] = "battle_progress_hong2.png",
    ["3"] = "battle_progress_cheng1.png",
    ["4"] = "battle_progress_cheng2.png",
    ["5"] = "battle_progress_huang1.png",
    ["6"] = "battle_progress_huang2.png",
    ["7"] = "battle_progress_lan1.png",
    ["8"] = "battle_progress_lan2.png",
    ["9"] = "battle_progress_lanlv1.png",
    ["10"] = "battle_progress_lanlv2.png",
    ["11"] = "battle_progress_qianlv1.png",
    ["12"] = "battle_progress_qianlv2.png",
    ["13"] = "battle_progress_shenlv1.png",
    ["14"] = "battle_progress_shenlv2.png",
    ["15"] = "battle_progress_zi1.png",
    ["16"] = "battle_progress_zi2.png"
}


--[[
获取血条的bg
]]
function BattlePVEHpView:getProgressBg(step )
    
    local maxNum = self.maxHpNum*2
    local cnt = 16
    --echo("step",step,"==============",maxNum,cnt)
    if maxNum<= cnt then
        return FuncRes.iconBar( self.progressBg[tostring(step)]  ) 
    end
    if step == maxNum then
        return FuncRes.iconBar( self.progressBg[tostring(1)]  ) 
    end
    if step == maxNum-1 then
        return FuncRes.iconBar( self.progressBg[tostring(2)]  ) 
    end

    local index = step%(cnt-2)
    return FuncRes.iconBar( self.progressBg[tostring(index+2)]  ) 
end


--[[
检查当前以后多少个技能
显示buff技能图标
]]
function BattlePVEHpView:initSkillIcon(  )
    if self.mainHero and self.mainHero.data then
        local allBuff = self.mainHero.data.hpAiObj:getAllBuffInfo()
        allBuff = table.values(allBuff)
        -- echo("所有的buff-----------------")
        -- dump(allBuff)
        -- echo("所有的buff-----------------")
        self.skillIconView ={}          --保存所有的view对象
        for kk,vv in pairs(allBuff) do
            local view = UIBaseDef:cloneOneView( self.mc_bufferObj )
            local icon = ObjectBuff.new(vv.id):sta_icon()
            view:showFrame(1)
            --echo("当前的icon")
            if icon == nil then icon = "battle_img_bianshen" end
            view.currentView.ctn_1:addChild(display.newSprite(FuncRes.icon( "buff/"..icon..".png" )))
            view:showFrame(2)
            view.currentView.ctn_2:addChild(display.newSprite(FuncRes.icon( "buff/"..icon.."2.png" )))
            self.skillIconView[tostring(vv.id)] = view
            --view:pos((kk-1)*40-(#allBuff)*40/2,0)
            view:pos((kk-1)*40-120,16)
            self.ctn_bufferjineng:addChild(view)
        end
        self:checkSkillIcon()
    end
end


--[[
判断buff技能图标是否激活
]]
function BattlePVEHpView:checkSkillIcon(  )
    if self.mainHero and self.mainHero.data then
       local allActiveBuff = self.mainHero.data.hpAiObj:getActiveBuffInfo()
       -- echo("所有激活的buff")
       -- dump(allActiveBuff)
       -- echo("所有激活的buff")
       local chkExist = function ( key )
           for kk,vv in pairs(allActiveBuff) do
               if tostring(vv.id) == tostring(key) then
                return true
               end
           end
           return false
       end
       if self.skillIconView then
           for k,v in pairs(self.skillIconView) do
               if chkExist(k) then
                    v:showFrame(1)
                else
                    v:showFrame(2)
               end
           end
        end
    end
end



--[[
中间层血条 变化
]]
function BattlePVEHpView:runToOnePercent(toPercent,step,curPercent)
    if not self.cProgressArr then
        self.cProgressArr = {}
    end

    -- if toPercent ~= nil and toPercent<0 then
    --     echoError("目标百分表小雨0=====")
    -- end
    --echo("toPercent",toPercent,"frameCnt",frameCnt,"step",step,"curPercent",curPercent,"===========")
    -- if toPercent ~= nil and frameCnt ~= nil and bg ~= nil and step ~= nil and curPercent ~= nil then
    --     --table.insert(self.cProgressArr,{toPercent = toPercent,frameCnt = frameCnt,bg = bg,step = step,curPercent =curPercent})
    -- end
   
    if  toPercent ~=nil and toPercent ~= false  and step ~= nil and step ~= false  then 
        -- echo(step,toPercent,curPercent,"新数据进来--------------------")
        if #self.cProgressArr ==0 then
            --1：第一次进来
            --2：某次进来但是播放开始了。没有完成
            --3:某次进来播放完成
            --self.lastStep = st
            local ccpp = curPercent
            if ccpp == nil  then
                ccpp = self.lastToPercent
                --ccpp = self.panel_1.progress_2:getPercent()
            end
            if ccpp == nil then
                ccpp = self.panel_1.progress_2:getPercent()
            end
            --self.lastToPercent = tp
            self.cProgressArr[1] = {toPercent = toPercent,step = step,curPercent =ccpp}
        else
            if curPercent == nil then
                curPercent = self.cProgressArr[#self.cProgressArr].curPercent
            end
            if self.cProgressArr[#self.cProgressArr].step == step then
                --当前管血

                self.cProgressArr[#self.cProgressArr] = 
                {
                    toPercent = self.cProgressArr[#self.cProgressArr].toPercent > toPercent and toPercent or self.cProgressArr[#self.cProgressArr].toPercent,
                    curPercent = self.cProgressArr[#self.cProgressArr].curPercent > curPercent and self.cProgressArr[#self.cProgressArr].curPercent or curPercent,
                    step = step
                }
            elseif self.cProgressArr[#self.cProgressArr].step >step then
                if curPercent == nil then
                    curPercent = self.cProgressArr[#self.cProgressArr].curPercent
                end
                self.cProgressArr[#self.cProgressArr+1] ={toPercent = toPercent,step = step,curPercent =curPercent}
            end
        end
    end
    if #self.cProgressArr>0 and self.panel_1.progress_2.running then
        -- local param = self.cProgressArr[1]
        -- local st = param.step <= -1 and 0 or param.step
        -- if st == self.lastStep then
        --     self.panel_1.progress_3:setPercent(tp)
        -- end
        for i = 1,#self.cProgressArr,1 do
            if self.cProgressArr[i].step == self.lastStep then
                self.panel_1.progress_3:setPercent(self.cProgressArr[i].toPercent)
            end
        end
    end


    if #self.cProgressArr>0 and  (not self.panel_1.progress_2.running ) then
            self.panel_1.progress_3:visible(true)
            self.panel_1.progress_2:visible(true)
            self.panel_1.progress_1:visible(true)
        --self.panel_1.progress_2:stopTween()
        local param = self.cProgressArr[1]
        local st = param.step<=-1 and 0 or param.step
        local cp = param.curPercent >0 and param.curPercent or 0
        local tp = param.toPercent
        
        --echo("开始播放:",st,cp,tp,fCnt,"---------------------")
        table.remove(self.cProgressArr,1) 
        local fCnt = self:getFrameCnt(self.panel_1.progress_2,cp,tp)
        if #self.cProgressArr>=1 then fCnt = 5 end

        --self.panel_1.progress_2:setBarSprite(self.progressBg[tostring((st+1)*2)])
        
        self.panel_1.progress_2:setBarSprite(self:getProgressBg( (st+1)*2 ) )
        self.panel_1.progress_2.step = st
        self.panel_1.progress_2:setPercent(cp)
        self.panel_1.progress_2:tweenToPercent(tp,fCnt,nil,1)
        self.panel_1.progress_2.running = true
        self.panel_1.progress_2:delayCall(c_func(self.onRunCallBack,self),fCnt/GAMEFRAMERATE)
        if st > 0 then 
            --self.panel_1.progress_1:setBarSprite(self.progressBg[tostring(st*2-1)])
            self.panel_1.progress_1:setBarSprite(self:getProgressBg (st*2-1) )
            self.panel_1.progress_1:setPercent(100)
        else
            self.panel_1.progress_1:visible(false)
        end
        --self.panel_1.progress_3:setBarSprite(self.progressBg[tostring((st+1)*2-1)])
        self.panel_1.progress_3:setBarSprite(self:getProgressBg( (st+1)*2-1 ) )
        local ccpp = tp
        if self.lastStep == st then
            ccpp = self.panel_1.progress_3:getPercent()
            if ccpp>tp then
                ccpp = tp
            end
        end
        self.panel_1.progress_3:setPercent(ccpp)
        self.lastStep = st
        self.lastToPercent = tp
    end
end


--[[
中间层血条，变化回调
]]
function BattlePVEHpView:onRunCallBack(  )
    --echo("缓动完成-----")
    self.panel_1.progress_2.running = false
    self:runToOnePercent(nil,nil,nil)
end

function BattlePVEHpView:getFrameCnt( progressBar,tarPercent,curPercent )
    if not curPercent then
        curPercent = progressBar:getPercent()
    end
    local durPer = math.abs(tarPercent-curPercent)
    return math.round( durPer/100*50 )>=10 and math.round( durPer/100*50 ) or 10
    --return 30
end


--当boss血量发生改变的时候
function BattlePVEHpView:onHpChanged(  )
    if self.mainHero then

        local percent = self.mainHero.data:hp()/ self.mainHero.data:maxhp() *100 
        --self.panel_1.progress_2:tweenToPercent(percent)
        local info = self.mainHero.data.hpAiObj:getDataInfo()
        --dump(info)
        local hpNum = #info+1                   --当前共有多少管血
        self.maxHpNum = hpNum
        local step = -1
        if #info>0 then
            step = 0
        end
        for i=#info,1,-1 do
            local hp = info[i].hp
            if percent>hp then
                step = i
                break
            end
        end
        local sw = math.floor( step/10 )
        local gw = step%10
        --echo("sw,gw",sw,gw,"=========================")
        if hpNum == 1 or step ==1 or (sw == 0 and gw== 0 ) then
            --一管血 或者最后一管
            self.mc_1:visible(false)
            self.mc_2:visible(false)
            self.mc_3:visible(false)
        elseif sw == 0 then
            --9管血一下
            self.mc_1:visible(false)
            self.mc_2:visible(true)
            self.mc_2:showFrame(gw)
            self.mc_3:showFrame(12)
        else
            --两位数血量
            self.mc_1:visible(true)
            self.mc_1:showFrame(sw)
            self.mc_2:visible(true)
            if gw == 0 then gw = 10 end
            self.mc_2:showFrame(gw)
            self.mc_3:showFrame(12)
        end

        -- self.mc_1:visible(step+1 ~= 1 and hpNum ~=1)
        -- self.mc_2:visible(step+1 ~= 1 and hpNum ~=1)

        -- self.mc_1:showFrame(step == -1 and 1 or step+1)
        -- self.mc_2:showFrame(12)

        if step ~= 0 and hpNum>1 then
            --echo("当前多管血，且不是最后一管",step,"==============")
            local lastPercent = 100
            if info[step+1] and info[step+1].hp then
                lastPercent = info[step+1].hp
            end
            --当前在这个阶段 总血量
            local allCurHp = (lastPercent-info[step].hp)*(self.mainHero.data:maxhp())/100

            local curHp = (self.mainHero.data:hp()- self.mainHero.data:maxhp()*info[step].hp/100 )
            local curPercent = math.round(curHp/allCurHp*100)
            
            --中间层
            if self.panel_1.progress_2.step == nil then
                --表示上来初始化  不用管
                self:runToOnePercent(curPercent,step,100)
            elseif self.panel_1.progress_2.step>step then
                --self.panel_1.progress_2:stopTween()
                for i=self.panel_1.progress_2.step,step,-1 do
                    local toPercent,frameCnt,bg,st,cP
                    if i == self.panel_1.progress_2.step then
                        toPercent = 0
                        st = i
                        cP =  nil      --self.panel_1.progress_2:getPercent()  这里赋值为空的含义是去当前取 上次更新的百分比
                    elseif i == step then
                        toPercent = curPercent
                        st = i
                        cP = 100
                    else
                        toPercent = 0
                        st = i
                        cP = 100
                    end 
                    self:runToOnePercent(toPercent,st,cP)
                end
            else

                self:runToOnePercent(curPercent,step)
            end

        elseif step == 0 and hpNum>1 then
            --echo("多管血，最后一管-00000")
            --最后一管血
            local lastPercent = info[1].hp
            local allCurHp = (lastPercent-0)*(self.mainHero.data:maxhp())/100
            local curHp = self.mainHero.data:hp()
            local curPercent = math.round(curHp/allCurHp*100)

            if self.panel_1.progress_2.step>0 then
                --self.panel_1.progress_2:stopTween()
                for i=self.panel_1.progress_2.step,0,-1 do
                    local toPercent,frameCnt,bg,st,cP
                    if i == self.panel_1.progress_2.step then
                        toPercent = 0
                        st = i
                        cP =  nil   --self.panel_1.progress_2:getPercent()
                    elseif i == step then
                        toPercent = curPercent
                        st = i
                        cP = 100
                    else
                        toPercent = 0
                        st = i
                        cP = 100
                    end 
                    self:runToOnePercent(toPercent,st,cP)
                end
            else
                self:runToOnePercent(curPercent,step)
            end
        elseif hpNum ==1 then
            --echo("只有一管血")
            --只有一管血
            self.panel_1.progress_3:visible(true)
            self.panel_1.progress_2:visible(true)
            self.panel_1.progress_1:visible(false)

            if self.panel_1.progress_2.step ~= step then
                --self.panel_1.progress_2:setBarSprite(self.progressBg["2"])
                
                self.panel_1.progress_2:setBarSprite(self:getProgressBg(2))
                self.panel_1.progress_2.step = step
            end
            self.panel_1.progress_2:tweenToPercent(percent,self:getFrameCnt(self.panel_1.progress_2,percent),nil,1)
            self.panel_1.progress_3:setPercent(percent)
        end



        --技能图标显示
        self:checkSkillIcon()
    end
end





return BattlePVEHpView