-- Author: ZhangYanguang
-- Date: 2017-01-10
-- 主角系统主界面

local CharMainView = class("CharMainView", UIBase);

function CharMainView:ctor(winName)
    CharMainView.super.ctor(self, winName);
end

function CharMainView:loadUIComplete()
	self:initData()
	self:initView()
	self:registerEvent()
end 

function CharMainView:registerEvent()
	self.btn_back:setTap(c_func(self.onClose,self))
	for i=1,self.tagNum do
		self.panel_bgyeqian["mc_yeqian" .. i]:setTouchedFunc(c_func(self.selectTagView, self,i));
	end
end

function CharMainView:initData()
	-- 页签数量
	self.tagNum = 4
end

function CharMainView:initView()
	-- UI适配
    FuncCommUI.setViewAlign(self.panel_bgyeqian,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.btn_back,UIAlignTypes.RightTop)

    self.mcView = self.mc_1

    -- 默认选中属性页
    -- self.panel_bgyeqian.mc_yeqian1:showFrame(2)
    
    self:selectTagView(1)
    -- self:hideTagView(4)
end

-- 选中页签
function CharMainView:selectTagView(tagIndex)
	if not tagIndex or tagIndex > self.tagNum then
		return
	end

	-- todo
	if tagIndex > 1 then
		WindowControler:showTips("玩命开发中...")
		return
	end

	for i=1,self.tagNum do
		local panelRedPoint = self.panel_bgyeqian["panel_yeqianred" .. i]
		if panelRedPoint then
			panelRedPoint:setVisible(false)
		end

		if i == tagIndex then
			self.panel_bgyeqian["mc_yeqian" .. i]:showFrame(2)
			self.mcView:showFrame(tagIndex)
		else
			self.panel_bgyeqian["mc_yeqian" .. i]:showFrame(1)
		end
	end
end

function CharMainView:hideTagView(tagIndex)
	local panelTagView = self.panel_bgyeqian["mc_yeqian" .. tagIndex]
	local panelRedPoint = self.panel_bgyeqian["panel_yeqianred" .. tagIndex]
	if panelTagView then
		panelTagView:setVisible(false)
	end

	if panelRedPoint then
		panelRedPoint:setVisible(false)
	end
end


function CharMainView:onClose()
	self:startHide()
end

return CharMainView;
