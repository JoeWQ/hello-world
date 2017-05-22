/*
  *��������,�������ݽṹ
  *2016-5-21
   */
//Version 5.0 �����е��йؾ���Ĳ������뵽��������,��Ϊ����ĳ�Ա����ʵ��
//Version 6.0 �����ߵļ������뵽����,������,��������������㷨��
//Version 7.0 ��������Ԫ���ļ���
//Version 8.0 Ϊ֧��ŷ���Ƕ���ӵľ�����ת����
//Version 9.0 ȫ��֧�ֹ�����Ԫ��������
//Version 10.0 ɾ������ʷ��������,������Ԫ����ʵ������һ���������ļ���
//Version 11.0  ������ƽ�淽��/��Χ����,����������֧��ģ��/�����������жϵĻ���
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
	//ƽ�淽��ʽ,��ʽΪ A*x+B*y+C*z-d=0
	class Plane
	{
		//ƽ�淨����(��λ��֮���)
		GLVector3    _normal;
		//(0,0,0)�����ڵ�ƽ��(ƽ�淨����Ϊ_normal)���ƽ��֮����������
		float              _distance;
	public:
		Plane();
		//A*x+B*y+C*z-d=0
		Plane(const GLVector3 &normal,const float distance);
		void   init(const GLVector3 &normal,const float distance);
		//��ȡƽ�淽�̵ķ�����
		const GLVector3 &getNormal()const;
		//��ȡ�������
		float   getDistance()const;
		//����Ҫ�ĺ���,���������3d�����,��ƽ����������
		float   distance(const GLVector3 &p3d)const;
	};
	//�ռ��Χ��
	class     AABB
	{
	public:
		//��Χ�е����,��С��
		GLVector3    _minBox;
		GLVector3    _maxBox;
	public:
		//�ɸ�����8��3d���������Χ��
		AABB(const GLVector3 *);
		//�ɸ�����8��3d������������Χ��
		AABB(const GLVector4 *);
		//
		AABB();
		AABB(const GLVector3 &minBox,const GLVector3 &maxBox);
		//
		AABB(const GLVector4 &minBox,const GLVector4 &maxBox);
		void   init(const GLVector3 *);
		void   init(const GLVector4 *);
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
		Matrix3         reverse()const;
		//����ʽ
		float               det()const;
		//�ҳ���ά������
		GLVector3   operator*(const GLVector3 &)const;
		Matrix3&     operator=(Matrix3 &);
	};

	class Quaternion;
	class Frustum;
	//��ά����,ȫ�µ�ʵ��
	class Matrix
	{
	private:
		float   m[4][4];
	public:
		friend   struct    GLVector4;
		friend   class      Quaternion;
		friend   class      Frustum;
		Matrix();
		//����ָ��������ݵ�ָ��,������ָ��
		inline    const float     *pointer() const { return (float*)m; };
		//���ص�λ����
		void      identity();
		//����֮��Ŀ��ٸ���
		void     copy(const Matrix   &);
		//����
		void     scale(const float scaleX, const float scaleY, const float  scaleZ);
		//ƽ��float 
		void    translate(const float deltaX, const float  deltaY,const float deltaZ);
		//ƽ��deltaXYZ����
		void    translate(const GLVector3 &deltaXYZ);
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
		//����˷�,this=this*srcA
		void    multiply(const Matrix   &srcA);
		//this=srcA*srcB
		void    multiply(Matrix   &srcA, Matrix   &rscB);
		//ƫ�þ���,�˾�����ר��Ϊ��Ӱ�����ṩֱ�ӵ�֧��,ͨ��ʹ�ù�Դ����֮��,��Ҫ��������,ƫ�ƾ���,���ô˺���
		//�൱����������˷�һ�����,����û�о������ݵĸ���,��˸�ֱ��,�Ҽ����ٶȸ���
		void   offset();
		//�����еľ������Ƶ������߾���
		Matrix3     normalMatrix()const;
		//�ض�Ϊ3ά����
		Matrix3       trunk()const;
		//�������
		Matrix             reverse()const;
		//����ʽ
		float                 det()const;
		//���� �˷������
		Matrix    operator*(const Matrix   &)const;
		//�����������˷�
		GLVector4  operator*(const GLVector4  &)const;
		//����֮��ĸ���
		Matrix&    operator=(const Matrix  &);
	};
	//���淽��ʽʵ��
	int  esGenSphere(int numSlices, float radius, float **vertices, float **normals, float  **tangents,
		float **texCoords, int **indices, int  *numberOfVertex);

	//numberOfVertex:������Ŀ,position 3����,normals������,indices
	int  esGenCube(float scale, float **vertices, float **normals, float **tangents,
		float **texCoords, int *numberOfVertex);

	//ƽ�����������㷨,Ŀǰ���㷨��ʵ���Ѿ���Shape.cpp��������ʵ��
	int  esGenSquareGrid(int size, float scale, float **vertices, int **indices, int *numberOfVertex);

	////////////////////////////////////////////////////////////����ʽ//////////////////////////////
	//�ĸ����ֹ��ɵĶ�ά���������ʽ
	float     detFloat(float  x1, float y1, float x2, float y2);
	//����������ά������
	float     detVector2(GLVector2  *a, GLVector2  *b);
	float     detVector3(GLVector3   *a, GLVector3   *b, GLVector3   *c);
	//////////////////////////////////////////////////////////////////////////////
__NS_GLK_END
#endif
