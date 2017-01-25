--
-- Author: XD
-- Date: 2014-07-24 10:44:47
--
--打击数据
ObjectAttack = class("ObjectAttack")

ObjectAttack.hid = nil

ObjectAttack.xChooseArr = nil
ObjectAttack.yChooseType = 0
--如果不是final攻击包
ObjectAttack.isFinal = false
--是否是第一个攻击包
ObjectAttack.isFirst = false

--伤害系数
ObjectAttack.dmgRatio = 1 

function ObjectAttack:ctor( hid )
    self.hid = hid

    ObjectCommon.getPrototypeData( "battle.Attack",hid ,self)
    self.xChooseArr = self:sta_x()
    if self.xChooseArr[1] == 0 then
    	self.xChooseArr = {1,2,3}
    end
    if self:sta_final() == 1 then
        self.isFinal = true
    end
    self.yChooseType = self:sta_y()
end


--存储所有的 atk对象
local allAttackObj ={}

--获取某个hid的攻击包
function ObjectAttack.getAtkObjByHid(hid )
    -- if not allAttackObj[hid] then
    --     allAttackObj[hid] = ObjectAttack.new(hid)
    -- end
    return ObjectAttack.new(hid)
end

--是否是最后一次攻击
function ObjectAttack:checkIsFinal(  )
    return self.isFinal
end


return  ObjectAttack
