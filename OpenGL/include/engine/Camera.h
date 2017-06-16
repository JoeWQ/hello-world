/*
  *�������,��Ҫ���ڴ��͵��ε���Ⱦ,�ռ䳡��׷�ٵ�һϵ�е�3d����
  *date:2017-6-14
  *@Author:xiaohuaxiong
 */
#ifndef __CAMERA_H__
#define __CAMERA_H__
#include "engine/Object.h"
#include "engine/Geometry.h"

__NS_GLK_BEGIN
/*
  *��������,�ڴ��͵���������
 */
class Camera :public Object
{
private:
	//��ͼ����
	Matrix    _viewMatrix;
	//��ͼ�������
	Matrix    _inverseViewMatrix;
	//ͶӰ����
	Matrix    _projMatrix;
	//ͶӰ�������
	Matrix   _inverseProjMatrix;
	//��ͼͶӰ����
	Matrix   _viewProjMatrix;
	//��ͼͶӰ�������
	Matrix   _inverseViewProjMatrix;
	//����������ɢ������������,���ںϳ���ͼ����,ͬʱҲ�������ͼ�������Լ��
	GLVector3    _xAxis;
	GLVector3    _yAxis;
	GLVector3    _zAxis;
	//��������ӵ��Ŀ�⳯��ĵ�
	GLVector3   _eyePosition;
	GLVector3   _targetPosition;
private:
	Camera();
	Camera(Camera &);
public:
	~Camera();
	/*
	  *�����������,�����۾����ڵ�����,Ŀ�⳯�������,�Լ����ϵķ�������
	  *ע��,��������·�������Ӧ�ó���,�����ڳ�������,�������ε�ʱ��ʼ�ջ�������������Լ��
	 */
	static Camera    *createCamera(const GLVector3 &eyePosition,const GLVector3 &targetPosition,const GLVector3 &upVec);
	/*
	  *����͸��ͶӰ����
	  *@param:angleΪ͸�ӽǶ�
	  *@param:widthRate��Ļ�ĺ��ݱ�
	  *@param:screenHeight��Ļ�ĸ߶�
	  *@param:nearZ,farZ��Զƽ��
	 */
	void    setPerspective(const float angle,const float widthRate,const float screenHeight,const float nearZ,const float farZ);
	/*
	  *��������ͶӰ
	  *@param:left,right��Ļ�����ҿ��
	  *@param:bottom,top��Ļ�ĵײ�,�ϲ��Ŀ��
	  *@param:near,far��Զƽ��
	*/
	void   setOrtho(float left,float right,float bottom,float top,float nearZ,float farZ);
	/*
	  *��ȡ��ͼͶӰ����
	 */
	const Matrix &getViewProjMatrix();
	/*
	  *��ȡͶӰ����
	 */
	const Matrix &getProjMatrix();
	/*
	  *��ȡ��ͼ�������
	 */
	const Matrix &getInverseViewMatrix();
	/*
	  *��ȡͶӰ�������
	 */
	const Matrix &getInverseViewProjMatrix();
	/*
	  *
	 */
};

__NS_GLK_END
#endif