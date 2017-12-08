-- NewLotteryRewardShowUI
--三皇抽奖系统
--2016-1-18 16:23:40
--@Author:wukai

local NewLotteryRewardShowUI = class("NewLotteryRewardShowUI", UIBase);

function NewLotteryRewardShowUI:ctor(winName,Data)    
    NewLotteryRewardShowUI.super.ctor(self, winName)
    self.Data = Data
    dump(Data,"界面显示")
end

function NewLotteryRewardShowUI:loadUIComplete()

	self.btn_close:setTap(c_func(self.press_btn_close,self))
	self:initData()
	self:registClickClose(nil, function ()
        self:press_btn_close()
    end);
end
local lotterytypename = {
	[1]  = "材料",
	[2]  = "伙伴",
	[3]  = "法宝",
	[4]  = "通用",
}
local lotteryqulityname = {
	[1]  = "白品质",
	[2]  = "绿品质",
	[3]  = "蓝品质",
	[4]  = "紫品质",
	[5]  = "金品质",
}
function NewLotteryRewardShowUI:superqulity(view,qualitys,typeID)
	local lockAni = nil
	if tonumber(qualitys) == 5 then
		local ctn = view:getViewByFrame(tonumber(qualitys)).ctn_1
	    if typeID == 1 then --
	        lockAni = self:createUIArmature("UI_chouka_a","UI_chouka_a_wenhao", nil, true, GameVars.emptyFunc)
	        lockAni:setScale(0.9)
	    elseif typeID == 2 then
	        lockAni = self:createUIArmature("UI_chouka_a","UI_chouka_a_huoban", nil, true, GameVars.emptyFunc)
	        lockAni:setScale(0.9)
	    elseif typeID == 3 then
	        lockAni = self:createUIArmature("UI_chouka_a","UI_chouka_a_fabao", nil, true, GameVars.emptyFunc)
	        lockAni:setScale(0.9)
	    elseif typeID == 4 then
	        lockAni = self:createUIArmature("UI_chouka_a","UI_chouka_a_cailiao", nil, true, GameVars.emptyFunc)
	        lockAni:setScale(0.9)
	    end
	    ctn:removeAllChildren()
		ctn:addChild(lockAni,3)
	end
end

function NewLotteryRewardShowUI:initData()
	local typename = nil
	local types = nil
	local qulity = nil
	if type(self.Data) == "table" then
		local LotteryData = FuncNewLottery.getIDLotteryData(self.Data.lotteryId)
		types = tonumber(LotteryData.type)
		typename = lotterytypename[types]
		qulity = tonumber(LotteryData.quality)
		self.mc_1:showFrame(types)
		if qulity == 5 or qulity == 6 then
			
			local view = self.mc_1:getViewByFrame(types).mc_1
			self:superqulity(view,qulity,types)


		end
		self.mc_1:getViewByFrame(types).mc_1:showFrame(qulity)
		self.txt_1:setString(lotteryqulityname[qulity]..typename)
	elseif type(self.Data) == "string" then
		local reward = string.split(self.Data, ",")
		local rewardtype = tonumber(reward[1])
		local rewardId = tonumber(reward[2])
		if rewardtype == 1 then

		elseif  rewardtype == 10 then

		elseif  rewardtype == 18 then

		end
		types = 5
		self.mc_1:showFrame(types)

		self.mc_1:getViewByFrame(types).UI_1:setResItemData({reward = self.Data})
		self.mc_1:getViewByFrame(types).UI_1:showResItemName(false)
		self.txt_1:setString("金品质道具")--lotteryqulityname[qulity]..typename)
	end

	self.UI_1:visible(false)
	local createFunc = function (itemdata)
		local itemView = UIBaseDef:cloneOneView(self.UI_1)
		self:updateItem(itemView, itemdata)
		return itemView
	end
	local data =self:rewarddata()
	local newparams = {
			{
				data = data,
				createFunc = createFunc,
				-- updateCellFunc = updateFunc_shop,
				perNums=4,
				offsetX = 15,
				offsetY = 10,
				itemRect = {x=0,y=-105,width=100,height = 105},
				perFrame =0,
				heightGap = 0
			}
		}
	self.scroll_list:styleFill(newparams)
	-- self.scroll_list:setCanScroll(false)
end
function NewLotteryRewardShowUI:updateItem(view,data)
	-- dump(data,"=========")
	view:setResItemData({reward = data[1]})
	view:showResItemName(false)

	local beginFunc  = function ()
		WindowControler:showTips("数据详情未开发")
	end
	view:setTouchedFunc(beginFunc,nil,false,nil,nil)





end
function NewLotteryRewardShowUI:rewarddata()
	local data = {}
	for i=1,11 do
		data[i] = {"18,5001,1"}
	end
	return data
end


function NewLotteryRewardShowUI:press_btn_close()
	
	self:startHide()
	
end

return NewLotteryRewardShowUI
