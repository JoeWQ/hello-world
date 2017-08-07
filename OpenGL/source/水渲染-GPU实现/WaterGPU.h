/*
  *水体仿真GPU实现
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
	//水面网格
	glk::Mesh                      *_waterMesh;
	//立方体贴图
	glk::GLCubeMap         *_texCubeMap;
	//立方体的半高度
	float                               _halfCubeHeight;
	//立方体各个面的法线向量
	glk::GLVector3             _texCubeNormals[6];
	//模型矩阵
	glk::Matrix                  _waterModelMatrix;
	glk::Matrix                  _skyboxModelMatrix;
	//法线矩阵
	glk::Matrix3                _waterNormalMatrix;
	//光源的位置
	glk::GLVector3            _lightPosition;
	//关于水网格的扰动参数
	glk::GLVector4           _waterParam;
	float                             _deltaTime;
private:
	WaterGPU();
	WaterGPU(const WaterGPU &);
	void           init();
public:
	~WaterGPU();
	static WaterGPU *create();
	//初始化摄像机
	void          initCamera(const glk::GLVector3 &eyePosition,const glk::GLVector3 &targetPosition);
	//设置关于水的参数
	void          initWaterParam();
	//渲染水高度纹理
	void          drawWaterHeightTexture();
	//渲染水面网格法线
	void          drawWaterNormalTexture();
	//渲染天空盒
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