/*
  *���������߿��Ƶ�
  *���ݼ���
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
	//��ʽ����ص�����
	void      format(std::string &);
	//���������ö����ߴ����Ҫ�����ַ�
	int         getProbablyCapacity()const;
	//�������ߵı��
	void       setId(int );
};

#endif
