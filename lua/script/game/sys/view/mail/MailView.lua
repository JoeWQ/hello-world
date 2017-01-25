local MailView = class("MailView", UIBase);

--[[
    self.UI_mail,
    self.btn_close,
    self.mc_mailzong1,
    self.scale9_mailbeijing,
]]

function MailView:ctor(winName)
    MailView.super.ctor(self, winName);
end

function MailView:loadUIComplete()
	self:registerEvent();

	self._currentIndex =1
	--分辨率适配
	--关闭按钮右上
	FuncCommUI.setViewAlign(self.btn_close,UIAlignTypes.RightTop) 
	FuncCommUI.setViewAlign(self.panel_title,UIAlignTypes.LeftTop) 
    FuncCommUI.setViewAlign(self.panel_res,UIAlignTypes.RightTop)
    FuncCommUI.setScale9Align(self.scale9_updi,UIAlignTypes.MiddleTop, 1, 0)
	--请求邮件

	--隐藏 需要克隆的邮件item
	self.mc_mailzong1:getViewByFrame(1).panel_1:visible(false)

	

	--初始化更新ui
	self:updateUI()

end 



function MailView:registerEvent()
	--添加邮件事件
	EventControler:addEventListener(MailEvent.MAILEVENT_DELMAIL  ,self.receiveMail,self)
	EventControler:addEventListener(MailEvent.MAILEVENT_UPDATEMAIL  ,self.receiveMail,self)
	MailView.super.registerEvent();
    self.btn_close:setTap(c_func(self.press_btn_close, self));
end

function MailView:press_btn_close()
	self:startHide()
end

function MailView:refreshBtnTap()
    local  mails = MailModel:getSortMail()
    
    if #mails > 0 then
        -- 一键领取
        local getAllBtn = self.mc_mailzong1.currentView.btn_lq
        getAllBtn:setTap(function()
            if mails then
                local num = 0
                for i,v in pairs(mails) do
                    if v.reward then
                        num = num + 1
                        self:pressLingquBtn(v)
                    end
                end
                if num == 0 then
                    WindowControler:showTips("没有可领取的奖励")
                end
            else    
                WindowControler:showTips("现在是空，此时逻辑有问题")
            end
        end)

        -- 一键删除
        local delAllBtn = self.mc_mailzong1.currentView.btn_sc
        delAllBtn:setTap(function()
            if mails then
                local num = 0
                for i,v in pairs(mails) do
                    if v.reward == nil then
                        num = num + 1
                        self:pressLingquBtn(v)
                    end
                end
                if num == 0 then
                    WindowControler:showTips("没有可删除的邮件")
                end
            else    
                WindowControler:showTips("现在是空，此时逻辑有问题")
            end
        end)
    end
    
end

--收到邮件后 更新UI
function MailView:receiveMail( e )
	echo("receiveMail:,",e.name)
	self:updateUI()
end


--获取邮件返回
function MailView:requestMailBack( data )

	--如果请求失败 
	if not data.result then
		return
	end

	local mails = data.result.data.data
	self:updateUI()
end


--刷新邮件列表
function MailView:updateUI(  )
	
	--获取邮件数据
	local  mails = MailModel:getSortMail()
--    local  mails = {}
    -- 检查错误信息
--    for i,v in pairs(_mails) do
--        if MailModel.checkErrorMail(v.reward) then
--            table.insert(mails,v)
--        end

--    end
    
    self._cacheMails = mails

    -- 不知道 有什么用
--	if not self._cacheMails then
--		self._cacheMails = mails
--	else
--		--把缓存的mails 和 mails 进行对比
--		for i=#self._cacheMails,1,-1 do
--			--如果没有这个邮件 那么直接删除
--			if not table.indexof(mails, self._cacheMails[i]) then
--				table.remove(self._cacheMails,i)
--			end

--		end

--		mails = self._cacheMails


--	end

	if not mails or #mails ==0 then
		self.mc_mailzong1:showFrame(2)
	else
		self.mc_mailzong1:showFrame(1)
		--dump(mails,"_mails_"..#mails)
		--存储所有的邮件信息
		
		local createFunc = function ( itemData )
			local view = UIBaseDef:cloneOneView(self.mc_mailzong1:getViewByFrame(1).panel_1)

			self:updateItem(view, itemData)
			return view
		end
		

		local scrollParams = {
			{
				data = mails,
				createFunc= createFunc,
				perFrame = 2,
				offsetX =6,
				offsetY =6,
				itemRect = {x=0,y=-90,width=356,height = 90},
				
				heightGap = 12
			}
		}

		local scroll = self.mc_mailzong1:getViewByFrame(1).scroll_list


		if self._currentIndex == (#self._cacheMails +1 ) then
            echo("self._currentIndex ==== "..self._currentIndex)
            self._currentIndex =1
            scroll:gotoTargetPos(1,1,0);
		end


		-- scroll:setFillEaseTime(0.3)
		scroll:styleFill(scrollParams)

		if self._currentIndex <= 0 then
			self._currentIndex =1
		end

		local info = mails[self._currentIndex]
		local isFirst = false
		if not info then
			--那么显示第一条
			info = mails[1]
			isFirst = true
		end
		
		--默认显示第一个
		self:showOneMailInfo(info,true)

	end

    self:refreshBtnTap()
end


--邮件信息
--[[

]]
function MailView:updateItem(view,info )
	
	view._itemData = info 

	--初始化隐藏选中框
	view.panel_jinjiao:visible(false)
	

	local frameView = view

     --取邮件内容如果有tempId时使用模板的title和content，否则用邮件数据本身的title和content
	local tempId = info.tempId 
    local title = info.title -- 邮件数据本身的title
    if tempId then
        title = FuncMail.getMailTitle(tempId)
    end
	--title
	--发送时间
	local sendTime = info.sendTime

	--日期table
	--[[	
		 - "data" = {
		     "day"   = 14
		     "hour"  = 15
		     "isdst" = false
		     "min"   = 8
		     "month" = 1
		     "sec"   = 18
		    "wday"  = 5
		     "yday"  = 14
		    "year"  = 2016
		}
		
	]]
	local date = os.date("*t",sendTime)

	-- local dateStr =date.year.."-"..date.month .."-"..date.day.." " ..string.ljust(date.hour,2) ..":" ..string.ljust(date.min,2) 
	local dateStr =string.ljust(date.hour,2) ..":" ..string.ljust(date.min,2) 

	view.txt_name:setString(title)

    view.txt_mailday:setString(dateStr)
	--view.txt_mailday:setString(dateStr.."_id:"..info._id)

	--注册点击事件
	view:setTouchedFunc(c_func(self.showOneMailInfo, self,info,false))


	view.mc_di1:showFrame(1)

	if info.reward then
		view.panel_reward:visible(true)
	else
		view.panel_reward:visible(false)
	end


	if (not info.read) or info.read ==0 then
--		view.mc_di1:showFrame(1)
		view.mc_icon:showFrame(1)
	else
--		view.mc_di1:showFrame(2)
		view.mc_icon:showFrame(2)
	end

	--有奖励的地板永远是 第一帧
--	if  info.reward then
--		view.mc_di1:showFrame(1)
--	end
    --邮件列表底板 只显示第一帧
    view.mc_di1:showFrame(1)
end

--显示mail详细信息 传递
function MailView:showOneMailInfo(info ,isInit)
	
	--如果滚动条是滚动中的

	local scroll_list = self.mc_mailzong1:getViewByFrame(1).scroll_list

	if scroll_list:isMoving() and (not isInit) then
		return 
	end
	if not self._currentIndex then
		self._currentIndex =1
	end
	--获取所有的邮件view
	local allViewArr = scroll_list:getAllView()
	for i,v in ipairs(allViewArr) do
		if v._itemData == info then
			v.panel_jinjiao:visible(true)
			self._currentIndex = i

			if not info.read  or info.read ==0 then
				--判断是否是未读
				local mailId = info._id
				--让这个邮件变成已读 同时记录scroll当前位置 读取完毕以后 复原

				--读邮件
				MailServer:readMail(mailId)
				--同时让修改读取状态
				if not info.reward then
					v.mc_di1:showFrame(2)
				else
					v.mc_di1:showFrame(1)
				end
				
				v.mc_icon:showFrame(2)

			end

		else
			v.panel_jinjiao:visible(false)
		end
	end


	--右边详情
	local targetView = self.mc_mailzong1.currentView.mc_xiangqing1
	--如果是有奖励的 
	if info.reward then
		targetView:showFrame(1)
		--领取奖励事件
		targetView.currentView.btn_lingqu1:setTap(c_func(self.pressLingquBtn, self,info))

		FilterTools.setGrayFilter(targetView.currentView.btn_lingqu1)
		FilterTools.clearFilter(targetView.currentView.btn_lingqu1)
		--奖励
		local rewards = info.reward

		--这里需要换成scroll
		local rewardScroll =  targetView.currentView.scroll_list

		local createFunc = function (data)
			local itemView = UIBaseDef:cloneOneView( targetView.currentView.UI_1 )
			itemView:setResItemData({reward = data})
			itemView:showResItemName(false)
			local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(data)
			FuncCommUI.regesitShowResView(itemView, resType, needNum, resId,data,true,true)

			return itemView
		end

		local params = {
			{
				data = rewards,
				createFunc= createFunc,
				-- perNums=1,
				offsetX =20,
				offsetY =10,
				itemRect = {x=0,y=-74,width=74,height = 74},
				perFrame = 2,
				heightGap = 0
			}
		}

		rewardScroll:styleFill(params)

		if #rewards <= 4 then
			--rewardScroll:setCanScroll(false)
		else
			rewardScroll:setCanScroll(true)
		end

		for i=1,4 do
			local itemView = targetView.currentView["UI_"..i]:visible(false)
			itemView:visible(false)
		end

	else
		targetView:showFrame(2)
		targetView.currentView.btn_shanchu1:setTap(c_func(self.pressLingquBtn, self,info))
	end

    --取邮件内容如果有tempId时使用模板的title和content，否则用邮件数据本身的title和content
	local tempId = info.tempId 
    local title = info.title -- 邮件数据本身的title
    local content = info.content 
    if tempId then
        title = FuncMail.getMailTitle(tempId) 
        if info.param == nil or tonumber(tempId) == 9 then
            echo("param ===== nil")
            info.param = {
                [1] = UserModel:name()
            }
        else
            info.param[1] = UserModel:name()
        end
        content = FuncMail.getMailContent(tempId, info.param)
        --发件人
	    local sec =  FuncMail.getMailSec( tempId )
	    content = content.. "\n\n"..MailView:getSpaceStr(sec)
    end
	   

	targetView.currentView.txt_biaoti:setString(title)

	
	

	--设置内容
	targetView.currentView.txt_neirong:setString(content)

	--targetView.currentView.txt_name:setString(sec)

end


--领取一条奖励
function MailView:pressLingquBtn(info  )
	local mailId = info._id


	local tempFunc =function (  )
		MailModel:deleteMail(mailId)
		if not info.reward then
			WindowControler:showTips({text ="删除邮件成功"})
		else
			FuncCommUI.startRewardView(info.reward)
		end
		--

	end

	MailServer:getAttachment(mailId,1,tempFunc)
	--self._currentMoveView = self.mc_mailzong1:getViewByFrame(1).scroll_list:getViewByData(info)

end


--计算发件人前面应该留多少个空格
function MailView:getSpaceStr( sec )
--    sec = "测试吃"
	local length = string.len4cn2(sec)
--    echo("++++++++++++++++++++++++ length = "..length)
	local total = 19
	local spaceNum = (total - length/2) * 2
--    echo("++++++++++++++++++++++++ spaceNum = "..spaceNum)
	local resultStr = ""
	for i=1,spaceNum do
		resultStr = resultStr.." "
	end
	resultStr = resultStr..sec
	return resultStr


end


return MailView;
