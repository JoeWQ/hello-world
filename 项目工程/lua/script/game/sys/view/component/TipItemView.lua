local TipItemView = class("TipItemView", UIBase);

--通用获取道具tipviews
--[[
    self.mc_1,
    self.scale9_tips,
    self.txt_1,
    self.txt_2,
]]

function TipItemView:ctor(winName)
    TipItemView.super.ctor(self, winName);
end

function TipItemView:loadUIComplete()
	self:registerEvent();
	AudioModel:playSound("s_com_moveTip")
end 

function TipItemView:registerEvent()
	TipItemView.super.registerEvent();

end

--资源类型字符串
function TipItemView:setRewardInfo(resStr )
	
	self.UI_1:setResItemData({reward=resStr})
	local needNum,nums,isEnough ,resType,resId = UserModel:getResInfo( resStr )
	-- self.UI_1:hideBgCase()
	--隐藏数量
	self.UI_1:showResItemNum(false)
	-- --判断是道具 还是其他资源  除了道具  其他资源走相同的
	-- local quality = FuncDataResource.getQualityById( resType,resId )
	-- local iconPath = FuncRes.iconRes(resType,resId)

	-- local icon = display.newSprite(iconPath)

	local resName = FuncDataResource.getResNameById(resType,resId)

	local quality =FuncDataResource.getQualityById( resType,resId )

	local colorStr = FuncCommon.getColorStrByQuality(quality)
    local   _text=resName.."×"..needNum;
	resName = "<color="..colorStr..">" ..resName .."<->"
	self.rich_2:setString(resName .. "×" ..   needNum)
	-- self.mc_1:showFrame(quality)
	-- self.ctn_icon:removeAllChildren()
	-- icon:addto(self.ctn_icon):anchor(0.5,0.5)
--//调整位置
   local   _width1=FuncCommUI.getStringWidth("你获得",22,"systemFont");
   local   _width2=87.5;
   local   _width3=FuncCommUI.getStringWidth(_text,24,"systemFont");
--//调整位置
   local   _width=_width1+_width2+_width3;
   local   _total_width=408;
--//求中心点 
   local   _centerx=self.scale9_tips:getPositionX();
   local   _size=self.scale9_tips:getContentSize();
   _centerx=_centerx+_size.width/2;
--//三个组件若是为一体的中心点
   local   _marginx=self.txt_1:getPositionX();
   _marginx=_marginx+50;--//加上偏移值,因为flash上组件是右对齐的
--//计算应该将组件内的那个点移动到中心点_centerx,_centery
   local    _otherx=_marginx+_width/2;
--//计算应该偏移的距离
   local   _offsetx=_centerx-_otherx;
--//移动组件
   local   _component={};
   _component[1]=self.txt_1;
   _component[2]=self.UI_1;
   _component[3]=self.rich_2;
   for _index=1,3 do
           local   _x=_component[_index]:getPositionX();
           _component[_index]:setPositionX(_x+_offsetx);
   end
end

function TipItemView:updateUI()
	
end

function TipItemView:setBaseReward(_resType,_resCount)
	 local quality = 1
     local    reward={};
     reward.reward="".._resType..",1"
     self.UI_1:setRewardItemData(reward);
     self.UI_1.panelInfo.txt_goodsshuliang:setVisible(false);
	 self.txt_2:setString("×" ..   _resCount)
end


return TipItemView;
