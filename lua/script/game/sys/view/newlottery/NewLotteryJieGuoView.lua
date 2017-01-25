-- NewLotteryJieGuoView
--三皇抽奖系统
--2016-12-27 10:40
--@Author:wukai

local NewLotteryJieGuoView = class("NewLotteryJieGuoView", UIBase);
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

function NewLotteryJieGuoView:ctor(winName)
    NewLotteryJieGuoView.super.ctor(self, winName);
end

function NewLotteryJieGuoView:loadUIComplete()
	-- self.btn_2:visible(false)
	-- self.mc_goon:visible(false)
	local a_black = FuncRes.a_black(1136*4,640*4)
	self.UI_1.ctn_2:addChild(a_black)

	self:registerEvent()
	self:initData()
    self:addEventListeners()
    self:addEffect()
    self:addbutton()

    
    -- self:ContinueButton()
end

function NewLotteryJieGuoView:registerEvent()
	NewLotteryJieGuoView.super.registerEvent()
	AudioModel:playSound(MusicConfig.s_scene_luck_get)
end
function NewLotteryJieGuoView:ShowItemsAudio()
	
	-- local s =  AudioModel:playSound(MusicConfig.s_scene_luck_icon)
	-- local musicFile = GameConfig.getMusic(MusicConfig.s_scene_luck_icon)
	-- local musicFileExist = cc.FileUtils:getInstance():isFileExist(musicFile)
	-- local s = audio.playSound(musicFile, false)
	-- echo("================",s)
	
end
function NewLotteryJieGuoView:ContinueButton()
	local electtype =	FuncNewLottery.getlotterytype()
	local freeselecttype = FuncNewLottery.getlotteryFreeType()
	local RMBselecttype = FuncNewLottery.getlotteryRMBType()
	local parmes = nil
	if electtype ==  1 then --免费
		if freeselecttype == 1 then
			parmes = 1
			self.mc_goon:getViewByFrame(parmes).mc_2:visible(true)
			self.mc_goon:getViewByFrame(parmes).mc_1:visible(false)
			self.mc_goon:getViewByFrame(parmes).btn_1:setTap(c_func(self.buttonFreeOnce,self))
			
		else   --五次数据
			parmes = 2
			self.mc_goon:getViewByFrame(parmes).mc_2:visible(true)
			self.mc_goon:getViewByFrame(parmes).mc_1:visible(false)
			self.mc_goon:getViewByFrame(parmes).btn_1:setTap(c_func(self.buttonFreeFive,self))
		end
		self:initfreeData(parmes)
	else   ---元宝抽
		if RMBselecttype == 1 then
			parmes = 1
			self.mc_goon:getViewByFrame(parmes).mc_2:visible(false)
			self.mc_goon:getViewByFrame(parmes).mc_1:visible(true)
			self.mc_goon:getViewByFrame(parmes).btn_1:setTap(c_func(self.buttonRMDOnce,self))
		else
			parmes = 3
			self.mc_goon:getViewByFrame(parmes).mc_2:visible(false)
			self.mc_goon:getViewByFrame(parmes).mc_1:visible(true)
			self.mc_goon:getViewByFrame(parmes).btn_1:setTap(c_func(self.buttonRMBTence,self))
		end
		self:initRMBData(parmes)
	end

	self.mc_goon:showFrame(parmes)
	-- self.mc_goon:getViewByFrame(parmes).btn_1:
end
function NewLotteryJieGuoView:initRMBData(parmes)
    --显示元宝十次高级造物符
    local tenRMBnumber = FuncNewLottery.consumeTenRMB()
    local seniorDrawcard = NewLotteryModel:getseniorDrawcard()
    local RMBonce = NewLotteryModel:getRMBoneLottery() --花费元宝抽
    local RMBfirstlottery =  NewLotteryModel:getRMBPayLottery()
    if parmes == 1 then
	    if RMBonce ~= 0 then
	        if seniorDrawcard > 0 then
	            -- self.mc_zao1:getViewByFrame(2).mc_cost2:showFrame(3)
	            self.mc_goon:getViewByFrame(parmes).mc_1:showFrame(3)
	            self.mc_goon:getViewByFrame(parmes).mc_1:getViewByFrame(3).txt_1:setString(seniorDrawcard.."/1")
	        else
	            if  RMBfirstlottery == 0 then
	            	self.mc_goon:getViewByFrame(parmes).mc_1:showFrame(4)
	            	self.mc_goon:getViewByFrame(parmes).mc_1:getViewByFrame(4).txt_1:setString(FuncNewLottery.consumeOnceRMB())
	            	self.mc_goon:getViewByFrame(parmes).mc_1:getViewByFrame(4).txt_2:setString(FuncNewLottery.consumeOnceRMB()/2)

	            else
	                self.mc_goon:getViewByFrame(parmes).mc_1:showFrame(2)
	                self.mc_goon:getViewByFrame(parmes).mc_1:getViewByFrame(2).txt_1:setString(FuncNewLottery.consumeOnceRMB())
	            end
	        end

	    elseif RMBonce == 0 then
	        -- if parmes == 1 then
	        	self.mc_goon:getViewByFrame(parmes).mc_1:showFrame(1)
	        -- end
	    end
	else
	    if seniorDrawcard >= 10 then
	        self.mc_goon:getViewByFrame(parmes).mc_1:showFrame(3)
	        self.mc_goon:getViewByFrame(parmes).mc_1:getViewByFrame(3).txt_1:setString(seniorDrawcard.."/10")
	    else
	        self.mc_goon:getViewByFrame(parmes).mc_1:showFrame(2)
	        self.mc_goon:getViewByFrame(parmes).mc_1:getViewByFrame(2).txt_1:setString(FuncNewLottery.consumeTenRMB())
	    end
	end
end


function NewLotteryJieGuoView:initfreeData(parmes)
    -- self.mc_goon:getViewByFrame(parmes).mc_2:showFrame() --1 是免费次数 2是普通抽卡卷

    self.serverdatafreeonce = NewLotteryModel:getLotterynumber() --服务器抽奖次数
    local Differ = FuncNewLottery.getFreecardnumber() - self.serverdatafreeonce
    if parmes == 1 then   --一次
	    -- --显示免费一次造物符
	    self:RefreshfreecradUI()
	end
    if parmes == 2 then   --五次
	    --显示免费五次造物符
	    -- self.mc_goon:getViewByFrame(parmes).mc_2:showFrame(2)
	    local onefreenumber = 5 * FuncNewLottery.Ordninaryfreecardnumber()
	    local number = NewLotteryModel:getordinaryDrawcard()
	    self.mc_goon:getViewByFrame(parmes).mc_2:showFrame(2)
	    self.mc_goon:getViewByFrame(parmes).mc_2:getViewByFrame(2).txt_1:setString(number.."/"..onefreenumber)
	end
    -- self:RefreshfreecradUI()
end
function NewLotteryJieGuoView:RefreshfreecradUI()
	 local freeitems  = NewLotteryModel:getLotterynumber()   --服务器抽奖次数
    local ordinarycrad = NewLotteryModel:getordinaryDrawcard()
    local cdtime = NewLotteryModel:getCDtime()
    -- echo("====freeitems========ordinarycrad==========cdtime=============",freeitems,ordinarycrad,cdtime)
    if freeitems ~= 0 then   
        if ordinarycrad ~= 0 then
            ---不显示倒计时，显示普通造物符
            if cdtime == 0 then
                -- 显示免费次数
                self.serverdatafreeonce = freeitems --服务器抽奖次数
                local Differ = FuncNewLottery.getFreecardnumber() - self.serverdatafreeonce
                --显示免费一次造物符
                if Differ ~= 0 then
                    self.mc_goon:getViewByFrame(1).mc_2:showFrame(1)
	    			self.mc_goon:getViewByFrame(1).mc_2:getViewByFrame(1).txt_1:setString("本次免费"..Differ.."/"..FuncNewLottery.getFreecardnumber())
                else --显示造物符
                    local number = NewLotteryModel:getordinaryDrawcard()
                    self.mc_goon:getViewByFrame(1).mc_2:showFrame(2)
                    self.mc_goon:getViewByFrame(1).mc_2:getViewByFrame(2).txt_1:setString(number.."/"..FuncNewLottery.Ordninaryfreecardnumber())
                end

            else
            	local number = NewLotteryModel:getordinaryDrawcard()
                self.mc_goon:getViewByFrame(1).mc_2:getViewByFrame(2).txt_1:setString(number.."/"..FuncNewLottery.Ordninaryfreecardnumber())
                self.cdtime = NewLotteryModel:getCDtime()
                self:setcdtime()
                self.mc_goon:getViewByFrame(1).mc_2:showFrame(2)
            end
        else
            --显示时间
            if  cdtime ~= 0 then
                self.cdtime = NewLotteryModel:getCDtime()
                self:setcdtime()
            else
            	local Differ = FuncNewLottery.getFreecardnumber() - self.serverdatafreeonce
                self.mc_goon:getViewByFrame(1).mc_2:showFrame(1)
	    		self.mc_goon:getViewByFrame(1).mc_2:getViewByFrame(1).txt_1:setString("本次免费"..Differ.."/"..FuncNewLottery.getFreecardnumber())
            end
        end
    else
    	if  cdtime ~= 0 then
            self.cdtime = NewLotteryModel:getCDtime()
            self:setcdtime()
        end
    end
end
function NewLotteryJieGuoView:setcdtime()
    if self.cdtime ~= 0 then
        local onetime =  math.floor(self.cdtime/3600)
        if string.len(onetime) == 1 then
            onetime = "0"..onetime
        end
        local onebranch = math.floor((self.cdtime - onetime*3600)/60)
        if string.len(onebranch) == 1 then
            onebranch = "0"..onebranch
        end
        local onesecond =  math.fmod(self.cdtime - onetime*3600, 60)
        if string.len(onesecond) == 1 then
            onesecond = "0"..onesecond
        end
        self.Atimes = onetime
        self.Abranchs = onebranch
        self.Aseconds = onesecond
    else
        self.Atimes = "00"
        self.Abranchs = "00"
        self.Aseconds = "00"
    end
    self.mc_goon:getViewByFrame(1).mc_2:showFrame(1)
	self.mc_goon:getViewByFrame(1).mc_2:getViewByFrame(1).txt_1:setString(self.Abranchs..":"..self.Aseconds)
    if self.Countdownsch == nil then
        self.Countdownsch = scheduler.scheduleGlobal(c_func(self.showCountdown,self), 1)
    end
end
function NewLotteryJieGuoView:showCountdown()
    ---一次的时间
        self.Aseconds = self.Aseconds - 1
        if self.Aseconds == -1  then
            if self.Abranchs ~= -1 then
                self.Abranchs = self.Abranchs - 1
                self.Aseconds = 59
                if self.Abranchs == -1 then
                    if self.Atimes ~= -1 then 
                        self.Atimes = self.Atimes - 1
                        self.Abranchs = 59 
                        if self.Atimes == -1 then
                            self.Atimes = 0
                            self.Abranchs = 0
                            self.Aseconds = 0
                            if self.Countdownsch ~= nil then
                                scheduler.unscheduleGlobal(self.Countdownsch)
                                self.Countdownsch = nil
                                self:ContinueButton()
                                return 
                            end
                        end
                    end
                end
            end
        end
        self.Atimes = self.Atimes..""
        self.Abranchs  = self.Abranchs..""
        self.Aseconds = self.Aseconds..""

        if string.len(self.Atimes) == 1 then
            self.Atimes = "0"..self.Atimes
        end
        if string.len(self.Abranchs) == 1 then
            self.Abranchs = "0"..self.Abranchs 
        end
        if string.len(self.Aseconds) == 1 then
            self.Aseconds = "0"..self.Aseconds
        end
        -- self.mc_zao1:getViewByFrame(1).mc_cost:showFrame(1)
        self.mc_goon:getViewByFrame(1).mc_2:getViewByFrame(1).txt_1:setString(self.Abranchs..":"..self.Aseconds)


end


function NewLotteryJieGuoView:buttonFreeOnce()
	echo("一次")
	self:judgeLotteryType(c_func(self.lotteryRMBResult,self))
end
function NewLotteryJieGuoView:buttonFreeFive()
	echo("五次")
	self:judgeLotteryType(c_func(self.lotteryRMBResult,self))
end
function NewLotteryJieGuoView:buttonRMDOnce()
	echo("元宝一次")
	self:judgeLotteryType(c_func(self.lotteryRMBResult,self))
end
function NewLotteryJieGuoView:buttonRMBTence()
	echo("元宝十次")
	self:judgeLotteryType(c_func(self.lotteryRMBResult,self))
end
function NewLotteryJieGuoView:lotteryRMBResult(result)
	-- dump(result,"结果界面抽")

	if result.error ~= nil then
		self.serverdata = true
		WindowControler:showTips("服务器返回错误 code ="..result.error.code)
		self:GetServerDataobjectID(math.random(1,6))
		return
	end
	local objectdata = result.result.data.reward
	NewLotteryModel:setServerData(objectdata)
	-- self.UI_1.ctn_1:removeFromParent()
	-- self.UI_1:removeFromParent()
	self.anim:removeFromParent()
	-- self.anim:doByLastFrame( true, true ,function () end)
	-- self.lockAni:doByLastFrame( true, true ,function () end)
	self.btn_2:visible(false)
	self.mc_goon:visible(false)
	self.anim = nil
	self.lockAni = nil
	self:registerEvent()
	self:initData()
	self:addEffect()
	self:ContinueButton()
end
function NewLotteryJieGuoView:addbutton()
	self.btn_2:visible(false)
	self.mc_goon:visible(false)
	self:confirmButton()
	self:ContinueButton()

end

function NewLotteryJieGuoView:judgeLotteryType(_callback)
	--发送抽奖协议
		local lottterytype= nil
		local types = FuncNewLottery.getlotterytype()

		if types == FuncNewLottery.lotterytypetable[1] then   ---免费抽 0 1 5
			local successfile,errorid = NewLotteryModel:FreeCanlottery()
			if successfile then
				local items = FuncNewLottery.getlotteryFreeType()   -- 1 ，5  
				local time = NewLotteryModel:getCDtime()
				if items == 1 then    ----1次
					if time == 0 then
						if NewLotteryModel:getLotterynumber() >= 5 then
							lottterytype = 1
						else
							lottterytype = 0
						end
					else
						local card = NewLotteryModel:getordinaryDrawcard()
						lottterytype = 1
					end
				else     ---5次
					lottterytype = 5
				end
				-- echo("===sendserver================",lottterytype)
				NewLotteryServer:freeDrawcard(lottterytype,_callback)
				return true
			else
				FuncNewLottery.getfreeIDerror(errorid)
				return false
			end
		elseif types ==  FuncNewLottery.lotterytypetable[2] then ---元宝抽
			local RMBCanlottery,errorid = NewLotteryModel:RMBCanlottery()
			if RMBCanlottery then
				local isGold = nil
				local types = nil
				local seniorDrawcard = NewLotteryModel:getseniorDrawcard()   --高级抽奖卡
			    local RMBonce = NewLotteryModel:getRMBoneLottery() --是否花费元宝抽抽奖
			    local RMBfirstlottery =  NewLotteryModel:getRMBPayLottery()   ---第一次元宝抽
			    local items = FuncNewLottery.getlotteryRMBType()   -- 1 ，10
			    if items == 1 then
				    if RMBonce ~= 0 then
				    	if seniorDrawcard > 0 then
				    		types = 1
				    		isGold = false
				    	else
				    		types = 1
				    		isGold = true
				    	end
				    else
				    	types  = 0
				    	isGold = false
				    end
			   	else
			   		if seniorDrawcard > 10 then
			   			types = 10
			   			isGold = false
			   		else
			   			if UserModel:getGold() > FuncNewLottery.consumeTenRMB() then
			   				types = 10
			   				isGold = true
			   			else
			   				types = 10
			   				isGold = false
			   			end

			   		end
			   	end
			   	-- echo("=====sendserver===================",types,isGold)c_func(self.lotteryRMBResult,self)
				NewLotteryServer:consumeDrawcard(types,isGold,_callback)
				return true
			else
				FuncNewLottery.getRMBIDerror(errorid)
				return false
			end
		end

end



function NewLotteryJieGuoView:confirmButton() --返回按钮
	self.btn_2:setTap(function ()
		--回调一个音乐开关的方法
		EventControler:dispatchEvent(NewLotteryEvent.GET_AUDIO_BLACK_MAIN)
	 	self:press_btn_close()
	 	if self.Countdownsch ~= nil then
            scheduler.unscheduleGlobal(self.Countdownsch)
            self.Countdownsch = nil
        end
	end)
end

function NewLotteryJieGuoView:addEffect() --doByLastFrame
	-- 奖品特效
    self.anim = FuncCommUI.playSuccessArmature(self.UI_1,FuncCommUI.SUCCESS_TYPE.GET, 1, false);
    -- self.anim:getBoneDisplay("renyi"):visible(false)
  	self.anim:registerFrameEventCallFunc(25, 1, function ()
  		
	  	local awardnumber =  #self.reward
	  	self.lockAni = nil
	  	local effectname = nil
	  	if awardnumber == 1 then
	  		effectname = "UI_chouka_b_danchou"
	  		self.lockAni = self:createUIArmature("UI_chouka_b",effectname, self.UI_1.ctn_1, false, function ()
	  		end)
	  		self.lockAni:registerFrameEventCallFunc(20,1,function ()
				self.lockAni = nil
				self:pressbtnclose()
			end)
	  		self.lockAni:registerFrameEventCallFunc(15, 1, function ()
	  			local awarddata = self.reward[1]
				local rewardtype =  tonumber(awarddata[1])
				local rewardID = tonumber(awarddata[2])
				if rewardtype == 18 then
					--跳到卡牌界面
					-- self.lockAni:pause(true)
					WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[1])
				end
	  		end)
		    FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a15_copy"), "node1", self.view[1])
		    self.lockAni:getBoneDisplay("a15_copy"):doByLastFrame( true, true )
		    self.view[1]:setPosition(-17,13)
		    -- self:ShowItemsAudio()
		  	AudioModel:playSound(MusicConfig.s_scene_luck_icon)

	  	elseif awardnumber == 5 then
	  		-- effectname = "UI_chouka_b_wulian"
	  		-- self.sumindex = 19
	  		-- self:otteryexchangelleffect()
	  		self:lotteryFives()

	  	elseif awardnumber == 10 then
	  		-- effectname = "UI_chouka_b_shilian"
	  		self:lotteryTen()


  		end
  	end);

    -- local self.lockAni = self:createUIArmature("UI_chouka_b",effectname, self.UI_1.ctn_1, false, function ()
    -- end)
    -- self.ctn_2:addChild(self.lockAni,3)
    -- FuncArmature.changeBoneDisplay(self.lockAni, "node1", self.panel_1);
    -- self.lockAni:doByLastFrame( true, true ,function () end)

    

end
function NewLotteryJieGuoView:pressbtnclose()
	self.btn_2:visible(true)
	self.mc_goon:visible(true)
	-- self:registClickClose(nil, function ()
	-- 	self:press_btn_close()
	-- 	if self.Countdownsch ~= nil then
 --            scheduler.unscheduleGlobal(self.Countdownsch)
 --            self.Countdownsch = nil
 --        end
	-- end);
end
function NewLotteryJieGuoView:lotteryOnce()
	
end

function NewLotteryJieGuoView:changeitmes()
	self.lockAnione:registerFrameEventCallFunc(5,1,function ()
		FuncArmature.changeBoneDisplay(self.lockAni, "node1", self.panel_1);
	end)
end


--初始化数据
function NewLotteryJieGuoView:initData()
	local prame = self:showFrameitmes()
	self.reward = NewLotteryModel:getServerData()
	-- echo("========prame===========",prame)
	self.mc_2:showFrame(prame)
	-- dump(reward,"抽奖奖励")
	self.view = {}
	for i=1,#self.reward do
		self.view[i] =  self.mc_2:getViewByFrame(prame)["mc_"..i]
		self.view[i]:visible(false)
		self:createreward(self.view[i],self.reward[i])
	end
	self.cradservea = false
	self.newindex = nil

end


function NewLotteryJieGuoView:addEventListeners()
 	EventControler:addEventListener(NewLotteryEvent.RESUME_REWARD_ITEMS,self.againshowitem,self)--繼續彈獎勵itmes
end
function NewLotteryJieGuoView:againshowitem()
	self:delayCall(function ()
		if self.lockAni ~= nil then
			self.lockAni:play(true)
		end
	end,0.3)
		-- self.lockAni:play(true)
	-- self.cradservea = false
	-- self:oneByonyShow(self.newindex + 1)
end
function NewLotteryJieGuoView:createreward(view,reward)
	-- dump(reward,"奖励数据")
	-- local reward = {
	-- 	[1] = 1,
	-- 	[2] = 9109,
	-- 	[3] = 1,
	-- }
	---1伙伴，2item（法宝碎片，伙伴碎片，道具）    3法宝
	local rewardtype =  tonumber(reward[1])
	local rewardID = tonumber(reward[2])
	local rewardnumber = tonumber(reward[3])
	if rewardtype == 1 then   --item
		-- view:visible(false)
		local  itemIcon = nil
		local itemData = FuncItem.getItemData(rewardID)
		local quality = itemData.quality
		view:showFrame(2)
		view:getViewByFrame(2).panel_1:visible(false)
		view:getViewByFrame(2).txt_1:setString(rewardnumber)
		view:getViewByFrame(2).mc_1:getViewByFrame(1).mc_coin:showFrame(quality)

		local itemsType = itemData.type
		self.itemSubType = tonumber(itemData.subType)
        if itemsType ~= nil and tonumber(itemsType) == ItemsModel.itemType.ITEM_TYPE_PIECE then
            
            if self.itemSubType == 202 then -- 伙伴碎片
                itemIcon = display.newSprite(FuncRes.iconHero(FuncItem.getItemData(rewardID).icon)):anchor(0.5,0.5)
                itemIcon:setScale(0.8)
            else
                itemIcon = display.newSprite(FuncRes.iconTreasure(rewardID)):anchor(0.5,0.5)
                itemIcon:setScale(0.44)
            end
        else
            itemIcon = display.newSprite(FuncRes.iconItem(rewardID)):anchor(0.5,0.5)
            -- itemIcon:setScale(0.8)
        end
		local name =  view:getViewByFrame(2).mc_1:getViewByFrame(1).mc_coin:getViewByFrame(quality).txt_1
		name:setString(GameConfig.getLanguage(itemData.name))
		view:getViewByFrame(2).mc_1:getViewByFrame(1).mc_goods:showFrame(quality)
		local bgicon = view:getViewByFrame(2).mc_1:getViewByFrame(1).mc_goods:getViewByFrame(quality).ctn_1
        bgicon:addChild(itemIcon)
	elseif rewardtype == 10 then

		view:showFrame(3)
		view:getViewByFrame(3).panel_1:visible(false)
		view:getViewByFrame(3).txt_1:setString(rewardnumber)
		local  Treasureinfo = FuncTreasure.getTreasureAllConfig()[tostring(rewardID)]  ---法宝详情
		local quality = Treasureinfo.quality
		view:showFrame(quality)
		view:getViewByFrame(3).mc_coin:showFrame(6)
		local name =  view:getViewByFrame(3).mc_coin:getViewByFrame(6).txt_1
		view:getViewByFrame(3).mc_goods:showFrame(quality)
		name:setString(GameConfig.getLanguage(Treasureinfo.name))
		local bgicon = view:getViewByFrame(3).ctn_2
		local  itemIcon = display.newSprite(FuncRes.iconEnemyTreasure(Treasureinfo.icon)):anchor(0.5,0.5)
        -- itemIcon:setScale(0.7)
        bgicon:addChild(itemIcon)

	elseif rewardtype == 18 then
		local PartnerID = rewardID
	    local PartnerData = FuncNewLottery.PartnerData --PartnerModel:getAllPartner()
	    -- view:getViewByFrame(3).txt_1:visible(false)
	    view:getViewByFrame(1).txt_1:setString(rewardnumber)
	    if PartnerData[tostring(PartnerID)] == nil then  --伙伴数据库里是否存在该伙伴
			view:showFrame(1)
			local Partnerinfo = FuncPartner.getPartnerById(rewardID)                       ----伙伴详情
			local quality = Partnerinfo.initQuality
			view:getViewByFrame(1).mc_coin:showFrame(quality)
			local name =  view:getViewByFrame(1).mc_coin:getViewByFrame(quality).txt_1
			view:getViewByFrame(1).mc_goods:showFrame(quality)
			name:setString(GameConfig.getLanguage(Partnerinfo.name))
			local bgicon = view:getViewByFrame(1).mc_goods:getViewByFrame(quality).ctn_1
			local  itemIcon = display.newSprite(FuncRes.iconHero(Partnerinfo.icon)):anchor(0.5,0.5)
	        itemIcon:setScale(0.8)
	        bgicon:addChild(itemIcon)
	    else
	    	local  itemIcon = nil
			local itemData = FuncItem.getItemData(rewardID)
			local quality = itemData.quality
	    	view:showFrame(2)
			view:getViewByFrame(2).mc_1:getViewByFrame(1).mc_coin:showFrame(quality)

			self.itemSubType = tonumber(itemData.subType)
			if self.itemSubType == 202 then -- 伙伴碎片
                itemIcon = display.newSprite(FuncRes.iconHero(FuncItem.getItemData(rewardID).icon)):anchor(0.5,0.5)
                itemIcon:setScale(0.8)
            end
            local number = FuncPartner.getPartnerById(rewardID).sameCardDebris
            local name =  view:getViewByFrame(2).mc_1:getViewByFrame(1).mc_coin:getViewByFrame(quality).txt_1
			name:setString(GameConfig.getLanguage(itemData.name))
			view:getViewByFrame(2).txt_1:setString(number)
			view:getViewByFrame(2).mc_1:getViewByFrame(1).mc_goods:showFrame(quality)
			local bgicon = view:getViewByFrame(2).mc_1:getViewByFrame(1).mc_goods:getViewByFrame(quality).ctn_1
	        bgicon:addChild(itemIcon)
	    end
	end
-- cca.show()
	-- view:runAction(cca.seq({cca.scaleTo(0.1,1),
	-- 	cca.delay(1.0),
	-- 	cca.callFunc(function()
	-- 		if rewardtype == 18 then
	-- 			echo("弹出卡牌")
	-- 		end
	-- 	end)}))
	-- self:delayCall(c_func(callBack, self),delayTime)
end
--获得第几帧的数据 1234 表示的第几帧显示
function NewLotteryJieGuoView:showFrameitmes()
	local frame = 1 -- 测试
	local index = 1
	local lottyertype = FuncNewLottery.getlotterytype() --1免费类型, 2元宝消耗
	-- echo("========抽奖类型=======",lottyertype)
	if lottyertype == FuncNewLottery.lotterytypetable[1] then --免费抽
		local items =  FuncNewLottery.getlotteryFreeType()
		if items == 1 then
			frame = 1 
			index = 1
		else
			frame = 2
			index = 2
		end
	elseif lottyertype == FuncNewLottery.lotterytypetable[2]  then --元宝抽
		local items =  FuncNewLottery.getlotteryRMBType()
		if items == 1 then
			frame = 1 
			index = 3
		else
			frame = 3
			index = 4
		end
	end
	self.mc_1:showFrame(index)
	return frame
end




function NewLotteryJieGuoView:press_btn_close()
	self:_callback()
    self:startHide()
    FuncNewLottery.CachePartnerdata()
end
function NewLotteryJieGuoView:_callback()
	EventControler:dispatchEvent(NewLotteryEvent.BLACK_LOTTERY_MAIN)
end
local parmes = {
	[1] = 3,
	[2] = 7,
	[3] = 10,
	[4] = 14,
	[5] = 17,
}
function NewLotteryJieGuoView:otteryexchangelleffect()
	-- self.lockAni = nil
	-- local  effectname = "UI_chouka_b_wulian"
	-- self.lockAni = self:createUIArmature("UI_chouka_b",effectname, self.UI_1.ctn_1, false, function () end)
	-- self.lockAni:doByLastFrame( true, true )
	-- self.lockAni:visible(false)
	-- self.lockAni:registerFrameEventCallFunc(parmes[1],1,function ()
	-- 	FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a19_copy"), "node1", self.view[1])  --替换
	-- end)
	-- self.lockAni:registerFrameEventCallFunc(parmes[2],1,function ()
	-- 	FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a17_copy"), "node1", self.view[2])  --替换
	-- end)
	-- self.lockAni:registerFrameEventCallFunc(parmes[3],1,function ()
	-- 	FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a15_copy"), "node1", self.view[3])  --替换
	-- end)
	-- self.lockAni:registerFrameEventCallFunc(parmes[4],1,function ()
	-- 	FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a13_copy"), "node1", self.view[4])  --替换
	-- end)
	-- self.lockAni:registerFrameEventCallFunc(parmes[5],1,function ()
	-- 	FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a11_copy"), "node1", self.view[5])  --替换
	-- end)
end

function NewLotteryJieGuoView:lotteryFives()

	local  effectname = "UI_chouka_b_wulian"
	self.lockAni = self:createUIArmature("UI_chouka_b",effectname, self.UI_1.ctn_1, false, function ()
		self.lockAni = nil
	end)
	self.lockAni:visible(true)
	FuncArmature.setArmaturePlaySpeed(self.lockAni,0.7)
	self.lockAni:registerFrameEventCallFunc(35,1,function ()
		self:pressbtnclose()
	end)

---[[
	-- self:ShowItemsAudio(true)
	self.lockAni:registerFrameEventCallFunc(parmes[1],1,function ()
		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a19_copy"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a19_copy"), "node1", self.view[1])  --替换
		self.lockAni:getBoneDisplay("a19_copy"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a19_copy"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a19_copy"):doByLastFrame( true, true ,function () 
		end)

		self.view[1]:setPosition(-17,13)
		local awarddata = self.reward[1]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[1])
		end
	end)







	self.lockAni:registerFrameEventCallFunc(parmes[2],1,function ()
		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a17_copy"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a17_copy"), "node1", self.view[2])  --替换
		self.lockAni:getBoneDisplay("a17_copy"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a17_copy"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a17_copy"):doByLastFrame( true, true ,function () 
		end)

		self.view[2]:setPosition(-17,13)
		local awarddata = self.reward[2]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[2])
		end

	end)
	self.lockAni:registerFrameEventCallFunc(parmes[3],1,function ()
		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a15_copy"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a15_copy"), "node1", self.view[3])  --替换
		self.lockAni:getBoneDisplay("a15_copy"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a15_copy"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a15_copy"):doByLastFrame( true, true ,function () 
		end)


		self.view[3]:setPosition(-17,13)
		local awarddata = self.reward[3]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[3])
		end

	end)
	self.lockAni:registerFrameEventCallFunc(parmes[4],1,function ()
		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a13_copy"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a13_copy"), "node1", self.view[4])  --替换
		self.lockAni:getBoneDisplay("a13_copy"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a13_copy"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a13_copy"):doByLastFrame( true, true ,function () 
		end)


		self.view[4]:setPosition(-17,13)
		local awarddata = self.reward[4]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[4])
		end

	end)
	self.lockAni:registerFrameEventCallFunc(parmes[5],1,function ()
		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a11_copy"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a11_copy"), "node1", self.view[5])  --替换
		self.lockAni:getBoneDisplay("a11_copy"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a11_copy"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a11_copy"):doByLastFrame( true, true ,function () 
		end)

		self.view[5]:setPosition(-17,13)
		local awarddata = self.reward[5]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[5])
		end
	end)
	-- self.lockAni:pause(true)
	-- self:delayCall(function ()
	-- 	-- self.lockAni:pause(true)
	-- end,1.0)
--]]

end
function NewLotteryJieGuoView:lotteryTen()
	local parmes = {
		[1] = 4,
		[2] = 7,
		[3] = 10,
		[4] = 13,
		[5] = 16,
		[6] = 19,
		[7] = 22,
		[8] = 25,
		[9] = 28,
		[10] = 31,
	}
	local  effectname = "UI_chouka_b_shilian"
	-- if self.lockAni == nil then
		self.lockAni= self:createUIArmature("UI_chouka_b",effectname, self.UI_1.ctn_1, false, function ()
			self.lockAni = nil
		end)
		self.lockAni:registerFrameEventCallFunc(37,1,function ()
			
			self:pressbtnclose()
		end)

		
		if tonumber(display.width) == 960 then
			self.lockAni:setScale(0.8)
			self.lockAni:setPosition(cc.p(self.lockAni:getPositionX(),self.lockAni:getPositionY()-50))
		end
		FuncArmature.setArmaturePlaySpeed(self.lockAni,0.7)
	-- end 
---[[
	self.lockAni:registerFrameEventCallFunc(parmes[1],1,function () --1
		-- self.view[1]:visible(true)
		-- self.lockAni:getBoneDisplay("a19"):registerFrameEventCallFunc(parmes[1],1,function ()
		-- 	FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a19"), "node1", self.view[1])  --替换
		-- end)
		-- -- FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a19"), "node1", self.view[1])  --替换
		-- self.lockAni:getBoneDisplay("a19"):doByLastFrame( true, true ,function () end)
		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a19"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a19"), "node1", self.view[1])  --替换
		self.lockAni:getBoneDisplay("a19"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a19"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a19"):doByLastFrame( true, true ,function () 
		end)




		self.view[1]:setPosition(-17,13)
		local awarddata = self.reward[1]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[1])
		end
	end)

	self.lockAni:registerFrameEventCallFunc(parmes[2],1,function () --2
		-- self.view[2]:visible(true)
		-- FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a17"), "node1", self.view[2])  --替换
		-- self.lockAni:getBoneDisplay("a17"):doByLastFrame( true, true ,function () end)

		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a17"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a17"), "node1", self.view[2])  --替换
		self.lockAni:getBoneDisplay("a17"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a17"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a17"):doByLastFrame( true, true ,function () 
		end)



		self.view[2]:setPosition(-17,13)
		local awarddata = self.reward[2]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[2])
		end
	end)

	self.lockAni:registerFrameEventCallFunc(parmes[3],1,function () --2
		-- self.view[3]:visible(true)
		-- FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a15"), "node1", self.view[3])  --替换
		-- self.lockAni:getBoneDisplay("a15"):doByLastFrame( true, true ,function () end)

		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a15"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a15"), "node1", self.view[3])  --替换
		self.lockAni:getBoneDisplay("a15"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a15"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a15"):doByLastFrame( true, true ,function () 
		end)


		self.view[3]:setPosition(-17,13)
		local awarddata = self.reward[3]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[3])
		end
	end)

	self.lockAni:registerFrameEventCallFunc(parmes[4],1,function () --2
		-- self.view[4]:visible(true)
		-- FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a13"), "node1", self.view[4])  --替换
		-- self.lockAni:getBoneDisplay("a13"):doByLastFrame( true, true ,function () end)
		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a13"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a13"), "node1", self.view[4])  --替换
		self.lockAni:getBoneDisplay("a13"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a13"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a13"):doByLastFrame( true, true ,function () 
		end)



		self.view[4]:setPosition(-17,13)
		local awarddata = self.reward[4]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[4])
		end
	end)
	self.lockAni:registerFrameEventCallFunc(parmes[5],1,function () --2
		-- self.view[5]:visible(true)
		-- FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a11"), "node1", self.view[5])  --替换
		-- self.lockAni:getBoneDisplay("a11"):doByLastFrame( true, true ,function () end)

		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a11"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a11"), "node1", self.view[5])  --替换
		self.lockAni:getBoneDisplay("a11"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a11"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a11"):doByLastFrame( true, true ,function () 
		end)



		self.view[5]:setPosition(-17,13)
		local awarddata = self.reward[5]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[5])
		end
	end)

	self.lockAni:registerFrameEventCallFunc(parmes[6],1,function () --2
		-- self.view[6]:visible(true)
		-- FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a9"), "node1", self.view[6])  --替换
		-- self.lockAni:getBoneDisplay("a9"):doByLastFrame( true, true ,function () end)
		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a9"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a9"), "node1", self.view[6])  --替换
		self.lockAni:getBoneDisplay("a9"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a9"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a9"):doByLastFrame( true, true ,function () 
		end)




		self.view[6]:setPosition(-17,13)
		local awarddata = self.reward[6]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[6])
		end
	end)
	self.lockAni:registerFrameEventCallFunc(parmes[7],1,function () --2
		-- self.view[7]:visible(true)
		-- FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a7"), "node1", self.view[7])  --替换
		-- self.lockAni:getBoneDisplay("a7"):doByLastFrame( true, true ,function () end)
		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a7"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a7"), "node1", self.view[7])  --替换
		self.lockAni:getBoneDisplay("a7"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a7"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a7"):doByLastFrame( true, true ,function () 
		end)




		self.view[7]:setPosition(-17,13)
		local awarddata = self.reward[7]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[7])
		end
	end)

	self.lockAni:registerFrameEventCallFunc(parmes[8],1,function () --2
		-- self.view[8]:visible(true)
		-- FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a5"), "node1", self.view[8])  --替换
		-- self.lockAni:getBoneDisplay("a5"):doByLastFrame( true, true ,function () end)

		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a5"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a5"), "node1", self.view[8])  --替换
		self.lockAni:getBoneDisplay("a5"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a5"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a5"):doByLastFrame( true, true ,function () 
		end)



		self.view[8]:setPosition(-17,13)
		local awarddata = self.reward[8]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[8])
		end
	end)
	self.lockAni:registerFrameEventCallFunc(parmes[9],1,function () --2
		-- self.view[9]:visible(true)
		-- FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a3"), "node1", self.view[9])  --替换
		-- self.lockAni:getBoneDisplay("a3"):doByLastFrame( true, true ,function () end)

		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a3"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a3"), "node1", self.view[9])  --替换
		self.lockAni:getBoneDisplay("a3"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a3"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a3"):doByLastFrame( true, true ,function () 
		end)




		self.view[9]:setPosition(-17,13)
		local awarddata = self.reward[9]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[9])
		end
	end)
	self.lockAni:registerFrameEventCallFunc(parmes[10],1,function () --2
		-- self.view[10]:visible(true)
		-- FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a1"), "node1", self.view[10])  --替换
		-- self.lockAni:getBoneDisplay("a1"):doByLastFrame( true, true ,function () end)

		self:ShowItemsAudio()
		self.lockAni:getBoneDisplay("a1"):getBone("node1"):visible(false)
		FuncArmature.changeBoneDisplay(self.lockAni:getBoneDisplay("a1"), "node1", self.view[10])  --替换
		self.lockAni:getBoneDisplay("a1"):registerFrameEventCallFunc(5,1,function ()
			self.lockAni:getBoneDisplay("a1"):getBone("node1"):visible(true)
		end)
		self.lockAni:getBoneDisplay("a1"):doByLastFrame( true, true ,function () 
		end)


		self.view[10]:setPosition(-17,13)
		local awarddata = self.reward[10]
		local rewardtype =  tonumber(awarddata[1])
		local rewardID = tonumber(awarddata[2])
		if rewardtype == 18 then
			--跳到卡牌界面
			self.lockAni:pause(true)
			WindowControler:showWindow("NewLotteryJieGuoCradView",self.reward[10])
		end
	end)


---]]

end

return NewLotteryJieGuoView
