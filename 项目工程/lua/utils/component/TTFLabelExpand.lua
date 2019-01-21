local TTFLabelExpand = class("TTFLabelExpand", function ( )
    return display.newNode()
end
)


local txtOffestX =0
local txtOffestY =3         --ttf字体变化这个值需要动态修改

-- if device.platform =="mac" then
--     txtOffestY = 8
-- end

local sysTxtOffestX = 0
local sysTxtOffestY = 1     --系统字体y偏移



--如果有投影或者 外发光  需要单独判断 因为win32还没实现
TTFLabelExpand.childLabels   =nil  


function TTFLabelExpand:ctor( cfgs )
    local txtCfg = cfgs[UIBaseDef.prop_config]
    local align ,valign = UIBaseDef:turnAlign(txtCfg.align, txtCfg.valign)
    local params = {
        font = UIBaseDef:turnFontName(txtCfg.fontName),
        text = txtCfg.text or "",
        size = txtCfg.fontSize or 24,
        align = align,
        valign = valign,
        color = numberToColor(txtCfg.color or 0),
        dimensions = cc.size(cfgs[UIBaseDef.prop_width],cfgs[UIBaseDef.prop_height]),
        kerning = txtCfg.kerning or 0
    }

    self.cfgs = cfgs
    self.params = params
    self.childLabels = {}

    if self.params.font ==GameVars.systemFontName then
        self._fontOffsetX = sysTxtOffestX
        self._fontOffsetY = sysTxtOffestY
    else
        self._fontOffsetX = txtOffestX
        self._fontOffsetY = txtOffestY
    end

    --判断是否是自动匹配
    params.color.a = (cfgs.a or 1) *255
	self.origin_color = params.color
    --组件配置
    local ccfg = cfgs[UIBaseDef.prop_config]
    --[[if device.platform  == "android"  then
        print("params.font=",params.font)
        params.font = "fnt/" .. params.font .. ".TTF";
    end--]]
    local label = display.newTTFLabel(params)
    self.baseLabel = label
    label:setAnchorPoint(cc.p(0,1))
    -- label:pos(self._fontOffsetX,self.params.dimensions.height +self._fontOffsetY)
    label:pos(self._fontOffsetX,self:getOffsetY() )
    label:setCascadeOpacityEnabled(true)
    label:setLineBreakWithoutSpace(true)
    label.baseColor = params.color

    if self.params.kerning and self.params.kerning ~=0 then
        -- label:setAdditionalKerning(self.params.kerning)
    end


    -- label:setMaxLineWidth(self.params.dimensions.width)
    table.insert(self.childLabels, label)

    if ccfg.outLineSize and ccfg.outLineSize > 0 then
       
        self:setOutLine(numberToColor(ccfg.outLine or 0),ccfg.outLineSize,ccfg.outLineAlpha )
    end
    

    if ccfg.shadowPos and (ccfg.shadowPos[1]> 0 or ccfg.shadowPos[2] >0 ) then
        self:setShadow(numberToColor(ccfg.shadow or 0),ccfg.shadowPos,ccfg.shadowAlpha )
    end

    -- self:setString(ccfg.text)
    label:addto(self)
    -- self:setContentSize(cc.size(self.params.dimensions.width,self.params.dimensions.height))

end


function TTFLabelExpand:getOffsetY(  )
    if device.platform =="mac" then
        local fontSize = self.params.size
        --目前mac暂时用这一版调配出来的数值 做偏移
        local offsetY = self._fontOffsetY + math.pow( fontSize/24,4 )/1.8 +1
        return offsetY

    elseif(device.platform=="android")then
         local      _offsetY=0;
         if(self.params.font ==GameVars.systemFontName)then
                 _offsetY= math.pow(self.params.size/24,6.28)/1.532+1;
         end
         return  self._fontOffsetY+_offsetY;
    else
        return self._fontOffsetY
    end

end


function TTFLabelExpand:getContainerBox()
    return {x=0,y=-self.params.dimensions.height,width=self.params.dimensions.width,height=self.params.dimensions.height}
end


function TTFLabelExpand:getStringNumLines(  )
    return self.childLabels[1]:getStringNumLines()
end

function TTFLabelExpand:getStringLength(  )
    return self.childLabels[1]:getStringLength()
end

local posWay = { {-1,0},{1,0},{0,1},{0,-1}  }

function TTFLabelExpand:getContentSize()
    local ss = cc.size(self.params.dimensions.width,self.params.dimensions.height)
    return ss
end


--给文本设置滤镜
function TTFLabelExpand:setLabelFtParams( ftParams )
    
    for i,v in ipairs(self.childLabels) do
        local turnColor =  FilterTools.turnFilterColor(v.baseColor, ftParams )
        v:setColor(turnColor)
        v:opacity(turnColor.a)
    end
end


--文本置灰
function TTFLabelExpand:resumeOrGray(value)


    for i,v in ipairs(self.childLabels) do
        if value == true then
            --那么还原成 基础颜色
            v:setColor(v.baseColor)
        else
            local turnColor = FilterTools.turnGrayColor( v.baseColor )
            --否则置灰
            v:setColor(turnColor)
        end
    end

    --如果是ios平台 

    --如果是有投影的
    -- if self.baseLabel._shadowInfo  then
    --     if value ==true then
    --         self.baseLabel:enableShadow(self.baseLabel._shadowInfo[1],self.baseLabel._shadowInfo[2])
    --     else
    --         self.baseLabel:enableShadow(FilterTools.turnGrayColor( self.baseLabel._shadowInfo[1] ),self.baseLabel._shadowInfo[2])
    --     end
        
    -- end

    -- --如果是有发光效果的 或者是ios或者android平台
    -- if self.baseLabel._outLineInfo  then
    --     if value ==true then
    --         self.baseLabel:enableOutline(self.baseLabel._outLineInfo[1],self.baseLabel._outLineInfo[2])
    --     else
    --         self.baseLabel:enableOutline(FilterTools.turnGrayColor( self.baseLabel._outLineInfo[1] ) ,self.baseLabel._outLineInfo[2])
    --     end
    -- end
end

function TTFLabelExpand:setColor(color)
    local label = self.childLabels[1]
    label.baseColor = color
    label:setColor(color)
end

function TTFLabelExpand:getOriginColor()
	return self.origin_color
end



function TTFLabelExpand:setTextHeight( hei )
    for i,v in ipairs(self.childLabels) do
        v:setHeight(hei)
    end
end

function TTFLabelExpand:setOutLine( color,length,alpha )
    if not length or length ==0 then
        return
    end
    alpha = alpha or 1
    if length > 1 then
        length = 1
    end
    color.a = alpha * 255
    --如果是ios或者android
    -- if (device.platform  == "ios" or device.platform  =="android" )  then
     if false then
        local c4b = cc.c4b(color.r,color.g,color.b,alpha *255)
        self.baseLabel:enableOutline(c4b,length)

        self.baseLabel._outLineInfo = {c4b,length}

    else
        for i=1,4 do
            local ttflabel = display.newTTFLabel(self.params):addto(self)
            ttflabel:setColor(color)
            ttflabel.baseColor = color
            local way = posWay[i]
            -- ttflabel:pos(way[1]*length + txtOffestX,way[2]*length + txtOffestY)
            -- ttflabel:setAnchorPoint(cc.p(0,0))

            ttflabel:setAnchorPoint(cc.p(0,1))
            -- ttflabel:pos(way[1]*length + self._fontOffsetX,self.params.dimensions.height +way[2]*length + self._fontOffsetY )
            ttflabel:pos(way[1]*length + self._fontOffsetX,way[2]*length + self:getOffsetY() )


            ttflabel:setCascadeOpacityEnabled(true)
            ttflabel:setLineBreakWithoutSpace(true)
            ttflabel:opacity(alpha*255)
            if self.params.kerning and self.params.kerning ~=0 then
                label:setAdditionalKerning(self.params.kerning)
            end
			ttflabel._is_outline = true
            table.insert(self.childLabels, ttflabel)
        end
    end
end

function TTFLabelExpand:disableOutLine()
    -- if device.platform == "ios" or device.platform == "android" and false then
	if false then
        local c4b = cc.c4b(255,255,255,0)
        self.baseLabel:enableOutline(c4b,1)
		self.baseLabel._outLineInfo = {c4b, 1}
	else
		for i,v in ipairs(self.childLabels) do
			if v._is_outline then
				v:visible(false)
			end
		end
	end
end

function TTFLabelExpand:setChildStr( text )
    for i,v in ipairs(self.childLabels) do
        v:setString(text)
    end
end

function TTFLabelExpand:setString(text )
    -- local lineLength = string.countTextLineLength( self.params.dimensions.width,self.params.size ) 
    -- local turnStr = string.turnStrToLineStr(text,lineLength)
    self._labelString = text
    self:setChildStr(text)
end


function TTFLabelExpand:setShadow( color,pos ,alpha)
    if not pos or (pos[1]==0 and pos[2] ==0) then
        return
    end
     alpha = alpha or 1

     if device.platform  == "ios" or device.platform  =="android"  then
--    if  false then
        local c4b = cc.c4b(color.r,color.g,color.b,alpha *255)
        local sz = cc.size(pos[1],pos[2])
        self.baseLabel:enableShadow(color,sz)
        self.baseLabel._shadowInfo = {c4b,sz}
    else
        local ttflabel = display.newTTFLabel(self.params):addto(self)
        ttflabel:setColor(color)
        ttflabel.baseColor = color
        ttflabel:setAnchorPoint(cc.p(0,0))
        ttflabel:setCascadeOpacityEnabled(true)
        ttflabel:setLineBreakWithoutSpace(true)
        ttflabel:opacity(alpha*255)
        if self.params.kerning and self.params.kerning ~=0 then
            label:setAdditionalKerning(self.params.kerning)
        end

        ttflabel:pos(pos[1] + self._fontOffsetX,-pos[2] + self:getOffsetY() )
        table.insert(self.childLabels, ttflabel)
    end
end

-- 初始化默认值
function TTFLabelExpand:initData()
    self.defaultSpeed = 10              --每秒几个字
    self.tagCount = 1
    self.charCount = 1
    self.skip = false
end


function TTFLabelExpand:startPrinter(text,speed)
    -- 初始化默认值
    self:initData()
    self.text = text
    
    self.speed = speed
    -- print("self.text=",self.text)
    -- 数据格式转换
    self.textCfgList = string.split2Array(self.text)

    local frame = GAMEFRAMERATE / self.speed
    if frame < 1 then
        self.delay = 1 / GAMEFRAMERATE
    else
        self.delay = frame / GAMEFRAMERATE
    end

    self:createText()
end

-- 跳过打印机
function TTFLabelExpand:skipPrinter()
    self.skip = true

    local str = table.concat(self.textCfgList,"",1,#self.textCfgList)
    self:setString(str)
end

-- 创建文本
function TTFLabelExpand:createText()
    if self.charCount > #self.textCfgList or self.skip == true then
        return
    end

    -- local char = self.textCfgList[self.charCount]
    -- self:createElementText(cfg)
    local str = table.concat(self.textCfgList,"",1,self.charCount)
    self:setString(str)

    self.charCount = self.charCount + 1
    self.tagCount = self.tagCount + 1

    self:delayCall(c_func(self.createText, self),self.delay)
end


--获取每行支持的字符数量
function TTFLabelExpand:getLineLength(  )
    local fontSize = self.params.size
    local wid = self.params.dimensions.width
    return  string.countTextLineLength( wid,fontSize )

end


--判断一个文本是不是单行文本
function TTFLabelExpand:checkIsOneLine(  )
    local wid = FuncCommUI.getStringWidth(self._labelString, self.params.size, self.params.font)
    --如果小于文本的宽度 那么表示是 单行文字
    if wid <= self.params.dimensions.width then
        return true
    end
    --否则是多行文字
    return false
end

function TTFLabelExpand:setAlignment(aligment)
    for k,v in pairs(self.childLabels) do
        v:setAlignment(aligment);
    end
end

function TTFLabelExpand:getFontSize()
	return self.params.size
end

function TTFLabelExpand:getFont()
	return self.params.font
end


return TTFLabelExpand
