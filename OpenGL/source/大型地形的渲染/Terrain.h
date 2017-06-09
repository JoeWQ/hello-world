/*
  *大型地形的渲染
  *2017-06-07
  *@Author:xiaohuaxiong
  *@Version:1.0 实现了最基本的地形渲染,在此版本中所有的数据的使用都保持原本模样, 在下一个版本中,我们将使用四叉树对地形的渲染分块,优化
  *@Version:2.0 
*/
#ifndef __TERRAIN_H__
#define __TERRAIN_H__
#include "engine/GLState.h"
#include "engine/Object.h"
#include "engine/GLTexture.h"
#include "engine/event/EventManager.h"
#include "TerrainShader.h"
#include<string>
class Terrain :public glk::Object
{
private:
	TerrainShader      *_terrainShader;
	//模型矩阵
	glk::Matrix             _modelMatrix;
	//视图矩阵
	glk::Matrix             _viewMatrix;
	//投影矩阵
	glk::Matrix             _projMatrix;
	//视图投影矩阵
	glk::Matrix             _viewProjMatrix;
	//光线的方向,必须单位化
	glk::GLVector3       _lightDirection;
	//光线的颜色
	glk::GLVector4       _lightColor;
	//关于投影矩阵的旋转向量和平移向量
	glk::GLVector3       _rotateVec;
	glk::GLVector3       _translateVec;
	//键盘事件,以后添加
	glk::KeyEventListener      *_keyListener;
	//触屏事件,以后添加
	glk::TouchEventListener  *_touchListener;
	//顶点缓冲区对象
	unsigned              _terrainVertexId;
	//索引缓冲区对象
	unsigned              _terrainIndexId;
	//地形的高度场数据
	float                     *_heightField;
	//地形的宽度(高度和宽度相等)
	int                       _terrainSize;
	//记录地形的最大最小边界值
	glk::GLVector3  _boundaryMin;
	glk::GLVector3  _boundaryMax;
private:
	Terrain();
	Terrain(Terrain &);
	/*
	  *加载二进制文件
	*/
	void                     initWithFile(const std::string &filename);
public:
	~Terrain();
	//使用给定地形文件计算
	static Terrain   *createTerrainWithFile(const std::string  &filename);
	//使用图片文件加载地形
	static Terrain   *createTerrainWithTexture(glk::GLTexture *hightTexture);
	/*
	  *给定地图的位置,获取其高程值
	 */
	inline  float        getHeightValue(int x,int z)const;
	/*
	  *给定一个地图坐标,获取其平滑的高程值
	 */
	 float         getHeightValueSmooth(float x,float z)const;
	/*
	  *给定地图坐标,计算其在内存中的实际索引
	*/
	inline int            getRealIndex(int x,int z)const;
	/*
	  *初始化视图投影矩阵数据
	 */
	void                     initCamera(const glk::GLVector3 &eyePosition,const glk::GLVector3 &targetPosition);
	//实时更新回调函数
	void                     update(const float deltaTime);
	//渲染
	void                     render();
	//键盘事件,触屏事件
};
#endif