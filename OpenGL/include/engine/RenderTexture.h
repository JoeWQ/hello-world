/*
  *渲染到纹理,创建帧缓冲区对象以及其附着
  *注意,此类只能用于普通渲染到纹理功能,不能用于MRT,Deffer shader
  *@date:2017-06-27
  *@Author:xiaohuaxiong
 */
#ifndef __RENDER_TENTURE_H__
#define __RENDER_TEXTURE_H__
#include "engine/GLState.h"
#include "engine/Object.h"
#include "engine/Geometry.h"
__NS_GLK_BEGIN
class RenderTexture :public glk::Object
{ 
public:
	//创建帧缓冲区对象的几个标志,可以使用 | 运算符连接
	enum RenderType
	{
		ColorBuffer = 0x1,//需要颜色缓冲区
		DepthBuffer = 0x2,//需要深度缓冲区
		StencilBuffer = 0x4,//需要模板缓冲区
		TotalBuffer = ColorBuffer | DepthBuffer | StencilBuffer,//使用所有的缓冲区
	};
private:
	unsigned      _framebufferId;//帧缓冲区对象
	unsigned      _colorbufferId;//颜色缓冲区对象
	unsigned      _depthbufferId;//深度缓冲区对象
	unsigned      _stencilbufferId;//模板缓冲区对象
	int			      _lastFramebufferId;
	Size               _frameSize;//帧缓冲区对象大小
	bool              _isRestoreLastFramebuffer;//在结束当前缓冲区的绑定的时候,是否需要还原到原来的缓冲区绑定
	bool              _isNeedClearBuffer;//是否需要在使用当前帧缓冲区对象的时候同时清除颜色,深度,模板缓冲区,如果绑定了的话
private:
	bool             initWithRender(const Size &frameSize,unsigned  genType);
	RenderTexture();
	RenderTexture(RenderTexture &);
public:
	~RenderTexture();
	/*
	  *创建帧缓冲区对象,需要参数缓冲区的大小,创建的标志
	  *需要RenderType枚举类型
	 */
	static RenderTexture *createRenderTexture(const Size &frameSize,unsigned genType);
	/*
	  *切换到当前的缓冲区对象,当前缓冲区对象会记录上次的帧缓冲区对象的使用 情况
	 */
	void    activeFramebuffer();
	/*
	  *禁止当前帧缓冲对象绑定
	 */
	void    disableFramebuffer()const;
	/*
	  *设置是否需要还原以前的缓冲区对象绑定
	 */
	void    setRestoreLastFramebuffer(bool isRestore);
	/*
	  *返回是否需要还原以前的帧缓冲区对象
	 */
	bool   isRestoreLastFramebuffer()const;
	/*
	  *是否需要在绑定当前缓冲区对象的时候清除相关的缓冲区
	 */
	void   setClearBuffer(bool b);
	/*
	  *返回是否在绑定当前缓冲区对象的时候同时清除缓冲区对象
	 */
	bool isClearBuffer()const;
	/*
	  *返回当前的颜色缓冲区对象,注此意如果使用者没有设置相关的标志,返回值将为0
	 */
	unsigned getColorBuffer()const;
	/*
	  *返回深度缓冲区对象
	 */
	unsigned getDepthBuffer()const;
};
__NS_GLK_END
#endif