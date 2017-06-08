/*
  *��Ⱦ���ε�OpenGL Shader
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
	//ģ�;����shaderλ��
	int                         _modelMatrixLoc;
	//��ͼͶӰ�����λ��
	int                         _viewProjMatrixLoc;
	//���߾���
	int                         _normalMatrixLoc;
	//�۾���λ��
	int                         _eyePositionLoc;
	//��ɫ
	int                         _colorLoc;
private:
	TerrainShader();
	TerrainShader(TerrainShader &);
	void    initWithFile(const char *vsFile,const char *fsFile);
public:
	~TerrainShader();

	static TerrainShader *createTerrainShader(const char *vsFile,const char *fsFile);
	/*
	  *����ģ�;���
	 */
	void   setModelMatrix(const glk::Matrix &modelMatrix);
	/*
	  *������ͼͶӰ����
	 */
	void   setViewProjMatrix(const glk::Matrix &viewProjMatrix);
	/*
	  *���÷��߾���
	 */
	void   setNormalMatrix(const glk::Matrix3 &normalMatrix);
	/*
	  *���ù۲��ߵ�λ��
	 */
	void   setEyePosition(const glk::GLVector3 &eyePosition);
	/*
	  *���õ��εĻ�����ɫ
	 */
	void   setTerrainColor(const glk::GLVector4 &color);
	/*
	  *ʹ��Shader
	 */
	void   perform()const;
};
#endif