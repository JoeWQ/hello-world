/*
  *事件管理实现
  *@date:2017-4-15
  *@Author:xiaohuaxiong
 */
#include<engine/event/EventManager.h>
#include<assert.h>
__NS_GLK_BEGIN

EventManager     EventManager::_static_eventManager;

EventManager::EventManager()
{
	_mouseLeftType = MouseType_None;
	_mouseLeftState = MouseState_None;
	_mouseRightType = MouseType_None;
	_mouseRightState = MouseState_None;

	_keyCodeMask = KeyCode_NONE;
	_keyStateMask = KeyState_None;

	_touchEventSet.reserve(64);
	_isInTouchEventDispatch = false;
}
//释放所有的被注册的事件管理器
EventManager::~EventManager()
{
	std::vector<TouchEventListener *>::iterator it = _touchEventSet.begin();
	for (; it != _touchEventSet.end(); ++it)
	{
		(*it)->release();
	}
	_touchEventSet.clear();
	_touchEventPriority.clear();
}

EventManager *EventManager::getInstance()
{
	return &_static_eventManager;
}

void EventManager::addMouseEvent(const MouseType mouseType, const MouseState mouseState, const GLVector2 &mouseEffectPosition)
{
	if (mouseType == MouseType_Left)
	{
		_mouseLeftType = mouseType;
		_mouseLeftState = mouseState;
		_mouseLeftClickPosition = mouseEffectPosition;
	}
	else if(mouseType == MouseType_Right)
	{
		_mouseRightType = mouseType;
		_mouseRightState = mouseState;
		_mouseRightClickPosition = mouseEffectPosition;
	}
}

void EventManager::addKeyEvent(const KeyCodeType keyCode, const KeyState keyState)
{

}

void EventManager::dispatchMouseEvent()
{
	if (!_touchEventSet.size())
		return;
	_isInTouchEventDispatch = true;
	TouchEventListener *targetEvent = nullptr;
	int      nowSize = 0;
	int      lastSize;
	//检测是否有触屏标志
	if (_mouseLeftType == MouseType_Left)
	{
		//首先派发触屏事件
		std::vector<TouchEventListener *>::iterator it = _touchEventSet.begin();
		//注意,在事件派发的过程中，有可能会添加/删除事件,目前这个功能暂时不实现,带到哥有时间的时候再说
		if (_mouseLeftState == MouseState_Pressed)
		{
			for (; it != _touchEventSet.end();++it )
			{
				targetEvent = *it;
				lastSize= _touchEventSet.size();
				//检测是否被释放，或者
				const bool interact = targetEvent->onTouchBegin(&_mouseLeftClickPosition);
				//如果有反馈,且事件被吞噬
				if (interact && targetEvent->isSwallowTouch())
					break;
				//检测是否中间产生了删除监听器事件,重新定位
				if (_touchEventSet.size() != lastSize)
				{
					printf("------------------\n");
				}
			}
		}
		else if (_mouseLeftState == MouseState_Moved)
		{
			for (; it != _touchEventSet.end(); ++it)
			{
				(*it)->onTouchMoved(&_mouseLeftClickPosition);
			}
		}
		else if (_mouseLeftState == MouseState_Released)
		{
			for (; it != _touchEventSet.end(); ++it)
			{
				(*it)->onTouchEnded(&_mouseLeftClickPosition);
			}
		}
	}
	_mouseLeftType = MouseType_None;
	_isInTouchEventDispatch = false;
}

void EventManager::dispatchKeyEvent()
{

}

void EventManager::removeListener(Object *obj)
{
	std::vector<TouchEventListener *>::iterator  it = _touchEventSet.begin();
	for (; it != _touchEventSet.end(); )
	{
		Object *targetObject = (*it)->getEventTarget();
		if (targetObject == obj)
		{
			targetObject->release();
			_touchEventPriority.erase(*it);
			it = _touchEventSet.erase(it);
		}
		else
			++it;
	}
}

void EventManager::addTouchEventListener(TouchEventListener *touchEvent,int priority)
{
	//检测是否重复添加了
	std::map<TouchEventListener *, int>::iterator itt = _touchEventPriority.find(touchEvent);
	assert(itt == _touchEventPriority.end());
	//计算索引次序
	int indexSequence = 0;
	std::vector<TouchEventListener *>::iterator it = _touchEventSet.begin();
	for ( ;it != _touchEventSet.end();++it)
	{
		int nowPriority = _touchEventPriority[*it];
		if (priority <= nowPriority)
			break;
		else
			++indexSequence;
	}
	_touchEventSet.insert(it, touchEvent);
}
__NS_GLK_END