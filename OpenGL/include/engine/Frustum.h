/*
  *ƽ��ͷ��ʵ��,��Ҫ����ģ�Ϳ������жϷ���
  *@date:2017-5-20
  *@Author:xiaohuaxiong
*/
#ifndef __FRUSTUM_H__
#define __FRUSTUM_H__
#include"engine/Geometry.h"
__NS_GLK_BEGIN
class Frustum
{
	//����ƽ�淽��
	Plane     _planes[6];
public:
	//ʹ����ͼͶӰ��������������ƽ��
	Frustum(const Matrix &viewProjMatrix);
	Frustum();
	//ʹ����ͼͶӰ������������ƽ�淽��
	void       init(const Matrix &viewProjMatrix);
	//�ж�ģ�͵İ�Χ���Ƿ���ƽ��ͷ���пɼ�
	bool       isOutOfFrustum(const AABB &box)const;
};
__NS_GLK_END
#endif