/*
  *OpenGL �������,�����¼�����
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
//�������״̬
enum MouseType
{
	MouseType_None = 0,//��Ч�İ���
	MouseType_Left = 1,//���
	MouseType_Right = 2,//�ʼ�
};
//����״̬
enum MouseState
{
	MouseState_None=0,//��Ч�Ķ���
	MouseState_Pressed=1,//��걻����
	MouseState_Moved=2,//��걻�϶�
	MouseState_Released = 3,//��걻�ͷ�
};
//���̰�����״̬
enum KeyState
{
	KeyState_None=0,//��Ч�ļ���״̬����
	KeyState_Pressed=1,//���̱�����
	KeyState_Released=2,//���̰������ͷ�
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
	//�����¼��ļ���
	std::vector<TouchEventListener *>		     _touchEventArrays;
	std::map<TouchEventListener *,int>      _touchEventPriority;
	//�����¼�����
	std::vector<KeyEventListener*>               _keyEventArrays;
	std::map<KeyEventListener*, int>            _keyEventPriority;
	//�Ƿ������������¼��ɷ�֮��
	bool                   _isInTouchEventDispatch;
	//�Ƿ������ڼ����¼��ɷ���
	bool                   _isInKeyEventDispatch;
private:

	EventManager();
	EventManager(EventManager &);
	static EventManager   _static_eventManager;
//friend
	//�ɷ����
	void        dispatchMouseEvent(MouseType mouseType,MouseState mouseState,const GLVector2 &mousePoint);
	//�ɷ������¼�
	void        dispatchKeyEvent(KeyCodeType keyCode,KeyCodeState keyState);
public:
	~EventManager();
	static EventManager   *getInstance();
	//ɾ����ĳһ��������ص��¼�
	void        removeListener(Object *);
	//ɾ��ĳһ���¼�
	void        removeListener(EventListener *eventListener);
	//����¼�������
	//@param:priority�������ȼ�,����ֵԽС����ʾ�����¼��Ĵ���Խ��ǰ
	void        addTouchEventListener(TouchEventListener *touchEvent,int priority);
	//�����¼����������
	void        addKeyEventListener(KeyEventListener *keyEvent,int priority);
	//����¼����������
	void        addMouseEventListener();
};

__NS_GLK_END
#endif