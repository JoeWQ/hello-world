/*
  *贝塞尔曲线控制点
  *数据集合
  *2017-3-23
  *@Author:xiaoxiong
 */
#ifndef __BESSEL_SET_H__
#define __BESSEL_SET_H__
#include "cocos2d.h"
class BesselSet
{
	std::vector<cocos2d::Vec3>   _pointsSet;
	int                                             _realSize;
	int                                             _curveId;
public:
	BesselSet();
	BesselSet(std::vector<cocos2d::Vec3> &);
	BesselSet(std::vector<cocos2d::Vec3> &,int realSize);
	void      addNewPoint(cocos2d::Vec3 &);
	//格式化相关的数据
	void      format(std::string &);
	//计算描述该段曲线大概需要多少字符
	int         getProbablyCapacity()const;
	//设置曲线的编号
	void       setId(int );
};

#endif
