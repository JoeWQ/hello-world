--三皇抽奖系统
--2016-12-27 10:40
--@Author:wukai

local NewLotteryShopView = class("NewLotteryShopView", UIBase);

function NewLotteryShopView:ctor(winName)
    NewLotteryShopView.super.ctor(self, winName);
end

function NewLotteryShopView:loadUIComplete()
	-- 适配
	FuncCommUI.setViewAlign(self.btn_back,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.UI_1,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.panel_icon,UIAlignTypes.LeftTop)
    FuncCommUI.setScale9Align(self.scale9_resdi,UIAlignTypes.MiddleTop,1,0)
    FuncCommUI.setViewAlign(self.UI_shop_btn1,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.UI_shop_btn2,UIAlignTypes.LeftTop)


    self.btn_back:setTap(c_func(self.press_btn_close,self))
    self.btn_refresh:setTap(c_func(self.refreshButton,self))

	self.UI_shop_btn1.mc_1.currentView.btn_1:setTap(c_func(self.buttonPartner,self))
	self.UI_shop_btn2.mc_1.currentView.btn_1:setTap(c_func(self.buttonpasurate,self))

-- self.UI_shop_btn1:visible(false)

	self:initData()
	self:defaultshowbutton()
	self:refreshbuttonInfo()
	self:addEventListeners()

end 
function NewLotteryShopView:initData()

	--从服务器获得数据
	self.partnerdata = {} --伙伴数据
	self.treasuredata = {} --法宝数据
	local partnerdatas = ShopModel:getShopItemList(FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP)
	local treasuredata = nil 
	local level = FuncNewLottery.getawardLevelopenfree()
	if UserModel:level() >= level then
		treasuredata = ShopModel:getShopItemList(FuncShop.SHOP_TYPES.LOTTER_MAGIC_SHOP)
	end
	for k,v in pairs(partnerdatas) do
		self.partnerdata[k] = FuncNewLottery.getpartnerdata(tonumber(v.id))
	end
	if treasuredata ~= nil then
		for k,v in pairs(treasuredata) do
			self.treasuredata[k] = FuncNewLottery.getTreasuredata(tonumber(v.id))
		end
	end
	

end

function NewLotteryShopView:defaultshowbutton()

	self.UI_shop_btn1.mc_1:getViewByFrame(1).panel_1:visible(false)
	self.UI_shop_btn1.mc_1:getViewByFrame(2).panel_1:visible(false)
	self.UI_shop_btn1.mc_1:showFrame(2)
	local level = FuncNewLottery.getawardLevelopenfree()
	if UserModel:level()  >= level then
		self.UI_shop_btn2.mc_1:getViewByFrame(1).panel_1:visible(false)
		self.UI_shop_btn2.mc_1:getViewByFrame(2).panel_1:visible(false)
	else
		self.UI_shop_btn2:visible(false)
	end
	FuncNewLottery.setTouchawardtype(1)
	self:addscollelist(self.partnerdata)
	

	
end

function NewLotteryShopView:addEventListeners()
    EventControler:addEventListener(NewLotteryEvent.DELETE_LITTERY_LAYER,self.refreshMianUI,self)
    -- EventControler:addEventListener(NewLotteryEvent.REFRESH_LOTTERY_SHOP_UI, self.refreshbuttonInfo, self)
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.refreshbuttonInfo, self)
end
function NewLotteryShopView:refreshMianUI()
	self:press_btn_close()
	EventControler:dispatchEvent(NewLotteryEvent.REFRESH_MAIN_UI)
end

function NewLotteryShopView:refreshbuttonInfo()
	-- self.panel_50.txt_1:setString("100")

	local refreshitem = NewLotteryModel:getshopRefreshcard() --刷新符
	if refreshitem ~= 0 then
		self.mc_cost:showFrame(2)
		self.mc_cost:getViewByFrame(2).txt_1:setString(refreshitem.."/1")  ---消耗刷新符
	else
		self.mc_cost:showFrame(1)
		local coinnumber = UserModel:getCoin()
		local number = FuncNewLottery.getlotteryShoprefreshitems()
		-- echo("======number=========",coinnumber)
		if coinnumber >= number then
			self.mc_cost:getViewByFrame(1).panel_50.txt_1:setColor(self:HEXtoC3b("0xfff5e6"))
		else
			self.mc_cost:getViewByFrame(1).panel_50.txt_1:setColor(cc.c3b(255,0, 0))
		end
		self.mc_cost:getViewByFrame(1).panel_50.txt_1:setString(number) --消耗铜钱
	end
end
function NewLotteryShopView:HEXtoC3b(hex)
    local flag = string.lower(string.sub(hex,1,2))
    local len = string.len(hex)
    if len~=8 then
        print("hex is invalid")
        return nil 
    end
    if flag ~= "0x" then
        print("not is a hex")
        return nil
    end
    local rStr =  string.format("%d","0x"..string.sub(hex,3,4))
    local gStr =  string.format("%d","0x"..string.sub(hex,5,6))
    local bStr =  string.format("%d","0x"..string.sub(hex,7,8))

    -- local ten = string.format("%d",hex)
    ten = cc.c3b(rStr,gStr,bStr)
    return ten
end




function NewLotteryShopView:addscollelist(data)
		if data == nil then
			return
		end
		self.data = data
 		 self.panel_1:visible(false)
		local rewardArray =  {} --{{1},{2},{3},{4},{5},{6}}
		-- dump(data,"商店数据")
		for k,v in pairs(self.data) do
			k = tonumber(k) 
			rewardArray[k] = {}
			rewardArray[k][1] = v.award[1]
			rewardArray[k][2] = v.cost
			rewardArray[k][3] = tonumber(k)
		end
		-- dump(rewardArray)
		local createFunc_shop = function (itemdata)
			local itemView = UIBaseDef:cloneOneView( self.panel_1 )
			self:updateItem(itemView, itemdata)
			return itemView
		end
		local updateFunc_shop = function (itemdata,view,index)
			if self._is_refresh_show then
				self:updateItem(view,rewardArray[index])
			end
		end

		local newparams = {
			{
				data = rewardArray,
				createFunc = createFunc_shop,
				updateCellFunc = updateFunc_shop,
				perNums=3,
				offsetX = -15,
				offsetY =0,
				itemRect = {x=0,y=-201,width=250,height = 201},
				perFrame =0,
				heightGap = 0
			}
		}
		self.scroll_list:styleFill(newparams)
		self.scroll_list:setCanScroll(false)
end
function NewLotteryShopView:dataTolabel(itemdata)
	if itemdata == nil then
		echo("替换池物品不存在")
		return
	end
	local itemdata = itemdata[1]
	local data = {}
	data.shopreward = itemdata
	return data
end
	
function NewLotteryShopView:updateItem( View,itemData )
	   -- self.mc_zao2:getViewByFrame(1).mc_1:showFrame(3)
	
	-- local quality = 1
	-- local reward = string.split(itemData[1], ",")
	-- if tonumber(reward[2]) == 5009 then
	-- 	itemData[1] = "10,509,1"
	-- end

	View.scale9_1:visible(false)
	View.panel_tihuan:visible(false)
	local reward = string.split(itemData[1], ",")
	local rewardType = tonumber(reward[1])
	local rewardNum = itemData[2]
	local rewardId  = reward[2]
	local  lotteryRewardView1 = View.UI_1
    lotteryRewardView1:setResItemData({reward = itemData[1]})
    --setResItemData({itemId = rewardId ,itemNum = rewardNum})
	lotteryRewardView1:showResItemName(false)
	-- lotteryRewardView1:showResItemNum(false)
	local name = nil
	local itemDatas = nil
	local quality = nil
	if rewardType == 1 then
		itemDatas = FuncItem.getItemData(rewardId)
		name = GameConfig.getLanguage(itemDatas.name)
		quality = itemDatas.quality
	elseif rewardType == 10 then
		itemDatas = FuncTreasure.getTreasureAllConfig()[tostring(rewardId)]

		name = GameConfig.getLanguage(itemDatas.name)
		quality = itemDatas.quality
	elseif rewardType == 18 then
		itemDatas = FuncPartner.getPartnerById(rewardId)
		name = GameConfig.getLanguage(itemDatas.name)
		quality = itemDatas.initQuality
	end
		-- echo("=====================",name)
	local number = UserModel:goldConsumeCoin()
	if number >= rewardNum then
		View.txt_1:setColor(self:HEXtoC3b("0xfff5e6"))
	else
		View.txt_1:setColor(cc.c3b(255,0, 0))
	end
	View.mc_color:showFrame(quality)
	View.mc_color:getViewByFrame(quality).txt_1:setString(name) --品质and名称


	View.txt_1:setString(rewardNum)

	local SelectType =  FuncNewLottery.getTouchawardtype()
	local shopdata = ShopModel:getShopItemList(SelectType)
	-- dump(shopdata)
	-- echo("===================SelectType============tonumber(itemData[3])==============",SelectType,tonumber(itemData[3]))
		if shopdata[tonumber(itemData[3])].buyTimes ~= 0 then
			View.scale9_1:visible(true)
			View.panel_tihuan:visible(true)
		else
			View.scale9_1:visible(false)
			View.panel_tihuan:visible(false)
		end
	local beginFunc  = function ()
			-- echo("对应的数")
			--给服务器数值
			local SelectType =  FuncNewLottery.getTouchawardtype()
			local shopdata = ShopModel:getShopItemList(SelectType)
			-- dump(shopdata,"奖池数据")
			if shopdata[tonumber(itemData[3])].buyTimes == 0 then
				local replacefile,data = self:getlowqualityobject()
				if replacefile == false then
					WindowControler:showTips("当前奖池都是稀有奖励，不需替换")
				else
					NewLotteryModel:setrepleacedata(data)
					NewLotteryModel:settouchreplacedata(itemData)
			   		WindowControler:showWindow("NewLotteryreplaceView")
				end
			else
				WindowControler:showTips("该物品已替换")
			end
	end
	View:setTouchedFunc(beginFunc,nil,false,nil,nil)


end

--替换规则
function NewLotteryShopView:getlowqualityobject()
		local SelectType =  FuncNewLottery.getTouchawardtype()
		local data = NewLotteryModel:getRMBData()
		
		-- dump(data,"奖池数据")


		local jingpingzhi = 0
		local replacenumber = 0
		for k,v in pairs(data) do
			if v.lotteryId ~= nil then
				local LotteryData = FuncNewLottery.getIDLotteryData(v.lotteryId)
				local quality = tonumber(LotteryData.quality)
				if quality == tonumber(FuncNewLottery.rewardquality.gold) then
					jingpingzhi = jingpingzhi + 1
				end
			else
				replacenumber = replacenumber + 1
			end
		end

		if jingpingzhi == 6 then
			return false,nil
		else
			if jingpingzhi + replacenumber == 6 then
				return false,nil
			elseif jingpingzhi + replacenumber < 6 then
				if SelectType == FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP then --伙伴
						-- local partnerdata =  ShopModel:getShopItemList(FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP)
						-- 伙伴2（序列）→材料1→法宝3→通用4
						local _newquality = nil
						local replecssedata = nil
						local typepaixu = nil
						for k,v in pairs(data) do
							if v.lotteryId ~= nil then
								local lotteryquality  = tonumber(FuncNewLottery.getIDLotteryData(v.lotteryId).quality)
								local lotterytype = tonumber(FuncNewLottery.getIDLotteryData(v.lotteryId).type)
								if _newquality == nil then
									_newquality = lotteryquality
									replecssedata = v
									typepaixu = lotterytype
								else
									if  lotteryquality < _newquality then
										_newquality = lotteryquality
										typepaixu = lotterytype
										replecssedata = v
									elseif lotteryquality > _newquality then


									elseif lotteryquality == _newquality then   --相同品质
										if lotterytype == 2 then --通用
											replecssedata = v
											typepaixu = lotterytype
										elseif lotterytype == 1 then
											if typepaixu == 2 then
											else
												typepaixu = lotterytype
												replecssedata = v
											end
										elseif lotterytype == 3 then
											if typepaixu == 2 then
											else
												if typepaixu == 1 then
												else
													typepaixu = lotterytype
													replecssedata = v
												end
											end
										elseif lotterytype == 2 then
											if typepaixu == 2 then
											else
												if typepaixu == 1 then
												else
													if typepaixu == 3 then
													else
														typepaixu = lotterytype
														replecssedata = v
													end
												end
											end
										end
									end
								end
							end
						end
						return true,replecssedata
				elseif SelectType == FuncShop.SHOP_TYPES.LOTTER_MAGIC_SHOP then  --法宝
						-- local magicdata = ShopModel:getShopItemList(FuncShop.SHOP_TYPES.LOTTER_MAGIC_SHOP)
						-- 法宝3→材料1→伙伴2→通用4
						local _newquality = nil
						local replecssedata = nil
						local typepaixu = nil
						for k,v in pairs(data) do
							if v.lotteryId ~= nil then
								local lotteryquality  = tonumber(FuncNewLottery.getIDLotteryData(v.lotteryId).quality)
								local lotterytype = tonumber(FuncNewLottery.getIDLotteryData(v.lotteryId).type)
								if _newquality == nil then
									_newquality = lotteryquality
									replecssedata = v
									typepaixu = lotterytype
								else
									if lotteryquality < _newquality then
										_newquality = lotteryquality
										typepaixu = lotterytype
										replecssedata = v
									elseif lotteryquality == _newquality then   --相同品质
										if lotterytype == 3 then
											typepaixu = lotterytype
											replecssedata = v
										elseif lotterytype == 1 then
											if typepaixu == 3 then
											else
												typepaixu = lotterytype
												replecssedata = v
											end
										elseif lotterytype == 2 then
											if typepaixu == 3 then
											else
												if typepaixu == 1 then
												else
													typepaixu = lotterytype
													replecssedata = v
												end
											end 
										elseif lotterytype == 3 then
											if typepaixu == 4 then
											else
												if typepaixu == 1 then
												else
													if typepaixu == 2 then
													else
														typepaixu = lotterytype
														replecssedata = v
													end
												end
											end
										end
									end
								end
							end
						end
						return true,replecssedata
				end
			end
		end
end

--伙伴
function NewLotteryShopView:buttonPartner()
	self._is_refresh_show = true
	self.UI_shop_btn1.mc_1:showFrame(2)
	self.UI_shop_btn2.mc_1:showFrame(1)
	self.UI_shop_btn1.mc_1:getViewByFrame(1).panel_1:visible(false)
	self.UI_shop_btn1.mc_1:getViewByFrame(2).panel_1:visible(false)
	FuncNewLottery.setTouchawardtype(1)
	self:addscollelist(self.partnerdata)
	self:refreshbuttonInfo()
	--伙伴

end
--法宝
function NewLotteryShopView:buttonpasurate()
	local level = FuncNewLottery.getawardLevelopenfree()
	if UserModel:level()  >= level then
		self._is_refresh_show = true
		self.UI_shop_btn2.mc_1:showFrame(2)
		self.UI_shop_btn1.mc_1:showFrame(1)
		FuncNewLottery.setTouchawardtype(2)
		self:addscollelist(self.treasuredata)
		self:refreshbuttonInfo()
		--法宝
	end
end


function NewLotteryShopView:refreshButton()
	local coinnumber = UserModel:getCoin()
	local number = FuncNewLottery.getlotteryShoprefreshitems()
	if coinnumber >= number then
		local shoptype = FuncNewLottery.getTouchawardtype()
		NewLotteryServer:Refreshbutton(shoptype,c_func(self.refreshUI, self))
	else
		WindowControler:showTips("金币不足")
	end
end
function NewLotteryShopView:refreshUI(result)
	-- dump(result,"刷新返回数据")
	if not result.result then
		return
	end
	--TODO
	local shopdata = result.result.data.dirtyList.u.shops
	if shopdata ~= nil then

		local shoptype = FuncNewLottery.getTouchawardtype()
		local goodsList = shopdata[tostring(shoptype)].goodsList
		
		if shoptype == FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP then
			self.partnerdata = {}
			for k,v in pairs(goodsList) do
				self.partnerdata[k] = FuncNewLottery.getpartnerdata(tonumber(v.id))
			end
		else
			self.treasuredata = {}
			for k,v in pairs(goodsList) do
				self.treasuredata[k] = FuncNewLottery.getTreasuredata(tonumber(v.id))
			end
		end

	end
	-- dump(self.partnerdata)
	WindowControler:showTips("刷新成功")
	self._is_refresh_show = true
	self:updataUI()
end

function NewLotteryShopView:updataUI()

	local shoptype = FuncNewLottery.getTouchawardtype()
	-- echo("=============shoptype==========",shoptype)
	if shoptype== FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP then
		self:addscollelist(self.partnerdata)
	elseif shoptype ==  FuncShop.SHOP_TYPES.LOTTER_MAGIC_SHOP then
		self:addscollelist(self.treasuredata)
	end
	self:refreshbuttonInfo()
end
function NewLotteryShopView:press_btn_close()
    self:startHide()
end



return NewLotteryShopView
--[[
unction 'call'
 "刷新返回数据" = {
     "id"     = 2000003
     "method" = 1604
     "result" = {
         "data" = {
             "dirtyList" = {
                 "u" = {
                     "_id"     = "dev_7006"
                     "counts" = {
                         "36" = {
                             "count"      = 1
                             "expireTime" = 1483732800
                             "id"         = "36"
                         }
                     }
                     "finance" = {
                         "coin" = 60000
                     }
                     "shops" = {
                         "7" = {
                             "goodsList" = {
                                 1 = {
                                     "id" = "6"
                                 }
                                 2 = {
                                     "id" = "2"
                                 }
                                 3 = {
                                     "id" = "6"
                                 }
                                 4 = {
                                     "id" = "14"
                                 }
                                 5 = {
                                     "id" = "14"
                                 }
                                 6 = {
                                     "id" = "7"
                                 }
                             }
                             "lastFlushTime" = 1483702937
                         }
                     }
                 }
             }
         }
         "serverInfo" = {
             "serverTime" = 1483702937482
         }
     }
 }
 --]]