
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
SKIP_VIDEO = true

SKIP_LOGO = true

--debug参数 到时会关掉
DEBUG = 2

-- 是否显示SceneTest界面及自动登录
-- 设置为true，在SceneTest.autoLoginConfig中填写账号、密码，可以实现自动登录
DEBUG_ENTER_SCENE_TEST = true;

-- display FPS stats on screen
DEBUG_FPS = true

--是否显示日志view
DEBUG_LOGVIEW = true 		

--是否 服务器纯跑逻辑
DEBUG_SERVICES = false

-- 1 是显示网络交互的输出日志 但是 不在 命令行里显示  2 是 又在命令行输出 又打出日志 0是什么都不输出	
DEBUG_CONNLOGS = 2 			

-- dump memory info every 10 seconds
--内存输出开关
DEBUG_MEM = false 	

--内存输出一次的时间间隔			
DEBUG_MEM_INTERVAL = 0.3

--是否加载废弃的api 		
-- load deprecated API 
LOAD_DEPRECATED_API = false
 
--是否加载扩展的api
-- load shortcodes API
LOAD_SHORTCODES_API = true

--横竖屏
-- screen orientation
CONFIG_SCREEN_ORIENTATION = "landscape"


--游戏帧率
GAMEFRAMERATE = 30

--动画播放帧率 --因为cocos armature 默认是按照60帧率播放的,所以在初始化一个动画的时候 需要设置一下动画播放速度 为0.5 
ARMATURERATE = 30

--游戏设计分辨率的宽高
GAMEWIDTH = 960
GAMEHEIGHT = 640

--游戏设计分辨率的半宽高
GAMEHALFWIDTH = GAMEWIDTH /2
GAMEHALFHEIGHT = GAMEHEIGHT /2

-- design resolution
CONFIG_SCREEN_WIDTH  = 960
CONFIG_SCREEN_HEIGHT = 640

--战斗 debug 开关
FIGHTDEBUG = true 

-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"

--是否使用散图
CONFIG_USEDISPERSED = true 		

-- pc 					Mac or Windows 使用asset下资源
-- android				使用asset_android下大图
-- ios 					使用asset_ios下大图
CONFIG_ASSET_PLATFOMR = "pc"

--ui对应的 png类型
CONFIG_UI_PNGTYPE=".png"

--1 是dev  目前 暂定 10001 为 版署包
APP_PLAT = 1 -- 1:dev

--游戏内部代号
APP_NAME = "xianpro"

RELEASE_VER = "1.0.0" --版本号名称

SHOW_CLICK_POS = true;

--是否开启新手引导
IS_OPEN_TURORIAL = false; 

IS_USE_SPINE_BINARY_CONFIG = true;

--是不是异步加载flash动画
IS_AYSNC_LOAD_ANITEX = false;

--true， gm升级弹升级界面，层级可能错误。false，该弹才弹
IS_SHOW_LEVEL_UP_VIEW_IMMEDIATELY = true


--是否显示战斗跳过
IS_SHOWBATTLESKIP = false