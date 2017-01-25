--
-- Author: xd
-- Date: 2016-04-25 12:24:10
--战斗资源管理器

GameResControler = class("GameResControler")

--缓存的数组
GameResControler._textureFlaArr = {}
GameResControler._textureSpineArr = {}
GameResControler._addTextureFlaArr = {}
GameResControler._addTextureSpineArr = {}

GameResControler.onLoadComplete = nil -- 加载完资源回调函数
GameResControler.cacheTexIdx = 0 -- 缓存资源控制

GameResControler.controler = nil
--
function GameResControler:ctor(controler)
	self.controler = controler
end


--检测是否缓存了资源
function GameResControler:checkIsHasSpineRes(spbName,spineName)
	for i=1,#self._textureSpineArr do
		local spine = self._textureSpineArr[i]
		if spine[1] == spbName and spine[2] == spineName then
			return true
		end
	end
	return false
end

-- 技能.. 这儿要考虑循环创建的情况,如果创建的人物是objherohid 则不需要缓存.因为是召唤的自己分身
function GameResControler:cacheSkillSummonResource( skill, objHeroHid )
	for i,v in pairs(skill.attackInfos) do
		if v[1] == Fight.skill_type_summon then
			if v[3].hid ~= objHeroHid then
				self:cacheOneHeroResource(v[3])
			end
		end
	end
end

--缓存召唤物的资源
function GameResControler:cacheSummonResource( trea )
end

-- cache一个英雄的所有材质
function GameResControler:cacheOneHeroResource( obj,add )
	-- char表配置的默认皮肤(其实这个可以不用加,因为必定会是默认的资源)
	-- table.insert(self._textureSpineArr,obj.defArmature)
	-- 法宝的armature
	for _, trea in pairs(obj.treasures) do
		-- spine 材质
		local spineName = trea.spineName
		if spineName then --B 类法宝没有配置这个字段
			local spbName = trea.spineName

			if spineName == "0" then
				spineName = obj.defArmature 
				spbName = obj.defSpbName     
		    end
		    
		    -- 唯一资源
		    local has = self:checkIsHasSpineRes(spbName,spineName)
		    if not has then
		    	table.insert(self._textureSpineArr,{spbName,spineName})
		    	if add then
		    		table.insert(self._addTextureSpineArr,{spbName,spineName})
		    	end
		    end
		end

		-- spine 特效
		local spineArr = trea.sourceData.effSpine
		if spineArr then
			local spineEff
			for i,v in ipairs(spineArr) do
				spineEff = v
				local has = self:checkIsHasSpineRes(spineEff,spineEff)
				if not has then
					table.insert(self._textureSpineArr,{spineEff,spineEff})
					if add then
						table.insert(self._addTextureSpineArr,{spineEff,spineEff})
					end
				end
			end
		end

	    -- fla材质
	    local flaArr = trea.sourceData.fla
	    if flaArr then
	    	if type(flaArr) == "string" then
	    		flaArr = {flaArr}
	    	end
	    	for i,v in ipairs(flaArr) do
	    		local fla = v
	    		if not table.indexof(self._textureFlaArr,fla) then
		    		table.insert(self._textureFlaArr,fla)
		    		if add then
		    			table.insert(self._addTextureFlaArr,fla)
		    		end
		    	end
	    	end

	    	
	    end

	    -- 技能资源一定在spine中或者fla中, 特殊的就是召唤物
	    -- 计算召唤物
	    self:cacheSummonResource(trea)
	end
end


-- 额外缓存一个英雄的材质
function GameResControler:addCacheOneResource(obj,frames)
	self:cacheOneHeroResource(obj,true)
	echo("________________新加入人的资源",obj.hid,frames,#self._addTextureSpineArr,#self._addTextureFlaArr)
	for i=1,#self._addTextureSpineArr do
		local spbName = self._addTextureSpineArr[i][1]
		local spineName = self._addTextureSpineArr[i][2]
		pc.PCSkeletonDataCache:getInstance():SkeletonDataPreLoad(FuncRes.spine(spbName,spineName))
	end
	for i=1,#self._addTextureFlaArr do
		FuncArmature.loadOneArmatureTexture(self._addTextureFlaArr[i] ,nil ,true)
	end
end


--资源管理器 初始化 通过 battleInfo 加载材质, onLoadComplete,材质加载完成的回调
function GameResControler:cacheResource( allObjArr,onLoadComplete )
	--echo("_________cacheResource_____________缓存资源")
	self.onLoadComplete = onLoadComplete

	--增加UI击杀 特效  gaoshuang  add
	-- 缓存公共资源
	local flaArr = {
		"eff_buff_bing","UI_jishajiangli","UI_main_img_shou",
		"UI_dazhaotishi",
		-- "eff_buff_gongjili","eff_buff_jiafanghudun",
		-- "eff_buff_jiafangyuli","eff_buff_jianfang","eff_buff_xuanyun",
		}
	self._textureFlaArr = clone(flaArr)

	local spineArr = {
		"eff_treasure0"
		}
	for i=1,#spineArr do
		table.insert(self._textureSpineArr,{spineArr[i],spineArr[i]})
	end

	-- 计算法宝资源
	for h, v in pairs(allObjArr) do
		self:cacheOneHeroResource(v)	
	end


	--dump(self._textureSpineArr,"战斗spine资源")
	--dump(self._textureFlaArr,"战斗flash资源")

	-- 缓存资源
	self.cacheTexIdx = 1
	self.controler._sceenRoot:delayCall(handler(self, self.cacheSpineTextureByFrame),Fight.frame_time)
end


-- 分帧加载资源
function GameResControler:cacheSpineTextureByFrame()
	local spineAni = self._textureSpineArr[self.cacheTexIdx]

	pc.PCSkeletonDataCache:getInstance():SkeletonDataPreLoad(FuncRes.spine(spineAni[1],spineAni[2]))
	
	self.cacheTexIdx = self.cacheTexIdx + 1
	if self.cacheTexIdx > #self._textureSpineArr then
		self.cacheTexIdx = 1
		self:cacheFlaTextureByFrame()
	else
		self.controler._sceenRoot:delayCall(handler(self, self.cacheSpineTextureByFrame),Fight.frame_time)
	end
end

-- 分帧加载资源
function GameResControler:cacheFlaTextureByFrame()
	--ViewArmature.cacheOneTexture(self._textureFlaArr[self.cacheTexIdx])
	--synchro 是否是 同步加载资源  false 是异步加载 true 是同步加载
	FuncArmature.loadOneArmatureTexture(self._textureFlaArr[self.cacheTexIdx] ,nil ,true)

	self.cacheTexIdx = self.cacheTexIdx + 1
	if self.cacheTexIdx > #self._textureFlaArr then
		self.onLoadComplete()
	else
		self.controler._sceenRoot:delayCall(handler(self, self.cacheFlaTextureByFrame),Fight.frame_time)
	end
end


--清除材质.(但是本主角的材质不能删除)
function GameResControler:clearResource(  )
	--echo("_____________clearResource___________释放缓存的资源")
	local avatar = 1
	local level = 1
	-- local spbName,spineName = FuncChar.getSpineAniName( avatar, level)

	for i=#self._textureSpineArr,1,-1 do
		local spine = self._textureSpineArr[i]
		-- if spine[1] ~= spbName or spine[2] ~= spineName then
		-- 	pc.PCSkeletonDataCache:getInstance():clearCacheByFileName(FuncRes.spine(spine[1],spine[2]));
		-- end
		pc.PCSkeletonDataCache:getInstance():clearCacheByFileName(FuncRes.spine(spine[1],spine[2]));
	end

	for i=#self._textureFlaArr,1,-1 do	
	end


	self._textureSpineArr = nil
	self._textureFlaArr = nil

	-- 清除缓存的特效
	ViewArmature:clearArmatureCache()
	ViewSpine:clearSpineCache()
end


return GameResControler



-- 资源备份中.. 
-- -- spineArr
-- self.spineArr = {
-- 	"treasure_a1","treasure_a2","treasure_a3","treasure_b1","treasure_b2","treasure_b3",
-- 	"10001_caoYao","20001_shanShen","10003_dengLongGuai","10002_huDieYao","30001_wuHou",
-- 	}

-- --需要加载的材质数组 固定会加载的 肯定有
-- self.flaArr = {
-- 	"UI_battle","common","treasure0","treasure00","enemy10002","enemy10003","enemy20001",
-- 	"treasure101","treasure102","treasure103","treasure104","treasure105","treasure106","treasure107",
-- 	"treasure201","treasure202","treasure204","treasure205","treasure206","treasure207","treasure209","treasure210","treasure211",
-- 	"treasure305","treasure322","xueshi","TreaGiveOut","enemy_30002A",
-- }	

