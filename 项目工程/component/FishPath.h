/*
  *贝塞尔曲线生成算法,针对2d捕鱼,
  *算法使用贝塞尔曲线的数学定义生成曲线的离散的点
  *date:2017年12月24日
  *@author:xiaoxiong
 */
#ifndef __FISH_PATH_H__
#define __FISH_PATH_H__
#include "cocos2d.h"
class FishPath
{
	//曲线的离散的点,方向插值
	std::vector<cocos2d::Vec2>  _dispersePosition;
	std::vector<cocos2d::Vec4>  _disperseDirection;//方向,包含了速度缩放系数,
	float                                             _curveDistance;//曲线的长度
private:
	/*
	*计算曲线的长度,此函数只会被调用一次
	*/
	void		calculate(const std::vector<cocos2d::Vec2> &controlPoints);
public:
	FishPath(float distance);
	/*
	  *使用离散的控制点生成贝塞尔曲线
	  *sw:客户端屏幕宽度与服务端屏幕宽度的比例
	  *sh:客户端屏幕高度与服务端屏幕高度的比例
	 */
	void    initWithControlPoint(const std::vector<cocos2d::Vec2>  &controlPoints,float sw,float sh);
	/*
	  *获取曲线的长度
	 */
	float    getCurveDistance()const { return _curveDistance; };
	/*
	  *给定当前的比例[0-1]获取在曲线的相关的插值点以及相关的方向
	  *速度的缩放系数
	  *方向的正余弦值
	 */
	void     extract(float distance,cocos2d::Vec2 &position,cocos2d::Vec4 &dspeeddxdy);
};
#endif