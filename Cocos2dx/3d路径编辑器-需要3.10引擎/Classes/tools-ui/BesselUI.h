/*
  *�������������ɹ���
  *2017-03-20
  *@Author:xiaoxiong
  *@Version:1.0 ֧�����������������
  *@Version:2.0 �����˶�3d���������ߵ���в��ݵĹ���
 */
#ifndef __BESSEL_UI_H__
#define __BESSEL_UI_H__
#include"cocos2d.h"
#include"geometry/Geometry.h"
#include "extensions/cocos-ext.h"
#include "ui/CocosGUI.h"
#include"BesselNode.h"
#include"DrawNode3D.h"
#include<vector>
//��������,Ŀǰֻ������һ��,�Ժ����Ź��ߵ���չ,�����������İ�������
#define _KEY_CTRL_MASK_      0x01
//���W��������
#define _KEY_W_MASK_            0x02
//���S��������
#define _KEY_S_MASK_			  0x04
/*
  *�������������ɹ�����
  *3d�������õ�������Ļ�����ĵ�Ϊ(0,0,0)��,����ϵ����OpenGL��������ϵ�����н�ģ
  *���ǵ����������߾��и���ƽ�Ƶ�����,����ڱ������ݵ�ʱ�����ǻὫ����������һ�α任
  *������ı䱴�������ߵ���״
  */
class BesselUI :public cocos2d::Layer
{
private:
	//�뱴�������ߵĲ��������йص����
	cocos2d::Layer     *_settingLayer;
	//���������
	cocos2d::Camera	*_viewCamera;
	//
	//position of uniform
	//�ϴ�ѡ�еı��������ߵ������
	int           _lastSelectIndex;
	cocos2d::Vec2        _offsetPoint;
	cocos2d::Vec2        _originVec2;
	//��¼x,y�����ϵ�ƫ��
	cocos2d::Vec2        _xyOffset;
	/*
	  *3d�����µ������
	 */
	cocos2d::Camera   *_camera;
	/*
	  *���������صĲ���,����������������Զ,�������
	  *����������������ͼ����֮��
	 */
	float             _maxZeye, _minZeye,_nowZeye;
	/*
	  *����������
	 */
	BesselNode             *_besselNode;
	//����3�������������
	cocos2d::DrawNode3D   *_axisNode;
	//3d�ռ������,����ʹ�����������пռ��
	Matrix    _rotateMatrix;
	//���̰�������
	int                            _keyMask;
	/*
	  *��¼�����Ѿ���ɵ����ߵ㼯������
	 */
	std::vector<BesselSet>     _besselSetData;
	int                                      _besselSetSize;
	cocos2d::EventListenerKeyboard   *_keyboardListener;
	cocos2d::EventListenerTouchOneByOne    *_touchListener;
private:
	BesselUI();
	void   initBesselLayer();
	/*
	  *������ת����
	 */
	void   makeRotateMatrix(const cocos2d::Vec2  &xyOffset,cocos2d::Mat4 &outMatrix,cocos2d::Quaternion  &);
	/*
	  *��������3d�������Լ������ռ�����
	 */
	void   drawAxisMesh();
	/*
	  *ʵʱ�����������λ��,����е���������Ķ���
	 */
	void   updateCamera(float dt);
public:
	~BesselUI();
	//layer
	static BesselUI    *createBesselLayer();
	//scene
	static cocos2d::Scene  *createScene();

	void BesselUI::visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags);
	//�����¼�
	virtual  bool   onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	virtual void    onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	virtual void    onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	//�����¼�,��Ҫ���Ctrl���Ƿ�����,�Ժ����Ź��ߵ���չ,�����������İ�������
	void                onKeyPressed(cocos2d::EventKeyboard::KeyCode    keyCode,cocos2d::Event    *unused_event);
	void                onKeyReleased(cocos2d::EventKeyboard::KeyCode   keyCode,cocos2d::Event *unused_event);
	/*
	  *����3d���������
	 */
	void           loadSettingLayer();
	/*
	  *������ػ�����չ���
	 */
	void           onButtonClick_SpreadOrHide(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *���Ʊ��������ߵĿ��Ƶ���Ŀ���鰴ť�¼�
	 */
	void          onChangeRadioButtonSelect(cocos2d::ui::RadioButton* radioButton, cocos2d::ui::RadioButton::EventType type);
	/*
	  *ɾ����һ����¼
	 */
	void          onButtonClick_RemoveLast(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *���浱ǰ��¼
	 */
	void          onButtonClick_SaveRecord(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *����ǰ��¼д�뵽�ļ���
	 */
	void          onButtonClick_SaveToFile(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *Ԥ������
	 */
	void         onButtonClick_Preview(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *д�뵽�ļ���
	 */
	void         writeRecordToFile();
};
#endif