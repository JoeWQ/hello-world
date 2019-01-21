
local RichTextExpand = class("RichTextExpand", function ()
    return display.newNode()
end)

RichTextExpand._label = display.newTTFLabel( { })
RichTextExpand._label:retain()

function RichTextExpand:ctor(cfgs)
    cfgs = cfgs or { }
    local txtCfg = cfgs[UIBaseDef.prop_config]
    txtCfg = txtCfg or { }
    self.defaultSpeed = 10
    -- 每秒几个字

        self.ALIGNMENT_TYPE =
    {
        LEFT = 0,
        CENTRE = 0.5,
        RIGHT = 1,
    }
    self._isOneLine = txtCfg

    self.defaultFont = UIBaseDef:turnFontName(txtCfg.fontName)

    self.defaultOpacity = 255
    self.defaultColor = cc.c3b(0, 0, 0)

    if txtCfg.color then
        self.defaultColor = numberToColor(txtCfg.color)
    end


    self.defaultFontSize = txtCfg.fontSize or 24

    local align, valign = UIBaseDef:turnAlignPoint(txtCfg.align, txtCfg.valign)

    local wid, hei = cfgs[UIBaseDef.prop_width] or 100, cfgs[UIBaseDef.prop_height] or 100

    self._wid = wid
    self._hei = hei
    self._halign = align
    self._valign = valign
    self._label = nil

    self.speed = self.defaultSpeed

    if txtCfg.text then
        self:setString(txtCfg.text)
    end

--    dump(self._richText:getVirtualRendererSize(), "____")
    -- echo(cfgs[UIBaseDef.prop_width],cfgs[UIBaseDef.prop_height],"____尺寸")

    self:setContentSize(cc.size(self._wid, self._hei))
 

end

-- --重写获取尺寸
-- function RichTextExpand:getContentSize()
--     return {width = self._wid,height = self._hei }
-- end


-- 初始化富文本 有个子对象是  富文本
function RichTextExpand:initRichText()
    if self._richText then
        self._richText:removeFromParent(true)
        self._richText = nil
    end
    self._richText = ccui.RichText:create()
    self._richText:setCascadeOpacityEnabled(true)
    self._richText:addto(self)
    self._richText:setContentSize(cc.size(self._wid, self._hei))
    self._richText:ignoreContentAdaptWithSize(false)
    self._richText:anchor(self._halign, self._valign)
    local xpos = 2 * self._halign * self._wid - 0.5 * self._wid
    -- local xpos = 0.5 * self._wid  --+ self._halign * self._wid

    local offsetX = 0

    if self._halign == self.ALIGNMENT_TYPE.CENTRE or self._halign == self.ALIGNMENT_TYPE.RIGHT then

         RichTextExpand._label:setString("") 
         RichTextExpand._label:setSystemFontSize(self.defaultFontSize)
        local _lx = RichTextExpand._label:getContentSize().width
        local _wchar = self:parseRichText()
        local _text = ""
        for i = 1, #_wchar do
            _text = _text .. _wchar[i].char
        end
        RichTextExpand._label:setString(_text)

        offsetX = _yuan3(self._halign == self.ALIGNMENT_TYPE.CENTRE, self._richText:getContentSize().width / 2 - RichTextExpand._label:getContentSize().width / 2 ,
        self._richText:getContentSize().width - RichTextExpand._label:getContentSize().width )
 
    elseif self._halign == self.ALIGNMENT_TYPE.LEFT then


    end
    local ypos = 0.5 * self._hei - self._hei *(1 - self._valign) * 2
    -- local ypos = -0.5*self._hei    --- self._valign * self._hei + self._hei
    self._richText:pos(xpos + offsetX, ypos + self._hei)

end

-- 初始化默认值
function RichTextExpand:initData()
	
	self.tagCount = 1
	self.charCount = 1
	self.skip = false
end

-- 解析富文本
function RichTextExpand:parseRichText()
    -- local str = "我是<color = 0000ff>小明<->,多来点钱,<color=0000ff>大名<->钱不够--少给点"
    local str = self.text
    local resultObj = {}

    --把换行符单独作为一个特殊的 字符 作为一组
    str = string.gsub(str,"\\n","\n")
    str = string.gsub(str,"\n","<newline=1>\n<->")

    local req = "<(.-)>(.-)(<%->)"
    local pos =0
    
	local length = string.len(str)
	local info1 

	local reqFunc = function (  )
		return string.find(str,req,pos )
	end

	for st,sp,p1,p2,p3 in reqFunc do
		info1 = {char= string.sub(str, pos, st - 1)  }
        table.insert(resultObj, info1)
        
        local info2 = {char = p2 }
        if p1 then
        	p1 = string.gsub(p1, "[%s\n\r\t]+", "")

        	local richTxt = p1
        	local richArr = string.split(p1,",")  --p1.split(",")
        	for k,v in pairs(richArr) do
        		local childArr =string.split(v,"=")
        		info2[childArr[1]] = childArr[2]
        	end
        	table.insert(resultObj, info2)
		end
        pos = sp+1
	end
	
    if pos < string.len(str) then
    	info1 = {char= string.sub(str, pos)  }
    	table.insert(resultObj, info1)
    end

    --判断换行符



    return resultObj
end




-- 将富文本转成打印机格式
function RichTextExpand:content2PrinterFormat(richTxtArr)
    local printerRichCharArr = {}
    for i=1,#richTxtArr do
        local richTxt = richTxtArr[i]
        local richCharArr = string.split2Array(richTxt.char)

        for i=1,#richCharArr do
            local richChar = {}
            
            if richTxt.rich ~= nil then
                for k,v in pairs(richTxt) do
                    richChar[k] = v
                end
            end
            richChar.char = richCharArr[i]
            printerRichCharArr[#printerRichCharArr+1] = richChar
        end
    end

    return printerRichCharArr
end




-- 开启打字机
function RichTextExpand:startPrinter(text,speed)
--	self:ignoreContentAdaptWithSize(false)
	
	self.text = text
	self:initRichText()

	-- 初始化默认值
	self:initData()

	local formatRichText = self:parseRichText()

	self.textCfgList = self:content2PrinterFormat(formatRichText)
	
	self.speed = speed

	local frame = GAMEFRAMERATE / self.speed 
	if frame < 1 then
        self.delay = 1 / GAMEFRAMERATE
    else
        self.delay = frame / GAMEFRAMERATE
    end

	self:createText()
end


--直接显示
function RichTextExpand:setString(text)
	self.text = text
	--self:ignoreContentAdaptWithSize(false)
	
	self:initRichText() 
	-- 初始化默认值
	self:initData() 

	self.textCfgList = self:parseRichText()
	for i=1,#self.textCfgList do
		local cfg = self.textCfgList[i]
		self:createElementText(cfg)
	end

end


-- 跳过打印机
function RichTextExpand:skipPrinter()
	self.skip = true

	for i=self.charCount,#self.textCfgList do
		local cfg = self.textCfgList[i]
		self:createElementText(cfg)
		self.tagCount = self.tagCount + 1
	end
end

-- 创建文本
function RichTextExpand:createText()
	if self.charCount > #self.textCfgList or self.skip == true then
		return
	end

	local cfg = self.textCfgList[self.charCount]
	self:createElementText(cfg)

	self.charCount = self.charCount + 1
	self.tagCount = self.tagCount + 1

	self:delayCall(c_func(self.createText, self),self.delay)
end

-- 创建文本元素
function RichTextExpand:createElementText(cfg)
	local char = cfg.char
	local opacity = cfg.opacity or self.defaultOpacity
	local fontName = cfg.font or self.defaultFont
	local fontSize = cfg.size or self.defaultFontSize

	local color
	if cfg.color then
		color = self:createColor(cfg.color)
	else
		color = self.defaultColor
	end
	-- self:createColor(colorStr)
	 

	if char == "\n" then
		self:addNewLine()
	else
		local richTextEle = self:getRichElementText(self.tagCount,color,opacity,char,fontName,fontSize)
   		self:pushBackElement(richTextEle)
	end
end



function RichTextExpand:pushBackElement( element )
	self._richText:pushBackElement(element) 
end

function RichTextExpand:createColor(colorStr)
	local r = string.sub(colorStr,1,2)
	local g = string.sub(colorStr,3,4)
	local b = string.sub(colorStr,5,6)

	local rc = string.format("%d","0x" .. r)
	local gc = string.format("%d","0x" .. g)
	local bc = string.format("%d","0x" .. b)

	-- print("rgb=",rc,gc,bc)
	return cc.c3b(rc,gc,bc)
end

function RichTextExpand:getRichElementText(tag, color, opacity, text, fontName, fontSize)
	local re = ccui.RichElementText:create(tag, color, opacity, text, fontName, fontSize)
	
	return re
end

function RichTextExpand:getRichElementImage(tag, color, opacity, filePath)
	local reimg = ccui.RichElementImage:create(tag, color, opacity, filePath)
	
	return reimg
end

function RichTextExpand:getRichElementCustomNode(tag, color, opacity, nd)
	
    local recustom = ccui.RichElementCustomNode:create(tag, color, opacity, nd)
    
    return recustom
end


--获取带下划线的文本
function RichTextExpand:getRichElementLinkLineNode(tag, color, opacity, text, fontName, fontSize)
	local re = display.newTTFLabel({
	    text = text,
	    font = fontName,
	    size = fontSize,
	    color = color,
	    align = cc.TEXT_ALIGNMENT_LEFT,
	    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
	})
    re:setAnchorPoint(cc.p(0,0))
    re:opacity(opacity)
    --re:pos(pos[1],-pos[2])
    
    local linkre =cc.LayerColor:create(cc.c4b(color.r,color.g,color.b,opacity))
    linkre:setContentSize(cc.size(re:getContentSize().width,1))
    linkre:setAnchorPoint(cc.p(0,1))
    linkre:opacity(opacity)
	
	local node = display.newNode()
	node:addChild(re)
	node:addChild(linkre)
	node:setContentSize(re:getContentSize())
	local recustom = ccui.RichElementCustomNode:create(tag, color, opacity, node)
	
	return recustom
end

function RichTextExpand:addNewLine()
	local node = display.newNode()
	local size  = self:getContentSize()
	node:setContentSize(cc.size(size.width, 0.1))
	local recustom = ccui.RichElementCustomNode:create(0, cc.c3b(0, 0, 0), 255, node)
	self:pushBackElement(recustom)
end

function RichTextExpand:getContainerBox(  )
	return {x=0,y = -self._hei,width = self._wid,height = self._hei}
end


return RichTextExpand