/*
  *视锥体深度范围分布图
  *@2017/11/24
  *@Author:xiaohuaxiong
 */
#include "DepthDistribute.h"
#include "common/Common.h"
#include "component/DrawNode3D.h"
USING_NS_CC;
DepthDistribute::DepthDistribute():
	_nearZ(0.1f)
	,_farZ(100.0f)
	,_vertexCount(0)
	,_pointProgram(nullptr)
	, _positionLoc(-1)
	, _vertexId(0)
	, _vertexData(nullptr)
{

}

DepthDistribute::~DepthDistribute()
{
	if (_pointProgram)
		_pointProgram->release();
	_pointProgram = nullptr;
	if (_vertexId)
		glDeleteBuffers(1,&_vertexId);
	if (_vertexData)
		delete[] _vertexData;
	_vertexData = nullptr;
}

DepthDistribute  *DepthDistribute::create(float nearZ, float farZ)
{
	DepthDistribute *depthCanvas = new DepthDistribute();
	depthCanvas->initWithNearFar(nearZ, farZ);
	depthCanvas->autorelease();
	return depthCanvas;
}

void DepthDistribute::initWithNearFar(float nearZ, float farZ)
{
	Node::init();
	_pointProgram = GLProgram::createWithByteArrays(Shader_VS_Point_No_Texture,Shader_FS_Point_No_Texture);
	_pointProgram->retain();
	_positionLoc = _pointProgram->getAttribLocation("a_position");
	_colorLoc = _pointProgram->getUniformLocation("u_color");
	_nearZ = nearZ;
	_farZ = farZ;
	CCASSERT(nearZ>0 && farZ >nearZ,"it must be nearZ >0 && farZ >nearZ");
	updateVertex();
	setColor(Vec4(1,1,1,1));
	drawMesh();
}

void DepthDistribute::draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& transform, uint32_t flags)
{
	_drawPointCommand.init(_globalZOrder);
	_drawPointCommand.func = CC_CALLBACK_0(DepthDistribute::drawPoint,this,transform,flags);
	renderer->addCommand(&_drawPointCommand);
}

void DepthDistribute::drawMesh()
{
	DrawNode *drawNode = DrawNode::create();
	//
	auto &winSize = _director->getWinSize();
	for (int i = 0; i < 9; ++i)
	{
		float x = winSize.width/10 *(i+1);
		float f = 1-0.5f*x/winSize.width;
		drawNode->drawLine(Vec2(x,0),Vec2(x,winSize.height),Color4F(f,0.5f,f,1));
	}
	for (int j = 0; j < 9; ++j)
	{
		float y = winSize.height/10 *(j+1);
		float f = 1-0.5f*y/winSize.height;
		drawNode->drawLine(Vec2(0,y),Vec2(winSize.width,y),Color4F(f,0.5f,f,1));
	}
	this->addChild(drawNode);
}

void DepthDistribute::drawPoint(const cocos2d::Mat4 &transform, uint32_t flag)
{
	_pointProgram->use();
	_pointProgram->setUniformsForBuiltins(transform);

	glBindBuffer(GL_ARRAY_BUFFER,_vertexId);

	glEnableVertexAttribArray(_positionLoc);
	glVertexAttribPointer(_positionLoc,2,GL_FLOAT,GL_FALSE,0,nullptr);

	glUniform4fv(_colorLoc,1,&_color.x);
	glEnable(GL_POINT_SPRITE);
	glEnable(GL_VERTEX_PROGRAM_POINT_SIZE);
	glDrawArrays(GL_POINTS, 0, _vertexCount);

	glBindBuffer(GL_ARRAY_BUFFER,0);
}

void DepthDistribute::updateVertex()
{
	auto &winSize = _director->getWinSize();
	if (!_vertexId)
	{
		_vertexCount = winSize.width +1;
		glGenBuffers(1,&_vertexId);
		glBindBuffer(GL_ARRAY_BUFFER, _vertexId);
		glBufferData(GL_ARRAY_BUFFER,sizeof(Vec2)*_vertexCount,nullptr,GL_DYNAMIC_DRAW);
	}
	else
		glBindBuffer(GL_ARRAY_BUFFER, _vertexId);
	//生成顶点数据,分布图以左下角为准
	float D = _farZ - _nearZ;
	float C =  (_nearZ+_farZ)/ D;
	float A = 2.0f*_nearZ * _farZ/ D;
	//
	if (_vertexData)
		delete[] _vertexData;
	_vertexData = new cocos2d::Vec2[_vertexCount];
	for (int k = 0; k < _vertexCount; ++k)
	{
		float Z = -(_nearZ +  k /winSize.width * D);
		float depth = A / Z + C;
		_vertexData[k] = Vec2(
			k,
		  winSize.height * (1 -   depth *0.5f -0.5f)
		);
	}
	glBufferSubData(GL_ARRAY_BUFFER,0,sizeof(Vec2)*_vertexCount,_vertexData);
	glBindBuffer(GL_ARRAY_BUFFER,0);
}

void DepthDistribute::setNearZ(float nearZ)
{
	if (_nearZ != nearZ)
	{
		_nearZ = nearZ;
		updateVertex();
	}
}

void DepthDistribute::setFarZ(float farZ)
{
	if (_farZ != farZ)
	{
		_farZ = farZ;
		updateVertex();
	}
}

void DepthDistribute::setNearFarZ(float nearZ, float farZ)
{
	if (_nearZ != nearZ || _farZ != farZ)
	{
		_nearZ = nearZ;
		_farZ = farZ;
		updateVertex();
	}
}

void DepthDistribute::setColor(const cocos2d::Vec4 &color)
{
	_color = color;
}

