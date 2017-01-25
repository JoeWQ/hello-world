--
-- Author: Your Name
-- Date: 2014-01-02 10:21:52
--


MapControler= class("MapControler")


local oneScreenWidth = 1136 -- 一屏的宽度   因为现在默认是按3屏摆放的 所以 需要判定当每一层的x坐标到达多少的时候 进行 循环容器

local baseScreenWidth = 960 		--基础屏幕宽度

local baseScreenNums = 3 		--基础屏幕数量  默认是拼3屏

local halfScreenWidth = 1136/2 				--半屏的宽度

local baseSwitchPos = oneScreenWidth * 1.5  --基础的需要切换的坐标  也就是说必须要坐标大于1.8屏的时候 才需要开始进行循环预备 

local mapScale = 0.5

local threeScreenWidth = oneScreenWidth * baseScreenNums 		--3屏幕的宽度
local halfThreeWidth = threeScreenWidth /2 			--1.5屏宽度
 
local useRepeatMap = false


MapControler.scaleCtnObj =nil  --进行缩放的容器Obj
MapControler.moveCtnObj = nil  --进行运动的容器obj


MapControler.layerPosIndexObj = nil 	--记录每一层 所在第几屏

local disableMap = false

--现在map采用循环拼接方式 所以需要对容器进行循环管理

--这个是记录每一层容器的初始偏移值 
MapControler.ctnPianyiObj = nil


--容器数组  对于每一层 都是可能是一个二维数组
--[[
	layer1 = {screen1,screen2   }
	layer2 = {screen1,screen2},
	...
]]
MapControler.ctnArrObj = nil

--血玉
MapControler.leftBloodJade = nil
MapControler.rightBloodJade = nil
MapControler.bloodJadePos = nil

-- 场景
local sceneArr = {"map_linjianxiaodao","map_lishushan","map_meijie","map_mojie","map_naiheqiao",
					"map_pilitang","map_qionghuafeixu","map_shilipo","map_shushan","map_suzhoucheng",
					"map_wanrengufeng","map_xianlingdao"
}

local currentMapIndex
function MapControler:setNextMapId(isInit )
	--目前用自动按钮 测试场景
	if FIGHTDEBUG then

		if not  currentMapIndex then
			currentMapIndex = 1
		else
			if not isInit then
				currentMapIndex = currentMapIndex + 1
				if currentMapIndex > #sceneArr then
					currentMapIndex = 1
				end
			end
		end

		self:setMapId(sceneArr[currentMapIndex] )

		return
	end
end


function MapControler:ctor(backCtn,frontCtn, mapId)
	index = index or 1
	-- mapId = "map_pilitang"
	-- mapId = "map_shushan"
	-- mapId = "map_shilipo"
	self.mapId =  mapId 
	mapId =  "map_lishushan" 


	self.backCtn = backCtn
	self.frontCtn = frontCtn

	self.layerIndex = index
	
	-- self:setNextMapId(true)

	self:setMapId(mapId)

	return self
end


function MapControler:setMapId(mapId  )
	
	--先清除当前的map
	self:clearCurrentMap()

	local backLayer = self.backCtn--self.controler.layer["a"..self.layerIndex.."1"]

	if disableMap then
		return
	end

	self.ctnArrObj = {}
	self.ctnPianyiObj = {}
	self.scaleCtnObj  = {}
	self.moveCtnObj = {}
	self.layerPosIndexObj = {}

	--local map = WindowsTools:createWindow("BattleMap"):addto(backLayer)
	local map = BattleMapTools:createWindow(mapId):addto(backLayer):pos(0,-GameVars.height)

	self.mapId = mapId
	self.map = map
	self.speed = map.speed
	self.ctnNameArr = map.ctnNameArr
	
	local landIndex = map.landIndex
	self.landIndex = landIndex
	if landIndex ==0 then
		landIndex = 99999
	end
	--给每一层需要包一层 用来缩放的
	local ctnBack = self.backCtn
	local ctnFront = self.backCtn--self.frontCtn  


	for i,v in ipairs(self.ctnNameArr) do

		local scaleNode =  display.newNode()
		self.scaleCtnObj[v] = scaleNode

		local oldCtn = map[v]

		local px,py = oldCtn:getPosition()

		--记录偏移 
		self.ctnPianyiObj[v] = {px,py}

		--初始化存储oldCtn
		self.ctnArrObj[v] = {oldCtn}

		--运动层 addto  scale层
		local moveNode = display.newNode():pos(0,0)
		self.moveCtnObj[v] = moveNode
		scaleNode:addTo(moveNode)
		--原始层 addto  move层
		oldCtn:parent(scaleNode)

		if i <= landIndex  then
			moveNode:addto(ctnBack)
		else
			moveNode:addto(ctnFront)
		end
	end
	self:updatePos(0,0)

	if self._targetScale then
		self:updateScale(self._targetScale, self._scalePos)
	end
end

--清除当前地形
function MapControler:clearCurrentMap(  )
	if self.map then
		for k,v in pairs(self.scaleCtnObj) do
			v:removeSelf()
		end

		self.map:deleteMe()
		self.map = nil

		self.layerPosIndexObj = nil
		--清除ctn数组
		self.ctnArrObj = nil
		self.scaleCtnObj = nil
		self.moveCtnObj = nil
		self.ctnPianyiObj = nil

	end
end

--获取某个layer的view
function MapControler:getOneLayerView(layerId,index  )
	--如果是还没创建 layer的 那么需要克隆一下
	if not self.ctnArrObj[layerId][index] then
		self:cloneOneLayer(layerId)
	end
	return self.ctnArrObj[layerId][index]
end

--给某个layer 设置坐标
function MapControler:setOneLayerPos(  )
	-- body
end

--根据坐标判断容器坐标
function MapControler:checkLayerPos( layerId,targetXpos )
	--如果都不够 基础长度


	targetXpos = - targetXpos


	if targetXpos < baseSwitchPos then
		return
	end



	
	--判断坐标在哪个区间内
	local index = math.ceil( (targetXpos )  /oneScreenWidth )
	
	-- --如果区域相同不执行
	if self.layerPosIndexObj[layerId]== index then
		return
	end

	--目前是循环的 所有至多只需要2个layer 就可以了
	local layer1 =self:getOneLayerView(layerId,1)
	local layer2 =self:getOneLayerView(layerId,2)

	--判断当前应该在哪个循环层
	local layerIndex = math.ceil ( index /3  )
	
	

	local yushu = layerIndex % 2

	local layerPos = self.ctnPianyiObj[layerId]

	--如果是在当前屏幕的左半边 那么需要向左循环
	if targetXpos % threeScreenWidth < oneScreenWidth then
		
		--如果当前是落在a屏
		if yushu == 1 then
			--那么移动b屏幕
			layer1:pos( (layerIndex-1) * threeScreenWidth + layerPos[1],layerPos[2] )
			layer2:pos( (layerIndex-2) * threeScreenWidth+ layerPos[1],layerPos[2] )
		else
			--否则就是移动a屏
			layer2:pos( (layerIndex-1) * threeScreenWidth+ layerPos[1],layerPos[2] )
			layer1:pos( (layerIndex-2) * threeScreenWidth+ layerPos[1],layerPos[2] )
			
		end
	else
		--如果当前是落在a屏
		if yushu == 1 then
			--那么移动b屏幕
			layer1:pos( (layerIndex-1) * threeScreenWidth+ layerPos[1],layerPos[2] )
			layer2:pos( (layerIndex) * threeScreenWidth+ layerPos[1],layerPos[2] )
		else
			--否则就是移动a屏
			layer2:pos( (layerIndex-1) * threeScreenWidth+ layerPos[1],layerPos[2] )
			layer1:pos( (layerIndex) * threeScreenWidth+ layerPos[1],layerPos[2] )
		end
	end

	--echo(targetXpos,index,"________targetPosx",layerIndex, layer2:getPosition())
end

-- 复制某一层
function MapControler:cloneOneLayer( layerId )
	local uiDatas = self.map.__uiCfg

	local index =  table.indexof(self.ctnNameArr, layerId)
	if not index then
		error("错误的layerid",layerId) 	
	end 

	local layerData = uiDatas.ch[index]

	if not layerData then
		error("没有找到这个层数据,index:",index)
	end
	local moveCtn = self.moveCtnObj[layerId]


	--设置为场景url
	UIBaseDef:setResUrlMap(  )
	UIBaseDef:setDynamicName(self.map.__uiCfg.ex.fla)
	--克隆一层以后 就可以
	local nd = UIBaseDef:get_panel( layerData)
	--nd:visible(false)
	nd:parent(moveCtn)

	UIBaseDef:setDynamicName(nil)
	UIBaseDef:setResUrlUI(  )
	table.insert(self.ctnArrObj[layerId], nd) 
end


--更新scale
function MapControler:updateScale( resultScale,scalePos )
	if disableMap then
		return
	end
	self._targetScale = resultScale
	self._scalePos = scalePos
	local xpos
	local ypos
	for i,v in pairs(self.speed) do
	    local sa = 1-  (1- resultScale)    * v 
        xpos = math.round( scalePos.x - scalePos.x *sa )
        ypos = math.round( scalePos.y - scalePos.y  * sa )
        local targetCtn =  self.scaleCtnObj[i] 
        targetCtn:pos(xpos,-ypos)

        targetCtn:scale(sa)
	end
end

--更新坐标
function MapControler:updatePos( posx,posy )
	if disableMap then
		return
	end
	local turnposx,turnposy
	if posx > 0 then
		posx = 0
	end
	posx = math.round(posx)

	for k,v in pairs(self.speed) do
		turnposx =  posx * v 
		turnposy =  posy * v --math.pow(v,0.5) 
		if self.moveCtnObj[k] then 
			self.moveCtnObj[k]:pos(turnposx,turnposy)
			-- self.moveCtnObj[k]:pos(turnposx,turnposy)
			--echo(table.indexof(k,"panel_land"),"---table.indexof",k)

			-- if string.find(k, "land") then
			-- 	self:checkLayerPos(k,turnposx)
			-- end
			if useRepeatMap then
				self:checkLayerPos(k,turnposx)
			end
			
			
		end
	end
end


-- mainlayer层
function MapControler:deleteMe(  )
	if disableMap then
		return
	end
	self:clearCurrentMap()
end


