--guan
--2016.2.25

local TrailRegulationView = class("TrailRegulationView", UIBase);

--[[
    self.UI_diban,
    self.panel_1,
    self.panel_back,
    self.scroll_huadong,
    self.txt_1,
]]

function TrailRegulationView:ctor(winName)
    TrailRegulationView.super.ctor(self, winName);
end

function TrailRegulationView:loadUIComplete()
	self:registerEvent();

    FuncCommUI.setViewAlign(self.panel_back, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.panel_1, UIAlignTypes.LeftTop);

    self:initScrollUI();
end 

function TrailRegulationView:registerEvent()
	TrailRegulationView.super.registerEvent();

	self.panel_back.btn_1:setTap(c_func(self.press_btn_back, self));
end

function TrailRegulationView:initScrollUI()
    self.txt_1:setVisible(false);

    local createRankItemFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.txt_1);
        self:updateItem(view, itemData)
        return view;
    end

    self._scrollParams = {
        {
            data = {1},
            createFunc = createRankItemFunc,
            perFrame = 0,
        },
    }

    self.scroll_huadong:styleFill(self._scrollParams);
end

function TrailRegulationView:updateItem(view, itemData)
	-- local str = GameConfig.getLanguage("#tid28019");
	-- view:setString(str);
end

function TrailRegulationView:press_btn_back()
	self:startHide();
end

function TrailRegulationView:updateUI()
	
end


return TrailRegulationView;
