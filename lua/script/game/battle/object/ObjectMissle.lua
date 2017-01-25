--
-- Author: XD
-- Date: 2014-07-24 10:44:47
--
ObjectMissle = class("ObjectMissle")

function ObjectMissle:ctor( hid )
     self.hid = hid

    EventEx.extend(self)
    -- 速度是常用的属性
    ObjectCommon.getPrototypeData( "battle.Missle",hid, self )
    self.curArmature = self:sta_armature()

    --记录对应的spineName
    self.spineName = FuncArmature.getSpineName(self.curArmature)
    self.speed = self:sta_speed() or 0
    self.moveType = self:sta_moveType()
        
    self.appearType = self:sta_appearType()

    --存在的帧数
    self.existFrame =  -1

    self.changeRota = self:sta_changeRota() ==1 and true or false

    if self:sta_attackId() then
        self.atkData = ObjectAttack.new(self:sta_attackId())
    end

    if self:sta_attackInfos() then
        local atkCfg = self:sta_attackInfos()
        self.attackInfos = {}
        for i,v in ipairs(atkCfg) do
            --进行一下分隔符操作 1表示攻击帧数 2表示攻击id
            self.attackInfos[i] = { numEncrypt:getNum(v.fm),  ObjectAttack.getAtkObjByHid(v.at) }
        end
    end
end

--清除
function ObjectMissle:clear(  )
    self:clearAllEvent()
end

function ObjectMissle:tostring(  )
    return "Missle--id:"..self.hid..",appearType:"..self.appearType..",speed:"..tostring(self.speed)
end

return  ObjectMissle
