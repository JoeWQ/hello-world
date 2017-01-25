--guan
--2016.3.21

local BattleInvitationView = class("BattleInvitationView", UIBase);



--[[
    self.btn_1,
    self.btn_2,
    self.panel_1,
    self.panel_1.ctn_1,
    self.scale9_bg,
    self.txt_1,
    self.txt_2,
]]
function BattleInvitationView:ctor(winName)
    BattleInvitationView.super.ctor(self, winName);
end

function BattleInvitationView:loadUIComplete()
	self:registerEvent();
end 

function BattleInvitationView:registerEvent()
	BattleInvitationView.super.registerEvent();
    self.btn_1:setTap(c_func(self.press_btn_1, self));
    self.btn_2:setTap(c_func(self.press_btn_2, self));

    self:registerBtnCall();
end

function BattleInvitationView:registerBtnCall()
    -- 全部点击事件
    self:setTouchedFunc(function ( ... )
        
    end)
    self:setTouchSwallowEnabled(true);
    self.btn_1:setTouchSwallowEnabled(true);
    self.btn_2:setTouchSwallowEnabled(true);
end

function BattleInvitationView:initUI(matchId)
    --通过这个 self._matchId 设置 搞ui
    self._matchId = matchId;

    --名字
    local nameId = FuncMatch.readMatchSystem(matchId, "des1");
    self.txt_1:setString(GameConfig.getLanguage(nameId));
    --描述
    local desId = FuncMatch.readMatchSystem(matchId, "des2");
    self.txt_1:setString(GameConfig.getLanguage(desId));
    --icon
    local imageName = FuncMatch.readMatchSystem(matchId, "img");
    local iconResPath = FuncRes.iconOther( image )
    local sp = display.newSprite(iconResPath);
    local ctn = self.panel_1.ctn_1;
    ctn:removeAllChildren();
    sp:size(ctn.ctnWidth, ctn.ctnHeight);
    ctn:addChild(sp);
    
end

function BattleInvitationView:press_btn_1()
    --没有用
    echo("--点左箭头--")
end

function BattleInvitationView:press_btn_2()
    --组队进入战斗
    echo("---start battle-- " .. tostring(self._matchId));

    --通知主界面换id
    EventControler:dispatchEvent(HomeEvent.CHANGE_INAITATION_MATCH_ID_EVENT);

    BattleServer:joinMatch(self._matchId, 
        c_func(self.jionpipeiBack, self));
end

--匹配返回
function BattleInvitationView:jionpipeiBack( result )
    echo("904__加入匹配返回, 服务器时间, 超时时间", 
        result.result.serverInfo.serverTime,result.result.data.idleExpireTime)
    echo(result.result.data.idleExpireTime, TimeControler:getServerTime(  ),
            result.result.data.idleExpireTime> TimeControler:getServerTime(  ) ,"---------------------" )
    if result and result.result and result.result.data and 
        result.result.data.idleExpireTime> TimeControler:getServerTime(  ) 
    then
        -- echo("点击气泡--执行加入操作的")
        -- --dump(result.)
        -- LogsControler:writeDumpToFile("点击气泡执行加入操作-----")
        -- LogsControler:writeDumpToFile(result)
        -- dump(result.result)
        -- echo("点击气泡--执行加入操作的")
        local loadingId= FuncMatch.getLoadIdBySystem( self._matchId )
        echo("903_加入匹配池子",poolSystem,loadingId)
        BattleControler:setLoadingId(loadingId,2)
    else
        WindowControler:showTips("战斗已经结束--")
    end

end

--通过 matchId 重新更新这个条
function BattleInvitationView:updateUI(matchId)
	self._matchId = matchId;
    self:initUI(matchId);
end



return BattleInvitationView;











