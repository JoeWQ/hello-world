/*
  *���͵��ε���Ⱦ
  *@date:2017-6-8
  *@Author:xiaohuaxiong
  *@Version 1.0:ʵ����������ĵ�����Ⱦ
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