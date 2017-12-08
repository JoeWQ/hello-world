/*
  *��3dģ�͵�չʾ���
  *2017-6-22
 */
#include "LayerDialog.h"
#include<math.h>
using namespace cocos2d;
//��������
#define _KEY_MASK_CTRL_  0x1
#define _KEY_MASK_ALT_    0x02
//����ѡ������
#define _AREA_INVALIDE_INDEX_ -1 //��Ч������
#define _AREA_DISPLAY_INDEX_ 1 //����չʾ����
#define _AREA_LIST_INDEX_         2 //���Ҳ��б�����
//����
#define _AREA_DISPLAY_ROW_    5
#define _AREA_DISPLAY_COULMN_ 5
LayerDialog::LayerDialog(const std::map<int, FishVisual> &fishVisualStatic, std::vector<int> &fishMapVector)
	:_fishVisualStatic(&fishVisualStatic)
	, _currentFishIds(fishMapVector)
	, _displaySize(80, 80)
	, _listSize(80, 80)
	, _displayAreaSize(_displaySize.width*_AREA_DISPLAY_ROW_,_displaySize.height*_AREA_DISPLAY_COULMN_)
	,_listAReaSize(_listSize.width,_listSize.height*_AREA_DISPLAY_ROW_)
	, _currentSprite3D(nullptr)
	,_listSprite3D(nullptr)
	, _labelTips(nullptr)
{
	_touchEventListener = nullptr;	
	_onConfirmCallback = nullptr;
	_onCancelCallback = nullptr;
	_keyMask = 0;
	_clippingDisplayArea = nullptr;
	_displayNode = nullptr;
	_clippingListArea = nullptr;
	_listNode = nullptr;
	_selectAreaIndex = _AREA_INVALIDE_INDEX_;
}

LayerDialog::~LayerDialog()
{
}

void  LayerDialog::setConfirmCallback(std::function<void (std::vector<int> &list)> confirmCallback)
{
	_onConfirmCallback = confirmCallback;
}

void LayerDialog::setCancelCallback(std::function<void ()> cancelCallback)
{
	_onCancelCallback = cancelCallback;
}

LayerDialog *LayerDialog::createLayerDialog(const std::map<int, FishVisual> &fishVisualStatic, std::vector<int> &fishMapVector)
{
	LayerDialog *dialog = new LayerDialog(fishVisualStatic,fishMapVector);
	dialog->initWithFishMap(fishVisualStatic, fishMapVector);
	dialog->autorelease();
	return dialog;
}

void LayerDialog::initWithFishMap(const std::map<int, FishVisual> &fishVisualStatic, std::vector<int> &fishMapVector)
{
	auto &winSize = cocos2d::Director::getInstance()->getWinSize();
	LayerColor::initWithColor(cocos2d::Color4B(128,128,128,128), winSize.width, winSize.height);
	//�¼�����
	_touchEventListener = cocos2d::EventListenerTouchOneByOne::create();
	_touchEventListener->onTouchBegan = CC_CALLBACK_2(LayerDialog::onTouchBegan, this);
	_touchEventListener->onTouchMoved = CC_CALLBACK_2(LayerDialog::onTouchMoved,this);
	_touchEventListener->onTouchEnded = CC_CALLBACK_2(LayerDialog::onTouchEnded,this);
	_touchEventListener->setSwallowTouches(true);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(_touchEventListener, this);
	//�����¼�
	auto *_keyEventListener = cocos2d::EventListenerKeyboard::create();
	_keyEventListener->onKeyPressed = CC_CALLBACK_2(LayerDialog::onKeyPressed,this);
	_keyEventListener->onKeyReleased = CC_CALLBACK_2(LayerDialog::onKeyReleased,this);
	_eventDispatcher->addEventListenerWithSceneGraphPriority(_keyEventListener, this);
	//Layer Size
	auto &layerSize = this->getContentSize();
	//����ȷ�ϰ�ť
	cocos2d::ui::Button  *confirmButton = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	const cocos2d::Size   &buttonSize = confirmButton->getContentSize();
	confirmButton->setPosition(cocos2d::Vec2(layerSize.width - 4*buttonSize.width,buttonSize.height *1.5f));
	confirmButton->addTouchEventListener(CC_CALLBACK_2(LayerDialog::onButtonClick_Confirm,this));
	Label *name = Label::createWithSystemFont("Confirm", "Arial", 16);
	name->setPosition(Vec2(buttonSize.width/2.0f,buttonSize.height/2.0f));
	confirmButton->addChild(name);
	this->addChild(confirmButton,2);
	//ȡ����ť
	cocos2d::ui::Button *cancelButton = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	cancelButton->setPosition(Vec2(layerSize.width -2.0f*buttonSize.width, buttonSize.height*1.5f));
	cancelButton->addTouchEventListener(CC_CALLBACK_2(LayerDialog::onButtonClick_Cancel,this));
	name = Label::createWithSystemFont("Cancel", "Arial", 16);
	name->setPosition(Vec2(buttonSize.width/2.0f,buttonSize.height/2.0f));
	cancelButton->addChild(name);
	this->addChild(cancelButton, 2);
	//ɾ����ť
	_removeButton = cocos2d::ui::Button::create("tools-ui/direct-button/backtotopnormal.png", "tools-ui/direct-button/backtotoppressed.png");
	_removeButton->setPosition(Vec2(layerSize.width - 2.0f*buttonSize.width, buttonSize.height*3.5f));
	_removeButton->addTouchEventListener(CC_CALLBACK_2(LayerDialog::onButtonClick_Remove,this));
	name = Label::createWithSystemFont("Remove", "Arial", 16);
	name->setPosition(Vec2(buttonSize.width/2.0f,buttonSize.height/2.0f));
	_removeButton->addChild(name);
	_removeButton->setEnabled(_currentFishIds.size());
	this->addChild(_removeButton,2);
	//������е�Sprite3D����
	_layerBackground = Sprite::create("tools-ui/layer-ui/global_bg_big.png");
	_layerBackground->setPosition(Vec2(layerSize.width/2.0f,layerSize.height/2.0f));
	this->addChild(_layerBackground);
	//�߿�
	_lineFrameNode = cocos2d::DrawNode::create();
	//������ģ��
	loadDisplayFishMap();
	//�����Ѿ���ȡ��ģ��
	loadListFishMap();
	this->addChild(_lineFrameNode, 4);

	cocos2d::ui::ImageView *image = cocos2d::ui::ImageView::create("");
	_currentFishIds = fishMapVector;
}

bool LayerDialog::onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unuseEvent)
{
	_selectAreaIndex = _AREA_INVALIDE_INDEX_;
	if (_currentSprite3D)//��ǰSprite3Dģ�������˶���
		return true;
	//������ܵĴ�������
	const Vec2 nowToucPoint = touch->getLocation();
	_offsetTouchPoint = nowToucPoint;
	//�Ƿ�����������ʾ������
	const Vec2 &displayPosition = _clippingDisplayArea->getPosition();
	if (nowToucPoint.x >= displayPosition.x && nowToucPoint.x< displayPosition.x + _displayAreaSize.width
		&& nowToucPoint.y>displayPosition.y  && nowToucPoint.y <= displayPosition.y + _displayAreaSize.height)
	{
		_selectAreaIndex = _AREA_DISPLAY_INDEX_;
		Vec2 displayPosition = _clippingDisplayArea->getPosition();
		//���㵱ǰClippingRectangleNode�е������ڵ������
		Vec2 cPosition = _displayNode->getPosition();
		//���㴥������ClippingRectangleNode�ֲ�����ϵ�е������
		Vec2 localPoint(nowToucPoint.x - displayPosition.x, nowToucPoint.y - displayPosition.y);
		//�þֲ���������_displayNode�������
		Vec2 relativePoint(localPoint.x - cPosition.x, localPoint.y - cPosition.y);
		//����Ƿ�����Ctrl����
		if (_keyMask & _KEY_MASK_CTRL_)
		{
			//relativePoint������ڲü������е���������
			int x = relativePoint.x / _displaySize.width;
			int y = -relativePoint.y / _displaySize.height;
			//�Ƿ�ѡ����ĳһ��Sprite3D
			char buffer[128];
			sprintf(buffer,"Sprite3D%d", y*_AREA_DISPLAY_COULMN_ + x);
			_currentSprite3D = (cocos2d::Sprite3D *)_displayNode->getChildByName(buffer);
			if (!_currentSprite3D)//���û��ѡ���κ�һ��Sprite3D,��ʱ�Ϳ���ֱ�ӷ�����
				return true;
			//����,����Sprite3D�����ݴ���
			Vec2 targetPosition = _currentSprite3D->convertToWorldSpace(Vec2());
			int id = _currentSprite3D->getTag();
			auto &fishMap = _fishVisualStatic->find(id)->second;
			//�������еĹ����������
			Sprite3D *model = this->createSprite3DByVisual(fishMap, _displaySize);
			model->setTag(id);
			model->setName(buffer);
			model->setPosition(targetPosition);
			_currentSprite3D = model;

			this->addChild(model,9);
		}
	}
	else
	{
		auto &listPosition = _clippingListArea->getPosition();
		if (nowToucPoint.x >= listPosition.x && nowToucPoint.x <= listPosition.x + _listAReaSize.width
			&& nowToucPoint.y >= listPosition.y && nowToucPoint.y <= listPosition.y + _listAReaSize.height)
		{
			_selectAreaIndex = _AREA_LIST_INDEX_;
			const Vec2 &listPosition = _clippingListArea->getPosition();
			//���б�����֮�ڵ�����ϵ
			Vec2 localPosition(nowToucPoint.x - listPosition.x,nowToucPoint.y -listPosition.y);
			//���б������ڵ������ڵ�����ϵ
			const Vec2 nodePosition = _listNode->getPosition();
			Vec2 relativePoint(localPosition.x -nodePosition.x,localPosition.y - nodePosition.y);
			//ͬʱ����Ƿ���3dģ�����ڲ���
			const int x = relativePoint.x / _listSize.width;
			const int y = -relativePoint.y / _listSize.height;
			if (_keyMask & _KEY_MASK_ALT_)
			{
				//���,ע�����ﲻ��������ǰ���жϷ���
				cocos2d::Vector<Node*> &children = _listNode->getChildren();
				Vector<Node*>::iterator it = children.begin();
				const float halfWidth = _listSize.width / 2.0f;
				const float halfHeight = _listSize.height / 2.0f;
				for (; it != children.end(); ++it)
				{
					Node *target = *it;
					auto &point = target->getPosition();
					if (relativePoint.x > point.x - halfWidth && relativePoint.x <= point.x + halfWidth
						&& relativePoint.y >= point.y - halfHeight && relativePoint.y <= point.y + halfHeight)
					{
						_currentSprite3D = (Sprite3D *)target;
						break;
					}
				}
				if (!_currentSprite3D)
					return true;
				const int fishMapId = _currentSprite3D->getTag();
				auto &fishMap = _fishVisualStatic->find(fishMapId)->second;
				cocos2d::Sprite3D *model = this->createSprite3DByVisual(fishMap, _listSize);
				Vec2    targetPosition = _currentSprite3D->convertToWorldSpace(Vec2());
				model->setPosition(targetPosition);
				model->setTag(fishMapId);
				model->setName(_currentSprite3D->getName());
				this->addChild(model, 9);
				_listSprite3D = _currentSprite3D;
				_currentSprite3D = model;
			}
			//
		}
	}
	_offsetTouchPoint = nowToucPoint;
	return true;
}

void LayerDialog::onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unuseEvent)
{
	const Vec2 nowPoint = touch->getLocation();
	//����Ƿ�������ĳһ������֮��
	if (_selectAreaIndex == _AREA_DISPLAY_INDEX_)//������չʾ����֮��
	{
		//����Ƿ�����Ctrl����
		if (_keyMask & _KEY_MASK_CTRL_)
		{
			if (_currentSprite3D)//�����ǰ�в�����Sprite3D,��ֱ��������ģ����
			{
				Vec2 modelPosition = _currentSprite3D->getPosition();
				_currentSprite3D->setPosition(modelPosition + nowPoint -_offsetTouchPoint);
			}
		}
		else//��������ü�����
		{
			float localNodePosition = _displayNode->getPositionY();
			//����Ƿ��ƶ��ľ������,������ʾģ�͵�����Ữ���ü�����
			int childSize = _displayNode->getChildrenCount();
			float  gridHeight = ceilf(1.0f *childSize / _AREA_DISPLAY_ROW_) * _displaySize.height;
			float afterPosition = localNodePosition + nowPoint.y - _offsetTouchPoint.y;
			if (afterPosition < _displayAreaSize.height)
				afterPosition = _displayAreaSize.height;
			else if (afterPosition > gridHeight )
				afterPosition= gridHeight ;
			_displayNode->setPositionY(afterPosition);
		}
	}
	else if(_selectAreaIndex == _AREA_LIST_INDEX_)//�����б������ڵ��¼�
	{
		//��ⰴ��
		if (_keyMask & _KEY_MASK_ALT_)
		{
			if (_currentSprite3D)
			{
				const Vec2 &nowPosition = _currentSprite3D->getPosition();
				_currentSprite3D->setPosition(nowPosition + nowPoint - _offsetTouchPoint);
			}
		}
		else//�����ƶ�չʾ�б�
		{
			float y = _listNode->getPositionY();
			const int childCount = _listNode->getChildrenCount();
			float  gridHeight = ceilf(1.0f * childCount/_AREA_DISPLAY_ROW_) * _listAReaSize.height;
			float newY = y + nowPoint.y - _offsetTouchPoint.y;
			if (newY < _listAReaSize.height)
				newY = _listAReaSize.height;
			else if (newY > gridHeight)
				newY = gridHeight;
			_listNode->setPositionY(newY);
		}
	}
	_offsetTouchPoint = nowPoint;
}

void LayerDialog::onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unuseEvent)
{
	auto &winSize = Director::getInstance()->getWinSize();
	const Vec2 touchPoint = touch->getLocation();
	//���
	if (_selectAreaIndex == _AREA_DISPLAY_INDEX_)
	{
		//����Ƿ��������б�����֮��
		const Vec2 &listPosition = _clippingListArea->getPosition();
		if (touchPoint.x >= listPosition.x && touchPoint.x <= listPosition.x + _listAReaSize.width
			&& touchPoint.y >= listPosition.y && touchPoint.y <= listPosition.y + _listAReaSize.height)
		{
			if (_currentSprite3D)//�����ʱ���ڲ���3dģ��,��3dģ�ͼ��뵽�б�����֮��,�����ʱ������û�����ģ�͵���Ϣ
			{
				const int fishMapId = _currentSprite3D->getTag();
				//���������Ŀ��,���ͷ���ص�3dģ��
				if(checkVector(_currentFishIds, fishMapId))
				{
					//��_displayNode���ҳ���صľ���
					Sprite3D *targetSprite3D = (Sprite3D*)_displayNode->getChildByName(_currentSprite3D->getName());
					Vec2 targetPosition = targetSprite3D->convertToWorldSpace(Vec2());
					const float duration = (targetPosition - _currentSprite3D->getPosition()).length() / winSize.width* 2.0f;
					_currentSprite3D->runAction(cocos2d::Sequence::create(cocos2d::MoveTo::create(duration, targetPosition), cocos2d::CallFunc::create([=]()
					{
						_currentSprite3D->removeFromParentAndCleanup(true);
						_currentSprite3D = nullptr;
					}), nullptr));
				}
				else//����,��ģ����ӵ��б���
				{
					_currentFishIds.push_back(fishMapId);
					auto &fishMap = _fishVisualStatic->find(fishMapId)->second;
					//�������еĹ����������
					Sprite3D *model = this->createSprite3DByVisual(fishMap,_listSize);
					int childCount = _listNode->getChildrenCount();
					model->setPosition(Vec2(_listSize.width/2.0f,-(childCount*_listSize.height+_listSize.height/2.0f)));
					model->setTag(fishMapId);
					model->setName(_currentSprite3D->getName());
					_listNode->addChild(model);
					//ͬʱɾ����ԭ����
					_currentSprite3D->removeFromParentAndCleanup(true);
					_currentSprite3D = nullptr;
					_removeButton->setEnabled(true);
				}
			}
		}
		else//����������б�����֮��
		{
			if (_currentSprite3D)//�����ʱ��Sprite3Dģ��
			{
				//��_displayNode���ҳ���صľ���
				Sprite3D *targetSprite3D = (Sprite3D*)_displayNode->getChildByName(_currentSprite3D->getName());
				Vec2 targetPosition = targetSprite3D->convertToWorldSpace(Vec2());
				const float duration = (targetPosition - _currentSprite3D->getPosition()).length() / winSize.width* 2.0f;
				_currentSprite3D->runAction(cocos2d::Sequence::create(cocos2d::MoveTo::create(duration, targetPosition), cocos2d::CallFunc::create([=]()
				{
					_currentSprite3D->removeFromParentAndCleanup(true);
					_currentSprite3D = nullptr;
				}), nullptr));
			}
		}
	}
	else if (_selectAreaIndex == _AREA_LIST_INDEX_)
	{
		//����в�����3dģ��
		if (_currentSprite3D)
		{
			//�����λ��
			auto &listPosition = _clippingListArea->getPosition();
			auto &nowPosition = _currentSprite3D->getPosition();
			if (nowPosition.x >= listPosition.x && nowPosition.x <= listPosition.x + _listAReaSize.width
				&& nowPosition.y >= listPosition.y && nowPosition.y <= listPosition.y + _listAReaSize.height)
			{
				//���ص�ԭ����λ��
				Vec2 worldPosition = _listSprite3D->convertToWorldSpace(Vec2());
				const float duration = (worldPosition - nowPosition).length() / winSize.width * 2.0f;
				_currentSprite3D->runAction(cocos2d::Sequence::create(cocos2d::MoveTo::create(duration,worldPosition),
					CallFuncN::create([=](Node *sender) {
					sender->removeFromParent();
					_currentSprite3D = nullptr;
				}), nullptr));
			}
			else//����ɾ����ԭ����3dģ��,ͬʱ��ԭ���ļ�����ɾ����ص����ݽṹ
			{
				FadeOut  *fadeAction = FadeOut::create(0.6f);
				CallFuncN  *callFunc = CallFuncN::create([=](Node *sender) {
					const int tag = sender->getTag();
					std::vector<int>::iterator it = _currentFishIds.begin();
					for (; it != _currentFishIds.end(); ++it)
					{
						if (*it == tag)
							break;
					}
					if (it != _currentFishIds.end())
						_currentFishIds.erase(it);
					//��ԭ���ļ�����ɾ����صĽڵ�
					Node *target = _listNode->getChildByName(sender->getName());
					target->removeFromParent();
					//��ԭ���Ľڵ������������
					cocos2d::Vector<Node*> &children= _listNode->getChildren();
					//���մ��µ��ϵ�˳��
					int index = 0;
					for (Vector<Node*>::iterator lit = children.begin(); lit != children.end(); ++lit,++index)
					{
						(*lit)->setPositionY(-_listSize.height *(index+0.5f));
					}
					_currentSprite3D = nullptr;
				});
				_currentSprite3D->runAction(cocos2d::Sequence::create(fadeAction,callFunc,RemoveSelf::create() ,nullptr));
				_removeButton->setEnabled(_currentFishIds.size());
			}
		}
	}
}

void  LayerDialog::onMouseClick(const cocos2d::Vec2 &touchPoint)
{
	//�����������ʾ��û����ʧ,��ֹ�ּ����˷����ĵ��
	if (_labelTips != nullptr)
		return;
	//�������еĽڵ�
	cocos2d::Vector<Node*> &children = _displayNode->getChildren();
	const Vec2 &areaPosition = _clippingDisplayArea->getPosition();
	//���child�Ƿ�����ʾ����֮��
	if (touchPoint.x > areaPosition.x && touchPoint.x < areaPosition.x + _displayAreaSize.width
		&& touchPoint.y >areaPosition.y && touchPoint.y < areaPosition.y + _displayAreaSize.height)
	{
		for (cocos2d::Vector<Node*>::iterator it = children.begin(); it != children.end(); ++it)
		{
			Sprite3D *targetNode = (Sprite3D *)*it;
			Vec2    targetPoint = targetNode->convertToWorldSpace(Vec2::ZERO);
			Vec2    absDistance(fabs(touchPoint.x - targetPoint.x), fabs(touchPoint.y-targetPoint.y));
			if (targetPoint.x > areaPosition.x && targetPoint.x < areaPosition.x + _displayAreaSize.width
				&& targetPoint.y >areaPosition.y && targetPoint.y < areaPosition.y + _displayAreaSize.height
				&& absDistance.x <=_displaySize.width/2 && absDistance.y <= _displaySize.height/2)
			{
				auto &fishMap = _fishVisualStatic->find(targetNode->getTag())->second;
				//�ڴ˴�����Label
				char buffer[256];
				sprintf(buffer,"%s,%d",fishMap.label.c_str(),targetNode->getTag());
				Label   *label = Label::createWithSystemFont(buffer, "Arial", 24);
				label->setAlignment(TextHAlignment::CENTER);
				label->setPosition(touchPoint);
				this->addChild(label, 101);
				//
				label->runAction(Sequence::create(DelayTime::create(0.5), CallFuncN::create(CC_CALLBACK_1(LayerDialog::delayCallback, this)), DelayTime::create(2),FadeOut::create(1), RemoveSelf::create(), nullptr));
				_labelTips = label;
				break;
			}
		}
	}
	//������ʾ�б������е�Sprite3D
	const Vec2  &listPosition = _clippingListArea->getPosition();
	cocos2d::Vector<Node*>    &listChild = _listNode->getChildren();
	if (touchPoint.x > listPosition.x && touchPoint.x < listPosition.x + _listAReaSize.width
		&& touchPoint.y >listPosition.y && touchPoint.y < listPosition.y + _listAReaSize.height)
	{
		for (cocos2d::Vector<Node*>::iterator it = listChild.begin(); it != listChild.end(); ++it)
		{
			Sprite3D *targetNode = (Sprite3D *)*it;
			Vec2    targetPoint = targetNode->convertToWorldSpace(Vec2::ZERO);
			Vec2    absDistance(fabs(touchPoint.x - targetPoint.x), fabs(touchPoint.y - targetPoint.y));
			if (targetPoint.x > listPosition.x && targetPoint.x < listPosition.x + _listAReaSize.width
				&& targetPoint.y >listPosition.y && targetPoint.y < listPosition.y + _listAReaSize.height
				&& absDistance.x <= _listSize.width / 2 && absDistance.y <= _listSize.height / 2)
			{
				auto &fishMap = _fishVisualStatic->find(targetNode->getTag())->second;
				//�ڴ˴�����Label
				char buffer[256];
				sprintf(buffer, "%s,%d", fishMap.label.c_str(), targetNode->getTag());
				Label   *label = Label::createWithSystemFont(buffer, "Arial", 24);
				label->setAlignment(TextHAlignment::CENTER);
				label->setPosition(touchPoint);
				this->addChild(label, 101);
				//
				label->runAction(Sequence::create(DelayTime::create(0.5), CallFuncN::create(CC_CALLBACK_1(LayerDialog::delayCallback, this)), DelayTime::create(2), FadeOut::create(1), RemoveSelf::create(), nullptr));
				_labelTips = label;
				break;
			}
		}
	}
}

void   LayerDialog::delayCallback(cocos2d::Node *target)
{
	_labelTips = nullptr;
}

void LayerDialog::onButtonClick_Remove(cocos2d::Ref *sender, cocos2d::ui::Widget::TouchEventType type)
{
	if (type == cocos2d::ui::Widget::TouchEventType::ENDED)
	{
		auto &children = _listNode->getChildren();
		cocos2d::Vector<Node*>::iterator it = children.begin();
		for (; it != children.end(); ++it)
		{
			(*it)->runAction(cocos2d::Sequence::create(
				cocos2d::FadeOut::create(0.4f),
				CallFuncN::create([=](Node *sender) {
					sender->removeFromParent();
			}),nullptr
			));
		}
		//ֱ��ɾ�����еĽڵ�
		_currentFishIds.clear();
		//��ֹ��ť�ĵ��
		cocos2d::ui::Button *removeButton = (cocos2d::ui::Button*)sender;
		removeButton->setEnabled(false);
	}
}

void LayerDialog::onButtonClick_Confirm(cocos2d::Ref *sender, cocos2d::ui::Widget::TouchEventType type)
{
	if (type == cocos2d::ui::Widget::TouchEventType::ENDED)
	{
		if (_onConfirmCallback)
			_onConfirmCallback(_currentFishIds);
		this->removeFromParentAndCleanup(true);
	}
}

void  LayerDialog::onButtonClick_Cancel(cocos2d::Ref *sender, cocos2d::ui::Widget::TouchEventType type)
{
	if (type == cocos2d::ui::Widget::TouchEventType::ENDED)
	{
		if (_onCancelCallback)
			_onCancelCallback();
		this->removeFromParentAndCleanup(true);
	}
}

void  LayerDialog::onKeyPressed(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event)
{
	if (keyCode == cocos2d::EventKeyboard::KeyCode::KEY_LEFT_CTRL)
		_keyMask |= _KEY_MASK_CTRL_;
	if (keyCode == cocos2d::EventKeyboard::KeyCode::KEY_LEFT_ALT)
		_keyMask |= _KEY_MASK_ALT_;
}

void  LayerDialog::onKeyReleased(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event)
{
	if (keyCode == cocos2d::EventKeyboard::KeyCode::KEY_LEFT_CTRL)
		_keyMask &= ~_KEY_MASK_CTRL_;
	if (keyCode == cocos2d::EventKeyboard::KeyCode::KEY_LEFT_ALT)
		_keyMask &= ~_KEY_MASK_ALT_;
}

void  LayerDialog::loadDisplayFishMap()
{
	//rectangle clipping node
	auto &winSize = cocos2d::Director::getInstance()->getWinSize();
	//��λx,y��λ��
	const float x =( winSize.width - _displayAreaSize.width - 200 - _listAReaSize.width)/4.0f;
	const float y = (winSize.height - _displayAreaSize.height  )/2.0f;
	_clippingDisplayArea = cocos2d::ClippingRectangleNode::create(cocos2d::Rect(0,0, _displayAreaSize.width, _displayAreaSize.height));
	_clippingDisplayArea->setPosition(Vec2(x,y));
	this->addChild(_clippingDisplayArea, 3);
	//�ü������е������ӽڵ�����,�ڵ����ClippingRectangleNode�����Ͻ�
	_displayNode = cocos2d::Node::create();
	_displayNode->setPosition(Vec2(0, _displayAreaSize.height));
	_clippingDisplayArea->addChild(_displayNode);
	//�������е���
	std::map<int, FishVisual>::const_iterator it = _fishVisualStatic->cbegin();
	const int mapSize = _fishVisualStatic->size();
	int     index = 0;//����ֵ�ǹ���չʾ������ͼ���λ�õļ����
	for (; it != _fishVisualStatic->cend(); ++it,++index)
	{
		auto &fishMap = it->second;
		//�������еĹ����������
		std::string fileName = "3d/"+fishMap.name+"/"+fishMap.name+".c3b";
		Sprite3D *model = cocos2d::Sprite3D::create(fileName);
		model->setPosition3D(Vec3());
		model->setRotation3D(Vec3());
		model->setScale(fishMap.scale);
		model->setForce2DQueue(true);//��Ϊ2dͼ��������
		//��������λ��
		int row = index/ _AREA_DISPLAY_COULMN_ ;
		int column = index % _AREA_DISPLAY_COULMN_;
		const float  x = column *_displaySize.width + _displaySize.width / 2;
		const float y = row* _displaySize.height + _displaySize.height / 2;
		model->setPosition(Vec2(x,-y));
		//�����ٴν�������
		const cocos2d::AABB &aabb = model->getAABB();
		float maxWidth = aabb._max.x - aabb._min.x;
		model->setScale(_displaySize.width /maxWidth * fishMap.scale);
		model->setTag(it->first);//index��id�������ݺϲ�
		char buffer[128];
		sprintf(buffer,"Sprite3D%d",index);
		model->setName(buffer);
		_displayNode->addChild(model,index);
	}
	//����
	_lineFrameNode->drawLine(Vec2(x,y),Vec2(x, y+_displayAreaSize.height),Color4F(1.0f,0.0f,0.0f,1.0f));
	_lineFrameNode->drawLine(Vec2(x,y),Vec2(x+_displayAreaSize.width,y),Color4F(1.0f,0.0f,0.0f,1.0f));
	_lineFrameNode->drawLine(Vec2(x,y+_displayAreaSize.height),Vec2(x+_displayAreaSize.width,y+_displayAreaSize.height),Color4F(1.0f,0.0f,0.0f,1.0f));
	_lineFrameNode->drawLine(Vec2(x+_displayAreaSize.width,y),Vec2(x+_displayAreaSize.width,y+_displayAreaSize.height),Color4F(1.0f,0.0f,0.0f,1.0f));
}

void LayerDialog::loadListFishMap()
{
	auto &winSize = Director::getInstance()->getWinSize();
	const float x = (winSize.width - _displayAreaSize.width - _listAReaSize.width) / 2.0f + _displayAreaSize.width + 200.0f;
	const float y = (winSize.height - _listAReaSize.height)/2.0f;
	_clippingListArea = cocos2d::ClippingRectangleNode::create(cocos2d::Rect(0,0,_listAReaSize.width,_listAReaSize.height));
	_clippingListArea->setPosition(Vec2(x,y));
	this->addChild(_clippingListArea, 3);
	//
	_listNode = cocos2d::Node::create();
	_listNode->setPosition(Vec2(0,_listAReaSize.height));
	_clippingListArea->addChild(_listNode);
	//�����򸽴�������д������,Ŀǰʹ����ʱ����
	std::vector<int>::iterator it = _currentFishIds.begin();
	int index = 0;
	for (; it != _currentFishIds.end(); ++it,++index)
	{
		auto &fishMap = _fishVisualStatic->find(*it)->second;
		//�������еĹ����������
		std::string fileName = "3d/" + fishMap.name + "/" + fishMap.name + ".c3b";
		Sprite3D *model = cocos2d::Sprite3D::create(fileName);
		model->setPosition3D(Vec3());
		model->setRotation3D(Vec3());
		model->setScale(fishMap.scale);
		model->setForce2DQueue(true);//��Ϊ2dͼ��������
									 //��������λ��
		const float  x =  _listSize.width / 2;
		const float y = index* _displaySize.height + _displaySize.height / 2;
		model->setPosition(Vec2(x, -y));
		//�����ٴν�������
		const cocos2d::AABB &aabb = model->getAABB();
		float maxWidth = aabb._max.x - aabb._min.x;
		model->setScale(_displaySize.width / maxWidth * fishMap.scale);
		model->setTag(*it);
		char buffer[128];
		sprintf(buffer,"Sprite3D%d",index);
		model->setName(buffer);
		_listNode->addChild(model);
	}
	//����
	_lineFrameNode->drawLine(Vec2(x, y), Vec2(x, y + _listAReaSize.height), Color4F(1.0f, 0.0f, 0.0f, 1.0f));
	_lineFrameNode->drawLine(Vec2(x, y), Vec2(x + _listAReaSize.width, y), Color4F(1.0f, 0.0f, 0.0f, 1.0f));
	_lineFrameNode->drawLine(Vec2(x, y + _listAReaSize.height), Vec2(x + _listAReaSize.width, y + _listAReaSize.height), Color4F(1.0f, 0.0f, 0.0f, 1.0f));
	_lineFrameNode->drawLine(Vec2(x + _listAReaSize.width, y), Vec2(x + _listAReaSize.width, y + _listAReaSize.height), Color4F(1.0f, 0.0f, 0.0f, 1.0f));
}

Sprite3D *LayerDialog::createSprite3DByVisual(const FishVisual &fishMap, const cocos2d::Size &showSize)
{
	//�������еĹ����������
	std::string fileName = "3d/" + fishMap.name + "/" + fishMap.name + ".c3b";
	Sprite3D *model = cocos2d::Sprite3D::create(fileName);
	model->setPosition3D(Vec3());
	model->setRotation3D(Vec3());
	model->setScale(fishMap.scale);
	model->setForce2DQueue(true);//��Ϊ2dͼ��������
	//�����ٴν�������
	const cocos2d::AABB &aabb = model->getAABB();
	float maxWidth = aabb._max.x - aabb._min.x;
	model->setScale(showSize.width / maxWidth * fishMap.scale);
	//model->setCameraMask((short)CameraFlag::DEFAULT, true);
	//label
	//Label *label = Label::createWithSystemFont(fishMap.label, "Arial",16);
	//label->setAlignment(TextHAlignment::CENTER);
	//label->setAnchorPoint(Vec2(0.5f,0.5f));
	////label->setCameraMask((short)CameraFlag::DEFAULT);
	//label->setScale(1.0f / model->getScale());
	//model->addChild(label);
	return model;
}