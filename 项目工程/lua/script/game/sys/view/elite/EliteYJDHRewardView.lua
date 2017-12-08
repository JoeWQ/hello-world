local EliteYJDHRewardView = class("EliteYJDHRewardView", UIBase)

function EliteYJDHRewardView:ctor(winName,data)
	EliteYJDHRewardView.super.ctor(self, winName)
    self.reward = data
end

function EliteYJDHRewardView:loadUIComplete()

	--隐藏要复制的对象
    self.panel_1:setVisible(false)
	self:setAlignment()
	self:registerEvent()
    self:setRewardList()
end


function EliteYJDHRewardView:setAlignment()
	--设置对齐方式

end

function EliteYJDHRewardView:setRewardList()
	
	local createFunc = function(record)
		local view = UIBaseDef:cloneOneView(self.panel_1)
        self:updateItemUI(view,record)
        view:setVisible(false)

		return view
	end
        
    


    local  rewardArr = {};
    for i,v in pairs(self.reward) do
        v.index = i
        table.insert(rewardArr,v)   
    end
    self.maxNum = #rewardArr

    local scroll_param = {}
	scroll_param = {
            data = rewardArr,
			perNums = 1,
			offsetX = 0,
			offsetY = 0,
			widthGap = 0,
			heightGap = 0 ,
			itemRect = {x=0,y= 0,width = 430,height = 167},
			perFrame=1,
            createFunc = createFunc,
	}


	local params = {scroll_param}
--    self.scroll_1:setItemAppearType(1,true)
	self.scroll_1:styleFill(params)
    self.scroll_1:setCanScroll(false)
    self.touchEnable = false

end
function EliteYJDHRewardView:updateItemUI(view,itemData)
    self:delayCall(function()
       view:setVisible(true)
       if tonumber(itemData.index) > 2 then
           echo("jiangliindex ========"..itemData.index)
           self.scroll_1:gotoTargetPos(tonumber(itemData.index),1,2,0.3)
       end
       if itemData.index == self.maxNum then
           self.scroll_1:setCanScroll(true)
           self.touchEnable = true
           self:registClickClose("out");
       end
    end,0.5 * tonumber(itemData.index - 1))
    view.txt_1:setString(string.format(GameConfig.getLanguage("elite_exchange_reward_num"),itemData.index))
    for i = 1,3 do
        if itemData[i] then
            view["UI_"..i]:setResItemData({reward = itemData[i]})
	        view["UI_"..i]:showResItemName(false)
            view["UI_"..i]:showResItemName(false)
            view["UI_"..i]:showResItemNum(false)
        else
            view["UI_"..i]:setVisible(false)
        end
    end
end




function EliteYJDHRewardView:registerEvent()
	EliteYJDHRewardView.super.registerEvent()
--    
    self.UI_1.btn_close:setTap(c_func(self.onBtnBackTap, self));
    self.UI_1.mc_1:showFrame(1);

    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.onBtnBackTap, self));
	
end

--返回 
function EliteYJDHRewardView:onBtnBackTap()
    if self.touchEnable == true then
        self:startHide()
    end
	
end

return EliteYJDHRewardView
