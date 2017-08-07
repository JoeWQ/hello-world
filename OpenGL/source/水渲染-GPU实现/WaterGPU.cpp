/*
  *水渲染GPU实现
  *2017-8-3
  *@Author:xiaohuaxiong
 */
#include "GL/glew.h"
#include "engine/GLContext.h"
#include "engine/GLCacheManager.h"

#include "WaterGPU.h"
__US_GLK__;
static const float MeshSize = 128.0f;
WaterGPU::WaterGPU() :
	_waterHeightShader(nullptr)
	, _waterNormalShader(nullptr)
	, _waterShader(nullptr)
	, _poolShader(nullptr)
	, _heightTexture0(nullptr)
	, _heightTexture1(nullptr)
	, _camera(nullptr)
	, _poolMesh(nullptr)
	,_waterMesh(nullptr)
	,_texCubeMap(nullptr)
	, _deltaTime(0)
{

}

WaterGPU::~WaterGPU()
{
	_waterHeightShader->release();
	_waterNormalShader->release();
	_waterShader->release();
	_poolShader->release();
	_heightTexture0->release();
	_heightTexture1->release();
	_camera->release();
	_poolMesh->release();
	_waterMesh->release();
	_texCubeMap->release();
}

WaterGPU * WaterGPU::create()
{
	WaterGPU * water = new WaterGPU();
	water->init();
	return water;
}

void		WaterGPU::init()
{
	//初始化shader
	_waterHeightShader = WaterHeightShader::create("shader/WaterGPU/WaterHeight_VS.glsl", "shader/WaterGPU/WaterHeight_FS.glsl");
	_waterNormalShader = WaterNormalShader::create("shader/WaterGPU/WaterNormal_VS.glsl","shader/WaterGPU/WaterNormal_FS.glsl");
	_waterShader = WaterShader::create("shader/WaterGPU/Water_VS.glsl", "shader/WaterGPU/Water_FS.glsl");
	_poolShader = PoolShader::create("shader/WaterGPU/Pool_VS.glsl","shader/WaterGPU/Pool_FS.glsl");
	_renderNormal = GLProgram::createWithFile("shader/WaterGPU/Normal_VS.glsl", "shader/WaterGPU/Normal_FS.glsl");
	/*
	  *天空盒
	 */
	_poolMesh = Skybox::createWithScale(MeshSize);
	_waterMesh = Mesh::createWithIntensity(MeshSize / 2.0f, MeshSize, MeshSize, 1.0f,Mesh::MeshType::MeshType_XOZ);
	const char *cubeMapFiles[6] = {
			"tga/water/pool/right.tga",//+X
			"tga/water/pool/left.tga",
			"tga/water/pool/top.tga",
			"tga/water/pool/bottom.tga",
			"tga/water/pool/front.tga",
			"tga/water/pool/back.tga"
	};
	_texCubeMap = GLCubeMap::createWithFiles(cubeMapFiles);
	/*
	  *立方体的各个法线向量
	 */
	_texCubeNormals[0] = GLVector3(-1.0f,0.0f,0.0f);//+X
	_texCubeNormals[1] = GLVector3(1.0f,0.0f,0.0f);//-X
	_texCubeNormals[2] = GLVector3(0.0f,-1.0f,0.0f);//+Y
	_texCubeNormals[3] = GLVector3(0.0f,1.0f,0.0f);//-Y
	_texCubeNormals[4] = GLVector3(0.0f,0.0f,-1.0f);//+Z
	_texCubeNormals[5] = GLVector3(0.0f,0.0f,1.0f);//-Z
	//立方体的半高度
	_halfCubeHeight = MeshSize;
	//Render Texture
	Size texSize(MeshSize,MeshSize);
	int   format[1] = {GL_RGBA32F};
	int   format2[1] = {GL_RGBA32F};
	_heightTexture0 = RenderTexture::createRenderTexture(texSize,RenderTexture::RenderType::ColorBuffer,format);
	_heightTexture1 = RenderTexture::createRenderTexture(texSize, RenderTexture::RenderType::ColorBuffer, format);
	_normalTexture = RenderTexture::createRenderTexture(texSize, RenderTexture::RenderType::ColorBuffer, format2);

	_heightTexture0->setClearBuffer(false);
	_heightTexture1->setClearBuffer(false);
	_normalTexture->setClearBuffer(false);
	//初始化摄像机
	initCamera(GLVector3(0.0f,MeshSize/1.f,MeshSize/2),GLVector3(0.0f,0.0f,-MeshSize/2.0f));
	//初始化关于水的参数
	initWaterParam();
}

void		WaterGPU::initCamera(const glk::GLVector3 &eyePosition, const glk::GLVector3 &targetPosition)
{
	_camera = Camera::createCamera(eyePosition, targetPosition, GLVector3(0.0f,1.0f,0.0f));
	auto &winSize = GLContext::getInstance()->getWinSize();
	_camera->setPerspective(60.0f, winSize.width/winSize.height,0.1f,500.0f);
}

void  WaterGPU::initWaterParam()
{
	//平面网格模型矩阵
	_waterModelMatrix.identity();
	_waterModelMatrix.translate(0.0f,0.0f,-MeshSize);
	//天空盒的平移矩阵
	_skyboxModelMatrix.identity();
	_skyboxModelMatrix.translate(0.0f, 0.0f, -MeshSize);

	_lightPosition = GLVector3(MeshSize/2.0f,MeshSize,-MeshSize);
}

void  WaterGPU::drawWaterHeightTexture()
{
	//绑定帧缓冲区对象,最后产生数值输出的一定是_heightTexture0
	_heightTexture0->activeFramebuffer();
	_waterHeightShader->perform();

	int identityVertex = GLCacheManager::getInstance()->loadBufferIdentity();
	glBindBuffer(GL_ARRAY_BUFFER,identityVertex);

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,sizeof(float)*5,nullptr);

	glEnableVertexAttribArray(1);
	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 5,(void*)(sizeof(float)*3));

	_waterHeightShader->setBaseMap(_heightTexture1->getColorBuffer(), 0);
	_waterHeightShader->setMeshSize(GLVector2(MeshSize,MeshSize));
	_waterHeightShader->setWaterParam(_waterParam);

	glDrawArrays(GL_TRIANGLE_STRIP,0,4);
	_heightTexture0->disableFramebuffer();
	_waterParam.w = 0;
}

void WaterGPU::drawWaterNormalTexture()
{
	//计算法线向量
	_normalTexture->activeFramebuffer();
	_waterNormalShader->perform();

	int identityVertex = GLCacheManager::getInstance()->loadBufferIdentity();
	glBindBuffer(GL_ARRAY_BUFFER,identityVertex);

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,sizeof(float)*5,nullptr);

	glEnableVertexAttribArray(1);
	glVertexAttribPointer(1,2,GL_FLOAT,GL_FALSE,sizeof(float)*5,(void*)(sizeof(float)*3));

	_waterNormalShader->setBaseMap(_heightTexture0->getColorBuffer(), 0);
	_waterNormalShader->setMeshInterval(1.0f);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	_normalTexture->disableFramebuffer();
}

void  WaterGPU::drawSkybox()
{
	_poolShader->perform();
	//绑定顶点数据
	_poolMesh->bindVertexObject(0);
	_poolMesh->bindTexCoordObject(1);
	//设置Uniform 变量
	_poolShader->setMVPMatrix(_skyboxModelMatrix * _camera->getViewProjMatrix());
	_poolShader->setTexCubeMap(_texCubeMap->getName(), 0);
	
	_poolMesh->drawShape();
}

void WaterGPU::draw()
{
	auto &winSize = GLContext::getInstance()->getWinSize();
	glViewport(0, 0, MeshSize, MeshSize);
	glDisable(GL_DEPTH_TEST);
	//glDisable(GL_CULL_FACE);
	/*
	  *计算高度场
	 */
	drawWaterHeightTexture();
	drawTest(_heightTexture0->getColorBuffer());
	///*
	//  *计算法线向量
	// */
	//drawWaterNormalTexture();
	////
	//glViewport(0, 0, winSize.width, winSize.height);
	//glEnable(GL_DEPTH_TEST);
	//glEnable(GL_CULL_FACE);
	///*
	//  *天空盒
	// */
	////drawSkybox();
	////glDisable(GL_CULL_FACE);
	///*
	//  *水
	// */
	//_waterShader->perform();
	////顶点数据
	//_waterMesh->bindVertexObject(0);
	//_waterMesh->bindTexCoordObject(1);
	////uniform
	//_waterShader->setCameraPosition(_camera->getCameraPosition());
	//_waterShader->setCubeMapNormal(_texCubeNormals,6);
	//_waterShader->setHalfCubeHeight(_halfCubeHeight);
	//_waterShader->setHeightMap(_heightTexture0->getColorBuffer(),0);
	//_waterShader->setNormalMap(_normalTexture->getColorBuffer(), 1);
	//_waterShader->setTexCubeMap(_texCubeMap->getName(), 2);
	//_waterShader->setModelMatrix(_waterModelMatrix);
	//_waterShader->setLightPosition(_lightPosition);
	//_waterShader->setViewProjMatrix(_camera->getViewProjMatrix());
	//
	//_waterMesh->drawShape();
	/*
	  *交换高度场RTT
	 */
	RenderTexture *rtt = _heightTexture0;
	_heightTexture0 = _heightTexture1;
	_heightTexture1 = rtt;
}

void WaterGPU::drawTest(int textureId)
{
	_renderNormal->perform();
	int mvpMatrixLoc = _renderNormal->getUniformLocation("g_MVPMatrix");
	int baseMapLoc = _renderNormal->getUniformLocation("g_BaseMap");
	int identityVertex = GLCacheManager::getInstance()->loadBufferIdentity();

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 5,nullptr);

	glEnableVertexAttribArray(1);
	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 5,(void*)(sizeof(float)*3));

	Matrix identityMatrix;
	glUniformMatrix4fv(mvpMatrixLoc,1,GL_FALSE,identityMatrix.pointer());

	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D,textureId);
	glUniform1i(baseMapLoc,0);

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

void WaterGPU::update(float deltaTime)
{
	_deltaTime += deltaTime;
	if (_deltaTime > 0.3)
	{
		_deltaTime = 0;
		float dx = 1.0f * rand() / RAND_MAX  ;
		float dy = 1.0f * rand() / RAND_MAX ;

		_waterParam.x = dx *MeshSize;
		_waterParam.y = dy * MeshSize;
		_waterParam.z = 32.0f;
		_waterParam.w = 4.0f;
	}
}