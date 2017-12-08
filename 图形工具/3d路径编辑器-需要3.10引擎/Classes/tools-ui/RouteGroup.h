/*
  *����·��Ԥ��,���ǲ�֧�ֱ༭����,ֻ����Ϊһ�����Թ۲�Ķ���
  *2017-10-23 11:33:52
  *@Author:xiaoxiong
 */
#ifndef __ROUTE_GROUP_H__
#define __ROUTE_GROUP_H__
#include "cocos2d.h"
#include "ControlPointSet.h"
/*
  *RouteGroup����ʹ�õ��й����ߵ���Ϣ�ṹ
 */
struct RouteObject
{
	cocos2d::Vec3    *vertexData;//��������,���е��������ն�����ֱ�ߵ���ʽ��������
	int                         vertexCount;//�������ݵ���Ŀ
	int                        id;//·�����
};
/*
 */
class RouteGroup :public cocos2d::Node
{
	//���߶���ļ���
	std::map<int, RouteObject>     _routeMap;
	cocos2d::CustomCommand      _drawRouteCommand;
	cocos2d::GLProgram                *_glProgram;
	//ÿ��ֱ���������һ����ɫ
	std::map<int, cocos2d::Vec4>   _lineColorMap;
private:
	RouteGroup();
	bool         initWithRoute(const std::vector<ControlPointSet> &routePointVec,const std::vector<int> &fishIdVec,const std::map<int, FishVisual> &fishStatic);
public:
	~RouteGroup();
	/*
	  *�����ĺ���Ϊ:���߿��Ƶ�ļ���,�������Ÿ����������ߵ���ļ���,���й��������ϸ��Ϣ
	 */
	static RouteGroup *createWithRoute(const std::vector<ControlPointSet> &routePointVec, const std::vector<int> &fishIdVec, const std::map<int, FishVisual> &fishStatic);

	//�ص�����
	void        drawRouteCallback(const cocos2d::Mat4 &parentToNodeTransform,uint32_t  flag);
	/*
	  *draw
	 */
	void       draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& transform, uint32_t flags);
};
#endif
