--三皇抽奖系统
--2016-12-27 10:40
--@Author:wukai

local NewLotteryreplaceView = class("NewLotteryreplaceView", UIBase);

function NewLotteryreplaceView:ctor(winName)
    NewLotteryreplaceView.super.ctor(self, winName);
end

function NewLotteryreplaceView:loadUIComplete()
	
    self.btn_close:setTap(c_func(self.press_btn_close,self))
    self.mc_3:getViewByFrame(1).btn_1:setTap(c_func(self.Confirmbutton,self))
    self.mc_3:getViewByFrame(1).btn_1:getUpPanel().txt_1:setString("替换")
    self:initData()
    self:exchangshowUI()

    self:registClickClose(nil, function ()
        self:press_btn_close()
    end);


end 


function NewLotteryreplaceView:initData()





        self.repleacedata = NewLotteryModel:getrepleacedata()
        -- dump(self.repleacedata,'替换数据')
        -- dump(FuncNewLottery.getIDLotteryData(self.repleacedata.lotteryId))
        local qualityobject = 1
        local quality = 1
        if self.repleacedata.lotteryId ~= nil then
            qualityobject = FuncNewLottery.getIDLotteryData(self.repleacedata.lotteryId).type
            quality = FuncNewLottery.getIDLotteryData(self.repleacedata.lotteryId).quality
        else

            -- qualityobject = FuncItem.getItemData(string.split(self.repleacedata.reward, ",")[2]).type
            local reward = string.split(self.repleacedata.reward, ",")[2]
            if reward[1] == 1 then  --item
                qualityobject = 1
            elseif reward[1] == 10 then  --法宝
                qualityobject = 3
            elseif  reward[1] == 18 then  --伙伴
                qualityobject = 2
            end
        end

		self.intemData = NewLotteryModel:gettouchreplacedata()
        -- dump(self.intemData)
		local reward = string.split(self.intemData[1], ",")
		local rewardType = reward[1]
		local rewardNum = reward[3]
		local rewardId = reward[2]
        self:setCommonUIData(self.intemData[1])
		self:getitempyte(tonumber(rewardType),rewardId,rewardNum)
		self.mc_1:showFrame(tonumber(qualityobject))
        self.mc_1:getViewByFrame(tonumber(qualityobject)).mc_1:showFrame(tonumber(quality))

        

end
function NewLotteryreplaceView:setCommonUIData(reward)

    self.UI_1:setResItemData({reward = reward})
    self.UI_1:showResItemName(true)

    
end
function NewLotteryreplaceView:getitempyte(rewardType,itemId,rewardNum)

	local itemData = FuncItem.getItemData(itemId)
    self.itemType = itemData.type
    self.itemSubType = itemData.subType or 0
    	if itemId ~= nil then
            local itemType = self.itemType
            -- 如果是碎片
            if itemType ~= nil and tonumber(itemType) == ItemsModel.itemType.ITEM_TYPE_PIECE then
                if self.itemSubType == 202 then -- 伙伴碎片
                    itemIcon = display.newSprite(FuncRes.iconHero(FuncItem.getItemData(itemId).icon)):anchor(0.5,0.5)
                    itemIcon:setScale(0.8)
                else
                    itemIcon = display.newSprite(FuncRes.iconTreasure(itemId)):anchor(0.5,0.5)
                    itemIcon:setScale(0.44)
                end

                -- 碎片资质
                
                -- qualityMc = self.panelInfo.mc_2
            else
                itemIcon = display.newSprite(FuncRes.iconItem(itemId)):anchor(0.5,0.5)
                itemIcon:setScale(0.7)

                -- 道具边框颜色
                -- quality = FuncItem.getItemQuality(itemId)
                -- qualityMc = self.panelInfo.mc_kuang
            end
        end 
        if rewardType == 1  then
            itemName = FuncItem.getItemName(itemId)
            quality = FuncItem.getItemQuality(itemId)
        elseif rewardType == 10 then
            quality = FuncTreasure.getValueByKeyTD(itemId,"quality")
            itemName = FuncTreasure.getValueByKeyTD(itemId,"name")
            itemName = GameConfig.getLanguage(itemName)
        elseif rewardType == 18 then
            quality = FuncPartner.getPartnerById(itemId).initQuality
            itemName = FuncPartner.getPartnerById(itemId).name
            itemName = GameConfig.getLanguage(itemName)
            itemIcon = display.newSprite(FuncRes.iconHero(FuncPartner.getPartnerById(itemId).icon)):anchor(0.5,0.5)
            itemIcon:setScale(0.8)
        end

    -- 道具icon
    -- local iconCtn = self.mc_2:getViewByFrame(quality).ctn_1
    -- iconCtn:removeAllChildren()
    -- iconCtn:addChild(itemIcon)

    -- 道具数量
    if tonumber(rewardNum) > 9999 then
        itemNum = 9999
    end


    -- 不带数量的名称
    self.itemNameWithNotNum = itemName
    -- 带数量的名称
    -- self.itemNameWithNum = GameConfig.getLanguage(self.itemNameWithNotNum)--"tid_common_1018",itemName,rewardNum)
    
    -- local itemName = GameConfig.getLanguage(itemName)
    local nameTxt = self.UI_1.panelInfo.mc_zi.currentView.txt_1
    nameTxt:setString(itemName)


	-- self.mc_2:showFrame(quality)
	-- local addchilednode = self.mc_2:getViewByFrame(quality).ctn_1
	
 --    self.mc_10:showFrame(quality)
	-- self.mc_10:getViewByFrame(quality).txt_1:setString(self.itemNameWithNotNum)

    self.txt_3:setString(self.itemNameWithNotNum)
    -- lotteryRewardView1:setResItemData({reward = itemData[1]})

end


function NewLotteryreplaceView:exchangshowUI()
--     FuncNewLottery.getpartnerdata()
--     FuncNewLottery.getTreasuredata()
	self.txt_4:setString(self.intemData[2])  --造物符的数量
end


function NewLotteryreplaceView:Confirmbutton()

    local refreshcradle =  UserModel:goldConsumeCoin()

    -- echo("=======refreshcradle========",refreshcradle)

    -- local cost = nil
    -- dump(refreshcradle)
    if refreshcradle ~= nil then
        if refreshcradle >  self.intemData[2] then
        	local shopType = FuncNewLottery.getTouchawardtype()
        	local shopIndex = self.intemData[3]
        	local replaceLotteryIndex = self.repleacedata.id  --TODO
            -- echo("===shopType===shopIndex============",shopType,shopIndex,replaceLotteryIndex)
        	NewLotteryServer:requestpoolCombineData( shopType ,shopIndex,replaceLotteryIndex,c_func(self.requesResult,self))
        else
            WindowControler:showTips("三皇符不足")
        end
    else
        WindowControler:showTips("三皇符不足")
    end

end 
function NewLotteryreplaceView:requesResult(result)
	-- dump(result,'替换结果')
    local index = nil
    local tihuangdata = result.result.data.dirtyList.u.lotteryGoldPools
    for k,v in pairs(tihuangdata) do
        index = k
    end
    if index == nil then
        index = 1
    end
    FuncNewLottery.tihuangIndex(tonumber(index))
    WindowControler:showTips("替换成功")
    self:press_btn_close()
    EventControler:dispatchEvent(NewLotteryEvent.DELETE_LITTERY_LAYER)
    
end

function NewLotteryreplaceView:press_btn_close()
    self:startHide()
end



return NewLotteryreplaceView
--[[
data: {
    d: {
        lotteryGoldPools: {
            5: {
                lotteryId: 1
            }
        },
        _id: "dev_7016"
    },
    u: {
        goldConsumeCoin: 99500,
        shops: {
            7: {
                goodsList: {
                    2: {
                        buyTimes: 1
                    }
                }
            }
        },
        lotteryGoldPools: {
            5: {
                reward: "1,5005,1"
            }
        },
        _id: "dev_7016"
    }
}
]]