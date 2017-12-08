local HappySignView = class("HappySignView", UIBase);



function HappySignView:ctor(winName)
    HappySignView.super.ctor(self, winName);
    self.selectInfo = nil;
    
end

function HappySignView:loadUIComplete()
     -- FuncArmature.loadOneArmatureTexture("UI_shop", nil, true)
	self:registerEvent();

	--分辨率适配
	--关闭按钮右上
	FuncCommUI.setViewAlign(self.btn_fanhui,UIAlignTypes.RightTop) 
	FuncCommUI.setViewAlign(self.panel_UI,UIAlignTypes.RightTop) 
    FuncCommUI.setScale9Align(self.scale9_heidai,UIAlignTypes.MiddleTop, 1, 0)
    FuncCommUI.setViewAlign(self.panel_1,UIAlignTypes.LeftTop) 
    

	--初始化更新ui
	self:updateUI()


end 



function HappySignView:registerEvent()
	HappySignView.super.registerEvent();
    self.btn_fanhui:setTap(c_func(self.press_btn_close, self));
end

function HappySignView:press_btn_close()
	self:startHide()
end

--刷新sign列表
function HappySignView:updateUI(  )
--    HappySignModel:checkShowRed()
    
    self.panel_zhong:setVisible(false)

	local createFunc = function ( itemData )
        local index = tonumber(itemData.hid)
        local view = UIBaseDef:cloneOneView(self.panel_zhong)
        self:delayCall(function ()
		    self:updateItem(view, itemData)
        end, index*0.01)
		return view
    end
    local reuseUpdateCellFunc = function (itemData, view)
        local index = tonumber(itemData.hid)
        self:updateItem(view, itemData,true)
        return view;  
    end

    local allData = HappySignModel:getSortItems()
    
	local _scrollParams = {
			{
				data = allData,
				createFunc= createFunc,
				perFrame = 1,
				offsetX =0,
				offsetY =0,
				itemRect = {x=0,y= -158,width=723,height = 158},
				heightGap = 0,
                perNums = 1,
                updateCellFunc = reuseUpdateCellFunc,

			}
		}
    self.scroll_1:styleFill(_scrollParams);
    
end


--signItem信息
function HappySignView:updateItem(view,info ,isReset)
    if info.isSign then
--       echo("------------------____info.isSign true".. info.hid)
       view.panel_ylq:setVisible(true)
       view.btn_hong:setVisible(false)
    else
       view.panel_ylq:setVisible(false)
       view.btn_hong:setVisible(true)
       view.btn_hong:setTap(c_func(function ()
           --
           if HappySignModel:canHappySign(tonumber(info.hid)) then
               self.selectInfo = info
               self:pressLingquBtn(info) 
               view.btn_hong:setTouchEnabled(false)
           else
               -- 条件不足
               WindowControler:showTips(string.format("再登陆%d天可领取",HappySignModel:willSignDayNums(info.hid)))
           end  
            
       end, self));

       if HappySignModel:canHappySign(tonumber(info.hid)) then
            FilterTools.clearFilter( view.btn_hong )
            if not view.btn_hong:getChildByName("ani_zhonganniu") then
                local ani = self:createUIArmature("UI_common","UI_common_zhonganniu", view.btn_hong, true);
                ani:setPosition(ani:getPositionX() + 67,ani:getPositionY() - 36)
                ani:setScale(0.9)
                ani:setName("ani_zhonganniu")
            else
                view.btn_hong:getChildByName("ani_zhonganniu"):setVisible(true)
            end
       else
            FilterTools.setGrayFilter(view.btn_hong);
           if view.btn_hong:getChildByName("ani_zhonganniu") then
                view.btn_hong:getChildByName("ani_zhonganniu"):setVisible(false)
            end
       end
    end
    
    if not isReset then

         for i = 1 ,4 do
            local itemData = info.reward[i]
            local data = string.split(itemData,",")
            local rewardType = data[1]
            local itemRewardView 
            if  i == 1 then -- 第一个单独处理
                itemRewardView = view.mc_1
                if rewardType == FuncDataResource.RES_TYPE.TREASURE then -- fabao
                    view.mc_1:showFrame(2)  
                    local itemRewardView2 = view.mc_1.currentView.panel_1.UI_fb1
                    itemRewardView2:updateUI(data[2])
                    view.mc_1.currentView.panel_1:setScale(0.7)
                    local xingji = FuncTreasure.getValueByKeyTD(data[2],"initStar")
                    view.mc_1.currentView.panel_1.mc_xing:showFrame(xingji)
                     --注册点击事件 弹框
                    local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
                    FuncCommUI.regesitShowResView(itemRewardView2, resType, needNum, resId,itemData,true,true)
                else
                    view.mc_1:showFrame(1)
                    local itemRewardView1 = view.mc_1.currentView.UI_1
                    itemRewardView1:setResItemData({reward = itemData})
		            itemRewardView1:showResItemName(false)
                     --注册点击事件 弹框
                    local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
                    FuncCommUI.regesitShowResView(itemRewardView1, resType, needNum, resId,itemData,true,true)
                end
                
            else
                itemRewardView = view["UI_"..i]
                
                itemRewardView:setResItemData({reward = itemData})
		        itemRewardView:showResItemName(false)

                 --注册点击事件 弹框
                local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
                FuncCommUI.regesitShowResView(itemRewardView, resType, needNum, resId,itemData,true,true)
            end
            
            --第一个有特效
            if i == 1 then 
                view.ctn_1:removeAllChildren()
                local data = string.split(itemData,",")
                local rewardType = data[1]
                local ani
                if tostring(rewardType) == FuncDataResource.RES_TYPE.TREASURE then
                    ani = self:createUIArmature("UI_shop","UI_shop_yuan2", view.ctn_1, true)
                    ani:playWithIndex(0,true)
                    ani:setScale(1.2)
                    itemRewardView:setScale(0.8)
                    itemRewardView:setPosition(-50, 30);
                else
                    ani = self:createUIArmature("UI_shop","UI_shop_fang", view.ctn_1, true)
                    ani:playWithIndex(0,true)
                    itemRewardView:setPosition(-83, 50);
                end
                ani:setPosition(ani:getPositionX()-385,ani:getPositionY() - 38)
                local nodeAni = ani:getBoneDisplay("node1");

                FuncArmature.changeBoneDisplay(nodeAni, "layer1", itemRewardView);
     
            end
            
        end
    end
    --第几天
    view.mc_number:showFrame(tonumber(info.hid)+1)

end

-- 服务器返回结果
function HappySignView:requestMailBack( event )

	--如果请求失败 
	if not event.result then
		return
	end
    -- 签到成功

    -- set signId 
    HappySignModel:setHappySignId(self.selectInfo.hid)
    --展示 获得的奖励
    local reward = self.selectInfo.reward
    FuncCommUI.startFullScreenRewardView(reward, c_func(self.updateUI, self));
   
	self:updateUI()
end
--领取一条奖励
function HappySignView:pressLingquBtn(itemInfo)
    
    HappySignServer:mark(tonumber(itemInfo.hid),c_func(self.requestMailBack, self));

    --self:requestMailBack()
end


return HappySignView;
