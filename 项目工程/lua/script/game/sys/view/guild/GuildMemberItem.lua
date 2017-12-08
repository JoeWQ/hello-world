--guan
--2016.1.11

local GuildMemberItem = class("GuildMemberItem", UIBase);

--[[
    self.mc_caozuobtn1,
    self.mc_player1,
    self.mc_zhiwei1,
    self.panel_playerkuang2,
    self.scale9_liebiaodi,
    self.txt_gongxian,
    self.txt_lv1,
    self.txt_name1,
]]

function GuildMemberItem:ctor(winName)
    GuildMemberItem.super.ctor(self, winName);
end

function GuildMemberItem:loadUIComplete()
	self:registerEvent();
end 

function GuildMemberItem:registerEvent()
	GuildMemberItem.super.registerEvent();

end

function GuildMemberItem:updateUI(index, adapter)
    local data = adapter:getDataByIndex(index);
    echo("index:" .. tostring(index));
    --是不是最后一个listItem
    if table.length(data) <= 7 and index == adapter:getItemNum() then
        self.txt_name1:setString("我要告诉你不足7人3天解散！");
    else 
        --名字
        self.txt_name1:setString(data._id);
        --权限
        self.mc_zhiwei1:showFrame(data.right);
        --btn
        if UserModel:_id() == data._id then --是自己
            self.mc_caozuobtn1:showFrame(1);
            self.mc_caozuobtn1.currentView.btn_tuichu1:setTap(
                c_func(self.quitGuild, self, data, index));
        else 
            self.mc_caozuobtn1:showFrame(2);
            self.mc_caozuobtn1.currentView.btn_xiangqing1:setTap(
                c_func(self.memberDetail, self, data, index));
        end 
    end 

	return self;
end

function GuildMemberItem:memberDetail(memberData, index)
    echo("memberData");
    WindowControler:showWindow("GuildMemberDetailView", memberData);    
end

function GuildMemberItem:quitGuild(memberData, index)
    echo("退出公会");

    WindowControler:showAlertView(
        {
            title = "退出公会", 
            des = "确定要退出公会吗",
            isSingleBtn = false,
            secondBtnCallBack = function ()
                EventControler:dispatchEvent(GuildEvent.GUILD_QUIT_EVENT, 
                    {id = memberData._id});
            end,

        }
    ); 
end

return GuildMemberItem;












