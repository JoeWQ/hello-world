/*
 *Water Simulate
 *2017/2/23
 *@Author:xiaoxiong
 */
#include"WaterSimulate.h"
#include"Geometry.h"
using namespace cocos2d;
typedef GLVector3 (*WaterType)[__WATER_SQUARE_LANDSCAPE__-2];
//coefficient of wave flow out 
const float WaterCoeffValue = 0.99f;
MeshSquare::MeshSquare()
{
	_vertexBufferId = 0;
	_normalBufferId = 0;
	_indexBufferId = 0;
	_countOfIndex = 0;
	_countOfVertex = 0;
}

MeshSquare::~MeshSquare()
{
	glDeleteBuffers(1, &_vertexBufferId);
	glDeleteBuffers(1, &_normalBufferId);
	glDeleteBuffers(1, &_indexBufferId);
	_vertexBufferId = 0;
	_normalBufferId = 0;
	_indexBufferId = 0;
}

void MeshSquare::initWithMeshSquare(float width, float height, int xgrid, int ygrid, float fragCoord)
{
	assert(xgrid>0 && ygrid>0);
	_countOfVertex = (xgrid + 1)*(ygrid+1);
	float *Vertex = new float[_countOfVertex*5];
	for (int j = 0; j < ygrid + 1; ++j)
	{
		const float factor = 1.0f*j / ygrid;
		const float y = height*factor;
		const float yfragCoord = fragCoord - factor;
		float  *nowVertex = Vertex + j*xgrid*5;
		for (int i = 0; i < xgrid + 1; ++i)
		{
			const int index = i * 5;
			nowVertex[index] =width*i/xgrid ;
			nowVertex[index + 1] = y;
			nowVertex[index + 2] = 0.0f;
			nowVertex[index + 3] = 1.0f*i / xgrid;
			nowVertex[index + 4] = yfragCoord;
		}
	}
	//generate index data
	_countOfIndex = xgrid*ygrid*6;
	int *indexVertex = new int[_countOfIndex];
	for (int j = 0; j < ygrid; ++j)
	{
		int *nowIndex = indexVertex + j*xgrid * 6;
		for (int i = 0; i < xgrid; ++i)
		{
			const int _index = i * 6;
			nowIndex[_index] = (j+1)*xgrid+i;
			nowIndex[_index + 1] = j*xgrid + i;
			nowIndex[_index + 2] = (j + 1)*xgrid + (i + 1);

			nowIndex[_index + 3] = (j+1)*xgrid+(i+1);
			nowIndex[_index + 4] = j*xgrid + i;
			nowIndex[_index + 5] = j*xgrid + i + 1;
		}
	}
	int _defaultVertexId,_defaultIndexId;
	glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &_defaultVertexId);
	glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &_defaultIndexId);
	//generate vertex and frag coord
	glGenBuffers(1, &_vertexBufferId);
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferId);
	glBufferData(GL_ARRAY_BUFFER, sizeof(float)*_countOfVertex * 5, Vertex, GL_STATIC_DRAW);
	//generate normal
	glGenBuffers(1,&_normalBufferId);
	glBindBuffer(GL_ARRAY_BUFFER, _normalBufferId);
	glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 3 * _countOfVertex, NULL, GL_DYNAMIC_DRAW);
	//generate index 
	glGenBuffers(1, &_indexBufferId);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferId);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int)*_countOfIndex , indexVertex,GL_STATIC_DRAW);

	delete indexVertex;
	delete Vertex;
	glBindBuffer(GL_ARRAY_BUFFER, _defaultVertexId);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _defaultIndexId);
}

void MeshSquare::drawMeshSquare(int posLoc, int normalLoc, int fragLoc)
{
	int _defaultVertexId;
	int _defaultIndexId;
	glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &_defaultVertexId);
	glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &_defaultIndexId);
	//bind vertex buffer
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferId);
	glEnableVertexAttribArray(posLoc);
	glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 5, NULL);

	glEnableVertexAttribArray(fragLoc);
	glVertexAttribPointer(fragLoc, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 5, (void*)(sizeof(float) * 3));
	//bind normal buffer
	glBindBuffer(GL_ARRAY_BUFFER, _normalBufferId);
	glEnableVertexAttribArray(normalLoc);
	glVertexAttribPointer(normalLoc, 3, GL_FLOAT, GL_FALSE, 0,NULL);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferId);
	glDrawElements(GL_TRIANGLES, _countOfIndex, GL_UNSIGNED_INT, NULL);

	glBindBuffer(GL_ARRAY_BUFFER, _defaultVertexId);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _defaultIndexId);
}

MeshSquare *MeshSquare::createMeshSquare(float width, float height, int xgrid, int ygrid, float fragCoord)
{
	MeshSquare *_meshSquare = new MeshSquare();
	_meshSquare->initWithMeshSquare(width, height, xgrid, ygrid, fragCoord);
	return _meshSquare;
}

//////////////////////////////////Class of Water Simulate/////////////////////////////////////////////////////////////////////
WaterSimulate::WaterSimulate()
{
	_meshSquare = NULL;
//	_texture = NULL;
	_skybox = NULL;
}

WaterSimulate::~WaterSimulate()
{
	_meshSquare->release();
//	_texture->release();
	_skybox->release();
	_glProgram->release();
}

void WaterSimulate::initWithCubeMap(TextureCube *_cubeMap)
{
//	_texture = Director::getInstance()->getTextureCache()->addImage(fileName);
	_skybox = _cubeMap;
	assert(_cubeMap);
	_skybox->retain();
//	_texture->retain();

	const cocos2d::Size &_size = Director::getInstance	()->getWinSize();// _skybox->getContentSize();
	this->setContentSize(_size);
	_meshSquare = MeshSquare::createMeshSquare(_size.width, _size.height, __WATER_SQUARE_LANDSCAPE__ - 3, __WATER_SQUARE_PORTRATE__ - 3,1.0f);
	_glProgram = GLProgram::createWithFilenames("3d/water.vsh", "3d/water.fsh");
	_glProgram->retain();
	_projMatrixLoc = _glProgram->getUniformLocation("CC_PMatrix");
	_modelMatrixLoc = _glProgram->getUniformLocation("u_modelMatrix");
//	_textureLoc = _glProgram->getUniformLocation("CC_Texture0");
	_skyboxLoc = _glProgram->getUniformLocation("u_skybox");
	_eyePositionLoc = _glProgram->getUniformLocation("u_eyePosition");
	_freshnelParamLoc = _glProgram->getUniformLocation("u_freshnelParam");
	_waterColorLoc = _glProgram->getUniformLocation("u_waterColor");
	_waterRatioLoc = _glProgram->getUniformLocation("u_waterRatio");

	_positionLoc = _glProgram->getAttribLocation("a_position");
	_normalLoc = _glProgram->getAttribLocation("a_normal");
	_fragCoordLoc = _glProgram->getAttribLocation("a_fragCoord");
	//set zero
	memset(_nowHeight, 0, sizeof(_nowHeight));
	memset(_nowVelocity,0,sizeof(_nowVelocity));
	_deltaTime = 0;
}

WaterSimulate *WaterSimulate::createWithCubeMap(TextureCube	*_cubeMap)
{
	WaterSimulate *_waterS = new WaterSimulate();
	_waterS->initWithCubeMap(_cubeMap);
	return _waterS;
}

void WaterSimulate::draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& transform, uint32_t flags)
{
	//calculate height field of water
	float _outHeight[__WATER_SQUARE_PORTRATE__][__WATER_SQUARE_LANDSCAPE__];
	memset(_outHeight,0,sizeof(_outHeight));
	for (int i = 1; i <__WATER_SQUARE_PORTRATE__ - 1; ++i)
	{
		for (int j = 1; j <  __WATER_SQUARE_LANDSCAPE__ - 1; ++j)
		{
			const float _arroundValue = _nowHeight[i-1][j-1] +_nowHeight[i-1][j]+_nowHeight[i-1][j+1] + _nowHeight[i][j-1]
															+_nowHeight[i][j+1] + _nowHeight[i+1][j-1]+_nowHeight[i+1][j]+_nowHeight[i+1][j+1];
			_nowVelocity[i][j] += _arroundValue * 0.125f - _nowHeight[i][j];
			_nowVelocity[i][j] *= WaterCoeffValue;
			_outHeight[i][j] = _nowVelocity[i][j]+_nowHeight[i][j];
		}
	}
	//begin map buffer
	int _defaultNormalId;
	glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &_defaultNormalId);
	const unsigned _normalBufferId = _meshSquare->getNormal();
	glBindBuffer(GL_ARRAY_BUFFER, _normalBufferId);
	WaterType nowNormal = (WaterType)glMapBufferRange(GL_ARRAY_BUFFER, 0, sizeof(GLVector3)*(__WATER_SQUARE_PORTRATE__ - 2)*(__WATER_SQUARE_LANDSCAPE__-2),GL_MAP_WRITE_BIT);
	//build normal
	for (int i = 1; i < __WATER_SQUARE_PORTRATE__ - 1; ++i)
	{
		for (int j = 1; j < __WATER_SQUARE_LANDSCAPE__ - 1; ++j)
		{
			nowNormal[i - 1][j - 1] = GLVector3(_outHeight[i][j + 1] - _outHeight[i][j], _outHeight[i + 1][j] - _outHeight[i][j], _outHeight[i][j]);
		}
	}
	glUnmapBuffer(GL_ARRAY_BUFFER);
	memcpy(_nowHeight, _outHeight, sizeof(_outHeight));
	glBindBuffer(GL_ARRAY_BUFFER, _defaultNormalId);
	//rain simulate
	_deltaTime += 0.033f;
	if (_deltaTime > 0.5f)
	{
		_deltaTime = 0.0f;
		const float idx = rand_0_1()*(__WATER_SQUARE_LANDSCAPE__-2);
		const float idy = rand_0_1()*(__WATER_SQUARE_PORTRATE__-2);
		const float _radius = 16.0f;
		for (int i = 1; i < __WATER_SQUARE_PORTRATE__ - 1; ++i)
		{
			for (int j = 1; j < __WATER_SQUARE_LANDSCAPE__ - 1; ++j)
			{
				const float _nowRadius = sqrt((i-idy)*(i-idy)+(j-idx)*(j-idx));
				_nowHeight[i][j] -= exp(-_nowRadius/_radius*6.0f - 2.0f);
			}
		}
	}
	//
	cocos2d::Node::draw(renderer,transform,flags);
}

void WaterSimulate::visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)
{
	if (!_visible)
		return;
	_drawWaterMeshCommand.init(_globalZOrder);
	_drawWaterMeshCommand.func = CC_CALLBACK_0(WaterSimulate::drawWaterMesh,this,parentTransform,parentFlags);
	renderer->addCommand(&_drawWaterMeshCommand);

	cocos2d::Node::visit(renderer, parentTransform, parentFlags);
}

void WaterSimulate::drawWaterMesh(const cocos2d::Mat4& transform, uint32_t flags)
{
	int _defaultTextureId;
	glGetIntegerv(GL_TEXTURE_BINDING_CUBE_MAP, &_defaultTextureId);
	//need calculate model matrix,self position
	Matrix _modelMatrix;
	memcpy(&_modelMatrix,&transform,sizeof(Matrix));
	_modelMatrix.translate(_position.x, _position.y, 0.0f);
	_glProgram->use();

	const cocos2d::Mat4 &_projMatrix = Director::getInstance()->getMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_PROJECTION);
	glUniformMatrix4fv(_modelMatrixLoc,1,GL_FALSE,_modelMatrix.pointer());
	glUniformMatrix4fv(_projMatrixLoc,1,GL_FALSE,_projMatrix.m);

	glActiveTexture(GL_TEXTURE0);
//	glBindTexture(GL_TEXTURE_2D, _texture->getName());
	glBindTexture(GL_TEXTURE_CUBE_MAP, _skybox->getName());
	_glProgram->setUniformLocationWith1i(_textureLoc, 0);

	Vec3  _freshnelParam(0.12f, 0.88f, 2.0f);
	const cocos2d::Size &_size = Director::getInstance()->getWinSize();
	Vec3  _eyePosition(_size.width/2.0f, _size.height/2.0f, _size.width/2.5f);
	Vec4  _waterColor(0.4f, 0.48f, 0.97f, 1.0f);
	float   _waterRatio = 1.0f / 1.33f;
	glUniform3fv(_freshnelParamLoc,1,&_freshnelParam.x);
	glUniform3fv(_eyePositionLoc,1,&_eyePosition.x);
	glUniform4fv(_waterColorLoc, 1, &_waterColor.x);
	glUniform1f(_waterRatioLoc,_waterRatio );

	_meshSquare->drawMeshSquare(_positionLoc, _normalLoc, _fragCoordLoc);

	glBindTexture(GL_TEXTURE_CUBE_MAP, _defaultTextureId);
}