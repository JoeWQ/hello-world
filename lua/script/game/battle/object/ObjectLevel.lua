--
-- Author: XD
-- Date: 2014-07-24 10:44:47
--

local levelCfg = require("level.Level")

ObjectLevel = class("ObjectLevel")


ObjectLevel.staticData = nil

--怪物配置数据
ObjectLevel._killSpecInfo = nil -- 胜利条件：消灭特殊怪物
ObjectLevel._winType = nil 	-- 胜利的条件
ObjectLevel._lastTime = nil -- 胜利条件：坚持的时间
ObjectLevel._tutorial = nil -- 战斗新手引导

ObjectLevel.cacheObjectHeroArr = nil 	--缓存的objectHero数组

ObjectLevel.campData1 = nil 		--阵营1的基础数据
ObjectLevel.waveDatas = nil 			--对方波数数据

ObjectLevel.maxWaves =  1 			--最大波数
ObjectLevel.userRid = nil 			--战斗中主角
ObjectLevel.dropArr = nil 			--战斗中掉落
ObjectLevel.gameMode = nil 			--游戏模式
ObjectLevel.randomSeed = nil 		--随机种子
ObjectLevel.buffInfo = nil 		--额外buff 信息 针对爬塔


function ObjectLevel:ctor( hid,gameData )
	hid = tostring(hid)
	self.hid = hid
	self.staticData = levelCfg[hid]	
	if not self.staticData then
		echoError("没有这个关卡id数据,暂时用10101代替,hid:",hid)
		hid = "10101"
		self.hid = hid
		self.staticData = levelCfg[hid]	
	end
	self.gameMode = gameData.gameMode

	self.cacheObjectHeroArr = {}
	self.gameData =  gameData

	self.enterType = self.staticData["1"].enter or 0

	self:getLevelInfo()
	self:checkEnemy()
	echo("关卡id:",self.hid,"_最大波数:",self.maxWaves)
end

-- 判断是否需要新手引导
function ObjectLevel:checkIsTutorial(levelId)
	-- 数据库判断
	--LS:prv():set("StorageCode.tutorial_use_treasure",0)

	local tutorial = LS:prv():get("StorageCode.tutorial_use_treasure",def)
	tutorial = tutorial or 0 

	if levelId == "10101" and tutorial ==0 then
	elseif levelId == "10102" and tutorial == Fight.treasureType_hou then
	elseif levelId == "10103" and tutorial ==Fight.treasureType_qian then
	end
end


-- 判定胜利条件
function ObjectLevel:getLevelInfo()
	-- loadingId
	self.__loadType = self.staticData["1"].loadId
	-- 结算类型
	self.__rstType = self.staticData["1"].resultType

	-- 使用法宝的数目
	self.__userTreaNum = self.staticData["1"].useTsrNum
	-- 显示法宝的数目
	self.__showTreaNum = self.staticData["1"].showTsrNum
	-- 星级评价
	self.__starInfo = clone(self.staticData["1"].starTime)
	-- 关卡的中心点
	self.__midPos = clone(self.staticData["1"].midPos)

	-- self.__midPos = { 1000,750+300 , 750 + 600	}

	self.__mapId = self.staticData["1"].map


	-- 胜利判定方式
	self._winType = Fight.levelWin_killAll

	-- 杀死特定的怪物
	local killSpec = clone(self.staticData["1"].killSpec)
	if killSpec then
		self._killSpecInfo = killSpec[1]
		self._winType = Fight.levelWin_killSpec
	end
end





function ObjectLevel:checkEnemy()
	self.maxWaves = table.nums(self.staticData)
	--我放人员应该是从后端返回的数据  这里相当于写死的数据
	local hidArr = {
		-- {	pos = 1, hid = "30008",	},
		-- {	pos = 2, hid = "30012",	},
		-- {	pos = 3, hid = "30005",	},
		-- {	pos = 4, hid = "30007",	},
		-- {	pos = 5, hid = "30004",	},
		-- {	pos = 6, hid = "30003",	},
	}

	--判断是否配了npc1
	local waveData = self.staticData[tostring(1)]
	for i=1,6 do
		if waveData["npc"..i] then
			hidArr[i] = {pos = i,hid = waveData["npc"..i] }
		end
	end


	local checkPosTab = {}
	local checkCfg = function ( hid,val )
		-- echo("hid",hid,"val",val)
		-- dump(checkPosTab)
		for k,v in pairs(checkPosTab) do
			if val == v then
				echoWarn(hid.."配置的pos错误和figure冲突")
				break
			end
		end
		table.insert(checkPosTab,val)
	end

	self.campData1 = {}
	

	for ii,vv in pairs(hidArr) do
		local enemyInfo  =  EnemyInfo.new(vv.hid)
		local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
		enemyInfo.attr.posIndex = vv.pos
		table.insert(self.cacheObjectHeroArr,objHero )
		table.insert(self.campData1, enemyInfo.attr)
		--暂定第一个人是主角
		enemyInfo.attr.rid = enemyInfo.hid.."_"..ii
		if string.find( vv.hid,"30003")  then
			self.userRid = enemyInfo.attr.rid
		end
		if IS_CHECK_CONFIG then
			if enemyInfo.attr.figure==1 then
				--table.insert(checkPosTab,vv.pos)
				checkCfg(vv.hid,vv.pos)
			elseif enemyInfo.attr.figure ==2 then
				if not ( vv.pos ==1 or vv.pos ==3 or vv.pos==5 ) then
					echoWarn(vv.hid.."配置的pos错误和figure冲突")
				else 
					checkCfg(vv.hid,vv.pos)
					checkCfg(vv.hid,vv.pos+1)
				end
			elseif enemyInfo.attr.figure == 4 then
				if not ( vv.pos ==1 or vv.pos ==3 ) then
					echoWarn(vv.hid.."配置的pos错误和figure冲突")
				else
					checkCfg(vv.hid,vv.pos)
					checkCfg(vv.hid,vv.pos+1)
					checkCfg(vv.hid,vv.pos+2)
					checkCfg(vv.hid,vv.pos+3)
				end
			elseif enemyInfo.attr.figure == 6 then
				if vv.pos~=1 then
					echoWarn(vv.hid.."配置的pos错误和figure冲突")
				else
					for i=0,5 do
						checkCfg(vv.hid,vv.pos+i)
					end
				end
			end
		end
	end

	--目前暂定写死几个怪物
	self.waveDatas = {}
	for i=1,self.maxWaves do
		self.waveDatas[i] = {}
		local waveData = self.staticData[tostring(i)]
		--拿敌人数据
		checkPosTab={}
		for ii=1,6 do
			local hid = waveData["e"..ii]
			if hid then
				local enemyInfo  =  EnemyInfo.new(hid)
				--定义rid
				enemyInfo.attr.rid = enemyInfo.hid.."_"..ii .."_"..i
				table.insert(self.waveDatas[i], enemyInfo.attr)
				local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
				--记录位置 有些人因为体形比较大 所以得区分对待
				enemyInfo.attr.posIndex = ii
				table.insert(self.cacheObjectHeroArr,objHero )
				--如果是boss
				if enemyInfo.attr.boss == 1 then
					self.enemyRid = enemyInfo.attr.rid 
				--特定30003是主角
				elseif hid == "30003" then
					self.enemyRid = enemyInfo.attr.rid 
				end


				if IS_CHECK_CONFIG then
					if enemyInfo.attr.figure==1 then
						--table.insert(checkPosTab,vv.pos)
						checkCfg(hid,enemyInfo.attr.posIndex)
					elseif enemyInfo.attr.figure ==2 then
						if not ( enemyInfo.attr.posIndex ==1 or enemyInfo.attr.posIndex ==3 or enemyInfo.attr.posIndex == 5) then
							echoError(hid.."配置的pos错误和figure冲突",enemyInfo.attr.figure,enemyInfo.attr.posIndex)
						else 
							checkCfg(hid,enemyInfo.attr.posIndex)
							checkCfg(hid,enemyInfo.attr.posIndex+1)
						end
					elseif enemyInfo.attr.figure == 4 then
						if not ( enemyInfo.attr.posIndex ==1 or enemyInfo.attr.posIndex ==3 ) then
							echoError(hid.."配置的pos错误和figure冲突",enemyInfo.attr.figure,enemyInfo.attr.posIndex)
						else
							checkCfg(hid,enemyInfo.attr.posIndex)
							checkCfg(hid,enemyInfo.attr.posIndex+1)
							checkCfg(hid,enemyInfo.attr.posIndex+2)
							checkCfg(hid,enemyInfo.attr.posIndex+3)
						end
					elseif enemyInfo.attr.figure == 6 then
						if enemyInfo.attr.posIndex~=1 then
							echoError(hid.."配置的pos错误和figure冲突",enemyInfo.attr.figure,enemyInfo.attr.posIndex)
						else
							for i=0,5 do
								checkCfg(hid,enemyInfo.attr.posIndex+i)
							end
						end
					end
				end

			end
		end

	end
end

function ObjectLevel:sta_starTime()
	return self.__starInfo
end

function ObjectLevel:sta_beforeDialogue(wave)
	if Fight.no_dialog then
		return nil
	end
	return self.staticData[tostring(wave)].battleDialog1
end

function ObjectLevel:sta_lastDialogue(wave)
	if Fight.no_dialog then
		return nil
	end
	return self.staticData[tostring(wave)].battleDialog2
end

--判断游戏胜利 失败 结束 前提是已经是最后一波
function ObjectLevel:checkGameResult(controler)

	--有一些一定会失败的
	local campArr1 = controler.campArr_1
	local diedArr1 = controler.diedArr_1
	local campArr2 = controler.campArr_2
	local diedArr2 = controler.diedArr_2
	if #campArr1 == 0 and #diedArr1 ==0 then
		return Fight.result_lose
	end
	--如果敌方死光了  那么直接胜利
	if #campArr2 == 0 and #diedArr2 ==0 then
		return Fight.result_win
	end
	local specInfo = self._killSpecInfo
	--如果有特殊条件
	if specInfo then
		if specInfo.type == 1 then
			return  Fight.result_none
		--如果是杀死boss后直接胜利
		elseif specInfo.type == 3 then
			local hasBoss = false
			for i,v in ipairs(campArr2) do
				if v:checkIsMainHero() then
					hasBoss = true
				end
			end

			for i,v in ipairs(diedArr2) do
				if v:checkIsMainHero() then
					hasBoss = true
				end
			end

			--如果没有boss了
			if not hasBoss then
				return Fight.result_win  
			end
		end

	end

	return Fight.result_none
end

--判断是否进功能攻击队列
function ObjectLevel:checkEnterQueneGroup( camp,wave )
	if camp == 1 then
		return true
	end
	local waveData = self.staticData[tostring(wave)]
	local queCamera = waveData.queCamera
	if queCamera then
		--1 是不需要进队列
		if queCamera[1] == 1 then
			return false
		end
	end
	return true
end

--判断是否需要摄像头移动
function ObjectLevel:checkCampCamera( camp,wave )
	if camp == 1 then
		return true
	end
	local waveData = self.staticData[tostring(wave)]
	local queCamera = waveData.queCamera
	if queCamera then
		--1 是不需要摄像头运动
		if queCamera[2] == 1 then
			return false
		end
	end
	return true
end


return  ObjectLevel
