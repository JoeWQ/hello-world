local WindowControler={}
WindowControler.VIEW_LEVEL_MAX = 9 --view的最大级别数字



WindowControler.ZORDER_LOADING = 9999 		--loadui的zorder 最大
WindowControler.ZORDER_INPUT = 1100 		--输入文本的 高度, 不能超过loading 但是大于所有的tips
WindowControler.ZORDER_TIPS =  999 			--一些信息提示框  他也是ui

--最上层的是否可以点击层
WindowControler.ZORDER_UI_CONTROL_CLICKABLE_OR_NOT = 998 

WindowControler.ZORDER_Tutorial = 995 		--新手引导层 他是node

--盖在上层的node，主界面有个右上角有个其他玩家信息 要点哪都关闭
WindowControler.ZORDER_TopOnUI = 990

WindowControler.ZORDER_PowerRolling = 985	

--进战斗前的ui数量
WindowControler._beforBattleUINums = 0


--增加系列cache方法
--BindExtend.cache(WindowControler)
--窗口层级管理 {window1,window2,...	}
WindowControler.windowInfo = {}

--缓存的window信息,{ {root=rootName,name=windowName,params= {}},...	}
WindowControler.windowCacheInfo = {}


--缓存窗口的层级信息 
--[[
	winName = 0
	
]]
WindowControler._lastZorderInfo = {}
function WindowControler:getWindowLastZorder(winName  )
	if not self._lastZorderInfo[winName] then
		return 0
	end
	return self._lastZorderInfo[winName] or 0
end


--现在打开的view，没有考虑zorder，showWindowByRoot就算加一个，closeWindow就减一个 todo 完善我
-- WindowControler.viewOpens = {};

-- ============================== 霸道分割线 ============================== --
-- view基础控制
-- ============================== 霸道分割线 ============================== --


function WindowControler:init()
	--升级后接受信息
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
    	self.showLevelUp, self);

end

function WindowControler:showLevelUp(event)
	local newLvl = event.params.level;
	--判断是不是战斗中
	if BattleControler:isInBattle() == true then 
		--WindowControler:showTopWindow("CharLevelUpView", newLvl);
	else 
		WindowControler:showTopWindow("CharLevelUpView", newLvl);
	end 
end

--[[
	设置全局可不可点击，管不了战斗界面，tips可点（让掉线重连可以点）
	true 是 可点击
	false 是不可点击
]]
function WindowControler:setUIClickable(isClickable)
	function createListener()
		local clickableListener = nil;
		local node = display.newNode();
	    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
		clickableListener = cc.EventListenerTouchOneByOne:create();

		clickableListener:setSwallowTouches(true);

		WindowControler:getScene()._topRoot:addChild(node, 
			WindowControler.ZORDER_UI_CONTROL_CLICKABLE_OR_NOT);

	    local function onTouchBegan(touch, event)
	        return true
	    end

	    clickableListener:registerScriptHandler(onTouchBegan, 
	        cc.Handler.EVENT_TOUCH_BEGAN);

		eventDispatcher:addEventListenerWithSceneGraphPriority(
	        clickableListener, node);
		return clickableListener;
	end

	if self._clickableListener == nil then 
		self._clickableListener = createListener();
	end 

	self._clickableListener:setEnabled(not isClickable);

	--todo 主界面的listener 搞一下 要不还能拖动主界面，再看看npc的点击是不是用listener了
end

--只创建节点 不加载到界面上
function WindowControler:createWindowNode(winName)
	local cfg = WindowsTools:getUiCfg(winName)
	local newPos = {x=cfg.pos.x + GameVars.UIOffsetX,y=cfg.pos.y - GameVars.UIOffsetY};

	local ui = WindowsTools:createWindow(winName);

	-- ui:ignoreAnchorPointForPosition(false);
	-- ui:setAnchorPoint(cc.p(0,0));
	ui:setPosition(newPos);
	return ui;
end

--显示正常root的某个view
function WindowControler:showWindow(winName,...)
	return self:showWindowByRoot("root",winName,...)
end


--显示战斗窗口
function WindowControler:showBattleWindow(winName,...  )
	return self:showWindowByRoot("battle",winName,...)
end

--显示新手引导层的windows
function WindowControler:showTutoralWindow( winName,... )
	return self:showWindowByRoot("tutoral",winName,...)
end

--显示top窗口
function WindowControler:showTopWindow(winName,...  )
	return self:showWindowByRoot("top",winName,...)
end

--显示窗口
function WindowControler:showWindowByRoot(rootName,winName,...  )
	if not winName then
		error("WindowControler show view params is nil!")
		return nil
	end
    echo("====================Open The Window Name ========--->>"..winName)

	if self:checkHasWindow(winName) then
		return self:popWindow(winName,...)
	end

	local t1 = os.clock()
	local scene = self:getCurrScene()
	local rootCtn
	if rootName == "battle"  then
		rootCtn = scene._battleRoot
	elseif rootName =="root" then
		rootCtn = scene._root
	elseif rootName =="tutoral" then
		rootCtn = scene._tutoralRoot
	elseif rootName =="top" then
		rootCtn = scene._topRoot
	else
		echoError("错误的rootName:", rootName)
		rootCtn = scene._root
	end

	local cfg = WindowsTools:getUiCfg(winName )

	local newPos = {x=cfg.pos.x + GameVars.UIOffsetX,y=cfg.pos.y - GameVars.UIOffsetY};
	-- echo("newPos=\n");
	-- dump(newPos);
	local ui = WindowsTools:createWindow(winName,...):addto(rootCtn):pos(newPos)
	--缓存root名称 和 参数
	ui._cacheInfo = {root = rootName,name = winName,zorder = #self.windowInfo +1, params = {...}}

	--如果有 缓存的winZorder
	local lastZorder = self:getWindowLastZorder(winName) 
	if lastZorder > 0 then
		ui:zorder(lastZorder)
		ui._cacheInfo.zorder = lastZorder
	else
		--那么新创建的ui需要加上
		ui._cacheInfo.zorder = ui._cacheInfo.zorder + self._beforBattleUINums
		ui:zorder(ui._cacheInfo.zorder)
	end

	-- for i=1,#self.windowInfo do
	-- 	echo(i)
	-- end

	--如果这个创建的窗口层级 小于总层级 说明是需要插入进去
	if ui._cacheInfo.zorder <= #self.windowInfo then
		
	end

	self._lastZorderInfo[winName] = nil

	table.insert(self.windowInfo, ui)

	if not cfg.hideBg then
		local color 
		if cfg.bgAlpha then
			color = cc.c4b(0,0,0,cfg.bgAlpha)
		else
			color = cc.c4b(0,0,0,190)
		end

		local layer =  self:createCoverLayer(nil,nil,color):addTo(ui,-10)
		ui.colorLayer=layer;
	end
	
	-- dump(ui:getAnchorPoint());
	if not ui then
		error("WindowsTools create window error")
		return
	end	
    -- 
	-- 开始显示
	ui:startShow()

	-- 保存本次打开的 window
	self.lastWinName = winName

	echo(os.clock()-t1,"_打开窗口时间:",winName,"zorder:",ui._cacheInfo.zorder)

	self:tostring();

	return ui
end




--判断是否有window
function WindowControler:checkHasWindow( windowName )
	for i,v in ipairs(self.windowInfo) do
		if v.windowName ==windowName then
			return true
		end
	end
	return false
end

--让window显示最上层
function WindowControler:popWindow( windowName )
	local view
	local index =0
	for i,v in ipairs(self.windowInfo) do
		if v.windowName ==windowName then
			view = v
			index = i
			table.remove(self.windowInfo,i)
			break
		end
	end
	echo("popWindow:",windowName,view,tolua.isnull(view),index)
	table.insert(self.windowInfo, view)
	for i,v in ipairs(self.windowInfo) do
		v:zorder(i+ self._beforBattleUINums)
		v._cacheInfo.zorder = i + self._beforBattleUINums
	end
	self:topWindowBecomeActive()
	return view

	-- view:startShow()


end

--移除一个window ,根据名字
function WindowControler:removeWindowByWinName( windowName )
	local index = -1
	for i,v in ipairs(self.windowInfo) do
		if v.windowName ==windowName then
			index = i
			break
		end
	end
	if index ~= -1  then
		local originLen = #self.windowInfo
		table.remove(self.windowInfo,index)
		--移除一个window 需要让其他层的所有window zorder 减1
		for i=index,originLen-1  do
			local winView = self.windowInfo[i]
			winView._cacheInfo.zorder = winView._cacheInfo.zorder - 1
			winView:zorder(winView._cacheInfo.zorder)
		end


		if index == originLen then
			self:topWindowBecomeActive()
		end
	end
	self:tostring()
end

--获取window
function WindowControler:getWindow( windowName )
	for i,v in ipairs(self.windowInfo) do
		if v.windowName ==windowName then
			return v
		end
	end
	return nil
end


--windowInfo 堆栈变化时，调用最顶层view的 onBecomeTopView 方法
function WindowControler:topWindowBecomeActive()
	local top = self.windowInfo[#self.windowInfo]
	if top then
		top:onBecomeTopView()
	end
end



--关闭某个层级的view
function WindowControler:closeWindow(windowName)
	local window = self:getWindow(windowName)
	if window then
		window:startHide()
	end
end

--移除某个window ,只是把他从windowInfo里面移除
function WindowControler:removeWindowFromGroup( windowName )
	

	echo("移除某个window：",windowName)
	local scene = self:getCurrScene()
	--scene._root:removeChildByName("BgLayer",true);

	self:removeWindowByWinName(windowName)

	local curWinInfo = self:getCurrentWindowView();

	if curWinInfo ~= nil then 
		echo(curWinInfo.windowName ,"____最新的一个uiname")
		--回到主界面
		if curWinInfo.windowName == "HomeMainView" then
			EventControler:dispatchEvent(HomeEvent.HOMEEVENT_COME_BACK_TO_MAIN_VIEW)
		end 
		
	    EventControler:dispatchEvent(TutorialEvent.TUTORIALEVENT_VIEW_CHANGE, 
	        {viewName = curWinInfo.windowName});
	end 
end


function WindowControler:getCurrentWindowView()
	return self.windowInfo[#self.windowInfo]
end

--关闭所有的ui
function WindowControler:clearAllWindow(  )
	for k,v in pairs(self.windowInfo) do
		v:deleteMe()
	end

	self.windowInfo = {}
end


--创建一个覆盖的层 主要用来覆盖底下的 点击事件
function WindowControler:createCoverLayer( x,y ,color)
	x= x or - GameVars.UIOffsetX
	y = y or GameVars.UIOffsetY
	color = color or cc.c4b(0,0,0,120)
	local layer = display.newColorLayer(color):pos(x,y)
	layer:setName("BgLayer");
	layer:setContentSize(cc.size(GameVars.width,GameVars.height))
	layer:anchor(0,1)
    layer:setTouchEnabled(true)
    layer:setTouchSwallowEnabled(true)
    return layer
end

--切换场景
function WindowControler:chgScene(sceneName, hasTransition)
	local oldScene = self:getScene()
	if oldScene then
		oldScene:removeFromParent()
	end

	local scene = require("app.scenes." .. sceneName).new()

	local transitionType = nil
	if hasTransition then
		transitionType = "fade"
	end
	display.replaceScene(scene, transitionType, 0.6 )

	self.loadView = nil
	return scene
end

--判断并获取当前场景
function WindowControler:getScene()
	return display.getRunningScene()
end

function  WindowControler:getDocLayer()
    local scene = self:getScene()
    return scene.__doc
end

function WindowControler:getCurrScene()
	return display.getRunningScene()
end

function WindowControler:enabledClickEffect( val )
	local scene = self:getCurrScene()
	if scene["enableClickEffect"] then
		scene["enableClickEffect"](scene,val)
	end
end

WindowControler._loadingCount =0

--显示load
function WindowControler:showLoading(  )
	self._loadingCount = self._loadingCount +1
	if not self.loadView then

		self.loadView = WindowsTools:createWindow("ServerLoading");
		local scene = self:getCurrScene()
		local cfg = WindowsTools:getUiCfg("ServerLoading")

		local newPos = {x=cfg.pos.x + GameVars.UIOffsetX,y=cfg.pos.y - GameVars.UIOffsetY};

		local layer = self:createCoverLayer(nil,nil,cc.c4b(255,255,0,0)):addTo(self.loadView,0)

		self.loadView:pos(newPos):addto(scene._topRoot,self.ZORDER_LOADING) --:zorder(self.ZORDER_LOADING)
	else
		self.loadView:visible(true)
	end
	self._isLoading = true
	self.loadView:startShow()

	--loading时候，让新手引导层不可点击
    if LoginControler:isStartPlay() == true and 
		TutorialManager.getInstance():isAllFinish() == false and 
		 TutorialManager.getInstance():isTutoring() == true then 

		 self._alreadyHideTutorlayer = true;
		 TutorialManager.getInstance():hideTutorialLayer();
	end 
end

--隐藏loading
function WindowControler:hideLoading()
	self._isLoading = false
	self._loadingCount = self._loadingCount -1
	if self.loadView then
		local hideLoading = function()
			self.loadView:visible(false)
			self.loadView:hideLoadingAnim()
		end
		hideLoading()
		-- self:globalDelayCall(c_func(hideLoading), 1.0/GAMEFRAMERATE*1)

		--关loading时候，让新手引导层不可点击
	    if self._alreadyHideTutorlayer == true then 
		 	TutorialManager.getInstance():showTutorialLayer();
		 	self._alreadyHideTutorlayer = false;
		end 
	end
end

--[[
	是否正在Loading中
]]
function WindowControler:isLoading()
	return self._isLoading == true and true or false;
end

--显示错误警告
--[[
	info = {text:提示文本信息  }

]]

function WindowControler:showTips( info )
	local scene = self:getCurrScene()
	if not self._tips then
		self._tips = WindowsTools:createWindow("Tips"):addto(scene._topRoot,WindowControler.ZORDER_TIPS)
	end
	AudioModel:playSound("s_com_tip")


	local cfg = WindowsTools:getUiCfg("Tips" )

	local newPos = {x= GameVars.cx,y= GameVars.height-170-90 };
	self._tips:pos(newPos.x,newPos.y)
	self._tips:startShow(info)
	self._tips:visible(true)

end
--//系统公告提示框,注意,此函数只能在主场景中调用
function WindowControler:showNotice()
	local scene = self:getCurrScene()
	if not self._tips then
		self._tips = WindowsTools:createWindow("TrotHoseLampView"):addto(scene._topRoot,WindowControler.ZORDER_TIPS)
	end
--	AudioModel:playSound("s_com_tip")

	local cfg = WindowsTools:getUiCfg("TrotHoseLampView" )

	local newPos = {x= GameVars.cx,y= GameVars.height-170-90 };
	self._tips:pos(newPos.x,newPos.y)
	self._tips:startShow(info)
	self._tips:visible(true)
end
--[[
	--todo 暂时没有考虑富文本

	params = {
		title = "", --标题
		des = "",   --内容
		isSingleBtn = bool, --1个btn还是2个btn 默认 true
		firstBtnCallBack = func, --第1个btn的点击相应 默认(关闭界面)
		secondBtnCallBack = func, --第2个btn的点击相应 默认(关闭界面)
		firstBtnStr = "",  --第1个btn上的字符 默认是 "取消" （一个btn是"确定"）
		secondBtnStr = "",  --第2个btn上的字符 默认是 "确定"
	}
]]
function WindowControler:showAlertView(params)
	if params.isSingleBtn == nil then
		params.isSingleBtn = true;
	end 

	self:showWindow("MessageBoxView", params);
end


-- ============================== 霸道分割线 ============================== --
--退出游戏
function WindowControler:exit()
	cc.Director:getInstance():endToLua()
	if device.platform == "ios" then
		--实测发现 android部分机型调用os.exit有几率异常退出
		os.exit()
	end
end

--一键回主界面
function WindowControler:goBackToHomeView()
	echo(" ----goBackToHomeView--- ");
	local viewToHide = {};

	for i = 1,#self.windowInfo do
		local v = self.windowInfo[i];

		echo("v ", v);
		echo("v.windowName ", v.windowName);

		if v.windowName == "HomeMainView" then
			
		else
			table.insert(viewToHide, v);
		end
	end

	for k, v in pairs(viewToHide) do
		v:startHide();
	end
end

--一键回登入
function WindowControler:goBackToEnterGameView()
	--先回loading，检查更新
	--目前先用原来的dmx：20160602
	--LoginControler:logout()
	--WindowControler:showWindow("LoginLoadingView")
	--for i=1,#self.windowInfo do
	--    local v = self.windowInfo[i]
	--    if v ~= nil and v.windowName ~= "LoginLoadingView" then
	--        v:startHide()
	--    end
	--end

	--正式版会走这里20160602
	LoginControler:logout()
	GameLuaLoader:clearModules()
end



--清除没有被使用的材质 一般主要在进战斗 出战斗的时候 或者大量使用icon的ui会调用
function WindowControler:clearUnusedTexture(  )
	--如果是使用散图的  那么不清理 
	if CONFIG_USEDISPERSED then
		return
	end

	--进入战斗之前移除没有使用的texture
    local tempFunc = function (  )
    	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end
    self:globalDelayCall(tempFunc,0.006)
end



--全局的延迟器, 如果是ui里面需要用 延迟函数的 一定要用ui自己的delayCall,不允许使用全局delaycall,否则 当ui关闭的时候
--还会执行全局dealyCall 
function WindowControler:globalDelayCall(func,delay )
	local scene = self:getCurrScene()
	scene:delayCall(func, delay)
end

--清除全局注册的所有delayCall
function WindowControler:clearGlobalDelay(  )
	local scene = self:getCurrScene()
	scene:stopAllActions()
end

--忽略的窗口
local igoneClearArr = {"WorldPVEMainView"}

--当进入战斗的时候
function WindowControler:onEnterBattle( callBack )
	--遍历所有的WindowInfo
	self.windowCacheInfo = {}



	self._beforBattleUINums = #self.windowInfo

	--分帧删除目前已经存在的场景
	local length = #self.windowInfo
	for i=#self.windowInfo,1,-1 do
		local v = self.windowInfo[i]
		local cacheInfo = v._cacheInfo
		--只移除root上的所有view
		if cacheInfo.root == "root"  then
			local winName = cacheInfo.name
			if not table.indexof(igoneClearArr, winName) then
				echo("移除当前window:",cacheInfo.name)
				table.insert(self.windowCacheInfo,1, cacheInfo)
				table.remove(self.windowInfo,i)
				self:globalDelayCall(c_func(v.deleteMe, v), i/GAMEFRAMERATE )
				self._lastZorderInfo[winName] = i
			else
				echo("忽略移除的window:",cacheInfo.name)
				self._beforBattleUINums = self._beforBattleUINums -1
			end
		else
			self._beforBattleUINums=self._beforBattleUINums -1
		end
	end

	local tempFunc = function (  )
		self:clearUnusedTexture()
		if callBack then
			callBack()
		end
	end
	self:globalDelayCall(tempFunc, (length+1)/GAMEFRAMERATE )

	echo("还剩多少个ui:",#self.windowInfo)

end


--给窗口排序
function WindowControler:sortWindow(  )
	local sortFunc = function ( w1,w2 )
		return w1._cacheInfo.zorder < w2._cacheInfo.zorder
	end

	table.sort(self.windowInfo,sortFunc)

end

--等ui回复完毕
function WindowControler:onResumeComplete(  )
	self._beforBattleUINums = 0
	self._lastZorderInfo ={}
	--给窗口重新排序
	self:sortWindow()
	self:tostring()
end

--打印窗口层级
function WindowControler:tostring()
	-- echo("窗口层级信息：")
	-- for i,v in ipairs(self.windowInfo) do
	-- 	echo("name:"..v._cacheInfo.name..",zorder:"..v._cacheInfo.zorder)
	-- end
end


--当退出战斗的时候
function WindowControler:onExitBattle(  )
	--遍历所有缓存的窗口信息


	local progressActions = {}
	local perViewFrame = math.ceil( 60/#self.windowCacheInfo )
	local perPercent =  math.ceil( 100/#self.windowCacheInfo )

	local createResumeWindow = function ( cacheInfo )
		local zorder = cacheInfo.zorder
		local window = self:showWindowByRoot(cacheInfo.root,cacheInfo.name,unpack(cacheInfo.params))
		-- window:zorder(zorder)
		-- echo(zorder,"___________新的zorder",cacheInfo.name)
		self:sortWindow()
		self:tostring()
	end

	for i,v in ipairs(self.windowCacheInfo) do

		local info = {
			percent = perPercent * i,
			frame = perViewFrame,
			action =c_func(createResumeWindow, v)  --c_func(self.showWindowByRoot,self, v.root,v.name,unpack(v.params) )
		}
		if i ==#self.windowCacheInfo then
			info.percent = 100
		end
		table.insert(progressActions, info)
		-- if v.params then
		-- 	self:showWindowByRoot(v.root,v.name , unpack(v.params))
		-- else
		-- 	self:showWindowByRoot(v.root,v.name )
		-- end
	end
	self.windowCacheInfo = {}
	return progressActions
end


function WindowControler:destroyData()
	self:clearAllWindow()
	self.windowInfo = {}
end

WindowControler:init();

return WindowControler

