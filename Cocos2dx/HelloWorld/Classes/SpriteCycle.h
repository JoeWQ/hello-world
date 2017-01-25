//循环精灵,以3D的形式展现
//2017-1-21 11:48:56
#ifndef __SPRITE_CYCLE_H__
#define __SPRITE_CYCLE_H__
#include"cocos2d.h"
//Vertex Shader
//空间3D圆环对象
//注意在使用的的时候最好能加上一个缓存
class  MeshCycle:public cocos2d::Ref
{
	unsigned _vVertexId;//顶点缓存对象
	unsigned _vVertexIndexId;//顶点索引对象
	int            _vVertexCount;//顶点的数目
	int            _vVertexIndexCount;//顶点索引的数目
public:
	MeshCycle();
	~MeshCycle();
	//param:width圆环的宽度
	//param:radius:圆环的半径
	//param:xGrid希望将圆环在横向细分的网格数目
	//param,yGrid希望将圆环在纵向细分的网格的数目,yGrid一定为一个奇数
	static MeshCycle *createMeshCycle(float width,float radius,int xGrid,int yGrid);
	void initMeshCycle(float width,float radius,int xGrid,int yGrid);
	void   drawMeshCycle(int ,int );
};
//再使用的时候,注意传入的图的格式一定为从下到上为0123456789
//并且图的高度一定要为10的整倍数,否则会出现计算的不精确
class  SpriteCycle :public cocos2d::Node
{
	cocos2d::Texture2D	  *_cycleTexture;
	MeshCycle		*_meshCycle;
	cocos2d::GLProgram  *_glProgram;
//3d坐标,最终将映射到2D坐标上,并且精灵的锚点始终在左下角
	cocos2d::Vec3               _cyclePsotion;
	//当前角度
	//当前唤醒精灵的角度,以绕X轴的正方向计算,注意,任何调用修改角度的函数,都必须将_cycleAngle的值设置为精确的指向一个数字
	//
	float                                _nowAngle;
	float                                _cycleRadius;
	//统一变量的位置
	unsigned					_modelViewLoc;
	unsigned                 _rotateLoc;
	unsigned                 _projLoc;
	unsigned                 _textureLoc;
	//属性变量位置
	unsigned                 _positionLoc;
	unsigned                 _fragCoordLoc;
	cocos2d::CustomCommand   _drawCycleCommand;
	SpriteCycle();
public:
	~SpriteCycle();
	void initWithCycle(std::string  &);
	static SpriteCycle		*createWithCycle(std::string &);
	void updateCycleWithAngle(float angle);
	//设置角度,之一因为绕X轴旋转,会使得抓动的方向从上到下,看起来是顺时针的
	//但是按照OpenGL的空间坐标系,实际上是逆时针的
	void setAngle(float angle);
	//将当前的显示设置到数字digit
	void setOriginDigit(int digit);
	float getOriginAngle();
	float getCycleRadius();//返回环的半径
	int    getOriginDigit();//返回当前环所在的数字,也就是正面向观察者的数字
	void drawMeshCycle(cocos2d::Mat4 &modelView,uint32_t flag);
	virtual void visit(cocos2d::Renderer *renderer, const cocos2d::Mat4 &parentTransform, uint32_t parentFlags);
};
#endif