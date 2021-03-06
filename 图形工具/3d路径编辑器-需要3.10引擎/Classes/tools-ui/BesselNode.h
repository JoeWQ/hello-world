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
#include"ControlPointSet.h"
#include "BezierRoute.hpp"
#include "Common.h"
#include "DrawNode3D.h"
#include "CurveNode.h"
/*
  *N阶贝塞尔曲线动作
  *
  */
class   BesselNAction :public cocos2d::ActionInterval
{
private:
	std::vector<int >             _actionIndexVec;
	std::function<void(const cocos2d::Vec3 &position)>   _callback;
	FishVisual							_fishVisualMap;
public:
	/*
	  *duration:持续的时间
	  *pointSequence:贝塞尔控制点的序列
	 */
	static BesselNAction  *createWithDuration(float duration,std::vector<int> &actionIndexVec, BezierRoute* _route);
	static BesselNAction  *createWithBezierRoute(float speed, BezierRoute* _route);
	virtual  void startWithTarget(cocos2d::Node *target);
    virtual void step(float dt) override;
	virtual void update(float time);
	void              setCallback(std::function<void(const cocos2d::Vec3 &)> callback) { _callback = callback; };
	void     setAnimationFile(const std::string &filename) { _aniFile = filename; };
	void     setActionIndex(int actionIndex) { _actionIndex = actionIndex; };
	void     setActionIndexVec(const std::vector<int> &actionIndexVec) {_actionIndexVec = actionIndexVec;};
	void     setFishVisual(const FishVisual &fishVisual) { _fishVisualMap = fishVisual; };
public:
	BesselNAction();
	~BesselNAction();
	void       initWithControlPoints(float d,std::vector<int> &actionIndexVec);
    void		  initWithBezierRoute(float speed, BezierRoute* _route);
    BezierRoute* _route;
	float   _distance;
	float   _pastDistance;
    float _lastTime;
    float _speed;
    struct State {
        float m_fSpeedCoef;
        cocos2d::Vec3 m_Position;
        cocos2d::Vec3 m_Direction;
    };
    State m_pBaseInterpState;
    float m_fLastInterp;
	//动画的文件名/全名
	std::string   _aniFile;
	//当前经过的控制点的索引
	int                _controlPointIndex;
	int                _actionIndex;
};
/*
  *需要注意的是.节点的中心点在屏幕的中心,这是因为在工具的UI，我们已经假定我们的所有的操作全部按照OpenGL世界坐标系
  */
class BesselNode :public CurveNode
{
private:
	//贝塞尔曲线点的集合
	std::vector<ControlPoint *>  _besselContainer;
	//实际的顶点的数目
	//int                                          _besselPointSize;
	//OpenGL程序对象
	cocos2d::GLProgram          *_lineProgram;
	//曲线的颜色
	cocos2d::Vec4                 _lineColor;
	//
	cocos2d::CustomCommand		_drawBesselCommand;
	//position of uniform
	int           _positionLoc;
	int           _colorLoc;
	//当前的偏移向量
	cocos2d::Vec2    _offsetVec2;
	/*
	  *上次选中的点坐标
	  *以及相关的点坐标
	 */
	int                         _lastSelectIndex;
	//当前选中的控制点,该控制点会被用来处理节点速度
	int                        _currentSelectIndex;
	cocos2d::Vec2     _lastOffsetVec2;
    
    BezierRoute* _bezierRoute;
    std::vector<CubicBezierRoute::PointInfo> _controlPoints;
	//按下Ctrl+Z键的时候回退,只能回退一次
	int                       _backTraceindex;
	std::function<void(int)> _selectedCallback;
private:
	BesselNode();
	void        initBesselNode();
public:
	~BesselNode();
    
    
    virtual void onEnter();
    
    virtual void setWeight(float weight);

	static  BesselNode  *createBesselNode();

	void        drawBesselPoint(cocos2d::Mat4  &parentTransform,uint32_t flag);

	virtual  void   draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags);
	/*
	*初始化贝塞尔曲线点
	*@param:pointCount为曲线的控制点的数目
	*初始为3个控制点
	*/
	virtual void   initControlPoint(int pointCount);
	/*
	  *用来控制曲线旋转的触屏回掉函数
	  *touchPoint:必须是以中心点为屏幕的中心的OpenGL世界坐标系下的点坐标
	 */
	virtual bool   onTouchBegan(const   cocos2d::Vec2   &touchPoint,cocos2d::Camera  *camera);
	virtual void   onTouchMoved(const   cocos2d::Vec2   &touchPoint,cocos2d::Camera *camera);
	virtual void   onTouchEnded(const    cocos2d::Vec2   &touchPoint,cocos2d::Camera *camera);
	/*
	  *响应鼠标右键的函数,此为用来在曲线中间进行插值的点
	 */
	virtual void onMouseClick(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera);
	virtual void onMouseMoved(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera);
	virtual void onMouseReleased(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera);
	/*
	  *用来操作当前预览的模型
	 */
	virtual void onMouseClickCtrl(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera);
	/*
	  *当按下的Ctrl键释放的时候的回掉函数
	 */
	virtual void    onCtrlKeyRelease();
	/*
	  *当按下Ctrl+Z键的时候
	*/
	virtual void onCtrlZPressed();
	/*
	  *获取当前的贝塞尔控制点信息
	  */
	virtual void   getControlPoint(ControlPointSet &)override;
	/*
	  *预览当前已经生成的曲线
	输入函数为去先浏览完毕之后的后调函数
	*/
	virtual void   previewCurive(std::function<void()> callback)override;
	/*
	  *使用给定的一系列控制点来初始化节点数据,必要的时候需要重新创建节点
	  */
	virtual void   initCurveNodeWithPoints(const ControlPointSet  &controlPointSet)override;
	/*
	  *恢复当前节点的位置
	 */
	void   restoreCurveNodePosition();
	/*
	  *预览模型的时候设置需要使用的模型的信息
	 */
	virtual void   setPreviewModel(const FishVisual &fishMap)override;
    
    void setTouchSelectedCallback(std::function<void (int)> callback) {_selectedCallback = callback;}
    
    cocos2d::DrawNode3D* drawNode;
    
    bool showLines;
	/*
	  *获取当前选中的控制点,如果没有选中任何一个,则返回nullptr
	 */
	ControlPoint  *getSelectControlPoint()const;
};

#endif
