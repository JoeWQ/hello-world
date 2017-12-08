-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local CombineControl = { }



function CombineControl:ctor()
    self.view = nil
end  

function CombineControl:showWindow()
    self.view = WindowControler:showWindow("CombineView", self, { bgAlpha = 0 }); 
    self.view:initData()
     
    return self.view
end 
--材料改变影响主UI 红点提示显示消息
function CombineControl:cailiaoChangeCallBack()
      local canCombine = self:isHaveCanCombineTreasure();
      EventControler:dispatchEvent(CombineEvent.OPERATION_STATE_CHANGE,
	        {isShow = canCombine});	
end
--满足合成法宝条件的碎片
function CombineControl:canCombineTreasure()
    local allCombineTreasue = self:sortTeasureItemData()
    local canCombineTreasue = {}
    for i,v in pairs(allCombineTreasue) do
        if v.isSatisfy then
            table.insert(canCombineTreasue,v)
        end
    end
    return canCombineTreasue
end

--有没有能合成的法宝，true有 false没有
function CombineControl:isHaveCanCombineTreasure()
    return table.length(self:canCombineTreasure()) ~= 0 and true or false;
end

function CombineControl:checkCombineState()
  return self:sortTeasureItemData()
end 
-- 排序 Temp
function CombineControl:sortTeasureItemData()
    local _data = self:getTeasureData() or { }
    table.sort(_data,function(a,b)
        return a.quality>b.quality
    end)
    local _a = { }
    local _b = { }

    for i = 1, #_data do
        if _data[i].isSatisfy then
            table.insert(_a, _data[i])
        else
            table.insert(_b, _data[i])
        end
    end

    for i = 1, #_b do
        table.insert(_a, _b[i])
    end

    return _a
end 
--  通过碎片获取相关的合成数据
function CombineControl:getTeasureData()
    -- 拥有的法宝碎片 {id ,num}
    local _treasureData = TreasuresModel:getAllTreasureFragmentsInBag() or { }
    local _newData = { }
    if _G.next(_treasureData) ~= nil then
        local _myTreasuresVer = TreasuresModel:getAllTreasure()
        -- 遍历当前拥有的碎片
        for i = 1, #_treasureData do
            if _myTreasuresVer[_treasureData[i].id] == nil then --已经拥有的整法宝不再进行合成
                local _itemInfo = self:getTeasureItemData(_treasureData[i].id, _treasureData[i].num)
                table.insert(_newData, _itemInfo)
            end
        end
    end
    return _newData
end

-- 通过ID 判断是否拥有此法宝
function CombineControl:isHasThisTreasureById(_mId)
    -- 我现在有的整法宝
    local _myTreasuresVer = TreasuresModel:getAllTreasure()
    if _myTreasuresVer then
        for i,v in pairs(_myTreasuresVer)  do
            if v[_id] == _mId then
                return true
            end
        end
    end
    return false
    
    
end

-- 通过ID获取相关的信息
-- ……得到信息为啥还要传个 num ？？？？？？？？？？ 
function CombineControl:getTeasureItemData( _mId , num )
   
    local _num = TreasuresModel:getTreasureFragmentsByID( _mId ).num
    if _num == nil then
       _num = 0
    end
    local _needNum = FuncTreasure.getCombineData(_mId, "num")
    -- 我现在有的整法宝
    local _myTreasuresVer = TreasuresModel:getAllTreasure()
    local _itemInfo = {
        id,
        --材料是否满足, --看代码是全部满足~~注释是不是写错了，guan
        isSatisfy = false,
        -- 是否满足条件
        coinSatisfy = false,
        --铜币是否满足
        debrisSatisfy = false,
        --碎片是否满足
        needGoodsIcon = { },
        -- 需要的整法宝icon信息
        needGoodssatisfy = { },-- 需要的法宝是否满足精炼等级
        goodsNum,-- 拥有的碎片个数
        star,-- 星级
        pos,-- 位置
        name,-- 法宝名
        nameSuipian,--法宝碎片名
        mainIcon,-- 主Icon
        quality,-- 资质
        coin,
    }
    local _a = false 
    -- 满足碎片个数
    local _b = true
    --所需的整法宝条件是否满足
    local _c = true
    --所需铜币是否满足
    --合成所需铜币
    _itemInfo.coin = FuncTreasure.getCombineData(_mId,"coin") or 0 
    -- 满足整法宝个数并且满足正法宝精炼等级
    -- ID
    _itemInfo.id = _mId
    -- 星级
    _itemInfo.star = FuncTreasure.getValueByKeyTD(_mId, "initStar")
    -- 资质
    _itemInfo.quality = tonum(FuncTreasure.getValueByKeyTD(_mId, "quality") or 0)
    -- 法宝位置信息
    local _pos = FuncTreasure.getValueByKeyTD(_mId, "label1")
    _itemInfo.pos = _yuan3(_pos <= 3, _pos, 0)
    -- 当前拥有的碎片个数
    _itemInfo.goodsNum = _num .."/".._needNum
    --_itemInfo.goodsNum = _yuan3(_num < _needNum, "<color=ff2700>" .. _num .."/".._needNum.. "<->", _num.."/".._needNum)
    _a = _yuan3(_num < _needNum, false, true)
    --碎片数是否满足
    _itemInfo.debrisSatisfy = _a
    -- 需要的完整法宝
    local _fullTreasureVer = FuncTreasure.getCombineData(_mId, "treasures")

    if _fullTreasureVer ~= -1 then

        local _len = #_fullTreasureVer
        for i = 1, _len do
            local _nId = _fullTreasureVer[i]
            -- 需要的法宝图标
            local _iconInfo = {
                _id = "0",
                _own = false,
                -- 是否拥有该法宝
                _iconName = "",
                _quality = 1
            }
            
            -- 是否拥有合成所需的整法宝
            if _myTreasuresVer[tostring(_nId)] ~= nil then
                _iconInfo._own = true
                -- 拥有该法宝，判断精炼等级
                local refineLv = FuncTreasure.getTreasureRefineMaxLvl(_nId)

                if (_myTreasuresVer[tostring(_nId)]:state() < refineLv) then _b = false end
                table.insert(_itemInfo.needGoodssatisfy, _yuan3(_myTreasuresVer[tostring(_nId)]:state() == refineLv, true, false))
                _iconInfo._quality = _myTreasuresVer[tostring(_nId)]:state() or 1
            else
                -- 未满足
                _b = false
                table.insert(_itemInfo.needGoodssatisfy, false)
            end
            _iconInfo._iconName = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE,_nId) 
            _iconInfo._id = _nId
            
            table.insert(_itemInfo.needGoodsIcon, _iconInfo)
        end
    end
    -- 法宝名
    _itemInfo.name = FuncTreasure.getValueByKeyTD(_mId, "name")
    --法宝碎片名
--    _itemInfo.nameSuipian = FuncTreasure.getValueByKeyTD(_mId, "name")
    -- 法宝icon
--    _itemInfo.mainIcon = FuncTreasure.getTreasureIconPath(_mId)
    _itemInfo.mainIcon = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE,_mId) 
  
    _c =_yuan3(tonumber(_itemInfo.coin) <= UserModel:finance().coin ,true,false)
    _itemInfo.coinSatisfy = _c
    _itemInfo.isSatisfy = _yuan3(_a and _b and _c, true, false)
  
   return _itemInfo 
end 

return CombineControl 


-- endregion
