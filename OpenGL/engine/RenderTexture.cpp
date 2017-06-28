/*
  *RTT实现,
  *@date:2017-6-27
  *@Author:xiaohuaxiong
*/
#include "GL/glew.h"
#include "engine/RenderTexture.h"
#include<assert.h>
__NS_GLK_BEGIN

RenderTexture::RenderTexture()
{
	_framebufferId = 0;
	_colorbufferId = 0;
	_depthbufferId = 0;
	_stencilbufferId = 0;
	_lastFramebufferId = 0;
	_isRestoreLastFramebuffer = true;
	_isNeedClearBuffer = true;
}

RenderTexture::~RenderTexture()
{
	if (_framebufferId)
		glDeleteFramebuffers(1,&_framebufferId);
	if (_colorbufferId)
		glDeleteTextures(1, &_colorbufferId);
	if (_depthbufferId)
		glDeleteTextures(1, &_depthbufferId);
	if (_stencilbufferId)
		glDeleteTextures(1, &_stencilbufferId);
}

RenderTexture *RenderTexture::createRenderTexture(const Size &frameSize, unsigned genType)
{
	RenderTexture *render = new RenderTexture();
	if (!render->initWithRender(frameSize, genType))
	{
		render->release();
		render = nullptr;
	}
	return render;
}

bool RenderTexture::initWithRender(const Size &frameSize, unsigned genType)
{
	_frameSize = frameSize;
	assert(frameSize.width>0 && frameSize.height>0);
	int defaultFramebufferId,colorbufferId;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &defaultFramebufferId);
	if(genType)
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &colorbufferId);
	
	glGenFramebuffers(1, &_framebufferId);
	glBindFramebuffer(GL_FRAMEBUFFER, _framebufferId);
	//颜色
	if (genType & RenderType::ColorBuffer)
	{
		glGenTextures(1, &_colorbufferId);
		glBindTexture(GL_TEXTURE_2D, _colorbufferId);
		glTexStorage2D(GL_TEXTURE_2D, 1, GL_RGBA8, frameSize.width, frameSize.height);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _colorbufferId, 0);
	}
	if (genType & RenderType::DepthBuffer)
	{
		glGenTextures(1, &_depthbufferId);
		glBindTexture(GL_TEXTURE_2D, _depthbufferId);
		glTexStorage2D(GL_TEXTURE_2D, 1, GL_DEPTH_COMPONENT32F, frameSize.width, frameSize.height);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, _depthbufferId, 0);
	}
	if (genType & RenderType::StencilBuffer)
	{
		glGenTextures(1, &_stencilbufferId);
		glBindTexture(GL_TEXTURE_2D, _stencilbufferId);
		glTexStorage2D(GL_TEXTURE_2D, 1, GL_STENCIL_COMPONENTS, frameSize.width, frameSize.height);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glFramebufferTexture2D(GL_TEXTURE_2D, GL_STENCIL_COMPONENTS, GL_TEXTURE_2D, _stencilbufferId, 0);
	}
	glDrawBuffer(GL_COLOR_ATTACHMENT0);
	//检查帧缓冲区对象的完整性
	const int status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	assert(status == GL_FRAMEBUFFER_COMPLETE);
	//restore
	if (genType)
		glBindTexture(GL_TEXTURE_2D, colorbufferId);
	glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebufferId);
	return status == GL_FRAMEBUFFER_COMPLETE;
}

void RenderTexture::activeFramebuffer()
{
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_lastFramebufferId);
	glBindFramebuffer(GL_FRAMEBUFFER, _framebufferId);
	if (_isNeedClearBuffer)
	{
		int flag = 0;
		if (_colorbufferId)
			flag |= GL_COLOR_BUFFER_BIT;
		if (_depthbufferId)
			flag |= GL_DEPTH_BUFFER_BIT;
		if (_stencilbufferId)
			flag |= GL_STENCIL_BUFFER_BIT;
		glClear(flag);
	}
}

void RenderTexture::disableFramebuffer()const
{
	if (_isRestoreLastFramebuffer)
		glBindFramebuffer(GL_FRAMEBUFFER, _lastFramebufferId);
}

void RenderTexture::setRestoreLastFramebuffer(bool b)
{
	_isRestoreLastFramebuffer = b;
}

bool RenderTexture::isRestoreLastFramebuffer()const
{
	return _isRestoreLastFramebuffer;
}

void RenderTexture::setClearBuffer(bool b)
{
	_isNeedClearBuffer = b;
}

bool RenderTexture::isClearBuffer()const
{
	return _isNeedClearBuffer;
}

unsigned RenderTexture::getColorBuffer()const
{
	return _colorbufferId;
}

unsigned RenderTexture::getDepthBuffer()const
{
	return _depthbufferId;
}

__NS_GLK_END