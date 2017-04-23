/*
  *��������,�������ݽṹ
  *2016-5-21
   */
//Version 5.0 �����е��йؾ���Ĳ������뵽��������,��Ϊ����ĳ�Ա����ʵ��
//Version 6.0 �����ߵļ������뵽����,������,��������������㷨��
//Version 7.0 ��������Ԫ���ļ���
//Version8.0 Ϊ֧��ŷ���Ƕ���ӵľ�����ת����
#ifndef   __GEOMETRY_H__
#define  __GEOMETRY_H__
#include<engine/GLState.h>
__NS_GLK_BEGIN
	//2,3,4ά����
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
	//���׾���,��Ϊʹ�õĵط��ǳ���,�������߾�û��ʵ���������й����׾���Ĳ���
	class     Matrix3
	{
	private:
		float   m[3][3];
	public:
		friend    class   Matrix;
		friend    struct GLVector3;
		Matrix3();
		inline     const float    *pointer() const { return  (float*)m; };
		//�������
		Matrix3         reverse();
		//����ʽ
		float               det();
		//�ҳ���ά������
		GLVector3   operator*(GLVector3 &);
		Matrix3&     operator=(Matrix3 &);
	};
	//��ά����,ȫ�µ�ʵ��
	class Matrix
	{
	private:
		float   m[4][4];
	public:
		friend   struct    GLVector4;
		friend   class      Quaternion;
		Matrix();
		//����ָ��������ݵ�ָ��,������ָ��
		inline    const float     *pointer() const { return (float*)m; };
		//���ص�λ����
		void      identity();
		//����֮��Ŀ��ٸ���
		void     copy(Matrix   &);
		//����
		void     scale(const float scaleX, const float scaleY, const float  scaleZ);
		//ƽ��float 
		void    translate(const float deltaX, const float  deltaY,const float deltaZ);
		//��ת
		void    rotate(float  angle, float x, float y, float z);
		//��X����ת
		void    rotateX(float pitch);
		//��Y����ת
		void    rotateY(float yaw);
		//��Z����ת
		void    rotateZ(float roll);
		//�ҳ���ͼ����
		void    lookAt(const GLVector3  &eyePosition, const GLVector3  &targetPosition, const GLVector3  &upVector);
		//�ҳ�����ͶӰ����
		void    orthoProject(float  left, float right, float  bottom, float  top, float  nearZ, float  farZ);
		//͸��ͶӰ����
		void    perspective(float fovy, float aspect, float nearZ, float farZ);
		//һ��ͶӰ����
		void    frustum(float left, float right, float bottom, float top, float nearZ, float farZ);
		//����˷�,self=self*srcA
		void    multiply(Matrix   &srcA);
		//self=srcA*srcB
		void    multiply(Matrix   &srcA, Matrix   &rscB);
		//ƫ�þ���
		void   offset();
		//�����еľ������Ƶ������߾���
		Matrix3     normalMatrix();
		//�ض�Ϊ3ά����
		Matrix3       trunk();
		//�������
		Matrix             reverse();
		//����ʽ
		float                 det();
		//���� �˷������
		Matrix    operator*(const Matrix   &);
		//�����������˷�
		GLVector4  operator*(const GLVector4  &)const;
		//����֮��ĸ���
		Matrix&    operator=(const Matrix  &);
	};

	//��ά����
	struct   ESMatrix3
	{
		float    mat3[3][3];
		ESMatrix3(GLVector3  *vec1, GLVector3  *vec2, GLVector3  *vec3)//�������������г�ʼ����������������
		{
			mat3[0][0] = vec1->x, mat3[0][1] = vec1->y, mat3[0][2] = vec1->z;
			mat3[1][0] = vec2->x, mat3[1][1] = vec2->y, mat3[1][2] = vec2->z;
			mat3[2][0] = vec3->x, mat3[2][1] = vec3->y, mat3[2][2] = vec3->z;
		}
		ESMatrix3() {};
	};
	//��Ԫ��
	/*
	  *��Ԫ����ʵ��
	  *������Ƕ�+����,��ת�����໥ת��
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
		//ʹ�ýǶ�+������ʼ����Ԫ��
		//	 Quaternion(float    angle,float      x,float  y,float   z);
		Quaternion(float    angle, GLVector3  &);
		//ʹ����ת�����ʼ������,ע��˱���Ϊ��ת����,��������
		Quaternion(Matrix      &);
		Quaternion();
		//���ص�λ��Ԫ��
		void                   identity();
		//��Ԫ���˷�
		void                    multiply(Quaternion   &);
		//��λ��
		void                    normalize();
		//����
		Quaternion        reverse();
		//������Ԫ��
		Quaternion		conjugate();
		//��������ת����
		Matrix               toRotateMatrix();
		//�˷����������
		Quaternion		operator*(Quaternion	&);
		//��������Ԫ��֮��������Բ�ֵ
		static    Quaternion	   lerp(Quaternion  &p, Quaternion	&q, float      lamda);
		//��������Ԫ��֮������������Բ�ֵ
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
	//numberOfVertex:������Ŀ,position 3����,normals������,indices
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

	//result�ҳ�ƫ�þ���,������Ӱ������
	void  esMatrixOffset(ESMatrix    *result);

	//����ƫ�þ���
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

	//�����Ĳ�� result=a x b
	GLVector3        cross(GLVector3  *a, GLVector3  *b);

	//�����ĵ��
	float                   dot(GLVector3  *srcA, GLVector3  *srcB);

	//������׼��
	GLVector3                  normalize(GLVector3   *src);
	GLVector2                  normalize(GLVector2   *src);
	///////////////////////Ϊ�˼�����ǰ�ĳ���,����Ĵ�����ʱ��ɾ��////////////////////////////
	/////////////////////////////////ֻ���ڴ�ģ�;�������ȡ���߾���////////////////////////////////////////////
	//����Զ���ı任�������Ƶ������߾���,�Ƽ���ʽ,��Ϊ�������������,���ҿɿ��Ը�ǿ
	void      esMatrixNormal(ESMatrix3  *result, ESMatrix   *src);
	//4ά����ض�Ϊ3ά
	void      esMatrixTrunk(ESMatrix3  *dst, ESMatrix *src);

	//�������
	//result:��Ҫд���Ŀ�����
	//x,y,z:��ʾĿ��ƽ��ķ�����,��ƽ�澭��ԭ��
	void      esMatrixMirror(ESMatrix  *result, float  x, float y, float z);
	////////////////////////////////////////////////////////////����ʽ//////////////////////////////
	//�ĸ����ֹ��ɵĶ�ά���������ʽ
	float     detFloat(float  x1, float y1, float x2, float y2);
	//����������ά������
	float     detVector2(GLVector2  *a, GLVector2  *b);
	//���׾��������ʽ
	float     detMatrix3(ESMatrix3    *mat3);
	float     detVector3(GLVector3   *a, GLVector3   *b, GLVector3   *c);
	float     detMatrix(ESMatrix    *src);//��ά���������ʽ
	//////////////////////////////////////////////////////////////////////////////
	//��ά����������
	void      esMatrixReverse(ESMatrix3  *result, ESMatrix3    *src);

	//��ά�������
	void      esMatrixReverse(ESMatrix    *result, ESMatrix    *src);

	//////////////////////////////////����ת��////////////////////////////////////
	void      esMatrixTranspose(ESMatrix    *result, ESMatrix    *src);
	void      esMatrixTranspose(ESMatrix3    *result, ESMatrix3    *src);

	//���׾���˷�
	void      esMatrixMultiply3(ESMatrix3   *result, ESMatrix3   *srcA, ESMatrix3  *srcB);

	//////////////////////////����������֮��ĳ˷�////////////////////
	GLVector4      esMatrixMultiplyVector4(ESMatrix   *, GLVector4   *);//�ҳ�
	GLVector4      esMatrixMultiplyVector4(GLVector4 *, ESMatrix    *);//���

	GLVector3      esMatrixMultiplyVector3(ESMatrix3   *, GLVector3   *);
	GLVector3      esMatrixMultiplyVector3(GLVector3  *, ESMatrix3   *);


__NS_GLK_END
#endif
