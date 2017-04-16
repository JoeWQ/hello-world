/*
  *贝塞尔曲线生成工具
  *2017-03-20
  *@Author:xiaoxiong
  *@Version:1.0 支持最基本的曲线生成
  *@Version:2.0 加入了对3d贝塞尔曲线点进行操纵的功能
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
//键盘掩码,目前只是用了一个,以后随着工具的扩展,将会引入更多的按键掩码
#define _KEY_CTRL_MASK_      0x01
//如果W键被按下
#define _KEY_W_MASK_            0x02
//如果S键被按下
#define _KEY_S_MASK_			  0x04
/*
  *贝塞尔曲线生成工具类
  *3d场景采用的是以屏幕的中心点为(0,0,0)点,坐标系按照OpenGL世界坐标系来进行建模
  *考虑到贝塞尔曲线具有刚体平移的性质,最后在保存数据的时候，我们会将他的数据做一次变换
  *但不会改变贝塞尔曲线的形状
  */
class BesselUI :public cocos2d::Layer
{
private:
	//与贝塞尔曲线的参数设置有关的组件
	cocos2d::Layer     *_settingLayer;
	//摄像机参数
	cocos2d::Camera	*_viewCamera;
	//
	//position of uniform
	//上次选中的贝塞尔曲线点的索引
	int           _lastSelectIndex;
	cocos2d::Vec2        _offsetPoint;
	cocos2d::Vec2        _originVec2;
	//记录x,y方向上的偏移
	cocos2d::Vec2        _xyOffset;
	/*
	  *3d场景下的摄像机
	 */
	cocos2d::Camera   *_camera;
	/*
	  *与摄像机相关的参数,摄像机可以拉伸的最远,最近距离
	  *此数据域作用于视图矩阵之上
	 */
	float             _maxZeye, _minZeye,_nowZeye;
	/*
	  *贝塞尔曲线
	 */
	BesselNode             *_besselNode;
	//关于3个方向的坐标轴
	cocos2d::DrawNode3D   *_axisNode;
	//3d空间的网格,用来使整个场景具有空间感
	Matrix    _rotateMatrix;
	//键盘按键掩码
	int                            _keyMask;
	/*
	  *记录所有已经完成的曲线点集合配置
	 */
	std::vector<BesselSet>     _besselSetData;
	int                                      _besselSetSize;
	cocos2d::EventListenerKeyboard   *_keyboardListener;
	cocos2d::EventListenerTouchOneByOne    *_touchListener;
private:
	BesselUI();
	void   initBesselLayer();
	/*
	  *创建旋转矩阵
	 */
	void   makeRotateMatrix(const cocos2d::Vec2  &xyOffset,cocos2d::Mat4 &outMatrix,cocos2d::Quaternion  &);
	/*
	  *画出整个3d坐标轴以及整个空间网格
	 */
	void   drawAxisMesh();
	/*
	  *实时更新摄像机的位置,如果有调整摄像机的动作
	 */
	void   updateCamera(float dt);
public:
	~BesselUI();
	//layer
	static BesselUI    *createBesselLayer();
	//scene
	static cocos2d::Scene  *createScene();

	void BesselUI::visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags);
	//触屏事件
	virtual  bool   onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	virtual void    onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	virtual void    onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	//键盘事件,主要检测Ctrl键是否按下了,以后随着工具的扩展,将会引入更多的按键处理
	void                onKeyPressed(cocos2d::EventKeyboard::KeyCode    keyCode,cocos2d::Event    *unused_event);
	void                onKeyReleased(cocos2d::EventKeyboard::KeyCode   keyCode,cocos2d::Event *unused_event);
	/*
	  *控制3d场景的面板
	 */
	void           loadSettingLayer();
	/*
	  *点击隐藏或者伸展面板
	 */
	void           onButtonClick_SpreadOrHide(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *控制贝塞尔曲线的控制点数目的组按钮事件
	 */
	void          onChangeRadioButtonSelect(cocos2d::ui::RadioButton* radioButton, cocos2d::ui::RadioButton::EventType type);
	/*
	  *删除上一条记录
	 */
	void          onButtonClick_RemoveLast(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *保存当前记录
	 */
	void          onButtonClick_SaveRecord(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *将当前记录写入到文件中
	 */
	void          onButtonClick_SaveToFile(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *预览曲线
	 */
	void         onButtonClick_Preview(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *写入到文件中
	 */
	void         writeRecordToFile();
};
#endif