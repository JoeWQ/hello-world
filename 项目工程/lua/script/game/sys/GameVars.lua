


--绝大部分全局定义的变量都写在这里
GameVars=GameVars or {}

--默认使用的ttf字体名称
GameVars.fontName = "HYShuHunJ.ttf"
-- GameVars.fontName = "FZHuaLi-M14S"
-- GameVars.fontName = "STXingkai"
-- GameVars.systemFontName = "Arial"
--win32和mac下 用Arial ,ios 和android 用SimHei

-- if device and device.platform ~="windows" and device.platform ~= "mac" then
-- 	GameVars.systemFontName = "SimHei"
-- else
-- 	GameVars.systemFontName = "Arial"
-- end
GameVars.systemFontName = "SimHei"

-- Android平台ttf字体必须带.ttf扩展名
if device.platform == "android" then
	GameVars.fontName = "ttf/" .. GameVars.fontName
end

--屏幕适配分辨率最大宽度（超过该宽度后左右留黑边）
GameVars.maxScreenWidth = 1136
-- 屏幕适配分辨率最大高度（超过该高度后上下留黑边）
GameVars.maxScreenHeight = 768

--资源分辨率最大宽度（屏幕宽度超过该值后右移scene._root）
GameVars.maxResWidth = 960
--资源分辨率最大高度（屏幕高度超过该值后上移scene._root）
GameVars.maxResHeight = 640


--UI背景偏移
GameVars.UIbgOffsetX = GameVars.maxResWidth/2 - GameVars.maxScreenWidth/2
GameVars.UIbgOffsetY = -GameVars.maxResHeight/2 + GameVars.maxScreenHeight/2

--游戏的相对显示区域大小, 一定是在  960-1136  , 640 - 768 的范围内
GameVars.width =0;
GameVars.height =0;


--设备尺寸放缩后的大小 
GameVars.scaleWidth =0;
GameVars.scaleHeight =0;


GameVars.sceneOffsetX = 0;
GameVars.sceneOffsetY = 0;

GameVars.UIOffsetX = 0 
GameVars.UIOffsetY = 0


GameVars.cx = 0;
GameVars.cy = 0;
GameVars.bgOffsetX = 0;
GameVars.bgOffsetY = 0;

--初始化scene及UI root偏移、缩放等因子值
GameVars.initUIFactor = function()
	local glview = cc.Director:getInstance():getOpenGLView()
	echo("=============================initUIOffsetFactor=============================\n");
	--scene的root缩放因子
	
	local wid,hei
	--这里先对符合尺寸的 屏幕不缩放
	if display.width <= GameVars.maxScreenWidth and display.width >= GameVars.maxResWidth 
		and display.height <= GameVars.maxScreenHeight and display.height >= GameVars.maxResHeight then
		wid = display.width 
		hei = display.height
	 	GameVars.rootScale =  1.0;
	 else
	 	local scaleW = display.width / GameVars.maxResWidth;
		local scaleH = display.height / GameVars.maxResHeight;
		
		local scaleMW =  display.width / GameVars.maxScreenWidth
		local scaleMH =  display.height / GameVars.maxScreenHeight

		--对4种比率排序 然后根据宽高计算应该分部在哪个比例空间
		local ratioArr = {scaleW,scaleH,scaleMW,scaleMH}

		table.sort( ratioArr, table.descSort )

		--遍历每一种比率  计算那种比率合适
		for i,v in ipairs(ratioArr) do
			 wid = display.width / v
			 hei = display.height / v

			--只要到达分部边界  那么就 采用这个缩放率
			if wid >= GameVars.maxResWidth and hei >= GameVars.maxResHeight then
				GameVars.rootScale = v
				break
			end
		end
	end

	--这里需要取整
	wid = math.round(wid)
	hei = math.round(hei)

	GameVars.scaleWidth = wid
	GameVars.scaleHeight = hei
	
	echo("GameVars.rootScale:",GameVars.rootScale)

	--这个地方修改display.width  和 display.heigt  这个为
	-- display.width = wid
	-- display.height = hei

	--scene的x,y方向偏移值
	GameVars.sceneOffsetX = 0;
	GameVars.sceneOffsetY = 0;

	if wid > GameVars.maxScreenWidth then
		GameVars.width = GameVars.maxScreenWidth
		GameVars.sceneOffsetX = (wid - GameVars.maxScreenWidth) / 2;
	else
		GameVars.width = wid
	end

	if hei > GameVars.maxScreenHeight then
		GameVars.sceneOffsetY = (hei - GameVars.maxScreenHeight) / 2;
		GameVars.height = GameVars.maxScreenHeight
	else
		GameVars.height = hei
	end

	--scene的root的x,y方向偏移值
	GameVars.UIOffsetX = 0;
	if GameVars.width - GameVars.maxResWidth > 0 then
		GameVars.UIOffsetX = (wid - GameVars.maxResWidth) / 2 - GameVars.sceneOffsetX;
	else
		GameVars.UIOffsetX = 0;
	end

	if GameVars.height - GameVars.maxResHeight > 0 then
		GameVars.UIOffsetY = (hei - GameVars.maxResHeight) / 2 - GameVars.sceneOffsetY ;
	else
		GameVars.UIOffsetY = 0;
	end
	glview:setDesignResolutionSize(GameVars.scaleWidth, GameVars.scaleHeight, cc.ResolutionPolicy.NO_BORDER)
	echo("##(GameVars.sceneOffsetX,GameVars.sceneOffsetY)",GameVars.sceneOffsetX,GameVars.sceneOffsetY);
	echo("##(GameVars.UIOffsetX,GameVars.UIOffsetY)",GameVars.UIOffsetX,GameVars.UIOffsetY);
end

--初始化scene宽高数据
GameVars.initSceneData = function()
	--初始化游戏场景逻辑宽高数据
	-- GameVars.width = display.width;
	-- if GameVars.width > GameVars.maxScreenWidth then
	-- 	GameVars.width = GameVars.maxScreenWidth;
	-- end

	-- GameVars.height = display.height;
	-- if GameVars.height > GameVars.maxScreenHeight then
	-- 	GameVars.height = GameVars.maxScreenHeight;
	-- end

	GameVars.cx = GameVars.width / 2;
	GameVars.cy = GameVars.height / 2;

	echo("(GameVars.width,GameVars.height)=",GameVars.width,GameVars.height);

	GameVars.bgOffsetX = (GameVars.maxScreenWidth - GameVars.width)/2;
	GameVars.bgOffsetY = (GameVars.maxScreenHeight - GameVars.height)/2;

	echo("(GameVars.bgOffsetX,GameVars.bgOffsetY)=",GameVars.bgOffsetX,GameVars.bgOffsetY);
end






-- 天赋状态
GameVars.geniusState = {
		ACTIVATE = 1,	-- 激活状态
		NOT_ACTIVATE = 2, -- 未激活
	}


if not DEBUG_SERVICES  then
	GameVars.initUIFactor();
	GameVars.initSceneData ();

	GameVars.grayColor = cc.c3b(1,31,49)
	--通用背景半透颜色
	GameVars.bgAlphaColor = cc.c4b(0,0,0,120)

end


--星级需要的魂石数量
GameVars.starNeedSoul = {
	10,20,50,100,150,210
}

-- start:一 end:龥
GameVars.CHINESE_UTF32_RANGE = {19968, 40869}

--注册一个空函数 什么也不做
GameVars.emptyFunc= function (  )
end

--注册一个空table
GameVars.emptyTable = {}




-- 战斗选人时人物的缩放比例
GameVars.batlSelScale = 0.45

-- 计算战斗属性使用的keys映射
GameVars.fightAttributeKeys = {
	"atk",
	"def",
	"crit",
	"resist",
	"dodge",
	"hit",
	"critR"
}


GameVars.poolSystem = {
	trail1 = "301",	
	trail2 = "302",	
	trail3 = "303",
	zhangyi = "0",		--行侠仗义
	gve = "1",			--gve
}


--每天固定时间发 TimeEvent.TIMEEVENT_STATIC_CLOCK_REACH_EVENT 消息，demo全局搜 TIMEEVENT_STATIC_CLOCK_REACH_EVENT
--必须是 XX:XX:XX
-- GameVars.fireEventTime = {"04:00:00", "03:55:10", 
-- 	"18:00:00", "22:05:00", "18:58:10",  "15:11:30"};
--测试不充分，注释掉
GameVars.fireEventTime = {};

--战斗标签 每场战斗一定会有这个标签 用来给分系统区分 同时用来 区别战斗胜利失败界面
GameVars.battleLabels = {
	towerPve = "6", 		--爬塔pve
	worldPve = "1", 			--传统pve 六界刷关卡寻仙
	worldGve1 = "worldGve1",			--传统gve 六界刷关卡寻仙
	worldGve2 = "worldGve2",			--传统gve 六界刷关卡寻仙
	pvp = "2",					--传统竞技场

	trailPve = "3" ,			--试炼pve
	trailPve2 = "4" ,			--试炼pve
	trailPve3 = "5" ,			--试炼pve

	trailGve1 = "trailGve1" , 	--山神试炼gve
	trailGve2 = "trailGve2" , 	--火神试炼gve
	trailGve3 = "trailGve3" , 	--雷神试炼gve
	kindGve = "kindGve",		--行侠仗义 

}




GameVars.sysLabelToTreaNatal = {
	homeScene = "1",		-- 主城
    towerPve = "5", 		--爬塔pve
	worldPve = "2", 		--传统pve 六界刷关卡寻仙
	worldGve1 = "4",		--传统gve 六界刷关卡寻仙
	--worldGve2 = "worldGve2",	--传统gve 六界刷关卡寻仙
	pvp = "3",			--传统竞技场
	
	trailPve = "6" ,		--试炼pve
	trailPve2 = "7" ,		--试炼pve
	trailPve3 = "8" ,		--试炼pve

	trailGve1 = "6" , 		--山神试炼gve
	trailGve2 = "7" , 		--火神试炼gve
	trailGve3 = "8" , 		--雷神试炼gve
	kindGve = "kindGve",	--行侠仗义    
}

GameVars.openLevelTid = "#tid1902" -- (等级#1开启)
