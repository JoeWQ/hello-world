/*
  *@aim:�������
  &2016-3-7 16:39:59
  */
#ifndef    __PROGRAM_OBJECT_H__
#define   __PROGRAM_OBJECT_H__
#include<GLES3/gl3.h>
#include"GLObject.h"
class      GLProgram:public    GLObject
{
private:
//�������
	         GLuint           _object;
//������ɫ��
			 GLuint           _vertex;
//Ƭ����ɫ��
			 GLuint           _frame;
private:
	         GLProgram(GLProgram &);
	         GLProgram();
//ʹ���ļ���ʼ��
			     bool          initWithFile(const   char    *vertex_file_name,const   char *frame_file_name);
//ʹ���ַ�����ʼ��
			     bool          initWithString(const  char  *vertex_string,const  char *frame_string);
public:
       static           GLProgram       *createWithFile(const   char    *vertex_file_name,const   char *frame_file_name);
       static           GLProgram       *createWithString(const  char  *vertex_string,const  char *frame_string);
			 ~GLProgram();
//��������,���ڱ任����,_attr_type:���������洢�ķ�ʽ
			 void          feedbackVaryingsWith(const  char *_varyings[],int   count,int   _attr_type);
//ʹ�ó������
			 void          enableObject();
//��ȡ�������,�˺����ӿ�ֻ���𷵻�����,�������𱣻�
			 GLuint      getObject();
//��ȡͳһ����λ��
			 GLuint      getUniformLocation(const  char  *);
};
//������ɫ��
static    GLuint         __compile_shader(GLenum    _type,const   char    *_shader_source);
//���ļ��ж�ȡ�ַ���
#endif