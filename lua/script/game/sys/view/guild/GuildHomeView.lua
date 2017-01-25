--guan
--2016.1.10

local GuildHomeView = class("GuildHomeView", UIBase);

--[[
    self.UI_guild_gonghuizhu,
    self.btn_yaoqing1,
    self.btn_zhucheng1,
    self.panel_biaozhi.panel_1,
    self.panel_biaozhi.panel_2,
    self.panel_caidan1.panel_dakaiguanbi1,
    self.panel_caidan1.panel_heng11,
    self.panel_caidan1.panel_heng22,
    self.panel_caidan1.panel_heng33,
    self.panel_caidan1.panel_heng44,
    self.panel_caidan1.panel_heng55,
    self.panel_caidan1.panel_shu1,
    self.panel_caidan1.panel_shu2,
    self.panel_caidan1.panel_shu3,
    self.panel_caidan1.panel_shu4,
    self.panel_exp,
    self.panel_exp.progress_xianmenglv1,
    self.panel_exp.txt_exp,
    self.panel_gaoshizong.btn_gaoshi1,
    self.panel_gaoshizong.panel_gaoshineirong1,
    self.scale9_chengyuandi,
    self.scale9_gongxiandi,
    self.scale9_iddi,
    self.scale9_mengzhudi,
    self.scale9_mingzidi,
    self.txt_chengyuan,
    self.txt_chengyuanzhi,
    self.txt_gongxian,
    self.txt_gongxianzhi,
    self.txt_id,
    self.txt_lv1,
    self.txt_mengzhu,
    self.txt_mengzhuname,
    self.txt_xianmengid,
    self.txt_xianmengname,
]]

function GuildHomeView:ctor(winName)
    GuildHomeView.super.ctor(self, winName);

    self._isBtnsOpen = true;
    self._actionTotalTime = 0.1;
    self._isDeclarationShowing = true;
end

function GuildHomeView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function GuildHomeView:registerEvent()
	GuildHomeView.super.registerEvent();
    self.panel_gaoshizong.btn_gaoshi1:setTap(c_func(self.press_panel_gaoshizong_btn_gaoshi1, self));
    self.btn_yaoqing1:setTap(c_func(self.press_btn_yaoqing1, self));
    self.panel_caidan1.panel_heng33.btn_heng33:setTap(c_func(self.press_panel_caidan1_panel_heng33_btn_heng33, self));
    --收缩展开的btn
    self.panel_caidan1.panel_dakaiguanbi1.btn_dakai1:setTap(c_func(self.press_panel_caidan1_panel_dakaiguanbi1_btn_dakai1, self));
    self.panel_caidan1.panel_shu1.btn_1:setTap(c_func(self.press_panel_caidan1_panel_shu1_btn_1, self));
    self.panel_caidan1.panel_shu3.btn_shu3:setTap(c_func(self.press_panel_caidan1_panel_shu3_btn_shu3, self));
    self.panel_caidan1.panel_heng22.btn_heng22:setTap(c_func(self.press_panel_caidan1_panel_heng22_btn_heng22, self));
    self.panel_caidan1.panel_heng44.btn_heng44:setTap(c_func(self.press_panel_caidan1_panel_heng44_btn_heng44, self));
    self.panel_caidan1.panel_shu4.btn_shu4:setTap(c_func(self.press_panel_caidan1_panel_shu4_btn_shu4, self));
    self.panel_caidan1.panel_heng55.btn_heng55:setTap(c_func(self.press_panel_caidan1_panel_heng55_btn_heng55, self));
    self.panel_caidan1.panel_shu2.btn_1:setTap(c_func(self.press_panel_caidan1_panel_shu2_btn_1, self));
    self.panel_caidan1.panel_heng11.btn_heng11:setTap(c_func(self.press_panel_caidan1_panel_heng11_btn_heng11, self));
    self.btn_zhucheng1:setTap(c_func(self.press_btn_zhucheng1, self));

    --修改通知完成
    EventControler:addEventListener(GuildEvent.GUILD_MODITY_CONFIG_OK_EVENT,
        self.modifyOk, self); 

    --退出公会   
    EventControler:addEventListener(GuildEvent.GUILD_QUIT_OK_EVENT,
        self.press_btn_zhucheng1, self); 
end


function GuildHomeView:initUI()
    self:initDownBtns();
    self:initPlayer();
    self:initDeclaration();
    self:initBaseInfo();
end

function GuildHomeView:initBaseInfo()
    local baseInfo = GuildModel:getGuildBaseInfo();
    --公会name 
    self.txt_xianmengname:setString(baseInfo.name);
    --公会ic
    self.txt_id:setString(baseInfo._id);
    --成员数
    local max = GuildModel:getMaxMemberNum();
    local members = baseInfo.members;
    self.txt_chengyuanzhi:setString(tostring(members) .. "/" .. tostring(max));

    local playerInfo = GuildModel:getMyMembersInfo();
    --玩家名字
    self.txt_mengzhuname:setString(playerInfo._id);
end

function GuildHomeView:initDeclaration()
    local noticeStr = GuildModel:getGuildBaseInfo().notice or "没有通知";
    self.panel_gaoshizong.panel_gaoshineirong1.txt_gaoshineirong:setString(
        noticeStr);

    self.panel_gaoshizong.panel_gaoshineirong1.txt_xiugai:setTouchedFunc(
        c_func(self.editDeclaration, self));

    --是否能改通知
    if GuildModel:getMyRight() == GuildModel.MEMBER_RIGHT.PEOPLE then 
        self.panel_gaoshizong.panel_gaoshineirong1.txt_xiugai:setVisible(false);
    end 
end

function GuildHomeView:editDeclaration()
    echo("editDeclaration");
    WindowControler:showWindow("GuildEditDeclarationView");

end

function GuildHomeView:initPlayer()
    --todo 提取到公共类里
    require("game.sys.view.home.init");  
    local mapNode = HomeMapLayer.new(true);
    self._mapNode = mapNode;
    self._root:addChild(mapNode, -1);
end

function GuildHomeView:initDownBtns()
    self:initPrePos();
    local x, y = self.panel_caidan1.panel_dakaiguanbi1:getPosition();
    --fixme
    self._targetPos = {x = x, y = y};
    --让btn在最上面
    self.panel_caidan1.panel_dakaiguanbi1:setLocalZOrder(10);
end

function GuildHomeView:initPrePos()
    self._btnsPrePos = {};
    --上条
    for i = 1, 4 do
        local panel = self.panel_caidan1["panel_shu" .. tostring(i)];
        self._btnsPrePos[panel] = {x = panel:getPositionX(), y = panel:getPositionY()};
    end

    --横条
    for i = 1, 5 do
        local panel = self.panel_caidan1["panel_heng" .. tostring(i) .. tostring(i)];
        self._btnsPrePos[panel] = {x = panel:getPositionX(), y = panel:getPositionY()};
    end
end

function GuildHomeView:press_panel_gaoshizong_btn_gaoshi1()
    echo("告示");
    if self._isDeclarationShowing == true then 
        self._isDeclarationShowing = false;
        self.panel_gaoshizong.panel_gaoshineirong1:setVisible(false);
    else 
        self._isDeclarationShowing = true;
        self.panel_gaoshizong.panel_gaoshineirong1:setVisible(true);      
    end 
end

function GuildHomeView:press_btn_yaoqing1()
    echo("发出世界邀请");
    WindowControler:showTips({text = "发出世界宣言"});
end

function GuildHomeView:press_panel_caidan1_panel_heng33_btn_heng33()

end

--展开或收缩框
function GuildHomeView:press_panel_caidan1_panel_dakaiguanbi1_btn_dakai1()
    local btn = self.panel_caidan1.panel_dakaiguanbi1.btn_dakai1;

    -- 一个让btn可点击的动作
    local btnEnableCallBackAct = cc.CallFunc:create(function ()
        self:delayCall(function ( ... )
            btn:enabled(true);
        end,self._actionTotalTime );
    end)

    -- 一个让btn不可点击的动作
    local btnDisableCallBackAct = cc.CallFunc:create(function ()
        btn:enabled(false);
    end)

    -- 上面的关闭
    local upCloseAct = cc.CallFunc:create(function ()
        for i = 1, 4 do
            local panel = self.panel_caidan1["panel_shu" .. tostring(i)];
            local moveAct = cc.MoveTo:create(self._actionTotalTime, 
                {x = panel:getPositionX(), y = self._targetPos.y});
            panel:runAction(moveAct);
        end
    end)

    -- 上面的打开
    local upOpenAct = cc.CallFunc:create(function ()
        for i = 1, 4 do
            local panel = self.panel_caidan1["panel_shu" .. tostring(i)];
            local moveAct = cc.MoveTo:create(self._actionTotalTime, self._btnsPrePos[panel]);
            panel:runAction(moveAct);
        end
    end)

    -- 下面的关闭
    local downCloseAct = cc.CallFunc:create(function ()
        for i = 1, 5 do
            local panel = self.panel_caidan1["panel_heng" .. tostring(i) .. tostring(i)];
            local moveAct = cc.MoveTo:create(self._actionTotalTime, 
                {x = self._targetPos.x, y = panel:getPositionY()});
            panel:runAction(moveAct);
        end
    end)

    -- 下面的打开
    local downOpenAct = cc.CallFunc:create(function ()
        for i = 1, 5 do
            local panel = self.panel_caidan1["panel_heng" .. tostring(i) .. tostring(i)];
            local moveAct = cc.MoveTo:create(self._actionTotalTime, self._btnsPrePos[panel]);
            panel:runAction(moveAct);
        end
    end)

    if self._isBtnsOpen == true then 
        local sequence = cc.Sequence:create(btnDisableCallBackAct, downCloseAct,
            upCloseAct, btnEnableCallBackAct);
        btn:runAction(sequence);

        self._isBtnsOpen = false;
    else 
        local sequence = cc.Sequence:create(btnDisableCallBackAct, downOpenAct,
            upOpenAct, btnEnableCallBackAct);
        btn:runAction(sequence);

        self._isBtnsOpen = true;
    end 
end

function GuildHomeView:press_panel_caidan1_panel_shu1_btn_1()

end

function GuildHomeView:press_panel_caidan1_panel_shu3_btn_shu3()

end

--管理
function GuildHomeView:press_panel_caidan1_panel_heng22_btn_heng22()
    WindowControler:showWindow("GuildManageView");
end

function GuildHomeView:press_panel_caidan1_panel_heng44_btn_heng44()

end

function GuildHomeView:press_panel_caidan1_panel_shu4_btn_shu4()

end

function GuildHomeView:press_panel_caidan1_panel_heng55_btn_heng55()

end

function GuildHomeView:press_panel_caidan1_panel_shu2_btn_1()

end

function GuildHomeView:press_panel_caidan1_panel_heng11_btn_heng11()

end

function GuildHomeView:press_btn_zhucheng1()
    self:startHide();
end


function GuildHomeView:updateUI()
	
end

function GuildHomeView:modifyOk(data)
    local configs = data.params.configs;
    --notice变化
    if configs.notice ~= nil then 
        echo('notice变化');
        GuildModel:getGuildBaseInfo().notice = configs.notice;
        self.panel_gaoshizong.panel_gaoshineirong1.txt_gaoshineirong:setString(
            configs.notice);
    end 
end


return GuildHomeView;















