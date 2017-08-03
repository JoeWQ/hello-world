/*
  *曲线节点,为了扩充曲线的类型并且不引入更多的不必要的复杂性,而引入的类
  *@date:2017-07-12
  *@Author:xiaoxiong
 */
#ifndef __CURVE_NODE_H__
#define __CURVE_NODE_H__
#include "cocos2d.h"
#include "Common.h"
#include "ControlPointSet.h"
#include "DrawNode3D.h"
/*
  *对于这个类的某些函数,如果其子类不支持某些功能,可以将与该功能对应的函数设置为不支持的函数
 */
class CurveNode :public cocos2d::Node
{
protected:
	CurveType        _curveType;
	cocos2d::Vec4  _lineColor;
	/*
	*对整个3d场景而言,最为关键的部分
	*3维旋转矩阵
	*/
	cocos2d::Mat4     _rotateMatrix;
	FishVisual			  _fishVisual;
	float _previewSpeed;//预览的速度
	//是否支持控制点的选择
	bool              _isSupportedControlPoint;
	float _weight;
protected:
	void              setSupportedControlPoint(bool b) { _isSupportedControlPoint = b; };
protected:
	CurveNode(CurveType curveType);
public:
	CurveType  getType()const { return _curveType; };
	//设置场景的旋转矩阵
	void     setRotateMatrix(const cocos2d::Mat4 &rotateM);
	//设置曲线的颜色
	void     setLineColor(const cocos2d::Vec4 &lineColor);
	//设置曲线的权重
	virtual  void  setWeight(float weight);
	//设置曲线的控制点的数目,如果函数不支持此功能,可以不用实现
	virtual void   initControlPoint(int pointCount);
	/*
	*用来控制曲线旋转的触屏回掉函数,此函数都是在Control按键被按下的时候调用
	*touchPoint:必须是以中心点为屏幕的中心的OpenGL世界坐标系下的点坐标
	*/
	virtual void   onTouchBegan(const   cocos2d::Vec2   &touchPoint, cocos2d::Camera  *camera);

	virtual void   onTouchMoved(const   cocos2d::Vec2   &touchPoint, cocos2d::Camera *camera);

	virtual void   onTouchEnded(const    cocos2d::Vec2   &touchPoint, cocos2d::Camera *camera);
	/*
	*当按下的Ctrl键释放的时候的回掉函数
	*/
	virtual void    onCtrlKeyRelease();
	/*
	*三维投影矩阵变换
	*/
	void   projectToOpenGL(cocos2d::Camera *camera, const cocos2d::Vec3  &src, cocos2d::Vec3   &dts);
	/*
	*获取当前的贝塞尔控制点信息
	*/

	//输入函数为去先浏览完毕之后的后调函数
	virtual void   previewCurive(std::function<void()> callback);
	/*
	*使用给定的一系列控制点来初始化节点数据,必要的时候需要重新创建节点
	*/
	virtual void   initCurveNodeWithPoints(const std::vector<cocos2d::Vec3>  &points);
	/*
	*恢复当前节点的位置
	*/
	virtual void   restoreCurveNodePosition();
	/*
	*预览模型的时候设置需要使用的模型的信息
	*/
    virtual void   setPreviewModel(const FishVisual &fishMap);
	/*
	  *获取节点的信息
	 */
	virtual void  getControlPoint(ControlPointSet &);
	/*
	  *设置速度
	 */
	virtual void  setPreviewSpeed(float speed);
	/*
	  *是否支持控制点选择,贝赛尔曲线支持,但是螺旋曲线不支持
	 */
	bool  isSupportedControlPoint() { return _isSupportedControlPoint; };
};
/*
*关于曲线控制点的外观标志
*/
class BesselNode;
class SpiralNode;
class ControlPoint :public cocos2d::Node
{
	friend class CureveNode;
	friend class BesselNode;
	friend class SpiralNode;
private:
	//3d模型,为了方便在3d空间中对远近概念有直观的视觉感受
	cocos2d::Sprite3D    *_modelSprite;
	//节点的顺序,贝塞尔曲线节点的顺序不同，最后形成的曲线路径也不同
	cocos2d::Label          *_sequence;
	//图标
	cocos2d::Sprite         *_iconSprite;
	//在控制点上画出坐标轴
	cocos2d::DrawNode3D *_drawNode3D;
private:
	ControlPoint();
	void      initControlPoint(int index);
public:
	~ControlPoint();
	static ControlPoint   *createControlPoint(int index);
	/*
	  *需要手工开启该函数
	 */
	void     drawAxis();//画坐标轴
    
    float _speedCoef;
};
#endif
