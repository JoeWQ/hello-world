/*
  *平截头体实现
  *@date:2017-5-20
  *@Author:xiaohuaxiong
*/
#include"engine/Frustum.h"
__NS_GLK_BEGIN
//从矩阵中提取平面方程可以参考如下链接
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
		//选择与法线的各个分量相反的坐标点,此时如果坐标与平面的有向距离为正,则一定说明模型的包围盒在平截头体之外
		//但是需要注意的是,该判定条件为充分条件
		p3d.x = normal.x > 0.0f ? box._minBox.x:box._maxBox.x;
		p3d.y = normal.y > 0.0f ? box._minBox.y:box._maxBox.y;
		p3d.z = normal.z > 0.0f ? box._minBox	.z:box._maxBox.z;
		if (plane->distance(p3d) > 0.0f)
			return true;
	}
	return false;
}
__NS_GLK_END
