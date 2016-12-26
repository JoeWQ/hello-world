GameLuaLoader = GameLuaLoader or {}

local load_paths = {

}
local GAME_SYS_EVENTS = {
	"InitEvent",
	"LogEvent",
	"HeroEvent",
	"UserEvent",
	"UserExtEvent",
	"LoginEvent",
	"TreasureEvent",
	"HomeEvent",
	"ChargeEvent",
	"ItemEvent",
	"SystemEvent",
	"TutorialEvent",
	"NotifyEvent",
	"TimeEvent",
	"PvpEvent",
	"PveEvent",
	"GuildEvent",
	"MailEvent",
	"FriendEvent",
	"ChatEvent",
	"CountEvent",
	"ShopEvent",
	"TrialEvent",
	"LotteryEvent",
	"LoadEvent",
	"BattleEvent",
	'YongAnGambleEvent',
	'SmeltEvent',
	'ActivityEvent',
	'WorldEvent',
	'QuestEvent',
	'CombineEvent',
	'UIEvent',
	"SettingEvent",
	'TowerEvent',
	'CharEvent',
	'StarlightEvent',
	'VersionEvent' ,
    'NatalEvent',
    'HappySignEvent',
    'EliteEvent',
    'RechargeEvent',
    "PartnerEvent",
}
local GAME_SYS_DATAS = {
	"MusicConfig",
	"ServiceData",
	"ArmatureData",
	"MethodCode",
	"StorageCode",
	"ErrorCode",
	"GameStatic",
}

local GAME_SYS_MODELS = {
	"BaseModel",
	"UserModel",
	"UserExtModel",
	"HomeModel",
	"ItemsModel",
	"PVPModel",
	"GuildModel",
	"Treasure",
	"TreasuresModel",
	"MailModel",
	"ShopModel",
	"NoRandShopModel",
	"SmeltModel",
	"CountModel",
	"CdModel",
	"SignModel",
	"LotteryModel",
	"TrailModel",
	"WorldModel",
	"AudioModel",
	"DailyQuestModel",
	"MainLineQuestModel",
	"CharModel",
	"YongAnGambleModel",
	"TowerNewModel",
	"ActTaskModel",
	"ActConditionModel",
	"StarlightModel",
	"FriendModel",
	"ChatModel",
	"NatalModel",
	"TalentModel",
    "ChallengeModel",
    "HappySignModel",
    "EliteModel",
    "EliteChanllengeModel",
    "RechargeModel",
    "VipModel",
    "GodModel",
    "GodFormulaModel",
    "DefenderModel",
    "PartnerModel",
    "TeamFormationModel"
}

local GAME_SYS_FUNCS = {
	"FuncDataSetting",	
	"FuncRes",
	"GameConfig",
	"FuncArmature",
	"FuncCommUI",
	"FuncChar",
	"FuncTranslate",
	"FuncTreasure",
	"FuncDataResource",
	"FuncItem",
	"FuncCommon",
	"FuncPvp",
	"FuncChapter",
	"FuncGuild",
	"FuncMail",
	"FuncShop",
	"FuncSmelt",
	"FuncSign",
	"FuncLottery",
	"FuncTrail",
	"FuncHome",
    "FuncLamp",
	"FuncNpcevent",
	"FuncAccountUtil",
	"FuncYongAnGamble",
	"FuncPlot",
	"FuncCount",
	"FuncLoading",
	"FuncMatch",
	"FuncQuest",
	"FuncSetting",
	"FuncActivity",
	"FuncTower",
	"FuncBattleBase",
	"FuncGuide",
	"FuncWorshipevent",
	"FuncNpcPos",
    "FuncChallenge",
    "FuncHappySign",
    "FuncElite",
    "FuncGod",
    "FuncDefender",
    "FuncPartner",
    "FuncTeamFormation"
}

local GAME_SYS_SERVERS = {
	"Server",
    "ServerOther",
	"HttpServer",
	"WebHttpServer",
	"CharServer",
	"BattleServer",
	"ItemServer",
	"UserServer",
	"FriendServer",
	"ChatServer",
    "LampServer",
	"CdServer",
	"PVPServer",
	"TreasureServer",
	"HomeServer",
	"GuildServer",
	"MailServer",
	"ShopServer",
	"RankServer",
	"SignServer",
	"LotteryServer",
	"TrialServer",
	"YongAnGambleServer",
	"SmeltServer",
	"ActivityServer",
	"WorldServer",
	"QuestServer",
	"CombineServer",
	"TutorServer",
	"TowerServer",
    "NatalServer",
    "HappySignServer",
    "FirstRechargeServer",
    "RechargeServer",
    "EliteServer",
    "VipServer",
    "GodServer",
    "PartnerServer",
    "TeamFormationServer"
}

local GAME_BATTLE_TOOLS = {
	"RandomControl",
	"TimeUtils",
	"GameStatistics",
	"BattleRandomControl",

}

local GAME_BATTLE_DATAS = {
	"Formula",
	"ConstValues",
	"FrameDatas",
	"EnemyLocation",
}

local GAME_BATTLE_CONTROLERS = {
	"LayerManager",
	"GameSortControler",
	"RefreshEnemyControler",
	"CameraControler",
	"GameControler",
	"GameControlerPVE",
	"GameControlerPVP",
	"GameControlerGVE",
	"GameBackupControler",
	"KeyControler",
	"ScreenControler",
	"MapControler",
	"GameResControler",
	"StatisticsControler",
	"LogicalControler"
}

local GAME_BATTLE_MODELS = {
	"ModelBasic",
	"ModelMoveBasic",
	"ModelHitBasic",
	"ModelFrameBasic",
	"ModelCreatureBasic",
	"ModelAutoFight",
	"ModelEffectBasic",
	"ModelEffectNum",
	"ModelActionExpand",
	"ModelEffectEnergy",
	"ModelShade",
	"ModelHero",
	"ModelMissle",
	"ModelPiece",
	"ModelPhantom",
	"ModelEnemy",
}

local GAME_BATTLE_OBJECTS = {
	"ObjectBuff",
	"ObjectSkill",
	"ObjectAttack",
	"ObjectHero",
	"ObjectMissle",
	"ObjectCommon",
	"ObjectLevel",
	"ObjectTreasure",
	"EnemyInfo",
	"ObjectRefresh",
	"ObjectFilterAi",
	"ObjectHpAi",
}

local GAME_BATTLE_VIEWS = {
	"ViewBasic",
	"ViewHealthBar",
	"ViewArmature",
	"ViewSpine",
}

local GAME_BATTLE_EXPANDS = {
	"MissleAppearType",
	"AttackChooseType",
	"AttackUseType",
	"SkillChooseExpand",
}

--加载更新完之后需要require的内容
function GameLuaLoader:loadGameStartupNeeded()
	require("game.sys.GameVars")
	require("app.scenes.init")
end

--加载更新完之后需要require的内容
function GameLuaLoader:loadFirstNeeded()
	require("game.sys.AppInformation")
	self:loadGameSysEvents()
	require('game.sys.view.init')
	self:loadTutorials()
	require('game.sys.controler.init')
	self:loadGameSysDatas()
	self:loadFirstNeededFuncs()
	self:loadGameSysModels()
	self:loadGameSysServers()
	require("game.battle.view.ViewSpine")
	require("game.battle.tools.RandomControl")
	require("game.battle.view.ViewArmature")

	AudioModel = require('game.sys.model.AudioModel')
end

function GameLuaLoader:loadTutorials()
	require("game.sys.view.tutorial.TutoralLayer")
	require("game.sys.view.tutorial.TutorialManager")
	require("game.sys.view.tutorial.UnforcedTutorialLayer")
	require("game.sys.view.tutorial.UnforcedTutorialManager")
end

function GameLuaLoader:loadFirstNeededFuncs()
	local funcs = {
		"FuncCommUI",
		"FuncArmature",
		"FuncTranslate",
		"FuncDataSetting",
		"FuncCommon",
		"FuncDataResource",
		"GameConfig",
		"FuncSetting", 
		"FuncLoading",
		"FuncRes",
		"FuncChar",
		"FuncItem",
		"FuncTreasure",
		"FuncShop",
		"FuncCount",
		"FuncMatch",
		"FuncTrail",
		"FuncAccountUtil",
		"FuncChapter",
		"FuncBattleBase",
	}
	for _, func in ipairs(funcs) do
		require('game.sys.func.'..func)
		local t = _G[func]
		if t and t.init then
			t.init()
			EventControler:dispatchEvent(InitEvent.INITEVENT_FUNC_INIT, {funcname=func})
		end
	end
end

function GameLuaLoader:loadGameSysEvents()
	local events = GAME_SYS_EVENTS
	for _,event in ipairs(events) do
		_G[event] = require('game.sys.event.'..event)
	end
end

function GameLuaLoader:loadGameSysDatas()
	local datas = GAME_SYS_DATAS
	for _, datakey in ipairs(datas) do
		_G[datakey] = require('game.sys.data.'..datakey)
	end
end

function GameLuaLoader:loadGameSysServers()
	for _, serverkey in ipairs(GAME_SYS_SERVERS) do
		_G[serverkey] = require("game.sys.service."..serverkey)
	end
end

function GameLuaLoader:loadGameSysModels()
	for _,modelkey in ipairs(GAME_SYS_MODELS) do
		_G[modelkey] = require("game.sys.model."..modelkey)
	end
end

function GameLuaLoader:loadGameSysFuncs()
	for _,funckey in ipairs(GAME_SYS_FUNCS) do
		local loadPath = "game.sys.func."..funckey
		if not package.loaded[loadPath] then
			require(loadPath)
			local t = _G[funckey]
			if t and t.init then
				t.init()
				EventControler:dispatchEvent(InitEvent.INITEVENT_FUNC_INIT, {funcname=funckey})
			end
		end
	end
end

function GameLuaLoader:loadGameBattleTools()
	self:_loadOnePath("game.battle.tools.", GAME_BATTLE_TOOLS)
end

function GameLuaLoader:loadGameBattleDatas()
	self:_loadOnePath("game.battle.data.", GAME_BATTLE_DATAS)
end

function GameLuaLoader:loadGameBattleControlers()
	self:_loadOnePath("game.battle.controler.", GAME_BATTLE_CONTROLERS)
end

function GameLuaLoader:loadGameBattleModels()
	self:_loadOnePath("game.battle.model.", GAME_BATTLE_MODELS)
end

function GameLuaLoader:loadGameBattleObjects()
	self:_loadOnePath("game.battle.object.", GAME_BATTLE_OBJECTS)
end

function GameLuaLoader:loadGameBattleViews()
	self:_loadOnePath("game.battle.view.", GAME_BATTLE_VIEWS)
end

function GameLuaLoader:loadGameBattleExpands()
	self:_loadOnePath("game.battle.expand.", GAME_BATTLE_EXPANDS)
end

function GameLuaLoader:loadGameBattleInit()
	if DEBUG_SERVICES then
		require("game.sys.battle.init")
	else
		self:loadGameBattleTools()
		self:loadGameBattleDatas()
		self:loadGameBattleControlers()
		self:loadGameBattleModels()
		self:loadGameBattleObjects()
		self:loadGameBattleViews()
		self:loadGameBattleExpands()
	end
end

function GameLuaLoader:_loadOnePath(requirePathStr, files)
	local loadPath = requirePathStr
	for _,v in ipairs(files) do
		require(loadPath..v)
	end
end

--进入游戏之后的loaded path
function GameLuaLoader:getAllLoadedPaths()
	local clearPaths = {
		"game.sys.GameVars",
	}
	for _, datakey in ipairs(GAME_SYS_DATAS) do
		table.insert(clearPaths, string.format("game.sys.data.%s", datakey))
	end

	for _, eventkey in ipairs(GAME_SYS_EVENTS) do
		table.insert(clearPaths, string.format('game.sys.event.%s', eventkey))
	end
	
	for _, funckey in ipairs(GAME_SYS_FUNCS) do
		table.insert(clearPaths, string.format("game.sys.func.%s", funckey))
	end

	for _, serverkey in ipairs(GAME_SYS_SERVERS) do
		table.insert(clearPaths, string.format('game.sys.service.%s', serverkey))
	end

	for _, modelkey in ipairs(GAME_SYS_MODELS) do
		table.insert(clearPaths, string.format("game.sys.model.%s", modelkey))
	end
end

function GameLuaLoader:clearModules()
	local scene = WindowControler:getScene()
	local childArr = scene:getChildren()
	EventControler:clearAllEvent()
	FightEvent:clearAllEvent()
	for i=#childArr,2,-1 do
		childArr[i]:removeFromParent(true)
	end
	ViewArmature:clearArmatureCache( )
	ViewSpine:clearSpineCache()
	AppHelper:releaseResAndRestart()
end

