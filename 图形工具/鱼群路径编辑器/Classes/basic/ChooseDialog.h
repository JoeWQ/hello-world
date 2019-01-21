/*
  *ѡ��Ի���,�����������е���ģ��,��ʹ����ѡ��
  *@2017-8-4
  *@Author:xiaohuaxiong
 */
#ifndef __CHOOSE_DIALOG_H__
#define __CHOOSE_DIALOG_H__
#include "cocos2d.h"
#include "extensions/cocos-ext.h"
#include "ui/CocosGUI.h"
#include "common/Common.h"
class ChooseDialog :public cocos2d::LayerColor
{
	//�����ȷ����ť��ʱ��Ļص�����
	std::function<void (const FishInfo &)>	_onConfirmCallback;
	const std::map<int, FishInfo>				*_fishInfos;
	cocos2d::ui::ScrollView                *_scrollView;
	cocos2d::Size                                   _valideSize;
private:
	ChooseDialog(const std::map<int, FishInfo> *fishInfoMap);
	ChooseDialog(const ChooseDialog &);
	bool      init();
	//���������й������Ϣ
	//void      loadFishInfo();
public:
	~ChooseDialog();
	static ChooseDialog  *create(const std::map<int,FishInfo> *fishInfoMap);
	/*
	  *�����¼����ε�
	  *
	 */
	bool   onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	void   onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	void   onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	/*
	  *��ȡ�Ի�����Чλ�õĳߴ�
	 */
	const cocos2d::Size    &getValideSize();
	/*
	  *����Ļ��ĳһ��λ�õ����Ի���,�ڶ��󴴽�֮��һ��Ҫ���ô˺���
	  *ע��,��ʹ���������λ��,Ҳ��һ��������Ի�����ڴ���λ�õ��·�
	 */
	void   popupDialog(const cocos2d::Vec2 &xy);
	/*
	  *���ûص�����,�����ȷ�ϰ�ť��ʱ�����
	 */
	void   registerConfirmCallback(std::function<void (const FishInfo &)> onConfirmCallback);
	/*
	  *�ص�����,��ĳһ���㱻ѡ�е�ʱ��
	 */
	void  onImageClick_FishSelect(cocos2d::Ref *sender,cocos2d::ui::Widget::TouchEventType eventType);
	/*
	  *ȡ���ص�����
	 */
	void  onButtonClick_Cancel(cocos2d::Ref *sender,cocos2d::ui::Widget::TouchEventType eventType);
};
#endif