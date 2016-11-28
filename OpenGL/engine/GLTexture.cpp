/*
 *OpenGL纹理实现
 *2016-6-14 20:38:16
  */
#include<engine/GLTexture.h>
#include<engine/Tools.h>
#include<engine/GLCacheManager.h>
#include<GL/glew.h>
#include<stdio.h>
#include<assert.h>
GLTexture::GLTexture()
{
	_textureId = 0;
	_contentSize.width=0.0f;
	_contentSize.height = 0.0f;
}
//
GLTexture::~GLTexture()
{
	glDeleteTextures(1, &_textureId);
	_textureId = 0;
}
//返回大小
float         GLTexture::getWidth()
{
	return _contentSize.width;
}
float    GLTexture::getHeight()
{
	return _contentSize.height;
}
Size&    GLTexture::getContentSize()
{
	return  _contentSize;
}
unsigned int         GLTexture::name()
{
	return _textureId;
}
//
GLTexture     *GLTexture::createWithFile(const char *_file_name)
{
	GLTexture   *_texture ;
	assert(_file_name);
#ifdef __ENABLE_TEXTURE_CACHE__
	std::string   _key(_file_name);
	_texture = GLCacheManager::getInstance()->findGLTexture(_key);
	if (_texture)
	{
		_texture->retain();
		return  _texture;
	}
#endif
	_texture=new   GLTexture();
	_texture->initWithFile(_file_name);
#ifdef __ENABLE_TEXTURE_CACHE__
	GLCacheManager::getInstance()->insertGLTexture(_key,_texture);
	_texture->retain();
#endif
	return  _texture;
}
//用给定的文件创建纹理
void        GLTexture::initWithFile(const char *_file_name)
{
	int   width, height, depth;
	char  *buffer =Tools::loadImage(_file_name, &width, &height, &depth);
	if (!buffer)
	{
		printf("file '%s' do not exist,please check it.",_file_name);
		assert(0);
	}
	_contentSize.width = width;
	_contentSize.height = height;
	static   int   formal_table[5] = {0,GL_RED,0,GL_RGB,GL_RGBA};
	static      int       other_table[5] = { 0, GL_RED, 0, GL_RGB, GL_RGBA };
//创建纹理对象
	const        int       _format_type = formal_table[depth>>3];
	assert(_format_type);
//	float          _maxAnisotropy = 0.0f;
//	glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &_maxAnisotropy);

	glGenTextures(1, &_textureId);
	glBindTexture(GL_TEXTURE_2D, _textureId);
	glTexImage2D(GL_TEXTURE_2D, 0, other_table[depth >> 3], width, height, 0, _format_type, GL_UNSIGNED_BYTE, buffer);
//生成的图的质量最好,但是注意一定要同时调用glGenerateMipmap函数
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glGenerateMipmap(GL_TEXTURE_2D);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//各向异性过滤
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, _maxAnisotropy);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glBindTexture(GL_TEXTURE_2D,0);
	delete buffer;
	buffer = NULL;
}

void        GLTexture::setWrapParam(unsigned wrap_param, unsigned _param)
{
	int   _default_textureId;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &_default_textureId);
	glBindTexture(GL_TEXTURE_2D, _textureId);
	glTexParameteri(GL_TEXTURE_2D, wrap_param, _param);
	glBindTexture(GL_TEXTURE_2D, _default_textureId);
}
void        GLTexture::genMipmap()
{
	glBindTexture(GL_TEXTURE_2D, _textureId);
	glGenerateMipmap(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, 0);
}

GLCubeMap::GLCubeMap()
{
	_cubeMapId = 0;
}
GLCubeMap::~GLCubeMap()
{
	glDeleteTextures(1, &_cubeMapId);
	_cubeMapId = 0;
}

void        GLCubeMap::initWithEmpty(Size &contentSize)
{
	int      _default_cubemapId;
	glGetIntegerv(GL_TEXTURE_BINDING_CUBE_MAP, &_default_cubemapId);

	glGenTextures(1, &_cubeMapId);
	glBindTexture(GL_TEXTURE_CUBE_MAP, _cubeMapId);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
//方向
	for (int i = 0; i < 6; ++i)
		glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X+i, 0, GL_DEPTH_COMPONENT, contentSize.width, contentSize.height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);

	glBindTexture(GL_TEXTURE_CUBE_MAP, _default_cubemapId);
	_contentSize = contentSize;
}

void        GLCubeMap::initWithFiles(const char **file_list)
{
	int      _default_cubemapId;
	glGetIntegerv(GL_TEXTURE_BINDING_CUBE_MAP, &_default_cubemapId);

	glGenTextures(1, &_cubeMapId);
	glBindTexture(GL_TEXTURE_CUBE_MAP, _cubeMapId);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
	//方向
	const int         cubeMapEnum[6] = {
		GL_TEXTURE_CUBE_MAP_POSITIVE_X,//0
		GL_TEXTURE_CUBE_MAP_NEGATIVE_X,//1
		GL_TEXTURE_CUBE_MAP_POSITIVE_Y,//2
		GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,//3
		GL_TEXTURE_CUBE_MAP_POSITIVE_Z,//4
		GL_TEXTURE_CUBE_MAP_NEGATIVE_Z,//5
	};
	for (int i = 0; i < 6; ++i)
	{
		int       width, height, bitDepth;
		const   char   *buffer = Tools::loadImage(file_list[i], &width, &height, &bitDepth);
		int      type = bitDepth == 24 ? GL_RGB : GL_RGBA;
		glTexImage2D(cubeMapEnum[i], 0, type, width, height, 0, type, GL_UNSIGNED_BYTE, buffer);
		delete buffer;
	}
	//	glGenerateMipmap(GL_TEXTURE_CUBE_MAP);
	glBindTexture(GL_TEXTURE_CUBE_MAP, _default_cubemapId);
}

unsigned     GLCubeMap::name()
{
	return  _cubeMapId;
}

GLCubeMap         *GLCubeMap::createEmptyMap(Size &contentSize)
{
	GLCubeMap    *_cubeMap = new    GLCubeMap();
	_cubeMap->initWithEmpty(contentSize);
	return  _cubeMap;
}

GLCubeMap        *GLCubeMap::createWithFiles(const char **file_list)
{
	GLCubeMap       *_cubeMap = new    GLCubeMap();
	_cubeMap->initWithFiles(file_list);
	return  _cubeMap;
}