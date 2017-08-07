/*
  *选择对话框,里面会加载所有的鱼模型,让使用者选择
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
	//当点击确定按钮的时候的回调函数
	std::function<void (const FishInfo &)>	_onConfirmCallback;
	const std::map<int, FishInfo>				*_fishInfos;
	cocos2d::ui::ScrollView                *_scrollView;
	cocos2d::Size                                   _valideSize;
private:
	ChooseDialog(const std::map<int, FishInfo> *fishInfoMap);
	ChooseDialog(const ChooseDialog &);
	bool      init();
	//加载所有有关鱼的信息
	//void      loadFishInfo();
public:
	~ChooseDialog();
	static ChooseDialog  *create(const std::map<int,FishInfo> *fishInfoMap);
	/*
	  *触屏事件屏蔽掉
	  *
	 */
	bool   onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	void   onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	void   onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	/*
	  *获取对话框有效位置的尺寸
	 */
	const cocos2d::Size    &getValideSize();
	/*
	  *在屏幕的某一个位置弹出对话框,在对象创建之后一定要调用此函数
	  *注意,即使给出了这个位置,也不一定代表这对话框会在触屏位置的下方
	 */
	void   popupDialog(const cocos2d::Vec2 &xy);
	/*
	  *设置回调函数,当点击确认按钮的时候调用
	 */
	void   registerConfirmCallback(std::function<void (const FishInfo &)> onConfirmCallback);
	/*
	  *回调函数,当某一条鱼被选中的时候
	 */
	void  onImageClick_FishSelect(cocos2d::Ref *sender,cocos2d::ui::Widget::TouchEventType eventType);
	/*
	  *取消回调函数
	 */
	void  onButtonClick_Cancel(cocos2d::Ref *sender,cocos2d::ui::Widget::TouchEventType eventType);
};
#endif