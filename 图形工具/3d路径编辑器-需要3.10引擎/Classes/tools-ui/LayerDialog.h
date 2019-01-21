/*
  *关于鱼类选择的展示面板
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
	//事件派发,设置确认按钮被点击后的回调函数,取消按钮被点击后的回调函数
	std::function<void(std::vector<int> &list)>      _onConfirmCallback;
	std::function<void()>                                       _onCancelCallback;
	const std::map<int, FishVisual>                     *_fishVisualStatic;
	//std::vector<int>                                                *_fishMapVector;
	//展示裁剪区域
	cocos2d::ClippingRectangleNode                   *_clippingDisplayArea;
	cocos2d::Node                                                  *_displayNode;//只用裁剪区域中
	//列表裁剪区域
	cocos2d::ClippingRectangleNode                   *_clippingListArea;
	cocos2d::Node                                                  *_listNode;//只用在裁剪区域中,用来装载其他的节点
	//当前选中的区域,其标志请参见LayerDialog.cpp文件
	int                                                                        _selectAreaIndex;
	//上次的触屏区域点
	cocos2d::Vec2                                                     _offsetTouchPoint;
	//当前正在操作的Sprite3D,这个值也可能为空
	cocos2d::Sprite3D                                              *_currentSprite3D;
	cocos2d::Sprite3D                                              *_listSprite3D;//正在操作的展示区域中的Sprite3D,避免了相关的重复计算
	//键盘掩码,具体标志参见LayerDialog.cpp文件
	int                                                                        _keyMask;
	//背景
	cocos2d::Sprite                                                  *_layerBackground;
	//展示区域的方框大小
	const cocos2d::Size                                             _displaySize;
	const cocos2d::Size                                             _listSize;
	const cocos2d::Size                                             _displayAreaSize;
	const cocos2d::Size                                             _listAReaSize;
	//线框,显示两个裁剪区域的外围框
	cocos2d::DrawNode                                           *_lineFrameNode;
	//删除按钮
	cocos2d::ui::Button                                            *_removeButton;
	std::vector<int>                                                    _currentFishIds;
	//当前是否有弹出提示的Label出现
	cocos2d::Label                                                    *_labelTips;
private:
	LayerDialog(const std::map<int, FishVisual> &fishVisualStatic, std::vector<int> &fishMapVector);
	LayerDialog(LayerDialog &);
	void         initWithFishMap(const std::map<int, FishVisual> &fishVisualStatic, std::vector<int> &fishMapVector);
public:
	~LayerDialog();
	/*
	  *传入一个关于鱼的数据结构的集合,以及一个可以写入到其中的选中的鱼的数据结构,
	  *并且最终会将所有的数据写入到其中
	 */
	static       LayerDialog *createLayerDialog(const std::map<int,FishVisual> &fishVisualStatic,std::vector<int> &fishMapVector);
	//当点击确定按钮之后的事件
	void         onButtonClick_Confirm(cocos2d::Ref *sender, cocos2d::ui::Widget::TouchEventType type);
	//取消按钮点击事件
	void         onButtonClick_Cancel(cocos2d::Ref *sender, cocos2d::ui::Widget::TouchEventType type);
	//将所有的已经选中的模型删除掉
	void         onButtonClick_Remove(cocos2d::Ref *sender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *触屏事件
	 */
	bool        onTouchBegan(cocos2d::Touch *touch,cocos2d::Event *unuseEvent);
	void        onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unuseEvent);
	void        onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unuseEvent);
	/*
	  *鼠标右键响应函数,当右键点击的时候调用
	 */
	void         onMouseClick(const cocos2d::Vec2   &touchPoint);
	//事件派发,设置确认按钮以及取消按钮被按下之后的回调函数
	void         setConfirmCallback(std::function<void(std::vector<int> &)> confirmCallback);
	void         setCancelCallback(std::function<void()> cancelCallback);
	/*
	  *键盘事件,需要按下键盘事件才能监听
	 */
	void         onKeyPressed(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event);
	void         onKeyReleased(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event);
	/*
	  *加载展示区域中的鱼
	 */
	void         loadDisplayFishMap();
	/*
	  *加载列表区域中的鱼
	 */
	void         loadListFishMap();
	/*
	  *给定资料,加载一个鱼的模型
	 */
	cocos2d::Sprite3D *createSprite3DByVisual(const FishVisual &fishMap,const cocos2d::Size &showSize);
	/*
	  *回调函数
	 */
	void      delayCallback(cocos2d::Node *target);
 };
#endif