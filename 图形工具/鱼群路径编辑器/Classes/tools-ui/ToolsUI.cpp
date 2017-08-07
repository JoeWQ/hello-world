/*
  *������ʵ��
  *2017-8-4
  *@Author:xiaohuaxiong
 */
#include "ToolsUI.h"
#include "group/RollingGroup.h"
#include "basic/ChooseDialog.h"
#include "basic/XMLParser.h"
#include<fstream>
USING_NS_CC;
//���̵�����
#define _TAG_KEY_MASK_CTRL_  0x01
#define _TAG_KEY_MASK_ALT_     0x02
//��ť��tag
#define _TAG_BUTTON_SAVE_   0x80
#define _TAG_BUTTON_PREVIEW_ 0x81
//ѡ��Ի���
#define _TAG_CHOOSE_DIALOG_    0x82
//�ļ���
#define _FISH_MAP_FILE_NAME_  "./FishMap.xml"
ToolsUI::ToolsUI() :
	_camera(nullptr)
	,_drawNode(nullptr)
	,_saveButton(nullptr)
	,_previewButton(nullptr)
	,_keyMask(0)
	, _groupRoute(nullptr)
{

}

ToolsUI::~ToolsUI()
{

}

ToolsUI *ToolsUI::create()
{
	ToolsUI * ui = new ToolsUI();
	ui->initLayer();
	ui->autorelease();
	return ui;
}

void    ToolsUI::initLayer()
{
	Layer::init();
	//���������
	auto &winSize = Director::getInstance()->getWinSize();
	float  eyeZ = winSize.height / 1.1566f;
	_camera = Camera::createPerspective(60.0f, winSize.width/winSize.height,0.1f,eyeZ+winSize.height + 400.0f);
	_camera->setPosition3D(Vec3(0,0,eyeZ));
	_camera->lookAt(Vec3(0,0,0),Vec3(0.0f,1.0f,0.0f));
	_camera->setCameraFlag(CameraFlag::USER1);
	this->addChild(_camera);
	//����
	_groupRoute = RollingRoute::create();
	_groupRoute->registerChooseDialogUICallback(CC_CALLBACK_4(ToolsUI::onPopupDialog,this));
	_groupRoute->registerQueryFishInfoCallback(CC_CALLBACK_1(ToolsUI::queryFishInfo,this));
	this->addChild(_groupRoute);
	//������������ת��,��׶��
	_drawNode = DrawNode3D::create();
	this->addChild(_drawNode);
	drawFrustum();
	this->setCameraMask((short)CameraFlag::USER1);
	/*
	  *�㳱����
	 */

	//�����¼�����
	EventListenerTouchOneByOne *eventListener = EventListenerTouchOneByOne::create();
	eventListener->onTouchBegan = CC_CALLBACK_2(ToolsUI::onTouchBegan,this);
	eventListener->onTouchMoved = CC_CALLBACK_2(ToolsUI::onTouchMoved,this);
	eventListener->onTouchEnded = CC_CALLBACK_2(ToolsUI::onTouchEnded,this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(eventListener,this);
	/*
	  *�����¼�
	 */
	EventListenerKeyboard *keyEvent = EventListenerKeyboard::create();
	keyEvent->onKeyPressed = CC_CALLBACK_2(ToolsUI::onKeyPressed,this);
	keyEvent->onKeyReleased = CC_CALLBACK_2(ToolsUI::onKeyReleased,this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(keyEvent,this);
	/*
	  *����Ҽ��¼�
	 */
	EventListenerMouse *mouseEvent = EventListenerMouse::create();
	mouseEvent->onMouseDown = CC_CALLBACK_1(ToolsUI::onMouseClick, this);
	mouseEvent->onMouseMove = CC_CALLBACK_1(ToolsUI::onMouseMoved,this);
	mouseEvent->onMouseUp = CC_CALLBACK_1(ToolsUI::onMouseEnded,this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(mouseEvent,this);
	//
	loadFishInfo();
}

bool  ToolsUI::onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unused_event)
{
	_offsetVec2 = touch->getLocation();
	auto &winSize = Director::getInstance()->getWinSize();
	if (_keyMask & _TAG_KEY_MASK_CTRL_)
	{
		_groupRoute->onTouchBegan(_offsetVec2 - Vec2(winSize.width/2.0f,winSize.height/2.0f),_camera);
	}
	return true;
}

void ToolsUI::onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unused_event)
{
	Vec2 touchPoint = touch->getLocation();
	auto &winSize = Director::getInstance()->getWinSize();
	
	if (_keyMask & _TAG_KEY_MASK_CTRL_)
	{
		//�����ɷ��¼�
		_groupRoute->onTouchMoved(touchPoint-Vec2(winSize.width/2,winSize.height/2),_camera);
	}
	else
	{
		_touchOffsetVec2 += touchPoint - _offsetVec2;
		//���㳡������ת����
		float  yaw = _touchOffsetVec2.x / winSize.width * 57.29578 * 0.6f;
		float  pitch = -_touchOffsetVec2.y / winSize.height * 57.29578 * 0.6f;
		updateLayerMatrix(pitch, yaw);
		//������׶�����ת�Ƕ�
		Vec3 r3d(pitch, yaw, 0);
		_drawNode->setRotation3D(r3d);
		_groupRoute->setRotation3D(r3d);
		_groupRoute->setRotateMatrix(_rotateMatrix);
	}
	_offsetVec2 = touchPoint;
}

void ToolsUI::onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event)
{
	Vec2 touchPoint = touch->getLocation();
	auto &winSize = Director::getInstance()->getWinSize();

	if (_keyMask & _TAG_KEY_MASK_CTRL_)
	{
		//�����ɷ��¼�
		_groupRoute->onTouchEnded(touchPoint - Vec2(winSize.width / 2, winSize.height / 2), _camera);
	}
}

void ToolsUI::updateLayerMatrix(float pitch, float yaw)
{
	_rotateMatrix.setIdentity();
	Mat4 rX, rY;
	Mat4::createRotationX(pitch/57.29578f,&rX);
	Mat4::createRotationY(yaw/57.29578f, &rY);
	_rotateMatrix = rX * rY;
}

void  ToolsUI::onKeyPressed(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event)
{
	if (keyCode == EventKeyboard::KeyCode::KEY_CTRL)
		_keyMask |= _TAG_KEY_MASK_CTRL_;
	else if (keyCode == EventKeyboard::KeyCode::KEY_ALT)
		_keyMask |= _TAG_KEY_MASK_ALT_;
}

void  ToolsUI::onKeyReleased(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event)
{
	if (keyCode == EventKeyboard::KeyCode::KEY_CTRL)
		_keyMask &= ~_TAG_KEY_MASK_CTRL_;
	else if (keyCode == EventKeyboard::KeyCode::KEY_ALT)
		_keyMask &= ~_TAG_KEY_MASK_ALT_;
}

void ToolsUI::drawFrustum()
{
	auto &winSize = Director::getInstance()->getWinSize();
	//X Axis
	_drawNode->drawLine(Vec3(0.0f, 0.0f, 0.0f), Vec3(winSize.width / 2.0f, 0.0f, 0.0f), Color4F(1.0f, 0.0f, 0.0f, 1.0f));
	//Y Axis
	_drawNode->drawLine(Vec3(0.0f, 0.0f, 0.0f), Vec3(0.0f, winSize.height / 2.0f, 0.0f), Color4F(0.0f, 1.0f, 0.0f, 1.0f));
	//Z Axis
	_drawNode->drawLine(Vec3(0.0f, 0.0f, 0.0f), Vec3(0.0f, 0.0f, winSize.height / 1.1566f), Color4F(0.0f, 0.0f, 1.0f, 1.0f));
	//�ռ�����,Ĭ��24*24
	const  int   meshSize = 24;
	const float stepX = winSize.width / meshSize;

	const float zeye = winSize.height / 1.1566f;
	const float startZ = winSize.height / 2.0f;
	const float  finalZ = -winSize.height / 1.1566f;
	const float  zlengthUnit = (finalZ - startZ) / meshSize;
	const float  ylengthUnit = winSize.height / meshSize;
	const float  halfWidth = winSize.width / 2.0f;
	const float  halfHeight = winSize.height / 2.0f;
	//������׶���������Զ���İ˸�����
	const float nearZ = startZ;
	const float farZ = zeye + winSize.height / 2.0f + 400.0f;
	//��Ļ�ĺ��ݱ�
	const float screenFactor = winSize.width / winSize.height;
	const float tanOfValue = tanf(CC_DEGREES_TO_RADIANS(60.0f / 2.0f));
	const float nearHeight = tanOfValue * nearZ;
	const float nearWidth = screenFactor * nearHeight;
	const float farHeight = tanOfValue * farZ;
	const float farWidth = screenFactor * farHeight;
	//��Զƽ�����������
	const Vec3 nearCenter(0.0f, 0.0f, -nearZ);
	const Vec3 farCenter(0.0f, 0.0f, -farZ);
	//��������
	const Vec3 forwardVec(0.0f, 0.0f, -1.0f);
	const Vec3 xVec(1.0f, 0.0f, 0.0f);
	const Vec3 yVec(0.0f, 1.0f, 0.0f);
	//8����׶�����������
	Vec3 frustumCoord[8] = {
		nearCenter - xVec * nearWidth - yVec * nearHeight,nearCenter + xVec * nearWidth - yVec * nearHeight,//(bottom left,bottom right)
		nearCenter - xVec * nearWidth + yVec * nearHeight,nearCenter + xVec * nearWidth + yVec * nearHeight,//(top left,top right)
		farCenter - xVec * farWidth - yVec *farHeight,farCenter + xVec* farWidth - yVec * farHeight,//far bottom left
		farCenter - xVec  * farWidth + yVec  * farHeight,farCenter + xVec *farWidth + yVec * farHeight,//far top left/right
	};
	//��ԭ���Ļ�����,����׶���Z�����ۼ���zeye
	for (int i = 0; i < 8; ++i)
		frustumCoord[i].z += zeye;
	//�·�����
	const Vec3 farStepBottomZ = (frustumCoord[5] - frustumCoord[4]) / meshSize;
	const Vec3 nearStepBottomZ = (frustumCoord[1] - frustumCoord[0]) / meshSize;
	for (int i = 0; i < meshSize + 1; ++i)
		_drawNode->drawLine(frustumCoord[0] + nearStepBottomZ * i, frustumCoord[4] + farStepBottomZ*i, Color4F(1.0f, 0.6f, 0.6f, 1.0f));
	const Vec3 leftStepBottom = (frustumCoord[4] - frustumCoord[0]) / meshSize;
	const Vec3 rightStepBottom = (frustumCoord[5] - frustumCoord[1]) / meshSize;
	for (int j = 0; j < meshSize + 1; ++j)
		_drawNode->drawLine(frustumCoord[0] + leftStepBottom*j, frustumCoord[1] + rightStepBottom*j, Color4F(0.6f, 1.0f, 0.6f, 1.0f));
	//�Ϸ�������
	const Vec3 nearStepTopZ = (frustumCoord[3] - frustumCoord[2]) / meshSize;
	const Vec3 farStepTopZ = (frustumCoord[7] - frustumCoord[6]) / meshSize;
	for (int i = 0; i < meshSize + 1; ++i)
		_drawNode->drawLine(frustumCoord[2] + nearStepTopZ*i, frustumCoord[6] + farStepTopZ*i, Color4F(1.0f, 1.0f, 0.0f, 1.0f));
	const Vec3 leftStepTop = (frustumCoord[6] - frustumCoord[2]) / meshSize;
	const Vec3 rightStepTop = (frustumCoord[7] - frustumCoord[3]) / meshSize;
	for (int j = 0; j < meshSize + 1; ++j)
		_drawNode->drawLine(frustumCoord[2] + leftStepTop*j, frustumCoord[3] + rightStepTop*j, Color4F(1.0f, 0.0f, 1.0f, 1.0f));
	//�������
	const Vec3 leftStepNear = (frustumCoord[2] - frustumCoord[0]) / meshSize;
	const Vec3 leftStepFar = (frustumCoord[6] - frustumCoord[4]) / meshSize;
	for (int i = 0; i < meshSize + 1; ++i)
		_drawNode->drawLine(frustumCoord[0] + leftStepNear*i, frustumCoord[4] + leftStepFar*i, Color4F(1.0f, 0.8f, 0.2f, 1.0f));
	for (int j = 0; j < meshSize + 1; ++j)
		_drawNode->drawLine(frustumCoord[0] + leftStepBottom*j, frustumCoord[2] + leftStepTop*j, Color4F(0.2f, 1.0f, 0.8f, 1.0f));
	//�Ҳ������
	const Vec3 rightStepNear = (frustumCoord[3] - frustumCoord[1]) / meshSize;
	const Vec3 rightStepFar = (frustumCoord[7] - frustumCoord[5]) / meshSize;
	for (int i = 0; i < meshSize + 1; ++i)
		_drawNode->drawLine(frustumCoord[1] + rightStepNear*i, frustumCoord[5] + rightStepFar*i, Color4F(0.782, 0.387, 0.664, 1.0f));
	for (int j = 0; j < meshSize + 1; ++j)
		_drawNode->drawLine(frustumCoord[1] + rightStepBottom*j, frustumCoord[3] + rightStepTop*j, Color4F(0.664f, 0.387f, 0.782f, 1.0f));
}

void ToolsUI::onMouseClick(cocos2d::EventMouse *mouseEvent)
{
	//���ܰ���Ctrl����
	_isResponseMouseEvent = false;
	if (mouseEvent->getMouseButton() == MOUSE_BUTTON_RIGHT && !_keyMask && !this->getChildByTag(_TAG_CHOOSE_DIALOG_))
	{
		Vec2 clickPoint = mouseEvent->getLocation();
		auto &winSize = Director::getInstance()->getWinSize();
		clickPoint.y = winSize.height - clickPoint.y;
		const Vec2 point(clickPoint - Vec2(winSize.width/2,winSize.height/2));
		_groupRoute->onMouseClick(point,_camera);
		_isResponseMouseEvent = true;
		//��ɾ���Ի���
		//Node *chooseDialog = this->getChildByTag(_TAG_CHOOSE_DIALOG_);
		//if (chooseDialog != nullptr)
		//	chooseDialog->removeFromParent();
		////�����Ի���
		//ChooseDialog * dialog = ChooseDialog::create(&_fishInfoMap);
		//dialog->setTag(_TAG_CHOOSE_DIALOG_);
		//this->addChild(dialog,10);
		//dialog->popupDialog(clickPoint);
	}
}

void ToolsUI::onMouseMoved(cocos2d::EventMouse *mouseEvent)
{
	if (_isResponseMouseEvent)
	{
		Vec2 clickPoint = mouseEvent->getLocation();
		auto &winSize = Director::getInstance()->getWinSize();
		clickPoint.y = winSize.height - clickPoint.y;
		const Vec2 point(clickPoint - Vec2(winSize.width / 2, winSize.height / 2));
		_groupRoute->onMouseMoved(point,_camera);
	}
}

void ToolsUI::onMouseEnded(cocos2d::EventMouse *mouseEvent)
{
	if (_isResponseMouseEvent)
	{
		Vec2 clickPoint = mouseEvent->getLocation();
		auto &winSize = Director::getInstance()->getWinSize();
		clickPoint.y = winSize.height - clickPoint.y;
		const Vec2 point(clickPoint - Vec2(winSize.width / 2, winSize.height / 2));
		_groupRoute->onMouseEnded(point,_camera);
	}
}

void ToolsUI::onPopupDialog(GroupType groupType, int param, const cocos2d::Vec3 &xyz, std::function<void(const FishInfo &)> onConfirmCallback)
{
	Node *chooseDialog = this->getChildByTag(_TAG_CHOOSE_DIALOG_);
	if (chooseDialog)
		chooseDialog->removeFromParent();
	ChooseDialog * dialog = ChooseDialog::create(&_fishInfoMap);
	dialog->setTag(_TAG_CHOOSE_DIALOG_);
	dialog->registerConfirmCallback(onConfirmCallback);
	dialog->popupDialog(Vec2(xyz.x,xyz.y));
	this->addChild(dialog,10);
	/*
	  *ͬʱ��������Ҽ��¼�
	 */
}

const FishInfo& ToolsUI::queryFishInfo(int fishId)
{
	return _fishInfoMap[fishId];
}

void ToolsUI::loadFishInfo()
{
	std::string fileName = _FISH_MAP_FILE_NAME_;
	std::ifstream inputStream(fileName, std::ios::binary);
	//�����ʧ��
	if (!inputStream.is_open())
	{
		auto &winSize = cocos2d::Director::getInstance()->getWinSize();
		cocos2d::Label   *labelTip = cocos2d::Label::create("Error,can not open file'FishMap.xml", "Arial", 32);
		labelTip->setColor(cocos2d::Color3B::RED);
		labelTip->setPosition(Vec2(winSize.width / 2.0f, winSize.height / 2.0f));
		cocos2d::LayerColor *maskLayer = cocos2d::LayerColor::create(cocos2d::Color4B(128, 128, 128, 128), winSize.width, winSize.height);
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
			FishInfo  visualData;
			ValueMap fishMap = v.asValueMap();
			visualData.fishId = fishMap["id"].asInt();
			visualData.scale = fishMap["scale"].asFloat();
			visualData.name = fishMap["name"].asString();
			visualData.startFrame = fishMap["from"].asFloat();
			visualData.endFrame = fishMap["to"].asFloat();
			//���뵽������ϼ�����
			_fishInfoMap[visualData.fishId] = visualData;
		}
	}
	else if (temp.getType() == cocos2d::Value::Type::MAP)
	{
		FishInfo  visualData;
		ValueMap fishMap = temp.asValueMap();
		visualData.fishId = fishMap["id"].asInt();
		visualData.scale = fishMap["scale"].asFloat();
		visualData.name = fishMap["name"].asString();
		visualData.startFrame = fishMap["from"].asFloat();
		visualData.endFrame = fishMap["to"].asFloat();
		//���뵽������ϼ�����
		_fishInfoMap[visualData.fishId] = visualData;
	}
}