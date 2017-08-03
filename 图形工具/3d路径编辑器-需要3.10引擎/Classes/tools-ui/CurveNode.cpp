/*
  *公共曲线类型实现
  *@2017-07-12
  *@Author:xiaoxiong
 */
#include "CurveNode.h"
USING_NS_CC;

CurveNode::CurveNode(CurveType curveType):
_curveType(curveType)
,_lineColor(1.0f,1.0f,1.0f,1.0f)
, _previewSpeed(1.0f)
, _isSupportedControlPoint(false)
, _weight(1.0f)
{

}

void    CurveNode::setRotateMatrix(const cocos2d::Mat4 &rotateMatrix)
{
	_rotateMatrix = rotateMatrix;
}

void    CurveNode::setLineColor(const cocos2d::Vec4 &color)
{
	_lineColor = color;
}

void   CurveNode::projectToOpenGL(cocos2d::Camera *camera, const cocos2d::Vec3 &src, cocos2d::Vec3 &dts)
{
	auto &viewport = Director::getInstance()->getWinSize();
	Vec4 clipPos;
	camera->getViewProjectionMatrix().transformVector(Vec4(src.x, src.y, src.z, 1.0f), &clipPos);

	CCASSERT(clipPos.w != 0.0f, "clipPos.w can't be 0.0f!");
	float ndcX = clipPos.x / clipPos.w;
	float ndcY = clipPos.y / clipPos.w;

	dts.x = ndcX  * 0.5f * viewport.width;
	dts.y = ndcY* 0.5f * viewport.height;
	dts.z = clipPos.z / clipPos.w;
}
 void  CurveNode::setWeight(float weight)
{
	//CCASSERT(false,"Unsupported Method:setWeight");
	 _weight = weight;
}

 void   CurveNode::initControlPoint(int pointCount)
 {
	 CCASSERT(false, "Unsupported Method:initControlPoint");
 }

 void   CurveNode::onTouchBegan(const   cocos2d::Vec2   &touchPoint, cocos2d::Camera  *camera)
 {
	 CCASSERT(false, "Unsupported Method:CurveNode::onTouchBegan");
 }

 void   CurveNode::onTouchMoved(const   cocos2d::Vec2   &touchPoint, cocos2d::Camera *camera)
 {
	 CCASSERT(false, "Unsupported Method:CurveNode::onTouchMoved");
 }

 void   CurveNode::onTouchEnded(const    cocos2d::Vec2   &touchPoint, cocos2d::Camera *camera)
 {
	 CCASSERT(false, "Unsupported Method:CurveNode::onTouchEnded");
 }

 void CurveNode::onMouseClick(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera)
 {
	 printf("not realize function CurveNode::onMouseClick\n");
 }

 void CurveNode::onMouseMoved(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera)
 {
	 printf("not realize function CurveNode::onMouseMoved\n");
 }

 void CurveNode::onMouseReleased(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera)
 {
	 printf("not realize function CurveNode::onMouseReleased\n");
 }

 void    CurveNode::onCtrlKeyRelease()
 {
	 CCASSERT(false, "Unsupported Method:CurveNode::onCtrlKeyRelease");
 }

 void CurveNode::onCtrlZPressed()
 {

 }

 void CurveNode::setUIChangedCallback(std::function<void(CurveType type, int param, int param2)> callback)
 {
	 _onUIChangedCallback = callback;
 }

 void   CurveNode::previewCurive(std::function<void()> callback)
 {
	 CCASSERT(false, "Unsupported Method:CurveNode::previewCurive");
  }
 void   CurveNode::initCurveNodeWithPoints(const std::vector<cocos2d::Vec3>  &points)
 {
	 CCASSERT(false, "Unsupported Method:CurveNode::initCurveNodeWithPoints");
  }
 void   CurveNode::restoreCurveNodePosition()
 {
	 CCASSERT(false, "Unsupported Method:CurveNode::restoreCurveNodePosition");
  }

 void   CurveNode::setPreviewModel(const FishVisual &fishMap)
 {
	 _fishVisual = fishMap;
  }

 void  CurveNode::getControlPoint(ControlPointSet &cpoint)
 {
	 CCASSERT(false, "Unsupported Method:CurveNode::getControlPoint");
 }

 void CurveNode::setPreviewSpeed(float speed)
 {
	 _previewSpeed = speed;
 }
//////////////////////////////////////////////////////
ControlPoint::ControlPoint():
_drawNode3D(nullptr)
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
	_index=index;
	//_modelSprite = Sprite3D::create("Sprite3d/xiaolvyu/xiaolvyu.c3b");
	//_modelSprite->setForce2DQueue(true);
	//_modelSprite->setScale(0.15);
	//this->addChild(_modelSprite);
	//_modelSprite->setVisible(false);

	_iconSprite = Sprite::create("tools-ui/snow.png");
	this->addChild(_iconSprite,9);

	int width = 14;
	if (index > 9)
		width = 28;
	char str[256];
	sprintf(str, "%d", index);
	_sequence = Label::createWithSystemFont(str, "", 32);
	_sequence->setColor(Color3B(255, 0, 0));
	this->addChild(_sequence,10);
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
	if (!_drawNode3D)
	{
		_drawNode3D = cocos2d::DrawNode3D::create();
		//+X
		_drawNode3D->drawLine(cocos2d::Vec3(),cocos2d::Vec3(40.0f,0.0f,0.0f),Color4F(1.0f,0.0f,0.0f,1.0f));
		//+Y
		_drawNode3D->drawLine(Vec3(),Vec3(0.0f,40.0f,0.0f),Color4F(0.0f,1.0f,0.0f,1.0f));
		//+Z
		_drawNode3D->drawLine(Vec3(),Vec3(0.0f,0.0f,40.0f),Color4F(0.0f,0.0f,1.0f,1.0f));
		//Line Width
		_drawNode3D->setLineWidth(4.0f);
		this->addChild(_drawNode3D);
	}
}
