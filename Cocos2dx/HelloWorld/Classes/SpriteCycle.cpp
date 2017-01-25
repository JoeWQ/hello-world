//循环滚动精灵实现
//注意滚动的时候,逆时针方向为正
//2017-1-21 11:54:45
#include"SpriteCycle.h"
#include"renderer/ccGLStateCache.h"
#include"Geometry.h"
#include<math.h>
#include<assert.h>
#define __MATH_PI_    3.14159265358
//元换角度的基数,所有的角度都需要类加上这个角度,以调整数字显示
#define __ANGLE_BASE_ (360/20-90)
//Vertex Shader 
static const char *CycleVertexShader = "attribute vec4    a_position;"
"attribute vec2 a_fragCoord;"
"uniform mat4 u_modelViewMatrix;"
"uniform mat4 u_rotateMatrix;"
"uniform mat4 u_projMatrix;"
"varying vec2 v_fragCoord;"
"void	main()"
"{"
"		gl_Position = u_projMatrix * u_modelViewMatrix * u_rotateMatrix*a_position;"
"		v_fragCoord = a_fragCoord;"
"}";
static const char *CycleFragShader = "uniform sampler2D CCTexture;"
"varying vec2 v_fragCoord;"
"void	main()"
"{"
"	gl_FragColor = texture2D(CCTexture,v_fragCoord);"
"}";
MeshCycle::MeshCycle()
{
	_vVertexId = 0;
	_vVertexIndexId = 0;
	_vVertexCount = 0;
	_vVertexIndexCount = 0;
}
MeshCycle::~MeshCycle()
{
	glDeleteBuffers(1, &_vVertexId);
	glDeleteBuffers(1, &_vVertexIndexId);
	_vVertexId = 0;
	_vVertexIndexId = 0;
	_vVertexCount = 0;
}
void MeshCycle::initMeshCycle(float width, float radius, int xGrid, int yGrid)
{
	//计算所有顶点的数目,注意还有纹理的坐标
	int totalCount = (xGrid+1)*(yGrid+1);
	float  *VertexData = new float[totalCount*(3+2)];
	float  xOffset = 0.0f;
	float  yOffset = 0.0f;
	//圆环的前半部分
	const  int  halfCycle = (yGrid + 1) / 2;
	for (int y = 0; y < yGrid + 1; ++y)//注意,这里不适用等号,是为了让代码更清晰,如果读者对这个过程比较熟悉,可以简化
	{
		yOffset = -radius*cos(1.0f*y / halfCycle*__MATH_PI_);
		//前方 
		float zOffset = radius * sin(1.0f*y / halfCycle*__MATH_PI_);
		float   *Vertex = VertexData + (xGrid + 1)*y *(3+2);
		for (int x = 0; x < xGrid + 1; ++x)//注意,顶点数据和纹理坐标交叉存储
		{
			const int index = x *(3+2);
			Vertex[index] = width*x/xGrid;
			Vertex[index + 1]=yOffset;
			Vertex[index + 2] = zOffset;
			//注意png纹理的格式问题
			Vertex[index + 3] = 1.0*x/xGrid;
			Vertex[index + 4] = 1.0 - 1.0*y / yGrid;
		}
	}
	//产生顶点索引对象
	int  indexCount = xGrid*yGrid*6;
	int  *indexVertx = new int[indexCount];
	for (int i = 0; i < yGrid; ++i)
	{
		for (int j = 0; j < xGrid; ++j)
		{
			const int index = (i * xGrid+j)*6;
			//两个三角形
			indexVertx[index ] = (i+1)*(xGrid+1)+j;
			indexVertx[index + 1] = i*(xGrid + 1) + j;
			indexVertx[index + 2] = (i + 1)*(xGrid + 1) + j+1;

			indexVertx[index + 3] = (i+1)*(xGrid+1)+j+1;
			indexVertx[index + 4] = i*(xGrid+1)+j;
			indexVertx[index + 5] = i*(xGrid+1)+j+1;
		}
	}
	//生成OpenGL顶点缓冲区对象
	int  defaultVertexId, defaultVertexIndexId;
	glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &defaultVertexId);
	glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &defaultVertexIndexId);
	glGenBuffers(1, &_vVertexId);
	glBindBuffer(GL_ARRAY_BUFFER, _vVertexId);
	glBufferData(GL_ARRAY_BUFFER, totalCount*sizeof(float)* 5, VertexData, GL_STATIC_DRAW);

	glGenBuffers(1, &_vVertexIndexId);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _vVertexIndexId);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexCount*sizeof(int), indexVertx, GL_STATIC_DRAW);

	glBindBuffer(GL_ARRAY_BUFFER, defaultVertexId);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, defaultVertexIndexId);
	//记录下顶点,索引的数目
	_vVertexCount = totalCount;
	_vVertexIndexCount = indexCount;
	delete VertexData;
	delete indexVertx;
}
MeshCycle *MeshCycle::createMeshCycle(float width, float radius, int xGrid, int yGrid)
{
	MeshCycle  *_Cycle = new MeshCycle();
	_Cycle->initMeshCycle(width, radius, xGrid, yGrid);
	return _Cycle;
}
//draw Cycle
void   MeshCycle::drawMeshCycle(int _VertexLoc,int _FragCoordLoc)
{
	int _defaultBufferId, _defaultIndexBufferId;
	glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &_defaultBufferId);
	glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &_defaultIndexBufferId);

	glBindBuffer(GL_ARRAY_BUFFER, _vVertexId);
	glEnableVertexAttribArray(_VertexLoc);
	glVertexAttribPointer(_VertexLoc, 3, GL_FLOAT, GL_FALSE, sizeof(float)* 5, NULL);
	glEnableVertexAttribArray(_FragCoordLoc);
	glVertexAttribPointer(_FragCoordLoc, 2, GL_FLOAT, GL_FALSE, sizeof(float)* 5, (void *)(sizeof(float)*3));

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,_vVertexIndexId);
	glDrawElements(GL_TRIANGLES, _vVertexIndexCount, GL_UNSIGNED_INT, NULL);
	//resume
	glBindBuffer(GL_ARRAY_BUFFER, _defaultBufferId);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _defaultIndexBufferId);
	CHECK_GL_ERROR_DEBUG();
}
SpriteCycle::SpriteCycle()
{
	_nowAngle = 0;
	_cycleTexture = NULL;
	_meshCycle = NULL;
	_glProgram = NULL;
}
SpriteCycle::~SpriteCycle()
{
	_cycleTexture->release();
	_meshCycle->release();
	_glProgram->release();
}
void  SpriteCycle::initWithCycle(std::string &fileName)
{
	//拘留
	_cycleTexture = cocos2d::Director::getInstance()->getTextureCache()->addImage(fileName);
	_cycleTexture->retain();
	//网格对象
	cocos2d::Size _size = _cycleTexture->getContentSize();
	//计算半径
	_cycleRadius = _size.height / (2.0f*__MATH_PI_);
	_meshCycle = MeshCycle::createMeshCycle(_size.width, _cycleRadius, 4, 64);
	//Create GLProgram
	//注意在实际使用的过程中,最好使用Shader缓存,因为这里是为了演示,所以没有使用
	_glProgram = cocos2d::GLProgram::createWithByteArrays(CycleVertexShader, CycleFragShader);
	_glProgram->retain();
	_modelViewLoc = _glProgram->getUniformLocation("u_modelViewMatrix");
	_rotateLoc = _glProgram->getUniformLocation("u_rotateMatrix");
	_projLoc = _glProgram->getUniformLocation("u_projMatrix");
	_textureLoc = _glProgram->getUniformLocation("CCTexture");

	_positionLoc = _glProgram->getAttribLocation("a_position");
	_fragCoordLoc = _glProgram->getAttribLocation("a_fragCoord");
}
SpriteCycle *SpriteCycle::createWithCycle(std::string &fileName)
{
	SpriteCycle *_cycle = new SpriteCycle();
	_cycle->initWithCycle(fileName);
	return _cycle;
}
//draw function
void SpriteCycle::drawMeshCycle( cocos2d::Mat4 &modelView, uint32_t flag)
{
	Matrix     _identity;
	_identity.rotate(_nowAngle + __ANGLE_BASE_, 1.0f, 0.0f, 0.0f);
	//注意需要累加上自己的位置,并且需要开启深度测试,还有背面剔除
	int   _isOpenDepthTest = glIsEnabled(GL_DEPTH_TEST);
	if (!_isOpenDepthTest)
		glEnable(GL_DEPTH_TEST);
	//开启背面剔除
	int _isCullFace = glIsEnabled(GL_CULL_FACE);
	if (!_isCullFace)
		glEnable(GL_CULL_FACE);
	cocos2d::Point _nowPoint = this->getPosition();
	_identity.translate(_nowPoint.x, _nowPoint.y, 0);
	int _default_textureId;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &_default_textureId);
//	int defaultObject;
//	glGetIntegerv(GL_CURRENT_PROGRAM, &defaultObject);
	_glProgram->use();

	glUniformMatrix4fv(_modelViewLoc, 1, GL_FALSE, modelView.m);
	glUniformMatrix4fv(_rotateLoc, 1, GL_FALSE, _identity.pointer());
	//投影矩阵
	const cocos2d::Mat4 &_projMatrix = cocos2d::Director::getInstance()->getMatrix(cocos2d::MATRIX_STACK_TYPE::MATRIX_STACK_PROJECTION);
	glUniformMatrix4fv(_projLoc, 1, GL_FALSE, _projMatrix.m);

	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, _cycleTexture->getName());
	glUniform1i(_textureLoc, 0);

	_meshCycle->drawMeshCycle(_positionLoc, _fragCoordLoc);
	CHECK_GL_ERROR_DEBUG();
	glBindTexture(GL_TEXTURE_2D, _default_textureId);
	if (!_isOpenDepthTest)
		glDisable(GL_DEPTH_TEST);
	if (!_isCullFace)
		glDisable(GL_CULL_FACE);
}
//
void SpriteCycle::setAngle(float angle)
{
	_nowAngle = angle;
}

float SpriteCycle::getCycleRadius()
{
	return _cycleRadius;
}

float SpriteCycle::getOriginAngle()
{
	return _nowAngle;
}

int  SpriteCycle::getOriginDigit()
{
	int nowAngle = (int)_nowAngle % 360;
	return nowAngle *10/ 360 ;
}

void SpriteCycle::setOriginDigit(int digit)
{
	assert(digit>=0 && digit<10);
	//计算所需要的角度
	_nowAngle = digit * 360 / 10;
}
void SpriteCycle::visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& transform, uint32_t flags)
{
	if (!_visible)
		return;
	_drawCycleCommand.func = CC_CALLBACK_0(SpriteCycle::drawMeshCycle, this, transform, flags);
	_drawCycleCommand.init(_globalZOrder);
	renderer->addCommand(&_drawCycleCommand);
	Node::visit(renderer, transform, flags);
}