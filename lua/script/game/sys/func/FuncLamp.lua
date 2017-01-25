--//跑马灯
--//2016-6-14 16:32:42
--//小花熊
FuncLamp=FuncLamp or {};

local    lampTable=nil;
function FuncLamp.init()
     lampTable=require("lantern.Lantern");
end
function FuncLamp.getLamp()
    return  lampTable;
end