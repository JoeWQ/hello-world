/*
  *2d鱼贝塞尔曲线路径生成算法
  *@date:2017年12月24日
  *@author:xiaoxiong
 */
#include "FishPath.h"
USING_NS_CC;
//目前贝塞尔曲线的阶最多可以支持到7阶
float  static_bezier_coeffcient[6][8] = {
	{1,2,1},//3
	{1,3,3,1},//4
	{1,4,6,4,1},//5
	{1,5,10,10,5,1},//6
	{1,6,15,20,15,6,1},//7
	{1,7,21,35,35,21,7,1},//8
};
#define _bezier_fact(k)  (k-3)
FishPath::FishPath(float distance):
	_curveDistance(distance)
{

}
/*
  *使用控制点初始化曲线
 */
void FishPath::initWithControlPoint(const std::vector<cocos2d::Vec2> &controlPoints,float sw,float sh)
{
	//控制点要求至少是2阶(3个控制点)的
	CCASSERT(controlPoints.size()>2,"Contrrol Points Size Must Greater Than 2.");
	//计算控制点的长度,目前已经使用离线计算完毕
	//calculate(controlPoints);
	//计算曲线的离散的点
	int  segCount = ceil(_curveDistance);
	_dispersePosition.reserve(segCount+1);
	_disperseDirection.reserve(segCount+1);
	float *coeffcient = &static_bezier_coeffcient[_bezier_fact(controlPoints.size())][0];
	int      n = controlPoints.size() - 1;
	for (int k = 0; k < segCount+1; ++k)
	{
		float t = k/ _curveDistance;
		if (t > 1.0f) t = 1.0f;
		float one_t = 1.0f - t;
		//计算位置
		float cx = 0, cy = 0;
		for (int j = 0; j < controlPoints.size(); ++j)
		{
			float factor = coeffcient[j] * powf(one_t, n -j)*powf(t,j);
			const Vec2 &point = controlPoints[j];
			cx +=point.x*factor ;
			cy += point.y*factor;
		}
		//计算偏导
		float factor1 = -n*powf(one_t, n - 1);
		float factor2 = n*powf(t, n - 1);
		float dx = controlPoints[0].x*factor1+ controlPoints[n].x*factor2;
		float dy = controlPoints[0].y*factor1+controlPoints[n].y*factor2;
		for (int j = 1; j < n; ++j)
		{
			float factor = -(n-j)*powf(one_t,n-j-1)*powf(t,j) + powf(one_t,n-j)*powf(t,j-1)*j;
			factor *= coeffcient[j];
			const Vec2 &point = controlPoints[j];
			dx += point.x*factor;
			dy += point.y*factor;
		}
		//位置
		_dispersePosition.push_back(Vec2(cx,cy));
		//求正余弦
		float d = sqrtf(dx*dx+dy*dy);
		float cosValue = dx / d;
		float sinValue = dy / d;
		//偏导以及速度缩放系数
		float cosValue2 = dx/sw;
		float sinValue2 = dy /sh;
		
		_disperseDirection.push_back(Vec4(-CC_RADIANS_TO_DEGREES(atan2f(dy,dx)),d/sqrtf(cosValue2*cosValue2 + sinValue2*sinValue2),cosValue,sinValue));
	}
}
/*
  *目前关于求贝塞尔曲线的长度涉及到椭圆积分,
  *而椭圆积分在数学上目前是没有解析解的,在这里为我们将使用分段积分法
  *将整个曲线划分为离散的小块区域,并对划分的线端进行离散积分
  *最后将积分的结果累加,近似求出曲线的长度
 */
void FishPath::calculate(const std::vector<cocos2d::Vec2> &controlPoints)
{
	int  segCount = 2000;//
	float distance = 0;
	float step = 1.0f / segCount;
	float lastX = controlPoints[0].x;
	float lastY = controlPoints[0].y;
	int    n = controlPoints.size() - 1;
	for (int k = 1; k < segCount+1; ++k)
	{
		float nowX=0,nowY=0;
		float t = 1.0f*k / segCount;
		float one_t = 1.0f - t;
		float *coeffcient = &static_bezier_coeffcient[_bezier_fact(controlPoints.size())][0];
		for (int j = 0; j < controlPoints.size(); ++j)
		{
			const Vec2 &point = controlPoints[j];
			float   factor = coeffcient[j] * powf(one_t, n - j) *powf(t, j);
			nowX += point.x * factor;
			nowY += point.y * factor;
		}
		//计算分段曲线的长度
		float dx = nowX - lastX;
		float dy = nowY - lastY;
		distance += sqrtf(dx*dx+dy*dy);
		
		lastX = nowX;
		lastY = nowY;
	}
	_curveDistance = distance;
}

void  FishPath::extract(float distance, cocos2d::Vec2 &position, Vec4 &dspeeddxdy)
{
	if (distance > _curveDistance)
		distance = _curveDistance;
	else if (distance < 0)
		distance = 0;
	position = _dispersePosition[distance];
	dspeeddxdy = _disperseDirection[distance];
}