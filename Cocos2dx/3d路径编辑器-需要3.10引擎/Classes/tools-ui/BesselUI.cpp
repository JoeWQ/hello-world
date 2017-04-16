/*
  *�������������ɹ���
  *2017-3-20
  *@Author:xiaoxiong
 */
#include"BesselUI.h"
#include<fstream>
//#include "extensions/cocos-ext.h"
//#include "ui/CocosGUI.h"
//#include"geometry/Geometry.h"
//��¼��ǰ���Ѿ���ɵı��������߿��Ƶ�����õ���Ŀ
#define  _TAG_LABEL_TOTAL_RECORD_    0x16
//ɾ����һ����¼
#define  _TAG_BUTTON_REMOVE_LAST_RECORD_ 0x17
//���浱ǰ��¼
#define  _TAG_BUTTON_SAVE_CURRENT_RECORD_ 0x18
//�����м�¼д�뵽�ļ�
#define  _TAG_BUTTON_SAVE_TO_FILE_                      0x19
//����Ԥ��
#define  _TAG_BUTTON_PREVIEW_                                 0x20
USING_NS_CC;
////////////////////////////////////////////////////////////////////////////////

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

BesselUI::BesselUI()
{
	_settingLayer = NULL;
	_viewCamera = NULL;
	_keyboardListener = NULL;
	_keyMask = 0;
	_besselSetData.reserve(128);
	_besselSetSize = 0;
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
	_besselNode = BesselNode::createBesselNode();
	this->addChild(_besselNode);
	//����һ���µ������
	auto &winSize = Director::getInstance()->getWinSize();
	const float zeye = winSize.height / 1.1566f;
	_camera = Camera::createPerspective(60.0f, winSize.width/ winSize.height,0.1f,zeye+winSize.height/2.0f+400);
	_camera->setCameraFlag(CameraFlag::USER1);
	_camera->setPosition3D(Vec3(0.0f, 0.0f, zeye));
	_camera->lookAt(Vec3(0.0f,0.0f,0.0),Vec3(0.0f,1.0f,0.0f));
	//������ص�͸�Ӿ���
	_nowZeye = zeye;
	_maxZeye = zeye *1.5f;
	_minZeye = zeye;
	/*
	  *Mesh
	 */
	_axisNode = DrawNode3D::create();
	this->addChild(_axisNode);
	this->drawAxisMesh();
	this->addChild(_camera);
	this->setCameraMask(2);
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
	//schedule update
	schedule(CC_SCHEDULE_SELECTOR(BesselUI::updateCamera, this));
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
		_besselNode->onTouchBegan(OpenGLVec2,_camera);
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
		_besselNode->onTouchMoved(OpenGLVec2,_camera);
	}
	else
	{
		_xyOffset += _nowOffset;
		Mat4  rotateMatrix;
		cocos2d::Quaternion qua;
		this->makeRotateMatrix(_xyOffset, rotateMatrix, qua);
		_besselNode->setRotationQuat(qua);
		_axisNode->setRotationQuat(qua);
		_besselNode->setRotateMatrix(rotateMatrix);
	}
	_originVec2 = touch->getLocation();
}

void BesselUI::onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event)
{
	if (_keyMask & _KEY_CTRL_MASK_)
	{
		auto &winSize = Director::getInstance()->getWinSize();
		const Vec2   OpenGLVec2 = touch->getLocation() - Vec2(winSize.width / 2.0f, winSize.height / 2.0f);
		_besselNode->onTouchEnded(OpenGLVec2,_camera);
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
}
void  BesselUI::onKeyReleased(EventKeyboard::KeyCode keyCode, Event *unused_event)
{
	if (keyCode == EventKeyboard::KeyCode::KEY_CTRL)
	{
		_keyMask &= ~_KEY_CTRL_MASK_;//���Ctrl����
		_besselNode->onCtrlKeyRelease();
	}
	else if(keyCode == EventKeyboard::KeyCode::KEY_W)
	{
		_keyMask &= ~_KEY_W_MASK_;
	}
	else if (keyCode == EventKeyboard::KeyCode::KEY_S)
	{
		_keyMask &= ~_KEY_S_MASK_;
	}
}

void    BesselUI::updateCamera(float dt)
{
	//S��������
	if (_keyMask & _KEY_S_MASK_)
	{
		_nowZeye = _nowZeye + dt * 64.0f;//�ٶ��趨Ϊ24����
		//�ض�
		_nowZeye =fmin(  fmax(_nowZeye,_minZeye),  _maxZeye);
		_camera->setPosition3D(Vec3(0.0f,0.0f,_nowZeye));
		_camera->lookAt(Vec3(0.0f,0.0f,0.0f));
	}
	//������������ͬʱ������
	if (_keyMask & _KEY_W_MASK_)
	{
		_nowZeye = _nowZeye - dt * 64.0f;
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
	_axisNode->drawLine(Vec3(0.0f,0.0f,0.0f),Vec3(winSize.width/2.0f,0.0f,0.0f),Color4F(1.0f,0.0f,0.0f,1.0f));
	//Y Axis
	_axisNode->drawLine(Vec3(0.0f,0.0f,0.0f),Vec3(0.0f,winSize.height/2.0f,0.0f),Color4F(0.0f,1.0f,0.0f,1.0f));
	//Z Axis
	_axisNode->drawLine(Vec3(0.0f, 0.0f, 0.0f), Vec3(0.0f,0.0f,winSize.height/1.1566f),Color4F(0.0f,0.0f,1.0f,1.0f));
	//�ռ�����,Ĭ��24*24
	const  int   meshSize = 24;
	const float stepX = winSize.width / meshSize;

	const float startZ = winSize.height/2.0f;
	const float  finalZ = -winSize.height / 1.1566f;
	const float  zlengthUnit = (finalZ - startZ)/meshSize;
	const float  halfWidth = winSize.width / 2.0f;
	const float  halfHeight = winSize.height / 2.0f;
	for (int i = 0; i < meshSize+1; ++i)
		_axisNode->drawLine(Vec3(i*stepX- halfWidth,-halfHeight +20.0f,startZ),Vec3(i*stepX-halfWidth,-halfHeight+20.0f,finalZ),Color4F(1.0f,0.6f,0.6f,1.0f));
	for (int j = 0; j < meshSize+1; ++j)
		_axisNode->drawLine(Vec3(-halfWidth,-halfHeight+20.0f,startZ+j*zlengthUnit),Vec3(halfWidth,-halfHeight+20.0f,startZ+j*zlengthUnit),Color4F(0.6f,1.0f,0.6f,1.0f));
}

void    BesselUI::loadSettingLayer()
{
	_settingLayer = Layer::create();
	const   float  layerHeight = 400;
	const   float  layerWidth = 240;
	auto &winSize = Director::getInstance()->getWinSize();
	const  float halfWidth = winSize.width / 2.0f;
	const  float halfHeight = winSize.height / 2.0f;
	//������
	Sprite   *bg = Sprite::create("tools-ui/layer-ui/global_bg_big.png",Rect((869.0f -layerWidth)/2.0f,(569.0f -layerHeight)/2.0f,layerWidth,layerHeight));
	bg->setAnchorPoint(Vec2(0.0f,0.0f));
	_settingLayer->addChild(bg,1);
	//����Ҳ����¾��ж���,Ĭ���ǹر��ŵ�
	_settingLayer->setPosition(Vec2(winSize.width,(winSize.height-layerHeight)/2));//(Vec2(halfWidth,(winSize.height-layerHeight)/2.0f - halfHeight));
	//ָʾ��ť
	cocos2d::ui::Button   *directButton = cocos2d::ui::Button::create("tools-ui/direct-button/arrow.png", "");
	directButton->setFlippedX(true);
	directButton->setPosition(Vec2(-18.0f,(layerHeight-56.0f)/2.0f));
	directButton->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_SpreadOrHide,this));
	_settingLayer->addChild(directButton,2);
	//���Ʊ��������߿��Ƶ���Ŀ��UIRadioButton
	cocos2d::ui::RadioButtonGroup     *buttonGroup = cocos2d::ui::RadioButtonGroup::create();
	_settingLayer->addChild(buttonGroup,3);
	//Ŀǰ֧�ֵı��������߿��Ƶ����ĿΪ3,4,5,6
	const float buttonWidth = 48.0f;
	const float buttonStartX = 24.0f + (layerWidth - 4.0f * buttonWidth)/2.0f;
	const float buttonHeight = layerHeight - buttonWidth *1.5f;
	for (int j = 0; j < 4; ++j)
	{
		cocos2d::ui::RadioButton* radioButton = cocos2d::ui::RadioButton::create("tools-ui/layer-ui/radio_button_off.png", "tools-ui/layer-ui/radio_button_on.png");
		radioButton->setPosition(Vec2(buttonStartX + buttonWidth * j,buttonHeight));
		radioButton->setTag(3+j);
		radioButton->addEventListener(CC_CALLBACK_2(BesselUI::onChangeRadioButtonSelect,this));
		buttonGroup->addRadioButton(radioButton);
		_settingLayer->addChild(radioButton,4);
		//label name,���ڿ��Ƶ���Ŀ��˵��
		char buffer[64];
		sprintf(buffer,"%d",3+j);
		Label    *labelName = Label::createWithSystemFont(buffer, "Arial", 14);
		labelName->setPosition(Vec2(buttonStartX+buttonWidth*j,buttonHeight+buttonWidth/1.5f));
		if(j+3 == 4)
			buttonGroup->setSelectedButton(radioButton);

		_settingLayer->addChild(labelName, 4);
	}
	//��¼��ǰ���Ѿ���������ݵ���Ŀ
	Label      *_saveLabel = Label::createWithSystemFont("finished: 0", "Arial", 16);
	_saveLabel->setAnchorPoint(Vec2());
	_saveLabel->setTag(_TAG_LABEL_TOTAL_RECORD_);
	_saveLabel->setPosition(Vec2(4.0f,4.0f));
	_saveLabel->setColor(Color3B(255,0,0));
	_settingLayer->addChild(_saveLabel,5);
	//ɾ����һ��
	const  float     buttonX = layerWidth/2.0f;
	const  float		buttonSeqHeight = 64.0f;//��ť���еĸ߶ȶ�����Ϊ48.0f����
	const  float     buttonY = (layerHeight - buttonStartX - 24.0f - buttonSeqHeight);
	cocos2d::ui::Button      *buttonRemove = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png","tools-ui/direct-button/backtotoppressed.png");
	buttonRemove->setTag(_TAG_BUTTON_REMOVE_LAST_RECORD_);
	Label       *labelName = Label::createWithSystemFont("Remove Record","Arial",14);
	buttonRemove->addChild(labelName);
	buttonRemove->setEnabled(false);
	labelName->setPosition(Vec2(50.0f,15.0f));
	buttonRemove->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_RemoveLast,this));
	buttonRemove->setPosition(Vec2(buttonX,buttonY));
	_settingLayer->addChild(buttonRemove,6);
	//���浱ǰ����
	cocos2d::ui::Button  *buttonSave = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	buttonSave->setTag(_TAG_BUTTON_SAVE_CURRENT_RECORD_);
	buttonSave->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_SaveRecord,this));
	labelName = Label::createWithSystemFont("Save Record", "Arial", 14);
	labelName->setPosition(Vec2(50.0f, 15.0f));
	buttonSave->addChild(labelName);
	buttonSave->setPosition(Vec2(buttonX,buttonY - buttonSeqHeight));
	_settingLayer->addChild(buttonSave,7);
	//���浽�ļ���
	cocos2d::ui::Button *buttonSaveFile = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	buttonSaveFile->setTag(_TAG_BUTTON_SAVE_TO_FILE_);
	buttonSaveFile->setEnabled(false);
	buttonSaveFile->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_SaveToFile,this));
	labelName = Label::createWithSystemFont("Save to File", "Arial", 14);
	labelName->setPosition(Vec2(50.0f, 15.0f));
	buttonSaveFile->addChild(labelName);
	buttonSaveFile->setPosition(Vec2(buttonX,buttonY - 2.0f*buttonSeqHeight));
	_settingLayer->addChild(buttonSaveFile,8);
	//����Ԥ��
	cocos2d::ui::Button *buttonPreview = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	buttonPreview->setTag(_TAG_BUTTON_PREVIEW_);
	buttonPreview->addTouchEventListener(CC_CALLBACK_2(BesselUI::onButtonClick_Preview,this));
	labelName = Label::createWithSystemFont("Preview", "Arial", 14);
	labelName->setPosition(Vec2(50.0f, 15.0f));
	buttonPreview->addChild(labelName);
	buttonPreview->setPosition(Vec2(buttonX,buttonY - 3.0f * buttonSeqHeight));
	_settingLayer->addChild(buttonPreview, 9);

	this->addChild(_settingLayer,2);
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

void      BesselUI::onChangeRadioButtonSelect(cocos2d::ui::RadioButton* radioButton, cocos2d::ui::RadioButton::EventType type)
{
	//���ĳһ����ť��ѡ����
	if (type == cocos2d::ui::RadioButton::EventType::SELECTED)
	{
		int   nowTag = radioButton->getTag();
		//
		_xyOffset = Vec2();
		cocos2d::Quaternion qua;
		Mat4       mat;
		_besselNode->setRotationQuat(qua);
		_besselNode->setRotateMatrix(mat);
		_besselNode->initBesselPoint(nowTag);
		//������ָ�
		_axisNode->setRotationQuat(qua);
	}
}

void    BesselUI::onButtonClick_RemoveLast(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type)
{
	cocos2d::ui::Button      *buttonRemove = (cocos2d::ui::Button *)_settingLayer->getChildByTag(_TAG_BUTTON_REMOVE_LAST_RECORD_);
	if (type == cocos2d::ui::Widget::TouchEventType::ENDED)
	{
		//����Ƿ��м�¼
		if (_besselSetSize>0)
		{
			_besselSetSize -= 1;
			//֪ͨUI�仯
			Label  *_saveLabel = (Label *)_settingLayer->getChildByTag(_TAG_LABEL_TOTAL_RECORD_);
			char    buffer[64];
			sprintf(buffer,"finished: %d",_besselSetSize);
			_saveLabel->setString(buffer);
			//���ɾ��֮����Ҳû��ʲô��¼
			if (!_besselSetSize)
			{
				buttonRemove->setEnabled(false);
				cocos2d::ui::Button *buttonSaveFile = (cocos2d::ui::Button *)_settingLayer->getChildByTag(_TAG_BUTTON_SAVE_TO_FILE_);
				buttonSaveFile->setEnabled(false);
			}
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
		BesselSet		besselSet;
		_besselNode->getBesselPoints(besselSet);
		//����id
		besselSet.setId(_besselSetSize);
		if (_besselSetSize < _besselSetData.size())
			_besselSetData.at(_besselSetSize)=besselSet;
		else
			_besselSetData.push_back(besselSet);
		_besselSetSize += 1;
		//֪ͨUI�仯
		Label     *_totalSaveLabel = (Label *)_settingLayer->getChildByTag(_TAG_LABEL_TOTAL_RECORD_);
		char buffer[64];
		sprintf(buffer,"finished: %d",_besselSetSize);
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
	if (_besselSetSize <= 0)
		return;
	cocos2d::ui::Button *buttonSaveFile = (cocos2d::ui::Button *)_settingLayer->getChildByTag(_TAG_BUTTON_SAVE_TO_FILE_);
	buttonSaveFile->setEnabled(false);
	writeRecordToFile();
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
//�˹�����ʱ��ʵ��
//Ŀǰ�Ѿ�ʵ����
void    BesselUI::onButtonClick_Preview(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type)
{
	if (type == ui::Widget::TouchEventType::ENDED)
	{
		cocos2d::ui::Button *buttonPreview = (cocos2d::ui::Button *)pSender;
		buttonPreview->setEnabled(false);
		std::function<void(float)> callback = [=](float timeCost) {
			buttonPreview->setEnabled(true);
		};
		_besselNode->previewCurive(callback);
	}
}
//����¼д�뵽�ļ���
void   BesselUI::writeRecordToFile()
{
	//���û��ʲô��¼��д,ֱ�ӷ���
	if (_besselSetSize <= 0)
		return;
	//ʹ��C++�����ļ�
//	const std::string  targetFile = "./Visual_Path.xml";
	//��������Ҫ���ֽڿռ�����
	int     needSpace = 0;
	for (int j = 0; j < _besselSetSize; ++j)
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
	for (int j = 0; j < _besselSetSize; ++j)
	{
		_besselSetData.at(j).format(record);
		recordSet.append(record);
	}
	recordSet.append("</FishPath>");
	std::ofstream    targetStream("./Visual_Path.xml",std::ios::out | std::ios::binary);
	targetStream.write(recordSet.c_str(), recordSet.size());
	targetStream.close();
}