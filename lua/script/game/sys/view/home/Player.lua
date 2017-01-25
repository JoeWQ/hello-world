--2016.7.5
--guan

--玩家的Y坐标
local playerPosY = -(640 - 150);

--主角移动速度每秒移动多少像素
local moveSpeed = 150 * 2;

local Player = class("Player", function()
	--是个Node, 里面放具体的人物, 看看是 dragonBone 或是 spine 
    return display.newNode()
end)

--传入node 或 是其他信息，在这里生成显示对象
function Player:ctor()
	--todo loading 时候加
    -- FuncArmature.loadOneArmatureTexture("common", nil, true)
	--spine 动画
	self._showNode = self:initShowNode();
	--脚下光圈
	FuncArmature.createArmature("common_juese", self, true);

	self:addChild(self._showNode);
end

function Player:setTitle(panel, name)
	panel:setPosition(0, 140);
	self:addChild(panel, 1000);
	name = name or "无名少侠"
	panel.txt_name:setString(name);
	self._panel = panel;
end

function Player:setName(name)
	self._panel.txt_name:setString(name);
end

function Player:getShowNode()
	return self._showNode;
end

function Player:initShowNode()
	-- local node = NatalModel:getCharOnNatal("1");
	local node = FuncChar.getSpineAni(tostring(UserModel:avatar()), UserModel:level());
	
	-- self._natalTid =  NatalModel:getNatalTreasure()["1"];
	self._natalTid = "";

	node:setPosition(0, 0);
	node:setAnchorPoint(cc.p(0, 0));

	--other init
	return node;
end

function Player:getNatalTid()
	return self._natalTid;
end

function Player:getCurSpeed()
	return moveSpeed / 30;
end

--出生动画，在posX出生, 先调用这个！！
function Player:birth(posX)
	self:setPosition(posX, playerPosY);
	--出生动画
	self._showNode:playLabel(self._showNode.actionArr.stand);
end

function Player:updateNatalTreasure()
	self._showNode:removeFromParent();
	self._showNode = self:initShowNode();
	self:addChild(self._showNode);
end

return Player;














