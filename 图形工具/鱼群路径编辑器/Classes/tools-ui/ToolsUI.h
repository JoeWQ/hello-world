/*
  *鱼群群体运动UI
  *在UI表现上,鱼潮编辑器并没有单路径编辑器复杂,因为其复杂性都分摊到了各个鱼群路径曲线类上
  *并且各个鱼群路线对象有自己的独特的UI,所以此UI层值提供最基本的场景管理
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
  *ToolsUI掌管着所有群体运动曲线的创建/加载/销毁
  *以及坐标系,触屏事件等
  *但是其本身并没有编辑曲线的功能,也不提供关于UI的操作
  *只提供关于曲线对象的创建,数据加载,预览,数据的保存等
  *整个编辑器的坐标系采用严格的OpenGL世界坐标系,屏幕的中心为原点
 */
class ToolsUI :public cocos2d::Layer
{
	//场景的摄像机
	cocos2d::Camera *_camera;
	//旋转轴,视锥体
	cocos2d::DrawNode3D  *_drawNode;
	//按钮
	cocos2d::ui::Button        *_saveButton;
	cocos2d::ui::Button        *_previewButton;
	//记录触屏的偏移量
	cocos2d::Vec2                  _touchOffsetVec2;
	cocos2d::Vec2                  _offsetVec2;
	//场景的旋转矩阵
	cocos2d::Mat4                 _rotateMatrix;
	//键盘掩码
	int                                     _keyMask;
	//群体运动对象
	GroupRoute                    *_groupRoute;
	//是否响应鼠标右键
	bool                                   _isResponseMouseEvent;
	//所有鱼的数据
	std::map<int, FishInfo>  _fishInfoMap;
private:
	ToolsUI();
	ToolsUI(const ToolsUI &);
	//初始化场景层
	void   initLayer();
	//加载和鱼相关的信息
	void   loadFishInfo();
	//画出3D场景视锥体
	void   drawFrustum();
public:
	~ToolsUI();
	static ToolsUI *create();

	//触屏事件
	bool      onTouchBegan(cocos2d::Touch *touch,cocos2d::Event *unused_event);
	void      onTouchMoved(cocos2d::Touch *touch,cocos2d::Event *unused_event);
	void      onTouchEnded(cocos2d::Touch *touch,cocos2d::Event *unused_event);
	/*
	  *场景的旋转矩阵
	  *pitch为绕X轴的旋转角
	  *yaw为绕Z轴的旋转角
	  *计算的过程遵循右手欧拉角
	 */
	void      updateLayerMatrix(float pitch,float yaw);
	/*
	  *键盘事件
	 */
	void      onKeyPressed(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event);
	void      onKeyReleased(cocos2d::EventKeyboard::KeyCode keyCode,cocos2d::Event* event);
	/*
	  *鼠标右键事件
	 */
	void      onMouseClick(cocos2d::EventMouse  *mouseEvent);
	void      onMouseMoved(cocos2d::EventMouse  *mouseEvent);
	void     onMouseEnded(cocos2d::EventMouse  *mouseEvent);
	//保存数据
	void      onButtonClick_SaveRecord(cocos2d::Ref *sender,cocos2d::ui::Widget::TouchEventType eventType);
	/*
	  *预览模型
	 */
	void      onButtonClick_Preview(cocos2d::Ref *sender,cocos2d::ui::Widget::TouchEventType eventType);
	/*
	  *回调函数,调用此函数之后会在制定的位置弹出对话框
	  *groupType:调用此函数的曲线的类型
	  *param:曲线传入的参数,其具体的含义由曲线的类型自定义
	  *xyz:弹出UI的位置,此位置需要曲线自己定义,注意这里我们给出的是3维的坐标,一般来讲Z坐标不会用到,这个视具体的实现而定
	  *onConfirmCallback:当点击确定按钮的时候的回调函数
	 */
	void      onPopupDialog(GroupType groupType,int param,const cocos2d::Vec3   &xyz,std::function<void (const FishInfo &)> onConfirmCallback);
	/*
	  *查询鱼的相关信息
	 */
	const FishInfo     &queryFishInfo(int fishId);
};

#endif