local ServerListView = class("ServerListView", UIBase)
local SERVER_NUM_OF_SECTION = 10
local MAX_HISTORY_SERVERS=LoginControler.MAX_HISTORY_SERVERS

local SERVER_LIST_TITLE = {
	HISTORY = "history",
	SELECT = "select",
	RECOMMAND = "recommand",
}

local sortBySortId = function(a, b)
	return tonumber(a.sortId) < tonumber(b.sortId)
end

function ServerListView:ctor(winName)
	ServerListView.super.ctor(self, winName)
end

function ServerListView:loadUIComplete()
	self:setViewAlign()
	self:registerEvent()

	self.mc_server_section:visible(false)
	self.mc_server_id:visible(false)
	local x,y = self.mc_server_recommand:getPosition()
	self.recommand_x = x
	self.recommand_y = y
	--self.panel_recommand:visible(false)
	self.mc_section_title:visible(false)

	self:initData()

	self:initServerSections()
end

function ServerListView:initData()
	--local data = self:getFakeServerInfos()
	local data = self:getServerInfos()
	self.history_servers = data.roleHistorys
	self.all_servers = data.secList

	--sort by sort id
	table.sort(self.all_servers, sortBySortId)

	self.serverid_map = {}
	local all_sections = {}

	local recommandInfo = {
		history = LoginControler:getHistoryLoginServers(true),
		latest = self:getLastestServers(),
	}

	table.insert(all_sections, recommandInfo)

	local serverListLen = #self.all_servers
	for i=1, serverListLen, SERVER_NUM_OF_SECTION do
		local secs = {}
		for j=i,i+SERVER_NUM_OF_SECTION-1 do
			if j<= serverListLen then
				local oneServerInfo = self.all_servers[j] 
				table.insert(secs, oneServerInfo)
				self.serverid_map[oneServerInfo._id] = j
			end
		end

		local info = {
			secs = secs,
			section_index = i,
		}
		table.insert(all_sections, 2, info)
	end
	self.all_sections = all_sections
end

function ServerListView:getLastestServers()
	local ret = {}
	for _,info in pairs(self.all_servers) do
		if info.new_open then
			table.insert(ret, info)
		end
	end
	return ret
end

--侧边栏服务器大区
function ServerListView:initServerSections()
	self.sectionViews = {}
	local createFunc = function(info, i)
		local view = UIBaseDef:cloneOneView(self.mc_server_section)
		view:setTouchedFunc(c_func(self.onPressServerSection, self, info, view))
		self:initOneSectionView(view, info, i)
		table.insert(self.sectionViews, view)
		return view
	end

	local params = {
		{
			data = self.all_sections,
	        createFunc = createFunc,
	        itemRect = {x=0,y=-68,width = 165,height = 68},
	        perNums= 1,
	        offsetX = 4,
	        offsetY = 15,
	        widthGap = 0,
	        heightGap = 15,
	        perFrame = 1
		}
	}
	self.scroll_server_section:styleFill(params)
	self.scroll_server_section:easeMoveto(0,0,0)
	--默认选择第一个
	self:selectServerSection(self.all_sections[1], self.sectionViews[1])
end

--初始化一个左侧栏服务器大区按钮
function ServerListView:initOneSectionView(view, info, index)
	local str = GameConfig.getLanguage("tid_login_1004")
	if index == 1 then
		--recommanded servers
	else
		local marklast = info.secs[#info.secs].mark
		local markfirst = info.secs[1].mark
		str = string.format("%s-%s服", markfirst, marklast)
	end
	view:getViewByFrame(1).btn_1:setBtnStr(str)
	view:getViewByFrame(2).btn_1:setBtnStr(str)
end

--显示右边服务器列表
function ServerListView:showServerList(info)
	if info.section_index ~= nil then
		self:showNormalServers(info)
	else
		self:showRecommandedServers(info)
	end
end

function ServerListView:showRecommandedServers(info)

	local createHistoryFunc = function(itemInfo)
		local view = UIBaseDef:cloneOneView(self.mc_server_id)
		self:initOneServerPanel(view, itemInfo, true)
		return view
	end

	local historyParams = {
		data = LoginControler:getHistoryLoginServers(true),
		createFunc = createHistoryFunc,
		itemRect = {x=0,y=-90,width = 325,height = 90},
		perNums= 2,
		offsetX = 15,
		offsetY = 25,
		widthGap = 0,
		heightGap = 25,
		perFrame = 1
	}

	local params = {}
	self.scroll_history:visible(true)
	self.scroll_server_list:visible(false)
	self:updateRecommandServerInfo(true)
	if info.history ==nil or next(info.history)==nil then
		self:showServerListTitle(SERVER_LIST_TITLE.RECOMMAND)
		self.panel_recommand:visible(false)
		self.mc_server_recommand:setPosition(cc.p(self.recommand_x, self.recommand_y+285))
	else
		params = {historyParams}
		self:showServerListTitle(SERVER_LIST_TITLE.HISTORY)
		self.scroll_history:styleFill(params)
		self.scroll_history:cancleCacheView()
		self.scroll_history:easeMoveto(0,0,0)
	end
end

function ServerListView:updateRecommandServerInfo(show)
	if show then
		self.panel_recommand:visible(true)
		self.mc_server_recommand:visible(true)
		local latest = self:getLastestServers()
		self:initOneServerPanel(self.mc_server_recommand, latest[1])
	else
		self.panel_recommand:visible(false)
		self.mc_server_recommand:visible(false)
	end
end

function ServerListView:showServerListTitle(type)
	if type == SERVER_LIST_TITLE.HISTORY then
		self.mc_section_title:showFrame(1)
	elseif type == SERVER_LIST_TITLE.SELECT then
		self.mc_section_title:showFrame(2)
		self.mc_section_title.currentView.txt_1:setString(GameConfig.getLanguage("tid_login_1005"))
	elseif type == SERVER_LIST_TITLE.RECOMMAND then
		self.mc_section_title.currentView.txt_1:setString(GameConfig.getLanguage("tid_login_1004"))
		self.mc_section_title:showFrame(2)
	end
	self.mc_section_title:visible(true)
end

function ServerListView:showNormalServers(info)
	self:showServerListTitle(SERVER_LIST_TITLE.SELECT)

	local secs = info.secs
	local createFunc = function(info)
		local view = UIBaseDef:cloneOneView(self.mc_server_id)
		self:initOneServerPanel(view, info)
		return view
	end
	table.sort(secs, function(a, b) return tonumber(a.sortId)>tonumber(b.sortId) end)

	local params = {
		{
			data = secs,
			createFunc = createFunc,
			itemRect = {x=0,y=-80,width = 325,height = 80},
			perNums= 2,
			offsetX = 15,
			offsetY = 15,
			widthGap = 0,
			heightGap = 15,
			perFrame = 1
		}
	}
	self.scroll_history:visible(false)
	self:updateRecommandServerInfo(false)
	self.scroll_server_list:visible(true)
	self.scroll_server_list:styleFill(params)
	self.scroll_server_list:easeMoveto(0,0,0)
	self.scroll_server_list:cancleCacheView()
end

function ServerListView:initOneServerPanel(view, info, isHistory)
	local server_id = nil
	local historyInfo = nil
	if isHistory then
		server_id = info.sec
		historyInfo = self.history_servers[server_id]
		local index = self.serverid_map[server_id]
		info = self.all_servers[index]
	end
	
	local index = info.sortId or ""
	local indexStr = string.format("%s服", info.mark)
	local serverName = info.name or ""
	--头像为空则不显示
	if isHistory and historyInfo.avatar~=nil and historyInfo.avatar ~= "" then
		view:showFrame(2)
		local level = historyInfo.level or 1
		view.currentView.btn_1:getUpPanel().panel_avatar.txt_1:setString(GameConfig.getLanguageWithSwap("tid_common_2015",level) )

		local avatarId = historyInfo.avatar..''
		if string.len(avatarId) == 3 then
			--icon
			local icon = FuncRes.iconAvatarHead(avatarId)
			local iconSprite = display.newSprite(icon)
			local avatarCtn = view.currentView.btn_1:getUpPanel().panel_avatar.ctn_1
			local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", avatarCtn, false, GameVars.emptyFunc)
			FuncArmature.changeBoneDisplay(iconAnim, "node", iconSprite);
		end
	else
		view:showFrame(1)
	end
	view.currentView.btn_1:setBtnStr(indexStr, 'txt_1')
	view.currentView.btn_1:setBtnStr(serverName, 'txt_2')
	view.currentView.btn_1:setTap(c_func(self.onServerSelected, self, info))
	--显示服务器状态
	local mc_status = view.currentView.btn_1:getUpPanel().mc_status
	local status_frame = LoginControler:getServerStatusKey(info)
	mc_status:showFrame(status_frame)
end


function ServerListView:onServerSelected(info)
	if not LoginControler:checkAbnormalStatus(info) then
		return
	end
	LoginControler:setServerInfo(info)	
	self:startHide()
end

function ServerListView:onPressServerSection(info, view)
	if self.scroll_server_section:isMoving() then
		return
	end
	local last_select_section = self._last_select_section
	if last_select_section == info.section_index then
		return
	else
		self._last_select_section = info.section_index
	end

	self:selectServerSection(info, view)
end

function ServerListView:selectServerSection(info, view)
	if self.currentSectionView == nil then
		self.currentSectionView = view
	else
		self.currentSectionView:showFrame(1)
		self.currentSectionView = view
	end
	view:showFrame(2)
	self:showServerList(info)
end

function ServerListView:getServerInfos()
	local data = {
		secList = LoginControler:getServerList(),
		roleHistorys = LoginControler:getHistoryLoginServers(),
	}
	return data
end

--function ServerListView:getFakeServerInfos()
--    local num = 95
--    local secList = {}
--    for i=1,num do
--        local oneInfo = {
--            _id = "id"..i, 
--            name = "test"..i, 
--            mark="s"..i,
--            sortId = i,
--            status = math.random(0,1),
--            link = "www.baidu.com",
--            openTime = os.time(),
--        }
--        table.insert(secList, oneInfo)
--    end
--    local data = {
--        secList = secList, 
--        roleHistorys = {
--            id1 = {
--                sec = "id1",
--                name = "最近1",
--                level = 1,
--                avatar = 1,
--                logoutTime = os.time()
--            },
--            id2 = {
--                sec = "id2",
--                name = "最近2",
--                level = 1,
--                avatar = 1,
--                logoutTime = os.time()
--            },
--            id3 = {
--                sec = "id3",
--                name = "最近3",
--                level = 1,
--                avatar = 1,
--                logoutTime = os.time()
--            }
--        }
--    }
--    return data
--end

function ServerListView:setViewAlign()
	FuncCommUI.setViewAlign(self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setScale9Align(self.scale9_title,UIAlignTypes.MiddleTop, 1, 0)
end

function ServerListView:registerEvent()
	self.btn_back:setTap(c_func(self.startHide, self))
end

return ServerListView

