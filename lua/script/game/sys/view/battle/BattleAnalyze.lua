




--[[
战斗伤害统计
]]
local BattleAnalyze = class("BattleAnalyze", UIBase);




 BattleAnalyze.damages=
        {
            camp1 = 
            {
                [5001] = {
                    hid = 5001,
                    damage = 100,
                    icon = "lixiaoyao",
                    percent = 40,
                    name = "张三",
                    maxDamage = 40000,
                },
                [5002] = {
                    hid = 5002,
                    damage = 100,
                    icon = "lixiaoyao",
                    percent = 40,
                    name = "张三",
                    maxDamage = 40000,
                },
                [5003] = {
                    hid = 5003,
                    damage = 100,
                    icon = "lixiaoyao",
                    percent = 40,
                    name = "张三",
                    maxDamage = 40000,
                },
                [5004] = {
                    hid = 5004,
                    damage = 100,
                    icon = "lixiaoyao",
                    percent = 40,
                    name = "张三",
                    maxDamage = 40000,
                },
                [5005] = {
                    hid = 5005,
                    damage = 100,
                    icon = "lixiaoyao",
                    percent = 40,
                    name = "张三",
                    maxDamage = 40000,
                },
                [5006] = {
                    hid = 5006,
                    damage = 100,
                    icon = "lixiaoyao",
                    percent = 40,
                    name = "张三",
                    maxDamage = 40000,
                }
            },
            camp2 = {
                 [5001] = {
                    hid = 5001,
                    damage = 100,
                    icon = "lixiaoyao",
                    percent = 40,
                    name = "张三",
                    maxDamage = 40000,
                },
                [5002] = {
                    hid = 5002,
                    damage = 100,
                    icon = "lixiaoyao",
                    percent = 40,
                    name = "张三",
                    maxDamage = 40000,
                },
                [5003] = {
                    hid = 5003,
                    damage = 100,
                    icon = "lixiaoyao",
                    percent = 40,
                    name = "张三",
                    maxDamage = 40000,
                },
                [5004] = {
                    hid = 5004,
                    damage = 100,
                    icon = "lixiaoyao",
                    percent = 40,
                    name = "张三",
                    maxDamage = 40000,
                },
                [5005] = {
                    hid = "5005",
                    damage = 100,
                    icon = "lixiaoyao",
                    percent = 40,
                    name = "张三",
                    maxDamage = 40000,
                },
                [5006] = {
                    hid = 5006,
                    damage = 100,
                    icon = "lixiaoyao",
                    percent = 40,
                    name = "张三",
                    maxDamage = 40000,
                }
            }
        }        



function BattleAnalyze:ctor(winName,params)
    BattleAnalyze.super.ctor(self, winName);
    --self.isUpgrade = false
    --self.battleDatas = params
    self.data = self.damages
end

function BattleAnalyze:loadUIComplete()
    self:registerEvent();
    self:uiAdjust()
    self:updateUI()
    --self:setViewStyle()
    --WindowControler:createCoverLayer(nil, nil, GameVars.bgAlphaColor):addto(self, -2)
   
end 

function BattleAnalyze:setViewStyle()


end 


--[[
界面进行适配
]]
function BattleAnalyze:uiAdjust()

    --上边的背景条
    FuncCommUI.setScale9Align( self.scale9_1,UIAlignTypes.MiddleTop )

    --Title左上
    FuncCommUI.setViewAlign(self.panel_1,UIAlignTypes.LeftTop)
    --按钮右上
    FuncCommUI.setViewAlign(self.btn_back,UIAlignTypes.RightTop)
end




function BattleAnalyze:registerEvent()
    self.btn_back:setTap(c_func(self.doCloseSelf,self))
end


 

function BattleAnalyze:updateUI()

    --self:playWinEff()
    self:updateList()

    --self.
end


--[[
更新列表中的数据
]]
function BattleAnalyze:updateList(  )
    local leftData = table.values(self.data.camp1)
    local rightData = table.values(self.data.camp2)
    for i=1,6,1 do
        local leftView = self["panel_left_"..i]
        self:updateItem(leftView,leftData[i])
        local rightView = self["panel_right_"..i]
        self:updateItem(rightView,rightData[i])
    end
end

--[[
更新每一项的数据
]]
function BattleAnalyze:updateItem( view,data )
    if data == nil then
        view:visible(false)
        return
    end
    view:visible(true)
    if LoginControler:isLogin() then
        local icon = FuncPartner.getPartnerById(data.hid).icon
        view.panel_1.ctn_1:addChild(display.newSprite( FuncRes.iconHero(icon ..".png")):size(78,78) )
    end
    view.panel_1.panel_1.txt_1:visible(false)
    view.panel_1.panel_1.txt_2:visible(false)
    view.panel_1.panel_1.progress_1:visible(false)
    view.panel_1.panel_1.scale9_1:visible(false)

    view.txt_2:setString(data.name.."("..data.percent..")")
    view.progress_1:setPercent(data.percent)

    

end





function BattleAnalyze:doCloseSelf(  )
    echo("点击关闭按钮---------")
    self:startHide()
end


function BattleAnalyze:hideComplete()
    BattleAnalyze.super.hideComplete(self)
    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
end


function BattleAnalyze:deleteMe()
    BattleAnalyze.super.deleteMe(self)
    self.controler = nil
end 

return BattleAnalyze;
