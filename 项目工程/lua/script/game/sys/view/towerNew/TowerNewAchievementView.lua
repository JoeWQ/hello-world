-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
  
local TowerNewAchievementView = class("TowerNewAchievementView", UIBase)

function TowerNewAchievementView:ctor(winName, _towerMainView)
    TowerNewAchievementView.super.ctor(self, winName)
end

function TowerNewAchievementView:loadUIComplete()
    self:initData()
    self:setViewCfg()
    self:registerEvent()
    self:updateUI()
end

-- 适配 
function TowerNewAchievementView:setViewCfg()
    FuncCommUI.setViewAlign(self.panel_1, UIAlignTypes.LeftTop)
--    FuncCommUI.setViewAlign(self.UI_keys, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)

    FuncCommUI.setScale9Align(self.scale9_1,UIAlignTypes.MiddleTop, 1, 0)
    
end 

function TowerNewAchievementView:initData()
    self.achievementData = TowerNewModel:getSortedAchievementConfig()
    dump(self.achievementData , "爬塔成就")
end 


function TowerNewAchievementView:updateUI()

    self.UI_4:setVisible(false)
	if next(self.achievementData) == nil then
		self.scroll_1:visible(false)
	else
		self:initAchievements()
	end
end 

function TowerNewAchievementView:initAchievements()
	local achievements = table.deepCopy(self.achievementData)
	local achievementsData = TowerNewModel:achievementReward()
	local targetIndex = nil
	for index, data in ipairs(achievements) do
		if targetIndex ==nil and achievementsData[data.id] ==nil then
			targetIndex = index
		end
	end
	local createFunc = function(data, index)
		local itemView = UIBaseDef:cloneOneView(self.UI_4)
		itemView:setItemData(data, self)
		itemView:updateUI()
		return itemView
	end

	local params = {
		{
			data = achievements,
			createFunc = createFunc,
			updateFunc = updateFunc,
			perNums = 1,
			offsetX = 26,
			offsetY = 10,
			widthGap = 15,
			heightGap = heightGap,
			itemRect = { x = 0, y = - 150, width = 255, height = 150 },
			perFrame = 1
		}
	}
	self.scroll_1:styleFill(params)
	self.scroll_1:easeMoveto(0, 0, 0)
	self:scrollToIndex(targetIndex)
end

function TowerNewAchievementView:scrollToIndex(index)
	if index ~= nil then
		self.scroll_1:gotoTargetPos(index, 1, 1, 0)
	end
end

function TowerNewAchievementView:registerEvent()
    self.btn_back:setTap(c_func(self.close, self))
end 

function TowerNewAchievementView:close()
	self:startHide()
end

return TowerNewAchievementView  
-- endregion
