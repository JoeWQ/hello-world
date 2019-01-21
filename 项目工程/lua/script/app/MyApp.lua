
require("config")
require("framework.init")
require("utils.init")

-- 根据CONFIG_ASSET_PLATFOMR的值设置asset搜索路径
local setSearchPath = function()
    local assetSearchPath = nil
    if device.platform == "mac" then
        assetSearchPath = "../../../../../svn/Resources/asset"
    elseif device.platform == "windows" then
        assetSearchPath = "asset"
    end

    if CONFIG_ASSET_PLATFOMR == nil or CONFIG_ASSET_PLATFOMR == "" or CONFIG_ASSET_PLATFOMR == "pc" then
        cc.FileUtils:getInstance():addSearchPath(assetSearchPath,true)
    else
        if device.platform == "android" or device.platform == "ios" then
            return
        end
        
        -- 强制使用大图，该类型资源没有散图
        CONFIG_USEDISPERSED = false
        assetSearchPath = assetSearchPath .. "_" .. CONFIG_ASSET_PLATFOMR
        cc.FileUtils:getInstance():addSearchPath(assetSearchPath,true) 
    end
end

setSearchPath()

if device.platform == "windows" then
    --判断是否是client目录
    if cc.FileUtils:getInstance():isFileExist("clientConfig.lua") then
        require("clientConfig")
    end
end

local originAllLoad = function()
	require("game.sys.init")
	require("app.scenes.init")
	require("game.battle.init")
	require("test.init")
	require("game.sys.view.tutorial.TutorialManager")
	require("game.sys.view.tutorial.UnforcedTutorialManager")
end

local minimumLoad = function()
    GameLuaLoader:loadGameStartupNeeded()
end

minimumLoad()
--originAllLoad()

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
    self.objects_ = {}
    self._timeClock = os.clock()
end

function MyApp:run()
    --设置帧频
    cc.Director:getInstance():setAnimationInterval(1.0/GAMEFRAMERATE )
    
    if (device.platform == "ios" or device.platform == "android") and (not SKIP_VIDEO) then
        self:init()
        WindowControler:chgScene("FullScreenVideoScene");
    else
        if not SKIP_LOGO then
            -- WindowControler:chgScene("SceneLogo");
            self:chgScene("SceneLogo")
            self:init()
        else
            self:init()
            if not DEBUG_ENTER_SCENE_TEST then
                WindowControler:chgScene("SceneMain");
            else
                WindowControler:chgScene("SceneTest");
            end
        end
    end
end

function MyApp:chgScene(sceneName)
    local scene = require("app.scenes." .. sceneName).new()

    local transitionType = nil
    if hasTransition then
        transitionType = "fade"
    end

    display.replaceScene(scene, transitionType, 0)
end

function MyApp:init()
    cc.Device:setKeepScreenOn(true)
    self:initTexturePixelFormatCfg()
    GameLuaLoader:loadFirstNeeded()
    self:doByFirst()
    --游戏启动打点
    ClientActionControler:sendNewDeviceActionToWebCenter(
        ClientActionControler.NEW_DEVICE_ACTION.LAUNCH_APP_SUCCESS);

    --发送之前木有发送成功的打点或错误日志;
    self:sendStorageFileToDataCenter();
end

--  设置材质像素格式配置
function MyApp:initTexturePixelFormatCfg()
    -- 暂时取消 ZhangYanguang 2016.12.08
    -- AppHelper:setTexturePixelFormat("anim/spine",cc.TEXTURE2D_PIXEL_FORMAT_RGBA4444)
end

--[[
    发送没有发送的数据给数据中心
    可能是之前发送失败或是出错大退了

]]
function MyApp:sendStorageFileToDataCenter()
    ClientActionControler:sendStorageFileToDataCenter();
end

function MyApp:doByFirst(  )
    -- 先加载global材质
    for i=1,3 do
        local targetPath  = "ui/global"..i
        if cc.FileUtils:getInstance():isFileExist( targetPath..".plist") then
            display.addSpriteFrames(targetPath..".plist", targetPath..CONFIG_UI_PNGTYPE)
        end
    end

end

function MyApp:setObject(id, object)
    assert(self.objects_[id] == nil, string.format("MyApp:setObject() - id \"%s\" already exists", id))
    self.objects_[id] = object
end

function MyApp:getObject(id)
    assert(self.objects_[id] ~= nil, string.format("MyApp:getObject() - id \"%s\" not exists", id))
    return self.objects_[id]
end

function MyApp:isObjectExists(id)
    return self.objects_[id] ~= nil
end

function MyApp:onEnterBackground()

    --echo("__________失去焦点")
    local timeStap,usec = pc.PCUtils:getMicroTime()
    self._lastTimeStap = timeStap
    self._lastUsec = usec

    self._timeClock = os.clock()

    --Server:handleClose()
    EventControler:dispatchEvent(SystemEvent.SYSTEMEVENT_APPENTERBACKGROUND,{time = timeStap,usec = usec} )
    --display.pause()
end


function MyApp:onEnterForeground()
    --echo("__恢复游戏焦点")
    --display.resume()
    local timeStap,usec = pc.PCUtils:getMicroTime()
    local dt = os.clock() - self._timeClock
    --恢复焦点   那么记录下 恢复时间戳和  相隔时间
    EventControler:dispatchEvent(SystemEvent.SYSTEMEVENT_APPENTERFOREGROUND ,{time = timeStap,usec = usec ,dt = dt} )
end

return MyApp
