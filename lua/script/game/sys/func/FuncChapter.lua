
FuncChapter= FuncChapter or {}

local storyData = nil
local raidData = nil
local sceneData = nil
local npcInfoData = nil

local raidInteractsArr = {}

FuncChapter.stageType = {
	TYPE_STAGE_MAIN = 1, --主线类型
	TYPE_STAGE_ELITE = 2, --精英类型
}


--初始化
function FuncChapter.init(  )
	storyData = require("story.Story")
	raidData = require("story.Raid")
	sceneData = require("story.Scene")
	npcInfoData = require("story.NpcInfo")

	FuncChapter.initRaidInteracts()
end

function FuncChapter.initRaidInteracts()
	local sortByRaidId = function(a, b)
		return tonumber(a.id) < tonumber(b.id)
	end
	local keys = table.sortedKeys(raidData, sortByRaidId)
	for i,key in ipairs(keys) do
		local info = raidData[key]
		if info.type == FuncChapter.stageType.TYPE_STAGE_ELITE and info.romanceInteractId~=nil then
			local data = {raidId = info.id, romanceInteractId = info.romanceInteractId}
			table.insert(raidInteractsArr, data)
		end
	end
end

function FuncChapter.getNpcInfoData()
	return npcInfoData
end

function FuncChapter.getNpcInfo(npcID)
	local npcInfo = npcInfoData[tostring(npcID)]
	if not npcInfo then
		echoError("ncpID is " .. npcID)
	end

	return npcInfo
end

function FuncChapter.getStoryData()
	return storyData
end

-- 根据storyId获取story数据
function FuncChapter.getStoryDataByStoryId(storyId)
	local data = storyData[tostring(storyId)]

	return data
end

-- 获取章的场景数据
function FuncChapter.getStorySceneData()
	return sceneData
end

-- 获取章的所有场景数据
function FuncChapter.getSceneDataByStoryId(storyId)
	local allSceneData = nil
	if storyId ~= nil then
		allSceneData = sceneData[tostring(storyId)]
	end

	return allSceneData
end

-- 临时方法
function FuncChapter.getMaxStoryIdFromSceneData()
	local maxStoryId = "0"
	for k,_ in pairs(sceneData) do
		if k > maxStoryId then
			maxStoryId = k
		end
	end

	return maxStoryId
end

-- storyId:章id
-- order:小场景id
function FuncChapter.getOneSceneData(storyId,order)
	local curSceneData = nil
	local allSceneData = FuncChapter.getSceneDataByStoryId(storyId)
	if storyId ~= nil then
		curSceneData = allSceneData[tostring(order)]
	end

	return curSceneData
end

-- 小场景id升序列表
function FuncChapter.getSceneOrderList(storyId)
	local allSceneData = FuncChapter.getSceneDataByStoryId(storyId)

	local orderList = {}
	for k,_ in pairs(allSceneData) do
		orderList[#orderList+1] = k
	end

	table.sort(orderList, function(a,b)
		return a < b
	end )

	return orderList
end

function FuncChapter.getRaidData()
	return raidData
end

function FuncChapter.getRaidDataByRaidId(raidId)
	local data = raidData[tostring(raidId)]
	return data
end

function FuncChapter.getRaidAttrByKey(raidId,key)
	local data = raidData[tostring(raidId)]
	local value = data[tostring(key)]
	return value
end

-- 获取章升序排序的节点列表
function FuncChapter.getOrderRaidList(storyId)
	local raidList = {}
	local raidData = FuncChapter.getRaidData()
	for k,v in pairs(raidData) do
		if v.chapter == tonumber(storyId) then
			raidList[#raidList+1] = k
		end
	end

	table.sort( raidList, function(a,b)
		return a < b
	end )

	return raidList
end

-- 根据章数及type，获取章数据
function FuncChapter.getStoryDataByChapter(chapter,type)
	for k,v in pairs(storyData) do
		local curChapter = v.chapter
		local curType = v.type
		if tonumber(curChapter) == tonumber(chapter) and tonumber(curType) == tonumber(type) then
			return v
		end
	end

	return nil
end

-- 根据storyId，获取其是第几章
function FuncChapter.getChapterByStoryId(storyId)
	local data = storyData[storyId]
	local chapter = data.chapter
	return chapter
end

-- 根据raidId，获取其在章中是第几节
function FuncChapter.getSectionByRaidId(raidId)
	-- print("raidId=",raidId)
	local section = FuncChapter.getRaidAttrByKey(raidId,"section")
	return section
end

-- 根据raidId，获取节剧情介绍
function FuncChapter.getDesByRaidId(raidId)
	local section = FuncChapter.getRaidAttrByKey(raidId,"des")
	return section
end

-- 根据raidId、key，获取节属性
function FuncChapter.getRaidAttrByKey(raidId,key)
	local data = raidData[tostring(raidId)]
	if data == nil then
		echoError("FuncChapter.getRaidAttrByKey raidId=",raidId,",key=",key)
	end
	local section = data[key]
	
	return section
end

-- 根据StoryId获取本章总节数
function FuncChapter.getMaxSectionByStoryId(storyId)
	local data = storyData[tostring(storyId)]
	if not data then
		echoError("___________没有找到storyId对应的数据",storyId)
		for k,v in pairs(storyData) do
			data = v
			break
		end
	end
	local section = data.section

	return section
end

-- 根据RaidId获取StoryId
function FuncChapter.getStoryIdByRaidId(raidId)
	local storyId = nil

	for k,v in pairs(raidData) do
		if tostring(raidId) == tostring(k) then
			storyId = v.chapter
			return storyId
		end
	end

	return storyId
end

-- 获取主线类型第一章的ID
function FuncChapter.getFirstStoryId(storyType)
	local storyId = nil
	local firstChapter = 1

	for k,v in pairs(storyData) do
		local type = v.type
		local chapter = v.chapter
		if tonumber(chapter) == firstChapter and tonumber(type) == tonumber(storyType) then
			storyId = k
			return storyId
		end
	end

	return storyId
end

-- 获取章最后一节的raidId
function FuncChapter.getLastRaidIdByStoryId(storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local totalSection = storyData.section

	local raidId = FuncChapter.getRaidIdByStoryId(storyId,totalSection)
	return raidId
end

-- 获取raidId
-- storyId：章的id,section:章的第几节
function FuncChapter.getRaidIdByStoryId(storyId,section)
	local raidId = nil
	
	for k,v in pairs(raidData) do
		local curSection = v.section
		local chapterId = v.chapter

		if tonumber(storyId) == tonumber(chapterId) and tonumber(section) == tonumber(curSection) then
			raidId = k
			return raidId
		end
	end

	if raidId == nil then
		echoError("FuncChapter.getRaidIdByStoryId storyId,section=",storyId,section,",raidId is nil")
	end

	return raidId
end

function FuncChapter.getNextOpenRomanceInteractId()
	local raidId = WorldModel:getUnLockMaxGVERaidId()
	raidId = tonumber(raidId)
	local interactId = nil
	if raidId < tonumber(raidInteractsArr[1].raidId) then
		interactId = raidInteractsArr[1].romanceInteractId
	else
		for _, info in ipairs(raidInteractsArr) do
			if raidId == tonumber(info.raidId) then
				interactId = info.romanceInteractId
				break
			end
		end
	end
	return interactId
end

function FuncChapter.getAllRaidInteractsInfo()
	return raidInteractsArr
end

