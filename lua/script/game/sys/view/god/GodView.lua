local GodView = class("GodView", UIBase)

function GodView:ctor(winName)
	GodView.super.ctor(self, winName)
end

function GodView:loadUIComplete()
	self.scroll_list = self.scroll_1
	self:setAlignment()
	self:setGodList()
	self:registerEvent()
    
end


function GodView:setAlignment()
	--设置对齐方式
	FuncCommUI.setViewAlign(self.panel_3, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.btn_1, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_icon, UIAlignTypes.LeftTop)
    FuncCommUI.setScale9Align(self.scale9_1,UIAlignTypes.MiddleTop, 1, 0)
end
function GodView:registerEvent()
    GodView.super.registerEvent();
    self.btn_1:setTap(c_func(self.onBtnBackTap, self));
end

function GodView:setGodList()
    local configData = FuncGod.getConfigGodData();
    self.panel_1:setVisible(false)

	local createFunc = function ( itemData )
		local view = UIBaseDef:cloneOneView(self.panel_1)
		self:updateItem(view, itemData)
		return view
    end
    local reuseUpdateCellFunc = function (itemData, view)
        self:updateItem(view, itemData,true)
        return view;  
    end
    
	local _scrollParams = {
			{
				data = configData,
				createFunc= createFunc,
				perFrame = 1,
				offsetX =0,
				offsetY =0,
				itemRect = {x=0,y= -472,width=318,height = 472},
				widthGap = 40,
                heightGap = 0,
                perNums = 1,
                updateFunc = reuseUpdateCellFunc,

			}
		}
    self.scroll_1:styleFill(_scrollParams);
	self.scroll_1:hideDragBar()

end
function GodView:updateItem(itemView,itemData)
    local framNum = itemData.fla or 1
    local panelInfo = itemView.panel_1
    panelInfo.mc_lihui:showFrame(framNum)
    panelInfo.panel_2.mc_1:showFrame(framNum)
    

    local lockBtn = GodModel:godCanUnlockById(itemData)
    local lockGod = GodModel:godUnlockById(itemData)

    if itemData.fla == 5 then
        panelInfo.mc_lihui:setPositionX(40)
    elseif  itemData.fla == 4 then
        panelInfo.mc_lihui:setPositionX(60)
    else
        panelInfo.mc_lihui:setPositionX(0)
    end
    
    if lockGod == true then
        FilterTools.clearFilter(itemView.mc_1)  
        panelInfo.panel_4:setVisible(false)
        FilterTools.clearFilter(panelInfo.mc_lihui)  
        -- 战斗力
        panelInfo.mc_power:showFrame(1)
        local zdl = GodModel:getZhandouli(itemData)
        local powerValueTable = number.split(zdl);
        self:setPowerNum(panelInfo.mc_power.currentView.panel_1, powerValueTable);
        if GodModel:godForMulaById(itemData) then
            itemView.mc_1:showFrame(3)
        else
            itemView.mc_1:showFrame(2)
            itemView.mc_1.currentView.btn_1:setTap(c_func(self.godBtnTap,self,itemData))
        end
        -- 等级
        panelInfo.panel_2.txt_1:setVisible(true)
        panelInfo.panel_2.txt_2:setVisible(true)
        panelInfo.panel_2.txt_1:setString(GodModel:getGodLevelById(itemData.id))
    else
        panelInfo.panel_4:setVisible(true)
        FilterTools.setGrayFilter(panelInfo.mc_lihui) 
        panelInfo.mc_power:showFrame(2)
        
        itemView.mc_1:showFrame(1)
        itemView.mc_1.currentView.btn_1:setTap(c_func(self.godBtnTap,self,itemData))
        -- 等级
        panelInfo.panel_2.txt_1:setVisible(false)
        panelInfo.panel_2.txt_2:setVisible(false)

        local strLock = GameConfig.getLanguage(itemData.openTranslate)
        panelInfo.mc_power.currentView.txt_1:setString(strLock)
        if lockBtn == true then
            -- 按钮
            FilterTools.clearFilter(itemView.mc_1)
            -- 可激活  
            panelInfo.mc_power.currentView.txt_1:setColor(cc.c3b(0,255,0))
        else
            -- 按钮
            FilterTools.setGrayFilter(itemView.mc_1)
            panelInfo.mc_power.currentView.txt_1:setColor(cc.c3b(255,0,0))
        end
    end
    panelInfo.mc_lihui:setTouchedFunc(c_func(self.godTap,self,itemData))
    
    --
end
-- 
function GodView:setPowerNum(panel_power,nums)
    local len = table.length(nums);
    panel_power.mc_shuzi:showFrame(len);

    for k, v in pairs(nums) do
        local mcs = panel_power.mc_shuzi:getCurFrameView();
        mcs["mc_" .. tostring(k)]:showFrame(v + 1);
    end
end
function GodView:godTap(itemData)
    if self.scroll_1:isMoving() then
        return
    end
    local lock = GodModel:godUnlockById(itemData)
    if lock == true then
        WindowControler:showWindow("GodDetailView",itemData)
    else
        local strLock = GameConfig.getLanguage(itemData.openTranslate)
        WindowControler:showTips(strLock)
    end
    
end

function GodView:godActivateCallBack(event)
    echo("godActivateCallBack 神明激活")
    if not event.result then
		return
	end
    self:setGodList()
end
function GodView:godFormulaCallBack(event)
    echo("godActivateCallBack 神明上阵")
    if not event.result then
		return
	end
    self:setGodList()
end
function GodView:godBtnTap(itemData)
    echo("神明 btnTap 测试")
    local lockBtn = GodModel:godCanUnlockById(itemData)
    local lockGod = GodModel:godUnlockById(itemData)
    if lockBtn then
        if lockGod then
            -- 可以上阵
            GodServer:godFormula(itemData.id,c_func(self.godFormulaCallBack,self))
        else
            -- 可以激活
            GodServer:godActivate(itemData.id,c_func(self.godActivateCallBack,self))
        end
    else
        -- 不可以 激活
        WindowControler:showTips("条件不足")
    end
end
--返回 
function GodView:onBtnBackTap()
	self:startHide()
end

return GodView
