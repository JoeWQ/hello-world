/*
  *几何向量,矩阵数据结构
  *2016-5-21
   */
//Version 5.0 将所有的有关矩阵的操作纳入到矩阵类中,作为矩阵的成员函数实现
//Version 6.0 将切线的计算引入到球体,立方体,地面网格的生成算法中
//Version 7.0 引入了四元数的计算
#ifndef   __GEOMETRY_H__
#define  __GEOMETRY_H__

//2,3,4维向量
struct  GLVector2
{
	float x, y;
	GLVector2(float a, float b)
	{
		x = a, y = b;
	}
	GLVector2(){ x = 0, y = 0; };
	GLVector2     operator*(float);
	GLVector2     operator*(GLVector2 &);
	GLVector2     operator+(GLVector2 &);
	GLVector2     operator-(GLVector2 &);
	GLVector2     operator/(float);
	GLVector2     operator/(GLVector2 &);
	GLVector2     normalize();
	float               dot(GLVector2 &other);
};
struct    Size
{
	float   width, height;
	Size(){ width = 0, height = 0; };
	Size(float  a, float b)
	{
		width = a, height = b;
	}
};
class  Matrix3;
struct  GLVector3
{
	float    x, y, z;
	GLVector3(float a, float b, float c)
	{
		x = a, y = b, z = c;
	}
	GLVector3(){ x = 0, y = 0, z = 0; };
	GLVector3   operator*(Matrix3 &);
	GLVector3   operator*(GLVector3 &);
	GLVector3   operator*(float);
	GLVector3   operator-(GLVector3 &);
	GLVector3   operator+(GLVector3 &);
	GLVector3   operator/(float);
	GLVector3   operator/(GLVector3 &);
	GLVector3   normalize();
	GLVector3   cross(GLVector3 &);
	float              dot(GLVector3 &other);
};
class  Matrix;
struct GLVector4
{
	float   x, y, z, w;
	GLVector4(float a, float b, float c, float d)
	{
		x = a, y = b;
		z = c, w = d;
	}
	GLVector4(){ x = 0, y = 0, z = 0, w = 0; };
	GLVector4   operator*(Matrix &);
	GLVector4   normalize();
	float              dot(GLVector4 &other);
};
//三阶矩阵,因为使用的地方非常少,所以作者就没有实现完所有有关三阶矩阵的操作
class     Matrix3
{
private:
	float   m[3][3];
public:
	friend    class   Matrix;
	friend    struct GLVector3;
	Matrix3();
	Matrix3(const Matrix3 &src);
	inline     float    *pointer(){ return  (float*)m; };
	//求逆矩阵
	Matrix3         reverse();
//行列式
	float               det();
//右乘三维列向量
	GLVector3   operator*(GLVector3 &);
	Matrix3&     operator=(Matrix3 &);
};
//四维矩阵,全新的实现
 class Matrix
{
private:
   float   m[4][4];
public:
	friend   struct    GLVector4;
	friend   class      Quaternion;
   Matrix();
//返回指向矩阵内容的指针,浮点型指针
   inline    float     *pointer(){   return (float*)m ; };
//加载单位矩阵
   void      identity();
//矩阵之间的快速复制
   void     copy(Matrix   &);
//缩放
   void     scale(float scaleX,float scaleY,float  scaleZ);
//平移float 
   void    translate(float deltaX,float  deltaY,float deltaZ);
//旋转
   void    rotate(float  angle,float x,float y,float z);
//右乘视图矩阵
   void    lookAt(GLVector3  &eyePosition,GLVector3  &targetPosition,GLVector3  &upVector);
//右乘正交投影矩阵
   void    orthoProject(float  left,float right,float  bottom,float  top,float  nearZ,float  farZ);
//透视投影矩阵
   void    perspective(float fovy, float aspect, float nearZ, float farZ);
//一般投影矩阵
   void    frustum(float left, float right, float bottom, float top, float nearZ, float farZ);
//矩阵乘法,self=self*srcA
   void    multiply(Matrix   &srcA);
//self=srcA*srcB
   void    multiply(Matrix   &srcA,Matrix   &rscB);
//偏置矩阵
   void   offset();
//从现有的矩阵中推导出法线矩阵
   Matrix3     normalMatrix();
//截断为3维矩阵
   Matrix3       trunk();
//求逆矩阵
   Matrix             reverse();
//行列式
   float                 det();
//重载 乘法运算符
   Matrix    operator*(Matrix   &);
//矩阵与向量乘法
   GLVector4  operator*(GLVector4  &);
//矩阵之间的复制
   Matrix&    operator=(Matrix  &);
} ;

 //四元数
 /*
   *四元数的实现
   *可以与角度+向量,旋转矩阵相互转换
   */
 class        Quaternion
 {
	 friend   class   Matrix;
 public:
	 float        w;
	 float        x;
	 float        y;
	 float        z;
 public:
	 Quaternion(float w,float x,float y,float z);
//使用角度+向量初始化四元数
//	 Quaternion(float    angle,float      x,float  y,float   z);
	 Quaternion(float    angle,GLVector3  &);
//使用旋转矩阵初始化向量,注意此必须为旋转矩阵,否则会崩溃
	 Quaternion(Matrix      &);
	 Quaternion();
//加载单位四元数
	 void                   identity();
//四元数乘法
	 void                    multiply(Quaternion   &);
//单位化
	 void                    normalize();
//求逆
	 Quaternion        reverse();
//求共轭四元数
	 Quaternion		conjugate();
//导出到旋转矩阵
	 Matrix               toRotateMatrix();
//乘法运算符重载
	 Quaternion		operator*(Quaternion	&);
//在两个四元数之间进行线性插值
	 static    Quaternion	   lerp(Quaternion  &p,Quaternion	&q,float      lamda);
//在两个四元数之间进行球面线性插值
	 static    Quaternion     slerp(Quaternion	&p,Quaternion		&q,float     lamda);
 };
//
int  esGenSphere ( int numSlices, float radius, float **vertices, float **normals,float  **tangents,
	float **texCoords, int **indices, int  *numberOfVertex);

/// \return The number of indices required for rendering the buffers (the number of indices stored in the indices array
///         if it is not NULL ) as a GL_TRIANGLES
//numberOfVertex:顶点数目,position 3分量,normals三分量,indices
int  esGenCube ( float scale, float **vertices, float **normals,float **tangents,
                           float **texCoords,int *numberOfVertex);

/// \return The number of indices required for rendering the buffers (the number of indices stored in the indices array
///         if it is not NULL ) as a GL_TRIANGLES
//
int  esGenSquareGrid(int size,float scale, float **vertices, int **indices,int *numberOfVertex);

//向量的叉乘 result=a x b
GLVector3        cross(GLVector3  *a,GLVector3  *b);

//向量的点乘
float                   dot(GLVector3  *srcA,GLVector3  *srcB);

//向量标准化
GLVector3                  normalize(GLVector3   *src);
GLVector2                  normalize(GLVector2   *src);

#endif
