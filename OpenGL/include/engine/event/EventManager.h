/*
  *OpenGL 引擎鼠标,键盘事件管理
  *@date:2017-4-15
  *@Author:xiaohuaxiong
 */
#ifndef __EVENT_MANAGER_H__
#define __EVENT_MANAGER_H__
#include "engine/GLState.h"
#include "engine/Object.h"
#include "engine/Geometry.h"
#include "engine/event/KeyCode.h"
#include "engine/event/TouchEventListener.h"
#include "engine/event/KeyEventListener.h"
#include<vector>
#include<map>
void _static_mousePressCallback(int, int, int, int);
void  _static_mouseMotionCallback(int, int);
__NS_GLK_BEGIN
//定义鼠标状态
enum MouseType
{
	MouseType_None = 0,//无效的按键
	MouseType_Left = 1,//左键
	MouseType_Right = 2,//邮件
};
//鼠标的状态
enum MouseState
{
	MouseState_None=0,//无效的动作
	MouseState_Pressed=1,//鼠标被按下
	MouseState_Moved=2,//鼠标被拖动
	MouseState_Released = 3,//鼠标被释放
};
//键盘按键的状态
enum KeyState
{
	KeyState_None=0,//无效的键盘状态类型
	KeyState_Pressed=1,//键盘被按下
	KeyState_Released=2,//键盘按键被释放
};

class EventManager
{
	friend void _static_mousePressCallback(int, int, int, int);
	friend void _static_mouseMotionCallback(int, int);
	friend void _static_keyPressCallback(unsigned char,int,int);
	friend void _static_keySpecialPressCallback(int keyCode, int x, int y);
	friend void _static_keyReleaseCallback(unsigned char, int, int);
	friend void _static_keySpecialReleaseCallback(int keyCode, int x, int y);
	friend class GLContext;
private:
	//触屏事件的集合
	std::vector<TouchEventListener *>		     _touchEventArrays;
	std::map<TouchEventListener *,int>      _touchEventPriority;
	//键盘事件集合
	std::vector<KeyEventListener*>               _keyEventArrays;
	std::map<KeyEventListener*, int>            _keyEventPriority;
	//是否正处触屏于事件派发之中
	bool                   _isInTouchEventDispatch;
	//是否正处于键盘事件派发中
	bool                   _isInKeyEventDispatch;
private:

	EventManager();
	EventManager(EventManager &);
	static EventManager   _static_eventManager;
//friend
	//派发鼠标
	void        dispatchMouseEvent(MouseType mouseType,MouseState mouseState,const GLVector2 &mousePoint);
	//派发键盘事件
	void        dispatchKeyEvent(KeyCodeType keyCode,KeyCodeState keyState);
public:
	~EventManager();
	static EventManager   *getInstance();
	//删除与某一个对象相关的事件
	void        removeListener(Object *);
	//删除某一个事件
	void        removeListener(EventListener *eventListener);
	//添加事件监听器
	//@param:priority代表优先级,其数值越小，表示监听事件的次序越靠前
	void        addTouchEventListener(TouchEventListener *touchEvent,int priority);
	//键盘事件侦听器添加
	void        addKeyEventListener(KeyEventListener *keyEvent,int priority);
	//鼠标事件侦听器添加
	void        addMouseEventListener();
};

__NS_GLK_END
#endif