local RechargeModel = class("RechargeModel")

function RechargeModel:init()

end

function RechargeModel:isFirstBuy(buyId)
	local info = UserModel:buyProductTimes();
	return info[buyId] == nil and true or false;
end

return RechargeModel;
