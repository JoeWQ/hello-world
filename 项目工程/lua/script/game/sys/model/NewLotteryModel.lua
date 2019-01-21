--三皇抽奖系统
--2016-12-27 10:40
--@Author:wukai



local NewLotteryModel = class("NewLotteryModel",BaseModel);

function NewLotteryModel:ctor()

end
--[[
{
	goldTimes = 1, 元宝抽卡次数
	goldLuckyCost = 1,元宝幸运值
	superPartnerTimes = 1,抽到金品伙伴次数
	superTreasureTimes = 1,-抽到法宝次数
	
	"抽奖系统数据2" = {
	    "1" = 9101
	    "2" = 9102
	    "3" = 9103
	    "4" = 9104
	    "5" = 9105
	    "6" = 9106
	}
	 "抽奖系统数据3" = {
     "1" = {
         "id"        = 1
         "lotteryId" = 9107
     }
     "2" = {
         "id"        = 2
         "lotteryId" = 9108
     }
     "3" = {
         "id"        = 3
         "lotteryId" = 9109
     }
     "4" = {
         "id"        = 4
         "lotteryId" = 9110
     }
     "5" = {
         "id"        = 5
         "lotteryId" = 9111
     }
     "6" = {
         "id"        = 6
         "lotteryId" = 9112
     }
 }
}
]]
function NewLotteryModel:init(data,freedatas,RMBdatas)

    NewLotteryModel.super.init(self, data);
    self.initDatas = data
    self.freedata = freedatas
    self.RMBdata = RMBdatas
    self.endtime = 0
    -- dump(self.initDatas,"数据")  --nextTreasureFlag 
    -- dump(self.RMBdata,"元宝数据")
end
function NewLotteryModel:updateData(data)
	NewLotteryModel.super.updateData(self, data);
    -- self.initDatas = nil
    self.initDatas.commonTimes = data.commonTimes
    self.initDatas.goldTimes = data.goldTimes
    if data.nextTreasureFlag ~= nil then
    	self.initDatas.nextTreasureFlag = data.nextTreasureFlag
    end

    
end
function NewLotteryModel:getnextTreasureFlag()
	-- dump(self.initDatas)
	return self.initDatas.nextTreasureFlag
end
function NewLotteryModel:FreeCounts()
	if self.initDatas.commonTimes == nil then
		self.initDatas.commonTimes = 0
	end
	return tonumber(self.initDatas.commonTimes)

end
function NewLotteryModel:RMBcounts()
	if self.initDatas.goldTimes == nil then
		self.initDatas.goldTimes = 0
	end
	return tonumber(self.initDatas.goldTimes)
end
--获得免费抽奖池type数据
function NewLotteryModel:getfreeawardpool()
	-- dump(self.freedata,"免费数据")
	local freedata = {}
	for k,v in pairs(self.freedata) do
		freedata[tonumber(k)] = {}
		freedata[tonumber(k)].type = tonumber(FuncNewLottery.getIDLotteryData(v).type)
		freedata[tonumber(k)].quality = tonumber(FuncNewLottery.getIDLotteryData(v).quality)
		freedata[tonumber(k)].lotteryId =  v
	end
	-- dump(freedata,"免费数据")
	return freedata
end
--设置免费抽奖数据
function NewLotteryModel:setfreeawardpool(goodlist)
	self.freedata = goodlist
end
--获得消耗元宝抽奖奖池数据
function NewLotteryModel:getRMBawardpool()
	local consumedata = {}
	-- dump(self.RMBdata,"元宝数据")
	if self.RMBdata ~= nil then
		for k,v in pairs(self.RMBdata) do
			local id = nil 
			local award = v.reward
			if award ~= nil then
				local reward = string.split(v.reward, ",")
				id = reward[2]
				consumedata[tonumber(k)] = v.reward--tonumber(reward[1])
			else
				id = v.lotteryId
				consumedata[tonumber(k)] = {}
				consumedata[tonumber(k)].type = tonumber(FuncNewLottery.getIDLotteryData(id).type)
				consumedata[tonumber(k)].quality = tonumber(FuncNewLottery.getIDLotteryData(id).quality)
				consumedata[tonumber(k)].lotteryId =  v.lotteryId
			end
		end
		-- dump(consumedata,"元宝数据")
		return consumedata
	end
end


--设置元宝抽奖数据
function NewLotteryModel:setRMBawardpool(goodlist)
	self.RMBdata = goodlist
end
-- function function_name( ... )
-- 	-- body
-- end


function NewLotteryModel:getfreeData()
	return self.freedata
end
function NewLotteryModel:getRMBData()
	return self.RMBdata
end


--获得免费抽奖次数
function NewLotteryModel:getLotterynumber()
	return CountModel:getLotteryfreeCount()
end
--获得RMB免费单抽奖次数
function NewLotteryModel:getRMBoneLottery()
	return CountModel:getLotteryGoldFreeCount()
end
--获得RMB单抽奖次数
function NewLotteryModel:getRMBPayLottery()
	return CountModel:getLotteryGoldPayCount()
end

--免费抽奖CD
function NewLotteryModel:getCDtime()
	self.endtime = CdModel:getCdExpireTimeById(1)
	-- echo("========self.endtime====",self.endtime)
	if self.endtime ~= 0 then
		-- echo("=========TimeControler=========",TimeControler:getServerTime())
		if self.endtime - TimeControler:getServerTime() < 0 then
			return 0
		else
			return self.endtime - TimeControler:getServerTime()
		end
	else
		return 0
	end
end
function NewLotteryModel:setCDStime(starttime,endtime)
	if starttime ~= nil then
		self.starttime = starttime  --结束时间
	end
	if endtime ~= nil then
		self.endtime = endtime
	end
end

--获得免费普通抽卡卷
function NewLotteryModel:getordinaryDrawcard()
	local itemid = FuncNewLottery:getOrdninaryID()
	local number = ItemsModel:getItemNumById(tostring(itemid))
	-- echo("=========itemid======ordinarynumber=======",itemid,number)
	return  number
end
--获得高级抽卡卷
function NewLotteryModel:getseniorDrawcard()
	local itemid = FuncNewLottery:getSeniorcardID()
	local number = ItemsModel:getItemNumById(tostring(itemid))
	-- echo("=========itemid======seniorDrawcard=======",itemid,number)
	return number
end
--获得刷新令
function NewLotteryModel:getshopRefreshcard()
	return UserModel:getShopToken() or 0
end
--判断免费是否可以抽卡--(1,2,3表示错误ID在func里面)
function NewLotteryModel:FreeCanlottery()
	local items = FuncNewLottery.getlotteryFreeType()   -- 1 ，5  
	local ordinarycard = NewLotteryModel:getordinaryDrawcard()
	local time = NewLotteryModel:getCDtime()

	if items == 1 then --一次
		if time ~= 0 then
			if ordinarycard > 0 then
				return true,2   --2 
			
			else
				return false,1   --1 时间CD
			end
		else
			local loterynumber = CountModel:getLotteryfreeCount()
			if loterynumber >= FuncNewLottery.getFreecardnumber() then
				if ordinarycard > 0 then
					return true,2
				else
					return false,2
				end
			else
				return true,2

			end
		end
	else   --五次
		if ordinarycard >= tonumber(items) then
			return true,2
		else
			return false,2
		end
	end
end
--判断元宝是否可以抽卡  ---(1,2,3表示错误ID在func里面)
function NewLotteryModel:RMBCanlottery()
	local items = FuncNewLottery.getlotteryRMBType()
	local freelotteryitems = CountModel:getLotteryGoldFreeCount() 
	local paylotteryitems  = CountModel:getLotteryGoldPayCount()
	local gaojicard = NewLotteryModel:getseniorDrawcard()
	local rmb =	UserModel:getGold() 
	if items == 1 then 
		if freelotteryitems ~= 0 then
			if gaojicard > 0 then
				return true,2
			else
				if paylotteryitems > 0 then
					if rmb > FuncNewLottery.consumeOnceRMB() then
				 		return true,3
				 	else
				 		return false,3
				 	end
				else
					if rmb > FuncNewLottery.consumeOnceRMB()/2 then
				 		return true,3
				 	else
				 		return false,3
				 	end
				end
			 	
			end
		else
			return true,1
		end
	else
		if gaojicard >= 10 then
			return true,2
		else
			if rmb >= FuncNewLottery.consumeTenRMB() then
				return true,3
			else
				return false,3
			end
		end
	end
end
function NewLotteryModel:setrepleacedata(data)
	self.repleacedata = data
end
function NewLotteryModel:getrepleacedata()
	return self.repleacedata
end

function NewLotteryModel:settouchreplacedata(itemdata)
	self.replaceitemdata = itemdata
end
function NewLotteryModel:gettouchreplacedata()
	return self.replaceitemdata
end
function NewLotteryModel:setServerData(reward)
	self.serverdata = reward
end
function NewLotteryModel:getServerData()
	return self.serverdata 
end
--替换数据刷新(单抽的时候)
function NewLotteryModel:settihuangAward(serverdata,tihuangID)
		-- serverdata = {
		-- 	"6" =  {
		-- 	    "lotteryId" = 1402
		-- 	}
		-- }
		-- dump(serverdata)
		-- echo("=========self.tihuangID===========",self.tihuangID)
		self.tihuangID = tihuangID
		self.quality = 1
		local lotterytype =  FuncNewLottery.getlotterytype()
		if serverdata ~= nil then
			if lotterytype == 1 then   --免费抽
					-- self.freedata
				for k,v in pairs(serverdata) do
					self.freedata[k] = v
					self.quality = FuncNewLottery.getIDLotteryData(v).quality
				end
			else    --花钱抽
				-- self.RMBdata
				for k,v in pairs(serverdata) do
					self.RMBdata[k].lotteryId = v.lotteryId
					self.quality = FuncNewLottery.getIDLotteryData(v.lotteryId).quality
				end
			end

		end

end
function NewLotteryModel:getihuangIndex( )
	return self.tihuangID,tonumber(self.quality)
end

return NewLotteryModel





















