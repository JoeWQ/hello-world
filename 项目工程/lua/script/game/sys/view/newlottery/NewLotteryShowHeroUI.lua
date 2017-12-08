-- NewLotteryShowHeroUI
--三皇抽奖系统
--2016-1-6 11:40
--@Author:wukai

local NewLotteryShowHeroUI = class("NewLotteryShowHeroUI", UIBase);

function NewLotteryShowHeroUI:ctor(winName,rewardID,file)    
    NewLotteryShowHeroUI.super.ctor(self, winName)
    self.reward = rewardID
    self.file = file 

end

function NewLotteryShowHeroUI:loadUIComplete()

	-- self:setTap(c_func(self.press_btn_close,self))

	FuncCommUI.setViewAlign(self.panel_1,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.panel_2,UIAlignTypes.RightTop)

    local a_black = FuncRes.a_black(1136*4,640*4)
	self:addChild(a_black,-10)


	self.type = self.panel_title.mc_1
	self.name = self.panel_title.txt_1
	self.Star = self.mc_xing--星级
	self.skillbtn = self.panel_2.ctn_1
	self.skillname = self.panel_2.txt_1    --大招
	self.skilldescribe =  self.panel_2.txt_2 --技能描述
	self.herolineUp =   self.panel_1.txt_2  ---排阵
	self.animation  = self.ctn_3--立绘
	self.txt_1:opacity(0)
	self.panel_1:setPosition(self.panel_1:getPositionX()-150,self.panel_1:getPositionY())
	self.panel_2:setPosition(self.panel_2:getPositionX()+150,self.panel_2:getPositionY())
	
	self:initData(self.reward)
	-- self:registClickClose(-1, c_func( function()
 --        self:press_btn_close()
 --    end , self))

end
function NewLotteryShowHeroUI:initData(award)


	-- dump(award,"伙伴数据显示")
	local partnerID = award
	local  partnerinfo = FuncPartner.getPartnerById(partnerID)
	if partnerinfo == nil then
		echo("不存在伙伴ID",partnerID)
		return 
	end
	-- echo("======partnerinfo.type==initStar==",partnerinfo.type,partnerinfo.initStar)
	self.type:showFrame(partnerinfo.type)
	self.Star:showFrame(partnerinfo.initStar)
	self.name:setString(GameConfig.getLanguage(partnerinfo.name))
	self:addHeroAnimation(partnerID)

	local  _skillInfo = FuncPartner.getSkillInfo(partnerinfo.skill[1])
	local skillname = GameConfig.getLanguage(_skillInfo.name)
	self.skillname:setString(skillname)
	local skill1 = self:getSkillIcon(partnerinfo.skill[1])
	self.skillbtn:addChild(skill1)

	local charaCteristic  =  GameConfig.getLanguage(partnerinfo.charaCteristic)
	self.skilldescribe:setString(charaCteristic)
	local translateFive  =  GameConfig.getLanguage(partnerinfo.translateFive)
	self.herolineUp:setString(translateFive)


end
function NewLotteryShowHeroUI:getSkillIcon(skillId,_skillLevel)
    skillLevel = _skillLevel or 1
    local  _skillInfo = FuncPartner.getSkillInfo(skillId)
    --图标
    local  _iconPath = FuncRes.iconSkill(_skillInfo.icon)
    local  _iconSprite = cc.Sprite:create(_iconPath)
    -- _iconSprite:scale(0.4)
    return _iconSprite
end
function NewLotteryShowHeroUI:addHeroAnimation(partnerId)
	 -----  npc ------
    local ctn = self.ctn_3;
    ctn:removeAllChildren();
    local sp = PartnerModel:initNpc(partnerId)   
    ctn:addChild(sp);

    self.panel_1:runAction(act.moveby(0.5,150,0))
    self.panel_2:runAction(act.moveby(0.5,-150,0))
    -- self.txt_1:visible(true)
    self.txt_1:runAction(act.fadein(1.0))
     self:delayCall(function ()
     	self:registClickClose(-1, c_func( function()
		    self:press_btn_close()
		end , self))
     end,1.0)

end

function NewLotteryShowHeroUI:press_btn_close()
	
	self:startHide()
	if self.file ~= nil then
		if self.file then
			EventControler:dispatchEvent(NewLotteryEvent.RESUME_REWARD_ITEMS)
		end
	end
end

return NewLotteryShowHeroUI
