local CompShopItemView = class("CompShopItemView", UIBase)
local COST_TO_MC_INDEX = {
	[FuncDataResource.RES_TYPE.COIN] = 1,
	[FuncDataResource.RES_TYPE.DIAMOND] = 2,
	[FuncDataResource.RES_TYPE.ARENACOIN] = 3,
	[FuncDataResource.RES_TYPE.SOUL] = 4,
	[FuncDataResource.RES_TYPE.CHIVALROUS] = 5,
}
function CompShopItemView:ctor(winName, dataForDisplay, index,globalIndex,aniId)
	CompShopItemView.super.ctor(self, winName)
	--itemData:
	--:itemId
	--:num
	--:costInfo
	--:soldOut
	--:itemIndex
	self.itemData = dataForDisplay
	self.index = index
    self.globalIndex=globalIndex;--//mc的帧�?
    self.aniId=aniId;--//动画显示
end

function CompShopItemView:loadUIComplete()
	self:registerEvent()
	local mc_cost = self.btn_1:getUpPanel().panel_1.mc_1
    self.mc_quality=self.btn_1:getUpPanel().panel_1.mc_di;
    self.mc_quality:showFrame(self.globalIndex<=4 and self.globalIndex or 4);
    self.panel_quality=self.mc_quality.currentView;
	self:showSoldOutMark()
	self:updateUI()
end

function CompShopItemView:registerEvent()
	EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.onUserModelUpdate, self)
--//购买道具完成事件监听
    EventControler:addEventListener(ShopEvent.SHOPEVENT_BUY_ITEM_END,self.onUserModelUpdate,self);
end

function CompShopItemView:onUserModelUpdate(_params)
--    self.itemData.soldOut=ShopModel:isSomeItemSoldOut(self.itemData.shopId,tostring(self.itemData.shopGoodsId));
    if(_params.params~=nil)then
           self.itemData.soldOut=_params.params.soldOut;
    end
	self:setCostInfo()	
end

function CompShopItemView:updateUI()
	if not self.itemData then return end
	self:setItemView()
	self:setCostInfo()
	self:setItemNameAndNum()
	self:showSoldOutMark()
	self:setLeftCorerMark()
--//加入flash对话
   local   flagString=self.itemData.specials;
   local   genAni=false;
   if(flagString)then
        for _index=1,#flagString do
             if(tonumber(flagString[_index])==self.aniId)then
                     genAni=true;
             end
        end
   end
   local    panel=self.btn_1:getUpPanel().panel_1;
   panel.ctn_s:removeAllChildren();
   if(genAni)then
        local  ani=self:createUIArmature("UI_shop","UI_shop_yuan",panel.ctn_s,true,GameVars.emptyFunc);
   end
end

function CompShopItemView:setLeftCorerMark()
	local contentPanel = self.btn_1:getUpPanel().panel_1
	local label = self.itemData.label
	if not label then
		contentPanel.mc_tuijian:visible(false)
	else
		contentPanel.mc_tuijian:visible(true)
		contentPanel.mc_tuijian:showFrame(tonumber(label))
	end
end

function CompShopItemView:setItemNameAndNum()
    local itemName =FuncItem.getItemName(tostring(self.itemData.itemId) )
    local num = self.itemData.num
	local itemStr = string.format("%s", itemName, num)
	local contentPanel = self.btn_1:getUpPanel().panel_1
--	contentPanel.txt_1:setString(itemStr)
    local  itemData=FuncItem.getItemData(self.itemData.itemId);
    if(itemData.type==2)then
          contentPanel.mc_coin:showFrame(6);
          contentPanel.mc_coin.currentView.txt_1:setString(itemStr);
    else
         contentPanel.mc_coin:showFrame(itemData.quality);
         contentPanel.mc_coin.currentView.txt_1:setString(itemStr);
    end
end

function CompShopItemView:setCostInfo()
	local contentPanel = self.btn_1:getUpPanel().panel_1
	mc_cost = contentPanel.mc_1
	local costInfo = self.itemData.costInfo

    local needNums,hasNums,isEnough,resType = UserModel:getResInfo(costInfo)

    local index = COST_TO_MC_INDEX[resType..'']
	mc_cost:showFrame(index)
	local num_txt = mc_cost.currentView.txt_1
	num_txt:setString(needNums)
	if not isEnough then
--		num_txt:setColor(FuncCommUI.COLORS.TEXT_RED)
		num_txt:disableOutLine()
        if(not self.itemData.soldOut)then--//如果是没有售完的
             num_txt:setColor(FuncCommUI.COLORS.TEXT_RED);
        end
	else
		num_txt:setColor(FuncCommUI.COLORS.TEXT_WHITE)
	end
end

function CompShopItemView:setItemView()
	local ui_item = self.btn_1:getUpPanel().panel_1.UI_1
	if ui_item then
        local data = {
            itemId = self.itemData.itemId,
            itemNum = self.itemData.num,
        }
        ui_item:setItemData(data)
	end
end

function CompShopItemView:setItemData(data)
	self.itemData = data
end

function CompShopItemView:getItemIndex()
	return self.itemData.itemIndex or 1
end

function CompShopItemView:showSoldOutMark()
	local show = self.itemData.soldOut or false
	local contentPanel = self.btn_1:getUpPanel().panel_1
	contentPanel.scale9_3:visible(show)
	contentPanel.panel_2:visible(show)
end

function CompShopItemView:playSoldOutAnim()
	self:zorder(self:getLocalZOrder()+100-self.index)
	local contentPanel = self.btn_1:getUpPanel().panel_1
	local ctn = contentPanel.ctn_2
	local soldOutPanel = contentPanel.panel_2
	local grayScale9 = contentPanel.scale9_3
	grayScale9:visible(true)
	local anim = self:createUIArmature("UI_common", "UI_common_shouqing", ctn, false, GameVars.emptyFunc)
	FuncArmature.changeBoneDisplay(anim, "layer1", soldOutPanel)
	soldOutPanel:pos(0,0)
end

function CompShopItemView:close()
	self:startHide()
end

return CompShopItemView
