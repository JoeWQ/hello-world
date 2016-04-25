/*
  *@aim:程序对象实现
  &2016-3-7 16:47:14
  */
#include"help.h"
#include"GLProgram.h"
#include<assert.h>
#include<stdio.h>
  GLProgram::GLProgram()
  {
	         _object=0;
			     _vertex=0;
			     _frame=0;
  }
//析构
  GLProgram::~GLProgram()
  {
	         glDetachShader(_object,_vertex);
			     glDetachShader(_object,_frame);
			     glDeleteShader(_vertex);
			     glDeleteShader(_frame);
			     glDeleteProgram(_object);
			     _object=0;
  }
  GLProgram               *GLProgram::createWithFile(const   char    *vertex_file_name,const   char *frame_file_name)
 {
              GLProgram           *_glProgram=new           GLProgram();
              _glProgram->initWithFile(vertex_file_name,frame_file_name);
              return   _glProgram;
  }
//
  GLProgram              *GLProgram::createWithString(const  char  *vertex_string,const  char *frame_string)
 { 
             GLProgram           *_glProgram=new           GLProgram();
             _glProgram->initWithString(vertex_string,frame_string);
             return      _glProgram;
  }
//使用着色器对象
  void      GLProgram::enableObject()
  {
			       glUseProgram(_object);
  }
//获取程序对象,
  GLuint      GLProgram::getObject()
  {
	           return     _object;
  }
  //
  GLuint      GLProgram::getUniformLocation(const   char  *_name)
  {
	            return     glGetUniformLocation(_object,_name);
  }
//使用文件初始化
  bool      GLProgram::initWithFile(const  char  *_vertex_file,const   char  *_frame_file)
  {
	           const    char   *_vertex_buff=Help::getFileContent(_vertex_file);
			   const    char   *_frame_buff=Help::getFileContent(_frame_file);
			   assert(_vertex_buff && _frame_buff);

			   bool    _result=this->initWithString(_vertex_buff,_frame_buff);
			   delete    _vertex_buff;
			   delete    _frame_buff;
			   return    _result;
  }
//使用字符串
  bool      GLProgram::initWithString(const  char  *_vertex_string,const  char  *_frame_string)
  {
              _vertex=__compile_shader(GL_VERTEX_SHADER,_vertex_string);
			  _frame=__compile_shader(GL_FRAGMENT_SHADER,_frame_string);
//首先必须编译成功
			  assert(_vertex && _frame);
//创建程序对象
			  _object=glCreateProgram();
			  glAttachShader(_object,_vertex);
			  glAttachShader(_object,_frame);
//链接
			  GLint     _result;
			  glLinkProgram(_object);
			  glGetProgramiv(_object,GL_LINK_STATUS,&_result);
			  if( !_result  )//如果没有连接成功
			  {
				           GLint      _size=0;
						   glGetProgramiv(_object,GL_INFO_LOG_LENGTH,&_size);
						   if(_size>0)
						   {
						              char    *_buff=new   char[_size+2];
									  glGetProgramInfoLog(_object,_size+1,NULL,_buff);
									  _buff[_size]='\0';
									  printf("%s\n",_buff);
									  delete    _buff;
						   }
						   glDeleteProgram(_object);
						   _object=0;
						   assert(false);
			  }
			  return   true;
  }
  void          GLProgram::feedbackVaryingsWith(const char *_varyings[],int _count,int _attr_type)
  {
	             glTransformFeedbackVaryings(_object,_count,_varyings,_attr_type);
				 glLinkProgram(_object);
				 int       result=0;
				 glGetProgramiv(_object,GL_LINK_STATUS,&result);
				 if(!result)
				 { 
					          int          _size=0;
							  glGetProgramiv(_object,GL_INFO_LOG_LENGTH,&_size);
							  if(_size>0)
							  {
								            char     *buffer=new   char[_size+2];
											glGetProgramInfoLog(_object,_size+1,NULL,buffer);
											buffer[_size]='\0';
											printf("%s\n",buffer);
											delete    buffer;
							  }
							  glDeleteProgram(_object);
							  _object=0;
							  assert(0);
				 }
  }
//着色器编译
  GLuint      __compile_shader(GLenum _type,const char *_shader_source)
  {
//限定只能是定点着色器或者片段着色器
	         assert(_type==GL_VERTEX_SHADER|| _type==GL_FRAGMENT_SHADER);
			 GLuint     _shader=glCreateShader(_type);
			 assert(_shader);
//附着代码
			 glShaderSource(_shader,1,&_shader_source,NULL);
			 glCompileShader(_shader);
			 GLint    _result=0;
			 glGetShaderiv(_shader,GL_COMPILE_STATUS,&_result);
			 if( !_result  )
			 {
				            GLint      _size=0;
							char        *_buff=NULL;
							glGetShaderiv(_shader,GL_INFO_LOG_LENGTH,&_size);
							if(  _size>0 )
							{
								             _buff=new   char[_size+2];
							                 glGetShaderInfoLog(_shader,_size+1,NULL,_buff);
											 _buff[_size]='\0';
											 printf("%s\n",_buff);
											 delete     _buff;
							}
							glDeleteShader(_shader);
							_shader=0;
							assert(false);
			 }
			 return    _shader;
  }
