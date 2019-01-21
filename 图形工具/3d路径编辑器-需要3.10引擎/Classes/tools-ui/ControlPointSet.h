/*
  *贝塞尔曲线控制点
  *数据集合
  *2017-3-23
  *@Author:xiaoxiong
 */
#ifndef __BESSEL_SET_H__
#define __BESSEL_SET_H__
#include "cocos2d.h"
#include "Common.h"
#include "BezierRoute.hpp"

class BesselUI;
class CurveNode;
class BesselNode;
class SpiralNode;
class ControlPointSet
{
	friend class BesselUI;
	friend class CurveNode;
	friend class BesselNode;
	friend class SpiralNode;
	friend void  _static_spiral_format(ControlPointSet *input, std::string &output);
	//格式化贝塞尔曲线数据
	friend void  _static_bessel_format(ControlPointSet *input, std::string &output);
public:
    
    std::vector<CubicBezierRoute::PointInfo>   _pointsSet;
	int                                             _realSize;
	int                                             _curveId;
	CurveType                                _type;
public:
	ControlPointSet(CurveType type);
	ControlPointSet(CurveType type,std::vector<CubicBezierRoute::PointInfo> &);
	ControlPointSet(CurveType type,std::vector<CubicBezierRoute::PointInfo> &,int realSize);
	void      addNewPoint(CubicBezierRoute::PointInfo &);
    void      addNewPoint(cocos2d::Vec3, float speedCoef = 1.0);
	//格式化相关的数据
	void      format(std::string &);
	//计算描述该段曲线大概需要多少字符
	int         getProbablyCapacity()const;
	//设置曲线的编号
	void       setId(int );
    //设置曲线的类型
	void       setType(CurveType type);
    float weight;
};

#endif
