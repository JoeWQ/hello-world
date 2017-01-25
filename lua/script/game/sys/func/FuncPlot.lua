
FuncPlot = {}
local plotCfg = nil
local plotID = 1



function FuncPlot.init(  )
   plotCfg= require("plot.Plot") 
end 

function FuncPlot.getPlotData( )
   local _ps = plotCfg
 return plotCfg[tostring(FuncPlot.plotID)]
end 

function FuncPlot.setPlotID( id )
  FuncPlot.plotID = id
end  
function FuncPlot.getPlotID( )
 return plotID
end  

function FuncPlot.getStepPlotData( id )
   local datga = FuncPlot.getPlotData()
   if(datga==nil)then
             echoError("剧情对话配置FuncPlot.plotID: ",FuncPlot.plotID,"  没有找到","当前索引的id:",id);
   end
	return datga[tostring(id)] or {}
end 

 
function FuncPlot.getPreAniData( id ) 
   local datga = FuncPlot.getStepPlotData(id)
	return datga.preAni or {}
end 

 
function FuncPlot.getPlotType()

end 
function FuncPlot.getLanguage(key)
    return GameConfig.getLanguage(key);
end

return FuncPlot  
