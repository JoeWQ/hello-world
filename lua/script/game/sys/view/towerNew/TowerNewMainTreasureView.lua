-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
  
local TowerNewMainTreasureView = class("TowerNewMainTreasureView", UIBase)

function TowerNewMainTreasureView:ctor(winName, _towerMainView)
    TowerNewMainTreasureView.super.ctor(self, winName)
end

function TowerNewMainTreasureView:initData()
    self.clickType =  0
    self.openState = false
end  

function TowerNewMainTreasureView:setViewCfg()
    FuncCommUI.setViewAlign(self.panel_icon, UIAlignTypes.LeftTop) 
--    FuncCommUI.setViewAlign(self.UI_keys, UIAlignTypes.RightTop) 
    FuncCommUI.setViewAlign(self.btn_back, UIAlignTypes.RightTop)  
    FuncCommUI.setViewAlign(self.UI_tower_box_key, UIAlignTypes.RightTop)
--    FuncCommUI.setViewAlign(self.btn_1, UIAlignTypes.LeftBottom) 
--    FuncCommUI.setViewAlign(self.btn_2, UIAlignTypes.MiddleBottom) 
--    FuncCommUI.setViewAlign(self.btn_3, UIAlignTypes.RightBottom) 

--	--此处注意，特效ctn需要和对应宝箱一起适配
--    FuncCommUI.setViewAlign(self.btn_box1, UIAlignTypes.Left) 
--    FuncCommUI.setViewAlign(self.ctn_baoxiang1, UIAlignTypes.Left) 
--    FuncCommUI.setViewAlign(self.btn_box3, UIAlignTypes.Right)  
--    FuncCommUI.setViewAlign(self.ctn_baoxiang3, UIAlignTypes.Right)  

    FuncCommUI.setScale9Align(self.scale9_1,UIAlignTypes.MiddleTop, 1, 0)
 
--    self.scale9_1:setScaleX(GameVars.width / GAMEWIDTH) 
end 

function TowerNewMainTreasureView:loadUIComplete()
    self:initData()
    self:setViewCfg()
    self:registerEvent() 
    self:updateUI()
end

function TowerNewMainTreasureView:registerEvent()
    self.btn_back:setTap(c_func(self.onBtnBackTap, self));
    for i = 1,3 do
		local btn_box = self["btn_box"..i]
		btn_box:setTap(c_func(self.showAward, self, i))

		local actionBtn = self['btn_'..i]
        actionBtn:setTap(c_func(self.onBoxActionBtnTap, self, i))
    end
end 

function TowerNewMainTreasureView:onBoxActionBtnTap(i)
	if self.boxKeys[i] > 0 then --开启所需钥匙数量
		if not self.openState then 
			if UserModel:isTest() then
				self:testOpenTreasureBox(i)
			else
				self:openTreasureBox(i)
			end
		end 
	else
		WindowControler:showTips("所需钥匙数量不足")
	end
end

function TowerNewMainTreasureView:onBtnBackTap()
	self:close()
end

function TowerNewMainTreasureView:close()
	--检查红点
	TowerNewModel:isShowRed()
	self:startHide()
end

--显示奖励物品
function TowerNewMainTreasureView:showAward(id)
	WindowControler:showWindow("TowerNewTreasureShowAward", id)
end 

--开启宝箱
function TowerNewMainTreasureView:openTreasureBox(_type)
	self.clickType = _type
	self.openState = true
	local keyType = FuncTower.KEY_TYPES[_type]
	local keyId = FuncTower.KEYS[keyType]
	local num = TowerNewModel:getCanOpenBoxNumOnce(keyId)
	TowerServer:requestOpenTeasuerBox({type = _type ,times = num},c_func(self.openTreasureCallbck, self))
end 

--for test
function TowerNewMainTreasureView:testOpenTreasureBox(_type)
	self.clickType = _type
	self.openState = true
	local keyType = FuncTower.KEY_TYPES[_type]
	local keyId = FuncTower.KEYS[keyType]
	local num = TowerNewModel:getCanOpenBoxNumOnce(keyId)
	if num <= 0 then
		WindowControler:showTips("开完了")
		return
	end
	TowerServer:requestOpenTeasuerBox({type = _type ,times = 1},c_func(self.testOpenTreasureBack, self, _type))
end 

--for test
function TowerNewMainTreasureView:testOpenTreasureBack(_type, serverData)
	local reward = serverData.result.data.reward[1][1]
	local needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(reward)
	local q = FuncDataResource.getQualityById(resType, resId)
	local log = string.format("开宝箱[%s] 获得 id:%s num:%s quality:%s", _type, resId, needNum, q)
	echo(log)
	self:testOpenTreasureBox(_type)
end

function TowerNewMainTreasureView:openTreasureCallbck(_p)
    function _callback() 
		self:delayCall(c_func(self.clearBoxEffectCtn, self, self["ctn_baoxiang"..self.clickType]), 0.1)
        self["btn_box"..self.clickType]:setVisible(true) 
          --刷新钥匙
        self.openState = false

        local rewardResult = WindowControler:showWindow("TowerNewBoxRewardView", self)
        rewardResult:initData(_p.result) 
		

        self:updateUI()
    end      
	EventControler:dispatchEvent(TowerEvent.TOWER_OPEN_BOX_OK)
    EventControler:dispatchEvent(TowerEvent.TOWERR_RED_POINT_UPDATA)
    
 
    local boxEffect = {"UI_suoyaota_muxiang", "UI_suoyaota_shixiang", "UI_suoyaota_Jin"} 
 
	self["btn_box"..self.clickType]:setVisible(false)
	local animCtn = self["ctn_baoxiang"..self.clickType] 
    local anim = self:createUIArmature("UI_suoyaota", boxEffect[self.clickType], animCtn, false, _callback)
end

function TowerNewMainTreasureView:clearBoxEffectCtn(ctn)
	if ctn then
		ctn:removeAllChildren()
	end
end


function TowerNewMainTreasureView:updateUI()
    -- 刷新钥匙
	self.boxKeys = TowerNewModel:getTreasureBoxKeys()
     
    for i = 1, 3 do
--        self["btn_" .. i].spUp.panel_hongdian1:setVisible(false)
        if self.boxKeys[i] < 1 then
            FilterTools.setGrayFilter(self["btn_" .. i]);
			self["btn_" .. i].spUp.txt_1:setString(GameConfig.getLanguage("tid_tower_1001"))
        else
        	local openCount = _yuan3(self.boxKeys[i] >= 10, 10, self.boxKeys[i])
			local str = GameConfig.getLanguageWithSwap('tid_tower_1002', openCount)
            if self.boxKeys[i] >= 10 then 
--				self["btn_" .. i]:getUpPanel().panel_hongdian1:setVisible(true)
            end 
			self["btn_" .. i]:getUpPanel().txt_1:setString(str)
        end
    end
end

function TowerNewMainTreasureView:deleteMe()   
    TowerNewMainTreasureView.super.deleteMe(self)
end

return TowerNewMainTreasureView  
-- endregion 
