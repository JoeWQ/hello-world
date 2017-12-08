--[[
	法宝的通用ui方法
	guan
	2016.6.15
]]

TreasureUICommon = TreasureUICommon or {};

function TreasureUICommon.setPowerWithAni(view)
    --得到增加威力的mc eg：+321
    function createFloatMcNum(targetNum)
        local mcClone = UIBaseDef:cloneOneView(view.panel_power.mc_num);
        local numArray = number.split(targetNum);
        local len = table.length(numArray);

--        echo("++++++++++++++++++++targetNum = "..targetNum)
--        echo("++++++++++++++++++++len = "..len)

        if len > 5 then 
            echo("------error: setPower len > 5 !!!-----");
        end 

        if targetNum > 0 then
            mcClone:showFrame(len);
            for k, v in pairs(numArray) do
                local mcs = mcClone:getCurFrameView();
                mcs["mc_" .. tostring(k)]:showFrame(v + 1);
            end
        end

        return mcClone;
    end

    function showRollingAni(prePower, curPower)
        local prePowerArray = number.split(prePower);
        local curPowerArray = number.split(curPower);
        local preLen = table.length(prePowerArray);
        local curLen = table.length(curPowerArray);

        view.panel_power.mc_shuzi:showFrame(curLen);
        local mcs = view.panel_power.mc_shuzi:getCurFrameView();

        --搞到新的位数上
        if preLen ~= curLen then 
            local mcIndex = 0;
            for i = 1, curLen - preLen do
                mcIndex = mcIndex + 1;
                mcs["mc_" .. tostring(mcIndex)]:visible(false);
            end

            for i = 1, preLen do
                mcIndex = mcIndex + 1;
                local num = prePowerArray[i];
                mcs["mc_" .. tostring(mcIndex)]:showFrame(num + 1);
            end
        end 

        local diffDigitCount = number.diffDigitCount(prePower, curPower)
        for i = 1, diffDigitCount do
            view:delayCall(function ( ... )
                local ctn = mcs["ctn_" .. tostring(curLen - i + 1)];
                local changeMc = mcs["mc_" .. tostring(curLen - i + 1)];

                local floatNumAni = FuncArmature.createArmature("UI_fabao_common_gunshuzi", 
                    ctn, false, GameVars.emptyFunc);

                changeMc:setPosition(0, 0);
                changeMc:showFrame(curPowerArray[curLen - i + 1] + 1);
                FuncArmature.changeBoneDisplay(floatNumAni, "c", changeMc);
            end, 1/30 * (i - 1) * 8);
        end

        if view.panel_star ~= nil then 
            --是否是满星
            local delayTime = 1/30 * (diffDigitCount - 1) * 8;
            
            view:delayCall(function ( ... )
                if view._treasure:isMaxStar() == false then 
                    view.panel_star.panel_jindu.mc_shengxing:setVisible(true)
                    view.panel_star.ctn_6:setVisible(true);
                end 
                -- view:resumeUIClick();
            end, delayTime);
        end 
    end

    local power = view._treasure:getPower();
    local prePower = view._beforePowerNum;

    --威力飘字
    local boneTobeChanged = createFloatMcNum(power - prePower);
    local boneTobeChanged2 = createFloatMcNum(power - prePower);

    local floatNumAni = FuncArmature.createArmature("UI_fabao_common_jiashuzifei", 
        view.panel_power.ctn_floatNum, false);
    boneTobeChanged:setPosition(0, 0);
    boneTobeChanged2:setPosition(0, 0);

    FuncArmature.changeBoneDisplay(floatNumAni, "layer3a", boneTobeChanged);
    FuncArmature.changeBoneDisplay(floatNumAni, "layer3a_copy", boneTobeChanged2);

    --16帧开始播其他动画
    floatNumAni:registerFrameEventCallFunc(15, 1, function ( ... )
        FuncArmature.createArmature("UI_fabao_common_weilishan", 
            view.panel_power.ctn_power, false, GameVars.emptyFunc);
        --滚！
        showRollingAni(prePower, power);   
    end);
end


