/*
  *阴影贴图.也包括了CSM实现的一部分,原来的文件被误删了，目前的版本是重新实现的
  *@date:2017-4-10
  *@author:xiaohuaxiong
 */
#ifndef __SHADOW_MAP_H__
#define __SHADOW_MAP_H__
#include<engine/Object.h>
#include<engine/Geometry.h>
//#include<engine/GLProgram.h>
__NS_GLK_BEGIN
class ShadowMap :public Object
{
private:
	unsigned        _framebufferId;
	unsigned        _depthTextureId;
	//旧的缓冲区对象,用于在帧缓冲区对象切换的时候使用
	int					 _oldFramebufferId;
	//深度纹理是否是层渲染对象,当这个标志置为true的时候，表示的是CSM功能
	bool					_isDepthLayerArray;
	int                   _numberOfLayer;//如果_isDepthLayerArray为true,此域代表层的数目,否则该域的值始终为0
	Size                 _shadowMapSize;
private:
	ShadowMap(ShadowMap &);
	ShadowMap();
	bool		initWithMapSize(const Size &mapSize);
	/*
	  @param:mapSize表示的是阴影贴图的尺寸
	  @param:numberOfLayer表示的是深度纹理层的数目
	 */
	bool     initWithMapLayer(const Size &mapSize,const int numberOfLayer);
public:
	~ShadowMap();
	static ShadowMap  *createWithMapSize(const Size &mapSize);
	/*
	  *@param:mapSize表示的是阴影贴图的尺寸
	  @param:numberOfLayer表示的是深度纹理层的数目
	  @note:如果创建失败的话,将返回一个空指针
	 */
	static ShadowMap  *createWithMapLayer(const Size &mapSize,const int numberOfLayer);
	//获取深度纹理,此纹理也可能是一个层叠的纹理
	const unsigned getDepthTexture()const;
	//是否是层叠深度纹理
	const bool   isDepthArrayLayer()const;
	//获取阴影贴图的尺寸
	const Size&   getMapSize()const;
	//获取阴影贴图的层的数目
	const int     getMapLayer()const;
	
	//激活当前的缓冲区对象,同时保存原来的帧缓冲区对象
	void   activeShadowFramebuffer();
	//恢复原来的缓冲区对象
	void   restoreFramebuffer();
};

__NS_GLK_END
#endif