/*
  *所有群体运动的父类
  *里面集成了所有子类需要实现的函数
  *@2017-8-4
  *@Author:xiaohuaxiong
 */
#ifndef __GROUP_ROUTE_H__
#define __GROUP_ROUTE_H__
#include "cocos2d.h"
#include "common/common.h"
/*
  *群体运动产生的数据
 */
class GroupData
{
	GroupType								 _groupType;
	std::vector<cocos2d::Vec4> _groupPoint;
public:
	GroupData(GroupType groupType);
	//将里面的数据格式化
	void     format(std::string &output);
};
class GroupRoute :public cocos2d::Node
{
protected:
	//曲线的类型
	GroupType           _groupType;
	//必须提供一个Layer,此Layer是用来操纵曲线对象的
	cocos2d::Layer   *_controlLayer;
	//节点的3d旋转的旋转矩阵,也可以直接通过欧拉角计算,也可以直接获取
	cocos2d::Mat4           _rotateMatrix;
	//回调函数,此函数可以调出对话框
	std::function<void(GroupType groupType, int param, const cocos2d::Vec3   &xyz, std::function<void(const FishInfo &)> onConfirmCallback)> _chooseDialogUICallback;
	//上层UI传入的查询函数,查询鱼的FishId
	std::function<const FishInfo & (int fishId)>         _queryFishCallback;
protected:
	GroupRoute(GroupType groupType);
public:
	GroupType   getType()const { return _groupType; };
	/*
	  *上层的回调函数,当触发触屏事件且Ctrl按键按下的时候调用
	 */
	virtual  bool  onTouchBegan(const cocos2d::Vec2 &touchPoint,cocos2d::Camera *camera);
	virtual  void  onTouchMoved(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	virtual  void  onTouchEnded(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	/*
	  *点击鼠标右键的时候回调函数
	 */
	virtual  void  onMouseClick(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera);
	virtual  void  onMouseMoved(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera);
	virtual  void  onMouseEnded(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera);
	//公共函数,将三维坐标转换成2d屏幕坐标,并保留了顶点的深度
	void      project2d(cocos2d::Camera *camera,const cocos2d::Vec3 &src3D,cocos2d::Vec3 &dst3d);
	//将给出的2维坐标转换成上层的UI坐标
	cocos2d::Vec2    convertUICoord(const cocos2d::Vec2 &src);
	//提供一个用来操作曲线的Layer,并且Layer的大小必须给出,上层UI需要用到这个数据来对Layer做适配
	cocos2d::Layer *getControlLayer();
	//从曲线中获取数据,此数据用来保存在文件中
	void      getGroupData(GroupData &output);
	/*
	  *设置旋转矩阵
	 */
	void     setRotateMatrix(const cocos2d::Mat4 &rm);
	/*
	  *设置注册函数,此函数不需要子类调用,只有框架本身使用
	 */
	void    registerChooseDialogUICallback(std::function<void(GroupType groupType, int param, const cocos2d::Vec3   &xyz, std::function<void(const FishInfo &)> onConfirmCallback)> callback);
	/*
	  *给定鱼的fishId，查询和该fishId的相关信息
	 */
	const FishInfo &queryFishInfo(int fishId)const;
	/*
	  *此函数不应再子类中调用,只用来被框架使用
	 */
	void   registerQueryFishInfoCallback(std::function<const FishInfo & (int fishId)> callback);
};
///////////////////////////////////控制点///////////////////////////////
class ControlPoint :public cocos2d::Node
{
private:
	//3d模型,为了方便在3d空间中对远近概念有直观的视觉感受
	cocos2d::Sprite3D    *_modelSprite;
	//节点的顺序,贝塞尔曲线节点的顺序不同，最后形成的曲线路径也不同
	cocos2d::Label          *_sequence;
	//图标
	cocos2d::Sprite         *_iconSprite;
	//在控制点上画出坐标轴
	//cocos2d::DrawNode3D *_drawNode3D;
	int                                _index;
private:
	ControlPoint();
	void      initControlPoint(int index);
public:
	~ControlPoint();
	static ControlPoint   *createControlPoint(int index);
	/*
	*修改控制点的次序
	*/
	void   changeSequence(int index);
	/*
	*需要手工开启该函数
	*/
	void     drawAxis();//画坐标轴

	float _speedCoef;
};
#endif