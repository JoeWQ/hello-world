/*
  *群体翻滚运动
  *2017-8-4
  *@Author:xiaohuaxiong
 */
#ifndef __ROLLING_GROUP_H__
#define __ROLLING_GROUP_H__
#include "extensions/cocos-ext.h"
#include "ui/CocosGUI.h"
#include "GroupRoute.h"
//每一个空间圆的参数方程
struct CycleEquation
{
	cocos2d::Vec3 centerPoint;//中心坐标点
	float                  radius;//半径
};
/*
  *群体翻滚运动
 */
class RollingRoute :public GroupRoute
{
	//方向
	cocos2d::Vec3    _tangent;
	//整个图形线条坐落的位置,默认位置为屏幕的中心点,实际上他也是节点的坐标
	cocos2d::Vec3   _location;
	//椭圆的方程式,参数a,b的取值范围为:最大屏幕的尺寸的一半,最小屏幕的1/4倍
	cocos2d::Vec2   _abEquation;
	//直线的方程式,此直线穿过椭圆的两端点与中心
	cocos2d::Vec3   _originLocation, _finalLocation;
	cocos2d::Vec3   _lineVertex[2];
	//横向XOY椭圆顶点数据
	cocos2d::Vec3    *_xoyVertex;
	int                         _xoyVertexSize;
	//纵向YOZ圆数据
	cocos2d::Vec3    *_yozVertex;
	int                         _yozVertexSize;
	//横向椭圆平分圆周多少次,最大约束在RollingGroup.cpp中
	int                         _windHCount;
	//纵向圆的数目,其约束范围在RollingGroup.cpp中
	int                         _windVCount;
	//Shader
	cocos2d::GLProgram              *_glProgram;
	//position loc
	int                                               _positionLoc;
	//color loc
	int                                               _colorLoc;
	//Model Matrix
	int                                              _modelMatrixLoc;
	//color
	cocos2d::Vec4                           _color;
	//渲染
	cocos2d::CustomCommand    _drawGroupCommand;
	//横向矩阵变换序列
	std::vector<cocos2d::Mat4>   _modelHMatrixVector;
	//纵向矩阵变换序列
	std::vector<cocos2d::Mat4>   _modelVMatrixVector;
	std::vector<CycleEquation>    _cycleEquations;
	//直线的变换矩阵
	cocos2d::Mat4                          _modelLineMatrix;
	//存储所有空间圆与空间椭圆的交点,键就是_cycleEquation的索引,
	std::map<int , std::vector<cocos2d::Vec3>>   _intersectPointMap;
	//在圆周交叉点的Sprite3D模型,模型的tag为鱼的Id如果没有就为nullptr
	std::map<int, std::vector<cocos2d::Sprite3D*>>   _intersectSprite3DMap;
	//显示椭圆与圆周交叉点的精灵,此精灵不参与计算,纯粹显示
	std::map<int, std::vector<cocos2d::Sprite*>>         _intersectSpriteMap;
	//每个纵向圆周的控制点,位于圆周和椭圆序列的中心线的交点,且最后一个是整个节点的中心控制点
	std::vector<ControlPoint *>   _cycleControlPoints;
	//当前选中的控制点的索引
	int                                              _lastSelectedIndex;
	//上次的触屏点
	cocos2d::Vec2                          _lastOffsetVec2;
	//与圆周的交叉情况
	int                                             _intersectCycleIndex;
private:
	RollingRoute();
	RollingRoute(const RollingRoute &);
	bool       initWithLayer();
public:
	~RollingRoute();
	static RollingRoute *create();
	/*
	  *创建Layer层,用来控制整个曲线的运作
	 */
	virtual cocos2d::Layer *getControlLayer();
	/*
	  *触屏回调函数
	 */
	virtual bool onTouchBegan(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	virtual void  onTouchMoved(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	virtual void  onTouchEnded(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	/*
	  *右键回调,只实现了其中的一个
	 */
	virtual void onMouseClick(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera);
	/*
	  *获取数据
	 */
	virtual void   getGroupData(GroupData &output);
	//draw
	virtual  void draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& transform, uint32_t flags);
	/*
	  *画整个运动曲线结构
	 */
	void             drawGroup(const cocos2d::Mat4 &transform,uint32_t flags);
	//更新顶点数据
	//check:是否需要检查更新的必要性
	void             updateVertex(bool needCheck);
	//更新场景的矩阵变换,此函数调用用来处理已经建立好了的顶点数据/矩阵变换
	//offsetVec3:表示中心点的平移坐标
	void             updateTranformMatrix(const cocos2d::Vec3 &offsetVec3);
	//更新某一条纵向圆
	void             updateSomeCycle(int selectIndex,cocos2d::Vec3 &offsetVec3);
	//调用上层的弹出对话框时需要传入的回调函数
	void             onChooseDialogConfirmCallback(const FishInfo &fishInfo);
};
////////////////////////////控制整个曲线的Layer层///////////////////
class LayerRolling :public cocos2d::Layer
{
	/*
	  *此类有2个功能,一是控制滚动的横向曲线数目
	  *二是与纵向曲线的重复数目
	 */
private:
	cocos2d::ui::ScrollView    *_scrollViewEllipse;//控制椭圆的重复度
	cocos2d::ui::ScrollView    *_scrollViewCycle;//控制圆周的重复度
	//伸缩Button
	cocos2d::ui::Button          *_hideSpreadButton;
	//关于RollingGroup对象的引用
	RollingRoute                     *_rollingRouteGroup;
private:
	LayerRolling(RollingRoute *rollingGroup);
	LayerRolling(const LayerRolling &);
	bool     init();
public:
	static LayerRolling *create(RollingRoute *rollingGroup);

	/*
	  *组按钮回调函数,切换椭圆的重复度
	 */
	void onRadioButtonClick_SelectEllipse(cocos2d::ui::RadioButton *radioButton, cocos2d::ui::RadioButton::EventType type);
	/*
	  *切换圆的重复度
	 */
	void onRadioButtonClick_SelectCycle(cocos2d::ui::RadioButton *radioButton, cocos2d::ui::RadioButton::EventType type);
	/*
	  *点击按钮的时候伸缩面板
	 */
	void onButtonClick_HideOrSpread(cocos2d::Ref *sender,cocos2d::ui::Widget::TouchEventType eventType);
};
#endif