/*
  *摄像机类,主要用于大型地形的渲染,空间场景追踪等一系列的3d操作
  *date:2017-6-14
  *@Author:xiaohuaxiong
 */
#ifndef __CAMERA_H__
#define __CAMERA_H__
#include "engine/Object.h"
#include "engine/Geometry.h"

__NS_GLK_BEGIN
/*
  *场景跟踪,在大型地形上漫游
 */
class Camera :public Object
{
private:
	//视图矩阵
	Matrix    _viewMatrix;
	//视图矩阵的逆
	Matrix    _inverseViewMatrix;
	//投影矩阵
	Matrix    _projMatrix;
	//投影矩阵的逆
	Matrix   _inverseProjMatrix;
	//视图投影矩阵
	Matrix   _viewProjMatrix;
	//视图投影矩阵的逆
	Matrix   _inverseViewProjMatrix;
	//对于三个离散分量的坐标轴,用于合成视图矩阵,同时也方便对视图矩阵加以约束
	GLVector3    _xAxis;
	GLVector3    _yAxis;
	GLVector3    _zAxis;
	//摄像机的视点和目光朝向的点
	GLVector3   _eyePosition;
	GLVector3   _targetPosition;
private:
	Camera();
	Camera(Camera &);
public:
	~Camera();
	/*
	  *创建摄像机类,给定眼睛所在的坐标,目光朝向的坐标,以及向上的方向向量
	  *注意,正常情况下方向向量应该朝上,并且在场景跟踪,地形漫游的时候始终会对这个条件加以约束
	 */
	static Camera    *createCamera(const GLVector3 &eyePosition,const GLVector3 &targetPosition,const GLVector3 &upVec);
	/*
	  *设置透视投影矩阵
	  *@param:angle为透视角度
	  *@param:widthRate屏幕的横纵比
	  *@param:screenHeight屏幕的高度
	  *@param:nearZ,farZ近远平面
	 */
	void    setPerspective(const float angle,const float widthRate,const float screenHeight,const float nearZ,const float farZ);
	/*
	  *设置正交投影
	  *@param:left,right屏幕的左右宽度
	  *@param:bottom,top屏幕的底部,上部的跨度
	  *@param:near,far近远平面
	*/
	void   setOrtho(float left,float right,float bottom,float top,float nearZ,float farZ);
	/*
	  *获取视图投影矩阵
	 */
	const Matrix &getViewProjMatrix();
	/*
	  *获取投影矩阵
	 */
	const Matrix &getProjMatrix();
	/*
	  *获取视图矩阵的逆
	 */
	const Matrix &getInverseViewMatrix();
	/*
	  *获取投影矩阵的逆
	 */
	const Matrix &getInverseViewProjMatrix();
	/*
	  *
	 */
};

__NS_GLK_END
#endif