/*
  *@aim: ͳһ��������
  *2016-4-23
  */
#ifndef    __GLPROGRAM_STATE_H__
#define   __GLPROGRAM_STATE_H__
#include<map>
#include<string>
#include "UniformVariable.h"
#include "GLProgram.h"
 class    GLProgramState:public    GLObject
{
private:
         GLProgram                                                         *_glProgram;
         std::map<std::string,UniformVariable *>        _uniformVariables;
private:
         GLProgramState(GLProgramState &);
          GLProgramState(GLProgram   *);
          bool             initWithProgram(GLProgram   *);
public:
         static         GLProgramState       *createWithProgram(GLProgram  *);
         ~GLProgramState();
//����ͳһ������ֵ,���û���ҵ����ͳһ����,������ܻ�����
         void            setUniformFloat(const char  *,float *,int  count);
         void            setUniformInt(const char *,int  *,int  count);
//ʹ��
         void            apply();
 };
#endif