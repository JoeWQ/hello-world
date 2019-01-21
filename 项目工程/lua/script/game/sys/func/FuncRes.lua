FuncRes=FuncRes or {}


--目前动画材质的类型 配备为 png
FuncRes.armatureTextType = "png"
-- FuncRes.armatureTextType = "pvr.ccz"

-- 目前动画配置文件的类型
-- FuncRes.armatureFileType = "xml"
FuncRes.armatureFileType = "bobj"

FuncRes.pngSuffix = ".png"
--获取NPC图标和相关的对话内容
function        FuncRes.getNpcIconDialog(_id)
         return      FuncCommon.getNpcIconDialog(_id);
end
--获取某个map名称
function FuncRes.map(image )
	return "map/"..image
end

--获取某个icon路径
function FuncRes.icon( image )
	return "icon/"..image
end

--[[
获取boss多血条图片
]]
function FuncRes.iconBar( image )
    return "icon/bar/"..image
end

--创建纯黑背景
function FuncRes.a_black( wid,hei,alpha )
    alpha = alpha or 255
    local sp = display.newSprite("a/a2_4.png",0,0)

    local scaleX=wid and wid/4 or 1
    local scaleY = hei and hei/4 or 1

    sp:setScaleX(scaleX)
    sp:setScaleY(scaleY)
    return sp
end

--创建纯白背景
function FuncRes.a_white( wid,hei)
    alpha = alpha or 255
    local sp = display.newSprite("a/a1_4.png")
    sp:opacity(alpha)
    local scaleX=wid and wid/4 or 1
    local scaleY = hei and hei/4 or 1

    sp:setScaleX(scaleX)
    sp:setScaleY(scaleY)
    return sp
end

function FuncRes.a_alpha( wid,hei)
    local sp = display.newSprite("a/a0_4.png")
    local scaleX=wid and wid/4 or 1
    local scaleY = hei and hei/4 or 1

    sp:setScaleX(scaleX)
    sp:setScaleY(scaleY)

    return sp
end

-- 获取资源icon
function FuncRes.iconRes(resType,resId)
    if resType == nil or resType == "" then
        echo("FuncRes.iconRes not found resType=",resType,resId)
        return nil
    end

    local basePath = "icon/res/"

    local iconPath = nil
    local rType = tostring(resType)
    if rType == UserModel.RES_TYPE.ITEM then
        local itemId = resId

        if ItemsModel:isTreasurePiece(resType, itemId) == true then 
            iconPath = FuncRes.iconTreasure(itemId);
        elseif ItemsModel:isPartnerPiece(resType, itemId) == true then
            iconPath = FuncRes.partnerIcon(itemId);
        else 
            iconPath = FuncRes.iconItem(itemId)
        end 

    elseif rType == UserModel.RES_TYPE.TREASURE then
        local treasureId = resId
        iconPath = FuncRes.iconTreasure(treasureId)
    else
        iconPath = FuncDataResource.getIconPathById(resType)
        if iconPath == nil or iconPath == "" then
            iconPath = basePath .. "ResIconTemp.png"
        else
            iconPath = basePath .. iconPath
        end
    end

    return iconPath
end

-- pve图标
function FuncRes.iconPVE(bgName)
    local basePath = "icon/pve/"
    local tempIcon = basePath .. "temp.png"

    local imagePath = FuncRes.getImagePath(basePath,bgName,tempIcon)
    return imagePath
end

-- buff图标
function FuncRes.iconBuff(image)
    local basePath = "icon/buff/"
    local tempIcon = basePath .. "temp.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--获取途径icon 
function FuncRes.iconWay( image )
    local basePath = "icon/way/"
    local tempIcon = basePath .. "WayIconTemp.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--获取bar 
function FuncRes.bar( image )
    local basePath = "icon/bar/"
    local tempIcon = basePath .. "BarIconTemp.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--英雄图标
function FuncRes.iconHero( image )
    local basePath = "icon/head/"
    local tempIcon = basePath .. "HeadIconTemp.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--法宝
function FuncRes.iconTreasure( treasureId )
    local basePath = "icon/treasure/"
    local tempIcon = basePath .. "TreasureIconTemp.png"
    
    local iconName = FuncTreasure.getIconPathById(treasureId)
    local imagePath = FuncRes.getImagePath(basePath,iconName,tempIcon)
    return imagePath
end

--那女猪脚半身像 1:男,2:nv
function FuncRes.iconChar( sex )
    local basePath = "icon/char/"
    local tempIcon = basePath .. "char_nv.png"
    
    local iconName = "char_nv.png";

    if sex == 1 then 
        iconName = "char_nan.png";
    end 

    local imagePath = FuncRes.getImagePath(basePath, iconName, tempIcon)
    return imagePath
end

--敌人法宝
function FuncRes.iconEnemyTreasure( image )
    local basePath = "icon/treasure/"
    local tempIcon = basePath .. "TreasureIconTemp.png"
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--//本命法宝,天赋,输入的是天赋法宝的图标名字
function FuncRes.iconTalent( _iconName)
    local basePath = "icon/treasure/"
    local tempIcon = basePath .. "TreasureIconTemp.png"
    
    local imagePath = FuncRes.getImagePath(basePath,_iconName,tempIcon)
    return imagePath
end
-- item图标
function FuncRes.iconItem(itemId)
    local basePath = "icon/item/"
    local tempIcon = basePath .. "ItemIconTemp.png"

    local iconName = FuncItem.getIconPathById(itemId)
    local imagePath = FuncRes.getImagePath(basePath,iconName,tempIcon)
    return imagePath
end

-- item图标
function FuncRes.iconItemWithImage(image)
    local basePath = "icon/item/"
    local tempIcon = basePath .. "ItemIconTemp.png"

    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon);
    return imagePath
end
-- 伙伴装备图标
function FuncRes.iconPartnerEquipment(image)
    local basePath = "icon/equipment/"
    local tempIcon = basePath .. "img_Icon4022.png"

    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon);
    return imagePath
end
--guild icon
function FuncRes.iconGuild(image)
    local basePath = "icon/guild/"
    local tempIcon = basePath .. "GuildIconTemp.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--获取背景
function FuncRes.iconBg( image )
    local basePath = "bg/"
    local tempIcon = basePath .. "bgTemp.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--获得新手指引箭头
function FuncRes.iconGuide(arrowName)
    local basePath = "icon/guide/"
    local tempIcon = basePath .. "weapon_203.png"

    local imagePath = FuncRes.getImagePath(basePath, arrowName, tempIcon)
    return imagePath
end

--shade
function FuncRes.getShade(image)
    local basePath = "icon/shade/"
    local tempIcon = basePath .. "ShadeIconTemp.png"
    
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--获取头像及npc头像
function FuncRes.iconHead( image )
    local basePath = "icon/head/"
    local tempIcon = basePath .. "HeadIconTemp.png"
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--获取伙伴头像
function FuncRes.partnerIcon(partnerId)
    local _partnerInfo = FuncPartner.getPartnerById(partnerId);
    if _partnerInfo then
        local _iconPath = FuncRes.iconHero(_partnerInfo.icon)
        return _iconPath
    else
        echoError("没有找到".. partnerId .."数据")
    end
end

-- npc动画
function FuncRes.npcAnim(npcAnimFileName,label)
    local animFileName = npcAnimFileName or "art_Spine30005"
    local animLabel = label or "stand"

    local npcAnim = ViewSpine.new(animFileName, {}, animFileName);
    npcAnim:playLabel(animLabel)
    return npcAnim
end

--英雄的头像
function FuncRes.iconAvatarHead(hid)
	local iconName = FuncChar.getHeroAvatar(hid)
	return FuncRes.iconHead(iconName)
end


--获取其他icon
function FuncRes.iconOther( image )
    local basePath = "icon/other/"
    local tempIcon = basePath .. "OtherTemp.png"
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--获取系统icon
function FuncRes.iconSys( image )
    local basePath = "icon/systemIcon/"
    local tempIcon = basePath .. "tempIcon.png"
    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon)
    return imagePath
end


-- 获取image路径
function FuncRes.getImagePath(basePath,image,tempIcon)
    if basePath == nil or image == nil then
        return tempIcon
    end

	if not string.find(image, FuncRes.pngSuffix) then
		image = image..FuncRes.pngSuffix
	end
    local path = basePath .. image

	if FS.exists(path) then
		return path
	end

    echoWarn("FuncRes.getImagePath " .. basePath .. "" .. image .. " not found")
    return tempIcon

    -- if FS.exists(path) then
    --     return path
    -- else
    --     path = path .. FuncRes.pngSuffix
    --     if FS.exists(path) then
    --         return path
    --     end

    --     echoWarn(basePath .. "" .. image .. " not found")

    --     return tempIcon
    -- end
end

function FuncRes.getParticlePath()
	return "anim/particle/"
end

--获取某个动画的路径 分别返回  图片url  plist  和 xml
function FuncRes.armature( name )
    local textureFile = "anim/armature/"..name.."." ..FuncRes.armatureTextType
    local plistFile = "anim/armature/"..name..".plist"
    local xmlFile = "anim/armature/"..name.."."..FuncRes.armatureFileType
    return textureFile,plistFile,xmlFile
end

--获取spine动画路径
function FuncRes.spine( name, atlasName )
    local foder = "anim/spine/"

    atlasName = atlasName or name;

    local atlasName = foder..atlasName..".atlas";
    local configName = nil;

    if IS_USE_SPINE_BINARY_CONFIG == true then 
        --测试用，先放在这
        pc.PCSkeletonDataCache:getInstance():setIsUseBinaryConfig(true);

        configName = foder..name..".spb";
    else  
        --默认是这个，所以不用设置
        -- pc.PCSkeletonDataCache:getInstance():setIsUseBinaryConfig(false);
        configName = foder..name..".json";
    end 

    if not cc.FileUtils:getInstance():isFileExist(atlasName) then 
        assert(false, "FuncRes.spine atlasName " .. tostring(atlasName) .. " is not exist!");
    end 

    if not cc.FileUtils:getInstance():isFileExist(configName) then 
        assert(false, "FuncRes.spine configName " .. tostring(configName) .. " is not exist!");
    end 

    return configName, atlasName;
end
--获取spine立绘路径
 function FuncRes.artPath( name )
--    local foder = "anim/spine/" 
    return FuncRes.spine(name)
end
--获取spine立绘 默认步行
function FuncRes.getArtSpineAni( resName )
     local _json,_atlas = FuncRes.artPath(resName)
     if cc.FileUtils:getInstance():isFileExist(_atlas) then
         local skeletonNode = pc.PCSkeletonAnimation:createWithFile(_json, _atlas, 1);
         skeletonNode:setAnimation(0, "stand", true); 
         return skeletonNode
     end 
     return nil 
end 
--字体目录
function FuncRes.fnt( fnt )
    return "fnt/"..fnt
end

--ui目录
function FuncRes.ui(name )
    return "ui/"..name
end

--ui散图目录
function FuncRes.uipng(name )
    if string.sub(name,-4,-1) ~= ".png" then
        name = name ..".png"
    end
    --如果是用散图
    if CONFIG_USEDISPERSED then
        return "uipng/"..name
    end
    --那么直接返回这个ui图片对应的材质集
    return "#"..name
end


function FuncRes.test( name )
    return "test/"..name
end

function FuncRes.playerBigImg(image)
	return "icon/player/"..image
end

-- 获取灵宝ICON
function FuncRes.iconLingBao(image)
	return "icon/lingbao/"..image
end

-- 获取功法ICON
function FuncRes.iconSkill(image)
	-- return "icon/skill/"..image
    local basePath = "icon/skill/"
    local tempIcon = basePath .. "skill_st1.png"
    
    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon)
    return imagePath
end

--获取case
function FuncRes.iconTreasureCase(quality,color)
    local image = "treasure_case_"..quality.."_"..color
    local basePath = "icon/case/"
    local tempIcon = basePath .. "treasure_case_1_1.png"
    
    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon)
    return imagePath
end


--主界面功能 npc icon
function FuncRes.iconIconHome(image)
    -- return "icon/skill/"..image
    local basePath = "icon/home/"
    local tempIcon = basePath .. "main_img_zhubao.png"
    
    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon)
    return imagePath
end



--加载一个ui材质集 不包含后缀名
function FuncRes.addOneUITexture( textureName ,handler )
    local plistUrl = "ui/"..textureName..".plist"
    local pngUrl = "ui/"..textureName.. CONFIG_UI_PNGTYPE
    if cc.FileUtils:getInstance():isFileExist(plistUrl) then
        display.addSpriteFrames(plistUrl, pngUrl, handler)
    end
    
end

--移除一个ui材质集 
function FuncRes.removeOneUITexture( textureName )
    local plistUrl = "ui/"..textureName..".plist"
    local pngUrl = "ui/"..textureName.. CONFIG_UI_PNGTYPE
    if cc.FileUtils:getInstance():isFileExist(plistUrl) then
        display.removeSpriteFramesWithFile(plistUrl, pngUrl)
    end
end

--移除背景
function FuncRes.removeBgTexture( bgName )
    if string.sub(bgName,-4,-1) ==".png" then
        bgName = string.sub(bgName,1,-5)
    end
    local plistUrl = "bg/"..bgName..".plist"
    local pngUrl = "bg/"..bgName.. CONFIG_UI_PNGTYPE
    cc.Director:getInstance():getTextureCache():removeTextureForKey(pngUrl)
end

--移除map场景
function FuncRes.removeMapTexture( mapName )
    display.removeSpriteFramesWithFile("map/"..mapName..".plist","map/"..mapName..CONFIG_UI_PNGTYPE)
    
    local anires = FuncRes.armature(mapName)
    if  (cc.FileUtils:getInstance():isFileExist(anires ))  then
        FuncArmature.clearOneArmatureTexture(mapName,true)
        echo("移除场景动画："..mapName..".bobj" );
    end
end

--添加场景材质
function FuncRes.addMapTexture( mapName )
    display.addSpriteFrames("map/"..mapName..".plist", "map/"..mapName..CONFIG_UI_PNGTYPE)
    local anires = FuncRes.armature(mapName)
    if  (cc.FileUtils:getInstance():isFileExist(anires ))  then
        FuncArmature.loadOneArmatureTexture(mapName,nil,true)
    end
end