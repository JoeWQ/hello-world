-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
  
local TowerNewSaoDangHeJLYLView = class("TowerNewSaoDangHeJLYLView", UIBase)

function TowerNewSaoDangHeJLYLView:ctor(winName,_typeView,data,initFloor)
    TowerNewSaoDangHeJLYLView.super.ctor(self, winName)
    self.typeView = _typeView
    self.rewardDatas = data
    self.closeAutoMove = true
    self.lastCurrentFloor = initFloor 
end
function TowerNewSaoDangHeJLYLView:loadUIComplete()
    self:registerEvent()
    self:initData()
    self:updateUI()
end


-- 适配 
function TowerNewSaoDangHeJLYLView:setViewCfg()
    FuncCommUI.setViewAlign(self.panel_1, UIAlignTypes.LeftTop)
--    FuncCommUI.setViewAlign(self.UI_keys, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)

    FuncCommUI.setScale9Align(self.scale9_1,UIAlignTypes.MiddleTop, 1, 0)
    
end 

function TowerNewSaoDangHeJLYLView:initData()
    if self.typeView == 0 then -- 扫荡
        self.rewardSDDatas = {}
        for i,v in pairs(self.rewardDatas) do
            local d = {}
            d.id = i + tonumber(self.lastCurrentFloor) - 1
            d.reward = v
            table.insert(self.rewardSDDatas,d)
        end

    elseif self.typeView == 1 then -- 奖励预览
        self.rewardDatas = FuncTower.getTowerAllFloorData()
    end
    
end 


function TowerNewSaoDangHeJLYLView:updateUI()

    self.panel_1:setVisible(false)
    if self.typeView == 1 then
        self.mc_1:showFrame(2)
        self:initRewardsYL()
    elseif self.typeView == 0 then 
        self.mc_1:showFrame(1)
        self:initRewardsSD()
    end
	
end 
-- 扫荡
function TowerNewSaoDangHeJLYLView:initRewardsSD()

	local createFunc = function(data)
		local itemView = UIBaseDef:cloneOneView(self.panel_1)
		self:updateRewardItem(itemView,data)
		return itemView
	end
    local reuseUpdateCellFunc = function(data, itemView)
        self:updateRewardItem(itemView,data)
        return itemView
    end

	local params = {
		{
			data = self.rewardSDDatas,
			createFunc = createFunc,
			updateCellFunc = reuseUpdateCellFunc,
			perNums = 1,
			offsetX = 0,
			offsetY = 0,
			widthGap = 0,
			heightGap = 0,
			itemRect = { x = 0, y = - 140, width = 440, height = 140 },
			perFrame = 1
		}
	}
	self.scroll_1:styleFill(params)
    self.scroll_1:setCanScroll(false);
    self.btn_close:setVisible(false);
    self.sdFinish = false
end
-- 预览
function TowerNewSaoDangHeJLYLView:initRewardsYL()
--    self.scroll_1:removeAllChildren()
    local itemDatas = { }
    for k, v in pairs(self.rewardDatas) do
        table.insert(itemDatas, v)
    end
    
    function sortFunc(a, b)
		return tonumber(a.id) < tonumber(b.id);
	end
	table.sort(itemDatas, sortFunc);
	local createFunc = function(data)
		local itemView = UIBaseDef:cloneOneView(self.panel_1)
		self:updateRewardItem(itemView,data)
		return itemView
	end
    local reuseUpdateCellFunc = function(data, itemView)
        self:updateRewardItem(itemView,data)
        return itemView
    end

	local params = {
		{
			data = itemDatas,
			createFunc = createFunc,
			updateCellFunc = reuseUpdateCellFunc,
			perNums = 1,
			offsetX = 0,
			offsetY = 0,
			widthGap = 0,
			heightGap = 0,
			itemRect = { x = 0, y = - 140, width = 440, height = 140 },
			perFrame = 1
		}
	}
	self.scroll_1:styleFill(params)

end
function TowerNewSaoDangHeJLYLView:updateRewardItem(itemView,data)
    local oneFloorTime = 0.3
    local floorMoveTime = 0.2
    local finishTime = 0.5
    if TowerNewModel:maxFloor() > 50 then
        oneFloorTime = 0.01
        floorMoveTime = 0.01
    elseif TowerNewModel:maxFloor() > 20 then
        oneFloorTime = 0.15
        floorMoveTime = 0.15
    end
    if self.typeView == 0 then -- 扫荡
        if self.closeAutoMove == true then
            itemView:setVisible(false)
            self:delayCall(function ()
                --itemView:setVisible(true)
                if TowerNewModel:maxFloor() <= 4 then
                    if data.id == TowerNewModel:maxFloor() then
                        self:delayCall(function ()
                             self.closeAutoMove = false
                             self.scroll_1:setCanScroll(true);
                             self.btn_close:setVisible(true);
                             self:registClickClose("out");
                             self.sdFinish = true
                        end,finishTime)
                    end 
                end
                if data.id > 4 then
                    self.scroll_1:gotoTargetPos(data.id,1,2,floorMoveTime)
                    if data.id == TowerNewModel:maxFloor() then
                        self:delayCall(function ()
                             self.closeAutoMove = false
                             self.scroll_1:setCanScroll(true);
                             self.btn_close:setVisible(true);
                             self.sdFinish = true
                             self:registClickClose("out");
                        end,finishTime)
                      
                    end
                
                end
                EventControler:dispatchEvent(TowerEvent.TOWERR_FLOOR_UPDATE,{floor = data.id})
            end, oneFloorTime)
        end
        
    end
    
    itemView.txt_2:setString("第"..data.id.."层")
    for i=1,4 do
    	local v = data.reward[i] 
        if i == 1 and data.reward[i] == nil then
            v = data.reward
        end
		local ui_item = itemView["UI_"..tostring(i)]
    	if v then
			local num,hasNum,isEnough,resType,itemId = UserModel:getResInfo(v)
			ui_item:visible(true)
			ui_item:setResItemData( {reward = v})
			ui_item:setResItemClickEnable(true)

            --注册点击事件 弹框
            local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(v)
            FuncCommUI.regesitShowResView(ui_item, resType, needNum, resId,v,true,true)
		else
			ui_item:visible(false)
		end
	end
    itemView:setVisible(false)
end



function TowerNewSaoDangHeJLYLView:registerEvent()
    self.btn_close:setTap(c_func(self.close, self))
    if self.typeView == 1 then -- 奖励预览
        self:registClickClose("out");
    end
end 

function TowerNewSaoDangHeJLYLView:close()
    if self.typeView == 0 then
        if self.sdFinish == false then
           return
        end
        EventControler:dispatchEvent(TowerEvent.TOWERR_FLOOR_UPDATE,{floor = tonumber(TowerNewModel:currentFloor())})
        EventControler:dispatchEvent(TowerEvent.TOWERR_RED_POINT_UPDATA);
    end
    
	self:startHide()
end


return TowerNewSaoDangHeJLYLView  
-- endregion
