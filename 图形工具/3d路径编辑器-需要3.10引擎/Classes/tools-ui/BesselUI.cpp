/*
  *�������������ɹ���
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
//��¼��ǰ���Ѿ���ɵı��������߿��Ƶ�����õ���Ŀ
#define  _TAG_LABEL_TOTAL_RECORD_                    0x80
//ָʾ��ť
#define _TAG_BUTTON_DIRECT_                                 0x81
//�½�һ��·��
#define  _TAG_NEW_PATH_                                           0x82
//ɾ����һ����¼
#define  _TAG_BUTTON_REMOVE_LAST_RECORD_ 0x83
//���浱ǰ��¼
#define  _TAG_BUTTON_SAVE_CURRENT_RECORD_ 0x84
//�����м�¼д�뵽�ļ�
#define  _TAG_BUTTON_SAVE_TO_FILE_                      0x85
//����Ԥ��
#define  _TAG_BUTTON_PREVIEW_                                 0x86
//�����tag
#define _TAG_RADIO_BUTTON_GROUP_                        0x87

#define  _TAG_BUTTON_SAVE_PARSED_                      0x88
//ѡ���������
#define _TAG_BUTTON_FISH_MAP_                               0x89
//�������͵����־
#define _TAG_RADIO_BUTTON_GROUP_CURVE_       0x90
//ScrollView
#define _TAG_SCROLL_VIEW_                                         0x91
#define _TAG_EDIT_BOX_0_                                             0x92
#define _TAG_EDIT_BOX_1_											  0x93
#define _TAG_EDIT_BOX_TOP_RADIUS_                       0x94
#define _TAG_EDIT_BOX_BOTTOM_RADIUS_               0x95
#define _TAG_EDIT_BOX_SPEED_                                    0x96
#define _TAG_EDIT_BOX_ROUTE_GROUP_                    0x97
//�鰴ť����ʼtag
#define _TAG_RADIO_BUTTON_										   3
//�Ի���tag
#define _TAG_LAYER_DIALOG_                                        0x101
USING_NS_CC;
////////////////////////////////////////////////////////////////////////////////
//#define __USE_OLD_LOAD_VISUAL_XML__ //�����Ҫת��ԭ�������ɵ������ļ�,��������
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
	//͸�Ӿ���
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
	//����һ���µ������
	auto &winSize = Director::getInstance()->getWinSize();
	const float zeye = winSize.height / 1.1566f;
	_camera = Camera::createPerspective(60.0f, winSize.width/ winSize.height,0.1f,zeye+winSize.height/2.0f + 5000);
	_camera->setCameraFlag(CameraFlag::USER1);
	_camera->setPosition3D(Vec3(0.0f, 0.0f, zeye));
	_camera->lookAt(Vec3(0.0f,0.0f,0.0),Vec3(0.0f,1.0f,0.0f));
	//������ص�͸�Ӿ���
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
	  *����ͼ
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
	//����ʼ��¼�
	_mouseListener = EventListenerMouse::create();
	_mouseListener->onMouseDown = CC_CALLBACK_1(BesselUI::onMouseClick,this);
	_mouseListener->onMouseMove = CC_CALLBACK_1(BesselUI::onMouseMoved,this);
	_mouseListener->onMouseUp = CC_CALLBACK_1(BesselUI::onMouseReleased,this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(_mouseListener, this);
	//schedule update
	schedule(CC_SCHEDULE_SELECTOR(BesselUI::updateCamera));
	loadFishVisualStatic();
	loadFishPathMap();
	//���õ�һ��
	_curveNode->setPreviewModel(_fishVisualStatic.begin()->second);
}

void  BesselUI::makeRotateMatrix(const Vec2 &xyOffset, Mat4 &rotateMatrix,cocos2d::Quaternion &qua)
{
	//ע��,������ת�Ƕȵ�ʱ��,�Ŷ�x�ǹ�����Y����ת,�Ŷ�Y�ǹ���X����ת
	//���ǣ����xyOffset.y��ֵΪ��,����ζ����X�������������ת
	//����Y����תȴû����������
	const  float offsetX = xyOffset.x * 0.08;
	const  float offsetY =- xyOffset.y * 0.08;
	//���±任��������ŷ���Ǳ任
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
	//���û�а���Ctrl����,����ζ����ת����,�������϶����������Ƶ�
	if (_keyMask & _KEY_CTRL_MASK_)
	{ 
		auto &winSize = Director::getInstance()->getWinSize();
		const Vec2   OpenGLVec2 = touch->getLocation() - Vec2(winSize.width/2.0f,winSize.height/2.0f);
		//���_curveNodeû������
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
		_keyMask |= _KEY_CTRL_MASK_;//����Ctrl��������
	else if (keyCode == EventKeyboard::KeyCode::KEY_W)
		_keyMask |= _KEY_W_MASK_;
	else if (keyCode == EventKeyboard::KeyCode::KEY_S)
		_keyMask |= _KEY_S_MASK_;
	else if (keyCode == EventKeyboard::KeyCode::KEY_ALT)
		_keyMask |= _KEY_ALT_MASK_;
	//����Ƿ���Ctrl+Z��,��ֻ��Ctrl+Z
	if ((_keyMask & _KEY_CTRL_MASK_) && keyCode == EventKeyboard::KeyCode::KEY_Z  && !(_keyMask  - _KEY_CTRL_MASK_))
	{
		_curveNode->onCtrlZPressed();
	}
	//�Ƿ���F5��������
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
		_keyMask &= ~_KEY_CTRL_MASK_;//���Ctrl����
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
  *����¼�
  *
 */
void    BesselUI::onMouseClick(cocos2d::EventMouse *mouseEvent)
{
	_isResponseMouse = false;
	//ֻ����Ӧ�����Ҽ�
	if (mouseEvent->getMouseButton() == MOUSE_BUTTON_RIGHT)
	{
		//���·ַ��¼�
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
		else if(! _keyMask)//����Ƿ���Ե�����һ���Ի����еĺ���
		{
				LayerDialog *dialog = (LayerDialog *)this->getChildByTag(_TAG_LAYER_DIALOG_);
				//���������Ӧ����
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
	//S��������
	if (_keyMask & _KEY_S_MASK_)
	{
		_nowZeye = _nowZeye + dt * speed;//�ٶ��趨Ϊ24����
		//�ض�
		_nowZeye =fmin(  fmax(_nowZeye,_minZeye),  _maxZeye);
		_camera->setPosition3D(Vec3(0.0f,0.0f,_nowZeye));
		_camera->lookAt(Vec3(0.0f,0.0f,0.0f));
	}
	//������������ͬʱ������
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
    
	//�ռ�����,Ĭ��24*24
	const  int   meshSize = 24;
	const float stepX = winSize.width / meshSize;

	const float zeye = winSize.height / 1.1566f;
	const float startZ = winSize.height/2.0f;
	const float  finalZ = -winSize.height / 1.1566f;
	const float  zlengthUnit = (finalZ - startZ)/meshSize;
	const float  ylengthUnit = winSize.height / meshSize;
	const float  halfWidth = winSize.width / 2.0f;
	const float  halfHeight = winSize.height / 2.0f;
	//������׶���������Զ���İ˸�����
	const float nearZ = startZ;
	const float farZ = zeye + winSize.height/2.0f + 5000.0f;
	//��Ļ�ĺ��ݱ�
	const float screenFactor = winSize.width/winSize.height;
	const float tanOfValue = tanf(CC_DEGREES_TO_RADIANS(60.0f/2.0f));
	const float nearHeight = tanOfValue * nearZ;
	const float nearWidth = screenFactor * nearHeight;
	const float farHeight = tanOfValue * farZ;
	const float farWidth = screenFactor * farHeight;
	//��Զƽ�����������
	const Vec3 nearCenter(0.0f,0.0f,-nearZ);
	const Vec3 farCenter(0.0f,0.0f,-farZ);
	//��������
	const Vec3 forwardVec(0.0f,0.0f,-1.0f);
	const Vec3 xVec(1.0f,0.0f,0.0f);
	const Vec3 yVec(0.0f,1.0f,0.0f);
	//8����׶�����������
	 Vec3 frustumCoord[8] = {
		nearCenter - xVec * nearWidth -  yVec * nearHeight,nearCenter + xVec * nearWidth - yVec * nearHeight,//(bottom left,bottom right)
		nearCenter  -xVec * nearWidth + yVec * nearHeight,nearCenter + xVec * nearWidth + yVec * nearHeight,//(top left,top right)
		farCenter    - xVec * farWidth    - yVec *farHeight,farCenter + xVec* farWidth- yVec * farHeight,//far bottom left
		farCenter    -xVec  * farWidth   +yVec  * farHeight,farCenter + xVec *farWidth + yVec * farHeight,//far top left/right
	};
	 //��ԭ���Ļ�����,����׶���Z�����ۼ���zeye
	 for (int i = 0; i < 8; ++i)
		 frustumCoord[i].z += zeye;
	//�·�����
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
	//�Ϸ�������
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
	//�������
	 const Vec3 leftStepNear =( frustumCoord[2]- frustumCoord[0])/meshSize;
	 const Vec3 leftStepFar = (frustumCoord[6]- frustumCoord[4])/meshSize;
	 for (int i = 0; i < meshSize + 1; ++i)
		 _axisNode->drawLine(frustumCoord[0]+leftStepNear*i, frustumCoord[4]+leftStepFar*i,Color4F(1.0f,0.8f,0.2f,0.15));
		//_axisNode->drawLine(Vec3(-halfWidth,-halfHeight+i*ylengthUnit,startZ),Vec3(-halfWidth,-halfHeight+i*ylengthUnit,finalZ),Color4F(1.0f,0.8f,0.2f,1.0f));
	 for (int j = 0; j < meshSize + 1; ++j)
		 _axisNode->drawLine(frustumCoord[0]+leftStepBottom*j, frustumCoord[2]+leftStepTop*j,Color4F(0.2f,1.0f,0.8f,0.15));
		//_axisNode->drawLine(Vec3(-halfWidth,-halfHeight,startZ+zlengthUnit*j),Vec3(-halfWidth,halfHeight,startZ+zlengthUnit*j),Color4F(0.2f,1.0f,0.8f,1.0f));
	//�Ҳ������
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
	//������
	Sprite   *bg = Sprite::create("tools-ui/layer-ui/global_bg_big.png",Rect((864.0f -layerWidth)/2.0f,(569.0f -layerHeight)/2.0f,layerWidth,layerHeight));
	bg->setAnchorPoint(Vec2(0.0f,0.0f));
	_settingLayer->addChild(bg,1);
	//����Ҳ����¾��ж���,Ĭ���ǹر��ŵ�
	_settingLayer->setPosition(Vec2(winSize.width,(winSize.height-layerHeight)/2));//(Vec2(halfWidth,(winSize.height-layerHeight)/2.0f - halfHeight));
	//ָʾ��ť
	cocos2d::ui::Button   *directButton = cocos2d::ui::Button::create("tools-ui/direct-button/arrow.png", "");
	directButton->setTag(_TAG_BUTTON_DIRECT_);
	directButton->setFlippedX(true);
	directButton->setPosition(Vec2(-18.0f,(secondaryHeight -56.0f)/2.0f));
	directButton->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_SpreadOrHide,this));
	_settingLayer->addChild(directButton,2);
	//���������л��������͵�RadioButton
	char buffer[64];
	char *nameTitle[2] = {"Bessel","Spiral"};
	ui::RadioButtonGroup *group = ui::RadioButtonGroup::create();
	group->setTag(_TAG_RADIO_BUTTON_GROUP_CURVE_);
	_settingLayer->addChild(group);
	int   tags[2] = {CurveType::CurveType_Bessel,CurveType::CurveType_Spiral};
	for (int i = 0; i < 2; ++i)//Ŀǰֻ��������������
	{
		cocos2d::ui::RadioButton *radioButton = ui::RadioButton::create("tools-ui/layer-ui/radio_button_off.png", "tools-ui/layer-ui/radio_button_on.png");
		radioButton->setPosition(Vec2(32+ 48*i,layerHeight - 50));
		radioButton->setTag(_TAG_RADIO_BUTTON_CURVE_+ tags[i]);//���ð�ť�ı�־����,Ҳ���������ߵ�����
		radioButton->addEventListener(CC_CALLBACK_2(BesselUI::onChangeRadioButtonSelect_ChangeCurve,this));
		group->addRadioButton(radioButton);
		_settingLayer->addChild(radioButton);
		Label *name = Label::createWithSystemFont(nameTitle[i], "Arial", 14);
		name->setPosition(Vec2(32+48 *i,layerHeight -20));
		_settingLayer->addChild(name);
		if (!  i  )
			group->setSelectedButton(radioButton);
	}
	//����ScrollView
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

	//���Ʊ��������߿��Ƶ���Ŀ��UIRadioButton
	cocos2d::ui::RadioButtonGroup     *buttonGroup = cocos2d::ui::RadioButtonGroup::create();
	buttonGroup->setTag(_TAG_RADIO_BUTTON_GROUP_);
	_scrollView->addChild(buttonGroup, 3);
	//Ŀǰ֧�ֵı��������߿��Ƶ����ĿΪ3,4,5,6,----16
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
		//label name,���ڿ��Ƶ���Ŀ��˵��
		sprintf(buffer,"%d", _TAG_RADIO_BUTTON_ +j);
		Label    *labelName = Label::createWithSystemFont(buffer, "Arial", 14);
		labelName->setPosition(Vec2(16+buttonWidth*j,10+buttonWidth/1.5f));
		if(j+ _TAG_RADIO_BUTTON_ == 4)
			buttonGroup->setSelectedButton(radioButton);

		_scrollView->addChild(labelName, 4);
	}
	//�����������ߵ���ת��������
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
	//��¼��ǰ���Ѿ���������ݵ���Ŀ
	sprintf(buffer, "finished: %d", _besselSetData.size());
	Label      *_saveLabel = Label::createWithSystemFont(buffer, "Arial", 16);
	_saveLabel->setAnchorPoint(Vec2());
	_saveLabel->setTag(_TAG_LABEL_TOTAL_RECORD_);
	_saveLabel->setPosition(Vec2(4.0f,4.0f));
	_saveLabel->setColor(Color3B(255,255,220));
	_settingLayer->addChild(_saveLabel,5);
	//ɾ����һ��
	const  float     buttonX = layerWidth/2.0f;
	const  float		buttonSeqHeight = 56.0f;//��ť���еĸ߶ȶ�����Ϊ48.0f����
    float     buttonY = (secondaryHeight - buttonStartX - 24.0f - buttonSeqHeight);
	//�½�һ��·��
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
	//���浱ǰ����
	cocos2d::ui::Button  *buttonSave = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	buttonSave->setTag(_TAG_BUTTON_SAVE_CURRENT_RECORD_);
	buttonSave->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_SaveRecord,this));
	labelName = Label::createWithSystemFont("Save Record", "Arial", 16);
	labelName->setPosition(Vec2(buttonSize.width / 2.0f, buttonSize.height / 2.0f));
	buttonSave->addChild(labelName);
	buttonSave->setPosition(Vec2(buttonX,buttonY - buttonSeqHeight));
	_settingLayer->addChild(buttonSave,7);
	//���浽�ļ���
	cocos2d::ui::Button *buttonSaveFile = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	buttonSaveFile->setTag(_TAG_BUTTON_SAVE_TO_FILE_);
	buttonSaveFile->setEnabled(_besselSetData.size());
	buttonSaveFile->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_SaveToFile,this));
	labelName = Label::createWithSystemFont("Save to File", "Arial", 16);
	labelName->setPosition(Vec2(buttonSize.width / 2.0f, buttonSize.height / 2.0f));
	buttonSaveFile->addChild(labelName);
	buttonSaveFile->setPosition(Vec2(buttonX,buttonY - 2.0f*buttonSeqHeight));
	_settingLayer->addChild(buttonSaveFile,8);
    
    // �������������
    cocos2d::ui::Button *buttonSaveParsed = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
    buttonSaveParsed->setTag(_TAG_BUTTON_SAVE_PARSED_);
    buttonSaveParsed->setEnabled(_besselSetData.size());
    buttonSaveParsed->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_SaveParsed,this));
    labelName = Label::createWithSystemFont("Save parsed", "Arial", 16);
    labelName->setPosition(Vec2(buttonSize.width / 2.0f, buttonSize.height / 2.0f));
    buttonSaveParsed->addChild(labelName);
    buttonSaveParsed->setPosition(Vec2(buttonX, buttonY - 3.0f*buttonSeqHeight));
    _settingLayer->addChild(buttonSaveParsed,8);
    
    //����Ԥ��
	cocos2d::ui::Button *buttonPreview = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	buttonPreview->setTag(_TAG_BUTTON_PREVIEW_);
	buttonPreview->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_Preview,this));
	labelName = Label::createWithSystemFont("Preview", "Arial", 16);
	labelName->setPosition(Vec2(buttonSize.width / 2.0f, buttonSize.height / 2.0f));
	buttonPreview->addChild(labelName);
	buttonPreview->setPosition(Vec2(buttonX,buttonY - 4.0f * buttonSeqHeight));
	_settingLayer->addChild(buttonPreview, 9);
	//ѡ������Ҫ����
	cocos2d::ui::Button *fishMap = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	fishMap->setTag(_TAG_BUTTON_FISH_MAP_);
	fishMap->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_FishMap,this));
	labelName = Label::createWithSystemFont("Fish Map Setting","Arial",16);
	labelName->setPosition(Vec2(buttonSize.width/2.0f,buttonSize.height/2.0f));
	fishMap->addChild(labelName);
	fishMap->setPosition(Vec2(buttonX,buttonY - 5.0f *buttonSeqHeight));
	_settingLayer->addChild(fishMap, 10);
	//�༭��
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
	//Ԥ�����ߵı༭��,֧�ֶ����ķ�
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
    //�༭�������Ƶ���ٶ�
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
	//�뾶�����
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
	//�°뾶�����
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
	//�༭���ߵĶ�������
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
		//�����ǰ����չ�ŵ�
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
		//��⵱ǰ���������RadioButton����ʾ���
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
			//�����鰴ť����ذ�ťָʾ
			cocos2d::ui::RadioButtonGroup *group = (cocos2d::ui::RadioButtonGroup*)_scrollView->getChildByTag(_TAG_RADIO_BUTTON_GROUP_);
			int index = group->getSelectedButtonIndex();
			cocos2d::ui::RadioButton *radioButton = group->getRadioButtonByIndex(index);
			node->initControlPoint(radioButton->getTag());
			//ͬʱ�������ػ������Ƶ�
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
			//��������������
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
	//��ǰ���Ƶ���ٶ�ϵ��
	sprintf(buffer, "%.2f", node->getSelectControlPoint()->_speedCoef);
	_speedEditBox->setText(buffer);
	//��ǰ���Ƶ�Ķ�������
	sprintf(buffer,"%d",node->getSelectControlPoint()->getActionIndex());
	_actionIndexEditBox->setText(buffer);
}

//�л���������
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
	//���ĳһ����ť��ѡ����
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
		//������ָ�
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
			//����������Ϊ����״̬
			cocos2d::Quaternion qua;
			Mat4       mat;
			_curveNode->setRotationQuat(qua);
			_curveNode->setRotateMatrix(mat);
			_curveNode->restoreCurveNodePosition();
			//������ָ�
			_axisNode->setRotationQuat(qua);
			_editBox->setText("");
			_currentSelectFishIds.clear();
		}
	}
}
//ɾ��idΪindex��·��
void    BesselUI::removeSomeRecore(int index)
{
	_besselSetData.erase(_besselSetData.begin() + index);
	//����ԭ���Ѿ�ӳ����˵�·������֮���ӳ���ϵ
	if (_pathFishMap.find(index) != _pathFishMap.end())
	{
		auto &fishIdMap = _pathFishMap[index];
		//����������·��,ɾ�����·����ص�����
		std::vector<int>::iterator it = fishIdMap.fishIdSet.begin();
		for (; it != fishIdMap.fishIdSet.end(); ++it)
		{
			//��������㱾����ŵ�·��
			auto &fishMap = _fishPathMap[*it];
			removeVector(fishMap.fishPathSet,index);
			if (!fishMap.fishPathSet.size())//���ɾ����·��֮���û����,��ɾ�������������
			{
				_fishPathMap.erase(*it);
			}
		}
		//ɾ��ԭ����·������֮���ӳ���ϵ
		_pathFishMap.erase(index);
	}
	//�����id��ǰ�ƶ�
	std::vector<ControlPointSet>::iterator it = _besselSetData.begin() + index;
	int  id = index;
	for (; it != _besselSetData.end(); ++it, ++id)
	{
		int lastId = it->_curveId;
		it->_curveId = id;
		//������·���޸�Ϊ��·��id
		if (_pathFishMap.find(lastId) != _pathFishMap.end())
		{
			_pathFishMap[id] = _pathFishMap[lastId];
			//��·������/����·��֮���ӳ���ϵ�޸�
			auto &pathMap = _pathFishMap[id];
			std::vector<int>::iterator lut = pathMap.fishIdSet.begin();
			for (; lut != pathMap.fishIdSet.end(); ++lut)
			{
				if (_fishPathMap.find(*lut) != _fishPathMap.end())
				{
					auto &fishMap = _fishPathMap[*lut];
					//����Ƿ�����ǰ��·��id
					checkVector(fishMap.fishPathSet,lastId,id);//��vector���滻����
				}
			}
			//ɾ����ǰ������·������֮���ӳ���ϵ
			_pathFishMap.erase(lastId);
		}
	}
}
void    BesselUI::onButtonClick_RemoveLast(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type)
{
	cocos2d::ui::Button      *buttonRemove = (cocos2d::ui::Button *)_settingLayer->getChildByTag(_TAG_BUTTON_REMOVE_LAST_RECORD_);
	if (type == cocos2d::ui::Widget::TouchEventType::ENDED)
	{
		//����Ƿ��м�¼,������ǰ��bug,����м�Ԥ������ǰ�����ߵ���ɾ������Ȼ����������
		if (_besselSetData.size() )
		{
			if (_currentEditPathIndex != -1)
				removeSomeRecore(_currentEditPathIndex);
			else
				removeSomeRecore(_besselSetData.size() - 1);
			//ɾ��֮��ֱ������ĩβ
			_currentEditPathIndex = -1;
			//֪ͨUI�仯
			Label  *_saveLabel = (Label *)_settingLayer->getChildByTag(_TAG_LABEL_TOTAL_RECORD_);
			char    buffer[64];
			sprintf(buffer,"finished: %d", _besselSetData.size());
			_saveLabel->setString(buffer);
			//���ɾ��֮����Ҳû��ʲô��¼
			if (!_besselSetData.size())
			{
				buttonRemove->setEnabled(false);
				cocos2d::ui::Button *buttonSaveFile = (cocos2d::ui::Button *)_settingLayer->getChildByTag(_TAG_BUTTON_SAVE_TO_FILE_);
				buttonSaveFile->setEnabled(false);
			}
			_editBox->setText("");
			//�ָ�ԭ���ĳ�����ʾ
			_curveNode->restoreCurveNodePosition();
		}
	}
}

void    BesselUI::onButtonClick_SaveRecord(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type)
{
	cocos2d::ui::Button      *buttonRemove = (cocos2d::ui::Button *)_settingLayer->getChildByTag(_TAG_BUTTON_REMOVE_LAST_RECORD_);
	if (type == cocos2d::ui::Widget::TouchEventType::ENDED)
	{
		//���Ӽ�¼
		buttonRemove->setEnabled(true);
		ControlPointSet		besselSet(_curveNode->getType());
		_curveNode->getControlPoint(besselSet);
		//����Ƿ����޸��м�Ĳ���
		int pathId = _currentEditPathIndex;
		if (_currentEditPathIndex != -1)
		{
			besselSet.setId(_currentEditPathIndex);
			_besselSetData[_currentEditPathIndex] = besselSet;
		}
		else
		{
			//����id
			besselSet.setId(_besselSetData.size());
			_besselSetData.push_back(besselSet);
			pathId = _besselSetData.size()-1;
		}
		//����ǰ��·������Ĺ���д�뵽���ݽṹ��
		std::vector<int>::iterator  it = _currentSelectFishIds.begin();
		for (; it != _currentSelectFishIds.end(); ++it)
		{
			if (_fishPathMap.find(*it) != _fishPathMap.end())
			{
				auto &fishPath = _fishPathMap[*it];
				//����Ƿ��ظ���
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
		//���·���󶨵����idҲҪ��Ӧ�ĸ���
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
		//֪ͨUI�仯
		Label     *_totalSaveLabel = (Label *)_settingLayer->getChildByTag(_TAG_LABEL_TOTAL_RECORD_);
		char buffer[64];
		sprintf(buffer,"finished: %d", _besselSetData.size());
		_totalSaveLabel->setString(buffer);
		//��ֹ�������Ƶ��
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
//�������еİ�ť�����е�����������
void    BesselUI::onButtonClick_SaveToFile(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type)
{
	if (type != cocos2d::ui::Widget::TouchEventType::ENDED)
		return;
	//����Ƿ��м�¼
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

//�������еİ�ť�����е�����������
void    BesselUI::onButtonClick_SaveParsed(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type)
{
    if (type != cocos2d::ui::Widget::TouchEventType::ENDED)
        return;
    //����Ƿ��м�¼
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

//�˹�����ʱ��ʵ��
//Ŀǰ�Ѿ�ʵ����
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
//��Ⱥ����
void BesselUI::onButtonClick_FishMap(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type)
{
	if (type == ui::Widget::TouchEventType::ENDED)
	{
		LayerDialog *layer = LayerDialog::createLayerDialog(_fishVisualStatic, _currentSelectFishIds);
		layer->setCameraMask((short)CameraFlag::DEFAULT, true);
		layer->setTag(_TAG_LAYER_DIALOG_);
		this->addChild(layer, 101);
		//���ذ�ť�������
		const float     layerWidth = 240;
		auto &winSize = Director::getInstance()->getWinSize();
		//�����ǰ����չ�ŵ�,���ذ�ť�������
		cocos2d::ui::Button * directButton = (cocos2d::ui::Button *)_settingLayer->getChildByTag(_TAG_BUTTON_DIRECT_);
		_settingLayer->runAction(
			cocos2d::Sequence::create(cocos2d::MoveBy::create(0.4f,Vec2(240.0f,0.0f)),
			cocos2d::CallFunc::create([=]() {
				directButton->setFlippedX(true);
			}),nullptr));
		//����layer�Ĳ���
		layer->setConfirmCallback([=](std::vector<int> &result) {
			//���result
			if (result.size())
			{
				_currentSelectFishIds = result;
				auto &fishMap= _fishVisualStatic.find(result[0])->second;
				_curveNode->setPreviewModel(fishMap);
			}
		});
	}
}

//����¼д�뵽�ļ���
void   BesselUI::writeRecordToFile()
{
	//���û��ʲô��¼��д,ֱ�ӷ���
	if (_besselSetData.size() <= 0)
		return;
	//ʹ��C++�����ļ�
//	const std::string  targetFile = "./Visual_Path.xml";
	//��������Ҫ���ֽڿռ�����
	int     needSpace = 0;
	for (int j = 0; j < _besselSetData.size(); ++j)
	{
		needSpace += _besselSetData.at(j).getProbablyCapacity();
	}
	std::string    recordSet;
	std::string    record;
	//
	recordSet.reserve(needSpace+24);
	//����д��xml�ļ��Ŀ�ͷ
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
	//����ļ���ʧ��
	if (!targetStream.is_open())
	{
		return;
	}
	targetStream.close();
	auto   &winSize = cocos2d::Director::getInstance()->getWinSize();
	const  float halfWidth = winSize.width / 2.0f;
	const  float halfHeight = winSize.height / 2.0f;
	const  float   zPositive = winSize.height / 1.1566f;
	//Z����ܳ���
	const float    nearPlane = 0.1f;
	const float    farPlane = zPositive + winSize.height / 2.0f + 400;
	const  float   zAxis = farPlane - nearPlane;
	int      visualId = 0;

	//�����ȡ���е��ļ�
	custom::XMLParser* doc = custom::XMLParser::create();
	ValueMap valueMap = doc->parseXML(filename);
	Value& temp = valueMap["FishPath"];
	//Ϊ�˳���׳,������ϵĴ��������
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
			if (type == CurveType::CurveType_Bessel)//����������
			{
				for (Value &_vv : v["Position"].asValueVector())
				{
					ValueMap &vv = _vv.asValueMap();
					const float x = vv["x"].asFloat() - 0.5f;
					const float y = vv["y"].asFloat() - 0.5f;
					const float z = vv["z"].asFloat() * zAxis + nearPlane - zPositive;
					float speedCoef = vv["speedCoef"].asFloat();
					speedCoef = speedCoef == 0.0 ? 1.0 : speedCoef;
					//��ԭ����
					CubicBezierRoute::PointInfo info;
					info.position = Vec3(x * 2.0f  * halfWidth, y*2.0f * halfHeight, -z);
					info.speedCoef = speedCoef;

					container.push_back(info);
				}
			}
			else if (type == CurveType::CurveType_Spiral)//������
			{
				for (Value &_vv : v["Position"].asValueVector())
				{
					ValueMap &vv = _vv.asValueMap();
					const float x = vv["x"].asFloat();
					const float y = vv["y"].asFloat();
					const float z = vv["z"].asFloat();
					float speedCoef = vv["speedCoef"].asFloat();
					speedCoef = speedCoef == 0.0 ? 1.0 : speedCoef;
					//��ԭ����
					CubicBezierRoute::PointInfo info;
					info.position = Vec3(x, y, z);
					info.speedCoef = speedCoef;

					container.push_back(info);
				}
				//�������������
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
				//��ԭ����
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
				//��ԭ����
				CubicBezierRoute::PointInfo info;
				info.position = Vec3(x, y, z);
				info.speedCoef = speedCoef;

				container.push_back(info);
			}
			//�������������
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
	//����ļ���ʧ��
	if (!targetStream.is_open())
	{
		return;
	}
	targetStream.close();
	auto   &winSize = cocos2d::Director::getInstance()->getWinSize();
	const  float halfWidth = winSize.width / 2.0f;
	const  float halfHeight = winSize.height / 2.0f;
	//const  float   zPositive = winSize.height / 1.1566f;
	//Z����ܳ���
	//const float    nearPlane = 0.1f;
	//const float    farPlane = zPositive + winSize.height / 2.0f + 5000;
	//const  float   zAxis = farPlane - nearPlane;
	int      visualId = 0;

	//�����ȡ���е��ļ�
	custom::XMLParser* doc = custom::XMLParser::create();
	ValueMap valueMap = doc->parseXML(filename);
	Value& temp = valueMap["FishPath"];
	//Ϊ�˳���׳,������ϵĴ��������
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
			if (type == CurveType::CurveType_Bessel)//����������
			{
				for (Value &_vv : v["Position"].asValueVector())
				{
					ValueMap &vv = _vv.asValueMap();
					const float x = vv["x"].asFloat() ;
					const float y = vv["y"].asFloat() ;
					const float z = vv["z"].asFloat();
                    float speedCoef = vv["speedCoef"].asFloat();
                    speedCoef = speedCoef == 0.0 ? 1.0 : speedCoef;
					//��ԭ����
                    CubicBezierRoute::PointInfo info;
                    info.position = Vec3(x , y, z);
                    info.speedCoef = speedCoef;
					info.aniIndex = vv["actionIndex"].asInt();
					info.aniDistance = vv["distance"].asFloat();
                    
					container.push_back(info);
				}
			}
			else if(type == CurveType::CurveType_Spiral)//������
			{
				for (Value &_vv : v["Position"].asValueVector())
				{
					ValueMap &vv = _vv.asValueMap();
					const float x = vv["x"].asFloat();
					const float y = vv["y"].asFloat();
					const float z = vv["z"].asFloat();
                    float speedCoef = vv["speedCoef"].asFloat();
                    speedCoef = speedCoef == 0.0 ? 1.0 : speedCoef;
					//��ԭ����
                    CubicBezierRoute::PointInfo info;
                    info.position = Vec3(x , y, z);
                    info.speedCoef = speedCoef;
                    
                    container.push_back(info);
				}
				//�������������
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
				//��ԭ����
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
				//��ԭ����
                CubicBezierRoute::PointInfo info;
                info.position = Vec3(x , y, z);
                info.speedCoef = speedCoef;
                
				container.push_back(info);
			}
			//�������������
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
	else if (name == "TopRadius")//�ϰ뾶
	{
		//ֻ�ܶ�����������Ч
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
			/////////////////ʣ�µ��Ǳ��������߿��Ƶ��ٶȲ���/////////////////
			ControlPoint *controlPoint = node->getSelectControlPoint();
			if (controlPoint != nullptr)//ѡ�еĿ��Ƶ㲻Ϊ��
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
        //ת����int,ע����������ֵ�Ǵ�1-ʵ�ʵ�������Ŀ,��Ҫת����ʵ�ʵ�����
        const int number = atoi(text);
        if (number <= 0 || number > _besselSetData.size() || number - 1 == _currentEditPathIndex)
		{
			_editBox->setText("");
			return;
		}
        _currentEditPathIndex = number - 1;
        //��鵱ǰ�������Ƿ���Ҫ����,���л���ǰ���ڱ༭�ı���������
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
		//�������߶�Ӧ�����idҲ����
		_currentSelectFishIds.clear();
		_currentSelectFishIds = _pathFishMap[_currentEditPathIndex].fishIdSet;
		if (_currentSelectFishIds.size())
			_curveNode->setPreviewModel(_fishVisualStatic[_currentSelectFishIds[0]]);
		//�����鰴ť����ذ�ťָʾ
		if (_curveNode->getType() == CurveType::CurveType_Bessel)//ֻ�б��������߲Ż�֧��
		{
			cocos2d::ui::RadioButtonGroup *group = (cocos2d::ui::RadioButtonGroup*)_scrollView->getChildByTag(_TAG_RADIO_BUTTON_GROUP_);
			cocos2d::ui::RadioButton *radioButton = (cocos2d::ui::RadioButton*)_scrollView->getChildByTag(controlPointSet._pointsSet.size());
			group->setSelectedButton(radioButton);
		}
        //����������ʹ��ĵ�ѡ��ť�Ƿ���Ҫ�仯
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
		//Ŀǰֻ֧�ֱ���������
		if (_curveNode->getType() != CurveType::CurveType_Bessel)
			return;
		BesselNode *node = (BesselNode*)_curveNode;
		ControlPoint *controlPoint = node->getSelectControlPoint();
		//���ص�ֵ�п���Ϊ��
		if (controlPoint != 0)
		{
			//��ȡ�ı��ַ���
			const char *text = editBox->getText();
			int actionIndex = atoi(text);
			//�Ƿ���Ҫ�л�����,������Ҫ�ж϶��������Ƿ�Ϸ�
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
	//���Ƚ����ķ�
	SyntaxParser   parser(syntax);
	//�����ſ��Ժ͵����ʷ���Ԫ����
	struct Token  token;
	parser.getToken(token);
	//·��id,��Ϊ������ܴ����ظ�
	std::map<int, int>   pathMap;
	bool                           syntaxError = true;
	while (token.syntaxType != SyntaxType::SyntaxType_None)
	{
		//ÿһ�ζ���������﷨����
		syntaxError = true;
		if (token.syntaxType == SyntaxType::SyntaxType_LeftBracket)//���������,����������������β
		{
			parser.getToken(token);
			if (token.syntaxType != SyntaxType::SyntaxType_Number)//��һ�������ı���������
				break;
			int  startId = atoi(token.syntax.c_str());
			//�м�Ĵʷ���Ԫ������ - ��
			parser.getToken(token);
			if (token.syntaxType != SyntaxType::SyntaxType_Minus)
				break;
			//������������
			parser.getToken(token);
			if (token.syntaxType != SyntaxType::SyntaxType_Number)
				break;
			int    endId = atoi(token.syntax.c_str());
			//�������������������
			parser.getToken(token);
			if (token.syntaxType != SyntaxType::SyntaxType_RightBracket)
				break;
			syntaxError = false;
			//��·��id��ӵ�������
			for (int id = startId; id <= endId; ++id)
				pathMap[id] = id;
			//�ƶ�����һ���ʷ���Ԫ
			parser.getToken(token);
		}
		else if (token.syntaxType == SyntaxType::SyntaxType_Number)
		{
			//��ʱֱ�ӽ����ִ���
			int id = atoi(token.syntax.c_str());
			pathMap[id] = id;
			//���Ҽ�����Ĵʷ���Ԫ,Ҫô�Ƕ���,Ҫô���ǿ�,Ҫô��������
			parser.getToken(token);
			if (token.syntaxType != SyntaxType::SyntaxType_Comma && token.syntaxType != SyntaxType::SyntaxType_None && token.syntaxType!= SyntaxType::SyntaxType_LeftBracket)
				break;
			//��������Ƕ�����������
			if(token.syntaxType == SyntaxType::SyntaxType_Comma)
				parser.getToken(token);
			syntaxError = false;
		}
	}
	if (!syntaxError && pathMap.size())//���û�дʷ�������������,�ͽ�����д��
	{
		std::vector<ControlPointSet>  routePointVec;
		std::vector<int>                        fishIdVec;
		for (std::map<int, int>::iterator it = pathMap.begin(); it != pathMap.end(); ++it)
		{
			//����Ƿ�Խ��
			if (it->first >= 0 && it->first < _besselSetData.size())
			{
				routePointVec.push_back(_besselSetData.at(it->first));
				//���·���ĵ�һ���㱻ѡ��,���û�����Ӧ����,��ֱ��д��1
				int   fishId = 1;
				if (_pathFishMap.find(it->first) != _pathFishMap.end() && _pathFishMap[it->first].fishIdSet.size())
					fishId = _pathFishMap[it->first].fishIdSet[0];
				fishIdVec.push_back(fishId);
			}
		}
		//���������,�򵯳����UI
		if (routePointVec.size() != 0)
		{
			//ɾ��ԭ����
			if (_routeGroupNode != nullptr)
				_routeGroupNode->removeFromParent();
			RouteGroup  *routeGroup = RouteGroup::createWithRoute(routePointVec, fishIdVec, _fishVisualStatic);
			this->addChild(routeGroup);
			//routeGroup->setRotationQuat();
			routeGroup->setCameraMask(short(CameraFlag::USER1));
			routeGroup->setRotationQuat(_rotateQua);
			//ԭ������������
			_curveNode->setVisible(false);
			_routeGroupNode = routeGroup;
		}
	}
	else//������ʾ,��������ݳ����﷨����
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
//////////////////////////�İ�////////////////////////////
void  BesselUI::loadFishVisualStatic()
{
	std::string fileName = "./FishMap.xml";
	std::ifstream inputStream(fileName, std::ios::binary);
	//�����ʧ��
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
	//��������ļ�����
	inputStream.close();
	//�����ȡ���е��ļ�
	custom::XMLParser* doc = custom::XMLParser::create();
	ValueMap valueMap = doc->parseXML(fileName);
	Value& temp = valueMap["FishMap"];
	//Ϊ�˳���׳,������ϵĴ��������
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
			//���ض�������
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
			//���뵽������ϼ�����
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
		//���뵽������ϼ�����
		_fishVisualStatic[visualData.id] = visualData;
	}
}

void BesselUI::saveFishMap()
{
	if (!_fishPathMap.size())//û��ʲô��д��
		return;
	//��ʽ����ص�����
	std::map<int, FishPathMap>::iterator it = _fishPathMap.begin();
	std::string buffer;
	buffer.reserve(_fishPathMap.size()*128);
	//�ļ�ͷ
	buffer.append("<?xml version=\"1.0\"?>\n");
	buffer.append("<FishMap>\n");
	for (; it != _fishPathMap.end(); ++it)
	{
		const FishPathMap & fishMap = it->second;
		//ÿһ�е�ͷ����־
		char  record[128];
		sprintf(record, "	<Fish id=\"%d\"",it->first );
		buffer.append(record);
		//��ÿ�����������·����id
		buffer.append(" path=\"");
		//����ÿһ��·��
		std::vector<int>::const_iterator lit = fishMap.fishPathSet.cbegin();
		for (;lit != fishMap.fishPathSet.end(); ++lit)
		{
			sprintf(record, "%d,", *lit);
			buffer.append(record);
		}
		//ɾ�����һ������
		buffer.erase(buffer.size()-1);
		buffer.append("\" />\n");
	}
	buffer.append("</FishMap>");
	//д�뵽�ļ�
	std::ofstream    targetStream("./FishPathMap.xml", std::ios::out | std::ios::binary);
	targetStream.write(buffer.c_str(), buffer.size());
	targetStream.close();
}

void BesselUI::loadFishPathMap()
{
	std::string fileName = "./FishPathMap.xml";
	std::ifstream inputStream(fileName, std::ios::binary);
	//�����ʧ��
	if (!inputStream.is_open())
	{
		inputStream.close();
		return;
	}
	//�����ȡ���е��ļ�
	custom::XMLParser* doc = custom::XMLParser::create();
	ValueMap valueMap = doc->parseXML(fileName);
	Value& temp = valueMap["FishMap"];
	//Ϊ�˳���׳,������ϵĴ��������
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
			//��·����id�ֽ�
			std::string pathIds = vv["path"].asString();
			std::string pathId;
			for (int i = 0; i < pathIds.size(); ++i)
			{
				if (pathIds[i] != ',')
					pathId.append(1,(char)pathIds[i]);
				else//д������
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
		//��·����id�ֽ�
		std::string pathIds = vv["path"].asString();
		std::string pathId;
		for (int i = 0; i < pathIds.size(); ++i)
		{
			if (pathIds[i] != ',')
				pathId.append(1, (char)pathIds[i]);
			else//д������
			{
				pathMap.fishPathSet.push_back(atoi(pathId.c_str()));
				pathId.clear();
			}
		}
		pathMap.fishPathSet.push_back(atoi(pathId.c_str()));
		_fishPathMap[id] = pathMap;
	}
	//�����ɵ������������ͳ��,�Է����Ժ��ɾ��ʱ�Ŀ��ٲ���
	std::map<int, FishPathMap>::iterator it = _fishPathMap.begin();
	for (; it != _fishPathMap.end(); ++it)
	{
		auto &pathVector = it->second.fishPathSet;
		std::vector<int>::iterator lut = pathVector.begin();
		//�����������ص����е�·��
		for (; lut != pathVector.end(); ++lut)
		{
			//�������ص�·���Ƿ��ж�Ӧ����
			if (_pathFishMap.find(*lut) != _pathFishMap.end())//������ֹ��ڴ�·����Ӧ�ļ��ϲ�Ϊ��,ֱ�����
			{
				_pathFishMap[*lut].fishIdSet.push_back(it->first);
			}
			else//���򴴽�һ���µ�����,Ȼ�����id��ӽ�ȥ
			{
				FishIdMap  fishIdMap;
				fishIdMap.fishIdSet.push_back(it->first);
				_pathFishMap[*lut] = fishIdMap;
			}
		}
	}

}
