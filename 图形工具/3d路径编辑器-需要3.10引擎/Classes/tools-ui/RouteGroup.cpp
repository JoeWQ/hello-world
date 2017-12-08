/*
  *群组路径路线预览实现
  *2017-10-23 12:00:05
  *@Author:xiaoxiong
 */
#include "RouteGroup.h"
#include "BesselNode.h"
#include "SpiralNode.h"
USING_NS_CC;
/*
  *创建贝赛尔曲线
 */
static void  _static_createBesselRoute(const ControlPointSet &controlPoints, RouteObject &route,Sprite3D *sprite)
{
	//Vec3集合
	//std::vector<Vec3>   points;
	//points.reserve(8);
	//std::vector<CubicBezierRoute::PointInfo>::const_iterator it=controlPoints._pointsSet.cbegin();
	//for (; it != controlPoints._pointsSet.cend(); ++it)
	//{
	//	points.push_back((*it).position);
	//}
	////创建贝赛尔曲线对象
	//int pointNumber = points.size();
	//std::vector<cocos2d::Vec3> curvePoints;
	//std::vector<cocos2d::Vec3> vertices;

	//for (int i = 0; i < pointNumber; i++)
	//{
	//	int index_back = (pointNumber + i - 1) % pointNumber;
	//	int index_forward = (i + 1) % pointNumber;
	//	Vec3 mid_back = (points[index_back] + points[i]) / 2;
	//	Vec3 mid_forward = (points[index_forward] + points[i]) / 2;
	//	float dist_back = points[index_back].distance(points[i]);
	//	float dist_forward = points[index_forward].distance(points[i]);
	//	Vec3 control_point_back = (mid_back - mid_forward) * dist_back * 0.5f / (dist_back + dist_forward) + points[i];
	//	Vec3 control_point_forward = (mid_forward - mid_back) * dist_forward * 0.5f / (dist_back + dist_forward) + points[i];

	//	curvePoints.push_back(control_point_back);
	//	curvePoints.push_back(control_point_forward);
	//}

	//for (int i = 1; i < pointNumber - 2; i++)
	//{
	//	Vec3& p0 = points[i];
	//	Vec3& p1 = curvePoints[(i * 2 + 1) % (pointNumber * 2)];
	//	Vec3& p2 = curvePoints[(i * 2 + 2) % (pointNumber * 2)];
	//	Vec3& p3 = points[(i + 1) % pointNumber];

	//	Vec3 a = -1 * p0 + 3 * p1 - 3 * p2 + p3;
	//	Vec3 b = 3 * p0 - 6 * p1 + 3 * p2;
	//	Vec3 c = -3 * p0 + 3 * p1;
	//	Vec3 d = p0;

	//	Vec3 da = -3 * p0 + 9 * p1 - 9 * p2 + 3 * p3;
	//	Vec3 db = 6 * p0 - 12 * p1 + 6 * p2;
	//	Vec3 dc = -3 * p0 + 3 * p1;

	//	float t = 0.0;
	//	do 
	//	{
	//		float t0 = t;
	//		float t1 = t = t + 1.0 / (t * t * da + t * db + dc).length();
	//		t1 = t = t > 1.0 ? 1.0 : t;
	//		Vec3 from = t0 * t0 * t0 * a + t0 * t0 * b + t0 * c + d;
	//		vertices.push_back(from);
	//	} while (t != 1);
	//}
	//计算集合
	std::vector<CubicBezierRoute::PointInfo> bezierPoints;
	for (int i = 0; i < controlPoints._pointsSet.size(); i++)
	{
		bezierPoints.push_back(controlPoints._pointsSet[i]);
	}
	//计算动作
	CubicBezierRoute   *bezierRoute = new CubicBezierRoute();
	bezierRoute->addPoints(bezierPoints);
	bezierRoute->autorelease();
	//数据复制
	const std::vector<Vec3> &vertices = bezierRoute->getCachedPosition();
	route.vertexData = new cocos2d::Vec3[vertices.size()];
	route.vertexCount = vertices.size();
	memcpy(route.vertexData,vertices.data(),sizeof(Vec3)*vertices.size());
	//
	BesselNAction *action= BesselNAction::createWithBezierRoute(100.0f, bezierRoute);
	sprite->runAction(RepeatForever::create(action));
}
/*
  *创建螺旋曲线对象
 */
static void _static_createSpiralRoute(const ControlPointSet &controlPoints,RouteObject &route,Sprite3D *sprite)
{
	/*
	  *将顶点写到集合中
	 */
	std::vector<Vec3>   points;
	points.reserve(8);
	std::vector<CubicBezierRoute::PointInfo>::const_iterator it = controlPoints._pointsSet.cbegin();
	for (; it != controlPoints._pointsSet.cend(); ++it)
	{
		points.push_back((*it).position);
	}
	//
	Vec3  rotateAxis = points[0];//旋转轴
	const Vec3 &point = points[2];
	//下上半径
	float radius0 = point.x;
	float radius1 = point.y;
	//导程
	float spiralHeight = point.z;
	//匝数
	float windCount = points[3].x;
	float clockwise = points[3].y;

	//旋转矩阵
	Vec3  axis;
	Vec3::cross(Vec3(0.0f, 1.0f, 0.0f), rotateAxis, &axis);
	axis.normalize();
	const float dotValue = Vec3::dot(rotateAxis, Vec3(0.0f, 1.0f, 0.0f));
	const float angle = acosf(dotValue);
	Mat4 _curveRotateMatrix;
	Mat4::createRotation(axis, angle, &_curveRotateMatrix);

	const float height = spiralHeight*windCount;
	//旋转轴的位置
	auto centerPoint = points[1];
	//计算级联矩阵
	Mat4  translateMatrix,modelMatrix;
	cocos2d::Mat4::createTranslation(centerPoint, &translateMatrix);
	modelMatrix = translateMatrix * _curveRotateMatrix;

	//计算顶点数据
	float length = 0.0f;
	//计算曲线的长度
	const int integrity = (int)windCount;//完整的周期
	const float frag = windCount - integrity;//剩余的不足一个的周期
	const float realRadius = radius0 + (radius1 - radius0) / windCount * integrity;
	for (int k = 1; k <= integrity; ++k)
	{
		float lastRadius = radius0 + 1.0f *(k - 1) / integrity * (realRadius - radius0);
		float nowRadius = radius0 + 1.0f *k / integrity * (realRadius - radius0);
		float tmp = (lastRadius + nowRadius)*M_PI;
		length += sqrtf(tmp * tmp + spiralHeight * spiralHeight);
	}
	//累计上剩余的尾巴
	float tmp = M_PI *(realRadius + realRadius + 1.0f / integrity *(realRadius - radius0));
	length += frag * sqrtf(tmp * tmp + spiralHeight * spiralHeight);
	//分段,每6像素一条线段
	float seg = 6.0f;
	if (length > 1000000)
		seg = 48;
	else if (length > 100000)
		seg = 24;
	else if (length > 50000)
		seg = 16;
	else if (length > 10000)
		seg = 8;
	route.vertexCount = ceil(length / seg);
	route.vertexData = new Vec3[route.vertexCount];
	int  index = 0;
	//注意半高度是指曲线的高度的一半而非曲线的积分的一半
	const float halfHeight = height / 2.0f;
	const float paix2 = 2.0f * M_PI * clockwise;//此代码决定这整个曲线是否是逆时针旋转
	const float totalAngle = paix2 * windCount;
	for (int k = 0; k < route.vertexCount; ++k)
	{
		const float rate = 1.0f *k / route.vertexCount;
		float  angle = rate * totalAngle;
		float radius = radius0 + (radius1 - radius0)*angle / totalAngle;
		route.vertexData[index].x = radius * sinf(angle);
		float vertexHeight = spiralHeight * angle / paix2 - halfHeight;
		route.vertexData[index].y = vertexHeight;
		route.vertexData[index].z = radius * cosf(angle);
		//需要经过矩阵变换
		modelMatrix.transformPoint(route.vertexData + index);
		++index;
	}
	//计算相关的动作
	float duration = length / 100.0f;
	SpiralAction *action = SpiralAction::create(duration,points);
	sprite->runAction(RepeatForever::create(action));
}

RouteGroup::RouteGroup():
	_glProgram(nullptr)
{

}

RouteGroup::~RouteGroup()
{
	_glProgram->release();
	_glProgram = nullptr;
}

RouteGroup *RouteGroup::createWithRoute(const std::vector<ControlPointSet> &routePointVec, const std::vector<int> &fishIdVec, const std::map<int, FishVisual> &fishStatic)
{
	RouteGroup *route = new RouteGroup();
	route->initWithRoute(routePointVec, fishIdVec, fishStatic);
	return route;
}

bool RouteGroup::initWithRoute(const std::vector<ControlPointSet> &routePointVec, const std::vector<int> &fishIdVec, const std::map<int, FishVisual> &fishStatic)
{
	Node::init();
	int index = 0;
	//遍历所有的控制点集合
	for (std::vector<ControlPointSet>::const_iterator it = routePointVec.cbegin(); it != routePointVec.cend(); ++it,++index)
	{
		//类型
		const ControlPointSet &controlPoints = *it;
		RouteObject   routeObject;
		routeObject.vertexData = nullptr;
		routeObject.vertexCount = 0;
		routeObject.id = -1;
		//每一个加载一个模型并且进行循环的游动
		const FishVisual &fishMap = fishStatic.find(fishIdVec[index])->second;
		auto &fishAniMap = fishMap.fishAniVec[0];
		std::string   filename = "3d/" + fishMap.name +"/" + fishMap.name +".c3b";
		Sprite3D *sprite = Sprite3D::create(filename);
		sprite->setScale(fishMap.scale);
		Animation3D *animation = Animation3D::create(filename);
		Animate3D    *animate = Animate3D::create(animation, fishAniMap.startFrame/30.0f,(fishAniMap .endFrame- fishAniMap.startFrame)/30.0f);
		sprite->runAction(RepeatForever::create(animate));
		//加载相关的动作
		//
		if (controlPoints._type == CurveType::CurveType_Bessel)
		{
			_static_createBesselRoute(controlPoints, routeObject,sprite);

		}
		else if (controlPoints._type == CurveType::CurveType_Spiral)
		{
			_static_createSpiralRoute(controlPoints, routeObject,sprite);
		}
		if (routeObject.vertexData != nullptr)
		{
			routeObject.id = controlPoints._curveId;
			_routeMap[controlPoints._curveId] = routeObject;
			_lineColorMap[controlPoints._curveId] = Vec4(0.4f+0.6f*rand_0_1(),0.4f+0.6f*rand_0_1(),0.4f+0.6f*rand_0_1(),1.0f);
			this->addChild(sprite);
		}
	}
	//glprogram
	_glProgram = GLProgramCache::getInstance()->getGLProgram(_SHADER_TYPE_COMMON_);
	_glProgram->retain();
	return true;
}

void RouteGroup::draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& transform, uint32_t flags)
{
	_drawRouteCommand.init(_globalZOrder);
	_drawRouteCommand.func = CC_CALLBACK_0(RouteGroup::drawRouteCallback,this,transform,flags);
	renderer->addCommand(&_drawRouteCommand);
}

void RouteGroup::drawRouteCallback(const cocos2d::Mat4 &parentToNodeTransform, uint32_t flag)
{
	//对于任意一个曲线,逐次遍历
	GL::bindVAO(0);
	int defaultVertexId = 0;
	glGetIntegerv(GL_ARRAY_BUFFER_BINDING,&defaultVertexId);
	if (defaultVertexId != 0)
		glBindBuffer(GL_ARRAY_BUFFER,0);
	//启用Shader
	_glProgram->use();
	//加载内部使用的矩阵
	_glProgram->setUniformsForBuiltins(parentToNodeTransform);
	//设置线宽
	glLineWidth(1.0f);
	//开启深度测试
	bool  depthTest = glIsEnabled(GL_DEPTH_TEST);
	if (!depthTest)
		glEnable(GL_DEPTH_TEST);
	//获取统一变量/属性变量的位置
	int  colorLoc = _glProgram->getUniformLocation("u_color");
	int  positionLoc = _glProgram->getAttribLocation("a_position");
	//Vec4 color(1.0f,1.0f,1.0f,1.0f);
	std::map<int, RouteObject>::iterator it = _routeMap.begin();
	for (; it != _routeMap.end(); ++it)
	{
		glUniform4fv(colorLoc, 1, &_lineColorMap[it->first].x);
		glEnableVertexAttribArray(positionLoc);
		glVertexAttribPointer(positionLoc,3,GL_FLOAT,GL_FALSE,0,it->second.vertexData);

		glDrawArrays(GL_LINE_STRIP, 0, it->second.vertexCount);
	}
	//关闭深度测试
	if (!depthTest)
		glDisable(GL_DEPTH_TEST);
	//
	if(defaultVertexId !=0)
		glBindBuffer(GL_ARRAY_BUFFER,defaultVertexId);
}