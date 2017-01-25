--
-- Author: zq
-- Date: 2016-08-15 20:02:07
--

FuncHappySign = FuncHappySign or {}
local happySignData = nil

function FuncHappySign.init(  )
	happySignData = require("happySign.HappySign")
end

function FuncHappySign.getItemDataById(_id)
    local itemData = happySignData[tostring(_id)];
    if itemData then
       return itemData
    end

    echoWarn("happySign.happySign cannot find id = ".._id)
    return nil;
end

function FuncHappySign.getHappySignData()
    return happySignData;
end








