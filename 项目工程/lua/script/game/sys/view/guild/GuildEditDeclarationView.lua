--guan
--2016.1.15

local GuildEditDeclarationView = class("GuildEditDeclarationView", UIBase);

--[[
    self.btn_xiugai1,
    self.scale9_xiugaidi,
    self.scale9_xiugaidi2,
    self.txt_xiugaigaoshi,
    self.txt_xiugaineirong,
]]

function GuildEditDeclarationView:ctor(winName)
    GuildEditDeclarationView.super.ctor(self, winName);
end

function GuildEditDeclarationView:loadUIComplete()
	self:registerEvent();
end 

function GuildEditDeclarationView:registerEvent()
	GuildEditDeclarationView.super.registerEvent();
    self.btn_xiugai1:setTap(c_func(self.press_btn_xiugai1, self));
end

function GuildEditDeclarationView:press_btn_xiugai1()
    echo("press_btn_xiugai1");

    local inputStr = self.input_xiugaineirong:getText();

    EventControler:dispatchEvent(GuildEvent.GUILD_MODITY_CONFIG_EVENT, 
        {configs = {notice = inputStr}});

    self:startHide();
end


function GuildEditDeclarationView:updateUI()
	
end


return GuildEditDeclarationView;
