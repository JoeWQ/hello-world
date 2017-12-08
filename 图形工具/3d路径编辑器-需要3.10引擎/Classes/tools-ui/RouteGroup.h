/*
  *多条路线预览,但是不支持编辑功能,只能作为一个可以观察的对象
  *2017-10-23 11:33:52
  *@Author:xiaoxiong
 */
#ifndef __ROUTE_GROUP_H__
#define __ROUTE_GROUP_H__
#include "cocos2d.h"
#include "ControlPointSet.h"
/*
  *RouteGroup对象将使用的有关曲线的信息结构
 */
struct RouteObject
{
	cocos2d::Vec3    *vertexData;//顶点数据,所有的数据最终都会以直线的形式被画出来
	int                         vertexCount;//顶点数据的数目
	int                        id;//路径编号
};
/*
 */
class RouteGroup :public cocos2d::Node
{
	//曲线对象的集合
	std::map<int, RouteObject>     _routeMap;
	cocos2d::CustomCommand      _drawRouteCommand;
	cocos2d::GLProgram                *_glProgram;
	//每条直线随机生成一个颜色
	std::map<int, cocos2d::Vec4>   _lineColorMap;
private:
	RouteGroup();
	bool         initWithRoute(const std::vector<ControlPointSet> &routePointVec,const std::vector<int> &fishIdVec,const std::map<int, FishVisual> &fishStatic);
public:
	~RouteGroup();
	/*
	  *参数的含义为:曲线控制点的集合,关于沿着该条曲线行走的鱼的集合,所有关于鱼的详细信息
	 */
	static RouteGroup *createWithRoute(const std::vector<ControlPointSet> &routePointVec, const std::vector<int> &fishIdVec, const std::map<int, FishVisual> &fishStatic);

	//回调函数
	void        drawRouteCallback(const cocos2d::Mat4 &parentToNodeTransform,uint32_t  flag);
	/*
	  *draw
	 */
	void       draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& transform, uint32_t flags);
};
#endif
