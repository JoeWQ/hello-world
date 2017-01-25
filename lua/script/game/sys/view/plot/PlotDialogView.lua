local PlotDialogView = class("PlotDialogView", UIBase)

--//逆向映射表
local     EmojiMap={
        UI_lihuibiaoqing_1="expression_jingya",--//惊讶
        UI_lihuibiaoqing_11="expression_yiwen",--//疑问
        UI_lihuibiaoqing_13="expression_yun",--//晕
        UI_lihuibiaoqing_3="expression_fennu",--//愤怒
        UI_lihuibiaoqing_5="expression_gaoxing",--//高兴
        UI_lihuibiaoqing_7="expression_liuhan",--//流汗
        UI_lihuibiaoqing_9="expression_ku",--//哭泣
};
--//主角动画映射
local    PlayerMap={
        [1]="art_NanZhuLiHui",--//男主角
        [2]="art_NvZhuLiHui",--//女主角
};
-- 克隆原件子集内的组件
-- local view = UIBaseDef:cloneOneView(self.mc_mailzong1:getViewByFrame(1).panel_1)
function PlotDialogView:ctor(winName, data)
    PlotDialogView.super.ctor(self, winName)
    local topBorderBg = display.newColorLayer(cc.c4b(100, 50, 30, 255))
    topBorderBg:setPlotLayerSize(GameVars.width+300,GameVars.height+300);

    self.sire = data
    self.oldRes = ""
    self.plotAni = nil
    self.oldPos = 0
    self.oldArtPos = 0
    topBorderBg:setPosition(cc.p(100, 100));
    self:addChild(topBorderBg)

    self.ANI_RUN_ACTION =
    {
        MIDDLE_TO_LEFT = 80,
        MIDDLE_TO_RIGHT = 81,
        LEFT_TO_MIDDLE = 82,
        RIGHT_TO_MIDDLE = 83,
        LEFT_TO_RIGHT = 84,
        RIGHT_TO_LEFT = 85,
    }
    self.LOCATION =
    {
        LEFT = 1,
        MIDDLE = 2,
        RIGHT = 3
    }

    self.aniIcon = nil
    self.artIcon = nil
    self.aniCtnPos = 0
 --   self.originPosition=WindowControler:getScene():getPosition();
end
function PlotDialogView:loadUIComplete()
    self.btState = false
    self:registerEvent()
    -- local bg = display.newSprite("test/bgimage01.png"):opacity(255);
    -- bg:anchor(0,0):pos(GameVars.sceneOffsetX - GameVars.bgOffsetX,GameVars.sceneOffsetY - GameVars.bgOffsetY)
    -- self:addChild(bg,0);
    -- 设置组件对齐方式
    FuncCommUI.setViewAlign(self.mc_bg, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.ctn_zuo, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.ctn_you, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.ctn_zhong, UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.panel_name1, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.panel_name3, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.panel_name2, UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.panel_1, UIAlignTypes.Left)
    FuncCommUI.setViewAlign(self.panel_3, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.btn_1, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.ctn_1, UIAlignTypes.RightBottom)

    FuncCommUI.setViewAlign(self.rich_1, UIAlignTypes.LeftBottom)

    
    -- 剧情对话框特效
    -- FuncArmature.loadOneArmatureTexture("UI_plot", nil, true)
    self.plotCtn = { self.ctn_zuo, self.ctn_zhong, self.ctn_you }
    self.rich_1:setVisible(false)
    for i = 1, 3 do
        self["panel_" .. i]:setVisible(false)
        self["panel_name" .. i]:setVisible(false)
    end
    self.mc_bg:setScaleX(GameVars.width / GAMEWIDTH)

    self:setOptionVisible(false)
    self:createUIArmature("UI_plot", "UI_plot_ctn_jt", nil,true ,GameVars.emptyFunc):addto(self.ctn_1)
    self.ctn_1:setVisible(false)
end 


 
function PlotDialogView:registerEvent()
    PlotDialogView.super.registerEvent();

    self.btn_1:setTap(c_func( function()
        self.sire:skipPlot()
    end , self));
    self.btn_1:setTouchSwallowEnabled(true);
    --  self.panel_duihua:setGlobalZOrder(100)
    -- 注册点击任意地方事件
    self:registClickClose(-1, c_func( function()
        self.sire:onTouchEvent()
    end , self))

    local _eventCallBack = { }
    for i = 1, 3 do
        _eventCallBack[i] = function()

        end
        self.panel_duihua["btn_duihua" .. i]:setTap(c_func( function()
            echo ("click ---------------here")
            self.sire:optionCallback(i)
            self:setOptionVisible(false)
        end , self));
    end
end 
 function PlotDialogView:setBackGroupImg(board)
    if board == nil then return end 
     if(board>0)then
        self.mc_bg:showFrame(board)
     else
        self.panel_duihua:setVisible(false);
        self.ctn_zuo:removeAllChildren(); ---//tatata
        self.ctn_zhong:removeAllChildren();
        self.ctn_you:removeAllChildren();
     end
 end 
 --//如果是停留动画
 function PlotDialogView:playDelayAni( data)
     assert(data.enterAni==0);
     function callBack()
         local _ipos = data.pos
         local _pos = _yuan3(self.aniCtnPos ~= 0, self.aniCtnPos, _ipos[1])
         self.plotCtn[_pos]:removeAllChildren();--//added
         self.oldPos = _pos
         self.sire:aniCompleteCallBack()
    end
    local  _mDelayAction=cc.DelayTime:create(0.5);
    local  _mCallFunc=cc.CallFunc:create(callBack);
    self.aniIcon:runAction(cc.Sequence:create(_mDelayAction,_mCallFunc));
 end
-- 播放剧情对话 
function PlotDialogView:playPlotAni(data)

    if data.enterAni == 0 then return end
    function callBack()
        self:removeSpineImg()
        local _ipos = data.pos
        self.sire:aniCompleteCallBack()
    end
    echo("_enterAni ---------->>" .. data.enterAni)
    local _aniName = "UI_plot_" .. data.enterAni
    if data.enterAni < 100 then
        self:loadPlayerImg(data, true)
        -- 不存在动画时加载立绘
        return nil
    end
    self:removeSpineImg()
    local _ipos = data.pos

    -- 初始朝向
    self.plotAni = self:createUIArmature("UI_plot", _aniName, nil, false, callBack)
    self.aniIcon = self:loadImgRes(data.img, false,data.emoji)
     local _dir = _yuan3(data.dir == 1, -1, 1)
    -- 设置动画朝向
    self.aniIcon:setScaleX(_dir);

    FuncArmature.changeBoneDisplay(self.plotAni, "node", self.aniIcon)
    local _pos = _yuan3(self.aniCtnPos ~= 0, self.aniCtnPos, _ipos[1])
    self.plotCtn[_pos]:removeAllChildren();--//added
    self.plotCtn[_pos]:addChild(self.plotAni)

    self.oldPos = _pos

end  

function PlotDialogView:setAniSkip()
    FuncArmature.setArmaturePlaySpeed(self.plotAni, 4)
end 
 
-- 加载图片
function PlotDialogView:loadImgRes(resName, isArt,_emoji)
    if resName == nil then 
       echo("loadImgRes image name is null ");
       return 
    end
    local    _image;
--    local _imgName = resName
--    if resName == "player" then
--        _imgName = "art_player_".. UserModel:avatar() .. "_" .. UserModel:state()
--        _imgName = "art_player_102_1"
--        --//如果没有找到资源,就返回空值
--        _image = FuncRes.getArtSpineAni(_imgName)
--       if _image == nil then 
--                echoWarn("---22#########no exist ".._imgName)
--               _image = FuncRes.getArtSpineAni("art_Spine30005")         
--       end 
----          resName =  "art_Spine30005"
--       self.oldRes = resName
--        return _image
--    else 
----        _imgName = "art_Spine30005"
--    end 
--[[    if isArt then
        _image = FuncRes.getArtSpineAni(_imgName)
        if _image == nil then 
          echoWarn("---11#########no exist ".._imgName)
           _image = FuncRes.getArtSpineAni("art_Spine30005")
        end 
        return _image
    else
--//如果没有找到资源,就返回空值
            _image = FuncRes.getArtSpineAni(_imgName)
            if _image == nil then 
                echoWarn("---22#########no exist ".._imgName)
               _image = FuncRes.getArtSpineAni("art_Spine30005")         
            end 
--          resName =  "art_Spine30005"
             self.oldRes = resName
        return _image
    end]]
--//加载Spine动画
   if(resName == "player")then
          local   _sex=UserModel:sex();
          resName = PlayerMap[_sex];
   end
    local     artSpine=ViewSpine.new(resName);
    artSpine:playLabel("stand",true);
    if(_emoji ~=nil )then
        assert(_emoji ~="");
        local   pos=artSpine:getBonePos(EmojiMap[_emoji]);--//加载逆向映射表
        local   ani=self:createUIArmature("UI_lihuibiaoqing", _emoji, artSpine, true, GameVars.emptyFunc);
        ani:pos(pos.x,pos.y);
    end
    return   artSpine;
end 

function PlotDialogView:loadPlayerImg(data, runAct)
    -- 该处可以用于立绘显示 以及  动画所用立绘形象
    local _ipos = data.pos
    -- 初始朝向
   local   _dir=_ipos[2]== 2 and 1 or -1;
    self.aniIcon = self:loadImgRes(data.img, false,data.emoji)
    local _pos = _yuan3(self.aniCtnPos ~= 0, self.aniCtnPos, _ipos[1])
    self.aniIcon:setPositionX(0)
    self.aniIcon:setScaleX(_dir);
    self.plotCtn[_pos]:removeAllChildren();
 --   self.aniIcon:parent(self.plotCtn[_pos])
     self.plotCtn[_pos]:addChild(self.aniIcon)
    self.oldPos = _pos
    if runAct then
        self:runAniAction(data)
    end
end 

function PlotDialogView:runAniAction(data)
    if self.aniIcon == nil then return end
    local _posX = self:getCtnPos(data.enterAni):convertLocalToNodeLocalPos(self.aniIcon)
    self.otherCtn=  self.oldPos
    function _callBack()
        self.sire:aniCompleteCallBack()
    end
    -- local _action = cc.Sequence:create(cc.MoveTo:create(10, cc.p(_posX, self.aniIcon:getPositionY())), cc.CallFunc:create(_callBack))
    local _args = { onComplete = _callBack }
    local _dir = _yuan3(data.pos[2] == 1, 1, -1)
    -- self.aniIcon:setScaleX(_dir)
    transition.execute(self.aniIcon, cc.MoveBy:create(0.5, cc.p(_posX.x*self.aniIcon:getScaleX(), self.aniIcon:getPositionY())), _args)
end 
 
-- 再每次播放动画时都会移除当前动画  
function PlotDialogView:removeSpineImg()
    --  echo("_____removeSpineImg_____")
    if self.oldPos ~= 0 then
        if self.aniIcon ~= nil then
            self.aniIcon:setPositionX(0)
        end
        self.plotCtn[self.oldPos]:removeChild(self.aniIcon)
        self.oldPos = 0
        self.aniIcon = nil
        self.oldRes = ""
    end
    for i = 1, 3 do
        self.panel_duihua["btn_duihua" .. i]:setVisible(false)
        self["panel_" .. i]:setVisible(false)
    end
end

function PlotDialogView:cleanLastAni()
    --  echo("_____cleanLastAni_____")
    if self.oldPos ~= 0 then
 --//       self.plotCtn[self.oldPos]:removeChild(self.aniIcon) --//暂时屏蔽掉,策划说不让删除以前的动画
        self.oldRes = ""
        self.aniIcon = nil
    end
    if self.oldArtPos ~= 0 then
 --       self.plotCtn[self.oldArtPos]:removeChild(self.artIcon)
    end
    if(self.otherCtn ~=nil )then
        self.plotCtn[self.otherCtn]:removeAllChildren();
        self.otherCtn=nil;
        self.aniIcon=nil;
    end
    self.oldRes = ""
    self:setNameVisible(-1)
    self.aniCtnPos = 0
    self.rich_1:setVisible(false)
    if self.plotAni and self.oldPos>0 then
       self.plotCtn[self.oldPos]:removeChild(self.plotAni);
 --       self.plotAni:clear()
    end
    self.plotAni=nil;
    self.ctn_1:setVisible(false)
end 
-- 移除当前动画
function PlotDialogView:removeCurAni()
    if self.plotAni then
        for _index=1, 3 do
                self.plotCtn[_index]:removeChild(self.plotAni);
        end
--        self.plotAni:delayCall(c_func(self.plotAni.visible, self.plotAni, false), 0.0001)
        self.plotAni = nil
    end
end 

function PlotDialogView:setNameVisible(id)
    for i = 1, 3 do
 --       local _v = _yuan3(id == i, true, false)
        self["panel_name" .. i]:setVisible(id == i)
    end
end
  
function PlotDialogView:getCtnPos(_aniID)

    if _aniID == self.ANI_RUN_ACTION.MIDDLE_TO_RIGHT or _aniID == self.ANI_RUN_ACTION.LEFT_TO_RIGHT then
        self.aniCtnPos = self.LOCATION.RIGHT
    elseif _aniID == self.ANI_RUN_ACTION.LEFT_TO_MIDDLE or _aniID == self.ANI_RUN_ACTION.RIGHT_TO_MIDDLE then
        self.aniCtnPos = self.LOCATION.MIDDLE
    elseif _aniID == self.ANI_RUN_ACTION.RIGHT_TO_LEFT or _aniID == self.ANI_RUN_ACTION.MIDDLE_TO_LEFT then
        self.aniCtnPos = self.LOCATION.LEFT
    end
    return self.plotCtn[self.aniCtnPos]
end 

function PlotDialogView:updateText(data)
    _yuan3(data.rich_1, self.panel_1.txt_1:setString(getPlotLanguage(data.rich_1)), nil)
end 
function PlotDialogView:updateUI(data,isShowText)
    if data == nil then return end

 
    -- board[string]	根据配置选择对话版不同的样式
    local bg = data.bg
    -- bg[string]	场景文件名，如果有，切换成对应背景，如过无，就保留当前背景，不额外加载图片
    local sfx = data.sfx
    -- sfx[string]	进场时候的音效，如果没有进场动画就不播放
    local enterAni = data.enterAni
    -- enterAni[string]	定义的动画组，依次播放【动画ID;】，动画结束后，立绘出现在对应位置
    -- 可以为空，为空就直接出现在预订位置。
    local emoji = data.emoji
    -- emoji[string]	说话时立绘上显示的表情，
    local effect = data.effect
    -- effect[string]	说话时身上的特效【特效ID】，可以为空

    local _pos = _yuan3(self.aniCtnPos ~= 0, self.aniCtnPos, data.pos[1] or  0)
    self:setNameVisible(_pos)
    self["panel_name" .. _pos]:setVisible(true)
   
    local _name = _yuan3(data.name == nil, UserModel:name(), getPlotLanguage(data.name))
    self["panel_name" .. _pos].txt_1:setString(_name)
--//表情面板
    local   _panel=self["panel_" .. _pos];
--//如果表情不为空
    self["panel_" .. _pos]:setVisible(false)

    -- self["panel_"..data.pos[1]]:addChild()
    -- text[string]	对话文本
    self.rich_1:setVisible(true)
 
    self.rich_1:setVisible( isShowText )
  
--//判断是否有需要参数替换
    local     _text=getPlotLanguage(data.text);
    if(data.param_place ~= nil)then
          local     _user_name = UserModel:name();
          for _key,_value in pairs(data.param_place) do
                local   _replace=_user_name;
                if(_value ~="player")then
                         _replace=GameConfig.getLanguage(_value);
                end
                _text  = string.gsub(_text, "#".._key, _replace)
          end
    end
    self:setRichText(_text)
    local bg2 = data.bg2
    -- bg2[string]	切换的背景图ID
    local shake = data.shake
    -- afterAni[vector<string>]	文本结束后，如果角色退场，会播放动画序列【动画I；】
    local scr = data.scr
    -- scr[string]	对话结束后执行脚本

    local glaType = data.glaType
    ------------  ------------  ------------  ------------ 
    if data.img ~= nil then 
     self:loadPlayerImg(data, false)
    end 
    ------------  ------------  ------------  ------------ 
   self.ctn_1:setVisible(true)
  
 
end 
-- 一当前动画全部结束
function PlotDialogView:plotDialogComplete(data)
    --    echo("plotDialogComplete")
    -- 清理上一场数据
    self:cleanLastAni()
    -- 添加上一次立绘
    self:showArtIcon(data, state)

end 
function PlotDialogView:showArtIcon(data)
    -- 设置立绘显示
    if data.stay == nil then return end
    if(data.board>0)then
         self.artIcon=self:loadImgRes(data.img, true,data.emoji)
         self.plotCtn[data.stay[1]]:removeAllChildren();
         self.artIcon:parent(self.plotCtn[data.stay[1]])
         local _dir = data.stay[2] == 2  and 1  or  -1
         self.artIcon:setScaleX(0.9*_dir)
         self.artIcon:setScaleY(0.9);
 --       self.artIcon:setColor(cc.c3b(80, 80, 80))
         --FilterTools.setGrayFilter(self.artIcon);
         FilterTools.setFlashColor(self.artIcon, "lowLight" );
--        self.artIcon:setScale(0.9*_dir)
        self.oldArtPos = data.stay[1]
    end
end 
function PlotDialogView:showLocalOption(data)

    local _nextId = data.nextId

    for i = 1, #data do
        local _odata = FuncPlot.getStepPlotData(data[i])
        if _odata.glaType == 4 then
            -- 对话类型为4
            self.panel_duihua["btn_duihua" .. i]:setVisible(true)
            self.panel_duihua["btn_duihua" .. i].spUp.rich_info:setString(getPlotLanguage(_odata.text))
        else
            -- error
        end
    end

end 
function PlotDialogView:showExtOption(data)
      for i = 1, #data do  
            self.panel_duihua["btn_duihua" .. i]:setVisible(true)
            self.panel_duihua["btn_duihua" .. i].spUp.rich_info:setString(GameConfig.getLanguage(data[i])) 
      end
end 

function PlotDialogView:setRichText(str)
    --  self.rich_1:setDimensions(cc.size(GameVars.width - 300, GameVars.height))
    --    local p = string.find(str, "[^%d.]")
    --    local _text = string.format("[fontColor=a1224]%s [/fontColor]", str)
--    self.rich_1:setString(str)
    if str ~= nil then 
    self.rich_1:startPrinter(str,20)
    end 
end 
function PlotDialogView:setOptionVisible(isVisible)
    for i = 1, 3 do
        self.panel_duihua["btn_duihua" .. i]:setVisible(isVisible)
    end
end 
      
  

function PlotDialogView:deleteMe()
    PlotDialogView.super.deleteMe(self)
    self.controler = nil
end 
function PlotDialogView:setSkipBtnVisable(isShow)
    self.btn_1:setVisible(isShow)
end 


return PlotDialogView;
