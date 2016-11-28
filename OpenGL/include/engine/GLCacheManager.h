/*
*�������,������󻺴����
*2016-6-17 18:38:16
*version:1.0
*С����
  */
//Version 2.0:�����˳������,�����������ü���bug,�Լ������ٳ����˳�ʱ��������������bug
#ifndef  __GL_CACHE_MANAGER_H__
#define __GL_CACHE_MANAGER_H__
#include<engine/GLProgram.h>
#include<engine/GLTexture.h>
#include<map>
#include<string>
//ȫ�ֵ���
class  GLCacheManager
{
private:
	std::map<std::string, GLProgram *>  _glProgramCache;
	std::map<std::string, GLTexture *>   _glTextureCache;
//�Ƿ�����Ƕ�ĳ������
	std::map<std::string, int>      _glEmbedProgramSrc;
	unsigned                                   _bufferIdentity;//��λ���㻺��������
private:
	GLCacheManager(GLCacheManager &);
	GLCacheManager();
private:
	static    GLCacheManager              _glCacheManager;
//�������󻺴��м���������,ע��,�����ʹ���߲�Ҫ�����������,�������ֻ����GLProgram�е���
	friend     class    GLProgram;
	void                          inserGLProgram(std::string  &, GLProgram *);
public:
	static    GLCacheManager              *getInstance();
	~GLCacheManager();
//�������ֲ��ҳ������,���û���ҵ�,����NULL
	GLProgram            *findGLProgram(std::string  &);
//�������ַ����������,���û���ҵ�,����NULL
	GLTexture              *findGLTexture(std::string  &);
//��������
	void                          insertGLTexture(std::string &,GLTexture  *);
//���ص�λ���黺����
	unsigned                 loadBufferIdentity();
};
#endif