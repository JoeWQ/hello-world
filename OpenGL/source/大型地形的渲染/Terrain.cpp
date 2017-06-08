/*
  *大型地形的渲染
  *@date:2017-6-8
  *@Author:xiaohuaxiong
  *@Version 1.0:实现了最基本的地形渲染
 */
#include "Terrain.h"

Terrain::Terrain()
{
	_terrainShader = nullptr;
}

Terrain::~Terrain()
{
	delete _terrainShader;
	_terrainShader = nullptr;
}