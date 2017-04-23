/*
  *几何向量,矩阵数据结构
  *2016-5-21
   */
//Version 5.0 将所有的有关矩阵的操作纳入到矩阵类中,作为矩阵的成员函数实现
//Version 6.0 将切线的计算引入到球体,立方体,地面网格的生成算法中
//Version 7.0 引入了四元数的计算
//Version8.0 为支持欧拉角而添加的矩阵旋转函数
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
		GLVector2     operator*(GLVector2 &)const;
		GLVector2     operator+(GLVector2 &)const;
		GLVector2     operator-(GLVector2 &)const;
		GLVector2     operator/(float)const;
		GLVector2     operator/(GLVector2 &)const;
		GLVector2&  operator=(const GLVector2 &src);
		GLVector2     normalize()const;
		const float     length()const;
		float               dot(GLVector2 &other)const;
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
		GLVector4  xyzw()const;
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
		GLVector4   operator*(Matrix &)const;
		GLVector4   operator*(const float )const;
		GLVector4   operator*(const GLVector4 &)const;
		GLVector4   operator-(const GLVector4 &)const;
		GLVector4   operator+(const GLVector4 &)const;
		GLVector4   operator/(const float )const;
		GLVector4   operator/(const GLVector4 &)const;
		GLVector4   min(const GLVector4 &)const;
		GLVector4   max(const GLVector4 &)const;
		GLVector4   normalize()const;
		float              dot(GLVector4 &other)const;
	};
	struct   ESMatrix
	{
		float     m[4][4];
		ESMatrix();
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
		inline    const float     *pointer() const { return (float*)m; };
		//加载单位矩阵
		void      identity();
		//矩阵之间的快速复制
		void     copy(Matrix   &);
		//缩放
		void     scale(const float scaleX, const float scaleY, const float  scaleZ);
		//平移float 
		void    translate(const float deltaX, const float  deltaY,const float deltaZ);
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
		//矩阵乘法,self=self*srcA
		void    multiply(Matrix   &srcA);
		//self=srcA*srcB
		void    multiply(Matrix   &srcA, Matrix   &rscB);
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
		Matrix    operator*(const Matrix   &);
		//矩阵与向量乘法
		GLVector4  operator*(const GLVector4  &)const;
		//矩阵之间的复制
		Matrix&    operator=(const Matrix  &);
	};

	//三维矩阵
	struct   ESMatrix3
	{
		float    mat3[3][3];
		ESMatrix3(GLVector3  *vec1, GLVector3  *vec2, GLVector3  *vec3)//用三个向量进行初始化三个矩阵行向量
		{
			mat3[0][0] = vec1->x, mat3[0][1] = vec1->y, mat3[0][2] = vec1->z;
			mat3[1][0] = vec2->x, mat3[1][1] = vec2->y, mat3[1][2] = vec2->z;
			mat3[2][0] = vec3->x, mat3[2][1] = vec3->y, mat3[2][2] = vec3->z;
		}
		ESMatrix3() {};
	};
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
		Quaternion(float w, float x, float y, float z);
		//使用角度+向量初始化四元数
		//	 Quaternion(float    angle,float      x,float  y,float   z);
		Quaternion(float    angle, GLVector3  &);
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
		static    Quaternion	   lerp(Quaternion  &p, Quaternion	&q, float      lamda);
		//在两个四元数之间进行球面线性插值
		static    Quaternion     slerp(Quaternion	&p, Quaternion		&q, float     lamda);
	};
	//
	int  esGenSphere(int numSlices, float radius, float **vertices, float **normals, float  **tangents,
		float **texCoords, int **indices, int  *numberOfVertex);

	//
	/// \brief Generates geometry for a cube.  Allocates memory for the vertex data and stores
	///        the results in the arrays.  Generate index list for a TRIANGLES
	/// \param scale The size of the cube, use 1.0 for a unit cube.
	/// \param vertices If not NULL, will contain array of float3 positions
	/// \param normals If not NULL, will contain array of float3 normals
	/// \param texCoords If not NULL, will contain array of float2 texCoords
	/// \param indices If not NULL, will contain the array of indices for the triangle strip
	/// \return The number of indices required for rendering the buffers (the number of indices stored in the indices array
	///         if it is not NULL ) as a GL_TRIANGLES
	//numberOfVertex:顶点数目,position 3分量,normals三分量,indices
	int  esGenCube(float scale, float **vertices, float **normals, float **tangents,
		float **texCoords, int *numberOfVertex);

	//
	/// \brief Generates a square grid consisting of triangles.  Allocates memory for the vertex data and stores
	///        the results in the arrays.  Generate index list as TRIANGLES.
	/// \param size create a grid of size by size (number of triangles = (size-1)*(size-1)*2)
	/// \param vertices If not NULL, will contain array of float3 positions
	/// \param indices If not NULL, will contain the array of indices for the triangle strip
	/// \return The number of indices required for rendering the buffers (the number of indices stored in the indices array
	///         if it is not NULL ) as a GL_TRIANGLES
	//
	int  esGenSquareGrid(int size, float scale, float **vertices, int **indices, int *numberOfVertex);

	//
	/// \brief Loads a 8-bit, 24-bit or 32-bit TGA image from a file
	/// \param ioContext Context related to IO facility on the platform
	/// \param fileName Name of the file on disk
	/// \param width Width of loaded image in pixels
	/// \param height Height of loaded image in pixels
	///  \return Pointer to loaded image.  NULL on failure.
	//

	//
	/// \brief multiply matrix specified by result with a scaling matrix and return new matrix in result
	/// \param result Specifies the input matrix.  Scaled matrix is returned in result.
	/// \param sx, sy, sz Scale factors along the x, y and z axes respectively
	//
	void  esScale(ESMatrix *result, float sx, float sy, float sz);

	//
	/// \brief multiply matrix specified by result with a translation matrix and return new matrix in result
	/// \param result Specifies the input matrix.  Translated matrix is returned in result.
	/// \param tx, ty, tz Scale factors along the x, y and z axes respectively
	//
	void  esTranslate(ESMatrix *result, float tx, float ty, float tz);

	//
	/// \brief multiply matrix specified by result with a rotation matrix and return new matrix in result
	/// \param result Specifies the input matrix.  Rotated matrix is returned in result.
	/// \param angle Specifies the angle of rotation, in degrees.
	/// \param x, y, z Specify the x, y and z coordinates of a vector, respectively
	//
	void  esRotate(ESMatrix *result, float angle, float x, float y, float z);

	//
	// \brief multiply matrix specified by result with a perspective matrix and return new matrix in result
	/// \param result Specifies the input matrix.  new matrix is returned in result.
	/// \param left, right Coordinates for the left and right vertical clipping planes
	/// \param bottom, top Coordinates for the bottom and top horizontal clipping planes
	/// \param nearZ, farZ Distances to the near and far depth clipping planes.  Both distances must be positive.
	//
	void  esFrustum(ESMatrix *result, float left, float right, float bottom, float top, float nearZ, float farZ);

	//
	/// \brief multiply matrix specified by result with a perspective matrix and return new matrix in result
	/// \param result Specifies the input matrix.  new matrix is returned in result.
	/// \param fovy Field of view y angle in degrees
	/// \param aspect Aspect ratio of screen
	/// \param nearZ Near plane distance
	/// \param farZ Far plane distance
	//
	void  esPerspective(ESMatrix *result, float fovy, float aspect, float nearZ, float farZ);

	//
	/// \brief multiply matrix specified by result with a perspective matrix and return new matrix in result
	/// \param result Specifies the input matrix.  new matrix is returned in result.
	/// \param left, right Coordinates for the left and right vertical clipping planes
	/// \param bottom, top Coordinates for the bottom and top horizontal clipping planes
	/// \param nearZ, farZ Distances to the near and far depth clipping planes.  These values are negative if plane is behind the viewer
	//
	void  esOrtho(ESMatrix *result, float left, float right, float bottom, float top, float nearZ, float farZ);

	//
	/// \brief perform the following operation - result matrix = srcA matrix * srcB matrix
	/// \param result Returns multiplied matrix
	/// \param srcA, srcB Input matrices to be multiplied
	//
	void  esMatrixMultiply(ESMatrix *result, ESMatrix *srcA, ESMatrix *srcB);

	//
	//// \brief return an indentity matrix
	//// \param result returns identity matrix
	//
	void  esMatrixLoadIdentity(ESMatrix *result);

	//result右乘偏置矩阵,用于阴影计算中
	void  esMatrixOffset(ESMatrix    *result);

	//生成偏置矩阵
	void  esMatrixLoadOffset(ESMatrix  *result);

	//
	/// \brief Generate a transformation matrix from eye position, look at and up vectors
	/// \param result Returns transformation matrix
	/// \param posX, posY, posZ           eye position
	/// \param lookAtX, lookAtY, lookAtZ  look at vector
	/// \param upX, upY, upZ              up vector
	//
	void
		esMatrixLookAt(ESMatrix *result,
			GLVector3   *eyePosition,
			GLVector3   *viewPosition,
			GLVector3   *up);

	void esMatrixLookAt(ESMatrix *result, float posX, float posY, float posZ,
		float lookAtX, float lookAtY, float lookAtZ,
		float upX, float upY, float upZ);

	//向量的叉乘 result=a x b
	GLVector3        cross(GLVector3  *a, GLVector3  *b);

	//向量的点乘
	float                   dot(GLVector3  *srcA, GLVector3  *srcB);

	//向量标准化
	GLVector3                  normalize(GLVector3   *src);
	GLVector2                  normalize(GLVector2   *src);
	///////////////////////为了兼容以前的程序,下面的代码暂时不删除////////////////////////////
	/////////////////////////////////只用于从模型矩阵中求取法线矩阵////////////////////////////////////////////
	//从针对顶点的变换矩阵中推导出法线矩阵,推荐方式,因为这个函数更正规,并且可靠性更强
	void      esMatrixNormal(ESMatrix3  *result, ESMatrix   *src);
	//4维矩阵截断为3维
	void      esMatrixTrunk(ESMatrix3  *dst, ESMatrix *src);

	//镜像矩阵
	//result:将要写入的目标矩阵
	//x,y,z:表示目标平面的法向量,该平面经过原点
	void      esMatrixMirror(ESMatrix  *result, float  x, float y, float z);
	////////////////////////////////////////////////////////////行列式//////////////////////////////
	//四个数字构成的二维矩阵的行列式
	float     detFloat(float  x1, float y1, float x2, float y2);
	//或者两个二维行向量
	float     detVector2(GLVector2  *a, GLVector2  *b);
	//三阶矩阵的行列式
	float     detMatrix3(ESMatrix3    *mat3);
	float     detVector3(GLVector3   *a, GLVector3   *b, GLVector3   *c);
	float     detMatrix(ESMatrix    *src);//四维矩阵的行列式
	//////////////////////////////////////////////////////////////////////////////
	//三维矩阵的逆矩阵
	void      esMatrixReverse(ESMatrix3  *result, ESMatrix3    *src);

	//四维矩阵的逆
	void      esMatrixReverse(ESMatrix    *result, ESMatrix    *src);

	//////////////////////////////////矩阵转置////////////////////////////////////
	void      esMatrixTranspose(ESMatrix    *result, ESMatrix    *src);
	void      esMatrixTranspose(ESMatrix3    *result, ESMatrix3    *src);

	//三阶矩阵乘法
	void      esMatrixMultiply3(ESMatrix3   *result, ESMatrix3   *srcA, ESMatrix3  *srcB);

	//////////////////////////矩阵与向量之间的乘法////////////////////
	GLVector4      esMatrixMultiplyVector4(ESMatrix   *, GLVector4   *);//右乘
	GLVector4      esMatrixMultiplyVector4(GLVector4 *, ESMatrix    *);//左乘

	GLVector3      esMatrixMultiplyVector3(ESMatrix3   *, GLVector3   *);
	GLVector3      esMatrixMultiplyVector3(GLVector3  *, ESMatrix3   *);


__NS_GLK_END
#endif
