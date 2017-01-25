local DefenderHelpView = class("DefenderHelpView",UIBase);



function DefenderHelpView:ctor(winName)
	DefenderHelpView.super.ctor(self, winName);   ---把自身当参数传入
end

function DefenderHelpView:loadUIComplete()      -----加载UIflash文件
	--适配
	FuncCommUI.setViewAlign(self.btn_back,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.panel_xianyu,UIAlignTypes.RightTop)
	FuncCommUI.setScale9Align(self.scale9_black,UIAlignTypes.MiddleTop,1,0)
	self.btn_back:setTap(c_func(self.press_btn_close,self));


	self:setscroll_listData()

end
function DefenderHelpView:setscroll_listData()
	self.panel_shuoming3.UI_1:visible(false)
	self.panel_shuoming1:visible(false)
	self.panel_shuoming2:visible(false)
	self.panel_shuoming3:visible(false)

	
	

	-- self.panel_shuoming1.txt_1:setString(titlestr1)
	-- self.panel_shuoming1.txt_2:setString(str2)

	-- self.panel_shuoming2.txt_1:setString(str3)
	-- self.panel_shuoming2.txt_2:setString(str4)
	-- self.panel_shuoming2.txt_3:visible(false)
	-- self.panel_shuoming2.txt_4:setString(str5)





	local createFunc_1 = function (itemdata)
		local itemView = UIBaseDef:cloneOneView( self.panel_shuoming1 )
			local titlestr1 = GameConfig.getLanguageWithSwap("#tid4301")
			local str2 = GameConfig.getLanguage("#tid4302")
			itemView.txt_1:setString(titlestr1)
			itemView.txt_2:setString(str2)
		return itemView
	end
	local createFunc_2 = function (itemdata)
		local itemView = UIBaseDef:cloneOneView( self.panel_shuoming2 )
			local str3 = GameConfig.getLanguage("#tid4303")
			local str4 = GameConfig.getLanguage("#tid4304")
			local str5 = GameConfig.getLanguage("#tid4305")
			itemView.txt_1:setString(str3)
			itemView.txt_2:setString(str4)
			itemView.txt_3:visible(false)
			itemView.txt_4:setString(str5)
		return itemView
	end
	

		local params = {
			{
				data = {1},
				createFunc= createFunc_1,
				perNums=1,
				offsetX =20,
				offsetY =10,
				itemRect = {x=0,y=-140,width=895,height = 140},
				perFrame = 2,
				heightGap = 0
			},
			{
				data = {1},
				createFunc= createFunc_2,
				perNums=1,
				
				offsetX =20,
				offsetY =10,
				itemRect = {x=0,y=-170,width=895,height = 170},
				perFrame = 2,
				heightGap = 0
			},
		}





		self.awardData = FuncDefender.getItemData()
		local awardDataNumber = 0
		for k,v in pairs(self.awardData) do
			awardDataNumber = awardDataNumber + 1
		end
		for i=1,awardDataNumber do
			local rewardArray = self.awardData[tostring(i)].reward
			local createFunc_3 = function (itemdata)
				local itemView = UIBaseDef:cloneOneView( self.panel_shuoming3 )
				self:updateItem(itemView, itemdata)
				return itemView
			end
			local newparams = {
				data = rewardArray,
				createFunc= createFunc_3,
				perNums=#rewardArray,
				offsetX =20,
				offsetY =0,
				itemRect = {x=0,y=-80,width=89.5,height = 80},
				perFrame =#rewardArray,
				heightGap = 0
			};
			-- echo("=====================111111111==========================")
			table.insert(params,newparams)
		end
		-- dump(params,nil,6) 

		self.scroll_1:styleFill(params)
		self.itemDatanumber = 1
		self.chaptnumber = 1

end
function DefenderHelpView:updateItem(View,itemData)
	-- dump(itemData,nil,6)
	local reward = string.split(itemData, ",");
	local rewardType = reward[1];
	local rewardNum = reward[table.length(reward)];
	local rewardId = reward[table.length(reward) - 1];
	View.txt_2:setString("守"..self.chaptnumber.."波:")
	local  defenderRewardView1 = View.UI_1
    defenderRewardView1:setResItemData({reward = itemData})
    FuncCommUI.regesitShowResView(defenderRewardView1,
            rewardType, rewardNum, rewardId, itemData, true, true);
    
    if self.itemDatanumber ~= 1 then
    	View.txt_2:visible(false)
    end
    if self.itemDatanumber == #self.awardData[tostring(self.chaptnumber)].reward then
    	self.chaptnumber = self.chaptnumber + 1
    	self.itemDatanumber = 0
    end
    self.itemDatanumber =  self.itemDatanumber + 1
end


function DefenderHelpView:press_btn_close()    ----点击使得该层消失
	self:startHide()
end
return DefenderHelpView


