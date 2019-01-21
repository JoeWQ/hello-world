--5个以下获得奖励弹窗
--guan
--2016.7.15

local RewardSmallBgView = class("RewardSmallBgView", UIBase);

function RewardSmallBgView:ctor(winName, itemArray, callBack)
    RewardSmallBgView.super.ctor(self, winName);
    -- dump(itemArray, "---itemArray---");
    self._itemArray = itemArray;
    self._callback = callBack or GameVars.emptyFunc;
end

function RewardSmallBgView:loadUIComplete()
	self:registerEvent();
	self:initUI();
    AudioModel:playSound(MusicConfig.s_com_reward);
end 

function RewardSmallBgView:registerEvent()
	RewardSmallBgView.super.registerEvent();
end

--初始化界面
function RewardSmallBgView:initUI()
    -- 奖品特效
    local anim = FuncCommUI.playSuccessArmature(self.UI_1, 
        FuncCommUI.SUCCESS_TYPE.GET, 2, true);

    -- FuncCommUI.addBlackBg(self._root);

    anim:registerFrameEventCallFunc(25, 1, function ( ... )
		self:registClickClose(nil, function ( ... )
			self:startHide();
			self._callback();
		end);
		-- self:registClickClose();
    end);

	local itemNum = table.length(self._itemArray);

	if itemNum > 5 then 
		echo("warning!!!  RewardSmallBgView:initUI() itemNum is more then 5!!!");
	end 

	self.mc_1:showFrame(itemNum);
	for i = 1, itemNum do
        local _reward = self._itemArray[i]
        local _data = string.split(_reward,",")
        local rewardType = _data[1]
        -- 添加法宝的显示效果
        if rewardType == FuncDataResource.RES_TYPE.TREASURE then -- fabao
            self.mc_1:getCurFrameView()["mc_" .. tostring(i)]:showFrame(2)
            local uiInfo = self.mc_1:getCurFrameView()["mc_" .. tostring(i)]:getCurFrameView()["UI_2"]
            local itemCommonUI = self.mc_1:getCurFrameView()["mc_" .. tostring(i)]:getCurFrameView()["UI_2"]
            itemCommonUI:updateUI(_data[2])
            uiInfo:setScale(0.8)
            local xingji = FuncTreasure.getValueByKeyTD(_data[2],"initStar")
--            uiInfo.mc_xing:showFrame(xingji)
        else
            self.mc_1:getCurFrameView()["mc_" .. tostring(i)]:showFrame(1)
            local itemCommonUI = self.mc_1:getCurFrameView()["mc_" .. tostring(i)]:getCurFrameView()["UI_1"]
		    itemCommonUI:setResItemData(
			    {reward = self._itemArray[i]});
		    itemCommonUI:showResItemName(true, true, 1);
        end
	end
end

return RewardSmallBgView;











