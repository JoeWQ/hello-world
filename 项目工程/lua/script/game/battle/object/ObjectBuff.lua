--
-- Author: XD
-- Date: 2014-07-24 10:44:47
--
--打击数据
ObjectBuff = class("ObjectBuff")

ObjectBuff.hid = nil
ObjectBuff.time = -1 --剩余作用时间(回合 -1表示永久)
ObjectBuff.initTime = -1 	--初始化的作用时间 --用来刷新buff

ObjectBuff.hero = nil 	--buff的释放着
ObjectBuff.useHero = nil 	--buff的作用着 
ObjectBuff.aniArr = nil 	--特效数组
ObjectBuff.enterAniArr = nil    --出场特效数据
ObjectBuff.endAniArr = nil    --结束特效数组
ObjectBuff.runType = 1 		--执行时机  1 是立刻执行 2 是回合开始前执行
ObjectBuff.ratio = 10000      --触发概率
function ObjectBuff:ctor( hid,skill )
    self.hid = hid
    ObjectCommon.getPrototypeData("battle.Buff",hid,self)
    self.type = self:sta_type()
    self.time = self:sta_time() or -1
    --如果是复活 不走 time
    if self.type == Fight.buffType_relive  then
        self.time = -1
    end

    self.runType = self:sta_runType() or Fight.buffRunType_now
    self.value = self:sta_value()
    self.changeType = self:sta_changeType()
    -- self.kind = self:sta_kind()

    self.replace = self:sta_replace()
    self.ratio = self:sta_ratio() or 10000
    self.skill = skill
    --如果小于0 那么表示是数值是走技能
    if self.ratio < 0 then
        local index = math.abs(self.ratio)
        local skillParams = skill.skillParams
        skillParams = skillParams or {}
        self.ratio = skillParams[index]
        if not self.ratio then
            echoError("这个buff没有找到对应的技能参数,hid:",self.hid,"参数序号:",index,'技能hid:',skill.hid)
            self.ratio = 10000
        end
    end
    if not self.replace then
    	self.replace = Fight.buffMulty_all
    end
 --    if self.time > 0 then
	-- 	self.time = self.time + 1
	-- end
    self.initTime = self.time
    --如果是比例 那么需要除以100
    if self.changeType == 2 then
    	self.value = self.value / 100
    end

    --扩展参数
    self.expandParams = self:sta_expandP()
    
    --判断复活参数
    self:checkReliveParams()
    self:checkKind()
end

function ObjectBuff:checkKind(  )
    local buffType = self.type
    local haoOrHuai = false
    if buffType == Fight.buffType_xuanyun  or buffType == Fight.buffType_chenmo 
        or buffType == Fight.buffType_xuanyun  or  buffType == Fight.buffType_bingdong  
        or bufftype == Fight.buffType_DOT 
     then
        haoOrHuai = false 
    elseif buffType == Fight.buffType_wudi  or buffType == Fight.buffType_relive 
        or buffType == Fight.buffType_HOT or buffType == Fight.buffType_bati 
        then
        haoOrHuai = true
    else
        local value  = self.value
        if not value then
            haoOrHuai = true
        else
            haoOrHuai = value > 0 and true or false
        end

    end

    --判断回合
    --如果是-1 表示光环
    if self.time == -1 then
        if haoOrHuai == true then
            self.kind = Fight.buffKind_aura 
        else
            self.kind = Fight.buffKind_aurahuai 
        end
    else
        if haoOrHuai ==true then
            self.kind = Fight.buffKind_hao 
        else
            self.kind = Fight.buffKind_huai 
        end
    end

    -- echo(self.kind,self.value,self.time,self.type,self.hid,"___________自动判定buffkind")
end


function ObjectBuff:checkReliveParams(  )
    if self.type == Fight.buffType_relive  then
        if not self.expandParams  then
            echoWarn("复活buff参数配置错误id:",self.hid)
            return 
        end
    end
    if not self.expandParams then
        return
    end
    local oldParams = self.expandParams
    --数据克隆一次
    self.expandParams = table.copy(oldParams)
    --判断是否需要动态取值得的
    --如果血量是要取百分比的
    if self.expandParams[2] < 0 then
        self.expandParams[2] = self.skill.skillParams[math.abs(oldParams[2])]
        if not self.expandParams[2] then
            dump(self.skill.skillParams,"__技能伤害参数")
            echoWarn("技能id:%s,伤害参数位置:%d 复活buff没有配置对应的生命系数,buffid:%s",self.skill.hid,oldParams[2])
        end
        if self.expandParams[1] == Fight.valueChangeType_ratio  then
            self.expandParams[2] = self.expandParams[2]/10000
        end
    end

    if self.expandParams[4] < 0 then
        self.expandParams[4] = self.skill.skillParams[math.abs(oldParams[4])]
        if not self.expandParams[4] then
            dump(self.skill.skillParams,"__技能伤害参数")
            echoWarn("技能id:%s,伤害参数位置:%d配置,复活buff没有配置对应的怒气系数, buffid:%s",self.skill.hid,oldParams[4])
        end
         if self.expandParams[3] == Fight.valueChangeType_ratio  then
            self.expandParams[4] = self.expandParams[4]/10000
        end
    end
end


--判断是否是光环
function ObjectBuff:checkIsAura(  )
	return self.kind == Fight.buffKind_aura  or self.kind == Fight.buffKind_aurahuai 
end

function ObjectBuff:tostring( )
    return "Buff--id:"..self.id..",type:"..self.type..",chooseType:"..self.value..",ani:"..tostring(self.ani)
end
--使用buff
function ObjectBuff:useBuff( )
	-- body
end

--清除buff
function ObjectBuff:clearBuff(  )
    if self:sta_endAni() then
        if self.useHero then
            self.useHero:createEffGroup(self:sta_endAni(),false,true)
        end
        
    end
	self:deleteMe()
end

--清除这个buff
function ObjectBuff:deleteMe()
	if self.aniArr then
		for k,v in pairs(self.aniArr) do
			--必须这个特效没有被干掉 
			if not v._isDied then
				v:deleteMe()
			end
		end
		self.aniArr = nil
	end
	self.hero = nil
    self.useHero = nil
end


return  ObjectBuff
