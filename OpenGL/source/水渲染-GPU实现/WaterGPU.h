/*
  *ˮ�����GPUʵ��
  *@2017-8-3
  *@Author:xiaohuaxiong
*/
#ifndef __WATER_GPU_H__
#define __WATER_GPU_H__
#include "engine/Object.h"
#include "engine/Geometry.h"
#include "engine/Camera.h"
#include "engine/RenderTexture.h"
#include "engine/Shape.h"
#include "engine/GLTexture.h"

#include "WaterHeightShader.h"
#include "WaterNormalShader.h"
#include "WaterShader.h"
#include "PoolShader.h"

class WaterGPU :public glk::Object
{
	//Shader
	WaterHeightShader     *_waterHeightShader;
	WaterNormalShader   *_waterNormalShader;
	WaterShader                *_waterShader;
	PoolShader                   *_poolShader;
	//Renderer Texture
	glk::RenderTexture      *_heightTexture0;
	glk::RenderTexture      *_heightTexture1;
	glk::RenderTexture      *_normalTexture;
	glk::GLProgram            *_renderNormal;
	//Camera
	glk::Camera                 *_camera;
	//Mesh
	glk::Skybox	                  *_poolMesh;
	//ˮ������
	glk::Mesh                      *_waterMesh;
	//��������ͼ
	glk::GLCubeMap         *_texCubeMap;
	//������İ�߶�
	float                               _halfCubeHeight;
	//�����������ķ�������
	glk::GLVector3             _texCubeNormals[6];
	//ģ�;���
	glk::Matrix                  _waterModelMatrix;
	glk::Matrix                  _skyboxModelMatrix;
	//���߾���
	glk::Matrix3                _waterNormalMatrix;
	//��Դ��λ��
	glk::GLVector3            _lightPosition;
	//����ˮ������Ŷ�����
	glk::GLVector4           _waterParam;
	float                             _deltaTime;
private:
	WaterGPU();
	WaterGPU(const WaterGPU &);
	void           init();
public:
	~WaterGPU();
	static WaterGPU *create();
	//��ʼ�������
	void          initCamera(const glk::GLVector3 &eyePosition,const glk::GLVector3 &targetPosition);
	//���ù���ˮ�Ĳ���
	void          initWaterParam();
	//��Ⱦˮ�߶�����
	void          drawWaterHeightTexture();
	//��Ⱦˮ��������
	void          drawWaterNormalTexture();
	//��Ⱦ��պ�
	void         drawSkybox();
	//draw
	void         draw();
	//update()
	void         update(float deltaTime);
	/*
	 */
	void         drawTest(int   textureId);
};
#endif