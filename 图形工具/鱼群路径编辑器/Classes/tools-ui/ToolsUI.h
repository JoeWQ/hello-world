/*
  *��ȺȺ���˶�UI
  *��UI������,�㳱�༭����û�е�·���༭������,��Ϊ�临���Զ���̯���˸�����Ⱥ·����������
  *���Ҹ�����Ⱥ·�߶������Լ��Ķ��ص�UI,���Դ�UI��ֵ�ṩ������ĳ�������
  *2017-8-4
  *@Author:xiaohuaxiong
 */
#ifndef __TOOLS_UI_H__
#define __TOOLS_UI_H__
#include "cocos2d.h"
#include "extensions/cocos-ext.h"
#include "ui/CocosGUI.h"
#include "basic/DrawNode3D.h"
#include "group/GroupRoute.h"
/*
  *ToolsUI�ƹ�������Ⱥ���˶����ߵĴ���/����/����
  *�Լ�����ϵ,�����¼���
  *�����䱾��û�б༭���ߵĹ���,Ҳ���ṩ����UI�Ĳ���
  *ֻ�ṩ�������߶���Ĵ���,���ݼ���,Ԥ��,���ݵı����
  *�����༭��������ϵ�����ϸ��OpenGL��������ϵ,��Ļ������Ϊԭ��
 */
class ToolsUI :public cocos2d::Layer
{
	//�����������
	cocos2d::Camera *_camera;
	//��ת��,��׶��
	cocos2d::DrawNode3D  *_drawNode;
	//��ť
	cocos2d::ui::Button        *_saveButton;
	cocos2d::ui::Button        *_previewButton;
	//��¼������ƫ����
	cocos2d::Vec2                  _touchOffsetVec2;
	cocos2d::Vec2                  _offsetVec2;
	//��������ת����
	cocos2d::Mat4                 _rotateMatrix;
	//��������
	int                                     _keyMask;
	//Ⱥ���˶�����
	GroupRoute                    *_groupRoute;
	//�Ƿ���Ӧ����Ҽ�
	bool                                   _isResponseMouseEvent;
	//�����������
	std::map<int, FishInfo>  _fishInfoMap;
private:
	ToolsUI();
	ToolsUI(const ToolsUI &);
	//��ʼ��������
	void   initLayer();
	//���غ�����ص���Ϣ
	void   loadFishInfo();
	//����3D������׶��
	void   drawFrustum();
public:
	~ToolsUI();
	static ToolsUI *create();

	//�����¼�
	bool      onTouchBegan(cocos2d::Touch *touch,cocos2d::Event *unused_event);
	void      onTouchMoved(cocos2d::Touch *touch,cocos2d::Event *unused_event);
	void      onTouchEnded(cocos2d::Touch *touch,cocos2d::Event *unused_event);
	/*
	  *��������ת����
	  *pitchΪ��X�����ת��
	  *yawΪ��Z�����ת��
	  *����Ĺ�����ѭ����ŷ����
	 */
	void      updateLayerMatrix(float pitch,float yaw);
	/*
	  *�����¼�
	 */
	void      onKeyPressed(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event);
	void      onKeyReleased(cocos2d::EventKeyboard::KeyCode keyCode,cocos2d::Event* event);
	/*
	  *����Ҽ��¼�
	 */
	void      onMouseClick(cocos2d::EventMouse  *mouseEvent);
	void      onMouseMoved(cocos2d::EventMouse  *mouseEvent);
	void     onMouseEnded(cocos2d::EventMouse  *mouseEvent);
	//��������
	void      onButtonClick_SaveRecord(cocos2d::Ref *sender,cocos2d::ui::Widget::TouchEventType eventType);
	/*
	  *Ԥ��ģ��
	 */
	void      onButtonClick_Preview(cocos2d::Ref *sender,cocos2d::ui::Widget::TouchEventType eventType);
	/*
	  *�ص�����,���ô˺���֮������ƶ���λ�õ����Ի���
	  *groupType:���ô˺��������ߵ�����
	  *param:���ߴ���Ĳ���,�����ĺ��������ߵ������Զ���
	  *xyz:����UI��λ��,��λ����Ҫ�����Լ�����,ע���������Ǹ�������3ά������,һ������Z���겻���õ�,����Ӿ����ʵ�ֶ���
	  *onConfirmCallback:�����ȷ����ť��ʱ��Ļص�����
	 */
	void      onPopupDialog(GroupType groupType,int param,const cocos2d::Vec3   &xyz,std::function<void (const FishInfo &)> onConfirmCallback);
	/*
	  *��ѯ��������Ϣ
	 */
	const FishInfo     &queryFishInfo(int fishId);
};

#endif