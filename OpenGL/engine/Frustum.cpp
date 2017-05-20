/*
  *ƽ��ͷ��ʵ��
  *@date:2017-5-20
  *@Author:xiaohuaxiong
*/
#include"engine/Frustum.h"
__NS_GLK_BEGIN
//�Ӿ�������ȡƽ�淽�̿��Բο���������
//http://www.lighthouse3d.com/tutorials/view-frustum-culling/clip-space-approach-extracting-the-planes/

Frustum::Frustum(const Matrix & viewProjMatrix)
{
	this->init(viewProjMatrix);
}

Frustum::Frustum()
{

}

void Frustum::init(const Matrix &viewProjMatrix)
{
	const float  (*array)[4] = viewProjMatrix.m;
	//+X
	_planes[0].init(GLVector3(-array[0][0] - array[0][3], -array[1][0] - array[1][3], -array[2][0] - array[2][3]), array[3][0] + array[3][3]);
	//-X
	_planes[1].init(GLVector3(array[0][0] - array[0][3], array[1][0] - array[1][3], array[2][0] - array[2][3]), array[3][3] - array[3][0]);
	//+Y
	_planes[2].init(GLVector3(-array[0][1] - array[0][3], -array[1][1] - array[1][3], -array[2][1] - array[2][3]), array[3][1] + array[3][3]);
	//-Y
	_planes[3].init(GLVector3(array[0][1] - array[0][3], array[1][1] - array[1][3], array[2][1] - array[2][3]), array[3][3] - array[3][1]);
	//+Z
	_planes[4].init(GLVector3(-array[0][2] - array[0][3], -array[1][2] - array[1][3], -array[2][2] - array[2][3]), array[3][2] + array[3][3]);
	//-Z
	_planes[5].init(GLVector3(array[0][2] - array[0][3], array[1][2] - array[1][3], array[2][2] - array[2][3]), array[3][3] - array[3][2]);
}

bool Frustum::isOutOfFrustum(const AABB &box)const
{
	GLVector3 p3d;
	for (int i = 0; i < 6; ++i)
	{
		const Plane  *plane = _planes+i;
		const GLVector3 &normal = plane->getNormal();
		//ѡ���뷨�ߵĸ��������෴�������,��ʱ���������ƽ����������Ϊ��,��һ��˵��ģ�͵İ�Χ����ƽ��ͷ��֮��
		//������Ҫע�����,���ж�����Ϊ�������
		p3d.x = normal.x > 0.0f ? box._minBox.x:box._maxBox.x;
		p3d.y = normal.y > 0.0f ? box._minBox.y:box._maxBox.y;
		p3d.z = normal.z > 0.0f ? box._minBox	.z:box._maxBox.z;
		if (plane->distance(p3d) > 0.0f)
			return true;
	}
	return false;
}
__NS_GLK_END
