local BattleChooseRoom = class("BattleChooseRoom", UIBase);

--[[
    self.btn_join,
    self.btn_exit,
    self.btn_back,
    self.panel_1.panel_1,
    self.panel_1.panel_2,
    self.panel_1.panel_3,
    self.panel_1.panel_4,
    self.panel_1.panel_5,
    self.panel_1.panel_6,
    self.rect_back,
    self.txt_2,
]]

function BattleChooseRoom:ctor(winName)
    BattleChooseRoom.super.ctor(self, winName);
end

function BattleChooseRoom:loadUIComplete()
    self:registerEvent(); 
end 

function BattleChooseRoom:registerEvent()
	BattleChooseRoom.super.registerEvent();
    self.btn_exit:setTap(c_func(self.press_btn_exit, self));
    self.btn_back:setTap(c_func(self.press_btn_back, self));
    self.btn_join:setTap(c_func(self.press_btn_join, self));
    self.btn_loadResOver:setTap(c_func(self.press_btn_loadResOver, self));

    --开始战斗
    self.btn_start:setTap(c_func(self.press_btn_start, self));


    --释放法宝
    self.btn_giveSkill:setTap(c_func(self.press_btn_giveSkill, self));
    self.btn_auto:setTap(c_func(self.press_btn_auto, self));
    self.btn_over:setTap(c_func(self.press_btn_over, self));
    self.btn_over_2:setTap(c_func(self.press_btn_over_2, self));

    self.btn_pipei:setTap(c_func(self.press_btn_pipei, self))
    self.btn_jionpipei:setTap(c_func(self.press_btn_jionpipei, self))


    EventControler:addEventListener("notify_battle_userJoinRoom_704", self.notify_battle_userJoinRoom_704, self)
    EventControler:addEventListener("notify_battle_userQuitRoom_732", self.notify_battle_userQuitRoom_732, self)

    EventControler:addEventListener("notify_battle_start_708", self.notify_battle_start_708, self)
    EventControler:addEventListener("notify_battle_useTreasure_716", self.notify_battle_useTreasure_716, self)
    EventControler:addEventListener("notify_battle_useAutoFight_724", self.notify_battle_useAutoFight_724, self)

    EventControler:addEventListener("notify_battle_pushTimeLine_710", self.notify_battle_pushTimeLine_710, self)
    EventControler:addEventListener("notify_battle_gameResult_720", self.notify_battle_gameResult_720, self)
    
    EventControler:addEventListener("notify_battle_loadBattleResOver_736", self.notify_battle_loadBattleResOver_736, self)

    EventControler:addEventListener("notify_match_intive_906", self.notify_match_intive_906, self)
    EventControler:addEventListener("notify_match_timeout_908", self.notify_match_timeout_908, self)

    self:showOneCampInfo(1,camp1)
    self:showOneCampInfo(2,camp2) 

    -- WindowControler:showTips({text="tip测试"})

    local roomId = LS:pub():get("roomId",100)
    self.input_1:setText(roomId)


    --有上一场没有完成的战斗id
    

end




--通知事件------------------------------------------------------------
-- 资源加载loading完成，开始战斗
function BattleChooseRoom:notify_battle_loadBattleResOver_736()
    self._isLoadResOver = true
    self.txt_warn:setString("(战斗中)")
    self:showInfo("[notify:]战斗开始----")

end

--战斗开始
function BattleChooseRoom:notify_battle_start_708( e )
    self._isStart = true
    self:showInfo("[notify:]战斗准备中----")
    self.txt_warn:setString("(加载资源loading...)")
end


--使用法宝
function BattleChooseRoom:notify_battle_useTreasure_716(e )
    -- self:showInfo(e.params.params.data.magicInfo  )
    local data = e.params.params.data
    self:showInfo(data.rid .. " 释放法宝")
end

--切换自动战斗状态
function BattleChooseRoom:notify_battle_useAutoFight_724( e )
    local data = e.params.params.data
    self:showInfo(data.rid .. " 切换为自动战斗")
end

--切换自动战斗状态
function BattleChooseRoom:notify_battle_pushTimeLine_710( e )
    local data = e.params.params.data

    local frame = data.frame

    -- BattleServer:pushTimeline(frame,{message="sumbit time line"})

    --self:showInfo("[notify] 切换自动操作状态")
end

--游戏结果判定
function BattleChooseRoom:notify_battle_gameResult_720(e )
    local data = e.params.params.data
    self:showInfo( "战斗结果:".. data.rt)
end


--用户加入房间
function BattleChooseRoom:notify_battle_userJoinRoom_704( e )

    local result = e.params.params

    local data = result.data

    local campInfo = self["_campInfo"..data.userInfo.team]
    local  userInfo =  data.userInfo
    table.insert(campInfo, userInfo)

    self:showOneUser(data.userInfo.team, #campInfo, userInfo)
end

--用户退出房间
function BattleChooseRoom:notify_battle_userQuitRoom_732( e )
    local result = e.params.params
    local data = result.data
    local rid = data.rid

    self:quitRome(data.team,rid)
    self:showOneCampInfo(data.team,campInfo)
end

  -- 退出房间，从阵营中删除
function BattleChooseRoom:quitRome(team,rid)
    local campInfo = self["_campInfo"..team]

    for i=1,#campInfo do
        if tostring(campInfo[i].rid == tostring(rid)) then
            table.remove(campInfo,i)
        end
    end
end


function BattleChooseRoom:notify_match_intive_906( e )
    --dump(e.params,"___匹配结果")
    --[[
    "method" = 906
    "params" = {
         "data" = {
             "poolSystem" = "1"
         }
     }
     "pushId" = 1000829

    ]]
    --dump(e.params)
    self.matchData = e.params.params.data
    self:showInfo("[notify:]906_有人邀请加入战斗")
    echo("906_有人邀请加入战斗-----")
end

function BattleChooseRoom:notify_match_timeout_908( e )
    self:showInfo("[notify:]908_匹配超时")
    echo("908_匹配超时-----")
end

--按钮事件------------------------------------------------------
--退出房间
function BattleChooseRoom:press_btn_exit()
    local roomId =tonumber( self.input_1:getText() )
    --BattleServer:quitOneRoom(roomId,c_func(self.quitRoomBack,self))
end

-- 退出房间回调
function BattleChooseRoom:quitRoomBack(result)
    echo("____quit room back")
    if not result then
        echo("___退出房间失败")
        return
    end

    local campInfo = self["_campInfo"..self.team]
    local rid = UserModel:rid()

    self:quitRome(self.team,rid)
    self:showOneCampInfo(self.team,campInfo)
end

--返回按钮
function BattleChooseRoom:press_btn_back()
    self:startHide()
end

--加入房间
function BattleChooseRoom:press_btn_join()
    local roomId =tonumber( self.input_1:getText() )
    LS:pub():set("roomId",roomId +1 )
    BattleServer:joinOneRoom(roomId,c_func(self.joinRoomBack,self))
end

--开始战斗
function BattleChooseRoom:press_btn_start()
    BattleServer:startBattle()
end

--通知server loading完成
function BattleChooseRoom:press_btn_loadResOver()
    BattleServer:loadBattleResOver()
end

--释放技能
function BattleChooseRoom:press_btn_giveSkill()
    if not self:checkBattleStatus() then
        return
    end
    local frame = 2

    local info = {message = LoginControler:getCid() .. "give skill--"}

    --BattleServer:giveOutTreasure( info,frame )
end

-- 切换自动战斗
function BattleChooseRoom:press_btn_auto(  )
    if not self:checkBattleStatus() then
        return
    end

    local frame = 3

    local info = {message = UserModel:rid() .. " set Auto Fight--"}

    local t = self.isAutoFight and 1 or 2

    -- BattleServer:changeHandle( t ,frame)
end


--战斗胜利
function BattleChooseRoom:press_btn_over(  )
    if not self:checkBattleStatus() then
        return
    end

    --BattleServer:submitGameResult( 100,{message="submit game result"},numEncrypt:getNum1() )

end

--战斗失败
function BattleChooseRoom:press_btn_over_2(  )
    if not self:checkBattleStatus() then
        return
    end

    --BattleServer:submitGameResult( 100,{message="submit game result "},numEncrypt:getNum0() )
end


--开始匹配
function BattleChooseRoom:press_btn_pipei(  )
    BattleServer:startMatch("1",c_func(self.pipeiBack, self) )
    self:showInfo("[notify:]901_向服务器请求匹配----")
end


--匹配返回
function BattleChooseRoom:pipeiBack( result )
    --dump(result,"__match result")
    self:showInfo("[notify:]902_服务器回复匹配中----")
end


--加入匹配池
function BattleChooseRoom:press_btn_jionpipei(  )
    if not self.matchData then
        self:showInfo("还没加入匹配信息")
        return
    end
    BattleServer:joinMatch(self.matchData.poolSystem,c_func(self.jionpipeiBack, self) )
end

--匹配返回
function BattleChooseRoom:jionpipeiBack( result )
    echo("904__加入匹配返回,服务器时间,超时时间",result.result.serverInfo.serverTime,result.result.data.idleExpireTime)
end

-- 检查战斗状态
function BattleChooseRoom:checkBattleStatus()
  if not BattleServer.battleId then
      -- self:showInfo("战斗还没开始准备")
      WindowControler:showTips("战斗还没开始准备")
      return false
  end

  if not self._isLoadResOver then
      -- self:showInfo("正在加载战斗资源")
      WindowControler:showTips("玩命加载战斗资源loading...")
      return false
  end

  return true
end

function BattleChooseRoom:joinRoomBack( result )
    result = result.result
    if not result then
        echo("___加入房间失败")
        return
    end

    local data = result.data
    local rid = UserModel:rid()
    self._campInfo1 = {}
    self._campInfo2 = {}
    for i,v in pairs(data.battleUsers) do
        if v.team == Fight.camp_1 then
            table.insert(self._campInfo1, v )
        else
            table.insert(self._campInfo2, v )
        end 
    end

    self:showOneCampInfo(1,self._campInfo1)
    self:showOneCampInfo(2,self._campInfo2)

    BattleServer:requestSelfState(nil,"battle")
end

function BattleChooseRoom:showOneCampInfo( camp,info )
    local panel = self["panel_"..camp]
    if not info then
        info = {}
    end

    for i=1,6 do
        self:showOneUser(camp,i,info[i])
    end
end


function BattleChooseRoom:showOneUser( camp,pos,userInfo )
    local panel = self["panel_"..camp]
    local userPanel = panel["panel_"..pos]


    if not userInfo then
        userPanel.txt_1:setString("等待加入")
    else
        if type(userInfo) == "string" then
            userInfo = json.decode(userInfo)
        end

        userPanel.txt_1:setString(userInfo.name)
    end

end

function BattleChooseRoom:showInfo(txt)
    if not self._strText then
        self._strText = txt

    else
        self._strText = txt .. "\n" .. self._strText
    end

    self.txt_info:setString(self._strText);
end

function BattleChooseRoom:updateUI()
	
end


return BattleChooseRoom
