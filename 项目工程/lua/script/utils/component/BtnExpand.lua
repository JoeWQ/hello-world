local BtnExpand = class("btnExpand", BtnBase)

BtnExpand.BTN_EFFECT_ANIM_TYPES = {
	CLICK1 = 1,
	CLICK2 = 2,
}

--按钮按下缓动帧数
local btnEaseFrame = 4


--[[
-- Usage: 暂时参考BtnImg
 ]]

--中心点


function BtnExpand:ctor(_spUp, _spDown, _spDisabled,_rect)
	assert(_spUp,"@BtnExpand:ctor(). '_spUp' is nil.")
	BtnExpand.super.ctor(self)
	self._root = display.newNode():addto(self)
	self._scaleX,self._scaleY = self:getScaleX(),self:getScaleY()
	self._click_sound_enable = true
	
	if(_spUp) then
		self:setBtnUpSp(_spUp)
	end
	if(_spDown) then
		self:setBtnDownSp(_spDown)
	end
	if(_spDisabled) then
		self:setBtnDisabledSp(_spDisabled)
	end
	
	
	-- 
	if _rect then
		self:setRect(_rect)
	else
		self:setRect(self:getContainerBox())
	end

end

--重写 setRect
function BtnExpand:setRect( rect )
	BtnExpand.super.setRect(self,rect)
	self._root:pos(self.centerPos.x,self.centerPos.y)
	if self.spUp then  self.spUp:setPosition(-self.centerPos.x,-self.centerPos.y) end
	if self.spDown then  self.spDown:setPosition(-self.centerPos.x,-self.centerPos.y) end
	if self.spDisabled then  self.spDisabled:setPosition(-self.centerPos.x,-self.centerPos.y) end
	
end

-- public functions
-- 改变按钮的有效状态，当有_spDisabled时会自动更改图片
function BtnExpand:enabled(v)
	if(v==nil) then return BtnExpand.super:enabled() end
	BtnExpand.super.enabled(self,v)
	if(self.__enabled) then -- 使有效
		self:setBtnUp()
	else  -- 使无效
		if self.spDisabled then self:setBtnDisabled() end
	end
	return self
end
-- 使按钮无效，但并不显示spDisabled
function BtnExpand:disabled(chgSpNow)
	if chgSpNow then self:enabled(0) --有参数时等同与enabled(0)
	else BtnExpand.super.enabled(self,0) end
	return self
end
--禁止按钮音效
function BtnExpand:disableClickSound()
	self._click_sound_enable = false
end

--激活按钮音效
function BtnExpand:enableClickSound()
	self._click_sound_enable = true
end
-- 设置按钮为抬起状态
function BtnExpand:setBtnUp()

	if self._isShareView then
		local upCfg = self.__upViewCfgs
		--遍历所有的upView子对象
		local childArr = self.spUp:getChildren()
		for i,v in ipairs(childArr) do
			UIBaseDef:setTransform(v,upCfg[i])
		end
	else
		self.spUp:visible(true)
		if not self.spDown then -- 没有spDown时，改变颜色
			--self.spUp:setOpacity(255) -- todo 暂时兼容S9Sprite没有setColor方法。此处用color会更好
			-- self._root:scaleByPoint(self.centerPos, self._scaleX, self._scaleY)
		else
			self.spDown:visible(false)
		end

	end

	
	if(self.spDisabled) then self.spDisabled:visible(false) end
	return self
end
-- 设置按钮为按下状态
function BtnExpand:setBtnDown()

	if self._isShareView then
		local downCfg = self.__downViewCfgs
		--遍历所有的upView子对象
		local childArr = self.spUp:getChildren()
		for i,v in ipairs(childArr) do
			UIBaseDef:setTransform(v,downCfg[i])
		end
	else
		if not self.spDown then -- 没有spDown时，改变spUp颜色
			self.spUp:visible(true) -- 有可能从disabled状态转过来
			--self.spUp:setOpacity(170) -- todo 暂时兼容S9Sprite没有setColor方法。此处用color会更好
			--self._scaleX,self._scaleY = self._root:getScaleX(),self._root:getScaleY()
			-- self._root:scaleByPoint(self.centerPos, self._scaleX*1.2, self._scaleY*1.2)
		else
			self.spDown:visible(true)
			self.spUp:visible(false)
		end
	end

	
	if(self.spDisabled) then self.spDisabled:visible(false) end
	return self
end
-- 设置按钮为无效状态
function BtnExpand:setBtnDisabled()
	if self.spDisabled then
		self.spDisabled:visible(true)
		self.spUp:visible(false)
		if(self.spDown) then self.spDown:visible(false) end
	end
	return self
end
-- 替换状态sp内容
function BtnExpand:setBtnUpSp(sp)
	if self.spUp then self.spUp:clear() end
	self.spUp = sp:addto(self._root,3,1)
	return self
end
function BtnExpand:setBtnDownSp(sp)
	if self.spDown then self.spDown:clear() end
	self.spDown = sp:addto(self._root,2,2):visible(false)
	return self
end
function BtnExpand:setBtnDisabledSp(sp)
	if self.spDisabled then self.spDisabled:clear() end
	self.spDisabled = sp:addto(self._root,1,3):visible(false)
	return self
end

--设置btnstr
function BtnExpand:setBtnStr( btnStr,txtName )
	txtName = txtName or "txt_1"
    if txtName then
    	if self.spUp and self.spUp[txtName] then
    		self.spUp[txtName]:setString(btnStr)
    	end

    	if self.spDown and self.spDown[txtName] then
    		self.spDown[txtName]:setString(btnStr)
    	end

    	if self.spDisabled and self.spDisabled[txtName] then
    		self.spDisabled[txtName]:setString(btnStr)
    	end

    end


end

function BtnExpand:setBtnChildVisible( childName,visible )
	if self.spUp and self.spUp[childName] then
		self.spUp[childName]:setVisible(visible)
	end

	if self.spDown and self.spDown[childName] then
		self.spDown[childName]:setVisible(visible)
	end

	if self.spDisabled and self.spDisabled[childName] then
		self.spDisabled[childName]:setVisible(visible)
	end
end

function BtnExpand:clearSp()
	if(self._sp) then
		self._sp:clear()
		self._sp = nil
	end
	return self
end
-- 设置图片偏移.(等同于BtnExpand:sp():pos(x,y))
function BtnExpand:offsetSp(x,y)
	if(self._sp) then self._sp:pos(x,y) end
	return self
end
-- 增加sp，不同于接口sp，spx不能取消，每次调用增加一个新节点
function BtnExpand:spx(_sp,_x,_y)
	assert(_sp,"@BtnExpand:spx(). param error.")
	if(type(_sp)=="string") then            -- sp(filename) --会自动生成sprite
		_sp = display.newSprite(_sp)
	end
	if _x and _y then _sp:pos(_x,_y) end
	_sp:addto(self._root,5)        -- sp(sprite). (其实这里(_sp)可以传入任何类型的node)
	return self
end


function BtnExpand:_onBegan()
	self:setBtnDown()
	self._isBtnBegin = true
	self._root:stopAllActions()
	if self._btnEffectType == self.BTN_EFFECT_ANIM_TYPES.CLICK1 then
		--缓动放大 然后颜色渐变
		self._root:runAction(act.bouncein( act.scaleto(btnEaseFrame/GAMEFRAMERATE ,1.07,1.07) ) )
		FilterTools.flash_easeBetween(self,btnEaseFrame,nil,"oldFt","btnlight")
	elseif self._btnEffectType == self.BTN_EFFECT_ANIM_TYPES.CLICK2 then
		self._root:runAction(act.bouncein( act.scaleto(btnEaseFrame/GAMEFRAMERATE ,0.9,0.9) ) )
		FilterTools.flash_easeBetween(self,btnEaseFrame,nil,"oldFt","btnlight")
	end
	-- if self._btnEffAni then
	-- 	self._btnEffAni:playWithIndex(0,0)
	-- end
end

function BtnExpand:_playSound()
	--禁止声效
	if not self._click_sound_enable then
		return
	end

	if self._btnEffectType == self.BTN_EFFECT_ANIM_TYPES.CLICK1 then
		AudioModel:playSound(MusicConfig.s_com_click1)
	else
		AudioModel:playSound(MusicConfig.s_com_click2)
	end
end
function BtnExpand:_onCancelled()
	
	--必须是从按下的情况下才能继续触发取消特效  因为一个点击过程会触发2次 cancle
	self:resumeBtnEff()
	self:setBtnUp()
end


function BtnExpand:resumeBtnEff(  )
	if self._isBtnBegin then
		self._root:stopAllActions()
		if self._btnEffectType == self.BTN_EFFECT_ANIM_TYPES.CLICK1 then
		--缓动放大 然后颜色渐变
			self._root:runAction(act.bouncein( act.scaleto(btnEaseFrame/GAMEFRAMERATE ,1,1) ) )
			FilterTools.flash_easeBetween(self,btnEaseFrame,nil,"btnlight","oldFt",true)
		elseif self._btnEffectType == self.BTN_EFFECT_ANIM_TYPES.CLICK2 then
			self._root:runAction(act.bouncein( act.scaleto(btnEaseFrame/GAMEFRAMERATE ,1,1) ) )
			FilterTools.flash_easeBetween(self,btnEaseFrame,nil,"btnlight","oldFt",true)
		end

		self._isBtnBegin =false
	end
end

function BtnExpand:_onEnded(x, y)
	BtnExpand.super._onEnded(self, x, y)
	self:resumeBtnEff()
	self:setBtnUp()
end

--获取正常状态的panel
function BtnExpand:getUpPanel()
	return self.spUp;
end

--获取按下的panel
function BtnExpand:getDownPanel()
	return self.spDown;
end

--获取 禁止状态的panel
function BtnExpand:getDisablePanel()
	return self.spDisabled;
end


--给按钮设置 点击点击效果1
function BtnExpand:setBtnClickEff(effectType  )
	self._btnEffectType = effectType or self.BTN_EFFECT_ANIM_TYPES.CLICK1
	

	-- if not self._btnEffAni then
	-- 	if self._btnEffectType == self.BTN_EFFECT_ANIM_TYPES.CLICK1 then
	-- 		FuncArmature.loadOneArmatureTexture("UI_common", nil, true)
	-- 		self._btnEffAni = FuncArmature.createArmature("UI_common_btnClick", self, true)
	--         local rect = self:_rect()
	--         local centerPosX = rect.x + rect.width/2
	--         local centerPosY = rect.y + rect.height/2
	--         self._btnEffAni:pos(centerPosX,centerPosY)
	--         FuncArmature.changeBoneDisplay(self._btnEffAni, "bone", self._root)
	--         self._root:pos(-centerPosX,-centerPosY)
	--         --让动画停住
	--         self._btnEffAni:pause()

	--     elseif self._btnEffectType == self.BTN_EFFECT_ANIM_TYPES.CLICK2 then
	--     	FuncArmature.loadOneArmatureTexture("UI_common", nil, true)
	-- 		self._btnEffAni = FuncArmature.createArmature("UI_common_btnClick2", self, true)
	--         local rect = self:_rect()
	--         local centerPosX = rect.x + rect.width/2
	--         local centerPosY = rect.y + rect.height/2
	--         self._btnEffAni:pos(centerPosX,centerPosY)
	--         FuncArmature.changeBoneDisplay(self._btnEffAni, "bone", self._root)
	--         self._root:pos(-centerPosX,-centerPosY)
	--         --让动画停住
	--         self._btnEffAni:pause()

	-- 	end

	-- end


end

--根据自身的大小重置矩形区域
function BtnExpand:resetRect(  )
	local rect = self.spUp:getContainerBox()
	local oldRect = self:_rect()
	--dump(rect,"_newRect")
	--dump(oldRect,"_OKDrecrt")
	self:setRect(rect)
end


return BtnExpand
