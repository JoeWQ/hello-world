/*
  *��������ѡ���չʾ���
  *2017-06-22
 */
#ifndef __LAYER_DIALOG_H__
#define __LAYER_DIALOG_H__
#include "cocos2d.h"
#include "extensions/cocos-ext.h"
#include "ui/CocosGUI.h"
#include "Common.h"
//
class LayerDialog :public cocos2d::LayerColor
{
	cocos2d::EventListenerTouchOneByOne   *_touchEventListener;
	//�¼��ɷ�,����ȷ�ϰ�ť�������Ļص�����,ȡ����ť�������Ļص�����
	std::function<void(std::vector<int> &list)>      _onConfirmCallback;
	std::function<void()>                                       _onCancelCallback;
	const std::map<int, FishVisual>                     *_fishVisualStatic;
	//std::vector<int>                                                *_fishMapVector;
	//չʾ�ü�����
	cocos2d::ClippingRectangleNode                   *_clippingDisplayArea;
	cocos2d::Node                                                  *_displayNode;//ֻ�òü�������
	//�б�ü�����
	cocos2d::ClippingRectangleNode                   *_clippingListArea;
	cocos2d::Node                                                  *_listNode;//ֻ���ڲü�������,����װ�������Ľڵ�
	//��ǰѡ�е�����,���־��μ�LayerDialog.cpp�ļ�
	int                                                                        _selectAreaIndex;
	//�ϴεĴ��������
	cocos2d::Vec2                                                     _offsetTouchPoint;
	//��ǰ���ڲ�����Sprite3D,���ֵҲ����Ϊ��
	cocos2d::Sprite3D                                              *_currentSprite3D;
	cocos2d::Sprite3D                                              *_listSprite3D;//���ڲ�����չʾ�����е�Sprite3D,��������ص��ظ�����
	//��������,�����־�μ�LayerDialog.cpp�ļ�
	int                                                                        _keyMask;
	//����
	cocos2d::Sprite                                                  *_layerBackground;
	//չʾ����ķ����С
	const cocos2d::Size                                             _displaySize;
	const cocos2d::Size                                             _listSize;
	const cocos2d::Size                                             _displayAreaSize;
	const cocos2d::Size                                             _listAReaSize;
	//�߿�,��ʾ�����ü��������Χ��
	cocos2d::DrawNode                                           *_lineFrameNode;
	//ɾ����ť
	cocos2d::ui::Button                                            *_removeButton;
	std::vector<int>                                                    _currentFishIds;
	//��ǰ�Ƿ��е�����ʾ��Label����
	cocos2d::Label                                                    *_labelTips;
private:
	LayerDialog(const std::map<int, FishVisual> &fishVisualStatic, std::vector<int> &fishMapVector);
	LayerDialog(LayerDialog &);
	void         initWithFishMap(const std::map<int, FishVisual> &fishVisualStatic, std::vector<int> &fishMapVector);
public:
	~LayerDialog();
	/*
	  *����һ������������ݽṹ�ļ���,�Լ�һ������д�뵽���е�ѡ�е�������ݽṹ,
	  *�������ջὫ���е�����д�뵽����
	 */
	static       LayerDialog *createLayerDialog(const std::map<int,FishVisual> &fishVisualStatic,std::vector<int> &fishMapVector);
	//�����ȷ����ť֮����¼�
	void         onButtonClick_Confirm(cocos2d::Ref *sender, cocos2d::ui::Widget::TouchEventType type);
	//ȡ����ť����¼�
	void         onButtonClick_Cancel(cocos2d::Ref *sender, cocos2d::ui::Widget::TouchEventType type);
	//�����е��Ѿ�ѡ�е�ģ��ɾ����
	void         onButtonClick_Remove(cocos2d::Ref *sender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *�����¼�
	 */
	bool        onTouchBegan(cocos2d::Touch *touch,cocos2d::Event *unuseEvent);
	void        onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unuseEvent);
	void        onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unuseEvent);
	/*
	  *����Ҽ���Ӧ����,���Ҽ������ʱ�����
	 */
	void         onMouseClick(const cocos2d::Vec2   &touchPoint);
	//�¼��ɷ�,����ȷ�ϰ�ť�Լ�ȡ����ť������֮��Ļص�����
	void         setConfirmCallback(std::function<void(std::vector<int> &)> confirmCallback);
	void         setCancelCallback(std::function<void()> cancelCallback);
	/*
	  *�����¼�,��Ҫ���¼����¼����ܼ���
	 */
	void         onKeyPressed(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event);
	void         onKeyReleased(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event);
	/*
	  *����չʾ�����е���
	 */
	void         loadDisplayFishMap();
	/*
	  *�����б������е���
	 */
	void         loadListFishMap();
	/*
	  *��������,����һ�����ģ��
	 */
	cocos2d::Sprite3D *createSprite3DByVisual(const FishVisual &fishMap,const cocos2d::Size &showSize);
	/*
	  *�ص�����
	 */
	void      delayCallback(cocos2d::Node *target);
 };
#endif