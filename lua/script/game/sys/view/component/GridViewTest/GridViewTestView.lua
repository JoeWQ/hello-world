local GridViewTestView = class("GridViewTestView", UIBase);

--[[
    self.btn_back,
    self.scroll_gundong,
    self.UI_kan,
]]

function GridViewTestView:ctor(winName)
    GridViewTestView.super.ctor(self, winName);
end

function GridViewTestView:loadUIComplete()
	self:registerEvent();

	local gridView = self.scroll_gundong;
    --gridView要用到的数据
    local tableData = {"1", "2", "3", "4",
                       "5", "6", "7", "8",
                       "9", "10", "11", "12",
                       "13", "14", "15", "16",
                       "aaa", "bbb", "ccc", "ddd",
                       "aaa", "bbb", "ccc", "ddd",
                       "aaa", "bbb", "ccc", "ddd",
                       "aaa", "bbb", "ccc", "ddd",
                       "9", "10", "ccc", "ddd",
                       "aaa", "bbb", "ccc", "ddd",
                       "aaa", "bbb", "ccc", "ddd",
                       "aaa", "bbb", "ccc", "ddd",
                       "aaa", "bbb", "ccc", "ddd",
                       "aaa", "bbb", "ccc", "ddd",
                       "9", "10", "ccc", "ddd",
                       "aaa", "bbb", "ccc", "ddd",
                       "aaa", "bbb", "ccc", "ddd",
                       "aaa", "bbb", "ccc", "ddd",
                       "aaa", "bbb", "ccc", "ddd",
                       "aaa", "bbb", "ccc", "100",
                      };
    --创建adapter
    local adapter = GridViewAdapter.new(tableData);
    --显示gridView
    gridView:setAdapter(adapter);
    gridView:gridViewInit();


    self._gridView = gridView;
    self._adapter = adapter;
end 

function GridViewTestView:registerEvent()
    self.btn_back:setTap(c_func(self.press_btn_back, self));
end

function GridViewTestView:press_btn_back()
	self:startHide();
	-- self._gridView:scrollToPosByPrecent(50);
	-- self._gridView:addItemByIndex("50", 3);
end


function GridViewTestView:updateUI()
	
end


return GridViewTestView;
