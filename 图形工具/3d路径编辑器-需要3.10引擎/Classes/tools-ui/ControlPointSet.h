/*
  *���������߿��Ƶ�
  *���ݼ���
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
	//��ʽ����������������
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
	//��ʽ����ص�����
	void      format(std::string &);
	//���������ö����ߴ����Ҫ�����ַ�
	int         getProbablyCapacity()const;
	//�������ߵı��
	void       setId(int );
    //�������ߵ�����
	void       setType(CurveType type);
    float weight;
};

#endif
