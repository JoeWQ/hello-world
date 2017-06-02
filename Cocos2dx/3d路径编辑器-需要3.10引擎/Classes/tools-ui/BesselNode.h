/*
  *贝塞尔曲线节点
  *目的在于方便矩阵操作,否则需要单独对所有的点进行3d坐标设置
  *@Version:1.0实现了最基本的3d场景显示
  *@Version:2.0实现了3d场景下网格系统,也使场景有了更好的3d体验
  *@Version:3.0 加入了3d路径演示的功能
  *2017-3-22
  *@Author:xiaoxiong
 */
#ifndef __BESSEL_NODE_H__
#define __BESSEL_NODE_H__
#include "cocos2d.h"
#include"BesselSet.h"
/*
  *贝塞尔曲线点
 */
class BesselPoint :public cocos2d::Node
{
private:
	//3d模型,为了方便在3d空间中对远近概念有直观的视觉感受
	cocos2d::Sprite3D    *_modelSprite;
	//节点的顺序,贝塞尔曲线节点的顺序不同，最后形成的曲线路径也不同
	cocos2d::Sprite          *_sequence;
	//图标
	cocos2d::Sprite         *_iconSprite;
private:
	BesselPoint();
	void      initBesselPoint(int index);
public:
	~BesselPoint();
	static BesselPoint   *createBesselPoint(int index);
};
/*
  *N阶贝塞尔曲线动作
  *
  */
class   BesselNAction :public cocos2d::ActionInterval
{
private:
	std::vector<cocos2d::Vec3 >  _besselPoints;
public:
	/*
	  *duration:持续的时间
	  *pointSequence:贝塞尔控制点的序列
	 */
	static BesselNAction  *createWithDuration(float duration,std::vector<cocos2d::Vec3> &pointSequence);
	virtual  void startWithTarget(cocos2d::Node *target);
	virtual  void update(float time);
private:
	void       initWithControlPoints(float d,std::vector<cocos2d::Vec3> &pointSequence);
};
/*
  *需要注意的是.节点的中心点在屏幕的中心,这是因为在工具的UI，我们已经假定我们的所有的操作全部按照OpenGL世界坐标系
  */
class BesselNode :public cocos2d::Node
{
private:
	//贝塞尔曲线点的集合
	std::vector<BesselPoint *>  _besselContainer;
	//实际的顶点的数目
	int                                          _besselPointSize;
	//OpenGL程序对象
	cocos2d::GLProgram          *_lineProgram;
	//曲线的颜色
	cocos2d::Vec4                 _lineColor;
	//
	cocos2d::CustomCommand		_drawBesselCommand;
	//position of uniform
	int           _positionLoc;
	int           _colorLoc;
	int           _modelMatrixLoc;
	//当前的偏移向量
	cocos2d::Vec2    _offsetVec2;
	/*
	  *对整个3d场景而言,最为关键的部分
	  *3维旋转矩阵
	 */
	cocos2d::Mat4     _rotateMatrix;
	/*
	  *上次选中的点坐标
	  *以及相关的点坐标
	 */
	int                         _lastSelectIndex;
	cocos2d::Vec2     _lastOffsetVec2;
private:
	BesselNode();
	void        initBesselNode();
public:
	~BesselNode();

	static  BesselNode  *createBesselNode();

	void        drawBesselPoint(cocos2d::Mat4  &parentTransform,uint32_t flag);

	virtual  void   visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags);
	/*
	*初始化贝塞尔曲线点
	*@param:pointCount为曲线的控制点的数目
	*初始为3个控制点
	*/
	void   initBesselPoint(int pointCount);
	/*
	  *设置曲线的颜色
	 */
	void   setLineColor(cocos2d::Vec4 &);
	/*
	  *设置场景的旋转矩阵
	  *此函数并不是必须的,但是可以简化cocos2d引擎中几何变换函数的调用
	 */
	void   setRotateMatrix(const cocos2d::Mat4 &);
	/*
	  *用来控制曲线旋转的触屏回掉函数
	  *touchPoint:必须是以中心点为屏幕的中心的OpenGL世界坐标系下的点坐标
	 */
	void   onTouchBegan(const   cocos2d::Vec2   &touchPoint,cocos2d::Camera  *camera);

	void   onTouchMoved(const   cocos2d::Vec2   &touchPoint,cocos2d::Camera *camera);

	void   onTouchEnded(const    cocos2d::Vec2   &touchPoint,cocos2d::Camera *camera);
	/*
	  *当按下的Ctrl键释放的时候的回掉函数
	 */
	void    onCtrlKeyRelease();
	/*
	*三维投影矩阵变换
	*/
	void   projectToOpenGL(cocos2d::Camera *camera,const cocos2d::Vec3  &src, cocos2d::Vec3   &dts);
	/*
	  *获取当前的贝塞尔控制点信息
	  */
	void   getBesselPoints(BesselSet &);
	/*
	  *预览当前已经生成的曲线
	  */
	//输入函数为去先浏览完毕之后的后调函数
	void   previewCurive(std::function<void  (float )> actionFinishedCallback);
	/*
	  *使用给定的一系列控制点来初始化节点数据,必要的时候需要重新创建节点
	  */
	void   initBesselNodeWithPoints(const std::vector<cocos2d::Vec3>  &points);
	/*
	  *恢复当前节点的位置
	 */
	void   restoreBesselNodePosition();
};

#endif