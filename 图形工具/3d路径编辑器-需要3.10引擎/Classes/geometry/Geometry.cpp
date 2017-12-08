//@2017-2-6 16:45:17
//@Author:小花熊
//Version:1.0 提供了对矩阵的最基本的操作,包括 单位矩阵,旋转矩阵,平移矩阵,投影矩阵,视图矩阵,矩阵乘法
//Version:2.0增加了镜像矩阵,以及3维矩阵的引入,2,3,4维向量的引入,并提供了对向量的基本操作<单位化,点乘,叉乘,长度>的支持
//Version:3.0 增加了对矩阵直接求逆的支持,以及法线矩阵的推导,行列式的直接支持,向量与矩阵的乘法
//Version:4.0 增加了对偏置矩阵的支持,可以直接对阴影进行操作
//Version 5.0 将所有的有关矩阵的操作纳入到矩阵类中,作为矩阵的成员函数实现,在以后的实际开发中,推荐使用新的类函数,因为他们的接口更友好,更方便
//Version 6.0 将切线的计算引入到球体,立方体,地面网格的生成算法中
//Version 7.0:修正球面的切线的计算,由原来的直接三角函数计算变成求球面的关于x的偏导
//Version 8.0:引入了对四元数的支持
///
//  Includes
//
#include"Geometry.h"
#include <math.h>
#include<string.h>
#include<assert.h>
#define PI 3.1415926535f
#define    __EPS__  0.0001f
#define    __SIGN(sign)   (-(  ((sign)&0x1)<<1)+1)
//新引入切线的计算
int  esGenSphere(int numSlices, float radius, float **vertices, float **normals, float  **tangents,
	float **texCoords, int **indices ,int  *numberOfVertex)
{
	int i,j;
	int numParallels = numSlices / 2;
	int numVertices = ( numParallels + 1 ) * ( numSlices + 1 );
	int numIndices = numParallels * numSlices * 6;
	float angleStep = 2.0f * PI /numSlices;
	*numberOfVertex = numVertices;
	float   *_vertex=NULL,*_texCoord=NULL,*_normal=NULL,*_tangent=NULL;
	// Allocate memory for buffers
	if ( vertices != NULL )
		_vertex = new float[3 * numVertices ];

	if ( normals != NULL )
		_normal= new  float[3 * numVertices ];

	if ( texCoords != NULL )
		_texCoord = new float[ 2 * numVertices ];

	if ( indices != NULL )
		*indices = new  int[numIndices];

	if (tangents)
		_tangent = new  float[3 * numVertices];

	for ( i = 0; i < numParallels + 1; i++ )//Y轴切片,只需要180度即可
	{
		const float   _real_radius=radius*sin(angleStep*i);
		const float   _real_cos=radius*cos(angleStep*i);
		for ( j = 0; j < numSlices + 1; j++ )
		{
			int vertex = ( i * ( numSlices + 1 ) + j ) * 3;

			if ( _vertex )
			{
				_vertex[vertex + 0] = _real_radius *sinf ( angleStep * j );//因为angleStep是与Z轴的夹角,所以取余弦值
				_vertex [vertex + 1] = _real_cos;//从y轴自上而下的夹角
				_vertex[vertex + 2] = _real_radius *cosf ( angleStep * j );//与Z轴的夹角
			}

			if ( _normal )
			{
				_normal[vertex + 0] = _vertex[vertex + 0] / radius;
				_normal[vertex + 1] = _vertex [vertex + 1] / radius;
				_normal[vertex + 2] = _vertex [vertex + 2] / radius;
			}
//切线是球面方程关于x的偏导数
			if (_tangent)
			{
					_tangent[vertex] = cos(j*angleStep);
					_tangent[vertex + 1] = 0.0f;
					_tangent[vertex + 2] = sin(j*angleStep);
			}
			if ( _texCoord )
			{
				int texIndex = ( i * ( numSlices + 1 ) + j ) * 2;
				_texCoord[texIndex + 0] = ( float ) j / ( float ) numSlices;
				_texCoord [texIndex + 1] =1.0f - ( float ) i /numParallels;
			}
		}
	}
//切线生成,需要先生成全部的顶点,纹理坐标
// Generate the indices
	GLVector3     *originVertex = (GLVector3 *)_vertex;
	GLVector2     *originTex = (GLVector2  *)_texCoord;
	GLVector3     *originTangent = (GLVector3 *)_tangent;
	if ( indices != NULL )
	{
		int *indexBuf =*indices;

		const      int     vSkipSlice = numSlices + 1;
		for ( i = 0; i < numParallels ; i++ )
		{
			const     int       vHead=i+1;
			for ( j = 0; j < numSlices; j++ )
			{
				const    int     vTail = j + 1;
				int         _pindex1, _pindex2, _pindex3;
				_pindex1 =  i * vSkipSlice + j;
				_pindex2 = vHead * vSkipSlice + j;
				_pindex3 = vHead* vSkipSlice + vTail;

				*indexBuf++ = _pindex1;
				*indexBuf++ = _pindex2;
				*indexBuf++ = _pindex3;

				GLVector2    deltaUV1 = originTex[_pindex2] - originTex[_pindex1];
				GLVector2    deltaUV2 = originTex[_pindex3] - originTex[_pindex1];

				float     _lamda = 1.0f / (deltaUV1.x*deltaUV2.y - deltaUV1.y*deltaUV2.x);

				GLVector3       e1 = originVertex[_pindex2] - originVertex[_pindex1];
				GLVector3       e2 = originVertex[_pindex3] - originVertex[_pindex1];

				float     x1 = (deltaUV2.y*e1.x - deltaUV1.y*e2.x)*_lamda;
				float     y1 = (deltaUV2.y*e1.y - deltaUV1.y*e2.y)*_lamda;
				float     z1 = (deltaUV2.y*e1.z - deltaUV1.y*e2.z)*_lamda;

				//float    x2 = -_v1*e1.x + _u1*e2.x;
				//float    y2 = -_v1*e1.y + _u1*e2.y;
				//float    z2 = -_v1*e1.z + _u1*e2.z;
				GLVector3    _tangentValue(x1,y1,z1);
				originTangent[_pindex1] = _tangentValue;
				originTangent[_pindex2] = _tangentValue;
				originTangent[_pindex3] = _tangentValue;


				_pindex1 =i * vSkipSlice + j ;
				_pindex2 = vHead *vSkipSlice + vTail;
				_pindex3 =i * vSkipSlice + vTail ;

				*indexBuf++ = _pindex1;
				*indexBuf++ = _pindex2;
				*indexBuf++ =_pindex3 ;

				deltaUV1 = originTex[_pindex1] - originTex[_pindex3];
				deltaUV2 = originTex[_pindex2] - originTex[_pindex3];

				_lamda = 1.0f / (deltaUV1.x*deltaUV2.y - deltaUV1.y*deltaUV2.x);

				e1 = originVertex[_pindex1] - originVertex[_pindex3];
				e2 = originVertex[_pindex2] - originVertex[_pindex3];

				 x1 = (deltaUV2.y*e1.x - deltaUV1.y*e2.x)*_lamda;
				 y1 = (deltaUV2.y*e1.y - deltaUV1.y*e2.y)*_lamda;
				 z1 = (deltaUV2.y*e1.z - deltaUV1.y*e2.z)*_lamda;

				 _tangentValue=GLVector3(x1, y1, z1);
				 originTangent[_pindex1] = _tangentValue;
				 originTangent[_pindex2] = _tangentValue;
				 originTangent[_pindex3] = _tangentValue;
			}
		}
	}
	*vertices=_vertex;
	*texCoords=_texCoord;
	*normals=_normal;
	*tangents = _tangent;
	return numIndices;
}

//
/// \brief Generates geometry for a cube.  Allocates memory for the vertex data and stores
///        the results in the arrays.  Generate index list for a TRIANGLES
/// \param scale The size of the cube, use 1.0 for a unit cube.
/// \param vertices If not NULL, will contain array of float3 positions
/// \param normals If not NULL, will contain array of float3 normals
/// \param texCoords If not NULL, will contain array of float2 texCoords
/// \param indices If not NULL, will contain the array of indices for the triangle strip
/// \return The number of indices required for rendering the buffers (the number of indices stored in the indices array
///         if it is not NULL ) as a GL_TRIANGLE_STRIP
//
int  esGenCube ( float scale, float **vertices, float **normals,float **tangents,float **texCoords,int  *numberOfVertex )
{
//从立方体的外面观察,所有的三角形都是正方向的
	float cubeVerts[] =
	{
//前
		-1.0f, -1.0f, 1.0f,
		1.0f, -1.0f, 1.0f,
		1.0f, 1.0f, 1.0f,
		1.0f, 1.0f, 1.0f,
		-1.0f, 1.0f, 1.0f,
		-1.0f, -1.0f, 1.0f,
//后
		-1.0f, 1.0f, -1.0f,
		1.0f, 1.0f, -1.0f,
		1.0f, -1.0f, -1.0f,
		1.0f, -1.0f, -1.0f,
		-1.0f, -1.0f, -1.0f,
		-1.0f, 1.0f, -1.0f,
//左
		-1.0f, 1.0f, 1.0f,
		-1.0f, 1.0f, -1.0f,
		-1.0f, -1.0f, -1.0f,
		-1.0f, -1.0f, -1.0f,
		-1.0f, -1.0f, 1.0f,
		-1.0f, 1.0f, 1.0f,
//右
		1.0f, -1.0f, 1.0f,
		1.0f, -1.0f, -1.0f,
		1.0f, 1.0f, -1.0f,
		1.0f, 1.0f, -1.0f,
		1.0f, 1.0f, 1.0f,
		1.0f, -1.0f, 1.0f,
//上
		-1.0f, 1.0f, 1.0f,
		1.0f, 1.0f, 1.0f,
		1.0f, 1.0f, -1.0f,
		1.0f, 1.0f, -1.0f,
		-1.0f, 1.0f, -1.0f,
		-1.0f, 1.0f, 1.0f,
//下
		-1.0f, -1.0f, 1.0f,
		-1.0f, -1.0f, -1.0f,
		1.0f, -1.0f, -1.0f,
		1.0f, -1.0f, -1.0f,
		1.0f, -1.0f, 1.0f,
		-1.0f, -1.0f, 1.0f,
	};
	//切线
	float    tangent[] = {
		//前
		1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
		1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
		//后
		-1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f,
		-1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f,
		//左
		0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f,
		0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f,
		//右
		0.0f, 0.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, -1.0f,
		0.0f, 0.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, -1.0f,
		//上
		1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
		1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
		//下
		1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
		1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
	};
	float cubeNormals[] =
	{
//前
		0.0f,0.0f,-1.0f,
		0.0f, 0.0f, -1.0f,
		0.0f, 0.0f, -1.0f,
		0.0f, 0.0f, -1.0f,
		0.0f, 0.0f, -1.0f, 
		0.0f, 0.0f, -1.0f,
//后
		0.0f,0.0f,1.0f,
		0.0f, 0.0f, 1.0f,
		0.0f, 0.0f, 1.0f,
		0.0f, 0.0f, 1.0f,
		0.0f, 0.0f, 1.0f,
		0.0f, 0.0f, 1.0f,
//左
		-1.0f, 0.0f, 0.0f,
		-1.0f, 0.0f, 0.0f,
		-1.0f, 0.0f, 0.0f,
		-1.0f, 0.0f, 0.0f,
		-1.0f, 0.0f, 0.0f,
		-1.0f, 0.0f, 0.0f,
//右
		1.0f, 0.0f, 0.0f,
		1.0f, 0.0f, 0.0f,
		1.0f, 0.0f, 0.0f,
		1.0f, 0.0f, 0.0f,
		1.0f, 0.0f, 0.0f,
		1.0f, 0.0f, 0.0f,
//上
		0.0f, 1.0f, 0.0f,
		0.0f, 1.0f, 0.0f,
		0.0f, 1.0f, 0.0f,
		0.0f, 1.0f, 0.0f,
		0.0f, 1.0f, 0.0f,
		0.0f, 1.0f, 0.0f,
//下
		0.0f, -1.0f,0.0f,
		0.0f, -1.0f, 0.0f,
		0.0f, -1.0f, 0.0f,
		0.0f, -1.0f, 0.0f,
		0.0f, -1.0f, 0.0f,
		0.0f, -1.0f, 0.0f,
	};

	float cubeTex[] =
	{
//前
		-1.0f, -1.0f, 1.0f,
		1.0f, -1.0f, 1.0f,
		1.0f, 1.0f, 1.0f,
		1.0f, 1.0f, 1.0f,
		-1.0f, 1.0f, 1.0f,
		-1.0f, -1.0f, 1.0f,
//后
		-1.0f, 1.0f, -1.0f,
		1.0f, 1.0f, -1.0f,
		1.0f, -1.0f, -1.0f,
		1.0f, -1.0f, -1.0f,
		-1.0f, -1.0f, -1.0f,
		-1.0f, 1.0f, -1.0f,
//左
		-1.0f, 1.0f, 1.0f,
		-1.0f, 1.0f, -1.0f,
		-1.0f, -1.0f, -1.0f,
		-1.0f, -1.0f, -1.0f,
		-1.0f, -1.0f, 1.0f,
		-1.0f, 1.0f, 1.0f,
//右
		1.0f, -1.0f, 1.0f,
		1.0f, -1.0f, -1.0f,
		1.0f, 1.0f, -1.0f,
		1.0f, 1.0f, -1.0f,
		1.0f, 1.0f, 1.0f,
		1.0f, -1.0f, 1.0f,
//上
		-1.0f, 1.0f, 1.0f,
		1.0f, 1.0f, 1.0f,
		1.0f, 1.0f, -1.0f,
		1.0f, 1.0f, -1.0f,
		-1.0f, 1.0f, -1.0f,
		-1.0f, 1.0f, 1.0f,
//下
		-1.0f, -1.0f, 1.0f,
		-1.0f, -1.0f, -1.0f,
		1.0f, -1.0f, -1.0f,
		1.0f, -1.0f, -1.0f,
		1.0f, -1.0f, 1.0f,
		-1.0f, -1.0f, 1.0f,
	};
	*numberOfVertex = sizeof(cubeVerts) / sizeof(float)/3;
	float   *_vertex = new float[sizeof(cubeVerts) / sizeof(float)];

	for (int i = 0; i < sizeof(cubeVerts) / sizeof(float); ++i)
		_vertex[i] = cubeVerts[i] * scale;
	*vertices = _vertex;
	*texCoords = new  float[sizeof(cubeTex) / sizeof(float)];
	*normals = new  float[sizeof(cubeVerts) / sizeof(float)];
	*tangents = new   float[sizeof(tangent)/sizeof(float)];
	memcpy(*texCoords,cubeTex,sizeof(cubeTex));
	memcpy(*normals,cubeNormals,sizeof(cubeNormals));
	memcpy(*tangents,tangent,sizeof(tangent));
	return 0;
}

//
/// \brief Generates a square grid consisting of triangles.  Allocates memory for the vertex data and stores
///        the results in the arrays.  Generate index list as TRIANGLES.
/// \param size create a grid of size by size (number of triangles = (size-1)*(size-1)*2)
/// \param vertices If not NULL, will contain array of float3 positions
/// \param indices If not NULL, will contain the array of indices for the triangle strip
/// \return The number of indices required for rendering the buffers (the number of indices stored in the indices array
///         if it is not NULL ) as a GL_TRIANGLES
//
int  esGenSquareGrid ( int size, float scale,float **vertices,int **indices,int  *numberOfVertex )
{
	int i, j;
	int numIndices = ( size - 1 ) * ( size - 1 ) * 2 * 3;

	// Allocate memory for buffers
	if ( vertices != NULL )
	{
		int numVertices = size * size;
		*numberOfVertex = numVertices;
		float stepSize = (( float)(size - 1))/2.0f;
		float   *_vertex =new float[ 3 * numVertices ];
		*vertices = _vertex;

		for ( i = 0; i <size; ++i ) // row
		{
			   const    float     locX=scale*(i/stepSize-1.0f);
			for ( j = 0; j <size; ++j ) // column
			{
				int   _index = (i*size + j) * 3;
				_vertex[_index] = scale*(j/stepSize-1.0f);
				_vertex[_index + 1] = locX;
				_vertex[_index + 2] = 0.0f;
			}
		}
	}
	// Generate the indices
	if ( indices != NULL )
	{
		int   *_indice = new int[numIndices];
		*indices = _indice;
		for ( i = 0; i < size - 1; ++i )
		{
			for ( j = 0; j < size - 1; ++j )
			{
// two triangles per quad
				int    _index = 6 * (j + i * (size - 1));
				_indice[_index] = j + i* size;
				_indice[_index + 1] = j + i* size+1;
				_indice[_index + 2] = j + (i + 1) * size+1;

				_indice[_index + 3] = j + (i + 1) * size+1;
				_indice[_index + 4] = j + (i + 1) * size;
				_indice[_index + 5] =  j + i* size;
			}
		}
	}
	return numIndices;
}
//vector cross
GLVector3     cross(GLVector3  *a,GLVector3  *b)
{
	float   x = a->y*b->z - a->z*b->y;
	float   y = a->z*b->x - a->x*b->z;
	float   z = a->x*b->y - a->y*b->x;

	return  GLVector3(x,y,z);
}
//vector dot
float       dot(GLVector3  *srcA, GLVector3  *srcB)
{
	return    srcA->x*srcB->x + srcA->y*srcB->y + srcA->z*srcB->z;
}
//normalize
GLVector3    normalize(GLVector3 *src)
{
	float     _distance = sqrt(src->x*src->x+src->y*src->y+src->z*src->z);
	assert(_distance>0);

	return  GLVector3(src->x/_distance,src->y/_distance,src->z/_distance);
}
GLVector2   normalize(GLVector2    *src)
{
	float    _distance = sqrt(src->x*src->x+src->y*src->y);
	assert(_distance>0);
	return  GLVector2(src->x/_distance,src->y/_distance);
}

/////////////////////////////二维,三维,四维向量右乘矩阵//////////////////////////////////////
GLVector2    GLVector2::operator*(float  _factor)
{
	return   GLVector2(x*_factor,y*_factor);
}
GLVector2   GLVector2::operator*(GLVector2  &_mfactor)
{
	return  GLVector2(x*_mfactor.x,y*_mfactor.y);
}
GLVector2   GLVector2::operator+(GLVector2  &_factor)
{
	return  GLVector2(x+_factor.x,y+_factor.y);
}
GLVector2   GLVector2::operator-(GLVector2  &_factor)
{
	return  GLVector2(x-_factor.x,y-_factor.y);
}
GLVector2   GLVector2::operator/(float _factor)
{
	return  GLVector2(x/_factor,y/_factor);
}
GLVector2    GLVector2::operator/(GLVector2  &_factor)
{
	return  GLVector2(x/_factor.x,y/_factor.y);
}
GLVector2   GLVector2::normalize()
{
	float  _length = sqrt(x*x+y*y);
	assert(_length>=__EPS__);
	return  GLVector2(x/_length,y/_length);
}
float     GLVector2::dot(GLVector2 &other)
{
	return x*other.x + y*other.y;
}
/////////////////////////////333333333333333333////////////////////////////////////
GLVector3   GLVector3::operator*(Matrix3 &src)
{
	float  x, y, z;
	x = this->x*src.m[0][0] + this->y*src.m[1][0] + this->z*src.m[2][0];
	y = this->x*src.m[0][1] + this->y*src.m[1][1] + this->z*src.m[2][1];
	z = this->x*src.m[0][2] + this->y*src.m[1][2] + this->z*src.m[2][2];

	return  GLVector3(x,y,z);
}
GLVector3    GLVector3::operator*(float   _factor)
{
	return  GLVector3(x*_factor,y*_factor,z*_factor);
}
GLVector3   GLVector3::operator*(GLVector3  &_factor)
{
	return  GLVector3(x*_factor.x,y*_factor.y,z*_factor.z);
}
GLVector3   GLVector3::operator+(GLVector3  &_factor)
{
	return  GLVector3(x+_factor.x,y+_factor.y,z+_factor.z);
}
GLVector3   GLVector3::operator-(GLVector3 &_factor)
{
	return  GLVector3(x-_factor.x,y-_factor.y,z-_factor.z);
}
GLVector3   GLVector3::operator/(float _factor)
{
	return  GLVector3(x/_factor,y/_factor,z/_factor);
}
GLVector3   GLVector3::operator/(GLVector3 &_factor)
{
	return   GLVector3(x/_factor.x,y/_factor.y,z/_factor.z);
}
GLVector3   GLVector3::normalize()
{
	float      _length = sqrt(x*x+y*y+z*z);
	assert(_length>=__EPS__);
	return    GLVector3(x/_length,y/_length,z/_length);
}
GLVector3   GLVector3::cross(GLVector3 &axis)
{
	return GLVector3(
		y*axis.z - z*axis.y,
		-x*axis.z + z*axis.x,
		x*axis.y - y*axis.x
		);
}
float    GLVector3::dot(GLVector3 &other)
{
	return x*other.x + y*other.y + z*other.z;
}
/////////////////////////4444444444444444///////////////////////////////////////
GLVector4     GLVector4::operator*(Matrix &src)
{
	float  x, y, z, w;
	x = this->x*src.m[0][0] + this->y*src.m[1][0] + this->z*src.m[2][0] + this->w*src.m[3][0];
	y = this->x*src.m[0][1] + this->y*src.m[1][1] + this->z*src.m[2][1] + this->w*src.m[3][1];
	z = this->x*src.m[0][2] + this->y*src.m[1][2] + this->z*src.m[2][2] + this->w*src.m[3][2];
	w = this->x*src.m[0][3] + this->y*src.m[1][3] + this->z*src.m[2][3] + this->w*src.m[3][3];
	return GLVector4(x, y, z, w);
}
GLVector4    GLVector4::normalize()
{
	float   _length = sqrt(x*x+y*y+z*z+w*w);
	assert(_length>__EPS__);
	return  GLVector4(x/_length,y/_length,z/_length,w/_length);
}
float    GLVector4::dot(GLVector4 &other)
{
	return x*other.x + y*other.y + z*other.z + w*other.w;
}
////////////////////////////四维矩阵实现//////////////////////////////////
Matrix::Matrix()
{
	m[0][0] = 1.0f, m[0][1] = 0.0f, m[0][2] = 0.0f, m[0][3] = 0.0f;
	m[1][0] = 0.0f, m[1][1] = 1.0f, m[1][2] = 0.0f, m[1][3] = 0.0f;
	m[2][0] = 0.0f, m[2][1] = 0.0f, m[2][2] = 1.0f, m[2][3] = 0.0f;
	m[3][0] = 0.0f, m[3][1] = 0.0f, m[3][2] = 0.0f, m[3][3] = 1.0f;
}
void     Matrix::identity()
{
	m[0][0] = 1.0f, m[0][1] = 0.0f, m[0][2] = 0.0f, m[0][3] = 0.0f;
	m[1][0] = 0.0f, m[1][1] = 1.0f, m[1][2] = 0.0f, m[1][3] = 0.0f;
	m[2][0] = 0.0f, m[2][1] = 0.0f, m[2][2] = 1.0f, m[2][3] = 0.0f;
	m[3][0] = 0.0f, m[3][1] = 0.0f, m[3][2] = 0.0f, m[3][3] = 1.0f;
}
void    Matrix::copy(Matrix  &srcA)
{
	m[0][0] = srcA.m[0][0], m[0][1] = srcA.m[0][1], m[0][2] = srcA.m[0][2], m[0][3] = srcA.m[0][3];
	m[1][0] = srcA.m[1][0], m[1][1] = srcA.m[1][1], m[1][2] = srcA.m[1][2], m[1][3] = srcA.m[1][3];
	m[2][0] = srcA.m[2][0], m[2][1] = srcA.m[2][1], m[0][2] = srcA.m[2][2], m[2][3] = srcA.m[2][3];
	m[3][0] = srcA.m[3][0], m[3][1] = srcA.m[3][1], m[3][2] = srcA.m[3][2], m[3][3] = srcA.m[3][3];
}
//右乘缩放矩阵
void   Matrix::scale(float scaleX, float scaleY, float  scaleZ)
{
	m[0][0] *= scaleX; m[0][1] *= scaleY; m[0][2] *= scaleZ; 
	m[1][0] *= scaleX; m[1][1] *= scaleY; m[1][2] *= scaleZ; 
	m[2][0] *= scaleX; m[2][1] *= scaleY; m[2][2] *= scaleZ; 
	m[3][0] *= scaleX;m[3][1] *= scaleY; m[3][2] *= scaleZ;
}
//平移
void    Matrix::translate(float deltaX, float  deltaY, float deltaZ)
{
	m[0][0] += m[0][3] * deltaX;
	m[0][1] += m[0][3] * deltaY;
	m[0][2] += m[0][3] * deltaZ;

	m[1][0] += m[1][3] * deltaX;
	m[1][1] += m[1][3] * deltaY;
	m[1][2] += m[1][3] * deltaZ;

	m[2][0] += m[2][3] * deltaX;
	m[2][1] += m[2][3] * deltaY;
	m[2][2] += m[2][3] * deltaZ;

	m[3][0] += m[3][3] * deltaX;
	m[3][1] += m[3][3] * deltaY;
	m[3][2] += m[3][3] * deltaZ;
}
//旋转
void    Matrix::rotate(float  angle, float x, float y, float z)
{
	float sinAngle, cosAngle;
	float mag = sqrtf(x * x + y * y + z * z);

	sinAngle = sinf(angle * PI / 180.0f);
	cosAngle = cosf(angle * PI / 180.0f);

	assert(mag > 0.0f);
	float xx, yy, zz, xy, yz, zx, xs, ys, zs;
	float oneMinusCos;
	Matrix tmp;

	x /= mag; y /= mag;  z /= mag;
   xx = x * x;  yy = y * y;   zz = z * z;
	xy = x * y;  yz = y * z;    zx = z * x;

	xs = x * sinAngle;  ys = y * sinAngle;   zs = z * sinAngle;   oneMinusCos = 1.0f - cosAngle;

	tmp.m[0][0] = (oneMinusCos * xx) + cosAngle;
	tmp.m[0][1] = (oneMinusCos * xy) + zs;
	tmp.m[0][2] = (oneMinusCos * zx) - ys;
	tmp.m[0][3] = 0.0F;

	tmp.m[1][0] = (oneMinusCos * xy) - zs;
	tmp.m[1][1] = (oneMinusCos * yy) + cosAngle;
	tmp.m[1][2] = (oneMinusCos * yz) + xs;
	tmp.m[1][3] = 0.0F;

	tmp.m[2][0] = (oneMinusCos * zx) + ys;
	tmp.m[2][1] = (oneMinusCos * yz) - xs;
	tmp.m[2][2] = (oneMinusCos * zz) + cosAngle;
	tmp.m[2][3] = 0.0F;

	tmp.m[3][0] = 0.0F;
	tmp.m[3][1] = 0.0F;
	tmp.m[3][2] = 0.0F;
	tmp.m[3][3] = 1.0F;

	this->multiply(tmp);
}
//视图投影矩阵
void    Matrix::lookAt(GLVector3  &eyePosition, GLVector3  &targetPosition, GLVector3  &upVector)
{
	Matrix    tmp, *result = &tmp;
	GLVector3    N = (eyePosition - targetPosition).normalize();
	GLVector3    U =upVector.cross(N).normalize() ;
	assert(U.x*U.x+U.y*U.y+U.z*U.z>__EPS__);
	GLVector3    V = N.cross(U);
	memset(result, 0x0, sizeof(Matrix));
	result->m[0][0] = U.x;
	result->m[1][0] = U.y;
	result->m[2][0] = U.z;

	result->m[0][1] = V.x;
	result->m[1][1] = V.y;
	result->m[2][1] = V.z;

	result->m[0][2] = N.x;
	result->m[1][2] = N.y;
	result->m[2][2] = N.z;

	result->m[3][0] = -U.dot(eyePosition);
	result->m[3][1] = -V.dot(eyePosition);
	result->m[3][2] = -N.dot(eyePosition);
	result->m[3][3] = 1.0f;
	this->multiply(tmp);
}
//矩阵乘法
void    Matrix::multiply(Matrix &srcA)
{
	Matrix     tmp;
	int         i;

	for (i = 0; i < 4; i++)
	{
		tmp.m[i][0] = (m[i][0] * srcA.m[0][0]) +
			(m[i][1] * srcA.m[1][0]) +
			(m[i][2] * srcA.m[2][0]) +
			(m[i][3] * srcA.m[3][0]);

		tmp.m[i][1] = (m[i][0] * srcA.m[0][1]) +
			(m[i][1] * srcA.m[1][1]) +
			(m[i][2] * srcA.m[2][1]) +
			(m[i][3] * srcA.m[3][1]);

		tmp.m[i][2] = (m[i][0] * srcA.m[0][2]) +
			(m[i][1] * srcA.m[1][2]) +
			(m[i][2] * srcA.m[2][2]) +
			(m[i][3] * srcA.m[3][2]);

		tmp.m[i][3] = (m[i][0] * srcA.m[0][3]) +
			(m[i][1] * srcA.m[1][3]) +
			(m[i][2] * srcA.m[2][3]) +
			(m[i][3] * srcA.m[3][3]);
	}

	memcpy(this, &tmp, sizeof(Matrix));
}
//二次矩阵乘法
void     Matrix::multiply(Matrix &srcA, Matrix &srcB)
{
	Matrix    tmp;
	int         i;

	for (i = 0; i < 4; i++)
	{
		tmp.m[i][0] = (srcA.m[i][0] * srcB.m[0][0]) +
			(srcA.m[i][1] * srcB.m[1][0]) +
			(srcA.m[i][2] * srcB.m[2][0]) +
			(srcA.m[i][3] * srcB.m[3][0]);

		tmp.m[i][1] = (srcA.m[i][0] * srcB.m[0][1]) +
			(srcA.m[i][1] * srcB.m[1][1]) +
			(srcA.m[i][2] * srcB.m[2][1]) +
			(srcA.m[i][3] * srcB.m[3][1]);

		tmp.m[i][2] = (srcA.m[i][0] * srcB.m[0][2]) +
			(srcA.m[i][1] * srcB.m[1][2]) +
			(srcA.m[i][2] * srcB.m[2][2]) +
			(srcA.m[i][3] * srcB.m[3][2]);

		tmp.m[i][3] = (srcA.m[i][0] * srcB.m[0][3]) +
			(srcA.m[i][1] * srcB.m[1][3]) +
			(srcA.m[i][2] * srcB.m[2][3]) +
			(srcA.m[i][3] * srcB.m[3][3]);
	}

	memcpy(m, &tmp, sizeof(Matrix));
}
//运算符重载
Matrix     Matrix::operator*(Matrix   &srcA)
{
	Matrix  tmp;
	int         i;

	for (i = 0; i < 4; i++)
	{
		tmp.m[i][0] = (m[i][0] * srcA.m[0][0]) +
			(m[i][1] * srcA.m[1][0]) +
			(m[i][2] * srcA.m[2][0]) +
			(m[i][3] * srcA.m[3][0]);

		tmp.m[i][1] = (m[i][0] * srcA.m[0][1]) +
			(m[i][1] * srcA.m[1][1]) +
			(m[i][2] * srcA.m[2][1]) +
			(m[i][3] * srcA.m[3][1]);

		tmp.m[i][2] = (m[i][0] * srcA.m[0][2]) +
			(m[i][1] * srcA.m[1][2]) +
			(m[i][2] * srcA.m[2][2]) +
			(m[i][3] * srcA.m[3][2]);

		tmp.m[i][3] = (m[i][0] * srcA.m[0][3]) +
			(m[i][1] * srcA.m[1][3]) +
			(m[i][2] * srcA.m[2][3]) +
			(m[i][3] * srcA.m[3][3]);
	}
	return tmp;
}
GLVector4  Matrix::operator*(GLVector4  &vec)
{
	float   x, y, z, w;
	x = vec.x*m[0][0] + vec.y*m[1][0] + vec.z*m[2][0] + vec.w*m[3][0];
	y = vec.x*m[0][1] + vec.y*m[1][1] + vec.z*m[2][1] + vec.w*m[3][1];
	z = vec.x*m[0][2] + vec.y*m[1][2] + vec.z*m[2][2] + vec.w*m[3][2];
	w = vec.x*m[0][3] + vec.y*m[1][3] + vec.z*m[2][3] + vec.w*m[3][3];
	return GLVector4(x, y, z, w);
}

Matrix&    Matrix::operator=(Matrix  &src)
{
	if (this!=&src)
	memcpy(this,&src,sizeof(Matrix));
	return src;
}
//正交投影
void    Matrix::orthoProject(float  left, float right, float  bottom, float  top, float  nearZ, float  farZ)
{
	float       deltaX = right - left;
	float       deltaY = top - bottom;
	float       deltaZ = farZ - nearZ;
	assert(deltaX > 0.0f && deltaY > 0.0f && deltaZ > 0.0f);
	Matrix    ortho;

	ortho.m[0][0] = 2.0f / deltaX;
	ortho.m[3][0] = -(right + left) / deltaX;
	ortho.m[1][1] = 2.0f / deltaY;
	ortho.m[3][1] = -(top + bottom) / deltaY;
	ortho.m[2][2] =- 2.0f / deltaZ;
	ortho.m[3][2] =- (nearZ + farZ) / deltaZ;

	this->multiply(ortho);
}
void    Matrix::frustum(float left, float right, float bottom, float top, float nearZ, float farZ)
{
	float       deltaX = right - left;
	float       deltaY = top - bottom;
	float       deltaZ = farZ - nearZ;
	Matrix    frust;

	assert(deltaX > 0.0f && deltaY > 0.0f && deltaZ > 0.0f && nearZ > 0.0f);

	frust.m[0][0] = 2.0f * nearZ / deltaX;
	frust.m[0][1] = frust.m[0][2] = frust.m[0][3] = 0.0f;

	frust.m[1][1] = 2.0f * nearZ / deltaY;
	frust.m[1][0] = frust.m[1][2] = frust.m[1][3] = 0.0f;

	frust.m[2][0] = (right + left) / deltaX;
	frust.m[2][1] = (top + bottom) / deltaY;
	frust.m[2][2] = -(nearZ + farZ) / deltaZ;
	frust.m[2][3] = -1.0f;

	frust.m[3][2] = -2.0f * nearZ * farZ / deltaZ;
	frust.m[3][0] = frust.m[3][1] = frust.m[3][3] = 0.0f;

	this->multiply(frust);
}

void    Matrix::perspective(float fovy, float aspect, float nearZ, float farZ)
{
	float frustumW, frustumH;

	frustumH = tanf(fovy / 360.0f * PI) * nearZ;
	frustumW = frustumH * aspect;

	this->frustum(-frustumW, frustumW, -frustumH, frustumH, nearZ, farZ);
}
float   detVector3(GLVector3    *a, GLVector3       *b, GLVector3  *c)
{
	float   _result = 0;
	_result = a->x* (b->y*c->z - b->z*c->y);
	_result -= a->y*(b->x*c->z - b->z*c->x);
	_result += a->z*(b->x*c->y - b->y*c->x);
	return _result;
}

//四维矩阵的逆
static   void   __fix__(int  *_index, int  _current)//辅助函数
{
	int   i = 0;
	int   k = 0;
	while (i < 4)
	{
		if (i != _current)
			_index[k++] = i;
		++i;
	}
}

Matrix             Matrix::reverse()
{
	Matrix     tmp;
	float             _det = this->det();
	assert(fabs(_det) > __EPS__);
	GLVector3    row1, row2, row3;
	int        _index[4];
	for (int i = 0; i < 4; ++i)
	{
		__fix__(_index, i);
		int     a = _index[0], b = _index[1], c = _index[2];
		//i,0
		row1 = GLVector3(m[a][1], m[a][2], m[a][3]);
		row2 = GLVector3(m[b][1], m[b][2], m[b][3]);
		row3 = GLVector3(m[c][1], m[c][2],m[c][3]);
		tmp.m[0][i] = __SIGN(i + 0)*detVector3(&row1, &row2, &row3);
		//i,1
		row1 = GLVector3(m[a][0], m[a][2], m[a][3]);
		row2 = GLVector3(m[b][0], m[b][2], m[b][3]);
		row3 = GLVector3(m[c][0], m[c][2],m[c][3]);
		tmp.m[1][i] = __SIGN(i + 1)*detVector3(&row1, &row2, &row3);
		//i,2
		row1 = GLVector3(m[a][0], m[a][1], m[a][3]);
		row2 = GLVector3(m[b][0], m[b][1], m[b][3]);
		row3 = GLVector3(m[c][0], m[c][1], m[c][3]);
		tmp.m[2][i] = __SIGN(i + 2)*detVector3(&row1, &row2, &row3);
		//i,3
		row1 = GLVector3(m[a][0], m[a][1], m[a][2]);
		row2 = GLVector3(m[b][0], m[b][1], m[b][2]);
		row3 = GLVector3(m[c][0], m[c][1], m[c][2]);
		tmp.m[3][i] = __SIGN(i + 3)*detVector3(&row1, &row2, &row3);
	}
	return   tmp;
}
//行列式
float           Matrix::det()
{
	GLVector3   row1, row2, row3;
	float  _det;
	//0,0
	row1 = GLVector3(m[1][1], m[1][2], m[1][3]);
	row2 = GLVector3(m[2][1], m[2][2], m[2][3]);
	row3 = GLVector3(m[3][1], m[3][2], m[3][3]);
	_det = m[0][0] * detVector3(&row1, &row2, &row3);
	//0,1
	row1 = GLVector3(m[1][0], m[1][2], m[1][3]);
	row2 = GLVector3(m[2][0], m[2][2], m[2][3]);
	row3 = GLVector3(m[3][0], m[3][2], m[3][3]);
	_det -= m[0][1] * detVector3(&row1, &row2, &row3);
	//0,2
	row1 = GLVector3(m[1][0], m[1][1], m[1][3]);
	row2 = GLVector3(m[2][0], m[2][1], m[2][3]);
	row3 = GLVector3(m[3][0], m[3][1], m[3][3]);
	_det += m[0][2] * detVector3(&row1, &row2, &row3);
	//0,3
	row1 = GLVector3(m[1][0], m[1][1], m[1][2]);
	row2 = GLVector3(m[2][0], m[2][1], m[2][2]);
	row3 = GLVector3(m[3][0], m[3][1], m[3][2]);
	_det -= m[0][3] * detVector3(&row1, &row2, &row3);
	return _det;
}

Matrix3     Matrix::normalMatrix()
{
	Matrix3      tmp;
	float            temp;
	tmp.m[0][0] = m[0][0];
	tmp.m[0][1] = m[0][1];
	tmp.m[0][2] = m[0][2];

	tmp.m[1][0] = m[1][0];
	tmp.m[1][1] = m[1][1];
	tmp.m[1][2] = m[1][2];

	tmp.m[2][0] = m[2][0];
	tmp.m[2][1] = m[2][1];
	tmp.m[2][2] = m[2][2];
//求逆矩阵
//	tmp = tmp.reverse();
//转置
#define     _SWAP_MAT3_(i,k) temp=tmp.m[i][k],  tmp.m[i][k]=tmp.m[k][i],tmp.m[k][i]=temp;
	_SWAP_MAT3_(0, 1)
    _SWAP_MAT3_(0, 2)
	_SWAP_MAT3_(1, 2)
#undef _SWAP_MAT3_
   return  tmp;
}

Matrix3    Matrix::trunk()
{
	Matrix3   tmp;
#define   _MATRIX_TRUNK_(i,k)   tmp.m[i][k]=m[i][k];
	_MATRIX_TRUNK_(0, 0)
	_MATRIX_TRUNK_(0, 1)
	_MATRIX_TRUNK_(0, 2)

	_MATRIX_TRUNK_(1, 0)
	_MATRIX_TRUNK_(1, 1)
	_MATRIX_TRUNK_(1, 2)

	_MATRIX_TRUNK_(2, 0)
	_MATRIX_TRUNK_(2, 1)
	_MATRIX_TRUNK_(2, 2)
#undef _MATRIX_TRUNK_
	return tmp;
}
//偏置矩阵
void     Matrix::offset()
{
#define    _OFFSET_MATRIX(i,k)  m[i][k]=m[i][k]*0.5f+temp;
	float  temp = m[0][3] * 0.5f;
	_OFFSET_MATRIX(0, 0)
	_OFFSET_MATRIX(0, 1)
	_OFFSET_MATRIX(0, 2)

	temp = m[1][3] * 0.5f;
	_OFFSET_MATRIX(1, 0)
	_OFFSET_MATRIX(1, 1)
	_OFFSET_MATRIX(1, 2)

	temp = m[2][3] * 0.5f;
	_OFFSET_MATRIX(2, 0)
	_OFFSET_MATRIX(2, 1)
	_OFFSET_MATRIX(2, 2)

	temp = m[3][3] * 0.5f;
	_OFFSET_MATRIX(3,0)
	_OFFSET_MATRIX(3,1)
	_OFFSET_MATRIX(3,2)
#undef _OFFSET_MATRIX
}
//////////////////////////////三维矩阵//////////////////////////
Matrix3::Matrix3(const Matrix3 &src)
{
	memcpy(this,&src,sizeof(Matrix3));
}
//行列式计算
static float     detFloat(float x1, float y1, float x2, float y2)
{
	return  x1*y2 - y1*x2;
}
Matrix3::Matrix3()
{
	m[0][0] = 1.0f; m[0][1] = 0.0f, m[0][2] = 0.0f;
	m[1][0] = 0.0f, m[1][1] = 1.0f, m[1][2] = 0.0f;
	m[2][0] = 0.0f, m[2][1] = 0.0f, m[2][2] = 1.0f;
}
Matrix3     Matrix3::reverse()
{
	Matrix3    tmp;
	float     _det = this->det();
	assert(fabs(_det) > __EPS__);

	tmp.m[0][0] = detFloat(m[1][1], m[1][2], m[2][1], m[2][2]) / _det;
	tmp.m[1][0] = -detFloat(m[1][0], m[1][2], m[2][0], m[2][2]) / _det;
	tmp.m[2][0] = detFloat(m[1][0], m[1][1], m[2][0], m[2][1]) / _det;

	tmp.m[0][1] = -detFloat(m[0][1], m[0][2], m[2][1], m[2][2]) / _det;
	tmp.m[1][1] = detFloat(m[0][0], m[0][2], m[2][0], m[2][2]) / _det;
	tmp.m[2][1] = -detFloat(m[0][0], m[0][1], m[2][0], m[2][1]) / _det;

	tmp.m[0][2] = detFloat(m[0][1], m[0][2], m[1][1], m[1][2]) / _det;
	tmp.m[1][2] = -detFloat(m[0][0], m[0][2], m[1][0], m[1][2]) / _det;
	tmp.m[2][2] = detFloat(m[0][0], m[0][1], m[1][0], m[1][1]) / _det;
	return  tmp;
}

float     Matrix3::det()
{
	float     _result;
	_result = m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]);
	_result -= m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]);
	_result += m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
	return _result;
}
//右乘三维向量
GLVector3     Matrix3::operator*(GLVector3 &vec)
{
	float x, y, z;
	x = m[0][0] * vec.x + m[0][1] * vec.y + m[0][2] * vec.z;
	y = m[1][0] * vec.x + m[1][1] * vec.y + m[1][2] * vec.z;
	z = m[2][0] * vec.x + m[2][1] * vec.y + m[2][2] * vec.z;

	return  GLVector3(x,y,z);
}
Matrix3&    Matrix3::operator=(Matrix3  &src)
{
	if (this != &src)
		memcpy(m,src.m,sizeof(Matrix3));
	return src;
}
///////////////////////////////////////////四元数的实现///////////////////////////////////////
Quaternion::Quaternion()
{
	w = 0.0f;
	x = 0.0f;
	y = 0.0f;
	z = 0.0f;
}

Quaternion::Quaternion(float w, float x, float y, float z)
{
	this->w = w;
	this->x = x;
	this->y = y;
	this->z = z;
}

Quaternion::Quaternion(float angle, GLVector3 &vec)
{
//半角
	float        _halfAngle = angle*3.14159265358/360.0f;
	float        _sinVector = sin(_halfAngle);
//单位化旋转向量
	float        _vector_length = sqrt(vec.x*vec.x+vec.y*vec.y+vec.z*vec.z);
	assert(_vector_length>=__EPS__);

	w = cos(_halfAngle);
	x = vec.x*_sinVector / _vector_length;
	y = vec.y*_sinVector / _vector_length;
	z = vec.z*_sinVector / _vector_length;
}

//Quaternion::Quaternion(float  angle,float   ax,float  ay,float  az)
//{
//	float     _halfAngle = angle*__MATH_PI__ / 360.0f;
//	float     _sinValue = sin(_halfAngle);
//	float     _length = sqrt(ax*ax+ay*ay+az*az);
//	assert(_length>=__EPS__);
//
//	w = cos(_halfAngle);
//	x = ax*_sinValue / _length;
//	y = ay*_sinValue / _length;
//	z = az*_sinValue / _length;
//}

Quaternion::Quaternion(Matrix   &rotate)
{
	float        _lamda = rotate.m[0][0] + rotate.m[1][1] + rotate.m[2][2] + 1.0f;
	assert(_lamda>__EPS__ &&  _lamda<=4.0f);
	w = 0.5f*sqrt(_lamda );

	float         w4 = 4.0f*w;
	x = (rotate.m[1][2]-rotate.m[2][1])/w4;
	y = (rotate.m[2][0]-rotate.m[0][2])/w4;
	z = (rotate.m[0][1]-rotate.m[1][0])/w4;
//进一步验证生成的数据的合法性,所得到的向量必须是单位向量
	assert(fabs(x*x+y*y+z*z-1.0f)<=__EPS__);
}

void      Quaternion::multiply(Quaternion &p)
{
	float    aw = w*p.w - x*p.x - y*p.y - z*p.z;
	float    ax = w*p.x + x*p.w+y*p.z - z*p.y;
	float    ay = w*p.y-x*p.z+y*p.w+z*p.x;
	float    az = w*p.z+x*p.y-y*p.x+z*p.w;
	w = aw, x = ax, y = ay, z = az;
}

Quaternion		Quaternion::operator*(Quaternion   &p)
{
	float    aw = w*p.w - x*p.x - y*p.y - z*p.z;
	float    ax = w*p.x + x*p.w + y*p.z - z*p.y;
	float    ay = w*p.y - x*p.z + y*p.w + z*p.x;
	float    az = w*p.z + x*p.y - y*p.x + z*p.w;

	return    Quaternion(aw,ax,ay,az);
}
void      Quaternion::identity()
{
	w = 1.0f;
	x = y = z = 0.0f;
}

void       Quaternion::normalize()
{
	float         _length = sqrt(w*w+x*x+y*y+z*z);
	assert(_length>__EPS__);

	w /= _length;
	x /= _length;
	y /= _length;
	z /= _length;
}

Matrix	    Quaternion::toRotateMatrix()
{
	Matrix      _rotate;
	float          xy = this->x * this->y;
	float          xz = this->x * this->z;
	float          yz = this->y * this->z;
	float         ww = this->w * this->w;

	_rotate.m[0][0] = 2 * (x*x + ww) - 1.0f;
	_rotate.m[0][1] =2.0f * (xy+ w*z) ;
	_rotate.m[0][2] = 2.0f*(xz - w*y);

	_rotate.m[1][0] = 2.0f*(xy - w*z);
	_rotate.m[1][1] = 2.0f*(y*y+ww)-1.0f;
	_rotate.m[1][2] = 2.0f*(yz * w*x);

	_rotate.m[2][0] = 2.0f*(xz + w*y);
	_rotate.m[2][1] = 2.0f*(yz - w*x);
	_rotate.m[2][2] = 2.0f*(z*z+ww) - 1.0f;

	return _rotate;
}

Quaternion       Quaternion::conjugate()
{
	return   Quaternion(w,-x,-y,-z);
}

Quaternion      Quaternion::reverse()
{
	float    _length = sqrt(w*w+x*x+y*y+z*z);
	assert(_length>=__EPS__);
	return    Quaternion( w/_length,-x/_length,-y/_length,-z/_length   );
}
//两个插值函数,以后再实现
