/*
  *��������,�������ݽṹ
  *2016-5-21
   */
//Version 5.0 �����е��йؾ���Ĳ������뵽��������,��Ϊ����ĳ�Ա����ʵ��
//Version 6.0 �����ߵļ������뵽����,������,��������������㷨��
//Version 7.0 ��������Ԫ���ļ���
#ifndef   __GEOMETRY_H__
#define  __GEOMETRY_H__

//2,3,4ά����
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
//���׾���,��Ϊʹ�õĵط��ǳ���,�������߾�û��ʵ���������й����׾���Ĳ���
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
   inline    float     *pointer(){   return (float*)m ; };
//���ص�λ����
   void      identity();
//����֮��Ŀ��ٸ���
   void     copy(Matrix   &);
//����
   void     scale(float scaleX,float scaleY,float  scaleZ);
//ƽ��float 
   void    translate(float deltaX,float  deltaY,float deltaZ);
//��ת
   void    rotate(float  angle,float x,float y,float z);
//�ҳ���ͼ����
   void    lookAt(GLVector3  &eyePosition,GLVector3  &targetPosition,GLVector3  &upVector);
//�ҳ�����ͶӰ����
   void    orthoProject(float  left,float right,float  bottom,float  top,float  nearZ,float  farZ);
//͸��ͶӰ����
   void    perspective(float fovy, float aspect, float nearZ, float farZ);
//һ��ͶӰ����
   void    frustum(float left, float right, float bottom, float top, float nearZ, float farZ);
//����˷�,self=self*srcA
   void    multiply(Matrix   &srcA);
//self=srcA*srcB
   void    multiply(Matrix   &srcA,Matrix   &rscB);
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
   Matrix    operator*(Matrix   &);
//�����������˷�
   GLVector4  operator*(GLVector4  &);
//����֮��ĸ���
   Matrix&    operator=(Matrix  &);
} ;

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
	 Quaternion(float w,float x,float y,float z);
//ʹ�ýǶ�+������ʼ����Ԫ��
//	 Quaternion(float    angle,float      x,float  y,float   z);
	 Quaternion(float    angle,GLVector3  &);
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
	 static    Quaternion	   lerp(Quaternion  &p,Quaternion	&q,float      lamda);
//��������Ԫ��֮������������Բ�ֵ
	 static    Quaternion     slerp(Quaternion	&p,Quaternion		&q,float     lamda);
 };
//
int  esGenSphere ( int numSlices, float radius, float **vertices, float **normals,float  **tangents,
	float **texCoords, int **indices, int  *numberOfVertex);

/// \return The number of indices required for rendering the buffers (the number of indices stored in the indices array
///         if it is not NULL ) as a GL_TRIANGLES
//numberOfVertex:������Ŀ,position 3����,normals������,indices
int  esGenCube ( float scale, float **vertices, float **normals,float **tangents,
                           float **texCoords,int *numberOfVertex);

/// \return The number of indices required for rendering the buffers (the number of indices stored in the indices array
///         if it is not NULL ) as a GL_TRIANGLES
//
int  esGenSquareGrid(int size,float scale, float **vertices, int **indices,int *numberOfVertex);

//�����Ĳ�� result=a x b
GLVector3        cross(GLVector3  *a,GLVector3  *b);

//�����ĵ��
float                   dot(GLVector3  *srcA,GLVector3  *srcB);

//������׼��
GLVector3                  normalize(GLVector3   *src);
GLVector2                  normalize(GLVector2   *src);

#endif
