
//
//    A utility library for OpenGL ES.  This library provides a
//    basic common framework for the example applications in the
//    OpenGL ES 3.0 Programming Guide.
//Version:1.0 提供了对矩阵的最基本的操作,包括 单位矩阵,旋转矩阵,平移矩阵,缩放矩阵,投影矩阵,视图矩阵,矩阵乘法
//Version:2.0增加了镜像矩阵,以及3维矩阵的引入,2,3,4维向量的引入,并提供了对向量的基本操作<单位化,点乘,叉乘,长度>的支持
//Version:3.0 增加了对矩阵直接求逆的支持,以及法线矩阵的推导,行列式的直接支持,向量与矩阵的乘法
//Version:4.0 增加了对偏置矩阵的支持,可以直接对阴影进行操作
//Version 5.0 将所有的有关矩阵的操作纳入到矩阵类中,作为矩阵的成员函数实现,在以后的实际开发中,
//推荐使用新的类函数,因为他们的接口更友好,更方便
//Version 6.0 将切线的计算引入到球体,立方体,地面网格的生成算法中
//Version 7.0:修正球面的切线的计算,由原来的直接三角函数计算变成求球面的关于x的偏导
//Version 8.0:引入了对四元数的支持
//Version 9.0:修正了关于四元数与矩阵之间的转换间的bug,以及Matrix.scale函数的bug
///
//  Includes
//
#include<engine/Geometry.h>
#include<engine/GLState.h>
#include <math.h>
#include<string.h>
#include<assert.h>
#define PI 3.1415926535f
#define    __EPS__  0.0001f
#define    __SIGN(sign)   (-(  ((sign)&0x1)<<1)+1)
__NS_GLK_BEGIN
ESMatrix::ESMatrix()
{
	esMatrixLoadIdentity(this);
}
void esScale ( ESMatrix *result, float sx, float sy, float sz )
{
   result->m[0][0] *= sx;
   result->m[0][1] *= sy;
   result->m[0][2] *= sz;

   result->m[1][0] *= sx;
   result->m[1][1] *= sy;
   result->m[1][2] *= sz;

   result->m[2][0] *= sx;
   result->m[2][1] *= sy;
   result->m[2][2] *= sz;
}

void esTranslate ( ESMatrix *result, float tx, float ty, float tz )
{
   //result->m[3][0] += ( result->m[0][0] * tx + result->m[1][0] * ty + result->m[2][0] * tz );
   //result->m[3][1] += ( result->m[0][1] * tx + result->m[1][1] * ty + result->m[2][1] * tz );
   //result->m[3][2] += ( result->m[0][2] * tx + result->m[1][2] * ty + result->m[2][2] * tz );
   //result->m[3][3] += ( result->m[0][3] * tx + result->m[1][3] * ty + result->m[2][3] * tz );
	ESMatrix	translate;
	esMatrixLoadIdentity(&translate);
	translate.m[3][0]=tx;
	translate.m[3][1]=ty;
	translate.m[3][2]=tz;
	esMatrixMultiply(result,result,&translate);
}

void esRotate ( ESMatrix *result, float angle, float x, float y, float z )
{
   float sinAngle, cosAngle;
   float mag = sqrtf ( x * x + y * y + z * z );

   sinAngle = sinf ( angle * PI / 180.0f );
   cosAngle = cosf ( angle * PI / 180.0f );

   assert(mag>0.0f);
      float xx, yy, zz, xy, yz, zx, xs, ys, zs;
      float oneMinusCos;
      ESMatrix rotMat;

      x /= mag;
      y /= mag;
      z /= mag;

      xx = x * x;
      yy = y * y;
      zz = z * z;
      xy = x * y;
      yz = y * z;
      zx = z * x;
      xs = x * sinAngle;
      ys = y * sinAngle;
      zs = z * sinAngle;
      oneMinusCos = 1.0f - cosAngle;

      rotMat.m[0][0] = ( oneMinusCos * xx ) + cosAngle;
      rotMat.m[0][1] = ( oneMinusCos * xy ) + zs;
      rotMat.m[0][2] = ( oneMinusCos * zx ) - ys;
      rotMat.m[0][3] = 0.0F;

      rotMat.m[1][0] = ( oneMinusCos * xy ) - zs;
      rotMat.m[1][1] = ( oneMinusCos * yy ) + cosAngle;
      rotMat.m[1][2] = ( oneMinusCos * yz ) + xs;
      rotMat.m[1][3] = 0.0F;

      rotMat.m[2][0] = ( oneMinusCos * zx ) + ys;
      rotMat.m[2][1] = ( oneMinusCos * yz ) - xs;
      rotMat.m[2][2] = ( oneMinusCos * zz ) + cosAngle;
      rotMat.m[2][3] = 0.0F;

      rotMat.m[3][0] = 0.0F;
      rotMat.m[3][1] = 0.0F;
      rotMat.m[3][2] = 0.0F;
      rotMat.m[3][3] = 1.0F;

      esMatrixMultiply ( result, result,&rotMat);
}

void esFrustum ( ESMatrix *result, float left, float right, float bottom, float top, float nearZ, float farZ )
{
   float       deltaX = right - left;
   float       deltaY = top - bottom;
   float       deltaZ = farZ - nearZ;
   ESMatrix    frust;

   assert(deltaX>0.0f && deltaY>0.0f && deltaZ>0.0f && nearZ>0.0f);

   frust.m[0][0] = 2.0f * nearZ / deltaX;
   frust.m[0][1] = frust.m[0][2] = frust.m[0][3] = 0.0f;

   frust.m[1][1] = 2.0f * nearZ / deltaY;
   frust.m[1][0] = frust.m[1][2] = frust.m[1][3] = 0.0f;

   frust.m[2][0] = ( right + left ) / deltaX;
   frust.m[2][1] = ( top + bottom ) / deltaY;
   frust.m[2][2] = - ( nearZ + farZ ) / deltaZ;
   frust.m[2][3] = -1.0f;

   frust.m[3][2] = -2.0f * nearZ * farZ / deltaZ;
   frust.m[3][0] = frust.m[3][1] = frust.m[3][3] = 0.0f;

   esMatrixMultiply(result, result, &frust);
}


void esPerspective ( ESMatrix *result, float fovy, float aspect, float nearZ, float farZ )
{
   float frustumW, frustumH;

   frustumH = tanf ( fovy / 360.0f * PI ) * nearZ;
   frustumW = frustumH * aspect;

   esFrustum ( result, -frustumW, frustumW, -frustumH, frustumH, nearZ, farZ );
}

void esOrtho ( ESMatrix *result, float left, float right, float bottom, float top, float nearZ, float farZ )
{
   float       deltaX = right - left;
   float       deltaY = top - bottom;
   float       deltaZ = farZ - nearZ;
   ESMatrix    ortho;

   assert(deltaX>0.0f && deltaY>0.0f && deltaZ>0.0f);

   esMatrixLoadIdentity ( &ortho );
   ortho.m[0][0] = 2.0f / deltaX;
   ortho.m[3][0] = - ( right + left ) / deltaX;
   ortho.m[1][1] = 2.0f / deltaY;
   ortho.m[3][1] = - ( top + bottom ) / deltaY;
   ortho.m[2][2] = -2.0f / deltaZ;
   ortho.m[3][2] = - ( nearZ + farZ ) / deltaZ;

   esMatrixMultiply(result,  result, &ortho);
}


void esMatrixMultiply ( ESMatrix *result, ESMatrix *srcA, ESMatrix *srcB )
{
   ESMatrix    tmp;
   int         i;

   for ( i = 0; i < 4; i++ )
   {
      tmp.m[i][0] =  ( srcA->m[i][0] * srcB->m[0][0] ) +
                     ( srcA->m[i][1] * srcB->m[1][0] ) +
                     ( srcA->m[i][2] * srcB->m[2][0] ) +
                     ( srcA->m[i][3] * srcB->m[3][0] ) ;

      tmp.m[i][1] =  ( srcA->m[i][0] * srcB->m[0][1] ) +
                     ( srcA->m[i][1] * srcB->m[1][1] ) +
                     ( srcA->m[i][2] * srcB->m[2][1] ) +
                     ( srcA->m[i][3] * srcB->m[3][1] ) ;

      tmp.m[i][2] =  ( srcA->m[i][0] * srcB->m[0][2] ) +
                     ( srcA->m[i][1] * srcB->m[1][2] ) +
                     ( srcA->m[i][2] * srcB->m[2][2] ) +
                     ( srcA->m[i][3] * srcB->m[3][2] ) ;

      tmp.m[i][3] =  ( srcA->m[i][0] * srcB->m[0][3] ) +
                     ( srcA->m[i][1] * srcB->m[1][3] ) +
                     ( srcA->m[i][2] * srcB->m[2][3] ) +
                     ( srcA->m[i][3] * srcB->m[3][3] ) ;
   }

   memcpy ( result, &tmp, sizeof ( ESMatrix ) );
}


void esMatrixLoadIdentity ( ESMatrix *result )
{
   memset ( result, 0x0, sizeof ( ESMatrix ) );
   result->m[0][0] = 1.0f;
   result->m[1][1] = 1.0f;
   result->m[2][2] = 1.0f;
   result->m[3][3] = 1.0f;
}
//右乘偏置矩阵
void  esMatrixOffset(ESMatrix    *result)
{
	result->m[0][0] = result->m[0][0]*0.5f+0.5f;
	result->m[0][1] = result->m[0][1] * 0.5f + 0.5f;
	result->m[0][2] = result->m[0][2] * 0.5f + 0.5f;
	
	result->m[1][0] = result->m[1][0] * 0.5f + 0.5f;
	result->m[1][1] = result->m[1][1] * 0.5f + 0.5f;
	result->m[1][2] = result->m[1][2] * 0.5f + 0.5f;

	result->m[2][0] = result->m[2][0] * 0.5f + 0.5f;
	result->m[2][1] = result->m[2][1] * 0.5f + 0.5f;
	result->m[2][2] = result->m[2][2] * 0.5f + 0.5f;

	result->m[3][0] = result->m[3][0] * 0.5f + 0.5f;
	result->m[3][1] = result->m[3][1] * 0.5f + 0.5f;
	result->m[3][2] = result->m[3][2] * 0.5f + 0.5f;
}

void  esMatrixLoadOffset(ESMatrix  *result)
{
	result->m[0][0] = 0.5f;
	result->m[0][1] = 0.0f;
	result->m[0][2] = 0.0f;
	result->m[0][3] = 0.0f;

	result->m[1][0] = 0.0f;
	result->m[1][1] = 0.5f;
	result->m[1][2] = 0.0f;
	result->m[1][3] = 0.0f;

	result->m[2][0] = 0.0f;
	result->m[2][1] = 0.0f;
	result->m[2][2] = 0.5f;
	result->m[2][3] = 0.0f;

	result->m[3][0] = 0.5f;
	result->m[3][1] = 0.5f;
	result->m[3][2] = 0.5f;
	result->m[3][3] = 1.0f;
}

void esMatrixLookAt ( ESMatrix *result,GLVector3    *eyePosition, GLVector3    *viewPosition,GLVector3    *up )
{
   float axisX[3], axisY[3], axisZ[3];
   float length;

   // axisZ = lookAt - pos
   axisZ[0] = viewPosition->x - eyePosition->x;
   axisZ[1] = viewPosition->y - eyePosition->y;
   axisZ[2] = viewPosition->z - eyePosition->z;

   // normalize axisZ
   length =sqrtf( axisZ[0] * axisZ[0] + axisZ[1] * axisZ[1] + axisZ[2] * axisZ[2] );
   assert(length>0.0f);
   axisZ[0] /= length;
   axisZ[1] /= length;
   axisZ[2] /= length;

   // axisX = up X axisZ
   axisX[0] = up->y * axisZ[2] - up->z * axisZ[1];
   axisX[1] = up->z * axisZ[0] - up->x * axisZ[2];
   axisX[2] = up->x * axisZ[1] - up->y * axisZ[0];

   // normalize axisX
   length =sqrtf( axisX[0] * axisX[0] + axisX[1] * axisX[1] + axisX[2] * axisX[2] );
   assert(length>0.0f);
   axisX[0] /= length;
   axisX[1] /= length;
   axisX[2] /= length;

   // axisY = axisZ x axisX
   axisY[0] = axisZ[1] * axisX[2] - axisZ[2] * axisX[1];
   axisY[1] = axisZ[2] * axisX[0] - axisZ[0] * axisX[2];
   axisY[2] = axisZ[0] * axisX[1] - axisZ[1] * axisX[0];

   // normalize axisY
   length =sqrtf( axisY[0] * axisY[0] + axisY[1] * axisY[1] + axisY[2] * axisY[2] );

   assert(length > 0.0f);
   axisY[0] /= length;
   axisY[1] /= length;
   axisY[2] /= length;

   memset ( result, 0x0, sizeof ( ESMatrix ) );

   result->m[0][0] = -axisX[0];
   result->m[0][1] =  axisY[0];
   result->m[0][2] = -axisZ[0];

   result->m[1][0] = -axisX[1];
   result->m[1][1] =  axisY[1];
   result->m[1][2] = -axisZ[1];

   result->m[2][0] = -axisX[2];
   result->m[2][1] =  axisY[2];
   result->m[2][2] = -axisZ[2];

   // translate (-posX, -posY, -posZ)
   result->m[3][0] =  axisX[0] * eyePosition->x + axisX[1] * eyePosition->y + axisX[2] * eyePosition->z;
   result->m[3][1] = -axisY[0] * eyePosition->x - axisY[1] * eyePosition->y - axisY[2] * eyePosition->z;
   result->m[3][2] = axisZ[0] * eyePosition->x + axisZ[1] * eyePosition->y + axisZ[2] * eyePosition->z;
   result->m[3][3] = 1.0f;
}
void esMatrixLookAt(ESMatrix *result ,float posX, float posY, float posZ,
	                                                                float lookAtX, float lookAtY, float lookAtZ,
                                                                    float upX, float upY, float upZ)
{
	float axisX[3], axisY[3], axisZ[3];
	float length;

	// axisZ = lookAt - pos
	axisZ[0] = lookAtX - posX;
	axisZ[1] = lookAtY - posY;
	axisZ[2] = lookAtZ - posZ;

	// normalize axisZ
	length = sqrtf(axisZ[0] * axisZ[0] + axisZ[1] * axisZ[1] + axisZ[2] * axisZ[2]);

	if (length != 0.0f)
	{
		axisZ[0] /= length;
		axisZ[1] /= length;
		axisZ[2] /= length;
	}

	// axisX = up X axisZ
	axisX[0] = upY * axisZ[2] - upZ * axisZ[1];
	axisX[1] = upZ * axisZ[0] - upX * axisZ[2];
	axisX[2] = upX * axisZ[1] - upY * axisZ[0];

	// normalize axisX
	length = sqrtf(axisX[0] * axisX[0] + axisX[1] * axisX[1] + axisX[2] * axisX[2]);

	if (length != 0.0f)
	{
		axisX[0] /= length;
		axisX[1] /= length;
		axisX[2] /= length;
	}

	// axisY = axisZ x axisX
	axisY[0] = axisZ[1] * axisX[2] - axisZ[2] * axisX[1];
	axisY[1] = axisZ[2] * axisX[0] - axisZ[0] * axisX[2];
	axisY[2] = axisZ[0] * axisX[1] - axisZ[1] * axisX[0];

	// normalize axisY
	length = sqrtf(axisY[0] * axisY[0] + axisY[1] * axisY[1] + axisY[2] * axisY[2]);

	if (length != 0.0f)
	{
		axisY[0] /= length;
		axisY[1] /= length;
		axisY[2] /= length;
	}

	memset(result, 0x0, sizeof(ESMatrix));

	result->m[0][0] = -axisX[0];
	result->m[0][1] = axisY[0];
	result->m[0][2] = -axisZ[0];

	result->m[1][0] = -axisX[1];
	result->m[1][1] = axisY[1];
	result->m[1][2] = -axisZ[1];

	result->m[2][0] = -axisX[2];
	result->m[2][1] = axisY[2];
	result->m[2][2] = -axisZ[2];

	// translate (-posX, -posY, -posZ)
	result->m[3][0] = axisX[0] * posX + axisX[1] * posY + axisX[2] * posZ;
	result->m[3][1] = -axisY[0] * posX - axisY[1] * posY - axisY[2] * posZ;
	result->m[3][2] = axisZ[0] * posX + axisZ[1] * posY + axisZ[2] * posZ;
	result->m[3][3] = 1.0f;
}
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
		const float   _real_radius=radius*sinf(angleStep*i);
		const float   _real_cos=radius*cosf(angleStep*i);
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
					_tangent[vertex] = cosf(j*angleStep);
					_tangent[vertex + 1] = 0.0f;
					_tangent[vertex + 2] = sinf(j*angleStep);
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
	float     _distance = sqrtf(src->x*src->x+src->y*src->y+src->z*src->z);
	assert(_distance>0);

	return  GLVector3(src->x/_distance,src->y/_distance,src->z/_distance);
}
GLVector2   normalize(GLVector2    *src)
{
	float    _distance = sqrtf(src->x*src->x+src->y*src->y);
	assert(_distance>0);
	return  GLVector2(src->x/_distance,src->y/_distance);
}
//矩阵截断
void    esMatrixTrunk(ESMatrix3   *dst, ESMatrix  *src)
{
	dst->mat3[0][0] = src->m[0][0];
	dst->mat3[0][1] = src->m[0][1];
	dst->mat3[0][2] = src->m[0][2];

	dst->mat3[1][0] = src->m[1][0];
	dst->mat3[1][1] = src->m[1][1];
	dst->mat3[1][2] = src->m[1][2];

	dst->mat3[2][0] = src->m[2][0];
	dst->mat3[2][1] = src->m[2][1];
	dst->mat3[2][2] = src->m[2][2];

}
void      esMatrixNormal(ESMatrix3  *result, ESMatrix   *src)
{
	result->mat3[0][0] = src->m[0][0];
	result->mat3[0][1] = src->m[0][1];
	result->mat3[0][2] = src->m[0][2];

	result->mat3[1][0] = src->m[1][0];
	result->mat3[1][1] = src->m[1][1];
	result->mat3[1][2] = src->m[1][2];

	result->mat3[2][0] = src->m[2][0];
	result->mat3[2][1] = src->m[2][1];
	result->mat3[2][2] = src->m[2][2];
//求逆矩阵
	esMatrixReverse(result, result);
//转置
	esMatrixTranspose(result, result);
//单位化,后来证明这是画蛇添足
	//GLVector3   vec1 =normalize(&GLVector3(result->mat3[0][0],result->mat3[0][1],result->mat3[0][2]));
	//GLVector3   vec2 = normalize(&GLVector3(result->mat3[1][0],result->mat3[1][1],result->mat3[1][2]));
	//GLVector3   vec3 = normalize(&GLVector3(result->mat3[2][0],result->mat3[2][1],result->mat3[2][2]));

	//result->mat3[0][0] = vec1.x, result->mat3[0][1] = vec1.y, result->mat3[0][2] = vec1.z;
	//result->mat3[1][0] = vec2.x, result->mat3[1][1] = vec2.y, result->mat3[1][2] = vec2.z;
	//result->mat3[2][0] = vec3.x, result->mat3[2][1] = vec2.y, result->mat3[2][2] = vec3.z;
}
//镜像矩阵
void       esMatrixMirror(ESMatrix   *result, float  x, float  y, float z)
{
	float    _mag = sqrtf(x*x+y*y+z*z);
	assert(_mag);
	x /= _mag;
	y /= _mag;
	z /= _mag;
	float     xy = x*y;
	float     xz = x*z;
	float     yz = y*z;

	ESMatrix     mirror;

	mirror.m[0][0] = 1-2*x*x;
	mirror.m[0][1] = -2 * xy;
	mirror.m[0][2] = -2 * xz;
	mirror.m[0][3] = 0.0f;

	mirror.m[1][0] = -2 * xy;
	mirror.m[1][1] = 1 - 2 * y*y;
	mirror.m[1][2] = -2 * yz;
	mirror.m[1][3] = 0.0f;

	mirror.m[2][0] = -2 * xz;
	mirror.m[2][1] = -2 * yz;
	mirror.m[2][2] = 1 - 2 * z*z;
	mirror.m[2][3] = 0.0f;

	mirror.m[3][0] = 0.0f;
	mirror.m[3][1] = 0.0f;
	mirror.m[3][2] = 0.0f;
	mirror.m[3][3] = 1.0f;

	esMatrixMultiply(result, result, &mirror);
}
//行列式计算
float     detFloat(float x1, float y1, float x2, float y2)
{
	return  x1*y2 - y1*x2;
}
float    detVector2(GLVector2   *a, GLVector2   *b)
{
	return a->x*b->y - a->y*b->x;
}
//三阶矩阵的行列式
float    detMatrix3(ESMatrix3   *mat)
{
	float     _result ;
	_result = mat->mat3[0][0] * (mat->mat3[1][1]*mat->mat3[2][2]-mat->mat3[1][2]*mat->mat3[2][1]);
	_result -= mat->mat3[0][1] * (mat->mat3[1][0]*mat->mat3[2][2]-mat->mat3[1][2]*mat->mat3[2][0]);
	_result += mat->mat3[0][2] * (mat->mat3[1][0]*mat->mat3[2][1]-mat->mat3[1][1]*mat->mat3[2][0]);

	return _result;
}
//
float   detVector3(GLVector3    *a,GLVector3       *b,GLVector3  *c)
{
	float   _result = 0;
	_result =a->x* (b->y*c->z-b->z*c->y);
	_result -= a->y*(b->x*c->z-b->z*c->x);
	_result += a->z*(b->x*c->y-b->y*c->x);
	return _result;
}
float     detMatrix(ESMatrix    *src)
{
	GLVector3   row1, row2, row3;
	float  _det;
//0,0
	row1 = GLVector3(src->m[1][1], src->m[1][2], src->m[1][3]);
	row2 = GLVector3(src->m[2][1], src->m[2][2], src->m[2][3]);
	row3 = GLVector3(src->m[3][1], src->m[3][2], src->m[3][3]);
	_det = src->m[0][0] * detVector3(&row1, &row2, &row3);
//0,1
	row1 = GLVector3(src->m[1][0], src->m[1][2], src->m[1][3]);
	row2 = GLVector3(src->m[2][0], src->m[2][2], src->m[2][3]);
	row3 = GLVector3(src->m[3][0], src->m[3][2], src->m[3][3]);
	_det -= src->m[0][1] * detVector3(&row1, &row2, &row3);
//0,2
	row1 = GLVector3(src->m[1][0],src->m[1][1],src->m[1][3]);
	row2 = GLVector3(src->m[2][0],src->m[2][1],src->m[2][3]);
	row3 = GLVector3(src->m[3][0], src->m[3][1], src->m[3][3]);
	_det += src->m[0][2] * detVector3(&row1, &row2, &row3);
//0,3
	row1 = GLVector3(src->m[1][0],src->m[1][1],src->m[1][2]);
	row2 = GLVector3(src->m[2][0],src->m[2][1],src->m[2][2]);
	row3 = GLVector3(src->m[3][0],src->m[3][1],src->m[3][2]);
	_det -= src->m[0][3] * detVector3(&row1, &row2, &row3);
	return _det;
}
//////////////////////////////////////////////////////////////////////
void     esMatrixReverse(ESMatrix3 *result, ESMatrix3 *src)
{
	ESMatrix3      tmp;
	ESMatrix3      *p = &tmp;

	float     _det = detMatrix3(src);
	assert(fabs(_det)>__EPS__);
	if (result != src)  p = result;
	p->mat3[0][0] = detFloat(src->mat3[1][1], src->mat3[1][2], src->mat3[2][1], src->mat3[2][2]) / _det;
	p->mat3[1][0] = -detFloat(src->mat3[1][0], src->mat3[1][2], src->mat3[2][0], src->mat3[2][2]) / _det;
	p->mat3[2][0] = detFloat(src->mat3[1][0], src->mat3[1][1], src->mat3[2][0], src->mat3[2][1]) / _det;

	p->mat3[0][1] = -detFloat(src->mat3[0][1], src->mat3[0][2], src->mat3[2][1], src->mat3[2][2]) / _det;
	p->mat3[1][1] = detFloat(src->mat3[0][0], src->mat3[0][2], src->mat3[2][0], src->mat3[2][2]) / _det;
	p->mat3[2][1] = -detFloat(src->mat3[0][0], src->mat3[0][1], src->mat3[2][0], src->mat3[2][1]) / _det;

	p->mat3[0][2] = detFloat(src->mat3[0][1], src->mat3[0][2], src->mat3[1][1], src->mat3[1][2]) / _det;
	p->mat3[1][2] = -detFloat(src->mat3[0][0], src->mat3[0][2], src->mat3[1][0], src->mat3[1][2]) / _det;
	p->mat3[2][2] = detFloat(src->mat3[0][0], src->mat3[0][1], src->mat3[1][0], src->mat3[1][1]) / _det;

	if (result == src)   memcpy(result, p, sizeof(ESMatrix3));
}
//四维矩阵的逆
static   void   __fix__(int  *_index,int  _current)//辅助函数
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
void     esMatrixReverse(ESMatrix    *result, ESMatrix    *src)
{
	ESMatrix     tmp;
	ESMatrix     *p = &tmp;
	if (result != src)p = result;
	float             _det = detMatrix(src);
	assert(fabs(_det)>__EPS__);
	GLVector3    row1, row2, row3;
	int        _index[4];
	for (int i = 0; i < 4; ++i)
	{
		__fix__(_index,i);
		int     a = _index[0], b = _index[1], c = _index[2];
//i,0
		row1 = GLVector3(src->m[a][1],src->m[a][2],src->m[a][3]);
		row2 = GLVector3(src->m[b][1],src->m[b][2],src->m[b][3]);
		row3 = GLVector3(src->m[c][1],src->m[c][2],src->m[c][3]);
		p->m[0][i] = __SIGN(i + 0)*detVector3(&row1,&row2,&row3);
//i,1
		row1 = GLVector3(src->m[a][0],src->m[a][2],src->m[a][3]);
		row2 = GLVector3(src->m[b][0],src->m[b][2],src->m[b][3]);
		row3 = GLVector3(src->m[c][0],src->m[c][2],src->m[c][3]);
		p->m[1][i] = __SIGN(i + 1)*detVector3(&row1, &row2, &row3);
//i,2
		row1 = GLVector3(src->m[a][0],src->m[a][1],src->m[a][3]);
		row2 = GLVector3(src->m[b][0],src->m[b][1],src->m[b][3]);
		row3 = GLVector3(src->m[c][0],src->m[c][1],src->m[c][3]);
		p->m[2][i] = __SIGN(i + 2)*detVector3(&row1, &row2, &row3);
//i,3
		row1 = GLVector3(src->m[a][0],src->m[a][1],src->m[a][2]);
		row2 = GLVector3(src->m[b][0],src->m[b][1],src->m[b][2]);
		row3 = GLVector3(src->m[c][0],src->m[c][1],src->m[c][2]);
		p->m[3][i] = __SIGN(i + 3)*detVector3(&row1, &row2, &row3);
	}
	if (result == src) memcpy(result,p,sizeof(ESMatrix));
}
//矩阵转置实现
void      esMatrixTranspose(ESMatrix3 *result, ESMatrix3 *src)
{
	ESMatrix3     tmp;
	ESMatrix3     *p = &tmp;
	if (result != src) p = result;

	p->mat3[0][0] = src->mat3[0][0];
	p->mat3[0][1] = src->mat3[1][0];
	p->mat3[0][2] = src->mat3[2][0];

	p->mat3[1][0] = src->mat3[0][1];
	p->mat3[1][1] = src->mat3[1][1];
	p->mat3[1][2] = src->mat3[2][1];

	p->mat3[2][0] = src->mat3[0][2];
	p->mat3[2][1] = src->mat3[1][2];
	p->mat3[2][2] = src->mat3[2][2];
	if (result == src)memcpy(result,p,sizeof(ESMatrix3));
}
void   esMatrixTranspose(ESMatrix *result, ESMatrix *src)
{
	ESMatrix   tmp;
	ESMatrix  *p = &tmp;
	if (result != src) p = result;

	int  i;
	for (i = 0; i < 4; ++i)
	{
		   p->m[i][0] = src->m[0][i];
		   p->m[i][1] = src->m[1][i];
		   p->m[i][2] = src->m[2][i];
		   p->m[i][3] = src->m[3][i];
	}
	if (result == src)   memcpy(result,p,sizeof(ESMatrix));
}
//三阶矩阵乘法
void     esMatrixMultiply3(ESMatrix3   *result,ESMatrix3   *srcA,ESMatrix3  *srcB)
{
	ESMatrix3    tmp;
	for (int i = 0; i < 3; ++i)
	{
		tmp.mat3[i][0] = srcA->mat3[i][0] * srcB->mat3[0][0] + srcA->mat3[i][1] * srcB->mat3[1][0] + srcA->mat3[i][2] * srcB->mat3[2][0];

		tmp.mat3[i][1] = srcA->mat3[i][0] * srcB->mat3[0][1] + srcA->mat3[i][1] * srcB->mat3[1][1] + srcA->mat3[i][2] * srcB->mat3[2][1];

		tmp.mat3[i][2] = srcA->mat3[i][0] * srcB->mat3[0][2] + srcA->mat3[i][1] * srcB->mat3[1][2] + srcA->mat3[i][2] * srcB->mat3[2][2];
	}
	memcpy(result,&tmp,sizeof(ESMatrix3));
}
//向量乘法,左乘
GLVector4     esMatrixMultiplyVector4(GLVector4 *vec, ESMatrix *matrix)
{
	float x, y, z, w;
	x = vec->x*matrix->m[0][0]+vec->y*matrix->m[1][0]+vec->z*matrix->m[2][0]+vec->w*matrix->m[3][0];
	y = vec->x*matrix->m[0][1] + vec->y*matrix->m[1][1] + vec->z*matrix->m[2][1] + vec->w*matrix->m[3][1];
	z = vec->x*matrix->m[0][2] + vec->y*matrix->m[1][2] + vec->z*matrix->m[2][2] + vec->w*matrix->m[3][2];
	w = vec->x*matrix->m[0][3] + vec->y*matrix->m[1][3] + vec->z*matrix->m[2][3] + vec->w*matrix->m[3][3];
	return GLVector4(x,y,z,w);
}
//向量右乘
GLVector4    esMatrixMultiplyVector4(ESMatrix   *matrix, GLVector4   *vec)
{
	float x, y, z, w;
	x = matrix->m[0][0] * vec->x + matrix->m[0][1] * vec->y + matrix->m[0][2] * vec->z + matrix->m[0][3] * vec->w;
	y = matrix->m[1][0] * vec->x + matrix->m[1][1] * vec->y + matrix->m[1][2] * vec->z + matrix->m[1][3] * vec->w;
	z = matrix->m[2][0] * vec->x + matrix->m[2][1] * vec->y + matrix->m[2][2] * vec->z + matrix->m[2][3] * vec->w;
	w = matrix->m[3][0] * vec->x + matrix->m[3][1] * vec->y + matrix->m[3][2] * vec->z + matrix->m[3][3] * vec->w;
	return GLVector4(x,y,z,w);
}

GLVector3      esMatrixMultiplyVector3(ESMatrix3   *matrix, GLVector3   *vec)
{
	float x, y, z;
	x = matrix->mat3[0][0] * vec->x + matrix->mat3[0][1] * vec->y + matrix->mat3[0][2] * vec->z;
	y = matrix->mat3[1][0] * vec->x + matrix->mat3[1][1] * vec->y + matrix->mat3[1][2] * vec->z;
	z = matrix->mat3[2][0] * vec->x + matrix->mat3[2][1] * vec->y + matrix->mat3[2][2] * vec->z;
	return GLVector3(x,y,z);
}

GLVector3      esMatrixMultiplyVector3( GLVector3   *vec, ESMatrix3   *matrix)
{
	float x, y, z;
	x = vec->x*matrix->mat3[0][0] + vec->y*matrix->mat3[1][0] + vec->z*matrix->mat3[2][0];
	y = vec->x*matrix->mat3[0][1] + vec->y*matrix->mat3[1][1] + vec->z*matrix->mat3[2][1];
	z = vec->x*matrix->mat3[0][2] + vec->y*matrix->mat3[1][2] + vec->z*matrix->mat3[2][2];
	return GLVector3(x,y,z);
}
/////////////////////////////二维,三维,四维向量右乘矩阵//////////////////////////////////////
GLVector2    GLVector2::operator*(float  _factor)const
{
	return   GLVector2(x*_factor,y*_factor);
}
GLVector2   GLVector2::operator*(GLVector2  &_mfactor)const
{
	return  GLVector2(x*_mfactor.x,y*_mfactor.y);
}
GLVector2   GLVector2::operator+(GLVector2  &_factor)const
{
	return  GLVector2(x+_factor.x,y+_factor.y);
}
GLVector2   GLVector2::operator-(GLVector2  &_factor)const
{
	return  GLVector2(x-_factor.x,y-_factor.y);
}
GLVector2   GLVector2::operator/(float _factor)const
{
	return  GLVector2(x/_factor,y/_factor);
}
GLVector2    GLVector2::operator/(GLVector2  &_factor)const
{
	return  GLVector2(x/_factor.x,y/_factor.y);
}

GLVector2& GLVector2::operator=(const GLVector2 &src)
{
	x = src.x, y = src.y;
	return *this;
}

GLVector2   GLVector2::normalize()const
{
	float  _length = sqrtf(x*x+y*y);
	assert(_length>=__EPS__);
	return  GLVector2(x/_length,y/_length);
}
float     GLVector2::dot(GLVector2 &other)const
{
	return x*other.x + y*other.y;
}

const float GLVector2::length()const
{
	return sqrtf(x*x+y*y);
}
/////////////////////////////333333333333333333////////////////////////////////////
GLVector4   GLVector3::xyzw0()const
{
	return GLVector4(x,y,z,0.0f);
}

GLVector4 GLVector3::xyzw1()const
{
	return GLVector4(x,y,z,1.0f);
}
GLVector3   GLVector3::operator*(const Matrix3 &src)const
{
	float  x, y, z;
	x = this->x*src.m[0][0] + this->y*src.m[1][0] + this->z*src.m[2][0];
	y = this->x*src.m[0][1] + this->y*src.m[1][1] + this->z*src.m[2][1];
	z = this->x*src.m[0][2] + this->y*src.m[1][2] + this->z*src.m[2][2];

	return  GLVector3(x,y,z);
}
GLVector3    GLVector3::operator*(const float   _factor)const
{
	return  GLVector3(x*_factor,y*_factor,z*_factor);
}
GLVector3   GLVector3::operator*(const GLVector3  &_factor)const
{
	return  GLVector3(x*_factor.x,y*_factor.y,z*_factor.z);
}
GLVector3   GLVector3::operator+(const GLVector3  &_factor)const
{
	return  GLVector3(x+_factor.x,y+_factor.y,z+_factor.z);
}
GLVector3   GLVector3::operator-(const GLVector3 &_factor)const
{
	return  GLVector3(x-_factor.x,y-_factor.y,z-_factor.z);
}
GLVector3   GLVector3::operator/(const float _factor)const
{
	return  GLVector3(x/_factor,y/_factor,z/_factor);
}
GLVector3   GLVector3::operator/(const GLVector3 &_factor)const
{
	return   GLVector3(x/_factor.x,y/_factor.y,z/_factor.z);
}
GLVector3   GLVector3::normalize()const
{
	float      _length = sqrtf(x*x+y*y+z*z);
	assert(_length>=__EPS__);
	return    GLVector3(x/_length,y/_length,z/_length);
}
GLVector3   GLVector3::cross(const GLVector3 &axis)const
{
	return GLVector3(
		y*axis.z - z*axis.y,
		-x*axis.z + z*axis.x,
		x*axis.y - y*axis.x
		);
}
float    GLVector3::dot(const GLVector3 &other)const
{
	return x*other.x + y*other.y + z*other.z;
}
const float GLVector3::length()const
{
	return sqrtf(x*x+y*y+z*z);
}

GLVector3 GLVector3::min(const GLVector3 &other)const
{
	const float nx = x < other.x ? x : other.x;
	const float ny = y < other.y ? y : other.y;
	const float nz = z < other.z ? z : other.z;
	return GLVector3(nx, ny, nz);
}

GLVector3 GLVector3::max(const GLVector3 &other)const
{
	const float nx = x > other.x ? x : other.x;
	const float ny = y > other.y ? y : other.y;
	const float nz = z > other.z ? z : other.z;
	return GLVector3(nx, ny, nz);
}

/////////////////////////4444444444444444///////////////////////////////////////
GLVector4     GLVector4::operator*(Matrix &src)const
{
	float  nx,ny, nz, nw;
	nx = this->x*src.m[0][0] + this->y*src.m[1][0] + this->z*src.m[2][0] + this->w*src.m[3][0];
	ny = this->x*src.m[0][1] + this->y*src.m[1][1] + this->z*src.m[2][1] + this->w*src.m[3][1];
	nz = this->x*src.m[0][2] + this->y*src.m[1][2] + this->z*src.m[2][2] + this->w*src.m[3][2];
	nw = this->x*src.m[0][3] + this->y*src.m[1][3] + this->z*src.m[2][3] + this->w*src.m[3][3];
	return GLVector4(nx, ny, nz, nw);
}
GLVector4    GLVector4::normalize()const
{
	float   _length = sqrtf(x*x+y*y+z*z+w*w);
	assert(_length>__EPS__);
	return  GLVector4(x/_length,y/_length,z/_length,w/_length);
}
float    GLVector4::dot(GLVector4 &other)const
{
	return x*other.x + y*other.y + z*other.z + w*other.w;
}

GLVector4 GLVector4::operator*(const float factor)const
{
	return GLVector4(x*factor,y*factor,z*factor,w*factor);
}

GLVector4 GLVector4::operator*(const GLVector4 &other)const
{
	return GLVector4(x*other.x,y*other.y,z*other.z,w*other.w);
}

GLVector4 GLVector4::operator+(const GLVector4 &other)const
{
	return GLVector4(x+other.x,y+other.y,z+other.z,w+other.w);
}

GLVector4 GLVector4::operator/(const GLVector4 &other)const
{
	return GLVector4(x/other.x,y/other.y,z/other.z,w/other.w);
}

GLVector4 GLVector4::operator/(const float factor)const
{
	return GLVector4(x/factor,y/factor,z/factor,w/factor);
}

GLVector4 GLVector4::operator-(const GLVector4 &other)const
{
	return GLVector4(x-other.x,y-other.y,z-other.z,w-other.w);
}

GLVector4 GLVector4::min(const GLVector4 &other)const
{
	const float nx = x < other.x ? x : other.x;
	const float ny = y < other.y ? y : other.y;
	const float nz = z < other.z ? z : other.z;
	const float nw = w < other.w ? w : other.w;
	return GLVector4(nx,ny,nz,nw);
}

GLVector4 GLVector4::max(const GLVector4 &other)const
{
	const float nx = x > other.x ? x : other.x;
	const float ny = y > other.y ? y : other.y;
	const float nz = z > other.z ? z : other.z;
	const float nw = w > other.w ? w : other.w;
	return GLVector4(nx, ny, nz, nw);
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
void    Matrix::copy(const Matrix  &srcA)
{
	m[0][0] = srcA.m[0][0], m[0][1] = srcA.m[0][1], m[0][2] = srcA.m[0][2], m[0][3] = srcA.m[0][3];
	m[1][0] = srcA.m[1][0], m[1][1] = srcA.m[1][1], m[1][2] = srcA.m[1][2], m[1][3] = srcA.m[1][3];
	m[2][0] = srcA.m[2][0], m[2][1] = srcA.m[2][1], m[0][2] = srcA.m[2][2], m[2][3] = srcA.m[2][3];
	m[3][0] = srcA.m[3][0], m[3][1] = srcA.m[3][1], m[3][2] = srcA.m[3][2], m[3][3] = srcA.m[3][3];
}
//右乘缩放矩阵
void   Matrix::scale(const float scaleX, const float scaleY, const float  scaleZ)
{
	m[0][0] *= scaleX; m[0][1] *= scaleY; m[0][2] *= scaleZ; 
	m[1][0] *= scaleX; m[1][1] *= scaleY; m[1][2] *= scaleZ; 
	m[2][0] *= scaleX; m[2][1] *= scaleY; m[2][2] *= scaleZ; 
	m[3][0] *= scaleX; m[3][1] *= scaleY; m[3][2] *= scaleZ; 
}
//平移
void    Matrix::translate(const float deltaX, const float  deltaY, const float deltaZ)
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

void Matrix::translate(const GLVector3 &deltaXYZ)
{
	m[0][0] += m[0][3] * deltaXYZ.x;
	m[0][1] += m[0][3] * deltaXYZ.y;
	m[0][2] += m[0][3] * deltaXYZ.z;

	m[1][0] += m[1][3] * deltaXYZ.x;
	m[1][1] += m[1][3] * deltaXYZ.y;
	m[1][2] += m[1][3] * deltaXYZ.z;

	m[2][0] += m[2][3] * deltaXYZ.x;
	m[2][1] += m[2][3] * deltaXYZ.y;
	m[2][2] += m[2][3] * deltaXYZ.z;

	m[3][0] += m[3][3] * deltaXYZ.x;
	m[3][1] += m[3][3] * deltaXYZ.y;
	m[3][2] += m[3][3] * deltaXYZ.z;
}

void    Matrix::rotateX(float pitch)
{
	Matrix  matX;

	const float sinX = sinf(pitch*_RADIUS_FACTOR_);
	const float cosX = cosf(pitch * _RADIUS_FACTOR_);

	matX.m[1][1] = cosX;
	matX.m[1][2] = sinX;
	
	matX.m[2][1] = -sinX;
	matX.m[2][2] = cosX;
	this->multiply(matX);
}

void Matrix::rotateY(float yaw)
{
	Matrix matY;

	const float sinY = sinf(yaw*_RADIUS_FACTOR_);
	const float cosY = cosf(yaw*_RADIUS_FACTOR_);

	matY.m[0][0] = cosY;
	matY.m[0][2] = -sinY;

	matY.m[2][0] = sinY;
	matY.m[2][2] = cosY;
	this->multiply(matY);
}

void Matrix::rotateZ(float roll)
{
	Matrix matZ;
	const float sinZ = sinf(roll*_RADIUS_FACTOR_);
	const float cosZ = cosf(roll*_RADIUS_FACTOR_);

	matZ.m[0][0] = cosZ;
	matZ.m[0][1] = sinZ;

	matZ.m[1][0] = -sinZ;
	matZ.m[1][1] = cosZ;
	this->multiply(matZ);
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
void    Matrix::lookAt(const GLVector3  &eyePosition, const GLVector3  &targetPosition, const GLVector3  &upVector)
{
	Matrix    tmp, *result = &tmp;
	GLVector3    N = (eyePosition - targetPosition).normalize();
	GLVector3    U =upVector.cross(N).normalize() ;
	assert(U.x*U.x+U.y*U.y+U.z*U.z>__EPS__);
	GLVector3    V = N.cross(U);
	memset(result, 0x0, sizeof(ESMatrix));
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
	ESMatrix    tmp;
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
Matrix     Matrix::operator*(const Matrix   &srcA)const
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
GLVector4  Matrix::operator*(const GLVector4  &vec)const
{
	float   x, y, z, w;
	x = vec.x*m[0][0] + vec.y*m[1][0] + vec.z*m[2][0] + vec.w*m[3][0];
	y = vec.x*m[0][1] + vec.y*m[1][1] + vec.z*m[2][1] + vec.w*m[3][1];
	z = vec.x*m[0][2] + vec.y*m[1][2] + vec.z*m[2][2] + vec.w*m[3][2];
	w = vec.x*m[0][3] + vec.y*m[1][3] + vec.z*m[2][3] + vec.w*m[3][3];
	return GLVector4(x, y, z, w);
}

Matrix&    Matrix::operator=(const Matrix  &src)
{
	if (this!=&src)
	memcpy(this,&src,sizeof(Matrix));
	return *this;
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

Matrix             Matrix::reverse()const
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
float           Matrix::det()const
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

Matrix3     Matrix::normalMatrix()const
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
	tmp = tmp.reverse();
//转置
#define     _SWAP_MAT3_(i,k) temp=tmp.m[i][k],  tmp.m[i][k]=tmp.m[k][i],tmp.m[k][i]=temp;
	_SWAP_MAT3_(0, 1)
    _SWAP_MAT3_(0, 2)
	_SWAP_MAT3_(1, 2)
#undef _SWAP_MAT3_
   return  tmp;
}

Matrix3    Matrix::trunk()const
{
	Matrix3   tmp;
#define   _MATRIX_TRUNK_(i,k)   tmp.m[i][k]=m[i][k]
	_MATRIX_TRUNK_(0, 0);
	_MATRIX_TRUNK_(0, 1);
	_MATRIX_TRUNK_(0, 2);

	_MATRIX_TRUNK_(1, 0);
	_MATRIX_TRUNK_(1, 1);
	_MATRIX_TRUNK_(1, 2);

	_MATRIX_TRUNK_(2, 0);
	_MATRIX_TRUNK_(2, 1);
	_MATRIX_TRUNK_(2, 2);
#undef _MATRIX_TRUNK_
	return tmp;
}
//偏置矩阵
void     Matrix::offset()
{
#define    _OFFSET_MATRIX(i,k)  m[i][k]=m[i][k]*0.5f+temp
	float  temp = m[0][3] * 0.5f;
	_OFFSET_MATRIX(0, 0);
	_OFFSET_MATRIX(0, 1);
	_OFFSET_MATRIX(0, 2);

	temp = m[1][3] * 0.5f;
	_OFFSET_MATRIX(1, 0);
	_OFFSET_MATRIX(1, 1);
	_OFFSET_MATRIX(1, 2);

	temp = m[2][3] * 0.5f;
	_OFFSET_MATRIX(2, 0);
	_OFFSET_MATRIX(2, 1);
	_OFFSET_MATRIX(2, 2);

	temp = m[3][3] * 0.5f;
	_OFFSET_MATRIX(3, 0);
	_OFFSET_MATRIX(3, 1);
	_OFFSET_MATRIX(3, 2);
#undef _OFFSET_MATRIX
}
//////////////////////////////三维矩阵//////////////////////////
Matrix3::Matrix3()
{
	m[0][0] = 1.0f; m[0][1] = 0.0f, m[0][2] = 0.0f;
	m[1][0] = 0.0f, m[1][1] = 1.0f, m[1][2] = 0.0f;
	m[2][0] = 0.0f, m[2][1] = 0.0f, m[2][2] = 1.0f;
}
Matrix3     Matrix3::reverse()const
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

float     Matrix3::det()const
{
	float     _result;
	_result = m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]);
	_result -= m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]);
	_result += m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
	return _result;
}
//右乘三维向量
GLVector3     Matrix3::operator*(const GLVector3 &vec)const
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
	w = 1.0f;
	x = 0.0f;
	y = 0.0f;
	z = 0.0f;
}

Quaternion::Quaternion(const float w,const float x, const float y, const float z)
{
	this->w = w;
	this->x = x;
	this->y = y;
	this->z = z;
}

Quaternion::Quaternion(const float angle, const GLVector3 &vec)
{
//半角
	float        _halfAngle = angle*__MATH_PI__/360.0f;
	float        _sinVector = sinf(_halfAngle);
//单位化旋转向量
	float        _vector_length = sqrtf(vec.x*vec.x+vec.y*vec.y+vec.z*vec.z);
	assert(_vector_length>=__EPS__);

	w = cosf(_halfAngle);
	x = vec.x*_sinVector / _vector_length;
	y = vec.y*_sinVector / _vector_length;
	z = vec.z*_sinVector / _vector_length;
}

Quaternion::Quaternion(const Matrix   &rotate)
{
	float        _lamda = rotate.m[0][0] + rotate.m[1][1] + rotate.m[2][2] + 1.0f;
	assert(_lamda>__EPS__ &&  _lamda<=4.0f);
	w = 0.5f*sqrtf(_lamda );

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

Quaternion		Quaternion::operator*(const Quaternion   &p)const
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
	float         _length = sqrtf(w*w+x*x+y*y+z*z);
	assert(_length>__EPS__);

	w /= _length;
	x /= _length;
	y /= _length;
	z /= _length;
}

void         Quaternion::toRotateMatrix(Matrix &rotateMatrix)const
{
	float          xy = this->x * this->y;
	float          xz = this->x * this->z;
	float          yz = this->y * this->z;
	float         ww = this->w * this->w;

	rotateMatrix.m[0][0] = 1.0f - 2 * (x*x + ww);
	rotateMatrix.m[0][1] = 2.0f * (xy + w*z);
	rotateMatrix.m[0][2] = 2.0f*(xz - w*y);
	rotateMatrix.m[0][3] = 0.0f;

	rotateMatrix.m[1][0] = 2.0f*(xy - w*z);
	rotateMatrix.m[1][1] = 1.0f - 2.0f*(y*y + ww);
	rotateMatrix.m[1][2] = 2.0f*(yz * w*x);
	rotateMatrix.m[1][3] = 0.0f;

	rotateMatrix.m[2][0] = 2.0f*(xz + w*y);
	rotateMatrix.m[2][1] = 2.0f*(yz - w*x);
	rotateMatrix.m[2][2] = 1.0f - 2.0f*(z*z + ww);
	rotateMatrix.m[2][3] = 0.0f;

	rotateMatrix.m[3][0] = 0.0f;
	rotateMatrix.m[3][1] = 0.0f;
	rotateMatrix.m[3][2] = 0.0f;
	rotateMatrix.m[3][3] = 0.0f;
}

Matrix	    Quaternion::toRotateMatrix()
{
	Matrix      _rotate;
	float          xy = this->x * this->y;
	float          xz = this->x * this->z;
	float          yz = this->y * this->z;
	float         ww = this->w * this->w;

	_rotate.m[0][0] = -1.0f + 2.0f * (x*x + ww) ;//==>1.0f - 2.0f *(y*y+z*z)
	_rotate.m[0][1] =2.0f * (xy+ w*z) ;
	_rotate.m[0][2] = 2.0f*(xz - w*y);

	_rotate.m[1][0] = 2.0f*(xy - w*z);
	_rotate.m[1][1] = -1.0f + 2.0f*(y*y+ww);//==>1.0f - 2.0f*(x*x+z*z)
	_rotate.m[1][2] = 2.0f*(yz * w*x);

	_rotate.m[2][0] = 2.0f*(xz + w*y);
	_rotate.m[2][1] = 2.0f*(yz - w*x);
	_rotate.m[2][2] = -1.0f + 2.0f*(z*z+ww) ;//==>1.0f - 2.0f*(x*x+y*y)

	return _rotate;
}

Quaternion       Quaternion::conjugate()
{
	return   Quaternion(w,-x,-y,-z);
}

Quaternion      Quaternion::reverse()const
{
	//float    _length = sqrtf(w*w+x*x+y*y+z*z);
	//assert(_length>=__EPS__);
	return    Quaternion( w,-x,-y,-z   );
}

float   Quaternion::dot(const Quaternion &other)const
{
	return w*other.w + x*other.x + y*other.y + z*other.z;
}
//旋转3维向量
GLVector3 Quaternion::rotate(const GLVector3 &src)const
{
	const GLVector3 sinVec(x,y,z);
	const GLVector3 uv = sinVec.cross(src);
	const GLVector3 uuv = sinVec.cross(uv);

	return src+ uv *(2.0f *w) + uuv * 2.0f;
}

GLVector3 Quaternion::operator*(const GLVector3 &src)const
{
	const GLVector3 sinVec(x, y, z);
	const GLVector3 uv = sinVec.cross(src);
	const GLVector3 uuv = sinVec.cross(uv);

	return src + uv *(2.0f *w) + uuv * 2.0f;
}

//两个插值函数,以后再实现

Quaternion Quaternion::lerp(const Quaternion &p, const Quaternion &q, const float lamda)
{	
	assert(lamda>=0.0f && lamda<=1.0f);
	const float one_minus_t = 1.0f - lamda;
	const float w = one_minus_t * p.w + lamda * q.w;
	const float  x = one_minus_t * p.x + lamda *q.x;
	const float  y = one_minus_t * p.y + lamda * q.y;
	const float  z = one_minus_t * p.z + lamda * q.z;
	const float length = sqrtf(w*w+x*x+y*y+z*z);
	return Quaternion(w/ length,x/ length,y,z/ length);
}

Quaternion  Quaternion::slerp(const Quaternion &p,const Quaternion &q, const float lamda)
{
	assert(lamda>=0.0f && lamda<=1.0f);
	//检测两个四元数之间的夹角
	const float angleOfIntersect = p.dot(q);
	assert(angleOfIntersect>=0.0f);
	//如果夹角接近于0,则使用线性插值
	if (angleOfIntersect >= 1.0f - 0.01f)
		return lerp(p, q, lamda);
	//取连个四元数之间的最短路径
	const float sinValue = sqrtf(1.0f - angleOfIntersect*angleOfIntersect);
	const float angle = asinf(sinValue);

	const float sin_one_minus_t = sinf((1.0f-lamda)*angle);
	const float sin_t = sinf(lamda * angle);
	const float a = sin_one_minus_t / sinValue;
	const float b = sin_t / sinValue;

	const float w = a* p.w + b * q.w;
	const float x = a *p.x + b * q.x;
	const float y = a * p.y + b*q.y;
	const float z = a *p.z + b*q.z;
	const float length =sqrtf( w* w + x*x + y*y + z*z);
	return Quaternion(w/length,x/length,y/length,z/length);
}
__NS_GLK_END