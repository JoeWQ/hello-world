/*
  *���͵��ε���Ⱦ
  *2017-06-07
  *@Author:xiaohuaxiong
  *@Version:1.0 ʵ����������ĵ�����Ⱦ,�ڴ˰汾�����е����ݵ�ʹ�ö�����ԭ��ģ��, ����һ���汾��,���ǽ�ʹ���Ĳ����Ե��ε���Ⱦ�ֿ�,�Ż�
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
	//ģ�;���
	glk::Matrix             _modelMatrix;
	//��ͼ����
	glk::Matrix             _viewMatrix;
	//ͶӰ����
	glk::Matrix             _projMatrix;
	//��ͼͶӰ����
	glk::Matrix             _viewProjMatrix;
	//���ߵķ���,���뵥λ��
	glk::GLVector3       _lightDirection;
	//���ߵ���ɫ
	glk::GLVector4       _lightColor;
	//����ͶӰ�������ת������ƽ������
	glk::GLVector3       _rotateVec;
	glk::GLVector3       _translateVec;
	//�����¼�,�Ժ����
	glk::KeyEventListener      *_keyListener;
	//�����¼�,�Ժ����
	glk::TouchEventListener  *_touchListener;
	//���㻺��������
	unsigned              _terrainVertexId;
	//��������������
	unsigned              _terrainIndexId;
	//���εĸ߶ȳ�����
	float                     *_heightField;
	//���εĿ��(�߶ȺͿ�����)
	int                       _terrainSize;
	//��¼���ε������С�߽�ֵ
	glk::GLVector3  _boundaryMin;
	glk::GLVector3  _boundaryMax;
private:
	Terrain();
	Terrain(Terrain &);
	/*
	  *���ض������ļ�
	*/
	void                     initWithFile(const std::string &filename);
public:
	~Terrain();
	//ʹ�ø��������ļ�����
	static Terrain   *createTerrainWithFile(const std::string  &filename);
	//ʹ��ͼƬ�ļ����ص���
	static Terrain   *createTerrainWithTexture(glk::GLTexture *hightTexture);
	/*
	  *������ͼ��λ��,��ȡ��߳�ֵ
	 */
	inline  float        getHeightValue(int x,int z)const;
	/*
	  *����һ����ͼ����,��ȡ��ƽ���ĸ߳�ֵ
	 */
	 float         getHeightValueSmooth(float x,float z)const;
	/*
	  *������ͼ����,���������ڴ��е�ʵ������
	*/
	inline int            getRealIndex(int x,int z)const;
	/*
	  *��ʼ����ͼͶӰ��������
	 */
	void                     initCamera(const glk::GLVector3 &eyePosition,const glk::GLVector3 &targetPosition);
	//ʵʱ���»ص�����
	void                     update(const float deltaTime);
	//��Ⱦ
	void                     render();
	//�����¼�,�����¼�
};
#endif