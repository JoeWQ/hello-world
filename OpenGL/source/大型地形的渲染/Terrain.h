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
	float                     _heightField;
	//地形的宽度(高度和宽度相等)
	int                       _terrainSize;
private:
	Terrain();
	Terrain(Terrain &);
	void                     initWithFile(const std::string &filename);
public:
	~Terrain();
	//使用给定地形文件计算
	static Terrain   *createTerrainWithFile(const std::string  &filename);
	//使用图片文件加载地形
	static Terrain   *createTerrainWithTexture(glk::GLTexture *hightTexture);
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