/*
  *�����¼�,ֻ������������м���
  *@date:2017-4-15
  *@Author:xiaohuaxiong
 */
#ifndef __TOUCH_EVENT_LISTENER_H__
#define __TOUCH_EVENT_LISTENER_H__
#include<engine/Object.h>
#include<engine/Types.h>
#include<engine/Geometry.h>
__NS_GLK_BEGIN
class TouchEventListener :public Object
{
private:
	//�Ƿ������¼��������־Ϊtrueʱ�����������ȼ����¼������ղ��������¼�
	bool       _isSwallowEvent;
	//�Ƿ���Ӧ�˴������µ��¼�
	bool      _isInteractTouch;
	//�¼��Ľ�����
	Object    *_eventTarget;
	//��������ָ��
	GLKTouchCallback     _touchBegan;
	GLKTouchMotionCallback _touchMotion;
	GLKTouchReleaseCallback _touchRelease;
private:
	TouchEventListener();
	TouchEventListener(TouchEventListener &);
	void   initWithTarget(Object *eventTarget);
	void   initWithTarget(Object *eventTarget, GLKTouchCallback touchBegin, GLKTouchMotionCallback touchMoved, GLKTouchReleaseCallback touchRelease);
public:
	~TouchEventListener();
	static TouchEventListener *createTouchListener(Object *eventTarget);
	static TouchEventListener *createTouchListener(Object *eventTarget,GLKTouchCallback touchBegin, GLKTouchMotionCallback touchMoved, GLKTouchReleaseCallback touchRelease);

	//�Ƿ����ɴ����¼�
	void    setSwallowTouch(bool );
	bool    isSwallowTouch()const;
	//�Ƿ���Ӧ�����ƶ��������¼�
	bool    isRespondTouch()const;
	//��ȡ�¼��ɷ��ߵĵ�ַ
	Object *getEventTarget()const;
	//�ɷ��¼�
	bool    onTouchBegin(const GLVector2 *touchPoint);
	void    onTouchMoved(const GLVector2 *touchPoint);
	void    onTouchEnded(const GLVector2 *touchPoint);
	//����
	void    registerTouchCallback(GLKTouchCallback touchBegin);
	void    registerMotionCallback(GLKTouchMotionCallback touchMoved);
	void    registerReleaseCallback(GLKTouchReleaseCallback touchRelease);
};
__NS_GLK_END
#endif