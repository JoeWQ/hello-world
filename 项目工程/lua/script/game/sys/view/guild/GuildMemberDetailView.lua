--guan
--2016.1.14

local GuildMemberDetailView = class("GuildMemberDetailView", UIBase);

--[[
    self.UI_guild_chakan,
    self.btn_close,
    self.btn_shanrang11,
    self.btn_shengzhi11,
    self.btn_tianjia1,
    self.btn_tiren1,
    self.mc_play1,
    self.panel_playerkuang1,
    self.scale9_chakandi,
    self.scale9_xinxidi,
    self.txt_chakantitle,
    self.txt_gongxian,
    self.txt_lv,
    self.txt_name1,
    self.txt_zhandouli,
    self.txt_zhandouzhi,
    self.txt_zhuangtai,
]]

function GuildMemberDetailView:ctor(winName, memberData)
    GuildMemberDetailView.super.ctor(self, winName);
    self._memberData = memberData;
end

function GuildMemberDetailView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function GuildMemberDetailView:registerEvent()
	GuildMemberDetailView.super.registerEvent();
    self.btn_tiren1:setTap(c_func(self.press_btn_tiren1, self));
    self.btn_close:setTap(c_func(self.press_btn_close, self));
    self.btn_tianjia1:setTap(c_func(self.press_btn_tianjia1, self));
    self.btn_shengzhi11:setTap(c_func(self.press_btn_shengzhi11, self));
    self.btn_shanrang11:setTap(c_func(self.press_btn_shanrang11, self));

    EventControler:addEventListener(GuildEvent.GUILD_KICK_GUILD_OK_EVENT,
        self.kickMemberCallBack, self);

    EventControler:addEventListener(GuildEvent.GUILD_MODIFY_MEMBER_RIGHT_OK_EVENT,
        self.modifyMemberCallback, self);
    
end

function GuildMemberDetailView:initUI()
    --名字
    self.txt_name1:setString(self._memberData._id);

    echo("self._memberData.right:" .. tostring(self._memberData.right));

    --太上长老不能升
    if GuildModel:getMyRight() == GuildModel.MEMBER_RIGHT.SUPER_MASTER then 
        self.btn_shengzhi11:setVisible(false);
        self.btn_shanrang11:setVisible(false);
    elseif GuildModel:getMyRight() == GuildModel.MEMBER_RIGHT.PEOPLE then 
        self.btn_shengzhi11:setVisible(false);
        self.btn_shanrang11:setVisible(false);
        self.btn_tiren1:setVisible(false);
    elseif GuildModel:getMyRight() == GuildModel.MEMBER_RIGHT.MASTER then
        self.btn_shengzhi11:setVisible(false);
        self.btn_shanrang11:setVisible(false);
    else 

    end 

    if self._memberData.right == GuildModel.MEMBER_RIGHT.SUPER_MASTER then 
        self.btn_shengzhi11:setVisible(false);
    end 
end

function GuildMemberDetailView:press_btn_tiren1()
    echo("踢人");
    
    WindowControler:showAlertView(
        {
            title = "踢人", 
            des = "确定要踢 " .. tostring(self._memberData._id),
            isSingleBtn = false,
            secondBtnCallBack = function ()
                EventControler:dispatchEvent(GuildEvent.GUILD_KICK_GUILD_EVENT, 
                    {id = self._memberData._id});
            end,

        }
    );
end

function GuildMemberDetailView:press_btn_close()
    self:startHide();
end

function GuildMemberDetailView:press_btn_tianjia1()

end

--升为长老，将为群众
function GuildMemberDetailView:press_btn_shengzhi11()
    local right = 0;
    local title = "";
    local des = "";

    if self._memberData.right == GuildModel.MEMBER_RIGHT.MASTER then 
        right = 4;
        des = "确定要降职 " .. tostring(self._memberData._id);
        title = "降职"
    elseif self._memberData.right == GuildModel.MEMBER_RIGHT.PEOPLE then 
        right = 3;
        title = "升值";
        des = "确定要升值 " .. tostring(self._memberData._id);
    else 
        echo("press_btn_shengzhi11 should not come here!");
    end 

    echo("press_btn_shengzhi11:" .. tostring(right));

    WindowControler:showAlertView(
        {
            title = title, 
            des = des,
            isSingleBtn = false,
            secondBtnCallBack = function ()
                EventControler:dispatchEvent(GuildEvent.GUILD_MODIFY_MEMBER_RIGHT_EVENT, 
                    {id = self._memberData._id, right = right});
            end,
        }
    ); 
    self._right = right;
end

function GuildMemberDetailView:press_btn_shanrang11()
    echo("让位");
    WindowControler:showAlertView(
        {
            title = "让位", 
            des = "确定要让位 " .. tostring(self._memberData._id),
            isSingleBtn = false,
            secondBtnCallBack = function ()
                EventControler:dispatchEvent(GuildEvent.GUILD_MODIFY_MEMBER_RIGHT_EVENT, 
                    {id = self._memberData._id, right = GuildModel.MEMBER_RIGHT.LEADER});
            end,
        }
    );
    self._right = GuildModel.MEMBER_RIGHT.LEADER;
end


function GuildMemberDetailView:updateUI()
	
end

function GuildMemberDetailView:kickMemberCallBack(data)
    local userId = data.params.userId;
    echo("kickMemberCallBack:" .. tostring(userId));

    GuildModel:delMembersInfo(userId);
    EventControler:dispatchEvent(GuildEvent.GUILD_MEMBER_CHANGE_EVENT, 
        {});    

    self:startHide();
end

function GuildMemberDetailView:modifyMemberCallback(data)
    local userId = data.params.userId;
    local right = data.params.right;

    echo("modifyMemberCallback:" .. tostring(userId));
    echo("modifyMemberCallback right:" .. tostring(right));

    if right == GuildModel.MEMBER_RIGHT.LEADER then 
        local info = GuildModel:getMyMembersInfo();
        info.right = GuildModel.MEMBER_RIGHT.PEOPLE;
    end 

    local info = GuildModel:getMemberInfo(userId);
    info.right = self._right;

    EventControler:dispatchEvent(GuildEvent.GUILD_MEMBER_CHANGE_EVENT, 
        {right = self._right});    

    self:startHide();
end


return GuildMemberDetailView;










