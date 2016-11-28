/*
 *OpenGL程序对象,纹理对象缓存实现
 *2016-6-17 18:47:11
 *version:1.0
 *小花熊
  */
#include<GL/glew.h>
#include<engine/GLCacheManager.h>
#include<engine/GLState.h>
#include<assert.h>
GLCacheManager    GLCacheManager::_glCacheManager;
//内嵌的程序对象源代码
//普通着色器
static   const  char  *_OpenGLSpriteProgram_Vert =
                                  "#version 330 core\n" \
                                  "precision highp float;\
                                   uniform  mat4   u_mvMatrix;  \
                                   layout(location=0)in   vec4    a_position;\
                                    layout(location = 1)in   vec2    a_texCoord;\
                                    out       vec2       v_texCoord;\
                                 \
                                   void  main()\
                                 {\
	                                      gl_Position = u_mvMatrix*a_position;\
	                                      v_texCoord = a_texCoord;\
	                              }"; 
static   const  char   *_OpenGLSpriteProgram_Frag =
                              "#version 330 core\n" \
							  "precision highp float;\
                               uniform   vec4      u_renderColor;                 \
                               uniform     sampler2D     u_baseMap;\
                                layout(location = 0)out     vec4    outColor;\
                                in       vec2     v_texCoord;\
                              \
                                void    main()\
                              {\
	                                  outColor = texture(u_baseMap, v_texCoord)*u_renderColor;\
                               }";
//一般光照着色器
 static   const   char      *_OpenGLNormalLightProgram_Vert =
                            "#version 330 core\n" \
                            "precision  highp  float;\
                             uniform                  mat4      u_mvpMatrix;\
							 uniform                  mat3      u_normalMatrix;\
                             layout(location = 0)in     vec4      a_position;\
                             layout(location = 1)in     vec2      a_texCoord;\
                             layout(location = 2)in     vec3      a_normal;\
							 out     vec2    v_texCoord;\
							 out     vec3    v_normal;\
							 void    main()\
							 {\
									v_normal=normalize(u_normalMatrix*a_normal);\
									\
									v_texCoord = a_texCoord;\
									gl_Position = u_mvpMatrix*a_position;\
							}";
 static   const   char      *_OpenGLNormalLightProgram_Frag = 
	                    "#version 330 core\n" \
	                     "precision    highp    float;\
	                      uniform      sampler2D       u_baseMap;\
                          uniform      vec4                  u_lightColor;\
						  uniform      vec3                  u_lightDir;\
                          layout(location = 0)out      vec4     outColor;\
                          in           vec2            v_texCoord;\
                          in           vec3            v_normal;\
                           \
                         void     main()\
                       {\
	                         vec4      baseColor = texture(u_baseMap, v_texCoord);\
	                         float     dotL = max(0.0, dot(normalize(v_normal), u_lightDir));\
	                          \
	                        outColor = baseColor*vec4(0.10, 0.10, 0.10, 0.10) + dotL*baseColor*u_lightColor;\
                       }";
//点光源着色器

//记录程序对象源代码的记录表
struct   __ProgramSrcRecord
{
	const  char  *vert_src;
	const  char  *frag_src;
};
static   __ProgramSrcRecord      __EmbedProgramTable[] = {
		                   {_OpenGLSpriteProgram_Vert,_OpenGLSpriteProgram_Frag},
						   {_OpenGLNormalLightProgram_Vert,_OpenGLNormalLightProgram_Frag},
                             };
GLCacheManager::GLCacheManager()
{
	_glEmbedProgramSrc[OpenGLSpriteProgram] = 0;
	_glEmbedProgramSrc[OpenGLNormalLightProgram] = 1;
	_bufferIdentity = 0;
}
GLCacheManager::~GLCacheManager()
{
//删除程序对象
	std::map<std::string, GLProgram *>::iterator   _it = _glProgramCache.begin();
	while (_it != _glProgramCache.end())
	{
		_it->second->release(); 
		++_it;
	}
//删除纹理对象
	std::map<std::string, GLTexture	*>::iterator  _texture_it = _glTextureCache.begin();
	while (_texture_it != _glTextureCache.end())
	{
		_texture_it->second->release();
		_texture_it++;
	}
	_glProgramCache.clear();
	_glTextureCache.clear();
	if (_bufferIdentity)
		glDeleteBuffers(1, &_bufferIdentity);
}
GLCacheManager    *GLCacheManager::getInstance()
{
	return &_glCacheManager;
}

//给定键值查找程序对象
GLProgram	*GLCacheManager::findGLProgram(std::string    &key)
{
//首先查找是否存在该程序对象
	std::map<std::string, GLProgram *>::iterator   _it = _glProgramCache.find(key);
	if (_it != _glProgramCache.end())
		    return  _it->second;
//如过没有找到,查看是否内嵌的程序对象
	std::map<std::string, int>::iterator  _minor_it = _glEmbedProgramSrc.find(key);
	if (_minor_it != _glEmbedProgramSrc.end())
	{
		int      _index = _minor_it->second;
		GLProgram   *_glProgram = GLProgram::createWithString(__EmbedProgramTable[_index].vert_src, __EmbedProgramTable[_index].frag_src);
		_glProgramCache[key] = _glProgram;//不会对引用计数加1操作
		_glProgram->retain();
		return   _glProgram;
	}
	return NULL;
}
//向缓存中加入程序对象
void           GLCacheManager::inserGLProgram(std::string &key, GLProgram *glProgram)
{
	std::map<std::string, GLProgram *>::iterator    it = _glProgramCache.find(key);
	assert(it == _glProgramCache.end());
	_glProgramCache[key] = glProgram;
}
//与程序对象不同,纹理对象没有内嵌的
GLTexture       *GLCacheManager::findGLTexture(std::string &key)
{
	std::map<std::string, GLTexture	*>::iterator _it = _glTextureCache.find(key);
	if (_it != _glTextureCache.end())
		return  _it->second;
	return NULL;
}
//插入纹理
void        GLCacheManager::insertGLTexture(std::string &key,GLTexture *glTexture)
{
        std::map<std::string,GLTexture *>::iterator  it=_glTextureCache.find(key);
		assert(it == _glTextureCache.end());
		_glTextureCache[key]=glTexture;
}

unsigned      GLCacheManager::loadBufferIdentity()
{
	if (!_bufferIdentity)
	{
		int         _default_bufferId;
		glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &_default_bufferId);
		float     _VertexData[20] = {
			-1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
			-1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
			1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
			1.0f, -1.0f, 0.0f, 1.0f, 0.0f, 
		};
		glGenBuffers(1, &_bufferIdentity);
		glBindBuffer(GL_ARRAY_BUFFER, _bufferIdentity);
		glBufferData(GL_ARRAY_BUFFER, sizeof(_VertexData), _VertexData, GL_STATIC_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, _default_bufferId);
	}
	return _bufferIdentity;
}