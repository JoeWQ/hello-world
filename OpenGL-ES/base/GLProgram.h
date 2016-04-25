/*
  *@aim:程序对象
  &2016-3-7 16:39:59
  */
#ifndef    __PROGRAM_OBJECT_H__
#define   __PROGRAM_OBJECT_H__
#include<GLES3/gl3.h>
#include"GLObject.h"
class      GLProgram:public    GLObject
{
private:
//程序对象
	         GLuint           _object;
//顶点着色器
			 GLuint           _vertex;
//片段着色器
			 GLuint           _frame;
private:
	         GLProgram(GLProgram &);
	         GLProgram();
//使用文件初始化
			     bool          initWithFile(const   char    *vertex_file_name,const   char *frame_file_name);
//使用字符串初始化
			     bool          initWithString(const  char  *vertex_string,const  char *frame_string);
public:
       static           GLProgram       *createWithFile(const   char    *vertex_file_name,const   char *frame_file_name);
       static           GLProgram       *createWithString(const  char  *vertex_string,const  char *frame_string);
			 ~GLProgram();
//二次链接,用于变换反馈,_attr_type:反馈变量存储的方式
			 void          feedbackVaryingsWith(const  char *_varyings[],int   count,int   _attr_type);
//使用程序对象
			 void          enableObject();
//获取程序对象,此函数接口只负责返回数据,但不负责保护
			 GLuint      getObject();
//获取统一变量位置
			 GLuint      getUniformLocation(const  char  *);
};
//编译着色器
static    GLuint         __compile_shader(GLenum    _type,const   char    *_shader_source);
//从文件中读取字符串
#endif