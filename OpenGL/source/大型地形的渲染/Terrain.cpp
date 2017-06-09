/*
  *大型地形的渲染
  *@date:2017-6-8
  *@Author:xiaohuaxiong
  *@Version 1.0:实现了最基本的地形渲染
 */
#include "GL/glew.h"
#include "engine/GLContext.h"
#include "Terrain.h"
#include<stdio.h>
#include<assert.h>
Terrain::Terrain()
{
	_terrainShader = nullptr;
	_keyListener = nullptr;
	_touchListener = nullptr;
	//
	_terrainVertexId = 0;
	_terrainIndexId = 0;
	//
	_heightField = nullptr;
	_terrainSize = 0;
}

Terrain::~Terrain()
{
	delete _terrainShader;
	_terrainShader = nullptr;
	glDeleteBuffers(1, &_terrainVertexId);
	glDeleteBuffers(1, &_terrainIndexId);
	_terrainVertexId = 0;
	_terrainIndexId = 0;
}

Terrain  *Terrain::createTerrainWithFile(const std::string &filename)
{
	Terrain  *terrain = new Terrain();
	terrain->initWithFile(filename);
	return terrain;
}

Terrain *Terrain::createTerrainWithTexture(glk::GLTexture *hightTexture)
{
	return nullptr;
}

void Terrain::initWithFile(const std::string &filename)
{
	//打开并测试文件
	FILE   *fp = nullptr;
	const int errorCode = fopen_s(&fp, filename.c_str(), "rb");
	if (errorCode)
	{
		printf("Open binary terrain file '%s' error!\n",filename.c_str());
		assert(!errorCode);
	}
	//检测文件内容
	if (fread(&_terrainSize, sizeof(int), 1, fp) != 1 || _terrainSize<=0 )
	{
		printf("Binary file '%s' has broken format!\n",filename.c_str());
		fclose(fp);
		fp = nullptr;
		assert(0);
	}
	const int sizePlusOne = _terrainSize + 1;
	const float halfWidth = _terrainSize/2.0f;
	const int    totalSize = sizePlusOne * sizePlusOne;
	_heightField = new float[totalSize];
	if (fread(_heightField, sizeof(float), totalSize,fp) != totalSize)
	{
		fclose(fp);
		fp = nullptr;
		printf("Binary file '%s' lose data.\n",filename.c_str());
		assert(0);
	}
	//计算最大/最小高程值
	for (int i = 0; i < totalSize; ++i)
	{
		if (_boundaryMax.y < _heightField[i])
			_boundaryMax.y = _heightField[i];
		if (_boundaryMin.y > _heightField[i])
			_boundaryMin.y = _heightField[i];
	}
	//计算平面网格
	int index = 0;
	float   *VertexData = new float[totalSize*6];
	for (int z = 0; z < sizePlusOne; ++z)
	{
		for (int x = 0; x < sizePlusOne; ++x)
		{
			//position
			glk::GLVector3  *position = (glk::GLVector3 *)(VertexData+index);
			position->x = x - halfWidth;
			position->y = this->getHeightValue(x, z);
			position->z = z - halfWidth;
			glk::GLVector3 *normal = (glk::GLVector3 *)(VertexData+index+3);
			normal->x = this->getHeightValue(x+1,z)-this->getHeightValue(x,z);
			normal->y = 1.0f;
			normal->z = this->getHeightValue(x, z + 1) - this->getHeightValue(x, z);
			index += 6;
		}
	}
	//生成顶点缓冲区对象
	glGenBuffers(1, &_terrainVertexId);
	glBindBuffer(GL_ARRAY_BUFFER, _terrainVertexId);
	glBufferData(GL_ARRAY_BUFFER, sizeof(float)*totalSize*6,VertexData,GL_STATIC_DRAW);
	delete VertexData;
	VertexData = nullptr;
	//产生三角形扇序列
	int *indexVertex = new int[_terrainSize*_terrainSize * 6];
	index = 0;
	for (int z = 0; z < _terrainSize; ++z)
	{
		for (int x = 0; x < _terrainSize; ++x)
		{
			//上三角
			indexVertex[index] = (z+1) *sizePlusOne+x;
			indexVertex[index + 1] = z*sizePlusOne+x;
			indexVertex[index + 2] = (z+1)*sizePlusOne + x + 1;
			//下三角
			indexVertex[index + 3] = (z + 1)*sizePlusOne + x + 1;
			indexVertex[index + 4] = z*sizePlusOne + x;
			indexVertex[index + 5] = z*sizePlusOne + x + 1;
			index += 6;
		}
	}
	glGenBuffers(1, &_terrainIndexId);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _terrainIndexId);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int)*_terrainSize*_terrainSize * 6,indexVertex,GL_STATIC_DRAW);
	delete indexVertex;
	indexVertex = nullptr;
	/*
	  *Shader
	*/
	_terrainShader = TerrainShader::createTerrainShader("shader/terrain/VS_Terrain.glsl", "shader/terrain/FS_Terrain.glsl");
}
inline float Terrain::getHeightValue(int x, int z)const
{
	const int nx = x < 0 ? 0 : (x>_terrainSize?_terrainSize:x);
	const int nz = z < 0 ? 0 : (z>_terrainSize?_terrainSize:z);
	return _heightField[nz*(_terrainSize+1)+x];
}

inline int Terrain::getRealIndex(int x, int z)const
{
	const int nx = x < 0 ? 0 : (x > _terrainSize ? _terrainSize : x);
	const int nz = z < 0 ? 0 : (z > _terrainSize ? _terrainSize : z);
	return nz *(_terrainSize+1) + nx;
}

float Terrain::getHeightValueSmooth(float x, float z)const
{
	const float halfWidth = _terrainSize / 2.0f;
	x += halfWidth;
	z += halfWidth;
	const float nx = x < 0 ? 0:(x>_terrainSize?_terrainSize:x);
	const float nz = z < 0 ? 0 : (z>_terrainSize?_terrainSize:z);

	const int lx = (int)nx;
	const int lz = (int)nz;
//计算中心位置离座小叫位置的偏移
	const float fx = nx - lx;
	const float fz = nz - lz;

	float a = this->getHeightValue(lx, lz);
	float b = this->getHeightValue(lx+1,lz);
	float c = this->getHeightValue(x, lz + 1);
	float d = this->getHeightValue(x + 1, lz + 1);

	float ab = a + (b - 1)*fx;
	float cd = c + (c - d)*fx;
	return ab + (cd-ab)*fz;
}

void   Terrain::initCamera(const glk::GLVector3 &eyePosition, const glk::GLVector3 &targetPosition)
{
	_viewMatrix.identity();
	_viewMatrix.lookAt(eyePosition, targetPosition, glk::GLVector3(0.0f,1.0f,0.0f));
	//投影矩阵
	auto &winSize = glk::GLContext::getInstance()->getWinSize();
	_projMatrix.identity();
	_projMatrix.perspective(60.0f, winSize.width/winSize.height, 0.1f, 500.0f);
	//视图投影矩阵
	_viewProjMatrix = _viewMatrix * _projMatrix;
	//分解矩阵
	const float *array = _viewMatrix.pointer();
}

void  Terrain::update(const float deltaTime)
{

}

void Terrain::render()
{

}