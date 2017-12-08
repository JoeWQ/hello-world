local LoginLoadingView = class("LoginLoadingView", UIBase)

function LoginLoadingView:ctor(winName)
	LoginLoadingView.super.ctor(self, winName)
end

function LoginLoadingView:loadUIComplete()
	self:setViewAlign()
	self:registerEvent()

	self:scheduleUpdateWithPriorityLua(c_func(self.frameUpdate, self) ,1)

	self.progress_bar = self.panel_loading_progress.panel_1.progress_1
	self.progress_cloud = self.panel_loading_progress.panel_1.panel_cloud
	self.progress_panel_box = self.panel_loading_progress:getContainerBox()
	self.txt_progress = self.panel_loading_progress.panel_1.txt_1
	self._tip_str = GameConfig.getLanguage('tid_update_1001')
	self.txt_progress:setString("5%")
	self.progress_bar:setPercent(5)

	self:initCommonRes()
    self:addLodingAni()

    --走更新流程
	self:checkVersion()
end

function LoginLoadingView:initCommonRes()
	local scene = WindowControler:getCurrScene()
	scene:initCommonRes()
end

function LoginLoadingView:addLodingAni()
    local loadingAniName = FuncCommon.getLoadingAniName()
    self.loadingAni1 = self:createUIArmature("UI_zhuanjuhua", loadingAniName, nil, true, GameVars.emptyFunc):addto(self.panel_loading_progress.ctn_aciton1)
    self.loadingAni2 = self:createUIArmature("UI_startLoading", "UI_startLoading", nil, true, GameVars.emptyFunc):addto(self.panel_loading_progress.ctn_aciton1)
    self.loadingAni2:setPositionY(self.loadingAni2:getPositionY()-18)
end

function LoginLoadingView:tallWebCenterNewDeviceUpdateSuccess()
	
end

function LoginLoadingView:frameUpdate()
	self:updateProgressCloud()
	self:updateTipStr()
end

function LoginLoadingView:setViewAlign()
	FuncCommUI.setViewAlign(self.txt_1, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.panel_loading_progress, UIAlignTypes.MiddleBottom)
end

function LoginLoadingView:updateTipStr()
	if self._tip_str then
		self.txt_1:setString(self._tip_str)
	end
end

function LoginLoadingView:checkVersion()
	VersionControler:checkVersion()
end

function LoginLoadingView:updateProgressCloud()
	local box = self.progress_panel_box
	local totalWidth = box.width
	local percent = self.progress_bar:getPercent()
	self.txt_progress:setString(math.ceil(percent).."%")
	self.progress_cloud:pos(math.ceil(percent)*1.0/100 * totalWidth-15, -box.height/2)
end

function LoginLoadingView:registerEvent()
	EventControler:addEventListener(VersionEvent.VERSIONEVENT_CHECK_VERSION, self.onVersionCheckOk, self)
	EventControler:addEventListener(VersionEvent.VERSIONEVENT_UPDATE_PACKAGE, self.onVersionUpdatePackage, self)
end

function LoginLoadingView:retryCheckVersion()
	VersionControler:checkVersion()
end

function LoginLoadingView:onVersionCheckOk(event)
	local params = event.params
	local code = params.code
	local VERSION_CODES = VersionControler.CHECK_VERSION_CODE
	if code == VERSION_CODES.CODE_NO_UPDATE then -- 不需要更新
		self._tip_str = GameConfig.getLanguage("tid_update_1003")
		self.progress_bar:tweenToPercent(100, 20, c_func(self.onUpdateEnd, self, false))

	elseif code == VERSION_CODES.CODE_DO_UPDATE then -- 需要更新
		self._have_update_package= true
		self._tip_str = GameConfig.getLanguage("tid_update_1004")
		self.progress_bar:tweenToPercent(20, 5)

	elseif code == VERSION_CODES.CODE_DOWNLOAD_NEW_CLIENT  					--新客户端[目前不支持]
		   or code == VERSION_CODES.CODE_MAINTAIN_SERVER   					--维护
		   or code == VERSION_CODES.CODE_BACK_TO_TARGET_VERSION				--灰度更新失败
		   or code == VERSION_CODES.CODE_CLIENT_VERSION_NOT_EXIST 			--客户端版本在服务端不存在
		   or code == VERSION_CODES.CODE_NETWORK_ERROR 						--网络错误
		   or code == VERSION_CODES.CODE_OTHER_ERROR 						--其他未知错误
		then 
		
		self:showUpdateException(code)
	end

	--告诉数据中心完成检测有没有更新
	ClientActionControler:sendNewDeviceActionToWebCenter(
		ClientActionControler.NEW_DEVICE_ACTION.CHECK_UPDATE_SUCCESS);
end

function LoginLoadingView:onVersionUpdatePackage(event)
	local params = event.params
	local code = params.code
	local UPDATE_CODES = VersionControler.UPDATE_PACKAGE_CODE 

	if code == UPDATE_CODES.CODE_PREPARE_DOWNLOAD then --准备下载zip
		self._fileCount = params.totalFileCount --下载文件数
		self._fileSize = params.totalFileSize --下载文件总大小

	elseif code == UPDATE_CODES.CODE_DOWNLOADING then
		--正在下载zip
		local percent = 0
		if params.percent and params.percent ~= "" then
			percent = params.percent
		end

		self._tip_str = GameConfig.getLanguage("tid_update_1002")
		local percent = 20 + (100-20) * percent*1.0/100
		self.progress_bar:tweenToPercent(percent, 5)

	elseif code == UPDATE_CODES.CODE_DOWNLOAD_ZIP_FAILURE then
	 	--下载zip失败
		self:showUpdateException(code)

	elseif code == UPDATE_CODES.CODE_UNZIP_ERROR then
		--解压zip失败
		self:showUpdateException(code)
	elseif code == UPDATE_CODES.CODE_BACK_VERSION_NOT_FOUND then 
		--灰度回滚，没有找到版本---
		-- Zhangyanguang 2016-06-30
		self._tip_str = GameConfig.getLanguage("tid_update_1003")
		self:delayCall(c_func(self.onUpdateEnd, self), 0.2)

	elseif code == UPDATE_CODES.CODE_UPDATE_DOWNLOAD_COMPLETE then 
		-- 下载安装包及安装完成
		self._tip_str = GameConfig.getLanguage("tid_update_1003")
		self:delayCall(c_func(self.onUpdateEnd, self), 0.2)

	elseif code == UPDATE_CODES.CODE_UPDATE_COMPLETE then 
		--更新完成
		self._tip_str = GameConfig.getLanguage("tid_update_1003")
		self:delayCall(c_func(self.onUpdateEnd, self), 0.2)

	elseif code == UPDATE_CODES.CODE_UPDATE_VERSION_COMPLETE then
		 --更新完成，只更新了版本号，没有任何脚本或资源变化
		self._have_update_package = false
		self._tip_str = GameConfig.getLanguage("tid_update_1003")
		self:delayCall(c_func(self.onUpdateEnd, self), 0.2)

	elseif code == UPDATE_CODES.CODE_DOWNLOAD_PARAM_ERROR then 
		--下载参数错误
		self:showUpdateException(code)

	elseif code == UPDATE_CODES.CODE_NO_RES_CHANGE_COMPLETE then
		-- 没有资源变更，更新完成
		self:onSimulateUpdateEnd()
	end
end

function LoginLoadingView:showUpdateException(code)
	self:delayCall(c_func(self.onUpdateException, self,code), 0.3)
end

function LoginLoadingView:onUpdateException(code)
	WindowControler:showWindow("LoginUpdateExceptionView", self,code)
end

-- 没有资源更新，模拟进度
function LoginLoadingView:onSimulateUpdateEnd(_frame)
	local frame = _frame or 10
	self.progress_bar:tweenToPercent(100, frame, c_func(self.onProgressEnd, self))
end

function LoginLoadingView:onUpdateEnd(isUpdate)
	--告诉数据中心内更完成
	ClientActionControler:sendNewDeviceActionToWebCenter(
		ClientActionControler.NEW_DEVICE_ACTION.DO_UPDATE_SUCCESS);
	
	self:startHide()
	if self._have_update_package then
		GameLuaLoader:clearModules()
	else
		WindowControler:showWindow("EnterGameView")
	end
end

--不走更新流程的过程
function LoginLoadingView:onProgressEnd()
	self:startHide()
	WindowControler:showWindow("EnterGameView")
end

return LoginLoadingView

