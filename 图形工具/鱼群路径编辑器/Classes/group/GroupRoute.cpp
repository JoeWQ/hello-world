/*
  *公共父类
  *@2017-8-4
  *@Author:xiaohuaxiong
 */
#include "GroupRoute.h"
USING_NS_CC;
GroupData::GroupData(GroupType groupType) :
	_groupType(groupType)
{

}

void GroupData::format(std::string &output)
{

}

/////////////////////////////////GroupRoute/////////////////////////////////////////////
GroupRoute::GroupRoute(GroupType groupType) :
	_groupType(groupType)
	,_controlLayer(nullptr)
{

}

bool GroupRoute::onTouchBegan(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera)
{
	return true;
}

void GroupRoute::onTouchMoved(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera)
{

}

void GroupRoute::onTouchEnded(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera)
{

}

void GroupRoute::onMouseClick(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera)
{

}

void GroupRoute::onMouseMoved(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera)
{

}

void GroupRoute::onMouseEnded(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera)
{

}

void GroupRoute::project2d(cocos2d::Camera *camera,const cocos2d::Vec3 &src3D, cocos2d::Vec3 &dst2d)
{
	auto &viewport = cocos2d::Director::getInstance()->getWinSize();
	cocos2d::Vec4 clipPos;
	camera->getViewProjectionMatrix().transformVector(cocos2d::Vec4(src3D.x, src3D.y, src3D.z, 1.0f), &clipPos);

	CCASSERT(clipPos.w != 0.0f, "clipPos.w can't be 0.0f!");
	float ndcX = clipPos.x / clipPos.w;
	float ndcY = clipPos.y / clipPos.w;

	dst2d.x = ndcX  * 0.5f * viewport.width;
	dst2d.y = ndcY* 0.5f * viewport.height;
	dst2d.z = clipPos.z / clipPos.w;
}

Vec2 GroupRoute::convertUICoord(const cocos2d::Vec2 &src)
{
	auto &winSize = Director::getInstance()->getWinSize();
	return Vec2(src.x + winSize.width/2,src.y+winSize.height/2);
}

cocos2d::Layer *GroupRoute::getControlLayer()
{
	return _controlLayer;
}

void GroupRoute::getGroupData(GroupData &output)
{

}

void GroupRoute::setRotateMatrix(const cocos2d::Mat4 &rm)
{
	_rotateMatrix = rm;
}

void GroupRoute::registerChooseDialogUICallback(std::function<void(GroupType groupType, int param, const cocos2d::Vec3 &xyz, std::function<void(const FishInfo &)> onConfirmCallback)> callback)
{
	_chooseDialogUICallback = callback;
}

void GroupRoute::registerQueryFishInfoCallback(std::function<const FishInfo & (int fishId)> callback)
{
	_queryFishCallback = callback;
}

const FishInfo& GroupRoute::queryFishInfo(int fishId)const
{
	return _queryFishCallback(fishId);
}
//////////////////////////////////////////////
ControlPoint::ControlPoint()// :
//	_drawNode3D(nullptr)
{
	_modelSprite = NULL;
	_sequence = NULL;
	_iconSprite = NULL;
	_speedCoef = 1.0;
}

ControlPoint::~ControlPoint()
{
}

void ControlPoint::initControlPoint(int index)
{
	Node::init();
	_index = index;

	_iconSprite = Sprite::create("tools-ui/snow.png");
	this->addChild(_iconSprite, 9);

	int width = 14;
	if (index > 9)
		width = 28;
	char str[256];
	sprintf(str, "%d", index);
	_sequence = Label::createWithSystemFont(str, "", 32);
	_sequence->setColor(Color3B(255, 0, 0));
	this->addChild(_sequence, 10);
	//设置大小尺寸,在后面的触屏操作中将会被用到
	this->setContentSize(_iconSprite->getContentSize());
}

ControlPoint   *ControlPoint::createControlPoint(int index)
{
	ControlPoint *point = new ControlPoint();
	point->initControlPoint(index);
	point->autorelease();
	return point;
}

void ControlPoint::changeSequence(int index)
{
	if (_index != index)
	{
		_index = index;
		int width = 14;
		if (index > 9)
			width = 28;
		char str[256];
		sprintf(str, "%d", index);
		_sequence->setString(str);
	}
}

void ControlPoint::drawAxis()
{
	//if (!_drawNode3D)
	//{
	//	_drawNode3D = cocos2d::DrawNode3D::create();
	//	//+X
	//	_drawNode3D->drawLine(cocos2d::Vec3(), cocos2d::Vec3(40.0f, 0.0f, 0.0f), Color4F(1.0f, 0.0f, 0.0f, 1.0f));
	//	//+Y
	//	_drawNode3D->drawLine(Vec3(), Vec3(0.0f, 40.0f, 0.0f), Color4F(0.0f, 1.0f, 0.0f, 1.0f));
	//	//+Z
	//	_drawNode3D->drawLine(Vec3(), Vec3(0.0f, 0.0f, 40.0f), Color4F(0.0f, 0.0f, 1.0f, 1.0f));
	//	//Line Width
	//	_drawNode3D->setLineWidth(4.0f);
	//	this->addChild(_drawNode3D);
	//}
}
