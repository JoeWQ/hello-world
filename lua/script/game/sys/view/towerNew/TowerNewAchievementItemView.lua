-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
  
local TowerNewAchievementItemView = class("TowerNewAchievementItemView", UIBase)

function TowerNewAchievementItemView:ctor(winName)
    TowerNewAchievementItemView.super.ctor(self, winName)
    self.data = nil
end 

function TowerNewAchievementItemView:setItemData(data, achieveMainView)
	self.data = data
    self.achieveMainView = achieveMainView
end 

function TowerNewAchievementItemView:updateUI()
	local data = self.data
    self.txt_1:setString(data.floor .. "层")
    -- Temp
    self.mc_1:showFrame(1)
	self.mc_1.currentView.btn_queding:getUpPanel().txt_1:setString("领取")
    local achievementReward = TowerNewModel:achievementReward()

    if achievementReward[data.id] ~= nil then
        self.mc_1:showFrame(2)
    else
        if tonumber(TowerNewModel:maxFloor()) < tonumber(data.floor) then
            FilterTools.setGrayFilter(self.mc_1.currentView.btn_queding)
            self.mc_1.currentView.panel_hongdian:setVisible(false)
        end
        self.mc_1.currentView.btn_queding:setTap(c_func(self.onConfirmTap, self))
    end
    for i=1,4 do
    	local v = data.reward[i]
		local ui_item = self["UI_"..tostring(i)]
    	if v then
			local num,hasNum,isEnough,resType,itemId = UserModel:getResInfo(v)
			ui_item:visible(true)
			ui_item:setResItemData( {reward = v})
			ui_item:setResItemClickEnable(true)
			ui_item:setClickBtnCallback(c_func(self.onRewardTap, self, resType, itemId, num))
		else
			ui_item:visible(false)
		end
	end
end

function TowerNewAchievementItemView:onRewardTap(resType, itemId, num)
	if self.achieveMainView.scroll_1:isMoving() then
		return
	end
	TowerNewModel:showDetail(resType, itemId, num)
end

function TowerNewAchievementItemView:onConfirmTap()
	-- 当前最大爬行层数大于 目前层数
	if tonumber(TowerNewModel:maxFloor()) < tonumber(self.data.floor) then
		WindowControler:showTips(GameConfig.getLanguage("tid_tower_1005"))
	else
		self:requestAchievementReward()
	end
end

-- 领取成就奖励
function TowerNewAchievementItemView:requestAchievementReward()
    function _callback(_p)
        FuncCommUI.startRewardView(_p.result.data.reward)
        self.mc_1:showFrame(2)
        self:playEff()
    end
    TowerServer:requestAchievementReward( { achievementId = self.data.id }, _callback)
end 

-- 领取成就奖励
function TowerNewAchievementItemView:playEff()
-- 新flash 没有
--    for i, v in pairs(self.data.reward) do
--        self:createUIArmature(nil,"UI_tower_baozha", nil, false, GameVars.emptyFunc):addto(self["ctn_daojukuang" .. i])
--    end
end

function TowerNewAchievementItemView:loadUIComplete()
    self:registerEvent()
end

function TowerNewAchievementItemView:registerEvent()
    
end  

function TowerNewAchievementItemView:updateCombineState()
    -- 更新数据
    self:updateUI()
end 

function TowerNewAchievementItemView:deleteMe()
    TowerNewAchievementItemView.super.deleteMe(self)
end

return TowerNewAchievementItemView  
-- endregion 
