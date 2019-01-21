/*
  *选择对话框实现
  *2017-8-5
  *@Author:xiaohuaxiong
 */
#include "ChooseDialog.h"
#include "XMLParser.h"
#include<fstream>

#define _FISH_MAP_FILE_NAME_  "./FishMap.xml"
USING_NS_CC;
ChooseDialog::ChooseDialog(const std::map<int, FishInfo> *fishInfoMap) :
	_fishInfos(fishInfoMap)
	,_onConfirmCallback(nullptr)
	,_scrollView(nullptr)
{

}

ChooseDialog::~ChooseDialog()
{

}

ChooseDialog *ChooseDialog::create(const std::map<int,FishInfo> *fishInfoMap)
{
	ChooseDialog *dialog = new ChooseDialog(fishInfoMap);
	dialog->init();
	dialog->autorelease();
	return dialog;
}

bool ChooseDialog::init()
{
	LayerColor::init();
	//loadFishInfo();
	//注册事件
	EventListenerTouchOneByOne *eventListenr = EventListenerTouchOneByOne::create();
	eventListenr->onTouchBegan = CC_CALLBACK_2(ChooseDialog::onTouchBegan,this);
	eventListenr->onTouchMoved = CC_CALLBACK_2(ChooseDialog::onTouchMoved,this);
	eventListenr->onTouchEnded = CC_CALLBACK_2(ChooseDialog::onTouchEnded,this);
	eventListenr->setSwallowTouches(true);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(eventListenr,this);
	this->setTouchEnabled(true);
	this->setContentSize(Director::getInstance()->getWinSize());
	/*
	  *鼠标右键
	 */
	//EventListenerMouse *mouseEvent = EventListenerMouse::create();
	//mouseEvent->onMouseDown = [=](EventMouse *) {};
	//mouseEvent->onMouseMove = [=](EventMouse *) {};
	//mouseEvent->onMouseUp = [=](EventMouse *) {};
	//_eventDispatcher->addEventListenerWithSceneGraphPriority(mouseEvent, this);
	//创建滚动条
	ui::ImageView  *parentView = ui::ImageView::create("tools-ui/layer-ui/backImageView.png");
	const Size  gridSize= parentView->getContentSize();;//每单元格的尺寸
	const int    heightCount = 5;//竖直的显示数目

	_scrollView = ui::ScrollView::create();
	_scrollView->setBounceEnabled(true);
	_scrollView->setDirection(ui::ScrollView::Direction::VERTICAL);
	_scrollView->setContentSize(cocos2d::Size(gridSize.width*2, gridSize.height*5));
	_scrollView->setScrollBarPositionFromCorner(Vec2(0, 0));
	_scrollView->setScrollBarColor(Color3B::YELLOW);
	_scrollView->setPosition(cocos2d::Vec2());
	_scrollView->setInnerContainerSize(cocos2d::Size(gridSize.width*2,ceil(_fishInfos->size()/2.0f)*gridSize.height));
	_valideSize = Size(gridSize.width*2,gridSize.height*5);
	this->addChild(_scrollView, 5);
	//暂时隐藏,只有当调用Popup函数的时候才会显示出来
	_scrollView->setVisible(false);
	//向ScrollView里面添加组件
	int  index = 0;
	for (std::map<int, FishInfo>::const_iterator it = _fishInfos->cbegin(); it != _fishInfos->cend(); ++it)
	{
		Sprite3D  *sprite = Sprite3D::create("3d/"+it->second.name+"/"+it->second.name+".c3b");
		sprite->setScale(it->second.scale);
		sprite->setTag(it->second.fishId);
		//计算缩放比例,以及对其的方式
		sprite->setPosition3D(Vec3());
		sprite->setRotation3D(Vec3());
		sprite->setScale(it->second.scale);
		sprite->setForce2DQueue(true);//作为2d图像来计算
		//对鱼再次进行缩放
		const cocos2d::AABB &aabb = sprite->getAABB();
		float maxWidth = aabb._max.x - aabb._min.x;
		sprite->setScale(gridSize.width / maxWidth * it->second.scale);

		float   x = gridSize.width  * (index % 2)  + gridSize.width/2;
		float   y =  gridSize.height *(index / 2)  +gridSize.height/2;
		
		ui::ImageView  *parentView = ui::ImageView::create("tools-ui/layer-ui/backImageView.png");
		parentView->setTag(it->first);
		parentView->setPosition(Vec2(x,y));
		sprite->setPosition(Vec2(gridSize.width/2,gridSize.height/2));
		parentView->addChild(sprite);
		_scrollView->addChild(parentView);
		++index;

		parentView->setTouchEnabled(true);
		parentView->addTouchEventListener(CC_CALLBACK_2(ChooseDialog::onImageClick_FishSelect,this));
	}
	_scrollView->jumpToBottom();
	////取消按钮
	//ui::Button  *cancelButton = ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	//cancelButton->setVisible(false);
	//cancelButton->addTouchEventListener(CC_CALLBACK_2(ChooseDialog::onButtonClick_Cancel,this));
	//Label *labelName = Label::createWithSystemFont("Cancel","Arial",16);
	//auto &buttonSize = cancelButton->getContentSize();
	//labelName->setPosition(Vec2(buttonSize.width/2.0f,buttonSize.height/2.0f));
	//cancelButton->addChild(labelName);

	//this->addChild(cancelButton);
	return true;
}

//void ChooseDialog::loadFishInfo()
//{
//	std::string fileName = _FISH_MAP_FILE_NAME_;
//	std::ifstream inputStream(fileName, std::ios::binary);
//	//如果打开失败
//	if (!inputStream.is_open())
//	{
//		auto &winSize = cocos2d::Director::getInstance()->getWinSize();
//		cocos2d::Label   *labelTip = cocos2d::Label::create("Error,can not open file'FishMap.xml", "Arial", 32);
//		labelTip->setColor(cocos2d::Color3B::RED);
//		labelTip->setPosition(Vec2(winSize.width / 2.0f, winSize.height / 2.0f));
//		cocos2d::LayerColor *maskLayer = cocos2d::LayerColor::create(cocos2d::Color4B(128, 128, 128, 128), winSize.width, winSize.height);
//		auto *touchListener = cocos2d::EventListenerTouchOneByOne::create();
//		touchListener->onTouchBegan = [=](cocos2d::Touch *touch, cocos2d::Event *) {return true; };
//		touchListener->onTouchMoved = [=](cocos2d::Touch *touch, cocos2d::Event *) {};
//		touchListener->onTouchEnded = [=](cocos2d::Touch *touch, cocos2d::Event *) {};
//		touchListener->setSwallowTouches(true);
//
//		this->addChild(maskLayer, 101);
//		maskLayer->getEventDispatcher()->addEventListenerWithSceneGraphPriority(touchListener, maskLayer);
//		maskLayer->addChild(labelTip);
//		maskLayer->setCameraMask((short)CameraFlag::DEFAULT, true);
//		return;
//	}
//	//否则加载文件数据
//	inputStream.close();
//	//否则读取所有的文件
//	custom::XMLParser* doc = custom::XMLParser::create();
//	ValueMap valueMap = doc->parseXML(fileName);
//	Value& temp = valueMap["FishMap"];
//	//为了程序健壮,必须加上的错误处理代码
//	if (temp.getType() != cocos2d::Value::Type::MAP)
//		return;
//	Value& TPS = temp.asValueMap()["Fish"];
//	if (TPS.getType() == cocos2d::Value::Type::VECTOR)
//	{
//		for (Value& v : TPS.asValueVector())
//		{
//			FishInfo  visualData;
//			ValueMap fishMap = v.asValueMap();
//			visualData.fishId = fishMap["id"].asInt();
//			visualData.scale = fishMap["scale"].asFloat();
//			visualData.name = fishMap["name"].asString();
//			visualData.startFrame = fishMap["from"].asFloat();
//			visualData.endFrame = fishMap["to"].asFloat();
//			//加入到鱼的资料集合中
//			_fishInfos[visualData.fishId] = visualData;
//		}
//	}
//	else if (temp.getType() == cocos2d::Value::Type::MAP)
//	{
//		FishInfo  visualData;
//		ValueMap fishMap = temp.asValueMap();
//		visualData.fishId = fishMap["id"].asInt();
//		visualData.scale = fishMap["scale"].asFloat();
//		visualData.name = fishMap["name"].asString();
//		visualData.startFrame = fishMap["from"].asFloat();
//		visualData.endFrame = fishMap["to"].asFloat();
//		//加入到鱼的资料集合中
//		_fishInfos[visualData.fishId] = visualData;
//	}
//}

const cocos2d::Size &ChooseDialog::getValideSize()
{
	return _valideSize;
}

void ChooseDialog::onImageClick_FishSelect(cocos2d::Ref *sender, cocos2d::ui::Widget::TouchEventType eventType)
{
	if (eventType == cocos2d::ui::Widget::TouchEventType::ENDED)
	{
		Node *node = (Node*)sender;
		int fishId = node->getTag();
		/*
		  *调用回调函数
		 */
		const FishInfo  &fishInfo = _fishInfos->find(fishId)->second;
		if (_onConfirmCallback)
			_onConfirmCallback(fishInfo);
		this->removeFromParent();
	}
}

void ChooseDialog::registerConfirmCallback(std::function<void(const FishInfo &)> onConfirmCallback)
{
	_onConfirmCallback = onConfirmCallback;
}

void ChooseDialog::onButtonClick_Cancel(cocos2d::Ref *sender, cocos2d::ui::Widget::TouchEventType eventType)
{
	if (eventType == cocos2d::ui::Widget::TouchEventType::ENDED)
	{
		this->removeFromParent();
	}
}

bool ChooseDialog::onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unused_event)
{
	//判断点击的地方是否坐落在有效区域之内
	Vec2 touchPoint = touch->getLocation();
	Vec2 position = _scrollView->getPosition();
	if( touchPoint.x >=position.x && touchPoint.x <= position.x + _valideSize.width
		 && touchPoint.y>=position.y - _valideSize.height && touchPoint.y <= position.y)
	return true;
	this->removeFromParent();
}

void ChooseDialog::onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unused_event)
{

}

void ChooseDialog::onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event)
{

}

void ChooseDialog::popupDialog(const cocos2d::Vec2 &xy)
{
	auto &winSize = Director::getInstance()->getWinSize();
	//计算屏幕位置是否协调
	int x=xy.x;
	int y=xy.y;
	if (xy.x + _valideSize.width > winSize.width)
		x = xy.x - _valideSize.width;
	if (xy.y + _valideSize.height > winSize.height)
		y = winSize.height -  _valideSize.height;
	_scrollView->setPosition(Vec2(x,y));
	_scrollView->setVisible(true);
}