/*
  *渲染地形的OpenGL Shader
  *@date:2017-6-8
  *@Author:xiaohuaxiong
  */
#ifndef __TERRAIN_SHADER_H__
#define __TERRAIN_SHADER_H__
#include "engine/GLProgram.h"
#include "engine/Geometry.h"
class TerrainShader
{
	glk::GLProgram *_terrainProgram;
	//模型矩阵的shader位置
	int                         _modelMatrixLoc;
	//视图投影矩阵的位置
	int                         _viewProjMatrixLoc;
	//法线矩阵
	int                         _normalMatrixLoc;
	//眼睛的位置
	int                         _eyePositionLoc;
	//颜色
	int                         _colorLoc;
private:
	TerrainShader();
	TerrainShader(TerrainShader &);
	void    initWithFile(const char *vsFile,const char *fsFile);
public:
	~TerrainShader();

	static TerrainShader *createTerrainShader(const char *vsFile,const char *fsFile);
	/*
	  *设置模型矩阵
	 */
	void   setModelMatrix(const glk::Matrix &modelMatrix);
	/*
	  *设置视图投影矩阵
	 */
	void   setViewProjMatrix(const glk::Matrix &viewProjMatrix);
	/*
	  *设置法线矩阵
	 */
	void   setNormalMatrix(const glk::Matrix3 &normalMatrix);
	/*
	  *设置观察者的位置
	 */
	void   setEyePosition(const glk::GLVector3 &eyePosition);
	/*
	  *设置地形的基本颜色
	 */
	void   setTerrainColor(const glk::GLVector4 &color);
	/*
	  *使用Shader
	 */
	void   perform()const;
};
#endif