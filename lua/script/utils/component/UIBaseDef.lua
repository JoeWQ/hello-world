

local resUrl = "uipng/"
local uiUrl = "uipng/"
local mapUrl = "map/"
local cfgUIUrl = "viewConfig.ui."

local cfgMapUrl = "viewConfig.map."

local fontUrl = "fnt/"
local defaultAnchorPos = cc.p(0,1)

--当前的damic
local dynamicName =nil

local mapScale = 0.5


--属性定义
UIBaseDef= {
    titleType_btn = "btn",
    titleType_checkbox = "checkbox",
    titleType_image = "image",
    titleType_input = "input",
    titleType_panel = "panel",
    titleType_scroll = "scroll",
    titleType_tab = "tab",
    titleType_txt = "txt",
    titleType_mc = "mc",
    titleType_UI = "UI",
    titleType_scale9 = "scale9",
    titleType_ani = "ani",
    titleType_map = "map",

    nameInstance = "instance",

    prop_matrix = "m",          --坐标数组　［x,y,sx,sy,rx,ry］
    prop_alpha = "a",               --透明度
    prop_className = "cl",          --类名
    prop_type = "t",                --类型 
    prop_child = "ch",              --子对象
    prop_frames = "fm",             --多帧对象 每一帧都有 ch 属性 
    prop_image = "img",             --图片 
    prop_config = "co",             --单独的配置 
    prop_width = "w",               --宽 
    prop_height = "h",              --高
    prop_name = "na",               --名字
    prop_fullName = "fu",           --全名

    prop_clickArea = "ar",          --针对按钮的点击区域
    prop_scale9 = "s9",             --9宫格矩阵 
    prop_anchor = "an",             --锚点

    --混合模式
    prop_blendMode="bl",            

    prop_extand = "ex",              -- 扩展  针对 场景的扩展

    --scroll扩展
    prop_scroll_dx = "dx",
    prop_scroll_dy = "dy",
    prop_scroll_num = "num",
    prop_scroll_ox = "ox",
    prop_scroll_oy = "oy",
    prop_scroll_scrollType = "scrollType",
    prop_scroll_scrollbarImgH = "scrollbarImgH",
    prop_scroll_scrollbarImgV = "scrollbarImgV",
}

--[[
    {
        aniLoadNum = , isUIConfigLoad = , isAniLoad = ,
        aniLoadNum = , isUIConfigLoad = , isAniLoad = ,
    }
]]
UIBaseDef._winLoadCompleteInfo = {};


--创建Component_public 子对象组件
function UIBaseDef:createPublicComponent( componentPubliName,childName )
    local cfgs = require(cfgUIUrl..componentPubliName)

    local childInfoArr = cfgs[self.prop_child]
    for i,v in ipairs(childInfoArr) do
        if v[self.prop_name] == childName then
            local t = v[self.prop_type]

            local childView = self["get_"..t](self,v)
            childView.__uiCfg = v

            return childView
        end

    end

    return nil

end

--获取某个ui的某个子对象的uipeizhi
function UIBaseDef:getUIChildCfgs( uiName,childName )
    local cfgs = require(cfgUIUrl..uiName)
    local childInfoArr = cfgs[self.prop_child]
    for i,v in ipairs(childInfoArr) do
        if v[self.prop_name] == childName then
            return v
        end
    end
    return nil
end



--设置UI的材质目录为 ui
function UIBaseDef:setResUrlUI(  )
    resUrl = uiUrl
end

--设置地形的目录为 map
function UIBaseDef:setResUrlMap(  )
    resUrl = mapUrl
end

--设置map动态名称
function UIBaseDef:setDynamicName(value )
    dynamicName = value
end


local blendModeMap = {
    BLEND_NORMAL =0,
    BLEND_LAYER = 1,
    BLEND_DARKEN = 2,
    BLEND_MULTIPLY =3,
    BLEND_LIGHTEN=4,
    BLEND_SCREEN=5,
    BLEND_OVERLAY=6,
    BLEND_HARD_LIGHT=7,
    BLEND_ADD=8,
    BLEND_SUBSTRACT=9,
    BLEND_DIFFERENCE=10,
    BLEND_INVERT=11,
    BLEND_ALPHA=12,
    BLEND_ERASE =13,
};




function UIBaseDef:getChildByName( name )
    return self[name]
end

--设置view的transfrom: x,y,sx,sy,rx,ry,alpha等
function UIBaseDef:setTransform( view,cfgs )
    local  transfrom = cfgs[self.prop_matrix]
    local xpos,ypos,sx,sy,rx,ry = unpack(transfrom)

    local blendMode = cfgs[self.prop_blendMode]

    if blendMode and blendMode~="0" then
        
        if view.setBlendFunc then
           blendMode = tonumber(blendMode)
            local glsrc,gldst

            if blendMode == blendModeMap.BLEND_ADD then
                glsrc = gl.SRC_ALPHA
                gldst = gl.ONE
            elseif blendMode == blendModeMap.BLEND_MULTIPLY then
                glsrc = gl.DST_COLOR
                gldst = gl.ONE_MINUS_SRC_ALPHA
            elseif blendMode == blendModeMap.BLEND_SCREEN then
                glsrc = gl.ONE
                gldst = gl.ONE_MINUS_SRC_COLOR
            else
                glsrc = gl.ONE
                gldst = gl.ONE_MINUS_SRC_ALPHA
            end
            view:setBlendFunc(glsrc,gldst)
        end
       

    end

    view:setPosition(cc.p(xpos,ypos))
    view:setScaleX(sx or 1)
    view:setScaleY(sy)
    view:setRotationSkewX(rx or 0)
    view:setRotationSkewY(ry or 0)
    local alpha = cfgs[self.prop_alpha]
    view:setOpacity( (alpha or 1) * 255)
    if cfgs[self.prop_type] ~= "btn" then
        view:setTouchEnabled(false)
    end

end

--创建子对象
function UIBaseDef:createChildArr( nd,childArr,uiView )
    if not childArr or #childArr ==0 then
        return nd
    end

    --这里是根据子对象的 类型 也就是t属性  获取对应的创建方法 以后各个游戏会根据自己的游戏 自己扩展
    local childView,name
    for i,v in ipairs(childArr) do
        name = v[self.prop_name]
        local func = self["get_"..v[self.prop_type]]
        if not func then
            dump(cfgs,"cfgs")
            error("not find targetFunc::get_"..tostring(v[self.prop_type]).."__prop_type:"..tostring(self.prop_type) )
        end
        childView = func(self,v):addTo(nd)
        childView.__uiCfg = v
        --给name赋属性值
        if uiView then
            uiView[name] = childView
        else
            nd[name] = childView
        end
    end
    return nd
end

--根据uiName创建UI
function UIBaseDef:createUIByName( uiName,classModel,...)
    --这里为了不与配置文件的lua名冲突, 我们实际的ui名字前面加一个G 或者根据项目需求自定义配对关系
    local anaName = string.split(uiName,"_")
    local uiDatas
    local winName
    local isNeedLoadAniTex = false;
    local uiView = nil;
    
    if anaName[1] ~= "map" then
        classModel = classModel or WindowsTools:getClassByUIName(uiName)
        winName = classModel.__cname or WindowsTools:getWindowNameByUIName(uiName )
        UIBaseDef._winLoadCompleteInfo[winName] = {aniLoadNum = 0, isUIConfigLoad = false, isAniLoad = false};

        resUrl = uiUrl
        uiDatas = require(cfgUIUrl..uiName)

        local windowCfg = WindowsTools:getUiCfg(winName)

        uiView = classModel.new(winName, ...)

        --这里动态加载ui材质
        if not CONFIG_USEDISPERSED  then 
            FuncRes.addOneUITexture( uiName  )
            -- display.addSpriteFrames("ui/" ..uiName..".plist", "ui/" ..uiName..CONFIG_UI_PNGTYPE)
        end
        --判断通用的材质集名称
        local commonTextureName = string.split(uiName,"_")
        commonTextureName = commonTextureName[1].."_" ..commonTextureName[2].."_common"
        --加载通用材质
        if not CONFIG_USEDISPERSED and (cc.FileUtils:getInstance():isFileExist("ui/" ..commonTextureName ..".plist"  )) then 
            FuncRes.addOneUITexture( commonTextureName  )
            uiView.__commonTextureName = commonTextureName
        end

        if not CONFIG_USEDISPERSED  then 
            FuncRes.addOneUITexture( "global1" );
        end 

        dynamicName = nil

        
        function armatureLoadCompleteCallBack(winName, winAniNum, uiView)
            UIBaseDef._winLoadCompleteInfo[winName].aniLoadNum = UIBaseDef._winLoadCompleteInfo[winName].aniLoadNum + 1;
            if self._winLoadCompleteInfo[winName].aniLoadNum == winAniNum  then  
                if self._winLoadCompleteInfo[winName].isUIConfigLoad == true then --ui配置也加载完成 
                    self._winLoadCompleteInfo[winName] = nil;
                    uiView:loadUIComplete();
                    uiView._root:setVisible(true);
                else 
                    self._winLoadCompleteInfo[winName].isAniLoad = true;
                end 
            end 
        end

        --如果有加载动画的
        --异步加载
        if windowCfg.aniTex then
            isNeedLoadAniTex = true;
            local aniNum = table.length(windowCfg.aniTex);
            for k, v in pairs(windowCfg.aniTex) do
                if IS_AYSNC_LOAD_ANITEX == true then 
                    FuncArmature.loadOneArmatureTexture(v, 
                        c_func(armatureLoadCompleteCallBack, winName, aniNum, uiView), false);
                else 
                    FuncArmature.loadOneArmatureTexture(v, nil, true);
                end 
            end
        end

    else
        resUrl = mapUrl
        classModel = classModel or BattleMapTools:getClassByUIName(uiName)
        winName = classModel.__cname or  BattleMapTools:getWindowNameByUIName(uiName )
        UIBaseDef._winLoadCompleteInfo[winName] = {aniLoadNum = 0, isUIConfigLoad = false, isAniLoad = false};

        uiDatas = require(cfgMapUrl..uiName)

        uiView = classModel.new(winName, ...)

        --如果是地图 这里直接缓存地图材质 包括动画和场景
        local aniTexture = uiDatas.ex.fla

        --目前全部采用地图 大材质集
        FuncRes.addMapTexture(aniTexture)
        
        --记录地形的名字  如果是场景 那么 需要根据这个场景名字拿图片
        dynamicName = aniTexture
    end

    local windowCfg = WindowsTools:getUiCfg(winName)
    if windowCfg.bg then
       --创建背景
       display.addImageAsync(FuncRes.iconBg(windowCfg.bg), function ( ... )
           uiView.__bgView = display.newSprite(FuncRes.iconBg(windowCfg.bg), GameVars.UIbgOffsetX, GameVars.UIbgOffsetY):anchor(0,1)
                    :addto(uiView,-2);

       end);
    end

    local rootView = display.newNode():addTo(uiView)
    uiView._root = rootView
    --初始化把uiData赋值给ui
    uiView.__uiCfg = uiDatas
    self:createChildArr(rootView, uiDatas[self.prop_child],uiView);
    uiView.getChildByName = self.getChildByName;
    self._winLoadCompleteInfo[winName].isUIConfigLoad = true;

    --所有的ui强制附加一个loadUIComplete()方法 只有在这个方法做完以后 才能进行 里面的属性访问
    if not uiView.loadUIComplete then
        echoError("uiName:" .. uiName .. "__没有注册loadUIComplete这个函数")
    end

    --有动画，在动画完成加载时调用 uiView:loadUIComplete()
    if IS_AYSNC_LOAD_ANITEX == false then 
        uiView:loadUIComplete();
        self._winLoadCompleteInfo[winName] = nil;
    else 
        if isNeedLoadAniTex ~= true or self._winLoadCompleteInfo[winName].isAniLoad == true then 
            uiView:loadUIComplete()
            self._winLoadCompleteInfo[winName] = nil;
            uiView._root:setVisible(true);
        else 
            uiView._root:setVisible(false);
        end 
    end 
    
    resUrl = uiUrl
    dynamicName= nil
    return uiView
end

--clone one ui
function UIBaseDef:cloneOneView( view )
    local cfg = view.__uiCfg
    local func = self["get_"..cfg[self.prop_type]]
    local newView = func(self,cfg)

    return newView
end


--根据配置 创建组件
function UIBaseDef:createViewByCfgs( cfg )
    local func = self["get_"..cfg[self.prop_type]]
    local newView = func(self,cfg)
    return newView
end


function UIBaseDef:get_UI( cfgs )
    local uiName = cfgs[self.prop_className]
    local uiView = self:createUIByName(uiName)

    uiView.name = cfgs[self.prop_name]
    uiView.getChildByName = self.getChildByName
    self:setTransform(uiView, cfgs)
    return uiView
end


function UIBaseDef:get_panel( cfgs )
    local nd = display.newNode()
    self:setTransform(nd, cfgs)
    local childArr = cfgs[self.prop_child]

    nd.name = cfgs[self.prop_name]

    self:createChildArr(nd, childArr)
    nd.getChildByName = self.getChildByName
    return nd
end



--获取slider
function UIBaseDef:get_slider( cfgs )
    local slider = SliderExpand.new(cfgs)

    self:setTransform(slider, cfgs)
    local childArr = cfgs[self.prop_child]

    slider.name = cfgs[self.prop_name]

    self:createChildArr(slider, childArr)
    slider.getChildByName = self.getChildByName

    slider:initComplete()

    return slider

end

function  UIBaseDef:get_btn( cfgs )
    local framesArr = cfgs[self.prop_frames]
    if not framesArr then
        dump(cfgs,"___btncfgs_")
        error("btnError")
    end
    local upView,downView,disableView
    
    upView = self:createChildArr(display.newNode(), framesArr[1])

    local isShare = false

    local btnEffType = 0

    --判断是否2帧共享同一个view
    if cfgs.co and cfgs.co.isShare then
        downView = upView
        isShare = true
        btnEffType = 0
    else
        if not framesArr[2] then
            btnEffType =1
            downView = nil--self:createChildArr(display.newNode(), framesArr[1])
        else
            -- echo(framesArr[2],#framesArr[2],cfgs.na,"__name")
            if not framesArr[2]  or #(framesArr[2]) == 0  then
                btnEffType = 2
                downView = nil--self:createChildArr(display.newNode(), framesArr[1])
            else
                downView = self:createChildArr(display.newNode(), framesArr[2])
            end

            
        end
    end

    
    if framesArr[3] then
        disableView= self:createChildArr(display.newNode(), framesArr[#framesArr])
    end
    
    local clickRect = cfgs[self.prop_clickArea]
    clickRect = cc.rect(clickRect.x,clickRect.y,clickRect.w,clickRect.h)
    local btn 
    if isShare then
        btn =BtnExpand.new(upView,nil,disableView,clickRect)
    else
        btn =BtnExpand.new(upView,downView,disableView,clickRect)
    end
    btn.__upViewCfgs = framesArr[1]
    --存储downview配置 
    btn.__downViewCfgs = framesArr[2]
    btn._isShareView = isShare
    btn.name = cfgs[self.prop_name]
    
    if btnEffType ~= 0 then
        btn:setBtnClickEff(btnEffType)
    end


    self:setTransform(btn, cfgs)
    return btn

end

function  UIBaseDef:get_txt( cfgs )
    local txtCfg = cfgs[self.prop_config]
    if not txtCfg then
        dump(cfgs,"txtCfg")
        error("txtError")
    end
   
    if txtCfg.fntName then
        return self:get_BMPTxt(cfgs)
    else
        return self:get_TTFTxt(cfgs)
    end

    return label
end


function UIBaseDef:get_rich( cfgs )
    local txtCfg = cfgs[self.prop_config]
    if not txtCfg then
        dump(cfgs,"txtCfg")
        error("txtError")
    end
    local label =  RichTextExpand.new(cfgs)  --display.newTTFLabel(params)
    label.name = cfgs[self.prop_name]
    label:setAnchorPoint(defaultAnchorPos)
    --label:enableOutline(cc.c4b(255,255,0,0),10)
    self:setTransform(label, cfgs)
    return label

    
end


--转化对齐方向
function UIBaseDef:turnAlign( halign,valign )
    
    if halign =="left" then
        halign = cc.TEXT_ALIGNMENT_LEFT
    elseif halign =="center" then
        halign = cc.TEXT_ALIGNMENT_CENTER
    elseif halign =="right" then
       halign = cc.TEXT_ALIGNMENT_RIGHT
    else
        halign = cc.TEXT_ALIGNMENT_CENTER
    end

    if valign =="up" then
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP
    elseif valign =="center" then
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    elseif valign =="down" then
        valign = cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM
    else
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    end
    return halign,valign
end


--转化锚点
function UIBaseDef:turnAlignPoint( halign,valign )
    if halign =="left" then
        halign = 0
    elseif halign =="center" then
        halign = 0.5
    elseif halign =="right" then
       halign = 1
    else
        halign = 0.5
    end

    if valign =="up" then
        valign = 1
    elseif valign =="center" then
        valign = 0.5
    elseif valign =="down" then
        valign = 0
    else
        valign = 0.5
    end
    return halign,valign
end



--位图文本的创建方式
function UIBaseDef:get_BMPTxt(cfgs)
     local txtCfg = cfgs[self.prop_config]
    if not txtCfg then
        dump(cfgs,"txtCfg")
        error("txtError")
    end
   
    local align ,valign = self:turnAlign(txtCfg.align, txtCfg.valign)
   
    local params = {
        text = txtCfg.text,
        size = txtCfg.fontSize or 24,
        --拼接字体的url 
        font =  fontUrl..txtCfg.fntName..".fnt",
        maxLineWidth = cfgs[self.prop_width],
    }
    local label = display.newBMFontLabel(params)
    label.name = cfgs[self.prop_name]
    label:setAlignment(align,valign)
    label:setDimensions(cfgs[self.prop_width],cfgs[self.prop_height])
    label:setAnchorPoint(defaultAnchorPos)
    self:setTransform(label, cfgs)
    if txtCfg.color and  txtCfg.color ~= 0 then
        label:setColor(numberToColor(txtCfg.color))
    end
    
    return label
end

--ttf的文本创建方式
function UIBaseDef:get_TTFTxt(cfgs )
    local txtCfg = cfgs[self.prop_config]
    if not txtCfg then
        dump(cfgs,"txtCfg")
        error("txtError")
    end
    local label =  TTFLabelExpand.new(cfgs)  --display.newTTFLabel(params)
    label.name = cfgs[self.prop_name]
    label:setAnchorPoint(defaultAnchorPos)
    --label:enableOutline(cc.c4b(255,255,0,0),10)
    self:setTransform(label, cfgs)

    -- dump(label:getContainerBox(),"labelbox")
    -- echo(cfgs.h,"___height")

    return label
end

--创建输入文本
function UIBaseDef:get_input( cfgs )
    local inputView = InputExpand.new(cfgs)
    self:setTransform(inputView, cfgs)

    inputView:setAnchorPoint(defaultAnchorPos)
    
    inputView:setTouchedFunc(c_func(inputView.startInput, inputView))
    -- local inputCfg =  cfgs[self.prop_config]
    -- if not inputCfg then
    --     dump(cfgs,"inputCfg")
    --     error("inputError")
    -- end


    -- local w,h = cfgs[self.prop_width],cfgs[self.prop_height]

    -- --这里一定要创建的是 editBox 默认传一个 4*4的透明背景图就可以了 因为
    -- local params = {
    --     UIInputType=1,
       
    --     size = cc.size(w,h),
    -- }


    -- local align = inputCfg.align or "center"

    -- local editBox = ccui.EditBox:create(cc.size(w,h) , display.newScale9Sprite() ,nil,nil )   --cc.ui.UIInput.new(params)
    -- --设置字体的尺寸颜色 宽高
    -- editBox:setFontSize(inputCfg.fontSize)
    -- editBox:setFontColor( numberToColor(inputCfg.color or 0) )
    -- editBox:setMaxLength(inputCfg.maxLength)
    
    -- --因为这里有一个对齐方式 ,如果我们希望输入文本是靠右对齐的 那么这里需要动态的修改文本的坐标,只有左对齐不需要

    -- local transfrom =  cfgs[self.prop_matrix]
    -- if align == "center" then
    --     editBox:pos(transfrom[1]+w/2,transfrom[2])
    --     editBox:setAnchorPoint(cc.p(0.5,1))
    -- elseif align =="left" then
    --     editBox:setAnchorPoint(defaultAnchorPos)
    --     editBox:pos(transfrom[1],transfrom[2])
    -- else
    --     editBox:setAnchorPoint(cc.p(1,1))
    --     editBox:pos(transfrom[1]+w,transfrom[2])
    -- end

    -- if inputCfg.passwordEnable then
        
    -- end

    --self:setTransform(editBox,cfgs)
    
    return inputView

end


function  UIBaseDef:get_image( cfgs )
    local imgName = cfgs[self.prop_image]
    local sp 
    --如果是场景 直接拿 材质集
    if dynamicName then
        sp = display.newSprite("#" ..imgName)
    else
        if CONFIG_USEDISPERSED  then
            sp = display.newSprite(resUrl ..imgName)
        else
            sp = display.newSprite("#" ..imgName)
        end
        
    end



    self:setTransform(sp,cfgs)

    if resUrl == mapUrl then
        -- echo("___设置sp缩放----")
        local sx = sp:getScaleX()
        local sy = sp:getScaleY()
        sp:setScaleX(1/mapScale * sx)
        sp:setScaleY(1/mapScale * sy)
    end

    local anchor = cfgs[self.prop_anchor]
    if anchor then
        sp:setAnchorPoint(anchor)
    else
        sp:setAnchorPoint(defaultAnchorPos)
    end
    return sp
end


-- 获取进度条
function UIBaseDef:get_progress(cfgs)
    -- dump(cfgs)
    local progress = ProgressBar.new(cfgs)
    self:setTransform(progress,cfgs)
    progress.name = cfgs[self.prop_name]
    return progress    
end

-- -- 获取圆形进度条
-- function UIBaseDef:get_circle(cfgs)
    
--     local image = resUrl ..cfgs[self.prop_image]
--     local circleProgress = display.newProgressTimer(image, display.PROGRESS_TIMER_RADIAL)
--     circleProgress.name = cfgs[self.prop_name]
--     -- 注册 get set 方法   是为了和自定义的progress组件 方法保持一致
--     circleProgress.setPercent = circleProgress.setPercentage
--     circleProgress.getPercent = circleProgress.getPercentage

--     self:setTransform(circleProgress,cfgs)
--     return circleProgress    
-- end


function UIBaseDef:get_scale9( cfgs )
    local imgName = cfgs[self.prop_image]
    local scale9Rect = cfgs[self.prop_scale9]
    local wid = cfgs[self.prop_width]
    local hei = cfgs[self.prop_height]

    local srect = cc.rect(scale9Rect.x,scale9Rect.y,scale9Rect.w,scale9Rect.h)

    local sp
    if CONFIG_USEDISPERSED  then
         sp = display.newScale9Sprite(resUrl..imgName,nil,nil,cc.size(wid,hei),srect)
    else
         sp = display.newScale9Sprite("#"..imgName,nil,nil,cc.size(wid,hei),srect)
    end

    --定义他的__cname 为scale9Sprite
    sp.__cname = "scale9Sprite"
    
    self:setTransform(sp,cfgs)
    sp:setAnchorPoint(defaultAnchorPos)
    return sp
end

--获取 rect背景组件
function UIBaseDef:get_rect(cfgs )
    local wid = math.round(cfgs[self.prop_width])
    local hei = math.round(cfgs[self.prop_height])
    local posx = math.round(cfgs[self.prop_matrix][1])
    local posy = math.round(cfgs[self.prop_matrix][2])

    local fullScreen = false

    local color  =cc.c3b(255,255,255)

    local alpha=100

    local lineAlpha = 100

    local lineColor= cc.c3b(0,0,0)
    
    local lineWid = 0


    if cfgs.co  then
        fullScreen = cfgs.co.fullScreen

        if cfgs.co.mcolor then
            color = numberToColor(cfgs.co.mcolor)
        end

        if cfgs.co.malpha then
            alpha = cfgs.co.malpha
        end

        if cfgs.co.lineColor then
            lineColor = numberToColor(cfgs.co.lineColor)
        end

        if cfgs.co.lineWid then
            lineWid = cfgs.co.lineWid /2
        end

        if cfgs.co.lineAlpha then
            lineAlpha = cfgs.co.lineAlpha
        end


    end

    if fullScreen then
        wid  = GameVars.width 
        hei = GameVars.height 
        posx = 0
        posy = 0
    end

    local rect = cc.rect(0, -hei,wid, hei)

    local sp=  display.newRect( rect,
        {fillColor = cc.c4f(color.r/255, color.g/255,color.b/255,alpha/100), borderColor = cc.c4f(lineColor.r/255,lineColor.g/255,lineColor.b/255,lineAlpha/100), borderWidth = lineWid})
    sp:pos(posx,posy)
    sp.__rect = rect
    sp:anchor(0,0)
    sp:setContentSize(cc.size(rect.width,rect.height))
    sp.getContainerBox =function (self  )
        return self.__rect
    end

    sp:setCascadeOpacityEnabled(true)
    -- sp.getContentSize = function (self  )
    --     return {width =self.__rect.width,height = self.__rect.height}
    -- end


    return sp

end

--获取 circle背景组件
function UIBaseDef:get_circle(cfgs )
    local wid = math.round(cfgs[self.prop_width])
    local hei = math.round(cfgs[self.prop_height])
    local posx = math.round(cfgs[self.prop_matrix][1])
    local posy = math.round(cfgs[self.prop_matrix][2])

    local fullScreen = false

    local color  =cc.c3b(255,255,255)

    local alpha=100

    local lineAlpha = 100

    local lineColor= cc.c3b(0,0,0)
    
    local lineWid = 0


    if cfgs.co  then
        fullScreen = cfgs.co.fullScreen

        if cfgs.co.mcolor then
            color = numberToColor(cfgs.co.mcolor)
        end

        if cfgs.co.malpha then
            alpha = cfgs.co.malpha
        end

        if cfgs.co.lineColor then
            lineColor = numberToColor(cfgs.co.lineColor)
        end

        if cfgs.co.lineWid then
            lineWid = cfgs.co.lineWid /2
        end

        if cfgs.co.lineAlpha then
            lineAlpha = cfgs.co.lineAlpha
        end


    end

    if fullScreen then
        wid  = GameVars.width 
        hei = GameVars.height 
        posx = 0
        posy = 0
    end

    local a = wid/2
    local b = hei/2


    sp = display.newEllipse(a,b,
        {x = a, y = b,
        fillColor = cc.c4f(color.r/255, color.g/255,color.b/255,alpha/100),
        borderColor = cc.c4f(lineColor.r/255,lineColor.g/255,lineColor.b/255,lineAlpha/100),
        borderWidth = lineWid})

    sp:pos(posx,posy)
    sp:anchor(0,1)
    sp:setCascadeOpacityEnabled(true)
    sp:setContentSize(wid,hei)
    sp.__rect = cc.rect(0,0,wid,hei)
    sp.getContainerBox =function (self  )
        return self.__rect
    end

    return sp

end



function  UIBaseDef:get_scroll( cfgs )
    -- dump(cfgs, "get_scroll")
    local wid = math.round(cfgs[self.prop_width])
    local hei = math.round(cfgs[self.prop_height])
    local posx = math.round(cfgs[self.prop_matrix][1])
    local posy = math.round(cfgs[self.prop_matrix][2])

    local params = nil;

    if cfgs.co == nil or cfgs.co.cl == nil then
        params = {
            bgColor = cc.c4b(200, 200, 200, 0),
            viewRect = cc.rect(0,-hei, wid, hei),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            }
    else
        params = {
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            numColumns = cfgs[self.prop_config][self.prop_scroll_num],
            xlineGap = cfgs[self.prop_config][self.prop_scroll_dx],
            ylineGap = cfgs[self.prop_config][self.prop_scroll_dy],
            GridViewWidth = cfgs[self.prop_width],
            GridViewHeight = cfgs[self.prop_height],
            itemClass = cfgs[self.prop_config][self.prop_className],
            xOffset = cfgs[self.prop_config][self.prop_scroll_ox],
            yOffset = cfgs[self.prop_config][self.prop_scroll_oy],
        };
    end

    local scrollcfg = cfgs[self.prop_config] or {scrollType = "vertical"}

    if scrollcfg.scrollType == "both" then
        params.direction = cc.ui.UIScrollView.DIRECTION_BOTH
    elseif scrollcfg.scrollType == "vertical" or not scrollcfg.scrollType then
        params.direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
        params.scrollbarImgV = FuncRes.bar("bar.png") 
        params.scrollbarImgVbg = FuncRes.bar("bar_bg.png") 
    elseif scrollcfg.scrollType == "horizontal" then 
        params.direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL
        params.scrollbarImgH = FuncRes.bar("bar2.png") 
        params.scrollbarImgHbg = FuncRes.bar("bar2_bg.png") 
    end
    local scroll = nil;
    if cfgs.co == nil or cfgs.co.cl == nil or cfgs.co.cl == "" then
        scroll = ScrollViewExpand.new(params):pos(posx,posy)
    else 
        scroll = GridView.new(params):pos(posx,posy)
    end 

    if scroll.sbV then
        scroll.sbV:setVisible(false)
    end

    if scroll.sbH then
        scroll.sbH:setVisible(false)
    end

    scroll.name = cfgs[self.prop_name]
    return scroll
end

--获取一个list
function UIBaseDef:get_list( cfgs )
    return self:get_scroll(cfgs)
end

function  UIBaseDef:get_mc( cfgs )
    local mc = MultiStateExpand.new(cfgs)
    self:setTransform(mc, cfgs)
    return mc
end

--获取一个空容器
function UIBaseDef:get_ctn( cfgs )
    local nd = display.newNode()
    self:setTransform(nd,cfgs)
    nd.name = cfgs[self.prop_name]

    nd.ctnWidth = cfgs[self.prop_width]
    nd.ctnHeight = cfgs[self.prop_height]
    
    return nd
end


--获取ani
function UIBaseDef:get_ani( cfgs )
    local name = cfgs[self.prop_name]
    local nameArr = string.split(name,"ani_" )
    name = nameArr[2]
    --这里 所有动画的属性名都是固定的ani_{aniName}_c_index  的形式  取中间一段为动画的名字  这样是为了编辑配置方便
    nameArr = string.split(name,"_c_" )
    local aniName = nameArr[1]
    local cl = cfgs[self.prop_className]
    if cl then
        aniName = cl
    end
    local flaName =FuncArmature.getArmatureFlaName(aniName)
    if flaName then
        FuncArmature.loadOneArmatureTexture(flaName, nil, true)
    end

    local ani = FuncArmature.createArmature(aniName, nil, true)  
    self:setTransform(ani,cfgs)
    ani:getAnimation():playWithIndex(0,0,1)
    return ani

end






if not bit then
    require("cocos.cocos2d.bitExtend")
end

local nums_ff0000 = 16711680 
local nums_00ff00 = 65280
local nums_0000ff =  255 

--将颜色的十进制数字 比如8587723 等 转化成 cc.c3b
function numberToColor( num )
    local r = bit.rshift( bit.band(num,nums_ff0000),16 )
    local g = bit.rshift( bit.band(num,nums_00ff00),8 )
    local b =  bit.band(num,nums_0000ff)
    return cc.c3b(r,g,b)
end





function UIBaseDef:turnFontName( fontName )

    -- local fontUrl = "fnt/"
    local fontUrl = ""

    if not fontName then
        return   fontUrl..GameVars.fontName
    end

    --如果是游戏字体1
    if fontName == "gameFont1" then
        return GameVars.fontName

    elseif fontName == GameVars.fontName then
        return fontUrl .. GameVars.fontName
    elseif fontName == "systemFont" then
        return  GameVars.systemFontName
    elseif fontName =="SimHei" then
        return GameVars.systemFontName
    end
   
    return  fontUrl ..GameVars.fontName

end




return UIBaseDef
