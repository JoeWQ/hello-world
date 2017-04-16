/*
  *�����Ӱʵ��
  *Cascade Shadow Map
  *@date:2017-4-8
  *@author:xiaohuaxiong
 */
#ifndef __CASCADE_SHADOW_MAP_H__
#define __CASCADE_SHADOW_MAP_H__
#include<engine/Object.h>
#include<engine/Shape.h>
#include<engine/GLTexture.h>
#include<engine/ShadowMap.h>
#include"LightShader.h"
#include"CameraShader.h"
class  CascadeShadowMap :public glk::Object
{
private:
	//�ӿ�
	glk::GLVector4		_viewport[4];
	//��ռ���ͼͶӰ����ƫ�ƾ���
	glk::Matrix            _lightVPSBMatrix[4];
	//ͶӰ����
	glk::Matrix            _projMatrix;
	//��Դ��ͼ����
	glk::Matrix             _lightViewMatrix;
	//��Դ��ͶӰ����
	glk::Matrix             _lightProjMatrix;
	//��Դ��ͼͶӰ����
	//glk::Matrix             _lightViewProjMatrix;
	//��Դ�ķ���
	glk::GLVector3       _lightDirection;
	//�۾�������
	glk::GLVector3        _eyePosition;
	//������ӽ��µ���ͼ����
	glk::Matrix             _cameraViewMatrix;
	//������ӽ��µ���ͼͶӰ����
	glk::Matrix             _cameraViewPorjMatrix;
	//�淶����Զƽ��ָ�
	glk::GLVector4		_normalSegments;
	//�ָ��Զƽ��(�ǹ淶��)
	float                        _farSegemtns[5];
	//Զƽ��,��ƽ�����
	float                        _nearZ, _farZ;
	//Shader
	LightShader		   *_lightShader;
	CameraShader      *_cameraShader;
	//ƽ���������
	glk::Mesh               *_groundMesh;
	//��ά����
	glk::Sphere            *_sphere;
	//����
	glk::GLTexture      *_groundTexture;
	glk::GLTexture      *_sphereTexture;
	//CSM��Ӱ��ͼ����
	glk::ShadowMap   *_csmShadowArray;
private:
	CascadeShadowMap(CascadeShadowMap &);
	CascadeShadowMap();
	void         initCascadeShadowMap();
public:
	~CascadeShadowMap();
	static CascadeShadowMap *createCascadeShadowMap();
	/*
	  *��ʼ�������
	 */
	void           initCamera(const glk::GLVector3 &eyePosition,const glk::GLVector3 &viewPosition,const glk::GLVector3 &upVector);
	/*
	  *��ʼ����Դ
	 */
	void           initLight(const glk::GLVector3 &lightPosition,const glk::GLVector3 &lightViewPosition,const glk::GLVector3 &upVector);
	/*
	  *������׶��ָ�ƽ��
	*/
	void           updateFrustumSegment();
	/*
	  *�������Դ��ص�Զƽ��ָ�,�Լ����ָ����׶��
	 */
	void           updateLightViewFrustum();
	/*
	  *�����Դ�ӽ��µ��ɸ���Զ��ƽ������İ�Χ�еĴ�С
	 */
	void           frustumBoudingboxInLightSpaceView(const float nearZ,const float farZ,glk::GLVector4 &boxMin,glk::GLVector4 &boxMax);
	/*
	  *��Ⱦ��Դ�ӽ��µĳ���
	 */
	void           renderLightView( );
	/*
	  *��Ⱦ������ӽ��µĳ���
	 */
	void           renderCameraView();
	/*
	  *������CSM��ص�����
	 */
	void           update(const float deltaTime);
};

#endif