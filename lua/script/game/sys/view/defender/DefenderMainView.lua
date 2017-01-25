local DefenderMainView = class("DefenderMainView",UIBase);
--[[
	self.panel_title
	self.btn_close
	self.panel_res
	self.scale9_updi
]]


function DefenderMainView:ctor(winName)
	DefenderMainView.super.ctor(self, winName);   ---把自身当参数传入
end

function DefenderMainView:loadUIComplete()      -----加载UIflash文件
	FuncCommUI.setViewAlign(self.btn_back,UIAlignTypes.RightTop)
	-- FuncCommUI.setViewAlign(self.panel_title,UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.panel_xianyu,UIAlignTypes.RightTop)
	FuncCommUI.setScale9Align(self.scale9_black,UIAlignTypes.MiddleTop,1,0)

	-- self.mc_mailzong1:getViewByFrame(1).panel_1:visible(false)

	self.buttonnumber  = 1   --测试


	local panel_X = self.panel_4:getPositionX()
	self.panel_4:setPositionX(panel_X+80)
	self.btn_back:setTap(c_func(self.press_btn_close,self));
	self.btn_help:setTap(c_func(self.guardboardHelp,self));
	-- self.mc_1.currentView.btn_1:setTap(c_func(self.setbtn,self));
	self.mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.setbtn,self));
	self.mc_1:getViewByFrame(2).btn_1:setTap(c_func(self.setbtn,self));
	self.mc_1:getViewByFrame(3).btn_1:setTap(c_func(self.setbtn,self));
	for i=1,5 do
		local commonUI = self.panel_3["UI_" .. tostring(i)];
		commonUI:visible(false)
	end
	--初始化更新ui
	self:updateUI()
	self:addEffect()
	self:setscroll_listData()
end
--刷新数据
function DefenderMainView:updateUI()
	self:initReward();
	self:btnshowInf();
end

function DefenderMainView:initReward()
	---- 获取服务器的数据
	
	local rewardsStr = self:getServiceData()
	-- local rewardArray = string.split(rewardsStr, ";");
	local rewardArray = rewardsStr.reward
	local itemNum = table.length(rewardArray);
	for i=1,itemNum do
		local reward = string.split(rewardArray[i], ",");
		local rewardType = reward[1];
		local rewardNum = reward[table.length(reward)];
		local rewardId = reward[table.length(reward) - 1];

		local commonUI = self.panel_3["UI_" .. tostring(i)];
		commonUI:setResItemData({reward = rewardArray[i]});
		-- commonUI:showResItemName(false);
		-- commonUI:showResItemRedPoint(false);
		commonUI:visible(true)
		FuncCommUI.regesitShowResView(commonUI,
            rewardType, rewardNum, rewardId, rewardArray[i], true, true);
	end
	local challengID = self:getchallengID()
	if challengID ~= 0 then
		challengID = challengID + 1
	end 
	self.panel_2.mc_1:showFrame(challengID)
	-- self.panel_4.txt_1:setString(FuncDefender.gettitleText())

end
function DefenderMainView:btnshowInf()
	--获得服务器数据 
	--TODO
	--显示是否挑战，是否领取。是否二次领取
	-- self.mc_1:showFrame(self.buttonnumber)
	if  DefenderModel:judgeIsChallenger() == 1 then
		self.mc_1:showFrame(1)
	end
	if  DefenderModel:judgeGetaward() == 1 then
		self.mc_1:showFrame(2)
	end
	if  DefenderModel:judgeAgainGetAward() == 1 then
		self.mc_1:showFrame(3)
	end
	if DefenderModel:judgeIsChallenger()== 0 and DefenderModel:judgeAgainGetAward() == 0  and  DefenderModel:judgeAgainGetAward() == 0 then
		self.mc_1:visible(false)
	end 

end



function DefenderMainView:getServiceData()
    local  challengID = self:getchallengID()
	local rewardsStr = FuncDefender.getIDAward(challengID)
	return rewardsStr
end
function DefenderMainView:getchallengID()
	local  challengID = DefenderModel:getChallengStagnumber()   ----获得服务器数据
	return challengID
end
--暂时测试用的
function DefenderMainView:setbtn()
	local rewardsStr = self:getServiceData()
	-- local rewardArray = string.split(rewardsStr, ";");
	local rewardArray =  rewardsStr.reward
	self.buttonnumber = self.buttonnumber + 1
	-- self.mc_1:showFrame(self.buttonnumber)
	-- echo("======================",self.buttonnumber)
	if self.buttonnumber == 3 then
		FuncCommUI.startFullScreenRewardView(rewardArray);
	elseif  self.buttonnumber == 4 then
		-- FuncCommUI.startFullScreenRewardView(rewardArray);
		local needVIPfile =	DefenderModel:getDefenderVIPWhetherAgainAward()
	    if needVIPfile then
	    	if DefenderModel:getDefenderJadeWhetherAgainAward() then
		    	FuncCommUI.startFullScreenRewardView(rewardArray);
		    	self.mc_1:visible(false)
		    else
		    	WindowControler:showTips("钻石不足"..FuncDefender.MAX_GOLDCOST_COUNT);
		    end
    	else
    		WindowControler:showTips("VIP等级不足"..FuncDefender:getAgainAwardNeedVIP());
    	end
    	self.buttonnumber = self.buttonnumber  - 1
	end

	if self.buttonnumber < 4 then
		self.mc_1:showFrame(self.buttonnumber)
	end
end
---点击挑战按钮调用
function DefenderMainView:touchChallengerBtn()
	--进入战斗调用
	-- local tempFunc =function ()
		--TODO
	-- end
	-- DefenderServer:requestDefenderChallenger(tempFunc)
end
--点击领取奖励按钮
function DefenderMainView:touchgetAwardBtn()
	--TODO
	-- local rewardsStr = self:getServiceData()
	-- local rewardArray =  rewardsStr.reward
	-- local getFunc =function ()
		--TODO
		-- FuncCommUI.startFullScreenRewardView(rewardArray);
		-- self:btnshowInf();
	-- end
	-- DefenderServer:requestGetAward(1,getFunc)

end
--点击再次领取按钮
function DefenderMainView:touchAgainAwardBtn()
	--TODO  
	-- local rewardsStr = self:getServiceData()
	-- local rewardArray =  rewardsStr.reward
	-- local againgetFunc =function ()
		--TODO
		-- FuncCommUI.startFullScreenRewardView(rewardArray);
		-- self:btnshowInf();
	-- end
	-- DefenderServer:requestGetAward(2,againgetFunc) 

end

function DefenderMainView:setscroll_listData()

	-- self.panel_4.scroll_1
	self.panel_4.rich_1:visible(false)

-- dump(self.panel_4.rich_1:getContainerBox())

	self.panel_4.panel_1:visible(false)
	self.panel_4.txt_2:visible(false)
	self.panel_4.rich_2:visible(false)

	local createFunc_1 = function (data)
		local itemView = UIBaseDef:cloneOneView( self.panel_4.rich_1 )
		-- itemView:setString(FuncDefender.getcontentInftext())
		-- itemView:setContentSize(cc.size(310,180))
		return itemView
	end

	local createFunc_2 = function (data)
		local itemView = UIBaseDef:cloneOneView( self.panel_4.panel_1 )
		return itemView
	end
	local createFunc_3 = function (data)
		local itemView = UIBaseDef:cloneOneView( self.panel_4.txt_2 )
		-- itemView:setString(FuncDefender.getstageText())
		return itemView
	end
	local createFunc_4 = function (data)
		local itemView = UIBaseDef:cloneOneView( self.panel_4.rich_2 )
		-- itemView:setString(FuncDefender.getstageInfText())
		return itemView
	end
		local params = {
			{
				data = {1},
				createFunc= createFunc_1,
				perNums=1,
				offsetX =20,
				offsetY =10,
				itemRect = {x=0,y=-self.panel_4.rich_1:getContainerBox().height,width=self.panel_4.rich_1:getContainerBox().width,height = self.panel_4.rich_1:getContainerBox().height},
				perFrame = 2,
				heightGap = 0
			},
			{
				data = {1},
				createFunc= createFunc_2,
				perNums=1,
				offsetX =-10,
				offsetY =10,
				itemRect = {x=0,y=-11,width=360,height = 11},
				perFrame = 2,
				heightGap = 0
			},
			{
				data = {1},
				createFunc= createFunc_3,
				perNums=1,
				offsetX =20,
				offsetY =10,
				itemRect = {x=0,y=-30,width=360,height = 30},
				perFrame = 2,
				heightGap = 0
			},
			{
				data = {1},
				createFunc= createFunc_4,
				perNums=1,
				offsetX =20,
				offsetY =5,
				itemRect = {x=0,y=-self.panel_4.rich_2:getContainerBox().height,width=self.panel_4.rich_2:getContainerBox().width,height = self.panel_4.rich_2:getContainerBox().height},
				perFrame = 2,
				heightGap = 0
			},
		}
		self.panel_4.scroll_1:styleFill(params)
end

function DefenderMainView:addEffect()
	echo("添加仙球旋转特效")
    local npcSpine = ViewSpine.new("UI_shouweizixuan_c") 
	npcSpine:playLabel("UI_shouweizixuan_renwu",true)
	self.ctn_1:removeAllChildren()
	npcSpine:setPositionY(npcSpine:getPositionY() - 65)
	self.ctn_1:addChild(npcSpine,2)
	self.ctn_1:setScale(1.0)

	local lockAni = self:createUIArmature("UI_shouweizixuan_a","UI_shouweizixuan_a_diceng", nil, true, GameVars.emptyFunc)
    lockAni:setPositionY(lockAni:getPositionY() - 77.5)
    lockAni:setPositionX(lockAni:getPositionX() - 10.5)
    self.ctn_1:addChild(lockAni,1)


    local lockAni = self:createUIArmature("UI_shouweizixuan_a","UI_shouweizixuan_a_qianceng", nil, true, GameVars.emptyFunc)
    lockAni:setPositionY(lockAni:getPositionY() - 77.5)
    lockAni:setPositionX(lockAni:getPositionX() - 8)
    self.ctn_1:addChild(lockAni,3)


   
    local lockAni = self:createUIArmature("UI_shouweizixuan_b","UI_shouweizixuan_b_21", nil, true, GameVars.emptyFunc)
    lockAni:setPositionY(lockAni:getPositionY() -60)
    -- lockAni:setPositionX(lockAni:getPositionX() - 6.5)
    self.ctn_ta:setScale(1.0)
    self.ctn_ta:addChild(lockAni)


    -- self.panel_1:setlocalzorder(10)
end


function DefenderMainView:guardboardHelp()
	echo("clickA1_Dafender");
    -- WindowControler:showWindow("MailView")
    WindowControler:showWindow("DefenderHelpView")
end


function DefenderMainView:press_btn_close()    ----点击使得该层消失
	self:startHide()
end
return DefenderMainView


