/*
  *��Ⱦ������,����֡�����������Լ��丽��
  *ע��,����ֻ��������ͨ��Ⱦ��������,��������MRT,Deffer shader
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
	//����֡����������ļ�����־,����ʹ�� | ���������
	enum RenderType
	{
		ColorBuffer = 0x1,//��Ҫ��ɫ������
		DepthBuffer = 0x2,//��Ҫ��Ȼ�����
		StencilBuffer = 0x4,//��Ҫģ�建����
		TotalBuffer = ColorBuffer | DepthBuffer | StencilBuffer,//ʹ�����еĻ�����
	};
private:
	unsigned      _framebufferId;//֡����������
	unsigned      _colorbufferId;//��ɫ����������
	unsigned      _depthbufferId;//��Ȼ���������
	unsigned      _stencilbufferId;//ģ�建��������
	int			      _lastFramebufferId;
	Size               _frameSize;//֡�����������С
	bool              _isRestoreLastFramebuffer;//�ڽ�����ǰ�������İ󶨵�ʱ��,�Ƿ���Ҫ��ԭ��ԭ���Ļ�������
	bool              _isNeedClearBuffer;//�Ƿ���Ҫ��ʹ�õ�ǰ֡�����������ʱ��ͬʱ�����ɫ,���,ģ�建����,������˵Ļ�
private:
	bool             initWithRender(const Size &frameSize,unsigned  genType,const int *formatTable);
	bool             initWithRender(const Size &frameSize, unsigned  genType);
	RenderTexture();
	RenderTexture(RenderTexture &);
public:
	~RenderTexture();
	/*
	  *����֡����������,��Ҫ�����������Ĵ�С,�����ı�־
	  *��ҪRenderTypeö������
	 */
	static RenderTexture *createRenderTexture(const Size &frameSize,unsigned genType);
	/*
	  *�Ը����ĸ�ʽ����֡����������,formatTable�ĳ�����genType����������������Ӧ
	  *����˳������ɫ,���,ģ���˳���趨,���ĳһ��������û��,����Ľ����Ÿ���
	 */
	static RenderTexture *createRenderTexture(const Size &frameSize, unsigned genType,const int *formatTable);
	/*
	  *�л�����ǰ�Ļ���������,��ǰ������������¼�ϴε�֡�����������ʹ�� ���
	 */
	void    activeFramebuffer();
	/*
	  *��ֹ��ǰ֡��������
	 */
	void    disableFramebuffer()const;
	/*
	  *�����Ƿ���Ҫ��ԭ��ǰ�Ļ����������
	 */
	void    setRestoreLastFramebuffer(bool isRestore);
	/*
	  *�����Ƿ���Ҫ��ԭ��ǰ��֡����������
	 */
	bool   isRestoreLastFramebuffer()const;
	/*
	  *�Ƿ���Ҫ�ڰ󶨵�ǰ�����������ʱ�������صĻ�����
	 */
	void   setClearBuffer(bool b);
	/*
	  *�����Ƿ��ڰ󶨵�ǰ�����������ʱ��ͬʱ�������������
	 */
	bool isClearBuffer()const;
	/*
	  *���ص�ǰ����ɫ����������,ע�������ʹ����û��������صı�־,����ֵ��Ϊ0
	 */
	unsigned getColorBuffer()const;
	/*
	  *������Ȼ���������
	 */
	unsigned getDepthBuffer()const;
};
__NS_GLK_END
#endif