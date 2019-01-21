/*
  *深度范围分布图形显示
  *2017年11月24日
  *@Author:xiaohuaxiong
 */
#ifndef __DEPTH_DISTRIBUTE_H__
#define __DEPTH_DISTRIBUTE_H__
#include "cocos2d.h"

class DepthDistribute :public cocos2d::Node
{
	float                               _nearZ, _farZ;
	cocos2d::Vec2              *_vertexData;
	int                                  _vertexCount;
	cocos2d::GLProgram  *_pointProgram;
	cocos2d::CustomCommand _drawPointCommand;
	int                                   _positionLoc,_colorLoc;
	unsigned                        _vertexId;
	cocos2d::Vec4               _color;
private:
	DepthDistribute();
	DepthDistribute(const DepthDistribute &);
	void                updateVertex();
public:
	~DepthDistribute();
	static DepthDistribute *create(float nearZ,float farZ);
	void     initWithNearFar(float nearZ,float farZ);
	void     setNearZ(float nearZ);
	void     setFarZ(float   farZ);
	void     setNearFarZ(float nearZ,float farZ);
	void               drawMesh();
	void               drawPoint(const cocos2d::Mat4 &transform,uint32_t flag);
	virtual void   draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& transform, uint32_t flags);
	void   setColor(const cocos2d::Vec4 &color);
};
#endif