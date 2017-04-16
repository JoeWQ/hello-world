/*
  *OpenGL �������,�����¼�����
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
//���̰���������,Ŀǰ֧�ֵ����Ͳ���ȫ��
enum KeyCodeType
{
	KeyCode_NONE=0,//��Ч�İ���
	KeyCode_W = 1,//W
	KeyCode_S = 2, //S
	KeyCode_A = 3,//A
	KeyCode_D = 4,//D
	KeyCode_CTRL = 5,//Ctrl
	KeyCode_SHIFT = 6,//Shift
	KeyCode_SPACE = 7,//�ո��

};
//�¼���Ԫ�ṹ��
struct EventUnit
{

};

class EventManager
{
	friend void _static_mousePressCallback(int, int, int, int);
	friend void _static_mouseMotionCallback(int, int);
	friend class GLContext;
private:
	//�������¼�,����״̬,����
	MouseType			_mouseLeftType;
	MouseState        _mouseLeftState;
	//���Ķ���λ��,��ʵ�ʵ�OpenGL����ϵΪ׼,(0,0)����Ļ�����½�
	GLVector2         _mouseLeftClickPosition;
	//�ʼ�����¼�
	MouseType        _mouseRightType;
	MouseState       _mouseRightState;
	GLVector2         _mouseRightClickPosition;
	//�����¼�
	KeyCodeType    _keyCodeMask;
	KeyState			   _keyStateMask;
	//�����¼��ļ���
	std::vector<TouchEventListener *>   _touchEventSet;
	std::map<TouchEventListener *,int>      _touchEventPriority;
	//�Ƿ��������¼��ɷ�֮��
	bool                   _isInTouchEventDispatch;
private:

	EventManager();
	EventManager(EventManager &);
	static EventManager   _static_eventManager;
//friend
//�������¼�
//@param:mouseEffectPosition��������õ�λ��
	void        addMouseEvent(const MouseType mouseType, const MouseState mouseState, const GLVector2 &mouseEffectPosition);

	//��Ӽ����¼�
	void        addKeyEvent(const KeyCodeType keyCode, const KeyState keyState);
	//�ɷ����
	void        dispatchMouseEvent();
	//�ɷ������¼�
	void        dispatchKeyEvent();
public:
	~EventManager();
	static EventManager   *getInstance();
	//ɾ����ĳһ��������ص��¼�
	void        removeListener(Object *);
	//����¼�������
	//@param:priority�������ȼ�,����ֵԽС����ʾ�����¼��Ĵ���Խ��ǰ
	void        addTouchEventListener(TouchEventListener *touchEvent,int priority);
};

__NS_GLK_END
#endif