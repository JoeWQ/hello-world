/*
  *螺旋曲线
  *@date:2017-7-12
  *@Author:xiaoxiong
  @Version:1.0 实现了圆柱螺旋线
  @Version:2.0 实现圆锥螺旋线
 */
#ifndef __SPIRAL_NODE_H__
#define __SPIRAL_NODE_H__
#include "cocos2d.h"
#include "CurveNode.h"
#include "DrawNode3D.h"
/*
  *螺旋曲线节点,初始螺旋线为旋转轴朝向正Y轴,中心在OpenGL世界坐标系原点
  *半径为100.0f,其中旋转轴可以被拖动旋转移动
  *在目前的版本中,只实现了最基本的圆柱螺旋线,在下一版本中将实现更加高级的圆锥螺旋线
 */
class SpiralNode :public CurveNode
{
private:
	//螺旋线的旋转轴,必须经过单位化,初始值为(0,1.0f,0.0f)
	cocos2d::Vec3						 _rotateAxis;
	//半径
	float											 _radius0;
	float                                         _radius1;
	//螺旋线的匝数
	float                                         _windCount;
	//每一匝螺旋线的高度
	float                                         _spiralHeight;
	//关于曲线的旋转
	cocos2d::Mat4                      _curveRotateMatrix;
	//关于曲线的模型矩阵
	cocos2d::Mat4                      _modelMatrix;
	//关于螺旋线的顶点数据,需要动态计算
	float                                         *_vertexData;
	//顶点的数目
	int                                              _vertexCount;
	/*
	  *五个控制点,每个控制点的意义请参见SpiralNode.cpp文件
	 */
	ControlPoint							*_controlPoints[6];
	//Shader
	cocos2d::GLProgram             *_glProgram;
	cocos2d::CustomCommand   _drawCommand;
	//Shader Position
	int                                             _positionLoc;
	int                                             _colorLoc;
	int                                             _modelMatrixLoc;
	cocos2d::DrawNode3D           *_axisNode;
	//上次选中的控制点
	int                                               _lastSelectIndex;
	//上次的坐标点
	cocos2d::Vec2                           _lastOffsetPoint;
	//回调函数
	std::function<void(SpiralValueType type,float radius)>  _radiusChangeCallback;
private:
	void  initSpiralNode();
	SpiralNode();
public:
	~SpiralNode();
	static SpiralNode *createSpiralNode();
	//设置曲线的控制点的数目,此函数为一个哑函数
	virtual void initControlPoint(int pointCount);
	//触屏回调,此回调函数都是在Control键被按下的时候调用
	virtual void onTouchBegan(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	virtual void onTouchMoved(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	virtual void onTouchEnded(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	/*
	*当按下的Ctrl键释放的时候的回掉函数
	*/
	virtual void    onCtrlKeyRelease();

	//浏览曲线模型的时候的回调函数
	virtual void   previewCurive(std::function<void()> callback);
	/*
	*使用给定的一系列控制点来初始化节点数据,必要的时候需要重新创建节点
	*/
	virtual void   initCurveNodeWithPoints(const std::vector<cocos2d::Vec3>  &points);
	/*
	*恢复当前节点的位置
	*/
	virtual void   restoreCurveNodePosition();
	virtual void   draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags);
	void               drawSpiralNode(cocos2d::Mat4 &parentTransform,uint32_t parentFlags);
	/*
	  *重新计算顶点的数目,
	  @param:needUpdateVertex是否需要更新顶点数据,false不需要,true需要
	 */
	void               updateVertexData(bool needUpdateVertex);
	/*
	  *由旋转轴计算相关的旋转矩阵
	 */
	void               updateRotateMatrix(const cocos2d::Vec3 &rotateAxis);
	/*
	  *从螺旋曲线节点中获取数据
	  *关于数据的格式,请参见SpiralNode.cpp文件
	 */
	virtual void  getControlPoint(ControlPointSet &cpoints);
	/*
	  *计算曲线的实际长度
	 */
	float             getSpiralLength()const;
	/*
	  *下半径发生变化的时候的回调函数
	  *type表半径的类型,也可以表示其他的类型
	  *目前0:下半径,1表示上半径
	 */
	void             setRadiusChangeCallback(std::function<void (SpiralValueType type,float radius)> callback);
	/*
	  *设置下半径
	 */
	void            setBottomRadius(float radius);
	/*
	  *设置上半径
	 */
	void            setTopRadius(float radius);
};
/*
  *螺旋曲线动作,
 */
class SpiralAction :public cocos2d::ActionInterval
{
private:
	cocos2d::Vec3  _rotateAxis;//旋转轴
	cocos2d::Vec3  _centerPoint;//中心坐标
	float                  _bottomRadius;//下方半径
	float                  _topRadius;//上方半径
	float                  _spiralHeight;//导程
	float                  _windCount;//匝数
	cocos2d::Mat4 _modelMatrix;//全部的数据合成的变换矩阵
private:
	/*
	  *数据排列的原则遵循getControlPoint函数中的说明
	 */
	void    initWithControlPoint(float duration,const std::vector<cocos2d::Vec3> &controlPoints);
	void    initWithControlPoint(float duration,const cocos2d::Vec3 &rotateAxis, const cocos2d::Vec3 &centerPoint, float bottomRadius, float topRadius, float spiralHeight, float windCount);
	//计算旋转矩阵
	void    updateRotateMatrix();
public:
	static SpiralAction *create(float duration,const cocos2d::Vec3 &rotateAxis,const cocos2d::Vec3 &centerPoint,float bottomRadius,float topRadius,float spiralHeight,float windCount);
	static SpiralAction *create(float duration,const std::vector<cocos2d::Vec3> &controlPoints);
	virtual  void update(float rate);
};
#endif