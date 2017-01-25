-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
  
local TowerNewTreasureShowAward = class("TowerNewTreasureShowAward", UIBase)


function TowerNewTreasureShowAward:ctor(winName, id)
    TowerNewTreasureShowAward.super.ctor(self, winName)
    
    self.towerTreasureBoxData = {}
	self:initData(id)
end

function TowerNewTreasureShowAward:initData(id)
    for i = 1,3 do
        table.insert(self.towerTreasureBoxData, FuncTower.getTowerTreasureBoxRewardByKey(id, "reward" .. i))
    end
    dump(self.towerTreasureBoxData,'==dmx==towerTreasureBoxData==dmx==')
end 

function TowerNewTreasureShowAward:updateItem(view, _itemData, is)

end 
  
function TowerNewTreasureShowAward:loadUIComplete()
    self.UI_1.mc_1:setVisible(false)
    self:registerEvent()
    self.UI_jiangliyulankuang:setVisible(false)
    self:updateUI()
end

function TowerNewTreasureShowAward:registerEvent()
    self:registClickClose("out")
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.close, self))
    self.UI_1.btn_close:setTap(c_func(self.close, self))
end 

function TowerNewTreasureShowAward:close()
	self:startHide()
end

function TowerNewTreasureShowAward:updateUI()
    self.UI_1.txt_1:setString("可获得奖励")
	if next(self.towerTreasureBoxData) ~= nil then
		self:initRewards()
    end
end

function TowerNewTreasureShowAward:initRewards()
	local boxRewardsData = table.deepCopy(self.towerTreasureBoxData)
	local boxRewardTypeTidPrefix = "tid_tower_box_reward_type_" 

	local createFunc = function(itemData, index)
		local itemView = UIBaseDef:cloneOneView(self.UI_jiangliyulankuang)
		itemView.panel_1.txt_2:setVisible(true)
		itemView.panel_1.txt_2:setString(GameConfig.getLanguage(boxRewardTypeTidPrefix..index))

		for i = 1,4 do
			local ui_item = itemView.panel_1["UI_"..i]
			if i > #itemData then
				ui_item:setVisible(false)
			else  
				local needNum, hasNum, isEnough, resType, itemId = UserModel:getResInfo(itemData[i])
                --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   
                -- 添加默认参数 保证不崩溃 后面还需要改  策划还不确定
                --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                if not itemId then
                    itemId = "4001"
                end
				ui_item:setResItemData( { itemId = itemId, itemNum = needNum })
				function _callback()
					if self.scroll_1:isMoving() then return end 
					TowerNewModel:showDetail(resType, itemId, needNum)
				end
				ui_item.mc_1.currentView.btn_1:setTouchedFunc(_callback, nil, false)
			end
		end

		itemView:setItemData(itemData)
		return itemView
	end

	local params = {
		{
			data = boxRewardsData,
			createFunc = createFunc,
			perNums = 1,
			offsetX = 20,
			offsetY = 0,
			widthGap = 15,
			heightGap = heightGap,
			itemRect = { x = 0, y = -165, width = 255, height = 165 },
			perFrame = 1
		}
	}
	self.scroll_1:styleFill(params)
	self.scroll_1:easeMoveto(0, 0, 0)
    self.scroll_1:hideDragBar()
end

function TowerNewTreasureShowAward:deleteMe()
    TowerNewTreasureShowAward.super.deleteMe(self)
    self.controler = nil
end

return TowerNewTreasureShowAward  
-- endregion 
