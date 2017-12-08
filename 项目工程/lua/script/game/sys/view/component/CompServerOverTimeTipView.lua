--
-- Author: ZhangQiang
-- Date: 2016-07-07
-- 断网提示界面

local CompServerOverTimeTipView = class("CompServerOverTimeTipView", UIBase);

function CompServerOverTimeTipView:ctor(winName,_other_ui)
    CompServerOverTimeTipView.super.ctor(self, winName);
    self.callFuncArr = {}
    self.other_ui=_other_ui
end

function CompServerOverTimeTipView:loadUIComplete()
	self:registerEvent()
    self:initData()

    if(self.other_ui)then
          self:showPlayerOfflineTips()
    else
         self:updateUI()
    end
end 

function CompServerOverTimeTipView:setTipContent(tipContent)
    self.tipContent = tipContent
    self:updateUI()
end

function CompServerOverTimeTipView:initData()
    self.tipContent = GameConfig.getLanguage("tid_common_2014")
end

function CompServerOverTimeTipView:registerEvent()
	CompServerOverTimeTipView.super.registerEvent();
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.press_btn_1, self));
    self.UI_1.btn_close:setVisible(false)
    self.UI_1.btn_close:setTap(c_func(self.close,self))
end

function CompServerOverTimeTipView:updateUI()
    self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_common_2013"))
    self.txt_1:setString(self.tipContent)
end

--//提示玩家当前已经被挤掉线
function CompServerOverTimeTipView:showPlayerOfflineTips()
   self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_player_offline_tips"));
   self.txt_1:setString(GameConfig.getLanguage("tid_player_offline_cause"))
end


function CompServerOverTimeTipView:setCallFunc( func )
    if #self.callFuncArr > 0 then
        echo("__当前重连函数数量:"..#self.callFuncArr)
    end
    if func then
        table.insert(self.callFuncArr,func)
    end
    
end
--这个是确定按钮的回调
function CompServerOverTimeTipView:press_btn_1()
    echo("确定按钮的回调");
    self:startHide()


	if #self.callFuncArr > 0 then
        local tempArr = table.copy(self.callFuncArr)

        --做回调
        for i,v in ipairs(tempArr) do
            v()
        end
        
  --       echo("确定按钮的回调 1");
		-- local func = self.callFunc
		-- self.callFunc = nil
		-- func()
	else
        echo("确定按钮的回调 2");
		--重发当前请求
		Server:reSendRequest()
	end
end



function CompServerOverTimeTipView:close()
	self:startHide()
end

return CompServerOverTimeTipView;
