--
-- Author: dou
-- Date: 2014-03-10 14:18:29
--
ModelEffectNum = class("ModelEffectNum", ModelBasic)

ModelEffectNum.target = nil --跟随对象
ModelEffectNum.info = nil --跟随信息
ModelEffectNum.frame =0 

--目前8个特效 分别是 动画名字,flash对应的mc名字,文字宽高
local typeToAniNameObj = {
    ["1"] = {"common_num_jianxue2","mc_rx",20,24},             --普通减血 
    ["2"] = {"common_num_jianxue1","mc_dh",30,35},              --暴击减血

    ["7"] = {"common_num_jiaxue","mc_qv",20,24},                --普通加血
    ["8"] = {"common_num_jiafa","mc_lg",20,24},                 --普通加法力
    ["9"] = {"common_num_jianfa","mc_ag",20,24},                --普通减法力
    ["10"] = {"common_num_jianweineng1","mc_hd",30,35},        --减威能暴击
    ["11"] = {"common_num_jianweineng2","mc_hx",20,24},        --减威能普通
    ["12"] = {"common_num_jiaweineng","mc_cheng",20,24},           --加威能
    ["13"] = {"common_num_jianxue3","mc_dh",30,35},             --技能减血
    ["20"] = {"common_num_shanbi","miss",20,24},           --闪避
}

function ModelEffectNum:ctor( ...)
    self.modelType = Fight.modelType_effect
	ModelEffectNum.super.ctor(self,...)
	--特效 深度排列类型优先级比较高
	self.depthType = 9
    self.totalFrame =0
	self.data = {}
    
end



function ModelEffectNum:setInfo(target,ctn, type,num )
	
	local node = self:createHurtLable(type,num)
    node:zorder(target.__zorder + 1)
    self.totalFrame = 35
    node:setScaleX(Fight.cameraWay )

    --存储目标
    self.target = target

    local numeEffArr = self.target.__numEffArr
    --临时特效数组
    if not numeEffArr then
        self.target.__numEffArr = {self}
        numeEffArr =self.target.__numEffArr
    else
        --来一个特效就插入一个特效
        table.insert(numeEffArr, 1,self)
    end

    local heiOff = 15

    --echo(#numeEffArr,type,"___特效长度----")
    self:initView(ctn,node,target.pos.x,target.pos.y,target.pos.z-target.data.viewSize[2]-target.data:hang() - 38 )

    -- self.myView.currentAni:playWithIndex(0, false)
    -- self.myView:delayCall(c_func(self.myView.currentAni.playWithIndex,self.myView.currentAni,1, false), self.myView.currentAni.totalFrame/GAMEFRAMERATE )
    self.myView.currentAni:runEndToNextLabel(0, 1, false)
    for i,v in ipairs(numeEffArr) do
        local yIndex = i %20
        if yIndex ==0 then
            yIndex = 20
        end

        v:setPos(self.pos.x -(i-1)*0*self.target.way ,self.pos.y,0-target.data.viewSize[2]-target.data:hang() - 38 - (yIndex-1) * heiOff )
        --进行跳帧
        if i < #numeEffArr then
             -- v.myView.currentAni:removeFrameCallFunc()
            if v.myView.currentAni:getAnimation():getMovementCount() <2 then
                echoWarn("动画"..v.myView.currentAni:getName().."_的帧标签少于2个")
            else
                --todo
            end

            -- v.myView.currentAni:playWithIndex(1, false)
        end
        --相对缩放
        -- v.myView:setScale(math.pow(0.95,i-1))
    end

end

--创建挨打效果
function ModelEffectNum:createHurtLable(type,num)
    -- body
    -- type = 2

    local cfg = typeToAniNameObj[tostring(type)]
    
    if not cfg then
        echoWarn("错误的数字特效类型:",type)
        return display.newNode()
    end

    local aniName = cfg[1]

    local view = ViewArmature.new(aniName)

    if type == 20 then
        return view
    end

    local bone = view.currentAni:getBone("node")

    local mcCfg = UIBaseDef:getUIChildCfgs("UI_battle_public",cfg[2])

    if bone then

        --那么创建数字特效
        local params = {
            uiCfg = mcCfg,
            number = num > 0 and ("+"..num) or num,
            width = cfg[3],
            halign = "center",
            valign = "center",
            height = cfg[4],
        }

        --如果是暴击减血
        if tostring(type) =="2" then
            params.number = math.abs(num)
            params.halign = "left"
        end

        if view.currentAni._numNode then 
            view.currentAni._numNode:setString(params.number)
        else
            local mcView = NumberEffect.new(params)
            FuncArmature.changeBoneDisplay(view.currentAni, "node", mcView)
            view.currentAni._numNode = mcView
        end

        
    end

    return view

end





--根据类型判定坐标
function ModelEffectNum:turnFollowPos(  )
	
	self:setWay(self.target.way)
	self.pos.x = self.target.pos.x +  self.pianyiPos.x * way
	self.pos.y =self.target.pos.y +  self.pianyiPos.y 
	self.pos.z = self.target.pos.z +  self.pianyiPos.z 
end


function ModelEffectNum:runBySpeedUpdate( )
    self:realPos(self)
    self.updateCount = self.updateCount + 1
    -- --如果是最后一帧
    -- if self.updateCount <= 20 then
    --     if self.target.__leftNumFrame > 0 then
    --         self.target.__leftNumFrame = self.target.__leftNumFrame -1
    --         --如果目标
    --         if self.target.__leftNumFrame <=0 then
    --             self.target.__numEffs =0
    --         end
    --     end
    -- end


    if self.updateCount % 3 ==1 then
        -- self.myView:zorder(self.target.__zorder +1)
    end

    if self.updateCount == self.totalFrame then

        if self.target.__numEffArr then
            table.removebyvalue(self.target.__numEffArr, self)
        end

        self:deleteMe()
    end

end


--创建得分总伤害 totalDamage  总伤害  heroArr命中的英雄数组 
function ModelEffectNum:createTotalDamage(totalDamage )
    local middlePos = BattleControler.gameControler.middlePos
    local ypos = 400
    local zpos = 0
    --如果小于100 return
    if totalDamage < 100 then
        return
    end

    if totalDamage > 9999999 then
        totalDamage = 9999999
    end
    totalDamage = math.floor(totalDamage)

    local titleEff = BattleControler.gameControler.__totalDamageEff

    if not titleEff then
        titleEff = FuncArmature.createArmature("UI_zhandou_zongshanghai", BattleControler.gameControler.gameUi._root, false, GameVars.emptyFunc)
        titleEff:pos(GAMEHALFWIDTH ,-540)
        BattleControler.gameControler.__totalDamageEff = titleEff
    end

    local weishuFrame
    --7位数
    if     totalDamage >= 1000000 then
        weishuFrame = 5
    elseif totalDamage >= 100000 then
        weishuFrame = 4
    elseif totalDamage >= 10000 then
        weishuFrame = 3
    elseif totalDamage >= 1000 then
        weishuFrame = 2
    elseif totalDamage >= 100 then
        weishuFrame = 1
    end

    local strDamage = tostring(totalDamage)
    local strLeng = string.len(strDamage)
    
    --先判断位数
    local turnNumFrame = function ( numAni  )

        numAni:gotoAndPause(weishuFrame)
        for i=1,strLeng do
            local childAni = numAni:getBoneDisplay("node"..i)
            local numFrame = tonumber( string.sub (strDamage,i,i) )
            numFrame = numFrame == 0  and 10 or numFrame
            childAni:playWithIndex(numFrame-1)
        end
    end

    titleEff:visible(true)
    titleEff:startPlay(true, false)
    titleEff:doByLastFrame(false,true)
    turnNumFrame(titleEff:getBoneDisplay("layer11"))
    turnNumFrame(titleEff:getBoneDisplay("layer10_copy"))
end


--创建怒气伤害
--chance 1出现  2  增加 3是最后一个
function ModelEffectNum:createSkillDamage( totalDamage,chance)
    if Fight.isDummy  then
        return
    end

    local middlePos = GameVars.width/2

    local lastEff = BattleControler.gameControler.__skillDamageEff 
    if not lastEff then
        
        --先创建标题动画
        lastEff = FuncArmature.createArmature("UI_zhandou_nvqishanghai", BattleControler.gameControler.gameUi._root, false, GameVars.emptyFunc)
     
        lastEff:pos(GAMEHALFWIDTH,-500)
        BattleControler.gameControler.__skillDamageEff  = lastEff
        lastEff.numNodeArr = {}
        -- lastEff:setScaleX(Fight.cameraWay )

        -- local childAni1 = lastEff:getBoneDisplay("layer11")
        local childAni2 = lastEff:getBoneDisplay("layer1")

        -- lastEff.numNode1  = display.newNode()
        lastEff.numNode2  = display.newNode()
        -- FuncArmature.changeBoneDisplay( childAni1,"layer3",lastEff.numNode1,  0 )
        FuncArmature.changeBoneDisplay( childAni2,"layer3",lastEff.numNode2,  0 )
    else
        lastEff:visible(true)
    end

    if totalDamage > 99999 then
        totalDamage = 99999
    end
    totalDamage = math.floor(totalDamage)
    
    local createAni = function (ani, x,y,fromIndex,toIndex )
        ani = ani and ani  or FuncArmature.createArmature("UI_zhandou_212",lastEff.numNode2,true)
        ani:pos(x,y)
        -- echo(fromIndex,toIndex,"_________aaaaaaaaaaa")
        ani:stopAllActions()
        if fromIndex == toIndex then
            ani:gotoAndPause(fromIndex)
        else
            ani:gotoAndPlay(fromIndex)
            local stopAni = function (  )
                ani:gotoAndPause(toIndex)
            end
            local dxFrame = toIndex - fromIndex
            if dxFrame < 0 then
                dxFrame = dxFrame +10
            end
            -- dxFrame = dxFrame +10
            ani:delayCall(stopAni, dxFrame/GAMEFRAMERATE )
            -- ani:registerFrameEventCallFunc(toIndex,1,c_func(stopAni,ani,toIndex))
        end
        return ani
    end


    local strDamage = tostring(totalDamage)
    
    local xoff =0
    local numWidth = 27
    local strLeng = string.len(strDamage)
    local targetX =0
    local numNodeArr = lastEff.numNodeArr

    for i,v in pairs(numNodeArr) do
        v:visible(false)
    end
    -- echo(totalDamage,"_______________技能当前伤害",strLeng)
    for i=1, strLeng do
        targetX = (i-1)*numWidth  + xoff
        local numFrame = tonumber( string.sub (strDamage,i,i) )
        local fromFrame = 1
        local oldAni = numNodeArr[strLeng - i +1]
        numFrame = numFrame == 0 and 10 or numFrame
        if oldAni then
            oldAni:visible(true)
            --如果是初始化 那么fromFrame 从10开始
            if chance == 1 then

            else
                fromFrame = oldAni:getCurrentFrame()
                fromFrame = fromFrame > 10 and 10 or fromFrame
            end

            -- echo(oldAni,fromFrame, numFrame,"__________",i)
            createAni(oldAni,targetX,0,fromFrame, numFrame)
        else
            numNodeArr[strLeng - i +1] = createAni(nil,targetX,0,fromFrame, numFrame)
            -- echo("新建ani",fromFrame, numFrame,"__________",i)
        end
    end

    

    local hidNode = function (  )
        lastEff:visible(false)
    end

    local delayPlay = function (  )
        lastEff:playWithIndex(1, false)
        lastEff:delayCall(hidNode,1)
    end
    --先停止action
    lastEff:stopAllActions()
    lastEff:removeFrameCallFunc()
    lastEff:visible(true)
    --如果是最后一次伤害 那么0.3秒以后 隐藏
    if chance == 3 then
        -- echo("__延迟隐藏")
        lastEff:stopAllActions()
        lastEff:delayCall(delayPlay,1.2)
    --如果是初始化
    elseif chance == 1 then

        lastEff:playWithIndex(0, false)
    --如果是单次伤害
    elseif chance == 4 then
        lastEff:playWithIndex(0, false)
        lastEff:stopAllActions()
        lastEff:delayCall(delayPlay,2)
    end

end


function ModelEffectNum:deleteMe( ... )
	ModelEffectNum.super.deleteMe(self,...)
	self.target = nil
end


return ModelEffectNum