/*
  *几何向量,矩阵数据结构
  *2016-5-21
   */
//Version 5.0 将所有的有关矩阵的操作纳入到矩阵类中,作为矩阵的成员函数实现
//Version 6.0 将切线的计算引入到球体,立方体,地面网格的生成算法中
//Version 7.0 引入了四元数的计算
//Version 8.0 为支持欧拉角而添加的矩阵旋转函数
//Version 9.0 全面支持关于四元数的运算
//Version 10.0 删除了历史遗留的类,并将四元数的实现置于一个单独的文件中
//Version 11.0  引入了平面方程/包围盒类,此两个类是支持模型/场景可视性判断的基础
#ifndef   __GEOMETRY_H__
#define  __GEOMETRY_H__
#include<engine/GLState.h>
__NS_GLK_BEGIN
	//2,3,4维向量
	struct  GLVector2
	{
		float x, y;
		GLVector2(float a, float b)
		{
			x = a, y = b;
		}
		GLVector2() { x = 0, y = 0; };
		GLVector2     operator*(float)const;
		GLVector2     operator*(const GLVector2 &)const;
		GLVector2     operator+(const GLVector2 &)const;
		GLVector2     operator-(const GLVector2 &)const;
		GLVector2     operator/(float)const;
		GLVector2     operator/(const GLVector2 &)const;
		GLVector2&  operator=(const GLVector2 &src);
		GLVector2     normalize()const;
		const float     length()const;
		float               dot(const GLVector2 &other)const;
	};
	struct    Size
	{
		float   width, height;
		Size() { width = 0, height = 0; };
		Size(float  a, float b)
		{
			width = a, height = b;
		}
	};
	class  Matrix3;
	struct  GLVector4;
	struct  GLVector3
	{
		float    x, y, z;
		GLVector3(float a, float b, float c)
		{
			x = a, y = b, z = c;
		}
		GLVector3(const float xyz)
		{
			x = y = z = xyz;
		}
		GLVector3() { x = 0, y = 0, z = 0; };
		GLVector4  xyzw0()const;
		GLVector4  xyzw1()const;
		GLVector3   operator*(const Matrix3 &)const;
		GLVector3   operator*(const GLVector3 &)const;
		GLVector3   operator*(const float)const;
		GLVector3   operator-(const GLVector3 &)const;
		GLVector3   operator+(const GLVector3 &)const;
		GLVector3   operator/(const float)const;
		GLVector3   operator/(const GLVector3 &)const;
		GLVector3   normalize()const;
		GLVector3   cross(const GLVector3 &)const;
		GLVector3   min(const GLVector3 &)const;
		GLVector3   max(const GLVector3 &)const;
		float              dot(const GLVector3 &other)const;
		const float    length()const;
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
		GLVector4(const float xyzw)
		{
			x = y = z = xyzw;
		}
		GLVector4() { x = 0, y = 0, z = 0, w = 0; };
		GLVector3    xyz() const{ return GLVector3(x, y, z); };
		GLVector4   operator*(const Matrix &)const;
		GLVector4   operator*(const float )const;
		GLVector4   operator*(const GLVector4 &)const;
		GLVector4   operator-(const GLVector4 &)const;
		GLVector4   operator+(const GLVector4 &)const;
		GLVector4   operator/(const float )const;
		GLVector4   operator/(const GLVector4 &)const;
		GLVector4   min(const GLVector4 &)const;
		GLVector4   max(const GLVector4 &)const;
		GLVector4   normalize()const;
		float              dot(const GLVector4 &other)const;
	};
	//平面方程式,形式为 A*x+B*y+C*z-d=0
	class Plane
	{
		//平面法向量(单位化之后的)
		GLVector3    _normal;
		//(0,0,0)点所在的平面(平面法向量为_normal)与该平面之间的有向距离
		float              _distance;
	public:
		Plane();
		//A*x+B*y+C*z-d=0
		Plane(const GLVector3 &normal,const float distance);
		void   init(const GLVector3 &normal,const float distance);
		//获取平面方程的法向量
		const GLVector3 &getNormal()const;
		//获取有向距离
		float   getDistance()const;
		//最重要的函数,计算给定的3d坐标点,离平面的有向距离
		float   distance(const GLVector3 &p3d)const;
	};
	//空间包围盒
	class     AABB
	{
	public:
		//包围盒的最大,最小点
		GLVector3    _minBox;
		GLVector3    _maxBox;
	public:
		//由给定的8个3d坐标点计算包围盒
		AABB(const GLVector3 *);
		//由给定的8个3d齐次坐标点计算包围盒
		AABB(const GLVector4 *);
		//
		AABB();
		AABB(const GLVector3 &minBox,const GLVector3 &maxBox);
		//
		AABB(const GLVector4 &minBox,const GLVector4 &maxBox);
		void   init(const GLVector3 *);
		void   init(const GLVector4 *);
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
		inline     const float    *pointer() const { return  (float*)m; };
		//求逆矩阵
		Matrix3         reverse()const;
		//行列式
		float               det()const;
		//右乘三维列向量
		GLVector3   operator*(const GLVector3 &)const;
		Matrix3&     operator=(Matrix3 &);
	};

	class Quaternion;
	class Frustum;
	//四维矩阵,全新的实现
	class Matrix
	{
	private:
		float   m[4][4];
	public:
		friend   struct    GLVector4;
		friend   class      Quaternion;
		friend   class      Frustum;
		Matrix();
		//返回指向矩阵内容的指针,浮点型指针
		inline    const float     *pointer() const { return (float*)m; };
		//加载单位矩阵
		void      identity();
		//矩阵之间的快速复制
		void     copy(const Matrix   &);
		//缩放
		void     scale(const float scaleX, const float scaleY, const float  scaleZ);
		//平移float 
		void    translate(const float deltaX, const float  deltaY,const float deltaZ);
		//平移deltaXYZ向量
		void    translate(const GLVector3 &deltaXYZ);
		//旋转
		void    rotate(float  angle, float x, float y, float z);
		//绕X轴旋转
		void    rotateX(float pitch);
		//绕Y轴旋转
		void    rotateY(float yaw);
		//绕Z轴旋转
		void    rotateZ(float roll);
		//右乘视图矩阵
		void    lookAt(const GLVector3  &eyePosition, const GLVector3  &targetPosition, const GLVector3  &upVector);
		//右乘正交投影矩阵
		void    orthoProject(float  left, float right, float  bottom, float  top, float  nearZ, float  farZ);
		//透视投影矩阵
		void    perspective(float fovy, float aspect, float nearZ, float farZ);
		//一般投影矩阵
		void    frustum(float left, float right, float bottom, float top, float nearZ, float farZ);
		//矩阵乘法,this=this*srcA
		void    multiply(const Matrix   &srcA);
		//this=srcA*srcB
		void    multiply(Matrix   &srcA, Matrix   &rscB);
		//偏置矩阵,此矩阵是专门为阴影计算提供直接的支持,通常使用光源矩阵之后,需要乘以缩放,偏移矩阵,调用此函数
		//相当于两个矩阵乘法一起进行,并且没有矩阵数据的复制,因此更直接,且计算速度更快
		void   offset();
		//从现有的矩阵中推导出法线矩阵
		Matrix3     normalMatrix()const;
		//截断为3维矩阵
		Matrix3       trunk()const;
		//求逆矩阵
		Matrix             reverse()const;
		//行列式
		float                 det()const;
		//重载 乘法运算符
		Matrix    operator*(const Matrix   &)const;
		//矩阵与向量乘法
		GLVector4  operator*(const GLVector4  &)const;
		//矩阵之间的复制
		Matrix&    operator=(const Matrix  &);
	};
	//球面方程式实现
	int  esGenSphere(int numSlices, float radius, float **vertices, float **normals, float  **tangents,
		float **texCoords, int **indices, int  *numberOfVertex);

	//numberOfVertex:顶点数目,position 3分量,normals三分量,indices
	int  esGenCube(float scale, float **vertices, float **normals, float **tangents,
		float **texCoords, int *numberOfVertex);

	//平面网格生成算法,目前该算法的实现已经在Shape.cpp里面另有实现
	int  esGenSquareGrid(int size, float scale, float **vertices, int **indices, int *numberOfVertex);

	////////////////////////////////////////////////////////////行列式//////////////////////////////
	//四个数字构成的二维矩阵的行列式
	float     detFloat(float  x1, float y1, float x2, float y2);
	//或者两个二维行向量
	float     detVector2(GLVector2  *a, GLVector2  *b);
	float     detVector3(GLVector3   *a, GLVector3   *b, GLVector3   *c);
	//////////////////////////////////////////////////////////////////////////////
__NS_GLK_END
#endif
