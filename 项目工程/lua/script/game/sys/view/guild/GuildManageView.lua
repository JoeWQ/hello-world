--guan
--2016.1.11

local GuildManageView = class("GuildManageView", UIBase);

--[[
    self.UI_guild_xinxi,
    self.btn_close,
    self.btn_gai1,
    self.btn_shengqinglable1,
    self.btn_xiugai1,
    self.panel_biaozhikuang.panel_1,
    self.panel_biaozhikuang.panel_2,
    self.panel_exp1,
    self.panel_exp1.progress_xianmenglv1,
    self.panel_exp1.txt_exp,
    self.panel_xiangqingtiaomu.panel_liebiao1,
    self.scale9_IDdi,
    self.scale9_chengyuandi,
    self.scale9_namedi1,
    self.scale9_xiangqingdi2,
    self.scale9_xuanyandi,
    self.scroll_list,
    self.txt_benzhougongx,
    self.txt_caozuo,
    self.txt_chengyuannum,
    self.txt_dengji,
    self.txt_id1,
    self.txt_lv1,
    self.txt_name,
    self.txt_touxiang,
    self.txt_xianmengcy,
    self.txt_xianmengid,
    self.txt_xianmengname1,
    self.txt_xuanyan,
    self.txt_xuanyanneirong,
    self.txt_zhiwei,
]]

function GuildManageView:ctor(winName)
    GuildManageView.super.ctor(self, winName);
    self._guildInfo = GuildModel:getGuildBaseInfo();
    self._allMembers = GuildModel:getGuildMembersInfo();
end

function GuildManageView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function GuildManageView:registerEvent()
	GuildManageView.super.registerEvent();
    self.btn_shengqinglable1:setTap(c_func(self.press_btn_shengqinglable1, self));
    self.btn_gai1:setTap(c_func(self.press_btn_gai1, self));
    self.btn_xiugai1:setTap(c_func(self.press_btn_xiugai1, self));
    self.btn_close:setTap(c_func(self.press_btn_close, self));

    --申请列表返回成功
    EventControler:addEventListener(GuildEvent.GUILD_GET_APPLY_LIST_OK_EVENT,
        self.getApplyListCallBack, self); 

    --修改完成
    EventControler:addEventListener(GuildEvent.GUILD_MODITY_CONFIG_OK_EVENT,
        self.modifyOk, self);  

    --member 变化
    EventControler:addEventListener(GuildEvent.GUILD_MEMBER_CHANGE_EVENT,
        self.memberChange, self); 

    --退出公会   
    EventControler:addEventListener(GuildEvent.GUILD_QUIT_OK_EVENT,
        self.press_btn_close, self); 
end

function GuildManageView:initUI()
    self.panel_xiangqingtiaomu:setVisible(false);
    self:initList();
    self._isInputEnable = true;

    self:initBaseInfo();
end

function GuildManageView:initBaseInfo()
    --宣言
    local baseInfo = GuildModel:getGuildBaseInfo();
    self.input_xuanyanneirong:setText(baseInfo.desc or "没有公告");

    --能否修改
    if GuildModel:getMyRight() == GuildModel.MEMBER_RIGHT.PEOPLE then 
        self.btn_xiugai1:setVisible(false);
        self.btn_shengqinglable1:setVisible(false);
        self.btn_gai1:setVisible(false);
        self.input_xuanyanneirong:setEnabled(false);
    end

    --名字
    self.txt_xianmengname1:setString(baseInfo.name);
    --id
    self.txt_id1:setString(baseInfo._id);
    --成员数
    self.txt_chengyuannum:setString(tostring(baseInfo.members) .. "/20");
end

function GuildManageView:initList()
    dump(self._allMembers, "self._allMembers");

    local data = table.getNewTableWithOutKey(self._allMembers);

    local fucSort = function (a, b)
        return a.right < b.right;
    end

    table.sort(data, fucSort);

    if (table.length(data) < 7 ) then
        --空的，显示不足干掉
        table.insert(data, {});
    end 
    -- dump(data, "_________data");
    --创建adapter
    local adapter = GridViewAdapter.new(data);
    adapter:setUIView(self);

    self.scroll_list:recreateUI(adapter);
end

function GuildManageView:press_btn_shengqinglable1()
    echo("申请列表");
    -- dump(UserModel:guildExt(), "__fsff");
    local myGuildId = UserModel:guildExt().id;
    --发出得到申请列表的协议
    EventControler:dispatchEvent(GuildEvent.GUILD_GET_APPLY_LIST_EVENT, 
        {guildId = myGuildId});
end

function GuildManageView:getApplyListCallBack(data)
    local applyList = data.params.guildApplyList;
    local isNeddApply = self._guildInfo.needApply == 1 and true or false;
    dump(self._guildInfo, "self._guildInfo");
    WindowControler:showWindow("GuildApplyListView", applyList, isNeddApply);   
end

function GuildManageView:press_btn_gai1()
    local desc = self.input_xuanyanneirong:getText();
    echo("desc:" .. tostring(desc));
    EventControler:dispatchEvent(GuildEvent.GUILD_MODITY_CONFIG_EVENT, 
        {configs = {desc = desc}});
end

function GuildManageView:press_btn_xiugai1()
    echo("修改图标");
    WindowControler:showWindow("GuildChangeIconView");
end

function GuildManageView:press_btn_close()
    self:startHide();
end


function GuildManageView:updateUI()
	
end

function GuildManageView:modifyOk(data)
    local configs = data.params.configs;

    --icon变化
    if configs.icon ~= nil then 
        echo('icon变化');
        self:initBaseInfo();
    end 

    --desc变化
    if configs.desc ~= nil then 
        echo('desc变化');
        GuildModel:getGuildBaseInfo().desc = configs.desc;
        self:initBaseInfo();
    end 
end

function GuildManageView:memberChange(data)
    echo("memberChange");
    if  data.params.right == GuildModel.MEMBER_RIGHT.LEADER then 
        self:initUI();
    else 
        self:initList();
    end 
end


return GuildManageView;







