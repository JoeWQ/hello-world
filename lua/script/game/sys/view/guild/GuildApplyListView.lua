--guan
--2016.1.12

local GuildApplyListView = class("GuildApplyListView", UIBase);

--[[
    self.UI_guild_liebiaoshenqing,
    self.btn_close,
    self.btn_kuaisuyaoqing1,
    self.mc_gouxuan1,
    self.panel_liebiaodi1.btn_jujue1,
    self.panel_liebiaodi1.btn_tongyi1,
    self.panel_liebiaodi1.mc_player1,
    self.panel_liebiaodi1.panel_playkuang1,
    self.panel_liebiaodi1.scale9_sqditiao,
    self.panel_liebiaodi1.txt_lv1,
    self.panel_liebiaodi1.txt_name1,
    self.panel_liebiaodi1.txt_zhandouli,
    self.panel_liebiaodi1.txt_zhandouzhi,
    self.scale9_liebiao1,
    self.scroll_list,
    self.txt_shenhewenzi,
    self.txt_titleshenqing,
]]

function GuildApplyListView:ctor(winName, applyList, isNeedVerify)
    GuildApplyListView.super.ctor(self, winName);
    self._applyList = applyList;
    self._isNeedVerify = isNeedVerify;
end

function GuildApplyListView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function GuildApplyListView:initUI()
    --todo 从后端读
    if self._isNeedVerify == false then 
        self.mc_gouxuan1:showFrame(2);
    else 
        self.mc_gouxuan1:showFrame(1);
    end 

    self:initList();
end

function GuildApplyListView:registerEvent()
	GuildApplyListView.super.registerEvent();
    self.btn_kuaisuyaoqing1:setTap(c_func(self.press_btn_kuaisuyaoqing1, self));
    self.btn_close:setTap(c_func(self.press_btn_close, self));

    self.mc_gouxuan1:setTouchedFunc(c_func(GuildApplyListView.changeVerify, self));

    --修改完成
    EventControler:addEventListener(GuildEvent.GUILD_MODITY_CONFIG_OK_EVENT,
        self.modifyOk, self); 
end

function GuildApplyListView:initList()
    -- local data = {"a"};
    --创建adapter
    local adapter = GridViewAdapter.new(self._applyList);
    adapter:setUIView(self);

    self.scroll_list:recreateUI(adapter);
end

function GuildApplyListView:changeVerify()
    if self._isVerifyChange == nil or self._isVerifyChange == false then 
        self._isVerifyChange = true;
    else 
        self._isVerifyChange = false;
    end

    if self._isNeedVerify == true then 
        self._isNeedVerify = false;
        self.mc_gouxuan1:showFrame(2);
        echo("不需审核");
    else
        self._isNeedVerify = true;
        self.mc_gouxuan1:showFrame(1);
        echo("需要审核");
    end 
end

function GuildApplyListView:press_btn_kuaisuyaoqing1()
    echo("快速邀请");
end

function GuildApplyListView:press_btn_close()
    --判断是否需要发出改变审核
    if self._isVerifyChange == true then 
        local isNeddVerify = self._isNeedVerify == true and 1 or 0;
        EventControler:dispatchEvent(GuildEvent.GUILD_MODITY_CONFIG_EVENT, 
            {configs = {needApply = isNeddVerify}});
    else 
        self:startHide();
    end 
end


function GuildApplyListView:updateUI()
	
end

function GuildApplyListView:modifyOk(data)
    local configs = data.params.configs;

    --needApply变化
    if configs.needApply ~= nil then 
        echo('needApply变化');
        self:startHide();
    end 
end


return GuildApplyListView;





