/*
  *OpenGL 引擎鼠标,键盘事件管理
  *@date:2017-4-15
  *@Author:xiaohuaxiong
 */
#ifndef __EVENT_MANAGER_H__
#define __EVENT_MANAGER_H__
#include<engine/GLState.h>
#include<engine/Object.h>
#include<engine/Geometry.h>
#include<engine/event/TouchEventListener.h>
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
//键盘按键的类型,目前支持的类型并不全面
enum KeyCodeType
{
	KeyCode_NONE=0,//无效的按键
	KeyCode_W = 1,//W
	KeyCode_S = 2, //S
	KeyCode_A = 3,//A
	KeyCode_D = 4,//D
	KeyCode_CTRL = 5,//Ctrl
	KeyCode_SHIFT = 6,//Shift
	KeyCode_SPACE = 7,//空格键

};
//事件单元结构体
struct EventUnit
{

};

class EventManager
{
	friend void _static_mousePressCallback(int, int, int, int);
	friend void _static_mouseMotionCallback(int, int);
	friend class GLContext;
private:
	//左键鼠标事件,鼠标的状态,类型
	MouseType			_mouseLeftType;
	MouseState        _mouseLeftState;
	//鼠标的动作位置,以实际的OpenGL坐标系为准,(0,0)在屏幕的左下角
	GLVector2         _mouseLeftClickPosition;
	//邮件鼠标事件
	MouseType        _mouseRightType;
	MouseState       _mouseRightState;
	GLVector2         _mouseRightClickPosition;
	//键盘事件
	KeyCodeType    _keyCodeMask;
	KeyState			   _keyStateMask;
	//触屏事件的集合
	std::vector<TouchEventListener *>   _touchEventSet;
	std::map<TouchEventListener *,int>      _touchEventPriority;
	//是否正处于事件派发之中
	bool                   _isInTouchEventDispatch;
private:

	EventManager();
	EventManager(EventManager &);
	static EventManager   _static_eventManager;
//friend
//添加鼠标事件
//@param:mouseEffectPosition鼠标起作用的位置
	void        addMouseEvent(const MouseType mouseType, const MouseState mouseState, const GLVector2 &mouseEffectPosition);

	//添加键盘事件
	void        addKeyEvent(const KeyCodeType keyCode, const KeyState keyState);
	//派发鼠标
	void        dispatchMouseEvent();
	//派发键盘事件
	void        dispatchKeyEvent();
public:
	~EventManager();
	static EventManager   *getInstance();
	//删除与某一个对象相关的事件
	void        removeListener(Object *);
	//添加事件监听器
	//@param:priority代表优先级,其数值越小，表示监听事件的次序越靠前
	void        addTouchEventListener(TouchEventListener *touchEvent,int priority);
};

__NS_GLK_END
#endif