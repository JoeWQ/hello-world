-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
  
local TowerNewBoxRewardView = class("TowerNewBoxRewardView", UIBase)
local KEYTYPES = {
	FuncTower.KEYS.COPPER,
	FuncTower.KEYS.SILVER,
	FuncTower.KEYS.GOLD,
}

function TowerNewBoxRewardView:ctor(winName, _boxTreasureMainView)
    TowerNewBoxRewardView.super.ctor(self, winName)
    self.boxTreasureMainView = _boxTreasureMainView
end

function TowerNewBoxRewardView:initData(data)
    self.rewardData = data
    self.data = data.data
    self.key = KEYTYPES[self.boxTreasureMainView.clickType]
    self:updateUI()
end 
  
function TowerNewBoxRewardView:loadUIComplete()
	self.btnConfirm = self.mc_btns:getViewByFrame(1).btn_2
	self.btnOpenMore = self.mc_btns:getViewByFrame(1).btn_1
	self.btnClose = self.mc_btns:getViewByFrame(2).btn_2

    FuncCommUI.addBlackBg(self._root)
    self:registerEvent()
end

function TowerNewBoxRewardView:registerEvent()
	self.btnConfirm:setTap(c_func(self.close, self))
	self.btnOpenMore:setTap(c_func(self.onOpenMoreTap, self))
	self.btnClose:setTap(c_func(self.close, self))
end 

function TowerNewBoxRewardView:onOpenMoreTap()
	local leftKeyNum = ItemsModel:getItemNumById(self.key)
	if leftKeyNum <= 0 then
		WindowControler:showTips(GameConfig.getLanguage("tid_tower_1001"))
	else
		self.boxTreasureMainView:openTreasureBox(self.boxTreasureMainView.clickType)
		self:startHide()
	end
end
 
function TowerNewBoxRewardView:updateCombineState()
    self.ownedTreasureDebris = self.boxTreasureMainView:sortTeasureItemData() or { }
    self:updateUI()
    -- 更新数据
end 

function TowerNewBoxRewardView:updateUI()
    --[[
    -- 道具数据格式
    data数据格式：{
        itemId="",          --道具ID
        itemNum="",         --道具数量
    }

    -- 奖品数据格式
    data数据格式：{
        reward="3,10",      --奖品字符串
    }
--]]
	self:playTitleAnim()

	local nextCanOpenNum = self:getNextOpenNum()
	if nextCanOpenNum <=0 then
		self.mc_btns:showFrame(2)
	else
		self.mc_btns:showFrame(1)
		self.btnOpenMore:setScale(0)
		self.btnOpenMore:runAction(act.scaleto(0.3, 1))
		self.btnOpenMore:setBtnStr(GameConfig.getLanguageWithSwap('tid_tower_1002', nextCanOpenNum))
	end
	local btnConfirm = self.mc_btns.currentView.btn_2
    btnConfirm:setScale(0)
	btnConfirm:runAction(act.scaleto(0.3, 1))

    local _len = #self.data.reward
    self.mc_1:showFrame(_len)

    -- dump(self.data.reward,"_self.data.reward")

    for i, v in pairs(self.data.reward) do
        -- 需要量, 拥有量,是否满足,资源类型,resId(如果是道具)

        local panel = self.mc_1.currentView["panel_" .. i]
        local ui_item = panel.UI_daoju
        ui_item:setResItemData( { reward = v[1] })

        --ui_item scale anim
		local itemCtn = ui_item.mc_1.currentView.btn_1:getUpPanel().panel_1.ctn_1
		itemCtn:setScale(2)
        local scaleto = cc.ScaleTo:create(0.3, 1);
		itemCtn:runAction(scaleto)
    end
end

function TowerNewBoxRewardView:getNextOpenNum()
	return TowerNewModel:getCanOpenBoxNumOnce(self.key)
end

function TowerNewBoxRewardView:playTitleAnim()  
    -- 奖品特效
    FuncCommUI.playSuccessArmature(self.UI_1,FuncCommUI.SUCCESS_TYPE.GET,1)
end


function TowerNewBoxRewardView:close()
	self:startHide()
end

function TowerNewBoxRewardView:deleteMe()
    TowerNewBoxRewardView.super.deleteMe(self)
end

return TowerNewBoxRewardView  
-- endregion 
