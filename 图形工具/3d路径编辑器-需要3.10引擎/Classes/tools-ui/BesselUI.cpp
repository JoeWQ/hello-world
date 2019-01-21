/*
  *贝塞尔曲线生成工具
  *2017-3-20
  *@Author:xiaoxiong
 */
#include"BesselUI.h"
#include "XMLParser.h"
#include<fstream>
#include "LayerDialog.h"
#include "SpiralNode.h"
#include "BesselNode.h"
#include "RouteGroup.h"
//#include "extensions/cocos-ext.h"
//#include "ui/CocosGUI.h"
//#include"geometry/Geometry.h"
#define _TAG_RADIO_BUTTON_CURVE_                  0x0
//记录当前的已经完成的贝塞尔曲线控制点的配置的数目
#define  _TAG_LABEL_TOTAL_RECORD_                    0x80
//指示按钮
#define _TAG_BUTTON_DIRECT_                                 0x81
//新建一条路径
#define  _TAG_NEW_PATH_                                           0x82
//删除上一条记录
#define  _TAG_BUTTON_REMOVE_LAST_RECORD_ 0x83
//保存当前记录
#define  _TAG_BUTTON_SAVE_CURRENT_RECORD_ 0x84
//将所有记录写入到文件
#define  _TAG_BUTTON_SAVE_TO_FILE_                      0x85
//曲线预览
#define  _TAG_BUTTON_PREVIEW_                                 0x86
//组策略tag
#define _TAG_RADIO_BUTTON_GROUP_                        0x87

#define  _TAG_BUTTON_SAVE_PARSED_                      0x88
//选择鱼的配置
#define _TAG_BUTTON_FISH_MAP_                               0x89
//曲线类型的组标志
#define _TAG_RADIO_BUTTON_GROUP_CURVE_       0x90
//ScrollView
#define _TAG_SCROLL_VIEW_                                         0x91
#define _TAG_EDIT_BOX_0_                                             0x92
#define _TAG_EDIT_BOX_1_											  0x93
#define _TAG_EDIT_BOX_TOP_RADIUS_                       0x94
#define _TAG_EDIT_BOX_BOTTOM_RADIUS_               0x95
#define _TAG_EDIT_BOX_SPEED_                                    0x96
#define _TAG_EDIT_BOX_ROUTE_GROUP_                    0x97
//组按钮的起始tag
#define _TAG_RADIO_BUTTON_										   3
//对话框tag
#define _TAG_LAYER_DIALOG_                                        0x101
USING_NS_CC;
////////////////////////////////////////////////////////////////////////////////
//#define __USE_OLD_LOAD_VISUAL_XML__ //如果需要转换原来的生成的数据文件,请打开这个宏
///////////////////////////////////////////////////////////////////////////////
Scene     *BesselUI::createScene()
{
	Scene  *_scene = Scene::create();
	BesselUI  *_layer = BesselUI::createBesselLayer();
	_scene->addChild(_layer);
	return _scene;
}

BesselUI	*BesselUI::createBesselLayer()
{
	BesselUI  *_layer = new BesselUI();
	_layer->initBesselLayer();
	_layer->autorelease();
	return _layer;
}

BesselUI::BesselUI():
_speedEditBox(nullptr)
,_topRadiusEditBox(nullptr)
,_bottomRadiusEditBox(nullptr)
, _ccwComponentPanel(nullptr)
, _routeGroupNode(nullptr)
, _routeGroupEditBox(nullptr)
, _actionIndexEditBox(nullptr)
, _curveNodeReturnValue(false)
{
	_settingLayer = NULL;
	_viewCamera = NULL;
	_keyboardListener = NULL;
	_keyMask = 0;
	_besselSetData.reserve(128);
	//_besselSetSize = 0;
	_currentEditPathIndex = -1;
	//透视距离
	_maxZeye = 0.0f;
	_minZeye = 0.0f;
	_nowZeye = 0.0f;
}

BesselUI::~BesselUI()
{
}

void  BesselUI::initBesselLayer()
{
	Layer::init();
	//
	//
    BesselNode * node = BesselNode::createBesselNode();
	node->setTouchSelectedCallback(CC_CALLBACK_1(BesselUI::notifyBesselNodeSelected, this));
	node->setUIChangedCallback(CC_CALLBACK_3(BesselUI::onUIChangedCallback,this));
	this->addChild(node);
    _curveNode = node;
	//创建一个新的摄像机
	auto &winSize = Director::getInstance()->getWinSize();
	const float zeye = winSize.height / 1.1566f;
	_camera = Camera::createPerspective(60.0f, winSize.width/ winSize.height,0.1f,zeye+winSize.height/2.0f + 5000);
	_camera->setCameraFlag(CameraFlag::USER1);
	_camera->setPosition3D(Vec3(0.0f, 0.0f, zeye));
	_camera->lookAt(Vec3(0.0f,0.0f,0.0),Vec3(0.0f,1.0f,0.0f));
	//设置相关的透视距离
	_nowZeye = zeye;
	_maxZeye = zeye * 5.5f;
	_minZeye = zeye;
	/*
	  *Mesh
	 */
	_axisNode = DrawNode3D::create();
	this->addChild(_axisNode);
	this->drawAxisMesh();
	this->addChild(_camera);
	/*
	  *背景图
	 */
	//cocos2d::Sprite *bg = cocos2d::Sprite::create("tools-ui/layer-ui/Map_new_0.jpg");
	//if (bg != nullptr)
	//{
	//	bg->setGlobalZOrder(-1000);
	//	this->addChild(bg);
	//}
	this->setCameraMask(2);
	//load visual xml
	loadVisualXml();
	/*
	*Setting Layer
	*/
	this->loadSettingLayer();
	_settingLayer->setCameraMask((short)CameraFlag::DEFAULT,true);
	//create keyboard listener
	_keyboardListener = EventListenerKeyboard::create();
	_keyboardListener->onKeyPressed = CC_CALLBACK_2(BesselUI::onKeyPressed,this);
	_keyboardListener->onKeyReleased = CC_CALLBACK_2(BesselUI::onKeyReleased,this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(_keyboardListener, this);
	//touch event
	_touchListener = EventListenerTouchOneByOne::create();
	_touchListener->onTouchBegan = CC_CALLBACK_2(BesselUI::onTouchBegan,this);
	_touchListener->onTouchMoved = CC_CALLBACK_2(BesselUI::onTouchMoved,this);
	_touchListener->onTouchEnded = CC_CALLBACK_2(BesselUI::onTouchEnded,this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(_touchListener, this);
	//鼠标邮件事件
	_mouseListener = EventListenerMouse::create();
	_mouseListener->onMouseDown = CC_CALLBACK_1(BesselUI::onMouseClick,this);
	_mouseListener->onMouseMove = CC_CALLBACK_1(BesselUI::onMouseMoved,this);
	_mouseListener->onMouseUp = CC_CALLBACK_1(BesselUI::onMouseReleased,this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(_mouseListener, this);
	//schedule update
	schedule(CC_SCHEDULE_SELECTOR(BesselUI::updateCamera));
	loadFishVisualStatic();
	loadFishPathMap();
	//设置第一个
	_curveNode->setPreviewModel(_fishVisualStatic.begin()->second);
}

void  BesselUI::makeRotateMatrix(const Vec2 &xyOffset, Mat4 &rotateMatrix,cocos2d::Quaternion &qua)
{
	//注意,计算旋转角度的时候,扰动x是关于绕Y轴旋转,扰动Y是关于X轴旋转
	//但是，如果xyOffset.y的值为正,将意味着绕X洲做负方向的旋转
	//而绕Y轴旋转却没有这种问题
	const  float offsetX = xyOffset.x * 0.08;
	const  float offsetY =- xyOffset.y * 0.08;
	//以下变换过程属于欧拉角变换
	//Mat4 rotateYInv;
	//Mat4 rotateY;
	//Mat4 rotateA;
	//Mat4::createRotation(Vec3(0, 1, 0), CC_DEGREES_TO_RADIANS(offsetX), &rotateY);
	//Mat4::createRotation(Vec3(0, 1, 0), CC_DEGREES_TO_RADIANS(-offsetX), &rotateYInv);
	//Vec3 axis = rotateYInv * Vec3(1, 0, 0);
	//Mat4::createRotation(axis, CC_DEGREES_TO_RADIANS(offsetY), &rotateA);
	//rotateMatrix = rotateY * rotateA;
	Matrix     aMatrix;
	Matrix     bMatrix;
	Matrix     cMatrix;
	aMatrix.rotate(offsetX,0.0f,1.0f,0.0f);
	bMatrix.rotate(-offsetX, 0.0f, 1.0f, 0.0f);
	GLVector4    axis = GLVector4(1.0f,0.0f,0.0f,0.0f) * bMatrix;
	cMatrix.rotate(offsetY, axis.x,axis.y,axis.z);
	Matrix    nMatrix =    cMatrix * aMatrix; 

	memcpy(&rotateMatrix,&nMatrix,sizeof(nMatrix));
	//cocos2d::Quaternion    rotateOfZ(Vec3(0.0f,0.0f,1.0f),M_PI_2);
	//cocos2d::Vec3   rotateOfVec3 = rotateOfZ * Vec3(1.0f,0.0f,0.0f);
	//
	rotateMatrix.getRotation(&qua);

//	memcpy(&_rotateMatrix,&rotateMatrix,sizeof(Matrix));
}

bool  BesselUI::onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unused_event)
{
	_originVec2 = touch->getLocation();
	if (_keyMask & _KEY_CTRL_MASK_)
	{
		auto &winSize = Director::getInstance()->getWinSize();
		const Vec2   OpenGLVec2 = touch->getLocation() - Vec2(winSize.width / 2.0f, winSize.height / 2.0f);
		_curveNodeReturnValue = _curveNode->onTouchBegan(OpenGLVec2,_camera);
	}
	return true;
}

void BesselUI::onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unused_event)
{
	Vec2  _nowOffset = (touch->getLocation() - _originVec2);
	//如果没有按下Ctrl按键,则意味着旋转场景,否则是拖动贝塞尔控制点
	if (_keyMask & _KEY_CTRL_MASK_)
	{ 
		auto &winSize = Director::getInstance()->getWinSize();
		const Vec2   OpenGLVec2 = touch->getLocation() - Vec2(winSize.width/2.0f,winSize.height/2.0f);
		//如果_curveNode没有隐藏
		if(_curveNodeReturnValue && _curveNode->isVisible())
			_curveNode->onTouchMoved(OpenGLVec2,_camera);
	}
	else if( !_keyMask)
	{
		_xyOffset += _nowOffset;
		Mat4  rotateMatrix;
		cocos2d::Quaternion qua;
		this->makeRotateMatrix(_xyOffset, rotateMatrix, qua);
		_curveNode->setRotationQuat(qua);
		_axisNode->setRotationQuat(qua);
		_curveNode->setRotateMatrix(rotateMatrix);
		if (_routeGroupNode != nullptr)
			_routeGroupNode->setRotationQuat(qua);
		_rotateQua = qua;
	}
	_originVec2 = touch->getLocation();
}

void BesselUI::onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event)
{
	if (_keyMask & _KEY_CTRL_MASK_)
	{
		auto &winSize = Director::getInstance()->getWinSize();
		const Vec2   OpenGLVec2 = touch->getLocation() - Vec2(winSize.width / 2.0f, winSize.height / 2.0f);
		if(_curveNodeReturnValue)
		_curveNode->onTouchEnded(OpenGLVec2,_camera);
	}
	_lastSelectIndex = -1;
}

void  BesselUI::onKeyPressed(EventKeyboard::KeyCode keyCode, Event* unused_event)
{
	if (keyCode == EventKeyboard::KeyCode::KEY_CTRL)
		_keyMask |= _KEY_CTRL_MASK_;//设置Ctrl按键掩码
	else if (keyCode == EventKeyboard::KeyCode::KEY_W)
		_keyMask |= _KEY_W_MASK_;
	else if (keyCode == EventKeyboard::KeyCode::KEY_S)
		_keyMask |= _KEY_S_MASK_;
	else if (keyCode == EventKeyboard::KeyCode::KEY_ALT)
		_keyMask |= _KEY_ALT_MASK_;
	//检测是否有Ctrl+Z键,且只有Ctrl+Z
	if ((_keyMask & _KEY_CTRL_MASK_) && keyCode == EventKeyboard::KeyCode::KEY_Z  && !(_keyMask  - _KEY_CTRL_MASK_))
	{
		_curveNode->onCtrlZPressed();
	}
	//是否有F5按键按下
	if (keyCode == EventKeyboard::KeyCode::KEY_F5)
	{
		if (_routeGroupNode != nullptr)
		{
			_routeGroupNode->removeFromParent();
			_curveNode->setVisible(true);
			_routeGroupNode = nullptr;
		}
	}
}
void  BesselUI::onKeyReleased(EventKeyboard::KeyCode keyCode, Event *unused_event)
{
	if (keyCode == EventKeyboard::KeyCode::KEY_CTRL)
	{
		_keyMask &= ~_KEY_CTRL_MASK_;//清除Ctrl按键
		_curveNode->onCtrlKeyRelease();
	}
	else if (keyCode == EventKeyboard::KeyCode::KEY_W)
	{
		_keyMask &= ~_KEY_W_MASK_;
	}
	else if (keyCode == EventKeyboard::KeyCode::KEY_S)
	{
		_keyMask &= ~_KEY_S_MASK_;
	}
	else if (keyCode == EventKeyboard::KeyCode::KEY_ALT)
		_keyMask &= ~_KEY_ALT_MASK_;
}
/*
  *鼠标事件
  *
 */
void    BesselUI::onMouseClick(cocos2d::EventMouse *mouseEvent)
{
	_isResponseMouse = false;
	//只会响应鼠标的右键
	if (mouseEvent->getMouseButton() == MOUSE_BUTTON_RIGHT)
	{
		//向下分发事件
		Vec2 touchPoint = mouseEvent->getLocation();
		auto &winSize = Director::getInstance()->getWinSize();
		touchPoint.y = winSize.height - touchPoint.y;
		if (_keyMask & _KEY_ALT_MASK_)
		{
			_isResponseMouse = true;
			_curveNode->onMouseClick(touchPoint - Vec2(winSize.width / 2.0f, winSize.height / 2.0f), _camera);
		}
		else if (_keyMask & _KEY_CTRL_MASK_)
		{
			_curveNode->onMouseClickCtrl(touchPoint - Vec2(winSize.width / 2.0f, winSize.height / 2.0f), _camera);
		}
		else if(! _keyMask)//检测是否可以调用另一个对话框中的函数
		{
				LayerDialog *dialog = (LayerDialog *)this->getChildByTag(_TAG_LAYER_DIALOG_);
				//调用鼠标响应函数
				if ( dialog != nullptr)
					dialog->onMouseClick(touchPoint);
		}
	 }
}

void BesselUI::onMouseMoved(cocos2d::EventMouse *mouseEvent)
{
	if (_isResponseMouse && (_keyMask & _KEY_ALT_MASK_))
	{
		Vec2 touchPoint = mouseEvent->getLocation();
		auto &winSize = Director::getInstance()->getWinSize();
		touchPoint.y = winSize.height - touchPoint.y;
		_curveNode->onMouseMoved(touchPoint - Vec2(winSize.width/2.0f,winSize.height/2.0f),_camera);
	}
}

void BesselUI::onMouseReleased(cocos2d::EventMouse *mouseEvent)
{
	if (_isResponseMouse && (_keyMask & _KEY_ALT_MASK_))
	{
		Vec2 touchPoint = mouseEvent->getLocation();
		auto &winSize = Director::getInstance()->getWinSize();
		touchPoint.y = winSize.height - touchPoint.y;
		_curveNode->onMouseReleased(touchPoint - Vec2(winSize.width / 2.0f, winSize.height / 2.0f), _camera);
	}
}

void    BesselUI::updateCamera(float dt)
{
	const float speed = 256.0f;
	//S键被按下
	if (_keyMask & _KEY_S_MASK_)
	{
		_nowZeye = _nowZeye + dt * speed;//速度设定为24像素
		//截断
		_nowZeye =fmin(  fmax(_nowZeye,_minZeye),  _maxZeye);
		_camera->setPosition3D(Vec3(0.0f,0.0f,_nowZeye));
		_camera->lookAt(Vec3(0.0f,0.0f,0.0f));
	}
	//不能两个按键同时被按下
	if (_keyMask & _KEY_W_MASK_)
	{
		_nowZeye = _nowZeye - dt * speed;
		_nowZeye = fmin( fmax(_nowZeye,_minZeye) ,_maxZeye);
		_camera->setPosition3D(Vec3(0.0f,0.0f,_nowZeye));
		_camera->lookAt(Vec3(0.0f,0.0f,0.0f));
	}
}

void BesselUI::visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)
{
	if (!_visible)
		return;
	//if (isVisitableByVisitingCamera())
//	{
		Layer::visit(renderer, parentTransform, parentFlags);
//	}
}

void   BesselUI::drawAxisMesh()
{
	auto &winSize = Director::getInstance()->getWinSize();
	//X Axis
//	_axisNode->drawLine(Vec3(0.0f,0.0f,0.0f),Vec3(winSize.width/2.0f,0.0f,0.0f),Color4F(1.0f,0.0f,0.0f,1.0f));
	//Y Axis
//	_axisNode->drawLine(Vec3(0.0f,0.0f,0.0f),Vec3(0.0f,winSize.height/2.0f,0.0f),Color4F(0.0f,1.0f,0.0f,1.0f));
	//Z Axis
//	_axisNode->drawLine(Vec3(0.0f, 0.0f, 0.0f), Vec3(0.0f,0.0f,winSize.height/1.1566f),Color4F(0.0f,0.0f,1.0f,1.0f));
    
    _axisNode->drawLine(Vec3(-667, -375, 0), Vec3(667, -375, 0), Color4F(1.0, 0.0, 0.0, 1.0));
    _axisNode->drawLine(Vec3(667, -375, 0), Vec3(667, 375, 0), Color4F(1.0, 0.0, 0.0, 1.0));
    _axisNode->drawLine(Vec3(667, 375, 0), Vec3(-667, 375, 0), Color4F(1.0, 0.0, 0.0, 1.0));
    _axisNode->drawLine(Vec3(-667, 375, 0), Vec3(-667, -375, 0), Color4F(1.0, 0.0, 0.0, 1.0));
    
	//空间网格,默认24*24
	const  int   meshSize = 24;
	const float stepX = winSize.width / meshSize;

	const float zeye = winSize.height / 1.1566f;
	const float startZ = winSize.height/2.0f;
	const float  finalZ = -winSize.height / 1.1566f;
	const float  zlengthUnit = (finalZ - startZ)/meshSize;
	const float  ylengthUnit = winSize.height / meshSize;
	const float  halfWidth = winSize.width / 2.0f;
	const float  halfHeight = winSize.height / 2.0f;
	//计算视锥体最近与最远处的八个坐标
	const float nearZ = startZ;
	const float farZ = zeye + winSize.height/2.0f + 5000.0f;
	//屏幕的横纵比
	const float screenFactor = winSize.width/winSize.height;
	const float tanOfValue = tanf(CC_DEGREES_TO_RADIANS(60.0f/2.0f));
	const float nearHeight = tanOfValue * nearZ;
	const float nearWidth = screenFactor * nearHeight;
	const float farHeight = tanOfValue * farZ;
	const float farWidth = screenFactor * farHeight;
	//近远平面的中心坐标
	const Vec3 nearCenter(0.0f,0.0f,-nearZ);
	const Vec3 farCenter(0.0f,0.0f,-farZ);
	//方向向量
	const Vec3 forwardVec(0.0f,0.0f,-1.0f);
	const Vec3 xVec(1.0f,0.0f,0.0f);
	const Vec3 yVec(0.0f,1.0f,0.0f);
	//8个视锥体世界坐标点
	 Vec3 frustumCoord[8] = {
		nearCenter - xVec * nearWidth -  yVec * nearHeight,nearCenter + xVec * nearWidth - yVec * nearHeight,//(bottom left,bottom right)
		nearCenter  -xVec * nearWidth + yVec * nearHeight,nearCenter + xVec * nearWidth + yVec * nearHeight,//(top left,top right)
		farCenter    - xVec * farWidth    - yVec *farHeight,farCenter + xVec* farWidth- yVec * farHeight,//far bottom left
		farCenter    -xVec  * farWidth   +yVec  * farHeight,farCenter + xVec *farWidth + yVec * farHeight,//far top left/right
	};
	 //在原来的基础上,将视锥体的Z坐标累加上zeye
	 for (int i = 0; i < 8; ++i)
		 frustumCoord[i].z += zeye;
	//下方网格
	 const Vec3 farStepBottomZ = (frustumCoord[5] - frustumCoord[4])/meshSize;
	 const Vec3 nearStepBottomZ =( frustumCoord[1] - frustumCoord[0])/meshSize;
	 for (int i = 0; i < meshSize + 1; ++i)
		 _axisNode->drawLine(frustumCoord[0] + nearStepBottomZ * i, frustumCoord[4]+farStepBottomZ*i, Color4F(1.0f, 0.6f, 0.6f, 0.15));
		//_axisNode->drawLine(Vec3(i*stepX- halfWidth,-halfHeight ,startZ),Vec3(i*stepX-halfWidth,-halfHeight,finalZ),Color4F(1.0f,0.6f,0.6f,1.0f));
	 const Vec3 leftStepBottom = (frustumCoord[4] - frustumCoord[0])/meshSize;
	 const Vec3 rightStepBottom = (frustumCoord[5]- frustumCoord[1])/meshSize;
	 for (int j = 0; j < meshSize + 1; ++j)
		 _axisNode->drawLine(frustumCoord[0]+leftStepBottom*j, frustumCoord[1]+rightStepBottom*j,Color4F(0.6f,1.0f,0.6f,0.15));
		//_axisNode->drawLine(Vec3(-halfWidth,-halfHeight,startZ+j*zlengthUnit),Vec3(halfWidth,-halfHeight,startZ+j*zlengthUnit),Color4F(0.6f,1.0f,0.6f,1.0f));
	//上方的网格
	 const Vec3 nearStepTopZ = (frustumCoord[3] - frustumCoord[2])/meshSize;
	 const Vec3 farStepTopZ = (frustumCoord[7] - frustumCoord[6])/meshSize;
	 for (int i = 0; i < meshSize + 1; ++i)
		 _axisNode->drawLine(frustumCoord[2]+nearStepTopZ*i, frustumCoord[6]+farStepTopZ*i,Color4F(1.0f,1.0f,0.0f,0.15));
		//_axisNode->drawLine(Vec3(i*stepX-halfWidth,halfHeight,startZ),Vec3(i*stepX-halfWidth,halfHeight,finalZ),Color4F(1.0f,1.0f,0.0f,1.0f));
	 const Vec3 leftStepTop = (frustumCoord[6] - frustumCoord[2])/meshSize;
	 const Vec3 rightStepTop = (frustumCoord[7]- frustumCoord[3])/meshSize;
	 for (int j = 0; j < meshSize + 1; ++j)
		 _axisNode->drawLine(frustumCoord[2]+leftStepTop*j, frustumCoord[3]+rightStepTop*j,Color4F(1.0f,0.0f,1.0f,0.15));
		//_axisNode->drawLine(Vec3(-halfWidth,halfHeight,startZ+j*zlengthUnit),Vec3(halfWidth,halfHeight,startZ+j*zlengthUnit),Color4F(1.0f,0.0f,1.0f,1.0f));
	//左侧网格
	 const Vec3 leftStepNear =( frustumCoord[2]- frustumCoord[0])/meshSize;
	 const Vec3 leftStepFar = (frustumCoord[6]- frustumCoord[4])/meshSize;
	 for (int i = 0; i < meshSize + 1; ++i)
		 _axisNode->drawLine(frustumCoord[0]+leftStepNear*i, frustumCoord[4]+leftStepFar*i,Color4F(1.0f,0.8f,0.2f,0.15));
		//_axisNode->drawLine(Vec3(-halfWidth,-halfHeight+i*ylengthUnit,startZ),Vec3(-halfWidth,-halfHeight+i*ylengthUnit,finalZ),Color4F(1.0f,0.8f,0.2f,1.0f));
	 for (int j = 0; j < meshSize + 1; ++j)
		 _axisNode->drawLine(frustumCoord[0]+leftStepBottom*j, frustumCoord[2]+leftStepTop*j,Color4F(0.2f,1.0f,0.8f,0.15));
		//_axisNode->drawLine(Vec3(-halfWidth,-halfHeight,startZ+zlengthUnit*j),Vec3(-halfWidth,halfHeight,startZ+zlengthUnit*j),Color4F(0.2f,1.0f,0.8f,1.0f));
	//右侧的网格
	 const Vec3 rightStepNear = (frustumCoord[3] - frustumCoord[1])/meshSize;
	 const Vec3 rightStepFar = (frustumCoord[7] - frustumCoord[5])/meshSize;
	 for (int i = 0; i < meshSize + 1; ++i)
		 _axisNode->drawLine(frustumCoord[1]+rightStepNear*i, frustumCoord[5]+rightStepFar*i,Color4F(0.782, 0.387, 0.664, 0.15));
	 // _axisNode->drawLine(Vec3(halfWidth, -halfHeight + i*ylengthUnit, startZ), Vec3(halfWidth, -halfHeight + i*ylengthUnit, finalZ), Color4F(0.782, 0.387, 0.664, 1.0f));
	 for (int j = 0; j < meshSize + 1; ++j)
		_axisNode->drawLine(frustumCoord[1]+ rightStepBottom*j, frustumCoord[3]+rightStepTop*j,Color4F(0.664f, 0.387f, 0.782f, 0.15)) ;
	 // _axisNode->drawLine(Vec3(halfWidth, -halfHeight, startZ + zlengthUnit*j), Vec3(halfWidth, halfHeight, startZ + zlengthUnit*j), Color4F(0.664f, 0.387f, 0.782f, 1.0f));
    
    
    float nearZBorder = zeye - 300;
    float farZBorder = zeye + 800;
    float nearYBorder = nearZBorder * tan(30.0 * M_PI / 180);
    float farYBorder = farZBorder * tan(30.0 * M_PI / 180);
    float nearXBorder = nearYBorder * 1334 / 750;
    float farXBorder= farYBorder * 1335 / 750;
    
    _axisNode->drawLine(Vec3(-nearXBorder, -nearYBorder, 300), Vec3(nearXBorder, -nearYBorder, 300), Color4F(1.0, 0.0, 0.0, 1.0));
    _axisNode->drawLine(Vec3(nearXBorder, -nearYBorder, 300), Vec3(nearXBorder, nearYBorder, 300), Color4F(1.0, 0.0, 0.0, 1.0));
    _axisNode->drawLine(Vec3(nearXBorder, nearYBorder, 300), Vec3(-nearXBorder, nearYBorder, 300), Color4F(1.0, 0.0, 0.0, 1.0));
    _axisNode->drawLine(Vec3(-nearXBorder, nearYBorder, 300), Vec3(-nearXBorder, -nearYBorder, 300), Color4F(1.0, 0.0, 0.0, 1.0));
    
    _axisNode->drawLine(Vec3(-farXBorder, -farYBorder, -800), Vec3(farXBorder, -farYBorder, -800), Color4F(1.0, 0.0, 0.0, 1.0));
    _axisNode->drawLine(Vec3(farXBorder, -farYBorder, -800), Vec3(farXBorder, farYBorder, -800), Color4F(1.0, 0.0, 0.0, 1.0));
    _axisNode->drawLine(Vec3(farXBorder, farYBorder, -800), Vec3(-farXBorder, farYBorder, -800), Color4F(1.0, 0.0, 0.0, 1.0));
    _axisNode->drawLine(Vec3(-farXBorder, farYBorder, -800), Vec3(-farXBorder, -farYBorder, -800), Color4F(1.0, 0.0, 0.0, 1.0));
    
    _axisNode->drawLine(Vec3(-667, -375, 0), Vec3(667, -375, 0), Color4F(1.0, 0.0, 0.0, 1.0));
    _axisNode->drawLine(Vec3(667, -375, 0), Vec3(667, 375, 0), Color4F(1.0, 0.0, 0.0, 1.0));
    _axisNode->drawLine(Vec3(667, 375, 0), Vec3(-667, 375, 0), Color4F(1.0, 0.0, 0.0, 1.0));
    _axisNode->drawLine(Vec3(-667, 375, 0), Vec3(-667, -375, 0), Color4F(1.0, 0.0, 0.0, 1.0));
    
    _axisNode->drawLine(Vec3(-farXBorder, 0, -800), Vec3(farXBorder, 0, -800), Color4F(1.0, 0.0, 0.0, 0.3));
    _axisNode->drawLine(Vec3(0, farYBorder, -800), Vec3(0, -farYBorder, -800), Color4F(1.0, 0.0, 0.0, 0.3));
    
    _axisNode->drawLine(Vec3(-nearXBorder, 0, 300), Vec3(nearXBorder, 0, 300), Color4F(1.0, 0.0, 0.0, 0.3));
    _axisNode->drawLine(Vec3(0, -nearYBorder, 300), Vec3(0, nearYBorder, 300), Color4F(1.0, 0.0, 0.0, 0.3));
    
    _axisNode->drawLine(Vec3(-667, 0, 0), Vec3(667, 0, 0), Color4F(1.0, 0.0, 0.0, 0.3));
    _axisNode->drawLine(Vec3(0, -375, 0), Vec3(0, 375, 0), Color4F(1.0, 0.0, 0.0, 0.3));
    

}

void    BesselUI::loadSettingLayer()
{
	_settingLayer = Layer::create();
	const   float  layerHeight = 600;
	const   float  layerWidth = 240;
	const   float  secondaryHeight = 560;
	auto &winSize = Director::getInstance()->getWinSize();
	const  float halfWidth = winSize.width / 2.0f;
	const  float halfHeight = winSize.height / 2.0f;
	//背景板
	Sprite   *bg = Sprite::create("tools-ui/layer-ui/global_bg_big.png",Rect((864.0f -layerWidth)/2.0f,(569.0f -layerHeight)/2.0f,layerWidth,layerHeight));
	bg->setAnchorPoint(Vec2(0.0f,0.0f));
	_settingLayer->addChild(bg,1);
	//面板右侧上下居中对齐,默认是关闭着的
	_settingLayer->setPosition(Vec2(winSize.width,(winSize.height-layerHeight)/2));//(Vec2(halfWidth,(winSize.height-layerHeight)/2.0f - halfHeight));
	//指示按钮
	cocos2d::ui::Button   *directButton = cocos2d::ui::Button::create("tools-ui/direct-button/arrow.png", "");
	directButton->setTag(_TAG_BUTTON_DIRECT_);
	directButton->setFlippedX(true);
	directButton->setPosition(Vec2(-18.0f,(secondaryHeight -56.0f)/2.0f));
	directButton->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_SpreadOrHide,this));
	_settingLayer->addChild(directButton,2);
	//创建可以切换曲线类型的RadioButton
	char buffer[64];
	char *nameTitle[2] = {"Bessel","Spiral"};
	ui::RadioButtonGroup *group = ui::RadioButtonGroup::create();
	group->setTag(_TAG_RADIO_BUTTON_GROUP_CURVE_);
	_settingLayer->addChild(group);
	int   tags[2] = {CurveType::CurveType_Bessel,CurveType::CurveType_Spiral};
	for (int i = 0; i < 2; ++i)//目前只有两种曲线类型
	{
		cocos2d::ui::RadioButton *radioButton = ui::RadioButton::create("tools-ui/layer-ui/radio_button_off.png", "tools-ui/layer-ui/radio_button_on.png");
		radioButton->setPosition(Vec2(32+ 48*i,layerHeight - 50));
		radioButton->setTag(_TAG_RADIO_BUTTON_CURVE_+ tags[i]);//设置按钮的标志类型,也代表着曲线的类型
		radioButton->addEventListener(CC_CALLBACK_2(BesselUI::onChangeRadioButtonSelect_ChangeCurve,this));
		group->addRadioButton(radioButton);
		_settingLayer->addChild(radioButton);
		Label *name = Label::createWithSystemFont(nameTitle[i], "Arial", 14);
		name->setPosition(Vec2(32+48 *i,layerHeight -20));
		_settingLayer->addChild(name);
		if (!  i  )
			group->setSelectedButton(radioButton);
	}
	//创建ScrollView
	_scrollView = ui::ScrollView::create();
	_scrollView->setBounceEnabled(true);
	_scrollView->setDirection(ui::ScrollView::Direction::HORIZONTAL);
	_scrollView->setContentSize(cocos2d::Size(200.0f, 48.0f));
	_scrollView->setScrollBarPositionFromCorner(Vec2(4, 4));
	_scrollView->setScrollBarColor(Color3B::YELLOW);
	_scrollView->setPosition(cocos2d::Vec2((layerWidth-200)/2.0f,(secondaryHeight -92.0f)));
	_scrollView->setInnerContainerSize(cocos2d::Size(48*(_static_bessel_node_max_count-_TAG_RADIO_BUTTON_), 48.0f));
	_scrollView->setTag(_TAG_SCROLL_VIEW_);
	_settingLayer->addChild(_scrollView,5);

	//控制贝塞尔曲线控制点数目的UIRadioButton
	cocos2d::ui::RadioButtonGroup     *buttonGroup = cocos2d::ui::RadioButtonGroup::create();
	buttonGroup->setTag(_TAG_RADIO_BUTTON_GROUP_);
	_scrollView->addChild(buttonGroup, 3);
	//目前支持的贝塞尔曲线控制点的数目为3,4,5,6,----16
	const float buttonWidth = 48.0f;
	const float buttonStartX = 24.0f + (layerWidth - 4.0f * buttonWidth)/2.0f;
	const float buttonHeight = secondaryHeight - buttonWidth *1.5f;
	for (int j = 0; j < _static_bessel_node_max_count- _TAG_RADIO_BUTTON_; ++j)
	{
		cocos2d::ui::RadioButton* radioButton = cocos2d::ui::RadioButton::create("tools-ui/layer-ui/radio_button_off.png", "tools-ui/layer-ui/radio_button_on.png");
		radioButton->setPosition(Vec2( 16+buttonWidth * j,16));
		radioButton->setTag(_TAG_RADIO_BUTTON_ +j);
		radioButton->addEventListener(CC_CALLBACK_2(BesselUI::onChangeRadioButtonSelect_ControlPoint,this));
		buttonGroup->addRadioButton(radioButton);
		_scrollView->addChild(radioButton,4);
		//label name,关于控制点数目的说明
		sprintf(buffer,"%d", _TAG_RADIO_BUTTON_ +j);
		Label    *labelName = Label::createWithSystemFont(buffer, "Arial", 14);
		labelName->setPosition(Vec2(16+buttonWidth*j,10+buttonWidth/1.5f));
		if(j+ _TAG_RADIO_BUTTON_ == 4)
			buttonGroup->setSelectedButton(radioButton);

		_scrollView->addChild(labelName, 4);
	}
	//控制螺旋曲线的旋转方向的组件
	_ccwComponentPanel = Node::create();
	_ccwComponentPanel->setPosition(Vec2(layerWidth/2.0f, (secondaryHeight - 76.0f)));
	_settingLayer->addChild(_ccwComponentPanel,5);
	ui::RadioButtonGroup  *ccwGroup = ui::RadioButtonGroup::create();
	_settingLayer->addChild(ccwGroup,5);
	const char *ccwName[2] = {"CW","CCW"};
	for (int j = 0; j < 2; ++j)
	{
		ui::RadioButton  *radioButton = ui::RadioButton::create("tools-ui/layer-ui/radio_button_off.png", "tools-ui/layer-ui/radio_button_on.png");
		radioButton->setPosition(Vec2(16 + buttonWidth * (j-1), 0));
		radioButton->setTag(j * 2 - 1);
		radioButton->addEventListener(CC_CALLBACK_2(BesselUI::onChangeRadioButtonSelect_ChangeCCW,this));
		Label    *labelName = Label::createWithSystemFont(ccwName[j], "Arial", 14);
		labelName->setPosition(Vec2(16 + buttonWidth * (j - 1),  buttonWidth / 1.5f));
		_ccwComponentPanel->addChild(radioButton);
		_ccwComponentPanel->addChild(labelName);
		ccwGroup->addRadioButton(radioButton);
		//
		if (j == 1)
			ccwGroup->setSelectedButton(radioButton);
	}
	_ccwComponentPanel->setVisible(false);
	//记录当前的已经保存的数据的数目
	sprintf(buffer, "finished: %d", _besselSetData.size());
	Label      *_saveLabel = Label::createWithSystemFont(buffer, "Arial", 16);
	_saveLabel->setAnchorPoint(Vec2());
	_saveLabel->setTag(_TAG_LABEL_TOTAL_RECORD_);
	_saveLabel->setPosition(Vec2(4.0f,4.0f));
	_saveLabel->setColor(Color3B(255,255,220));
	_settingLayer->addChild(_saveLabel,5);
	//删除上一条
	const  float     buttonX = layerWidth/2.0f;
	const  float		buttonSeqHeight = 56.0f;//按钮序列的高度都设置为48.0f像素
    float     buttonY = (secondaryHeight - buttonStartX - 24.0f - buttonSeqHeight);
	//新建一条路径
	cocos2d::ui::Button *buttonNew = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	const cocos2d::Size &buttonSize = buttonNew->getContentSize();
	buttonNew->setTag(_TAG_NEW_PATH_);
	buttonNew->setPosition(Vec2(buttonX,buttonY));
	buttonNew->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_New,this));
	Label   *name = Label::createWithSystemFont("New", "Arial", 16);
	name->setPosition(Vec2(buttonSize.width/2.0f, buttonSize.height/2.0f));
	buttonNew->addChild(name);
	_settingLayer->addChild(buttonNew, 5);
	buttonY -= buttonSeqHeight;
	//
	cocos2d::ui::Button      *buttonRemove = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png","tools-ui/direct-button/backtotoppressed.png");
	buttonRemove->setTag(_TAG_BUTTON_REMOVE_LAST_RECORD_);
	Label       *labelName = Label::createWithSystemFont("Remove Record","Arial",16);
	buttonRemove->addChild(labelName);
	buttonRemove->setEnabled(_besselSetData.size());
	labelName->setPosition(Vec2(buttonSize.width / 2.0f, buttonSize.height / 2.0f));
	buttonRemove->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_RemoveLast,this));
	buttonRemove->setPosition(Vec2(buttonX,buttonY));
	_settingLayer->addChild(buttonRemove,6);
	//保存当前设置
	cocos2d::ui::Button  *buttonSave = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	buttonSave->setTag(_TAG_BUTTON_SAVE_CURRENT_RECORD_);
	buttonSave->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_SaveRecord,this));
	labelName = Label::createWithSystemFont("Save Record", "Arial", 16);
	labelName->setPosition(Vec2(buttonSize.width / 2.0f, buttonSize.height / 2.0f));
	buttonSave->addChild(labelName);
	buttonSave->setPosition(Vec2(buttonX,buttonY - buttonSeqHeight));
	_settingLayer->addChild(buttonSave,7);
	//保存到文件中
	cocos2d::ui::Button *buttonSaveFile = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	buttonSaveFile->setTag(_TAG_BUTTON_SAVE_TO_FILE_);
	buttonSaveFile->setEnabled(_besselSetData.size());
	buttonSaveFile->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_SaveToFile,this));
	labelName = Label::createWithSystemFont("Save to File", "Arial", 16);
	labelName->setPosition(Vec2(buttonSize.width / 2.0f, buttonSize.height / 2.0f));
	buttonSaveFile->addChild(labelName);
	buttonSaveFile->setPosition(Vec2(buttonX,buttonY - 2.0f*buttonSeqHeight));
	_settingLayer->addChild(buttonSaveFile,8);
    
    // 保存参数化数据
    cocos2d::ui::Button *buttonSaveParsed = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
    buttonSaveParsed->setTag(_TAG_BUTTON_SAVE_PARSED_);
    buttonSaveParsed->setEnabled(_besselSetData.size());
    buttonSaveParsed->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_SaveParsed,this));
    labelName = Label::createWithSystemFont("Save parsed", "Arial", 16);
    labelName->setPosition(Vec2(buttonSize.width / 2.0f, buttonSize.height / 2.0f));
    buttonSaveParsed->addChild(labelName);
    buttonSaveParsed->setPosition(Vec2(buttonX, buttonY - 3.0f*buttonSeqHeight));
    _settingLayer->addChild(buttonSaveParsed,8);
    
    //曲线预览
	cocos2d::ui::Button *buttonPreview = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	buttonPreview->setTag(_TAG_BUTTON_PREVIEW_);
	buttonPreview->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_Preview,this));
	labelName = Label::createWithSystemFont("Preview", "Arial", 16);
	labelName->setPosition(Vec2(buttonSize.width / 2.0f, buttonSize.height / 2.0f));
	buttonPreview->addChild(labelName);
	buttonPreview->setPosition(Vec2(buttonX,buttonY - 4.0f * buttonSeqHeight));
	_settingLayer->addChild(buttonPreview, 9);
	//选择所需要的鱼
	cocos2d::ui::Button *fishMap = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	fishMap->setTag(_TAG_BUTTON_FISH_MAP_);
	fishMap->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_FishMap,this));
	labelName = Label::createWithSystemFont("Fish Map Setting","Arial",16);
	labelName->setPosition(Vec2(buttonSize.width/2.0f,buttonSize.height/2.0f));
	fishMap->addChild(labelName);
	fishMap->setPosition(Vec2(buttonX,buttonY - 5.0f *buttonSeqHeight));
	_settingLayer->addChild(fishMap, 10);
	//编辑框
	ui::Scale9Sprite *textBg = cocos2d::ui::Scale9Sprite::create("tools-ui/text_bg.png");
	_editBox = cocos2d::ui::EditBox::create(cocos2d::Size(48,32),textBg);
	_editBox->setFont("Arial",16);
	_editBox->setFontColor(Color4B(255,32,255,255));
	_editBox->setPlaceHolder("input");
	_editBox->setPlaceholderFontColor(Color4B::GRAY);
	_editBox->setMaxLength(3);
	_editBox->setInputMode(ui::EditBox::InputMode::NUMERIC);
	_editBox->setDelegate(this);
	_editBox->setPosition(Vec2(layerWidth - 32,32));
    _editBox->setName("RouteIndex");
	_settingLayer->addChild(_editBox,10);
	this->addChild(_settingLayer,2);
	//预览曲线的编辑框,支持多种文法
	ui::Scale9Sprite  *editboxBgc = cocos2d::ui::Scale9Sprite::create("tools-ui/text_bg.png");
	_routeGroupEditBox = cocos2d::ui::EditBox::create(cocos2d::Size(100, 32), editboxBgc);
	_routeGroupEditBox->setTag(_TAG_EDIT_BOX_ROUTE_GROUP_);
	_routeGroupEditBox->setFont("Arial", 16);
	_routeGroupEditBox->setFontColor(Color4B::RED);
	//_routeGroupEditBox->setInputMode(cocos2d::ui::EditBox::InputMode::NUMERIC);
	_routeGroupEditBox->setDelegate(this);
	_routeGroupEditBox->setName("RouteGroup");
	_routeGroupEditBox->setPosition(Vec2(layerWidth/2-10,48));
	_settingLayer->addChild(_routeGroupEditBox,2);
    //编辑各个控制点的速度
   ui::Scale9Sprite *b2g = cocos2d::ui::Scale9Sprite::create("tools-ui/text_bg.png");
	_speedEditBox = cocos2d::ui::EditBox::create(cocos2d::Size(48, 32), b2g);
	_speedEditBox->setTag(_TAG_EDIT_BOX_0_);
	_speedEditBox->setFont("Arial", 16);
	_speedEditBox->setFontColor(Color4B(255, 32, 255, 255));
	_speedEditBox->setPlaceHolder("1.00");
	_speedEditBox->setPlaceholderFontColor(Color4B::GRAY);
	_speedEditBox->setMaxLength(3);
	_speedEditBox->setInputMode(ui::EditBox::InputMode::NUMERIC);
	_speedEditBox->setDelegate(this);
	_speedEditBox->setPosition(Vec2(567, 70));
	_speedEditBox->setText("100");
	_speedEditBox->setName("nicaicaispeed");
	this->addChild(_speedEditBox, 13);
	//
    ui::Scale9Sprite *speedSetting = cocos2d::ui::Scale9Sprite::create("tools-ui/text_bg.png");
    cocos2d::ui::EditBox* _editBox = cocos2d::ui::EditBox::create(cocos2d::Size(48,32),speedSetting);
	_editBox->setTag(_TAG_EDIT_BOX_0_);
    _editBox->setFont("Arial",16);
    _editBox->setFontColor(Color4B(255,32,255,255));
    _editBox->setPlaceHolder("100");
    _editBox->setPlaceholderFontColor(Color4B::GRAY);
    _editBox->setMaxLength(3);
    _editBox->setInputMode(ui::EditBox::InputMode::NUMERIC);
    _editBox->setDelegate(this);
    _editBox->setPosition(Vec2(667, 70));
    _editBox->setText("100");
    _editBox->setName("SpeedSetting");

    this->addChild(_editBox,10);
    
    ui::Scale9Sprite *weightSetting = cocos2d::ui::Scale9Sprite::create("tools-ui/text_bg.png");
    _editBox = cocos2d::ui::EditBox::create(cocos2d::Size(48,32),weightSetting);
	_editBox->setTag(_TAG_EDIT_BOX_1_);
    _editBox->setFont("Arial",16);
    _editBox->setFontColor(Color4B(255,32,255,255));
    _editBox->setPlaceHolder("0.5");
    _editBox->setPlaceholderFontColor(Color4B::GRAY);
    _editBox->setMaxLength(3);
    _editBox->setInputMode(ui::EditBox::InputMode::NUMERIC);
    _editBox->setDelegate(this);
    _editBox->setPosition(Vec2(767, 70));
    _editBox->setText("0.5");
    _editBox->setName("WeightSetting");
    
    this->addChild(_editBox,10);
	//半径输入框
	cocos2d::ui::Scale9Sprite *editboxBg = cocos2d::ui::Scale9Sprite::create("tools-ui/text_bg.png");
	_topRadiusEditBox = cocos2d::ui::EditBox::create(cocos2d::Size(48,32),editboxBg);
	_topRadiusEditBox->setTag(_TAG_EDIT_BOX_TOP_RADIUS_);
	_topRadiusEditBox->setFont("Arial",16);
	_topRadiusEditBox->setFontColor(Color4B::RED);
	_topRadiusEditBox->setPlaceHolder("50");
	_topRadiusEditBox->setMaxLength(3);
	_topRadiusEditBox->setInputMode(cocos2d::ui::EditBox::InputMode::NUMERIC);
	_topRadiusEditBox->setDelegate(this);
	_topRadiusEditBox->setText("50");
	_topRadiusEditBox->setName("TopRadius");
	_topRadiusEditBox->setPosition(Vec2(867 ,70));
	this->addChild(_topRadiusEditBox, 11);
	//下半径输入框
	editboxBg = cocos2d::ui::Scale9Sprite::create("tools-ui/text_bg.png");
	_bottomRadiusEditBox = cocos2d::ui::EditBox::create(cocos2d::Size(48, 32), editboxBg);
	_bottomRadiusEditBox->setTag(_TAG_EDIT_BOX_TOP_RADIUS_);
	_bottomRadiusEditBox->setFont("Arial", 16);
	_bottomRadiusEditBox->setFontColor(Color4B::RED);
	_bottomRadiusEditBox->setPlaceHolder("50");
	_bottomRadiusEditBox->setMaxLength(3);
	_bottomRadiusEditBox->setInputMode(cocos2d::ui::EditBox::InputMode::NUMERIC);
	_bottomRadiusEditBox->setDelegate(this);
	_bottomRadiusEditBox->setText("50");
	_bottomRadiusEditBox->setName("BottomRadius");
	_bottomRadiusEditBox->setPosition(Vec2(967, 70));
	this->addChild(_bottomRadiusEditBox, 12);
	//编辑曲线的动画索引
	editboxBg = cocos2d::ui::Scale9Sprite::create("tools-ui/text_bg.png");
	_actionIndexEditBox = cocos2d::ui::EditBox::create(cocos2d::Size(48, 32), editboxBg);
	_actionIndexEditBox->setTag(_TAG_EDIT_BOX_TOP_RADIUS_);
	_actionIndexEditBox->setFont("Arial", 16);
	_actionIndexEditBox->setFontColor(Color4B::RED);
	_actionIndexEditBox->setPlaceHolder("0");
	_actionIndexEditBox->setMaxLength(3);
	_actionIndexEditBox->setInputMode(cocos2d::ui::EditBox::InputMode::NUMERIC);
	_actionIndexEditBox->setDelegate(this);
	_actionIndexEditBox->setText("0");
	_actionIndexEditBox->setName("ActionIndex");
	_actionIndexEditBox->setPosition(Vec2(1067, 70));
	this->addChild(_actionIndexEditBox,12);

	_topRadiusEditBox->setVisible(false);
	_bottomRadiusEditBox->setVisible(false);
}
void   BesselUI::onButtonClick_SpreadOrHide(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type)
{
	cocos2d::ui::Button        *directButton = (cocos2d::ui::Button *)pSender;
	if (type == cocos2d::ui::Widget::TouchEventType::ENDED)
	{
		const float     layerWidth = 240;
		//如果当前是伸展着的
		if (directButton->isFlippedX())
		{
			cocos2d::Sequence     *seqAction = cocos2d::Sequence::create(
				cocos2d::MoveBy::create(0.2f,Vec3(-layerWidth,0.0f,0.0f)),
				cocos2d::CallFunc::create([=]() {
				directButton->setFlippedX(false);
			}),
				NULL
			);
			_settingLayer->runAction(seqAction);
		}
		else
		{
			cocos2d::Sequence  *seqAcxtion = cocos2d::Sequence::create(
				cocos2d::MoveBy::create(0.2f,Vec3(layerWidth,0.0f,0.0f)),
				cocos2d::CallFunc::create([=]() {
					directButton->setFlippedX(true);
				}),
				NULL
			);
			_settingLayer->runAction(seqAcxtion);
		}
	}
}

void BesselUI::onUIChangedCallback(CurveType curveType, int param1, int param2)
{
	if (curveType == CurveType::CurveType_Bessel)
	{
		//检测当前滑动面板中RadioButton的显示情况
		if (param2)
		{
			cocos2d::ui::RadioButtonGroup *group = (cocos2d::ui::RadioButtonGroup*)_scrollView->getChildByTag(_TAG_RADIO_BUTTON_GROUP_);
			cocos2d::ui::RadioButton *radioButton = (cocos2d::ui::RadioButton*)_scrollView->getChildByTag(param2);
			group->setSelectedButton(radioButton);
		}
	}
	else if (curveType == CurveType::CurveType_Spiral)
	{
		char buffer[128];
		sprintf(buffer, "%.1f", param2);
		if (param1 == SpiralValueType::SpiralValueType_BottomRadius)
			_bottomRadiusEditBox->setText(buffer);
		else if (param1 == SpiralValueType::SpiralValueType_TopRadius)
			_topRadiusEditBox->setText(buffer);
	}
}

void      BesselUI::changeCurveNode(CurveType curveType)
{
	if (curveType != _curveNode->getType())
	{
		CurveNode *newNode = nullptr;
		if (curveType == CurveType::CurveType_Bessel)
		{
			BesselNode *node = BesselNode::createBesselNode();
			newNode = node;
			//设置组按钮的相关按钮指示
			cocos2d::ui::RadioButtonGroup *group = (cocos2d::ui::RadioButtonGroup*)_scrollView->getChildByTag(_TAG_RADIO_BUTTON_GROUP_);
			int index = group->getSelectedButtonIndex();
			cocos2d::ui::RadioButton *radioButton = group->getRadioButtonByIndex(index);
			node->initControlPoint(radioButton->getTag());
			//同时不再隐藏滑动控制点
			_scrollView->setVisible(true);
			_topRadiusEditBox->setVisible(false);
			_bottomRadiusEditBox->setVisible(false);
			_ccwComponentPanel->setVisible(false);
			node->setTouchSelectedCallback(CC_CALLBACK_1(BesselUI::notifyBesselNodeSelected,this));
		}
		else if (curveType == CurveType::CurveType_Spiral)
		{	
			SpiralNode *nbode=SpiralNode::createSpiralNode();
			newNode = nbode;
			_scrollView->setVisible(false);
			_topRadiusEditBox->setVisible(true);
			_bottomRadiusEditBox->setVisible(true);
			_ccwComponentPanel->setVisible(true);
		}
		if (newNode != nullptr)
		{
			_curveNode->removeFromParent();
			_curveNode = newNode;
			_curveNode->setCameraMask((short)CameraFlag::USER1);
			_curveNode->setUIChangedCallback(CC_CALLBACK_3(BesselUI::onUIChangedCallback,this));
			_curveNode->setRotationQuat(_rotateQua);
			this->addChild(_curveNode);
			//设置鱼的相关数据
			if (_currentSelectFishIds.size())
			{
				int fishId = _currentSelectFishIds[0];
				auto &fishVisual = _fishVisualStatic[fishId];
				_curveNode->setPreviewModel(fishVisual);
			}
			else
				_curveNode->setPreviewModel(_fishVisualStatic.begin()->second);
		}
	}
}

void BesselUI::notifyBesselNodeSelected(int selectedIndex)
{
	if (_curveNode->getType() != CurveType::CurveType_Bessel)
		return;
	BesselNode	 *node = (BesselNode*)_curveNode;
	char buffer[128];
	//当前控制点的速度系数
	sprintf(buffer, "%.2f", node->getSelectControlPoint()->_speedCoef);
	_speedEditBox->setText(buffer);
	//当前控制点的动画索引
	sprintf(buffer,"%d",node->getSelectControlPoint()->getActionIndex());
	_actionIndexEditBox->setText(buffer);
}

//切换曲线类型
void      BesselUI::onChangeRadioButtonSelect_ChangeCurve(cocos2d::ui::RadioButton *radioButton, cocos2d::ui::RadioButton::EventType type)
{
	if (type == cocos2d::ui::RadioButton::EventType::SELECTED)
	{
		CurveType curveType = (CurveType)(radioButton->getTag()- _TAG_RADIO_BUTTON_CURVE_);
		changeCurveNode(curveType);
	}
}

void      BesselUI::onChangeRadioButtonSelect_ChangeCCW(cocos2d::ui::RadioButton *radioButton, cocos2d::ui::RadioButton::EventType type)
{
	if (type == ui::RadioButton::EventType::SELECTED)
	{
		int   tag = radioButton->getTag();
		SpiralNode *node = (SpiralNode *)_curveNode;
		node->setCCWValue(tag);
	}
}

void      BesselUI::onChangeRadioButtonSelect_ControlPoint(cocos2d::ui::RadioButton* radioButton, cocos2d::ui::RadioButton::EventType type)
{
	//如果某一个按钮被选中了
	if (type == cocos2d::ui::RadioButton::EventType::SELECTED)
	{
		int   nowTag = radioButton->getTag();
		//
		_xyOffset = Vec2();
		cocos2d::Quaternion qua;
		Mat4       mat;
		_curveNode->setRotationQuat(qua);
		_curveNode->setRotateMatrix(mat);
		_curveNode->initControlPoint(nowTag);
		//坐标轴恢复
		_axisNode->setRotationQuat(qua);
	}
}

void BesselUI::onButtonClick_New(cocos2d::Ref *sender, cocos2d::ui::Widget::TouchEventType type)
{
	cocos2d::ui::Button *button = (cocos2d::ui::Button *)sender;
	if (type == cocos2d::ui::Widget::TouchEventType::ENDED)
	{
		if (_currentEditPathIndex != -1)
		{
			_currentEditPathIndex = -1;
			//将场景设置为正常状态
			cocos2d::Quaternion qua;
			Mat4       mat;
			_curveNode->setRotationQuat(qua);
			_curveNode->setRotateMatrix(mat);
			_curveNode->restoreCurveNodePosition();
			//坐标轴恢复
			_axisNode->setRotationQuat(qua);
			_editBox->setText("");
			_currentSelectFishIds.clear();
		}
	}
}
//删除id为index的路径
void    BesselUI::removeSomeRecore(int index)
{
	_besselSetData.erase(_besselSetData.begin() + index);
	//整合原来已经映射好了的路径与鱼之间的映射关系
	if (_pathFishMap.find(index) != _pathFishMap.end())
	{
		auto &fishIdMap = _pathFishMap[index];
		//遍历鱼的相关路径,删除与此路径相关的数据
		std::vector<int>::iterator it = fishIdMap.fishIdSet.begin();
		for (; it != fishIdMap.fishIdSet.end(); ++it)
		{
			//查找与此鱼本身绑定着的路径
			auto &fishMap = _fishPathMap[*it];
			removeVector(fishMap.fishPathSet,index);
			if (!fishMap.fishPathSet.size())//如果删除此路径之后就没有了,就删除这条鱼的配置
			{
				_fishPathMap.erase(*it);
			}
		}
		//删除原来的路径与鱼之间的映射关系
		_pathFishMap.erase(index);
	}
	//后面的id向前移动
	std::vector<ControlPointSet>::iterator it = _besselSetData.begin() + index;
	int  id = index;
	for (; it != _besselSetData.end(); ++it, ++id)
	{
		int lastId = it->_curveId;
		it->_curveId = id;
		//将其他路径修改为此路径id
		if (_pathFishMap.find(lastId) != _pathFishMap.end())
		{
			_pathFishMap[id] = _pathFishMap[lastId];
			//将路径与鱼/鱼与路径之间的映射关系修改
			auto &pathMap = _pathFishMap[id];
			std::vector<int>::iterator lut = pathMap.fishIdSet.begin();
			for (; lut != pathMap.fishIdSet.end(); ++lut)
			{
				if (_fishPathMap.find(*lut) != _fishPathMap.end())
				{
					auto &fishMap = _fishPathMap[*lut];
					//检查是否有以前的路径id
					checkVector(fishMap.fishPathSet,lastId,id);//简化vector的替换操作
				}
			}
			//删除当前处理后的路径与鱼之间的映射关系
			_pathFishMap.erase(lastId);
		}
	}
}
void    BesselUI::onButtonClick_RemoveLast(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type)
{
	cocos2d::ui::Button      *buttonRemove = (cocos2d::ui::Button *)_settingLayer->getChildByTag(_TAG_BUTTON_REMOVE_LAST_RECORD_);
	if (type == cocos2d::ui::Widget::TouchEventType::ENDED)
	{
		//检测是否还有记录,修正以前的bug,如果中间预览了以前的曲线导致删除的仍然是最后的曲线
		if (_besselSetData.size() )
		{
			if (_currentEditPathIndex != -1)
				removeSomeRecore(_currentEditPathIndex);
			else
				removeSomeRecore(_besselSetData.size() - 1);
			//删除之后直接跳到末尾
			_currentEditPathIndex = -1;
			//通知UI变化
			Label  *_saveLabel = (Label *)_settingLayer->getChildByTag(_TAG_LABEL_TOTAL_RECORD_);
			char    buffer[64];
			sprintf(buffer,"finished: %d", _besselSetData.size());
			_saveLabel->setString(buffer);
			//如果删除之后再也没有什么记录
			if (!_besselSetData.size())
			{
				buttonRemove->setEnabled(false);
				cocos2d::ui::Button *buttonSaveFile = (cocos2d::ui::Button *)_settingLayer->getChildByTag(_TAG_BUTTON_SAVE_TO_FILE_);
				buttonSaveFile->setEnabled(false);
			}
			_editBox->setText("");
			//恢复原来的场景显示
			_curveNode->restoreCurveNodePosition();
		}
	}
}

void    BesselUI::onButtonClick_SaveRecord(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type)
{
	cocos2d::ui::Button      *buttonRemove = (cocos2d::ui::Button *)_settingLayer->getChildByTag(_TAG_BUTTON_REMOVE_LAST_RECORD_);
	if (type == cocos2d::ui::Widget::TouchEventType::ENDED)
	{
		//增加记录
		buttonRemove->setEnabled(true);
		ControlPointSet		besselSet(_curveNode->getType());
		_curveNode->getControlPoint(besselSet);
		//检测是否是修改中间的部分
		int pathId = _currentEditPathIndex;
		if (_currentEditPathIndex != -1)
		{
			besselSet.setId(_currentEditPathIndex);
			_besselSetData[_currentEditPathIndex] = besselSet;
		}
		else
		{
			//设置id
			besselSet.setId(_besselSetData.size());
			_besselSetData.push_back(besselSet);
			pathId = _besselSetData.size()-1;
		}
		//将当前的路径和鱼的关联写入到数据结构中
		std::vector<int>::iterator  it = _currentSelectFishIds.begin();
		for (; it != _currentSelectFishIds.end(); ++it)
		{
			if (_fishPathMap.find(*it) != _fishPathMap.end())
			{
				auto &fishPath = _fishPathMap[*it];
				//检查是否重复了
				if( !checkVector(fishPath.fishPathSet,pathId))
				fishPath.fishPathSet.push_back(pathId);
			}
			else
			{
				FishPathMap fishMap;
				fishMap.fishPathSet.push_back(pathId);
				_fishPathMap[*it] = fishMap;
			}
		}
		//与该路径绑定的鱼的id也要相应的更新
		if (_pathFishMap.find(pathId) != _pathFishMap.end())
		{
			auto &pathMap = _pathFishMap[pathId];
			for (std::vector<int>::iterator it = _currentSelectFishIds.begin(); it != _currentSelectFishIds.end(); ++it)
			{
				if(!checkVector(pathMap.fishIdSet,*it))
					pathMap.fishIdSet.push_back(*it);
			}
		}
		else
		{
			FishIdMap fishIdMap;
			for (std::vector<int>::iterator it = _currentSelectFishIds.begin(); it != _currentSelectFishIds.end(); ++it)
			{
				fishIdMap.fishIdSet.push_back(*it);
			}
			_pathFishMap[pathId] = fishIdMap;
		}
		//通知UI变化
		Label     *_totalSaveLabel = (Label *)_settingLayer->getChildByTag(_TAG_LABEL_TOTAL_RECORD_);
		char buffer[64];
		sprintf(buffer,"finished: %d", _besselSetData.size());
		_totalSaveLabel->setString(buffer);
		//防止点击过于频繁
		cocos2d::ui::Button *buttonSave = (cocos2d::ui::Button *)pSender;
		buttonSave->setEnabled(false);
		buttonSave->runAction(cocos2d::Sequence::create(
			cocos2d::DelayTime::create(5.0f),
			cocos2d::CallFunc::create([=]() {
			buttonSave->setEnabled(true);
		}),
			NULL));
		cocos2d::ui::Button *buttonSaveFile = (cocos2d::ui::Button *)_settingLayer->getChildByTag(_TAG_BUTTON_SAVE_TO_FILE_);
		buttonSaveFile->setEnabled(true);
	}
}
//这是所有的按钮功能中的重量级功能
void    BesselUI::onButtonClick_SaveToFile(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type)
{
	if (type != cocos2d::ui::Widget::TouchEventType::ENDED)
		return;
	//检测是否有记录
	if (_besselSetData.size() <= 0)
		return;
	cocos2d::ui::Button *buttonSaveFile = (cocos2d::ui::Button *)_settingLayer->getChildByTag(_TAG_BUTTON_SAVE_TO_FILE_);
	buttonSaveFile->setEnabled(false);
	writeRecordToFile();
	saveFishMap();
	buttonSaveFile->runAction(
		cocos2d::Sequence::create(
			cocos2d::DelayTime::create(10.0f),
			cocos2d::CallFunc::create([=]() {
			buttonSaveFile->setEnabled(true);
			}),
			NULL
		)
	);
}

//这是所有的按钮功能中的重量级功能
void    BesselUI::onButtonClick_SaveParsed(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type)
{
    if (type != cocos2d::ui::Widget::TouchEventType::ENDED)
        return;
    //检测是否有记录
    if (_besselSetData.size() <= 0)
        return;
    cocos2d::ui::Button *buttonSaveFile = (cocos2d::ui::Button *)_settingLayer->getChildByTag(_TAG_BUTTON_SAVE_PARSED_);
    buttonSaveFile->setEnabled(false);

    buttonSaveFile->runAction(
                              cocos2d::Sequence::create(
                                                        cocos2d::DelayTime::create(10.0f),
                                                        cocos2d::CallFunc::create([=]() {
                                  buttonSaveFile->setEnabled(true);
                              }),
                                                        NULL
                                                        )
                              );
    
    std::string    recordSet;
    std::string    record;

    recordSet.append("<?xml version=\"1.0\"?>\n");
    recordSet.append("<FishPath>\n");
    for (int j = 0; j < _besselSetData.size(); ++j)
    {
        _besselSetData.at(j).format(record);
        recordSet.append(record);
    }
    recordSet.append("</FishPath>");
    std::ofstream    targetStream("./Visual_Path.xml",std::ios::out | std::ios::binary);
    targetStream.write(recordSet.c_str(), recordSet.size());
    targetStream.close();
}

//此功能暂时不实现
//目前已经实现了
void    BesselUI::onButtonClick_Preview(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type)
{
	if (type == ui::Widget::TouchEventType::ENDED)
	{
		cocos2d::ui::Button *sender = (cocos2d::ui::Button *)pSender;
		//sender->setEnabled(false);
//
		_curveNode->previewCurive([=]() {
			sender->setEnabled(true);
		});
	}
}
//鱼群设置
void BesselUI::onButtonClick_FishMap(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type)
{
	if (type == ui::Widget::TouchEventType::ENDED)
	{
		LayerDialog *layer = LayerDialog::createLayerDialog(_fishVisualStatic, _currentSelectFishIds);
		layer->setCameraMask((short)CameraFlag::DEFAULT, true);
		layer->setTag(_TAG_LAYER_DIALOG_);
		this->addChild(layer, 101);
		//隐藏按钮操作面板
		const float     layerWidth = 240;
		auto &winSize = Director::getInstance()->getWinSize();
		//如果当前是伸展着的,隐藏按钮操作面板
		cocos2d::ui::Button * directButton = (cocos2d::ui::Button *)_settingLayer->getChildByTag(_TAG_BUTTON_DIRECT_);
		_settingLayer->runAction(
			cocos2d::Sequence::create(cocos2d::MoveBy::create(0.4f,Vec2(240.0f,0.0f)),
			cocos2d::CallFunc::create([=]() {
				directButton->setFlippedX(true);
			}),nullptr));
		//设置layer的参数
		layer->setConfirmCallback([=](std::vector<int> &result) {
			//检测result
			if (result.size())
			{
				_currentSelectFishIds = result;
				auto &fishMap= _fishVisualStatic.find(result[0])->second;
				_curveNode->setPreviewModel(fishMap);
			}
		});
	}
}

//将记录写入到文件中
void   BesselUI::writeRecordToFile()
{
	//如果没有什么记录可写,直接返回
	if (_besselSetData.size() <= 0)
		return;
	//使用C++创建文件
//	const std::string  targetFile = "./Visual_Path.xml";
	//计算大概需要的字节空间需求
	int     needSpace = 0;
	for (int j = 0; j < _besselSetData.size(); ++j)
	{
		needSpace += _besselSetData.at(j).getProbablyCapacity();
	}
	std::string    recordSet;
	std::string    record;
	//
	recordSet.reserve(needSpace+24);
	//首先写入xml文件的开头
	recordSet.append("<?xml version=\"1.0\"?>\n");
	recordSet.append("<FishPath>\n");
	for (int j = 0; j < _besselSetData.size(); ++j)
	{
		_besselSetData.at(j).format(record);
		recordSet.append(record);
	}
	recordSet.append("</FishPath>");
	std::ofstream    targetStream("./Visual_Path.xml",std::ios::out | std::ios::binary);
	targetStream.write(recordSet.c_str(), recordSet.size());
	targetStream.close();
}
#ifdef __USE_OLD_LOAD_VISUAL_XML__
void BesselUI::loadVisualXml()
{
	const std::string filename = "./Visual_Path.xml";
	std::ifstream  targetStream(filename, std::ios::binary);
	//如果文件打开失败
	if (!targetStream.is_open())
	{
		return;
	}
	targetStream.close();
	auto   &winSize = cocos2d::Director::getInstance()->getWinSize();
	const  float halfWidth = winSize.width / 2.0f;
	const  float halfHeight = winSize.height / 2.0f;
	const  float   zPositive = winSize.height / 1.1566f;
	//Z轴的总长度
	const float    nearPlane = 0.1f;
	const float    farPlane = zPositive + winSize.height / 2.0f + 400;
	const  float   zAxis = farPlane - nearPlane;
	int      visualId = 0;

	//否则读取所有的文件
	custom::XMLParser* doc = custom::XMLParser::create();
	ValueMap valueMap = doc->parseXML(filename);
	Value& temp = valueMap["FishPath"];
	//为了程序健壮,必须加上的错误处理代码
	if (temp.getType() != cocos2d::Value::Type::MAP)
		return;
	Value& TPS = temp.asValueMap()["Path"];
	if (TPS.getType() == cocos2d::Value::Type::VECTOR)
	{
		for (Value& _v : TPS.asValueVector())
		{
			ValueMap v = _v.asValueMap();
			float weight = v["weight"].asFloat();
			CurveType type = (CurveType)v["Type"].asInt();
			if (weight == 0) { weight = 0.5; }
			std::vector<CubicBezierRoute::PointInfo>   container;
			container.reserve(6);
			if (type == CurveType::CurveType_Bessel)//贝塞尔曲线
			{
				for (Value &_vv : v["Position"].asValueVector())
				{
					ValueMap &vv = _vv.asValueMap();
					const float x = vv["x"].asFloat() - 0.5f;
					const float y = vv["y"].asFloat() - 0.5f;
					const float z = vv["z"].asFloat() * zAxis + nearPlane - zPositive;
					float speedCoef = vv["speedCoef"].asFloat();
					speedCoef = speedCoef == 0.0 ? 1.0 : speedCoef;
					//还原数据
					CubicBezierRoute::PointInfo info;
					info.position = Vec3(x * 2.0f  * halfWidth, y*2.0f * halfHeight, -z);
					info.speedCoef = speedCoef;

					container.push_back(info);
				}
			}
			else if (type == CurveType::CurveType_Spiral)//螺旋线
			{
				for (Value &_vv : v["Position"].asValueVector())
				{
					ValueMap &vv = _vv.asValueMap();
					const float x = vv["x"].asFloat();
					const float y = vv["y"].asFloat();
					const float z = vv["z"].asFloat();
					float speedCoef = vv["speedCoef"].asFloat();
					speedCoef = speedCoef == 0.0 ? 1.0 : speedCoef;
					//还原数据
					CubicBezierRoute::PointInfo info;
					info.position = Vec3(x, y, z);
					info.speedCoef = speedCoef;

					container.push_back(info);
				}
				//更正中心坐标点
				container[1].position.x -= halfWidth;
				container[1].position.y -= halfHeight;
			}
			ControlPointSet   _controlPointSet(type, container);
			_controlPointSet.setId(visualId);
			_controlPointSet.weight = weight;
			_besselSetData.push_back(_controlPointSet);
			++visualId;
		}
	}
	else if (temp.getType() == cocos2d::Value::Type::MAP)
	{
		ValueMap  &secondaryMap = TPS.asValueMap();
		float weight = secondaryMap["weight"].asFloat();
		CurveType  type = (CurveType)secondaryMap["Type"].asInt();
		if (weight == 0) { weight = 0.5; }
		std::vector<CubicBezierRoute::PointInfo>   container;
		container.reserve(6);
		if (type == CurveType::CurveType_Bessel)
		{
			for (Value& _v : secondaryMap["Position"].asValueVector())
			{
				ValueMap v = _v.asValueMap();
				ValueMap &vv = _v.asValueMap();
				const float x = vv["x"].asFloat() - 0.5f;
				const float y = vv["y"].asFloat() - 0.5f;
				const float z = vv["z"].asFloat() * zAxis + nearPlane - zPositive;
				float speedCoef = vv["speedCoef"].asFloat();
				speedCoef = speedCoef == 0.0 ? 1.0 : speedCoef;
				//还原数据
				CubicBezierRoute::PointInfo info;
				info.position = Vec3(x * 2.0f  * halfWidth, y*2.0f * halfHeight, -z);
				info.speedCoef = speedCoef;

				container.push_back(info);
			}
		}
		else if (type == CurveType::CurveType_Spiral)
		{
			for (Value& _v : secondaryMap["Position"].asValueVector())
			{
				ValueMap v = _v.asValueMap();
				ValueMap &vv = _v.asValueMap();
				const float x = vv["x"].asFloat();
				const float y = vv["y"].asFloat();
				const float z = vv["z"].asFloat();
				float speedCoef = vv["speedCoef"].asFloat();
				speedCoef = speedCoef == 0.0 ? 1.0 : speedCoef;
				//还原数据
				CubicBezierRoute::PointInfo info;
				info.position = Vec3(x, y, z);
				info.speedCoef = speedCoef;

				container.push_back(info);
			}
			//更正中心坐标点
			container[1].position.x -= halfWidth;
			container[1].position.y -= halfHeight;
		}
		ControlPointSet   _controlPointSet(type, container);
		_controlPointSet.setId(visualId);
		_controlPointSet.weight = weight;
		_besselSetData.push_back(_controlPointSet);
		++visualId;
	}
}
#else
void BesselUI::loadVisualXml()
{
	const std::string filename = "./Visual_Path.xml";
	std::ifstream  targetStream(filename,std::ios::binary);
	//如果文件打开失败
	if (!targetStream.is_open())
	{
		return;
	}
	targetStream.close();
	auto   &winSize = cocos2d::Director::getInstance()->getWinSize();
	const  float halfWidth = winSize.width / 2.0f;
	const  float halfHeight = winSize.height / 2.0f;
	//const  float   zPositive = winSize.height / 1.1566f;
	//Z轴的总长度
	//const float    nearPlane = 0.1f;
	//const float    farPlane = zPositive + winSize.height / 2.0f + 5000;
	//const  float   zAxis = farPlane - nearPlane;
	int      visualId = 0;

	//否则读取所有的文件
	custom::XMLParser* doc = custom::XMLParser::create();
	ValueMap valueMap = doc->parseXML(filename);
	Value& temp = valueMap["FishPath"];
	//为了程序健壮,必须加上的错误处理代码
	if (temp.getType() != cocos2d::Value::Type::MAP)
		return;
	Value& TPS = temp.asValueMap()["Path"];
	if (TPS.getType() == cocos2d::Value::Type::VECTOR)
	{
		for (Value& _v : TPS.asValueVector())
		{
			ValueMap v = _v.asValueMap();
            float weight = v["weight"].asFloat();
			CurveType type = (CurveType)v["Type"].asInt();
            if(weight == 0) {weight = 0.5;}
            std::vector<CubicBezierRoute::PointInfo>   container;
			container.reserve(6);
			if (type == CurveType::CurveType_Bessel)//贝塞尔曲线
			{
				for (Value &_vv : v["Position"].asValueVector())
				{
					ValueMap &vv = _vv.asValueMap();
					const float x = vv["x"].asFloat() ;
					const float y = vv["y"].asFloat() ;
					const float z = vv["z"].asFloat();
                    float speedCoef = vv["speedCoef"].asFloat();
                    speedCoef = speedCoef == 0.0 ? 1.0 : speedCoef;
					//还原数据
                    CubicBezierRoute::PointInfo info;
                    info.position = Vec3(x , y, z);
                    info.speedCoef = speedCoef;
					info.aniIndex = vv["actionIndex"].asInt();
					info.aniDistance = vv["distance"].asFloat();
                    
					container.push_back(info);
				}
			}
			else if(type == CurveType::CurveType_Spiral)//螺旋线
			{
				for (Value &_vv : v["Position"].asValueVector())
				{
					ValueMap &vv = _vv.asValueMap();
					const float x = vv["x"].asFloat();
					const float y = vv["y"].asFloat();
					const float z = vv["z"].asFloat();
                    float speedCoef = vv["speedCoef"].asFloat();
                    speedCoef = speedCoef == 0.0 ? 1.0 : speedCoef;
					//还原数据
                    CubicBezierRoute::PointInfo info;
                    info.position = Vec3(x , y, z);
                    info.speedCoef = speedCoef;
                    
                    container.push_back(info);
				}
				//更正中心坐标点
				container[1].position.x -= halfWidth;
				container[1].position.y -= halfHeight;
			}
			ControlPointSet   _controlPointSet(type ,container);
            _controlPointSet.setId(visualId);
            _controlPointSet.weight = weight;
			_besselSetData.push_back(_controlPointSet);
			++visualId;
		}
	}
	else if (temp.getType() == cocos2d::Value::Type::MAP)
	{
		ValueMap  &secondaryMap = TPS.asValueMap();
        float weight = secondaryMap["weight"].asFloat();
		CurveType  type = (CurveType)secondaryMap["Type"].asInt();
        if(weight == 0) {weight = 0.5;}
		std::vector<CubicBezierRoute::PointInfo>   container;
		container.reserve(6);
		if (type == CurveType::CurveType_Bessel)
		{
			for (Value& _v : secondaryMap["Position"].asValueVector())
			{
				ValueMap v = _v.asValueMap();
				ValueMap &vv = _v.asValueMap();
				const float x = vv["x"].asFloat() ;
				const float y = vv["y"].asFloat() ;
				const float z = vv["z"].asFloat()  ;
                float speedCoef = vv["speedCoef"].asFloat();
                speedCoef = speedCoef == 0.0 ? 1.0 : speedCoef;
				//还原数据
                CubicBezierRoute::PointInfo info;
                info.position = Vec3(x , y, z);
                info.speedCoef = speedCoef;
				info.aniIndex = vv["actionIndex"].asInt();
				info.aniDistance = vv["distance"].asFloat();
                
                container.push_back(info);
			}
		}
		else if (type == CurveType::CurveType_Spiral)
		{
			for (Value& _v : secondaryMap["Position"].asValueVector())
			{
				ValueMap v = _v.asValueMap();
				ValueMap &vv = _v.asValueMap();
				const float x = vv["x"].asFloat();
				const float y = vv["y"].asFloat();
				const float z = vv["z"].asFloat();
                float speedCoef = vv["speedCoef"].asFloat();
                speedCoef = speedCoef == 0.0 ? 1.0 : speedCoef;
				//还原数据
                CubicBezierRoute::PointInfo info;
                info.position = Vec3(x , y, z);
                info.speedCoef = speedCoef;
                
				container.push_back(info);
			}
			//更正中心坐标点
			container[1].position.x -= halfWidth;
			container[1].position.y -= halfHeight;
		}
		ControlPointSet   _controlPointSet(type,container);
		_controlPointSet.setId(visualId);
        _controlPointSet.weight = weight;
		_besselSetData.push_back(_controlPointSet);
		++visualId;
	}
}
#endif


void BesselUI::editBoxEditingDidBegin(cocos2d::ui::EditBox* editBox)
{

}

void BesselUI::editBoxEditingDidEnd(cocos2d::ui::EditBox* editBox)
{
	const std::string &name = editBox->getName();
	if (name == "SpeedSetting")
	{
		std::string content = editBox->getText();
		int speed = 0;
		std::stringstream converter;
		converter << content;
		converter >> speed;

		speed = speed == 0 ? 100 : speed;

		_curveNode->setPreviewSpeed(speed);
	}
	else if (name == "WeightSetting")
	{
		std::string content = editBox->getText();
		float weight = 0.5;
		std::stringstream converter;
		converter << content;
		converter >> weight;


		if (_currentEditPathIndex == -1)
		{
			_besselSetData[_besselSetData.size() - 1].weight = weight;
			_curveNode->setWeight(weight);
		}
		else
		{
			_besselSetData[_currentEditPathIndex].weight = weight;
			_curveNode->setWeight(weight);
		}
	}
	else if (name == "TopRadius")//上半径
	{
		//只能对螺旋曲线有效
		if (_curveNode->getType() == CurveType::CurveType_Spiral)
		{
			SpiralNode *node = (SpiralNode*)_curveNode;
			const char *text = _topRadiusEditBox->getText();
			float radius = strtof(text);
			node->setTopRadius(radius);
			node->updateVertexData(true);
		}
	}
	else if (name == "BottomRadius")
	{
		if (_curveNode->getType() == CurveType::CurveType_Spiral)
		{
			SpiralNode *node = (SpiralNode*)_curveNode;
			const char *text = _bottomRadiusEditBox->getText();
			float radius = strtof(text);
			node->setBottomRadius(radius);
			node->updateVertexData(true);
		}
	}
	else if (name == "nicaicaispeed")
	{
		if (_curveNode->getType() == CurveType::CurveType_Bessel)
		{
			BesselNode *node = (BesselNode*)_curveNode;
			const char *text = _speedEditBox->getText();
			float  speed = strtof(text);
			/////////////////剩下的是贝塞尔曲线控制点速度操作/////////////////
			ControlPoint *controlPoint = node->getSelectControlPoint();
			if (controlPoint != nullptr)//选中的控制点不为空
			{
				controlPoint->_speedCoef = speed;
			}
		}
	}
	else if (name == "RouteGroup")
		setRouteGroup(editBox->getText());
}

void BesselUI::editBoxTextChanged(cocos2d::ui::EditBox* editBox, const std::string& text)
{

}

void BesselUI::editBoxReturn(cocos2d::ui::EditBox* editBox)
{
    if(editBox->getName() == "RouteIndex")
    {
        const char *text = editBox->getText();
        //转换成int,注意对于输入的值是从1-实际的曲线数目,需要转换到实际的索引
        const int number = atoi(text);
        if (number <= 0 || number > _besselSetData.size() || number - 1 == _currentEditPathIndex)
		{
			_editBox->setText("");
			return;
		}
        _currentEditPathIndex = number - 1;
        //检查当前的曲线是否需要更换,并切换当前正在编辑的贝塞尔曲线
		auto &controlPointSet = _besselSetData.at(_currentEditPathIndex);
		changeCurveNode(controlPointSet._type);
        
        //std::vector<Vec3> points;
        //
        //for(int i = 0; i < controlPointSet._realSize; i++)
        //{
        //    points.push_back(controlPointSet._pointsSet[i].position);
        //}
        
		_curveNode->initCurveNodeWithPoints(controlPointSet);
		_curveNode->setWeight(controlPointSet.weight);
		//将该曲线对应的鱼的id也读入
		_currentSelectFishIds.clear();
		_currentSelectFishIds = _pathFishMap[_currentEditPathIndex].fishIdSet;
		if (_currentSelectFishIds.size())
			_curveNode->setPreviewModel(_fishVisualStatic[_currentSelectFishIds[0]]);
		//设置组按钮的相关按钮指示
		if (_curveNode->getType() == CurveType::CurveType_Bessel)//只有贝塞尔曲线才会支持
		{
			cocos2d::ui::RadioButtonGroup *group = (cocos2d::ui::RadioButtonGroup*)_scrollView->getChildByTag(_TAG_RADIO_BUTTON_GROUP_);
			cocos2d::ui::RadioButton *radioButton = (cocos2d::ui::RadioButton*)_scrollView->getChildByTag(controlPointSet._pointsSet.size());
			group->setSelectedButton(radioButton);
		}
        //检测曲线类型处的单选按钮是否需要变化
		ui::RadioButtonGroup *group = (ui::RadioButtonGroup *)_settingLayer->getChildByTag(_TAG_RADIO_BUTTON_GROUP_CURVE_);
		ui::RadioButton  *radioButton = (ui::RadioButton *)_settingLayer->getChildByTag(controlPointSet._type + _TAG_RADIO_BUTTON_CURVE_);
		group->setSelectedButton(radioButton);
		//
        std::stringstream converter;
        converter<<_besselSetData[_currentEditPathIndex].weight;
        
        ((cocos2d::ui::EditBox*)this->getChildByName("WeightSetting"))->setText(converter.str().c_str());
    }
	else if (editBox == _actionIndexEditBox)
	{
		//目前只支持贝塞尔曲线
		if (_curveNode->getType() != CurveType::CurveType_Bessel)
			return;
		BesselNode *node = (BesselNode*)_curveNode;
		ControlPoint *controlPoint = node->getSelectControlPoint();
		//返回的值有可能为空
		if (controlPoint != 0)
		{
			//获取文本字符串
			const char *text = editBox->getText();
			int actionIndex = atoi(text);
			//是否需要切换索引,并且需要判断动画索引是否合法
			if (actionIndex >=0 && actionIndex<node->getFishVisual().fishAniVec.size() && actionIndex != controlPoint->getActionIndex())
			{
				controlPoint->setActionIndex(actionIndex);
				controlPoint->setActionDistance(0);
			}
		}
	}
}
/*
  *
*/
void  BesselUI::setRouteGroup(const char *syntax)
{
	//首先解析文法
	SyntaxParser   parser(syntax);
	//中括号可以和单个词法单元共存
	struct Token  token;
	parser.getToken(token);
	//路径id,因为输入可能存在重复
	std::map<int, int>   pathMap;
	bool                           syntaxError = true;
	while (token.syntaxType != SyntaxType::SyntaxType_None)
	{
		//每一次都假设存在语法错误
		syntaxError = true;
		if (token.syntaxType == SyntaxType::SyntaxType_LeftBracket)//左侧中括号,必须以右中括号收尾
		{
			parser.getToken(token);
			if (token.syntaxType != SyntaxType::SyntaxType_Number)//第一个接壤的必须是数字
				break;
			int  startId = atoi(token.syntax.c_str());
			//中间的词法单元必须是 - 号
			parser.getToken(token);
			if (token.syntaxType != SyntaxType::SyntaxType_Minus)
				break;
			//其后必须是数字
			parser.getToken(token);
			if (token.syntaxType != SyntaxType::SyntaxType_Number)
				break;
			int    endId = atoi(token.syntax.c_str());
			//后面接壤的是右中括号
			parser.getToken(token);
			if (token.syntaxType != SyntaxType::SyntaxType_RightBracket)
				break;
			syntaxError = false;
			//将路径id添加到集合中
			for (int id = startId; id <= endId; ++id)
				pathMap[id] = id;
			//移动到下一个词法单元
			parser.getToken(token);
		}
		else if (token.syntaxType == SyntaxType::SyntaxType_Number)
		{
			//此时直接将数字存入
			int id = atoi(token.syntax.c_str());
			pathMap[id] = id;
			//并且检测后面的词法单元,要么是逗号,要么就是空,要么是中括号
			parser.getToken(token);
			if (token.syntaxType != SyntaxType::SyntaxType_Comma && token.syntaxType != SyntaxType::SyntaxType_None && token.syntaxType!= SyntaxType::SyntaxType_LeftBracket)
				break;
			//如果后面是逗号跳过逗号
			if(token.syntaxType == SyntaxType::SyntaxType_Comma)
				parser.getToken(token);
			syntaxError = false;
		}
	}
	if (!syntaxError && pathMap.size())//如果没有词法错误并且有数据,就将数据写入
	{
		std::vector<ControlPointSet>  routePointVec;
		std::vector<int>                        fishIdVec;
		for (std::map<int, int>::iterator it = pathMap.begin(); it != pathMap.end(); ++it)
		{
			//检测是否越界
			if (it->first >= 0 && it->first < _besselSetData.size())
			{
				routePointVec.push_back(_besselSetData.at(it->first));
				//相关路径的第一条鱼被选中,如果没有相对应的鱼,则直接写入1
				int   fishId = 1;
				if (_pathFishMap.find(it->first) != _pathFishMap.end() && _pathFishMap[it->first].fishIdSet.size())
					fishId = _pathFishMap[it->first].fishIdSet[0];
				fishIdVec.push_back(fishId);
			}
		}
		//如果有数据,则弹出相关UI
		if (routePointVec.size() != 0)
		{
			//删除原来的
			if (_routeGroupNode != nullptr)
				_routeGroupNode->removeFromParent();
			RouteGroup  *routeGroup = RouteGroup::createWithRoute(routePointVec, fishIdVec, _fishVisualStatic);
			this->addChild(routeGroup);
			//routeGroup->setRotationQuat();
			routeGroup->setCameraMask(short(CameraFlag::USER1));
			routeGroup->setRotationQuat(_rotateQua);
			//原来的曲线隐藏
			_curveNode->setVisible(false);
			_routeGroupNode = routeGroup;
		}
	}
	else//弹出提示,输入的内容出现语法错误
	{
		Label  *label = Label::createWithSystemFont("Input Content Has Syntax Error!", "Arial", 16);
		label->setAlignment(TextHAlignment::CENTER);
		auto &winSize = Director::getInstance()->getWinSize();
		label->setPosition(Vec2(winSize.width/2,winSize.height/2));
		this->addChild(label);
		label->runAction(Sequence::create(FadeOut::create(0.5f),RemoveSelf::create(),nullptr));
	}
}

void BesselUI::parseControlPoints()
{
	for (int i = 0; i < _parsedRoutes.size(); i++)
	{
		delete _parsedRoutes[i];
	}

	_parsedRoutes.clear();
	_parsedRoutes.resize(_besselSetData.size());

	for (int i = 0; i < _besselSetData.size(); i++)
	{
		std::vector<cocos2d::Vec3> translatedPoints;
		translatedPoints.resize(_besselSetData[i]._realSize);

		for (int j = 0; j < _besselSetData[i]._realSize; j++)
		{
			//            _real
		}


		CubicBezierRoute* routeInfo = new CubicBezierRoute();
		routeInfo->addPoints(_besselSetData[i]._pointsSet);
//		routeInfo->calculateDistance();

		_parsedRoutes[i] = routeInfo;
	}
}
//////////////////////////四版////////////////////////////
void  BesselUI::loadFishVisualStatic()
{
	std::string fileName = "./FishMap.xml";
	std::ifstream inputStream(fileName, std::ios::binary);
	//如果打开失败
	if (!inputStream.is_open())
	{		
		auto &winSize = cocos2d::Director::getInstance()->getWinSize();
		cocos2d::Label   *labelTip = cocos2d::Label::create("Error,can not open file'FishMap.xml","Arial",32);
		labelTip->setColor(cocos2d::Color3B::RED);
		labelTip->setPosition(Vec2(winSize.width/2.0f,winSize.height/2.0f));
		cocos2d::LayerColor *maskLayer = cocos2d::LayerColor::create(cocos2d::Color4B(128,128,128,128),winSize.width,winSize.height);
		auto *touchListener = cocos2d::EventListenerTouchOneByOne::create();
		touchListener->onTouchBegan = [=](cocos2d::Touch *touch, cocos2d::Event *) {return true; };
		touchListener->onTouchMoved = [=](cocos2d::Touch *touch, cocos2d::Event *) {};
		touchListener->onTouchEnded = [=](cocos2d::Touch *touch, cocos2d::Event *) {};
		touchListener->setSwallowTouches(true);

		this->addChild(maskLayer, 101);
		maskLayer->getEventDispatcher()->addEventListenerWithSceneGraphPriority(touchListener, maskLayer);
		maskLayer->addChild(labelTip);
		maskLayer->setCameraMask((short)CameraFlag::DEFAULT, true);
		return;
	}
	//否则加载文件数据
	inputStream.close();
	//否则读取所有的文件
	custom::XMLParser* doc = custom::XMLParser::create();
	ValueMap valueMap = doc->parseXML(fileName);
	Value& temp = valueMap["FishMap"];
	//为了程序健壮,必须加上的错误处理代码
	if (temp.getType() != cocos2d::Value::Type::MAP)
		return;
	Value& TPS = temp.asValueMap()["Fish"];
	if (TPS.getType() == cocos2d::Value::Type::VECTOR)
	{
		for (Value& v : TPS.asValueVector())
		{
			FishVisual  visualData;
			ValueMap &fishMap = v.asValueMap();
			visualData.id = fishMap["id"].asInt();
			visualData.scale = fishMap["scale"].asFloat();
			visualData.name = fishMap["name"].asString();
			visualData.label = fishMap["label"].asString();
			//加载动画集合
			Value &fishAnimation = fishMap["Animation"];
			if (fishAnimation.getType() == cocos2d::Value::Type::VECTOR)
			{
				for (Value &aV : fishAnimation.asValueVector())
				{
					ValueMap &bV = aV.asValueMap();
					visualData.fishAniVec.push_back(AnimationFrameInfo(bV["from"].asInt(),bV["to"].asInt()));
				}
			}
			else if (fishAnimation.getType() == cocos2d::Value::Type::MAP)
			{
				ValueMap &bv = fishAnimation.asValueMap();
				visualData.fishAniVec.push_back(AnimationFrameInfo(bv["from"].asInt(),bv["to"].asInt()));
			}
			//加入到鱼的资料集合中
			_fishVisualStatic[visualData.id] = visualData;
		}
	}
	else if (temp.getType() == cocos2d::Value::Type::MAP)
	{
		FishVisual  visualData;
		ValueMap fishMap = temp.asValueMap();
		visualData.id = fishMap["id"].asInt();
		visualData.scale = fishMap["scale"].asFloat();
		visualData.name = fishMap["name"].asString();
		visualData.label = fishMap["label"].asString();
		Value &fishAni = fishMap["Animation"];
		if (fishAni.getType() == cocos2d::Value::Type::VECTOR)
		{
			for (Value &aV : fishAni.asValueVector())
			{
				ValueMap &bV = aV.asValueMap();
				visualData.fishAniVec.push_back(AnimationFrameInfo(bV["from"].asInt(),bV["to"].asInt()));
			}
		}
		else if (fishAni.getType() == cocos2d::Value::Type::MAP)
		{
			ValueMap &bV = fishAni.asValueMap();
			visualData.fishAniVec.push_back(AnimationFrameInfo(bV["from"].asInt(),bV["to"].asInt()));
		}
		//加入到鱼的资料集合中
		_fishVisualStatic[visualData.id] = visualData;
	}
}

void BesselUI::saveFishMap()
{
	if (!_fishPathMap.size())//没有什么可写的
		return;
	//格式化相关的数据
	std::map<int, FishPathMap>::iterator it = _fishPathMap.begin();
	std::string buffer;
	buffer.reserve(_fishPathMap.size()*128);
	//文件头
	buffer.append("<?xml version=\"1.0\"?>\n");
	buffer.append("<FishMap>\n");
	for (; it != _fishPathMap.end(); ++it)
	{
		const FishPathMap & fishMap = it->second;
		//每一行的头部标志
		char  record[128];
		sprintf(record, "	<Fish id=\"%d\"",it->first );
		buffer.append(record);
		//和每个鱼相关联的路径的id
		buffer.append(" path=\"");
		//遍历每一个路径
		std::vector<int>::const_iterator lit = fishMap.fishPathSet.cbegin();
		for (;lit != fishMap.fishPathSet.end(); ++lit)
		{
			sprintf(record, "%d,", *lit);
			buffer.append(record);
		}
		//删除最后一个逗号
		buffer.erase(buffer.size()-1);
		buffer.append("\" />\n");
	}
	buffer.append("</FishMap>");
	//写入到文件
	std::ofstream    targetStream("./FishPathMap.xml", std::ios::out | std::ios::binary);
	targetStream.write(buffer.c_str(), buffer.size());
	targetStream.close();
}

void BesselUI::loadFishPathMap()
{
	std::string fileName = "./FishPathMap.xml";
	std::ifstream inputStream(fileName, std::ios::binary);
	//如果打开失败
	if (!inputStream.is_open())
	{
		inputStream.close();
		return;
	}
	//否则读取所有的文件
	custom::XMLParser* doc = custom::XMLParser::create();
	ValueMap valueMap = doc->parseXML(fileName);
	Value& temp = valueMap["FishMap"];
	//为了程序健壮,必须加上的错误处理代码
	if (temp.getType() != cocos2d::Value::Type::MAP)
		return;
	Value& TPS = temp.asValueMap()["Fish"];
	if (TPS.getType() == cocos2d::Value::Type::VECTOR)
	{
		for (Value& v : TPS.asValueVector())
		{
			ValueMap vv = v.asValueMap();
			FishPathMap   pathMap;
			const int id = vv["id"].asInt();
			//将路径的id分解
			std::string pathIds = vv["path"].asString();
			std::string pathId;
			for (int i = 0; i < pathIds.size(); ++i)
			{
				if (pathIds[i] != ',')
					pathId.append(1,(char)pathIds[i]);
				else//写入数据
				{
					pathMap.fishPathSet.push_back(atoi(pathId.c_str()));
					pathId.clear();
				}
			}
			pathMap.fishPathSet.push_back(atoi(pathId.c_str()));
			_fishPathMap[id] = pathMap;
		}
	}
	else if (temp.getType() == cocos2d::Value::Type::MAP)
	{
		FishPathMap   pathMap;
		ValueMap vv = temp.asValueMap();
		const int id = vv["id"].asInt();
		//将路径的id分解
		std::string pathIds = vv["path"].asString();
		std::string pathId;
		for (int i = 0; i < pathIds.size(); ++i)
		{
			if (pathIds[i] != ',')
				pathId.append(1, (char)pathIds[i]);
			else//写入数据
			{
				pathMap.fishPathSet.push_back(atoi(pathId.c_str()));
				pathId.clear();
			}
		}
		pathMap.fishPathSet.push_back(atoi(pathId.c_str()));
		_fishPathMap[id] = pathMap;
	}
	//对生成的资料做反向的统计,以方便以后的删除时的快速查找
	std::map<int, FishPathMap>::iterator it = _fishPathMap.begin();
	for (; it != _fishPathMap.end(); ++it)
	{
		auto &pathVector = it->second.fishPathSet;
		std::vector<int>::iterator lut = pathVector.begin();
		//遍历与此鱼相关的所有的路径
		for (; lut != pathVector.end(); ++lut)
		{
			//检测与相关的路径是否有对应的鱼
			if (_pathFishMap.find(*lut) != _pathFishMap.end())//如果发现关于此路径对应的集合不为空,直接添加
			{
				_pathFishMap[*lut].fishIdSet.push_back(it->first);
			}
			else//否则创建一个新的容器,然后将鱼的id添加进去
			{
				FishIdMap  fishIdMap;
				fishIdMap.fishIdSet.push_back(it->first);
				_pathFishMap[*lut] = fishIdMap;
			}
		}
	}

}
